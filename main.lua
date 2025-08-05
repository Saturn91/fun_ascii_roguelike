-- ASCII Roguelike using Love2D
-- Main game file

-- Global version constant
VERSION = "1.0.0"

-- global imports
Log = require("game.ui.Logger")

-- Import game modules
Colors = require("Colors")
local Fonts = require("fonts")
local AsciiEngine = require("asciiEngine.engine")
local AsciiGrid = require("asciiEngine.asciiGrid")
local GridAdapter = require("gridAdapter")
local Game = require("game.__index")
local UI = require("game.ui")
local Controls = require("game.controls")
local GameOverScreen = require("menu.gameOverScreen")

require("util._index")
require("sandbox/Sandbox")
Sandbox.init()

-- ASCII Engine variables
local engine = nil
local grid = nil
local gameGrid = nil -- Compatibility grid adapter

function love.load()
     Log.log("[gold]Welcome human![/gold] Lets get started")

    -- Initialize configuration manager first
    ConfigManager.load()
    
    -- Initialize font system
    font, fontName, charWidth, charHeight = Fonts.init(12)
    
    -- Set up game grid dimensions
    local windowWidth = 1024
    local windowHeight = 768
    love.window.setMode(windowWidth, windowHeight, {resizable = true})
    
    -- Calculate grid dimensions for the ASCII engine
    local tempGridWidth = math.floor(windowWidth / charWidth)
    local tempGridHeight = math.floor(windowHeight / charHeight)
    
    -- Initialize ASCII Engine with calculated font
    engine = AsciiEngine:new({
        gridCols = 146,
        gridRows = 54,
        font = love.graphics.newFont("assets/fonts/Ac437_IBM_BIOS.ttf", 240)
    })

    -- Create and add a grid layer
    grid = AsciiGrid:new()
    engine:addLayer(grid)
    
    -- Create compatibility grid adapter
    gameGrid = GridAdapter:new(grid, engine)
    
    -- Calculate initial scaling
    engine:calculateScaling()
    
    -- Store engine references globally for other modules
    _G.asciiEngine = engine
    _G.asciiGrid = grid
    _G.gameGrid = gameGrid -- Make gameGrid global for backward compatibility
    
    -- Get grid dimensions from engine and make them global
    gridWidth, gridHeight = engine:getGridSize()
    _G.gridWidth = gridWidth
    _G.gridHeight = gridHeight
    
    -- Initialize game state and menu
    Game.init()
    
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
    
    -- Clear the grid first
    gameGrid:clear()
    
    if GameState.isMenu() then
        -- Draw menu with dynamic background
        Menu.draw(gameGrid, gridWidth, gridHeight, love.timer.getDelta())
    elseif GameState.isPlaying() then
        -- Draw the UI (this modifies the grid to include UI elements)
        UI.draw(gameGrid, player)
    elseif GameState.isPaused() then
        -- First draw the game as it was when paused
        UI.draw(gameGrid, player)
    elseif GameState.isGameOver() then
        -- First draw the game as it was when player died
        UI.draw(gameGrid, player)
    end
    
    -- Draw the ASCII engine (includes all layers)
    engine:draw()
    
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
    -- Clear any previous log messages
    Log.clear()
    
    -- Clear menu background before starting game
    Menu.clearBackground()
    
    -- Clear the grid
    gameGrid:clear()
    
    -- Initialize UI system and get adjusted game area dimensions
    gameAreaWidth, gameAreaHeight = UI.init(gridWidth, gridHeight, charWidth, charHeight)
    
    -- Set up UI reference for Player and Enemy modules
    Player.setUI(UI)
    Enemy.setUI(UI)
    
    -- Generate the room layout using the MapGenerator module (only in game area)
    MapGenerator.generate(gameGrid, gameAreaWidth, gameAreaHeight)
    
    -- Create and position the player using the Player module
    local startX, startY = Room.findPlayerStartPosition(gameGrid, gameAreaWidth, gameAreaHeight)
    player = Player.new(startX, startY) -- Use default health from config
    player:placeOnGrid(gameGrid)
    
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
    
    -- Clear the grid
    gameGrid:clear()
    
    -- Reinitialize menu
    Menu.init()
    
    -- Switch to menu state
    GameState.setState(GameState.STATES.MENU)
end

function love.resize(w, h)
    -- Recalculate engine scaling when window is resized
    if engine then
        engine:resize()
    end
end
