local levelSelect = {}

function levelSelect.draw(params)
    -- Draw title with outline
    love.graphics.setFont(params.fonts.title)
    local selectText = "Select Difficulty"
    local titleY = love.graphics.getHeight() / 6
    
    -- Draw text outline
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(selectText, -2, titleY, love.graphics.getWidth(), "center")
    love.graphics.printf(selectText, 2, titleY, love.graphics.getWidth(), "center")
    love.graphics.printf(selectText, 0, titleY - 2, love.graphics.getWidth(), "center")
    love.graphics.printf(selectText, 0, titleY + 2, love.graphics.getWidth(), "center")
    
    -- Draw main text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(selectText, 0, titleY, love.graphics.getWidth(), "center")

    -- Draw options
    love.graphics.setFont(params.fonts.cute)
    local startY = love.graphics.getHeight() / 3
    local spacing = 60

    for i, option in ipairs(params.options) do
        -- Draw option outline
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(option, -2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        love.graphics.printf(option, 2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        love.graphics.printf(option, 0, startY + (i-1) * spacing - 2, love.graphics.getWidth(), "center")
        love.graphics.printf(option, 0, startY + (i-1) * spacing + 2, love.graphics.getWidth(), "center")
        
        -- Draw option text
        if i == params.selectedOption then
            love.graphics.setColor(1, 1, 0)  -- Highlight selected
        else
            love.graphics.setColor(1, 1, 1)  -- Normal color
        end
        love.graphics.printf(option, 0, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
    end
end

-- Add input handling function
function levelSelect.handleInput(params)
    local result = {
        selectedOption = params.selectedOption,
        gameState = params.gameState,
        currentLevel = params.currentLevel
    }

    if params.key == "up" or params.key == "w" then
        result.selectedOption = result.selectedOption - 1
        if result.selectedOption < 1 then 
            result.selectedOption = #params.options
        end
    elseif params.key == "down" or params.key == "s" then
        result.selectedOption = result.selectedOption + 1
        if result.selectedOption > #params.options then
            result.selectedOption = 1
        end
    elseif params.key == "return" or params.key == "space" then
        if result.selectedOption == 1 then
            result.currentLevel = "easy"
            result.shouldStartGame = true
        elseif result.selectedOption == 2 then
            result.currentLevel = "medium"
            result.shouldStartGame = true
        elseif result.selectedOption == 3 then
            result.currentLevel = "hard"
            result.shouldStartGame = true
        elseif result.selectedOption == 4 then
            result.gameState = "menu"
            result.menuState = "main"
            result.selectedOption = 1
        end
    end

    return result
end

return levelSelect