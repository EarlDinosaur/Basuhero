local gameover = {}

function gameover.draw(params)
    -- Draw semi-transparent black overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw "Game Over" text bigger and with more dramatic outline
    love.graphics.setFont(params.fonts.cute)
    local gameOverText = "Game Over"
    local centerY = love.graphics.getHeight() / 4
    
    -- Thicker outline for game over text
    love.graphics.setColor(0, 0, 0)
    for i = 1, 3 do
        love.graphics.printf(gameOverText, -i, centerY, love.graphics.getWidth(), "center")
        love.graphics.printf(gameOverText, i, centerY, love.graphics.getWidth(), "center")
        love.graphics.printf(gameOverText, 0, centerY - i, love.graphics.getWidth(), "center")
        love.graphics.printf(gameOverText, 0, centerY + i, love.graphics.getWidth(), "center")
    end
    
    -- Main game over text
    love.graphics.setColor(1, 0.3, 0.3)  -- Reddish color for game over
    love.graphics.printf(gameOverText, 0, centerY, love.graphics.getWidth(), "center")

    -- Draw score info with larger font and better spacing
    local scoreY = centerY + 80
    love.graphics.setFont(params.fonts.cute)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Final Score: " .. params.score, 0, scoreY, love.graphics.getWidth(), "center")
    
    -- Show high score with golden color if it's a new record
    local isNewHighScore = params.score > (params.highScores[params.currentLevel] or 0)
    if isNewHighScore then
        love.graphics.setColor(1, 0.843, 0)  -- Golden color
        love.graphics.printf("New High Score!", 0, scoreY + 40, love.graphics.getWidth(), "center")
    else
        love.graphics.setColor(0.7, 0.7, 0.7)  -- Grey color
        love.graphics.printf("High Score: " .. (params.highScores[params.currentLevel] or 0), 0, scoreY + 40, love.graphics.getWidth(), "center")
    end

    -- Draw options with better spacing and visual hierarchy
    local startY = love.graphics.getHeight() / 2 + 100
    local spacing = 50

    for i, option in ipairs(params.options) do
        -- Draw option outline
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(option, -2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        love.graphics.printf(option, 2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        love.graphics.printf(option, 0, startY + (i-1) * spacing - 2, love.graphics.getWidth(), "center")
        love.graphics.printf(option, 0, startY + (i-1) * spacing + 2, love.graphics.getWidth(), "center")
        
        -- Draw text with highlight
        if i == params.selectedOption then
            love.graphics.setColor(1, 1, 0)  -- Yellow highlight for selected
        else
            love.graphics.setColor(0.8, 0.8, 0.8)  -- Slightly dimmer for non-selected
        end
        love.graphics.printf(option, 0, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
    end
end

function gameover.handleInput(params)
    local result = {
        selectedGameOverOption = params.selectedGameOverOption,
        gameState = params.gameState,
        menuState = params.menuState,
        selectedOption = params.selectedOption,
        selectedLevelOption = params.selectedLevelOption
    }

    if params.key == "up" or params.key == "w" then
        result.selectedGameOverOption = result.selectedGameOverOption - 1
        if result.selectedGameOverOption < 1 then 
            result.selectedGameOverOption = #params.gameOverOptions
        end
    elseif params.key == "down" or params.key == "s" then
        result.selectedGameOverOption = result.selectedGameOverOption + 1
        if result.selectedGameOverOption > #params.gameOverOptions then
            result.selectedGameOverOption = 1
        end
    elseif params.key == "return" or params.key == "space" then
        if result.selectedGameOverOption == 1 then
            result.shouldRestart = true  -- Signal to restart game
        elseif result.selectedGameOverOption == 2 then
            result.gameState = "levelSelect"
            result.selectedLevelOption = 1
        elseif result.selectedGameOverOption == 3 then
            result.gameState = "menu"
            result.menuState = "main"
            result.selectedOption = 1
        end
    end

    return result
end

return gameover