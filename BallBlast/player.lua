local player = { displayGroup = nil}

local playerTypesMap = require("playerTypesMap")

local player_mt = {__index = player}

function player.new(type, x, y)
	local newPlayer = {
		type = type
		x = x
		y = y
		vx = 200
		vy = 0
		sprite = nil -- actual sprite of player
		-- shadow = nil -- shadow of player
	}

	newPlayer = playerTypesMap.makePlayer(newPlayer, displayGroup) -- make object's view based on its type

	return setmetatable(newPlayer, player_mt) -- this will return an object of this class
end


function player.update(dt)
	player.x = player.x + player.vx * dt
	player.y = player.y + player.vy * dt

	player:updateImage()
end

function player:updateImage( )
	self.sprite.x = self.x
	self.sprite.y = self.y
end


return player