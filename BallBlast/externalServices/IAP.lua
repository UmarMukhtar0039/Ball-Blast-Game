local IAP=
{
	products={}--list of all available products along with their relevant information like product title, description etc.	
}

local targetAppStore=system.getInfo( "targetAppStore" )
local store

local debugStmt=require"helperScripts.printDebugStmt"
local toast=require"helperScripts.toast"
local preferenceHandler=require"helperScripts.preferenceHandler"
local json = require("json")
local textResource=require "helperScripts.textResource"
local assetName=require "helperScripts.assetName"
local analytics=require "helperScripts.analytics"

local productIdentifiers={"com.famousdoggstudios.bb.product1","com.famousdoggstudios.bb.product2","com.famousdoggstudios.bb.product3"}
-----FWD reference
local iosStoreInited--flag will be raised once ios store is successfully inited in the update function to avoid products being loaded multiple times
local transactionListenerAndroid,transactionListenerIOS, performProductAction, productListener, checkProhibitedApp

--function to init store
function IAP.init()
	iosStoreInited=false--set to false as default
	
	--check the device platform and call the appropriate listener
	if(targetAppStore=="apple")then--iOS
        store = require( "store" )
		store.init( transactionListenerIOS)
	elseif(targetAppStore=="google")then--Android
        store = require( "plugin.google.iap.v3" )
		store.init( transactionListenerAndroid)
	end

	-- checkProhibitedApp()
end

-----------------------------------------
--since there is no init callback for store on ios, an update function should be called from a persistent script (such as main) to wait for the 
-- store to become availabe for ios and to only then load the products
function IAP.update()
	if(targetAppStore=="apple")then
		if(store.isActive and store.canLoadProducts and iosStoreInited==false)then
			store.loadProducts(productIdentifiers,productListener)
			iosStoreInited=true
		end
	end
end

------------------------------------------
--listener that will receive the productList event
function productListener(event)
	for i = 1,#event.products do
        IAP.products[#IAP.products+1]=event.products[i]--add the available products to the local list
        debugStmt.print( "IAP:"..IAP.products[#IAP.products].productIdentifier)
        debugStmt.print( "IAP:"..IAP.products[#IAP.products].localizedPrice )
        debugStmt.print( "IAP:"..IAP.products[#IAP.products].title )
        debugStmt.print( "IAP:"..IAP.products[#IAP.products].description )
	end
end
------------------------------------------
--the transaction listener for android that'll govern all store events inluding initialisation, transactions etc.
function transactionListenerAndroid(event)

	local transaction = event.transaction

   -- Google IAP initialization event
    if ( event.name == "init" ) then
        if not ( transaction.isError ) then
            -- Perform steps to enable IAP, load products, etc.
 			if(store.canLoadProducts)then
 				store.loadProducts(productIdentifiers,productListener)
 				debugStmt.print("IAP:inited"..#productIdentifiers)
			end	
        else  -- Unsuccessful initialization; output error details
            debugStmt.print("IAP:"..transaction.errorType)
			debugStmt.print("IAP:"..transaction.errorString)
        end

    -- Store transaction event
    elseif ( event.name == "storeTransaction" ) then
        if not ( transaction.state == "failed" ) then  -- Successful transaction
 			if ( transaction.state == "purchased") then
	            -- Handle a normal purchase or restored purchase here
	            performProductAction(transaction.productIdentifier)
	            store.finishTransaction( transaction )--this will end the transaction, if not called the transaction will remain incomplete and continue on next app launch
	        elseif(transition.state=="consumed")then
	        	--now make the product available for purchase
	        elseif(transition.state=="refunded")then
	        	--delete or revert any addition/change the refunded transaction would have brought about when the transaction was made. 
	        elseif ( transaction.state == "cancelled" ) then
	            -- Handle a cancelled transaction here
	        elseif ( transaction.state == "failed" ) then
	            -- Handle a failed transaction here
	        end
        else  -- Unsuccessful transaction; output error details
            debugStmt.print("IAP:"..transaction.errorType )
            debugStmt.print("IAP:"..transaction.errorString )
        end
    end
end

------------------------------------------
--the transaction listener for iOS that'll govern store transaction events
function transactionListenerIOS(event)
 	local transaction = event.transaction

    if ( transaction.isError ) then
        debugStmt.print( "IAP:"..transaction.errorType )
        debugStmt.print( "IAP:"..transaction.errorString )
    else
        -- No errors; proceed
        if ( transaction.state == "purchased" or transaction.state == "restored" ) then
            -- Handle a normal purchase or restored purchase here
 			performProductAction(transaction.productIdentifier)
 			-- Tell the store that the transaction is complete
	        -- If you're providing downloadable content, do not call this until the download has completed
	        store.finishTransaction( transaction )
        elseif ( transaction.state == "cancelled" ) then
            -- Handle a cancelled transaction here
        elseif ( transaction.state == "failed" ) then
            -- Handle a failed transaction here
        end
    end
    
end

------------------------------------------
--function to purchase a product, accepts the identifier of the product as a parameter. If prohibited app was found on device, the function will show toast and return
function IAP.purchase(productIdentifier)
	
	-- if (checkProhibitedApp())then
	-- 	toast.showToast(textResource.prohibitedAppText)
	-- 	--fire an event if a prohibited app was found
	-- 	analytics.sendTrackingEvent("BlockedProhibitedApp")
	-- 	return
	-- end

	store.purchase(productIdentifier)
end

------------------------------------------
--function to restore previously purchased product, this functionality is used when users change their devices, or clear their data 
function IAP.restore()
	store.restore()
end

------Getters,Setters & Other Helper Functions------
--these getters are used in the creation of shop menu, the name and image path of the product are fetched from these methods 
------------------------------------------
function IAP.getProductNameByID(identifier)
	local productName

	if(identifier=="com.famousdoggstudios.bb.product1")then
		productName=textResource.product1Text
	elseif(identifier=="com.famousdoggstudios.bb.product2")then
		productName=textResource.product2Text
	elseif(identifier=="com.famousdoggstudios.bb.product3")then
		productName=textResource.product3Text
	end

	return productName
end

------------------------------------------
function IAP.getAssetPathByID(identifier)
	local assetPath

	if(identifier=="com.famousdoggstudios.bb.product1")then
		assetPath=assetName.shopItem1
	elseif(identifier=="com.famousdoggstudios.bb.product1")then
		assetPath=assetName.shopItem2
	elseif(identifier=="com.famousdoggstudios.bb.product1")then
		assetPath=assetName.shopItem3
	end

	return assetPath
end

------------------------------------------
function IAP.getEffectPathByID(identifier)
	local effectPath

	if(identifier=="com.famousdoggstudios.bb.product1")then
		effectPath=assetName.shopButton2Animation
	elseif(identifier=="com.famousdoggstudios.bb.product2")then
		effectPath=assetName.shopButton3Animation
	elseif(identifier=="com.famousdoggstudios.bb.product3")then
		effectPath=assetName.shopButton4Animation
	end

	return effectPath
end

------------------------------------------
--function that'll assign an action based on the product identifier passed when a successful transaction was made for that product
function performProductAction(identifier)
	if(identifier=="com.famousdoggstudios.bb.product1")then
		debugStmt.print("purchasedProduct1")
		analytics.sendTrackingEvent("purchasedProduct1")
	elseif(identifier=="com.famousdoggstudios.bb.product2")then
		debugStmt.print("purchasedProduct2")
		analytics.sendTrackingEvent("purchasedProduct2")
	elseif(identifier=="com.famousdoggstudios.bb.product3")then
		debugStmt.print("purchasedProduct3")
		analytics.sendTrackingEvent("purchasedProduct3")   
	end
	toast.showToast(textResource.purchaseGreeting)
end

------------------------------------------
--function will use the preference value for all the prohibited app ids found and if an app exists on device, it will return true
function checkProhibitedApp()
	local string=preferenceHandler.get("prohibitedApps")

	local packageList={}

	local lastDelimiterIndex=0

	--look for delimiters and populate a table of the individual package ids
	for i=1,#string do
		if(string:sub(i,i)=="&")then
			packageList[#packageList+1]=string:sub(lastDelimiterIndex+1,i-1)
			lastDelimiterIndex=i
			debugStmt.print("IAP: prohibited package is "..tostring(packageList[#packageList]))
		end
	end

	--iterate over the package ids and attempt to load icons for those apps. If a hit is made, remove that icon from display and return true
	for i=1, #packageList do
		local appIcon= display.newImage("android.app.icon://"..tostring(packageList[i]))
		if (appIcon) then
			appIcon:removeSelf()
			appIcon=nil
			return true
		end
		-- toast.showToast("package not found"..tostring(packageList[i]))
	end

	return false
end

return IAP