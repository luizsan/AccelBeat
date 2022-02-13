local t = Def.ActorFrame{}

-- #====================================================================================================================
-- # Song Indexing & Browsing
-- #====================================================================================================================

local INSPECT = LoadModule("inspect.lua")

local MaximumRows = 15
local MaximumPerRow = {
    Song = 5,
    Folder = 1,
    Sort = 3
}

local Grid = { 
    slots = { x = math.max( MaximumPerRow.Song, MaximumPerRow.Folder, MaximumPerRow.Sort ), y = MaximumRows },
    size = {
        Song = { x = 180, y = 135 },
        Folder = { x = 500, y = 56 },
        Sort = { x = 192, y = 48 },
    },
    spacing = { x = 24, y = 12 },
    offset = { x = 0, y = 24 },
    middle = { x = 0, y = 0 },
    colors = {
        Song = BoostColor( Color.White, 0.4 ),
        Folder = { 0.090196, 0.0223529, 0.6, 1 },
        Sort = { 0.184313, 0.447058, 0.749019, 1 },
    },

    transition = {
        slow = math.random(2,5),
        medium = math.random(2,5),
        fast = math.random(2,5),
    }
}

Grid.middle.x = math.ceil( Grid.slots.x / 2 )
Grid.middle.y = math.ceil( Grid.slots.y / 2 )

local Scrollbar = {
    size = { x = 6, y = 540 },
    position = { x = SCREEN_RIGHT-32, y = SCREEN_CENTER_Y + 56 }
}

local SortMode = {
    All = "All",
    Title = "Title",
    Artist = "Artist",
    Group = "Group",
    Level = "Level"
}

local ItemType = {
    Song = "Song",
    Folder = "Folder",
    Sort = "Sort",
}

local AlphabetSort = {
    "ABCD",
    "EFGH",
    "IJKL",
    "MNOP",
    "QRST",
    "UVWXYZ",
    "Others"
}

local song_data = {}
local song_folders = {}
local song_levels = {}

local current_index = { x = 1, y = 1 }
local current_folder = "Luizsan"
local current_sort = SortMode.Group
local current_items = {}
local current_rows = {}
local current_songs = {}

local current_row = nil
local current_item = nil
local current_column = 1

local first_song_row = -1

local coords_table = {}
local coords_direction = 0
local grid_height = 0

if not banner_cache then
    banner_cache = nil
end

function GetCurrentIndex() return current_index end
function GetCurrentRow(index)
    while index < 1 and #current_rows > 0 do index = index + #current_rows end
    while index > #current_rows and #current_rows > 0 do index = index - #current_rows end
    return current_rows[index] or nil
end

function GetCurrentItem(row)
    return row and row[ clamp(current_index.x, 1, #row) ] or nil
end

function GetRowIndex(type, content)
    for i, r in ipairs(current_rows) do
        for c = 1, #r do 
            if r[c].type == type and r[c].content == content then return i end
        end
    end
    return -1
end

function LoadData()
    song_data.all = FilterSongs( SONGMAN:GetAllSongs() )
    song_data.title = {}
    song_data.artist = {}
    song_data.group = {}
    song_data.level = {}

    song_folders = SONGMAN:GetSongGroupNames()

    for i, song in ipairs(song_data.all) do
        
        -- first of all, check if the song has playable steps
        local steps = FilterSteps(song)

        if #steps > 0 then
            AddSongToFolder(song)
            AddSongToLevelGroup(song, steps)
            AddSongToMetaGroup(song)
        end
    end

    SortDataCollections()
end

function AddSongToFolder(song)
    local _folder = song:GetGroupName()
    if not song_data.group[_folder] then
        song_data.group[_folder] = {}
    end
    table.insert( song_data.group[_folder], song )
end

function AddSongToLevelGroup(song, steps)
    for i, st in ipairs(steps) do
        local meter = st:GetMeter()

        if not song_data.level[ meter ] then
            song_data.level[ meter ] = {}
            song_levels[#song_levels+1] = meter
        end

        if not table.contains( song_data.level[ meter ], song ) then
            table.insert( song_data.level[ meter ], song )
        end
    end
end

function AddSongToMetaGroup(song)
    local inserted_title = false
    local inserted_artist = false

    -- do not iterate last element
    for k = 1, #AlphabetSort-1 do
        local keys = AlphabetSort[k]
        if not song_data.title[keys] then song_data.title[keys] = {} end
        if not song_data.artist[keys] then song_data.artist[keys] = {} end

        for k = 1, #keys do
            -- title
            if string.startswith( song:GetTranslitMainTitle():lower(), string.sub(keys, k, k):lower() ) then
                table.insert( song_data.title[keys], song )
                inserted_title = true
            end
            
            -- artist
            if string.startswith( song:GetTranslitArtist():lower(), string.sub(keys, k, k):lower() ) then
                table.insert( song_data.artist[keys], song )
                inserted_artist = true
            end
        end
    end

    if not inserted_title then 
        if not song_data.title["Others"] then song_data.title["Others"] = {} end
        table.insert( song_data.title["Others"], song ) 
    end
    
    if not inserted_artist then 
        if not song_data.artist["Others"] then song_data.artist["Others"] = {} end
        table.insert( song_data.artist["Others"], song ) 
    end
end

function SortDataCollections()
    -- group
    for k, v in ipairs( song_data.group ) do
        song_data.group[k] = table.sort( song_data.group[k], SortSongsByTitle )
    end
    
    -- artist/title
    for k, v in ipairs(AlphabetSort) do
        table.sort( song_data.title[v], SortSongsByTitle )
        table.sort( song_data.artist[v], SortSongsByArtist )
    end
    
    -- level
    table.sort( song_levels )
    for k, v in ipairs( song_levels ) do
        table.sort( song_data.level[v], SortSongsByTitle )
    end
end


function AddSongsToGrid(list)
    for i, song in ipairs( list ) do 
        table.insert( current_items, { type = ItemType.Song, content = song })
    end
end


function BuildItems()
    current_items = {}
    current_songs = {}

    -- sort modes
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.All })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Title })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Artist })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Group })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Level })

    -- all songs
    if current_sort == SortMode.All then
        current_songs = song_data.all
        AddSongsToGrid(current_songs)

    -- folders
    elseif current_sort == SortMode.Group then
        for i, folder in ipairs(song_folders) do 
            if song_data.group[folder] and #song_data.group[folder] > 0 then
                table.insert( current_items, { type = ItemType.Folder, content = folder, num_songs = song_data.group[folder] and #song_data.group[folder] or 0 })
                if current_folder and current_folder == folder and song_data.group[current_folder] then
                    AddSongsToGrid( song_data.group[current_folder] )
                end
            end
        end

    elseif current_sort == SortMode.Title then 
        for i, keys in ipairs( AlphabetSort ) do 
            table.insert( current_items, { type = ItemType.Folder, content = keys, num_songs = song_data.title[keys] and #song_data.title[keys] or 0 })
            if current_folder and current_folder == keys and song_data.title[keys] then
                AddSongsToGrid( song_data.title[keys] )
            end
        end

    elseif current_sort == SortMode.Artist then
        for i, keys in ipairs( AlphabetSort ) do 
            table.insert( current_items, { type = ItemType.Folder, content = keys, num_songs = song_data.artist[keys] and #song_data.artist[keys] or 0 })
            if current_folder and current_folder == keys and song_data.artist[keys] then
                AddSongsToGrid( song_data.artist[keys] )
            end
        end

    elseif current_sort == SortMode.Level then
        for i, v in ipairs( song_levels ) do 
            table.insert( current_items, { type = ItemType.Folder, content = v, num_songs = song_data.level[v] and #song_data.level[v] or 0 })
            if current_folder and current_folder == v and song_data.level[v] and #song_data.level[v] > 0 then
                AddSongsToGrid( song_data.level[v] )
            end
        end
    end
    
end


function BuildRows()
    current_rows = {}

    local row_count = 1
    local col_count = 1
    local col_target = 0

    local prev_data = nil
    local cur_data = nil

    for i = 1, #current_items do
        cur_data = current_items[i]
        col_target = MaximumPerRow[cur_data.type]

        if i > 1 then
            if prev_data and cur_data.type ~= prev_data.type then
                col_count = 1
                row_count = row_count + 1
            else
                if col_count > col_target then
                    col_count = 1;
                    row_count = row_count + 1;
                end
            end
        end

        if #current_rows < row_count then
            current_rows[row_count] = {}
        end

        table.insert( current_rows[row_count], cur_data )
        col_count = col_count + 1
        prev_data = cur_data

        -- index first row containing a song
        if first_song_row < 0 and cur_data.type == ItemType.Song then
            first_song_row = row_count
        end
    end
end

function UpdateGridCoords()
    local total_height = 0
    for y = 1, Grid.slots.y do
        coords_table[y] = {}
        
        local row = GetCurrentRow(y + current_index.y - Grid.middle.y)
        local type = row[1].type 
        local item_width = Grid.size[type].x + Grid.spacing.x
        local item_height = Grid.size[type].y + Grid.spacing.y

        for x = 1, Grid.slots.x do
            coords_table[y][x] = {}

            local center_align = #row % 2 == 0 and 0.5 or 0
            local item_offset = (Grid.slots.x - #row) / 2.0

            coords_table[y][x].x = SCREEN_CENTER_X + ((x - Grid.middle.x) * item_width) + Grid.offset.x + (item_offset * item_width)
            coords_table[y][x].y = total_height
            coords_table[y][x].width = Grid.size[type].x
            coords_table[y][x].height = Grid.size[type].y
            coords_table[y][x].active = x <= #row
            coords_table[y][x].type = type

        end

        total_height = total_height + item_height
    end

    grid_center = coords_table[Grid.middle.y][1].y + (coords_table[Grid.middle.y][1].height * 0.5)
end


function GridInputController(context)
    if not context then return end

    coords_direction = 0

    local prev_row = GetCurrentRow(current_index.y)
    local sort_changed = false

    if context.Button == "Up" then 
        current_index.y = current_index.y - 1 
        coords_direction = -1
    end
    
    if context.Button == "Down" then 
        current_index.y = current_index.y + 1 
        coords_direction = 1
    end
    
    if context.Button == "Left" then 
        current_index.x = clamp(current_index.x, 1, #prev_row) - 1 
        if current_index.x < 1 then WrapBackward() end
    end
    
    if context.Button == "Right" or context.Input == "Options" then 
        current_index.x = clamp(current_index.x, 1, #prev_row) + 1 
        if current_index.x > #prev_row then WrapForward() end
    end
    
    if current_index.y > #current_rows then 
        current_index.y = 1 
        coords_direction = 1
    end
    
    if current_index.y < 1 then 
        current_index.y = #current_rows 
        coords_direction = -1
    end

    current_row = GetCurrentRow(current_index.y)
    current_item = GetCurrentItem(current_row)
    current_column = clamp(current_index.x, 1, #current_row)

    if current_item and current_item.type and current_item.type == ItemType.Song then
        GAMESTATE:SetCurrentSong( current_item.content )
    end

    if context.Input == "Sort" then 
        SCREENMAN:SystemMessage("SORT")
    end

    if context.Input == "Center" or context.Input == "Start" then
        if current_item then
            if current_item.type == ItemType.Sort and current_sort ~= current_item.content then
                current_sort = current_item.content
                sort_changed = true

            elseif current_item.type == ItemType.Folder then
                if current_folder == current_item.content then
                    current_folder = nil
                else
                    current_folder = current_item.content
                    sort_changed = true
                end
            elseif current_item.type == ItemType.Song then
                SetSong( current_item.content )
            end
            
            -- deep copy data to save item position after grid is changed
            local _type = current_item.type
            local _content = current_item.content
            
            BuildItems()
            BuildRows()
            
            local index = GetRowIndex(_type, _content)
            if index > 0 then
                current_index.y = index
            end
        end
    end


    UpdateGridCoords()
    MESSAGEMAN:Broadcast("GridScroll")

    if sort_changed then
        MESSAGEMAN:Broadcast("SortChanged", { item = current_item, sort = current_sort })
    end

    if current_item and not (context.Input == "Center" or context.Input == "Start") then
        GAMESTATE:SetCurrentSong( current_item.type == ItemType.Song and current_item.content or nil )
        MESSAGEMAN:Broadcast("GridSelected", { item = current_item, sort = current_sort })
    end
end


function SetSong(song)
    GAMESTATE:SetCurrentSong(song)
    SelectMusic.state = 1
    SelectMusic.steps = FilterSteps(song)
    MESSAGEMAN:Broadcast("SongChosen")
    MESSAGEMAN:Broadcast("StateChanged")
end


function WrapForward()
    coords_direction = 1
    current_index.y = current_index.y + 1
    current_index.x = 1 
    if current_index.y > #current_rows then 
        current_index.y = 1 
    end
end


function WrapBackward()
    coords_direction = -1
    current_index.y = current_index.y - 1
    current_index.x = #GetCurrentRow(current_index.y)
    if current_index.y < 1 then 
        current_index.y = #current_rows 
    end
end


function ItemDelay(x, y)
    return (math.abs(y - Grid.middle.y) * 0.075) + (x * 0.075) * 0.75
end


function SetupGrid()
    LoadData()
    BuildItems()
    BuildRows()
    
    current_index.y = first_song_row
    UpdateGridCoords()

    GridInputController({})
    MESSAGEMAN:Broadcast("SortChanged", { item = current_item, sort = current_sort })
end


-- grid
for y = 1, Grid.slots.y do
    for x = 1, Grid.slots.x do
        t[#t+1] = Def.ActorFrame{
            Name = "Item"..tostring(#t+1),
            OnCommand=function(self)
                self:playcommand("GridScroll") 
            end,

            GridScrollMessageCommand=function(self)
                local _offset = coords_table[Grid.middle.y][1].height * coords_direction
                local _coord = SCREEN_CENTER_Y + coords_table[y][x].y + Grid.offset.y - grid_center
                
                self:visible(coords_table[y][x].active)

                if SelectMusic.state == 1 then
                    self:stoptweening()
                else
                    self:finishtweening()
                end
                
                self:xy(coords_table[y][x].x, _coord):addy(_offset)
                self:decelerate(0.125)
                self:y(_coord)
            end,

            SortChangedMessageCommand=function(self)
                local coord = coords_table[y][x]
                if coord and coord.type and coord.type == ItemType.Song then
                    self:finishtweening()
                    self:rotationx(90)
                    self:sleep(ItemDelay(x,y) * 0.5)
                    self:decelerate(0.1)
                    self:rotationx(0)
                end
            end,
            
            -- base quad
            Def.Quad{
                Name = "Quad",
                InitCommand=function(self)
                    self:diffuse( x / Grid.slots.x, y / Grid.slots.y, 0, 1)
                    self:shadowcolor(0,0,0,0.25):shadowlength(5)
                    self:valign(0)
                end,
                
                OnCommand=function(self)
                    self:playcommand("GridScroll")
                end,

                StateChangedMessageCommand=function(self) 
                    if SelectMusic.state == 0 then
                        self:finishtweening()
                        self:sleep(ItemDelay(x,y))
                        self:decelerate(0.1)
                        self:rotationx(0)
                    else
                        self:finishtweening()
                        self:sleep(ItemDelay(x,y))
                        self:decelerate(0.1)
                        self:rotationx(90)
                    end
                end,    

                GridScrollMessageCommand=function(self)
                    local coord = coords_table[y][x]
                    if SelectMusic.state == 0 then
                        self:finishtweening()
                    end
                    
                    self:zoomto(coord.width, coord.height)
                    if current_column == x and Grid.middle.y == y then
                        self:diffuse( Color.White )
                    else
                        local type = coords_table[y][x].type
                        self:diffuse( Grid.colors[type] )
                    end
                end
            },
            

            Def.Banner{
                Name = "Banner",
                InitCommand=function(self)
                    self:valign(0)
                end,
                
                OnCommand=function(self)
                    self:playcommand("GridScroll")
                end,

                StateChangedMessageCommand=function(self) 
                    if SelectMusic.state == 0 then
                        self:finishtweening()
                        self:sleep(ItemDelay(x,y))
                        self:decelerate(0.1)
                        self:rotationx(0)
                    else
                        self:finishtweening()
                        self:sleep(ItemDelay(x,y))
                        self:decelerate(0.1)
                        self:rotationx(90)
                    end
                end,   
        
                GridScrollMessageCommand=function(self)
                    if SelectMusic.state == 0 then
                        self:finishtweening()
                    end

                    self:Load(nil)
        
                    local selected = current_column == x and Grid.middle.y == y
                    local item = GetCurrentRow( y + current_index.y - Grid.middle.y )[x]
        
                    if not item or item.type ~= ItemType.Song then 
                        self:Load(nil)
                    else
                        -- local path = item.content:GetBannerPath()
                        -- if path then
                        --     if not BANNER_CACHE[path] then
                        --         self:LoadFromCachedBanner(path)
                        --         BANNER_CACHE[path] = self:GetTexture()
                        --     else
                        --         self:SetTexture( BANNER_CACHE[path] )
                        --     end
                        -- else
                            self:Load(THEME:GetPathG("", "patterns/noise"))
                            self:customtexturerect(0,0, 128 / self:GetWidth(), 128 / self:GetHeight())
                            self:texcoordvelocity(80,120)
                        -- end
                    end
        
                    self:scaletoclipped(Grid.size.Song.x, Grid.size.Song.y)
                    self:diffuse( selected and Color.White or Grid.colors.Song )
                    self:glow( selected and {1,1,1,1} or {0,0,0,0} )
                end,
            },
            

            Def.BitmapText{
                Name = "Label",
                Font = "NewRodinB-24",
                InitCommand=function(self) 
                    self:shadowlength(1)
                end,
                
                OnCommand=function(self)
                    self:playcommand("GridScroll") 
                end,

                StateChangedMessageCommand=function(self) 
                    if SelectMusic.state == 0 then
                        self:finishtweening()
                        self:sleep(ItemDelay(x,y))
                        self:decelerate(0.1)
                        self:rotationx(0)
                    else
                        self:finishtweening()
                        self:sleep(ItemDelay(x,y) * 0.5)
                        self:decelerate(0.1)
                        self:rotationx(90)
                    end
                end,

                GridScrollMessageCommand=function(self)
                    if SelectMusic.state == 0 then
                        self:finishtweening()
                    end

                    self:y(coords_table[y][x].height * 0.5):addy(-2)

                    local selected = current_column == x and Grid.middle.y == y
                    local item = GetCurrentRow(y + current_index.y - Grid.middle.y)[x]

                    if not item then 
                        self:settext("") 
                    else
                        if item.type == ItemType.Song then
                            -- local path = item.content:GetBannerPath()
                            -- self:visible(path == nil)
                            self:zoom(0.5)
                            self:maxwidth( Grid.size.Song.x * 2 - 32)
                            self:wrapwidthpixels( Grid.size.Song.x * 2 - 32)
                            self:settext( item.content:GetDisplayMainTitle())
                        else
                            -- self:visible(true)
                            self:zoom(0.65)
                            self:maxwidth( Grid.size[item.type].x * 1.5 - 32)
                            self:wrapwidthpixels( Grid.size[item.type].x * 1.5 - 32)
                            self:settext( item.content )
                        end
                    end

                    self:diffuse( selected and Color.Blue or Color.White )
                    self:shadowcolor( selected and {0,0,0,0} or BoostColor( Color.Black, 0.25 ))
                end
            }
        }
    end
end

-- scrollbar
t[#t+1] = Def.ActorFrame{
    Name = "Scrollbar",
    Def.Quad{
        InitCommand=function(self)
            self:zoomto(Scrollbar.size.x, Scrollbar.size.y)
            self:diffuse(0,0,0,0.25)
            self:x(Scrollbar.position.x)
            self:y(Scrollbar.position.y)
        end,

    },

    Def.Quad{
        InitCommand=function(self) self:playcommand("GridScroll") end,
        GridScrollMessageCommand=function(self)
            local size = clamp(5 / #current_rows, 0, 1)
            local progress = (current_index.y-1) / clamp(#current_rows-1, 1, math.huge)
            local top = Scrollbar.position.y - (Scrollbar.size.y * 0.5)
            local bottom = Scrollbar.position.y + (Scrollbar.size.y * 0.5)

            local final_size = Scrollbar.size.y * size
            self:zoomto( Scrollbar.size.x, final_size )
            self:x( Scrollbar.position.x )
            self:y( lerp(progress, top + (final_size * 0.5), bottom - (final_size * 0.5)) )
        end,
    },
}

return t