-- init class
GameManager = {}
GameManager.__index = GameManager

-- constants
BASE_PEASANT_TIME = 10
BASE_NOBLE_TIME = 8
THIEF_TIME = 2
THIEF_COOLDOWN = 5

-- base coordinates for quads
baseX = (SPRITE_WIDTH + SPRITE_SPACER)
baseY = (SPRITE_HEIGHT + SPRITE_SPACER)

numberQuads = {
	['1'] = love.graphics.newQuad(SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512),
	['2'] = love.graphics.newQuad(baseX + SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512),
	['3'] = love.graphics.newQuad(2 * baseX + SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512),
	['4'] = love.graphics.newQuad(3 * baseX + SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512),
	['5'] = love.graphics.newQuad(4 * baseX + SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512),
	['6'] = love.graphics.newQuad(5 * baseX + SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512),
	['7'] = love.graphics.newQuad(6 * baseX + SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512),
	['8'] = love.graphics.newQuad(7 * baseX + SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512),
	['9'] = love.graphics.newQuad(8 * baseX + SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512),
	['0'] = love.graphics.newQuad(9 * baseX + SPRITE_SPACER, baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
}
-- timer
lowTimeQuad 	= love.graphics.newQuad(SPRITE_SPACER, 3 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
halfTimeQuad 	= love.graphics.newQuad(baseX + SPRITE_SPACER, 3 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
nearTimeQuad 	= love.graphics.newQuad(2 * baseX + SPRITE_SPACER, 3 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
fullTimeQuad 	= love.graphics.newQuad(3 * baseX + SPRITE_SPACER, 3 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
-- feedback
happyPQuad 		= love.graphics.newQuad(4 * baseX + SPRITE_SPACER, 3 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
happyRQuad 		= love.graphics.newQuad(5 * baseX + SPRITE_SPACER, 3 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
angryPQuad 		= love.graphics.newQuad(6 * baseX + SPRITE_SPACER, 3 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
angryRQuad 		= love.graphics.newQuad(7 * baseX + SPRITE_SPACER, 3 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
-- storage
lowCoinQuad		= love.graphics.newQuad(14 * baseX + SPRITE_SPACER, 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
highCoinQuad	= love.graphics.newQuad(9 * baseX + SPRITE_SPACER, 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
lowMeatSQuad	= love.graphics.newQuad(12 * baseX + SPRITE_SPACER, 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
highMeatSQuad	= love.graphics.newQuad(6 * baseX + SPRITE_SPACER, 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
lowMeatHQuad	= love.graphics.newQuad(13 * baseX + SPRITE_SPACER, 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
highMeatHQuad	= love.graphics.newQuad(8 * baseX + SPRITE_SPACER, 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
-- thieves
coinThiefQuad	= love.graphics.newQuad(4 * baseX + SPRITE_SPACER, 2 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
meatThiefQuad	= love.graphics.newQuad(5 * baseX + SPRITE_SPACER, 2 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
coinKnightQuad	= love.graphics.newQuad(6 * baseX + SPRITE_SPACER, 2 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)
meatKnightQuad	= love.graphics.newQuad(7 * baseX + SPRITE_SPACER, 2 * baseY + 1, SPRITE_WIDTH,SPRITE_HEIGHT, 512,512)

-- creates a game manager object
function GameManager.create()
	local self = {}
	setmetatable(self,GameManager)
	self:reset()
	return self
end

-- inits/resets the status of the game manager
function GameManager:reset()
	-- timer for sides
	self.peasantTime = 0
	self.nobleTime = 0
	-- inventory
	self.coinCount = 0
	self.meatCount = 0
	-- score
	self.score = 0
	self.scoreTimer = 0
	-- thieves
	self.thiefTime = 0
	self.thiefCooldown = 0
	self.coinThief = false
	self.meatThief = false
	-- win condition check
	self.win = false
end

-- updates states for peasants, nobles, thieves and score
function GameManager:update(dt)
	-- update timers
	self.peasantTime = self.peasantTime + dt
	self.nobleTime = self.nobleTime + dt
	self.scoreTimer = self.scoreTimer + dt

	-- spawn thieves
	if self.peasantTime > BASE_PEASANT_TIME and not self.coinThief and self.thiefCooldown <= 0 then
		self.coinThief = true
		angryFx:stop() angryFx:play()
	end
	if self.nobleTime > BASE_NOBLE_TIME and not self.meatThief and self.thiefCooldown <= 0 then
		self.meatThief = true
		angryFx:stop() angryFx:play()
	end

	-- deduct for thieves
	if self.coinThief then
		self.thiefTime = self.thiefTime + dt
		if self.thiefTime > THIEF_TIME and self.coinCount > 0 then
			self.thiefTime = 0
			self.coinCount = self.coinCount - 1
		end
	elseif self.thiefCooldown > 0 then -- prevent instant thieving!
		self.thiefCooldown = self.thiefCooldown - dt
	end
	if self.meatThief then
		self.thiefTime = self.thiefTime + dt
		if self.thiefTime > THIEF_TIME and self.meatCount > 0 then
			self.thiefTime = 0
			self.meatCount = self.meatCount - 1
		end
	elseif self.thiefCooldown > 0 then -- prevent instant thieving!
		self.thiefCooldown = self.thiefCooldown - dt
	end

	-- increment the score
	self.score = (self.coinCount * 10) + (self.meatCount * 10) + math.floor(self.scoreTimer * 10)

	-- check win condition
	if self.coinCount == 20 and self.meatCount == 20 then
		self.win = true
		highscore[difficulty] = self.score
	end
end

-- draw the score, timers, feedback and thieves
function GameManager:draw()
	-- draw timers
	if self.peasantTime < 0 then
		love.graphics.drawq(imgSprites,happyPQuad,0,400)
	elseif self.peasantTime > BASE_PEASANT_TIME/4 and self.peasantTime < 2 * (BASE_PEASANT_TIME/4) then
		love.graphics.drawq(imgSprites,fullTimeQuad,0,400)
	elseif self.peasantTime > 2 * (BASE_PEASANT_TIME/4) and self.peasantTime < 3 * (BASE_PEASANT_TIME/4) then
		love.graphics.drawq(imgSprites,nearTimeQuad,0,400)
	elseif self.peasantTime > 3 * (BASE_PEASANT_TIME/4) and self.peasantTime < BASE_PEASANT_TIME - 0.5 then
		love.graphics.drawq(imgSprites,halfTimeQuad,0,400)
	elseif self.peasantTime > BASE_PEASANT_TIME - 0.5 then
		love.graphics.drawq(imgSprites,angryPQuad,0,400)
	end

	if self.nobleTime < 0 then
		love.graphics.drawq(imgSprites,happyRQuad,WIDTH-32,400)
	elseif self.nobleTime > BASE_NOBLE_TIME/4 and self.nobleTime < 2 * (BASE_NOBLE_TIME/4) then
		love.graphics.drawq(imgSprites,fullTimeQuad,WIDTH-32,400)
	elseif self.nobleTime > 2 * (BASE_NOBLE_TIME/4) and self.nobleTime < 3 * (BASE_NOBLE_TIME/4) then
		love.graphics.drawq(imgSprites,nearTimeQuad,WIDTH-32,400)
	elseif self.nobleTime > 3 * (BASE_NOBLE_TIME/4) and self.nobleTime < BASE_NOBLE_TIME - 0.5 then
		love.graphics.drawq(imgSprites,halfTimeQuad,WIDTH-32,400)
	elseif self.nobleTime > BASE_NOBLE_TIME - 0.5 then
		love.graphics.drawq(imgSprites,angryRQuad,WIDTH-32,400)
	end

	-- storage
	if self.coinCount >= 3 then
		love.graphics.drawq(imgSprites, lowCoinQuad, 0, HEIGHT - 32)
	end
	if self.coinCount >= 6 then
		love.graphics.drawq(imgSprites, highCoinQuad, 0, HEIGHT - 32)
	end
	if self.coinCount >= 9 then
		love.graphics.drawq(imgSprites, lowCoinQuad, SPRITE_WIDTH, HEIGHT - 32)
	end
	if self.coinCount >= 12 then
		love.graphics.drawq(imgSprites, highCoinQuad, SPRITE_WIDTH, HEIGHT - 32)
	end
	if self.coinCount >= 15 then
		love.graphics.drawq(imgSprites, lowCoinQuad, 2 * SPRITE_WIDTH, HEIGHT - 32)
	end
	if self.coinCount >= 18 then
		love.graphics.drawq(imgSprites, highCoinQuad, 2 * SPRITE_WIDTH, HEIGHT - 32)
	end
	if self.meatCount >= 3 then
		love.graphics.drawq(imgSprites, lowMeatSQuad, WIDTH - 32, HEIGHT - 32)
		love.graphics.drawq(imgSprites, lowMeatHQuad, WIDTH - 32, HEIGHT - 64)
	end
	if self.meatCount >= 6 then
		love.graphics.drawq(imgSprites, highMeatSQuad, WIDTH - 32, HEIGHT - 32)
		love.graphics.drawq(imgSprites, highMeatHQuad, WIDTH - 32, HEIGHT - 64)
	end
	if self.meatCount >= 9 then
		love.graphics.drawq(imgSprites, lowMeatSQuad, WIDTH - 64, HEIGHT - 32)
		love.graphics.drawq(imgSprites, lowMeatHQuad, WIDTH - 64, HEIGHT - 64)
	end
	if self.meatCount >= 12 then
		love.graphics.drawq(imgSprites, highMeatSQuad, WIDTH - 64, HEIGHT - 32)
		love.graphics.drawq(imgSprites, highMeatHQuad, WIDTH - 64, HEIGHT - 64)
	end
	if self.meatCount >= 15 then
		love.graphics.drawq(imgSprites, lowMeatSQuad, WIDTH - 96, HEIGHT - 32)
	end
	if self.meatCount >= 18 then
		love.graphics.drawq(imgSprites, highMeatSQuad, WIDTH - 96, HEIGHT - 32)
	end

	-- thieves
	if self.coinThief then
		love.graphics.drawq(imgSprites, coinThiefQuad, 0, HEIGHT - 32)
	end
	if ct.alive and self.thiefCooldown > 0 then
		love.graphics.drawq(imgSprites, coinKnightQuad, 0, HEIGHT - 32)
	end
	if self.meatThief then
		love.graphics.drawq(imgSprites, meatThiefQuad, WIDTH - 32, HEIGHT - 32)
	end
	if mt.alive and self.thiefCooldown > 0 then
		love.graphics.drawq(imgSprites, meatKnightQuad, WIDTH - 32, HEIGHT - 32)
	end

	-- score
	local scoreString = tostring(self.score)
	for offset = 1, #scoreString do
		love.graphics.drawq(imgSprites,numberQuads[scoreString:sub(offset,offset)],SPRITE_WIDTH * (offset - 1),0)
	end
end

-- reset peasant happiness
function GameManager:resetPeasants()
	self.peasantTime = -2 -- time for animation
	if self.coinThief then
		self.coinThief = false
	end
	happyFx:stop() happyFx:play()
end

-- reset noble happiness
function GameManager:resetNobles()
	self.nobleTime = -2 -- time for animation
	if self.meatThief then
		self.meatThief = false
	end
	happyFx:stop() happyFx:play()
end

-- add a coin to the treasure room
function GameManager:incrementCoin()
	self.coinCount = self.coinCount + 1
	pointFx:stop() pointFx:play()
end

-- add meat to storage
function GameManager:incrementMeat()
	self.meatCount = self.meatCount + 1
	pointFx:stop() pointFx:play()
end

-- dispatch a knight to treasure room
function GameManager:ejectCoinThief()
	self.coinThief = false
	ct = Droppable.create(3)
	ct:throwTo(5)
	self.thiefCooldown = THIEF_COOLDOWN
	ejectFx:stop() ejectFx:play()
end

-- dispatch a knight to meat storage
function GameManager:ejectMeatThief()
	self.meatThief = false
	mt = Droppable.create(4)
	mt:throwTo(6)
	self.thiefCooldown = THIEF_COOLDOWN
	ejectFx:stop() ejectFx:play()
end