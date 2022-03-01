function string.startswith(s, pattern)
    if not s then return false
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