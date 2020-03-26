local composer = require("composer")
local mainMenu = composer.newScene()

local soundManager=require("soundManager")
local printDebugStmt = require("helperScripts.printDebugStmt")
local assetName = require("helperScripts.assetName")
local menuMaker=require("menuHelper.menu")
local app42=require("externalServices.app42")
local preferenceHandler=require("helperScripts.preferenceHandler")
local shop=require("shop")


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
local leaderboardMenu
local makeLeaderboardMenu
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
	if menuMaker.getMenuInFocus() ~= nil  then
		if menuMaker.getMenuInFocus().name == "waitMenu" then
			--check if leaderboardIsFetched then make leaderboard menu
			if app42.leaderboardIsFetched==true then
				waitMenu:destroy()
				makeLeaderboardMenu()
			end	-- body
		end
	end

	shop.update()
end

---------------------------

-- called from external script to make a pause menu
function makeMainMenu()
		printDebugStmt.print("make Menu")
	mainMenuDisplay=menuMaker.newMenu("mainMenuDisplay", width*0.25, height*0.25, displayGroup,assetName.mainMenuBase,385,408)
	-- if we want to set alpha of base image ?? 
	-- displayMenu.baseImage.alpha=0.2

	mainMenuDisplay:addButton("newsButton",200,170,100,70)
	mainMenuDisplay:addButton("leaderboardButton",200, 250, 200, 70)
	mainMenuDisplay:addButton("shopButton",200,330,150,70)
	mainMenuDisplay:addButton("playButton",200, 430,126,88,nil,assetName.pauseButton)
	mainMenuDisplay:getItemByID("newsButton"):addTextDisplay({id="newsTextTitle",string="News",xRelative=0, yRelative=0, fontSize=30, colour={r=1,g=0,b=0}})
	mainMenuDisplay:getItemByID("leaderboardButton"):addTextDisplay({id="highscoreText",string="Leaderboard",xRelative=0,yRelative=0,fontSize=30,colour={r=0,g=0,b=1}})
	mainMenuDisplay:getItemByID("shopButton"):addTextDisplay({id="shopText",string="Shop",xRelative=0,yRelative=0,fontSize=30,colour={r=0,g=1,b=0}})
	

	-- add an exclamation mark if new news is added
	if app42.currentNewsVersion~=nil then
		if  app42.currentNewsVersion>preferenceHandler.get("currentNewsVersion")then
			local sheet=graphics.newImageSheet(assetName.exclamationSprite,{width = 13, height = 42, numFrames = 5, sheetContentWidth = 65, sheetContentHeight = 42})
			mainMenuDisplay:getItemByID("newsButton"):addAnimation({xRelative = 30, yRelative=-10, sheet=sheet,sequence={name="usual", start=1, count=5,time=800,loopcount=0}})
			preferenceHandler.set("currentNewsVersion",app42.currentNewsVersion)
		end		
	end	

	-- on play button callbackUp destroy the current menu and goto the gameWorld scene
	mainMenuDisplay:getItemByID("playButton").callbackUp=function( )
		mainMenuDisplay:destroy()
		composer.gotoScene("gameWorld", {effect = "fade", time = 800, params = {callingScene="Screens.mainMenu"}})	
	end

	mainMenuDisplay:getItemByID("newsButton").callbackUp=function( )
		mainMenuDisplay:destroy()
		makeNewsMenu()
	end

	mainMenuDisplay:getItemByID("leaderboardButton").callbackUp=function()
		mainMenuDisplay:destroy()
		makeWaitMenu()
		-- fetch n top rankers from server
		app42.fetchScores(5)
	end
	-- call make shop menu when shop button is clicked
	mainMenuDisplay:getItemByID("shopButton").callbackUp=function( )
		mainMenuDisplay:destroy()
		shop.makeShopMenu(makeMainMenu)
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
-- make leaderboard menu when leaderboard is fetched
function makeLeaderboardMenu()
	leaderboardMenu=menuMaker.newMenu("leaderboardMenu",width*0.25, height*0.25, displayGroup,assetName.baseMenu,489,660)
	leaderboardMenu:addButton("okButton",200,600,100,100)
	leaderboardMenu:getItemByID("okButton"):addTextDisplay({id="okText",string="OK",xRelative=0,yRelative=0,fontSize=30,colour={r=1,g=0,b=0}})

	-- add display text i.e. seperate column for names and scores
	leaderboardMenu:addTextDisplay({id="leaderboardNameTitle",string="Name",xRelative=100,yRelative=150,fontSize=30,colour={r=1,g=1,b=1}})
	leaderboardMenu:addTextDisplay({id="leaderboardScoreTitle",string="Score",xRelative=350,yRelative=150,fontSize=30,colour={r=1,g=1,b=1}})

	-- iterate through the leaderboardtable and list out names and scores
	for i=1,#app42.leaderboardTable do
		local name=app42.leaderboardTable[i].name
		local score=app42.leaderboardTable[i].score
		
		-- set y relative of first player's score and name manually and then 
		if i==1 then		
			leaderboardMenu:addTextDisplay({id="name"..i,string=name, xRelative=80, yRelative=200,fontSize=25,colour={r=1,g=1,b=1}})
			leaderboardMenu:addTextDisplay({id="score"..i,string=score, xRelative=330, yRelative=200, fontSize=25,colour={r=1,g=1,b=1}})
		else
			local yRelative= leaderboardMenu:getItemByID("name"..(i-1)).y + 50
			yRelative=yRelative-leaderboardMenu.y		
			leaderboardMenu:addTextDisplay({id="name"..i,string=name, xRelative=80, yRelative=yRelative,fontSize=25,colour={r=1,g=1,b=1}})
			leaderboardMenu:addTextDisplay({id="score"..i,string=score, xRelative=330, yRelative=yRelative, fontSize=25,colour={r=1,g=1,b=1}})
		end
	end

	leaderboardMenu:getItemByID("okButton").callbackUp=function()
		leaderboardMenu:destroy()
		makeMainMenu()		
	end
end

------------------------

mainMenu:addEventListener("create",mainMenu) -- called when we create screen
mainMenu:addEventListener("destroy", mainMenu) -- called when we destroy screen
------------------------

return mainMenu