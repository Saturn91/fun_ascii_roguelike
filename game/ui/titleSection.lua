-- Title section module for ASCII Roguelike UI
local TitleSection = {}

-- Import Colors module
local Colors = require("Colors")

-- Draw the title section content
function TitleSection.draw(gameGrid, titleArea)
    local titleLines = {
        "",
        "ASCII ROGUELIKE",
        "---------------",
        "Version: " .. VERSION,
        "",
        "Made by:",
        "Saturn91.dev"
    }
    
    local colors = {
        Colors.palette.text,
        Colors.palette.gold,
        Colors.palette.lightgray,
        Colors.palette.info,
        Colors.palette.text,
        Colors.palette.text,
        Colors.palette.heal
    }
    
    for i, line in ipairs(titleLines) do
        local y = titleArea.y + i - 1
        if y <= titleArea.y + titleArea.height - 1 then
            -- Center all title lines
            local startX = titleArea.x + math.floor((titleArea.width - #line) / 2)
            
            for j = 1, math.min(#line, titleArea.width) do
                local x = startX + j - 1
                if y <= #gameGrid and x <= #gameGrid[y] then
                    local color = colors[i] or Colors.palette.text  -- Default to text color if not defined
                    
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

return TitleSection
