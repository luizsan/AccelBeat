function table.contains( table, element )
    for k,v in pairs(table) do
        if v == element then return true end
    end
    return false
end

function table.index( table, element )
    for k, v in ipairs(table) do
        if v == element then return k end
    end
    return nil
end