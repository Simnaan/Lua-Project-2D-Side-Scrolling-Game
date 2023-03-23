
local GUI = {}
local Player = require("player") 

function GUI:load()
	self.coins = {}
	self.coins.image = love.graphics.newImage("assets/Buddah.png")
	self.coins.width = self.coins.image:getWidth()
	self.coins.height = self.coins.image:getHeight()
	self.coins.scale = 3
	self.coins.x = 75
	self.coins.y = 100

	self.font = love.graphics.newFont("assets/invasion2000.regular.ttf", 36)

	self.hearts = {}
	self.hearts.image = love.graphics.newImage("assets/heart.png")
	self.hearts.width = self.hearts.image:getWidth()
	self.hearts.height = self.hearts.image:getHeight()
	self.hearts.x = 0
	self.hearts.y = 30
	self.hearts.scale = 2
	self.hearts.spacing = self.hearts.width * self.hearts.scale + 30
end

function GUI:update(dt )

end

function GUI:draw()
	self:displayCoins()
	self:CoinCounter()
	self:displayHearts()
end

function GUI:displayHearts()
	for i=1,Player.health.current do
		local x = self.hearts.x + self.hearts.spacing * i
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.draw(self.hearts.image, x + 2, self.hearts.y + 2, 0, self.hearts.scale, self.hearts.scale)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(self.hearts.image, x, self.hearts.y, 0, self.hearts.scale, self.hearts.scale)
	end
end

function GUI:displayCoins()

	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.draw(self.coins.image, self.coins.x + 2, self.coins.y + 2, 0, self.coins.scale, self.coins.scale)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.coins.image, self.coins.x, self.coins.y, 0, self.coins.scale, self.coins.scale)

end

function GUI:CoinCounter()
	love.graphics.setFont(self.font)
	local x = self.coins.x + self.coins.width * self.coins.scale
	local y = self.coins.y + self.coins.height / 2 * self.coins.scale - self.font:getHeight() / 2
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.print(" : "..Player.coins, x + 2, y + 2)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(" : "..Player.coins, x, y)
end

return GUI