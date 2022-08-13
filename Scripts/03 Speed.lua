DEFAULT_SPEED_VALUE = 500
DEFAULT_SPEED_TYPE = "maximum"
DEFAULT_INCREMENT = 25

function GetSpeed(pn)
    local state = GAMESTATE:GetPlayerState(pn)
    local options = state:GetPlayerOptions("ModsLevel_Preferred")

    if options:AMod() then
        return {  options:AMod(), "average" }
    elseif options:MMod() then
        return {  options:MMod(), "maximum" }
    elseif options:XMod() then
        return {  math.ceil(options:XMod() * 100), "multiple" }
    elseif options:CMod() then
        return {  options:CMod(), "constant" }
    else
        -- shouldn't be possible but ayy it's sm
        SCREENMAN:SystemMessage("Somehow this player has no speedmod set")
        return nil
    end
end

function SetSpeed(pn, value, type)
    if not value then return end

    local state = GAMESTATE:GetPlayerState(pn)
    local options = state:GetPlayerOptions("ModsLevel_Preferred")

    if not type then type = "maximum" end

    if type == "average" then
        options:AMod(value)
        state:ApplyPreferredOptionsToOtherLevels()

    elseif type == "maximum" then
        options:MMod(value)
        state:ApplyPreferredOptionsToOtherLevels()

    elseif type == "multiple" then
        options:XMod(math.ceil(value * 100) / 10000)
        state:ApplyPreferredOptionsToOtherLevels()

    elseif type == "constant" then
        options:CMod(value)
        state:ApplyPreferredOptionsToOtherLevels()

    else
        SCREENMAN:SystemMessage("Invalid speed mode, reverting to defaults")
        SetSpeed(pn, DEFAULT_SPEED_VALUE, DEFAULT_SPEED_TYPE)

    end
end

function SpeedFormat(value, type)
    if type == "average" then
        return "a"..tostring(value)
    elseif type == "maximum" then
        return "m"..tostring(value)
    elseif type == "multiple" then
        return string.format("%.2f", value/100).."x"
    elseif type == "constant" then
        return "c"..tostring(value)
    end
end