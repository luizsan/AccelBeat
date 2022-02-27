function clamp(t, min, max)
    if t < min then return min elseif t > max then return max else return t end
end

function loop(t, min, max)
    return (((t - min) % (max - min)) + (max - min)) % (max - min) + min
end