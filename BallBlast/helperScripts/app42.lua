local app42={newsIsFetched=false, newsTable={}, leaderboardFetched=false}

local App42API = require("App42-Lua-API.App42API")  

local dbName, dataCollectionName
local storageService
local newsTableLength=3

local gameName, description
local gameService, scoreBoardService

function app42.init()
	dbName="BALLBLASTDUMMY"
	dataCollectionName="newCollection"
	App42API:initialize("31d2b43de6e4343b2591a042a9d8c9f1adb53c10de147694aed91eb0263d099b","caee7d81eb000e47fe4926f8d353b1dc8f590c3d5751f9949ee8695a07cf6ac6")
	storageService=App42API:buildStorageService() 
	gameName="ballblastdummy"
	description=""
	gameService = App42API.buildGameService()
	scoreBoardService = App42API.buildScoreBoardService()
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


function app42.fetchScores(Number)
	
		-- if table is not empty then first empty the whole table
	local App42Callback={}
	local leaderboard={}

	function App42Callback:onSuccess(object)	
		if table.getn(object) > 1 then   
			
			for i=1,table.getn(object) do
				local jsonDocument = object:getJsonDocList()[i]:getJsonDoc()
				local string=jsonDocument["*"]
				if string~=nil then
					leaderboard[#leaderboard+1]=string
					printDebugStmt.print("string: "..string)
				end
			end
			
			if #leaderboard==3 then
				app42.leaderboardFetched=true
			end
		end
	end

	function App42CallBack:onException(exception)      
		toast.showToast("app42: onException")
		app42.leaderboardFetched=false
	end

	gameService:getGameByName(gameName,App42CallBack)  
end

function app42.sendScore(userName, gameScore)
	local App42Callback={}
	function App42Callback:onSuccess(object)
		toast.showToast("Score saved on server!")
	end	
	function App42CallBack:onException(exception)      
		toast.showToast("Score can't be saved on server!")
	end

	scoreBoardService:saveUserScore(gameName,userName,gameScore,App42CallBack)  
end