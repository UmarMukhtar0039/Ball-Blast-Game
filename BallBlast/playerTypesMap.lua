local playerTypesMap = {}


function playerTypesMap.makePlayer(player, displayGroup)
	if (player.type == "something") then
		player.width = 200
		player.height = 100
		player.sprite = display.newRect(displayGroup, player.x, player.y, player.width, player.height)
		player.sprite.x = player.x
		player.sprite.y = player.y
	end
	
	return player
end


return playerTypesMap