local playing = {}

-- Add score multipliers for each difficulty
local scoreMultipliers = {
    easy = 1,
    medium = 1.5,
    hard = 2
}

local function playRandomTrashSound(trashSounds, volume)
    local sounds = {trashSounds.sound1, trashSounds.sound2, trashSounds.sound3}
    local randomSound = sounds[love.math.random(#sounds)]
    randomSound:setVolume(volume.effects * 0.5)
    randomSound:play()
end

 local gradientColors = {
    {{0.5, 0.7, 1}, {0.2, 0.4, 0.8}},  -- Light blue to darker blue
    {{0.8, 0.5, 0.5}, {1, 0.7, 0.7}},  -- Soft pink to light red
    {{0.6, 0.8, 0.4}, {0.3, 0.6, 0.2}},  -- Light green to darker green
    {{196/255, 153/255, 33/255}, {232/255, 173/255, 7/255}}  -- Yellowish gradient
}


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

    drawGradient(currentGradientIndex, nextGradientIndex, gradientTransitionProgress, gradientColors)

    love.graphics.setColor(1, 1, 1, 0.5)
    -- Draw background
    params.draw.drawLevelBackground(params.currentBackground)

     local screenWidth, screenHeight = love.graphics.getDimensions()
     local scaleX = screenWidth / currentBackground:getWidth()
        local scaleX = screenWidth / currentBackground:getWidth()
            local scaleY = screenHeight / currentBackground:getHeight()
            love.graphics.draw(currentBackground, 0, 0, 0, scaleX, scaleY)


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
    
    if shakeTime > 0 then
    love.graphics.pop()
    end
 
end

function drawGradient(currentGradientIndex, nextGradientIndex, gradientTransitionProgress, gradientColors)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local colorTop = {}
    local colorBottom = {}

    for i = 1, 3 do
        colorTop[i] = (1 - gradientTransitionProgress) * gradientColors[currentGradientIndex][1][i] +
                      gradientTransitionProgress * gradientColors[nextGradientIndex][1][i]
        colorBottom[i] = (1 - gradientTransitionProgress) * gradientColors[currentGradientIndex][2][i] +
                         gradientTransitionProgress * gradientColors[nextGradientIndex][2][i]
    end
        
    for y = 0, screenHeight do
        local ratio = y / screenHeight
        local r = (1 - ratio) * colorTop[1] + ratio * colorBottom[1]
        local g = (1 - ratio) * colorTop[2] + ratio * colorBottom[2]
        local b = (1 - ratio) * colorTop[3] + ratio * colorBottom[3]
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", 0, y, screenWidth, 1)
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
              gradientColors, gradientTransitionProgress, shakeTime, gameOver, newLives = 
              playing.checkTrashClear(params)
        
        return {
            score = score,
            currentGradientIndex = currentGradientIndex,
            nextGradientIndex = nextGradientIndex,
            gradientColors = gradientColors,
            gradientTransitionProgress = gradientTransitionProgress or 0,
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
    local gradientTransitionProgress = gradientTransitionProgress
    local shakeTime = params.shakeTime
    local shakeDuration = params.shakeDuration
    local shakeMagnitude = params.shakeMagnitude
    local volume = params.volume  -- Include volume parameter
    local sfx = params.sfx

    for i, trash in ipairs(trashItems) do
        if trash.touchingLine then
            if (key == "q" and trash.type == "compostable") or
               (key == "w" and trash.type == "nonrec") or
               (key == "e" and trash.type == "recyclable") then
               table.remove(trashItems, i)
                -- Apply score multiplier based on difficulty
               local multiplier = scoreMultipliers[currentLevel] or 1
               score = score + (100 * multiplier)
                
               shakeTime = 0.5
               shakeDuration = 0.3
               shakeMagnitude = 8
                currentGradientIndex = nextGradientIndex
                nextGradientIndex = math.random(#gradientColors)
                gradientTransitionProgress = 0
               

                return score, currentGradientIndex, nextGradientIndex, gradientTransitionProgress, shakeTime, shakeDuration
            else
                lives = lives - 1
                if lives <= 0 then
                    return score, currentGradientIndex, nextGradientIndex, gradientTransitionProgress, shakeTime, shakeDuration
                end
                return score, currentGradientIndex, nextGradientIndex, gradientTransitionProgress, shakeTime, lives
            end
        end
    end
    return score, currentGradientIndex, nextGradientIndex, gradientTransitionProgress, shakeTime, lives
end

return playing