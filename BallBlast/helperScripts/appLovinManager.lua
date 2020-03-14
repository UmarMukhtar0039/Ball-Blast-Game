--the rewardedAdCallback table will be a function that will be passed from adManager at the time of calling rewardedAd. This will be called back on 
--successful completion of the rewarded ad. 
local appLovinManager={rewardedAdCallback={}}
local applovin = require( "plugin.applovin" )
local toast=require "scripts.helperScripts.toast"
local debugStmt= require "scripts.helperScripts.printDebugStmt"
local preferenceHandler=require "scripts.helperScripts.preferenceHandler"

local sdkKey
if(system.getInfo( "platform" )=="android")then--android
    --if the preference that was fetched and stored from app42 indicates that ads need to be run off publisher account, init the SDK accordingly, else use our own settings
    if(preferenceHandler.get("isPublisherActive"))then
        sdkKey="KHzTI_3Zbib_B7T8i5Z7QbhHkZQLDTgLCC7Z-qRJN9cppuAyoyH49TNW-uzSZsWz5ryeXNytTbKs6m7u4m8PJT"--DT
    else
        sdkKey="rQ7hZBT6LW8eDHDS55CE-auqbUzaNT8D-GvTSMfouoR53eX9klNhKFWwkTV61dK0vDTLaC8T_ZT3C5Cxqac8q8"--famous dogg
    end
else--ios
    --if the preference that was fetched and stored from app42 indicates that ads need to be run off publisher account, init the SDK accordingly, else use our own settings
    if(preferenceHandler.get("isPublisherActive"))then
        sdkKey="t966TJ6ScstvR-sTBPM1XosX5f0uyRBqaHw8b1bCuS5JRxncL7dtwUO09Pv5r4vQMqZys98kcE13ApgWxINron"--appsolute
    else
        sdkKey="rQ7hZBT6LW8eDHDS55CE-auqbUzaNT8D-GvTSMfouoR53eX9klNhKFWwkTV61dK0vDTLaC8T_ZT3C5Cxqac8q8"--famous dogg
    end
end

--indicate if a rewardedvideo ad or statc ad was available. This value is set from the listener
local isRewardedAdAvailable=false
local isStaticAdAvailable=false
local isBannerAdAvailable=false
----------------------------------
local function adListener( event )
    if ( event.phase == "init" ) then  -- Successful initialization
        debugStmt.print( "appLovin:init "..tostring(event.isError) )
        applovin.setHasUserConsent( true )
        -- Load an AppLovin static and video ad
        applovin.load("interstitial")
        applovin.load("rewardedVideo")
        applovin.load("banner")
    elseif ( event.phase == "loaded" ) then  -- The ad was successfully loaded
        debugStmt.print( "appLovin:loaded"..event.type )
        if(event.type=="rewardedVideo")then
            isRewardedAdAvailable=true
        elseif(event.type=="interstitial")then
            isStaticAdAvailable=true
        elseif(event.type=="banner")then
            isBannerAdAvailable=true    
        end
    elseif ( event.phase == "failed" ) then  -- The ad failed to load
        debugStmt.print( "appLovin:failed"..event.type )
        debugStmt.print( "applovin:failed"..tostring(event.isError))
        debugStmt.print( "appLovin: failed"..event.response )
    elseif ( event.phase == "displayed" or event.phase == "playbackBegan" ) then  -- The ad was displayed/played
        debugStmt.print( "appLovin:playbackBegan"..event.type )
    elseif ( event.phase == "hidden" or event.phase == "playbackEnded" ) then  -- The ad was closed/hidden
        debugStmt.print( "appLovin:playBack Ended "..event.type )
        if(event.type=="rewardedVideo")then
            --load another ad only after one ad was closed
            applovin.load("rewardedVideo")
        elseif(event.type=="interstitial")then
            applovin.load("interstitial")
        elseif(event.type=="banner")then
            applovin.load("banner")    
        end
    elseif ( event.phase == "clicked" ) then  -- The ad was clicked/tapped
        debugStmt.print( "Applovin:"..event.type )      
    elseif ( event.phase == "declinedToView" ) then  --start defining pahses for rewarded video ads
        debugStmt.print("Applovin: User declined to view ad")
    elseif ( event.phase == "validationSucceeded" ) then  
        debugStmt.print("Applovin: validation succeeded")   
        appLovinManager.rewardedAdCallback()
    elseif ( event.phase == "validationRejected" ) then 
        debugStmt.print("Applovin: validationRejected")    
        -- Indicates that the AppLovin server rejected the reward request.
    elseif ( event.phase == "validationFailed" ) then 
        debugStmt.print("Applovin: validationFailed")  
        --  AppLovin server could not be contacted
    end
end

-- Initialize the AppLovin plugin
applovin.init( adListener, { sdkKey=sdkKey} )

----------------------------------
--function to check if a static ad is loaded. If it is not, attempt to load a new one. 
function appLovinManager.isStaticAdReady()
    if isStaticAdAvailable then 
        return true
    else
        applovin.load("interstitial")
        return false
    end
end

----------------------------------
--function to check if a banner is loaded. If it is not, attempt to load a new one. 
function appLovinManager.isBannerAdReady()
    if isBannerAdAvailable then 
        return true
    else
        applovin.load("banner")
        return false
    end
end

----------------------------------
--function to check if a rewarded ad is ready and load a new one if an ad was not found
function appLovinManager.isRewardedAdReady()
    if isRewardedAdAvailable then 
        return true
    else
        applovin.load("rewardedVideo")
        return false
    end
end

----------------------------------
--function  to show a static interstitial ad if one is loaded
function appLovinManager.showStaticAd()
    if isStaticAdAvailable then 
        applovin.show("interstitial")
        isStaticAdAvailable=false-- consume the static ad
    end
end

----------------------------------
--function  to show a banner  ad if one is loaded
function appLovinManager.showBannerAd()
    if isBannerAdAvailable then 
        applovin.show("banner", {y="bottom"})----add params here to insert y position
    end
end

----------------------------------
--function  to hide a banner ad
function appLovinManager.hideBannerAd()
    if isBannerAdAvailable then 
        applovin.hide("banner")
        isBannerAdAvailable=false-- consume the ad whenever hide is called
    end
end

---------------------------------
--function  to show a rewarded video ad if one is loaded
function appLovinManager.showRewardedAd(callback)
    if isRewardedAdAvailable then 
        appLovinManager.rewardedAdCallback=callback
        applovin.show("rewardedVideo")
        isRewardedAdAvailable=false--consume the rewarded ad
    end
end


return appLovinManager 