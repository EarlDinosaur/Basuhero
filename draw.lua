local draw = {}

function draw.drawHearts(lives, heartImage)
    local heartSize = 30  -- Desired size of the heart in pixels
    local heartX = love.graphics.getWidth() - heartSize - 40  -- Starting X position for the hearts (20px padding from the right)
    local heartY = 60  -- Y position for the hearts
    local spacing = heartSize + 10  -- Spacing between hearts (10px padding)

    for i = 1, lives do
        love.graphics.draw(
            heartImage,
            heartX - (i - 1) * spacing,  -- Adjust X position for each heart
            heartY,
            0,  -- No rotation
            heartSize / heartImage:getWidth(),  -- Scale X to 30px
            heartSize / heartImage:getHeight()  -- Scale Y to 30px
        )
    end
end

function draw.drawBins(binImages, binOrder, lineY)
    local centerX = love.graphics.getWidth() / 2
    local binY = lineY + 70
    local labelY = binY + 1  -- Position for labels above bins
    local font = love.graphics.getFont()
    local textScale = 1.4  -- Adjust this value to change text size


    for i, binType in ipairs(binOrder) do
        -- Adjust position based on the order of bins
        local xOffset = (i - 2) * 300  -- Left, Center, Right positions
        local xPosition = centerX + xOffset
        local binImage = binImages[binType]
       
        -- Draw the bin
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(binImage, xPosition, binY, 0, 1, 1, binImage:getWidth() / 2, binImage:getHeight() / 2)

         -- Draw label with scale
         local label = string.upper(binType)
         local labelWidth = font:getWidth(label) * textScale
         
         -- Save current graphics state
         love.graphics.push()
         love.graphics.translate(xPosition - labelWidth/2, labelY)
         love.graphics.scale(textScale, textScale)
 
         -- Draw text outline
         love.graphics.setColor(0, 0, 0)
         love.graphics.print(label, -1, -1)
         love.graphics.print(label, 1, -1)
         love.graphics.print(label, -1, 1)
         love.graphics.print(label, 1, 1)
         
         -- Draw main text
         love.graphics.setColor(1, 1, 1)
         love.graphics.print(label, 0, 0)
 
         -- Restore graphics state
         love.graphics.pop()
    end
end

function draw.drawLevelBackground(currentBackground)
    love.graphics.setColor(1, 1, 1, 0.5)  -- Reset color to white for proper image rendering
    if currentBackground then
        -- Scale the background to fit the screen
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local scaleX = screenWidth / currentBackground:getWidth()
        local scaleY = screenHeight / currentBackground:getHeight()
        love.graphics.draw(currentBackground, 0, 0, 0, scaleX, scaleY)
    end
end




return draw