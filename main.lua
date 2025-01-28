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
        "Back"
    },
    howtoplay = {
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

local lives = 3  -- Number of lives the player starts with
local heartImage = love.graphics.newImage("assets/images/heart.png")  -- Load heart image

local draw = require("draw")
local menu = require("menu")
local levelSelect = require ("levelSelect")
local playing = require("playing")
local gameover = require('gameover')
local utils = require("utils")

function love.load()
    love.window.setTitle("BASUHERO - Trash Sorting Game")
    
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
    nonrecImages = {
        love.graphics.newImage("assets/images/poop.png"),
        love.graphics.newImage("assets/images/poop.png"),
        love.graphics.newImage("assets/images/poop.png")
    }
    

    recyclableImages = {
        love.graphics.newImage("assets/images/bottle.png"),
        love.graphics.newImage("assets/images/box.png"),
        love.graphics.newImage("assets/images/can.png")
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
    lineY = love.graphics.getHeight() - 150  -- Position of the "clear line"
    gameRunning = true  -- Game state variable

    -- Define positions for the trash bins below the line
    binPositions = {
        compostable = {x = love.graphics.getWidth() / 2 - 300, y = lineY + 50},
        nonrec = {x = love.graphics.getWidth() / 2, y = lineY + 50},
        recyclable = {x = love.graphics.getWidth() / 2 + 300, y = lineY + 50}
    }

    binOrder = {"compostable", "nonrec", "recyclable"}

    -- Load bin images
    binImages = {
        compostable = love.graphics.newImage("assets/images/compost.png"),  -- Example image paths
        nonrec = love.graphics.newImage("assets/images/nonrec.png"),
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

    clickSound = love.audio.newSource("assets/audio/click.wav", "static")  -- Load click sound
end

function love.update(dt)

    backgroundTimer = backgroundTimer + dt
    if backgroundTimer >= backgroundTransitionTime then
        backgroundTimer = 0
        currentBackgroundIndex = currentBackgroundIndex % #backgroundImages + 1
    end
    
    if gameState == "menu" then
        menu.update(dt)
    end

    if gameState == "playing" then
        timer = timer + dt

        if timer >= spawnInterval then
            local newTrash = utils.spawnTrash({
                currentLevel = currentLevel,
                images = {
                    compostable = compostableImages,
                    nonrec = nonrecImages,
                    recyclable = recyclableImages
                },
                centerX = centerX,
                trashWidth = trashWidth,
                trashHeight = trashHeight
            })
            table.insert(trashItems, newTrash)
            timer = 0
        end

        -- Update trash positions and check for collisions
        for i = #trashItems, 1, -1 do
            local trash = trashItems[i]
            trash.y = trash.y + fallSpeed * dt
            trash.rotation = trash.rotation + trash.rotationSpeed * dt

            -- Check if trash is touching the line
            if trash.y + trash.height >= lineY and not trash.touchingLine then
                trash.touchingLine = true
            end

            -- Remove trash and decrease lives if it fully crosses the line
            if trash.y >= lineY + 30 then
                table.remove(trashItems, i)
                lives = lives - 1
                if lives <= 0 then
                    endGame()
                end
            end
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
        menu.draw(backgroundImages, backgroundTimer, backgroundTransitionTime, currentBackgroundIndex,  menuOptions, menuState, selectedOption, logoImage, cuteFont, menuFont)
    elseif gameState == "levelSelect" then
        levelSelect.draw({
            fonts = {
                title = titleFont,
                cute = cuteFont,
                menu = menuFont
            },
            options = levelSelectOptions,
            selectedOption = selectedLevelOption,
            backgrounds = backgroundImages,
            currentBackgroundIndex = currentBackgroundIndex,
            backgroundTimer = backgroundTimer,
            backgroundTransitionTime = backgroundTransitionTime
        })
    elseif gameState == "playing" then
        playing.drawPlaying({
            font = font,
            shakeTime = shakeTime,
            shakeMagnitude = shakeMagnitude,
            draw = draw,
            currentBackground = currentBackground,
            trashItems = trashItems,
            binImages = binImages,
            binOrder = binOrder,
            lineY = lineY,
            score = score,
            highScores = highScores,
            currentLevel = currentLevel,
            lives = lives,
            heartImage = heartImage
        })

    elseif gameState == "gameOver" then
        gameover.draw({
            fonts = {
                cute = cuteFont,
                regular = font
            },
            options = gameOverOptions,
            selectedOption = selectedGameOverOption,
            score = score,
            highScores = highScores,
            currentLevel = currentLevel
        })
    end 
    
end

function love.keypressed(key)
    if gameState == "menu" then
        menuState, selectedOption, newGameState, volume = menu.handleMenuInput(key, menuState, selectedOption, volume, levelMusic, menuOptions)
    elseif gameState == "levelSelect" then
        local result = levelSelect.handleInput({
            key = key,
            selectedOption = selectedLevelOption,
            options = levelSelectOptions,
            gameState = gameState,
            currentLevel = currentLevel
        })
    
        -- Update states based on result
        selectedLevelOption = result.selectedOption
        gameState = result.gameState
        if result.menuState then
            menuState = result.menuState
        end
        
        if result.shouldStartGame then
            currentLevel = result.currentLevel
            currentBackground = backgrounds[currentLevel]
            startGame()
        end

    elseif gameState == "playing" then
        local result = playing.handleInput({
            key = key,
            gameState = gameState,
            menuState = menuState,
            selectedOption = selectedOption,
            binOrder = binOrder,
            levelMusic = levelMusic,
            trashItems = trashItems,
            score = score,
            lives = lives,
            currentLevel = currentLevel,
            currentGradientIndex = currentGradientIndex,
            nextGradientIndex = nextGradientIndex,
            gradientColors = gradientColors,
            gradientTransitionProgress = gradientTransitionProgress,
            shakeTime = shakeTime,
            shakeDuration = shakeDuration
        })
    
        -- Update all returned states
        for k, v in pairs(result) do
            _G[k] = v
        end
    
        if result.gameOver then
            endGame()
        end

    elseif gameState == "gameOver" then 
        local result = gameover.handleInput({
            key = key,
            gameState = gameState,
            menuState = menuState,
            selectedOption = selectedOption,
            selectedLevelOption = selectedLevelOption,
            selectedGameOverOption = selectedGameOverOption,
            gameOverOptions = gameOverOptions
        })
    
        -- Update states
        gameState = result.gameState
        menuState = result.menuState
        selectedOption = result.selectedOption
        selectedLevelOption = result.selectedLevelOption
        selectedGameOverOption = result.selectedGameOverOption
    
        if result.shouldRestart then
            startGame()
        end
    end
end


function loadScreen()
    gameState = "menu"
end

function startGame()
    local resetResult = utils.resetGame({
        trashItems = trashItems,
        timer = timer,
        score = score,
        levelMusic = levelMusic,
        currentLevel = currentLevel,
        volume = volume
    })
    
    -- Update local variables with reset results
    trashItems = resetResult.trashItems
    timer = resetResult.timer
    score = resetResult.score
    
    highScores = utils.loadHighScores()
    gameState = "playing"
    lives = 3

    -- Adjust game parameters based on the selected level
    if currentLevel == "easy" then
        local bpm = 107
        local beatsPerSecond = bpm / 60
        spawnInterval = 1 / beatsPerSecond
        fallSpeed = 250
        lineY = love.graphics.getHeight() - 125
    elseif currentLevel == "medium" then
        local bpm = 117
        local beatsPerSecond = bpm / 60
        spawnInterval = 1 / beatsPerSecond
        fallSpeed = 300
        lineY = love.graphics.getHeight() - 125
    elseif currentLevel == "hard" then
        local bpm = 140
        local beatsPerSecond = bpm / 60
        spawnInterval = 1 / beatsPerSecond
        fallSpeed = 350
        lineY = love.graphics.getHeight() - 125
    end
end

-- Remove resetGame from main.lua since it's now in utils

function endGame()
    gameState = "gameOver"
    for _, music in pairs(levelMusic) do
        music:stop()
    end

   if score > highScores[currentLevel] then
        highScores[currentLevel] = score
        utils.saveHighScores(highScores)
    end
end
