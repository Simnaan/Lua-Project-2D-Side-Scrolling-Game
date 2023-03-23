
local Spike = {image = love.graphics.newImage("assets/spikes.png")}
Spike.__index = Spike
Spike.width = Spike.image:getWidth()
Spike.height = Spike.image:getHeight()
local ActiveSpikes = {}
local Player = require("player") 

function Spike:newSpike(x, y)
	local instance = setmetatable({}, Spike)
	instance.x = x
	instance.y = y

	instance.damage = 1

	instance.width = instance.image:getWidth()
	instance.height = instance.image:getHeight()

	instance.physics = {}
	instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
	instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
	instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
	instance.physics.fixture:setSensor(true)
	table.insert(ActiveSpikes, instance)
end

function Spike.removeAll()
	for i,v in ipairs(ActiveSpikes) do
		v.physics.body:destroy()
	end

	ActiveSpikes = {}
end

function Spike:update(dt)

end

function Spike:draw()
	love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Spike:updateAll(dt)
	for i,instance in ipairs(ActiveSpikes) do
		instance:update(dt)
	end
end

function Spike:drawAll() -- this is used to draw all the Spikes into the world
	for i,instance in ipairs(ActiveSpikes) do
		instance:draw()
	end
end

function Spike:beginContact(a, b, collision) -- this code is used to check whether the play has collided with the Spike.
	for i,instance in ipairs(ActiveSpikes) do
		if a == instance.physics.fixture or b == instance.physics.fixture then
			if a == Player.physics.fixture or b == Player.physics.fixture then
				Player:damage(instance.damage)
				return true
			end
		end
	end
end
return Spike