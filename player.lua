
local Player={}

function Player:load()
	self.x = 10
	self.y = 0
	self.defaultX = self.x
	self.defaultY = self.y
	self.width = 20
	self.height = 60
	self.xVelocity = 0
	self.yVelocity = 100
	self.maxVelocity = 200
	self.acceleration = 4000
	self.friction = 2000
	self.gravity = 1500
	self.jumpValue = -500
	self.coins = 0
	self.health = {current = 3, max = 3}

	self.color = {
		red = 1,
		green = 1,
		blue = 1,
		speed = 3,
	}

	self.alive = true
	self.damaged = false
	self.attacking = false
	self.damageDelt = 1

	self.grounded = false
	self.direction = "right"
	self.characterState = "idle"

	self:loadAssets()

	--This variable stores all the collision informaton for the character
	self.physics = {}
	self.physics.body = love.physics.newBody(World, self.x, self.y,	"dynamic") --gave the charcter the dynamic property so it can move around the world freely
	self.physics.body:setFixedRotation(true) --set fixed rotation to true so the character model doesnt rotate
	self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
	self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)

end

function Player:loadAssets() --Loads the character sprite and stores the images in a table
	self.animation = {timer = 0, rate = 0.1}

	self.animation.run = {total = 8, current = 1, image = {}}
	for i = 1, self.animation.run.total do
		self.animation.run.image[i] = love.graphics.newImage("Assets/Anims/run/"..i..".png")
	end

	self.animation.idle = {total = 4, current = 1, image = {}}
	for i = 1, self.animation.idle.total do
		self.animation.idle.image[i] = love.graphics.newImage("Assets/Anims/idle/"..i..".png")
	end

	self.animation.jump = {total = 2, current = 1, image = {}}
	for i = 1, self.animation.jump.total do
		self.animation.jump.image[i] = love.graphics.newImage("Assets/Anims/jump/"..i..".png")
	end

	self.animation.fall = {total = 2, current = 1, image = {}}
	for i = 1, self.animation.fall.total do
		self.animation.fall.image[i] = love.graphics.newImage("Assets/Anims/fall/"..i..".png")
	end

	self.animation.attack = {total = 4, current = 1, image = {}}
	for i = 1, self.animation.attack.total do
		self.animation.attack.image[i] = love.graphics.newImage("Assets/Anims/attack/"..i..".png")
	end

	self.animation.damage = {total = 3, current = 1, image = {}}
	for i = 1, self.animation.damage.total do
		self.animation.damage.image[i] = love.graphics.newImage("Assets/Anims/damage/"..i..".png")
	end

	self.animation.draw = self.animation.idle.image[1]
	self.animation.width = self.animation.draw:getWidth()
	self.animation.height = self.animation.draw:getHeight()
end

function Player:incrementCoins() --increments coin by 1
	self.coins = self.coins + 1
end

function Player:respawn() -- respawns the charcter after he dies
	if not self.alive then
		self:resetPosition()
		self.health.current = self.health.max
		self.alive = true
	end
end

function Player:resetPosition()
	self.physics.body:setPosition(self.defaultX, self.defaultY)
end

function Player:damage(amount) --allows the player to take damage
	self:damageTint()
	if self.health.current - amount > 0 then
		self.health.current = self.health.current - amount
	else
		self.health.current = 0
		self:died()
	end
	self.damaged = false
end

function Player:damageTint()
	self.color.green = 0
	self.color.blue = 0
	self.damaged = true
end

function Player:untint(dt)
	self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
	self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
	self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Player:died()
	self.alive = false
end

function Player:update(dt)
	self:untint(dt)
	self:setState()
	self:setDirection()
	self:syncPhysics()
	self:move(dt)
	self:applyGravity(dt)
	self:animate(dt)
	self:respawn()
	--self:attack()
end

function Player:setState() --used to check which animation should be playing for the character
	if not self.grounded then
		self.characterState = "jump"
	elseif self.xVelocity == 0 then
		self.characterState = "idle"
	else
		self.characterState = "run"
	end
	if self.damaged then
		self.characterState = "damage"
	end
	if love.mouse.isDown(1) then
		self.characterState = "attack"
	end
end

function Player:animate(dt)
	self.animation.timer = self.animation.timer + dt
	if self.animation.timer > self.animation.rate then
		self.animation.timer = 0
		self:setNewFrame()
	end
end

function Player:setNewFrame()
	local anim = self.animation[self.characterState]
	if anim.current < anim.total then
		anim.current = anim.current + 1
	else
		anim.current = 1
	end
	self.animation.draw = anim.image[anim.current]
end

function Player:setDirection()--checks which direction the player is looking
	if self.xVelocity < 0 then
		self.direction = "left"
	elseif self.xVelocity > 0 then
		self.direction = "right"
	end
end

function Player:move(dt) -- this controls the left and right movement of the character. it compares the charcater current velocity to the maximum velocity allowed and if the current vleocity is lower then speeds up the character in the relevent direction.
	if love.keyboard.isDown("d", "right") then
		if self.xVelocity < self.maxVelocity then
			if self.xVelocity + self.acceleration * dt < self.maxVelocity then
				self.xVelocity = self.xVelocity + self.acceleration * dt
			else
				self.xVelocity = self.maxVelocity
			end
		end
	elseif love.keyboard.isDown("a", "left") then
		if self.xVelocity > -self.maxVelocity then
			if self.xVelocity - self.acceleration * dt > self.maxVelocity then
				self.xVelocity = self.xVelocity - self.acceleration * dt
			else
				self.xVelocity = -self.maxVelocity
			end
		end
	else
		self:applyFriction(dt)
	end	
end 

--[[function Player:attack()
	if love.mouse.isDown(1) then
		self.attacking = true
		Player:damageEnemy()
	end
end

function Player:damageEnemy()
	for i,instance in ipairs(Enemy.ActiveEnemies) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Enemy:damage(self.damageDelt)
         end
      end
   end
end8;]]--

function Player:applyFriction(dt) -- adds friction to the character to slow them down after moving. makes the motion more fluid.
	if self.xVelocity > 0 then
		if self.xVelocity - self.friction * dt > 0 then
			self.xVelocity = self.xVelocity - self.friction * dt
		else
			self.xVelocity = 0
		end
	elseif self.xVelocity < 0 then
		if self.xVelocity + self.friction * dt < 0 then
			self.xVelocity = self.xVelocity + self.friction * dt
		else
			self.xVelocity = 0
		end
	end
end

function Player:applyGravity(dt) -- applies gravity to the character
	if not self.grounded then
		self.yVelocity = self.yVelocity + self.gravity * dt
	end
end

function Player:syncPhysics()
	self.x, self.y = self.physics.body:getPosition()
	self.physics.body:setLinearVelocity(self.xVelocity, self.yVelocity)
end

function Player:beginContact(a, b, collision) -- this code is how the character interacts with the world.

	if self.grounded == true then return end
	local nx, ny = collision:getNormal()
	if a == self.physics.fixture then
		if ny > 0 then
			self:land(collision)
		elseif ny < 0 then
			self.yVelocity = 0
		end
	elseif	b == self.physics.fixture then
		if ny < 0 then
			self:land(collision)
		elseif ny > 0 then
			self.yVelocity = 0
		end
	end
end

function Player:jump(key)
	if (key == "w" or key == "up" or key == "space") and self.grounded then 
		self.yVelocity = self.jumpValue
		self.grounded = false
	end
end

function Player:land(collision)
	self.currentGround = collision
	self.yVelocity = 0 
	self.grounded = true
end

function Player:endContact(a, b, collision)
	if a == self.physics.fixture or b == self.physics.fixture then 
		if self.currentGround == collision then
			self.grounded = false
		end
	end
end

function Player:draw()
	local scaleX = 1
	if self.direction == "left" then
		scaleX = -1
	end
	if attacking then
		love.graphics.rectangle("fill", self.x, self.y, 75, 20)	
		print("YES")
	end
	love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
	love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1, self.animation.width / 2, self.animation.height / 2)
	love.graphics.setColor(1,1,1,1)
end

return Player