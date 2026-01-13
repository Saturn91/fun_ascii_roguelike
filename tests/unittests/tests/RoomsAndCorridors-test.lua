RoomsAndCorridors = require("mapgenerators.generators.RoomsAndCorridors")
MapDefinition = require("mapgenerators.mapdefinition")

function run(test)
    
    test.newSection("RoomsAndCorridors Generator Tests")
    
    local map = RoomsAndCorridors.generate(20, 15)
    
    test.assert_equal(20, map.width, "Map width should be correct")
    test.assert_equal(15, map.height, "Map height should be correct")
    test.assert_equal("table", type(map.tileMap), "Should have tileMap")
    test.assert_equal("table", type(map.walkable), "Should have walkable map")
    test.assert_equal("table", type(map.options.rooms), "Should have rooms data")
    
    test.assert_equal(3, #map.tileDefinitions, "Should have 3 tile definitions")
    test.assert_equal(".", map.tileDefinitions[1].glyph, "Floor tile should be '.'")
    test.assert_equal("█", map.tileDefinitions[2].glyph, "Wall tile should be '█'")
    test.assert_equal(" ", map.tileDefinitions[3].glyph, "Empty tile should be ' '")
    
    test.assert_equal("floor", map.tileIds[1], "Floor tile ID should be correct")
    test.assert_equal("wall", map.tileIds[2], "Wall tile ID should be correct")
    test.assert_equal("empty", map.tileIds[3], "Empty tile ID should be correct")
    
    local hasFloors = false
    local hasWalls = false
    local hasEmpty = false
    
    for y = 1, map.height do
        for x = 1, map.width do
            local tileType = map.tileMap[y][x]
            if tileType == 1 then hasFloors = true end
            if tileType == 2 then hasWalls = true end
            if tileType == 3 then hasEmpty = true end
        end
    end
    
    test.assert_equal(true, hasFloors, "Map should have floor tiles")
    test.assert_equal(true, hasWalls, "Map should have wall tiles")
    test.assert_equal(true, hasEmpty, "Map should have empty space")
    
    test.assert_equal(true, #map.options.rooms > 0, "Should generate at least one room")
    
    for _, room in ipairs(map.options.rooms) do
        test.assert_equal("number", type(room.x), "Room should have x coordinate")
        test.assert_equal("number", type(room.y), "Room should have y coordinate")
        test.assert_equal("number", type(room.width), "Room should have width")
        test.assert_equal("number", type(room.height), "Room should have height")
        test.assert_equal("number", type(room.centerX), "Room should have centerX")
        test.assert_equal("number", type(room.centerY), "Room should have centerY")
    end
    
    test.newSection("RoomsAndCorridors Utility Function Tests")
    
    local walkable1 = RoomsAndCorridors.initializeWalkableMap(5, 3)
    test.assert_equal(3, #walkable1, "Should create correct height")
    test.assert_equal(5, #walkable1[1], "Should create correct width")
    test.assert_equal(false, walkable1[1][1], "Should initialize as non-walkable")
    
    local tileMap1 = RoomsAndCorridors.initializeTileMap(4, 2)
    test.assert_equal(2, #tileMap1, "Should create correct height")
    test.assert_equal(4, #tileMap1[1], "Should create correct width")
    test.assert_equal(3, tileMap1[1][1], "Should initialize as empty space")
    
    local room1 = {x = 1, y = 1, width = 3, height = 3}
    local room2 = {x = 10, y = 1, width = 3, height = 3}
    local room3 = {x = 2, y = 2, width = 3, height = 3}
    
    test.assert_equal(false, RoomsAndCorridors.roomsOverlap(room1, room2), "Non-overlapping rooms should not overlap")
    test.assert_equal(true, RoomsAndCorridors.roomsOverlap(room1, room3), "Overlapping rooms should overlap")
    
    local distance = RoomsAndCorridors.calculateRoomDistance(
        {centerX = 0, centerY = 0},
        {centerX = 3, centerY = 4}
    )
    test.assert_equal(5, distance, "Distance calculation should be correct")
    
end

return run
