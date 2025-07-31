-- ASCII Roguelike using Love2D
-- Main game file

-- global imports
Logger = require("game.ui.logger")

-- Import game modules
local Fonts = require("fonts")
local AsciiGrid = require("asciiGrid")
local Room = require("game.room")
local Player = require("game.player")
local Enemy = require("game.enemy")
local UI = require("game.ui")
local MapGenerator = require("game.mapGenerator")
local Controls = require("game.controls")
local Menu = require("game.menu")
local GameState = require("game.gameState")

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
    
    -- Calculate initial grid dimensions for UI system
    local tempGridWidth = math.floor(windowWidth / charWidth)
    local tempGridHeight = math.floor(windowHeight / charHeight)
    
    -- Initialize ASCII grid system (full screen for menu)
    gameGrid, gridWidth, gridHeight = AsciiGrid.init(windowWidth, windowHeight, charWidth, charHeight, tempGridWidth, tempGridHeight)
    
    -- Initialize game state and menu
    GameState.init()
    Menu.init()
    
    -- Game variables (will be initialized when starting new game)
    player = nil
    gameAreaWidth = nil
    gameAreaHeight = nil
end

function love.update(dt)
    -- Game update logic will go here
end

function love.draw()
    -- Clear screen with black background
    love.graphics.clear(0, 0, 0, 1)
    
    if GameState.isMenu() then
        -- Draw menu
        Menu.draw(gameGrid, gridWidth, gridHeight)
    elseif GameState.isPlaying() then
        -- Draw the UI (this modifies the gameGrid to include UI elements)
        UI.draw(gameGrid, player)
    end
    
    -- Draw the ASCII grid using the AsciiGrid module
    AsciiGrid.draw()
end

function love.keypressed(key)
    if GameState.isMenu() then
        -- Handle menu input
        local result = Menu.handleInput(key)
        if result == "new_game" then
            startNewGame()
        elseif result == "quit" then
            love.event.quit()
        end
    elseif GameState.isPlaying() then
        -- Delegate all keyboard handling to the Controls module
        Controls.handleKeypress(key, player, gameGrid)
    end
end

function startNewGame()
    -- Initialize UI system and get adjusted game area dimensions
    gameAreaWidth, gameAreaHeight = UI.init(gridWidth, gridHeight, charWidth, charHeight)
    
    -- Reinitialize ASCII grid system with game area boundaries
    gameGrid, gridWidth, gridHeight = AsciiGrid.init(love.graphics.getWidth(), love.graphics.getHeight(), charWidth, charHeight, gameAreaWidth, gameAreaHeight)
    
    -- Set up UI reference for Player and Enemy modules
    Player.setUI(UI)
    Enemy.setUI(UI)
    
    -- Generate the room layout using the MapGenerator module (only in game area)
    MapGenerator.generate(gameGrid, gameAreaWidth, gameAreaHeight)
    
    -- Create and position the player using the Player module
    local startX, startY = Room.findPlayerStartPosition(gameGrid, gameAreaWidth, gameAreaHeight)
    player = Player.new(startX, startY, 10)
    Player.placeOnGrid(player, gameGrid)
    
    -- Spawn some enemies
    Enemy.spawnRandom(gameGrid, gameAreaWidth, gameAreaHeight, 3, "goblin")
    Enemy.spawnRandom(gameGrid, gameAreaWidth, gameAreaHeight, 2, "orc")
    Enemy.spawnRandom(gameGrid, gameAreaWidth, gameAreaHeight, 2, "skeleton")
    
    -- Add welcome messages with color markup
    Logger.log("[gold]Welcome to ASCII Roguelike![/gold]")
    Logger.log("[warning]Enemies have appeared![/warning]")
    
    -- Switch to playing state
    GameState.setState(GameState.STATES.PLAYING)
end
