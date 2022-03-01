local h = 72
local t = Def.ActorFrame{}

-- folder
t[#t+1] = Def.ActorFrame{
    InitCommand=function(self) 
        self:xy(SCREEN_CENTER_X - 485, h + 48)
        self:finishtweening()
    end,

    StateChangedMessageCommand=function(self) self:playcommand("Refresh") end,
    GridSelectedMessageCommand=function(self) self:playcommand("Refresh") end,
    RefreshCommand=function(self)
        self:stoptweening()
        self:decelerate(0.1)
        self:zoomy( GAMESTATE:GetCurrentSong() and SelectMusic.state == 0 and 1 or 0 )
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
        Font = Font.UINormal,
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
        Font = Font.UINormal,
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

return t