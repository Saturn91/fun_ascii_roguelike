-- Health Bar module for ASCII Roguelike
-- Displays player health at the top of the screen
local HealthBar = {}

-- Health bar configuration
local FULL_BLOCK = "█"  -- Unicode full block character
local EMPTY_BLOCK = "░"  -- Unicode light shade character
local HEALTH_COLOR = {0, 0.8, 0}  -- Dark green for better contrast
local DAMAGE_COLOR = {0.6, 0.1, 0.1}  -- Dark red
local BACKGROUND_COLOR = {0.3, 0.3, 0.3}  -- Dark gray

-- Draw the health bar at the top of the screen
function HealthBar.draw(gameGrid, player, gridWidth)
    if not player or not gameGrid or not gameGrid[1] then
        return
    end
    
    -- Calculate health bar dimensions
    local barWidth = math.min(gridWidth - 4, 40)  -- Leave some padding, max 40 chars
    local barStartX = math.floor((gridWidth - barWidth) / 2)  -- Center the bar
    local barY = 1  -- Top row
    
    -- Calculate how many blocks should be filled based on health percentage
    local healthPercent = player.health / player.maxHealth
    local filledBlocks = math.floor(barWidth * healthPercent)
    
    -- Draw the health bar
    for i = 1, barWidth do
        local x = barStartX + i - 1
        if x >= 1 and x <= gridWidth then
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
    
    -- Draw health text (HP: X/Y) to the right of the bar
    local healthText = string.format("HP: %d/%d", player.health, player.maxHealth)
    local textStartX = barStartX + barWidth + 2
    
    for i = 1, #healthText do
        local x = textStartX + i - 1
        if x >= 1 and x <= gridWidth then
            gameGrid[barY][x] = {
                char = healthText:sub(i, i),
                color = {1, 1, 1},  -- White text
                walkable = false
            }
        end
    end
end

return HealthBar
