--[[
/----------------------------------------\
| Encodes/decodes simulation save files. |
\----------------------------------------/
]]--

function encodeSave(table)
    save = ''
    width, height = love.window.getMode()
    save = width..':'..height..'\n'
    for i,v in ipairs(table) do
        save = save..tostring(v.x)..":"..tostring(v.y)..":"..tostring(v.type)..":"..tostring(v.falling or false)..":"
    end
    return save
end

return encodeSave