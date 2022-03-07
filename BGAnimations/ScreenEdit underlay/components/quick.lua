
local master = GAMESTATE:GetMasterPlayerNumber()
local profile_dir = GetPlayerOrMachineProfileDir(master)

local labelSize = 0.475
local itemSize = 0.55

local speed_mod
local speed_type


local ml = "ModsLevel_Preferred"

function ToggleMusicRate(event)
    if SCREENMAN:GetTopScreen():GetEditState() ~= "EditState_Edit" then return end
    if event.type == "InputEventType_FirstPress" then
        if event.DeviceInput.button == "DeviceButton_h" then
            if GAMESTATE:GetSongOptionsObject(ml):MusicRate() < 1 then
                GAMESTATE:GetSongOptionsObject(ml):Haste(1,math.huge)
                GAMESTATE:GetSongOptionsObject(ml):MusicRate(1,math.huge)
            else
                GAMESTATE:GetSongOptionsObject(ml):Haste(0.5,math.huge)
                GAMESTATE:GetSongOptionsObject(ml):MusicRate(0.5,math.huge)
            end
            GAMESTATE:ApplyPreferredSongOptionsToOtherLevels( )
            --SCREENMAN:SystemMessage("Set Rate to "..GAMESTATE:GetSongOptionsObject(ml):MusicRate())
            MESSAGEMAN:Broadcast("EditorOptionChanged")
        end
    end
end

function ChangeSpeed(event)
    if event.type == "InputEventType_FirstPress" then
        if event.DeviceInput.button == "DeviceButton_u" then
            local index = table.index( SpeedType, speed_type ) or 1
            speed_type = SpeedType[loop( index + 1, 1, #SpeedType + 1)]
            SetSpeed(master, speed_mod, speed_type)
            LoadModule("Config.Save.lua")("Speed", speed_mod, profile_dir.."/"..EditorConfigDir)
            LoadModule("Config.Save.lua")("Type", speed_type, profile_dir.."/"..EditorConfigDir)

        elseif event.DeviceInput.button == "DeviceButton_i" then
            speed_mod = speed_mod -25
            SetSpeed(master, speed_mod, speed_type)
            LoadModule("Config.Save.lua")("Speed", speed_mod, profile_dir.."/"..EditorConfigDir)
            LoadModule("Config.Save.lua")("Type", speed_type, profile_dir.."/"..EditorConfigDir)
            
        elseif event.DeviceInput.button == "DeviceButton_o" then
            speed_mod = speed_mod +25
            SetSpeed(master, speed_mod, speed_type)
            LoadModule("Config.Save.lua")("Speed", speed_mod, profile_dir.."/"..EditorConfigDir)
            LoadModule("Config.Save.lua")("Type", speed_type, profile_dir.."/"..EditorConfigDir)

        end
    end
    MESSAGEMAN:Broadcast("EditorOptionChanged")
end


function DefaultSpeed()
    speed_mod = LoadModule("Config.Load.lua")("Speed", profile_dir.."/"..EditorConfigDir) or DEFAULT_SPEED_VALUE
    speed_type = LoadModule("Config.Load.lua")("Type", profile_dir.."/"..EditorConfigDir) or DEFAULT_SPEED_TYPE
    SetSpeed(master, speed_mod, speed_type)
    LoadModule("Config.Save.lua")("Speed", speed_mod, profile_dir.."/"..EditorConfigDir)
    LoadModule("Config.Save.lua")("Type", speed_type, profile_dir.."/"..EditorConfigDir)
end

local function EditControls(event)
    ToggleMusicRate(event)
    ChangeSpeed(event)
end



local t = Def.ActorFrame{
    InitCommand=function(self)
        DefaultSpeed(master)
    end,

    OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( EditControls ) end,
    OffCommand=function(self) SCREENMAN:GetTopScreen():RemoveInputCallback( EditControls ) end,
    EditorStateChangedMessageCommand=function(self, context)
        self:visible( context.EditState ~= "EditState_Playing" )
    end,
}



t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_LEFT + 20, SCREEN_BOTTOM - 88)
    end,

    Def.BitmapText{
        Font = Font.EditorUINormal,
        Text = "Quick Settings",
        InitCommand=function(self) 
            self:zoomto(32,32)
            self:align(0,1)
            self:zoom(labelSize)
            self:diffuse( BoostColor(Color.White, 0.5))
        end,
    },

    Def.BitmapText{
        Font = Font.EditorUIHeavy,
        Text = "Music Rate",
        InitCommand=function(self) 
            self:zoomto(32,32)
            self:align(0,1)
            self:xy(8,20)
            self:zoom(itemSize)
            self:diffuse( Color.White )
            self:playcommand("Refresh")
        end,

        EditorOptionChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        RefreshCommand=function(self)
            local rate = string.format("[H] Music Rate: %.f", GAMESTATE:GetSongOptionsObject(ml):MusicRate() * 100)
            self:settext(rate.."%")
        end,
    },

    Def.BitmapText{
        Font = Font.EditorUIHeavy,
        Text = "Speed",
        InitCommand=function(self) 
            self:zoomto(32,32)
            self:align(0,1)
            self:xy(8,40)
            self:zoom(itemSize)
            self:diffuse( Color.White )
        end,

        OnCommand=function(self)
            self:playcommand("Refresh")
        end,

        EditorOptionChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        RefreshCommand=function(self)
            local s = string.format("[I][O] Speed: %s", SpeedFormat(speed_mod, speed_type))
            self:settext(s)
        end,
    },

    Def.BitmapText{
        Font = Font.EditorUIHeavy,
        Text = "Mode",
        InitCommand=function(self) 
            self:zoomto(32,32)
            self:align(0,1)
            self:xy(8,60)
            self:zoom(itemSize)
            self:diffuse( Color.White )
        end,
        
        OnCommand=function(self)
            self:playcommand("Refresh")
        end,

        EditorOptionChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        RefreshCommand=function(self)
            local m = string.format("[U] Mode: %s", speed_type )
            self:settext(m)
        end,
    },
}


return t
