-- Controls module for ASCII Roguelike
-- Displays game controls and keybindings
local Controls = {}

-- Draw the controls section
function Controls.draw(gameGrid, controlsArea)
    if not gameGrid or not controlsArea then
        return
    end
    
    -- Draw "CONTROLS" title
    local titleY = controlsArea.y - 1
    local titleText = "CONTROLS"
    local startX = controlsArea.x + math.floor((controlsArea.width - #titleText) / 2)
    
    for i = 1, #titleText do
        local x = startX + i - 1
        if titleY <= #gameGrid and x <= #gameGrid[titleY] then
            gameGrid[titleY][x] = {
                char = titleText:sub(i, i),
                color = {0.8, 0.6, 1},  -- Light purple for controls title
                walkable = false
            }
        end
    end
    
    -- Define control instructions
    local controlLines = {
        "Movement:",
        "  Arrows - Move",
        "",
        "Tabs:",
        "  P - Player",
        "  I - Inventory",
        "  S - Stats",
        "",
        "System:",
        "  ESC - Pause Game"
    }
    
    -- Draw control lines
    for i, line in ipairs(controlLines) do
        local y = controlsArea.y + i - 1
        if y <= controlsArea.y + controlsArea.height - 1 then
            for j = 1, math.min(#line, controlsArea.width) do
                local x = controlsArea.x + j - 1
                if y <= #gameGrid and x <= #gameGrid[y] then
                    local color
                    if line:match("^%s*%w+ ?%-") then
                        -- Key bindings (indented lines with dashes)
                        color = {0.7, 0.9, 0.7}  -- Light green for key bindings
                    elseif line:match(":$") then
                        -- Category headers (ending with colon)
                        color = {1, 1, 0.7}  -- Light yellow for categories
                    else
                        -- Default text
                        color = {0.8, 0.8, 0.9}  -- Light blue-gray
                    end
                    
                    gameGrid[y][x] = {
                        char = line:sub(j, j),
                        color = color,
                        walkable = false
                    }
                end
            end
        end
    end
end

return Controls
