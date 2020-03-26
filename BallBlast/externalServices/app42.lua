local app42={newsIsFetched=false, newsTable={}, currentNewsVersion=nil, leaderboardIsFetched=false, leaderboardTable={}}

local App42API = require("App42-Lua-API.App42API")
local printDebugStmt = require("helperScripts.printDebugStmt")
local toast=require("helperScripts.toast")

local dbName, dataCollectionName
local storageService
local newsCount=4
local fetchNewsVersion

local gameName, description
local gameService, scoreBoardService

--------------------
-- called from main script
function app42.init()
	
	App42API:initialize("31d2b43de6e4343b2591a042a9d8c9f1adb53c10de147694aed91eb0263d099b","caee7d81eb000e47fe4926f8d353b1dc8f590c3d5751f9949ee8695a07cf6ac6")
	
	dbName="BALLBLASTDUMMY"
	dataCollectionName="newCollection"
	storageService=App42API:buildStorageService() 
	fetchNewsVersion() -- stores value of currentNewsVersion from server
	app42.fetchNews()

	gameName="ballBlastDummy"
	description="ballBlastReplica"
	gameService=App42API.buildGameService()
	scoreBoardService = App42API.buildScoreBoardService()
end

--------------------
--called from external script
--fetches news from server
function app42.fetchNews()
	app42.newsIsFetched=false
	local App42CallBack={}

	-- if dataCollectionName and databaseName is found
	function App42CallBack:onSuccess(object)
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
	function App42CallBack:onException(exception)
		toast.showToast("app42: onException")
		app42.newsIsFetched=false
	end

	storageService:findAllDocuments(dbName, dataCollectionName, App42CallBack)
end

--------------------
-- fetches the news version from 
function fetchNewsVersion( )
	local App42CallBack={}
	local collectionName="generalDataCollection"

	function App42CallBack:onSuccess(object)
		for i=1,table.getn(object:getJsonDocList()) do
			local jsonDocument = object:getJsonDocList()[i]:getJsonDoc()
			local newsVersion=tonumber(jsonDocument["currentNewsVersion"])
			if newsVersion~=nil then
				app42.currentNewsVersion=newsVersion
			end
		end
	end

	--documents in db are not found
	function App42CallBack:onException(exception)
		toast.showToast("app42: newCollection not found")
	end

	storageService:findAllDocuments(dbName,collectionName,App42CallBack)
end

--------------------
-- fetches score from server and displays score on clicking leaderboard button on main menu
function app42.fetchScores(number)
	
	-- if table is not empty then first empty the whole table
	local App42CallBack={}
	app42.leaderboardIsFetched=false

	function App42CallBack:onSuccess(object)      
		
		if app42.leaderboardTable~=nil then
			for i=#app42.leaderboardTable,1,-1 do
				table.remove(app42.leaderboardTable,i)
			end
		end
		
		for i=1,table.getn(object:getScoreList()) do              
				app42.leaderboardTable[#app42.leaderboardTable+1]={}
				app42.leaderboardTable[#app42.leaderboardTable].name=object:getScoreList()[i]:getUserName()
				app42.leaderboardTable[#app42.leaderboardTable].score=object:getScoreList()[i]:getValue()	
		end
		
		if #app42.leaderboardTable==number then
			toast.showToast("leaderBoard fetched")
			app42.leaderboardIsFetched=true
		end
	end  

	function App42CallBack:onException(exception)      
		toast.showToast("app42: onException")
		app42.leaderboardIsFetched=false
	end
			
	scoreBoardService:getTopNRankers(gameName,number,App42CallBack)
end

--------------------
-- this script is called from external script whenever we want to send score to server i.e. when bestscore in pref. is beaten
function app42.sendScore(userName, gameScore)
	local App42CallBack={}
	
	function App42CallBack:onSuccess(object)
		toast.showToast("Score saved on server!")
	end	

	function App42CallBack:onException(exception)      
		toast.showToast("Score can't be saved on server!")
	end
	
	scoreBoardService:saveUserScore(gameName,userName,gameScore,App42CallBack)  
end
--------------------

return app42