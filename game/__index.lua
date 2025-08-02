InventoryController = require("game.inventoryController")
Creature = require("game.creatures.creature")
Player = require("game.creatures.player")
Enemy = require("game.creatures.enemy")
MapGenerator = require("game.mapGenerator")
GameState = require("game.gameState")
PauseMenu = require("menu.pauseMenu")
ConfigManager = require("game.configManager")
Room = require("game.room")
Dice = require("game.dice")
itemManager = require("game.items.itemManager")
Menu = require("menu.menu")

local Game = {}

function Game.init()
    GameState.init()
    Menu.init()
    itemManager.init()
end

return Game