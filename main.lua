-- Global sizes for sprites
WIDTH = 480
HEIGHT = 640
SPRITE_WIDTH = 32
SPRITE_HEIGHT = 32
SPRITE_SPACER = 2

-- includes
require("table-save")
require("gamemanager")
require("player")
require("droppable")
require("cloud")
require("world")
require("menu")

-- base bgcolor
bgcolor = {135,206,235,255} -- sky blue

-- difficulty settings
START_SPEED = 250
SPEED_INCREASE = 0.3
MAX_SPEED = 350

highscore = {0,0,0}
difficulty = 1
difficultySettings = {{250,0.3,350},{350,0.4,375},{400,0.6,600}}

-- state settings
pause = false
mute = false
gameState = 1
selection = 0
submenu = 0
use_music = true

-- Init settings
function love.load()
	math.randomseed(os.time())
	love.graphics.setBackgroundColor(bgcolor)

	loadHighscore()
	loadResources()

	pl = Player.create()
	gm = GameManager.create()
	restart()
end

-- Reset variables
function restart()
	pl:reset()
	gm:reset()

	clouds = {}
	cloudTimer = 0

	START_SPEED = difficultySettings[difficulty][1]
	SPEED_INCREASE = difficultySettings[difficulty][2]
	MAX_SPEED = difficultySettings[difficulty][3]
	globalSpeed = START_SPEED

	droppable = Droppable.create()
	droppable.alive = false
	ct = Droppable.create(3)
	ct.alive = false
	mt = Droppable.create(4)
	mt.alive = false

	score = 0
end

-- update game state
function love.update(dt)
	if gameState == 0 then
		updateGame(dt)
	end
end

-- updates player actions, droppables and game manager
function updateGame(dt)
	-- don't update anything if paused, gameover or win
	if pause == true or pl.status == 3 or gm.win then
		return
	end

	-- Update player
	pl:update(dt)
	gm:update(dt)

	-- Update droppables
	droppable:update(dt)
	ct:update(dt)
	mt:update(dt)

	-- Update clouds
	spawnClouds(dt)
	for i,cl in ipairs(clouds) do
		cl:update(dt)
		if cl.x < -32 then
			table.remove(clouds,i)
		end
	end

	-- Increase speed
	if droppable.alive == true then
		globalSpeed = globalSpeed + SPEED_INCREASE * dt
		if globalSpeed > MAX_SPEED then 
			globalSpeed = MAX_SPEED
		end
	else -- Respawn droppable or thief
		droppable = Droppable.createRandom()
	end
end

-- draw game/menu
function love.draw()
	if gameState == 0 then
		drawGame()
	elseif gameState == 1 then
		drawMenu()
	end
end

-- Draw the game state
function drawGame()
	-- Draw world
	drawWorld()

	-- Draw droppable
	droppable:draw()
	ct:draw()
	mt:draw()

	-- Draw player
	love.graphics.setColor(255,255,255,255)
	pl:draw()

	-- handles drawing for score, feedback and thieves
	gm:draw()

	-- Draw win message
	if gm.win then
		love.graphics.printf("You are the greatest ruler this land has ever known! Congrats!",0,250,WIDTH,"center")
		love.graphics.printf("Score: ".. gm.score .. "\n High Score: " .. highscore[difficulty],0,300,WIDTH,"center")
		love.graphics.printf("Press 'r' to restart.",0,330,WIDTH,"center")
	end

	-- Draw game over message
	if pl.status == 3 then
		love.graphics.printf(pl.shameMessage,0,250,WIDTH,"center")
		love.graphics.printf("Score: ".. gm.score .. "\n High Score: " .. highscore[difficulty],0,300,WIDTH,"center")
		love.graphics.printf("Press 'r' to restart.",0,330,WIDTH,"center")
	end

	-- Draw pause message
	if pause == true then
		love.graphics.printf("paused\npress p to continue",0,50,WIDTH,"center")
	end
end

-- keymapping
function love.keypressed(key,unicode)
	if key == 'r' then -- reset game
		restart()
	elseif key == 'up' then -- change selection in menu
		selection = selection-1
	elseif key == 'down' then -- change seletion in menu
		selection = selection+1
	elseif key == 'return' then -- select
		if gameState == 1 then
			if submenu == 0 then -- splash screen
				submenu = 1 -- Jumps straight to difficulty.
				selectFx:stop() selectFx:play()
			elseif submenu == 1 then  -- difficulty selection
				difficulty = selection+1
				selectFx:stop() selectFx:play()
				gameState = 0
				restart()
			end
		end
	elseif key == 'escape' then -- quit
		if gameState == 0 then -- ingame, go to menu
			gameState = 1
			submenu = 1
			selection = 0
		elseif gameState == 1 then -- menu, quit entirely
			if submenu == 0 then
				love.event.push("q")
			elseif submenu == 1 then
				submenu = 0
			end
		end
		selectFx:stop() selectFx:play()
	elseif key == 'p' then -- pause
		if gameState == 0 then
			pause = not pause
		end
	elseif key == 'm' then -- mute/unmute
		if mute == false then
			mute = true
			love.audio.setVolume(0.0)
		else
			mute = false
			love.audio.setVolume(1.0)
		end
	end
end

-- load images/sounds
function loadResources()
	-- Load images
	imgSprites = love.graphics.newImage("assets/img/tiles.png")
	imgSprites:setFilter("nearest","nearest")

	imgWorld = love.graphics.newImage("assets/img/world.png")
	imgWorld:setFilter("nearest","nearest")

	imgSplash = love.graphics.newImage("assets/img/splash.png")
	imgSplash:setFilter("nearest","nearest")

	-- Load sound effects
	angryFx = love.audio.newSource("assets/sfx/angry.wav","static")
	happyFx = love.audio.newSource("assets/sfx/happy.wav","static")
	pointFx = love.audio.newSource("assets/sfx/point.wav","static")
	ejectFx = love.audio.newSource("assets/sfx/eject.wav","static")
	selectFx = love.audio.newSource("assets/sfx/select.wav","static")
	if use_music == true then
		music = love.audio.newSource("assets/sfx/hidden_and_rich.ogg","stream")
		music:setLooping(true)
		music:setVolume(0.6)
		music:play()
	end
end

-- load the highscore into highscore table
function loadHighscore()
	if love.filesystem.exists("highscore") then
		local data = love.filesystem.read("highscore")
		if data ~=nil then
			local datatable = table.load(data)
			if (not datatable) then 
				print("broken hiscore data=",data)
			else 
				if #datatable == #highscore then
					highscore = datatable
				end
			end
		end
	end
end

-- save highscoretable to filesystem
function saveHighscore()
	local datatable = table.save(highscore)
	love.filesystem.write("highscore",datatable)
end

-- save highscore on quit
function love.quit()
	saveHighscore()
end

-- pause on losing focus
function love.focus(f)
	if not f and gameState == 0 then
		pause = true
	end
end


