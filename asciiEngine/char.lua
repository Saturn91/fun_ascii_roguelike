local Char = {}

Char.__index = Char

function Char:new(glyph, color)
    local instance = setmetatable({}, self)
    instance.glyph = glyph or ' '
    instance.color = color or {1, 1, 1, 1}
    return instance
end

return Char