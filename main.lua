-- ASCII Roguelike using Love2D
-- Main game file

function love.load()
    -- Set up the game window
    love.window.setTitle("ASCII Roguelike")
    
    -- Try to load a monospace font for ASCII art
    -- Using White Rabbit font - perfect for roguelikes!
    local fontSize = 16
    
    -- Load the White Rabbit font (whitrabt.ttf)
    local fontPath = "assets/fonts/whitrabt.ttf"
    if love.filesystem.getInfo(fontPath) then
        font = love.graphics.newFont(fontPath, fontSize)
        print("Loaded White Rabbit font successfully!")
    else
        -- Fallback to system font if White Rabbit isn't found
        font = love.graphics.newFont(fontSize)
        print("White Rabbit font not found, using system font")
    end
    
    love.graphics.setFont(font)
    
    -- Calculate character dimensions for grid-based ASCII display
    local testChar = "M" -- Use 'M' as it's typically the widest character
    charWidth = font:getWidth(testChar)
    charHeight = font:getHeight()
    
    -- Set up game grid dimensions
    local windowWidth = 1024
    local windowHeight = 768
    love.window.setMode(windowWidth, windowHeight)
    
    gridWidth = math.floor(windowWidth / charWidth)
    gridHeight = math.floor(windowHeight / charHeight)
    
    -- Initialize game state
    gameGrid = {}
    for y = 1, gridHeight do
        gameGrid[y] = {}
        for x = 1, gridWidth do
            gameGrid[y][x] = {char = ".", color = {1, 1, 1}} -- Default to white dots
        end
    end
    
    -- Player position
    player = {x = math.floor(gridWidth/2), y = math.floor(gridHeight/2)}
    gameGrid[player.y][player.x] = {char = "@", color = {1, 1, 0}} -- Yellow player
    
    print("Font loaded: " .. font:getFilter())
    print("Character dimensions: " .. charWidth .. "x" .. charHeight)
    print("Grid dimensions: " .. gridWidth .. "x" .. gridHeight)
end

function love.update(dt)
    -- Game update logic will go here
end

function love.draw()
    -- Clear screen with black background
    love.graphics.clear(0, 0, 0, 1)
    
    -- Draw the ASCII grid
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local cell = gameGrid[y][x]
            if cell and cell.char then
                love.graphics.setColor(cell.color)
                love.graphics.print(cell.char, (x-1) * charWidth, (y-1) * charHeight)
            end
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    local newX, newY = player.x, player.y
    
    -- Handle player movement
    if key == "up" or key == "w" then
        newY = newY - 1
    elseif key == "down" or key == "s" then
        newY = newY + 1
    elseif key == "left" or key == "a" then
        newX = newX - 1
    elseif key == "right" or key == "d" then
        newX = newX + 1
    elseif key == "escape" then
        love.event.quit()
    end
    
    -- Check bounds and update player position
    if newX >= 1 and newX <= gridWidth and newY >= 1 and newY <= gridHeight then
        -- Clear old position
        gameGrid[player.y][player.x] = {char = ".", color = {1, 1, 1}}
        
        -- Update player position
        player.x = newX
        player.y = newY
        gameGrid[player.y][player.x] = {char = "@", color = {1, 1, 0}}
    end
end
