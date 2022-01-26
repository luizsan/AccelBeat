local gamecodes = {
    ["Options"] = {
        ["dance"]   = "Left,Right,Left,Right,Left,Right",
        ["pump"]    = "DownLeft,DownRight,DownLeft,DownRight,DownLeft,DownRight",
        ["default"] = "MenuLeft,MenuRight,MenuLeft,MenuRight,MenuLeft,MenuRight"
    }
}


function GameCode(code)
    if gamecodes and gamecodes[code] and gamecodes[code][string.lower(Game())] then
        return gamecodes[code][string.lower(Game())];
    else
        return gamecodes[code]["default"];
    end;
end;


local function MenuInputGame(button)
    local game = string.lower(Game());
    local inputs = {
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

    if inputs[game] and inputs[game][button] then
        return inputs[game][button]
    elseif inputs["default"][button] then
        return inputs["default"][button]
    else
        return ""
    end;
end;


function MenuInputActor()
    return Def.ActorFrame{
        MenuUpP1MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuUp"), Button = "Up", Player = PLAYER_1 }); end; 
        MenuUpP2MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuUp"), Button = "Up", Player = PLAYER_2 }); end; 
        MenuDownP1MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuDown"), Button = "Down", Player = PLAYER_1 }); end; 
        MenuDownP2MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuDown"), Button = "Down", Player = PLAYER_2 }); end; 
        MenuLeftP1MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuLeft"), Button = "Left", Player = PLAYER_1 }); end;
        MenuLeftP2MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuLeft"), Button = "Left", Player = PLAYER_2 }); end; 
        MenuRightP1MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuRight"), Button = "Right", Player = PLAYER_1 }); end; 
        MenuRightP2MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = MenuInputGame("MenuRight"), Button = "Right", Player = PLAYER_2 }); end; 
        CodeMessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = param.Name, Button = "", Player = param.PlayerNumber });  end;
    }
end;