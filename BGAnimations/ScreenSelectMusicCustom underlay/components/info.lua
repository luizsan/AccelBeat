
local h = 72

local ItemType = {
    Song = "Song",
    Folder = "Folder",
    Sort = "Sort",
}

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
            self:settext( context.item.content )
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


-- folder
t[#t+1] = Def.ActorFrame{
    InitCommand=function(self) 
        self:xy(SCREEN_CENTER_X - 485, h + 48)
        self:finishtweening()
    end,

    GridSelectedMessageCommand=function(self)
        self:stoptweening()
        self:decelerate(0.15)
        self:zoomy( GAMESTATE:GetCurrentSong() and 1 or 0 )
    end,

    StateChangedMessageCommand=function(self)
        self:stoptweening()
        self:decelerate(0.1)
        self:zoomy( SelectMusic.state == 0 and 1 or 0 )
    end,

    Def.Sprite{
        Texture = "../graphics/header_sub",
        InitCommand=function(self)
            self:animate(0)
            self:setstate(0)
            self:align(1,0)
            self:xy(-36, -10)
            self:zoomto(48 * 0.3333333, 50)
        end,
    },

    Def.Sprite{
        Texture = "../graphics/header_sub",
        InitCommand=function(self)
            self:animate(0)
            self:setstate(1)
            self:align(0,0)
            self:xy(-36, -10)
            self:zoomto(2, 50)
        end,
        GroupTextChangedMessageCommand=function(self,context)
            self:zoomto( context.text:GetZoomedWidth() + 42, self:GetZoomedHeight() )
        end
    },

    Def.Sprite{
        Texture = "../graphics/header_sub",
        InitCommand=function(self)
            self:animate(0)
            self:setstate(2)
            self:align(0,0)
            self:xy(-36, -10)
            self:zoomto(48 * 0.333333, 50)
        end,
        GroupTextChangedMessageCommand=function(self,context)
            self:x( -36 + context.text:GetZoomedWidth() + 42)
        end
    },



    Def.BitmapText{
        Name = "Folder",
        Font = "NewRodinB-24",
        Text = "Song Folder",
        InitCommand=function(self)
            self:diffuse(Color.White)
            self:align(0,0)
            self:zoom(0.45)
            self:strokecolor(0,0,0,0.2)
            self:y(2)
        end,
        GridSelectedMessageCommand=function(self,context)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                self:settext( song:GetGroupName() )
            end
            context.text = self
            MESSAGEMAN:Broadcast("GroupTextChanged", context)
        end,
    },

    -- folder
    Def.Sprite{
        Name = "Icon",
        Texture = "../graphics/header_category",
        InitCommand=function(self)
            self:animate(0)
            self:zoom(0.35)
            self:shadowlength(1)
            self:align(1, 0.5)
            self:setstate(1)
            self:xy(-8, 10)
        end,
    }
}

-- sort
t[#t+1] = Def.ActorFrame{
    InitCommand=function(self) 
        self:xy(SCREEN_CENTER_X + 484, h + 48)
        self:finishtweening()
    end,

    SortChangedMessageCommand=function(self)
        self:stoptweening()
        self:zoomy(0)
        self:decelerate(0.15)
        self:zoomy(1)
    end,

    StateChangedMessageCommand=function(self)
        self:stoptweening()
        self:decelerate(0.1)
        self:zoomy( SelectMusic.state == 0 and 1 or 0 )
    end,
    
    Def.Sprite{
        Texture = "../graphics/header_sub",
        InitCommand=function(self)
            self:animate(0)
            self:setstate(2)
            self:align(0,0)
            self:xy(36, -10)
            self:zoomto(48 * 0.3333333, 50)
        end,
    },

    Def.Sprite{
        Texture = "../graphics/header_sub",
        InitCommand=function(self)
            self:animate(0)
            self:setstate(1)
            self:align(1,0)
            self:xy(36, -10)
            self:zoomto(2,50)
        end,
        SortTextChangedMessageCommand=function(self,context)
            self:zoomto( context.text:GetZoomedWidth() + 36, self:GetZoomedHeight() )
        end
    },

    Def.Sprite{
        Texture = "../graphics/header_sub",
        InitCommand=function(self)
            self:animate(0)
            self:setstate(0)
            self:align(1,0)
            self:xy(36, -10)
            self:zoomto(48 * 0.333333, 50)
        end,
        SortTextChangedMessageCommand=function(self,context)
            self:x( 36 - context.text:GetZoomedWidth() - 36)
        end
    },

    Def.BitmapText{
        Name = "Sort",
        Font = "NewRodinB-24",
        Text = "Sort Mode",
        InitCommand=function(self)
            self:diffuse(Color.White)
            self:align(1,0)
            self:zoom(0.45)
            self:strokecolor(0,0,0,0.2)
            self:xy(8, 2)
        end,
        SortChangedMessageCommand=function(self,context)
            self:settext( context.sort )
            context.text = self
            MESSAGEMAN:Broadcast("SortTextChanged", context)
        end,
    },

    Def.Sprite{
        Name = "Icon",
        Texture = "../graphics/header_category",
        InitCommand=function(self)
            self:animate(0)
            self:zoomx(0.4)
            self:zoomy(0.3)
            self:shadowlength(1)
            self:align(0, 0.5)
            self:setstate(2)
            self:xy(12, 10)
        end,
    }
}

-- bpm label
t[#t+1] = Def.BitmapText{
    Name = "BPM",
    Font = "NewRodinB-24",
    Text = "BPM",
    InitCommand=function(self)
        self:diffuse( BoostColor( Color.White, 0.333333 ))
        self:align(1,0)
        self:xy(SCREEN_CENTER_X + 518, h - 14)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-1)
        self:zoom(0.375)
    end,

    GridSelectedMessageCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            self:visible(true)
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
        self:align(1,0)
        self:xy(SCREEN_CENTER_X + 520, h)
        self:shadowcolor( Color.White )
        self:shadowlengthy(-2)
        self:zoom(0.6)

    end,

    GridSelectedMessageCommand=function(self,context)
        if not context or not context.item or not context.item.type then return end
        if context.item.type == ItemType.Song then
            self:SetFromSong( context.item.content )
            self:visible(true)
        else
            self:visible(false)
        end
    end
}


return t