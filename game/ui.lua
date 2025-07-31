-- UI module for ASCII Roguelike
-- Handles all user interface elements including logger
local UI = {}

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

-- Logger configuration
local MAX_LOG_MESSAGES = 37
local logMessages = {}

-- Initialize the UI system
function UI.init(gridWidth, gridHeight, charWidth, charHeight)
    -- Calculate UI dimensions
    UI.gameAreaWidth = math.floor(gridWidth * (1 - UI_WIDTH_RATIO))
    UI.uiAreaWidth = gridWidth - UI.gameAreaWidth
    UI.totalWidth = gridWidth
    UI.totalHeight = gridHeight
    UI.charWidth = charWidth
    UI.charHeight = charHeight
    
    -- UI sections
    UI.gameArea = {
        x = 1,
        y = 1,
        width = UI.gameAreaWidth,
        height = UI.totalHeight
    }
    
    UI.uiArea = {
        x = UI.gameAreaWidth + 1,
        y = 1,
        width = UI.uiAreaWidth,
        height = UI.totalHeight
    }
    
    -- Logger area (top part of UI)
    UI.logArea = {
        x = UI.uiArea.x + 1,
        y = UI.uiArea.y + 1,
        width = UI.uiArea.width - 2,
        height = math.floor(UI.totalHeight * 0.6) - 2
    }
    
    -- Info area (bottom part of UI)
    UI.infoArea = {
        x = UI.uiArea.x + 1,
        y = UI.logArea.y + UI.logArea.height + 2,
        width = UI.uiArea.width - 2,
        height = UI.totalHeight - (UI.logArea.y + UI.logArea.height + 2)
    }
    
    -- Initialize with welcome message
    UI.log("Welcome to ASCII Roguelike!")
    UI.log("Use WASD or arrow keys to move")
    UI.log("Press ESC to quit")
    
    return UI.gameAreaWidth, UI.totalHeight
end

-- Logger function to replace print statements
function UI.log(message)
    local timestamp = os.date("%H:%M:%S")
    local logEntry = string.format("[%s] %s", timestamp, tostring(message))
    
    table.insert(logMessages, logEntry)
    
    -- Remove old messages if we exceed the limit
    while #logMessages > MAX_LOG_MESSAGES do
        table.remove(logMessages, 1)
    end
end

-- Draw the entire UI
function UI.draw(gameGrid, player)
    -- Clear UI area with empty/black background
    UI.clearUIArea(gameGrid)
    
    -- Draw game area border
    UI.drawGameAreaBorder(gameGrid)
    
    -- Draw UI panel border
    UI.drawUIPanelBorder(gameGrid)
    
    -- Draw logger content
    UI.drawLogger(gameGrid)
    
    -- Draw info panel content
    UI.drawInfoPanel(gameGrid, player)
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
    
    -- Separator between log and info areas
    local sepY = UI.logArea.y + UI.logArea.height + 1
    for x = uiX, uiX + uiW - 1 do
        if sepY <= #gameGrid and x <= #gameGrid[sepY] then
            gameGrid[sepY][x] = {
                char = BORDER_CHARS.horizontal,
                color = {0.7, 0.7, 0.7},
                walkable = false
            }
        end
    end
end

-- Draw the logger content
function UI.drawLogger(gameGrid)
    -- Draw "LOG" title
    local titleY = UI.logArea.y - 1
    local titleText = "LOG"
    local startX = UI.logArea.x + math.floor((UI.logArea.width - #titleText) / 2)
    
    for i = 1, #titleText do
        local x = startX + i - 1
        if titleY <= #gameGrid and x <= #gameGrid[titleY] then
            gameGrid[titleY][x] = {
                char = titleText:sub(i, i),
                color = {1, 1, 0.5},
                walkable = false
            }
        end
    end
    
    -- Draw log messages
    local displayMessages = {}
    local startIdx = math.max(1, #logMessages - UI.logArea.height + 1)
    
    for i = startIdx, #logMessages do
        table.insert(displayMessages, logMessages[i])
    end
    
    for i, message in ipairs(displayMessages) do
        local y = UI.logArea.y + i - 1
        if y <= UI.logArea.y + UI.logArea.height - 1 then
            -- Wrap text if it's too long
            local wrappedLines = UI.wrapText(message, UI.logArea.width)
            for lineIdx, line in ipairs(wrappedLines) do
                local currentY = y + lineIdx - 1
                if currentY <= UI.logArea.y + UI.logArea.height - 1 then
                    for j = 1, math.min(#line, UI.logArea.width) do
                        local x = UI.logArea.x + j - 1
                        if currentY <= #gameGrid and x <= #gameGrid[currentY] then
                            gameGrid[currentY][x] = {
                                char = line:sub(j, j),
                                color = {0.9, 0.9, 0.9},
                                walkable = false
                            }
                        end
                    end
                end
            end
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
                color = {0.5, 1, 0.5},
                walkable = false
            }
        end
    end
    
    -- Draw player info
    local infoLines = {
        "Player: @",
        string.format("Pos: (%d,%d)", player.x, player.y),
        "",
        "Controls:",
        "WASD - Move",
        "ESC - Quit"
    }
    
    for i, line in ipairs(infoLines) do
        local y = UI.infoArea.y + i - 1
        if y <= UI.infoArea.y + UI.infoArea.height - 1 then
            for j = 1, math.min(#line, UI.infoArea.width) do
                local x = UI.infoArea.x + j - 1
                if y <= #gameGrid and x <= #gameGrid[y] then
                    gameGrid[y][x] = {
                        char = line:sub(j, j),
                        color = {0.8, 0.8, 1},
                        walkable = false
                    }
                end
            end
        end
    end
end

-- Wrap text to fit within specified width
function UI.wrapText(text, maxWidth)
    local lines = {}
    local currentLine = ""
    
    for word in text:gmatch("%S+") do
        if #currentLine + #word + 1 <= maxWidth then
            if #currentLine > 0 then
                currentLine = currentLine .. " " .. word
            else
                currentLine = word
            end
        else
            if #currentLine > 0 then
                table.insert(lines, currentLine)
            end
            currentLine = word
        end
    end
    
    if #currentLine > 0 then
        table.insert(lines, currentLine)
    end
    
    return lines
end

-- Get game area dimensions for the main game logic
function UI.getGameAreaDimensions()
    return UI.gameAreaWidth, UI.totalHeight
end

-- Check if a coordinate is in the game area
function UI.isInGameArea(x, y)
    return x >= UI.gameArea.x and x <= UI.gameArea.width and 
           y >= UI.gameArea.y and y <= UI.gameArea.height
end

return UI
