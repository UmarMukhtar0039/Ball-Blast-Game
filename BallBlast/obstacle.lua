local obstacle = {
    displayGroup = nil,
    shadowGroup = nil,
}
local typesMap = require("obstacleTypesMap")

local obstacle_mt = {__index = obstacle}

---------------------------
-- creates a new instance
function obstacle.new(type, x, y)
    local newObstacle = {
        type = type,
        x = x,
        y = y,
        VX = nil, -- set in types map
        VY = 200,
        height = nil,
        width = nil,
        sprite = nil,
        outOfBound = false, -- if obstacle goes out of bound delete it's display
        contentBound = { x = nil, y = nil, r = nil}
    }

    newObstacle = typesMap.makeObstacle(newObstacle, obstacle.displayGroup)

    return setmetatable(newObstacle, obstacle_mt)
end

---------------------------

function obstacle:updateBound( )
    self.contentBound.x = self.x
    self.contentBound.y = self.y 
end

-- when we bind a certain function to a particular table then it should not be local
function obstacle.updateImage(self)
    self.sprite.x = self.x
    self.sprite.y = self.y
    -- self.sprite.alpha = self.y/200 -- setting alpha w.r.t the players position, if player is at 700 it's alpha will be 1
end

---------------------------

-- updating model and view of obstacle, called every frame from an external script
function obstacle.update(self, playerVY, dt)
    self.x = self.x + self.VX  * dt
    self.y = self.y + self.VY  * dt

    -- going beyond screen, remove it
    if self.y > display.contentHeight - 100 then--+ self.width * 0.5 then
        self.outOfBound = true
    end

    self:updateBound()   
    self.updateImage(self)  
end

---------------------------
-- destorying all sprites of obstacle
function obstacle:destroyImages( )
    self.sprite:removeSelf()
    self.sprite = nil
end


return obstacle