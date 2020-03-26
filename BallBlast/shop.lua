local shop={}


-- local IAP=require("externalServices.IAP")
local menuMaker=require("menuHelper.menu")
local assetName=require("helperScripts.assetName")
local textResource=require("helperScripts.textResource")
local IAP=require("externalServices.IAP")
local toast=require("helperScripts.toast")
local debugStmt=require("helperScripts.printDebugStmt")
local preferenceHandler=require("helperScripts.preferenceHandler")

local shopMenu

function shop.makeShopMenu(callBack)

    shopMenu=menuMaker.newMenu("shopMenu",50,200,nil,assetName.baseMenu,666,998,true)	
    
    --Menu title text
    shopMenu:addTextDisplay({xRelative=333,yRelative=60,font=assetName.mtv,fontSize=textResource.fontXXL,string=textResource.showMenuTitle,
    colour={r=1,g=1,b=1}})

   -- available cash
    shopMenu:addTextDisplay({xRelative=200, yRelative=200,font=assetName.mtv, fontSize=textResource.fontL,string="Available Cash",
    colour={r=1,g=1,b=1},align="left",width=300})
    shopMenu:addTextDisplay({id="currencyText",xRelative=350, yRelative=200,font=assetName.mtv,fontSize=textResource.fontL,string=tostring(preferenceHandler.get("playerCurrency"))
    ,colour={r=1,g=1,b=1}})


    -- shopProducts[#shopProducts+1] = {}
    -- shopProducts[#shopProducts].productIdentifier = "com.famousdoggstudios.bb.product"..tostring(i)
    -- shopProducts[#shopProducts].localizedPrice=50+i
    -- shopProducts[#shopProducts].title="Product "..tostring(i)
    -- shopProducts[#shopProducts].description="background"..tostring(i)
    local products={}
	--if products information was fetched in IAP script
	if(#IAP.products>0)then
		products=IAP.products
	else -- rig shop
		--define products in the required order
		products[1]={}
		products[1].productIdentifier="com.famousdoggstudios.bb.product1"
		products[1].localizedPrice="1"
		products[1].title="Product 1"
		products[2]={}
		products[2].productIdentifier="com.famousdoggstudios.bb.product2"
		products[2].localizedPrice="2"
		products[2].title="Product 2"
		products[3]={}
		products[3].productIdentifier="com.famousdoggstudios.bb.product3"
		products[3].localizedPrice="3"
		products[3].title="Product 3"
	end

    --adding items in Shop Menu--------------
    --make purchasable product 1
    -- shopMenu:addImage({xRelative=333, yRelative=300,})
    shopMenu:addTextDisplay({xRelative=333,yRelative=180,font=assetName.mtv,fontSize=textResource.fontL,string=products[1].title,
        colour={r=255/255,g=255/255,b=255/255},align="center",width=300})
    shopMenu:addTextDisplay({xRelative=413,yRelative=265,font=assetName.mtv,fontSize=textResource.fontL,string=products[1].localizedPrice,
        colour={r=255/255,g=255/255,b=255/255},align="left",width=200})    
        
    shopMenu:addButton("IAP1Button",550,210,80,80,nil,assetName.blankButton,nil,nil,nil,nil,true)
    shopMenu:getItemByID("IAP1Button"):addTextDisplay({xRelative=0,yRelative=-2,font=assetName.mtv,fontSize=textResource.fontL,string=products[1].localizedPrice,
        colour={r=255/255,g=255/255,b=255/255}})
    shopMenu:getItemByID("IAP1Button").callbackUp=function()
        -- IAP.purchase(products[i].productIdentifier)
        debugStmt.print("shop: purchasing product - "..products[1].title)
        toast.showToast("product is comin")
        local playerMoney=preferenceHandler.get("playerCurrency") - products[1].localizedPrice
        printDebugStmt.print("playerMOney "..playerMoney)
        preferenceHandler.set("playerCurrency",playerMoney)
        end


    -- on close button
    shopMenu:addButton("closeButton",350,950,150,80)
	shopMenu:getItemByID("closeButton"):addTextDisplay({id="closeText",string="Close",xRelative=0,yRelative=0,fontSize=30,colour={r=1,g=0,b=0}})
    shopMenu:getItemByID("closeButton").callbackUp=function()
        shopMenu:destroy()
        callBack()
    end
end

----------------------------------
--update the contents of shop menu
function shop.update()
	--update available slips count in get slips button
	if(shopMenu~=nil)then
		shopMenu:getItemByID("currencyText").text=tostring(preferenceHandler.get("playerCurrency"))
	end
end

----------------------------------
return shop