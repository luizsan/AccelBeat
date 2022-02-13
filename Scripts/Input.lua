local _gamecodes = {
    ["Options"] = {
        ["dance"]   = "Left,Right,Left,Right,Left,Right",
        ["pump"]    = "DownLeft,DownRight,DownLeft,DownRight,DownLeft,DownRight",
        ["default"] = "MenuLeft,MenuRight,MenuLeft,MenuRight,MenuLeft,MenuRight"
    },
    ["Sort"] = {
        ["dance"]   = "Up-Down",
        ["pump"]    = "UpLeft-UpRight",
        ["default"] = "MenuUp-MenuDown"
    }
}

local _inputs = {
    ["pump"] = {
        ["MenuUp"] = "Back",
        ["MenuDown"] = "Back",
        ["MenuLeft"] = "Prev",
        ["MenuRight"] = "Next",
    },
    ["default"] = {
        ["MenuUp"] = "Prev",
        ["MenuDown"] = "Next",
        ["MenuLeft"] = "Prev",
        ["MenuRight"] = "Next",
    },
}

function GameCode(code)
    if _gamecodes and _gamecodes[code] and _gamecodes[code][Game():lower()] then
        return _gamecodes[code][Game():lower()];
    else
        return _gamecodes[code]["default"];
    end;
end;

local function MenuInputGame(button)
    local game = Game();
    if _inputs[game] and _inputs[game][button] then
        return _inputs[game][button]
    elseif _inputs["default"][button] then
        return _inputs["default"][button]
    else
        return ""
    end;
end;


function MenuInputActor()
    return Def.ActorFrame{
        MenuUpP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuUp"), Button = "Up", Player = PLAYER_1 }); end; 
        MenuUpP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuUp"), Button = "Up", Player = PLAYER_2 }); end; 
        MenuDownP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuDown"), Button = "Down", Player = PLAYER_1 }); end; 
        MenuDownP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuDown"), Button = "Down", Player = PLAYER_2 }); end; 
        MenuLeftP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuLeft"), Button = "Left", Player = PLAYER_1 }); end;
        MenuLeftP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuLeft"), Button = "Left", Player = PLAYER_2 }); end; 
        MenuRightP1MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuRight"), Button = "Right", Player = PLAYER_1 }); end; 
        MenuRightP2MessageCommand=function(self) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuRight"), Button = "Right", Player = PLAYER_2 }); end; 
        CodeMessageCommand=function(self,context) MESSAGEMAN:Broadcast("MenuInput", { Input = context.Name, Button = "", Player = context.PlayerNumber });  end;
    }
end;