-- main.lua

local levelMusic = {}
local highScores = {
    easy = 0,
    medium = 0,
    hard = 0
}
local backgrounds = {}
font = love.graphics.newFont("assets/CabinBold.ttf", 14)

local menuState = "main"  -- "main", "options", "credits", "howtoplay"
local menuOptions = {
    main = {"Play Game", "How to Play", "Options", "Credits", "Exit"},
    options = {"Music Volume: 100%", "Sound Effects: 100%", "Back"},
    credits = {
        "BASUHERO",
        "",
        "Group Members:",
        "Charles Andrei Abuela",
        "Earl Gem Llesis",
        "Giancarlo Bajit",
        "Jhonder Sta Ines",
        "Meinard Francisco",
        "Rodney Milay Maisog",
        "Ruzel Luigi Alano",
        "",
        "Back"
    },
    howtoplay = {
        "How to Play",
        "",
        "Goal: Sort the falling trash into correct bins",
        "",
        "Controls:",
        "Q - Compostable",
        "W - Waste",
        "E - Recyclable",
        "ESC - Return to Menu",
        "",
        "Tips:",
        "- Watch the trash type carefully",
        "- Sort before trash crosses the line",
        "- Higher levels have faster speeds",
        "",
        "Back"
    }
}
local selectedOption = 1
local volume = {
    music = 1.0,
    effects = 1.0
}

local levelSelectOptions = {"Dumpster Diving", "Rags to Riches", "Trash King", "Back to Main Menu"}
local selectedLevelOption = 1

local gameOverOptions = {"Retry", "Level Select", "Main Menu"}
local selectedGameOverOption = 1

function love.load()
    love.graphics.setBackgroundColor(.64, .6, 1.4)  -- Light blue background

    levelMusic = {
    easy = love.audio.newSource("assets/audio/pinkponyclub.mp3", "stream"),
    medium = love.audio.newSource("assets/audio/goodluckbabe.mp3", "stream"),
    hard = love.audio.newSource("assets/audio/hottogo.mp3", "stream"),
}

    backgrounds.easy = love.graphics.newImage("assets/images/easybg.png")
    backgrounds.medium = love.graphics.newImage("assets/images/mediumbg.png")
    backgrounds.hard = love.graphics.newImage("assets/images/hardbg.png")

    currentBackground = nil

    trashItems = {}  -- Table to store falling trash items
    spawnInterval = 0.5  -- Time in seconds between spawns
    timer = 0  -- Timer to control the interval

    compostableImages = {
        love.graphics.newImage("assets/images/apple.png"),
        love.graphics.newImage("assets/images/banana.png"),
        love.graphics.newImage("assets/images/fishbone.png")
    }
    wasteImage = love.graphics.newImage("assets/images/poop.png")
    

    recyclableImages = {
        love.graphics.newImage("assets/images/bottle.png"),
        love.graphics.newImage("assets/images/can.png"),
        love.graphics.newImage("assets/images/box.png")
    }

    -- Set fixed values for trash size, x position
    trashWidth = 100
    trashHeight = 100
    centerX = love.graphics.getWidth() / 2 - trashWidth / 2

    gradientColors = {
        {{0.5, 0.7, 1}, {0.2, 0.4, 0.8}},  -- Light blue to darker blue
        {{0.8, 0.5, 0.5}, {1, 0.7, 0.7}},  -- Soft pink to light red
        {{0.6, 0.8, 0.4}, {0.3, 0.6, 0.2}},  -- Light green to darker green
        {{196/255, 153/255, 33/255}, {232/255, 173/255, 7/255}}  -- Yellowish gradient
    }


    currentGradientIndex = 1
    nextGradientIndex = 2
    gradientTransitionProgress = 1  -- Start fully transitioned to the first color

    -- Define the line position and game state
    lineY = love.graphics.getHeight() - 100  -- Position of the "clear line"
    gameRunning = true  -- Game state variable

    -- Define positions for the trash bins below the line
    binPositions = {
        compostable = {x = love.graphics.getWidth() / 2 - 300, y = lineY + 50},
        waste = {x = love.graphics.getWidth() / 2, y = lineY + 50},
        recyclable = {x = love.graphics.getWidth() / 2 + 300, y = lineY + 50}
    }

    binOrder = {"compostable", "waste", "recyclable"}

    -- Load bin images
    binImages = {
        compostable = love.graphics.newImage("assets/images/compost.png"),  -- Example image paths
        waste = love.graphics.newImage("assets/images/waste.png"),
        recyclable = love.graphics.newImage("assets/images/recycle.png")
    }

    -- Screen shake variables
    shakeDuration = 0.15  -- Shake duration in seconds
    shakeMagnitude = 5    -- Magnitude of shake effect
    shakeTime = 0         -- Timer for shake effect

    -- Game state variables
    gameState = "menu"  -- "menu", "playing", or "gameOver"
    currentLevel = "easy"

    -- Add menu background and assets
    titleFont = love.graphics.newFont("assets/CabinBold.ttf", 48)
    menuFont = love.graphics.newFont("assets/CabinBold.ttf", 24)

    backgroundTransitionTime = 5  -- Time in seconds for each background transition (faster animation)
    backgroundTimer = 0  -- Timer to control background transitions
    currentBackgroundIndex = 1
    backgroundImages = {backgrounds.easy, backgrounds.medium, backgrounds.hard}

    logoImage = love.graphics.newImage("assets/images/Basuhero_Logo.png")
    -- Use a built-in Love2D font or another available font if CuteFont.ttf is not available
    cuteFont = love.graphics.newFont(32)  -- Use a default font with size 32
end

function love.update(dt)

    if gameState == "menu" then
        for _, music in pairs(levelMusic) do
            music:stop()
        end

        backgroundTimer = backgroundTimer + dt
        if backgroundTimer >= backgroundTransitionTime then
            backgroundTimer = 0
            currentBackgroundIndex = currentBackgroundIndex % #backgroundImages + 1
        end

    elseif gameState == "levelSelect" then

    elseif gameState == "playing" then
        timer = timer + dt  -- Increment the timer by the delta time

        -- Check if it's time to spawn trash
        if timer >= spawnInterval then
            spawnTrash()  -- Spawn trash
            timer = 0  -- Reset the timer
        end

        -- Update trash positions and check for collisions
        for i = #trashItems, 1, -1 do  -- Iterate in reverse for safe removal
            local trash = trashItems[i]
            trash.y = trash.y + fallSpeed * dt

            -- Check if trash is touching the line
            if trash.y + trash.height >= lineY and not trash.touchingLine then
                trash.touchingLine = true  -- Trash has reached the line
            end

            -- End the game if trash goes below the line without being cleared
            if trash.touchingLine and trash.y + trash.height > lineY + trash.height then
                endGame()  -- End game if trash goes past the line
                return
            end
        end

         -- Update trash positions and rotations
        for i = #trashItems, 1, -1 do  -- Iterate in reverse for safe removal
            local trash = trashItems[i]
            trash.y = trash.y + fallSpeed * dt
            trash.rotation = trash.rotation + trash.rotationSpeed * dt  -- Update rotation angle
        end

        -- Smooth gradient transition if in progress
        if gradientTransitionProgress < 1 then
            gradientTransitionProgress = math.min(1, gradientTransitionProgress + dt)  -- Gradual transition
        end

         -- Update shake timer
        if shakeTime > 0 then
            shakeTime = shakeTime - dt
        end
    end
end

function love.draw()
    if gameState == "menu" then
        love.graphics.setFont(cuteFont)
        drawMenu()
    elseif gameState == "levelSelect" then
        love.graphics.setFont(titleFont)
        love.graphics.setColor(1, 1, 1)
        
        -- Draw "Select Difficulty" with outline at the top center
        local selectText = "Select Difficulty"
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(selectText, -2, love.graphics.getHeight() / 6, love.graphics.getWidth(), "center")
        love.graphics.printf(selectText, 2, love.graphics.getHeight() / 6, love.graphics.getWidth(), "center")
        love.graphics.printf(selectText, 0, love.graphics.getHeight() / 6 - 2, love.graphics.getWidth(), "center")
        love.graphics.printf(selectText, 0, love.graphics.getHeight() / 6 + 2, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(selectText, 0, love.graphics.getHeight() / 6, love.graphics.getWidth(), "center")

        love.graphics.setFont(cuteFont)
        local startY = love.graphics.getHeight() / 3
        local spacing = 60

        for i, option in ipairs(levelSelectOptions) do
            -- Draw outline
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(option, -2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
            love.graphics.printf(option, 2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
            love.graphics.printf(option, 0, startY + (i-1) * spacing - 2, love.graphics.getWidth(), "center")
            love.graphics.printf(option, 0, startY + (i-1) * spacing + 2, love.graphics.getWidth(), "center")
            
            -- Draw text with highlight
            if i == selectedLevelOption then
                love.graphics.setColor(1, 1, 0)  -- Highlight selected option
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(option, 0, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        end

    elseif gameState == "playing" then
        love.graphics.setFont(font)
        -- Set initial shake offsets to zero
        local shakeOffsetX, shakeOffsetY = 0, 0

        -- Apply shake if active
        if shakeTime > 0 then
            shakeOffsetX = love.math.random(-shakeMagnitude, shakeMagnitude)
            shakeOffsetY = love.math.random(-shakeMagnitude, shakeMagnitude)
            love.graphics.push()  -- Push before applying shake
            love.graphics.translate(shakeOffsetX, shakeOffsetY)
        end

        drawLevelBackground()

        -- Draw each trash item
        for _, trash in ipairs(trashItems) do
            love.graphics.setColor(1, 1, 1)  -- Reset color for images
            love.graphics.draw(
                trash.image,
                trash.x + trash.width / 2,  -- Center for rotation
                trash.y + trash.height / 2,
                trash.rotation,             -- Rotation angle
                trash.width / trash.image:getWidth(),  -- X scale
                trash.height / trash.image:getHeight(), -- Y scale
                trash.image:getWidth() / 2,  -- Offset to center of image
                trash.image:getHeight() / 2  -- Offset to center of image
            )
        end

        drawBins()

        -- Draw the clear line
        love.graphics.setColor(1.68, .5, .54, 0.7)
        love.graphics.setLineWidth(5)
        love.graphics.line(0, lineY, love.graphics.getWidth(), lineY)

        -- Display instructions and scores
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Press q if it is compostable", 50, 20)
        love.graphics.print("Press w if it is waste", 50, 35)
        love.graphics.print("Press e if it is recyclable", 50, 50)
        love.graphics.print("Press esc to go to the main menu", 50, 65)
        love.graphics.print("Score: " .. score, love.graphics.getWidth() - 150, 20)
        love.graphics.print("High Score: " .. (highScores[currentLevel] or 0), love.graphics.getWidth() - 150, 40)

        -- Only pop if we pushed for shake effect
        if shakeTime > 0 then
            love.graphics.pop()
        end

    elseif gameState == "gameOver" then
        love.graphics.setFont(cuteFont)
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

        for i, option in ipairs(gameOverOptions) do
            -- Draw outline
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(option, -2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
            love.graphics.printf(option, 2, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
            love.graphics.printf(option, 0, startY + (i-1) * spacing - 2, love.graphics.getWidth(), "center")
            love.graphics.printf(option, 0, startY + (i-1) * spacing + 2, love.graphics.getWidth(), "center")
            
            -- Draw text with highlight
            if i == selectedGameOverOption then
                love.graphics.setColor(1, 1, 0)  -- Highlight selected option
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(option, 0, startY + (i-1) * spacing, love.graphics.getWidth(), "center")
        end

        love.graphics.setFont(font)
        love.graphics.print("Score: " .. score, love.graphics.getWidth() - 150, 20)
        love.graphics.print("High Score: " .. (highScores[currentLevel] or 0), love.graphics.getWidth() - 150, 40)
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        handleMenuInput(key)
    elseif gameState == "levelSelect" then
        if key == "up" or key == "w" then
            selectedLevelOption = selectedLevelOption - 1
            if selectedLevelOption < 1 then 
                selectedLevelOption = #levelSelectOptions
            end
        elseif key == "down" or key == "s" then
            selectedLevelOption = selectedLevelOption + 1
            if selectedLevelOption > #levelSelectOptions then
                selectedLevelOption = 1
            end
        elseif key == "return" or key == "space" then
            if selectedLevelOption == 1 then
                currentLevel = "easy"
                currentBackground = backgrounds[currentLevel]
                startGame()  -- Start game with easy level
            elseif selectedLevelOption == 2 then
                currentLevel = "medium"
                currentBackground = backgrounds[currentLevel]
                startGame()  -- Start game with medium level
            elseif selectedLevelOption == 3 then
                currentLevel = "hard"
                currentBackground = backgrounds[currentLevel]
                startGame()  -- Start game with hard level
            elseif selectedLevelOption == 4 then
                gameState = "menu"
                menuState = "main"
                selectedOption = 1
            end
        end

    elseif gameState == "playing" then
        if key == "escape" then
            gameState = "menu"
            menuState = "main"
            selectedOption = 1
            for _, music in pairs(levelMusic) do
                music:stop()
            end
            return
        end

        if key == "q" then
            binOrder = {"waste", "compostable", "recyclable"}
        elseif key == "w" then
            binOrder = {"recyclable", "waste", "compostable"}
        elseif key == "e" then
            binOrder = {"compostable", "recyclable", "waste"}
        end

        if key == "q" or key == "w" or key == "e" then
            checkTrashClear(key)
        end

    elseif gameState == "gameOver" then 
        if key == "up" or key == "w" then
            selectedGameOverOption = selectedGameOverOption - 1
            if selectedGameOverOption < 1 then 
                selectedGameOverOption = #gameOverOptions
            end
        elseif key == "down" or key == "s" then
            selectedGameOverOption = selectedGameOverOption + 1
            if selectedGameOverOption > #gameOverOptions then
                selectedGameOverOption = 1
            end
        elseif key == "return" or key == "space" then
            if selectedGameOverOption == 1 then
                startGame()  -- Retry
            elseif selectedGameOverOption == 2 then
                gameState = "levelSelect"
                selectedLevelOption = 1
            elseif selectedGameOverOption == 3 then
                gameState = "menu"
                menuState = "main"
                selectedOption = 1
            end
        end
    end
end

function handleMenuInput(key)
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
        handleMenuSelection()
    end
end

function handleMenuSelection()
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

function drawMenu()
    -- Draw animated background
    drawGradient()

    if menuState == "credits" or menuState == "howtoplay" then
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

function drawLevelBackground()
    love.graphics.setColor(1, 1, 1, 0.5)  -- Reset color to white for proper image rendering
    if currentBackground then
        -- Scale the background to fit the screen
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local scaleX = screenWidth / currentBackground:getWidth()
        local scaleY = screenHeight / currentBackground:getHeight()
        love.graphics.draw(currentBackground, 0, 0, 0, scaleX, scaleY)
    end
end

function drawGradient()
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

function drawBins()
    local centerX = love.graphics.getWidth() / 2
    local binY = lineY + 70
     local scaleFactor = 4  -- Adjust this value to scale the bins larger
    local spacing = 100

    for i, binType in ipairs(binOrder) do
        -- Adjust position based on the order of bins
        local xOffset = (i - 2) * 300  -- Left, Center, Right positions
        local xPosition = centerX + xOffset
        local binImage = binImages[binType]
       
        -- Draw the bin with the adjusted position
        love.graphics.draw(binImage, xPosition, binY, 0, 1, 1, binImage:getWidth() / 2, binImage:getHeight() / 2)

        
        end
end

-- Spawn trash with a random type
function spawnTrash()
    local trashType
    local trashImage
    local types = {"compostable", "waste", "recyclable"}
    trashType = types[math.random(#types)]

    if currentLevel == "easy" then
    if trashType == "compostable" then
        trashImage = compostableImages[1]
    elseif trashType == "waste" then
        trashImage = wasteImage
    elseif trashType == "recyclable" then
        trashImage = recyclableImages[1]
    end
    
    elseif currentLevel == "medium" then

    if trashType == "compostable" then
        trashImage = compostableImages[math.random(1,2)]
    elseif trashType == "waste" then
        trashImage = wasteImage
    elseif trashType == "recyclable" then
        trashImage = recyclableImages[math.random(1,2)]
    end

    elseif currentLevel == "hard" then
    if trashType == "compostable" then
        trashImage = compostableImages[math.random(#compostableImages)]
    elseif trashType == "waste" then
        trashImage = wasteImage
    elseif trashType == "recyclable" then
        trashImage = recyclableImages[math.random(#recyclableImages)]
    end
end

    local trash = {
        x = centerX,
        y = -trashHeight,  -- Start just above the screen
        width = trashWidth,
        height = trashHeight,
        type = trashType,
        image = trashImage,
        rotation = 0,  -- Initial rotation angle
        rotationSpeed = math.random(-2, 2) * math.pi / 3,  -- Random rotation speed between -120 and +120 degrees per second
        touchingLine = false
    }
    
    table.insert(trashItems, trash)
end

function checkTrashClear(key)
    for i, trash in ipairs(trashItems) do
        if trash.touchingLine then
            -- Match key to trash type
            if (key == "q" and trash.type == "compostable") or
               (key == "w" and trash.type == "waste") or
               (key == "e" and trash.type == "recyclable") then
                table.remove(trashItems, i)  -- Remove correctly cleared trash
                score = score + 100  -- Increase score
                
                -- Trigger gradient change on clear
                currentGradientIndex = nextGradientIndex
                nextGradientIndex = math.random(#gradientColors)
                gradientTransitionProgress = 0

                shakeTime = shakeDuration  -- Start screen shake effect
                
                return
            else
                endGame()  -- End game on incorrect key
                return
            end
        end
    end
end

function playLevelMusic(level)

    -- Stop any currently playing music
    for _, music in pairs(levelMusic) do
        music:stop()
    end
    -- Play the music for the specified level
    if levelMusic[level] then
        levelMusic[level]:setVolume(volume.music)
        levelMusic[level]:setLooping(true)  -- Loop the music
 levelMusic[level]:play()  -- Start playing the music
end
end

function loadHighScores()
    if love.filesystem.getInfo("highScores.txt") then
        local contents = love.filesystem.read("highscores.txt")
        local easy, medium, hard = contents:match("(%d+)\n(%d+)\n(%d+)")
        highScores.easy = tonumber(easy) or 0
        highScores.medium = tonumber(medium) or 0
        highScores.hard = tonumber(hard) or 0
    else
        highScores = { easy = 0, medium = 0, hard = 0 }
    end
end

function saveHighScores()
    local data = string.format("%d\n%d\n%d", highScores.easy, highScores.medium, highScores.hard)
    love.filesystem.write("highscores.txt", data)
end

function table.serialize(tbl)
    local result = "{\n"
    for k, v in pairs(tbl) do
        result = result .. string.format("    %s = %d,\n", k, v)
    end
    result = result .. "}"
    return result
end

function loadScreen()
    gameState = "menu"
end

function startGame()
    resetGame()
    loadHighScores()
    gameState = "playing"
    playLevelMusic(currentLevel)
    -- Adjust game parameters based on the selected level
    if currentLevel == "easy" then
        local bpm = 107
        local beatsPerSecond = bpm / 60
        spawnInterval = 1 / beatsPerSecond  -- This will give you approximately 0.4286 seconds
        fallSpeed = 250  -- Faster fall speed
        lineY = love.graphics.getHeight() - 125  -- Larger line for easy level
    elseif currentLevel == "medium" then
        local bpm = 117
        local beatsPerSecond = bpm / 60
        spawnInterval = 1 / beatsPerSecond  -- This will give you approximately 0.4286 seconds
        fallSpeed = 300  -- Faster fall speed
        lineY = love.graphics.getHeight() - 125  -- Medium line size for medium level
    elseif currentLevel == "hard" then
        local bpm = 140
        local beatsPerSecond = bpm / 60
        spawnInterval = 1 / beatsPerSecond  -- This will give you approximately 0.4286 seconds
        fallSpeed = 350  -- Faster fall speed
        lineY = love.graphics.getHeight() - 125  -- Default line size for hard level
    end
end

function endGame()
    gameState = "gameOver"
    for _, music in pairs(levelMusic) do
        music:stop()
    end

   if score > highScores[currentLevel] then
        highScores[currentLevel] = score
        saveHighScores()
    end
end

function resetGame()
    trashItems = {}
    timer = 0
    score = 0
    playLevelMusic(currentLevel)
end