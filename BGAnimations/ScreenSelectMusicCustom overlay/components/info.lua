
local h = 72


local t = Def.ActorFrame{}

t[#t+1] = Def.Sprite{
    Texture = "../graphics/header_category",
    InitCommand=function(self)
        self:animate(0)
        self:xy(SCREEN_CENTER_X - 520, h)
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
        self:xy(SCREEN_CENTER_X - 520, h)
        self:zoom(0.8)
        self:diffuse( AccentColor( "Blue", 1 ))
    end,
    
    GridSelectedMessageCommand=function(self,context)
        if context and context.item then
            if context.item.type == ItemType.Song then
                self:setstate(3)
                self:visible(true)
            elseif context.item.type == ItemType.Folder then
                self:visible(false)
            elseif context.item.type == ItemType.Sort then
                self:setstate(5)
            end
        end
    end,
}

t[#t+1] = Def.BitmapText{
    Name = "Title",
    Font = "NewRodinB-24",
    Text = "Song Title",
    InitCommand=function(self)
        self:diffuse(BoostColor(Color.White, 0.1))
        self:align(0, 0)
        self:xy(SCREEN_CENTER_X - 485, h - 22)
        self:zoom(0.675)
        self:strokecolor(0,0,0,0.2)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-2)
    end,
    GridSelectedMessageCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            self:settext( context.item.content:GetMainTitle(), context.item.content:GetTranslitMainTitle() )
        elseif context.item.type == ItemType.Folder then
            if SelectMusic.currentSort == SortMode.Level then
                self:settext( "Level "..context.item.content )
            else
                self:settext( context.item.content )
            end
        elseif context.item.type == ItemType.Sort then
            self:settext( context.item.content )
        end
    end
}
    
t[#t+1] = Def.BitmapText{
    Name = "Artist",
    Font = "NewRodinB-24",
    Text = "Artist",
    InitCommand=function(self)
        self:diffuse(0,0.625,1,1)
        self:halign(0,0)
        self:xy(SCREEN_CENTER_X - 485, h + 8)
        self:zoom(0.6)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-2)
    end,
    GridSelectedMessageCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            self:settext( context.item.content:GetDisplayArtist(), context.item.content:GetTranslitArtist() )
        elseif context.item.type == ItemType.Folder then
            self:settext( context.item.num_songs.." songs" )
        elseif context.item.type == ItemType.Sort then
            self:settext( "Sort Mode ")
        end
    end
}



-- duration
t[#t+1] = Def.BitmapText{
    Name = "BPM",
    Font = "NewRodinEB-32-Numbers",
    Text = "BPM",
    InitCommand=function(self)
        self:diffuse( BoostColor( Color.White, 0.333333 ))
        self:align(1,1)
        self:xy(SCREEN_CENTER_X + 520, h - 2)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-1)
        self:zoom(0.35)
    end,

    GridSelectedMessageCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            self:visible(true)
            local sec = context.item.content:MusicLengthSeconds()
            if sec >= 3600 then
                self:settext( SecondsToHHMMSS(sec) )
            else
                self:settext( SecondsToMMSS(sec) )
            end
        else
            self:visible(false)
        end
    end
}


-- BPM
t[#t+1] = Def.BPMDisplay{
    Name = "BPM",
    Font = "NewRodinEB-32-Numbers",
    Text = "000",
    InitCommand=function(self)
        self:diffuse(0,0.625,1,1)
        self:align(1,1)
        self:xy(SCREEN_CENTER_X + 520, h + 16)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-2)
        self:zoom(0.5)

        local c = AccentColor("Blue", 1)
        self:diffuseshift()
        self:effectcolor1( BoostColor(c, 1.5) )
        self:effectcolor2( BoostColor(c, 0.9) )
        self:effectclock("beat")
    end,

    GridSelectedMessageCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            self:SetFromSong( context.item.content )
            self:visible(true)
            self:settext( self:GetText().." BPM" )
        else
            self:visible(false)
        end
    end
}


return t