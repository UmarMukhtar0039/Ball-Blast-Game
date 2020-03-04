local obstacleTypesMap = {}

local assetName = require("helperScripts.assetName")
local animationService = require("helperScripts.animationService")

function obstacleTypesMap.makeObstacle( obstacle, displayGroup )
    local xVelocity = { -225, 0,120 , 225}
    local colour = { {r= 1,g=0,b=0}, {r=0,g=1,b=0}, {r=0,g=0,b=1},{r=1,g=0,b=1}}
    if obstacle.type == "circle" then
        local lifeSheet = graphics.newImageSheet(assetName.obstacleLifeInGrade, {width=80, height=40, numFrames =6,sheetContentWidth=480,sheetContentHeight =40})
        local lifeAnimSequeunce = {
            name="life",
            start=1,
            count=6,
            loopCount=1,
            loopDirection="forward"
        }

        local selector = math.random(#xVelocity)
        obstacle.sprite = display.newCircle(displayGroup, obstacle.x, obstacle.y, 50)
        obstacle.sprite:setFillColor(colour[selector].r, colour[selector].g, colour[selector].b) 
        obstacle.sprite.x = obstacle.x
        obstacle.sprite.y = obstacle.y
        obstacle.VX = xVelocity[selector]
        -- setting up life 
        obstacle.life = 100
        obstacle.totalLife = obstacle.life
        obstacle.lifeInGrade = (obstacle.life / obstacle.totalLife) * 5 -- bcz we have 5 stripes
        obstacle.lifeInGradesSprite = animationService.newSprite(displayGroup, lifeSheet, lifeAnimSequeunce)
        obstacle.lifeInGradesSprite.x = obstacle.x
        obstacle.lifeInGradesSprite.y = obstacle.y
        obstacle.lifeInGradesSprite:setFrame(6)
        obstacle.lifeInGradesSprite:play();

        -- collision bounds
        obstacle.contentBound.x = obstacle.x
        obstacle.contentBound.y = obstacle.y
        obstacle.contentBound.r = obstacle.sprite.path.radius
    ---------------------------
   
    end

    return obstacle
end

return obstacleTypesMap