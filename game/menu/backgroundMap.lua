-- Background Map module for ASCII Roguelike
-- Generates and manages animated background worlds for menus
local BackgroundMap = {}

-- Import required modules
local MapGenerator = require("game.mapGenerator")
local Enemy = require("game.enemy")

-- Background world state
local backgroundGrid = nil
local backgroundEnemies = {}
local lastEnemyUpdate = 0
local enemyUpdateInterval = 0.5  -- 500ms

-- Initialize the background map system
function BackgroundMap.init()
    backgroundGrid = nil
    backgroundEnemies = {}
    lastEnemyUpdate = 0
end

-- Generate a new background world
function BackgroundMap.generate(gridWidth, gridHeight)
    -- Create a temporary grid for the background
    backgroundGrid = {}
    for y = 1, gridHeight do
        backgroundGrid[y] = {}
        for x = 1, gridWidth do
            backgroundGrid[y][x] = {char = "#", color = {0.2, 0.2, 0.2}, walkable = false}
        end
    end
    
    -- Generate rooms and corridors for background
    MapGenerator.generate(backgroundGrid, gridWidth, gridHeight)
    
    -- Spawn enemies in the background
    backgroundEnemies = {}
    Enemy.spawnRandom(backgroundGrid, gridWidth, gridHeight, 5, "goblin", backgroundEnemies)
    Enemy.spawnRandom(backgroundGrid, gridWidth, gridHeight, 3, "orc", backgroundEnemies)
    Enemy.spawnRandom(backgroundGrid, gridWidth, gridHeight, 2, "skeleton", backgroundEnemies)
end

-- Update background enemies movement
function BackgroundMap.update(dt)
    if not backgroundGrid or #backgroundEnemies == 0 then
        return
    end
    
    lastEnemyUpdate = lastEnemyUpdate + dt
    
    if lastEnemyUpdate >= enemyUpdateInterval then
        lastEnemyUpdate = 0
        
        -- Update each enemy in the background
        for _, enemy in ipairs(backgroundEnemies) do
            if enemy.health > 0 then
                -- Simple random movement for background enemies
                local directions = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}, {0, 0}} -- up, down, left, right, stay
                local direction = directions[love.math.random(1, #directions)]
                local newX = enemy.x + direction[1]
                local newY = enemy.y + direction[2]
                
                -- Check if the new position is valid and walkable
                if backgroundGrid[newY] and backgroundGrid[newY][newX] and 
                   backgroundGrid[newY][newX].walkable and 
                   backgroundGrid[newY][newX].char == "." then
                    
                    -- Clear old position
                    if backgroundGrid[enemy.y] and backgroundGrid[enemy.y][enemy.x] then
                        backgroundGrid[enemy.y][enemy.x].char = "."
                        backgroundGrid[enemy.y][enemy.x].color = {0.6, 0.6, 0.6}
                    end
                    
                    -- Move to new position
                    enemy.x = newX
                    enemy.y = newY
                    
                    -- Place enemy at new position
                    if backgroundGrid[newY] and backgroundGrid[newY][newX] then
                        backgroundGrid[newY][newX].char = enemy.char
                        backgroundGrid[newY][newX].color = enemy.color
                    end
                end
            end
        end
    end
end

-- Draw the background to the game grid with specified opacity
function BackgroundMap.draw(gameGrid, gridWidth, gridHeight, opacity)
    opacity = opacity or 0.4  -- Default 40% opacity
    
    -- Generate background if it doesn't exist
    if not backgroundGrid then
        BackgroundMap.generate(gridWidth, gridHeight)
    end
    
    -- Copy background to main grid with opacity
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            if gameGrid[y] and gameGrid[y][x] and backgroundGrid[y] and backgroundGrid[y][x] then
                gameGrid[y][x] = {
                    char = backgroundGrid[y][x].char,
                    color = {
                        backgroundGrid[y][x].color[1] * opacity,
                        backgroundGrid[y][x].color[2] * opacity,
                        backgroundGrid[y][x].color[3] * opacity
                    },
                    walkable = backgroundGrid[y][x].walkable
                }
            end
        end
    end
end

-- Apply a darker overlay in a specific region (useful for menu areas)
function BackgroundMap.drawOverlay(gameGrid, centerX, centerY, width, height, overlayOpacity)
    overlayOpacity = overlayOpacity or 0.3  -- Default 30% opacity
    
    local startX = centerX - width
    local endX = centerX + width
    local startY = centerY - height
    local endY = centerY + height
    
    for y = startY, endY do
        for x = startX, endX do
            if y > 0 and y <= #gameGrid and x > 0 and x <= #gameGrid[1] and 
               gameGrid[y] and gameGrid[y][x] then
                -- Darken the background further in overlay area
                gameGrid[y][x].color = {
                    gameGrid[y][x].color[1] * overlayOpacity,
                    gameGrid[y][x].color[2] * overlayOpacity,
                    gameGrid[y][x].color[3] * overlayOpacity
                }
            end
        end
    end
end

-- Clear the background (useful when starting a new game)
function BackgroundMap.clear()
    backgroundGrid = nil
    backgroundEnemies = {}
    lastEnemyUpdate = 0
end

-- Check if background exists
function BackgroundMap.exists()
    return backgroundGrid ~= nil
end

-- Get enemy count (for debugging)
function BackgroundMap.getEnemyCount()
    return #backgroundEnemies
end

-- Regenerate background with new parameters
function BackgroundMap.regenerate(gridWidth, gridHeight)
    BackgroundMap.clear()
    BackgroundMap.generate(gridWidth, gridHeight)
end

return BackgroundMap
