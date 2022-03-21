local master = GAMESTATE:GetMasterPlayerNumber()
local labelSize = 0.475
local itemSize = 0.55
local labelSpacing = 14

local t = Def.ActorFrame{
    EditorStateChangedMessageCommand=function(self, context)
        self:visible( context.EditState ~= "EditState_Playing" )
    end,
}

-- title
t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_LEFT + 20, SCREEN_TOP + 12)
    end,

    Def.BitmapText{
        Font = Font.EditorUINormal,
        Text = "Currently Editing",
        InitCommand=function(self)
            self:zoom(labelSize)
            self:align(0,0)
            self:diffuse( BoostColor( Color.White, 0.5 ))
        end,
    },

    Def.BitmapText{
        Font = Font.EditorUIHeavy,
        InitCommand=function(self)
            self:zoom(itemSize)
            self:align(0,0)
            self:y(labelSpacing)
            self:settext( GAMESTATE:GetCurrentSong():GetMainTitle() )
        end,
    }
}

-- title
t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_LEFT + 20, SCREEN_TOP + 52)
    end,

    Def.BitmapText{
        Font = Font.EditorUINormal,
        Text = "Chart Author",
        InitCommand=function(self)
            self:zoom(labelSize)
            self:align(0,0)
            self:diffuse( BoostColor( Color.White, 0.5 ))
        end,
    },

    Def.BitmapText{
        Font = Font.EditorUIHeavy,
        InitCommand=function(self)
            self:zoom(itemSize)
            self:align(0,0)
            self:y(labelSpacing)

            local author = GAMESTATE:GetCurrentSteps(master):GetAuthorCredit()
            self:settext( author and author ~= "" and author or "Unknown Author" )
        end,
    }
}


-- beat
t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_RIGHT - 20, SCREEN_TOP + 12)
    end,

    Def.BitmapText{
        Font = Font.EditorUINormal,
        Text = "Current Beat",
        InitCommand=function(self)
            self:zoom(labelSize)
            self:align(1,0)
            self:diffuse( BoostColor( Color.White, 0.5 ))
        end,
    },

    Def.BitmapText{
        Font = Font.EditorUIHeavy,
        InitCommand=function(self)
            self:zoom(itemSize)
            self:align(1,0)
            self:y(labelSpacing)
        end,
        EditorUpdateMessageCommand=function(self, context)
            self:settextf( "%.3f", context.Beat )
        end,
    }
}


-- time
t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_RIGHT - 20, SCREEN_TOP + 52)
    end,

    Def.BitmapText{
        Font = Font.EditorUINormal,
        Text = "Current Time",
        InitCommand=function(self)
            self:zoom(labelSize)
            self:align(1,0)
            self:diffuse( BoostColor( Color.White, 0.5 ))
        end,
    },

    Def.BitmapText{
        Font = Font.EditorUIHeavy,
        InitCommand=function(self)
            self:zoom(itemSize)
            self:align(1,0)
            self:y(labelSpacing)
        end,
        EditorUpdateMessageCommand=function(self, context)
            self:settextf( "%.3f", context.Second )
        end,
    }
}

-- snap
t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_RIGHT - 20, SCREEN_TOP + 92)
    end,

    Def.BitmapText{
        Font = Font.EditorUINormal,
        Text = "Snap",
        InitCommand=function(self)
            self:zoom(labelSize)
            self:align(1,0)
            self:diffuse( BoostColor( Color.White, 0.5 ))
        end,
    },

    Def.BitmapText{
        Font = Font.EditorUIHeavy,
        InitCommand=function(self)
            self:zoom(itemSize)
            self:align(1,0)
            self:y(labelSpacing)
        end,
        EditorUpdateMessageCommand=function(self, context)
            self:settextf( "%s", context.SnapType.." ("..context.TapNoteType..")" )
        end,

    }
}
-- params.MarkerRange

return t