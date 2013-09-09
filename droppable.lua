-- init class
Droppable = {}
Droppable.__index = Droppable

-- constants
THROW_DURATION = 2
THROW_STEP = 0.05

-- base coordinates for quads
droppableX = (SPRITE_WIDTH + SPRITE_SPACER)
droppableY = 2 * (SPRITE_HEIGHT + SPRITE_SPACER) + 1

coinQuad 	= love.graphics.newQuad(SPRITE_SPACER, droppableY, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
meatQuad 	= love.graphics.newQuad(droppableX + SPRITE_SPACER, droppableY, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
peasantQuad = love.graphics.newQuad(2 * droppableX + SPRITE_SPACER, droppableY, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
nobelQuad 	= love.graphics.newQuad(3 * droppableX + SPRITE_SPACER, droppableY, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)

-- creates a random coin or meat drop
function Droppable.createRandom()
	return Droppable.create(math.random(1,2))
end

-- creates a new droppable object
function Droppable.create(type)
	local self = {}
	setmetatable(self,Droppable)
	if type == 1 or type == 2 then -- coin/meat
		self.speed = math.random(globalSpeed,globalSpeed+20)
		self.x = 224
		self.y = 12
		self.falling = true
	elseif type == 3 then -- coin thief
		self.speed = 250
		self.x = 0
		self.y = HEIGHT - 32
		self.falling = false
		self.firstThrow = true
	elseif type == 4 then -- meat thief
		self.speed = 250
		self.x = WIDTH - 32
		self.y = HEIGHT - 32
		self.falling = false
		self.firstThrow = true
	end
	self.type = type
	self.alive = true
	self.thrown = false
	return self
end

-- updates the position of the droppable on fall/throw
function Droppable:update(dt)
	if not self.alive then
		return
	end

	-- throw animation
	if self.thrown then
		self.t = self.t + THROW_STEP
		local t = self.t
		-- bezier curve
		local x = ( (1-t) * (1-t) * self.x + 2 * (1-t) * t * self.bezierX + t * t * self.roomX )
		local y = ( (1-t) * (1-t) * self.y + 2 * (1-t) * t * self.bezierY + t * t * self.roomY )

		self.x = x
		self.y = y 

		if t >= THROW_DURATION or ((self.type == 3 or self.type == 4) and self.y >= 400 and self.firstThrow) then
			-- ejected thief
			if (self.type == 3 or self.type == 4) and self.firstThrow then
				self.falling = true
				self.thrown = false
				self.x = 224
				self.y = 424
				droppable.alive = false
				self.firstThrow = false
			else -- normal throw end
				self.alive = false
			end
		end

		return
	end

	-- falling from above
	if self.falling then
		self.y = self.y + self.speed * dt
		if self.y >= 480 then
			if self.type == 1 or self.type == 2 then
				pl.status = 1
			else 
				pl.status = 2
			end
			self.falling = false
		end
	end
end

-- Creates a bezier curve via 3 points (current, mid, end)
-- 1: Peasants (0,448)
-- 2: Treasure Room (0,HEIGHT)
-- 3: Meat Storage (WIDTH,HEIGHT)
-- 4: Nobles (WIDTH,448)
-- 5: King from Treasure Room (224,448)
-- 6: King from Meat Storage (224,448)
function Droppable:throwTo(direction)
	self.thrown = true
	self.t = 0
	if direction == 1 then
		self.roomX = 0
		self.roomY = 448
		self.bezierX = 128
		self.bezierY = 380
	elseif direction == 2 then
		self.roomX = 0
		self.roomY = HEIGHT
		self.bezierX = 150
		self.bezierY = HEIGHT - 112
	elseif direction == 3 then
		self.roomX = WIDTH
		self.roomY = HEIGHT
		self.bezierX = WIDTH - 150
		self.bezierY = HEIGHT - 112
	elseif direction == 4 then
		self.roomX = WIDTH
		self.roomY = 448
		self.bezierX = WIDTH - 128
		self.bezierY = 380
	else 
		self.roomX = 224
		self.roomY = 400
		if direction == 5 then
			self.bezierX = 150
			self.bezierY = HEIGHT - 112
		else
			self.bezierX = WIDTH - 150
			self.bezierY = HEIGHT - 112
		end
	end
end

-- draws the droppable
function Droppable:draw()
	if not self.alive then
		return
	end

	if self.type == 1 then -- coin
		love.graphics.drawq(imgSprites,coinQuad,self.x,self.y)
	elseif self.type == 2 then -- meat
		love.graphics.drawq(imgSprites,meatQuad,self.x,self.y)
	elseif self.type == 3 then -- peasant
		love.graphics.drawq(imgSprites,peasantQuad,self.x,self.y)
	else -- noble
		love.graphics.drawq(imgSprites,nobelQuad,self.x,self.y)
	end
end
