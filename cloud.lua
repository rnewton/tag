-- init class
Cloud = {}
Cloud.__index = Cloud

-- constants
MAX_CLOUDS = 12

-- base y coordinate for cloud quads
local spriteY = 5 * (SPRITE_HEIGHT + SPRITE_SPACER) + 1

-- creates a new cloud at the given y coor, size and type
function Cloud.create(y,size,type)
	local self = {}
	setmetatable(self,Cloud)
	self.x = WIDTH
	self.y = y
	self.size = size
	self.type = type
	self.alive = true
	return self
end

-- moves the cloud to the left
function Cloud:update(dt)
	self.x = self.x - globalSpeed/4 * dt
end

-- draws the cloud
function Cloud:draw()
	local quad = nil
	if self.size == 1 then
		quad = love.graphics.newQuad((self.type*SPRITE_WIDTH)+SPRITE_SPACER, spriteY, SPRITE_WIDTH, SPRITE_WIDTH, 512,512)
	elseif self.size == 2 then
		quad = love.graphics.newQuad((4*(SPRITE_WIDTH+SPRITE_SPACER)+SPRITE_SPACER)+(self.type*SPRITE_WIDTH), spriteY, 2*SPRITE_WIDTH, SPRITE_HEIGHT, 512,512)
	end
	if quad ~= nil then
		love.graphics.drawq(imgSprites,quad,self.x,self.y)
	end
end

-- creates a new cloud after a random amount of time
function spawnClouds(dt)
	cloudTimer = cloudTimer - dt
	if cloudTimer <= 0 then
		if #clouds < MAX_CLOUDS then
			if math.random(2) == 1 then -- small cloud
				table.insert(clouds,Cloud.create(math.random(320),1,math.random(0,2)))
			else -- large cloud
				table.insert(clouds,Cloud.create(math.random(320),2,1))
			end
		end
		cloudTimer = math.random()
	end
end
