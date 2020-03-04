local obstacle = {
    displayGroup = nil,
    shadowGroup = nil,
}
local typesMap = require("obstacleTypesMap")
local particleSystem = require("helperScripts.particleSystem")
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
        life = nil, -- actual life in numerics
        lifeInGrade = nil, -- life in graphics
        lifeInGradesSprite = nil, -- sprite to hold the anim sprite
        removeMe = false,
        outOfBound = false, -- if obstacle goes out of bound delete it's display
        contentBound = { x = nil, y = nil, r = nil},
        emitter = nil, -- on detruction start emmiting particles
        isActive = true, -- used to indicate if object is in active state or not, in-active state is when the obstacle life becomes 0
        isSensor = false, -- to sensor means it should not respond to collision
    }

    newObstacle = typesMap.makeObstacle(newObstacle, obstacle.displayGroup)

    return setmetatable(newObstacle, obstacle_mt)
end

---------------------------

function obstacle:updateBound( )
    self.contentBound.x = self.x
    self.contentBound.y = self.y 
end

---------------------------

-- when we bind a certain function to a particular table then it should not be local
function obstacle.updateImage(self)
    self.sprite.x = self.x
    self.sprite.y = self.y
    self.lifeInGradesSprite.x = self.x + 10
    self.lifeInGradesSprite.y = self.y - 10
    self.lifeInGradesSprite:setFrame(self.lifeInGrade+1)

    -- if not active then set alpha to 0 
    if not self.isActive then
        self.sprite.alpha = 0
        self.lifeInGradesSprite.alpha = 0
    end
    -- self.sprite.alpha = self.y/200 -- setting alpha w.r.t the players position, if player is at 700 it's alpha will be 1
end

---------------------------

function obstacle:updateEmitter( dt )
    self.emitter:update(dt)
end
---------------------------

-- updating model and view of obstacle, called every frame from an external script
function obstacle.update(self, playerVY, dt)

    self.x = self.x + self.VX  * dt
    self.y = self.y + self.VY  * dt

    self.lifeInGrade = math.round((self.life/self.totalLife)*5) -- life grade should be atmost 5

    -- going beyond screen, remove it
    if self.y > display.contentHeight - 100 then--+ self.width * 0.5 then
        self.removeMe = true
    end

    if self.life <= 0 and self.isActive then 
        self.emitter.x = self.x
        self.emitter.y = self.y 
        self.emitter.forceSingleEmission = true
        self.isActive = false 
        self.isSensor = true
    end

    self:updateBound()
    self.updateImage(self)
    self:updateEmitter(dt)
end

---------------------------

-- destorying all sprites of obstacle
function obstacle:destroyImages( )
    self.sprite:removeSelf()
    self.sprite = nil
    self.lifeInGradesSprite:removeSelf()
    self.lifeInGradesSprite = nil
    
end


return obstacle