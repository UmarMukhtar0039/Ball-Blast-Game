local soundManager = {}

local runtime

-- bullet's sound vars
local bulletSound1
local bulletSound2
local bulletSound3
local bulletSoundTime
local bulletSoundTimeGap
local playBulletSound

-- obstacle's sound
local player
local obstacleDeathSound
local obstacleDeathSoundTime
local obstacleDeathSoundTimeGap
local playObstacleDeathSound
-------------------

function soundManager.init(playerRef)
	
	runtime = 0	

	player = playerRef

	-- bullet sound init
	bulletSound1=audio.loadSound("assets/sounds/".."bulletSound1.mp3")
	bulletSound2=audio.loadSound("assets/sounds/".."bulletSound2.mp3")
	bulletSound3=audio.loadSound("assets/sounds/".."bulletSound3.mp3")
	bulletSoundTimeGap=0.45 -- in secs
	bulletSoundTime=-bulletSoundTimeGap

	--obstacleDeathSound init
	obstacleDeathSound=audio.loadSound("assets/sounds/".."rockBlast.mp3")
	obstacleDeathSoundTimeGap=0.4
	obstacleDeathSoundTime=-obstacleDeathSoundTimeGap
end

-------------------

function soundManager.update( dt )
	runtime = runtime + dt -- in seconds

	if runtime - bulletSoundTime > bulletSoundTimeGap then
		playBulletSound()
	end

	if runtime-obstacleDeathSoundTime>obstacleDeathSoundTimeGap then
			local obstacle=player.lastDestroyedObstacle	
			if not obstacle.isAlive then			
				
			end
	
	end

end

-------------------

function playBulletSound()
	local selector=math.random(3)
	local channel
	if selector == 1 then -- select which audio to play
		channel=audio.play(bulletSound1)
	elseif selector ==2 then
		channel=audio.play(bulletSound2)
	else
		channel=audio.play(bulletSound3)
	end
	
	audio.setVolume(1,channel) -- set audio's volume on  current channel range : [0-1]
	
	-- channel.setVolume = 1
	bulletSoundTime = runtime
	
end

-------------------

function playObstacleDeathSound()
	local channel = audio.play(obstacleDeathSound)
end

return soundManager