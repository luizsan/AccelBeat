local _codes = {
    OptionsNormal = { "Left", "Right", "Left", "Right", "Left", "Right" },
    OptionsMenu = { "MenuLeft", "MenuRight", "MenuLeft", "MenuRight", "MenuLeft", "MenuRight" },
    OptionsPump = { "DownLeft", "DownRight", "DownLeft", "DownRight", "DownLeft", "DownRight" },
}

local _direction = {
    ["UpLeft"] = "Up",
    ["UpRight"] = "Down",
    ["DownLeft"] = "Left",
    ["DownRight"] = "Right",
    --
    ["MenuUp"] = "Up",
    ["MenuDown"] = "Down",
    ["MenuLeft"] = "Left",
    ["MenuRight"] = "Right",
}

local _menu = {
    ["UpLeft"] = "Return",
    ["UpRight"] = "Return",
    ["DownLeft"] = "Prev",
    ["DownRight"] = "Next",
    ["Center"] = "Start",

    ["Up"] = "Prev",
    ["Down"] = "Next",
    ["Left"] = "Prev",
    ["Right"] = "Next",

    ["Up"] = "Prev",
    ["Down"] = "Next",
    ["Left"] = "Prev",
    ["Right"] = "Next",
}

local _codeQueue = {
    [PLAYER_1] = nil,
    [PLAYER_2] = nil,
}

function MenuInputMaster(event)
    if event.type ~= "InputEventType_Release" then
        local context = {
            Menu = _menu[event.button] or event.button,
            Direction = _direction[event.button] or event.button,
            Button = event.button,
            Player = event.PlayerNumber,
        }

        if context.Player and GAMESTATE:IsSideJoined(context.Player) then
            MESSAGEMAN:Broadcast("MenuInput", context)
            RunCodeQueue(context)
        end
    end
end

function RunCodeQueue(context)
    if not context or not context.Player then return end
    if _codeQueue[context.Player] then 
        MESSAGEMAN:Broadcast("MenuInput", _codeQueue[context.Player] )
        _codeQueue[context.Player] = nil
    end
end

function GameCode(code)
    return table.concat( _codes[code], "," )
end

function DirectionIndex(dir)
    if not dir then return nil end
    if dir == "Up" or dir == "Left" then return -1 end
    if dir == "Down" or dir == "Right" then return 1 end
    return 0 
end

function MenuInputActor()
    return Def.ActorFrame{
        OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( MenuInputMaster )  end,
        OffCommand=function(self) SCREENMAN:GetTopScreen():RemoveInputCallback( MenuInputMaster ) end,

        -- code messages are executed before input callback
        -- queue the code so it's executed along with the input callback (scroll up)
        CodeMessageCommand=function(self,context) 
            if context.PlayerNumber and GAMESTATE:IsSideJoined(context.PlayerNumber) then
                local code = _codes[context.Name] or nil
                local last_press = code[#code]
                local pn = context.PlayerNumber
                _codeQueue[pn] = { Menu = context.Name, Player = pn }
            end
        end
    }
end