function table.contains( table, element )
    for k,v in pairs(table) do
        if v == element then return true end
    end
    return false
end