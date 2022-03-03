local _codes = {
    Options1 = { "MenuLeft", "MenuRight", "MenuLeft", "MenuRight", "MenuLeft", "MenuRight" },
    Options2 = { "DownLeft", "DownRight", "DownLeft", "DownRight", "DownLeft", "DownRight" },
    Sort1 = { "MenuUp-MenuDown" },
    Sort2 = { "UpLeft-UpRight" },
}

local _direction = {
    ["UpLeft"] = "Up",
    ["UpRight"] = "Down",
    ["DownLeft"] = "Left",
    ["DownRight"] = "Right",
    ["Center"] = "Center",
    --
    ["MenuUp"] = "Up",
    ["MenuDown"] = "Down",
    ["MenuLeft"] = "Left",
    ["MenuRight"] = "Right",
    ["Start"] = "Center",
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

local _specialKeys = {
    SHIFT = false,
    CTRL = false,
    ALT = false,
}

function ReleaseSpecialKeys()
    for key, value in pairs(_specialKeys) do
        _specialKeys[key] = false
    end
end

function SpecialKeys(event)
    for key, value in pairs(_specialKeys) do
        if event.DeviceInput.button:find(key:lower()) then
            if event.type == "InputEventType_FirstPress" then
                _specialKeys[key] = true
            elseif event.type == "InputEventType_Release" then
                _specialKeys[key] = false
            end
        end
    end
end

function MenuInputMaster(event)
    SpecialKeys(event)
    Search(event)
    Menu(event)
end

function Menu(event)
    if _specialKeys.ALT then return end
    if _specialKeys.CTRL then return end
    if event.type ~= "InputEventType_Release" then
        local context = {
            Menu = _menu[event.button] or event.button,
            Direction = _direction[event.button] or nil,
            Button = event.button,
            Player = event.PlayerNumber,
        }

        if context.Player and GAMESTATE:IsSideJoined(context.Player) then
            MESSAGEMAN:Broadcast("MenuInput", context)
            RunCodeQueue(context)
        end
    end
end

function Search(event)
    if _specialKeys.CTRL and event.DeviceInput.button == "DeviceButton_f" then
        MESSAGEMAN:Broadcast("Search")
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
        OnCommand=function(self) 
            _specialKeys.SHIFT = false
            _specialKeys.CTRL = false
            _specialKeys.ALT = false
            SCREENMAN:GetTopScreen():AddInputCallback( MenuInputMaster )  
        end,

        OffCommand=function(self) 
            SCREENMAN:GetTopScreen():RemoveInputCallback( MenuInputMaster ) 
        end,

        -- code messages are executed before input callback
        -- queue the code so it's executed along with the input callback (scroll up)
        CodeMessageCommand=function(self,context) 
            if context.PlayerNumber and GAMESTATE:IsSideJoined(context.PlayerNumber) then
                _codeQueue[context.PlayerNumber] = { Menu = context.Name, Player = context.PlayerNumber }
            end
        end
    }
end