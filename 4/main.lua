function love.load()

    love.graphics.setFont(love.graphics.newFont(11))

	love.physics.setMeter( 32 )

	world = love.physics.newWorld(0, 9.81*32, true)

	ground = love.physics.newBody(world, 0, 0, "static")

	ground_shape = love.physics.newRectangleShape( 400, 500, 600, 10)

	ground_fixture = love.physics.newFixture( ground, ground_shape)

	ball = love.graphics.newImage("assets/love-ball.png")

	body = love.physics.newBody(world, 400, 200, "dynamic")

	circle_shape = love.physics.newCircleShape( 0,0,32)

    fixture = love.physics.newFixture( body, circle_shape)
	body:setMassData(circle_shape:computeMass( 1 ))

end

function love.update(dt)
	-- Update the world.
	world:update(dt)
end

function love.draw()
	love.graphics.polygon("line", ground:getWorldPoints(ground_shape:getPoints()))

	love.graphics.draw(ball,body:getX(), body:getY(), body:getAngle(),1,1,32,32)

	love.graphics.print("space: Apply a random impulse",5,5)
end

function love.keypressed(k)
	if k == "space" then
		-- Apply a random impulse
		body:applyLinearImpulse(150-math.random(0, 300),-math.random(0, 1500))
	end
end
