-- AttackHandler module for ASCII Roguelike
-- Handles all attack behavior between creatures
local AttackHandler = {}

-- Handle attack between two creatures
-- @param attacker - The creature performing the attack
-- @param victim - The creature being attacked
-- @param gameGrid - The game grid for any grid-related updates
-- @return boolean - true if attack was successful, false otherwise
function AttackHandler.attack(attacker, victim, gameGrid)
    if not attacker or not victim then
        return false
    end
    
    -- Get attack damage from attacker
    local damage = attacker.baseAttackDamage or 1
    
    -- Apply damage to victim using their health manager
    local actualDamage = victim.healthManager:damage(damage)
    
    -- Log the attack
    local attackerName = attacker.name or (attacker.char and string.format("[%s]%s[/%s]", attacker.color, attacker.char, attacker.color)) or "Unknown"
    local victimName = victim.name or (victim.char and string.format("[%s]%s[/%s]", victim.color, victim.char, victim.color)) or "Unknown"
    
    Log.log(string.format("%s attacks %s for [damage]%d damage[/damage]! ([health]%d[/health]/[health]%d[/health])", 
        attackerName, victimName, actualDamage, victim.healthManager.health, victim.healthManager.maxHealth))
    
    -- Check if victim died
    if victim.healthManager.health <= 0 then
        AttackHandler.handleDeath(victim, gameGrid)
        return true -- Successful kill
    end
    
    return true -- Successful attack
end

-- Handle creature death
-- @param victim - The creature that died
-- @param gameGrid - The game grid for cleanup
function AttackHandler.handleDeath(victim, gameGrid)
    if not victim or not gameGrid then
        return
    end
    
    -- Log death
    local victimName = victim.name or (victim.char and string.format("[%s]%s[/%s]", victim.color, victim.char, victim.color)) or "Unknown"
    Log.log(string.format("[success]%s defeated![/success]", victimName))
    
    -- Handle enemy-specific death logic
    if victim.isEnemy then
        -- Increment kill count and log it
        local success, Enemy = pcall(require, "game.creatures.enemy")
        if success and Enemy.incrementKillCount then
            Enemy.incrementKillCount()
        end
        
        -- Remove from enemies list
        if success and Enemy.remove then
            Enemy.remove(victim)
        end
    end
    
    -- Remove from grid (restore floor)
    if victim.x and victim.y and gameGrid[victim.y] and gameGrid[victim.y][victim.x] then
        gameGrid[victim.y][victim.x] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
    end
end

return AttackHandler
