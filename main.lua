push = require 'push' -- Including push library

Class = require 'class' -- Including class dierctory to bring in OOP concepts

-- Adding ball class
require 'Ball' 
-- Adding paddle class
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

--[[  Runs when the game first starts up, only once; used to initialize the game. ]]
function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Setting window title name
    love.window.setTitle('Pong')

    -- RNG using os.time() as a base for random number generation
    math.randomseed(os.time())

    -- Get new font
    smallFont = love.graphics.newFont("font.ttf", 8)
    winnerFont = love.graphics.newFont("font.ttf", 16)
    scoreFont = love.graphics.newFont("font.ttf", 32)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- Creating ball object
    ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)

    -- Variables to store player scores
    Player1Score = 0
    Player2Score = 0

    -- Creating Player 1 and Player 2 paddles
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    servingPlayer = 1;
    winningPlayer = 0;

    -- Initializing a table for sound effects
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/point.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['win'] = love.audio.newSource('sounds/win.wav', 'static')
    }

    -- Game state variable used to switch between different parts of the game
    -- Used for beginning menus, main game, highscore etc
    gameState = 'start'
end

-- Function to rescale the window
function love.resize(w, h)
    push: resize(w, h)
end


-- [[   Keyboard Handling, called by LOVE2D each frame  ]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    -- Checking for state changes
    elseif key == "enter" or key == "return" then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- Restarting game 
            gameState = 'serve'
            ball:reset()

            -- Reset Scores
            Player1Score = 0
            Player2Score = 0
            
            -- Decide the loosing player as serving next
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.update(dt)
    
    -- Player 1 movement
    if love.keyboard.isDown('w') then
        -- Add negetive paddle speed to current Y scaled by dt
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
            -- Add positive paddle speed to the current Y scaled by dt
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- Player 2 movement
    if love.keyboard.isDown('up') then
        -- Add negetive paddle speed to current Y scaled by dt
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
            -- Add positive paddle speed to the current Y scaled by dt
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'serve' then
        -- Before starts playing set the vellocity opposite to the player who scored last
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = -math.random(140, 200)
        else
            ball.dx = math.random(140, 200)
        end

    -- Ball movement if we are in play state
    elseif gameState == 'play' then
        -- Checking collision for player 1
        if ball:collides(player1) then
            
            -- Play paddle hit audio
            sounds['paddle_hit']:play()

            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            
            -- Keep velocity going in the same direction but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- Checking collision for player 2
        if ball:collides(player2) then

            -- Play paddle hit audio
            sounds['paddle_hit']:play()


            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- Keep velocity ging in the same direction but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- Detect upper screen boundary collision and reverse the direction
        if ball.y <= 0 then
            -- Play audio for wall hit
            sounds['wall_hit']:play()

            ball.y = 0
            ball.dy = -ball.dy
        end

        -- Detect lower screen boundaty collision and reeverse the direction
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            --Play audio for wall_hit
            sounds['wall_hit']:play()

            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end 
    end
       -- Checking scores by seeing if it has crossed the left or right screen boundaries

    if ball.x < 0 then
        servingPlayer = 1
        Player2Score = Player2Score + 1
        -- Check if player 2 has won
        if Player2Score >= 10 then
           sounds['win']:play() 
           gameState = 'done'
           winningPlayer = 2
        else
           gameState = 'serve'
           -- Play scoring audio
           sounds['score']:play()
        end
        ball:reset()
    end
    if ball.x > VIRTUAL_WIDTH then
        servingPlayer = 2
        Player1Score = Player1Score + 1
        -- Check if player 1 has won
        if Player1Score >= 10 then
           sounds['win']:play()
           gameState = 'done'
           winningPlayer = 1
        else
            -- Play scoring audio
            sounds['score']:play()
            gameState = 'serve'
        end
        ball:reset()
    end


    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
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
    
    if gameState == 'start' then
        love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' serving', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(winnerFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press ENTER to restert', 0, 45, VIRTUAL_WIDTH, 'center')
    end

    -- Set font to score font to render font in bigger size
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT / 3)

    -- Render Player 1 paddle
    player1:render()

    -- Render Player 2 paddle
    player2:render()
    
    -- Render Ball
    ball:render()

    -- Display FPS
    displayFPS()

    -- end rendering at virtual resolution
    push:apply('end')
end

function displayFPS()
    -- Simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    -- The .. operator is used to do string concatination in lua
    love.graphics.print('FPS : ' .. tostring(love.timer.getFPS()), 10, 10)
end