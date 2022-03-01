-- stepstype that requires both sides
local _multi = {
    "Double",
    "Couple",
    "Halfdouble",
    "Routine"
}

function FilterSongs(songs, sides)
    local filtered = {}
    if songs then
        for i = 1, #songs do
            local steps = FilterSteps( songs[i], sides )
            if #steps > 0 then
                filtered[#filtered+1] = songs[i]
            end
        end
    end
    return filtered
end


function FilterSteps(song, sides)
    local filtered = {}
    local steps = song and song:GetAllSteps() or nil
    if song and steps then
        for i = 1, #steps do
            if steps[i] and steps[i]:GetMeter() > 0 and EligibleSteps(steps[i], sides) then
                filtered[#filtered+1] = steps[i]
            end
        end
        table.sort(filtered,function(a,b) return SortSteps(a,b) end)
    end
    return filtered
end


function SortSongsByFolder(a,b)
    return a:GetSongFolder() < b:GetSongFolder()
end

function SortSongsByTitle(a,b)
    return a:GetTranslitFullTitle() < b:GetTranslitFullTitle()
end

function SortSongsByArtist(a,b)
    return a:GetTranslitArtist() < b:GetTranslitArtist()
end

-- had to copy this over from _fallback because it wasn't working
function StepsType:Compare( e1, e2 )
	local Reverse = self:Reverse()
	local Value1 = Reverse[e1]
	local Value2 = Reverse[e2]

	assert( Value1, tostring(e1) .. " is not an enum of type " .. self:GetName() )
	assert( Value2, tostring(e2) .. " is not an enum of type " .. self:GetName() )
	-- Nil enums correspond to "invalid". These compare greater than any valid
	-- enum value, to line up with the equivalent C++ code.

	-- should this be changed to math.huge()? -shake
	if not e1 then Value1 = math.huge end
	if not e2 then Value2 = math.huge end
	return Value1 - Value2
end


function SortSteps(a,b)
    local s = StepsType:Compare(a:GetStepsType(),b:GetStepsType()) < 0
    if a:GetStepsType() == b:GetStepsType() then
        return a:GetMeter() < b:GetMeter()
    else
        return s
    end
end


function SidesRequired(stepstype)
    for i, s in ipairs(_multi) do
        if string.find(stepstype, s) then
            return 2
        end
    end
    return 1
end

-- improve this later
function EligibleSteps(step, sides)
    local st = step:GetStepsType()

    -- do not show steps from games other than the current
    if not string.find(st:lower(), GameName():lower()) then return false end

    local type = ToEnumShortString(st)
    local joined = GAMESTATE:GetNumSidesJoined()
    
    local sides_required = SidesRequired(type)
    
    if sides then
        if sides == FilterMode.Singles and sides_required == 2 then return false end
        if sides == FilterMode.Doubles and sides_required == 1 then return false end
    end

    if joined > 1 and joined == sides_required then 
        return false 
    end

    return true
end