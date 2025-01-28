local utils = {}

function utils.spawnTrash(params)
    local trashType
    local trashImage
    local types = {"compostable", "nonrec", "recyclable"}
    trashType = types[math.random(#types)]

    -- Select image based on level and type
    if params.currentLevel == "easy" then
        if trashType == "compostable" then
            trashImage = params.images.compostable[1]
        elseif trashType == "nonrec" then
            trashImage = params.images.nonrec[1]
        elseif trashType == "recyclable" then
            trashImage = params.images.recyclable[1]
        end
    elseif params.currentLevel == "medium" then
        if trashType == "compostable" then
            trashImage = params.images.compostable[math.random(1,2)]
        elseif trashType == "nonrec" then
            trashImage = params.images.nonrec[math.random(1,2)]
        elseif trashType == "recyclable" then
            trashImage = params.images.recyclable[math.random(1,2)]
        end
    elseif params.currentLevel == "hard" then
        if trashType == "compostable" then
            trashImage = params.images.compostable[math.random(#params.images.compostable)]
        elseif trashType == "nonrec" then
            trashImage = params.images.nonrec[math.random(#params.images.nonrec)]
        elseif trashType == "recyclable" then
            trashImage = params.images.recyclable[math.random(#params.images.recyclable)]
        end
    end

    local trash = {
        x = params.centerX,
        y = -params.trashHeight,
        width = params.trashWidth,
        height = params.trashHeight,
        type = trashType,
        image = trashImage,
        rotation = 0,
        rotationSpeed = math.random(-2, 2) * math.pi / 3,
        touchingLine = false
    }
    
    return trash
end

function utils.playLevelMusic(params)
    -- Stop any currently playing music
    for _, music in pairs(params.levelMusic) do
        music:stop()
    end
    
    if params.levelMusic[params.level] then
        params.levelMusic[params.level]:setVolume(params.volume.music)
        params.levelMusic[params.level]:setLooping(true)
        params.levelMusic[params.level]:play()
    end
end

function utils.loadHighScores()
    local highScores = { easy = 0, medium = 0, hard = 0 }
    
    if love.filesystem.getInfo("highScores.txt") then
        local contents = love.filesystem.read("highscores.txt")
        local easy, medium, hard = contents:match("(%d+)\n(%d+)\n(%d+)")
        highScores.easy = tonumber(easy) or 0
        highScores.medium = tonumber(medium) or 0
        highScores.hard = tonumber(hard) or 0
    end
    
    return highScores
end

function utils.saveHighScores(highScores)
    local data = string.format("%d\n%d\n%d", 
        highScores.easy, 
        highScores.medium, 
        highScores.hard
    )
    love.filesystem.write("highscores.txt", data)
end

function utils.resetGame(params)
    params.trashItems = {}
    params.timer = 0
    params.score = 0
    utils.playLevelMusic({
        levelMusic = params.levelMusic,
        level = params.currentLevel,
        volume = params.volume
    })
    return params
end

function utils.serializeTable(tbl)
    local result = "{\n"
    for k, v in pairs(tbl) do
        result = result .. string.format("    %s = %d,\n", k, v)
    end
    result = result .. "}"
    return result
end

return utils