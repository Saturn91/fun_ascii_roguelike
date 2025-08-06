local MapAdapter = {}

MapAdapter.__index = MapAdapter

function MapAdapter.new()
    local self = setmetatable({}, MapAdapter)
    return self
end

function MapAdapter.createLayerFromMapDefinition(mapDefinition, layerId, offsetX, offsetY)
    if not mapDefinition then
        error("MapDefinition is required")
    end
    
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    layerId = layerId or "map"
    
    local layer = AsciiGrid:new(layerId)
    
    return layer, function(engine)
        layer:initialize(engine)
        
        for y = 1, mapDefinition.height do
            for x = 1, mapDefinition.width do
                local tileIndex = mapDefinition.tileMap[y][x]
                local tileChar = mapDefinition.tileDefinitions[tileIndex]
                
                if tileChar then
                    local screenX = x + offsetX
                    local screenY = y + offsetY
                    
                    local cols, rows = engine:getGridSize()
                    if screenX >= 1 and screenX <= cols and screenY >= 1 and screenY <= rows then
                        layer:setCell(screenX, screenY, tileChar.glyph, tileChar.color, nil)
                    end
                end
            end
        end
    end
end

return MapAdapter
