-- init class
Player = {}
Player.__index = Player

-- creates a new Player
function Player.create()
	local self = {}
	setmetatable(self,Player)
	self:reset()
	return self
end

-- inits/resets status
function Player:reset()
	self.frame = 0
	self.x = 224
	self.y = 512
	self.status = 0
end

-- checks for user input and handles droppable reaction
function Player:update(dt)
	-- Check keyboard input
	if love.keyboard.isDown('a') and self.status == 1 then -- throw to peasants
		self.frame = 1
		droppable:throwTo(1)
		self.status = 0
		if droppable.type == 2 then -- correct, throw meat
			gm:resetPeasants()
		else -- wrong!
			self.status = 3
			self.shameMessage = "You have brought shame upon your kingdom. \nYou have given the peasants hope!"
			highscore[difficulty] = gm.score
		end
	elseif love.keyboard.isDown('a') and self.status == 2 and ct.alive then -- toss coin thief
		self.frame = 1
		ct:throwTo(1)
		self.status = 0
		gm:resetPeasants()
	elseif love.keyboard.isDown('s') and self.status == 1 and droppable.type == 1 then -- toss coin to treasure room
		self.frame = 1
		droppable:throwTo(2)
		gm:incrementCoin()
		self.status = 0
	elseif love.keyboard.isDown('d') and self.status == 1 and droppable.type == 2 then -- toss meat to storage
		self.frame = 2
		droppable:throwTo(3)
		gm:incrementMeat()
		self.status = 0
	elseif love.keyboard.isDown('f') and self.status == 1 then -- throw to nobles
		self.frame = 2
		droppable:throwTo(4)
		self.status = 0
		if droppable.type == 1 then -- correct, throw coin
			gm:resetNobles()
		else -- wrong!
			self.status = 3
			self.shameMessage = "You have brought shame upon your kingdom. \nYou have implied that the nobles cannot feed themselves!"
			highscore[difficulty] = gm.score
		end
	elseif love.keyboard.isDown('f') and self.status == 2 and mt.alive then -- toss meat thief
		self.frame = 2
		mt:throwTo(4)
		self.status = 0
		gm:resetNobles()
	elseif love.keyboard.isDown('x') and gm.coinThief and gm.thiefCooldown <= 0 then -- dispatch coin knight
		gm:ejectCoinThief()
	elseif love.keyboard.isDown('c') and gm.meatThief and gm.thiefCooldown <= 0 then -- dispatch meat knight
		gm:ejectMeatThief()
	else
		self.frame = 0;
	end
end

-- draws the player & "animation"
function Player:draw()
	local x = math.floor(self.frame) * (SPRITE_WIDTH + SPRITE_SPACER) + SPRITE_SPACER
	local y = 4 * (SPRITE_HEIGHT + SPRITE_SPACER) + 1
	local quad = love.graphics.newQuad(x,y,SPRITE_WIDTH,SPRITE_HEIGHT,512,512)
	love.graphics.drawq(imgSprites,quad,self.x,self.y)
end

-- Status values:
	-- 0 = alive
	-- 1 = has item
	-- 2 = has thief
	-- 3 = SHAME!!!