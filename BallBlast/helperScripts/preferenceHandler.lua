local preferenceHandler={}
local GGData= require "helperScripts.GGData"
local debugStmt=require "helperScripts.printDebugStmt"
local box= GGData:new ("userdata")
local crypto = require( "crypto" )

box:enableIntegrityControl( crypto.sha512, "Famousdogg8190!" )

--perform verification on all entries
local corruptEntries = box:verifyIntegrity()
box:save()

--Init the required fields and their corresponding start values if they are presently nil
function preferenceHandler.init()
	if box:get("soundOn")== nil then
		-- debugStmt.print("preferenceHandler: initing soundOn to true")
		box:set("soundOn",true)
	end

	if box:get("launchCount")== nil then
		-- debugStmt.print("preferenceHandler: initing launchCount to 0")
		box:set("launchCount",0)
	end

	if box:get("staticAdSkipLimit")== nil then
		-- debugStmt.print("preferenceHandler: initing staticAdSkipLimit to 5")
		box:set("staticAdSkipLimit",5)
	end	

	if box:get("didUserRate")== nil then
		-- debugStmt.print("preferenceHandler: initing didUserRate to false")
		box:set("didUserRate",false)
	end

	if box:get("isNoAdsPurchased")== nil then
		-- debugStmt.print("preferenceHandler: initing isNoAdsPurchased to false")
		box:set("isNoAdsPurchased",false)
	end

	if box:get("prohibitedApps")== nil then
		-- debugStmt.print("preferenceHandler: initing prohibitedApps to nil")
		box:set("prohibitedApps","nil")
	end

	if box:get("iosVersionLink")== nil then
		-- debugStmt.print("preferenceHandler: initing iosVersionLink to nil ")
		box:set("iosVersionLink","nil")
	end

	if box:get("androidVersionLink")== nil then
		-- debugStmt.print("preferenceHandler: initing androidVersionLink to nil ")
		box:set("androidVersionLink","nil")
	end

	if box:get("minimumIosVersion")== nil then
		-- debugStmt.print("preferenceHandler: initing minimumIosVersion to 0 ")
		box:set("minimumIosVersion",0)
	end
	
	if box:get("minimumAndroidVersion")== nil then
		-- debugStmt.print("preferenceHandler: initing minimumAndroidVersion to 0 ")
		box:set("minimumAndroidVersion",0)
	end

	if box:get("isVibrationOn")== nil then
		-- debugStmt.print("preferenceHandler: initing isVibrationOn to true ")
		box:set("isVibrationOn",true)
	end

	if box:get("isHighPerformanceOn")== nil then
		-- debugStmt.print("preferenceHandler: initing isHighPerformanceOn to false ")
		box:set("isHighPerformanceOn",false)
	end

	if box:get("currency")== nil then
		-- debugStmt.print("preferenceHandler: initing currency to 100 ")
		box:set("currency",100)
	end

	if box:get("cumulativeScore")== nil then
		-- debugStmt.print("preferenceHandler: initing cumulativeScore to 0 ")
		box:set("cumulativeScore",0)
	end

	if box:get("bestScore")== nil then
		-- debugStmt.print("preferenceHandler: initing bestScore to 0 ")
		box:set("bestScore",0)
	end
	
	if box:get("currentLevel")== nil then
		-- debugStmt.print("preferenceHandler: initing currentLevel to 1 ")
		box:set("currentLevel",1)
	end

	if box:get("currentWaterPower")== nil then
		-- debugStmt.print("preferenceHandler: initing currentWaterPower to 0.5 ")
		box:set("currentWaterPower",0.5)
	end

	if box:get("waterPowerCost")== nil then
		-- debugStmt.print("preferenceHandler: initing waterPowerCost to 50 ")
		box:set("waterPowerCost",50)
	end

	if box:get("didUpgradeWaterPower")== nil then--pref will be used in forcing the user to upgrade their water power at least once. 
		-- debugStmt.print("preferenceHandler: initing didUpgradeWaterPower to false ")
		box:set("didUpgradeWaterPower",false)
	end

	if box:get("highestLevelCleared")== nil then
		-- debugStmt.print("preferenceHandler: initing highestLevelCleared to 0 ")
		box:set("highestLevelCleared",0)
	end
	
	--unlock and select the default background and pipe
	if box:get("isBg1Purchased")== nil then
		-- debugStmt.print("preferenceHandler: initing isBg1Purchased to true ")
		box:set("isBg1Purchased",true)
	end
	if box:get("lastSelectedBg")== nil then
		-- debugStmt.print("preferenceHandler: initing lastSelectedBg to bg1 ")
		box:set("lastSelectedBg","bg1")
	end
	if box:get("isPipe1Purchased")== nil then
		-- debugStmt.print("preferenceHandler: initing isPipe1Purchased to true ")
		box:set("isPipe1Purchased",true)
	end
	if box:get("lastSelectedPipe")== nil then
		-- debugStmt.print("preferenceHandler: initing lastSelectedPipe to pipe1 ")
		box:set("lastSelectedPipe","pipe1")
	end
	
	--rig prefs
	-- box:set("didUserRate",false)
	-- box:set("currency",100)
	-- box:set("bestScore",0)
	-- box:set("isBg1Purchased",true)
	-- box:set("isBg2Purchased",true)
	-- box:set("isBg3Purchased",true)
	-- box:set("isBg4Purchased",true)
	-- box:set("isBg5Purchased",true)
	-- box:set("currentWaterPower",1)
	-- box:set("lastSelectedBg","bg1")
	-- box:set("isPipe5Purchased",false)
	-- box:set("isPipe6Purchased",false)

	box:save()
end

---------------------------------------
--mount the box into the preferenceHandler table for external use
preferenceHandler.box=box

--Used the getter ans setter methods rather than directly accessing box
function preferenceHandler.get(field)
	local toReturn= box:get(field)
	if toReturn=="true" then
		return true
	elseif toReturn=="false" then
		return false
	else
		return toReturn
	end
end

------------------------

function preferenceHandler.set(field, value)
	local val=nil
	if value==true then
		val="true"
	elseif value==false then
		val="false"
	else
		val=value
	end
	box:set(field,val)
	box:save()
end

------------------------

--clear the list and reset preferences
function preferenceHandler.clearPreferences()
	box:clear()
	preferenceHandler.init()
end


return preferenceHandler