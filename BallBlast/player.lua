local player = { displayGroup = nil}

local typesMap = require("playerTypesMap")

local player_mt = {__index = player}

function player.new(type, x, y)
	local newPlayer = {
		type = type,
		x = x,
		y = y,
		VX = 300,
		VY = 0,
		dir = nil,
		sprite = nil, -- actual sprite of player
		-- shadow = nil -- shadow of player
		--collision properties
		contentBound = {xMin = nil, yMin = nil, xMax = nil, yMax = nil, width = nil, height = nil}		

	}

	newPlayer = typesMap.makePlayer(newPlayer, player.displayGroup) -- make object's view based on its type

	return setmetatable(newPlayer, player_mt)  -- this will return an object of this class
end

---------------------------
function player:updateBound( )
	self.contentBound.xMin = self.x - self.contentBound.width * 0.5
	self.contentBound.xMax = self.x + self.contentBound.width * 0.5
	self.contentBound.yMin = self.y - self.contentBound.height * 0.5 --+ self.contentBound.yOffset
	self.contentBound.yMax = self.y + self.contentBound.height * 0.5 --+ self.contentBound.yOffset
end
---------------------------

-- updating view
function player:updateImage( )
	self.sprite.x = self.x
	self.sprite.y = self.y
end

---------------------------

-- updating model
function player:update(dt)
	if self.dir == "r" then
		self.x = self.x + self.VX * dt
		self.y = self.y + self.VY * dt
	elseif self.dir == "l" then
		self.x = self.x - self.VX * dt
	end
	
	self:updateBound()
	self:updateImage()
end

---------------------------

return player