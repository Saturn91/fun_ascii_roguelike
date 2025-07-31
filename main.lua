-- ASCII Roguelike using Love2D
-- Main game file

-- global imports
Logger = require("game.ui.logger")

-- Import game modules
local Fonts = require("fonts")
local AsciiGrid = require("asciiGrid")
local Room = require("game.room")
local Player = require("game.player")
local UI = require("game.ui")

function love.load()
    -- Set up the game window
    love.window.setTitle("ASCII Roguelike")
    
    -- Initialize font system
    local fontSize = 12
    font, fontName, charWidth, charHeight = Fonts.init(fontSize)
    
    -- Set up game grid dimensions
    local windowWidth = 1024
    local windowHeight = 768
    love.window.setMode(windowWidth, windowHeight)
    
    -- Initialize ASCII grid system
    gameGrid, gridWidth, gridHeight = AsciiGrid.init(windowWidth, windowHeight, charWidth, charHeight)
    
    -- Initialize UI system and get adjusted game area dimensions
    local gameAreaWidth, gameAreaHeight = UI.init(gridWidth, gridHeight, charWidth, charHeight)
    
    -- Set up UI reference for Player module
    Player.setUI(UI)
    
    -- Generate the room layout using the Room module (only in game area)
    Room.generateDefaultLayout(gameGrid, gameAreaWidth, gameAreaHeight)
    
    -- Create and position the player using the Player module
    local startX, startY = Room.findPlayerStartPosition(gameGrid, gameAreaWidth, gameAreaHeight)
    player = Player.new(startX, startY, 10)
    Player.placeOnGrid(player, gameGrid)
    
    -- Add welcome messages with color markup
    Logger.log("[gold]Welcome to ASCII Roguelike![/gold]")
end

function love.update(dt)
    -- Game update logic will go here
end

function love.draw()
    -- Clear screen with black background
    love.graphics.clear(0, 0, 0, 1)
    
    -- Draw the UI (this modifies the gameGrid to include UI elements)
    UI.draw(gameGrid, player)
    
    -- Draw the ASCII grid using the AsciiGrid module
    AsciiGrid.draw()
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
