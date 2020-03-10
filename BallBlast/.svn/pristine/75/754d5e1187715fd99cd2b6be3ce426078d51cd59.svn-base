timerService={}

local timers={}
local pause=false

local deltaTime=require "helperScripts.deltaTime"
local debugStmt=require "helperScripts.printDebugStmt"

local mymath=
{
	round=math.round,
} 

-- Call this function to add a timer from another part of the code and to supply a duration and callback function for the nil
--name is optional and can be used for debugging etc to identify timer
function timerService.addTimer(duration, callback, name)
	local currentIndex=#timers+1
	timers[currentIndex]={}
	timers[currentIndex].currentTime=0
	timers[currentIndex].duration=duration
	timers[currentIndex].isComplete=false
	timers[currentIndex].callback=callback
	if(name~=nil)then
		timers[currentIndex].name=name
	end

	return timers[currentIndex]
end

------------------
-- Update the timers stored in the current list of timers. Call this from an update function or tie to an enterFrame listener
function update()
	-- debugStmt.print("timerService: timer count is "..#timers)
	if(pause)then
		return
	end

	delta=deltaTime.getDelta()
	delta=delta*1000--convert the delta value to millis as all timers are specified in millis

	for i = 1, #timers do
		timers[i].currentTime=timers[i].currentTime+mymath.round(delta)

		--for debug only: print the name, index, currentTime of a timer
		-- if(timers[i].name==nil)then
		-- 	debugStmt.print("timerService: timer at index "..i.." current time is "..timers[i].currentTime.."delta was "..delta)
		-- else
		-- 	debugStmt.print("timerService: timer at index "..i.." has name "..timers[i].name.." and current time is "..timers[i].currentTime.."delta was "..delta)
		-- end

		if(timers[i].currentTime>timers[i].duration)then
			timers[i].isComplete=true
			pcall(timers[i].callback)
		end
	end

	--iterate in reverse and remove compelted timers. 
	for i=#timers, 1, -1 do
		if(timers[i].isComplete)then
			obj=table.remove(timers, i)
			obj=nil
		end
	end
end

------------------
-- Call this function when moving from a screen etc. to remove all timer reference. 
function timerService.cancelAll()
	-- iterate in reverse and remove all timers
	for i=#timers, 1, -1 do
		obj=table.remove(timers, i)
		obj=nil
	end
end

--call this function to trigger a boolean that will pause all timers
function timerService.pause()
	pause=true
end

--call this function to resume timers
function timerService.resume()
	pause=false
end

------------------
--persistent listener for the timer service
Runtime:addEventListener ( "enterFrame", update)

return timerService