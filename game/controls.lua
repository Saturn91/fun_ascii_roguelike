-- Controls module for ASCII Roguelike
-- Handles all keyboard input and game controls
local Controls = {}

-- Import required modules
local Player = require("game.player")
local Enemy = require("game.enemy")
local UI = require("game.ui")
local Logger = require("game.ui.logger")
local GameState = require("game.gameState")
local PauseMenu = require("game.pauseMenu")
local GameOverScreen = require("game.gameOverScreen")

-- Game statistics tracking
local gameStartTime = nil

-- Handle all keyboard input for the game
function Controls.handleKeypress(key, player, gameGrid)
    -- Handle game state specific controls
    if GameState.isPlaying() then
        return Controls.handlePlayingInput(key, player, gameGrid)
    elseif GameState.isPaused() then
        return Controls.handlePauseInput(key)
    elseif GameState.isGameOver() then
        return Controls.handleGameOverInput(key)
    end
end

-- Handle input during gameplay
function Controls.handlePlayingInput(key, player, gameGrid)
    -- Handle system keys
    if key == "escape" then
        GameState.setState(GameState.STATES.PAUSED)
        PauseMenu.init()
        Logger.log("[info]Game paused[/info]")
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
            Controls.triggerGameOver("Combat")
            return
        end
        
        -- Check victory condition
        if Enemy.getTotalCount() == 0 then
            Logger.log("[success]Victory! All enemies defeated![/success]")
            Logger.log("[info]Press Escape to quit[/info]")
        end
    end
end

-- Handle input during pause menu
function Controls.handlePauseInput(key)
    local action = PauseMenu.handleInput(key)
    
    if action == "resume" then
        GameState.setState(GameState.STATES.PLAYING)
        Logger.log("[info]Game resumed[/info]")
    elseif action == "new_game" then
        -- Start a new game
        GameState.setState(GameState.STATES.PLAYING)
        Logger.log("[success]Starting new game![/success]")
        return "new_game"  -- Signal to main.lua to restart
    elseif action == "main_menu" then
        GameState.setState(GameState.STATES.MENU)
        Logger.log("[info]Returning to main menu[/info]")
        return "main_menu"  -- Signal to main.lua to reset
    elseif action == "quit" then
        love.event.quit()
    end
end

-- Handle input during game over screen
function Controls.handleGameOverInput(key)
    local action = GameOverScreen.handleInput(key)
    
    if action == "retry" then
        GameState.setState(GameState.STATES.PLAYING)
        Logger.log("[success]Starting new game![/success]")
        return "new_game"  -- Signal to main.lua to restart
    elseif action == "main_menu" then
        GameState.setState(GameState.STATES.MENU)
        Logger.log("[info]Returning to main menu[/info]")
        return "main_menu"  -- Signal to main.lua to reset
    elseif action == "quit" then
        love.event.quit()
    end
end

-- Trigger game over with cause
function Controls.triggerGameOver(cause)
    local timeAlive = Controls.getGameTime()
    local stats = {
        enemiesKilled = Enemy.getKillCount(),
        timeAlive = timeAlive,
        cause = cause or "Unknown"
    }
    
    GameOverScreen.init(stats)
    GameState.setState(GameState.STATES.GAME_OVER)
    Logger.log("[error]Game Over! Cause: " .. cause .. "[/error]")
end

-- Initialize game statistics
function Controls.initGameStats()
    gameStartTime = love.timer.getTime()
    Enemy.resetKillCount()
end

-- Get formatted game time
function Controls.getGameTime()
    if not gameStartTime then
        return "00:00"
    end
    
    local elapsed = love.timer.getTime() - gameStartTime
    local minutes = math.floor(elapsed / 60)
    local seconds = math.floor(elapsed % 60)
    return string.format("%02d:%02d", minutes, seconds)
end

return Controls
