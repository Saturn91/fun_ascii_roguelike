-- Player module for ASCII Roguelike
local Player = {}

-- We'll get UI reference when needed to avoid circular dependency
local UI = nil

-- Initialize UI reference (called from main)
function Player.setUI(uiModule)
    UI = uiModule
end

-- Create a new player at the specified position
function Player.new(x, y, health)
    return {
        x = x,
        y = y,
        char = "@",
        color = {1, 1, 0}, -- Yellow,
        health = health,
        maxHealth = health,
        walkable = true
    }
end

-- Damage the player (reduce health)
function Player.takeDamage(player, damage)
    player.health = math.max(0, player.health - damage)
    Logger.log(string.format("Player takes [damage]%d damage[/damage]! Health: [health]%d[/health]/[health]%d[/health]", 
        damage, player.health, player.maxHealth))
end

-- Heal the player (restore health)
function Player.heal(player, amount)
    player.health = math.min(player.maxHealth, player.health + amount)
    Logger.log(string.format("Player heals [heal]%d health[/heal]! Health: [health]%d[/health]/[health]%d[/health]", 
        amount, player.health, player.maxHealth))
end

-- Check if player is alive
function Player.isAlive(player)
    return player.health > 0
end

-- Handle player movement input and update position
function Player.handleMovement(player, key, gameGrid, gridWidth, gridHeight)
    local newX, newY = player.x, player.y
    
    -- Handle player movement input
    if key == "up" or key == "w" then
        newY = newY - 1
    elseif key == "down" or key == "s" then
        newY = newY + 1
    elseif key == "left" or key == "a" then
        newX = newX - 1
    elseif key == "right" or key == "d" then
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
    -- Check bounds and if the target tile is walkable
    if newX >= 1 and newX <= gridWidth and newY >= 1 and newY <= gridHeight then
        local targetTile = gameGrid[newY][newX]
        if targetTile and targetTile.walkable then
            -- Clear old position (restore the floor)
            gameGrid[player.y][player.x] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
            
            -- Update player position
            player.x = newX
            player.y = newY
            gameGrid[player.y][player.x] = {char = player.char, color = player.color, walkable = true}
            
            return true -- Movement successful
        else
            -- Player tried to walk into a wall
            Logger.log("[warning]Bonk![/warning] That's a wall!")
            return false -- Movement blocked
        end
    end
    
    return false -- Out of bounds
end

-- Place the player on the game grid at their current position
function Player.placeOnGrid(player, gameGrid)
    gameGrid[player.y][player.x] = {
        char = player.char, 
        color = player.color, 
        walkable = true
    }
end

-- Get player's current position
function Player.getPosition(player)
    return player.x, player.y
end

-- Check if player is at a specific position
function Player.isAt(player, x, y)
    return player.x == x and player.y == y
end

return Player
