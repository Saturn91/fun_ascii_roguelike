GridChar = require("asciiEngine.GridChar")
AsciiGrid = require("asciiEngine.asciiGrid")

local AsciiEngine = {}

AsciiEngine.__index = AsciiEngine

function AsciiEngine:new(options)
    options = options or {}
    local instance = setmetatable({}, self)
    
    -- Core properties
    instance.gridCols = options.gridCols or 80
    instance.gridRows = options.gridRows or 25
    instance.font = options.font
    
    -- Scaling and positioning
    instance.scale = 1
    instance.offsetX = 0
    instance.offsetY = 0
    instance.charWidth = 0
    instance.charHeight = 0
    
    -- Layers system
    instance.layers = {}
    instance.layerLookUp = {}
    
    -- Initialize font if provided
    if instance.font then
        instance:setFont(instance.font)
    end
    
    return instance
end

function AsciiEngine:setFont(font)
    self.font = font
    love.graphics.setFont(font)
    
    -- Calculate character dimensions using a wide character
    local testChar = "M"
    self.charWidth = font:getWidth(testChar)
    self.charHeight = font:getHeight()
    
    -- Recalculate scaling after font change
    self:calculateScaling()
end

function AsciiEngine:setGridSize(cols, rows)
    self.gridCols = cols
    self.gridRows = rows
    self:calculateScaling()
    
    for _, layer in ipairs(self.layers) do
        layer:initialize(self)
    end
end

function AsciiEngine:calculateScaling()
    if not self.font then
        return
    end
    
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    -- Calculate required dimensions for the grid
    local requiredWidth = self.gridCols * self.charWidth
    local requiredHeight = self.gridRows * self.charHeight
    
    -- Calculate scale to fit window (maintain aspect ratio)
    local scaleX = windowWidth / requiredWidth
    local scaleY = windowHeight / requiredHeight
    self.scale = math.min(scaleX, scaleY)
    
    -- Calculate centering offsets
    local scaledWidth = requiredWidth * self.scale
    local scaledHeight = requiredHeight * self.scale
    self.offsetX = (windowWidth - scaledWidth) / 2
    self.offsetY = (windowHeight - scaledHeight) / 2
end

function AsciiEngine:addLayer(layer)
    layer:initialize(self)
    if self.layerLookUp[layer.id] then error("Layer with id '" .. layer.id .. "' already exists") end
    self.layerLookUp[layer.id] = layer
    table.insert(self.layers, layer)
end

function AsciiEngine:draw()
    love.graphics.push()
    
    love.graphics.translate(self.offsetX, self.offsetY)
    love.graphics.scale(self.scale, self.scale)

    love.graphics.setFont(self.font)
    
    for _, layer in ipairs(self.layers) do
        if layer.draw then
            layer:draw()
        end
    end
    
    love.graphics.pop()
end

function AsciiEngine:screenToGrid(screenX, screenY)
    local gridX = math.floor((screenX - self.offsetX) / (self.charWidth * self.scale)) + 1
    local gridY = math.floor((screenY - self.offsetY) / (self.charHeight * self.scale)) + 1
    
    gridX = math.max(1, math.min(self.gridCols, gridX))
    gridY = math.max(1, math.min(self.gridRows, gridY))
    
    return gridX, gridY
end

function AsciiEngine:gridToScreen(gridX, gridY)
    local screenX = (gridX - 1) * self.charWidth * self.scale + self.offsetX
    local screenY = (gridY - 1) * self.charHeight * self.scale + self.offsetY
    
    return screenX, screenY
end

function AsciiEngine:resize()
    self:calculateScaling()
end

function AsciiEngine:getGridSize()
    return self.gridCols, self.gridRows
end

function AsciiEngine:getCharSize()
    return self.charWidth, self.charHeight
end

function AsciiEngine:getScale()
    return self.scale
end

function AsciiEngine:getLayerById(id)
    return self.layerLookUp[id]
end

return AsciiEngine