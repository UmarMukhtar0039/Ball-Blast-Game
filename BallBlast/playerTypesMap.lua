local playerTypesMap = {}


function playerTypesMap.makePlayer(player, displayGroup)
	if (player.type == "something") then
		player.width = 200
		player.height = 100
		player.sprite = display.newRect(displayGroup, player.x, player.y, player.width, player.height)
		player.sprite.x = player.x
		player.sprite.y = player.y
		
		-- collision bounds	
		player.contentBound.width = player.width --- 20 
		player.contentBound.height = player.height --- 40
		player.contentBound.xOffset = nil
		player.contentBound.yOffset = -17 
		player.contentBound.xMin = player.x - player.contentBound.width * 0.5 
		player.contentBound.xMax = player.x + player.contentBound.width * 0.5
		player.contentBound.yMin = player.y - player.contentBound.height * 0.5 --+ player.contentBound.yOffset
		player.contentBound.yMax = player.y + player.contentBound.height * 0.5 --+ player.contentBound.yOffset

	end
	
	return player
end


return playerTypesMap