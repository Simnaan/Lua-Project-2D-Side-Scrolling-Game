

local Enemy = {}
Enemy.__index = Enemy
local Player = require("player")

local ActiveEnemies = {}

function Enemy.removeAll()
   for i,v in ipairs(ActiveEnemies) do
      v.physics.body:destroy()
   end

   ActiveEnemies = {}
end

function Enemy.newEnemy(x,y)
   local instance = setmetatable({}, Enemy)
   instance.x = x
   instance.y = y
   instance.offsetSpawnY = -15
   instance.r = 0

   instance.speed = 50
   instance.xVelocity = instance.speed

   instance.health = {current = 1, max = 1}
   instance.damage = 1
   instance.alive = true

   instance.enemyState = "idle"

   instance.animation = {timer = 0, rate = 0.1}
   instance.animation.run = {total = 8, current = 1, image = Enemy.runAnim}
   instance.animation.idle = {total = 8, current = 1, image = Enemy.idleAnim}
   instance.animation.draw = instance.animation.idle.image[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.2, instance.height * 0.1)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveEnemies, instance)
end

function Enemy.loadAssets()
   Enemy.runAnim = {}
   for i=1,8 do
      Enemy.runAnim[i] = love.graphics.newImage("assets/enemy/run/"..i..".png")
   end
   Enemy.idleAnim = {}
   for i=1,8 do
      Enemy.idleAnim[i] = love.graphics.newImage("assets/enemy/idle/"..i..".png")
   end

   Enemy.width = Enemy.runAnim[1]:getWidth()
   Enemy.height = Enemy.runAnim[1]:getHeight()
end

function Enemy.removeAll()
   for i,v in ipairs(ActiveEnemies) do
      v.physics.body:destroy()
   end

   ActiveEnemies = {}
end

function Enemy:update(dt)
   self:syncPhysics()
   self:animate(dt)
end

function Enemy:damage(amount) --allows the Enemy to take damage
      if instance.health.current - amount > 0 then
      instance.health.current = instance.health.current - amount
   else
      instance.health.current = 0
      instance:died()
   end
end

function Enemy:died()
   for i,instance in ipairs(ActiveEnemies) do
      if instance == self then
         self.physics.body:destroy()
         table.remove(ActiveEnemies, i)
      end
   end
end


function Enemy:changeDirection()
   self.xVelocity = -self.xVelocity
end

function Enemy:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Enemy:setNewFrame()
   local anim = self.animation[self.enemyState]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.image[anim.current]
end

function Enemy:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
  -- self.physics.body:setLinearVelocity(self.xVelocity, 100)
end

function Enemy:draw()
   local scaleX = 1
   if self.xVelocity < 0 then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetSpawnY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end

function Enemy.updateAll(dt)
   for i,instance in ipairs(ActiveEnemies) do
      instance:update(dt)
   end
end

function Enemy.drawAll()
   for i,instance in ipairs(ActiveEnemies) do
      instance:draw()
   end
end

function Enemy:beginContact(a, b, collision) -- this code is used to check whether the play has collided with the enemy.
   for i,instance in ipairs(ActiveEnemies) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:damage(instance.damage)
         end
         instance:changeDirection()
      end
   end
end

return Enemy