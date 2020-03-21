push = require 'push' -- Including push library

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

--[[  Runs when the game first starts up, only once; used to initialize the game. ]]
function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Get new font
    smallFont = love.graphics.newFont("font.ttf", 8)
    scoreFont = love.graphics.newFont("font.ttf", 32)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- Variables to store player scores
    Player1Score = 0
    Player2Score = 0

    -- Paddle position on the Y axis
    Player1Y = 30
    Player2Y = VIRTUAL_HEIGHT - 50
end

-- [[   Keyboard Handling, called by LOVE2D each frame  ]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    -- Player 1 movement
    if love.keyboard.isDown('w') then
        -- Add negetive paddle speed to current Y scaled by dt
        Player1Y = Player1Y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('s') then
            -- Add positive paddle speed to the current Y scaled by dt
        Player1Y = Player1Y + PADDLE_SPEED * dt
    end

    -- Player 2 movement
    if love.keyboard.isDown('up') then
        -- Add negetive paddle speed to current Y scaled by dt
        Player2Y = Player2Y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('down') then
            -- Add positive paddle speed to the current Y scaled by dt
        Player2Y = Player2Y + PADDLE_SPEED * dt
    end
end

--[[  Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise. ]]
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear()

    -- draw welcome text toward the top of the screen
    love.graphics.setFont(smallFont)
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    -- Set font to score font to render font in bigger size
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT / 3)

    -- render first paddle (left side)
    love.graphics.rectangle('fill', 10, Player1Y, 5, 20)

    -- render second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, Player2Y, 5, 20)

    -- render ball (center)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- end rendering at virtual resolution
    push:apply('end')
end
