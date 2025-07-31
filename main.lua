-- ASCII Roguelike using Love2D
-- Main game file

-- global imports
Logger = require("game.ui.logger")

-- Import game modules
local Room = require("game.room")
local Player = require("game.player")
local UI = require("game.ui")

function love.load()
    -- Set up the game window
    love.window.setTitle("ASCII Roguelike")
    
    -- Try to load a monospace font for ASCII art
    -- Using White Rabbit font - perfect for roguelikes!
    local fontSize = 16
    
    -- Load the White Rabbit font (whitrabt.ttf)
    local fontPath = "assets/fonts/whitrabt.ttf"
    if love.filesystem.getInfo(fontPath) then
        font = love.graphics.newFont(fontPath, fontSize)
        print("Loaded White Rabbit font successfully!")
    else
        -- Fallback to system font if White Rabbit isn't found
        font = love.graphics.newFont(fontSize)
        print("White Rabbit font not found, using system font")
    end
    
    love.graphics.setFont(font)
    
    -- Calculate character dimensions for grid-based ASCII display
    local testChar = "M" -- Use 'M' as it's typically the widest character
    charWidth = font:getWidth(testChar)
    charHeight = font:getHeight()
    
    -- Set up game grid dimensions
    local windowWidth = 1024
    local windowHeight = 768
    love.window.setMode(windowWidth, windowHeight)
    
    gridWidth = math.floor(windowWidth / charWidth)
    gridHeight = math.floor(windowHeight / charHeight)
    
    -- Initialize UI system and get adjusted game area dimensions
    local gameAreaWidth, gameAreaHeight = UI.init(gridWidth, gridHeight, charWidth, charHeight)
    
    -- Set up UI reference for Player module
    Player.setUI(UI)
    
    -- Initialize game state with solid walls everywhere
    gameGrid = {}
    for y = 1, gridHeight do
        gameGrid[y] = {}
        for x = 1, gridWidth do
            gameGrid[y][x] = {char = "#", color = {0.4, 0.4, 0.4}, walkable = false} -- Dark gray walls
        end
    end
    
    -- Generate the room layout using the Room module (only in game area)
    Room.generateDefaultLayout(gameGrid, gameAreaWidth, gameAreaHeight)
    
    -- Create and position the player using the Player module
    local startX, startY = Room.findPlayerStartPosition(gameGrid, gameAreaWidth, gameAreaHeight)
    player = Player.new(startX, startY, 10)
    Player.placeOnGrid(player, gameGrid)
end

function love.update(dt)
    -- Game update logic will go here
end

function love.draw()
    -- Clear screen with black background
    love.graphics.clear(0, 0, 0, 1)
    
    -- Draw the UI (this modifies the gameGrid to include UI elements)
    UI.draw(gameGrid, player)
    
    -- Draw the ASCII grid (including game area and UI)
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local cell = gameGrid[y][x]
            if cell and cell.char and cell.char ~= " " then  -- Don't render space characters
                love.graphics.setColor(cell.color)
                love.graphics.print(cell.char, (x-1) * charWidth, (y-1) * charHeight)
            end
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    -- Handle system keys
    if key == "escape" then
        love.event.quit()
        return
    end
    
    -- Test keys for health bar (temporary)
    if key == "h" then
        Player.heal(player, 1)  -- Heal 1 HP with 'h' key
        return
    elseif key == "j" then
        Player.takeDamage(player, 1)  -- Take 1 damage with 'j' key
        return
    end
    
    -- Handle player movement using Player module (constrained to game area)
    local gameAreaWidth, gameAreaHeight = UI.getGameAreaDimensions()
    Player.handleMovement(player, key, gameGrid, gameAreaWidth, gameAreaHeight)
end
