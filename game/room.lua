-- Room generation module for ASCII Roguelike
local Room = {}

-- Helper function to create a rectangular room
function Room.createRoom(gameGrid, gridWidth, gridHeight, x1, y1, x2, y2)
    -- Make sure coordinates are in bounds
    x1 = math.max(2, x1)
    y1 = math.max(2, y1)
    x2 = math.min(gridWidth - 1, x2)
    y2 = math.min(gridHeight - 1, y2)
    
    -- Fill the room with floor tiles
    for y = y1, y2 do
        for x = x1, x2 do
            gameGrid[y][x] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
        end
    end
    
    -- Add walls around the room
    for x = x1 - 1, x2 + 1 do
        if x >= 1 and x <= gridWidth then
            if y1 - 1 >= 1 then
                gameGrid[y1 - 1][x] = {char = "#", color = {0.8, 0.8, 0.8}, walkable = false}
            end
            if y2 + 1 <= gridHeight then
                gameGrid[y2 + 1][x] = {char = "#", color = {0.8, 0.8, 0.8}, walkable = false}
            end
        end
    end
    for y = y1 - 1, y2 + 1 do
        if y >= 1 and y <= gridHeight then
            if x1 - 1 >= 1 then
                gameGrid[y][x1 - 1] = {char = "#", color = {0.8, 0.8, 0.8}, walkable = false}
            end
            if x2 + 1 <= gridWidth then
                gameGrid[y][x2 + 1] = {char = "#", color = {0.8, 0.8, 0.8}, walkable = false}
            end
        end
    end
end

-- Helper function to create a corridor between two points
function Room.createCorridor(gameGrid, gridWidth, gridHeight, x1, y1, x2, y2)
    -- Create horizontal corridor first
    local startX, endX = math.min(x1, x2), math.max(x1, x2)
    for x = startX, endX do
        if x >= 1 and x <= gridWidth and y1 >= 1 and y1 <= gridHeight then
            gameGrid[y1][x] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
        end
    end
    
    -- Then create vertical corridor
    local startY, endY = math.min(y1, y2), math.max(y1, y2)
    for y = startY, endY do
        if x2 >= 1 and x2 <= gridWidth and y >= 1 and y <= gridHeight then
            gameGrid[y][x2] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
        end
    end
end

-- Generate the default room layout for the game
function Room.generateDefaultLayout(gameGrid, gridWidth, gridHeight)
    -- Create some rooms
    Room.createRoom(gameGrid, gridWidth, gridHeight, 5, 3, 15, 8)        -- Top-left room
    Room.createRoom(gameGrid, gridWidth, gridHeight, 20, 3, 35, 12)      -- Top-right room  
    Room.createRoom(gameGrid, gridWidth, gridHeight, 5, 15, 20, 25)      -- Bottom-left room
    Room.createRoom(gameGrid, gridWidth, gridHeight, 25, 18, 40, 28)     -- Bottom-right room
    Room.createRoom(gameGrid, gridWidth, gridHeight, 12, 10, 25, 15)     -- Center room
    
    -- Create corridors to connect rooms
    -- Horizontal corridor connecting top rooms
    Room.createCorridor(gameGrid, gridWidth, gridHeight, 15, 6, 20, 6)
    
    -- Vertical corridor connecting center to top
    Room.createCorridor(gameGrid, gridWidth, gridHeight, 18, 8, 18, 10)
    
    -- Corridor connecting center to bottom-left
    Room.createCorridor(gameGrid, gridWidth, gridHeight, 12, 15, 20, 15)
    
    -- Corridor connecting center to bottom-right
    Room.createCorridor(gameGrid, gridWidth, gridHeight, 25, 15, 25, 18)
end

-- Find a safe starting position for the player in any walkable area
function Room.findPlayerStartPosition(gameGrid, gridWidth, gridHeight)
    -- Try center room first (preferred starting location)
    local centerX, centerY = 18, 12
    if centerX <= gridWidth and centerY <= gridHeight and 
       gameGrid[centerY] and gameGrid[centerY][centerX] and 
       gameGrid[centerY][centerX].walkable then
        return centerX, centerY
    end
    
    -- Fallback: find any walkable tile
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            if gameGrid[y][x].walkable then
                return x, y
            end
        end
    end
    
    -- Should never reach here, but just in case
    return math.floor(gridWidth/2), math.floor(gridHeight/2)
end

return Room
