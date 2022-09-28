
local h = 72

local t = Def.ActorFrame{
    FOV = 60,
    InitCommand=function(self)
        self:xy(SCREEN_CENTER_X, SCREEN_TOP + h)
        self:vanishpoint(SCREEN_CENTER_X, SCREEN_CENTER_Y)
    end,
}

t[#t+1] = LoadActor("header")..{
    InitCommand=function(self) self:y(-40):rotationx(0) end
}

t[#t+1] = Def.Sprite{
    Texture = "../graphics/header_category",
    InitCommand=function(self)
        self:animate(0)
        self:xy(-520, 0)
        self:zoom(0.8)
        self:diffuse( BoostColor( Color.White, 0.333333 ))
    end,

    GridSelectedMessageCommand=function(self,context)
        if context and context.item then
            if context.item.type == ItemType.Song then
                self:setstate(0)
                self:zoom(0.8)
            elseif context.item.type == ItemType.Folder then
                self:setstate(1)
                self:zoom(0.666666)
            elseif context.item.type == ItemType.Sort then
                self:setstate(2)
                self:zoom(0.666666)
            elseif context.item.type == ItemType.Filter then
                self:setstate(3)
                self:zoom(0.666666)
            end
        end
    end,
}

-- icon detail
t[#t+1] = Def.Sprite{
    Texture = "../graphics/header_category",
    InitCommand=function(self)
        self:animate(0)
        self:setstate(3)
        self:xy(-520, 0)
        self:zoom(0.8)
        self:diffuse( AccentColor( "Blue", 1 ))
    end,
    
    GridSelectedMessageCommand=function(self,context)
        if context and context.item then
            if context.item.type == ItemType.Song then
                self:setstate(4)
                self:visible(true)
            else
                self:visible(false)
            end
        end
    end,
}

t[#t+1] = Def.BitmapText{
    Name = "Title",
    Font = Font.UIHeavy,
    Text = "Song Title",
    InitCommand=function(self)
        self:diffuse(BoostColor(Color.White, 0.1))
        self:align(0, 0)
        self:xy(-485, -22)
        self:zoom(0.675)
        self:strokecolor(0,0,0,0.2)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-2)
    end,

    SortChangedMessageCommand=function(self,context) self:playcommand("Refresh", context) end,
    GridSelectedMessageCommand=function(self,context) self:playcommand("Refresh", context) end,
    RefreshCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            if context.item.content then
                self:settext( context.item.content:GetMainTitle(), context.item.content:GetTranslitMainTitle() )
            else 
                self:settext("Random")
            end
        elseif context.item.type == ItemType.Folder then
            if SelectMusic.currentSort == SortMode.Level then
                self:settext( "Level "..context.item.content )
            else
                self:settext( context.item.content )
            end
        elseif context.item.type == ItemType.Filter then
            self:settext( context.filter )
        else
            self:settext( context.item.content )
        end
    end
}
    
t[#t+1] = Def.BitmapText{
    Name = "Artist",
    Font = Font.UINormal,
    Text = "Artist",
    InitCommand=function(self)
        self:diffuse(0,0.625,1,1)
        self:halign(0,0)
        self:xy(-485, 6)
        self:zoom(0.55)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-2)
    end,
    GridSelectedMessageCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            if context.item.content then
                self:settext( context.item.content:GetDisplayArtist(), context.item.content:GetTranslitArtist() )
            else
                self:settext( "Pick a random song" )
            end
        elseif context.item.type == ItemType.Folder then
            self:settext( context.item.num_songs.." songs" )
        elseif context.item.type == ItemType.Sort then
            self:settext( "Sort Mode")
        elseif context.item.type == ItemType.Filter then
            self:settext( "Filter Mode" )
        end
    end
}



-- duration
t[#t+1] = Def.BitmapText{
    Name = "BPM",
    Font = Font.UIHeavy,
    Text = "BPM",
    InitCommand=function(self)
        self:diffuse( BoostColor( Color.White, 0.333333 ))
        self:align(1,1)
        self:xy(520,-2)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-1)
        self:zoom(0.475)
    end,

    GridSelectedMessageCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            self:visible(true)
            if context.item.content then
                local sec = context.item.content:MusicLengthSeconds()
                if sec >= 3600 then
                    self:settext( SecondsToHHMMSS(sec) )
                else
                    self:settext( SecondsToMMSS(sec) )
                end
            else
                self:settext( "??:??" )
            end
        else
            self:visible(false)
        end
    end
}


-- BPM
t[#t+1] = Def.BPMDisplay{
    Name = "BPM",
    Font = Font.UIHeavy,
    Text = "000",
    InitCommand=function(self)
        self:diffuse(0,0.625,1,1)
        self:align(1,1)
        self:xy(520,16)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-2)
        self:zoom(0.7)

        local c = AccentColor("Blue", 1)
        self:diffuseshift()
        self:effectcolor1( BoostColor(c, 1.5) )
        self:effectcolor2( BoostColor(c, 0.9) )
        self:effectclock("beat")
    end,

    GridSelectedMessageCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            if context.item.content then
                self:SetFromSong( context.item.content )
            else
                self:SetFromSong( nil )
            end
            self:visible(true)
            self:settext( self:GetText().." BPM" )
        else
            self:visible(false)
        end
    end
}


return t