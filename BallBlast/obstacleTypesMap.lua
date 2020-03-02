local obstacleTypesMap = {}

function obstacleTypesMap.makeObstacle( obstacle, displayGroup )
    local xVelocity = { -225, 0,120 , 225}
    if obstacle.type == "circle" then
        local selector = math.random(#xVelocity)
        obstacle.sprite = display.newCircle(displayGroup, obstacle.x, obstacle.y, 50) 
        obstacle.sprite.x = obstacle.x
        obstacle.sprite.y = obstacle.y
        obstacle.VX = xVelocity[selector]
        -- collision bounds
        obstacle.contentBound.x = obstacle.x
        obstacle.contentBound.y = obstacle.y
        obstacle.contentBound.r = obstacle.sprite.path.radius
    ---------------------------
   
    end

    return obstacle
end

return obstacleTypesMap