-- Logger module for ASCII Roguelike UI
local Logger = {}

-- Logger configuration
local MAX_LOG_MESSAGES = 27
local logMessages = {}

-- Logger function to replace print statements
function Logger.log(message)
    local timestamp = os.date("%H:%M:%S")
    local logEntry = string.format("[%s] %s", timestamp, tostring(message))
    print(logEntry)
    table.insert(logMessages, tostring(message))
    
    -- Remove old messages if we exceed the limit
    while #logMessages > MAX_LOG_MESSAGES do
        table.remove(logMessages, 1)
    end
end

-- Wrap text to fit within specified width
function Logger.wrapText(text, maxWidth)
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

-- Draw the logger content
function Logger.draw(gameGrid, logArea)
    -- Draw "LOG" title
    local titleY = logArea.y - 1
    local titleText = "LOG"
    local startX = logArea.x + math.floor((logArea.width - #titleText) / 2)
    
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
    local startIdx = math.max(1, #logMessages - logArea.height + 1)
    
    for i = startIdx, #logMessages do
        table.insert(displayMessages, logMessages[i])
    end
    
    for i, message in ipairs(displayMessages) do
        local y = logArea.y + i - 1
        if y <= logArea.y + logArea.height - 1 then
            -- Wrap text if it's too long
            local wrappedLines = Logger.wrapText(message, logArea.width)
            for lineIdx, line in ipairs(wrappedLines) do
                local currentY = y + lineIdx - 1
                if currentY <= logArea.y + logArea.height - 1 then
                    for j = 1, math.min(#line, logArea.width) do
                        local x = logArea.x + j - 1
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

return Logger
