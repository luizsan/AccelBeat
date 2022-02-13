function FilterSongs(songs)
    local filtered = {}
    local steps = {}
    
    for i = 1, #songs do
        steps = FilterSteps( songs[i] )
        if #steps > 0 then
            filtered[#filtered+1] = songs[i]
        end
    end

    if #filtered == 0 then filtered = {} end
    return filtered
end


function FilterSteps(song)
    local filtered = {}
    local steps = song:GetAllSteps()
    if song and steps then
        for i = 1, #steps do
            if steps[i] and steps[i]:GetMeter() > 0 and EligibleSteps(steps[i]) then
                filtered[#filtered+1] = steps[i]
            end
        end
        table.sort(filtered,function(a,b) return SortSteps(a,b) end)
        return filtered
    else
        return {}
    end
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


function StepsType:Compare( e1, e2 )
	local Reverse = self:Reverse()
	local Value1 = Reverse[e1]
	local Value2 = Reverse[e2]

	assert( Value1, tostring(e1) .. " is not an enum of type " .. self:GetName() )
	assert( Value2, tostring(e2) .. " is not an enum of type " .. self:GetName() )

	-- Nil enums correspond to "invalid". These compare greater than any valid
	-- enum value, to line up with the equivalent C++ code.

	-- should this be changed to math.huge()? -shake
	if not e1 then
		Value1 = 99999999
	end
	if not e2 then
		Value2 = 99999999
	end
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


function EligibleSteps(step)
    local st = step:GetStepsType()

    -- do not show steps from games other than the current
    if not string.find(st:lower(), Game():lower()) then return false end

    local type = ToEnumShortString(st)
    local joined = GAMESTATE:GetNumSidesJoined()

    local multi = {
        "Double",
        "Couple",
        "Halfdouble",
        "Routine"
    }
    
    local sides_required = 1

    for i,s in ipairs(multi) do
        if string.find(type, s) then
            sides_required = 2
        end
    end

    if joined > 1 and sides_required == joined then 
        return false 
    end

    return true
end