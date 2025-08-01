-- Enemy Configuration Array
local enemyConfig = {
    goblin = {
        char = "g",
        color = "green",
        health = 3,
        damage = 1,
        name = "Goblin",
        moveChance = 0.3, -- 30% chance to move each turn
        aggroRange = 3    -- Will chase player within 3 tiles
    },
    orc = {
        char = "O",
        color = "brown",
        health = 5,
        damage = 2,
        name = "Orc",
        moveChance = 0.2, -- 20% chance to move each turn
        aggroRange = 4    -- Will chase player within 4 tiles
    },
    skeleton = {
        char = "s",
        color = "light_gray",
        health = 2,
        damage = 1,
        name = "Skeleton",
        moveChance = 0.4, -- 40% chance to move each turn
        aggroRange = 2    -- Will chase player within 2 tiles
    }
}

-- Validation function for enemy configuration
function enemyConfig.validate(config)
    if not config then
        return "Config is nil"
    end
    
    if type(config) ~= "table" then
        return "Config must be a table"
    end
    
    -- Check if there's at least one enemy type
    local hasEnemies = false
    for enemyType, enemy in pairs(config) do
        if type(enemy) == "table" then
            hasEnemies = true
            
            -- Validate individual enemy
            local result = enemyConfig.validateEnemy(enemyType, enemy)
            if result ~= true then
                return result
            end
        end
    end
    
    if not hasEnemies then
        return "Config must contain at least one enemy type"
    end
    
    return true
end

-- Validation function for individual enemy
function enemyConfig.validateEnemy(enemyType, enemy)
    if not enemy or type(enemy) ~= "table" then
        return string.format("Enemy '%s' must be a table", enemyType)
    end
    
    -- Validate char
    if not enemy.char or type(enemy.char) ~= "string" or enemy.char == "" then
        return string.format("Enemy '%s' char must be a non-empty string", enemyType)
    end
    
    if string.len(enemy.char) > 1 then
        return string.format("Enemy '%s' char must be a single character", enemyType)
    end
    
    -- Validate color
    if not enemy.color or type(enemy.color) ~= "string" or enemy.color == "" then
        return string.format("Enemy '%s' color must be a non-empty string", enemyType)
    end
    
    -- Validate health
    if not enemy.health or type(enemy.health) ~= "number" or enemy.health <= 0 then
        return string.format("Enemy '%s' health must be a positive number", enemyType)
    end
    
    if enemy.health > 1000 then
        return string.format("Enemy '%s' health cannot exceed 1000", enemyType)
    end
    
    -- Validate damage
    if not enemy.damage or type(enemy.damage) ~= "number" or enemy.damage <= 0 then
        return string.format("Enemy '%s' damage must be a positive number", enemyType)
    end
    
    if enemy.damage > 100 then
        return string.format("Enemy '%s' damage cannot exceed 100", enemyType)
    end
    
    -- Validate name
    if not enemy.name or type(enemy.name) ~= "string" or enemy.name == "" then
        return string.format("Enemy '%s' name must be a non-empty string", enemyType)
    end
    
    -- Validate moveChance
    if not enemy.moveChance or type(enemy.moveChance) ~= "number" or enemy.moveChance < 0 or enemy.moveChance > 1 then
        return string.format("Enemy '%s' moveChance must be a number between 0 and 1", enemyType)
    end
    
    -- Validate aggroRange
    if not enemy.aggroRange or type(enemy.aggroRange) ~= "number" or enemy.aggroRange < 1 then
        return string.format("Enemy '%s' aggroRange must be a positive number >= 1", enemyType)
    end
    
    if enemy.aggroRange > 50 then
        return string.format("Enemy '%s' aggroRange cannot exceed 50", enemyType)
    end
    
    return true
end

return enemyConfig
