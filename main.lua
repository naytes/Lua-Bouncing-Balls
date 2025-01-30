--[[ A program to simulate falling balls of various sizes and colors. You can add momentum to all balls in cardinal directions using the WASD keys. This was my first Lua project that serves as a starting point for learning the language as well as the Love2d framework.
I realize that much of the code is poorly designed for scalability but it works well for the small simulation it runs.]]

-- Nayte Chandler 1/30/2025 NAC


-- need to run with the Love2d framework for gui support
local love = require "love"

function love.load()
    love.window.setTitle("Bouncey Balls")
    -- set seed for rnd
    math.randomseed(os.time())
    -- scale window to half scrren size
    local winWidth = love.graphics.getWidth() * .5
    local winHeight = love.graphics.getHeight() * .5
    -- create an array of ball objects
    Balls = {}

    for i = 1, 25 do
        -- one ball for each loop iteration
        local ball = {}

        -- balls spawn randomly north of the window confined by x axis
        ball.ballX = math.random(0, winWidth*2)
        ball.ballY = math.random(winHeight*-2, 0)
    
        -- give ball random south east tragectory 
        ball.ballDX = math.random(50, 150)
        ball.ballDY = math.random(50, 25)

        -- set static gravity for balls as well as factors for loss in momentum on wall collision
        ball.gravity = 1.05
        ball.speedCoefficient = 15
        ball.momentumLost = .75

        -- set random blue color for ball
        ball.r = (math.random(255)/255)
        ball.g = (math.random(255)/255)
        ball.b = (math.random(200,255)/255)

        -- random size etween 4 and 12
        ball.rad = math.random(4,12)

        -- logic to determine next location for ball based on ground collision, tragectory changes and some key inputs
        function ball:update(dt)
            -- if ball is moving and above ground, add momentum based on mass and time since last check
            if self.ballDY ~= 0 and self.ballY < winHeight*2-self.rad then
                self.ballDY = self.ballDY + 50*dt*self.rad
            end
            -- if ball is almost out of momentum and near the ground then remove momentum
            if self.ballY > (winHeight*2)- self.rad and (self.ballDY < 1 and self.ballDY > -1) then
                self.ballY = winHeight*2 - self.rad
                self.ballDY = 0
            end
            -- if ball is moving vertically remove .01% of its momentum
            if self.ballDX ~= 0 then
                self.ballDX = ball.ballDX * .999
            end
            -- if the ball is out of horizontal mometum and touching the ground then reset the ball to a new position above the window with randomized features
            if self.ballDY < .5 and self.ballDY > -.5 and self.ballY > (winHeight*2) - (self.rad*1.25) then
                self.ballX = math.random(0, winWidth*2)
                self.ballY = math.random(winHeight*-2, 0)
                self.ballDX = math.random(50, 150)
                self.ballDY = math.random(50, 25)
                self.rad = math.random(4,12)
            end
        end
        -- append ball to balls
        table.insert(Balls, ball)
    end
end

-- when ball location gets updated, apply proper math to position and direction
function love.update(dt)
    -- do this for every ball
    for i, ball in ipairs(Balls) do
        -- add momentum in direction assosiated with keyboard inputs. 'w' = north 'd'= east etc...
        if love.keyboard.isDown('w') then
            ball.ballDY = ball.ballDY - ball.speedCoefficient
        end
        if love.keyboard.isDown('s')  then
            ball.ballDY = ball.ballDY + ball.speedCoefficient
        end
        if love.keyboard.isDown('d') then
            ball.ballDX = ball.ballDX + ball.speedCoefficient
        end
        if love.keyboard.isDown('a') then
            ball.ballDX = ball.ballDX - ball.speedCoefficient
        end
        -- if the ball exits the screen on the west side and is moving west, place the ball on the east side of screen
        if ball.ballX < -1*(ball.rad) and ball.ballDX < 0 then
            ball.ballX = love.graphics.getWidth() + ball.rad
        end
        -- if the ball exits the screen on the east side and is moving east, place the ball on the west side of screen
        if ball.ballX > love.graphics.getWidth() + ball.rad and ball.ballDX > 0 then
            ball.ballX = -1 *ball.rad
        end
        -- if the ball hits the ground and has horizontal momentum, reverse the momentum causing it to bounce upward with slightly reduced momentum
        if ball.ballY > love.graphics.getHeight() - ball.rad and ball.ballDY > 0 then
            ball.ballDY = (-ball.ballDY) * ball.momentumLost
        end
        -- run the individual ball update function
        ball:update(dt)
        -- update ball position based on current direction
        ball.ballX = ball.ballX + ball.ballDX * dt
        ball.ballY = ball.ballY + ball.ballDY * dt
    end
end

-- when the escape key is pressed, exit the program
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

-- draw each ball with their randomly determined features
function love.draw()
    for i, ball in ipairs(Balls) do
        love.graphics.setColor(ball.r, ball.g, ball.b)
        love.graphics.circle("fill", ball.ballX, ball.ballY, ball.rad)
    end
end