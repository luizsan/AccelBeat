local x, y = ...
local padding = 64

function MainImage(self, context)
    
    local path = nil
    local w,h = 0,0
    local x,y = 0,0
    local c = Color.White
    local rect = nil

    self:StopUsingCustomPosCoords()

    if context.item then
        if context.item.type == ItemType.Song then
            path = context.item.content and context.item.content:GetBannerPath() or nil
            w, h = context.width - 10, context.height - 8
            x, y = 0, 6
            c = context.selected and Color.White or context.color

        elseif context.item.type == ItemType.Sort then
            path = THEME:GetPathG("", "select_music/grid_sort_" .. (SelectMusic.currentSort == context.item.content and "selected" or "normal"))
            w, h = context.width + 32, context.height + 24
            x, y = 0, -10
            c = BoostColor( Color.White, context.selected and 1 or 0.666666 )

        else
            self:visible(false)
            return

        end
    end

    self:visible(true)

    -- if you're wondering why there are 2 Load calls:
    -- somehow, it will actually cache the banner if loaded twice
    -- this massively improves performance when loading new banners
    -- a certified stepmania™ moment
    if path then
        self:animate(0)
        self:Load(path) 
        self:Load(path) 

    else 
        self:animate(1)
        self:Load(THEME:GetPathG("", "patterns/noise"))
        self:texcoordvelocity(10 + (math.random() * 10), 10 + (math.random() * 10))
        c = BoostColor(c, 0.5)

    end

    -- another wonderful hack so the sprite maintains its molecular integrity
    -- self:zoomto(w,h)
    self:scaletoclipped(w,h) 

    self:xy(x,y)
    self:diffuse(c)

    if context.selected then
        self:stoptweening()
        self:glow( Color.White )
        self:linear(0.125)
        self:glow( 1,1,1,0 )
        self:diffuseshift():effectperiod(0.5)
        self:effectcolor1(BoostColor(c, 0.666666)):effectcolor2(c)
    else
        self:stopeffect()
    end
end


function MainLabel(self, context)

    local width, wrap = 0, 0
    local x, y = 0, context.height * 0.5
    local color = Color.White
    local shadowcolor, shadowlength = Color.White, { 0, 0 }
    local visible = false
    local text = ""
    local size = 1

    if not context.item then 
        visible = false
    else
        if context.item.type == ItemType.Song then
            width =  context.width * 2 - padding
            wrap = context.width * 2 - padding

            if context.item.content then
                -- song
                local path = context.item.content:GetBannerPath() or nil
                visible = (path == nil)
                size = 0.5
                text = context.item.content:GetDisplayMainTitle()
                color = BoostColor( Color.White, context.selected and 1 or 0.5 )
            else
                -- random
                y = context.height * 0.5 + 16
                visible = true
                size = 0.5
                text = "Random"
                color = BoostColor( {1, 0.2, 0.2, 1}, context.selected and 1 or 0.5 )
            end

            shadowcolor = { 0,0,0,0.75 }
            shadowlength = { 1, 1 }
        else
            
            visible = true
            size = 0.6
            width = context.width * 1.5 - padding
            wrap = context.width * 1.5 - padding
            text = context.item.content
            shadowcolor = { 0,0,0,0 }
            shadowlength = { 0, 0 }

            if context.item.type == ItemType.Folder then
                if SelectMusic.currentSort == SortMode.Level then text = "Level "..text end
                color = context.selected and Color.Blue or Color.White

            elseif context.item.type == ItemType.Filter then
                text = "Filter: "..text

            elseif context.item.type == ItemType.Sort then
                color = context.selected and Color.White or context.color
                shadowcolor = { 0, 0, 0, 0.25 }
                shadowlength = { 0, -1.75 }
            end

        end
        
        self:visible( visible )
        self:maxwidth( width )
        self:wrapwidthpixels( wrap )
        self:diffuse( color )
        self:y( y )
        self:settext( text )
        self:zoom( size )
        self:shadowcolor( shadowcolor )
        self:shadowlengthx( shadowlength[1] )
        self:shadowlengthy( shadowlength[2] )
    end
end


function SubLabel(self, context)
    if not context.item then 
        self:visible(false)
    else
        if context.item.type == ItemType.Song and not context.item.content then
            -- random
            self:zoom(0.75):align(0.5, 1)
            self:diffuse( BoostColor(Color.White, context.selected and 1 or 0.5 ))
            self:xy(0, context.height * 0.5 + 4 )
            self:settext("???"):visible(true)
            self:shadowlength( 1 )
            self:shadowcolor( 0,0,0,0.5 )
            
        elseif context.item.type == ItemType.Folder then 
            -- num songs in folder
            self:zoom(0.5):align(0, 0.5)
            self:diffuse(Color.Blue)
            self:x(context.width * -0.5 + 16)
            self:y(context.height * 0.5 )
            self:shadowlength( 1 )
            self:shadowcolor( context.selected and {0,0,0,0} or {0,0,0,0.5} )
            self:settext(context.item.num_songs):visible(true) 
        else 
            self:visible(false)
        end
    end
end



local t = Def.ActorFrame{
    
    -- -- base quad
    -- Def.Quad{
    --     Name = "Quad",
    --     InitCommand=function(self)
    --         self:shadowcolor(0,0,0,0.25):shadowlength(5)
    --         self:valign(0)
    --     end,

    --     ActivateCommand=function(self,context)
    --         if SelectMusic.state == 0 then self:finishtweening() end
    --         self:zoomto(context.width, context.height)
    --         self:visible(context.item and context.item.type == ItemType.Folder or false)
    --         self:diffuse( context.selected and Color.White or context.color )
    --     end
    -- },

    Def.Sprite{
        Name = "Mask",
        Texture = "../graphics/grid_song_mask",
        InitCommand=function(self)
            self:valign(0):MaskSource(true)
        end,

        ActivateCommand=function(self,context)
            self:zoomto(context.width + 20, context.height + 10)
            self:visible(context.is_song)
        end,
    },
    
    -- image
    Def.Banner{
        Name = "Banner",
        InitCommand=function(self) self:valign(0):MaskDest() end,
        HideCommand=function(self) self:visible(false) end,
        ActivateCommand=function(self,context)
            if SelectMusic.state == 0 then self:finishtweening() end
            MainImage( self, context )
        end,
    },
    
    -- frame
    Def.Sprite{
        Name = "Frame",
        Texture = "../graphics/grid_song_frame",
        InitCommand=function(self)
            self:xy(1,-3):valign(0)
            self:diffuse( BoostColor( Color.White, 0.1 ))
            self:diffusetopedge( BoostColor( Color.White, 0.333333 ))
        end,
        
        ActivateCommand=function(self,context)
            self:visible(context.is_song)
            self:zoomto(context.width + 20, context.height + 12)

            local c = context.selected and AccentColor( "Blue", 1 ) or Color.White
            self:diffuse( BoostColor( c, context.selected and 1 or 0.1 ))
            self:diffusetopedge( BoostColor( c, context.selected and 5 or 0.333333 ))
        end,
    },

    -- label
    Def.BitmapText{
        Name = "MainText",
        Font = Font.UINormal,
        ActivateCommand=function(self,context)
            if SelectMusic.state == 1 then return end
            if SelectMusic.state == 0 then self:finishtweening() end
            MainLabel(self, context)
        end
    },

    -- sub text
    Def.BitmapText{
        Name = "SubText",
        Font = Font.UINormal,
        ActivateCommand=function(self,context)
            if SelectMusic.state == 1 then return end
            if SelectMusic.state == 0 then self:finishtweening() end
            SubLabel(self, context)
        end
    },


}

return t