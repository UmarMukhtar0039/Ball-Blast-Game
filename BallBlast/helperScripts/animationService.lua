local animationService={}

-- local debugStmt = require( "scripts.helperScripts.printDebugStmt" )
local animations={}

-- add a new sprite animation using group, sheet and sequence name references. This is added to the local record of all anims.
-- This fn also performs basic housekeeping by removing records that do not exist any longer.
function animationService.newSprite(group, sheet, sequence)
	-- debugStmt.print("Animations Service: size is "..#animations)
	for i=#animations, 1, -1 do
		if(animations[i].frame==nil)then
			-- debugStmt.print("Animations Service: obj frame at "..i.." is nil. Will remove from records")
			obj=table.remove( animations,i )
			-- obj:removeSelf() ??
			obj=nil
		end
	end

	local currentIndex=#animations+1

	if(group~=nil)then
		animations[currentIndex]=display.newSprite(group,sheet,sequence)
	else
		animations[currentIndex]=display.newSprite(sheet,sequence)
	end

	return animations[currentIndex]
end

---------------------------

--function will pause all animations that are presently playing and will raise a "paused" flag to their object so that they can be later resumed
function animationService.pause()
	for i=1, #animations do
		if(animations[i].isPlaying)then
			animations[i]:pause()
			animations[i].isPaused=true
		end
	end
end

--function will resume all previously paused animations
function animationService.resume()
	for i=1, #animations do
		if(animations[i].isPaused)then
			animations[i]:play()
			--pull the flag back down after playing to prevent animation from playing endlessly!
			animations[i].isPaused=false
		end
	end
end

--call this fucntion when transitioning screens etc to remove all animations since these will become null when the view changes
function animationService.removeAll()
	for i=#animations, 1, -1 do
		obj=table.remove( animations,i )
		obj=nil
	end
end


return animationService