-- Menu module for ASCII Roguelike
-- Handles main menu display and navigation
local Menu = {}

-- Import required modules
local Colors = require("Colors")
local BackgroundMap = require("game.menu.backgroundMap")

-- Menu state
local selectedOption = 2  -- Start on "New Game"
local menuOptions = {
    {text = "Continue", enabled = false, color = "darkgray"},
    {text = "New Game", enabled = true, color = "white"},
    {text = "Close", enabled = true, color = "white"}
}

-- Initialize the menu
function Menu.init()
    selectedOption = 2  -- Start on "New Game" instead of "Continue"
    BackgroundMap.init()
end

-- Draw the menu to the ASCII grid
function Menu.draw(gameGrid, gridWidth, gridHeight, dt)
    -- Update and draw background map
    if dt then
        BackgroundMap.update(dt)
    end
    BackgroundMap.draw(gameGrid, gridWidth, gridHeight, 0.4)
    
    -- Calculate center positions
    local centerX = math.floor(gridWidth / 2)
    local centerY = math.floor(gridHeight / 2)
    
    -- Draw darker overlay behind menu text
    BackgroundMap.drawOverlay(gameGrid, centerX, centerY, 15, 8, 0.3)
    
    -- Draw title
    local title = "ASCII ROGUELIKE"
    local titleStartX = centerX - math.floor(string.len(title) / 2)
    local titleY = centerY - 6
    
    if titleY > 0 and titleStartX > 0 then
        for i = 1, string.len(title) do
            local char = string.sub(title, i, i)
            local x = titleStartX + i - 1
            if x <= gridWidth and gameGrid[titleY] and gameGrid[titleY][x] then
                gameGrid[titleY][x] = {char = char, color = {1.0, 0.8, 0.2}, walkable = false} -- Gold color
            end
        end
    end
    
    -- Draw menu options
    for i, option in ipairs(menuOptions) do
        local optionY = centerY - 2 + (i * 2)
        local prefix = (i == selectedOption) and "> " or "  "
        local fullText = prefix .. option.text
        local optionStartX = centerX - math.floor(string.len(fullText) / 2)
        
        if optionY > 0 and optionY <= gridHeight and optionStartX > 0 then
            -- Get color based on selection and enabled state
            local color
            if not option.enabled then
                color = Colors.palette.darkgray
            elseif i == selectedOption then
                color = Colors.palette.yellow
            else
                color = Colors.palette.white
            end
            
            for j = 1, string.len(fullText) do
                local char = string.sub(fullText, j, j)
                local x = optionStartX + j - 1
                if x <= gridWidth and gameGrid[optionY] and gameGrid[optionY][x] then
                    gameGrid[optionY][x] = {char = char, color = color, walkable = false}
                end
            end
        end
    end
end

-- Handle menu navigation
function Menu.handleInput(key)
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
            if option.text == "New Game" then
                return "new_game"
            elseif option.text == "Close" then
                return "quit"
            elseif option.text == "Continue" then
                return "continue"
            end
        end
    elseif key == "escape" then
        return "quit"
    end
    
    return nil
end

-- Get current selected option (for debugging)
function Menu.getSelectedOption()
    return selectedOption, menuOptions[selectedOption].text
end

-- Clear background when starting new game
function Menu.clearBackground()
    BackgroundMap.clear()
end

return Menu
