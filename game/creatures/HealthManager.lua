-- Health Manager
-- Manages health and maxHealth for entities
local HealthManager = {}
HealthManager.__index = HealthManager

-- Initialize health manager with health and maxHealth values
function HealthManager.new(health, creature)
    local healthManager = setmetatable({}, HealthManager)
    healthManager.health = health
    healthManager.maxHealth = health
    healthManager.creature = creature
    return healthManager
end

-- Set current health (clamped between 0 and maxHealth)
function HealthManager:set(newHealth)
    self.health = math.max(0, math.min(newHealth, self.maxHealth))
    return self.health
end

-- Heal by amount (cannot exceed maxHealth)
function HealthManager:heal(amount)
    local oldHealth = self.health
    self.health = math.min(self.health + amount, self.maxHealth)
    local actualHealed = self.health - oldHealth
    
    return actualHealed
end

-- Damage by amount (cannot go below 0)
function HealthManager:damage(amount)
    local oldHealth = self.health
    self.health = math.max(0, self.health - amount)
    local actualDamage = oldHealth - self.health
    
    return actualDamage
end

function HealthManager:isAlive()
    return self.health > 0
end

function HealthManager:getPercentage()
    return self.health / self.maxHealth
end

return HealthManager
