local DefaultMapDefinition = {}

function DefaultMapDefinition.createSimpleRoom(width, height)
    width = width or 20
    height = height or 15
    
    local walkable = {}
    local tileMap = {}
    
    for y = 1, height do
        walkable[y] = {}
        tileMap[y] = {}
        for x = 1, width do
            if x == 1 or x == width or y == 1 or y == height then
                walkable[y][x] = false
                tileMap[y][x] = 2
            else
                walkable[y][x] = true
                tileMap[y][x] = 1
            end
        end
    end
    
    -- Create map definition object manually to bypass validation bug
    local mapDefinition = {
        height = height,
        walkable = walkable,
        width = width,
        options = {},
        tileDefinitions = {[1] = ".", [2] = "█"},
        tileIds = {[1] = "floor", [2] = "wall"},
        tileMap = tileMap
    }
    
    return mapDefinition
end

return DefaultMapDefinition
