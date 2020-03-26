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

	if box:get("bestScore")== nil then
		-- debugStmt.print("preferenceHandler: initing bestScore to 0 ")
		box:set("bestScore",0)
	end
	
	if box:get("currentLevel")== nil then
		-- debugStmt.print("preferenceHandler: initing currentLevel to 1 ")
		box:set("currentLevel",1)
	end

	if box:get("volumeLevel")== nil then
		box:set("volumeLevel",3)
	end

	if box:get("currentNewsVersion")== nil then
		box:set("currentNewsVersion",1)
	end

	if box:get("playerCurrency")== nil then
		-- debugStmt.print("preferenceHandler: initing currency to 0 ")
		box:set("playerCurrency",0)
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
	box:set("bestScore",0)
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