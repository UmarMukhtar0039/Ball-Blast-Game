local analytics={}
local googleAnalytics = require( "plugin.googleAnalytics" )
local debugStmt= require "helperScripts.printDebugStmt"

local deviceID=tostring(system.getInfo("deviceID")) 

--google init
googleAnalytics.init( "BB", "UA-160774884-2" )
	
--------------------------
function analytics.sendTrackingEvent(eventName)
	--if the analytics had been blocked or the environment is not a device, don't fire events
	googleAnalytics.logEvent( "BBEvent", eventName, deviceID,1)
	debugStmt.print("analytics: Event fired:"..eventName)
end

return analytics