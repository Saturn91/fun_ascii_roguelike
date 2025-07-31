-- Room generation module for ASCII Roguelike
local Room = {}

-- Import the map generator
local MapGenerator = require("game.mapGenerator")

-- Find a safe starting position for the player in any walkable area
function Room.findPlayerStartPosition(gameGrid, gridWidth, gridHeight)
    -- Try to use the first generated room if available
    if MapGenerator.generatedRooms and #MapGenerator.generatedRooms > 0 then
        local startingRoom = MapGenerator.findStartingRoom(MapGenerator.generatedRooms)
        if startingRoom then
            local centerX, centerY = MapGenerator.getRoomCenter(startingRoom)
            if centerX <= gridWidth and centerY <= gridHeight and 
               gameGrid[centerY] and gameGrid[centerY][centerX] and 
               gameGrid[centerY][centerX].walkable then
                return centerX, centerY
            end
        end
    end
    
    -- Fallback: find any walkable tile
    for y = 3, gridHeight do -- Start from y=3 to avoid health bar area
        for x = 1, gridWidth do
            if gameGrid[y] and gameGrid[y][x] and gameGrid[y][x].walkable then
                return x, y
            end
        end
    end
    
    -- Should never reach here, but just in case
    return math.floor(gridWidth/2), math.floor(gridHeight/2)
end

return Room
