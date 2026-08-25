/** Copyright (c) 2006-2023 LOVE Development Team. */
#pragma once

#include "common/Module.h"
#include "common/Object.h"
#include "image/FormatHandler.h"
#include "thread/Channel.h"

#include <string>

namespace love::graphics
{

struct GraphicsScreenshotRequest
{
	enum class Type { Function, File, Channel };
	Type type = Type::Function;
	int callbackReference = LUA_NOREF;
	std::string filename;
	image::FormatHandler::EncodedFormat format = image::FormatHandler::ENCODED_PNG;
	StrongRef<thread::Channel> channel;
};

class GraphicsScreenshotCommand
{
public:
	virtual ~GraphicsScreenshotCommand() = default;
	virtual void captureScreenshot(lua_State *L, GraphicsScreenshotRequest request) = 0;
};

LOVE_EXPORT int w_captureScreenshot(lua_State *L);

}
