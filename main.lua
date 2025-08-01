-- ASCII Roguelike using Love2D
-- Main game file

-- global imports
Log = require("game.ui.Logger")

-- Import game modules
local Fonts = require("fonts")
local AsciiGrid = require("asciiGrid")
local Room = require("game.room")
local Player = require("game.player")
local Enemy = require("game.enemy")
local UI = require("game.ui")
local MapGenerator = require("game.mapGenerator")
local Controls = require("game.controls")
local Menu = require("menu.menu")
local GameState = require("game.gameState")
local PauseMenu = require("menu.pauseMenu")
local GameOverScreen = require("menu.gameOverScreen")
require("util._index")
require("sandbox/Sandbox")
Sandbox.init()

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
        -- Draw menu with dynamic background
        Menu.draw(gameGrid, gridWidth, gridHeight, love.timer.getDelta())
    elseif GameState.isPlaying() then
        -- Draw the UI (this modifies the gameGrid to include UI elements)
        UI.draw(gameGrid, player)
    elseif GameState.isPaused() then
        -- First draw the game as it was when paused
        UI.draw(gameGrid, player)
    elseif GameState.isGameOver() then
        -- First draw the game as it was when player died
        UI.draw(gameGrid, player)
    end
    
    -- Draw the ASCII grid
    AsciiGrid.draw()
    
    -- If paused, draw the Love2D overlay on top
    if GameState.isPaused() then
        PauseMenu.draw(gridWidth, gridHeight)
    elseif GameState.isGameOver() then
        GameOverScreen.draw(gridWidth, gridHeight)
    end
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
    elseif GameState.isPlaying() or GameState.isPaused() or GameState.isGameOver() then
        -- Delegate all keyboard handling to the Controls module
        local result = Controls.handleKeypress(key, player, gameGrid)
        
        -- Handle special results from pause menu or game over screen
        if result == "new_game" then
            startNewGame()
        elseif result == "main_menu" then
            returnToMainMenu()
        end
    end
end

function startNewGame()
    -- Clear menu background before starting game
    Menu.clearBackground()
    
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
    Log.log("[gold]Welcome to ASCII Roguelike![/gold]")
    Log.log("[warning]Enemies have appeared![/warning]")
    
    -- Initialize game statistics
    Controls.initGameStats()
    
    -- Switch to playing state
    GameState.setState(GameState.STATES.PLAYING)
end

function returnToMainMenu()
    -- Clear game state
    player = nil
    gameAreaWidth = nil
    gameAreaHeight = nil
    
    -- Clear any enemies
    Enemy.clear()
    
    -- Reinitialize menu
    Menu.init()
    
    -- Reinitialize ASCII grid system for menu (full screen)
    gameGrid, gridWidth, gridHeight = AsciiGrid.init(love.graphics.getWidth(), love.graphics.getHeight(), charWidth, charHeight, math.floor(love.graphics.getWidth() / charWidth), math.floor(love.graphics.getHeight() / charHeight))
    
    -- Switch to menu state
    GameState.setState(GameState.STATES.MENU)
end
