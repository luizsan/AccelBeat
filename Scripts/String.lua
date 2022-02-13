function string.startswith(s, pattern)
    return string.sub(s, 1, string.len(pattern)) == pattern
end

function string.cap(s, cap, digits)
    return string.rep(cap, digits - #tostring(s))..tostring(s)
end

function ShortType(steps)
    if steps then
        return string.gsub( ToEnumShortString(steps:GetStepsType()), Game().."_","")
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