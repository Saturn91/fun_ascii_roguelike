-- Controls module for ASCII Roguelike
-- Handles all keyboard input and game controls
local Controls = {}

-- Import required modules
local Player = require("game.player")
local Enemy = require("game.enemy")
local UI = require("game.ui")
local Logger = require("game.ui.logger")

-- Handle all keyboard input for the game
function Controls.handleKeypress(key, player, gameGrid)
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

return Controls
