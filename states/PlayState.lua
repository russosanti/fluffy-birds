--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

-- size of the gap between pipes
local MIN_GAP_HEIGHT = 75
local START_GAP_HEIGHT = 140

-- spawn interval for new pipes
local MIN_PIPE_SPAWN_INTERVAL = 1.7
local MAX_PIPE_SPAWN_INTERVAL = 4

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.t = 0
    self.score = 0
    self.spawnInterval = math.random(MIN_PIPE_SPAWN_INTERVAL, MAX_PIPE_SPAWN_INTERVAL)

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
    -- update timer for pipe spawning
    self.timer = self.timer + dt
    self.t = self.t + dt

    -- spawn a new pipe pair every second and a half
    if self.timer > self.spawnInterval then
        -- Randomize the gap height, but make sure it's not too small as the player progresses. Gap makes smaller as games improves
        local gap = START_GAP_HEIGHT - self.t < MIN_GAP_HEIGHT and math.random(MIN_GAP_HEIGHT, MIN_GAP_HEIGHT + 20) or
            math.random(START_GAP_HEIGHT - self.t, START_GAP_HEIGHT + 30 - self.t)

        
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length from the bottom added ground to consider that
        local y = math.max(-PIPE_HEIGHT + 10,
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - gap - PIPE_HEIGHT - GROUND_HEIGHT))
        self.lastY = y

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y, gap))

        -- reset timer
        self.timer = 0
        self.spawnInterval = math.random(MIN_PIPE_SPAWN_INTERVAL, MAX_PIPE_SPAWN_INTERVAL)
    end

    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                gSounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                gSounds['explosion']:play()
                gSounds['hurt']:play()

                -- gStateMachine:change('score', {
                --    score = self.score
               --  })
            end
        end
    end

    -- Continuous input checking; if space is maintained pressed, make bird jump several times in a row
    if love.keyboard.isDown('space') then
        love.keyboard.keysPressed['space'] = true
    end
    if love.mouse.isDown(1) then
        love.mouse.buttonsPressed[1] = true
    end

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        gSounds['explosion']:play()
        gSounds['hurt']:play()

        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end
