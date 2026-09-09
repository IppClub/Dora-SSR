local canvas
local baseImage
local maskImage
local glsl3Shader
local glsl1Shader
local combinedShader
local frames = 0
local readbackPassed = false
local failureChecks = 0

local translationFailure = [[
#pragma language glsl3
	vec4 effect(vec4 color) {
		return color;
	}
]]

local compileFailure = [[
#pragma language glsl3
	vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen) {
		return missingWebGLFunction(color);
	}
]]

local linkFailureVertex = [[
#pragma language glsl3
	extern vec2 LinkValues[2];
	vec4 position(mat4 transform, vec4 vertex) {
		return transform * vertex + vec4(LinkValues[0], 0.0, 0.0);
	}
]]

local linkFailurePixel = [[
#pragma language glsl3
	extern vec2 LinkValues[3];
	vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen) {
		return Texel(texture, uv) * color + vec4(LinkValues[0], 0.0, 0.0);
	}
]]

local function expectNewShaderFailure(label, marker, ...)
	local ok, value = pcall(love.graphics.newShader, ...)
	assert(not ok, label .. " unexpectedly created a Shader")
	local message = tostring(value)
	assert(message:find(marker, 1, true), label .. " missing marker " .. marker .. ": " .. message)
	failureChecks = failureChecks + 1
	print("LOVE_WEB_SHADER_FAILURE_PASS", label, marker)
	local diagnostic = message:gsub("\n", " | ")
	print("LOVE_WEB_SHADER_FAILURE_DIAGNOSTIC", label, diagnostic)
end

local function expectValidationFailure(label, marker, ...)
	local valid, message = love.graphics.validateShader(true, ...)
	assert(not valid, label .. " unexpectedly validated")
	message = tostring(message)
	assert(message:find(marker, 1, true), label .. " missing marker " .. marker .. ": " .. message)
	failureChecks = failureChecks + 1
	print("LOVE_WEB_SHADER_VALIDATION_FAILURE_PASS", label, marker)
	local diagnostic = message:gsub("\n", " | ")
	print("LOVE_WEB_SHADER_FAILURE_DIAGNOSTIC", label, diagnostic)
end

local function imageFromPixels(width, height, pixel)
	local data = love.image.newImageData(width, height)
	data:mapPixel(pixel)
	local image = love.graphics.newImage(data)
	image:setFilter("nearest")
	return image
end

local function near(actual, expected)
	return math.abs(actual - expected) < 0.04
end

local function assertColor(image, x, y, expected, label)
	local red, green, blue, alpha = image:getPixel(x, y)
	assert(near(red, expected[1]) and near(green, expected[2])
		and near(blue, expected[3]) and near(alpha, 1),
		label .. ": " .. red .. "," .. green .. "," .. blue .. "," .. alpha)
end

function love.load()
	expectNewShaderFailure("translation", "[love-shader/translation]", translationFailure)
	expectNewShaderFailure("compile", "[love-shader/driver/pixel]", compileFailure)
	expectNewShaderFailure("link", "[love-shader/driver/link]", linkFailureVertex, linkFailurePixel)
	expectValidationFailure("validate", "[love-shader/driver/pixel]", compileFailure)
	assert(failureChecks == 4)
	print("LOVE_WEB_SHADER_FAILURE_POLICY_PASS", failureChecks)

	canvas = love.graphics.newCanvas(192, 64, {format = "rgba8", readable = true, msaa = 0})
	canvas:setFilter("nearest")
	baseImage = imageFromPixels(16, 16, function()
		return 1, 1, 1, 1
	end)
	maskImage = imageFromPixels(16, 16, function(x)
		if x < 8 then return 1, 0.5, 0.25, 1 end
		return 0.25, 1, 0.5, 1
	end)

	print("LOVE_WEB_SHADER_GLSL3_BEGIN")
	glsl3Shader = love.graphics.newShader([[
#pragma language glsl3
		extern highp vec2 DrawOffset;
		out mediump vec2 ProbeUV;
		out highp vec4 ProbeTint;
		vec4 position(mat4 transform, vec4 vertex) {
			ProbeUV = VertexTexCoord.xy;
			ProbeTint = vec4(0.5, 1.0, 1.0, 1.0);
			vertex.xy += DrawOffset;
			return transform * vertex;
		}
	]], [[
#pragma language glsl3
		extern highp vec4 Tint;
		extern mediump Image Mask;
		in mediump vec2 ProbeUV;
		in highp vec4 ProbeTint;
		vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen) {
			highp vec4 source = Texel(texture, ProbeUV);
			mediump vec4 mask = Texel(Mask, ProbeUV);
			highp vec3 coordinateFactor = mix(vec3(1.0), vec3(1.0, 0.5, 1.0), step(48.0, screen.x));
			return source * mask * ProbeTint * Tint * vec4(coordinateFactor, 1.0) * color;
		}
	]])
	glsl3Shader:send("DrawOffset", {16, 16})
	glsl3Shader:send("Tint", {0.8, 0.5, 1, 1})
	glsl3Shader:send("Mask", maskImage)
	assert(glsl3Shader:hasUniform("DrawOffset") and glsl3Shader:hasUniform("Tint")
		and glsl3Shader:hasUniform("Mask"))
	print("LOVE_WEB_SHADER_GLSL3_END")

	print("LOVE_WEB_SHADER_GLSL1_BEGIN")
	glsl1Shader = love.graphics.newShader([[
#pragma language glsl1
		#define LOVE_TEST_PRECISION highp
		extern LOVE_TEST_PRECISION number LegacyGain;
		extern mediump Image LegacyMask;
	vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen) {
		return Texel(texture, uv) * Texel(LegacyMask, uv)
			* vec4(LegacyGain, 1.0, 1.0, 1.0) * color;
	}
	]])
	glsl1Shader:send("LegacyGain", 0.5)
	glsl1Shader:send("LegacyMask", maskImage)
	assert(glsl1Shader:hasUniform("LegacyGain") and glsl1Shader:hasUniform("LegacyMask"))
	print("LOVE_WEB_SHADER_GLSL1_END")

	combinedShader = love.graphics.newShader([[
#pragma language glsl3
		vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen) {
			return Texel(texture, uv) * color;
		}
		vec4 position(mat4 transform, vec4 vertex) {
			return transform * vertex;
		}
	]])
	assert(combinedShader)
	print("LOVE_WEB_SHADER_COMBINED_STAGE_PASS")
	print("LOVE_WEB_SHADER_OBJECTS_PASS")
end

function love.update()
	frames = frames + 1
	if frames == 4 then
		local pixels = canvas:newImageData()
		assertColor(pixels, 24, 24, {0.4, 0.25, 0.25}, "GLSL3 left")
		assertColor(pixels, 64, 24, {0.1, 0.25, 0.5}, "GLSL3 right and screen coordinate")
		assertColor(pixels, 120, 24, {0.5, 0.5, 0.25}, "GLSL1 left")
		assertColor(pixels, 160, 24, {0.125, 1, 0.5}, "GLSL1 right")
		readbackPassed = true
		print("LOVE_WEB_SHADER_READBACK_PASS", pixels:getDimensions())
	end
	if frames > 240 and not readbackPassed then
		error("Love Web shader Canvas readback timed out")
	end
end

function love.draw()
	love.graphics.clear(0.015, 0.02, 0.035, 1)
	love.graphics.setCanvas(canvas)
	love.graphics.clear(0.01, 0.01, 0.015, 1)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setShader(glsl3Shader)
	love.graphics.draw(baseImage, 0, 0, 0, 4, 2)
	love.graphics.setShader(glsl1Shader)
	love.graphics.draw(baseImage, 112, 16, 0, 4, 2)
	love.graphics.setShader()
	love.graphics.setCanvas()
	love.graphics.draw(canvas, 16, 16)
	if readbackPassed and frames == 5 then
		print("LOVE_WEB_SHADER_READY")
	end
end
