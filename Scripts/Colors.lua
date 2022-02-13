local pn_color = {
    [PLAYER_1] = {0.20,0.75,1, alpha or 1},
    [PLAYER_2] = {0.2,1,0.8, alpha or 1}, 
}

local st_color = {
    -- yellow
    ["Single"] = {0.95,0.75,0.1,1},

    -- green
    ["Double"] = {0.2,0.9,0.2,1},

    -- magenta
    ["Halfdouble"] = {0.8,0.1,0.6,1},

    -- blue
    ["Routine"] = {0.3,0.85,1,1},

    -- pink
    ["Solo"] = {1,0.5,0.5,1},
    ["Couple"] = {1,0.5,0.5,1},
    ["Real"] = {1,0.5,0.5,1},
}


local accent_color = {
    ["Blue"] = {
        { 0, 0.625, 1, 1 },
        { 0.332031, 0.988281, 1, 1 },
        { 0, 1, 1, 0.25 },
        { 0.117187, 0.238281, 0.773437, 0.5 },
    },
}

function PlayerColor(pn, alpha)
    return pn_color[pn] or {1,1,1,1}
end

function StepsColor(steps)
    if steps then
        local type = ShortType(steps)
        return st_color[type] or Color.White
    end
    return Color.White
end

function AccentColor(color, index)
    if accent_color[color] and accent_color[color][index] then
        return accent_color[color][index]
    else
        return Color.White
    end
end