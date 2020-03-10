local composer = require("composer")
local mainMenu = composer.newScene()

local soundManager=require("soundManager")
local printDebugStmt = require("helperScripts.printDebugStmt")
local assetName = require("helperScripts.assetName")

--------local Variables--------
local displayGroup

--------Fwd References--------
local makeMainMenu

---------------------------
function mainMenu:create(event)
	composer.removeScene(event.params.callingScene)
	soundManager.playMainMenuBackgroundMusic()	

	displayGroup = display.newGroup()
	local mainMenuGroup = self.view
	mainMenuGroup:insert(displayGroup)
	makeMainMenu()
end

---------------------------
-- called when this scene is destroyed
function mainMenu:destroy(event)
	soundManager.stopBackgroundMusic()
end
---------------------------

-- called from external script to make a pause menu
function makeMainMenu()

	local menuBox = display.newRect(displayGroup, display.contentCenterX, display.contentCenterY , 400, 400)
	menuBox.alpha = 0.2
	
	-- Title of Main Menu
	display.newText(displayGroup,"Main Menu", menuBox.x, menuBox.y - 250 )
	
	-- Text in Menu
	display.newText(displayGroup,"Tap to Play", menuBox.x, menuBox.y - 50)
	
	local playButton = display.newImage(displayGroup,assetName.playButton , menuBox.x, menuBox.y + 80)

	local function resumeGame( ) -- on tapping on resume Button we want to goto gameWorld screen
		playButton:removeEventListener("tap", resumeGame) -- remove listeners after removing the button	
		composer.gotoScene("gameWorld", {effect = "fade", time = 800, params = {callingScene="Screens.mainMenu"}})
	end

	playButton:addEventListener("tap", resumeGame)	
end

------------------------
-- no need of this function now, since everything gets deleted when this scene gets deleted, bcz all are part of same display group i.e. self.view
-- -- this function can remove a particular UI group
-- function removeUI()
-- 	for i=#group,1,-1 do
-- 		local temp = table.remove( group,i )
-- 		temp:removeSelf()
-- 		temp = nil
-- 	end
-- end

------------------------

mainMenu:addEventListener("create",mainMenu) -- called when we create screen
mainMenu:addEventListener("destroy", mainMenu) -- called when we destroy screen
------------------------

return mainMenu