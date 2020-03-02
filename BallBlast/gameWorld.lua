local gameWorld = {}

-- local playerMaker = require("player")
local obstacleMaker = require("obstacle")
local deltaTime = require("helperScripts.deltaTime")
local collisionHandler = require("helperScripts.collisionHandler")
local printDebugStmt = require("helperScripts.printDebugStmt")


---------local vars---------
local width = display.contentWidth
local height = display.contentHeight
local player -- player object
local obstacles -- obstacles queue
local leftWall  -- rectangle at left side of screen where collision is possible
local rightWall -- rectangle at right side of screen where collision is possible
local base -- rectangle at the bottom of screen where collision is possible
local timer = 0
local timeLimit = 0.5 -- spawn time limit
local xPositions = { 100, 300, 500, 650}
local vxObstacles = { -250, 0,200 , 25}

---------displayGroups---------
local masterGroup -- will contain all displayGroups
local playerGroup 
local obstacleGroup 

---------fwd references---------
local updatePlayer -- function that will call player's update function
local updateObstacle -- function that will call obstacle's update function
local onTap

------------------------
-- update of gameWorld
local function update()
	local dt = deltaTime.getDelta()

	timer = timer + dt
	if timer > timeLimit then -- spawning should begin
		local selector = math.random(#xPositions)
		obstacles[#obstacles+1] = display.newCircle(obstacleGroup, xPositions[selector], 100, 50) 
		obstacles[#obstacles].contentBound = { x = obstacles[#obstacles].x, y=obstacles[#obstacles].y, r = obstacles[#obstacles].path.radius } 
	 	obstacles[#obstacles].VX = vxObstacles[selector]
		obstacles[#obstacles].VY = 200
	 	timer = 0
	end
	
	-- updatePlayer(dt)
	updateObstacle(dt)
end

------------------------

function updatePlayer(dt)
	player.update(dt)
end

------------------------
-- updates all the obstacles every frame
function updateObstacle(dt)
	for i=#obstacles,1,-1 do
		-- obstacles[i]:update(dt)
		obstacles[i].x = obstacles[i].x + obstacles[i].VX * dt
		obstacles[i].y = obstacles[i].y + obstacles[i].VY * dt
		obstacles[i].contentBound.x = obstacles[i].x -- update Content bound
		obstacles[i].contentBound.y = obstacles[i].y
		
		if collisionHandler.circleRect(obstacles[i], leftWall)  then
			obstacles[i].VX = -obstacles[i].VX		
		end
		if collisionHandler.circleRect(obstacles[i], rightWall) then
			obstacles[i].VX = -obstacles[i].VX		
		end
		print(i,obstacles[i].VX)

		if obstacles[i].y > height - 100 then
			local temp = table.remove(obstacles,i)
			temp:removeSelf()
			temp = nil
		end
	end
end

------------------------

local function initBackground()
	leftWall.contentBound = {xMin = 0, xMax = 10, yMin = 0, yMax = height} -- contentBound of left wall
	rightWall.contentBound = {xMin = width-10, xMax = width , yMin = 0, yMax = height} -- contentBound of right wall
	base.contentBound = {xMin = 0, xMax = width, yMin = height * 0.80, yMax = height} -- contentBound of base
	-- base.image = display.newRect(obstacleGroup, (base.contentBound.xMin+base.contentBound.xMax)*0.5,(base.contentBound.yMin+base.contentBound.yMax)*0.5, base.contentBound.xMax-base.contentBound.xMin, base.contentBound.yMax-base.contentBound.yMin)
	
	--For Debug only--
	leftWall.debugImage = display.newRect(obstacleGroup,(leftWall.contentBound.xMin+leftWall.contentBound.xMax)*0.5, (leftWall.contentBound.yMin + leftWall.contentBound.yMax)*0.5, leftWall.contentBound.xMax - leftWall.contentBound.xMin, leftWall.contentBound.yMax - leftWall.contentBound.yMin)
	leftWall.debugImage:setFillColor(1,0,0)
	rightWall.debugImage= display.newRect(obstacleGroup,(rightWall.contentBound.xMin+rightWall.contentBound.xMax)*0.5, (rightWall.contentBound.yMin + rightWall.contentBound.yMax) * 0.5, rightWall.contentBound.xMax - rightWall.contentBound.xMin, rightWall.contentBound.yMax - rightWall.contentBound.yMin)
	rightWall.debugImage:setFillColor(0,1,0)
end

------------------------

function onTap( event )
	event.target:removeSelf()
end



------------------------

-- init of gameWorld
local function init()
	--init all Display Groups
	masterGroup = display.newGroup()
	playerGroup = display.newGroup()
	obstacleGroup = display.newGroup()
	masterGroup:insert(playerGroup)
	masterGroup:insert(obstacleGroup)

	-- init player
	-- playerMaker.displayGroup = playerGroup
	-- player = playerMaker.new("something", width * 0.5, height * 0.80) -- gets an object i.e. player 
	
	-- init obstacle
	obstacleMaker.displayGroup = obstacleGroup
	obstacles = {} -- queue that contains all the obstacles

	-- init background
	leftWall = {}
	rightWall = {}
	base = {}
	initBackground()
end

------------------------
init()

Runtime:addEventListener("enterFrame", update)
Runtime:addEventListener("tap", onTap)

return gameWorld