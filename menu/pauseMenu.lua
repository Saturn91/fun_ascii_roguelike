-- Pause Menu module for ASCII Roguelike
-- Handles pause menu display and navigation
local PauseMenu = {}

-- Import required modules
local Colors = require("Colors")

-- Menu state
local selectedOption = 1  -- Start on "Resume"
local menuOptions = {
    {text = "Resume", enabled = true, color = "white"},
    {text = "New Game", enabled = true, color = "white"},
    {text = "Main Menu", enabled = true, color = "white"},
    {text = "Close", enabled = true, color = "white"}
}

-- Initialize the pause menu
function PauseMenu.init()
    selectedOption = 1  -- Start on "Resume"
end

-- Draw the pause menu using Love2D graphics overlay
function PauseMenu.draw(gridWidth, gridHeight)
    -- Get character dimensions for positioning
    local font = love.graphics.getFont()
    local charWidth = font:getWidth("A")
    local charHeight = font:getHeight()
    
    -- Draw semi-transparent overlay using Love2D graphics
    love.graphics.setColor(0, 0, 0, 0.7)  -- Semi-transparent black
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Calculate center positions
    local centerX = math.floor(gridWidth / 2)
    local centerY = math.floor(gridHeight / 2)
    
    -- Draw "PAUSED" title
    local title = "PAUSED"
    local titleX = (centerX - math.floor(string.len(title) / 2)) * charWidth
    local titleY = (centerY - 6) * charHeight
    
    love.graphics.setColor(1.0, 0.8, 0.2)  -- Gold color
    love.graphics.print(title, titleX, titleY)
    
    -- Draw menu options
    for i, option in ipairs(menuOptions) do
        local optionY = centerY - 2 + (i * 2)
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

-- Hide the pause menu (no-op for this approach)
function PauseMenu.hide()
    -- Nothing to do for Love2D graphics approach
end

-- Handle pause menu navigation
function PauseMenu.handleInput(key)
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
            if option.text == "Resume" then
                return "resume"
            elseif option.text == "New Game" then
                return "new_game"
            elseif option.text == "Main Menu" then
                return "main_menu"
            elseif option.text == "Close" then
                return "quit"
            end
        end
    elseif key == "escape" then
        return "resume"  -- Escape resumes the game
    end
    
    return nil
end

-- Get current selected option (for debugging)
function PauseMenu.getSelectedOption()
    return selectedOption, menuOptions[selectedOption].text
end

return PauseMenu
