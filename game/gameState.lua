-- Game State module for ASCII Roguelike
-- Manages different game states (menu, playing, etc.)
local GameState = {}

-- Game states
local states = {
    MENU = "menu",
    PLAYING = "playing",
    PAUSED = "paused"
}

-- Current state
local currentState = states.MENU

-- Initialize game state
function GameState.init()
    currentState = states.MENU
end

-- Get current state
function GameState.getCurrentState()
    return currentState
end

-- Set current state
function GameState.setState(newState)
    currentState = newState
end

-- Check if in specific state
function GameState.isMenu()
    return currentState == states.MENU
end

function GameState.isPlaying()
    return currentState == states.PLAYING
end

function GameState.isPaused()
    return currentState == states.PAUSED
end

-- Export states
GameState.STATES = states

return GameState
