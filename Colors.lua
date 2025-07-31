-- Colors module for ASCII Roguelike
-- Defines color palettes and markup parsing for colored text
local Colors = {}

-- Predefined color palette
Colors.palette = {
    -- Basic colors
    red = {1, 0.2, 0.2},
    green = {0.2, 0.8, 0.2},
    blue = {0.2, 0.4, 1},
    yellow = {1, 1, 0.3},
    cyan = {0.2, 0.8, 0.8},
    magenta = {1, 0.2, 1},
    white = {1, 1, 1},
    black = {0, 0, 0},
    gray = {0.5, 0.5, 0.5},
    
    -- Game-specific colors
    health = {0, 0.8, 0},      -- Green for health
    damage = {0.8, 0.2, 0.2},  -- Red for damage
    heal = {0.2, 1, 0.4},      -- Bright green for healing
    warning = {1, 0.8, 0.2},   -- Orange for warnings
    error = {1, 0.3, 0.3},     -- Bright red for errors
    info = {0.6, 0.8, 1},      -- Light blue for info
    gold = {1, 0.8, 0.2},      -- Gold for valuable items
    silver = {0.8, 0.8, 0.9},  -- Silver for items
    
    -- UI colors
    border = {0.7, 0.7, 0.7},  -- Gray for borders
    background = {0.1, 0.1, 0.1}, -- Dark background
    text = {0.9, 0.9, 0.9},    -- Light gray for normal text
    
    -- Player/Entity colors
    player = {1, 1, 0},        -- Yellow for player
    enemy = {1, 0.3, 0.3},     -- Red for enemies
    npc = {0.3, 0.8, 1},       -- Light blue for NPCs
    item = {0.8, 0.6, 1},      -- Purple for items
}

-- Parse markup text and return segments with colors
-- Input: "[red]Hello[/red] [blue]world[/blue]!"
-- Output: {{text="Hello", color={1,0.2,0.2}}, {text=" ", color=nil}, {text="world", color={0.2,0.4,1}}, {text="!", color=nil}}
function Colors.parseMarkup(text, defaultColor)
    defaultColor = defaultColor or Colors.palette.text
    local segments = {}
    local pos = 1
    
    while pos <= #text do
        -- Look for opening tag [colorname]
        local tagStart, tagEnd, colorName = text:find("%[([%w_]+)%]", pos)
        
        if tagStart then
            -- Add any text before the tag
            if tagStart > pos then
                local beforeText = text:sub(pos, tagStart - 1)
                table.insert(segments, {text = beforeText, color = defaultColor})
            end
            
            -- Find closing tag [/colorname]
            local closeTag = "%[/" .. colorName .. "%]"
            local closeStart, closeEnd = text:find(closeTag, tagEnd + 1)
            
            if closeStart then
                -- Extract colored text
                local coloredText = text:sub(tagEnd + 1, closeStart - 1)
                local color = Colors.palette[colorName] or defaultColor
                table.insert(segments, {text = coloredText, color = color})
                pos = closeEnd + 1
            else
                -- No closing tag found, treat as normal text
                table.insert(segments, {text = text:sub(tagStart, tagEnd), color = defaultColor})
                pos = tagEnd + 1
            end
        else
            -- No more tags, add remaining text
            local remainingText = text:sub(pos)
            if #remainingText > 0 then
                table.insert(segments, {text = remainingText, color = defaultColor})
            end
            break
        end
    end
    
    -- If no segments were created, add the whole text with default color
    if #segments == 0 then
        table.insert(segments, {text = text, color = defaultColor})
    end
    
    return segments
end

-- Get a color by name, with fallback
function Colors.get(colorName, fallback)
    return Colors.palette[colorName] or fallback or Colors.palette.text
end

-- Add a new color to the palette
function Colors.add(name, r, g, b)
    Colors.palette[name] = {r, g, b}
end

-- Create a color from RGB values (0-255)
function Colors.fromRGB(r, g, b)
    return {r/255, g/255, b/255}
end

-- Create a color from hex string (#RRGGBB or RRGGBB)
function Colors.fromHex(hex)
    hex = hex:gsub("#", "")
    if #hex ~= 6 then
        return Colors.palette.text -- fallback
    end
    
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    
    return {r, g, b}
end

return Colors
