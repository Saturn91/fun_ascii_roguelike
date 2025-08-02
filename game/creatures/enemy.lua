-- Enemy module for ASCII Roguelike
local Enemy = {}
Enemy.__index = Enemy

local EnemyAI = require("game.enemy.ai")

-- We'll get UI reference when needed to avoid circular dependency
local UI = nil
local Player = require("game.creatures.player")

-- Kill counter
local killCount = 0

-- Initialize UI reference (called from main)
function Enemy.setUI(uiModule)
    UI = uiModule
end

-- List to store all active enemies
local enemies = {}

-- Create a new enemy of specified type at position
function Enemy.new(x, y, enemyType)
    local template = ConfigManager.ENEMY[enemyType]
    if not template then
        error("Unknown enemy type: " .. tostring(enemyType))
    end
    
    -- Resolve color string to actual color values
    local color = template.color
    if color == nil or color == "" then
        color = "white"
    end
    
    -- Create base creature with enemy-specific config
    local creatureConfig = {
        x = x,
        y = y,
        char = template.char,
        color = color,
        damageLogColor = "red",
        health = template.health,
        walkable = false, -- Enemies block movement
        baseAttackDamage = template.damage
    }
    
    local enemy = Creature.new(creatureConfig)
    setmetatable(enemy, Enemy)
    
    -- Add enemy-specific properties
    enemy.damage = template.damage
    enemy.name = template.name
    enemy.moveChance = template.moveChance
    enemy.aggroRange = template.aggroRange
    enemy.type = enemyType
    enemy.isEnemy = true
    
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
-- Clear all enemies
function Enemy.clear()
    enemies = {}
end

-- Move enemy to new position if valid
function Enemy.moveTo(enemy, newX, newY, gameGrid, gridWidth, gridHeight)
    -- Check if target position has an enemy (enemies can't move to occupied positions)
    local targetCell = gameGrid[newY] and gameGrid[newY][newX]
    if targetCell and targetCell.isEnemy then
        return false
    end
    
    -- Use inherited moveTo method
    return enemy:moveTo(newX, newY, gameGrid, gridWidth, gridHeight)
end

-- AI behavior for a single enemy (delegates to AI module)
function Enemy.updateAI(enemy, player, gameGrid, gridWidth, gridHeight)
    -- Use the AI module to determine behavior
    local action = EnemyAI.updateBehavior(enemy, player, gameGrid, gridWidth, gridHeight)
    
    -- Handle attack action
    if action == "attack" then
        Enemy.attackPlayer(enemy, player)
    end
    
    return action
end

-- Enemy attacks the player
function Enemy.attackPlayer(enemy, player)
    Player.takeDamage(player, enemy.damage)
    Log.log(string.format("[red]%s[/red] attacks [gold]@[/gold] for [damage]%d damage[/damage]!", 
        enemy.name, enemy.damage))
end

-- Player attacks an enemy
function Enemy.takeDamage(enemy, damage, gameGrid)
    local actualDamage = enemy.healthManager:damage(damage)
    
    Log.log(string.format("[gold]@[/gold] attacks [red]%s[/red] for [damage]%d damage[/damage]! ([health]%d[/health]/[health]%d[/health])", 
        enemy.name, actualDamage, enemy.healthManager.health, enemy.healthManager.maxHealth))
    
    if enemy.healthManager.health <= 0 then
        Log.log(string.format("[success]%s defeated![/success]", enemy.name))
        -- Increment kill count
        killCount = killCount + 1
        Log.log(string.format("[info]Enemies defeated: %d[/info]", killCount))
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
        if enemy.healthManager.health > 0 then
            Enemy.updateAI(enemy, player, gameGrid, gridWidth, gridHeight)
        end
    end
end

-- Place enemy on the game grid at their current position
function Enemy.placeOnGrid(enemy, gameGrid)
    Creature.placeOnGrid(enemy, gameGrid)

    -- Add enemy-specific properties to the grid cell
    gameGrid[enemy.y][enemy.x].isEnemy = true
    gameGrid[enemy.y][enemy.x].enemy = enemy -- Reference to the enemy object
end

-- Spawn enemies in random walkable locations
function Enemy.spawnRandom(gameGrid, gridWidth, gridHeight, count, enemyType, customEnemyList)
    local enemyList = customEnemyList or enemies  -- Use custom list or default global list
    local spawned = 0
    local attempts = 0
    local maxAttempts = 1000
    
    while spawned < count and attempts < maxAttempts do
        attempts = attempts + 1
        local x = love.math.random(2, gridWidth - 1)
        local y = love.math.random(3, gridHeight - 1) -- Avoid top rows (UI area)
        
        local cell = gameGrid[y][x]
        if cell and cell.walkable and cell.char == "." and not cell.isEnemy then
            local enemy = Enemy.new(x, y, enemyType)
            if enemy then
                table.insert(enemyList, enemy)
                Enemy.placeOnGrid(enemy, gameGrid)
                spawned = spawned + 1
            end
        end
    end
    
    return spawned
end

-- Get total living enemy count
function Enemy.getTotalCount()
    local count = 0
    for _, enemy in ipairs(enemies) do
        if enemy.healthManager.health > 0 then
            count = count + 1
        end
    end
    return count
end

-- Get total enemies killed
function Enemy.getKillCount()
    return killCount
end

-- Reset kill count (called when starting new game)
function Enemy.resetKillCount()
    killCount = 0
end

return Enemy
