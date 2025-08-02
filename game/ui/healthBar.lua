-- Health Bar module for ASCII Roguelike
-- Displays player health at the top of the screen
local HealthBar = {}

-- Health bar configuration
local FULL_BLOCK = "█"  -- Unicode full block character
local EMPTY_BLOCK = "░"  -- Unicode light shade character
local HEALTH_COLOR = {0, 0.8, 0}  -- Dark green for better contrast
local DAMAGE_COLOR = {0.6, 0.1, 0.1}  -- Dark red
local BACKGROUND_COLOR = {0.3, 0.3, 0.3}  -- Dark gray

-- Draw the health bar at the top of the screen, centered over game area
function HealthBar.draw(gameGrid, player, gameAreaWidth)
    if not player or not gameGrid or not gameGrid[1] then
        return
    end
    
    -- Calculate health bar dimensions (centered over game area only)
    local barWidth = math.min(gameAreaWidth - 4, 40)  -- Leave some padding, max 40 chars
    local barStartX = math.floor((gameAreaWidth - barWidth) / 2)  -- Center over game area
    local barY = 1  -- Top row
    
    -- Calculate how many blocks should be filled based on health percentage
    local healthPercent = player.healthManager:getPercentage()
    local filledBlocks = math.floor(barWidth * healthPercent)
    
    -- Draw the health bar
    for i = 1, barWidth do
        local x = barStartX + i - 1
        if x >= 1 and x <= gameAreaWidth then  -- Only draw within game area
            local char, color
            
            if i <= filledBlocks then
                -- Filled portion (green)
                char = FULL_BLOCK
                color = HEALTH_COLOR
            else
                -- Empty portion (red background)
                char = EMPTY_BLOCK
                color = DAMAGE_COLOR
            end
            
            gameGrid[barY][x] = {
                char = char,
                color = color,
                walkable = false
            }
        end
    end
    
    -- Draw health text (HP: X/Y) to the right of the bar with 3-digit zero padding
    local healthText = string.format("HP: %03d/%03d", player.healthManager.health, player.healthManager.maxHealth)
    local textStartX = barStartX + barWidth + 2
    
    for i = 1, #healthText do
        local x = textStartX + i - 1
        if x >= 1 and x <= gameAreaWidth then  -- Only draw within game area
            gameGrid[barY][x] = {
                char = healthText:sub(i, i),
                color = {1, 1, 1},  -- White text
                walkable = false
            }
        end
    end
end

return HealthBar
