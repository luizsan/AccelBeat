local master = GAMESTATE:GetMasterPlayerNumber()

local padding = {
    top = 12,
    side = 20,
}

local size = {
    label = 0.45,
    item = 0.55,
}

local spacing = {
    label = 12,
    item = 36,
}

local editScreen = nil
local editorSteps = nil
local editorState = nil
local songPosition = nil
local editorPosition = nil

local infoItems = {
    { 
        name = "Title", label = "Currently Editing", side = 0, row = 0, 
        action = function(self, context) 
            self:settext( GAMESTATE:GetCurrentSong():GetMainTitle() )        
        end,
    },
    { 
        name = "Author", label = "Chart Author", side = 0, row = 1, 
        action = function(self, context) 
            local author = editorSteps and editorSteps:GetAuthorCredit() or nil
            self:settext( author and author ~= "" and author or "Unknown Author" )
        end,
    },
    { 
        name = "Steps", label = "Chart", side = 0, row = 2, 
        action = function(self, context)
            if not editorSteps then return end
            self:settext( string.format("%s %s", ToEnumShortString(editorSteps:GetStepsType()):gsub("_", " "), editorSteps:GetMeter()) )
            self:diffuse( BoostColor( StepsColor(editorSteps), 3 ) )
        end,
    },
    { 
        name = "Mode", label = "Timing Mode", side = 0, row = 3, 
        action = function(self, context) 
            if not editScreen then return end
            local b = editScreen:IsStepTiming()
            self:settext( b and "Step Timing" or "Song Timing" )
        end,
    },
    { 
        name = "Beat", label = "Current Beat", side = 1, row = 0, 
        action = function(self, context)
            if not context.Beat then return end
            self:settext( string.format("%.3f", context.Beat) )
        end,
    },
    { 
        name = "Time", label = "Current Time", side = 1, row = 1, 
        action = function(self, context)
            if not context.Time then return end
            self:settext( string.format("%.3fs", context.Time) )
        end,
    }
}

local function EditorRefresh(self, dt)
    editorSteps = GAMESTATE:GetCurrentSteps(master)
    editorPosition = (editScreen and editScreen:GetEditorPosition()) or nil
    songPosition = GAMESTATE:GetSongPosition() or nil

    local pos = editorState and editorState == "EditState_Playing" and songPosition or editorPosition
    local args = {
        Time = pos and pos:GetMusicSeconds() or 0,
        Beat = pos and pos:GetSongBeat() or 0
    }

    MESSAGEMAN:Broadcast("EditorUpdate", args)
end

local t = Def.ActorFrame{
    OnCommand=function(self)
        editScreen = SCREENMAN:GetTopScreen()
        self:SetUpdateFunction(EditorRefresh)
    end,

    EditorStateChangedMessageCommand=function(self, context)
        editorState = context.EditState
        -- self:visible( context.EditState ~= "EditState_Playing" )
    end,
}

for i, item in ipairs(infoItems) do

    t[#t+1] = Def.ActorFrame{
        Name = item.name.."_"..i,
        InitCommand=function(self)
            local _side = ((item.side * 2)-1)
            self:xy(SCREEN_CENTER_X + (SCREEN_WIDTH * 0.5 * _side) - (padding.side * _side), SCREEN_TOP + padding.top + (item.row * spacing.item))
        end,
        
        Def.BitmapText{
            Font = Font.EditorUINormal,
            Text = item.label,
            InitCommand=function(self)
                self:zoom( size.label )
                self:align( item.side, 0 )
                self:diffuse( BoostColor( Color.White, 0.5 ))
            end,
        },
        
        Def.BitmapText{
            Font = Font.EditorUIHeavy,
            InitCommand=function(self)
                self:zoom( size.item )
                self:align( item.side, 0 )
                self:y( spacing.label )
            end,

            EditorUpdateMessageCommand=function(self,context)
                if item.action then item.action(self,context) end
            end,
        }
    }

end

return t