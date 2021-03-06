local t = Def.ActorFrame{}

-- #====================================================================================================================
-- # Song Indexing & Browsing
-- #====================================================================================================================

local INSPECT = LoadModule("inspect.lua")

local MaximumRows = 15
local MaximumPerRow = {
    Song = 5,
    Folder = 1,
    Filter = 1,
    Sort = 3
}

local Grid = { 
    slots = { x = math.max( MaximumPerRow.Song, MaximumPerRow.Folder, MaximumPerRow.Sort ), y = MaximumRows },
    size = {
        Song = { x = 180, y = 135 },
        Folder = { x = 500, y = 56 },
        Sort = { x = 192, y = 48 },
        Filter = { x = 256, y = 48 },
    },
    spacing = { x = 16, y = 10 },
    offset = { x = 0, y = 24 },
    middle = { x = 0, y = 0 },
    padding = {
        Song = 64,
    },
    colors = {
        Song = BoostColor( Color.White, 0.4 ),
        Folder = { 0.090196, 0.0223529, 0.6, 1 },
        Sort = { 0.184313, 0.447058, 0.749019, 1 },
        Filter = { 0.5, 0.3, 0.9, 1 },
    },
}

Grid.middle.x = math.ceil( Grid.slots.x / 2 )
Grid.middle.y = math.ceil( Grid.slots.y / 2 )

local Scrollbar = {
    size = { x = 6, y = 540 },
    position = { x = SCREEN_RIGHT-32, y = SCREEN_CENTER_Y + 56 }
}

local master = GAMESTATE:GetMasterPlayerNumber()
local profile_dir = GetPlayerOrMachineProfileDir(master)

local preferred_song = GAMESTATE:GetPreferredSong() or GAMESTATE:GetCurrentSong()
if not preferred_song and PROFILEMAN:IsPersistentProfile(master) then
    preferred_song = PROFILEMAN:GetProfile(master):GetLastPlayedSong()
end

local found_song = false

local song_data = {}
local song_folders = {}
local song_levels = {}

local current_rows = {}
local current_songs = {}
local current_items = {}
local current_index = { x = 1, y = 1 }

local prev_row = nil
local current_item = nil
local current_row = nil
local current_column = 1
local first_song_row = -1

local coords_table = {}
local coords_direction = 0
local grid_height = 0

if not banner_cache then
    banner_cache = nil
end

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
            if r[c].type == type and r[c].content == content then return i, c end
        end
    end
    return -1, -1
end


function InitializeGrid()
    SelectMusic.state = 0

    local pref_sort = LoadModule("Config.Load.lua")("SortMode", profile_dir.."/"..ThemeConfigDir)
    local pref_folder = LoadModule("Config.Load.lua")("Folder", profile_dir.."/"..ThemeConfigDir)

    if pref_sort then
        SelectMusic.currentFolder = pref_folder or preferred_song:GetGroupName()
        if pref_sort == SortMode.Search and #SelectMusic.searchResults < 1 then
            SelectMusic.currentSort = SortMode.Group
        else
            SelectMusic.currentSort = pref_sort
        end
    end

    if GAMESTATE:GetNumSidesJoined() > 1 then
        SelectMusic.currentFilter = FilterMode.All
    end

    LoadData()
    BuildItems()
    BuildRows()
    
    -- set default song
    if current_index.y == 1 and first_song_row > -1 then
        current_index.y = first_song_row
    end

    -- try to get to preferred song folder if no sort is specified
    local preferred_index_row = -1
    local preferred_index_col = -1

    if found_song then
        preferred_index_row, preferred_index_col = GetRowIndex(ItemType.Song, preferred_song)
        if preferred_index_row > -1 then
            current_index.y = preferred_index_row
            current_index.x = preferred_index_col > -1 and preferred_index_col or 1
        end

        -- set default steps
        SelectMusic.steps = FilterSteps(preferred_song)
        for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
            local psteps = SelectMusic.playerSteps[pn] or GAMESTATE:GetCurrentSteps(pn)
            if psteps then
                for k, st in ipairs(SelectMusic.steps) do
                    if st == psteps then 
                        SelectMusic.stepsIndex[pn] = k
                        SelectMusic.playerSteps[pn] = st
                    end
                end
            end
        end
    end

    UpdateGridCoords()
    GridInputController({ Direction = "Center" })
    GAMESTATE:SetCurrentSong( current_item.type == ItemType.Song and current_item.content or nil )
    MESSAGEMAN:Broadcast("SortChanged", { item = current_item, sort = SelectMusic.currentSort, filter = SelectMusic.currentFilter })
    MESSAGEMAN:Broadcast("GridSelected", { item = current_item, sort = SelectMusic.currentSort, filter = SelectMusic.currentFilter })
end


function ResetGridState()
	for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
		SelectMusic.confirm[pn] = 0
	end
end


function LoadData()
    song_data.all = FilterSongs( SONGMAN:GetAllSongs() )
    song_data.title = {}
    song_data.artist = {}
    song_data.group = {}
    song_data.level = {}

    song_folders = SONGMAN:GetSongGroupNames()
    table.sort(song_folders)

    found_song = false
    if preferred_song and table.contains(song_data.all, preferred_song) then
        found_song = true
    end

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


function AddSongsToGrid(list, random)
    if random and list and #list > 1 then table.insert( current_items, { type = ItemType.Song, content = nil }) end

    current_songs = list and list or {}
    for i, song in ipairs( list ) do 
        table.insert( current_items, { type = ItemType.Song, content = song, index = i })
    end
end


function BuildItems()
    current_items = nil
    current_items = {}
    
    current_songs = nil
    current_songs = {}

    -- sort modes
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.All })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Title })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Artist })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Group })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Level })

    -- filter
    if GAMESTATE:GetNumSidesJoined() < 2 then
        table.insert( current_items, { type = ItemType.Filter, content = SelectMusic.currentFilter })
    else
        SelectMusic.currentFilter = FilterMode.All
    end

    -- all songs
    if SelectMusic.currentSort == SortMode.All then
        local filtered_songs = FilterSongs( song_data.all, SelectMusic.currentFilter )
        AddSongsToGrid( filtered_songs, true )

    -- all songs
    elseif SelectMusic.currentSort == SortMode.Search then
        local filtered_songs = FilterSongs( SelectMusic.searchResults, SelectMusic.currentFilter )
        table.insert( current_items, { type = ItemType.Folder, content = "Search Results", num_songs = #filtered_songs, blocked = true })
        AddSongsToGrid( filtered_songs, false )

    -- folders
    elseif SelectMusic.currentSort == SortMode.Group then
        for i, folder in ipairs(song_folders) do 

            local filtered_songs = FilterSongs( song_data.group[folder], SelectMusic.currentFilter )
            if #filtered_songs > 0 then
                table.insert( current_items, { type = ItemType.Folder, content = folder, num_songs = #filtered_songs })
                if SelectMusic.currentFolder and SelectMusic.currentFolder == folder then
                    AddSongsToGrid( filtered_songs, true )
                end
            end
        end

        
    elseif SelectMusic.currentSort == SortMode.Title then 
        for i, keys in ipairs( AlphabetSort ) do 

            local filtered_songs = FilterSongs( song_data.title[keys], SelectMusic.currentFilter )
            if #filtered_songs > 0 then
                table.insert( current_items, { type = ItemType.Folder, content = keys, num_songs = #filtered_songs })
                if SelectMusic.currentFolder and SelectMusic.currentFolder == keys then
                    AddSongsToGrid( filtered_songs, true )
                end
            end
        end

    elseif SelectMusic.currentSort == SortMode.Artist then
        for i, keys in ipairs( AlphabetSort ) do 

            local filtered_songs = FilterSongs( song_data.artist[keys], SelectMusic.currentFilter )
            if #filtered_songs > 0 then
                table.insert( current_items, { type = ItemType.Folder, content = keys, num_songs = #filtered_songs })
                if SelectMusic.currentFolder and SelectMusic.currentFolder == keys then
                    AddSongsToGrid( filtered_songs, true )
                end
            end
        end

    elseif SelectMusic.currentSort == SortMode.Level then
        for i, v in ipairs( song_levels ) do 

            local filtered_songs = FilterSongs( song_data.level[v], SelectMusic.currentFilter )
            if #filtered_songs > 0 then
                table.insert( current_items, { type = ItemType.Folder, content = v, num_songs = #filtered_songs })
                if SelectMusic.currentFolder and SelectMusic.currentFolder == v then
                    AddSongsToGrid( filtered_songs, true )
                end
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


function SearchGrid(query)
    if not query or query == "" then return end

    current_items = nil
    current_items = {}
    SelectMusic.currentFilter = FilterMode.All
    SelectMusic.currentSort = SortMode.Search

    -- sort modes
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.All })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Title })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Artist })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Group })
    table.insert( current_items, { type = ItemType.Sort, content = SortMode.Level })
    
    local index_offset = 4
    
    -- filter
    if GAMESTATE:GetNumSidesJoined() < 2 then
        table.insert( current_items, { type = ItemType.Filter, content = SelectMusic.currentFilter })
        index_offset = 5
    end
    
    -- search
    SelectMusic.searchResults = nil
    SelectMusic.searchResults = {}

    for i, song in ipairs( song_data.all ) do
        if string.find( song:GetTranslitFullTitle():lower(), query) then 
            SelectMusic.searchResults[#SelectMusic.searchResults + 1] = song
            
        elseif string.find( song:GetDisplayFullTitle():lower(), query) then
            SelectMusic.searchResults[#SelectMusic.searchResults + 1] = song
            
        elseif string.find( song:GetTranslitArtist():lower(), query) then 
            SelectMusic.searchResults[#SelectMusic.searchResults + 1] = song
            
        elseif string.find( song:GetDisplayArtist():lower(), query) then
            SelectMusic.searchResults[#SelectMusic.searchResults + 1] = song
            
        end
    end
    
    -- blocked folder
    table.insert( current_items, { 
        type = ItemType.Folder, 
        content = "Search Results", 
        num_songs = #SelectMusic.searchResults, 
        blocked = true,
    })

    AddSongsToGrid(SelectMusic.searchResults)
    
    BuildRows()
    GoToItem( #SelectMusic.searchResults > 0 and index_offset or 1, 1 )
    MESSAGEMAN:Broadcast("SortChanged")
end

function GoToItem(row, column)
    current_index.y = row
    current_index.x = column

    current_row = GetCurrentRow(current_index.y)
    current_column = clamp(current_index.x, 1, #current_row)
    current_item = GetCurrentItem(current_row)

    SelectMusic.song = current_item and current_item.type == ItemType.Song and current_item.content or nil
    GAMESTATE:SetCurrentSong(SelectMusic.song)

    UpdateGridCoords()

    local params = { 
        item = current_item, 
        sort = SelectMusic.currentSort, 
        folder = SelectMusic.currentFolder, 
        filter = SelectMusic.currentFilter,
        Direction = "Center"
    }

    MESSAGEMAN:Broadcast("GridScroll", params)  
    MESSAGEMAN:Broadcast("GridSelected", params)  
end


function GridInputController(context)
    if not context then return end

    coords_direction = 0
    prev_row = GetCurrentRow(current_index.y)

    local sort_changed = false

    if context.Menu == "Back" then
        SCREENMAN:SetNewScreen("ScreenTitleMenu")
    end

    if context.Direction == "Up" then 
        current_index.y = current_index.y - 1 
        AdjustCursorPosition()
        coords_direction = -1
    end
    
    if context.Direction == "Down" then 
        current_index.y = current_index.y + 1   
        AdjustCursorPosition()
        coords_direction = 1
    end
    
    if context.Direction == "Left" then 
        current_index.x = clamp(current_index.x, 1, #prev_row) - 1 
        if current_index.x < 1 then WrapBackward() end
    end
    
    if context.Direction == "Right" then 
        current_index.x = clamp(current_index.x, 1, #prev_row) + 1 
        if current_index.x > #prev_row then WrapForward() end
    end

    -- // ========================================
    
    if current_index.y > #current_rows then 
        current_index.y = 1 
        coords_direction = 1
    end
    
    if current_index.y < 1 then 
        current_index.y = #current_rows 
        coords_direction = -1
    end

    -- // ========================================
    
    if context.Menu ~= nil and string.startswith( context.Menu, "Sort" ) then
        GoToItem(1,1)
    end

    -- // ========================================
    
    current_row = GetCurrentRow(current_index.y)
    current_item = GetCurrentItem(current_row)

    -- now redundant with AdjustCursorPosition() but might be useful in the future
    current_column = clamp(current_index.x, 1, #current_row)
    SelectMusic.song = current_item and current_item.type == ItemType.Song and current_item.content or nil

    if context.Menu == "Start" then
        if current_item then
            if current_item.blocked then return end

            if current_item.type == ItemType.Sort and SelectMusic.currentSort ~= current_item.content then
                SelectMusic.currentSort = current_item.content
                sort_changed = true

            elseif current_item.type == ItemType.Folder then
                if SelectMusic.currentFolder == current_item.content then
                    SelectMusic.currentFolder = nil
                else
                    SelectMusic.currentFolder = current_item.content
                    sort_changed = true
                end
            elseif current_item.type == ItemType.Song then
                if current_item.content then 
                    SetSong( current_item.content )
                else
                    SetRandomSong( false )
                end

            elseif current_item.type == ItemType.Filter then

                -- I'm not proud of this
                if SelectMusic.currentFilter == FilterMode.All then 
                    SelectMusic.currentFilter = FilterMode.Singles 
                elseif SelectMusic.currentFilter == FilterMode.Singles then 
                    SelectMusic.currentFilter = FilterMode.Doubles
                elseif SelectMusic.currentFilter == FilterMode.Doubles then 
                    SelectMusic.currentFilter = FilterMode.All
                end
                sort_changed = true
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

    -- if string.startswith( context.Menu, "Sort" ) then
    --     current_index.y = 0
    -- end

    local params = { 
        item = current_item, 
        sort = SelectMusic.currentSort, 
        folder = SelectMusic.currentFolder, 
        filter = SelectMusic.currentFilter,
        Direction = "Center"
    }

    if context.Direction then 
        UpdateGridCoords()
        MESSAGEMAN:Broadcast("GridScroll", params)
    end

    if sort_changed then
        MESSAGEMAN:Broadcast("SortChanged")
    end

    local input_dir = context.Direction and DirectionIndex(context.Direction) or 0
    if current_item and math.abs(input_dir) > 0 then
        GAMESTATE:SetCurrentSong( current_item.type == ItemType.Song and current_item.content or nil )
        MESSAGEMAN:Broadcast("GridSelected", params)
    end
end


-- prevents visual oddities from happening due to different grid indices being aligned
function AdjustCursorPosition()
    current_row = GetCurrentRow(current_index.y)
    if #current_row < #prev_row then
        current_index.x = current_index.x - math.floor((#prev_row - #current_row) * 0.5)
    end
    if #current_row > #prev_row then
        current_index.x = current_index.x + math.floor((#current_row - #prev_row) * 0.5)
    end
    current_index.x = clamp(current_index.x, 1, #current_row)
end


function SetRandomSong(jump)
    local num_songs = current_songs and #current_songs or 0
    if num_songs > 0 then
        
        local random_song = current_songs[math.random(num_songs)]

        if jump then
            current_index.y, current_index.x = GetRowIndex( ItemType.Song, random_song )
            GoToItem( current_index.y, current_index.x )
        end
        

        local params = { 
            item = { type = ItemType.Song, content = random_song }, 
            sort = SelectMusic.currentSort, 
            filter = SelectMusic.currentFilter 
        }

        SetSong( random_song )
        MESSAGEMAN:Broadcast("GridSelected", params)
    end
end


function SetSong(song)
    GAMESTATE:SetCurrentSong(song)
    SelectMusic.song = song
    SelectMusic.state = 1
    SelectMusic.steps = FilterSteps(song, SelectMusic.currentFilter)

    local context = { 
        item = current_item, 
        sort = SelectMusic.currentSort, 
        folder = SelectMusic.currentFolder, 
        filter = SelectMusic.currentFilter 
    }

    MESSAGEMAN:Broadcast("SongChosen", context)
    MESSAGEMAN:Broadcast("StateChanged", context)
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
    -- return (math.abs(y - Grid.middle.y) * 0.075) + (x * 0.075) * 0.75
    return math.random() * 0.333333
end


function ItemBanner(self, song, selected)
    local path = song and song:GetBannerPath() or nil
    
    if path then
        self:animate(0)

        -- somehow, it will actually cache the banner if loaded twice
        -- this massively improves performance when loading new banners
        -- a certified stepmania??? moment
        self:LoadFromCached("Banner", path) 
        self:LoadFromCached("Banner", path) 
    else 
        self:animate(1)
        self:Load(THEME:GetPathG("", "patterns/noise"))
        self:texcoordvelocity(60 + (math.random() * 20), 100 + (math.random() * 20))
    end

    local target_w = Grid.size.Song.x - 8
    local target_h = Grid.size.Song.y - 12
    self:scaletoclipped(target_w, target_h)

    local c = selected and Color.White or Grid.colors.Song
    self:diffuse( BoostColor(c, 1 )) 
    self:glow( selected and not path and {1,1,1,1} or {0,0,0,0} )
    self:xy(0,8)
end


local g = Def.ActorFrame{}

-- grid
for y = 1, Grid.slots.y do
    for x = 1, Grid.slots.x do
        g[#g+1] = Def.ActorFrame{
            Name = "Item"..tostring(#t+1),
            OnCommand=function(self) self:playcommand("GridScroll") end,

            GridScrollMessageCommand=function(self)
                if SelectMusic.state == 1 then return end

                local _offset = coords_table[Grid.middle.y][1].height * coords_direction
                local _coord = SCREEN_CENTER_Y + coords_table[y][x].y + Grid.offset.y - grid_center

                self:finishtweening()
                self:visible(coords_table[y][x].active)
                self:xy(coords_table[y][x].x, _coord + _offset):z((y * x + x) * 0.01)
                self:decelerate(0.125):y(_coord)
            end,

            StateChangedMessageCommand=function(self) 
                self:finishtweening()
                self:sleep(ItemDelay(x,y)):decelerate(0.1)
                self:zoomy(SelectMusic.state == 0 and 1 or 0) 
            end,

            SortChangedMessageCommand=function(self)
                local coord = coords_table[y][x]
                if coord and coord.type and coord.type == ItemType.Song then
                    self:finishtweening():zoomy(0)
                    self:sleep(ItemDelay(x,y) * 0.5):decelerate(0.1)
                    self:zoomy(1)
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

                GridScrollMessageCommand=function(self)
                    local coord = coords_table[y][x]
                    local item = GetCurrentRow( y + current_index.y - Grid.middle.y )[x]
                    if SelectMusic.state == 0 then self:finishtweening() end
                    self:zoomto(coord.width, coord.height)
                    if current_column == x and Grid.middle.y == y then
                        self:diffuse( Color.White )
                    else
                        self:diffuse( Grid.colors[ coords_table[y][x].type ] )
                    end
                    self:visible(not (item and item.type and item.type == ItemType.Song and true or false))
                end
            },

            Def.Sprite{
                Name = "Mask",
                Texture = "../graphics/grid_song_mask",
                InitCommand=function(self)
                    self:valign(0):MaskSource(true)
                    self:scaletoclipped(Grid.size.Song.x + 20, Grid.size.Song.y + 16)
                end,

                GridScrollMessageCommand=function(self)
                    local item = GetCurrentRow( y + current_index.y - Grid.middle.y )[x]
                    self:visible(item and item.type and item.type == ItemType.Song and true or false)
                end,
            },
            

            Def.Banner{
                Name = "Banner",
                InitCommand=function(self) self:valign(0):MaskDest() end,
                OnCommand=function(self) self:playcommand("GridScroll") end,
                HideCommand=function(self) self:visible(false) end,

                GridScrollMessageCommand=function(self)
                    if SelectMusic.state == 0 then
                        self:finishtweening()
                    end

                    local selected = current_column == x and Grid.middle.y == y
                    local item = GetCurrentRow( y + current_index.y - Grid.middle.y )[x]
                    local has_banner = false

                    if item then
                        if item.type == ItemType.Song then 
                            ItemBanner( self, item.content, selected )
                        else
                            self:Load(nil)
                        end
                    else
                        self:Load(nil)
                    end
                end,
            },
            
            -- frame
            Def.Sprite{
                Name = "Frame",
                Texture = "../graphics/grid_song_frame",
                InitCommand=function(self)
                    self:xy(1,-1):valign(0)
                    self:scaletoclipped(Grid.size.Song.x + 20, Grid.size.Song.y + 12)
                    self:diffuse( BoostColor( Color.White, 0.1 ))
                    self:diffusetopedge( BoostColor( Color.White, 0.333333 ))
                end,

                GridScrollMessageCommand=function(self)
                    local item = GetCurrentRow( y + current_index.y - Grid.middle.y )[x]
                    local selected = current_column == x and Grid.middle.y == y
                    self:visible(item and item.type and item.type == ItemType.Song and true or false)

                    local c = selected and AccentColor( "Blue", 1 ) or Color.White
                    self:diffuse( BoostColor( c, selected and 1 or 0.1 ))
                    self:diffusetopedge( BoostColor( c, selected and 5 or 0.333333 ))
                end,
            },

            -- label
            Def.BitmapText{
                Name = "Label",
                Font = Font.UINormal,
                InitCommand=function(self) self:shadowlength(1) end,
                OnCommand=function(self) self:playcommand("GridScroll") end,
                GridScrollMessageCommand=function(self)
                    if SelectMusic.state == 1 then return end
                    if SelectMusic.state == 0 then self:finishtweening() end

                    self:y(coords_table[y][x].height * 0.5  )
                    local selected = current_column == x and Grid.middle.y == y
                    local item = GetCurrentRow(y + current_index.y - Grid.middle.y)[x]
                    
                    if not item then 
                        self:visible(false) 
                    else
                        if item.type == ItemType.Song then
                            self:maxwidth( Grid.size.Song.x * 2 - Grid.padding.Song)
                            self:wrapwidthpixels( Grid.size.Song.x * 2 - Grid.padding.Song)
                            
                            if item.content then
                                local path = item.content ~= nil and item.content:GetBannerPath() or nil
                                self:visible(path == nil)
                                self:zoom(0.5)
                                self:settext( item.content and item.content:GetDisplayMainTitle() or "Random")
                            else
                                self:y(coords_table[y][x].height * 0.5 + 16  )
                                self:visible(true)
                                self:zoom(0.5)
                                self:settext( "Random")

                            end
                        else
                            self:visible(true)
                            self:zoom(0.6)
                            self:maxwidth( Grid.size[item.type].x * 1.5 - Grid.padding.Song)
                            self:wrapwidthpixels( Grid.size[item.type].x * 1.5 - Grid.padding.Song)
                            if item.type == ItemType.Folder and SelectMusic.currentSort == SortMode.Level then
                                self:settext( "Level "..item.content )
                            elseif item.type == ItemType.Filter then
                                self:settext( "Filter: "..item.content )
                            else
                                self:settext( item.content )
                            end
                        end
                    end

                    self:diffuse( selected and (item.content and Color.Blue or Color.Red) or Color.White )
                    self:shadowcolor( selected and {0,0,0,0} or BoostColor( Color.Black, 0.25 ))
                end
            },

            -- sub text
            Def.BitmapText{
                Name = "SubText",
                Font = Font.UINormal,
                OnCommand=function(self) self:playcommand("GridScroll") end,
                GridScrollMessageCommand=function(self)
                    if SelectMusic.state == 1 then return end
                    if SelectMusic.state == 0 then self:finishtweening() end

                    local selected = current_column == x and Grid.middle.y == y
                    local item = GetCurrentRow(y + current_index.y - Grid.middle.y)[x]

                    if not item then 
                        self:settext("") 
                    else
                        if item.type == ItemType.Song and not item.content then
                            self:zoom(0.75):align(0.5, 1)
                            self:diffuse(selected and Color.Red or Color.White):shadowlength(selected and 0 or 1)
                            self:xy(0, coords_table[y][x].height * 0.5 + 4 )
                            self:settext("???"):visible(true)

                        elseif item.type == ItemType.Folder then 
                            self:zoom(0.5):align(0, 0.5)
                            self:diffuse(Color.Blue)
                            self:x(coords_table[y][x].width * -0.5 + 16)
                            self:y(coords_table[y][x].height * 0.5 )
                            self:settext(item.num_songs):visible(true) 
                        else 
                            self:visible(false)
                        end
                    end
                end
            },


        }
    end
end

t[#t+1] = g

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