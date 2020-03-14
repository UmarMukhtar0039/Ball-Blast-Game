local bullet = { displayGroup = nil}



local bullet_mt = {__index = bullet}

-------------------

function bullet.new(x,y)
	local newBullet = {
	x = x,  y = y,
	VX = 0, VY = -1400, 
	removeMe = false,
	damage = 20,--20, -- amount of damage on hitting obstacle
	sprite = display.newRect(bullet.displayGroup, x, y, 10,10),
	isSensor = false
	}

	return setmetatable(newBullet, bullet_mt)
end

-------------------

function bullet:updateImage()
	self.sprite.x = self.x
	self.sprite.y = self.y
end

-------------------

function bullet:update(dt)
 	self.x = self.x + self.VX * dt
	self.y = self.y + self.VY * dt

	if self.y < 100 then -- if bullet goes past 100 in negative y-axis it should pool
		self.removeMe = true
	end
	
	-- update view
	self:updateImage()
end

-------------------

function bullet:sendToPool()
	self.x = -5000
	self.y = -5000
	self.sprite.x = self.x
	self.sprite.y = self.y
	self.removeMe = false
	self.sprite.alpha = 1
	self.isSensor = false
end

-------------------

function bullet:disableBullet()
	self.sprite.alpha = 0
	self.isSensor = true
end

-------------------

return bullet