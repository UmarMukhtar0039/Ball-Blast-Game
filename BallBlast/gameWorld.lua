local composer = require("composer")
local gameWorld = composer.newScene()
gameWorld.gameState = nil

local playerMaker = require("player")
local obstacleMaker = require("obstacle")
local bulletMaker = require("bullet")
local deltaTime = require("helperScripts.deltaTime")
local collisionHandler = require("helperScripts.collisionHandler")
local printDebugStmt = require("helperScripts.printDebugStmt")
local soundManager = require("soundManager")
local preferenceHandler=require("helperScripts.preferenceHandler")
local gameplayManager=require("gameplayManager")
local particleSystem=require("helperScripts.particleSystem")
local assetName=require("helperScripts.assetName")
local inGameUI=require("inGameUI")
local messageService=require("helperScripts.messageService")

---------local vars---------
local width = display.contentWidth
local height = display.contentHeight
local player -- player object
local obstacles -- obstacles queue
local leftWall  -- rectangle at left side of screen where collision is possible
local rightWall -- rectangle at right side of screen where collision is possible
local base -- rectangle at the bottom of screen where collision is possible
local obstacleSpawnTimer, obstacleSpawnTimeLimit -- obstacle spawn time limit
local bulletTimer, bulletTimeLimit -- bullet spawn time limit
local xPositions -- of obstacles
local bullets -- bullets queue that contains bullets on screen
local bulletsPool-- pool that will contain prespawned bullets
local finishTimer, finishTimeLimit -- time limit to triggerFinish
local confettiEmitterLeft -- Emitter that will emit from left side of screen
local confettiEmitterRight --Emitter that will emit from right side of screen
local speakers -- contains refernce of speakers in the game (for proximity sounds)
local readyTimer
local readyTimeLimit -- time after which game state will be set to running
local readyText

---------displayGroups---------
local masterGroup -- will contain all displayGroups
local playerGroup 
local obstacleGroup 
local bulletGroup
local UIGroup -- displayGroup for UI Elements
---------fwd references---------
local updatePlayer -- function that will call player's update function
local updateObstacles -- function that will call obstacle's update function
local updateBullets
local makeGameOverMenu
local playProximitySounds -- function to play ProximitySounds
------------------------

-- update of gameWorld
local function update()
	local dt = deltaTime.getDelta()
	
	if gameWorld.gameState == "triggerFinish" then
		finishTimer = finishTimer + dt -- for trigger finish after finishTimeLimit
		if finishTimer >= finishTimeLimit then
			gameWorld.gameState = "suspended"
			makeGameOverMenu()
		end
		return
	end

	if gameWorld.gameState == "suspended" then
			confettiEmitterLeft:update(dt)
			confettiEmitterRight:update(dt)
		return
	end

	if gameWorld.gameState=="ready" then
		readyTimer=readyTimer+dt

		-- readyText.text=math.round(readyTimer)
		if readyTimer>=readyTimeLimit then
			printDebugStmt.print("running")
			gameWorld.gameState="running"
		end
		return
	end

	gameplayManager.update()	
	updateObstacles(dt)
	updatePlayer(dt)
	updateBullets(dt)	
	playProximitySounds()
end

------------------------
-- updates all the obstacles every frame
function updateObstacles(dt)

	obstacleSpawnTimer = obstacleSpawnTimer + dt
	-- obstacles spawning
	if obstacleSpawnTimer > obstacleSpawnTimeLimit then -- spawning should begin
		--creating new obstacle and adding it to the obstacles queue
		local selector = math.random(#xPositions) -- select any random position on x-axis
		obstacles[#obstacles+1] = obstacleMaker.new("circle", xPositions[selector], 0) 
	 	obstacleSpawnTimer = 0 -- reset timer
	end



	-- update obstacles 
	for i=#obstacles,1,-1 do
		obstacles[i]:update(dt)	
		
		-- checking left and rightWall collision
		if collisionHandler.hasCollided(obstacles[i], leftWall) then
			if obstacles[i].VX < 0 then -- if collided with left wall then always give it positive velocity
				obstacles[i].VX = -obstacles[i].VX -- give it a positive velocity
			end
		elseif collisionHandler.hasCollided(obstacles[i], rightWall) then
			if obstacles[i].VX >0 then -- if obstacle collided with right wall then always give it a negative velocity		
				obstacles[i].VX = -obstacles[i].VX -- give it a negative velocity
			end
		end

		-- checking collision of obstacle with bullets
		for j=1,#bullets do
			if collisionHandler.circlePoint(obstacles[i], bullets[j]) then-- circle point collison
				-- bullet has collided with obstacle
				obstacles[i].life = obstacles[i].life - bullets[j].damage -- reduce obstacles life on collision
				bullets[j]:disableBullet()
				soundManager.playBulletHitSound(obstacles[i])
			end
		end

		if obstacles[i].removeMe == true then -- if it goes out of bounds remove it
			local temp = table.remove(obstacles, i)
			temp:destroyImages()
			temp = nil
		end
	end
end

------------------------

function updatePlayer(dt)
	player:update(dt)
	-- checking obstacle and player collision
	for i=1,#obstacles do
		if collisionHandler.hasCollided(player,obstacles[i]) then
			gameWorld.gameState = "triggerFinish"			
			break
		end		
	end
end

------------------------

function updateBullets(dt)

	bulletTimer = bulletTimer + dt
	-- displaying prespawned bullets
	if bulletTimer > bulletTimeLimit then
		bullets[#bullets+1] = table.remove(bulletsPool,1) -- add bullet to bullets queue(i.e on display) and remove it from bulletsPool
		bullets[#bullets].x = player.x
		bullets[#bullets].y = player.y - 10
		bulletTimer = 0
		soundManager.playBulletSound()--now play bullet Shoot sound
	end

	-- updating bullets
	for i=#bullets,1,-1 do
		bullets[i]:update(dt)

		if bullets[i].removeMe then
			bullets[i]:sendToPool()
			bulletsPool[#bulletsPool + 1] = table.remove(bullets, i)
		end
	end

end

------------------------

function playProximitySounds()
	local infinity=300
	local minDisSQ= (player.x-speakers[1].x)^2 + (player.y-speakers[1].y)^2
	local infinitySQ=infinity^2
	
	for i=1,#speakers do
		local minDisPlayerSQ=(player.x-speakers[i].x)^2 + (player.y-speakers[i].y)^2
		if minDisSQ> minDisPlayerSQ then
			minDisSQ=minDisPlayerSQ
		end
	end
	soundManager.setBackgroundVolume(minDisSQ, infinitySQ)
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

-- called to make a gameOverMenu menu
function makeGameOverMenu()
	local bestScore = player.score
	
	if preferenceHandler.get("bestScore")<player.score then
		preferenceHandler.set("bestScore",bestScore)

		--forcing single emission
		confettiEmitterLeft.forceSingleEmission=true
		confettiEmitterRight.forceSingleEmission=true			
		-- printDebugStmt.print(" HighScore: "..bestScore)
		
	end

	local menuBox = display.newRect(UIGroup, display.contentCenterX, display.contentCenterY-400 , 400, 400) -- box to be displayed+
	menuBox.alpha = 0.2 
	
	local menuText = display.newText(UIGroup,"GameOver", menuBox.x, menuBox.y - 50) -- title
	
	local function gotoMainMenu( ) -- on tapping on resume Button we want to goto gameWorld screen
		menuText:removeEventListener("tap", gotoMainMenu) -- remove listeners after removing the button
		composer.gotoScene("Screens.mainMenu", {effect = "fade", params = {callingScene="gameWorld"}})
	end

	menuText:addEventListener("tap", gotoMainMenu)	
end

------------------------

local function initBackground()
	leftWall.contentBound = {xMin = -0.5, xMax = 0, yMin = 0, yMax = height} -- contentBound of left wall
	rightWall.contentBound = {xMin = width, xMax = width+0.5 , yMin = 0, yMax = height} -- contentBound of right wall
	base.contentBound = {xMin = 0, xMax = width, yMin = height * 0.80, yMax = height} -- contentBound of base
	-- base.image = display.newRect(obstacleGroup, (base.contentBound.xMin+base.contentBound.xMax)*0.5,(base.contentBound.yMin+base.contentBound.yMax)*0.5, base.contentBound.xMax-base.contentBound.xMin, base.contentBound.yMax-base.contentBound.yMin)
	-- base.image.alpha=0.3
	--For Debug only--
	-- leftWall.debugImage = display.newRect(obstacleGroup,(leftWall.contentBound.xMin+leftWall.contentBound.xMax)*0.5, (leftWall.contentBound.yMin + leftWall.contentBound.yMax)*0.5, leftWall.contentBound.xMax - leftWall.contentBound.xMin, leftWall.contentBound.yMax - leftWall.contentBound.yMin)
	-- leftWall.debugImage:setFillColor(1,0,0)
	-- rightWall.debugImage= display.newRect(obstacleGroup,(rightWall.contentBound.xMin+rightWall.contentBound.xMax)*0.5, (rightWall.contentBound.yMin + rightWall.contentBound.yMax) * 0.5, rightWall.contentBound.xMax - rightWall.contentBound.xMin, rightWall.contentBound.yMax - rightWall.contentBound.yMin)
	-- rightWall.debugImage:setFillColor(0,1,0)
end

------------------------

-- init of gameWorld
function gameWorld:create(event)
	composer.removeScene(event.params.callingScene) -- remove the screen from where gotoScreen was called
	--init all Display Groups
	masterGroup = display.newGroup()
	playerGroup = display.newGroup()
	obstacleGroup = display.newGroup()
	bulletGroup = display.newGroup()
	UIGroup = display.newGroup()
	masterGroup:insert(playerGroup)
	masterGroup:insert(obstacleGroup)
	masterGroup:insert(bulletGroup)


	local sceneGroup = self.view
	sceneGroup:insert(masterGroup)
	sceneGroup:insert(UIGroup)

	-- init background
	leftWall = {}
	rightWall = {}
	base = {}
	initBackground()
	
	-- init player
	playerMaker.displayGroup = playerGroup
	player = playerMaker.new("something", width * 0.5, height * 0.75) -- gets an object i.e. player 
	
	--init gameplayManager
	obstacles = {} -- table that contains all the obstacles

	gameplayManager.displayGroup=UIGroup
	gameplayManager.init(player,obstacles)
	
	-- init obstacle
	xPositions = { 100, 300, 500, 650}
	obstacleSpawnTimer = 0
	obstacleSpawnTimeLimit = 1.5
	obstacleMaker.displayGroup = obstacleGroup
	obstacleMaker.player = player -- give reference of player to all obstacles table

	--init bullets vars-------------
	bulletTimer = 0
	bulletTimeLimit = 0.1 
	bulletMaker.displayGroup = bulletGroup
	bullets = {} -- bullets table will contain display object and velocity
	bulletsPool = {}

	-- spawning bullets and pooling them in bullet pool
	for i=1,15 do
		bulletsPool[#bulletsPool + 1] = bulletMaker.new( 5000,5000)--player.x, player.y - 10)
	end

	finishTimer = 0
	finishTimeLimit = 2
	gameWorld.gameState = "ready" -- initially the game state will by ready



	--Making emmiters--------------------
	-- Emit from left Side of screen
	confettiEmitterLeft=particleSystem.new({name="HighScore",displayGroup=UIGroup,count=15,emissionRate=1,startColor={r=1,g=1,b=1,a=1},angle=60,
	colorVarStart={{r=0,g=1,b=1,a=1},{r=1,g=0,b=0,a=1},{r=0,b=1,g=1,a=1},{r=0,b=1,g=0,a=1},{r=0,b=0,g=1,a=1},{r=1,b=0,g=1,a=1},{r=1,b=1,g=0,a=1}}, 
	x=10,y=height-200,xVar=100,life=3, yVar=300, vX=200, vxVar=250, vY=-800, vYVar=300,gravity=1000,
	particlePath={assetName.confettiParticle1,assetName.confettiParticle2,assetName.confettiParticle3}})

	-- Emit from right side of screen
	confettiEmitterRight=particleSystem.new({name="HighScore",displayGroup=UIGroup,count=15,emissionRate=1,startColor={r=1,g=1,b=1,a=1},
		colorVarStart={{r=0,g=1,b=1,a=1},{r=1,g=0,b=0,a=1},{r=0,b=1,g=1,a=1},{r=0,b=1,g=0,a=1},{r=0,b=0,g=1,a=1},{r=1,b=0,g=1,a=1},{r=1,b=1,g=0,a=1}}, 
		x=width-10,y=height-300,xVar=100,life=3, yVar=300, vX=-200, vxVar=250, vY=-800, vYVar=300,gravity=1000,
		particlePath={assetName.confettiParticle1,assetName.confettiParticle2,assetName.confettiParticle3}})		
	---------------------------------------
	
	speakers={}
	speakers[#speakers+1]=display.newImage(UIGroup,assetName.speaker,50,850)
	speakers[#speakers+1]=display.newImage(UIGroup,assetName.speaker,width-50,850)
	
	-- playBackGround music sound
	soundManager.playBackgroundMusic()

	-- init inGameUI and makeControlMenu
	inGameUI.displayGroup=UIGroup 
	inGameUI.init(gameWorld,player)
	inGameUI.makeControlMenu()

	-- time after which game state will be set to running
	readyTimer=0
	readyTimeLimit=3

	messageService.showMessage(UIGroup,{text=3,x=display.contentCenterX,y=display.contentCenterY,time = 1000, color={r=1,g=0,b=0}})						
	messageService.showMessage(UIGroup,{text=2,x=display.contentCenterX,y=display.contentCenterY,time = 1000, color={r=1,g=0,b=0}})						
	messageService.showMessage(UIGroup,{text=1,x=display.contentCenterX,y=display.contentCenterY,time = 1000, color={r=1,g=0,b=0}})						
	messageService.showMessage(UIGroup,{text="GO!",x=display.contentCenterX,y=display.contentCenterY,time = 1000, color={r=1,g=0,b=0}})						

	Runtime:addEventListener("key",onKeyEvent)
	Runtime:addEventListener("enterFrame", update)
end

------------------------
-- called from external script when this scene is destroyed
function gameWorld:destroy(event)
	soundManager.stopBackgroundMusic()
	Runtime:removeEventListener("enterFrame",update)
	Runtime:removeEventListener("key", onKeyEvent)
end

gameWorld:addEventListener("create", gameWorld)
gameWorld:addEventListener("destroy", gameWorld)

return gameWorld