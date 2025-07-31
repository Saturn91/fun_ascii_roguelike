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
    
    -- Set up UI reference for Player and Enemy modules
    Player.setUI(UI)
    Enemy.setUI(UI)
    
    -- Generate the room layout using the Room module (only in game area)
    Room.generateDefaultLayout(gameGrid, gameAreaWidth, gameAreaHeight)
    
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
    local playerMoved = Player.handleMovement(player, key, gameGrid, gameAreaWidth, gameAreaHeight)
    
    -- If player moved or took an action, update enemies
    if playerMoved then
        Enemy.updateAll(player, gameGrid, gameAreaWidth, gameAreaHeight)
        
        -- Check if player died
        if not Player.isAlive(player) then
            Logger.log("[error]Game Over! You have died![/error]")
            Logger.log("[info]Press Escape to quit[/info]")
        end
        
        -- Check victory condition
        if Enemy.getTotalCount() == 0 then
            Logger.log("[success]Victory! All enemies defeated![/success]")
            Logger.log("[info]Press Escape to quit[/info]")
        end
    end
end
