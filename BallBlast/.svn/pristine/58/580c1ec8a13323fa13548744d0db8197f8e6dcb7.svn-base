local inGameUI={displayGroup=nil}
local width=display.contentWidth
local height=display.contentHeight

local menuMaker=require("menuHelper.menu")
local assetName=require("helperScripts.assetName")
local composer=require("composer")
local preferenceHandler=require("helperScripts.preferenceHandler")
local printDebugStmt=require("helperScripts.printDebugStmt")
local soundManager=require("soundManager")

local player -- gets reference of player
local gameWorld -- gets reference of game World
local controlMenu
local makePauseMenu -- fwd reference
local pauseMenu
local onPlayButtonDown
local volumeButtonDown
local volumeCycler

--------------------
--called from external script
function inGameUI.init(gw,playerRef)
    gameWorld=gw
    player=playerRef
end

--------------------

--called from external script
function inGameUI.makeControlMenu()
    controlMenu=menuMaker.newMenu("controlMenu", 0,height*0.75, inGameUI.displayGroup,nil, width, height*0.5, false)
    controlMenu:addButton("leftControlButton", width*0.25,0, width*0.5, height*0.25, nil,assetName.leftControlButton,nil,nil,1,0.4)
    controlMenu:addButton("rightControlButton", width*0.75,0, width*0.5, height*0.25, nil,assetName.rightControlButton,nil,nil,1,0.4)
    controlMenu:addButton("pauseButton",width-150,-800,126,88, nil,assetName.pauseButton,nil,nil,1,1)

    -- function callbacks
    controlMenu:getItemByID("leftControlButton").callbackDown=function()
    		player.dir="l"
    end
	controlMenu:getItemByID("leftControlButton").callbackUp=function()
			player.dir=nil
	end
    controlMenu:getItemByID("rightControlButton").callbackDown=function()
    		player.dir="r"
	end
	controlMenu:getItemByID("rightControlButton").callbackUp=function()
			player.dir=nil
	end
    controlMenu:getItemByID("pauseButton").callbackDown=function()
			controlMenu:destroy() -- first destroy the controlMenu
			makePauseMenu() -- then make the pause menu
	end
end

--------------------

function makePauseMenu()
    gameWorld.gameState="suspended" -- suspended the game state on pause
    pauseMenu=menuMaker.newMenu("pauseMenu",width*0.25, height*0.25,inGameUI.displayGroup,assetName.baseMenu,489,660,true)
    pauseMenu:addButton("scrollUp",70, 500, 100, 100)
    pauseMenu:getItemByID("scrollUp"):addTextDisplay({xRelative=0, yRelative=0, string="up",width=50,colour={r=1,g=0,b=0}})

    pauseMenu:addButton("scrollDown",200, 500, 100, 100)
    pauseMenu:getItemByID("scrollDown"):addTextDisplay({xRelative=0, yRelative=0, string="down",width=150,colour={r=1,g=0,b=0}})
    
    pauseMenu:addButton("btnPlay",350, 400, 83, 70, nil,assetName.btnPlay)
    pauseMenu:addButton("btnExit",350, 500, 83, 70, nil,assetName.btnExit)
    
    -- addButton image according to the volumeLevel in preferenceHandler and set gain accordingly
    local volumeLevel=preferenceHandler.get("volumeLevel")
    if volumeLevel==0 then
        pauseMenu:addButton("btnVolume", 350, 304, 169, 72, nil, assetName.btnSound1)
    elseif volumeLevel==1 then
        pauseMenu:addButton("btnVolume", 350, 304, 169, 72, nil, assetName.btnSound2)
    elseif volumeLevel==2 then
        pauseMenu:addButton("btnVolume", 350, 304, 169, 72, nil, assetName.btnSound3)
    	elseif volumeLevel==3 then
        pauseMenu:addButton("btnVolume", 350, 304, 169, 72, nil, assetName.btnSound4)
    end
    	
    -- adding button to scrollable plane
    local scrollContentBound={xMin=pauseMenu.x+200, xMax = pauseMenu.x+475, yMin=pauseMenu.y+250, yMax=pauseMenu.y+350}
    scrollContentBound.width=scrollContentBound.xMax-scrollContentBound.xMin
    scrollContentBound.height=scrollContentBound.yMax-scrollContentBound.yMin
    pauseMenu:addButtonToScrollpane(pauseMenu:getItemByID("btnVolume"), scrollContentBound)
    pauseMenu:addButtonToScrollpane(pauseMenu:getItemByID("btnPlay"), scrollContentBound)
    pauseMenu:addButtonToScrollpane(pauseMenu:getItemByID("btnExit"), scrollContentBound)

    	
    -- function callbacks
    pauseMenu:getItemByID("scrollUp").callbackUp=function()
        pauseMenu:scrollY(-100)
    end
    pauseMenu:getItemByID("scrollDown").callbackUp=function()
    	pauseMenu:scrollY(100)
    end

    pauseMenu:getItemByID("btnPlay").callbackDown=function()
			pauseMenu:destroy()
			gameWorld.gameState="running"
    		inGameUI.makeControlMenu()	
	end
	
    pauseMenu:getItemByID("btnExit").callbackDown=function()
			composer.gotoScene("Screens.mainMenu", {effect = "fade", params = {callingScene="gameWorld"}})
	end
	
    -- on pressing the volume button the volume should be set accordingly to which button is being displayed
    pauseMenu:getItemByID("btnVolume").callbackDown=function()
 			if volumeLevel==0 then
 				preferenceHandler.set("volumeLevel",1)
                soundManager.playBackgroundMusic()
                soundManager.setGain()
 			elseif	volumeLevel==1 then
 				preferenceHandler.set("volumeLevel",2)
    			soundManager.setGain()
 			elseif volumeLevel==2 then
 				preferenceHandler.set("volumeLevel",3)
    			soundManager.setGain()
 			elseif volumeLevel==3 then
 				preferenceHandler.set("volumeLevel",0)
 				soundManager.stopAllAudios()	
 			end

    		pauseMenu:destroy() -- destroy the current menu
    		makePauseMenu() -- make a new menu with the right volume button
	end
end

--------------------

return inGameUI