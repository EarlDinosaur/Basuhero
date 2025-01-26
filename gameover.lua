local gameover = {}

function gameover.draw(params)
    love.graphics.setFont(params.fonts.cute)
    love.graphics.setColor(1, 1, 1)
    
    -- Draw "Game Over" with outline
    local gameOverText = "Game Over"
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(gameOverText, -2, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")
    love.graphics.printf(gameOverText, 2, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")
    love.graphics.printf(gameOverText, 0, love.graphics.getHeight() / 4 - 2, love.graphics.getWidth(), "center")
    love.graphics.printf(gameOverText, 0, love.graphics.getHeight() / 4 + 2, love.graphics.getWidth(), "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(gameOverText, 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")

    local startY = love.graphics.getHeight() / 2
    local spacing = 50

    for i, option in ipairs(params.options) do
        -- Draw outline
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(option, -2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        love.graphics.printf(option, 2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        love.graphics.printf(option, 0, startY + (i-1) * spacing - 2, love.graphics.getWidth(), "center")
        love.graphics.printf(option, 0, startY + (i-1) * spacing + 2, love.graphics.getWidth(), "center")
        
        -- Draw text with highlight
        if i == params.selectedOption then
            love.graphics.setColor(1, 1, 0)  -- Highlight selected option
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(option, 0, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
    end

    love.graphics.setFont(params.fonts.regular)
    love.graphics.print("Score: " .. params.score, love.graphics.getWidth() - 150, 20)
    love.graphics.print("High Score: " .. (params.highScores[params.currentLevel] or 0), love.graphics.getWidth() - 150, 40)
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