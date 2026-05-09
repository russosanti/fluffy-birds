--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

local medals = {
    { score = 70, medal = 'god' },
    { score = 50, medal = 'gold' },
    { score = 40, medal = 'silver' },
    { score = 25, medal = 'bronze' },
    { score = 10, medal = 'steel' },
    { score = 5, medal = 'copper' }
}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- checks for medals and renders score

    local earnedMedal, nextMedal = self:getMedalInfo()
    
    if earnedMedal ~= nil then
        self:renderMedal(earnedMedal, nextMedal)
    else
        love.graphics.setFont(flappyFont)
        love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(mediumFont)
        love.graphics.printf('You score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')
        -- Points needed for first medal
        local pointsNeeded = medals[#medals].score - self.score
        love.graphics.printf('You need ' .. pointsNeeded .. ' more point(s) for a medal', 0, 130, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.printf('Press Enter to Play Again!', 0, 180, VIRTUAL_WIDTH, 'center')
end

-- Renders medal using medal name as key to gTextures
function ScoreState:renderMedal(medal, nextMedal)
    love.graphics.setFont(flappyFont)

    local text = 'Congrats!'

    -- dimensions
    local medalScale = 0.3

    -- centered text position
    local textX = (VIRTUAL_WIDTH - flappyFont:getWidth(text)) / 2
    local textY = 64

    -- medal position
    local medalX = textX - gTextures[medal]:getWidth() * medalScale - 10
    local medalY = textY + (flappyFont:getHeight() - gTextures[medal]:getHeight() * medalScale) / 2

    -- draw medal
    love.graphics.draw(gTextures[medal], medalX, medalY, 0, medalScale, medalScale)

    -- draw text
    love.graphics.print(text, textX, textY)
    love.graphics.setFont(mediumFont)
    love.graphics.printf('You won a ' .. medal .. ' medal', 0, 100, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('You score: ' .. tostring(self.score), 0, 140, VIRTUAL_WIDTH, 'center')

    -- Display next medal information
    if nextMedal == nil then
        love.graphics.printf('You earned the highest medal!', 0, 160, VIRTUAL_WIDTH, 'center')
    else
        local pointsNeeded = nextMedal.score - self.score
        love.graphics.printf('You need ' .. pointsNeeded .. ' more point(s) for a ' .. nextMedal.medal .. ' medal', 0, 160, VIRTUAL_WIDTH, 'center')
    end
end

function ScoreState:getMedalInfo()
    local earnedMedal = nil
    local nextMedal = nil

    for i, m in ipairs(medals) do
        if self.score >= m.score then
            earnedMedal = m.medal
            -- previous item is actually the NEXT better medal
            if i > 1 then
                nextMedal = medals[i - 1]
            end
            break
        end
    end

    return earnedMedal, nextMedal
end