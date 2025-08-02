-- ASCII Grid Management Module
-- Handles grid initialization, rendering, and cell management

local AsciiGrid = {}

-- Grid state variables
local gridWidth = 0
local gridHeight = 0
local charWidth = 0
local charHeight = 0
local gameAreaWidth = 0
local gameAreaHeight = 0

-- Foreground layer for overlays (like pause menu)
local foregroundGrid = nil
local foregroundEnabled = false

-- Initialize the ASCII grid system
function AsciiGrid.init(windowWidth, windowHeight, cellCharWidth, cellCharHeight, gameAreaW, gameAreaH)
    charWidth = cellCharWidth
    charHeight = cellCharHeight
    
    -- Calculate grid dimensions based on character size
    gridWidth = math.floor(windowWidth / charWidth)
    gridHeight = math.floor(windowHeight / charHeight)
    
    -- Store game area dimensions for boundary checking
    gameAreaWidth = gameAreaW or gridWidth
    gameAreaHeight = gameAreaH or gridHeight
    
    -- Initialize game state
    local gameGrid = {}
    for y = 1, gridHeight do
        gameGrid[y] = {}
        for x = 1, gridWidth do
            if y == 1 then
                -- Top row is reserved for health bar - make it empty/black
                gameGrid[y][x] = {char = " ", color = {0, 0, 0}, walkable = false}
            elseif x <= gameAreaWidth and y >= 2 and y <= gameAreaHeight + 1 then
                -- Game area: start with walls that will be carved out by room generation
                gameGrid[y][x] = {char = "#", color = {0.4, 0.4, 0.4}, walkable = false} -- Dark gray walls
            else
                -- Outside game area: empty space (UI area or borders)
                gameGrid[y][x] = {char = " ", color = {0, 0, 0}, walkable = false}
            end
        end
    end
    
    return gameGrid, gridWidth, gridHeight
end

-- Get grid dimensions
function AsciiGrid.getDimensions()
    return gridWidth, gridHeight
end

-- Get character dimensions
function AsciiGrid.getCharDimensions()
    return charWidth, charHeight
end

-- Set a cell in the grid (works with global gameGrid)
function AsciiGrid.setCell(grid, x, y, char, color, walkable)
    if x >= 1 and x <= gridWidth and y >= 1 and y <= gridHeight then
        grid[y][x] = {
            char = char or " ",
            color = color or {1, 1, 1},
            walkable = walkable ~= false -- Default to true unless explicitly false
        }
    end
end

-- Get a cell from the grid
function AsciiGrid.getCell(grid, x, y)
    if x >= 1 and x <= gridWidth and y >= 1 and y <= gridHeight then
        return grid[y][x]
    end
    return nil
end

-- Check if a position is within grid bounds
function AsciiGrid.isInBounds(x, y)
    return x >= 1 and x <= gridWidth and y >= 1 and y <= gridHeight
end

-- Check if a cell is walkable
function AsciiGrid.isWalkable(grid, x, y)
    local cell = AsciiGrid.getCell(grid, x, y)
    return cell and cell.walkable
end

-- Clear a specific area of the grid
function AsciiGrid.clearArea(grid, startX, startY, endX, endY, char, color, walkable)
    char = char or " "
    color = color or {0, 0, 0}
    walkable = walkable ~= false
    
    for y = startY, endY do
        for x = startX, endX do
            AsciiGrid.setCell(grid, x, y, char, color, walkable)
        end
    end
end

-- Render the entire ASCII grid with optional foreground layer
function AsciiGrid.draw(grid)
    grid = grid or _G.gameGrid -- Use global gameGrid if no grid provided
    
    -- Draw main grid
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local cell = grid[y][x]
            if cell and cell.char and cell.char ~= " " then  -- Don't render space characters
                if type(cell.color) == "string" then
                    love.graphics.setColor(Colors.get(cell.color))
                else
                    love.graphics.setColor(cell.color)
                end
                
                love.graphics.print(cell.char, (x-1) * charWidth, (y-1) * charHeight)
            end
        end
    end
    
    -- Draw foreground layer if enabled
    if foregroundEnabled and foregroundGrid then
        AsciiGrid.drawForeground()
    end
    
    -- Reset color to white
    love.graphics.setColor(1, 1, 1)
end

-- Draw only the foreground layer
function AsciiGrid.drawForeground()
    if foregroundEnabled and foregroundGrid then
        for y = 1, gridHeight do
            for x = 1, gridWidth do
                local cell = foregroundGrid[y][x]
                if cell and cell.char then
                    love.graphics.setColor(cell.color)
                    love.graphics.print(cell.char, (x-1) * charWidth, (y-1) * charHeight)
                end
            end
        end
    end
end

-- Render a specific area of the grid
function AsciiGrid.drawArea(grid, startX, startY, endX, endY)
    grid = grid or _G.gameGrid -- Use global gameGrid if no grid provided
    
    for y = math.max(1, startY), math.min(gridHeight, endY) do
        for x = math.max(1, startX), math.min(gridWidth, endX) do
            local cell = grid[y][x]
            if cell and cell.char and cell.char ~= " " then
                love.graphics.setColor(cell.color)
                love.graphics.print(cell.char, (x-1) * charWidth, (y-1) * charHeight)
            end
        end
    end
    
    -- Reset color to white
    love.graphics.setColor(1, 1, 1)
end

-- Fill the entire grid with a specific character
function AsciiGrid.fill(grid, char, color, walkable)
    char = char or " "
    color = color or {0, 0, 0}
    walkable = walkable ~= false
    
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            grid[y][x] = {char = char, color = color, walkable = walkable}
        end
    end
end

-- Reset grid to initial state (walls with health bar space)
function AsciiGrid.reset(grid)
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            if y == 1 then
                -- Top row is reserved for health bar - make it empty/black
                grid[y][x] = {char = " ", color = {0, 0, 0}, walkable = false}
            elseif x <= gameAreaWidth and y >= 2 and y <= gameAreaHeight + 1 then
                -- Game area: start with walls that will be carved out by room generation
                grid[y][x] = {char = "#", color = {0.4, 0.4, 0.4}, walkable = false}
            else
                -- Outside game area: empty space (UI area or borders)
                grid[y][x] = {char = " ", color = {0, 0, 0}, walkable = false}
            end
        end
    end
end

-- Initialize foreground layer
function AsciiGrid.initForeground()
    foregroundGrid = {}
    for y = 1, gridHeight do
        foregroundGrid[y] = {}
        for x = 1, gridWidth do
            foregroundGrid[y][x] = nil  -- Empty cells by default
        end
    end
end

-- Enable/disable foreground layer
function AsciiGrid.setForegroundEnabled(enabled)
    foregroundEnabled = enabled
    if enabled and not foregroundGrid then
        AsciiGrid.initForeground()
    end
end

-- Clear foreground layer
function AsciiGrid.clearForeground()
    if foregroundGrid then
        for y = 1, gridHeight do
            for x = 1, gridWidth do
                foregroundGrid[y][x] = nil
            end
        end
    end
end

-- Set a cell in the foreground layer
function AsciiGrid.setForegroundCell(x, y, char, color)
    if not foregroundGrid then
        AsciiGrid.initForeground()
    end
    
    if x > 0 and x <= gridWidth and y > 0 and y <= gridHeight then
        foregroundGrid[y][x] = {char = char, color = color}
    end
end

-- Get foreground grid for direct manipulation
function AsciiGrid.getForegroundGrid()
    if not foregroundGrid then
        AsciiGrid.initForeground()
    end
    return foregroundGrid
end

return AsciiGrid
