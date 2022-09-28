local t = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_CENTER_X, SCREEN_BOTTOM)
        self:zoom(0.6)
    end,
}

local _game = GAMESTATE:GetCurrentGame():GetName()
local _screens = {
    ["ScreenSelectMusicCustom"] = true,
}

-- base
t[#t+1] = Def.Sprite{
    Texture = THEME:GetPathG("", "engine/" .._game.."_base"),
    InitCommand=function(self) 
        self:valign(1)
    end,
}

-- main lights
t[#t+1] = Def.ActorFrame{
    OnCommand=function(self)
        self:stoptweening()
        self:playcommand("Toggle")
        self:playcommand("Startup")
    end,

    ToggleCommand=function(self)
        self:visible( _screens[SCREENMAN:GetTopScreen():GetName()] and true or false ) 
    end,

    GridScrollMessageCommand=function(self)
        self:playcommand("Startup")
    end,

    StartupCommand=function(self)
        self:stoptweening()
        self:stopeffect()
        self:playcommand("Pulse")
        self:diffusealpha(0):sleep(0.5):linear(0.2):diffusealpha(SelectMusic.song and 1 or 0)
    end,

    PulseCommand=function(self)
        self:diffuseramp()
        self:effectclock("bgm")
        self:effectcolor1(BoostColor(Color.White, 0.5))
        self:effectcolor2(BoostColor(Color.White, 1))
    end,

    -- bloom
    Def.Sprite{
        Texture = THEME:GetPathG("", "engine/base_bloom"),
        InitCommand=function(self) 
            self:valign(1):blend("BlendMode_Add")
        end,
    },

    -- emission
    Def.Sprite{
        Texture = THEME:GetPathG("", "engine/base_emission"),
        InitCommand=function(self) 
            self:valign(1):blend("BlendMode_Add")
        end,
    },

    -- button bloom
    Def.Sprite{
        Texture = THEME:GetPathG("", "engine/".._game.."_buttons_bloom"),
        InitCommand=function(self) 
            self:valign(1):blend("BlendMode_Add")
        end,
    },

    -- button bloom
    Def.Sprite{
        Texture = THEME:GetPathG("", "engine/".._game.."_buttons_emission"),
        InitCommand=function(self) 
            self:valign(1):blend("BlendMode_Add"):diffusealpha(0.75)
        end,
    },

}

-- side lights
t[#t+1] = Def.ActorFrame{
    OnCommand=function(self)
        self:stoptweening()
        
        local _screen = SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusicCustom"
        local _stage = GAMESTATE:GetCurrentStageIndex()

        if not _screen then 
            self:diffusealpha(0)
            return
        end

        if _stage < 1 then
            self:diffusealpha(0)
            self:linear(0.75)
        end
        
        self:diffusealpha(1)
        self:sleep(0.25)
        self:diffuseshift()
        self:effectperiod(0.5)
        self:effectcolor1(BoostColor(Color.White, 0.25))
        self:effectcolor2(BoostColor(Color.White, 0.75))
    end,

    -- bloom
    Def.Sprite{
        Texture = THEME:GetPathG("", "engine/side_bloom"),
        InitCommand=function(self) 
            self:valign(1):blend("BlendMode_Add")
        end,
    },

    -- emission
    Def.Sprite{
        Texture = THEME:GetPathG("", "engine/side_emission"),
        InitCommand=function(self) 
            self:valign(1):blend("BlendMode_Add")
        end,
    },
}

return t