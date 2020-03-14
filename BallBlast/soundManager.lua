local soundManager = {}

local printDebugStmt = require("helperScripts.printDebugStmt")
local assetName=require("helperScripts.assetName")
local preferenceHandler=require("helperScripts.preferenceHandler")
local runtime

-- bullet's sound vars
local bulletSound1
local bulletSound2
local bulletSoundTime
local bulletSoundTimeGap
local bulletHitSound
local bulletHitSoundTime
local bulletHitSoundTimeGap
-------------------

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


local gain -- can be positive or negative

local setVolume
local setPitch -- set pitch of an audio source

-------------------

function soundManager.init()
	
	runtime = 0	

	-- bullet sound init
	bulletSound1=audio.loadSound("assets/sounds/".."bulletSound1.wav")
	bulletSound2=audio.loadSound("assets/sounds/".."bulletSound2.wav")
	bulletSoundTimeGap=0.45 -- in secs
	bulletSoundTime=-bulletSoundTimeGap

	bulletHitSound=audio.loadSound("assets/sounds/".."bulletHitSound.wav")
	bulletHitSoundTimeGap=0.16 -- in secs
	bulletHitSoundTime=-bulletHitSoundTimeGap

	--obstacleDeathSound init
	obstacleDeathSound=audio.loadSound("assets/sounds/".."rockBlast.wav")
	obstacleDeathSoundTimeGap=0.40
	obstacleDeathSoundTime=-obstacleDeathSoundTimeGap

	-- backGroundMusic init
	currentMusicIndex=1
	lastMusicIndex=3 -- current we have 3 audio clips of bg musics

	-- mainMenu music
	currentMainMenuMusicIndex=1
	lastMainMenuMusicIndex=3

	local volumeLevel=preferenceHandler.get("volumeLevel")
	if volumeLevel==1 then
		gain=-0.5
	elseif volumeLevel==2 then
		gain=0
	elseif volumeLevel==3 then
		gain=0.5
	end

	if gain==nil then --this will happen when we start the game and audio was muted already i.e. volumeLevel==0
		gain=0.5
	end

	--reserveChannel for backGroundMusics
	audio.reserveChannels(1) -- both for backGroundMusic and mainMenu
end


-------------------
function soundManager.setGain()
	local volumeLevel=preferenceHandler.get("volumeLevel")
	
	if volumeLevel==1 then
		gainPercent=-0.5
	elseif volumeLevel==2 then
		gainPercent=0
	elseif volumeLevel==3 then
		gainPercent=0.5
	end

	-- bcz we want the actual value of volume and then apply the gainPercent to it
	local currentGain=gain

	local currentVolume=audio.getVolume({channel=1})
	local volume=currentVolume/(1+currentGain)

	gain=gainPercent
	setVolume(volume, 1)	-- sets volume of 1st Channel
end

-------------------

function soundManager.setBackgroundVolume(mindis, infinity )
	local volume=0
	if currentMusicIndex==1 then
		volume=0.1
	elseif	currentMusicIndex==2 then
		volume=0.1
	elseif currentMusicIndex==3 then
		volume=0.1
	end

	volume=((infinity-mindis)/infinity)*volume
	setVolume(volume,1)
end

-------------------

function soundManager.stopAllAudios( )
	audio.stop()
end
-------------------

function soundManager.playBackgroundMusic( )

	-- don't play any sound when volumeLevel is 0
	if preferenceHandler.get("volumeLevel") == 0 then
		return
	end
	-- removing previously buffered music
	audio.dispose(backgroundMusic)			
	backgroundMusic=nil		
	
	local volume=nil
	local seekPoint=nil
	currentMusicIndex=currentMusicIndex+1
	if currentMusicIndex > lastMusicIndex then
		currentMusicIndex=1		
	end

	if (currentMusicIndex==1) then
		volume=0.1
		seekPoint=20
	elseif (currentMusicIndex==2) then
		volume=0.1
		seekPoint=27
	else 
		volume=0.1
		seekPoint=14
	end	
	
	backgroundMusic=audio.loadStream("assets/sounds/backgroundMusic"..currentMusicIndex..".wav")
	-- play and callback's the function
	audio.seek(seekPoint*1000, backGroundMusic)
	local channel,src=audio.play(backgroundMusic,{channel=1, loop=0,
		onComplete=function(event) 
		if (event.completed) then
			soundManager.playBackgroundMusic() -- call recursively
		end
	end})
	setVolume(volume, 1)	-- sets volume of currentChannel
end

-------------------

function soundManager.playMainMenuBackgroundMusic()
	-- don't play any sound when volumeLevel is 0
	if preferenceHandler.get("volumeLevel") == 0 then
		return
	end

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
	local channel,src=audio.play(mainMenuBGMusic,{channel=1, loop=0, 
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
	-- don't play any sound when volumeLevel is 0
	if preferenceHandler.get("volumeLevel") == 0 then
		return
	end
	
	if runtime - bulletSoundTime > bulletSoundTimeGap then
		-- local selector=math.random(2)
		-- if selector == 1 then -- select which audio to play
		local channel,src=audio.play(bulletSound1)
		-- elseif selector ==2 then
		-- 	channel=audio.play(bulletSound2)
		-- end
		setVolume(0.01,channel) -- set audio's volume on  current channel range : [0-1]
		setPitch(src,1)
		bulletSoundTime = runtime
	end	
end

-------------------
-- sound played when bullet hits an obstacle
function soundManager.playBulletHitSound(obstacle)
	local pitch=0
	if obstacle.VY<120 then
	   pitch=0.25
	elseif	obstacle.VY >120 and obstacle.VY<170 then
		pitch=0.5
	elseif obstacle.VY >170 and obstacle.VY<220 then
		pitch=0.75
	else
		pitch=1
	end

	if runtime-bulletHitSoundTime>bulletHitSoundTimeGap then
		local channel,src=audio.play(bulletHitSound)
		setVolume(1,channel)
		setPitch(src, pitch) -- if we are setting the pitch for this channel the change will reflect on all channel so manually set pitch in all other channels	
		bulletHitSoundTime=runtime
	end
end


-------------------
-- called from external script, wherever we need to play sound
function soundManager.playObstacleDeathSound()
	-- don't play any sound when volumeLevel is 0
	if preferenceHandler.get("volumeLevel") == 0 then
		return
	end

	if runtime-obstacleDeathSoundTime>obstacleDeathSoundTimeGap then
		local channel,src= audio.play(obstacleDeathSound)
		setPitch(src,1)
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
	local vol=volume+volume*gain -- increases or decreases the volume
	if (vol>1) then -- if adding gain increases the volume above 100% then set volume to 100% i.e. 1
		vol=1
	end
	audio.setVolume(vol,{channel=channel})
end

-------------------

function setPitch(src, pitch)
	al.Source(src,al.PITCH,pitch)
end

-------------------

return soundManager