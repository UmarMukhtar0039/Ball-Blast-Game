local app42={newsIsFetched=false, newsTable={}}

local App42API = require("App42-Lua-API.App42API")  

local dbName, dataCollectionName
local storageService
local newsTableLength=3

function app42.init()
	dbName="BALLBLASTDUMMY"
	dataCollectionName="newCollection"
	App42API:initialize("31d2b43de6e4343b2591a042a9d8c9f1adb53c10de147694aed91eb0263d099b","caee7d81eb000e47fe4926f8d353b1dc8f590c3d5751f9949ee8695a07cf6ac6")
	storageService=App42API:buildStorageService() 
end

--------------------
--called from external script 
--fetches news from server
function app42.fetchNews()
	local App42Callback={}

	function App42Callback:onSuccess(object)
		-- if table is not empty then first empty the whole table
		if app42.newsTable~=nil then
			for i=#app42newsTable,1,-1 do
				table.remove(newsTable,i)
			end
		end

		for i=1,table.getn(object:getJsonDocList()) do
			local jsonDocument = object:getJsonDocList()[i]:getJsonDoc()
			local string=jsonDocument["news"]
			if string~=nil then
				printDebugStmt.print("news: "..i.." "..string)
				app42.newsTable[#app42.newsTable+1]=string
			end
		end
		
		if #newsTable==newsTableLength then
			app42.newsIsFetched=true
		end
	end

	function App42CallBack:onException(exception)      
		toast.showToast("app42: onException")
		app42.newsIsFetched=false
	end

	storageService:findAllDocuments(dbName, dataCollectionName, App42CallBack)
end