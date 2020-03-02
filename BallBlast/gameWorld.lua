local gameWorld = {}

local playerMaker = require("player")
local obstacleMaker = require("obstacle")
local bulletMaker = require("bullet")
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
local timeLimit = 3 -- spawn time limit
local bulletTimer = 0
local bulletTimeLimit = 0.12 
local xPositions = { 100, 300, 500, 650}
local vxObstacles = { -225, 0,220 , 225}
local bullets -- bullets queue that contains bullets on screen
local bulletsPool = {}-- pool that will contain prespawned bullets

---------displayGroups---------
local masterGroup -- will contain all displayGroups
local playerGroup 
local obstacleGroup 
local bulletGroup
---------fwd references---------
local updatePlayer -- function that will call player's update function
local updateObstacles -- function that will call obstacle's update function
local updateBullets

------------------------

-- update of gameWorld
local function update()
	local dt = deltaTime.getDelta()

	timer = timer + dt
	bulletTimer = bulletTimer + dt

	-- obstacles spawning
	if timer > timeLimit then -- spawning should begin
		--creating new obstacle and adding it to the obstacles queue
		local selector = math.random(#xPositions) -- select any random position on x-axis
		obstacles[#obstacles+1] = obstacleMaker.new("circle", xPositions[selector], 100) 
	 	timer = 0 -- reset timer
	end

	updatePlayer(dt)

	-- displaying prespawned bullets
	if bulletTimer > bulletTimeLimit then
		bullets[#bullets+1] = table.remove(bulletsPool,1) -- add bullet to bullets queue(i.e on display) and remove it from bulletsPool
		bullets[#bullets].x = player.x
		bullets[#bullets].y = player.y - 10
		bulletTimer = 0
	end

	updateBullets(dt)
	print("GW: bullets: "..#bullets.. " pool: ".. #bulletsPool)
	updateObstacles(dt)
end

------------------------

function updatePlayer(dt)
	player:update(dt)
	
end

------------------------

function updateBullets(dt)
-- updating bullets
	for i=#bullets,1,-1 do
		bullets[i]:update(dt)
		if bullets[i].removeMe == true then
			bullets[i]:sendToPool()
			bulletsPool[#bulletsPool + 1] = table.remove(bullets, i)
		end
	end
end
------------------------
-- updates all the obstacles every frame
function updateObstacles(dt)
	for i=#obstacles,1,-1 do
		obstacles[i]:update(player.VY, dt)
		
		if obstacles[i].outOfBound == true then -- if it goes out of bounds remove it
			obstacles[i]:destroyImages()
			table.remove(obstacles, i)
		elseif collisionHandler.hasCollided(obstacles[i], leftWall) then
			if obstacles[i].VX < 0 then -- if collided with left wall then always give it positive velocity
				obstacles[i].VX = -obstacles[i].VX -- give it a positive velocity
			end
		elseif collisionHandler.hasCollided(obstacles[i], rightWall) then
			if obstacles[i].VX >0 then -- if obstacle collided with right wall then always give it a negative velocity		
				obstacles[i].VX = -obstacles[i].VX -- give it a negative velocity
			end
		end
	 	
	end
end

------------------------

-- setting player's direction on pressing keys
local function onKeyEvent(event)
	if event.phase == "down" then
		if event.keyName == 'a' then
			player.dir = 'l'
		elseif event.keyName == 'd' then
			player.dir = 'r'
		end 
	end
	if event.phase == "up" then
		player.dir = nil
	end

end

------------------------

local function initBackground()
	leftWall.contentBound = {xMin = -0.5, xMax = 0, yMin = 0, yMax = height} -- contentBound of left wall
	rightWall.contentBound = {xMin = width, xMax = width+0.5 , yMin = 0, yMax = height} -- contentBound of right wall
	base.contentBound = {xMin = 0, xMax = width, yMin = height * 0.80, yMax = height} -- contentBound of base
	base.image = display.newRect(obstacleGroup, (base.contentBound.xMin+base.contentBound.xMax)*0.5,(base.contentBound.yMin+base.contentBound.yMax)*0.5, base.contentBound.xMax-base.contentBound.xMin, base.contentBound.yMax-base.contentBound.yMin)
	
	--For Debug only--
	leftWall.debugImage = display.newRect(obstacleGroup,(leftWall.contentBound.xMin+leftWall.contentBound.xMax)*0.5, (leftWall.contentBound.yMin + leftWall.contentBound.yMax)*0.5, leftWall.contentBound.xMax - leftWall.contentBound.xMin, leftWall.contentBound.yMax - leftWall.contentBound.yMin)
	leftWall.debugImage:setFillColor(1,0,0)
	rightWall.debugImage= display.newRect(obstacleGroup,(rightWall.contentBound.xMin+rightWall.contentBound.xMax)*0.5, (rightWall.contentBound.yMin + rightWall.contentBound.yMax) * 0.5, rightWall.contentBound.xMax - rightWall.contentBound.xMin, rightWall.contentBound.yMax - rightWall.contentBound.yMin)
	rightWall.debugImage:setFillColor(0,1,0)
end

------------------------

-- init of gameWorld
local function init()
	--init all Display Groups
	masterGroup = display.newGroup()
	playerGroup = display.newGroup()
	obstacleGroup = display.newGroup()
	bulletGroup = display.newGroup()
	masterGroup:insert(playerGroup)
	masterGroup:insert(obstacleGroup)
	masterGroup:insert(bulletGroup)

	-- init player
	playerMaker.displayGroup = playerGroup
	player = playerMaker.new("something", width * 0.5, height * 0.75) -- gets an object i.e. player 
	bullets = {} -- bullets table will contain display object and velocity

	-- init obstacle
	obstacleMaker.displayGroup = obstacleGroup
	obstacles = {} -- table that contains all the obstacles

	--init bullets-------------
	bulletMaker.displayGroup = bulletGroup
	bullets = {}
	-- spawning bullets and pooling them in bullet pool
	for i=1,15 do
		bulletsPool[#bulletsPool + 1] = bulletMaker.new( 5000,5000)--player.x, player.y - 10)
	end

	-- init background
	leftWall = {}
	rightWall = {}
	base = {}
	initBackground()

end

------------------------
init()

Runtime:addEventListener("key",onKeyEvent)
Runtime:addEventListener("enterFrame", update)


return gameWorld