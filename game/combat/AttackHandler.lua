-- AttackHandler module for ASCII Roguelike
-- Handles all attack behavior between creatures
local AttackHandler = {}

-- Calculate damage for an attacker, considering equipped weapons
-- @param attacker - The creature performing the attack
-- @return number - The calculated damage value
function AttackHandler.calculateDamage(attacker)
    if not attacker then
        return 1
    end
    
    -- Check if attacker has inventory and a weapon equipped in right hand
    if attacker.inventory and attacker.inventory.equipment and attacker.inventory.equipment.r then
        local weapon = attacker.inventory.equipment.r
        
        -- If weapon has a damage dice formula, roll it
        if weapon.damage and Dice.validateFormula(weapon.damage) then
            local rollResult = Dice.roll(weapon.damage)
            Log.log(string.format("[info]%s:%s damage roll: %s = %d[/info]", attacker.char, weapon.char, weapon.damage, rollResult))
            return rollResult
        end
    end
    
    -- Fall back to base attack damage
    return attacker.baseAttackDamage or 1
end

-- Handle attack between two creatures
-- @param attacker - The creature performing the attack
-- @param victim - The creature being attacked
-- @param gameGrid - The game grid for any grid-related updates
-- @return boolean - true if attack was successful, false otherwise
function AttackHandler.attack(attacker, victim, gameGrid)
    if not attacker or not victim then
        return false
    end
    
    -- Calculate attack damage
    local damage = AttackHandler.calculateDamage(attacker)
    
    -- Apply damage to victim using their health manager
    local actualDamage = victim.healthManager:damage(damage)
    
    -- Log the attack
    local attackerName = attacker.name or (attacker.char and string.format("[%s]%s[/%s]", attacker.color, attacker.char, attacker.color)) or "Unknown"
    local victimName = victim.name or (victim.char and string.format("[%s]%s[/%s]", victim.color, victim.char, victim.color)) or "Unknown"
    
    -- Check if attacker used a weapon
    local weaponInfo = ""
    if attacker.inventory and attacker.inventory.equipment and attacker.inventory.equipment.r then
        local weapon = attacker.inventory.equipment.r
        local weaponChar = weapon.char or "?"
        local weaponColor = weapon.color or "silver"
        weaponInfo = string.format(" with [%s]%s[/%s]", weaponColor, weaponChar, weaponColor)
    end
    
    Log.log(string.format("%s attacks %s%s for [damage]%d damage[/damage]! ([health]%d[/health]/[health]%d[/health])", 
        attackerName, victimName, weaponInfo, actualDamage, victim.healthManager.health, victim.healthManager.maxHealth))
    
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
