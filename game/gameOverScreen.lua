-- Game Over Screen module for ASCII Roguelike
-- Handles game over display and navigation
local GameOverScreen = {}

-- Import required modules
local Colors = require("Colors")

-- Menu state
local selectedOption = 1  -- Start on "Retry"
local menuOptions = {
    {text = "Retry", enabled = true, color = "white"},
    {text = "Main Menu", enabled = true, color = "white"},
    {text = "Quit", enabled = true, color = "white"}
}

-- Game statistics (to be set when player dies)
local gameStats = {
    enemiesKilled = 0,
    timeAlive = "00:00",
    cause = "Unknown"
}

-- Initialize the game over screen
function GameOverScreen.init(stats)
    selectedOption = 1  -- Start on "Retry"
    if stats then
        gameStats = stats
    end
end

-- Draw the game over screen using Love2D graphics overlay
function GameOverScreen.draw(gridWidth, gridHeight)
    -- Get character dimensions for positioning
    local font = love.graphics.getFont()
    local charWidth = font:getWidth("A")
    local charHeight = font:getHeight()
    
    -- Draw semi-transparent overlay using Love2D graphics
    love.graphics.setColor(0.1, 0, 0, 0.8)  -- Dark red tint for game over
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Calculate center positions
    local centerX = math.floor(gridWidth / 2)
    local centerY = math.floor(gridHeight / 2)
    
    -- Draw "GAME OVER" title
    local title = "GAME OVER"
    local titleX = (centerX - math.floor(string.len(title) / 2)) * charWidth
    local titleY = (centerY - 8) * charHeight
    
    love.graphics.setColor(1.0, 0.2, 0.2)  -- Red color
    love.graphics.print(title, titleX, titleY)
    
    -- Draw game statistics
    local stats = {
        "Cause: " .. gameStats.cause,
        "Enemies Defeated: " .. gameStats.enemiesKilled,
        "Time Survived: " .. gameStats.timeAlive
    }
    
    love.graphics.setColor(0.8, 0.8, 0.8)  -- Light gray
    for i, stat in ipairs(stats) do
        local statX = (centerX - math.floor(string.len(stat) / 2)) * charWidth
        local statY = (centerY - 5 + i) * charHeight
        love.graphics.print(stat, statX, statY)
    end
    
    -- Draw separator line
    local separator = "─────────────────────"
    local sepX = (centerX - math.floor(string.len(separator) / 2)) * charWidth
    local sepY = (centerY - 1) * charHeight
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print(separator, sepX, sepY)
    
    -- Draw menu options
    for i, option in ipairs(menuOptions) do
        local optionY = centerY + 1 + (i * 2)
        local prefix = (i == selectedOption) and "> " or "  "
        local fullText = prefix .. option.text
        local optionX = (centerX - math.floor(string.len(fullText) / 2)) * charWidth
        local optionScreenY = optionY * charHeight
        
        -- Get color based on selection and enabled state
        local color
        if not option.enabled then
            color = Colors.palette.darkgray
        elseif i == selectedOption then
            color = Colors.palette.yellow
        else
            color = Colors.palette.white
        end
        
        love.graphics.setColor(color)
        love.graphics.print(fullText, optionX, optionScreenY)
    end
    
    -- Reset color to white
    love.graphics.setColor(1, 1, 1)
end

-- Handle game over screen navigation
function GameOverScreen.handleInput(key)
    if key == "up" or key == "w" then
        repeat
            selectedOption = selectedOption - 1
            if selectedOption < 1 then
                selectedOption = #menuOptions
            end
        until menuOptions[selectedOption].enabled
        return "navigate"
    elseif key == "down" or key == "s" then
        repeat
            selectedOption = selectedOption + 1
            if selectedOption > #menuOptions then
                selectedOption = 1
            end
        until menuOptions[selectedOption].enabled
        return "navigate"
    elseif key == "return" or key == "space" then
        local option = menuOptions[selectedOption]
        if option.enabled then
            if option.text == "Retry" then
                return "retry"
            elseif option.text == "Main Menu" then
                return "main_menu"
            elseif option.text == "Quit" then
                return "quit"
            end
        end
    elseif key == "escape" then
        return "main_menu"  -- Escape goes to main menu
    end
    
    return nil
end

-- Get current selected option (for debugging)
function GameOverScreen.getSelectedOption()
    return selectedOption, menuOptions[selectedOption].text
end

return GameOverScreen
