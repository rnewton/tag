worldQuad = love.graphics.newQuad(0,0,480,640,480,640)

-- draws the background and clouds
function drawWorld()
	-- Draw clouds
	for i,cl in ipairs(clouds) do
		cl:draw()
	end

	love.graphics.drawq(imgWorld,worldQuad,0,0)
end
