-- Font management module for ASCII Roguelike
-- Loads the bundled DejaVu Sans Mono font
local Fonts = {}

-- Font configuration - we bundle DejaVu Sans Mono for reliable Unicode support
local FONT_PATH = "assets/fonts/DejaVuSansMono.ttf"
local FONT_NAME = "DejaVu Sans Mono"

-- Module state
local currentFont = nil
local charWidth = 0
local charHeight = 0

-- Initialize the font system
function Fonts.init(fontSize)
    fontSize = fontSize or 12
    
    -- Load our bundled DejaVu Sans Mono font
    currentFont = love.graphics.newFont(FONT_PATH, fontSize)
    print("Loaded bundled font: " .. FONT_NAME)
    
    -- Set as active font and calculate character dimensions
    love.graphics.setFont(currentFont)
    local testChar = "M" -- Use 'M' as it's typically the widest character
    charWidth = currentFont:getWidth(testChar)
    charHeight = currentFont:getHeight()
    
    return currentFont, FONT_NAME, charWidth, charHeight
end

-- Get current font information
function Fonts.getCurrentFont()
    return currentFont, FONT_NAME
end

-- Get character dimensions
function Fonts.getCharacterDimensions()
    return charWidth, charHeight
end

-- Test if current font supports specific Unicode characters
function Fonts.testUnicodeSupport(characters)
    if not currentFont then
        return {}
    end
    
    characters = characters or {"█", "░", "▓", "▒"} -- Common block characters
    local supported = {}
    
    for _, char in ipairs(characters) do
        -- Test by checking if the character width is reasonable
        local width = currentFont:getWidth(char)
        supported[char] = width > 0
    end
    
    return supported
end

-- Get detailed font info for debugging
function Fonts.getFontInfo()
    if not currentFont then
        return "No font loaded"
    end
    
    local info = {
        name = FONT_NAME,
        height = currentFont:getHeight(),
        baseline = currentFont:getBaseline(),
        ascent = currentFont:getAscent(),
        descent = currentFont:getDescent(),
        lineHeight = currentFont:getLineHeight(),
        charWidth = charWidth,
        charHeight = charHeight
    }
    
    return info
end

return Fonts
