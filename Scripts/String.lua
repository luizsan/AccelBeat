function string.startswith(s, pattern)
    return string.sub(s, 1, string.len(pattern)) == pattern
end