-- Tetris Game in Lua using Love framework

local serpent = require("serpent")

-- Constants
local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600
local BLOCK_SIZE = 30
local GRID_WIDTH = 10
local GRID_HEIGHT = 20
local MOVE_DELAY = 0.5
local SAVE_GAME_FILENAME = "savegame2.txt"
-- Variables
local grid = {}
local currentPiece = {}
local nextPiece = {}
local pieceX = 0
local pieceY = 0
local score = 0 

local timeSinceMove = 0 
local lineMultiplier = {0, 40, 100, 300, 1200}
local vsyncEnabled = true 
local gameOver = false


-- Tetrimino shapes
local tetriminos = {
    -- Shape I
    {
        { 1, 1, 1, 1 },
    },
    -- Shape L
    {
        { 1, 0, 0 },
        { 1, 1, 1 },
    },
    -- Shape J
    {
        { 0, 0, 1 },
        { 1, 1, 1 },
    },
    -- Shape O
    {
        { 1, 1 },
        { 1, 1 },
    },
    -- Shape Z
    {
        { 1, 1, 0 },
        { 0, 1, 1 },
    },
    -- Shape T
    {
        { 0, 1, 0 },
        { 1, 1, 1 },
    },
    -- Shape S
    {
        { 0, 1, 1 },
        { 1, 1, 0 },
    },
}

-- Save the current game state to a file
function saveGame()
    local gameData = {
        grid = grid,
        currentPiece = currentPiece,
        nextPiece = nextPiece,
        pieceX = pieceX,
        pieceY = pieceY,
        score = score
    }

    love.filesystem.write(SAVE_GAME_FILENAME, serpent.dump(gameData))
end

-- Load the game state from a file
function loadGame()
    if love.filesystem.getInfo(SAVE_GAME_FILENAME) then
        local gameData = love.filesystem.load(SAVE_GAME_FILENAME)()
        grid = gameData.grid
        currentPiece = gameData.currentPiece
        nextPiece = gameData.nextPiece
        pieceX = gameData.pieceX
        pieceY = gameData.pieceY
        score = gameData.score
        return true
    end
    return false
end



function copy2DArray(originalArray)
    local copiedArray = {}
    
    for i = 1, #originalArray do
        copiedArray[i] = {}
        for j = 1, #originalArray[i] do
            if type(originalArray[i][j]) == "table" then
                copiedArray[i][j] = copy2DArray(originalArray[i][j])  -- Recursive call for nested tables
            else
                copiedArray[i][j] = originalArray[i][j]
            end
        end
    end
    
    return copiedArray
end


function newPiece()
    local shape = tetriminos[math.random(#tetriminos)]
    currentPiece = nextPiece
    nextPiece = copy2DArray(shape)
    pieceX = math.floor(GRID_WIDTH / 2) - math.floor(#shape[1] / 2)
    pieceY = 1

    if not isPieceValid() then
        gameOver = true
    end

end


function resetGame()
    local shape = tetriminos[math.random(#tetriminos)]
    nextPiece = copy2DArray(shape)
    grid = {}
    -- Set up the grid
    for row = 1, GRID_HEIGHT do
    grid[row] = {}
        for col = 1, GRID_WIDTH do
            grid[row][col] = 0
        end
    end
    newPiece()
    score = 0
end


function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { vsync = vsyncEnabled })
    love.window.setTitle("Tetris")
    sound = love.audio.newSource("block.ogg", "static")

    if loadGame() == false then
        resetGame()
        newPiece()
    end
end

function love.keypressed(key)
    if key == "left" then
        pieceX = pieceX - 1
        if not isPieceValid() then
            pieceX = pieceX + 1
        end
    elseif key == "right" then
        pieceX = pieceX + 1
        if not isPieceValid() then
            pieceX = pieceX - 1
        end
    elseif key == "up" then
        rotatePiece()
    elseif key == "s" then
        saveGame()
    elseif key == "l" then
        loadGame()
    elseif key == "r" then
        resetGame()
    end
end

function love.update(dt)
    if love.keyboard.isDown("down") then
        fallSpeed = .1
    else
        fallSpeed = MOVE_DELAY
    end

    timeSinceMove = timeSinceMove + dt

    -- Update the piece's position
    if timeSinceMove >= fallSpeed then
        pieceY = pieceY + 1
        timeSinceMove = timeSinceMove - fallSpeed 
        if not isPieceValid() then
            pieceY = pieceY - 1
            lockPiece()
            clearLines()
            newPiece()
        end
    end
end

function isPieceValid()
    for row = 1, #currentPiece do
        for col = 1, #currentPiece[row] do
            if currentPiece[row][col] ~= 0 then
                local x = pieceX + col - 1
                local y = pieceY + row - 1

                if x < 1 or x > GRID_WIDTH or y > GRID_HEIGHT then
                    return false
                end

                if y >= 1 and grid[y][x] ~= 0 then
                    return false
                end
            end
        end
    end

    return true
end

function lockPiece()
    for row = 1, #currentPiece do
        for col = 1, #currentPiece[row] do
            if currentPiece[row][col] ~= 0 then
                local x = pieceX + col - 1
                local y = pieceY + row - 1
                grid[y][x] = 1
            end
        end
    end
end

function clearLines()
    local linesCleared = 0
    for row = GRID_HEIGHT, 1, -1 do
        local lineComplete = true
        for col = 1, GRID_WIDTH do
            if grid[row][col] == 0 then
                lineComplete = false
                break
            end
        end

        if lineComplete then
            table.remove(grid, row)
            table.insert(grid, 1, {})
            linesCleared = linesCleared + 1
        end
    end
    if linesCleared ~= 0 then
        score = score + lineMultiplier[linesCleared]
        love.audio.play(sound)
    end

end

function rotatePiece()
    local rotatedPiece = {}
    for col = 1, #currentPiece[1] do
        rotatedPiece[col] = {}
        for row = #currentPiece, 1, -1 do
            rotatedPiece[col][#currentPiece - row + 1] = currentPiece[row][col]
        end
    end

    currentPiece = rotatedPiece

    while pieceX + #currentPiece[1] - 1 > GRID_WIDTH do
        pieceX = pieceX - 1
    end
    while pieceY + #currentPiece > GRID_HEIGHT do
        pieceY = pieceY - 1
    end

    if not isPieceValid() then
        currentPiece = rotatedPiece
    end
end

function love.draw()
    for row = 1, GRID_HEIGHT do
        for col = 1, GRID_WIDTH do
            local x = (col - 1) * BLOCK_SIZE
            local y = (row - 1) * BLOCK_SIZE

            if grid[row][col] == 1 then
                love.graphics.rectangle("fill", x, y, BLOCK_SIZE, BLOCK_SIZE)
            else
                love.graphics.rectangle("line", x, y, BLOCK_SIZE, BLOCK_SIZE)
            end
        end
    end

    for row = 1, #currentPiece do
        for col = 1, #currentPiece[row] do
            local x = (pieceX + col - 2) * BLOCK_SIZE
            local y = (pieceY + row - 2) * BLOCK_SIZE

            if currentPiece[row][col] == 1 then
                love.graphics.rectangle("fill", x, y, BLOCK_SIZE, BLOCK_SIZE)
            end
        end
    end

    for row = 1, #nextPiece do
        for col = 1, #nextPiece[row] do
            local x = (GRID_WIDTH + col + 2) * BLOCK_SIZE
            local y = (3 + row) * BLOCK_SIZE

            if nextPiece[row][col] == 1 then
                love.graphics.rectangle("fill", x, y, BLOCK_SIZE, BLOCK_SIZE)
            end
        end
    end

    love.graphics.print("Score: " .. score, WINDOW_WIDTH - 100, 20)
    if gameOver then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over", 0, WINDOW_HEIGHT / 2 - 20, WINDOW_WIDTH, "center")
        love.graphics.printf("Press 'R' to restart", 0, WINDOW_HEIGHT / 2 + 20, WINDOW_WIDTH, "center")
    end

end

function love.run()
    if love.load then
        love.load(love.arg.parseGameArguments(arg), arg)
    end

    if love.timer then
        love.timer.step()
    end

    local dt = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        if love.update then
            love.update(dt)
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then
                love.draw()
            end
            love.graphics.present()
        end

    end
end
