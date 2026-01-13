local CaveSystem = {}

function CaveSystem.generate(width, height)
    width = width or 80
    height = height or 50
    
    local walkable = CaveSystem.initializeWalkableMap(width, height)
    local caves = CaveSystem.generateCaveSystem(width, height, walkable)
    
    -- First, force extensions between separate cave groups
    local extensionMap = CaveSystem.forceExtensions(caves, walkable, width, height)
    
    -- Then connect any remaining unconnected caves
    if #caves > 1 then
        CaveSystem.connectCaves(caves, walkable, width, height)
    end
    
    CaveSystem.smoothCaves(walkable, width, height)
    local tileMap = CaveSystem.createTileMapFromWalkable(walkable, width, height)
    CaveSystem.applyExtensionColors(tileMap, extensionMap, width, height)
    CaveSystem.addWalls(tileMap, walkable, width, height)
    
    return MapDefinition:new({
        height = height,
        width = width,
        walkable = walkable
    }, {
        tileDefinitions = {[1] = { glyph = ".", color = {0.4, 0.3, 0.2, 1} }, [2] = { glyph = "█", color = {0.3, 0.2, 0.1, 1} }, [3] = { glyph = " ", color = {0, 0, 0, 1} }, [4] = { glyph = ".", color = {0.2, 0.5, 1.0, 1} }},
        tileIds = {[1] = "floor", [2] = "wall", [3] = "empty", [4] = "extension"},
        tileMap = tileMap,
        rooms = caves
    })
end

function CaveSystem.initializeWalkableMap(width, height)
    local walkable = {}
    for y = 1, height do
        walkable[y] = {}
        for x = 1, width do
            walkable[y][x] = false
        end
    end
    return walkable
end

function CaveSystem.createTileMapFromWalkable(walkable, width, height)
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

function CaveSystem.generateCaveSystem(width, height, walkable)
    local caves = {}
    local maxCaves = love.math.random(4, 8)
    local minCaveSize = 6
    local maxCaveSize = math.max(minCaveSize + 2, math.floor(math.min(width, height) / 3))
    
    for attempt = 1, maxCaves * 5 do
        local caveRadius = love.math.random(minCaveSize, maxCaveSize) / 2
        local buffer = math.max(2, math.floor(math.min(width, height) / 15))
        local minX = math.ceil(caveRadius) + buffer
        local maxX = width - math.ceil(caveRadius) - buffer
        local minY = math.ceil(caveRadius) + buffer
        local maxY = height - math.ceil(caveRadius) - buffer
        
        if minX <= maxX and minY <= maxY then
            local centerX = love.math.random(minX, maxX)
            local centerY = love.math.random(minY, maxY)
            
            local cave = {
                centerX = centerX,
                centerY = centerY,
                radius = caveRadius,
                width = math.ceil(caveRadius * 2),
                height = math.ceil(caveRadius * 2),
                x = centerX - math.ceil(caveRadius),
                y = centerY - math.ceil(caveRadius)
            }
            
            if CaveSystem.canPlaceCave(cave, caves, width, height) then
                CaveSystem.carveCave(cave, walkable)
                table.insert(caves, cave)
                
                if #caves >= maxCaves then
                    break
                end
            end
        end
    end
    
    -- Add fewer sub-caves to maintain separation while adding detail
    if love.math.random() < 0.6 then -- 60% chance to add sub-caves
        CaveSystem.addSubCaves(caves, walkable, width, height)
    end
    
    return caves
end

function CaveSystem.canPlaceCave(newCave, existingCaves, mapWidth, mapHeight)
    local buffer = math.max(2, math.floor(math.min(mapWidth, mapHeight) / 15))
    
    if newCave.centerX - newCave.radius < buffer or 
       newCave.centerX + newCave.radius > mapWidth - buffer or
       newCave.centerY - newCave.radius < buffer or 
       newCave.centerY + newCave.radius > mapHeight - buffer then
        return false
    end
    
    for _, cave in ipairs(existingCaves) do
        local distance = math.sqrt((newCave.centerX - cave.centerX)^2 + (newCave.centerY - cave.centerY)^2)
        local minDistance = newCave.radius + cave.radius + love.math.random(8, 15) -- Increased separation
        
        if distance < minDistance then
            return false
        end
    end
    
    return true
end

function CaveSystem.carveCave(cave, walkable)
    local centerX, centerY = cave.centerX, cave.centerY
    local baseRadius = cave.radius
    local height = #walkable
    local width = #walkable[1]
    
    for y = math.max(1, centerY - math.ceil(baseRadius) - 2), math.min(height, centerY + math.ceil(baseRadius) + 2) do
        if walkable[y] then
            for x = math.max(1, centerX - math.ceil(baseRadius) - 2), math.min(width, centerX + math.ceil(baseRadius) + 2) do
                local distance = math.sqrt((x - centerX)^2 + (y - centerY)^2)
                local noiseVariation = (love.math.random() - 0.5) * 3
                local effectiveRadius = baseRadius + noiseVariation
                
                local edgeFactor = math.max(0, 1 - (distance / effectiveRadius))
                local caveChance = edgeFactor * edgeFactor
                
                if distance <= effectiveRadius * 0.7 then
                    walkable[y][x] = true
                elseif love.math.random() < caveChance * 0.8 then
                    walkable[y][x] = true
                end
            end
        end
    end
end

function CaveSystem.addSubCaves(mainCaves, walkable, width, height)
    if #mainCaves == 0 then return end
    
    local maxSubCaves = math.max(3, #mainCaves) -- Reduced from previous calculation
    local subCaveCount = love.math.random(1, maxSubCaves)
    
    for i = 1, subCaveCount do
        local parentCave = mainCaves[love.math.random(1, #mainCaves)]
        local angle = love.math.random() * 2 * math.pi
        local distance = love.math.random(parentCave.radius + 6, parentCave.radius + 12) -- Reduced distance
        
        local subCaveX = parentCave.centerX + math.cos(angle) * distance
        local subCaveY = parentCave.centerY + math.sin(angle) * distance
        local subCaveRadius = love.math.random(2, 6) -- Smaller sub-caves
        
        local subCave = {
            centerX = subCaveX,
            centerY = subCaveY,
            radius = subCaveRadius,
            width = math.ceil(subCaveRadius * 2),
            height = math.ceil(subCaveRadius * 2),
            x = subCaveX - math.ceil(subCaveRadius),
            y = subCaveY - math.ceil(subCaveRadius)
        }
        
        if subCaveX - subCaveRadius >= 3 and subCaveX + subCaveRadius <= width - 3 and
           subCaveY - subCaveRadius >= 3 and subCaveY + subCaveRadius <= height - 3 then
            CaveSystem.carveCave(subCave, walkable)
            table.insert(mainCaves, subCave)
        end
    end
end

function CaveSystem.connectCaves(caves, walkable, width, height)
    local connected = {1}
    local unconnected = {}
    
    for i = 2, #caves do
        table.insert(unconnected, i)
    end
    
    while #unconnected > 0 do
        local closestPair = CaveSystem.findClosestCavePair(caves, connected, unconnected)
        local caveA = caves[closestPair.connectedIndex]
        local caveB = caves[closestPair.unconnectedIndex]
        
        CaveSystem.createNaturalTunnel(caveA, caveB, walkable, width, height)
        
        table.insert(connected, closestPair.unconnectedIndex)
        for i = #unconnected, 1, -1 do
            if unconnected[i] == closestPair.unconnectedIndex then
                table.remove(unconnected, i)
                break
            end
        end
    end
    
    CaveSystem.addExtraTunnels(caves, walkable, width, height)
end

function CaveSystem.findClosestCavePair(caves, connected, unconnected)
    local minDistance = math.huge
    local closestPair = {}
    
    for _, connectedIndex in ipairs(connected) do
        for _, unconnectedIndex in ipairs(unconnected) do
            local distance = CaveSystem.calculateCaveDistance(caves[connectedIndex], caves[unconnectedIndex])
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

function CaveSystem.calculateCaveDistance(cave1, cave2)
    local dx = cave1.centerX - cave2.centerX
    local dy = cave1.centerY - cave2.centerY
    return math.sqrt(dx * dx + dy * dy)
end

function CaveSystem.createNaturalTunnel(caveA, caveB, walkable, width, height)
    local startX, startY = caveA.centerX, caveA.centerY
    local endX, endY = caveB.centerX, caveB.centerY
    
    local currentX, currentY = startX, startY
    local tunnelWidth = love.math.random(2, 4)
    
    local stepCount = 0
    local maxSteps = math.abs(endX - startX) + math.abs(endY - startY) + 20
    
    while (math.abs(currentX - endX) > 1 or math.abs(currentY - endY) > 1) and stepCount < maxSteps do
        stepCount = stepCount + 1
        
        CaveSystem.carveTunnelSection(currentX, currentY, tunnelWidth, walkable, width, height)
        
        local dx = endX - currentX
        local dy = endY - currentY
        
        if love.math.random() < 0.7 then
            if math.abs(dx) > math.abs(dy) then
                currentX = currentX + (dx > 0 and 1 or -1)
            else
                currentY = currentY + (dy > 0 and 1 or -1)
            end
        else
            if love.math.random() < 0.5 then
                currentX = currentX + (dx > 0 and 1 or (dx < 0 and -1 or 0))
            else
                currentY = currentY + (dy > 0 and 1 or (dy < 0 and -1 or 0))
            end
        end
        
        if love.math.random() < 0.1 then
            tunnelWidth = math.max(1, math.min(5, tunnelWidth + love.math.random(-1, 1)))
        end
        
        currentX = math.max(2, math.min(width - 1, currentX))
        currentY = math.max(2, math.min(height - 1, currentY))
    end
    
    CaveSystem.carveTunnelSection(endX, endY, tunnelWidth, walkable, width, height)
end

function CaveSystem.carveTunnelSection(centerX, centerY, tunnelWidth, walkable, width, height)
    local radius = math.ceil(tunnelWidth / 2)
    
    for y = math.max(1, centerY - radius), math.min(height, centerY + radius) do
        if walkable[y] then
            for x = math.max(1, centerX - radius), math.min(width, centerX + radius) do
                local distance = math.sqrt((x - centerX)^2 + (y - centerY)^2)
                local carveChance = math.max(0, 1 - distance / (radius + 0.5))
                
                if distance <= radius * 0.8 or love.math.random() < carveChance * 0.9 then
                    walkable[y][x] = true
                end
            end
        end
    end
end

function CaveSystem.addExtraTunnels(caves, walkable, width, height)
    local extraTunnels = math.min(2, math.floor(#caves / 4))
    
    for i = 1, extraTunnels do
        local caveA = caves[love.math.random(1, #caves)]
        local caveB = caves[love.math.random(1, #caves)]
        
        if caveA ~= caveB and love.math.random() < 0.4 then
            CaveSystem.createNaturalTunnel(caveA, caveB, walkable, width, height)
        end
    end
end

function CaveSystem.smoothCaves(walkable, width, height)
    for iteration = 1, 2 do
        local newWalkable = {}
        for y = 1, height do
            newWalkable[y] = {}
            for x = 1, width do
                newWalkable[y][x] = walkable[y][x]
            end
        end
        
        for y = 2, height - 1 do
            for x = 2, width - 1 do
                local neighbors = CaveSystem.countWalkableNeighbors(x, y, walkable)
                
                if walkable[y][x] then
                    if neighbors >= 4 then
                        newWalkable[y][x] = true
                    else
                        newWalkable[y][x] = false
                    end
                else
                    if neighbors >= 5 then
                        newWalkable[y][x] = true
                    else
                        newWalkable[y][x] = false
                    end
                end
            end
        end
        
        walkable = newWalkable
    end
    
    for y = 1, height do
        for x = 1, width do
            if y ~= 1 and y ~= height and x ~= 1 and x ~= width then
                if walkable[y] and walkable[y][x] ~= nil then
                    -- Skip, this is fine
                else
                    walkable[y] = walkable[y] or {}
                    walkable[y][x] = false
                end
            end
        end
    end
end

function CaveSystem.countWalkableNeighbors(x, y, walkable)
    local count = 0
    local directions = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}
    
    for _, dir in ipairs(directions) do
        local newX, newY = x + dir[1], y + dir[2]
        if walkable[newY] and walkable[newY][newX] then
            count = count + 1
        end
    end
    
    return count
end

function CaveSystem.addWalls(tileMap, walkable, width, height)
    for y = 1, height do
        for x = 1, width do
            if walkable[y][x] then
                CaveSystem.addWallsAroundTile(x, y, tileMap, width, height)
            end
        end
    end
end

function CaveSystem.addWallsAroundTile(x, y, tileMap, width, height)
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

function CaveSystem.forceExtensions(caves, walkable, width, height)
    local extensionMap = CaveSystem.initializeExtensionMap(width, height)
    
    if #caves <= 1 then
        return extensionMap
    end
    
    -- Find separate cave groups
    local caveGroups = CaveSystem.findSeparateCaveGroups(caves, walkable)
    
    -- If we have multiple groups, force connections between ALL of them
    if #caveGroups > 1 then
        -- Connect each group to its nearest neighbor(s)
        for groupIndex, group in ipairs(caveGroups) do
            local nearestGroup, distance = CaveSystem.findNearestCaveGroup(group, caveGroups, groupIndex)
            
            if nearestGroup then
                CaveSystem.createExtensions(group, nearestGroup, walkable, extensionMap, width, height)
            end
            
            -- Also try to connect to a second group if we have many groups
            if #caveGroups > 2 then
                local secondNearestGroup = CaveSystem.findSecondNearestCaveGroup(group, caveGroups, groupIndex)
                if secondNearestGroup and love.math.random() < 0.6 then
                    CaveSystem.createExtensions(group, secondNearestGroup, walkable, extensionMap, width, height)
                end
            end
        end
        
        -- Ensure full connectivity by creating a spanning tree
        CaveSystem.ensureFullConnectivity(caveGroups, walkable, extensionMap, width, height)
    end
    
    return extensionMap
end

function CaveSystem.initializeExtensionMap(width, height)
    local extensionMap = {}
    for y = 1, height do
        extensionMap[y] = {}
        for x = 1, width do
            extensionMap[y][x] = false
        end
    end
    return extensionMap
end

function CaveSystem.findSeparateCaveGroups(caves, walkable)
    local visited = {}
    local groups = {}
    
    for i, cave in ipairs(caves) do
        visited[i] = false
    end
    
    for i, cave in ipairs(caves) do
        if not visited[i] then
            local group = {}
            CaveSystem.floodFillCaveGroup(i, caves, walkable, visited, group)
            if #group > 0 then
                table.insert(groups, group)
            end
        end
    end
    
    return groups
end

function CaveSystem.floodFillCaveGroup(caveIndex, caves, walkable, visited, group)
    if visited[caveIndex] then
        return
    end
    
    visited[caveIndex] = true
    table.insert(group, caves[caveIndex])
    
    local currentCave = caves[caveIndex]
    
    -- Check if other caves are connected via walkable path
    for i, otherCave in ipairs(caves) do
        if not visited[i] and CaveSystem.areCavesConnected(currentCave, otherCave, walkable) then
            CaveSystem.floodFillCaveGroup(i, caves, walkable, visited, group)
        end
    end
end

function CaveSystem.areCavesConnected(cave1, cave2, walkable)
    -- Even more strict connection detection - requires a very clear walkable path
    local startX, startY = cave1.centerX, cave1.centerY
    local endX, endY = cave2.centerX, cave2.centerY
    
    local dx = math.abs(endX - startX)
    local dy = math.abs(endY - startY)
    local steps = math.max(dx, dy)
    
    if steps == 0 then return true end
    
    local stepX = (endX - startX) / steps
    local stepY = (endY - startY) / steps
    
    local connectedSteps = 0
    local consecutiveConnected = 0
    local maxConsecutive = 0
    
    for i = 0, steps do
        local x = math.floor(startX + stepX * i + 0.5)
        local y = math.floor(startY + stepY * i + 0.5)
        
        if walkable[y] and walkable[y][x] then
            connectedSteps = connectedSteps + 1
            consecutiveConnected = consecutiveConnected + 1
            maxConsecutive = math.max(maxConsecutive, consecutiveConnected)
        else
            consecutiveConnected = 0
        end
    end
    
    -- Require at least 80% of the path to be walkable AND at least 50% consecutive connection
    local percentConnected = connectedSteps / steps
    local percentConsecutive = maxConsecutive / steps
    
    return percentConnected > 0.8 and percentConsecutive > 0.5
end

function CaveSystem.findNearestCaveGroup(currentGroup, allGroups, currentGroupIndex)
    local minDistance = math.huge
    local nearestGroup = nil
    
    for groupIndex, group in ipairs(allGroups) do
        if groupIndex ~= currentGroupIndex then
            local distance = CaveSystem.calculateGroupDistance(currentGroup, group)
            if distance < minDistance then
                minDistance = distance
                nearestGroup = group
            end
        end
    end
    
    return nearestGroup, minDistance
end

function CaveSystem.findSecondNearestCaveGroup(currentGroup, allGroups, currentGroupIndex)
    local firstNearest, firstDistance = CaveSystem.findNearestCaveGroup(currentGroup, allGroups, currentGroupIndex)
    local secondMinDistance = math.huge
    local secondNearestGroup = nil
    
    for groupIndex, group in ipairs(allGroups) do
        if groupIndex ~= currentGroupIndex and group ~= firstNearest then
            local distance = CaveSystem.calculateGroupDistance(currentGroup, group)
            if distance < secondMinDistance then
                secondMinDistance = distance
                secondNearestGroup = group
            end
        end
    end
    
    return secondNearestGroup
end

function CaveSystem.ensureFullConnectivity(caveGroups, walkable, extensionMap, width, height)
    -- Use a simple approach: connect groups in a chain to ensure all are reachable
    for i = 1, #caveGroups - 1 do
        local currentGroup = caveGroups[i]
        local nextGroup = caveGroups[i + 1]
        
        -- Check if these groups are actually connected via walkable path
        if not CaveSystem.areGroupsConnected(currentGroup, nextGroup, walkable) then
            CaveSystem.createExtensions(currentGroup, nextGroup, walkable, extensionMap, width, height)
        end
    end
end

function CaveSystem.areGroupsConnected(group1, group2, walkable)
    -- Check if any cave in group1 is connected to any cave in group2
    for _, cave1 in ipairs(group1) do
        for _, cave2 in ipairs(group2) do
            if CaveSystem.areCavesConnected(cave1, cave2, walkable) then
                return true
            end
        end
    end
    return false
end

function CaveSystem.calculateGroupDistance(group1, group2)
    local minDistance = math.huge
    
    for _, cave1 in ipairs(group1) do
        for _, cave2 in ipairs(group2) do
            local distance = math.sqrt((cave1.centerX - cave2.centerX)^2 + (cave1.centerY - cave2.centerY)^2)
            if distance < minDistance then
                minDistance = distance
            end
        end
    end
    
    return minDistance
end

function CaveSystem.createExtensions(fromGroup, toGroup, walkable, extensionMap, width, height)
    -- Find the closest caves between groups
    local closestFromCave, closestToCave = CaveSystem.findClosestCavesInGroups(fromGroup, toGroup)
    
    if not closestFromCave or not closestToCave then
        return
    end
    
    -- Create multiple extension tendrils from the fromGroup toward the toGroup
    local extensionCount = love.math.random(2, 5) -- Increased from 2-4
    
    for i = 1, extensionCount do
        -- Pick a random cave from the fromGroup
        local fromCave = fromGroup[love.math.random(1, #fromGroup)]
        
        -- Find the edge of this cave closest to the target group
        local edgePoint = CaveSystem.findCaveEdgeTowardTarget(fromCave, closestToCave)
        
        -- Create a natural extension from this edge point
        CaveSystem.createNaturalExtension(edgePoint, closestToCave, walkable, extensionMap, width, height)
    end
    
    -- Always create one guaranteed strong connection between the closest caves
    local fromEdge = CaveSystem.findCaveEdgeTowardTarget(closestFromCave, closestToCave)
    local toEdge = CaveSystem.findCaveEdgeTowardTarget(closestToCave, closestFromCave)
    CaveSystem.createDirectExtension(fromEdge, toEdge, walkable, extensionMap, width, height)
end

function CaveSystem.findClosestCavesInGroups(group1, group2)
    local minDistance = math.huge
    local closestCave1, closestCave2 = nil, nil
    
    for _, cave1 in ipairs(group1) do
        for _, cave2 in ipairs(group2) do
            local distance = math.sqrt((cave1.centerX - cave2.centerX)^2 + (cave1.centerY - cave2.centerY)^2)
            if distance < minDistance then
                minDistance = distance
                closestCave1 = cave1
                closestCave2 = cave2
            end
        end
    end
    
    return closestCave1, closestCave2
end

function CaveSystem.findCaveEdgeTowardTarget(fromCave, toCave)
    local dx = toCave.centerX - fromCave.centerX
    local dy = toCave.centerY - fromCave.centerY
    local distance = math.sqrt(dx^2 + dy^2)
    
    if distance == 0 then
        return {x = fromCave.centerX, y = fromCave.centerY}
    end
    
    -- Normalize direction
    dx = dx / distance
    dy = dy / distance
    
    -- Find edge point of the cave
    local edgeX = fromCave.centerX + dx * fromCave.radius * 0.8
    local edgeY = fromCave.centerY + dy * fromCave.radius * 0.8
    
    return {x = math.floor(edgeX + 0.5), y = math.floor(edgeY + 0.5)}
end

function CaveSystem.createNaturalExtension(startPoint, targetCave, walkable, extensionMap, width, height)
    local currentX, currentY = startPoint.x, startPoint.y
    local targetX, targetY = targetCave.centerX, targetCave.centerY
    
    local maxSteps = 100 -- Increased from 50
    local stepCount = 0
    local extensionWidth = love.math.random(1, 3)
    
    while stepCount < maxSteps do
        stepCount = stepCount + 1
        
        -- Calculate direction toward target
        local dx = targetX - currentX
        local dy = targetY - currentY
        local distance = math.sqrt(dx^2 + dy^2)
        
        if distance < targetCave.radius + 5 then -- Extended reach
            break -- Reached the target cave area
        end
        
        -- Add some randomness to make it more natural, but less than before
        local randomAngle = (love.math.random() - 0.5) * math.pi / 4 -- ±45 degrees (reduced from 60)
        local angle = math.atan2(dy, dx) + randomAngle
        
        -- Move toward target with some natural variation
        local stepSize = love.math.random() * 1.5 + 0.5 -- Variable step size
        local stepX = math.cos(angle) * stepSize
        local stepY = math.sin(angle) * stepSize
        
        currentX = currentX + stepX
        currentY = currentY + stepY
        
        -- Clamp to map bounds
        currentX = math.max(2, math.min(width - 1, currentX))
        currentY = math.max(2, math.min(height - 1, currentY))
        
        -- Carve the extension
        CaveSystem.carveExtensionArea(math.floor(currentX + 0.5), math.floor(currentY + 0.5), extensionWidth, walkable, extensionMap, width, height)
        
        -- Occasionally change direction or width
        if love.math.random() < 0.1 then
            extensionWidth = math.max(1, math.min(4, extensionWidth + love.math.random(-1, 1)))
        end
    end
end

function CaveSystem.createDirectExtension(startPoint, endPoint, walkable, extensionMap, width, height)
    -- Create a more direct connection between two points
    local currentX, currentY = startPoint.x, startPoint.y
    local targetX, targetY = endPoint.x, endPoint.y
    
    local dx = targetX - currentX
    local dy = targetY - currentY
    local distance = math.sqrt(dx^2 + dy^2)
    
    if distance == 0 then return end
    
    local steps = math.ceil(distance)
    local stepX = dx / steps
    local stepY = dy / steps
    
    for i = 0, steps do
        local x = math.floor(currentX + stepX * i + 0.5)
        local y = math.floor(currentY + stepY * i + 0.5)
        
        -- Clamp to map bounds
        x = math.max(1, math.min(width, x))
        y = math.max(1, math.min(height, y))
        
        -- Carve a wider path for the direct connection
        CaveSystem.carveExtensionArea(x, y, 2, walkable, extensionMap, width, height)
    end
end

function CaveSystem.carveExtensionArea(centerX, centerY, extensionWidth, walkable, extensionMap, width, height)
    local radius = math.ceil(extensionWidth / 2)
    
    for y = math.max(1, centerY - radius), math.min(height, centerY + radius) do
        if walkable[y] then
            for x = math.max(1, centerX - radius), math.min(width, centerX + radius) do
                local distance = math.sqrt((x - centerX)^2 + (y - centerY)^2)
                
                if distance <= radius then
                    walkable[y][x] = true
                    extensionMap[y][x] = true
                end
            end
        end
    end
end

function CaveSystem.applyExtensionColors(tileMap, extensionMap, width, height)
    for y = 1, height do
        for x = 1, width do
            if extensionMap[y][x] and tileMap[y][x] == 1 then
                tileMap[y][x] = 4 -- Blue extension tile
            end
        end
    end
end

return CaveSystem
