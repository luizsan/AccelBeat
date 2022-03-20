function table.contains( t, element )
    for k, v in pairs(t) do
        if v == element then return true end
    end
    return false
end

function table.index( t, element )
    for k, v in ipairs(t) do
        if v == element then return k end
    end
    return nil
end

function table.reverse( t )
    local reverse = {}
    local count = #t
    for k, v in ipairs(t) do
        reverse[count + 1 - k] = v
    end
    return reverse
end

