-- Map Generator module for ASCII Roguelike
-- Handles procedural dungeon generation
local MapGenerator = {}

-- Generate non-overlapping rooms on the map
function MapGenerator.generateRooms(gameGrid, gridWidth, gridHeight, amount, minSize, maxSize)
    amount = amount or 5
    minSize = minSize or 5
    maxSize = maxSize or 8
    
    local rooms = {}
    local maxAttempts = 500 -- Increased from 100 to allow more attempts
    local attempts = 0
    local consecutiveFailures = 0
    local maxConsecutiveFailures = 50 -- If we fail 50 times in a row, stop trying
    
    while #rooms < amount and attempts < maxAttempts and consecutiveFailures < maxConsecutiveFailures do
        attempts = attempts + 1
        
        -- Generate random room dimensions
        local roomWidth = love.math.random(minSize, maxSize)
        local roomHeight = love.math.random(minSize, maxSize)
        
        -- Generate random position (leave border space)
        local x = love.math.random(2, gridWidth - roomWidth - 2)
        local y = love.math.random(3, gridHeight - roomHeight - 2) -- Start at y=3 to avoid health bar area
        
        -- Create room bounds
        local newRoom = {
            x1 = x,
            y1 = y,
            x2 = x + roomWidth - 1,
            y2 = y + roomHeight - 1,
            width = roomWidth,
            height = roomHeight,
            centerX = math.floor(x + roomWidth / 2),
            centerY = math.floor(y + roomHeight / 2)
        }
        
        -- Check if this room overlaps with any existing room
        local overlaps = false
        for _, existingRoom in ipairs(rooms) do
            if MapGenerator.roomsOverlap(newRoom, existingRoom) then
                overlaps = true
                break
            end
        end
        
        -- If no overlap, add the room
        if not overlaps then
            table.insert(rooms, newRoom)
            MapGenerator.createRoom(gameGrid, newRoom)
            consecutiveFailures = 0 -- Reset failure counter
        else
            consecutiveFailures = consecutiveFailures + 1
        end
    end
    
    -- Log generation statistics
    if Log then
        if #rooms < amount then
            local reason = ""
            if attempts >= maxAttempts then
                reason = "max attempts"
            elseif consecutiveFailures >= maxConsecutiveFailures then
                reason = "map full"
            end
            
            Log.log(string.format("[warning]Generated %d/%d rooms (%s)[/warning]", 
                #rooms, amount, reason))
            Log.log(string.format("[info]Attempts: %d, Failures: %d[/info]", 
                attempts, consecutiveFailures))
        else
            Log.log(string.format("[success]Generated %d rooms /%d[/success]", 
                #rooms, attempts))
        end
    end
    
    return rooms
end

-- Check if two rooms overlap (including a 1-tile buffer)
function MapGenerator.roomsOverlap(room1, room2)
    -- Add 1-tile buffer around each room to prevent touching
    local buffer = 1
    
    return not (room1.x2 + buffer < room2.x1 or 
                room2.x2 + buffer < room1.x1 or 
                room1.y2 + buffer < room2.y1 or 
                room2.y2 + buffer < room1.y1)
end

-- Create a single room in the game grid
function MapGenerator.createRoom(gameGrid, room)
    -- Fill the room with floor tiles
    for y = room.y1, room.y2 do
        for x = room.x1, room.x2 do
            if gameGrid[y] and gameGrid[y][x] then
                gameGrid[y][x] = {char = ".", color = {0.6, 0.6, 0.6}, walkable = true}
            end
        end
    end
    
    -- Add walls around the room (only if the space was originally a wall)
    MapGenerator.addRoomWalls(gameGrid, room)
end

-- Add walls around a room
function MapGenerator.addRoomWalls(gameGrid, room)
    -- Top and bottom walls
    for x = room.x1 - 1, room.x2 + 1 do
        -- Top wall
        if room.y1 - 1 >= 1 and gameGrid[room.y1 - 1] and gameGrid[room.y1 - 1][x] then
            if gameGrid[room.y1 - 1][x].char == "#" then -- Only replace existing walls
                gameGrid[room.y1 - 1][x] = {char = "#", color = {0.8, 0.8, 0.8}, walkable = false}
            end
        end
        
        -- Bottom wall
        if room.y2 + 1 <= #gameGrid and gameGrid[room.y2 + 1] and gameGrid[room.y2 + 1][x] then
            if gameGrid[room.y2 + 1][x].char == "#" then -- Only replace existing walls
                gameGrid[room.y2 + 1][x] = {char = "#", color = {0.8, 0.8, 0.8}, walkable = false}
            end
        end
    end
    
    -- Left and right walls
    for y = room.y1 - 1, room.y2 + 1 do
        -- Left wall
        if room.x1 - 1 >= 1 and gameGrid[y] and gameGrid[y][room.x1 - 1] then
            if gameGrid[y][room.x1 - 1].char == "#" then -- Only replace existing walls
                gameGrid[y][room.x1 - 1] = {char = "#", color = {0.8, 0.8, 0.8}, walkable = false}
            end
        end
        
        -- Right wall
        if room.x2 + 1 <= #gameGrid[1] and gameGrid[y] and gameGrid[y][room.x2 + 1] then
            if gameGrid[y][room.x2 + 1].char == "#" then -- Only replace existing walls
                gameGrid[y][room.x2 + 1] = {char = "#", color = {0.8, 0.8, 0.8}, walkable = false}
            end
        end
    end
end

-- Get room information for debugging or other uses
function MapGenerator.getRoomInfo(room)
    return string.format("Room: (%d,%d) to (%d,%d) [%dx%d] Center: (%d,%d)", 
        room.x1, room.y1, room.x2, room.y2, room.width, room.height, room.centerX, room.centerY)
end

-- Find a suitable starting room for the player
function MapGenerator.findStartingRoom(rooms)
    if #rooms == 0 then return nil end
    
    -- For now, just return the first room
    -- In the future, this could be more sophisticated (e.g., largest room, specific position, etc.)
    return rooms[1]
end

-- Get the center position of a room (useful for placing player or connecting corridors)
function MapGenerator.getRoomCenter(room)
    return room.centerX, room.centerY
end

-- Check if a position is inside a room
function MapGenerator.isPositionInRoom(x, y, room)
    return x >= room.x1 and x <= room.x2 and y >= room.y1 and y <= room.y2
end

-- Find the closest room to a given position
function MapGenerator.findClosestRoom(x, y, rooms)
    local closestRoom = nil
    local minDistance = math.huge
    
    for _, room in ipairs(rooms) do
        local dx = room.centerX - x
        local dy = room.centerY - y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < minDistance then
            minDistance = distance
            closestRoom = room
        end
    end
    
    return closestRoom, minDistance
end

-- Connect all rooms with corridors using nearest neighbor approach
function MapGenerator.connectRooms(gameGrid, rooms, gridWidth, gridHeight)
    if #rooms < 2 then return end
    
    local connected = {}
    local connections = {}
    
    -- Mark first room as connected
    connected[1] = true
    local connectedCount = 1
    
    -- Connect each unconnected room to the nearest connected room
    while connectedCount < #rooms do
        local bestConnection = nil
        local shortestDistance = math.huge
        local bestRoomIndex = nil
        
        -- Find the shortest connection between connected and unconnected rooms
        for i = 1, #rooms do
            if not connected[i] then
                for j = 1, #rooms do
                    if connected[j] then
                        local distance = MapGenerator.getRoomDistance(rooms[i], rooms[j])
                        if distance < shortestDistance then
                            shortestDistance = distance
                            bestConnection = {from = j, to = i}
                            bestRoomIndex = i
                        end
                    end
                end
            end
        end
        
        -- Create the corridor for the best connection
        if bestConnection then
            MapGenerator.createCorridor(gameGrid, rooms[bestConnection.from], rooms[bestConnection.to], gridWidth, gridHeight)
            connected[bestRoomIndex] = true
            connectedCount = connectedCount + 1
            table.insert(connections, bestConnection)
        end
    end
end

-- Calculate distance between two rooms
function MapGenerator.getRoomDistance(room1, room2)
    local dx = room1.centerX - room2.centerX
    local dy = room1.centerY - room2.centerY
    return math.sqrt(dx * dx + dy * dy)
end

-- Create a corridor between two rooms
function MapGenerator.createCorridor(gameGrid, room1, room2, gridWidth, gridHeight)
    local startX, startY = room1.centerX, room1.centerY
    local endX, endY = room2.centerX, room2.centerY
    
    -- Create L-shaped corridor (horizontal first, then vertical)
    -- Horizontal segment
    local minX = math.min(startX, endX)
    local maxX = math.max(startX, endX)
    for x = minX, maxX do
        if x >= 1 and x <= gridWidth and startY >= 1 and startY <= gridHeight then
            if gameGrid[startY] and gameGrid[startY][x] then
                if not gameGrid[startY][x].walkable then
                    gameGrid[startY][x] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
                end
            end
        end
    end
    
    -- Vertical segment
    local minY = math.min(startY, endY)
    local maxY = math.max(startY, endY)
    for y = minY, maxY do
        if endX >= 1 and endX <= gridWidth and y >= 1 and y <= gridHeight then
            if gameGrid[y] and gameGrid[y][endX] then
                if not gameGrid[y][endX].walkable then
                    gameGrid[y][endX] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
                end
            end
        end
    end
end

-- Generate a complete map with rooms (entry point)
function MapGenerator.generateMap(gameGrid, gridWidth, gridHeight, options)
    options = options or {}
    local roomCount = options.roomCount or 5
    local minRoomSize = options.minRoomSize or 5
    local maxRoomSize = options.maxRoomSize or 8
    
    -- Generate rooms
    local rooms = MapGenerator.generateRooms(gameGrid, gridWidth, gridHeight, roomCount, minRoomSize, maxRoomSize)
    
    -- Connect rooms with corridors
    if #rooms > 1 then
        MapGenerator.connectRooms(gameGrid, rooms, gridWidth, gridHeight)
    end
    
    -- Log generation results
    if Log then
        Log.log(string.format("[info]Map: %d rooms[/info]", #rooms))
    end
    
    return rooms
end

-- Generate the default map layout for the game (main entry point)
function MapGenerator.generate(gameGrid, gridWidth, gridHeight)
    -- Generate a random number of rooms between 10-20
    local roomCount = love.math.random(10, 20)
    
    -- Use the map generator to create procedural rooms
    local rooms = MapGenerator.generateMap(gameGrid, gridWidth, gridHeight, {
        roomCount = roomCount,
        minRoomSize = 4,  -- Reduced min size to fit more rooms
        maxRoomSize = 7   -- Reduced max size to fit more rooms
    })
    
    -- Store rooms for later use (e.g., pathfinding, player placement)
    MapGenerator.generatedRooms = rooms
    
    return rooms
end

return MapGenerator
