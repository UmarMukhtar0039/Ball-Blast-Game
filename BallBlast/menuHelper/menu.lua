menu={
}
local debugStmt=require "scripts.helperScripts.printDebugStmt"
local buttonMaker=require "scripts.menuHelper.button"
local assetName=require "scripts.helperScripts.assetName"
local deltaTime=require "scripts.helperScripts.deltaTime"
local toast=require "scripts.helperScripts.toast"
local animationService= require "scripts.helperScripts.animationService"

local menu_mt={__index=menu}-- metatable

local myMath={
  abs=math.abs,
  atan2=math.atan2,
  sin=math.sin,
  cos=math.cos,
}

-------------GUIDE ON EXTRA PARAMS---------Note: params marked with * cannot be passed through constructor and must be defined externally.
-- * addTextDisplay({xRelative,yRelative,font, fontSize,string,colour,align,width, Id})-colour is a table containing the rgb values 
--align is a string that indicates the text alignment(center,left or right ), must be passed along with the width
--width is a parameter that signifies the max horizontal length of the text in pixels 
--* addImage(data={imagePath,xRelative,yRelative, id})
--* addAnimation(data={xRelative,yRelative,sheet,sequence,id})
--*setKeyboardSupport(bool) can be set be passed true to show a pointer image for arrow keys navigation. Enter key will be used for selection.
--*addButtonToScrollpane(button,scrollContentBound): pass a button object along with contentBounds for the scrolling region to this function for the button to participate in calls made to scrollX and scrollY
--*scrollX(distanceToScroll) and scrollY(distanceToScroll) functions can be called with a distance to be scrolled. They will respect the sign of the distance and scroll all buttons added through addButtonToScrollpane as requested. 
-------------------------------------------

local menuInFocus--this will be the menu that currently has focus of the touch listener
local width=display.contentWidth
local height=display.contentHeight
------variables specific to keyboard and mouse controls:
local mouseSetupHelper--fwd reference for function that is INTERNALLY called to init the mouse pointer img and then place it based on a set of conditions
local previouslyFocussedMenu--this will keep track of the menu which was previously focussed. Helps in mouse tracking to determine if the new menu has same name as last menu
local isMouseInputMode--a boolean that is used to identify if the user is using mouse to navigate through menus. This will help in deciding if mouse pointer should be adjusted to a button's locatoin automatically or be allowd to follow the actual mouse input
local focusedButtonIndex=1--indicates the index of the current button that is focused by user input. Value is assigned in key and axis listener based on proximity from mouse pointer
local lastButtonPressed--this keeps track of the last button that was acted on. Helps when a menu is changed and mouse needs to be placed on the button with a same name 
--a reference of previous positions of mouse pointer is stored. This is done since the pointer is created and destroyed along with the menu. 
--tracking previous positions helps in keeping the pointer's position undisturbed when navigating between menus.
local pointerPosition={x=0,y=0}
--whenever a new menu is created, a time needs to be used to prevent the keys from becoming immediately active and to force the user to first be able to see the menu
local keyListenerDelayTimer=0--init the timer to 0. Reset each time a new menu is created otherwise.  
local keyListenerDelayTimeLimit=0.3-- in seconds
-------------------------------------------
--touch listener for buttons
local function moveTouch(event)
	if(menuInFocus==nil)then
		return
	end

	function sendEventToButtons()
		--if a touch up was recevied, release the button graphics irrespective of whether they're touched or not
		if(event.phase=="ended")then
			for i=1,#menuInFocus.buttons do
				menuInFocus.buttons[i]:forceGraphicsRelease()
			end
		end

		for i=1, #menuInFocus.buttons do
			--check which is the first button that is touched by the current touch event and also ensure that this button was not hidden as a result of being
			--on a the scrollableButtons table. Only then pass the event and break the loop.
			if(collisionHandler.buttonCollision(event,menuInFocus.buttons[i]) and menuInFocus.buttons[i].isButtonVisible)then
					menuInFocus.buttons[i]:touchEvent(event)
					lastButtonPressed=menuInFocus.buttons[i]-- store a reference for the button that was acted upon
				break
			end
		end
	end
	
	--addressing of the menuInFocus and its buttons can address nil values as the listener responds on a differnt thread and
	--when menus are being created/destroyed, values may change DURING the listener event and nil values will come up
	pcall(sendEventToButtons)
end	

----------------------------
--Key listener is used for the situation when the doesSupportKeyboard flag of a menu object is raised. Arrow keys can be used for navigation and enter key to perform button action
local function moveKey(event)
	if(menuInFocus==nil )then
		return
	end
	--if the menu in focus doesn't support keyboard, abort
	if(menuInFocus.doesSupportKeyboard==false )then
		return
	end
	--if the timer that blocks key action on creation of a new menu is still running (i.e. block is needed), return
	if(keyListenerDelayTimer<=keyListenerDelayTimeLimit)then
		return
	end

	local function performKeyActions()
		--whenever a key is pressed, start by determining the closest button index to the current mouse pointer
		local minDist=100000000000
		for i=1,#menuInFocus.buttons do
			local squaredDist=((menuInFocus.buttons[i].y-menuInFocus.pointerImage.y)^2)+((menuInFocus.buttons[i].x-menuInFocus.pointerImage.x)^2)
			if(squaredDist<minDist)then
				focusedButtonIndex=i
				minDist=squaredDist
			end
		end
		if(event.phase=="down")then
			if(event.keyName=="left" or event.keyName=="up" or event.keyName=="leftShoulderButton1") then
				isMouseInputMode=false--if user is using keyboard to navigate through the menus, set mouse inpute mode to false
				--first check if the mouse is already aligned with its nearest button by using collisionHandler and also check if the button in focus is visible. 
				--If it is not, don't change the focusedButtonIndex in order to force an alignment
				if(not collisionHandler.buttonCollision(menuInFocus.pointerImage,menuInFocus.buttons[focusedButtonIndex]) and menuInFocus.buttons[focusedButtonIndex].isButtonVisible)then
					focusedButtonIndex=focusedButtonIndex
				else
					--use an infinite loop to determine the nearest visible button-- in backward order
					while(true)do
					   	focusedButtonIndex=focusedButtonIndex-1
					   	if(focusedButtonIndex<1)then
							focusedButtonIndex=#menuInFocus.buttons
						end
						--if the button currently in focus is visible break the loop
					   	if(menuInFocus.buttons[focusedButtonIndex].isButtonVisible)then
					   		break	
					  	end
					end
				end
				--set position of the pointer image and enable make it visible
				menuInFocus.pointerImage.x=menuInFocus.buttons[focusedButtonIndex].x+menuInFocus.buttons[focusedButtonIndex].width*0.25
				menuInFocus.pointerImage.y=menuInFocus.buttons[focusedButtonIndex].y+menuInFocus.buttons[focusedButtonIndex].height*0.25
				menuInFocus.pointerImage.alpha=1
			elseif(event.keyName=="right" or event.keyName=="down" or event.keyName=="rightShoulderButton1") then
				isMouseInputMode=false--set the mouseInput mode to false
				--first check if the mouse is already aligned with its nearest button by using collisionHandler and also check if the button in focus is visible. 
				--If it is not, don't change the focusedButtonIndex in order to force an alignment
				if(not collisionHandler.buttonCollision(menuInFocus.pointerImage,menuInFocus.buttons[focusedButtonIndex]) and menuInFocus.buttons[focusedButtonIndex].isButtonVisible)then
					focusedButtonIndex=focusedButtonIndex
				else
					--use an infinite loop to determine the nearest visible button-- in forward order
					while(true)do
					   	focusedButtonIndex=focusedButtonIndex+1
					   	if(focusedButtonIndex>#menuInFocus.buttons)then
					   		focusedButtonIndex=1
					   	end
					   	--if the button currently in focus is visible break the loop
					   	if(menuInFocus.buttons[focusedButtonIndex].isButtonVisible)then
					   		break	
					   	end
					end
				end
				menuInFocus.pointerImage.x=menuInFocus.buttons[focusedButtonIndex].x+menuInFocus.buttons[focusedButtonIndex].width*0.25
				menuInFocus.pointerImage.y=menuInFocus.buttons[focusedButtonIndex].y+menuInFocus.buttons[focusedButtonIndex].height*0.25
				menuInFocus.pointerImage.alpha=1
			--check for a list of keys that are generally used in keyboards/controllers to perform action pertaining to the button selected.   
			elseif(event.keyName=="enter" or event.keyName=="buttonX" or event.keyName=="buttonA" or event.keyName=="button3" or 
				event.keyName=="buttonStart") then
				--first check if the mouse is already aligned with the button in focus and then check if the button is visible, if yes perform action
				if(collisionHandler.buttonCollision(menuInFocus.pointerImage,menuInFocus.buttons[focusedButtonIndex]) and menuInFocus.buttons[focusedButtonIndex].isButtonVisible)then
					event.phase="began"--hack the event phase before calling the touchEvent  on the down stroke of the enter key. This is because the button script recognises "began" phase
					menuInFocus.buttons[focusedButtonIndex]:touchEvent(event)
					lastButtonPressed=menuInFocus.buttons[focusedButtonIndex]--set the reference for the last button pressed
				end
			end
			elseif(event.phase=="up")then
			if(event.keyName=="enter" or event.keyName=="buttonX" or event.keyName=="buttonA" or event.keyName=="button3" or event.keyName=="buttonStart")then
				--first check if the mouse is already aligned with the button in focus and then check if the button is visible, if yes perform action
				if(collisionHandler.buttonCollision(menuInFocus.pointerImage,menuInFocus.buttons[focusedButtonIndex]) and menuInFocus.buttons[focusedButtonIndex].isButtonVisible)then
					event.phase="ended"--hack the event phase before calling the forceGraphicsRelease on the release of the enter key. This is because the button script recognises "ended" phase
					menuInFocus.buttons[focusedButtonIndex]:touchEvent(event)
					menuInFocus.buttons[focusedButtonIndex]:forceGraphicsRelease()
					lastButtonPressed=menuInFocus.buttons[focusedButtonIndex]--set the reference for the last button pressed
				else--if the up event detected is outside the current button call force release graphics 
					menuInFocus.buttons[focusedButtonIndex]:forceGraphicsRelease()
				end
			end
		end
	end

	--addressing of the menuInFocus and its buttons can address nil values as the listener responds on a differnt thread and
	--when menus are being created/destroyed, values may change DURING the listener event and nil values will come up
	pcall(performKeyActions)
end

-----------------------------
local currentAxisLocation={x=0, y=0}
--joystick movement is tracked by the moveAxis listener if the doesSupportKeyboard bool is activated. Joystick keys can be used for navigation between buttons
local function moveAxis(event)
	if(menuInFocus==nil )then
		return
	end
	--if the menu in focus doesn't support keyboard, abort
	if(menuInFocus.doesSupportKeyboard==false )then
		return
	end
	--Firstly, check if the position of controller is outside the deadzone, otherwise bring the pointer to a halt.
	if(event.normalizedValue>0.5 or event.normalizedValue<-0.5)then
		if(event.axis.type=="leftX" or event.axis.type=="x") then
			currentAxisLocation.x=event.normalizedValue
			--if user is using controller to navigate through the menus, set mouse inpute mode to true. NOTE: Some controls tend to fire axis events even if the user
			--is not moving the joystick. To prevent it from affecting the pointer system, set isMouseInputMode only when a relevant event is detected.  
			isMouseInputMode=true
		elseif(event.axis.type=="leftY" or event.axis.type=="y") then
			currentAxisLocation.y=event.normalizedValue	
			isMouseInputMode=true
		end
	else
		--if the movement is on x axis, set the x variable of axis location
		if(event.axis.type=="leftX" or event.axis.type=="x")then
			currentAxisLocation.x=0
		--if the movement is on y axis, set the y variable of axis location
		elseif(event.axis.type=="leftY" or event.axis.type=="y")then
			currentAxisLocation.y=0
		end
	end
end
-----------------------------
--mouse movement is only tracked if the doesSupportKeyboard bool is activated. Moving the mouse over a button will override the actions performed using keyboard and will make the pointer follow the mouse cursor
local function moveMouse(event)
	if(menuInFocus==nil )then
		return
	end
	--set mouse input mode to true if the mouse is moved. For menus like controls menu in GW, the keyboard support is disabled and a duplicate pointer image is used instead.
	--Hence this rule is not aplicable for menus that don't have keyboard support
	if(menuInFocus.doesSupportKeyboard)then
		isMouseInputMode=true
		--make the pointer image follow the mouse as a mouse cursor would do
		menuInFocus.pointerImage.x=event.x
		menuInFocus.pointerImage.y=event.y
	end
end

-----------------------------
local function update()
	dt=deltaTime.getDelta()
    local function updateMenuInFocus()
    	--update the alpha value for fadeIn if alpha was <1
    	if (menuInFocus.imageGroup.alpha<1) then
    		menuInFocus.imageGroup.alpha=menuInFocus.imageGroup.alpha+(4*dt)
    	end
    end

    local function updateJoystickMouse()
	    --compute angle that the current axis location makes with the origin(0,0) to determine the angle of movement and move the mouse pointer image
	    local angle=myMath.atan2(currentAxisLocation.y-0, currentAxisLocation.x-0)
	    local mouseV=700
	    --to make the speed of mouse proportional to the axes' tilt, multiply the magnitude of current axis location 
	    local mouseVx=myMath.abs(currentAxisLocation.x)*mouseV*myMath.cos(angle)
	    local mouseVy=myMath.abs(currentAxisLocation.y)*mouseV*myMath.sin(angle)
	    --if the analog stick was restored back to 0, force the x and y components of mouse velocity to 0
	    if(currentAxisLocation.x==0 and currentAxisLocation.y==0)then
	    	mouseVx=0
	    	mouseVy=0
	    end
	    --compute the leftmost and rightmost points on the screen from 0,0 of the content area 
	    local leftEdge=-(display.pixelWidth*0.5-width*0.25)
	    local rightEdge=display.pixelWidth*0.5+width*0.75
	    --make sure the pointer doesn't move out of the screen, confine the pointer's movement within the bounds of the screen
	    if(menuInFocus.pointerImage.x+mouseVx*dt<leftEdge or menuInFocus.pointerImage.x+mouseVx*dt>rightEdge or
	    menuInFocus.pointerImage.y+mouseVy*dt<0 or menuInFocus.pointerImage.y+mouseVy*dt>height)then
			return
		end
	    --add distances along x and y to the pointer image owned by the current menu based on velocity components computed above
	    menuInFocus.pointerImage.x=menuInFocus.pointerImage.x+mouseVx*dt
	    menuInFocus.pointerImage.y=menuInFocus.pointerImage.y+mouseVy*dt
	end
	--update the keyListenerDelayTimer only if it is less the limiting value
	if(keyListenerDelayTimer<=keyListenerDelayTimeLimit)then
		keyListenerDelayTimer=keyListenerDelayTimer+dt
	end

    pcall(updateMenuInFocus)
    pcall(updateJoystickMouse)
end	

----------Constructor--------
--NOTE that the width and height of base image are passed to the function and its compulsory. This is to ensure that the placement and dimensions of the base image
--is precise even in devices of lower resolutions.
function menu.newMenu(name,x,y,masterImageGroup, baseImagePath,baseImageWidth,baseImageHeight,isOverlayNeeded)
	local newMenu={
		name=name,
		x=x,
		y=y,
		buttons={},
		textDisplays={},
		images={},
		doesSupportKeyboard=false,-- disable keyboard support as default. This is an OPTIONAL value to be set externally only
		scrollableButtons={},--table that can only contain objects of button type. Function later in the script will facilitate scrolling of table
		scrollContentBound={}--this is the table of the scrollPane that will be used for culling effect of the scrollableButtons. It should be passed from the addButtonToScrollpane function
	}

	--create a sub group for self and then add to the supplied master group
	newMenu.imageGroup=display.newGroup()
	if(masterImageGroup~=nil)then
		masterImageGroup:insert(newMenu.imageGroup)
	end

	if(isOverlayNeeded)then
		local overlay=display.newRect(newMenu.imageGroup,width*0.5,height*0.5,width*2,height*2)
		
		overlay:setFillColor(0,0,0,0.4)
	end

	--draw the base image only when all 3 of the variables are passed.
	if(baseImagePath~=nil and baseImageWidth~=nil and baseImageHeight~=nil)then
		newMenu.baseImage=display.newImage(newMenu.imageGroup,baseImagePath)
		newMenu.baseImage.x=newMenu.x+baseImageWidth*0.5
		newMenu.baseImage.y=newMenu.y+baseImageHeight*0.5
		newMenu.baseImage.width=baseImageWidth
		newMenu.baseImage.height=baseImageHeight
	end

	--by default, a newly created menu should have touch focus
	menuInFocus=newMenu

	--reset the keyListenerDelayTimer and set the time limit
	keyListenerDelayTimer=0

	return setmetatable(newMenu,menu_mt)
end

--------------------------------------
--pass in a table accoridng to previously given guidelines to add a text display relative to the menu
function menu:addTextDisplay(data)

	local textParams = 
		{
			parent=self.imageGroup,
		    text = data.string,     
		    x = self.x+data.xRelative,
		    y = self.y+data.yRelative,
		    width = data.width,
		    font = data.font,   
		    fontSize = data.fontSize,
		    align = data.align -- Alignment parameter, works only when the width is specified
		}
	self.textDisplays[#self.textDisplays+1]=display.newText(textParams)

	--set id so that this textDisplay obejct can be fetched externally by id for updation etc
	self.textDisplays[#self.textDisplays].id=data.id

	--set the colour of the text 
	self.textDisplays[#self.textDisplays]:setFillColor(data.colour.r,data.colour.g,data.colour.b)
end

--------------------------------------
--pass in a table accoridng to previously given guidelines to add a images relative to the menu
function menu:addImage(data)
	self.images[#self.images+1]=display.newImage( self.imageGroup,data.imagePath,self.x+data.xRelative,self.y+data.yRelative)

	--set id so that this image obejct can be fetched externally by id for updation etc
	self.images[#self.images].id=data.id
end

--------------------------------------
--pass data table as per guidelines mentioned at top of script
function menu:addAnimation(data)
	--for menus avoid the use of animation service as in states like gameLose/gameWin, the animation service won't update
	self.images[#self.images+1]=display.newSprite(self.imageGroup,data.sheet,data.sequence)

	--set the position of animation
	self.images[#self.images].x=self.x+data.xRelative
	self.images[#self.images].y=self.y+data.yRelative

	--set id so that this animation obejct can be fetched externally by id for updation etc
	self.images[#self.images].id=data.id
	--play the animation
	self.images[#self.images]:play()
end

--------------------------------------
function menu:addButton(id, xRelative,yRelative,width,height,imageDownPath,imageUpPath,callbackDown,callbackUp,alphaDown,alphaUp,doesScaleDown, doesGlow,activatedImagePath)
	self.buttons[#self.buttons+1]=buttonMaker.newButton(id,self.x+xRelative,self.y+yRelative,width,height,self.imageGroup, imageDownPath, imageUpPath, callbackDown, callbackUp
		,alphaDown, alphaUp,doesScaleDown, doesGlow,activatedImagePath)
end

---------------------------------------
function menu:scrollY(distanceToScroll)
	--first check if the first button in the list is visible on the scrollPane. If it is and the user requested scrolling in the +ve y direction, do nothing
	if(self.scrollableButtons[1].contentBounds.yMin>self.scrollContentBound.yMin and distanceToScroll>0)then
		return
	end
	--simlilarly, if the last button is visible and scrolling was requested in the -ve y direction, reject
	if(self.scrollableButtons[#self.scrollableButtons].contentBounds.yMax<self.scrollContentBound.yMax and distanceToScroll<0)then
		return
	end

	--if scrolling request is deemed valid and code arrives here, Scroll!!
	for i=1, #self.scrollableButtons do
		self.scrollableButtons[i]:scrollY(distanceToScroll,self.scrollContentBound)
	end
end

---------------------------------------
function menu:scrollX(distanceToScroll)
	--first check if the first button in the list is visible on the scrollPane. If it is and the user requested scrolling in the +ve x direction, do nothing
	if(self.scrollableButtons[1].contentBounds.xMin>self.scrollContentBound.xMin and distanceToScroll>0)then
		return
	end
	--simlilarly, if the last button is visible and scrolling was requested in the -ve x direction, reject
	if(self.scrollableButtons[#self.scrollableButtons].contentBounds.xMax<self.scrollContentBound.xMax and distanceToScroll<0)then
		return
	end

	--if scrolling request is deemed valid and code arrives here, Scroll!!
	for i=1, #self.scrollableButtons do
		self.scrollableButtons[i]:scrollX(distanceToScroll,self.scrollContentBound)
	end
end

------------------------------------
--NOTE: if a button (preexisting) has to be added to the scrollPane, DO NOT do it directly but only through this function.
--Also note that this function should only add in a button on which all necessary actions such as addition of text and graphic have been performed. 
function menu:addButtonToScrollpane(button,scrollContentBound)
	self.scrollContentBound=scrollContentBound

	self.scrollableButtons[#self.scrollableButtons+1]=button

	--force a 0 scroll on x and y axis so that the button scripts can perform the basic visibility related work for the graphics of the button that was just added
	--otherwise this button will be visible even if it is outside the scrollpane
	self.scrollableButtons[#self.scrollableButtons]:scrollY(0,scrollContentBound)
	self.scrollableButtons[#self.scrollableButtons]:scrollX(0,scrollContentBound)
end

---------------------------------------
function menu:getItemByID(id)
	--check if button matches id
	for i=1, #self.buttons do
		if(self.buttons[i].id==id)then
			return self.buttons[i]
		end
	end

	--check if text matches id
	for i=1, #self.textDisplays do
		if(self.textDisplays[i].id==id)then
			return self.textDisplays[i]
		end
	end

	--check if image matches id
	for i=1, #self.images do
		if(self.images[i].id==id)then
			return self.images[i]
		end
	end
	return nil
end

----------------------------------------
--call this function externally to toggle the support for keyboard access on this menu object. DO NOT handle the doesSupportKeyboard boolean directly
--NOTE: this function assumes that all the buttons pertaining to the menu(in focus) have already been created. Hence it must be called at the end.
function menu:setKeyboardSupport(doesSupportKeyboard)
	self.doesSupportKeyboard=doesSupportKeyboard
	mouseSetupHelper(self)
end
--------------------------------------
-- This is a local helper function that is called from the setKeyboardSupport function. Note that if keyboard support is enable for a menu, mouse support is automatically added. 
-- Rule1: if the new menu doesn't have the same name as previous menu and the last input was made using a mouse, the pointer is placed where it was last placed in the previous menu
-- Rule2: if the new menu doesn't have the same name as previous menu but mouse was NOT used as the input device for last menu, the pointer is placed at button index 1 in new menu
-- Rule3: if the new menu has the same name as the previous menu, the system will look for a button with the same name as the last button pressed in previous menu and place the pointer there. 
function mouseSetupHelper(self)
	--start by creating an image for the mouse pointer
	self.pointerImage=display.newImage(assetName.pointer,pointerPosition.x,pointerPosition.y)--NOTE- pointer should be at the top most layer in z-order, so no group is assigned
	self.pointerImage.width=100
	self.pointerImage.height=100
	--bring the pointer image on the first button of the menu, if the menu created is different from the previous one or the first menu of the game
	--it is also checked if the user had last used the mouse or not. If the last input was from a mouse, do not set the pointerImage to the first button of the menu
	if((previouslyFocussedMenu==nil or previouslyFocussedMenu.name~=self.name) and not isMouseInputMode)then
		self.pointerImage.x=self.buttons[1].x+self.buttons[1].width*0.25
		self.pointerImage.y=self.buttons[1].y+self.buttons[1].height*0.25
	end
	--if the previously focused menu is the same as the current menu's name, look at the reference for the last buttont that was clicked on the previous menu
	--and set the mouse pointer to that button. This is necessary to maintain coherence in scenarious where new menus are created for a scrolling effect or in the case of level-cards etc.
	if(previouslyFocussedMenu~=nil and previouslyFocussedMenu.name==self.name and not isMouseInputMode)then
		--search through all the buttons of the current menu to get the button that was last selected in the previouslyFocusedMenu.
		for i=1, #self.buttons do
			if(lastButtonPressed.name==self.buttons[i].name)then--place the pointer at the location of this button and break the loop
				self.pointerImage.x=self.buttons[i].x+self.buttons[i].width*0.25
				self.pointerImage.y=self.buttons[i].y+self.buttons[i].height*0.25
				break
			end
		end
	end
end

----------------------------------------
--enable this menu for touch response whilst disabling all others
function menu:setFocus()
	menuInFocus=self
end
----------------------------------------
--remove focus from the menu
function menu.disableFocus()
	previouslyFocussedMenu=menuInFocus
	menuInFocus=nil
end
----------------------------------------
--bring focus back to the previously focussed menu
function menu.enableFocus()
	menuInFocus=previouslyFocussedMenu
end
----------------------------------------
--function that returns the menu currently in focus
function menu.getMenuInFocus()
	return menuInFocus
end
----------------------------------------
--call this function to fade the menu in. This can technically be called at any time but should be done as soon as all buttons, texts are added
--WARNING: The fading seems to work correctly even for buttons that rely on changing alpha values but it is not advised to use this feature in such menus
--NOTE: option of setting fadeTime was removed since lua cannot handle small floating points correctly. Fixed approx speed is used.
function menu:fadeIn()
	self.imageGroup.alpha=0
end

-------------------------------------
--remove all display objects associated with menu, remove focus from this menu if it was in focus and then set to nil
function menu:destroy()
	if(menuInFocus==self)then	
		previouslyFocussedMenu=menuInFocus	
		menuInFocus=nil
	end
	--update the values of pointer positions to keep track of the pointer's positions to determine the placement of next menu's pointer
	if(self.doesSupportKeyboard)then--check if pointer is enabled
		pointerPosition.x=self.pointerImage.x
		pointerPosition.y=self.pointerImage.y
		self.pointerImage:removeSelf()
	end
	self.imageGroup:removeSelf()
	self=nil
end
----------------------------------------
--add a universal action listener for menus as well as frame listener to update menus independently
Runtime:addEventListener ( "touch", moveTouch)
Runtime:addEventListener ( "enterFrame", update)
Runtime:addEventListener("key", moveKey )
Runtime:addEventListener("axis", moveAxis )
Runtime:addEventListener("mouse", moveMouse)
----------------------------------------
return menu