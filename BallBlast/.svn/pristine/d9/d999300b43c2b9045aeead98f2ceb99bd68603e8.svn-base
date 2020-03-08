local messageService={	width=display.contentWidth,
								height=display.contentHeight,
							}
local timerService=require "scripts.helperScripts.timerService"							
local assetName=require "scripts.helperScripts.assetName"
local debugStmt=require "scripts.helperScripts.printDebugStmt"
local obj--the text display object
local image-- some calls may supply an optional imagePath to be displayed
local q--a queue that stores the data 
local textTransition,imageTransition

obj=nil
image=nil
q={}

--------------------------------------------------------------

--function to remove the current data and show the next data in the queue
local function remove()
	if obj~= nil then
		--trigger a tween out of the obj and image and remove the display object at the end of the transition
		if(image~=nil)then
			imageTransition=transition.to(image, {alpha=0,y=image.y-100, time = 500, onComplete=
			function (  )
				display.remove(image)
				image=nil
			end})
		end

		textTransition=transition.to(obj, {alpha=0,y=obj.y-100, time = 500, onComplete=
			function (  )
				display.remove(obj)
				obj=nil
				--if queue is not empty, show next data
				if(#q~=0) then
					messageService.showMessage(q[1].displayGroup,q[1].data)
					table.remove( q, 1)
				end
			end})
	end
end

--------------------------------------------------------------
-- Data  table format {text="....",x=....,y=.....,fontName=, size=.., color={r,g,b}, time=, imagePath, imageX, imageY,imageWidth,imageHeight}
--Time,fontName ,colour, imagePath, imageX, imageY,imageWidth,imageHeight are optional
function messageService.showMessage(displayGroup,data)
	-- if the display object is occupied, don't override but add the data to queue for later.
	if(obj~=nil) then
		q[#q+1]={}
		q[#q].displayGroup=displayGroup
		q[#q].data=data
		return
	end

	local fontName
	if(data.fontName==nil)then
		fontName=assetName.AMB
	else
		fontName=data.fontName
	end

	--if object is nil then set the object and its background
	obj=display.newText(displayGroup,data.text, data.x, data.y,fontName, data.size)
	if(data.color~=nil)then
		obj:setFillColor(data.color.r,data.color.g,data.color.b,1)
	else
		obj:setFillColor(1,1,1,1)
	end

	--check if an image path was specified and then add that image at the supplied coordinates
	if(data.imagePath~=nil)then
		image=display.newImage(displayGroup,data.imagePath,data.imageX,data.imageY)
	end

	local duration
	
	if(data.time~=nil)then
		duration=data.time
	else
		duration=3000
	end

	--bring the message to the rear of the display group to make sure it remains behind the menus
	obj:toBack()
	if(image~=nil)then
		image:toBack()
	end
	--remove a data after 3 seconds 
	timerService.addTimer( duration, remove)
end

--------------------------------------------------------------
--a variation of show message function where messages will be independent of the waiting queue. This can allow for multiple messages to be shown on the screen at the same time
function messageService.showMessageWithoutQueue(displayGroup,data)

	local fontName
	if(data.fontName==nil)then
		fontName=assetName.AMB
	else
		fontName=data.fontName
	end
	
	--if object is nil then set the object and its background
	local obj=display.newText(displayGroup,data.text, data.x, data.y,fontName, data.size)
	if(data.color~=nil)then
		obj:setFillColor(data.color.r,data.color.g,data.color.b,1)
	else
		obj:setFillColor(1,1,1,1)
	end

	--check if an image path was specified and then add that image at the supplied coordinates
	if(data.imagePath~=nil)then
		local image=display.newImage(displayGroup,data.imagePath,data.imageX,data.imageY)
	end

	local duration
	
	if(data.time~=nil)then
		duration=data.time
	else
		duration=3000
	end

	--bring the message to the rear of the display group to make sure it remains behind the menus
	obj:toBack()
	if(image~=nil)then
		image:toBack()
	end
	
	--remove a data after 3 seconds 
	local function remove()
		--trigger a tween out of the obj and image and remove the display object at the end of the transition
		if(image~=nil)then
			transition.to(image, {alpha=0,y=image.y-100, time = 500, onComplete=
			function (  )
				display.remove(image)
				image=nil
			end})
		end

		transition.to( obj, {alpha=0,y=obj.y-100, time = 500, onComplete=
		function (  )
			display.remove(obj)
			obj=nil
		end})
	end

	timerService.addTimer( duration, remove)
end

--------------------------------------------------------------
--resets the message service, must be called from the destroy of every script to erase any message lingering from the previous screen
function messageService.cancelAll()
	if(textTransition~=nil)then
		transition.cancel(textTransition)
	end
	if(imageTransition~=nil)then
		transition.cancel(imageTransition)
	end
	obj=nil
	image=nil
	q={}
end
--------------------------------------------------------------

return messageService