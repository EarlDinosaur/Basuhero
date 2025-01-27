local menu = {}

function menu.draw(backgroundImages, backgroundTimer, backgroundTransitionTime, currentBackgroundIndex, menuOptions, menuState, selectedOption, logoImage, cuteFont, menuFont)
    -- Draw animated background
    menu.drawGradient(backgroundImages, backgroundTimer, backgroundTransitionTime, currentBackgroundIndex)
    if menuState == "credits" or menuState == "howtoplay" then
        -- Add semi-transparent black background
        love.graphics.setColor(0, 0, 0, 0.7)  -- Black with 70% opacity
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        love.graphics.setFont(menuFont)
        local startY = 100
        local spacing = 30
        
        for i, option in ipairs(menuOptions[menuState]) do
            if i == #menuOptions[menuState] then  -- "Back" option
                if i == selectedOption then
                    love.graphics.setColor(1, 1, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(option, 0, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        end
        
    else
        if menuState == "options" then
            -- Add semi-transparent black background
            love.graphics.setColor(0, 0, 0, 0.7)  -- Black with 70% opacity
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        end
        -- Draw logo image
        love.graphics.setColor(1, 1, 1)
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local logoX = (screenWidth - logoImage:getWidth()) / 2
        local logoY = 100  -- Adjusted Y position to avoid conflict
        love.graphics.draw(logoImage, logoX, logoY)

        -- Draw menu options with cute font and outline
        love.graphics.setFont(cuteFont)
        local startY = logoY + logoImage:getHeight() + 50 -- Adjusted startY to be below the logo
        local spacing = 50

        for i, option in ipairs(menuOptions[menuState]) do
            -- Draw outline
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(option, -2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
            love.graphics.printf(option, 2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
            love.graphics.printf(option, 0, startY + (i-1) * spacing - 2, love.graphics.getWidth(), "center")
            love.graphics.printf(option, 0, startY + (i-1) * spacing + 2, love.graphics.getWidth(), "center")
            
            -- Draw text with highlight
            if i == selectedOption then
                love.graphics.setColor(1, 1, 0)  -- Highlight selected option
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(option, 0, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        end
    end
end

function menu.drawGradient(backgroundImages, backgroundTimer, backgroundTransitionTime, currentBackgroundIndex)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local currentBackground = backgroundImages[currentBackgroundIndex]
    local nextBackground = backgroundImages[currentBackgroundIndex % #backgroundImages + 1]
    local transitionProgress = backgroundTimer / backgroundTransitionTime

    -- Draw the current background
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(currentBackground, 0, 0, 0, screenWidth / currentBackground:getWidth(), screenHeight / currentBackground:getHeight())

    -- Draw the next background with transparency based on transition progress
    love.graphics.setColor(1, 1, 1, transitionProgress)
    love.graphics.draw(nextBackground, 0, 0, 0, screenWidth / nextBackground:getWidth(), screenHeight / nextBackground:getHeight())
end

function menu.handleMenuSelection(menuState, selectedOption)
    if menuState == "main" then
        if selectedOption == 1 then  -- Play Game
            gameState = "levelSelect"
        elseif selectedOption == 2 then  -- How to Play
            menuState = "howtoplay"
            selectedOption = #menuOptions.howtoplay  -- Select Back button
        elseif selectedOption == 3 then  -- Options
            menuState = "options"
            selectedOption = #menuOptions.options  -- Select Back button
        elseif selectedOption == 4 then  -- Credits
            menuState = "credits"
            selectedOption = #menuOptions.credits  -- Select Back button
        elseif selectedOption == 5 then  -- Exit
            love.event.quit()
        end
    elseif menuState == "options" or menuState == "credits" or menuState == "howtoplay" then
        if selectedOption == #menuOptions[menuState] then  -- Back option
            menuState = "main"
            selectedOption = 1
        end
    end
end

function menu.handleMenuInput(key, menuState, selectedOption, volume, levelMusic, menuOptions)
    if menuState == "options" then
        if key == "left" or key == "right" then
            local change = key == "left" and -0.1 or 0.1
            if selectedOption == 1 then
                volume.music = math.max(0, math.min(1, volume.music + change))
                menuOptions.options[1] = string.format("Music Volume: %d%%", math.floor(volume.music * 100))
                -- Update all music volumes
                for _, music in pairs(levelMusic) do
                    music:setVolume(volume.music)
                end
            elseif selectedOption == 2 then
                volume.effects = math.max(0, math.min(1, volume.effects + change))
                menuOptions.options[2] = string.format("Sound Effects: %d%%", math.floor(volume.effects * 100))
            end
        end
    end

    if key == "up" or key == "w" then
        selectedOption = selectedOption - 1
        if selectedOption < 1 then 
            selectedOption = #menuOptions[menuState]
        end
    elseif key == "down" or key == "s" then
        selectedOption = selectedOption + 1
        if selectedOption > #menuOptions[menuState] then
            selectedOption = 1
        end
    elseif key == "return" or key == "space" then
        if menuState == "main" then
            if selectedOption == 1 then  -- Play Game
                gameState = "levelSelect"
            elseif selectedOption == 2 then  -- How to Play
                menuState = "howtoplay"
                selectedOption = #menuOptions.howtoplay  -- Select Back button
            elseif selectedOption == 3 then  -- Options
                menuState = "options"
                selectedOption = #menuOptions.options  -- Select Back button
            elseif selectedOption == 4 then  -- Credits
                menuState = "credits"
                selectedOption = #menuOptions.credits  -- Select Back button
            elseif selectedOption == 5 then  -- Exit
                love.event.quit()
            end
        elseif menuState == "options" or menuState == "credits" or menuState == "howtoplay" then
            if selectedOption == #menuOptions[menuState] then  -- Back option
                menuState = "main"
                selectedOption = 1
            end
        end
    elseif key == "escape" then
        if menuState == "main" then
            love.event.quit()
        else
            menuState = "main"
            selectedOption = 1
        end
    end
    
    return menuState, selectedOption, gameState, volume
end


return menu