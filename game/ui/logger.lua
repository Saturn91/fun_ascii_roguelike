-- Logger module for ASCII Roguelike UI
local Logger = {}

-- Import Colors module for markup parsing
local Colors = require("Colors")

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

function Logger.error(message)
    Logger.log("[red]-->err:" .. message .. "[/red]")
end

-- Wrap colored text segments to fit within specified width
function Logger.wrapColoredText(segments, maxWidth)
    local lines = {}
    local currentLine = {}
    local currentLength = 0
    
    for _, segment in ipairs(segments) do
        local words = {}
        for word in segment.text:gmatch("%S+") do
            table.insert(words, word)
        end
        
        for _, word in ipairs(words) do
            if currentLength + #word + (currentLength > 0 and 1 or 0) <= maxWidth then
                -- Add space if not first word on line
                if currentLength > 0 then
                    table.insert(currentLine, {text = " ", color = segment.color})
                    currentLength = currentLength + 1
                end
                table.insert(currentLine, {text = word, color = segment.color})
                currentLength = currentLength + #word
            else
                -- Start new line
                if #currentLine > 0 then
                    table.insert(lines, currentLine)
                end
                currentLine = {{text = word, color = segment.color}}
                currentLength = #word
            end
        end
    end
    
    -- Add the last line if it has content
    if #currentLine > 0 then
        table.insert(lines, currentLine)
    end
    
    return lines
end

-- Original wrap function for backward compatibility
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
    
    -- Draw log messages with color support
    local displayMessages = {}
    local startIdx = math.max(1, #logMessages - logArea.height + 1)
    
    for i = startIdx, #logMessages do
        table.insert(displayMessages, logMessages[i])
    end
    
    local currentY = logArea.y
    for i, message in ipairs(displayMessages) do
        if currentY > logArea.y + logArea.height - 1 then
            break
        end
        
        -- Parse color markup in the message
        local segments = Colors.parseMarkup(message, Colors.palette.text)
        
        -- Wrap the colored segments
        local wrappedLines = Logger.wrapColoredText(segments, logArea.width)
        
        for lineIdx, coloredLine in ipairs(wrappedLines) do
            if currentY > logArea.y + logArea.height - 1 then
                break
            end
            
            -- Draw each colored segment in the line
            local x = logArea.x
            for _, segment in ipairs(coloredLine) do
                for charIdx = 1, #segment.text do
                    if x <= logArea.x + logArea.width - 1 and currentY <= #gameGrid and x <= #gameGrid[currentY] then
                        gameGrid[currentY][x] = {
                            char = segment.text:sub(charIdx, charIdx),
                            color = segment.color,
                            walkable = false
                        }
                        x = x + 1
                    end
                end
            end
            currentY = currentY + 1
        end
    end
end

return Logger
