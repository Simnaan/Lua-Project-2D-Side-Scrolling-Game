local Map = {}
local STI = require("sti") --used an external library to import map from tiled
local Coin = require("coin")
local Enemy = require("enemy")
local Spike = require("spike")
local Player = require("player")

function Map:loadMap()
	self.currentLevel = 1
    World = love.physics.newWorld(0,2000)
    World:setCallbacks(beginContact, endContact)

    self:init()
end

function Map:init()
	self.level = STI("Map/"..self.currentLevel..".lua", {"box2d"})

	self.level:box2d_init(World)
	self.collideLayer = self.level.layers.Collide
    self.entityLayer = self.level.layers.Entity
    self.backgroundLayer = self.level.layers.Background

    self.collideLayer.visible = false
   	self.entityLayer.visible = false
    MapWidth = self.backgroundLayer.width * 16

    self:spawnEntities()
end

function Map:nextLevel()
	self:cleanMap()
	self.currentLevel = self.currentLevel + 1
	self:init()
	Player:resetPosition()
end

function Map:cleanMap()
	self.level:box2d_removeLayer("Collide")
	Coin.removeAll()
	Enemy.removeAll()
	Spike.removeAll()
end

function Map:update()
	if Player.x > MapWidth - 16 then
		self:nextLevel()
	end
end

function Map:spawnEntities()
    for i,v in ipairs(self.entityLayer.objects) do
        if v.type == "spike" then
            Spike:newSpike(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "enemy" then
            Enemy.newEnemy(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "coin" then
            Coin:newCoin(v.x, v.y)
        end
    end
end

return Map