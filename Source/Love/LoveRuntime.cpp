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
#include "Love/LoveGraphicsAdapter.h"
#include "Love/LoveTextLayout.h"
#include "Common/Debug.h"
#include "Lua/BuiltinModules.h"
#include "3rdParty/Love/src/libraries/lz4/lz4.h"
#include "3rdParty/Love/src/libraries/lz4/lz4hc.h"
#include "3rdParty/Love/src/common/Object.h"
#include "3rdParty/Love/src/common/Reference.h"
#include "3rdParty/Love/src/common/runtime.h"
#include "3rdParty/Love/src/modules/data/ByteData.h"
#include "3rdParty/Love/src/modules/data/HashFunction.h"
#include "3rdParty/Love/src/modules/data/wrap_DataModule.h"
#include "3rdParty/Love/src/modules/audio/wrap_Source.h"
#include "3rdParty/Love/src/common/floattypes.h"
#include "3rdParty/Love/src/modules/filesystem/File.h"
#include "3rdParty/Love/src/modules/filesystem/FileData.h"
#include "3rdParty/Love/src/modules/filesystem/Filesystem.h"
#include "3rdParty/Love/src/modules/filesystem/wrap_File.h"
#include "3rdParty/Love/src/modules/filesystem/wrap_FileData.h"
#include "3rdParty/Love/src/modules/filesystem/wrap_Filesystem.h"
#include "3rdParty/Love/src/modules/event/Event.h"
#include "3rdParty/Love/src/modules/event/wrap_Event.h"
#include "3rdParty/Love/src/modules/font/GlyphData.h"
#include "3rdParty/Love/src/modules/font/Font.h"
#include "3rdParty/Love/src/modules/font/Rasterizer.h"
#include "3rdParty/Love/src/modules/font/TrueTypeRasterizer.h"
#include "3rdParty/Love/src/modules/font/wrap_Font.h"
#include "3rdParty/Love/src/modules/font/wrap_GlyphData.h"
#include "3rdParty/Love/src/modules/font/wrap_Rasterizer.h"
#include "3rdParty/Love/src/modules/graphics/Canvas.h"
#include "3rdParty/Love/src/modules/graphics/Drawable.h"
#include "3rdParty/Love/src/modules/graphics/Font.h"
#include "3rdParty/Love/src/modules/graphics/Image.h"
#include "3rdParty/Love/src/modules/graphics/Quad.h"
#include "3rdParty/Love/src/modules/graphics/Text.h"
#include "3rdParty/Love/src/modules/graphics/Video.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Image.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Font.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Mesh.h"
#include "3rdParty/Love/src/modules/graphics/wrap_ParticleSystem.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Quad.h"
#include "3rdParty/Love/src/modules/graphics/wrap_SpriteBatch.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Text.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Video.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsTransform.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsQuad.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsCanvasConstructor.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsScreenshot.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Texture.h"
#include "3rdParty/Love/src/modules/image/ImageData.h"
#include "3rdParty/Love/src/modules/image/CompressedImageData.h"
#include "3rdParty/Love/src/modules/image/Image.h"
#include "3rdParty/Love/src/modules/image/wrap_CompressedImageData.h"
#include "3rdParty/Love/src/modules/image/wrap_Image.h"
#include "3rdParty/Love/src/modules/image/wrap_ImageData.h"
#include "3rdParty/Love/src/modules/math/wrap_BezierCurve.h"
#include "3rdParty/Love/src/modules/math/wrap_Math.h"
#include "3rdParty/Love/src/modules/math/wrap_RandomGenerator.h"
#include "3rdParty/Love/src/modules/math/wrap_Transform.h"
#include "3rdParty/Love/src/modules/sound/SoundData.h"
#include "3rdParty/Love/src/modules/sound/Sound.h"
#include "3rdParty/Love/src/modules/sound/wrap_Decoder.h"
#include "3rdParty/Love/src/modules/sound/wrap_Sound.h"
#include "3rdParty/Love/src/modules/sound/wrap_SoundData.h"
#include "3rdParty/Love/src/modules/system/System.h"
#include "3rdParty/Love/src/modules/system/wrap_System.h"
#include "3rdParty/Love/src/modules/timer/Timer.h"
#include "3rdParty/Love/src/modules/timer/wrap_Timer.h"
#include "3rdParty/Love/src/modules/window/Window.h"
#include "3rdParty/Love/src/modules/window/wrap_Window.h"
#include "3rdParty/Love/src/modules/thread/Channel.h"
#include "3rdParty/Love/src/modules/thread/LuaThread.h"
#include "3rdParty/Love/src/modules/thread/ThreadModule.h"
#include "3rdParty/Love/src/modules/thread/wrap_Channel.h"
#include "3rdParty/Love/src/modules/thread/wrap_LuaThread.h"
#include "3rdParty/Love/src/modules/thread/wrap_ThreadModule.h"
#include "3rdParty/Love/src/modules/video/theora/TheoraVideoStream.h"
#include "3rdParty/Love/src/modules/video/wrap_VideoStream.h"
#include "3rdParty/Zip/zlib/zlib.h"
#include "3rdParty/stb/stb_truetype.h"

#include <algorithm>
#include <array>
#include <atomic>
#include <bit>
#include <charconv>
#include <cctype>
#include <chrono>
#include <condition_variable>
#include <cmath>
#include <cstring>
#include <cstdlib>
#include <filesystem>
#include <iomanip>
#include <iterator>
#include <limits>
#include <memory>
#include <mutex>
#include <new>
#include <numbers>
#include <set>
#include <sstream>
#include <thread>
#include <tuple>
#include <type_traits>
#include <utility>

// ImageData uses the same half/packed-float conversions as Love 11.5. Keep the
// implementation in this backend-independent runtime translation unit so all
// Dora targets and the standalone compatibility tests share identical bits.
#include "3rdParty/Love/src/common/floattypes.cpp"

#include "3rdParty/Love/src/modules/keyboard/wrap_Keyboard.h"
#include "3rdParty/Love/src/modules/mouse/wrap_Mouse.h"
#include "3rdParty/Love/src/modules/mouse/wrap_Cursor.h"
#include "3rdParty/Love/src/modules/touch/wrap_Touch.h"
#include "3rdParty/Love/src/modules/joystick/wrap_Joystick.h"
#include "3rdParty/Love/src/modules/joystick/wrap_JoystickModule.h"
#include "3rdParty/Love/src/modules/physics/Body.h"
#include "3rdParty/Love/src/modules/physics/Contact.h"
#include "3rdParty/Love/src/modules/physics/Fixture.h"
#include "3rdParty/Love/src/modules/physics/Shape.h"
#include "3rdParty/Love/src/modules/physics/Joint.h"
#include "3rdParty/Love/src/modules/physics/World.h"
#include "3rdParty/Love/src/modules/physics/wrap_Body.h"
#include "3rdParty/Love/src/modules/physics/wrap_Contact.h"
#include "3rdParty/Love/src/modules/physics/wrap_Fixture.h"
#include "3rdParty/Love/src/modules/physics/wrap_Joint.h"
#include "3rdParty/Love/src/modules/physics/wrap_Shape.h"
#include "3rdParty/Love/src/modules/physics/wrap_World.h"

extern "C"
{
#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"
}

namespace Dora::Love
{

#include "LoveRuntimeAdapters.inc"

int LoveRuntime::traceback(lua_State *state)
{
	const char *message = lua_tostring(state, 1);
	if (message == nullptr)
		message = "LoveRuntime error";
	luaL_traceback(state, state, message, 1);
	if (auto *runtime = runtimeFromUpvalue(state))
		runtime->rewriteGeneratedErrorOnStack(state);
	return 1;
}

std::string LoveRuntime::prepareGeneratedChunk(std::string_view code,
	std::string_view chunkName)
{
	const auto firstLineEnd = code.find_first_of("\r\n");
	const auto firstLine = code.substr(0, firstLineEnd);
	if (!firstLine.starts_with("-- ["))
		return std::string(chunkName);
	const auto languageEnd = firstLine.find("]: ", 4);
	if (languageEnd == std::string_view::npos)
		return std::string(chunkName);
	const auto language = firstLine.substr(4, languageEnd - 4);
	if (language != "ts" && language != "tsx" && language != "tl" && language != "yue")
		return std::string(chunkName);
	std::string source(firstLine.substr(languageEnd + 3));
	if (source.empty())
		return std::string(chunkName);
	if (source.front() == '@')
		source.erase(source.begin());

	GeneratedLineMap mapping;
	mapping.source = source;
	mapping.lines.push_back(0); // Lua source lines are one-based.
	int generatedLine = 0;
	int lastSourceLine = 1;
	std::size_t offset = 0;
	while (offset <= code.size())
	{
		const auto lineEnd = code.find('\n', offset);
		auto line = code.substr(offset,
			lineEnd == std::string_view::npos ? code.size() - offset : lineEnd - offset);
		if (!line.empty() && line.back() == '\r')
			line.remove_suffix(1);
		++generatedLine;
		if (generatedLine == 1)
		{
			mapping.lines.push_back(1);
		}
		else if (language == "tl")
		{
			mapping.lines.push_back(generatedLine - 1);
		}
		else
		{
			std::size_t valueEnd = line.size();
			while (valueEnd > 0 && std::isspace(static_cast<unsigned char>(line[valueEnd - 1])))
				--valueEnd;
			const auto marker = line.rfind("-- ", valueEnd);
			if (marker != std::string_view::npos && marker + 3 < valueEnd)
			{
				int sourceLine = 0;
				const auto *begin = line.data() + marker + 3;
				const auto *end = line.data() + valueEnd;
				const auto parsed = std::from_chars(begin, end, sourceLine);
				if (parsed.ec == std::errc{} && parsed.ptr == end && sourceLine > 0)
					lastSourceLine = sourceLine;
			}
			mapping.lines.push_back(lastSourceLine);
		}
		if (lineEnd == std::string_view::npos)
			break;
		offset = lineEnd + 1;
	}
	_generatedLineMaps[source] = std::move(mapping);
	return "@" + source;
}

std::string LoveRuntime::rewriteGeneratedError(std::string message) const
{
	for (const auto &[_, mapping] : _generatedLineMaps)
	{
		std::string displayedSource = mapping.source;
		constexpr std::size_t chunkTail = LUA_IDSIZE - 4;
		if (displayedSource.size() + 1 > LUA_IDSIZE)
			displayedSource = "..." + displayedSource.substr(displayedSource.size() - chunkTail);
		for (std::size_t generatedLine = 1;
			generatedLine < mapping.lines.size(); ++generatedLine)
		{
			const int sourceLine = mapping.lines[generatedLine];
			if (sourceLine <= 0)
				continue;
			const std::string token = displayedSource + ":"
				+ std::to_string(generatedLine) + ":";
			const std::string replacement = mapping.source + ":"
				+ std::to_string(sourceLine) + ":";
			if (token == replacement)
				continue;
			std::size_t position = 0;
			while ((position = message.find(token, position)) != std::string::npos)
			{
				message.replace(position, token.size(), replacement);
				position += replacement.size();
			}
		}
	}
	return message;
}

void LoveRuntime::rewriteGeneratedErrorOnStack(lua_State *state) const
{
	std::size_t size = 0;
	const char *message = lua_tolstring(state, -1, &size);
	if (!message)
		return;
	const std::string rewritten = rewriteGeneratedError(std::string(message, size));
	lua_pop(state, 1);
	lua_pushlstring(state, rewritten.data(), rewritten.size());
}

bool LoveRuntime::execute(std::string_view code, std::string_view chunkName, std::string &error)
{
	if (_state == nullptr)
	{
		error = "LoveRuntime is not open";
		return false;
	}

	const int base = lua_gettop(_state);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, traceback, 1);
	const int errorHandler = lua_gettop(_state);

	std::string chunk = prepareGeneratedChunk(code, chunkName);
	if (loadLoveChunk(_state, code, chunk.c_str()) != LUA_OK)
	{
		const char *loadError = lua_tostring(_state, -1);
		error = rewriteGeneratedError(loadError ? loadError : "LoveRuntime load error");
		lua_settop(_state, base);
		return false;
	}

	if (lua_pcall(_state, 0, 0, errorHandler) != LUA_OK)
	{
		error = lua_tostring(_state, -1);
		lua_settop(_state, base);
		return false;
	}

	lua_settop(_state, base);
	error.clear();
	return true;
}

bool LoveRuntime::fail(std::string message, std::string &error)
{
	_lastError = std::move(message);
	_status = Status::Faulted;
	error = _lastError;
	return false;
}

bool LoveRuntime::callLoveCallback(const char *name, int argumentCount, int resultCount, std::string &error)
{
	const int base = lua_gettop(_state) - argumentCount;
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, traceback, 1);
	lua_insert(_state, base + 1);
	const int errorHandler = base + 1;

	lua_getglobal(_state, "love");
	lua_getfield(_state, -1, name);
	lua_remove(_state, -2);
	if (lua_isnil(_state, -1))
	{
		lua_settop(_state, base);
		error.clear();
		return true;
	}
	if (!lua_isfunction(_state, -1))
	{
		lua_settop(_state, base);
		return fail(std::string("love.") + name + " must be a function", error);
	}

	if (argumentCount > 0)
		lua_insert(_state, base + 2);
	if (lua_pcall(_state, argumentCount, resultCount, errorHandler) != LUA_OK)
	{
		std::string message = lua_tostring(_state, -1);
		lua_settop(_state, base);
		return fail(std::move(message), error);
	}

	lua_remove(_state, errorHandler);
	error.clear();
	return true;
}

bool LoveRuntime::boot(std::string_view code, std::string_view chunkName, std::string &error)
{
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before boot";
		return false;
	}

	_bootCode.assign(code);
	_bootChunkName.assign(chunkName);
	if (!execute(_bootCode, _bootChunkName, error))
		return fail(error, error);
	return start(error);
}

bool LoveRuntime::configure(std::string &error)
{
	error.clear();
	_configurationWarnings.clear();
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before configure";
		return false;
	}

	lua_newtable(_state);
	lua_pushliteral(_state, "11.5");
	lua_setfield(_state, -2, "version");
	lua_pushliteral(_state, "Untitled");
	lua_setfield(_state, -2, "title");
	if (!_identity.empty())
	{
		lua_pushlstring(_state, _identity.data(), _identity.size());
		lua_setfield(_state, -2, "identity");
	}
	else
	{
		lua_pushboolean(_state, false);
		lua_setfield(_state, -2, "identity");
	}
	const auto setBooleanField = [this](const char *field, bool value) {
		lua_pushboolean(_state, value);
		lua_setfield(_state, -2, field);
	};
	setBooleanField("console", false);
	setBooleanField("appendidentity", false);
	setBooleanField("externalstorage", false);
	setBooleanField("accelerometerjoystick", true);
	setBooleanField("gammacorrect", false);
	lua_newtable(_state);
	setBooleanField("mixwithsystem", true);
	setBooleanField("mic", false);
	lua_setfield(_state, -2, "audio");
	lua_newtable(_state);
	static constexpr std::array<const char *, 18> ModuleNames = {
		"data", "event", "keyboard", "mouse", "timer", "joystick", "touch", "image",
		"graphics", "audio", "math", "physics", "sound", "system", "font", "thread",
		"window", "video"};
	for (const auto *module : ModuleNames)
		setBooleanField(module, true);
	lua_setfield(_state, -2, "modules");
	lua_newtable(_state);
	lua_pushinteger(_state, DefaultWindowWidth);
	lua_setfield(_state, -2, "width");
	lua_pushinteger(_state, DefaultWindowHeight);
	lua_setfield(_state, -2, "height");
	lua_pushinteger(_state, 1);
	lua_setfield(_state, -2, "minwidth");
	lua_pushinteger(_state, 1);
	lua_setfield(_state, -2, "minheight");
	setBooleanField("fullscreen", false);
	lua_pushliteral(_state, "desktop");
	lua_setfield(_state, -2, "fullscreentype");
	lua_pushinteger(_state, 1);
	lua_setfield(_state, -2, "display");
	setBooleanField("highdpi", false);
	setBooleanField("usedpiscale", true);
	setBooleanField("resizable", false);
	setBooleanField("borderless", false);
	setBooleanField("centered", true);
	lua_pushinteger(_state, 1);
	lua_setfield(_state, -2, "vsync");
	lua_pushinteger(_state, 0);
	lua_setfield(_state, -2, "msaa");
	lua_setfield(_state, -2, "window");
	lua_pushvalue(_state, -1);
	const int configuration = luaL_ref(_state, LUA_REGISTRYINDEX);
	if (!callLoveCallback("conf", 1, 0, error))
	{
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return false;
	}

	lua_rawgeti(_state, LUA_REGISTRYINDEX, configuration);
	lua_getfield(_state, -1, "window");
	const bool windowDisabled = lua_isnil(_state, -1)
		|| (lua_isboolean(_state, -1) && !lua_toboolean(_state, -1));
	if (!lua_istable(_state, -1) && !windowDisabled)
	{
		lua_pop(_state, 2);
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return fail("love.conf must leave t.window as a table", error);
	}
	if (windowDisabled)
	{
		lua_pop(_state, 1);
		lua_newtable(_state);
		lua_pushinteger(_state, DefaultWindowWidth); lua_setfield(_state, -2, "width");
		lua_pushinteger(_state, DefaultWindowHeight); lua_setfield(_state, -2, "height");
		lua_pushboolean(_state, false); lua_setfield(_state, -2, "fullscreen");
		lua_pushboolean(_state, false); lua_setfield(_state, -2, "highdpi");
		lua_pushboolean(_state, false); lua_setfield(_state, -2, "resizable");
		lua_pushinteger(_state, 1); lua_setfield(_state, -2, "display");
		lua_pushinteger(_state, 1); lua_setfield(_state, -2, "vsync");
		_configurationWarnings = "window module is disabled; LoveNode keeps its virtual surface available";
	}
	const auto appendConfigurationWarning = [this](std::string_view warning) {
		if (!_configurationWarnings.empty()) _configurationWarnings += "; ";
		_configurationWarnings += warning;
	};
	const auto readDimension = [&](const char *field, int &value) {
		lua_getfield(_state, -1, field);
		const bool isNumber = lua_isnumber(_state, -1);
		const lua_Number configuredNumber = lua_tonumber(_state, -1);
		lua_pop(_state, 1);
		if (!isNumber || !std::isfinite(configuredNumber)
			|| configuredNumber < 0 || configuredNumber > MaximumWindowDimension)
		{
			error = std::string("love.conf t.window.") + field
				+ " must be a number from 0 to " + std::to_string(MaximumWindowDimension);
			return false;
		}
		const int configuredValue = static_cast<int>(configuredNumber);
		if (configuredValue == 0)
		{
			value = _graphicsBackend
				? (std::string_view(field) == "width" ? _graphicsBackend->getPixelWidth()
					: _graphicsBackend->getPixelHeight())
				: (std::string_view(field) == "width" ? DefaultWindowWidth : DefaultWindowHeight);
			if (value <= 0)
				value = std::string_view(field) == "width" ? DefaultWindowWidth : DefaultWindowHeight;
		}
		else value = configuredValue;
		return true;
	};
	int width = DefaultWindowWidth;
	int height = DefaultWindowHeight;
	bool resizable = false;
	const auto readBoolean = [&](const char *field, bool &value) {
		lua_getfield(_state, -1, field);
		if (!lua_isboolean(_state, -1))
		{
			lua_pop(_state, 1);
			error = std::string("love.conf t.window.") + field + " must be a boolean";
			return false;
		}
		value = lua_toboolean(_state, -1);
		lua_pop(_state, 1);
		return true;
	};
	bool fullscreen = false;
	bool highdpi = false;
	int vsync = 1;
	const bool valid = readDimension("width", width) && readDimension("height", height)
		&& readBoolean("fullscreen", fullscreen) && readBoolean("highdpi", highdpi)
		&& readBoolean("resizable", resizable);
	if (valid)
	{
		lua_getfield(_state, -1, "display");
		int isInteger = 0;
		const lua_Integer display = lua_tointegerx(_state, -1, &isInteger);
		lua_pop(_state, 1);
		if (!isInteger || display < 1)
			error = "love.conf t.window.display must be a positive integer";
		else if (display != 1 || fullscreen || highdpi)
			appendConfigurationWarning("ignoring unsupported embedded window settings; "
				"LoveNode uses t.window.fullscreen=false, highdpi=false, and display=1");
		if (error.empty())
		{
			lua_getfield(_state, -1, "vsync");
			lua_Integer configuredVSync = 0;
			if (lua_isboolean(_state, -1))
			{
				configuredVSync = lua_toboolean(_state, -1) ? 1 : 0;
				isInteger = 1;
			}
			else configuredVSync = lua_tointegerx(_state, -1, &isInteger);
			lua_pop(_state, 1);
			if (!isInteger || configuredVSync < -1 || configuredVSync > 1)
				error = "love.conf t.window.vsync must be -1, 0, or 1";
			else vsync = static_cast<int>(configuredVSync);
		}
	}
	const bool supported = valid && error.empty();
	lua_pop(_state, 2);
	lua_rawgeti(_state, LUA_REGISTRYINDEX, configuration);
	lua_getfield(_state, -1, "title");
	if (!lua_isstring(_state, -1))
	{
		lua_pop(_state, 2);
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return fail("love.conf t.title must be a string", error);
	}
	const std::string configuredTitle = lua_tostring(_state, -1);
	lua_pop(_state, 1);
	lua_getfield(_state, -1, "identity");
	const bool disabledIdentity = lua_isboolean(_state, -1) && !lua_toboolean(_state, -1);
	if (!lua_isnil(_state, -1) && !lua_isstring(_state, -1) && !disabledIdentity)
	{
		lua_pop(_state, 2);
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return fail("love.conf t.identity must be a string, false, or nil", error);
	}
	const std::string configuredIdentity = lua_isstring(_state, -1) ? lua_tostring(_state, -1) : _identity;
	lua_pop(_state, 1);
	lua_getfield(_state, -1, "audio");
	bool applyMixWithSystem = false;
	bool mixWithSystem = true;
	if (lua_istable(_state, -1))
	{
		lua_getfield(_state, -1, "mixwithsystem");
		if (!lua_isnil(_state, -1))
		{
			if (!lua_isboolean(_state, -1))
			{
				lua_pop(_state, 3);
				luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
				return fail("love.conf t.audio.mixwithsystem must be a boolean or nil", error);
			}
			applyMixWithSystem = true;
			mixWithSystem = lua_toboolean(_state, -1) != 0;
		}
		lua_pop(_state, 1);
	}
	else if (!lua_isnil(_state, -1) && !(lua_isboolean(_state, -1) && !lua_toboolean(_state, -1)))
	{
		lua_pop(_state, 2);
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return fail("love.conf t.audio must be a table, false, or nil", error);
	}
	lua_pop(_state, 2);
	luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
	if (!supported)
		return fail(error, error);
	if (!setIdentity(configuredIdentity.empty() ? "love" : configuredIdentity, error))
		return fail(error, error);
	if (applyMixWithSystem && _audioBackend)
		_audioBackend->setMixWithSystem(mixWithSystem);
	_configuredWidth = width;
	_configuredHeight = height;
	_windowResizable = resizable;
	_windowTitle = configuredTitle;
	_windowVSync = vsync;
	error.clear();
	return true;
}

bool LoveRuntime::start(std::string &error)
{
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before start";
		return false;
	}
	lua_getglobal(_state, "love");
	lua_getfield(_state, -1, "load");
	const bool hasLoadCallback = lua_isfunction(_state, -1);
	lua_pop(_state, 2);
	if (_graphicsBackend && hasLoadCallback)
		_graphicsBackend->beginFrame();
	_graphicsFrameActive = hasLoadCallback;
	_graphicsLoadCallbackActive = hasLoadCallback;
	lua_getglobal(_state, "arg");
	const bool loaded = callLoveCallback("load", 1, 0, error);
	_graphicsLoadCallbackActive = false;
	_graphicsFrameActive = false;
	if (_graphicsBackend && hasLoadCallback)
		_graphicsBackend->endFrame();
	if (!loaded)
		return false;

	_status = Status::Running;
	return true;
}

bool LoveRuntime::update(double deltaTime, std::string &error)
{
	if (_status != Status::Running)
	{
		error = _lastError.empty() ? "LoveRuntime is not running" : _lastError;
		return false;
	}
	drainThreadFilesystemRequests();
	_timerDelta = std::max(0.0, deltaTime);
	_timerWindow += _timerDelta;
	++_timerFrames;
	if (_timerWindow >= 1.0)
	{
		_timerFPS = static_cast<int>(std::floor(static_cast<double>(_timerFrames) / _timerWindow + 0.5));
		_timerAverageDelta = _timerWindow / static_cast<double>(_timerFrames);
		_timerWindow = 0.0;
		_timerFrames = 0;
	}
	if (!dispatchQueuedEvents(error))
		return false;
	if (_status == Status::Stopped || _status == Status::RestartRequested)
	{
		error.clear();
		return true;
	}
	lua_pushnumber(_state, deltaTime);
	return callLoveCallback("update", 1, 0, error);
}

bool LoveRuntime::dispatchQueuedEvents(std::string &error)
{
	drainThreadErrors();
	while (!_eventQueue.empty())
	{
		QueuedEvent event = std::move(_eventQueue.front());
		_eventQueue.pop_front();
		const char *callback = nullptr;
		int argumentCount = 0;
		switch (event.type)
		{
			case QueuedEventType::KeyPressed:
				_pressedKeys.insert(event.first);
				_pressedScancodes.insert(event.second);
				callback = "keypressed";
				lua_pushlstring(_state, event.first.data(), event.first.size());
				lua_pushlstring(_state, event.second.data(), event.second.size());
				lua_pushboolean(_state, event.flag);
				argumentCount = 3;
				break;
			case QueuedEventType::KeyReleased:
				_pressedKeys.erase(event.first);
				_pressedScancodes.erase(event.second);
				callback = "keyreleased";
				lua_pushlstring(_state, event.first.data(), event.first.size());
				lua_pushlstring(_state, event.second.data(), event.second.size());
				argumentCount = 2;
				break;
			case QueuedEventType::TextInput:
				callback = "textinput";
				lua_pushlstring(_state, event.first.data(), event.first.size());
				argumentCount = 1;
				break;
			case QueuedEventType::TextEdited:
				callback = "textedited";
				lua_pushlstring(_state, event.first.data(), event.first.size());
				lua_pushinteger(_state, event.button);
				lua_pushinteger(_state, event.presses);
				argumentCount = 3;
				break;
			case QueuedEventType::MousePressed:
				_mouseX = event.x;
				_mouseY = event.y;
				_pressedMouseButtons.insert(event.button);
				callback = "mousepressed";
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				lua_pushinteger(_state, event.button);
				lua_pushboolean(_state, event.flag);
				lua_pushinteger(_state, event.presses);
				argumentCount = 5;
				break;
			case QueuedEventType::MouseReleased:
				_mouseX = event.x;
				_mouseY = event.y;
				_pressedMouseButtons.erase(event.button);
				callback = "mousereleased";
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				lua_pushinteger(_state, event.button);
				lua_pushboolean(_state, event.flag);
				lua_pushinteger(_state, event.presses);
				argumentCount = 5;
				break;
			case QueuedEventType::MouseMoved:
				_mouseX = event.x;
				_mouseY = event.y;
				callback = "mousemoved";
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				lua_pushnumber(_state, event.deltaX);
				lua_pushnumber(_state, event.deltaY);
				lua_pushboolean(_state, event.flag);
				argumentCount = 5;
				break;
			case QueuedEventType::WheelMoved:
				callback = "wheelmoved";
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				argumentCount = 2;
				break;
			case QueuedEventType::TouchPressed:
			case QueuedEventType::TouchMoved:
			case QueuedEventType::TouchReleased:
				if (event.type == QueuedEventType::TouchReleased)
					_touches.erase(event.touchId);
				else
					_touches[event.touchId] = {event.x, event.y, event.pressure};
				callback = event.type == QueuedEventType::TouchPressed ? "touchpressed"
					: event.type == QueuedEventType::TouchMoved ? "touchmoved" : "touchreleased";
				lua_pushlightuserdata(_state, reinterpret_cast<void *>(event.touchId));
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				lua_pushnumber(_state, event.deltaX);
				lua_pushnumber(_state, event.deltaY);
				lua_pushnumber(_state, event.pressure);
				argumentCount = 6;
				break;
			case QueuedEventType::JoystickAdded:
				callback = "joystickadded";
				pushJoystick(event.controllerId);
				argumentCount = 1;
				break;
			case QueuedEventType::JoystickRemoved:
				callback = "joystickremoved";
				pushJoystick(event.controllerId);
				argumentCount = 1;
				break;
			case QueuedEventType::JoystickPressed:
			case QueuedEventType::JoystickReleased:
				callback = event.type == QueuedEventType::JoystickPressed
					? "joystickpressed" : "joystickreleased";
				pushJoystick(event.controllerId);
				lua_pushinteger(_state, event.button + 1);
				argumentCount = 2;
				break;
			case QueuedEventType::JoystickAxis:
				callback = "joystickaxis";
				pushJoystick(event.controllerId);
				lua_pushinteger(_state, event.button + 1);
				lua_pushnumber(_state, event.x);
				argumentCount = 3;
				break;
			case QueuedEventType::JoystickHat:
				callback = "joystickhat";
				pushJoystick(event.controllerId);
				lua_pushinteger(_state, event.button + 1);
				lua_pushlstring(_state, event.first.data(), event.first.size());
				argumentCount = 3;
				break;
			case QueuedEventType::GamepadPressed:
			{
				auto found = _joysticks.find(event.controllerId);
				if (found == _joysticks.end())
					continue;
				found->second.buttons.insert(event.first);
				callback = "gamepadpressed";
				pushJoystick(event.controllerId);
				lua_pushlstring(_state, event.first.data(), event.first.size());
				argumentCount = 2;
				break;
			}
			case QueuedEventType::GamepadReleased:
			{
				auto found = _joysticks.find(event.controllerId);
				if (found == _joysticks.end())
					continue;
				found->second.buttons.erase(event.first);
				callback = "gamepadreleased";
				pushJoystick(event.controllerId);
				lua_pushlstring(_state, event.first.data(), event.first.size());
				argumentCount = 2;
				break;
			}
			case QueuedEventType::GamepadAxis:
			{
				auto found = _joysticks.find(event.controllerId);
				if (found == _joysticks.end())
					continue;
				found->second.axes[event.first] = event.x;
				callback = "gamepadaxis";
				pushJoystick(event.controllerId);
				lua_pushlstring(_state, event.first.data(), event.first.size());
				lua_pushnumber(_state, event.x);
				argumentCount = 3;
				break;
			}
			case QueuedEventType::Custom:
			{
				if (event.first == "quit")
				{
					bool restart = false;
					if (event.registryReference != LUA_NOREF && event.presses > 0)
					{
						lua_rawgeti(_state, LUA_REGISTRYINDEX, event.registryReference);
						lua_rawgeti(_state, -1, 1);
						restart = lua_type(_state, -1) == LUA_TSTRING
							&& std::string_view(lua_tostring(_state, -1)) == "restart";
						lua_pop(_state, 2);
					}
					const int stackBase = lua_gettop(_state);
					releaseQueuedEvent(event);
					if (!callLoveCallback("quit", 0, 1, error))
					{
						clearQueuedEvents();
						return false;
					}
					const bool cancelled = lua_gettop(_state) > stackBase && lua_toboolean(_state, -1);
					lua_settop(_state, stackBase);
					if (!cancelled)
					{
						_status = restart ? Status::RestartRequested : Status::Stopped;
						clearQueuedEvents();
					}
					continue;
				}
				callback = event.first.c_str();
				if (event.registryReference != LUA_NOREF)
				{
					const int base = lua_gettop(_state);
					lua_rawgeti(_state, LUA_REGISTRYINDEX, event.registryReference);
					for (int index = 1; index <= event.presses; ++index)
						lua_rawgeti(_state, base + 1, index);
					lua_remove(_state, base + 1);
					argumentCount = event.presses;
				}
				break;
			}
			case QueuedEventType::Quit:
			{
				const int stackBase = lua_gettop(_state);
				if (!callLoveCallback("quit", 0, 1, error))
				{
					clearQueuedEvents();
					return false;
				}
				const bool cancelled = lua_gettop(_state) > stackBase && lua_toboolean(_state, -1);
				lua_settop(_state, stackBase);
				if (!cancelled)
				{
					_status = event.first == "restart" ? Status::RestartRequested : Status::Stopped;
					clearQueuedEvents();
				}
				continue;
			}
		}
		if (!callLoveCallback(callback, argumentCount, 0, error))
		{
			releaseQueuedEvent(event);
			clearQueuedEvents();
			return false;
		}
		releaseQueuedEvent(event);
	}
	error.clear();
	return true;
}

bool LoveRuntime::draw(std::string &error)
{
	if (_status != Status::Running)
	{
		error = _lastError.empty() ? "LoveRuntime is not running" : _lastError;
		return false;
	}
	if (_graphicsBackend)
		_graphicsBackend->beginFrame();
	resetGraphicsTransform();
	for (const auto &saved : _graphicsStateStack)
	{
		for (const int reference : saved.canvasReferences)
			luaL_unref(_state, LUA_REGISTRYINDEX, reference);
	}
	_graphicsStateStack.clear();
	_graphicsFrameActive = true;
	const bool success = callLoveCallback("draw", 0, 0, error);
	_graphicsFrameActive = false;
	if (_graphicsBackend)
		_graphicsBackend->endFrame();
	return success;
}

bool LoveRuntime::stop(std::string &error)
{
	if (_status != Status::Running)
	{
		error = _lastError.empty() ? "LoveRuntime is not running" : _lastError;
		return false;
	}
	if (!callLoveCallback("quit", 0, 0, error))
		return false;
	_status = Status::Stopped;
	return true;
}

bool LoveRuntime::restart(std::string &error)
{
	if (_bootChunkName.empty())
	{
		error = "LoveRuntime has no boot chunk to restart";
		return false;
	}

	const std::string code = _bootCode;
	const std::string chunkName = _bootChunkName;
	const std::string sourceRoot = _sourceRoot;
	const std::string saveBaseRoot = _saveBaseRoot;
	const std::string identity = _identity;
	close();
	if (!open(error))
		return false;
	if (!sourceRoot.empty() && !setSourceRoot(sourceRoot, error))
		return false;
	if (!saveBaseRoot.empty() && !setSaveBaseRoot(saveBaseRoot, error))
		return false;
	if (!identity.empty() && !setIdentity(identity, error))
		return false;
	return boot(code, chunkName, error);
}

} // namespace Dora::Love

namespace love::filesystem
{

Filesystem *newDoraFilesystem(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love filesystem has no owning runtime.");
	return new Dora::Love::DoraLoveFilesystem(runtime);
}

} // namespace love::filesystem

namespace love::sound
{

Sound *newDoraSound(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love sound module has no owning runtime.");
	return new Dora::Love::DoraLoveSound(runtime);
}

} // namespace love::sound

namespace love::font
{

Font *newDoraFont(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love font module has no owning runtime.");
	return new Dora::Love::DoraLoveFont(runtime);
}

} // namespace love::font

namespace love::image
{

Image *newDoraImage(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love image module has no owning runtime.");
	return new Dora::Love::DoraLoveImage(runtime);
}

} // namespace love::image

namespace love::thread
{

ThreadModule *newDoraThreadModule(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love thread module has no owning runtime.");
	return new Dora::Love::DoraLoveThreadModule(runtime);
}

} // namespace love::thread

namespace love::system
{

System *newDoraSystem(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love system module has no owning runtime.");
	return new Dora::Love::DoraLoveSystem(runtime);
}

} // namespace love::system

namespace love::timer
{

Timer *newDoraTimer(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love timer module has no owning runtime.");
	return new Dora::Love::DoraLoveTimer(runtime);
}

} // namespace love::timer

namespace love::event
{

Event *newDoraEvent(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love event module has no owning runtime.");
	return new Dora::Love::DoraLoveEvent(runtime, state);
}

} // namespace love::event

namespace love::window
{

Window *newDoraWindow(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love window module has no owning runtime.");
	return new Dora::Love::DoraLoveWindow(runtime);
}

} // namespace love::window

namespace love::keyboard
{

Keyboard *newDoraKeyboard(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love keyboard module has no owning runtime.");
	return new Dora::Love::DoraLoveKeyboard(runtime);
}

} // namespace love::keyboard

namespace love::mouse
{

Mouse *newDoraMouse(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love mouse module has no owning runtime.");
	return new Dora::Love::DoraLoveMouse(runtime);
}

} // namespace love::mouse

namespace love::touch
{

Touch *newDoraTouch(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love touch module has no owning runtime.");
	return new Dora::Love::DoraLoveTouch(runtime);
}

} // namespace love::touch

namespace love::joystick
{

JoystickModule *newDoraJoystickModule(lua_State *state)
{
	lua_getfield(state, LUA_REGISTRYINDEX, "Dora.Love.Runtime");
	auto *runtime = static_cast<Dora::Love::LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (!runtime)
		throw love::Exception("Dora Love joystick module has no owning runtime.");
	return new Dora::Love::DoraLoveJoystickModule(runtime);
}

} // namespace love::joystick
