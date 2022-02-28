local slot = {
    [PLAYER_1] = "ProfileSlot_Player1",
    [PLAYER_2] = "ProfileSlot_Player2",
}

ThemeConfigDir = "AccelBeat/ThemeConfig.ini"
PlayerConfigDir = "AccelBeat/PlayerConfig.ini"

function GetPlayerOrMachineProfileDir(pn)
    if slot[pn] then 
        local profile_dir = PROFILEMAN:GetProfileDir( slot[pn] ) 
        if profile_dir and profile_dir ~= "" then 
            return profile_dir 
        end
    end
    return PROFILEMAN:GetProfileDir("ProfileSlot_Machine")
end