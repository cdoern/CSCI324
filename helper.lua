function readFile(file)
    local d = {}
    local f = io.open("dictionary.txt")
    for fields in f:lines() do
        w = string.gsub(fields,"\r", "")
        --w = string.gsub(fields,"'", "")
        local f2 = io.open("dictionary1.txt", "a+")
        f2:write(w .. "\n")
        f2:close()
    end
    f:close()
end

readFile()