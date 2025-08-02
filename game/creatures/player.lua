-- Player module for ASCII Roguelike
local Player = {}
Player.__index = Player
setmetatable(Player, Creature)

-- We'll get UI reference when needed to avoid circular dependency
local UI = nil

-- Initialize UI reference (called from main)
function Player.setUI(uiModule)
    UI = uiModule
end

-- Create a new player at the specified position
function Player.new(x, y, health)
    local playerHealth = health or ConfigManager.PLAYER.health
    
    -- Resolve player color
    local color = ConfigManager.PLAYER.color
    if not color or color == "" then
        color = "player"
    end
    
    -- Create base creature with player-specific config
    local creatureConfig = {
        x = x,
        y = y,
        char = ConfigManager.PLAYER.char or "@",
        color = color,
        health = playerHealth,
        walkable = true,
        baseAttackDamage = ConfigManager.PLAYER.baseAttackDamage
    }
    
    local player = Creature.new(creatureConfig)
    setmetatable(player, Creature)

    if ConfigManager.PLAYER.weapon then
        local slot = player.inventory:addItem(ConfigManager.PLAYER.weapon)
        player.inventory:equip(slot)
    end

    return player
end

-- Heal the player (restore health)
function Player.heal(player, amount)
    local actualHealed = player.healthManager:heal(amount)
    Log.log(string.format("["..player.color.."]"..player.char.."[/"..player.color.."] heals [heal]%d health[/heal]! ([health]%d[/health]/[health]%d[/health])", 
        actualHealed, player.healthManager.health, player.healthManager.maxHealth))
end

-- Check if player is alive
function Player.isAlive(player)
    return player.healthManager.health > 0
end

-- Handle player movement input and update position
function Player.handleMovement(player, key, gameGrid, gridWidth, gridHeight)
    local newX, newY = player.x, player.y
    
    -- Handle player movement input (arrow keys only)
    if key == "up" then
        newY = newY - 1
    elseif key == "down" then
        newY = newY + 1
    elseif key == "left" then
        newX = newX - 1
    elseif key == "right" then
        newX = newX + 1
    else
        -- No movement input, return false to indicate no movement
        return false
    end
    
    -- Attempt to move the player
    return Player.moveTo(player, newX, newY, gameGrid, gridWidth, gridHeight)
end

-- Move player to new position if valid
function Player.moveTo(player, newX, newY, gameGrid, gridWidth, gridHeight)
    -- Check bounds
    if newX >= 1 and newX <= gridWidth and newY >= 1 and newY <= gridHeight then
        local targetTile = gameGrid[newY][newX]
        
        -- Check if there's an enemy at the target position
        if targetTile and targetTile.isEnemy and targetTile.enemy then
            -- Attack the enemy using AttackHandler
            AttackHandler.attack(player, targetTile.enemy, gameGrid)
            return true -- Action taken (attack)
        elseif targetTile and targetTile.walkable then
            -- Use inherited moveTo method from Creature
            return player:moveTo(newX, newY, gameGrid, gridWidth, gridHeight)
        else
            -- Player tried to walk into a wall
            Log.log("[warning]Bonk![/warning] That's a wall!")
            return false -- Movement blocked
        end
    end
    
    return false -- Out of bounds
end

return Player
