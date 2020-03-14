local adManager={}
local appLovin=require "scripts.externalServices.appLovinManager"
local vungle=require "scripts.externalServices.vungleManager"
local inMobi=require "scripts.externalServices.inMobiManager"
local supersonic=require "scripts.externalServices.supersonicManager"
local fbAds=require "scripts.externalServices.fbAdsManager"
local app42=require "scripts.externalServices.app42"
local toast=require "scripts.helperScripts.toast"
local textResource=require "scripts.helperScripts.textResource"
local debugStmt= require "scripts.helperScripts.printDebugStmt"
local preferenceHandler= require "scripts.helperScripts.preferenceHandler"
local menuMaker=require "scripts.menuHelper.menu"
local assetName=require "scripts.helperScripts.assetName"
local analytics=require "scripts.helperScripts.analytics"

local currentIndex-- vairable to iterate over the table that contains order of precedence of ad networks

local adSkipTimer=0--intialise the timer variables that will govern the skipping of static interstitial ads. 

--character codes for networks are: a. AppLovin v. Vungle i. InMobi s. supersonic d. appodeal f. facebookAds
local orderTable
------------------------------

--call the update function from the main script so that the adSkipTimer can be updated regularly. 
function adManager.update(delta)
	--don't waste resource in computing timer if noAds is purchased
	if(preferenceHandler.get("isNoAdsPurchased"))then
		return
	end

	adSkipTimer=adSkipTimer+delta
	--NOTE: timer is not reset here. That will done in the static ad function after an ad is successfully shown
end
-------------------------------

--this function should be called every time to attempt to re-obtain precedence from app42. Initing at start will not work since app42 obtains this asynchronously 
local function fetchAdPrecedence()
	orderTable={}
	for i=1, #app42.adPrecedence do
		orderTable[i]=app42.adPrecedence[i]
		debugStmt.print("adManager:AdPrecedence "..orderTable[i])
	end
	-- if no precedence table returned from app42, use default values
	if(#orderTable==0)then
		debugStmt.print("adManager: no precedence found on app42. Using defaults.")
		orderTable[1]="a"
		orderTable[2]="s"
		orderTable[3]="v"
		orderTable[4]="i"
	end

	--rig the order if needed for testing:
	-- orderTable={}
	-- orderTable[1]="f"
end

--Pass this function to the rewarded ad calling point of any of the ad services-- they will call this back on successful completion of the ad. 
local function rewardedAdCallback()
	toast.showToast(textResource.bonusSlipReceived)
	analytics.sendTrackingEvent("AdShown")
	preferenceHandler.set("bonusSlip",preferenceHandler.get("bonusSlip")+1)--provide a skip slip if the ad was successfully shown. 
end

------------------------------
function adManager.showStaticAd()
	--if the necessary amount of time has not elapsed since the time the last ad was shown, return. 
	if(adSkipTimer<preferenceHandler.get("adSkipTimeLimit"))then
		return
	end

	--if the user has not yet cleared the first two levels, do not shown an ad
	if(preferenceHandler.get("highestLevelCleared")<2)then
		return
	end

	--start by checking if the user has purchased no ads, if yes return 
	if(preferenceHandler.get("isNoAdsPurchased"))then
		return
	end

	--fetch ad precedence table and setting iterator to 1
	fetchAdPrecedence()
	currentIndex=1
	while(true) do
		--if all networds were exhausted and the function had still not returned, force abort the function execution
		if(currentIndex>#orderTable)then
			debugStmt.print("adManager: no static found on any network")
			return
		end

		if(orderTable[currentIndex]=="a")then--AppLovin
			if(appLovin.isStaticAdReady())then
				appLovin.showStaticAd()
				adSkipTimer=0--reset the timer since ad was successfully shown
				analytics.sendTrackingEvent("StaticAdShownAppLovin")--fire an event to indicate what network's ad was shown
				return--terminate the function
			end
		elseif(orderTable[currentIndex]=="v")then--Vungle
			if(vungle.isStaticAdReady())then
				--show static ad for vungle here
				vungle.showStaticAd()
				adSkipTimer=0--reset the timer since ad was successfully shown
				analytics.sendTrackingEvent("StaticAdShownVungle")--fire an event to indicate what network's ad was shown
				return--terminate the function
			end
		elseif(orderTable[currentIndex]=="i")then--inMobi
			if(inMobi.isStaticAdReady())then
				inMobi.showStaticAd()
				adSkipTimer=0--reset the timer since ad was successfully shown
				analytics.sendTrackingEvent("StaticAdShownInMobi")--fire an event to indicate what network's ad was shown
				return--terminate the function
			end
		elseif(orderTable[currentIndex]=="s")then--supersonic
			if(supersonic.isStaticAdReady())then
				supersonic.showStaticAd()
				adSkipTimer=0--reset the timer since ad was successfully shown
				analytics.sendTrackingEvent("StaticAdShownSupersonic")--fire an event to indicate what network's ad was shown
				return--terminate the function
			end	
		elseif(orderTable[currentIndex]=="d")then--appodeal
			if(appodeal.isStaticAdReady())then
				-- appodeal.showStaticAd()
				adSkipTimer=0--reset the timer since ad was successfully shown
				analytics.sendTrackingEvent("StaticAdShownAppodeal")--fire an event to indicate what network's ad was shown
				return--terminate the function
			end		
		elseif(orderTable[currentIndex]=="f")then--facebook
			if(fbAds.isStaticAdReady())then
				fbAds.showStaticAd()
				adSkipTimer=0--reset the timer since ad was successfully shown
				analytics.sendTrackingEvent("StaticAdShownFacebook")--fire an event to indicate what network's ad was shown
				return--terminate the function
			end		
		end

		--move to next index
		currentIndex=currentIndex+1
	end
end
-------------------------

function adManager.showRewardedAd()

	--start by fetchin ad precedence table and setting iterator to 1
	fetchAdPrecedence()
	currentIndex=1

	while(true) do
		--if all networds were exhausted and the function had still not returned, force abort the function execution
		if(currentIndex>#orderTable)then
			debugStmt.print("adManager: no RewardedAd found on any network")
			toast.showToast(textResource.adNotAvailableToast)
			analytics.sendTrackingEvent("NoAdFound")
			return
		end
		if(orderTable[currentIndex]=="a")then--AppLovin
			if(appLovin.isRewardedAdReady())then
				appLovin.showRewardedAd(rewardedAdCallback)
				return--terminate the function
			end
		elseif(orderTable[currentIndex]=="v")then--Vungle
			if(vungle.isRewardedAdReady())then
				--show rewarded ad for vungle
				vungle.showRewardedAd(rewardedAdCallback)
				return--terminate the function
			end
		elseif(orderTable[currentIndex]=="i")then--inMobi
			if(inMobi.isRewardedAdReady())then
				--show rewarded ad for inMobi
				return--terminate the function
			end
		elseif(orderTable[currentIndex]=="s")then--supersonic
			if(supersonic.isRewardedAdReady())then
				--show rewarded ad for supersonic
				supersonic.showRewardedAd(rewardedAdCallback)
				return--terminate the function
			end	
		elseif(orderTable[currentIndex]=="d")then--appodeal
			if(appodeal.isRewardedAdReady())then
				--show rewarded ad for supersonic
				-- appodeal.showRewardedAd(rewardedAdCallback)
				return--terminate the function
			end		
		elseif(orderTable[currentIndex]=="f")then--facebook
			if(fbAds.isRewardedAdReady())then--facebook doesn't support rewarded ads
				return--terminate the function
			end		
		end

		--move to next index
		currentIndex=currentIndex+1
	end
end
-------------------------

--function will perform certain checks to see if banner can be shown and if those conditions are met, precedence will be used to show a banner ad
function adManager.showBannerAd()
	-- --start by checking if the user has purchased no ads, if yes return. 
	-- if(preferenceHandler.get("isNoAdsPurchased"))then
	-- 	return
	-- end

	-- --fetch ad precedence table and setting iterator to 1
	-- fetchAdPrecedence()
	-- currentIndex=1

	-- while(true) do
	-- 	--if all networds were exhausted and the function had still not returned, force abort the function execution
	-- 	if(currentIndex>#orderTable)then
	-- 		debugStmt.print("adManager: no banner found on any network")
	-- 		return
	-- 	end

	-- 	if(orderTable[currentIndex]=="a")then--AppLovin
	-- 		if(appLovin.isBannerAdReady())then
	-- 			appLovin.showBannerAd()
	-- 			return--terminate the function
	-- 		end
	-- 	elseif(orderTable[currentIndex]=="v")then--Vungle
	-- 		if(vungle.isBannerAdReady())then
	-- 			--show banner ad for vungle here
	-- 			return--terminate the function
	-- 		end
	-- 	elseif(orderTable[currentIndex]=="i")then--inMobi
	-- 		if(inMobi.isBannerAdReady())then
	-- 			inMobi.showBannerAd()
	-- 			return--terminate the function
	-- 		end
	-- 	elseif(orderTable[currentIndex]=="s")then--supersonic
	-- 		if(supersonic.isBannerAdReady())then
	-- 			--show banner ad for supersonic here
	-- 			return--terminate the function
	-- 		end
	-- 	elseif(orderTable[currentIndex]=="d")then--appodeal
	-- 		if(appodeal.isBannerAdReady())then
	-- 			--show banner ad for appodeal here
	-- 			-- appodeal.showBannerAd()
	-- 			return--terminate the function
	-- 		end	
	-- 	elseif(orderTable[currentIndex]=="f")then--facebook
	-- 		if(fbAds.isBannerAdReady())then
	-- 			fbAds.showBannerAd()
	-- 			toast.showToast("adManager: banner ad shown")
	-- 			return--terminate the function
	-- 		end
	-- 	end

	-- 	--move to next index
	-- 	currentIndex=currentIndex+1
	-- end 
end
-------------------------

--function will hide a banner ad if one was being shown
function adManager.hideBannerAd()
	--hide applovin banner
	appLovin.hideBannerAd()

	--hide vungle banner

	--hide inMobi banner
	inMobi.hideBannerAd()

	--hide supersonic banner

	--hide appodeal banner
	-- appodeal.hideBannerAd()

	--hide facebook banner
	fbAds.hideBannerAd()
end
-------------------------

return adManager