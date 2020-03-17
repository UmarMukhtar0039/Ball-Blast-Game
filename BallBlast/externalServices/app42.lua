local app42={newsIsFetched=false, newsTable={}, currentNewsVersion=nil}

local App42API = require("App42-Lua-API.App42API")
local printDebugStmt = require("helperScripts.printDebugStmt")
local toast=require("helperScripts.toast")

local dbName, dataCollectionName
local storageService
local newsCount=4
local currentNewsVersion
local fetchNewsVersion
--------------------
-- called from main script
function app42.init()
	dbName="BALLBLASTDUMMY"
	dataCollectionName="newCollection"
	App42API:initialize("31d2b43de6e4343b2591a042a9d8c9f1adb53c10de147694aed91eb0263d099b","caee7d81eb000e47fe4926f8d353b1dc8f590c3d5751f9949ee8695a07cf6ac6")
	storageService=App42API:buildStorageService() 
	fetchNewsVersion() -- stores value of currentNewsVersion from server
end

--------------------
--called from external script
--fetches news from server
function app42.fetchNews()
	local App42Callback={}


	-- if dataCollectionName and databaseName is found
	function App42Callback:onSuccess(object)
		-- if table is not empty then first empty the whole table
		if app42.newsTable~=nil then
			for i=#app42.newsTable,1,-1 do
				table.remove(app42.newsTable,i)
			end
		end
		
		for i=1,table.getn(object:getJsonDocList()) do
			local jsonDocument = object:getJsonDocList()[i]:getJsonDoc()
			
			local string=jsonDocument["news"]
			if string~=nil then
				-- printDebugStmt.print("news: "..i.." "..string)
				app42.newsTable[#app42.newsTable+1]=string
			end
		end
		
		-- if news table length is equal to the predefined length that means news is fetched
		if #app42.newsTable==newsCount then
			app42.newsIsFetched=true
		end
	end

	--documents in db are not found
	function App42Callback:onException(exception)
		toast.showToast("app42: onException")
		app42.newsIsFetched=false
	end

	storageService:findAllDocuments(dbName, dataCollectionName, App42Callback)
end

--------------------
-- fetches the news version from 
function fetchNewsVersion( )
	local App42Callback={}
	local collectionName="generalDataCollection"

	function App42Callback:onSuccess(object)
		for i=1,table.getn(object:getJsonDocList()) do
			local jsonDocument = object:getJsonDocList()[i]:getJsonDoc()
			local newsVersion=tonumber(jsonDocument["currentNewsVersion"])
			if newsVersion~=nil then
				app42.currentNewsVersion=newsVersion
				printDebugStmt.print("app 42: cv set "..app42.currentNewsVersion)	
			end
		end
	end

	--documents in db are not found
	function App42Callback:onException(exception)
		toast.showToast("app42: newCollection not found")
	end

	storageService:findAllDocuments(dbName,collectionName,App42Callback)
end

--------------------

return app42