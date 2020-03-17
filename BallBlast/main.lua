local composer = require("composer")
local soundManager=require("soundManager")
local preferenceHandler=require("helperScripts.preferenceHandler")
local deltaTime=require("helperScripts.deltaTime")
local app42=require("externalServices.app42")

-----------------------
-- update function of main
local function update()
	local dt=deltaTime.getDelta()

	soundManager.update(dt)
end

-----------------------

preferenceHandler.init() -- initializing game box that will be initialized once bcz main script only execute once
preferenceHandler.set("launchCount",preferenceHandler.get("launchCount")+1) -- incrementing launch count every time the game is launched

-- initialize soundManager
soundManager.init()

-- initialize app42
app42.init()

-- go to menu screen
composer.gotoScene("Screens.mainMenu",{ params = {callingScene="nil"}})

Runtime:addEventListener("enterFrame",update)