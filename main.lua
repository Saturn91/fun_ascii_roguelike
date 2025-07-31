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
    
    -- Initialize UI system and get adjusted game area dimensions
    local gameAreaWidth, gameAreaHeight = UI.init(tempGridWidth, tempGridHeight, charWidth, charHeight)
    
    -- Initialize ASCII grid system with game area boundaries
    gameGrid, gridWidth, gridHeight = AsciiGrid.init(windowWidth, windowHeight, charWidth, charHeight, gameAreaWidth, gameAreaHeight)
    
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
    -- Delegate all keyboard handling to the Controls module
    Controls.handleKeypress(key, player, gameGrid)
end
