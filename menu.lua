-- easy, medium, hard
menuDifficulties = {"naught","fraught","distraught"}

-- splash screen
splashQuad = love.graphics.newQuad(0, 0, 480,640, 480,640)

-- draws the menu and difficulty selector
function drawMenu()
	drawWorld()

	if submenu == 0 then -- splash screen
		love.graphics.drawq(imgSplash,splashQuad,0,0)
		love.graphics.printf("<- controls ->",0,HEIGHT-32,WIDTH,"center")
	elseif submenu == 1 then -- difficulty selector
		love.graphics.printf("Select Difficulty",0,250,WIDTH,"center")
		if selection > 2 then selection = 0
		elseif selection < 0 then selection = 2 end

		for i = 0,2 do
			if i == selection then
				love.graphics.printf("·"..menuDifficulties[i+1].."·",0,300+i*13,WIDTH,"center")
			else
				love.graphics.printf(menuDifficulties[i+1],0,300+i*13,WIDTH,"center")
			end
		end
	end
end