--the rewardedAdCallback table will be a function that will be passed from adManager at the time of calling rewardedAd. This will be called back on 
--successful completion of the rewarded ad.  
local appodealManager={rewardedAdCallback={}}

-- Require libraries/plugins
local appodeal = require "plugin.appodeal" 
local debugStmt= require "scripts.helperScripts.printDebugStmt"
local toast=require "scripts.helperScripts.toast"

-- Preset Appodeal app keys (must be replaced these with the new ones)
local appK
if ( system.getInfo("platform")=="android" ) then  -- Android
	appK = "b5de96e676f3af73547be5bd84f7532d7cf5c5da5d038a3d"
else  --iOS
	appK = "1cfff0894273b2e4c94753985092c660ac3d8db1b6db5e2d"
end

--indicate if a banner ad, rewarded ad or statc ad was available. This value is set from the listener
local isBannerAdAvailable=false
local isStaticAdAvailable=false
local isRewardedAdAvailable=false

------------------------------------
-- Ad listener function
local function adListener( event )
	-- Successful initialization of the Appodeal plugin
	if ( event.phase == "init" ) then
		debugStmt.print( "Appodeal: initialization successful" )
		appodeal.load( "banner")
		appodeal.load( "interstitial")
		appodeal.load( "rewardedVideo")

	-- An ad loaded successfully
	elseif ( event.phase == "loaded" ) then
		debugStmt.print( "Appodeal: " .. tostring(event.type) .. " ad loaded successfully" )
		if(tostring(event.type)=="interstitial")then
			isStaticAdAvailable=true
		elseif(tostring(event.type)=="rewardedVideo")then
			isRewardedAdAvailable=true
		elseif(tostring(event.type)=="banner")then
			isBannerAdAvailable=true
		end
	-- The ad was displayed/played
	elseif ( event.phase == "displayed" or event.phase == "playbackBegan" ) then
		debugStmt.print( "Appodeal: " .. tostring(event.type) .. " ad displayed" )

	-- The ad was closed/hidden/completed
	elseif ( event.phase == "hidden" or event.phase == "closed" or event.phase == "playbackEnded" ) then
		debugStmt.print( "Appodeal: " .. tostring(event.type) .. " ad closed/hidden/completed" )
		if(tostring(event.type)=="interstitial")then
			appodeal.load( "interstitial")
		elseif(tostring(event.type)=="rewardedVideo")then
			appodeal.load( "rewardedVideo")
		elseif(tostring(event.type)=="banner")then
			appodeal.load( "banner")
		end
	-- The user clicked/tapped an ad
	elseif ( event.phase == "clicked" ) then
		-- debugStmt.print( "Appodeal: " .. tostring(event.type) .. " ad clicked/tapped" )

	-- The ad failed to load
	elseif ( event.phase == "failed" ) then
		debugStmt.print( "Appodeal: " .. tostring(event.type) .. " ad failed to load" )
		debugStmt.print( "Appodeal: isError : "..tostring(event.isError))
		debugStmt.print( "Appodeal: response : "..tostring(event.response))
	end
end

----------------------------------
-- Init the Appodeal plugin
appodeal.init( adListener, { appKey=appK, testMode=false, supportedAdTypes={"banner", "interstitial", "rewardedVideo"}, 
	disableAutoCacheForAdTypes={"interstitial","rewardedVideo", "banner"},disableNetworks={"mintegral","amazon_ads","my_target"}} )

----------------------------------
--function to check if a static ad is loaded. If it is not, attempt to load a new one. 
function appodealManager.isStaticAdReady()
    if isStaticAdAvailable then 
        return true
    else
        appodeal.load( "interstitial")
        debugStmt.print("Appodeal: static ad not loaded. Attempting now")
        return false
    end
end

----------------------------------
--function to check if a banner is loaded. Always return false for startapp
function appodealManager.isBannerAdReady()
    if isBannerAdAvailable then 
        return true
    else
        appodeal.load( "banner")
         debugStmt.print("Appodeal: banner ad not loaded. Attempting now")
        return false
    end
end

---------------------------------
--see other adManagers for reference
function appodealManager.isRewardedAdReady()
    if isRewardedAdAvailable then 
        return true
    else
        appodeal.load("rewardedVideo")
        debugStmt.print("Appodeal: rewardedVideo ad not loaded. Attempting now")
        return false
    end
end

----------------------------------
--function  to show a static interstitial ad if one is loaded
function appodealManager.showStaticAd()
    if isStaticAdAvailable then 
        appodeal.show("interstitial")
        isStaticAdAvailable=false-- consume the static ad
    end
end
----------------------------------
--function  to show a rewarded video ad if one is loaded
function appodealManager.showRewardedAd(callback)
    if isRewardedAdAvailable then 
        appodealManager.rewardedAdCallback=callback
        appodeal.show("rewardedVideo")
        isRewardedAdAvailable=false--consume the rewarded ad
    end
end
----------------------------------
--function  to show a banner  ad if one is loaded
function appodealManager.showBannerAd()
    if isBannerAdAvailable then 
        appodeal.show("banner", {yAlign="bottom"})----add params here to insert y position
    end
end

----------------------------------
--function  to hide a banner ad
function appodealManager.hideBannerAd()
    if isBannerAdAvailable then 
        appodeal.hide("banner")
        isBannerAdAvailable=false-- consume the ad whenever hide is called
    end
end
----------------------------------

return appodealManager