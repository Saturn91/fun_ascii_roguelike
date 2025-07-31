-- Title section module for ASCII Roguelike UI
local TitleSection = {}

-- Draw the title section content
function TitleSection.draw(gameGrid, titleArea)
    local titleLines = {
        "",
        "ASCII ROGUELIKE",
        "---------------",
        "Version: 1.0.0",
        "",
        "Made by:",
        "Saturn91.dev"
    }
    
    local colors = {
        {0.9, 0.9, 0.9},  -- White for empty line
        {1, 0.8, 0.2},    -- Gold for title
        {0.7, 0.7, 0.7},  -- Gray for underline
        {0.6, 0.8, 1},    -- Light blue for version
        {0.9, 0.9, 0.9},  -- White for empty line
        {0.9, 0.9, 0.9},  -- White for "Made by:"
        {0.8, 1, 0.8}     -- Light green for author
    }
    
    for i, line in ipairs(titleLines) do
        local y = titleArea.y + i - 1
        if y <= titleArea.y + titleArea.height - 1 then
            -- Center all title lines
            local startX = titleArea.x + math.floor((titleArea.width - #line) / 2)
            
            for j = 1, math.min(#line, titleArea.width) do
                local x = startX + j - 1
                if y <= #gameGrid and x <= #gameGrid[y] then
                    local color = colors[i] or {0.9, 0.9, 0.9}  -- Default to white if color not defined
                    
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
