local levelSelect = {}

local difficultyInfo = {
    {
        name = "Dumpster Diving",
        description = "Beginner-friendly pace",
        speed = "Speed: Slow",
        multiplier = "Score: x1"
    },
    {
        name = "Rags to Riches",
        description = "Moderate challenge",
        speed = "Speed: Medium",
        multiplier = "Score: x1.5"
    },
    {
        name = "Trash King",
        description = "For seasoned players",
        speed = "Speed: Fast",
        multiplier = "Score: x2"
    }
}

function levelSelect.draw(params)
    -- Draw animated background first
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local currentBackground = params.backgrounds[params.currentBackgroundIndex]
    local nextBackground = params.backgrounds[params.currentBackgroundIndex % #params.backgrounds + 1]
    local transitionProgress = params.backgroundTimer / params.backgroundTransitionTime

    -- Draw the current background
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(currentBackground, 0, 0, 0, screenWidth / currentBackground:getWidth(), screenHeight / currentBackground:getHeight())

    -- Draw the next background with transparency
    love.graphics.setColor(1, 1, 1, transitionProgress)
    love.graphics.draw(nextBackground, 0, 0, 0, screenWidth / nextBackground:getWidth(), screenHeight / nextBackground:getHeight())

    -- Add semi-transparent black background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title
    love.graphics.setFont(params.fonts.title)
    local selectText = "Select Difficulty"
    local titleY = love.graphics.getHeight() / 6 - 20  -- Moved up slightly

    -- Draw decorative lines
    love.graphics.setColor(1, 0.843, 0, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.line(
        love.graphics.getWidth() * 0.3, titleY - 20,
        love.graphics.getWidth() * 0.7, titleY - 20
    )
    
    -- Draw title text
    love.graphics.setColor(1, 0.843, 0)
    love.graphics.printf(selectText, 0, titleY, love.graphics.getWidth(), "center")

    -- Draw difficulty options
    love.graphics.setFont(params.fonts.cute)
    local startY = love.graphics.getHeight() / 3 - 30  -- Moved up
    local spacing = 90  -- Reduced spacing

    for i = 1, 3 do
        local info = difficultyInfo[i]
        local y = startY + (i-1) * spacing

        -- Selection box
        if i == params.selectedOption then
            love.graphics.setColor(1, 1, 0, 0.2)
            local boxWidth = 400
            local boxHeight = 80
            love.graphics.rectangle(
                "fill",
                love.graphics.getWidth()/2 - boxWidth/2,
                y - 10,
                boxWidth,
                boxHeight
            )
        end

        -- Difficulty name
        love.graphics.setFont(params.fonts.cute)
        love.graphics.setColor(i == params.selectedOption and {1, 1, 0} or {1, 1, 1})
        love.graphics.printf(info.name, 0, y, love.graphics.getWidth(), "center")

        -- Speed and multiplier on same line
        love.graphics.setFont(params.fonts.menu)
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf(
            info.speed .. "  •  " .. info.multiplier,
            0, y + 35, love.graphics.getWidth(), "center"
        )
    end

    -- Back option at bottom
    local backY = love.graphics.getHeight() - 120
    love.graphics.setFont(params.fonts.cute)
    love.graphics.setColor(params.selectedOption == 4 and {1, 1, 0} or {0.8, 0.8, 0.8})
    love.graphics.printf("Back to Main Menu", 0, backY, love.graphics.getWidth(), "center")

    -- Bottom decorative line
    love.graphics.setColor(1, 0.843, 0, 0.5)
    love.graphics.line(
        love.graphics.getWidth() * 0.3, love.graphics.getHeight() - 50,
        love.graphics.getWidth() * 0.7, love.graphics.getHeight() - 50
    )
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