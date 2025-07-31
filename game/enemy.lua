-- Enemy module for ASCII Roguelike
local Enemy = {}

-- We'll get UI reference when needed to avoid circular dependency
local UI = nil
local Player = require("game.player")

-- Initialize UI reference (called from main)
function Enemy.setUI(uiModule)
    UI = uiModule
end

-- Enemy types with different characteristics
local EnemyTypes = {
    goblin = {
        char = "g",
        color = {0.0, 0.8, 0.0}, -- Green
        health = 3,
        damage = 1,
        name = "Goblin",
        moveChance = 0.3, -- 30% chance to move each turn
        aggroRange = 3    -- Will chase player within 3 tiles
    },
    orc = {
        char = "O",
        color = {0.6, 0.3, 0.0}, -- Brown
        health = 5,
        damage = 2,
        name = "Orc",
        moveChance = 0.2, -- 20% chance to move each turn
        aggroRange = 4    -- Will chase player within 4 tiles
    },
    skeleton = {
        char = "s",
        color = {0.9, 0.9, 0.9}, -- Light gray
        health = 2,
        damage = 1,
        name = "Skeleton",
        moveChance = 0.4, -- 40% chance to move each turn
        aggroRange = 2    -- Will chase player within 2 tiles
    }
}

-- List to store all active enemies
local enemies = {}

-- Create a new enemy of specified type at position
function Enemy.new(x, y, enemyType)
    local template = EnemyTypes[enemyType]
    if not template then
        error("Unknown enemy type: " .. tostring(enemyType))
    end
    
    local enemy = {
        x = x,
        y = y,
        char = template.char,
        color = template.color,
        health = template.health,
        maxHealth = template.health,
        damage = template.damage,
        name = template.name,
        moveChance = template.moveChance,
        aggroRange = template.aggroRange,
        type = enemyType,
        walkable = false, -- Enemies block movement
        isEnemy = true
    }
    
    -- Add to enemies list
    table.insert(enemies, enemy)
    
    return enemy
end

-- Get all active enemies
function Enemy.getAll()
    return enemies
end

-- Remove an enemy from the active list
function Enemy.remove(enemy)
    for i, e in ipairs(enemies) do
        if e == enemy then
            table.remove(enemies, i)
            break
        end
    end
end

-- Clear all enemies
function Enemy.clear()
    enemies = {}
end

-- Calculate distance between two points
local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Check if enemy can see/reach the player
function Enemy.canSeePlayer(enemy, player)
    local dist = distance(enemy.x, enemy.y, player.x, player.y)
    return dist <= enemy.aggroRange
end

-- Get direction towards target
local function getDirectionTo(fromX, fromY, toX, toY)
    local dx = toX - fromX
    local dy = toY - fromY
    
    -- Normalize to -1, 0, or 1
    if dx > 0 then dx = 1 elseif dx < 0 then dx = -1 else dx = 0 end
    if dy > 0 then dy = 1 elseif dy < 0 then dy = -1 else dy = 0 end
    
    return dx, dy
end

-- Move enemy towards target position
function Enemy.moveTowards(enemy, targetX, targetY, gameGrid, gridWidth, gridHeight)
    local dx, dy = getDirectionTo(enemy.x, enemy.y, targetX, targetY)
    local newX = enemy.x + dx
    local newY = enemy.y + dy
    
    return Enemy.moveTo(enemy, newX, newY, gameGrid, gridWidth, gridHeight)
end

-- Move enemy to new position if valid
function Enemy.moveTo(enemy, newX, newY, gameGrid, gridWidth, gridHeight)
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
        
        -- Place enemy at new position
        Enemy.placeOnGrid(enemy, gameGrid)
        
        return true
    end
    
    return false
end

-- AI behavior for a single enemy
function Enemy.updateAI(enemy, player, gameGrid, gridWidth, gridHeight)
    -- Don't move if enemy is dead
    if enemy.health <= 0 then
        return
    end
    
    -- Check if player is adjacent (combat range)
    local dist = distance(enemy.x, enemy.y, player.x, player.y)
    if dist <= 1.5 then -- Adjacent (including diagonals)
        -- Attack the player
        Enemy.attackPlayer(enemy, player)
        return
    end
    
    -- Check if enemy should chase the player
    if Enemy.canSeePlayer(enemy, player) then
        -- Move towards player
        Enemy.moveTowards(enemy, player.x, player.y, gameGrid, gridWidth, gridHeight)
    else
        -- Random movement chance
        if math.random() < enemy.moveChance then
            local directions = {{0,1}, {0,-1}, {1,0}, {-1,0}}
            local dir = directions[math.random(#directions)]
            Enemy.moveTo(enemy, enemy.x + dir[1], enemy.y + dir[2], gameGrid, gridWidth, gridHeight)
        end
    end
end

-- Enemy attacks the player
function Enemy.attackPlayer(enemy, player)
    Player.takeDamage(player, enemy.damage)
    Logger.log(string.format("[red]%s[/red] attacks [gold]@[/gold] for [damage]%d damage[/damage]!", 
        enemy.name, enemy.damage))
end

-- Player attacks an enemy
function Enemy.takeDamage(enemy, damage, gameGrid)
    enemy.health = math.max(0, enemy.health - damage)
    
    Logger.log(string.format("[gold]@[/gold] attacks [red]%s[/red] for [damage]%d damage[/damage]! ([health]%d[/health]/[health]%d[/health])", 
        enemy.name, damage, enemy.health, enemy.maxHealth))
    
    if enemy.health <= 0 then
        Logger.log(string.format("[success]%s defeated![/success]", enemy.name))
        -- Remove enemy from grid
        gameGrid[enemy.y][enemy.x] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
        -- Remove from enemies list
        Enemy.remove(enemy)
    end
end

-- Update all enemies (called each turn)
function Enemy.updateAll(player, gameGrid, gridWidth, gridHeight)
    -- Create a copy of the enemies list to avoid modification during iteration
    local enemiesCopy = {}
    for i, enemy in ipairs(enemies) do
        enemiesCopy[i] = enemy
    end
    
    for _, enemy in ipairs(enemiesCopy) do
        if enemy.health > 0 then
            Enemy.updateAI(enemy, player, gameGrid, gridWidth, gridHeight)
        end
    end
end

-- Place enemy on the game grid at their current position
function Enemy.placeOnGrid(enemy, gameGrid)
    gameGrid[enemy.y][enemy.x] = {
        char = enemy.char,
        color = enemy.color,
        walkable = false,
        isEnemy = true,
        enemy = enemy -- Reference to the enemy object
    }
end

-- Spawn enemies in random walkable locations
function Enemy.spawnRandom(gameGrid, gridWidth, gridHeight, count, enemyType)
    local spawned = 0
    local attempts = 0
    local maxAttempts = 1000
    
    while spawned < count and attempts < maxAttempts do
        attempts = attempts + 1
        local x = math.random(2, gridWidth - 1)
        local y = math.random(3, gridHeight - 1) -- Avoid top rows (UI area)
        
        local cell = gameGrid[y][x]
        if cell and cell.walkable and cell.char == "." and not cell.isEnemy then
            local enemy = Enemy.new(x, y, enemyType)
            Enemy.placeOnGrid(enemy, gameGrid)
            spawned = spawned + 1
        end
    end
    
    return spawned
end

-- Check if there's an enemy at the given position
function Enemy.getEnemyAt(x, y)
    for _, enemy in ipairs(enemies) do
        if enemy.x == x and enemy.y == y and enemy.health > 0 then
            return enemy
        end
    end
    return nil
end

-- Get enemy count by type
function Enemy.getCount(enemyType)
    local count = 0
    for _, enemy in ipairs(enemies) do
        if enemy.type == enemyType and enemy.health > 0 then
            count = count + 1
        end
    end
    return count
end

-- Get total living enemy count
function Enemy.getTotalCount()
    local count = 0
    for _, enemy in ipairs(enemies) do
        if enemy.health > 0 then
            count = count + 1
        end
    end
    return count
end

return Enemy
