local RoomsAndCorridors = {}

function RoomsAndCorridors.generate(width, height)
    width = width or 80
    height = height or 50
    
    local walkable = RoomsAndCorridors.initializeWalkableMap(width, height)
    local tileMap = RoomsAndCorridors.initializeTileMap(width, height)
    local rooms = RoomsAndCorridors.generateRooms(width, height, tileMap, walkable)
    
    if #rooms > 1 then
        RoomsAndCorridors.connectRooms(rooms, tileMap, walkable)
    end
    
    return MapDefinition:new({
        height = height,
        width = width,
        walkable = walkable
    }, {
        tileDefinitions = {[1] = { glyph = ".", color = {0.3, 0.3, 0.3, 1} }, [2] = { glyph = "█", color = {0.5, 0.5, 0.5, 1} }, [3] = { glyph = " ", color = {0, 0, 0, 1} }},
        tileIds = {[1] = "floor", [2] = "wall", [3] = "empty"},
        tileMap = tileMap,
        rooms = rooms
    })
end

function RoomsAndCorridors.initializeWalkableMap(width, height)
    local walkable = {}
    for y = 1, height do
        walkable[y] = {}
        for x = 1, width do
            walkable[y][x] = false
        end
    end
    return walkable
end

function RoomsAndCorridors.initializeTileMap(width, height)
    local tileMap = {}
    for y = 1, height do
        tileMap[y] = {}
        for x = 1, width do
            tileMap[y][x] = 3
        end
    end
    return tileMap
end

function RoomsAndCorridors.generateRooms(width, height, tileMap, walkable)
    local rooms = {}
    local maxAttempts = 100
    local minRoomSize = 4
    local maxRoomSize = 12
    
    for attempt = 1, maxAttempts do
        local roomWidth = love.math.random(minRoomSize, maxRoomSize)
        local roomHeight = love.math.random(minRoomSize, maxRoomSize)
        local roomX = love.math.random(1, width - roomWidth)
        local roomY = love.math.random(1, height - roomHeight)
        
        local room = {
            centerX = roomX + math.floor(roomWidth / 2),
            centerY = roomY + math.floor(roomHeight / 2),
            height = roomHeight,
            width = roomWidth,
            x = roomX,
            y = roomY
        }
        
        if RoomsAndCorridors.canPlaceRoom(room, rooms, width, height) then
            RoomsAndCorridors.carveRoom(room, tileMap, walkable)
            table.insert(rooms, room)
        end
    end
    
    return rooms
end

function RoomsAndCorridors.canPlaceRoom(newRoom, existingRooms, mapWidth, mapHeight)
    if newRoom.x < 2 or newRoom.y < 2 or 
       newRoom.x + newRoom.width >= mapWidth or 
       newRoom.y + newRoom.height >= mapHeight then
        return false
    end
    
    for _, room in ipairs(existingRooms) do
        if RoomsAndCorridors.roomsOverlap(newRoom, room) then
            return false
        end
    end
    
    return true
end

function RoomsAndCorridors.roomsOverlap(room1, room2)
    local buffer = 2
    return not (room1.x + room1.width + buffer < room2.x or
                room2.x + room2.width + buffer < room1.x or
                room1.y + room1.height + buffer < room2.y or
                room2.y + room2.height + buffer < room1.y)
end

function RoomsAndCorridors.carveRoom(room, tileMap, walkable)
    for y = room.y + 1, room.y + room.height - 2 do
        for x = room.x + 1, room.x + room.width - 2 do
            tileMap[y][x] = 1
            walkable[y][x] = true
        end
    end
    
    for y = room.y, room.y + room.height - 1 do
        for x = room.x, room.x + room.width - 1 do
            if y == room.y or y == room.y + room.height - 1 or
               x == room.x or x == room.x + room.width - 1 then
                if tileMap[y][x] == 3 then
                    tileMap[y][x] = 2
                end
            end
        end
    end
end

function RoomsAndCorridors.connectRooms(rooms, tileMap, walkable)
    local connected = {1}
    local unconnected = {}
    
    for i = 2, #rooms do
        table.insert(unconnected, i)
    end
    
    while #unconnected > 0 do
        local closestPair = RoomsAndCorridors.findClosestRoomPair(rooms, connected, unconnected)
        local roomA = rooms[closestPair.connectedIndex]
        local roomB = rooms[closestPair.unconnectedIndex]
        
        RoomsAndCorridors.createCorridor(roomA, roomB, tileMap, walkable)
        
        table.insert(connected, closestPair.unconnectedIndex)
        for i = #unconnected, 1, -1 do
            if unconnected[i] == closestPair.unconnectedIndex then
                table.remove(unconnected, i)
                break
            end
        end
    end
    
    RoomsAndCorridors.addExtraConnections(rooms, tileMap, walkable)
end

function RoomsAndCorridors.findClosestRoomPair(rooms, connected, unconnected)
    local minDistance = math.huge
    local closestPair = {}
    
    for _, connectedIndex in ipairs(connected) do
        for _, unconnectedIndex in ipairs(unconnected) do
            local distance = RoomsAndCorridors.calculateRoomDistance(rooms[connectedIndex], rooms[unconnectedIndex])
            if distance < minDistance then
                minDistance = distance
                closestPair = {
                    connectedIndex = connectedIndex,
                    unconnectedIndex = unconnectedIndex
                }
            end
        end
    end
    
    return closestPair
end

function RoomsAndCorridors.calculateRoomDistance(room1, room2)
    local dx = room1.centerX - room2.centerX
    local dy = room1.centerY - room2.centerY
    return math.sqrt(dx * dx + dy * dy)
end

function RoomsAndCorridors.createCorridor(roomA, roomB, tileMap, walkable)
    local startX, startY = roomA.centerX, roomA.centerY
    local endX, endY = roomB.centerX, roomB.centerY
    
    local corridorTiles = {}
    local currentX, currentY = startX, startY
    
    while currentX ~= endX do
        table.insert(corridorTiles, {x = currentX, y = currentY})
        currentX = currentX + (currentX < endX and 1 or -1)
    end
    
    while currentY ~= endY do
        table.insert(corridorTiles, {x = currentX, y = currentY})
        currentY = currentY + (currentY < endY and 1 or -1)
    end
    
    table.insert(corridorTiles, {x = endX, y = endY})
    
    for _, tile in ipairs(corridorTiles) do
        if tileMap[tile.y] and tileMap[tile.y][tile.x] and tileMap[tile.y][tile.x] == 3 then
            tileMap[tile.y][tile.x] = 1
            walkable[tile.y][tile.x] = true
        end
    end
    
    for _, tile in ipairs(corridorTiles) do
        RoomsAndCorridors.addWallsAroundTile(tile.x, tile.y, tileMap)
    end
end

function RoomsAndCorridors.addWallsAroundTile(x, y, tileMap)
    local directions = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}
    
    for _, dir in ipairs(directions) do
        local newX, newY = x + dir[1], y + dir[2]
        if tileMap[newY] and tileMap[newY][newX] and tileMap[newY][newX] == 3 then
            tileMap[newY][newX] = 2
        end
    end
end

function RoomsAndCorridors.addExtraConnections(rooms, tileMap, walkable)
    local extraConnections = math.min(3, math.floor(#rooms / 3))
    
    for i = 1, extraConnections do
        local roomA = rooms[love.math.random(1, #rooms)]
        local roomB = rooms[love.math.random(1, #rooms)]
        
        if roomA ~= roomB and love.math.random() < 0.3 then
            RoomsAndCorridors.createCorridor(roomA, roomB, tileMap, walkable)
        end
    end
end

return RoomsAndCorridors