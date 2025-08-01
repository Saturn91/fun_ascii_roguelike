-- UI module for ASCII Roguelike
-- Handles all user interface elements including Log
local UI = {}

-- Import UI sub-modules
local TitleSection = require("game.ui.titleSection")
local HealthBar = require("game.ui.healthBar")
local Controls = require("game.ui.controls")

-- UI configuration
local UI_WIDTH_RATIO = 0.25  -- UI takes up 25% of screen width
local BORDER_CHARS = {
    vertical = "|",
    horizontal = "-",
    corner_tl = "+",
    corner_tr = "+",
    corner_bl = "+",
    corner_br = "+",
    cross = "+"
}

-- Initialize the UI system
function UI.init(gridWidth, gridHeight, charWidth, charHeight)
    -- Calculate UI dimensions
    UI.gameAreaWidth = math.floor(gridWidth * (1 - UI_WIDTH_RATIO))
    UI.uiAreaWidth = gridWidth - UI.gameAreaWidth
    UI.totalWidth = gridWidth
    UI.totalHeight = gridHeight
    UI.charWidth = charWidth
    UI.charHeight = charHeight
    
    -- UI sections (health bar over game area, UI extends to top)
    UI.gameArea = {
        x = 1,
        y = 2,  -- Start one row down to make room for health bar
        width = UI.gameAreaWidth,
        height = UI.totalHeight - 1  -- Reduce height by 1 for health bar
    }
    
    UI.uiArea = {
        x = UI.gameAreaWidth + 1,
        y = 1,  -- UI section extends to the very top
        width = UI.uiAreaWidth,
        height = UI.totalHeight  -- Full height for UI
    }
    
    -- Title area (top section of UI)
    UI.titleArea = {
        x = UI.uiArea.x + 1,
        y = UI.uiArea.y,  -- Start at very top of UI area
        width = UI.uiArea.width - 2,
        height = 8  -- Space for title, version, and author
    }
    
    -- Log area (moved down to make room for title)
    UI.logArea = {
        x = UI.uiArea.x + 1,
        y = UI.titleArea.y + UI.titleArea.height + 2,  -- Position after title area + border
        width = UI.uiArea.width - 2,
        height = math.floor(UI.totalHeight * 0.6) - 2 - UI.titleArea.height - 2  -- Adjust for title space
    }
    
    -- Info area (player information)
    local remainingHeight = UI.totalHeight - (UI.logArea.y + UI.logArea.height + 2)
    local infoHeight = math.floor(remainingHeight * 0.4)  -- 40% for info
    local controlsHeight = remainingHeight - infoHeight - 2  -- Rest for controls (minus separator)
    
    UI.infoArea = {
        x = UI.uiArea.x + 1,
        y = UI.logArea.y + UI.logArea.height + 2,
        width = UI.uiArea.width - 2,
        height = infoHeight
    }
    
    -- Controls area (game controls)
    UI.controlsArea = {
        x = UI.uiArea.x + 1,
        y = UI.infoArea.y + UI.infoArea.height + 2,
        width = UI.uiArea.width - 2,
        height = controlsHeight
    }

    return UI.gameAreaWidth, UI.gameArea.height
end

-- Draw the entire UI
function UI.draw(gameGrid, player)
    -- Draw health bar centered over game area
    HealthBar.draw(gameGrid, player, UI.gameAreaWidth)
    
    -- Clear UI area with empty/black background
    UI.clearUIArea(gameGrid)
    
    -- Draw game area border
    UI.drawGameAreaBorder(gameGrid)
    
    -- Draw UI panel border
    UI.drawUIPanelBorder(gameGrid)
    
    -- Draw title section using TitleSection module
    TitleSection.draw(gameGrid, UI.titleArea)
    
    -- Draw Log content using Log module
    Log.draw(gameGrid, UI.logArea)
    
    -- Draw info panel content
    UI.drawInfoPanel(gameGrid, player)
    
    -- Draw controls section using Controls module
    Controls.draw(gameGrid, UI.controlsArea)
end

-- Clear the UI area with black background (empty cells)
function UI.clearUIArea(gameGrid)
    -- Clear the entire UI area
    for y = UI.uiArea.y, UI.uiArea.y + UI.uiArea.height - 1 do
        for x = UI.uiArea.x, UI.uiArea.x + UI.uiArea.width - 1 do
            if y <= #gameGrid and x <= #gameGrid[y] then
                gameGrid[y][x] = {
                    char = " ",  -- Space character for clean background
                    color = {0, 0, 0},  -- Black color
                    walkable = false
                }
            end
        end
    end
end

-- Draw border around the game area
function UI.drawGameAreaBorder(gameGrid)
    local x = UI.gameAreaWidth + 1
    
    -- Vertical border line
    for y = 1, UI.totalHeight do
        if y <= #gameGrid and x <= #gameGrid[y] then
            gameGrid[y][x] = {
                char = BORDER_CHARS.vertical,
                color = {0.7, 0.7, 0.7},
                walkable = false
            }
        end
    end
end

-- Draw border around UI panels
function UI.drawUIPanelBorder(gameGrid)
    local uiX = UI.uiArea.x
    local uiY = UI.uiArea.y
    local uiW = UI.uiArea.width
    local uiH = UI.uiArea.height
    
    -- Top border of UI area
    for x = uiX, uiX + uiW - 1 do
        if uiY <= #gameGrid and x <= #gameGrid[uiY] then
            gameGrid[uiY][x] = {
                char = BORDER_CHARS.horizontal,
                color = {0.7, 0.7, 0.7},
                walkable = false
            }
        end
    end
    
    -- Bottom border of UI area
    local bottomY = uiY + uiH - 1
    for x = uiX, uiX + uiW - 1 do
        if bottomY <= #gameGrid and x <= #gameGrid[bottomY] then
            gameGrid[bottomY][x] = {
                char = BORDER_CHARS.horizontal,
                color = {0.7, 0.7, 0.7},
                walkable = false
            }
        end
    end
    
    -- Right border of UI area
    local rightX = uiX + uiW - 1
    for y = uiY, uiY + uiH - 1 do
        if y <= #gameGrid and rightX <= #gameGrid[y] then
            gameGrid[y][rightX] = {
                char = BORDER_CHARS.vertical,
                color = {0.7, 0.7, 0.7},
                walkable = false
            }
        end
    end
    
    -- Separator between title and log areas
    local titleSepY = UI.titleArea.y + UI.titleArea.height + 1
    for x = uiX, uiX + uiW - 1 do
        if titleSepY <= #gameGrid and x <= #gameGrid[titleSepY] then
            gameGrid[titleSepY][x] = {
                char = BORDER_CHARS.horizontal,
                color = {0.7, 0.7, 0.7},
                walkable = false
            }
        end
    end
    
    -- Separator between log and info areas
    local logInfoSepY = UI.logArea.y + UI.logArea.height + 1
    for x = uiX, uiX + uiW - 1 do
        if logInfoSepY <= #gameGrid and x <= #gameGrid[logInfoSepY] then
            gameGrid[logInfoSepY][x] = {
                char = BORDER_CHARS.horizontal,
                color = {0.7, 0.7, 0.7},
                walkable = false
            }
        end
    end
    
    -- Separator between info and controls areas
    local infoControlsSepY = UI.infoArea.y + UI.infoArea.height + 1
    for x = uiX, uiX + uiW - 1 do
        if infoControlsSepY <= #gameGrid and x <= #gameGrid[infoControlsSepY] then
            gameGrid[infoControlsSepY][x] = {
                char = BORDER_CHARS.horizontal,
                color = {0.7, 0.7, 0.7},
                walkable = false
            }
        end
    end
end

-- Draw the info panel content
function UI.drawInfoPanel(gameGrid, player)
    -- Draw "INFO" title
    local titleY = UI.infoArea.y - 1
    local titleText = "INFO"
    local startX = UI.infoArea.x + math.floor((UI.infoArea.width - #titleText) / 2)
    
    for i = 1, #titleText do
        local x = startX + i - 1
        if titleY <= #gameGrid and x <= #gameGrid[titleY] then
            gameGrid[titleY][x] = {
                char = titleText:sub(i, i),
                color = {0.5, 1, 0.5},  -- Light green for info title
                walkable = false
            }
        end
    end
    
    -- Draw player info
    local infoLines = {
        "Player: @",
        string.format("Pos: (%d,%d)", player.x, player.y),
        string.format("HP: %d/%d", player.health, player.maxHealth),
        "",
        "Status: Alive"
    }
    
    for i, line in ipairs(infoLines) do
        local y = UI.infoArea.y + i - 1
        if y <= UI.infoArea.y + UI.infoArea.height - 1 then
            for j = 1, math.min(#line, UI.infoArea.width) do
                local x = UI.infoArea.x + j - 1
                if y <= #gameGrid and x <= #gameGrid[y] then
                    gameGrid[y][x] = {
                        char = line:sub(j, j),
                        color = {0.8, 0.8, 1},  -- Light blue for info text
                        walkable = false
                    }
                end
            end
        end
    end
end

-- Get game area dimensions for the main game logic
function UI.getGameAreaDimensions()
    return UI.gameAreaWidth, UI.gameArea.height
end

-- Check if a coordinate is in the game area
function UI.isInGameArea(x, y)
    return x >= UI.gameArea.x and x <= UI.gameArea.width and 
           y >= UI.gameArea.y and y <= UI.gameArea.height
end

return UI
