local soundManager = {}

local printDebugStmt = require("helperScripts.printDebugStmt")
local assetName=require("helperScripts.assetName")
local runtime

-- bullet's sound vars
local bulletSound1
local bulletSound2
local bulletSoundTime
local bulletSoundTimeGap

-- obstacle's sound
local obstacleDeathSound
local obstacleDeathSoundTime
local obstacleDeathSoundTimeGap
-------------------
-- backGround Music
---gameplay music---
local currentMusicIndex -- current backGround music index
local lastMusicIndex -- no. of backGround music clips
local backgroundMusic -- reference of current playing bgMusic

---mainMenu music---
local currentMainMenuMusicIndex
local lastMainMenuMusicIndex
local mainMenuBGMusic


local gain={} -- can be positive or negative
local cycleGain -- cycles b/w gain table
local buttonGain -- increments the gain's cycle

local setVolume

-------------------

function soundManager.init()
	
	runtime = 0	

	-- bullet sound init
	bulletSound1=audio.loadSound("assets/sounds/".."bulletSound1.wav")
	bulletSound2=audio.loadSound("assets/sounds/".."bulletSound2.wav")
	bulletSoundTimeGap=0.45 -- in secs
	bulletSoundTime=-bulletSoundTimeGap

	--obstacleDeathSound init
	obstacleDeathSound=audio.loadSound("assets/sounds/".."rockBlast.wav")
	obstacleDeathSoundTimeGap=0.4
	obstacleDeathSoundTime=-obstacleDeathSoundTimeGap

	-- backGroundMusic init
	currentMusicIndex=1
	lastMusicIndex=3 -- current we have 3 audio clips of bg musics

	-- mainMenu music
	currentMainMenuMusicIndex=1
	lastMainMenuMusicIndex=3

	-------------------
	gain={-0.5,0,0.5}
	cycleGain=1
	buttonGain=display.newImage(assetName.playButton,100,1000) -- display image that will increment gain cycler
	-- on tapping gain cycler will increment
	local function onTap( event )
		cycleGain=cycleGain+1
		if cycleGain>#gain then
			cycleGain=1
		end
		setVolume(volume, 1)	-- sets volume of currentChannel
	end

	buttonGain:addEventListener("tap",onTap)
	-------------------
	
	--reserveChannel for backGroundMusics
	audio.reserveChannels(1) -- both for backGroundMusic and mainMenu
end


-------------------

function soundManager.playBackgroundMusic( )
	local volume=nil
	local seekPoint=nil
	currentMusicIndex=currentMusicIndex+1
	if currentMusicIndex > lastMusicIndex then
		currentMusicIndex=1		
	end

	if (currentMusicIndex==1) then
		volume=1
		seekPoint=29
	elseif (currentMusicIndex==2) then
		volume=1
		seekPoint=26
	else 
		volume=1
		seekPoint=13
	end	

	-- removing previously buffered music
	audio.dispose(backgroundMusic)
	backgroundMusic=nil

	
	backgroundMusic=audio.loadStream("assets/sounds/backgroundMusic"..currentMusicIndex..".wav")
	-- play and callback's the function
	audio.seek(seekPoint*1000, backGroundMusic)
	audio.play(backgroundMusic,{channel=1, loop=0, 
		onComplete=function(event) 
		if (event.completed) then
			soundManager.playBackgroundMusic() -- call recursively
		end
	end})
end

-------------------

function soundManager.playMainMenuBackgroundMusic( )
	local volume=nil
	local seekPoint=nil
	currentMainMenuMusicIndex=currentMainMenuMusicIndex+1
	if currentMainMenuMusicIndex > lastMainMenuMusicIndex then
		currentMainMenuMusicIndex=1		
	end

	if (currentMainMenuMusicIndex==1) then
		volume=0.2
		seekPoint=28
	elseif (currentMainMenuMusicIndex==2) then
		volume=0.2
		seekPoint=26
	else 
		volume=0.2
		seekPoint=13
	end	
	-- removing previously buffered music
	audio.dispose(mainMenuBGMusic)
	mainMenuBGMusic=nil
	
	mainMenuBGMusic=audio.loadStream("assets/sounds/mainMenuBG"..currentMusicIndex..".wav")
	-- play and callback's the function
	audio.play(mainMenuBGMusic,{channel=1, loop=0, 
		onComplete=function(event) 
		if (event.completed) then
			soundManager.playMainMenuBackgroundMusic() -- call recursively
		end
	end})
	setVolume(volume, 1) -- sets volume of currentChannel
end

-------------------

function soundManager.update( dt )
	runtime = runtime + dt -- in seconds
end

-------------------
-- called from external script, wherever we need to play sound
function soundManager.playBulletSound()
	if runtime - bulletSoundTime > bulletSoundTimeGap then
		local selector=math.random(3)
		local channel
		if selector == 1 then -- select which audio to play
			channel=audio.play(bulletSound1)
		elseif selector ==2 then
			channel=audio.play(bulletSound2)
		end

		setVolume(1,channel) -- set audio's volume on  current channel range : [0-1]		
		-- channel.setVolume = 1
		bulletSoundTime = runtime
	end	
end

-------------------
-- called from external script, wherever we need to play sound
function soundManager.playObstacleDeathSound()
	if runtime-obstacleDeathSoundTime>obstacleDeathSoundTimeGap then
		local channel = audio.play(obstacleDeathSound)
		obstacleDeathSoundTime=runtime -- reset the last played time
	end
end

-------------------

-- stops audio on channel 1
function soundManager.stopBackgroundMusic()
	audio.stop(1)
end

-------------------
-- sets volume at a channel
function setVolume( volume, channel )
	local vol=volume+volume*gain[cycleGain] -- increases or decreases the volume
	if (vol>1) then -- if adding gain increases the volume above 100% then set volume to 100% i.e. 1
		vol=1
	end
	printDebugStmt.print("SM. Volume"..vol..", Gain: "..gain[cycleGain])
	audio.setVolume(vol,{channel=channel})
end

-------------------

return soundManager