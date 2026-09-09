/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#include "Love/LoveRuntime.h"

#include <emscripten/emscripten.h>

#include <fstream>
#include <iterator>
#include <memory>
#include <string>

namespace
{
std::string lastError;
std::unique_ptr<Dora::Love::LoveRuntime> incrementalRuntime;
int incrementalSteps = 0;

bool runIncrementalFailureAndCloseChecks()
{
	using StartResult = Dora::Love::LoveRuntime::StartResult;
	{
		Dora::Love::LoveRuntime runtime;
		if (!runtime.open(lastError)
			|| !runtime.execute(R"lua(
function love.conf(config)
	config.window = false
	config.modules.audio = false
	config.modules.video = false
	config.modules.thread = false
	config.modules.physics = false
end
function love.load()
	for index = 1, 100000 do local value = index * index end
	error("incremental failure marker")
end
)lua", "@love-incremental-failure.lua", lastError)
			|| !runtime.configure(lastError)
			|| !runtime.beginStart(lastError))
			return false;
		StartResult result = StartResult::Pending;
		while (result == StartResult::Pending)
			result = runtime.resumeStart(10000, lastError);
		if (result != StartResult::Failed
			|| lastError.find("incremental failure marker") == std::string::npos)
		{
			lastError = "incremental love.load failure did not preserve its traceback";
			return false;
		}
		runtime.close();
	}
	{
		Dora::Love::LoveRuntime runtime;
		if (!runtime.open(lastError)
			|| !runtime.execute("function love.load() while true do end end",
				"@love-incremental-close.lua", lastError)
			|| !runtime.configure(lastError)
			|| !runtime.beginStart(lastError)
			|| runtime.resumeStart(10000, lastError) != StartResult::Pending)
			return false;
		runtime.close();
		if (runtime.getStatus() != Dora::Love::LoveRuntime::Status::Closed)
		{
			lastError = "closing a pending incremental love.load did not close the runtime";
			return false;
		}
	}
	return true;
}
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_link_probe()
{
	Dora::Love::LoveRuntime runtime;
	lastError.clear();
	std::ifstream fontFile("/love-fixture.ttf", std::ios::binary);
	if (!fontFile)
	{
		lastError = "preloaded Love font fixture is missing";
		return 0;
	}
	runtime.setDefaultFontData(std::string(
		std::istreambuf_iterator<char>(fontFile), std::istreambuf_iterator<char>()));
	if (!runtime.open(lastError)) return 0;
	if (!runtime.execute(R"lua(
local fixture = {load = 0, update = 0, draw = 0, key = 0, mouse = 0, touch = 0}

function love.conf(config)
	config.window = false
	config.modules.audio = false
	config.modules.video = false
	config.modules.thread = false
	config.modules.physics = false
end

function love.load()
	fixture.load = fixture.load + 1
	local image = love.image.newImageData(2, 2)
	image:setPixel(1, 1, 0.25, 0.5, 0.75, 1.0)
	local red, green, blue, alpha = image:getPixel(1, 1)
	assert(math.abs(red - 0.25) < 0.01 and math.abs(green - 0.5) < 0.01)
	assert(math.abs(blue - 0.75) < 0.01 and alpha == 1.0)
	local rasterizer = love.font.newRasterizer(12)
	assert(rasterizer:getGlyphCount() > 0)
end

function love.keypressed(key, scancode, repeated)
	assert(key == "space" and scancode == "space" and repeated == false)
	fixture.key = fixture.key + 1
end

function love.mousepressed(x, y, button, isTouch, presses)
	assert(x == 12 and y == 34 and button == 1 and isTouch == false and presses == 1)
	fixture.mouse = fixture.mouse + 1
end

function love.touchpressed(id, x, y, dx, dy, pressure)
	assert(id ~= nil and x == 0.25 and y == 0.75 and dx == 0 and dy == 0 and pressure == 1)
	fixture.touch = fixture.touch + 1
end

function love.update(delta)
	assert(delta == 0.016)
	fixture.update = fixture.update + 1
end

function love.draw()
	fixture.draw = fixture.draw + 1
end

local value = love.math.newRandomGenerator(0x1234):random(1, 100)
assert(type(value) == "number" and value >= 1 and value <= 100)
assert(love.data.hash("sha256", "dora-web-love") ~= nil)
	_G.doraWebLoveFixture = fixture
)lua", "@love-link-probe.lua", lastError))
	{
		runtime.close();
		return 0;
	}
	if (!runtime.configure(lastError) || !runtime.start(lastError))
	{
		runtime.close();
		return 0;
	}
	runtime.queueKeyPressed("space", "space");
	runtime.queueMousePressed(12.0f, 34.0f, 1);
	runtime.queueTouchPressed(7, 0.25f, 0.75f, 0.0f, 0.0f, 1.0f);
	if (!runtime.update(0.016, lastError) || !runtime.draw(lastError)
		|| !runtime.execute(R"lua(
local fixture = assert(doraWebLoveFixture)
assert(fixture.load == 1 and fixture.update == 1 and fixture.draw == 1)
assert(fixture.key == 1 and fixture.mouse == 1 and fixture.touch == 1)
)lua", "@love-link-probe-verify.lua", lastError)
		|| !runtime.stop(lastError))
	{
		runtime.close();
		return 0;
	}
	runtime.close();
	return runIncrementalFailureAndCloseChecks() ? 1 : 0;
}

extern "C" EMSCRIPTEN_KEEPALIVE const char *dora_web_love_link_probe_error()
{
	return lastError.c_str();
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_incremental_probe_begin()
{
	incrementalRuntime = std::make_unique<Dora::Love::LoveRuntime>();
	incrementalSteps = 0;
	lastError.clear();
	if (!incrementalRuntime->open(lastError)
		|| !incrementalRuntime->execute(R"lua(
function love.conf(config)
	config.window = false
	config.modules.audio = false
	config.modules.video = false
	config.modules.thread = false
	config.modules.physics = false
end

function love.load()
	local checksum = 0
	for index = 1, 750000 do
		checksum = (checksum + index) % 1000003
	end
	love.bootYield()
	_G.doraWebLoveExplicitYieldResumed = true
	for index = 1, 750000 do
		checksum = (checksum + index * 3) % 1000003
	end
	_G.doraWebLoveLoadChecksum = checksum
end
)lua", "@love-incremental-probe.lua", lastError)
		|| !incrementalRuntime->configure(lastError)
		|| !incrementalRuntime->beginStart(lastError))
	{
		incrementalRuntime->close();
		incrementalRuntime.reset();
		return 0;
	}
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_incremental_probe_step()
{
	if (!incrementalRuntime)
	{
		lastError = "incremental Love runtime probe was not started";
		return -1;
	}
	++incrementalSteps;
	const auto result = incrementalRuntime->resumeStart(20000, lastError);
	if (result == Dora::Love::LoveRuntime::StartResult::Pending)
		return 0;
	if (result == Dora::Love::LoveRuntime::StartResult::Failed)
	{
		incrementalRuntime->close();
		incrementalRuntime.reset();
		return -1;
	}
	if (!incrementalRuntime->execute(R"lua(
assert(doraWebLoveExplicitYieldResumed == true)
assert(type(doraWebLoveLoadChecksum) == "number")
)lua", "@love-incremental-probe-verify.lua", lastError)
		|| !incrementalRuntime->stop(lastError))
	{
		incrementalRuntime->close();
		incrementalRuntime.reset();
		return -1;
	}
	incrementalRuntime->close();
	incrementalRuntime.reset();
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_incremental_probe_steps()
{
	return incrementalSteps;
}
