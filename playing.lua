local playing = {}

-- Add score multipliers for each difficulty
local scoreMultipliers = {
    easy = 1,
    medium = 1.5,
    hard = 2
}

-- Function to play a random trash sound
local function playRandomTrashSound(trashSounds, volume)
    local sounds = {trashSounds.sound1, trashSounds.sound2, trashSounds.sound3}
    local randomSound = sounds[love.math.random(#sounds)]
    randomSound:setVolume(volume.effects * 0.5)
    randomSound:play()
end

function playing.drawPlaying(params)
    -- Font setup
    love.graphics.setFont(params.font)
    
    -- Handle screen shake
    local shakeOffsetX, shakeOffsetY = 0, 0
    if params.shakeTime > 0 then
        shakeOffsetX = love.math.random(-params.shakeMagnitude, params.shakeMagnitude)
        shakeOffsetY = love.math.random(-params.shakeMagnitude, params.shakeMagnitude)
        love.graphics.push()
        love.graphics.translate(shakeOffsetX, shakeOffsetY)
    end

    -- Draw background
    params.draw.drawLevelBackground(params.currentBackground)

    -- Draw trash items
    for _, trash in ipairs(params.trashItems) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            trash.image,
            trash.x + trash.width / 2,
            trash.y + trash.height / 2,
            trash.rotation,
            trash.width / trash.image:getWidth(),
            trash.height / trash.image:getHeight(),
            trash.image:getWidth() / 2,
            trash.image:getHeight() / 2
        )
    end

    -- Draw bins
    params.draw.drawBins(params.binImages, params.binOrder, params.lineY)

    -- Draw clear line
    love.graphics.setColor(1.68, .5, .54, 0.7)
    love.graphics.setLineWidth(5)
    love.graphics.line(0, params.lineY, love.graphics.getWidth(), params.lineY)

    -- Draw UI text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Press q if it is compostable", 50, 20)
    love.graphics.print("Press w if it is non-recyclable", 50, 35)
    love.graphics.print("Press e if it is recyclable", 50, 50)
    love.graphics.print("Press esc to go to the main menu", 50, 65)
    love.graphics.print("Score: " .. params.score, love.graphics.getWidth() - 150, 20)
    love.graphics.print("High Score: " .. (params.highScores[params.currentLevel] or 0), love.graphics.getWidth() - 150, 40)

    -- Draw hearts
    params.draw.drawHearts(params.lives, params.heartImage)

    -- Pop shake transform
    if params.shakeTime > 0 then
        love.graphics.pop()
    end
end

function playing.handleInput(params)
    local key = params.key
    local gameState = params.gameState
    local menuState = params.menuState
    local selectedOption = params.selectedOption
    local binOrder = params.binOrder
    local levelMusic = params.levelMusic

    -- Handle escape key
    if key == "escape" then
        for _, music in pairs(levelMusic) do
            music:stop()
        end
        return {
            gameState = "menu",
            menuState = "main",
            selectedOption = 1
        }
    end

    -- Handle bin swapping
    if key == "q" then
        binOrder = {"nonrec", "compostable", "recyclable"}
    elseif key == "w" then
        binOrder = {"recyclable", "nonrec", "compostable"}
    elseif key == "e" then
        binOrder = {"compostable", "recyclable", "nonrec"}
    end

    -- Handle trash clearing if a valid key was pressed
    if key == "q" or key == "w" or key == "e" then
        local score, currentGradientIndex, nextGradientIndex, 
              gradientTransitionProgress, shakeTime, gameOver, newLives = 
              playing.checkTrashClear(params)
        
        return {
            score = score,
            currentGradientIndex = currentGradientIndex,
            nextGradientIndex = nextGradientIndex,
            gradientTransitionProgress = gradientTransitionProgress,
            shakeTime = shakeTime,
            gameOver = gameOver,
            lives = newLives,
            binOrder = binOrder
        }
    end

    return { binOrder = binOrder }
end

function playing.checkTrashClear(params)
    local key = params.key
    local trashItems = params.trashItems
    local score = params.score or 0
    local lives = params.lives
    local currentLevel = params.currentLevel
    local currentGradientIndex = params.currentGradientIndex
    local nextGradientIndex = params.nextGradientIndex
    local gradientColors = params.gradientColors
    local gradientTransitionProgress = params.gradientTransitionProgress
    local shakeTime = params.shakeTime
    local shakeDuration = params.shakeDuration
    local volume = params.volume  -- Include volume parameter

    for i, trash in ipairs(trashItems) do
        if trash.touchingLine then
            if (key == "q" and trash.type == "compostable") or
               (key == "w" and trash.type == "nonrec") or
               (key == "e" and trash.type == "recyclable") then
                table.remove(trashItems, i)
                -- Apply score multiplier based on difficulty
                local multiplier = scoreMultipliers[currentLevel] or 1
                score = score + (100 * multiplier)
                
                -- Play random trash sound
                playRandomTrashSound(params.trashSounds, params.volume)
                
                currentGradientIndex = nextGradientIndex
                nextGradientIndex = math.random(#gradientColors)
                gradientTransitionProgress = 0
                shakeTime = shakeDuration
                
                return score, currentGradientIndex, nextGradientIndex, gradientTransitionProgress, shakeTime
            else
                lives = lives - 1
                if lives <= 0 then
                    return score, currentGradientIndex, nextGradientIndex, gradientTransitionProgress, shakeTime, true -- true indicates game over
                end
                return score, currentGradientIndex, nextGradientIndex, gradientTransitionProgress, shakeTime, false, lives
            end
        end
    end
    return score, currentGradientIndex, nextGradientIndex, gradientTransitionProgress, shakeTime, false, lives
end

return playing