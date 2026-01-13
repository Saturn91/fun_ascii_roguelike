local MapAdapter = {}

MapAdapter.__index = MapAdapter

function MapAdapter.new(mapDefinition, layerId, offsetX, offsetY)
    local self = setmetatable({}, MapAdapter)
    
    if not mapDefinition then
        error("MapDefinition is required")
    end
    
    self.mapDefinition = mapDefinition
    self.offsetX = offsetX or 0
    self.offsetY = offsetY or 0
    self.layerId = layerId or "map"
    self.layer = AsciiGrid:new(self.layerId)
    
    return self
end

function MapAdapter:populate(engine)
    self.layer:initialize(engine)
    
    for y = 1, self.mapDefinition.height do
        for x = 1, self.mapDefinition.width do
            local tileIndex = self.mapDefinition.tileMap[y][x]
            local tileChar = self.mapDefinition.tileDefinitions[tileIndex]
            
            if tileChar then
                local screenX = x + self.offsetX
                local screenY = y + self.offsetY
                
                local cols, rows = engine:getGridSize()
                if screenX >= 1 and screenX <= cols and screenY >= 1 and screenY <= rows then
                    self.layer:setCell(screenX, screenY, tileChar.glyph, tileChar.color, nil)
                end
            end
        end
    end
end

function MapAdapter:updateMap(newMapDefinition, engine)
    if not newMapDefinition then
        error("MapDefinition is required")
    end
    
    self.mapDefinition = newMapDefinition
    self.layer:clear()
    
    for y = 1, self.mapDefinition.height do
        for x = 1, self.mapDefinition.width do
            local tileIndex = self.mapDefinition.tileMap[y][x]
            local tileChar = self.mapDefinition.tileDefinitions[tileIndex]
            
            if tileChar then
                local screenX = x + self.offsetX
                local screenY = y + self.offsetY
                
                local cols, rows = engine:getGridSize()
                if screenX >= 1 and screenX <= cols and screenY >= 1 and screenY <= rows then
                    self.layer:setCell(screenX, screenY, tileChar.glyph, tileChar.color, nil)
                end
            end
        end
    end
end

return MapAdapter
