local composer = require("composer")
local mainMenu = composer.newScene()

local soundManager=require("soundManager")
local printDebugStmt = require("helperScripts.printDebugStmt")
local assetName = require("helperScripts.assetName")
local menuMaker=require("menuHelper.menu")
local app42=require("externalServices.app42")
local preferenceHandler=require("helperScripts.preferenceHandler")


--------local Variables--------
local displayGroup
local width=display.contentWidth
local height=display.contentHeight

--------Fwd References--------
local makeMainMenu
local mainMenuDisplay
local makeWaitMenu
local waitMenu
local makeNewsMenu
local update -- update Function of this script


---------------------------
function mainMenu:create(event)
	composer.removeScene(event.params.callingScene)
	soundManager.playMainMenuBackgroundMusic()	

	displayGroup = display.newGroup()
	local mainMenuGroup = self.view
	mainMenuGroup:insert(displayGroup)
	makeMainMenu()

	Runtime:addEventListener("enterFrame",update)
end
---------------------------
-- called when this scene is destroyed
function mainMenu:destroy(event)
	soundManager.stopBackgroundMusic()
	Runtime:removeEventListener("enterFrame",update)
end

---------------------------

function update()
	-- check if news is ready if yes then delete the wait menu and call makeNewsMenu
	if menuMaker.getMenuInFocus().name == "waitMenu" then
		if app42.newsIsFetched==true then
			waitMenu:destroy()			
			makeNewsMenu()
		end
	end
end

---------------------------

-- called from external script to make a pause menu
function makeMainMenu()
		
	mainMenuDisplay=menuMaker.newMenu("mainMenuDisplay", width*0.25, height*0.25, displayGroup,assetName.mainMenuBase,385,408)
	-- if we want to set alpha of base image ?? 
	-- displayMenu.baseImage.alpha=0.2

	mainMenuDisplay:addButton("newsButton",200,170,100,70)
	mainMenuDisplay:addButton("playButton",200, 300,126,88,nil,assetName.pauseButton)
	mainMenuDisplay:getItemByID("newsButton"):addTextDisplay({id="newsTextTitle",string="News",xRelative=0, yRelative=0, fontSize=30, colour={r=1,g=0,b=0}})


	if app42.currentNewsVersion~=nil then
		if  app42.currentNewsVersion>preferenceHandler.get("currentNewsVersion")then
			printDebugStmt.print("MM: cv: ")	
			mainMenuDisplay:getItemByID("newsButton"):addAnimation({xRelative = 20, yRelative=-10, sheet= ,sequence={name="usual", start=1, count=5,time=800,loopcount=0}})
		end		
	end	

	-- on play button callbackUp destroy the current menu and goto the gameWorld scene
	mainMenuDisplay:getItemByID("playButton").callbackUp=function( )
		mainMenuDisplay:destroy()
		composer.gotoScene("gameWorld", {effect = "fade", time = 800, params = {callingScene="Screens.mainMenu"}})	
	end

	mainMenuDisplay:getItemByID("newsButton").callbackUp=function( )
		mainMenuDisplay:destroy()
		makeWaitMenu()
		app42.fetchNews()
	end
end

------------------------
-- made while the news is being fetched
function makeWaitMenu()
	waitMenu=menuMaker.newMenu("waitMenu", width*0.25, height*0.25,nil,nil,385,408)
	waitMenu:addTextDisplay({id="waitText", string="...Wait...",xRelative=200,yRelative=200, width=200, fontSize=50, colour={r=1,g=1,b=1}})
	waitMenu:addButton("cancelButton",200,350,100,100)
	waitMenu:getItemByID("cancelButton"):addTextDisplay({id="cancelText",string="Cancel",xRelative=0,yRelative=0,fontSize=30,colour={r=1,g=0,b=0}})

	waitMenu:getItemByID("cancelButton").callbackUp=function()
		waitMenu:destroy()
		makeMainMenu()
	end
end

------------------------
-- make news menu after news is fetched
function makeNewsMenu()
	app42.newsIsFetched=false
	newsMenu=menuMaker.newMenu("newsMenu", width*0.25, height*0.25,displayGroup,assetName.baseMenu,489,660)
	newsMenu:addButton("okButton",200,600,100,100)
	newsMenu:getItemByID("okButton"):addTextDisplay({id="okText",string="OK",xRelative=0,yRelative=0,fontSize=30,colour={r=1,g=0,b=0}})

	for i=1,#app42.newsTable do
		-- printDebugStmt.print("news: "..i.. " ".. app42.newsTable[i])
		local text=app42.newsTable[i]
		newsMenu:addTextDisplay({id="news"..i, string=text, xRelative=230, yRelative=i*130,fontSize=30,colour={r=1,g=1,b=1}})
	end

	newsMenu:getItemByID("okButton").callbackUp=function()
		newsMenu:destroy()
		makeMainMenu()		
	end
end

------------------------

mainMenu:addEventListener("create",mainMenu) -- called when we create screen
mainMenu:addEventListener("destroy", mainMenu) -- called when we destroy screen
------------------------

return mainMenu