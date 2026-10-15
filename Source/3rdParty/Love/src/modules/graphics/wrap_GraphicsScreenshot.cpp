/** Copyright (c) 2006-2023 LOVE Development Team. */
#include "wrap_GraphicsScreenshot.h"

#include "common/runtime.h"
#include "image/ImageData.h"
#include "thread/wrap_Channel.h"

#include <algorithm>
#include <cctype>

namespace love::graphics
{

static GraphicsScreenshotCommand *screenshotCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsScreenshotCommand *>(module);
	if (!command) luaL_error(L, "love.graphics has no state-local screenshot backend");
	return command;
}

int w_captureScreenshot(lua_State *L)
{
	GraphicsScreenshotRequest request;

	if (lua_isfunction(L, 1))
	{
		request.type = GraphicsScreenshotRequest::Type::Function;
		lua_pushvalue(L, 1);
		request.callbackReference = luaL_ref(L, LUA_REGISTRYINDEX);
	}
	else if (lua_isstring(L, 1))
	{
		request.type = GraphicsScreenshotRequest::Type::File;
		request.filename = luax_checkstring(L, 1);
		std::string extension;
		const size_t dot = request.filename.rfind('.');
		if (dot != std::string::npos)
			extension = request.filename.substr(dot + 1);
		std::transform(extension.begin(), extension.end(), extension.begin(),
			[](unsigned char value) { return (char) std::tolower(value); });
		if (!image::ImageData::getConstant(extension.c_str(), request.format))
			return luax_enumerror(L, "encoded image format",
				image::ImageData::getConstants(request.format), extension.c_str());
	}
	else if (luax_istype(L, 1, thread::Channel::type))
	{
		request.type = GraphicsScreenshotRequest::Type::Channel;
		request.channel.set(thread::luax_checkchannel(L, 1));
	}
	else
		return luax_typerror(L, 1, "function, string, or Channel");

	const int callbackReference = request.callbackReference;
	luax_catchexcept(L,
		[&]() { screenshotCommand(L)->captureScreenshot(L, std::move(request)); },
		[&](bool except) {
			if (except && callbackReference != LUA_NOREF)
				luaL_unref(L, LUA_REGISTRYINDEX, callbackReference);
		});
	return 0;
}

}
