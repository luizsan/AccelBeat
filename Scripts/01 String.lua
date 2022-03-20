function string.startswith(s, pattern)
    if not s then return false end
    return string.sub(s, 1, string.len(pattern)) == pattern
end

function string.cap(s, cap, digits)
    return string.rep(cap, digits - #tostring(s))..tostring(s)
end

function GameName()
	local game = string.upper(GAMESTATE:GetCurrentGame():GetName())
	local temp1 = string.sub(string.lower(game), 2)
	local text = string.gsub(string.upper(game),string.upper(temp1),temp1)
	return text
end

function ShortType(steps)
    if steps then
        return string.gsub( ToEnumShortString(steps:GetStepsType()), GameName().."_","")
    else
        return nil
    end
end

function ValidMetadata(s)
    if not s then return false end
    if s == "" then return false end
    if s:lower() == "blank" then return false end
    return true
end

function FormatAward(award)
    if award == "StageAward_FullComboW3" then return "Full Combo!"
    elseif award == "StageAward_SingleDigitW3" then return "Single Digit Greats!"
    elseif award == "StageAward_OneW3" then return "One Great!"
    elseif award == "StageAward_FullComboW2" then return "Full Perfect!"
    elseif award == "StageAward_SingleDigitW2" then return "Single Digit Perfects!"
    elseif award == "StageAward_OneW2" then return "One Perfect!"
    elseif award == "StageAward_FullComboW1" then return "Absolutely Flawless!"
    else return nil
    end
end

function DateToNumber(datetime)
    local str = datetime
    str = string.gsub(str, "-", "")
    str = string.gsub(str, ":", "")
    str = string.gsub(str, " ", "")
    return tonumber(str)
end