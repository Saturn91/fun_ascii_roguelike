local Char = {}
Char.__index = Char

function Char:new(x, y, options)
    options = options or {}
    local instance = setmetatable({}, self)
    instance.x = x
    instance.y = y
    instance.glyph = options.glyph or ' '
    instance.color = options.color or {1, 1, 1, 1} -- Default to white (LOVE2D color format)
    instance.backgroundColor = options.backgroundColor -- Can be nil for transparent
    return instance
end

function Char:setGlyph(glyph)
    self.glyph = glyph
end

function Char:setColor(color)
    self.color = color
end

function Char:setBackgroundColor(backgroundColor)
    self.backgroundColor = backgroundColor
end

return Char