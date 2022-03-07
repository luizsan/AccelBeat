-- progress bar
local height = 2

local master = GAMESTATE:GetMasterPlayerNumber()
local total = clamp(GAMESTATE:GetCurrentSong():GetLastSecond(), 1, math.huge) or 1
local progress = 0.0
local current = 0.0

return Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_LEFT, SCREEN_TOP) 
    end,

    UpdateGameplayMessageCommand=function(self) 
        current = clamp(GAMESTATE:GetCurMusicSeconds(), 0, total)
    end,

    Def.Quad{
        InitCommand=function(self)
            self:diffuse(0,0,0,0.25)
            self:zoomto(SCREEN_WIDTH, height + 4)
            self:align(0,0)
        end
    },

    Def.Quad{
        InitCommand=function(self)
            self:zoomto(0,2)
            self:align(0,0)
            self:xy(2, 2)
            self:diffuse( BoostColor( PlayerColor(master), 1 ))
            self:diffuserightedge( BoostColor( PlayerColor(master), 2 ))
        end,

        UpdateGameplayMessageCommand=function(self)
            self:zoomto((SCREEN_WIDTH - 4) * (current / total), height)
        end
    }
}