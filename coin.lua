
local Coin = {image = love.graphics.newImage("assets/Buddah.png")}
Coin.__index = Coin
Coin.width = Coin.image:getWidth()
Coin.height = Coin.image:getHeight()
local ActiveCoins = {}
local Player = require("player") 

function Coin:newCoin(x, y)
	local instance = setmetatable({}, Coin) 
	instance.x = x
	instance.y = y

	instance.scaleX = 1
	instance.timeOffSet = math.random(0, 100)
	instance.toBeRemoved = false

	instance.physics = {}
	instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
	instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
	instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
	instance.physics.fixture:setSensor(true)
	table.insert(ActiveCoins, instance)
end

function Coin:removeCoin() -- function that removes a coin from the world and the table
	for i,instance in ipairs(ActiveCoins) do
		if instance == self then
			Player:incrementCoins()
			self.physics.body:destroy()
			table.remove(ActiveCoins, i)
		end
	end
end

function Coin.removeAll()
	for i,v in ipairs(ActiveCoins) do
		v.physics.body:destroy()
	end

	ActiveCoins = {}
end

function Coin:update(dt)
	self:spinAnimation(dt)
	self:checkRemove()
end

function Coin:checkRemove()--checks if the coin needs to be removed
	if self.toBeRemoved then
		self:removeCoin()
	end
end

function Coin:spinAnimation(dt) -- adds a spin animation to the coin
	self.scaleX = math.sin(love.timer.getTime() * 2 + self.timeOffSet)
end

function Coin:draw()
	love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Coin:updateAll(dt)
	for i,instance in ipairs(ActiveCoins) do
		instance:update(dt)
	end
end

function Coin:drawAll() -- this is used to draw all the coins into the world
	for i,instance in ipairs(ActiveCoins) do
		instance:draw()
	end
end

function Coin:beginContact(a, b, collision) -- this code is used to check whether the play has collided with the coin.
	for i,instance in ipairs(ActiveCoins) do
		if a == instance.physics.fixture or b == instance.physics.fixture then
			if a == Player.physics.fixture or b == Player.physics.fixture then
				instance.toBeRemoved = true
				return true
			end
		end
	end
end

return Coin