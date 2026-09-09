local canvas
local mesh
local image
local batch
local particles
local frames = 0
local readbackPassed = false

local function solidImage(width, height, red, green, blue, alpha)
	local data = love.image.newImageData(width, height)
	data:mapPixel(function()
		return red, green, blue, alpha
	end)
	local result = love.graphics.newImage(data)
	result:setFilter("nearest")
	return result
end

local function near(actual, expected)
	return math.abs(actual - expected) < 0.04
end

function love.load()
	canvas = love.graphics.newCanvas(64, 64, {
		format = "rgba8",
		readable = true,
		msaa = 0,
	})
	canvas:setFilter("nearest")
	local canvasWidth, canvasHeight = canvas:getDimensions()
	assert(canvasWidth == 64 and canvasHeight == 64)
	assert(canvas:isReadable() and canvas:getFormat() == "rgba8")

	mesh = love.graphics.newMesh({
		{96, 16, 0, 0, 1, 0, 0, 1},
		{160, 16, 1, 0, 1, 0, 0, 1},
		{160, 80, 1, 1, 1, 0, 0, 1},
		{96, 80, 0, 1, 1, 0, 0, 1},
	}, "fan", "static")
	assert(mesh:getVertexCount() == 4 and mesh:getDrawMode() == "fan")

	image = solidImage(16, 16, 1, 0.82, 0.05, 1)
	batch = love.graphics.newSpriteBatch(image, 4, "dynamic")
	assert(batch:add(176, 16) == 1)
	assert(batch:add(208, 32, 0, 1.5, 1.5) == 2)
	assert(batch:getCount() == 2 and batch:getBufferSize() == 4)

	local particleImage = solidImage(12, 12, 0.05, 0.9, 1, 1)
	particles = love.graphics.newParticleSystem(particleImage, 4)
	particles:setParticleLifetime(10)
	particles:setEmitterLifetime(10)
	particles:setPosition(274, 48)
	particles:setSpeed(0)
	particles:setSizes(1)
	particles:emit(1)
	particles:update(0.01)
	particles:pause()
	assert(particles:getCount() == 1 and particles:isPaused())
	print("LOVE_WEB_GRAPHICS_OBJECTS_PASS", mesh:getVertexCount(), batch:getCount(), particles:getCount())
end

function love.update()
	frames = frames + 1
	if frames == 4 then
		local pixels = canvas:newImageData()
		local red, green, blue, alpha = pixels:getPixel(8, 8)
		assert(near(red, 0.05) and near(green, 0.2) and near(blue, 0.9) and near(alpha, 1),
			"Canvas blue readback mismatch")
		red, green, blue, alpha = pixels:getPixel(32, 32)
		assert(near(red, 0.1) and near(green, 0.95) and near(blue, 0.25) and near(alpha, 1),
			"Canvas green readback mismatch")
		readbackPassed = true
		print("LOVE_WEB_GRAPHICS_READBACK_PASS", pixels:getDimensions())
	end
	if frames > 240 and not readbackPassed then
		error("Love Web graphics Canvas readback timed out")
	end
end

function love.draw()
	love.graphics.clear(0.015, 0.02, 0.035, 1)

	love.graphics.setCanvas(canvas)
	love.graphics.clear(0.05, 0.2, 0.9, 1)
	love.graphics.setColor(0.1, 0.95, 0.25, 1)
	love.graphics.rectangle("fill", 16, 16, 32, 32)
	love.graphics.setCanvas()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(canvas, 16, 16)
	love.graphics.draw(mesh)
	love.graphics.draw(batch)
	love.graphics.draw(particles)

	if readbackPassed and frames == 5 then
		print("LOVE_WEB_GRAPHICS_READY")
	end
end
