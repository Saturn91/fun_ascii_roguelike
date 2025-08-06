Char = require("asciiEngine.char")

local GridChar = {}
GridChar.__index = GridChar
setmetatable(GridChar, Char)

function GridChar:new(x, y, options)
    options = options or {}
    local instance = setmetatable(Char:new(options.glyph, options.color), self)
    instance.x = x
    instance.y = y
    return instance
end

return GridChar