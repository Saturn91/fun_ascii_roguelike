local BinarySpacePartitioning = {}

function BinarySpacePartitioning.generate(width, height)
    width = width or 80
    height = height or 50

    local walkable = BinarySpacePartitioning.initializeWalkableMap(width, height)
    local rooms = {}
    BinarySpacePartitioning.partitionSpace(1, 1, width, height, rooms, walkable, 5)

    BinarySpacePartitioning.connectClosestRooms(rooms, walkable)
    local tileMap = BinarySpacePartitioning.createTileMapFromWalkable(walkable, width, height)
    BinarySpacePartitioning.addWalls(tileMap, walkable, width, height)

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

function BinarySpacePartitioning.initializeWalkableMap(width, height)
    local walkable = {}
    for y = 1, height do
        walkable[y] = {}
        for x = 1, width do
            walkable[y][x] = false
        end
    end
    return walkable
end

function BinarySpacePartitioning.partitionSpace(x, y, width, height, rooms, walkable, depth)
    if depth <= 0 or width < 12 or height < 12 then
        local minRoomSize = 6
        local maxRoomSize = math.min(width - 4, height - 4, 14)
        local roomWidth = love.math.random(minRoomSize, maxRoomSize)
        local roomHeight = love.math.random(minRoomSize, maxRoomSize)
        local roomX = love.math.random(x + 2, x + width - roomWidth - 2)
        local roomY = love.math.random(y + 2, y + height - roomHeight - 2)
        local room = {
            centerX = roomX + math.floor(roomWidth / 2),
            centerY = roomY + math.floor(roomHeight / 2),
            height = roomHeight,
            width = roomWidth,
            x = roomX,
            y = roomY
        }
        BinarySpacePartitioning.carveRoom(room, walkable)
        table.insert(rooms, room)
        return
    end
    local splitVertical = width > height
    if splitVertical then
        local split = love.math.random(math.floor(width * 0.3), math.floor(width * 0.7))
        BinarySpacePartitioning.partitionSpace(x, y, split, height, rooms, walkable, depth - 1)
        BinarySpacePartitioning.partitionSpace(x + split, y, width - split, height, rooms, walkable, depth - 1)
    else
        local split = love.math.random(math.floor(height * 0.3), math.floor(height * 0.7))
        BinarySpacePartitioning.partitionSpace(x, y, width, split, rooms, walkable, depth - 1)
        BinarySpacePartitioning.partitionSpace(x, y + split, width, height - split, rooms, walkable, depth - 1)
    end
end

function BinarySpacePartitioning.carveRoom(room, walkable)
    for y = room.y, room.y + room.height - 1 do
        if y == 1 or y == #walkable then goto continueY end
        for x = room.x, room.x + room.width - 1 do
            if x == 1 or x == #walkable[1] then goto continueX end
            if walkable[y] ~= nil and walkable[y][x] ~= nil then
                walkable[y][x] = true
            end
            ::continueX::
        end
        ::continueY::
    end
end

function BinarySpacePartitioning.connectClosestRooms(rooms, walkable)
    if #rooms < 2 then return end
    local connected = {1}
    local unconnected = {}
    for i = 2, #rooms do
        table.insert(unconnected, i)
    end
    while #unconnected > 0 do
        local closestPair = BinarySpacePartitioning.findClosestRoomPair(rooms, connected, unconnected)
        local roomA = rooms[closestPair.connectedIndex]
        local roomB = rooms[closestPair.unconnectedIndex]
        BinarySpacePartitioning.createCorridor(roomA, roomB, walkable)
        table.insert(connected, closestPair.unconnectedIndex)
        for i = #unconnected, 1, -1 do
            if unconnected[i] == closestPair.unconnectedIndex then
                table.remove(unconnected, i)
                break
            end
        end
    end
end

function BinarySpacePartitioning.findClosestRoomPair(rooms, connected, unconnected)
    local minDistance = math.huge
    local closestPair = {}
    for _, connectedIndex in ipairs(connected) do
        for _, unconnectedIndex in ipairs(unconnected) do
            local distance = BinarySpacePartitioning.calculateRoomDistance(rooms[connectedIndex], rooms[unconnectedIndex])
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

function BinarySpacePartitioning.calculateRoomDistance(room1, room2)
    local dx = room1.centerX - room2.centerX
    local dy = room1.centerY - room2.centerY
    return math.sqrt(dx * dx + dy * dy)
end

function BinarySpacePartitioning.createCorridor(roomA, roomB, walkable)
    local x1, y1 = roomA.centerX, roomA.centerY
    local x2, y2 = roomB.centerX, roomB.centerY
    if love.math.random() < 0.5 then
        BinarySpacePartitioning.carveHorizontalCorridor(x1, x2, y1, walkable)
        BinarySpacePartitioning.carveVerticalCorridor(y1, y2, x2, walkable)
    else
        BinarySpacePartitioning.carveVerticalCorridor(y1, y2, x1, walkable)
        BinarySpacePartitioning.carveHorizontalCorridor(x1, x2, y2, walkable)
    end
end

function BinarySpacePartitioning.carveHorizontalCorridor(x1, x2, y, walkable)
    for x = math.min(x1, x2), math.max(x1, x2) do
        walkable[y][x] = true
    end
end

function BinarySpacePartitioning.carveVerticalCorridor(y1, y2, x, walkable)
    for y = math.min(y1, y2), math.max(y1, y2) do
        walkable[y][x] = true
    end
end

function BinarySpacePartitioning.createTileMapFromWalkable(walkable, width, height)
    local tileMap = {}
    for y = 1, height do
        tileMap[y] = {}
        for x = 1, width do
            if walkable[y][x] then
                tileMap[y][x] = 1
            else
                tileMap[y][x] = 3
            end
        end
    end
    return tileMap
end

function BinarySpacePartitioning.addWalls(tileMap, walkable, width, height)
    for y = 1, height do
        for x = 1, width do
            if walkable[y][x] then
                BinarySpacePartitioning.addWallsAroundTile(x, y, tileMap, width, height)
            end
        end
    end
end

function BinarySpacePartitioning.addWallsAroundTile(x, y, tileMap, width, height)
    local directions = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}
    for _, dir in ipairs(directions) do
        local newX, newY = x + dir[1], y + dir[2]
        if newX >= 1 and newX <= width and newY >= 1 and newY <= height then
            if tileMap[newY][newX] == 3 then
                tileMap[newY][newX] = 2
            end
        end
    end
end

return BinarySpacePartitioning
