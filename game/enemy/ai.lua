-- Enemy AI Module for ASCII Roguelike
-- Handles all AI behaviors, pathfinding, and decision making

local EnemyAI = {}

-- Calculate distance between two points
local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Get direction towards target (normalized to -1, 0, or 1)
local function getDirectionTo(fromX, fromY, toX, toY)
    local dx = toX - fromX
    local dy = toY - fromY
    
    -- Normalize to -1, 0, or 1
    if dx > 0 then dx = 1 elseif dx < 0 then dx = -1 else dx = 0 end
    if dy > 0 then dy = 1 elseif dy < 0 then dy = -1 else dy = 0 end
    
    return dx, dy
end

-- Check if enemy can see/detect the player
function EnemyAI.canSeePlayer(enemy, player)
    local dist = distance(enemy.x, enemy.y, player.x, player.y)
    return dist <= enemy.aggroRange
end

-- Check if player is in attack range (adjacent)
function EnemyAI.isPlayerInAttackRange(enemy, player)
    local dist = distance(enemy.x, enemy.y, player.x, player.y)
    return dist <= 1.5 -- Adjacent (including diagonals)
end

-- Basic chase AI - move towards player
function EnemyAI.chasePlayer(enemy, player, gameGrid, gridWidth, gridHeight)
    local dx, dy = getDirectionTo(enemy.x, enemy.y, player.x, player.y)
    local newX = enemy.x + dx
    local newY = enemy.y + dy
    
    return EnemyAI.moveToPosition(enemy, newX, newY, gameGrid, gridWidth, gridHeight)
end

-- Random movement AI
function EnemyAI.randomMovement(enemy, gameGrid, gridWidth, gridHeight)
    -- Only move if random chance succeeds
    if math.random() < enemy.moveChance then
        local directions = {{0,1}, {0,-1}, {1,0}, {-1,0}}
        local dir = directions[math.random(#directions)]
        local newX = enemy.x + dir[1]
        local newY = enemy.y + dir[2]
        
        return EnemyAI.moveToPosition(enemy, newX, newY, gameGrid, gridWidth, gridHeight)
    end
    
    return false
end

-- Move enemy to a specific position if valid
function EnemyAI.moveToPosition(enemy, newX, newY, gameGrid, gridWidth, gridHeight)
    -- Check bounds
    if newX < 1 or newX > gridWidth or newY < 1 or newY > gridHeight then
        return false
    end
    
    local targetCell = gameGrid[newY][newX]
    if targetCell and targetCell.walkable and not targetCell.isEnemy then
        -- Clear old position (restore the floor)
        gameGrid[enemy.y][enemy.x] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
        
        -- Update enemy position
        enemy.x = newX
        enemy.y = newY
        
        -- Place enemy at new position (we'll need to import Enemy module for this)
        local Enemy = require("game.creatures.enemy")
        Enemy.placeOnGrid(enemy, gameGrid)
        
        return true
    end
    
    return false
end

-- Aggressive AI behavior - actively hunts player
function EnemyAI.aggressiveBehavior(enemy, player, gameGrid, gridWidth, gridHeight)
    -- Attack if in range
    if EnemyAI.isPlayerInAttackRange(enemy, player) then
        return "attack"
    end
    
    -- Chase if can see player
    if EnemyAI.canSeePlayer(enemy, player) then
        EnemyAI.chasePlayer(enemy, player, gameGrid, gridWidth, gridHeight)
        return "chase"
    end
    
    -- Random movement otherwise
    EnemyAI.randomMovement(enemy, gameGrid, gridWidth, gridHeight)
    return "wander"
end

-- Defensive AI behavior - tries to keep distance
function EnemyAI.defensiveBehavior(enemy, player, gameGrid, gridWidth, gridHeight)
    local dist = distance(enemy.x, enemy.y, player.x, player.y)
    
    -- Attack if cornered (adjacent)
    if dist <= 1.5 then
        return "attack"
    end
    
    -- Try to maintain distance if player is close
    if dist <= 3 then
        -- Move away from player
        local dx, dy = getDirectionTo(player.x, player.y, enemy.x, enemy.y) -- Reversed direction
        local newX = enemy.x + dx
        local newY = enemy.y + dy
        
        EnemyAI.moveToPosition(enemy, newX, newY, gameGrid, gridWidth, gridHeight)
        return "flee"
    end
    
    -- Random movement otherwise
    EnemyAI.randomMovement(enemy, gameGrid, gridWidth, gridHeight)
    return "wander"
end

-- Guard AI behavior - patrols a small area
function EnemyAI.guardBehavior(enemy, player, gameGrid, gridWidth, gridHeight)
    -- Store original position if not set
    if not enemy.guardX then
        enemy.guardX = enemy.x
        enemy.guardY = enemy.y
        enemy.guardRadius = 3
    end
    
    -- Attack if player is adjacent
    if EnemyAI.isPlayerInAttackRange(enemy, player) then
        return "attack"
    end
    
    -- Chase player if within guard area and detection range
    local playerInGuardArea = distance(player.x, player.y, enemy.guardX, enemy.guardY) <= enemy.guardRadius
    if playerInGuardArea and EnemyAI.canSeePlayer(enemy, player) then
        EnemyAI.chasePlayer(enemy, player, gameGrid, gridWidth, gridHeight)
        return "chase"
    end
    
    -- Return to guard post if too far away
    local distFromPost = distance(enemy.x, enemy.y, enemy.guardX, enemy.guardY)
    if distFromPost > enemy.guardRadius then
        local dx, dy = getDirectionTo(enemy.x, enemy.y, enemy.guardX, enemy.guardY)
        local newX = enemy.x + dx
        local newY = enemy.y + dy
        EnemyAI.moveToPosition(enemy, newX, newY, gameGrid, gridWidth, gridHeight)
        return "return"
    end
    
    -- Random patrol movement within guard area
    EnemyAI.randomMovement(enemy, gameGrid, gridWidth, gridHeight)
    return "patrol"
end

-- Main AI decision function - chooses behavior based on enemy type
function EnemyAI.updateBehavior(enemy, player, gameGrid, gridWidth, gridHeight)
    -- Don't act if enemy is dead
    if not enemy.healthManager:isAlive() then
        return "dead"
    end
    
    -- Choose AI behavior based on enemy type
    local action = "idle"
    
    if enemy.type == "goblin" then
        -- Goblins are aggressive and chase the player
        action = EnemyAI.aggressiveBehavior(enemy, player, gameGrid, gridWidth, gridHeight)
    elseif enemy.type == "orc" then
        -- Orcs are aggressive but slower
        action = EnemyAI.aggressiveBehavior(enemy, player, gameGrid, gridWidth, gridHeight)
    elseif enemy.type == "skeleton" then
        -- Skeletons guard their area
        action = EnemyAI.guardBehavior(enemy, player, gameGrid, gridWidth, gridHeight)
    else
        -- Default behavior for unknown types
        action = EnemyAI.aggressiveBehavior(enemy, player, gameGrid, gridWidth, gridHeight)
    end
    
    return action
end

-- Advanced pathfinding using simple A* approach (optional enhancement)
function EnemyAI.findPath(enemy, targetX, targetY, gameGrid, gridWidth, gridHeight, maxSteps)
    maxSteps = maxSteps or 10 -- Limit pathfinding steps for performance
    
    -- Simple pathfinding: try direct approach first
    local dx, dy = getDirectionTo(enemy.x, enemy.y, targetX, targetY)
    local newX = enemy.x + dx
    local newY = enemy.y + dy
    
    -- Check if direct path is clear
    if newX >= 1 and newX <= gridWidth and newY >= 1 and newY <= gridHeight then
        local targetCell = gameGrid[newY][newX]
        if targetCell and targetCell.walkable and not targetCell.isEnemy then
            return newX, newY
        end
    end
    
    -- If direct path blocked, try alternative directions
    local alternatives = {}
    for _, dir in ipairs({{1,0}, {-1,0}, {0,1}, {0,-1}}) do
        local altX = enemy.x + dir[1]
        local altY = enemy.y + dir[2]
        
        if altX >= 1 and altX <= gridWidth and altY >= 1 and altY <= gridHeight then
            local cell = gameGrid[altY][altX]
            if cell and cell.walkable and not cell.isEnemy then
                local dist = distance(altX, altY, targetX, targetY)
                table.insert(alternatives, {x = altX, y = altY, dist = dist})
            end
        end
    end
    
    -- Sort by distance and return closest valid position
    if #alternatives > 0 then
        table.sort(alternatives, function(a, b) return a.dist < b.dist end)
        return alternatives[1].x, alternatives[1].y
    end
    
    -- No valid path found
    return enemy.x, enemy.y
end

-- Group AI behavior (for future expansion)
function EnemyAI.groupBehavior(enemies, player, gameGrid, gridWidth, gridHeight)
    -- This could be used for coordinated attacks, formations, etc.
    -- For now, just a placeholder for future development
    return false
end

return EnemyAI
