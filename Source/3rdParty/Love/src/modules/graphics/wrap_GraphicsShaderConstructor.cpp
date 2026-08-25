/** Copyright (c) 2006-2023 LOVE Development Team. */
#include "wrap_GraphicsShaderConstructor.h"

#include "common/Module.h"
#include "filesystem/Filesystem.h"
#include "filesystem/wrap_Filesystem.h"
#include "wrap_Shader.h"

#include <regex>

namespace love::graphics
{

static GraphicsShaderConstructorCommand *shaderConstructorCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsShaderConstructorCommand *>(module);
	if (!command) luaL_error(L, "love.graphics has no state-local Shader factory");
	return command;
}

static void loadShaderArgument(lua_State *L, int index, std::string &source)
{
	using namespace love::filesystem;
	if (!lua_isstring(L, index) && luax_cangetfiledata(L, index))
	{
		auto *data = luax_getfiledata(L, index);
		source.assign(static_cast<const char *>(data->getData()), data->getSize());
		data->release();
		return;
	}
	if (!lua_isstring(L, index))
		luaL_argerror(L, index, "expected shader source code, a filename, or FileData");
	size_t size = 0;
	const char *text = lua_tolstring(L, index, &size);
	std::string candidate(text, size);
	auto *module = luax_getmodule(L, Module::M_FILESYSTEM);
	auto *filesystem = dynamic_cast<Filesystem *>(module);
	Filesystem::Info info = {};
	if (filesystem && candidate.find('\n') == std::string::npos
		&& filesystem->getInfo(candidate.c_str(), info))
	{
		FileData *data = nullptr;
		luax_catchexcept(L, [&](){ data = filesystem->read(candidate.c_str()); });
		source.assign(static_cast<const char *>(data->getData()), data->getSize());
		data->release();
		return;
	}
	const auto dot = candidate.find('.');
	if (candidate.size() < 64 && candidate.find('\n') == std::string::npos
		&& dot != std::string::npos && candidate.find(';', dot) == std::string::npos
		&& candidate.find(' ', dot) == std::string::npos)
		luaL_error(L, "Could not open file %s. Does not exist.", candidate.c_str());
	source = std::move(candidate);
}

static void getShaderSource(lua_State *L, int startIndex,
	std::string &vertexSource, std::string &pixelSource)
{
	const int count = lua_isnoneornil(L, startIndex + 1) ? 1 : 2;
	std::vector<std::string> arguments(static_cast<std::size_t>(count));
	for (int index = 0; index < count; ++index)
		loadShaderArgument(L, startIndex + index, arguments[static_cast<std::size_t>(index)]);
	static const std::regex vertexEntry(R"(\bvec4\s+position\s*\()",
		std::regex_constants::ECMAScript);
	static const std::regex pixelEntry(R"(\b(?:vec4|void)\s+effect\s*\()",
		std::regex_constants::ECMAScript);
	for (const auto &source : arguments)
	{
		if (std::regex_search(source, vertexEntry)) vertexSource = source;
		if (std::regex_search(source, pixelEntry)) pixelSource = source;
	}
	if (arguments.size() == 2 && (vertexSource.empty() || pixelSource.empty()))
		luaL_error(L, "%s", vertexSource.empty()
			? "Could not parse vertex shader code (missing 'position' function?)"
			: "Could not parse pixel shader code (missing 'effect' function?)");
	if (vertexSource.empty() && pixelSource.empty())
		luaL_argerror(L, startIndex, "missing 'position' or 'effect' function?");
}

int w_newShader(lua_State *L)
{
	std::string vertexSource;
	std::string pixelSource;
	getShaderSource(L, 1, vertexSource, pixelSource);
	Shader *shader = nullptr;
	luax_catchexcept(L, [&]()
	{
		shader = shaderConstructorCommand(L)->newShader(vertexSource, pixelSource);
	});
	luax_pushtype(L, shader);
	shader->release();
	return 1;
}

int w_validateShader(lua_State *L)
{
	const bool gles = luax_checkboolean(L, 1);
	std::string vertexSource;
	std::string pixelSource;
	getShaderSource(L, 2, vertexSource, pixelSource);
	std::string error;
	bool success = false;
	try
	{
		success = shaderConstructorCommand(L)->validateShader(
			gles, vertexSource, pixelSource, error);
	}
	catch (const love::Exception &exception)
	{
		error = exception.what();
	}
	luax_pushboolean(L, success);
	if (!success)
	{
		luax_pushstring(L, error);
		return 2;
	}
	return 1;
}

}
