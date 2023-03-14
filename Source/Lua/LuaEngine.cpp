/* Copyright (c) 2023 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Lua/LuaEngine.h"

#include "Common/Async.h"
#include "Lua/LuaBinding.h"
#include "Lua/LuaFromXml.h"
#include "Lua/LuaHandler.h"
#include "Lua/LuaManual.h"
#include "Node/Node.h"
#include "Support/Value.h"

extern "C" {
int luaopen_yue(lua_State* L);
int luaopen_colibc_json(lua_State* L);
}

NS_DOROTHY_BEGIN

int LuaEngine::_callFromLua = 0;

static int dora_print(lua_State* L) {
	int nargs = lua_gettop(L);
	lua_getglobal(L, "tostring");
	int funcIndex = lua_gettop(L);
	std::string t;
	for (int i = 1; i <= nargs; i++) {
		lua_pushvalue(L, funcIndex);
		lua_pushvalue(L, i);
		lua_call(L, 1, 1);
		t += tolua_toslice(L, -1, nullptr);
		lua_pop(L, 1);
		if (i != nargs) t += '\t';
	}
	t += '\n';
	lua_settop(L, nargs);
	LogPrint(t);
	return 0;
}

static int dora_trace_back(lua_State* L) {
	// -1 error_string
	lua_getglobal(L, "debug"); // err debug
	lua_getfield(L, -1, "traceback"); // err debug traceback
	lua_pushvalue(L, -3); // err debug traceback err
	lua_pushinteger(L, 1); // err debug traceback err 1
	lua_call(L, 2, 1); // traceback(err, 1), err debug msg
	LogPrint(tolua_toslice(L, -1, nullptr));
	lua_pop(L, 3); // empty
	return 0;
}

static int dora_load_file(lua_State* L, String filename, String moduleName = nullptr) {
	AssertIf(filename.empty(), "passing empty filename string to lua loader.");
	std::string extension = Path::getExt(filename);
	std::string targetFile = filename;
	if (extension.empty() && targetFile.back() != '.') {
		std::string fullPath;
		for (auto ext : {"lua"s, "xml"s, "tl"s, "wasm"s}) {
			fullPath = SharedContent.getFullPath(targetFile + '.' + ext);
			if (SharedContent.exist(fullPath)) {
				targetFile = fullPath;
				extension = ext;
				break;
			}
		}
		if (extension.empty()) {
			std::stringstream ss;
			bool first = true;
			for (auto ext : {"lua"s, "xml"s, "tl"s, "wasm"s}) {
				auto triedPaths = SharedContent.getFullPathsToTry(targetFile + '.' + ext);
				for (auto it = triedPaths.begin(); it != triedPaths.end(); ++it) {
					if (first)
						first = false;
					else
						ss << "\n\t"sv;
					ss << "no file '"sv << *it << '\'';
				}
			}
			auto msg = ss.str();
			lua_pushlstring(L, msg.c_str(), msg.size());
			return 1;
		}
	} else if (!SharedContent.exist(targetFile)) {
		std::stringstream ss;
		auto triedPaths = SharedContent.getFullPathsToTry(targetFile);
		for (auto it = triedPaths.begin(); it != triedPaths.end(); ++it) {
			if (it != triedPaths.begin()) ss << "\n\t"sv;
			ss << "no file '"sv << *it << '\'';
		}
		auto msg = ss.str();
		lua_pushlstring(L, msg.c_str(), msg.size());
		return 1;
	}

	const char* codeBuffer = nullptr;
	size_t codeBufferSize = 0;
	OwnArray<uint8_t> buffer;
	std::string codes;
	switch (Switch::hash(extension)) {
		case "xml"_hash: {
			codes = SharedXmlLoader.load(targetFile);
			if (codes.empty()) {
				luaL_error(L, "error parsing xml file: %s\n%s", filename.c_str().get(), SharedXmlLoader.getLastError().c_str());
			} else {
				codes.insert(0, "-- [xml]: "s + filename + '\n');
				codeBuffer = codes.c_str();
				codeBufferSize = codes.size();
				std::string name = "@"s + filename;
				lua_getglobal(L, "package"); // package
				lua_getfield(L, -1, "loaded"); // package loaded
				lua_getfield(L, -1, "yue"); // package loaded yue
				lua_getfield(L, -1, "yue_compiled"); // package loaded yue compiled
				lua_pushlstring(L, name.c_str(), name.size()); // package loaded yue compiled name
				lua_pushlstring(L, codeBuffer, codeBufferSize); // package loaded yue compiled name buffer
				lua_rawset(L, -3); // compiled[name] = buffer, package loaded yue compiled
				lua_pop(L, 4); // clear
			}
			break;
		}
		case "tl"_hash: {
			auto data = SharedContent.load(targetFile);
			auto str = Slice(r_cast<char*>(data.first.get()), data.second).toString();
			std::string err;
			std::tie(codes, err) = SharedLuaEngine.compileTealToLua(str, moduleName);
			if (codes.empty()) {
				luaL_error(L, "%s", err.c_str());
			} else {
				codeBuffer = codes.c_str();
				codeBufferSize = codes.size();
			}
			break;
		}
		case "wasm"_hash: {
			codes = "builtin.Wasm:executeMainFile(\""s + targetFile + "\")"s;
			codeBuffer = codes.c_str();
			codeBufferSize = codes.size();
			break;
		}
		default: {
			auto data = SharedContent.load(targetFile);
			buffer = std::move(data.first);
			codeBuffer = r_cast<char*>(buffer.get());
			codeBufferSize = data.second;
			break;
		}
	}
	if (codeBuffer) {
		if (luaL_loadbuffer(L, codeBuffer, codeBufferSize, filename.c_str()) != 0) {
			luaL_error(L, "error loading module \"%s\" from file \"%s\" :\n\t%s",
				lua_tostring(L, 1), filename.c_str().get(), lua_tostring(L, -1));
		}
	} else {
		luaL_error(L, "can not get data from file \"%s\"", filename.c_str().get());
	}
	return 1;
}

static int dora_load_file(lua_State* L) {
	size_t size = 0;
	const char* str = luaL_checklstring(L, 1, &size);
	Slice filename(str, size);
	return dora_load_file(L, filename);
}

static int dora_do_file(lua_State* L) {
	size_t size = 0;
	const char* str = luaL_checklstring(L, 1, &size);
	Slice filename(str, size);
	dora_load_file(L, filename);
	if (lua_isnil(L, -2) && lua_isstring(L, -1)) {
		luaL_error(L, lua_tostring(L, -1));
	}
	int top = lua_gettop(L) - 1;
	LuaEngine::call(L, 0, LUA_MULTRET);
	int newTop = lua_gettop(L);
	return newTop - top;
}

static int dora_loader(lua_State* L) {
	size_t size = 0;
	const char* str = luaL_checklstring(L, 1, &size);
	Slice filename(str, size);
	bool convertToPath = true;
	for (auto ch : filename) {
		if (ch == '\\' || ch == '/') {
			convertToPath = false;
			break;
		}
	}
	if (convertToPath) {
		auto tokens = filename.split("."_slice);
		auto file = Path::concat(tokens);
		return dora_load_file(L, file, filename);
	}
	return dora_load_file(L, filename, filename);
}

static int dora_do_xml(lua_State* L) {
	size_t len = 0;
	std::string codes(luaL_checklstring(L, 1, &len), len);
	codes = SharedXmlLoader.load(codes);
	if (codes.empty()) {
		luaL_error(L, "error parsing local xml, %s\n", SharedXmlLoader.getLastError().c_str());
	}
	if (luaL_loadbuffer(L, codes.c_str(), codes.size(), "xml") != 0) {
		Error("[Lua] {}", codes);
		luaL_error(L, "error loading module %s from file %s :\n\t%s",
			lua_tostring(L, 1), "xml", lua_tostring(L, -1));
	}
	LuaEngine::call(L, 0, 1);
	return 1;
}

static int dora_xml_to_lua(lua_State* L) {
	size_t len = 0;
	std::string codes(luaL_checklstring(L, 1, &len), len);
	codes = SharedXmlLoader.loadXml(codes);
	if (codes.empty()) {
		const std::string& lastError = SharedXmlLoader.getLastError();
		lua_pushnil(L);
		lua_pushlstring(L, lastError.c_str(), lastError.size());
		return 2;
	}
	lua_pushlstring(L, codes.c_str(), codes.size());
	return 1;
}

static int dora_teal_to_lua(lua_State* L) {
	size_t len = 0;
	std::string codes(luaL_checklstring(L, 1, &len), len);
	std::string moduleName(luaL_checklstring(L, 2, &len), len);
	std::string res, err;
	std::tie(res, err) = SharedLuaEngine.compileTealToLua(codes, moduleName);
	if (res.empty() && !err.empty()) {
		lua_pushnil(L);
		lua_pushlstring(L, err.c_str(), err.size());
		return 2;
	}
	lua_pushlstring(L, res.c_str(), res.size());
	return 1;
}

static int dora_teal_to_lua_async(lua_State* L) {
	size_t len = 0;
	std::string codes(luaL_checklstring(L, 1, &len), len);
	std::string moduleName(luaL_checklstring(L, 2, &len), len);
	tolua_Error err;
	if (!tolua_isfunction(L, 3, &err)) {
		tolua_error(L, "#ferror in function 'teal.toluaAsync'.", &err);
	}
	Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 3)));
	SharedLuaEngine.compileTealToLuaAsync(codes, moduleName, [handler](auto result) {
		std::string res, err;
		std::tie(res, err) = result;
		auto L = SharedLuaEngine.getState();
		int top = lua_gettop(L);
		DEFER(lua_settop(L, top));
		if (res.empty() && !err.empty()) {
			lua_pushnil(L);
			lua_pushlstring(L, err.c_str(), err.size());
			LuaEngine::invoke(L, handler->get(), 2, 0);
		} else {
			lua_pushlstring(L, res.c_str(), res.size());
			LuaEngine::invoke(L, handler->get(), 1, 0);
		}
	});
	return 0;
}

static int dora_reset_teal(lua_State* L) {
	SharedLuaEngine.resetTealCompiler();
	return 0;
}

static int dora_teal_check_async(lua_State* L) {
	size_t len = 0;
	std::string codes(luaL_checklstring(L, 1, &len), len);
	std::string moduleName(luaL_checklstring(L, 2, &len), len);
	bool lax = lua_toboolean(L, 3) != 0;
	tolua_Error err;
	if (!tolua_isfunction(L, 4, &err)) {
		tolua_error(L, "#ferror in function 'teal.checkAsync'.", &err);
	}
	Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 4)));
	SharedLuaEngine.checkTealAsync(codes, moduleName, lax, [handler](auto result) {
		auto L = SharedLuaEngine.getState();
		int top = lua_gettop(L);
		DEFER(lua_settop(L, top));
		if (result) {
			lua_pushboolean(L, 0);
			lua_createtable(L, result.value().size(), 0);
			int index = 0;
			for (const auto& err : result.value()) {
				lua_createtable(L, 5, 0);
				tolua_pushslice(L, err.type);
				lua_rawseti(L, -2, 1);
				tolua_pushslice(L, SharedContent.getFullPath(err.filename));
				lua_rawseti(L, -2, 2);
				lua_pushinteger(L, err.row);
				lua_rawseti(L, -2, 3);
				lua_pushinteger(L, err.col);
				lua_rawseti(L, -2, 4);
				tolua_pushslice(L, err.msg);
				lua_rawseti(L, -2, 5);
				lua_rawseti(L, -2, ++index);
			}
			LuaEngine::invoke(L, handler->get(), 2, 0);
		} else {
			lua_pushboolean(L, 1);
			LuaEngine::invoke(L, handler->get(), 1, 0);
		}
	});
	return 0;
}

static int dora_teal_complete_async(lua_State* L) {
	size_t len = 0;
	std::string codes(luaL_checklstring(L, 1, &len), len);
	std::string line(luaL_checklstring(L, 2, &len), len);
	int row = static_cast<int>(luaL_checknumber(L, 3));
	tolua_Error err;
	if (!tolua_isfunction(L, 4, &err)) {
		tolua_error(L, "#ferror in function 'teal.completeAsync'.", &err);
	}
	Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 4)));
	SharedLuaEngine.completeTealAsync(codes, line, row, [handler](auto result) {
		auto L = SharedLuaEngine.getState();
		int top = lua_gettop(L);
		DEFER(lua_settop(L, top));
		lua_createtable(L, result.size(), 0);
		int i = 0;
		for (const auto& item : result) {
			lua_createtable(L, 2, 0);
			tolua_pushslice(L, item.name);
			lua_rawseti(L, -2, 1);
			tolua_pushslice(L, item.desc);
			lua_rawseti(L, -2, 2);
			tolua_pushslice(L, item.type);
			lua_rawseti(L, -2, 3);
			lua_rawseti(L, -2, ++i);
		}
		LuaEngine::invoke(L, handler->get(), 1, 0);
	});
	return 0;
}

static int dora_teal_infer_async(lua_State* L) {
	size_t len = 0;
	std::string codes(luaL_checklstring(L, 1, &len), len);
	std::string line(luaL_checklstring(L, 2, &len), len);
	int row = static_cast<int>(luaL_checknumber(L, 3));
	tolua_Error err;
	if (!tolua_isfunction(L, 4, &err)) {
		tolua_error(L, "#ferror in function 'teal.completeAsync'.", &err);
	}
	Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 4)));
	SharedLuaEngine.inferTealAsync(codes, line, row, [handler](auto result) {
		auto L = SharedLuaEngine.getState();
		int top = lua_gettop(L);
		DEFER(lua_settop(L, top));
		if (result) {
			lua_createtable(L, 0, 0);
			tolua_pushslice(L, result.value().desc);
			lua_setfield(L, -2, "desc");
			tolua_pushslice(L, result.value().file);
			lua_setfield(L, -2, "file");
			lua_pushinteger(L, result.value().row);
			lua_setfield(L, -2, "row");
			lua_pushinteger(L, result.value().col);
			lua_setfield(L, -2, "col");
			if (!result.value().file.empty()) {
				tolua_pushslice(L, SharedContent.getFullPath(result.value().file));
				lua_setfield(L, -2, "key");
			}
		} else {
			lua_pushnil(L);
		}
		LuaEngine::invoke(L, handler->get(), 1, 0);
	});
	return 0;
}

static int dora_teal_threaded_read(lua_State* L) {
	size_t size = 0;
	auto fileStr = luaL_checklstring(L, 1, &size);
	Slice filename{fileStr, size};
	OwnArray<uint8_t> codeData;
	size_t codeSize;
	bx::Semaphore waitForLoaded;
	SharedApplication.invokeInLogic([&]() {
		SharedContent.loadAsyncData(filename, [&](OwnArray<uint8_t>&& data, size_t size) {
			codeData = std::move(data);
			codeSize = size;
			waitForLoaded.post();
		});
	});
	waitForLoaded.wait();
	Slice codes{r_cast<char*>(codeData.get()), codeSize};
	tolua_pushslice(L, codes);
	return 1;
}

static int dora_file_exist(lua_State* L) {
	size_t size = 0;
	auto str = luaL_checklstring(L, 1, &size);
	lua_pushboolean(L, SharedContent.exist({str, size}) ? 1 : 0);
	return 1;
}

static int dora_read_file(lua_State* L) {
	size_t size = 0;
	auto fileStr = luaL_checklstring(L, 1, &size);
	Slice filename{fileStr, size};
	auto data = SharedContent.load(filename);
	Slice codes{r_cast<char*>(data.first.get()), data.second};
	if (codes.left(3) == "\xEF\xBB\xBF"_slice) {
		codes.skip(3);
	}
	tolua_pushslice(L, codes);
	return 1;
}

static int dora_load_base(lua_State* L) {
	const luaL_Reg lualibs[] = {
		{LUA_GNAME, luaopen_base},
		{LUA_LOADLIBNAME, luaopen_package},
		{LUA_COLIBNAME, luaopen_coroutine},
		{LUA_TABLIBNAME, luaopen_table},
		{LUA_STRLIBNAME, luaopen_string},
		{LUA_MATHLIBNAME, luaopen_math},
		{LUA_UTF8LIBNAME, luaopen_utf8},
		{LUA_DBLIBNAME, luaopen_debug},
		{NULL, NULL}};
	for (const luaL_Reg* lib = lualibs; lib->func; lib++) {
		luaL_requiref(L, lib->name, lib->func, 1);
		lua_pop(L, 1);
	}
	return 0;
}

static int dora_load_libs(lua_State* L) {
	dora_load_base(L);
	luaL_requiref(L, "json", luaopen_colibc_json, 0);
	lua_pop(L, 1);
	luaL_requiref(L, "yue", luaopen_yue, 0); // yue
	lua_pushcfunction(L, dora_file_exist);
	lua_setfield(L, -2, "file_exist");
	lua_pushcfunction(L, dora_read_file);
	lua_setfield(L, -2, "read_file");
	lua_pop(L, 1);
	return 0;
}

static void dora_open_compiler(void* state) {
	lua_State* L = s_cast<lua_State*>(state);
	dora_load_libs(L);
	const luaL_Reg global_functions[] = {
		{"print", dora_print},
		{NULL, NULL}};
	lua_pushglobaltable(L);
	luaL_setfuncs(L, global_functions, 0);
	lua_pop(L, 1);
}

static int dora_yue_check(lua_State* L) {
	size_t size = 0;
	auto codes = luaL_checklstring(L, 1, &size);
	yue::YueConfig config;
	config.implicitReturnRoot = true;
	config.reserveLineNumber = true;
	config.lintGlobalVariable = true;
	auto result = yue::YueCompiler{nullptr, dora_open_compiler}.compile({codes, size}, config);
	lua_createtable(L, 0, 0);
	int i = 0;
	if (result.error) {
		const auto& error = result.error.value();
		lua_createtable(L, 4, 0);
		tolua_pushslice(L, "error"_slice);
		lua_rawseti(L, -2, 1);
		tolua_pushslice(L, error.msg);
		lua_rawseti(L, -2, 2);
		tolua_pushinteger(L, error.line);
		lua_rawseti(L, -2, 3);
		tolua_pushinteger(L, error.col);
		lua_rawseti(L, -2, 4);
		lua_rawseti(L, -2, ++i);
	}
	if (result.globals) {
		for (const auto& global : *result.globals) {
			lua_createtable(L, 4, 0);
			tolua_pushslice(L, "global"_slice);
			lua_rawseti(L, -2, 1);
			tolua_pushslice(L, global.name);
			lua_rawseti(L, -2, 2);
			tolua_pushinteger(L, global.line);
			lua_rawseti(L, -2, 3);
			tolua_pushinteger(L, global.col);
			lua_rawseti(L, -2, 4);
			lua_rawseti(L, -2, ++i);
		}
	}
	if (result.error) {
		return 1;
	} else {
		tolua_pushslice(L, result.codes);
		return 2;
	}
}

static int dora_yue_compile(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(L, 1, 0, &tolua_err) || !tolua_isstring(L, 2, 0, &tolua_err) || !tolua_isfunction(L, 3, &tolua_err) || !tolua_isfunction(L, 4, &tolua_err) || !tolua_isnoobj(L, 5, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		std::string src = tolua_toslice(L, 1, 0);
		std::string dest = tolua_toslice(L, 2, 0);
		Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 3)));
		LuaFunction<void> callback(tolua_ref_function(L, 4));
		SharedContent.loadAsyncData(src, [src, dest, handler, callback](OwnArray<uint8_t>&& codes, size_t size) {
			if (!codes) {
				{
					lua_State* L = SharedLuaEngine.getState();
					int top = lua_gettop(L);
					DEFER(lua_settop(L, top));
					auto err = fmt::format("failed to get yue source codes from \"{}\".", src);
					lua_pushnil(L);
					lua_pushlstring(L, err.c_str(), err.size());
					LuaEngine::invoke(L, handler->get(), 2, 0);
				}
				callback(false);
			} else {
				auto input = std::make_shared<std::tuple<
					std::string, std::string, OwnArray<uint8_t>, size_t>>(
					src, dest, std::move(codes), size);
				SharedAsyncThread.run(
					[input, src]() {
						yue::YueConfig config;
						config.implicitReturnRoot = true;
						config.reserveLineNumber = true;
						config.lintGlobalVariable = true;
						config.module = src;
						size_t size = std::get<3>(*input);
						const auto& codes = std::get<2>(*input);
						auto result = yue::YueCompiler{nullptr, dora_open_compiler}.compile({r_cast<char*>(codes.get()), size}, config);
						return Values::alloc(std::move(result));
					},
					[input, handler, callback](Own<Values> values) {
						yue::CompileInfo result;
						values->get(result);
						std::string finalCodes;
						bool success = false;
						{
							lua_State* L = SharedLuaEngine.getState();
							int top = lua_gettop(L);
							DEFER(lua_settop(L, top));
							if (result.error) {
								lua_pushnil(L);
								const auto& msg = result.error.value().displayMessage;
								tolua_pushslice(L, msg);
							} else {
								tolua_pushslice(L, result.codes);
								lua_pushnil(L);
							}
							if (result.globals) {
								lua_createtable(L, s_cast<int>(result.globals->size()), 0);
								int i = 1;
								for (const auto& var : *result.globals) {
									lua_createtable(L, 3, 0);
									lua_pushlstring(L, var.name.c_str(), var.name.size());
									lua_rawseti(L, -2, 1);
									lua_pushinteger(L, var.line);
									lua_rawseti(L, -2, 2);
									lua_pushinteger(L, var.col);
									lua_rawseti(L, -2, 3);
									lua_rawseti(L, -2, i);
									i++;
								}
							} else
								lua_pushnil(L);
							auto mainL = SharedLuaEngine.getState();
							LuaEngine::invoke(mainL, handler->get(), 3, 1);
							if (lua_isstring(mainL, -1) != 0) {
								finalCodes = tolua_toslice(mainL, -1, nullptr);
								success = true;
							}
						}
						if (!success)
							callback(false);
						else
							SharedContent.saveAsync(std::get<1>(*input), finalCodes, [callback](bool success) {
								callback(success);
							});
					});
			}
		});
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'yuecompile'.", &tolua_err);
	return 0;
#endif
}

static int dora_ubox(lua_State* L) {
	lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_UBOX); // ubox
	return 1;
}

lua_State* LuaEngine::getState() const {
	return L;
}

yue::YueCompiler& LuaEngine::getYue() {
	if (!_yueCompiler) {
		_yueCompiler = New<yue::YueCompiler>(L);
	}
	return *_yueCompiler;
}

int LuaEngine::getMemoryCount() const {
	int k = lua_gc(L, LUA_GCCOUNT);
	int b = lua_gc(L, LUA_GCCOUNTB);
	int memLua = (k * 1024 + b);
	if (_tlState) {
		k = lua_gc(_tlState->L, LUA_GCCOUNT);
		b = lua_gc(_tlState->L, LUA_GCCOUNTB);
		memLua += (k * 1024 + b);
	}
	return memLua;
}

LuaEngine::LuaEngine()
	: L(luaL_newstate())
	, _tlState(nullptr) {
	dora_load_libs(L);
	tolua_open(L);

	// Register our version of the global "print" function
	const luaL_Reg global_functions[] = {
		{"print", dora_print},
		{"loadfile", dora_load_file},
		{"dofile", dora_do_file},
		{NULL, NULL}};
	lua_pushglobaltable(L);
	luaL_setfuncs(L, global_functions, 0);
	lua_pop(L, 1);

	// add dorothy loader
	LuaEngine::insertLuaLoader(dora_loader, 2);

	// load cpp binding
	tolua_LuaBinding_open(L);

	// add manual binding
	tolua_beginmodule(L, nullptr); // stack: builtin
	{
		tolua_function(L, "doxml", dora_do_xml);
		tolua_function(L, "xmltolua", dora_xml_to_lua);
		tolua_function(L, "ubox", dora_ubox);
		tolua_function(L, "emit", dora_emit);

		tolua_beginmodule(L, "Application");
		{
			tolua_variable(L, "testNames", Test_getNames, nullptr);
			tolua_function(L, "runTest", Test_runTest);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Path");
		{
			tolua_call(L, MT_CALL, Path_create);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Content");
		{
			tolua_variable(L, "searchPaths", Content_GetSearchPaths, Content_SetSearchPaths);
			tolua_function(L, "loadExcel", Content_loadExcel);
			tolua_function(L, "loadExcelAsync", Content_loadExcelAsync);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Node");
		{
			tolua_function(L, "gslot", Node_gslot);
			tolua_function(L, "slot", Node_slot);
			tolua_function(L, "emit", Node_emit);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Action");
		{
			tolua_call(L, MT_CALL, Action_create);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Dictionary");
		{
			tolua_function(L, "set", Dictionary_set);
			tolua_function(L, "get", Dictionary_get);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Array");
		{
			tolua_variable(L, "first", Array_getFirst, nullptr);
			tolua_variable(L, "last", Array_getLast, nullptr);
			tolua_variable(L, "randomObject", Array_getRandomObject, nullptr);
			tolua_function(L, "set", Array_set);
			tolua_function(L, "get", Array_get);
			tolua_function(L, "add", Array_add);
			tolua_function(L, "insert", Array_insert);
			tolua_function(L, "contains", Array_contains);
			tolua_function(L, "index", Array_index);
			tolua_function(L, "removeLast", Array_removeLast);
			tolua_function(L, "fastRemove", Array_fastRemove);
			tolua_call(L, MT_CALL, Array_create);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Entity");
		{
			tolua_function(L, "set", Entity_set);
			tolua_function(L, "get", Entity_get);
			tolua_function(L, "getOld", Entity_getOld);
			tolua_call(L, MT_CALL, Entity_create);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Group");
		{
			tolua_function(L, "watch", EntityGroup_watch);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Observer");
		{
			tolua_function(L, "watch", EntityObserver_watch);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "BodyDef");
		{
			tolua_variable(L, "type", BodyDef_GetType, BodyDef_SetType);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Sprite");
		{
			tolua_variable(L, "uwrap", Sprite_GetUWrap, Sprite_SetUWrap);
			tolua_variable(L, "vwrap", Sprite_GetVWrap, Sprite_SetVWrap);
			tolua_variable(L, "filter", Sprite_GetTextureFilter, Sprite_SetTextureFilter);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Label");
		{
			tolua_variable(L, "alignment", Label_GetTextAlign, Label_SetTextAlign);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "DrawNode");
		{
			tolua_function(L, "drawVertices", DrawNode_drawVertices);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Spine");
		{
			tolua_function(L, "containsPoint", Spine_containsPoint);
			tolua_function(L, "intersectsSegment", Spine_intersectsSegment);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "DragonBone");
		{
			tolua_function(L, "containsPoint", DragonBone_containsPoint);
			tolua_function(L, "intersectsSegment", DragonBone_intersectsSegment);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "DB");
		{
			tolua_function(L, "transaction", DB_transaction);
			tolua_function(L, "transactionAsync", DB_transactionAsync);
			tolua_function(L, "query", DB_query);
			tolua_function(L, "insert", DB_insert);
			tolua_function(L, "exec", DB_exec);
			tolua_function(L, "queryAsync", DB_queryAsync);
			tolua_function(L, "insertAsync", DB_insertAsync);
			tolua_function(L, "execAsync", DB_execAsync);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "HttpServer");
		{
			tolua_function(L, "post", HttpServer_post);
			tolua_function(L, "postSchedule", HttpServer_postSchedule);
			tolua_function(L, "upload", HttpServer_upload);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "ML");
		{
			tolua_beginmodule(L, "QLearner");
			{
				tolua_function(L, "pack", QLearner_pack);
				tolua_function(L, "unpack", QLearner_unpack);
				tolua_function(L, "load", QLearner_load);
				tolua_variable(L, "matrix", QLearner_getMatrix, nullptr);
			}
			tolua_endmodule(L);
		}
		tolua_endmodule(L);

		lua_getglobal(L, "package"); // builtin package
		lua_getfield(L, -1, "loaded"); // builtin package loaded
		lua_getfield(L, -1, "yue"); // builtin package loaded yue
		lua_setfield(L, -4, "yue"); // builtin["yue"] = yue, builtin package loaded
		lua_pop(L, 2);
		tolua_beginmodule(L, "yue");
		{
			tolua_function(L, "compile", dora_yue_compile);
			tolua_function(L, "check", dora_yue_check);
		}
		tolua_endmodule(L);

		tolua_module(L, "teal", 0);
		tolua_beginmodule(L, "teal");
		{
			tolua_function(L, "tolua", dora_teal_to_lua);
			tolua_function(L, "toluaAsync", dora_teal_to_lua_async);
			tolua_function(L, "reset", dora_reset_teal);
			tolua_function(L, "checkAsync", dora_teal_check_async);
			tolua_function(L, "completeAsync", dora_teal_complete_async);
			tolua_function(L, "inferAsync", dora_teal_infer_async);
		}
		tolua_endmodule(L);

		tolua_beginmodule(L, "Platformer");
		{
			tolua_beginmodule(L, "Behavior");
			{
				tolua_beginmodule(L, "Blackboard");
				{
					tolua_function(L, "set", Platformer::Blackboard_set);
					tolua_function(L, "get", Platformer::Blackboard_get);
				}
				tolua_endmodule(L);
			}
			tolua_endmodule(L);
		}
		tolua_endmodule(L);
	}
	tolua_endmodule(L); // stack: package.loaded

	tolua_setlightmetatable(L);

	// load binding codes
	tolua_LuaCode_open(L);

	lua_settop(L, 0); // clear stack
}

LuaEngine::~LuaEngine() {
	lua_close(L);
	L = nullptr;
	if (_tlState) {
		lua_close(_tlState->L);
		_tlState = nullptr;
	}
}

LuaEngine::TealState* LuaEngine::loadTealState() {
	if (!_tlState) {
		_tlState = New<LuaEngine::TealState>();
		lua_State* tl = luaL_newstate();
		_tlState->L = tl;
		_tlState->thread = SharedAsyncThread.newThread();
		int top = lua_gettop(tl);
		DEFER(lua_settop(tl, top));
		dora_load_base(tl);
		lua_gc(tl, LUA_GCGEN, 0, 0);
		lua_getglobal(tl, "package"); // package
		lua_getfield(tl, -1, "searchers"); // package, searchers
		lua_pushcfunction(tl, dora_loader); // package, searchers, loader
		lua_rawseti(tl, -2, 1); // searchers[1] = loader, package, searchers
		lua_pop(tl, 2); // clear
		tolua_TealCompiler_open(tl);
		lua_getglobal(tl, "package"); // package
		lua_pushliteral(tl, "path"); // package "path"
		lua_pushliteral(tl, "?.lua"); // package "path" "?.lua"
		lua_rawset(tl, -3); // package.path = "?.lua", package
		lua_getfield(tl, -1, "loaded"); // package loaded
		lua_getfield(tl, -1, "tl"); // package loaded tl
		lua_pushcfunction(tl, dora_file_exist);
		lua_setfield(tl, -2, "file_exist");
		lua_pushcfunction(tl, dora_read_file);
		lua_setfield(tl, -2, "read_file");
		lua_getfield(tl, -1, "dora_init"); // package loaded tl dora_init
		LuaEngine::call(tl, 0, 0);
	}
	return _tlState.get();
}

std::string LuaEngine::getTealVersion() {
	auto tlState = loadTealState();
	auto tl = tlState->L;
	auto thread = tlState->thread;
	std::string version;
	thread->pause();
	{
		int top = lua_gettop(tl);
		DEFER(lua_settop(tl, top));
		lua_getglobal(tl, "package"); // package
		lua_getfield(tl, -1, "loaded"); // package loaded
		lua_getfield(tl, -1, "tl"); // package loaded tl
		lua_getfield(tl, -1, "version"); // package loaded tl version
		LuaEngine::call(tl, 0, 1); // version(), package loaded tl res err
		version = tolua_toslice(tl, -1, nullptr);
	}
	thread->resume();
	return version;
}

static std::pair<std::string, std::string> compile_teal(lua_State* L, String tlCodes, String moduleName, bool mainThread) {
	int top = lua_gettop(L);
	DEFER(lua_settop(L, top));
	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "loaded"); // package loaded
	lua_getfield(L, -1, "tl"); // package loaded tl
	if (mainThread) {
		lua_pushcfunction(L, dora_read_file);
		lua_setfield(L, -2, "read_file");
	} else {
		lua_pushcfunction(L, dora_teal_threaded_read);
		lua_setfield(L, -2, "read_file");
	}
	lua_getfield(L, -1, "dora_to_lua"); // package loaded tl tolua
	tolua_pushslice(L, tlCodes); // package loaded tl tolua tlCodes
	tolua_pushslice(L, moduleName); // package loaded tl tolua tlCodes moduleName
	LuaEngine::call(L, 2, 2); // tolua(tlCodes, moduleName), package loaded tl res err
	if (lua_isnil(L, -2) != 0) {
		return {Slice::Empty, tolua_toslice(L, -1, nullptr)};
	} else {
		return {tolua_toslice(L, -2, nullptr), Slice::Empty};
	}
}

std::pair<std::string, std::string> LuaEngine::compileTealToLua(String tlCodes, String moduleName) {
	auto tlState = loadTealState();
	auto tl = tlState->L;
	auto thread = tlState->thread;
	thread->pause();
	auto res = compile_teal(tl, tlCodes, moduleName, false);
	thread->resume();
	return res;
}

void LuaEngine::compileTealToLuaAsync(String tlCodes, String moduleName, const std::function<void(std::pair<std::string, std::string>)>& callback) {
	auto tlState = loadTealState();
	auto tl = tlState->L;
	auto thread = tlState->thread;
	thread->run([tl, codes = tlCodes.toString(), name = moduleName.toString()]() {
		auto res = compile_teal(tl, codes, name, false);
		return Values::alloc(std::move(res)); },
		[callback](Own<Values> values) {
			std::pair<std::string, std::string> res;
			values->get(res);
			callback(res);
		});
}

static std::optional<std::list<LuaEngine::TealError>> check_teal_async(lua_State* L, String tlCodes, String moduleName, bool lax) {
	int top = lua_gettop(L);
	DEFER(lua_settop(L, top));
	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "loaded"); // package loaded
	lua_getfield(L, -1, "tl"); // package loaded tl
	lua_pushcfunction(L, dora_teal_threaded_read);
	lua_setfield(L, -2, "read_file");
	lua_getfield(L, -1, "dora_check"); // package loaded tl check
	tolua_pushslice(L, tlCodes); // package loaded tl check tlCodes
	tolua_pushslice(L, moduleName); // package loaded tl check tlCodes moduleName
	lua_pushboolean(L, lax ? 1 : 0); // package loaded tl check tlCodes moduleName lax
	LuaEngine::call(L, 3, 2); // check(tlCodes, moduleName, lax), package loaded tl res err
	if (lua_toboolean(L, -2) == 0) {
		std::list<LuaEngine::TealError> errors;
		if (lua_istable(L, -1) == 0) {
			errors = {{"crash", moduleName, 0, 0, ""}};
		} else {
			std::list<LuaEngine::TealError> errors;
			int tabIndex = lua_gettop(L);
			size_t len = lua_rawlen(L, tabIndex);
			for (size_t i = 0; i < len; i++) {
				lua_rawgeti(L, tabIndex, i + 1);
				lua_rawgeti(L, -1, 1);
				Slice type = tolua_toslice(L, -1, nullptr);
				lua_pop(L, 1);
				lua_rawgeti(L, -1, 2);
				Slice filename = tolua_toslice(L, -1, nullptr);
				lua_pop(L, 1);
				lua_rawgeti(L, -1, 3);
				int row = static_cast<int>(lua_tonumber(L, -1));
				lua_pop(L, 1);
				lua_rawgeti(L, -1, 4);
				int col = static_cast<int>(lua_tonumber(L, -1));
				lua_pop(L, 1);
				lua_rawgeti(L, -1, 5);
				Slice msg = tolua_toslice(L, -1, nullptr);
				lua_pop(L, 1);
				errors.push_back({type, filename, row, col, msg});
			}
		}
		return errors;
	}
	return std::nullopt;
}

void LuaEngine::checkTealAsync(String tlCodes, String moduleName, bool lax, const std::function<void(std::optional<std::list<LuaEngine::TealError>>)>& callback) {
	auto tlState = loadTealState();
	auto tl = tlState->L;
	auto thread = tlState->thread;
	thread->run([tl, codes = tlCodes.toString(), name = moduleName.toString(), lax]() {
		auto res = check_teal_async(tl, codes, name, lax);
		return Values::alloc(std::move(res)); },
		[callback](Own<Values> values) {
			std::optional<std::list<LuaEngine::TealError>> res;
			values->get(res);
			callback(res);
		});
}

static std::list<LuaEngine::TealToken> complete_teal_async(lua_State* L, String tlCodes, String line, int row) {
	int top = lua_gettop(L);
	DEFER(lua_settop(L, top));
	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "loaded"); // package loaded
	lua_getfield(L, -1, "tl"); // package loaded tl
	lua_pushcfunction(L, dora_teal_threaded_read);
	lua_setfield(L, -2, "read_file");
	lua_getfield(L, -1, "dora_complete"); // package loaded tl complete
	tolua_pushslice(L, tlCodes); // package loaded tl complete tlCodes
	tolua_pushslice(L, line); // package loaded tl complete tlCodes line
	lua_pushnumber(L, row); // package loaded tl complete tlCodes line row
	LuaEngine::call(L, 3, 1); // complete(tlCodes,line,row), package loaded tl res
	std::list<LuaEngine::TealToken> res;
	if (lua_istable(L, -1) != 0) {
		int len = static_cast<int>(lua_rawlen(L, -1));
		for (int i = 1; i <= len; i++) {
			lua_rawgeti(L, -1, i);
			lua_rawgeti(L, -1, 1);
			lua_rawgeti(L, -2, 2);
			lua_rawgeti(L, -3, 3);
			res.push_back({tolua_toslice(L, -3, nullptr),
				tolua_toslice(L, -2, nullptr),
				tolua_toslice(L, -1, nullptr)});
			lua_pop(L, 4);
		}
	}
	return res;
}

void LuaEngine::completeTealAsync(String tlCodes, String line, int row, const std::function<void(std::list<LuaEngine::TealToken>)>& callback) {
	auto tlState = loadTealState();
	auto tl = tlState->L;
	auto thread = tlState->thread;
	thread->run([tl, tlCodes = tlCodes.toString(), line = line.toString(), row]() {
		auto res = complete_teal_async(tl, tlCodes, line, row);
		return Values::alloc(std::move(res)); },
		[callback](Own<Values> values) {
			std::list<LuaEngine::TealToken> res;
			values->get(res);
			callback(res);
		});
}

static std::optional<LuaEngine::TealInference> infer_teal_async(lua_State* L, String tlCodes, String line, int row) {
	int top = lua_gettop(L);
	DEFER(lua_settop(L, top));
	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "loaded"); // package loaded
	lua_getfield(L, -1, "tl"); // package loaded tl
	lua_pushcfunction(L, dora_teal_threaded_read);
	lua_setfield(L, -2, "read_file");
	lua_getfield(L, -1, "dora_infer"); // package loaded tl infer
	tolua_pushslice(L, tlCodes); // package loaded tl infer tlCodes
	tolua_pushslice(L, line); // package loaded tl infer tlCodes line
	lua_pushnumber(L, row); // package loaded tl infer tlCodes line row
	LuaEngine::call(L, 3, 1); // infer(tlCodes,line,row), package loaded tl res
	std::optional<LuaEngine::TealInference> res;
	if (lua_istable(L, -1) != 0) {
		lua_getfield(L, -1, "str");
		lua_getfield(L, -2, "file");
		lua_getfield(L, -3, "y");
		lua_getfield(L, -4, "x");
		LuaEngine::TealInference res{"", "", 0, 0};
		res.desc = tolua_toslice(L, -4, nullptr);
		if (lua_isstring(L, -3) != 0) {
			res.file = tolua_toslice(L, -3, nullptr);
		}
		if (lua_isnumber(L, -2) != 0) {
			res.row = static_cast<int>(lua_tonumber(L, -2));
		}
		if (lua_isnumber(L, -1) != 0) {
			res.col = static_cast<int>(lua_tonumber(L, -1));
		}
		return res;
	}
	return std::nullopt;
}

void LuaEngine::inferTealAsync(String tlCodes, String line, int row, const std::function<void(std::optional<LuaEngine::TealInference>)>& callback) {
	auto tlState = loadTealState();
	auto tl = tlState->L;
	auto thread = tlState->thread;
	thread->run([tl, tlCodes = tlCodes.toString(), line = line.toString(), row]() {
		auto res = infer_teal_async(tl, tlCodes, line, row);
		return Values::alloc(std::move(res)); },
		[callback](Own<Values> values) {
			std::optional<LuaEngine::TealInference> res;
			values->get(res);
			callback(res);
		});
}

void LuaEngine::resetTealCompiler() {
	if (!_tlState) return;
	auto tl = _tlState->L;
	auto thread = _tlState->thread;
	thread->pause();
	{
		int top = lua_gettop(tl);
		DEFER(lua_settop(tl, top));
		lua_getglobal(tl, "package"); // package
		lua_getfield(tl, -1, "loaded"); // package loaded
		lua_getfield(tl, -1, "tl"); // package loaded tl
		lua_getfield(tl, -1, "dora_clear");
		LuaEngine::call(tl, 0, 0); // clear(), package loaded tl
	}
	thread->resume();
}

void LuaEngine::insertLuaLoader(lua_CFunction func, int index) {
	if (!func) return;
	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "searchers"); // package, searchers
	// insert searcher into index 1
	lua_pushcfunction(L, func); // package, searchers, func
	for (int i = s_cast<int>(lua_rawlen(L, -2)) + 1; i > index; --i) {
		lua_rawgeti(L, -2, i - 1); // package, searchers, func, function
		// we call lua_rawgeti, so the searchers table now is at -3
		lua_rawseti(L, -3, i); // package, searchers, func
	}
	lua_rawseti(L, -2, index); // searchers[1] = func, package searchers
	lua_pop(L, 2); // stack empty
}

void LuaEngine::removeScriptHandler(int handler) {
	tolua_remove_function_by_refid(L, handler);
}

void LuaEngine::removePeer(Object* object) {
	if (object->isLuaReferenced()) {
		int refid = object->getLuaRef();
		lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_UBOX); // ubox
		lua_rawgeti(L, -1, refid); // ubox ud
		if (!lua_toboolean(L, -1)) {
			lua_pushvalue(L, TOLUA_NOPEER); // ubox ud nopeer
			lua_setuservalue(L, -2); // ud<nopeer>, ubox ud
		}
		lua_pop(L, 2); // empty
	}
}

bool LuaEngine::executeString(const std::string& codes) {
	luaL_loadstring(L, codes.c_str());
	return LuaEngine::execute(L, 0);
}

bool LuaEngine::executeScriptFile(String filename) {
	int top = lua_gettop(L);
	DEFER(lua_settop(L, top));
	lua_getglobal(L, "dofile"); // file, dofile
	lua_pushlstring(L, filename.c_str(), filename.size());
	int result = LuaEngine::call(L, 1, 0); // dofile(file)
	return result != 0;
}

bool LuaEngine::executeModule(String module) {
	int top = lua_gettop(L);
	DEFER(lua_settop(L, top));
	lua_getglobal(L, "require"); // file, require
	lua_pushlstring(L, module.c_str(), module.size());
	int result = LuaEngine::call(L, 1, 0); // require(module)
	return result != 0;
}

void LuaEngine::pop(int count) {
	lua_pop(L, count);
}

void LuaEngine::push(Value* value) {
	if (value) {
		value->pushToLua(L);
	} else {
		lua_pushnil(L);
	}
}

void LuaEngine::push(String value) {
	lua_pushlstring(L, value.begin(), value.size());
}

void LuaEngine::push(const Vec2& value) {
	tolua_pushlight(L, value);
}

void LuaEngine::push(lua_State* L, Value* value) {
	if (value) {
		value->pushToLua(L);
	} else {
		lua_pushnil(L);
	}
}

void LuaEngine::push(lua_State* L, String value) {
	lua_pushlstring(L, value.begin(), value.size());
}

void LuaEngine::push(lua_State* L, const Vec2& value) {
	tolua_pushlight(L, value);
}

bool LuaEngine::to(bool& value, int index) {
	if (lua_isboolean(L, index)) {
		value = lua_toboolean(L, index) != 0;
		return true;
	}
	return false;
}

bool LuaEngine::to(std::string& value, int index) {
	if (lua_isstring(L, index)) {
		value = tolua_toslice(L, index, 0);
		return true;
	}
	return false;
}

bool LuaEngine::executeFunction(int handler, int paramCount) {
	return LuaEngine::execute(L, handler, paramCount);
}

void LuaEngine::executeReturn(LuaHandler*& luaHandler, int handler, int paramCount) {
	int top = lua_gettop(L);
	if (LuaEngine::invoke(L, handler, paramCount, 1)) {
		int funcRef = tolua_ref_function(L, -1);
		if (funcRef) {
			luaHandler = LuaHandler::create(funcRef);
		} else
			Error("Lua callback should return another function.");
	}
	lua_settop(L, top);
}

bool LuaEngine::isInLua() const {
	return _callFromLua > 0;
}

bool LuaEngine::scriptHandlerEqual(int handlerA, int handlerB) {
	tolua_get_function_by_refid(L, handlerA);
	tolua_get_function_by_refid(L, handlerB);
	int result = lua_rawequal(L, -1, -2);
	lua_pop(L, 2);
	return result != 0;
}

bool LuaEngine::call(lua_State* L, int paramCount, int returnCount) {
	int functionIndex = -(paramCount + 1);
#ifndef TOLUA_RELEASE
	int top = lua_gettop(L);
	int traceIndex = std::max(functionIndex + top, 1);
	int type = lua_type(L, functionIndex);
	switch (type) {
		case LUA_TFUNCTION: {
			lua_pushcfunction(L, dora_trace_back); // func args... traceback
			lua_insert(L, traceIndex); // traceback func args...

			++_callFromLua;
			int error = lua_pcall(L, paramCount, returnCount, traceIndex); // traceback error ret
			--_callFromLua;

			lua_remove(L, traceIndex);

			if (error) // traceback error
			{
				return false;
			}
			break;
		}
		case LUA_TTHREAD: {
			int nres = 0;
			lua_State* co = lua_tothread(L, functionIndex);
			lua_xmove(L, co, paramCount);
			lua_pop(L, 1);
			++_callFromLua;
			int res = lua_resume(co, nullptr, paramCount, &nres);
			--_callFromLua;
			if (res != LUA_OK && res != LUA_YIELD) {
				dora_trace_back(co);
				return false;
			} else
				lua_xmove(co, L, nres);
			break;
		}
		default:
			Error("[Lua] value at stack [{}] is not function or thread in LuaEngine::call", functionIndex);
			lua_pop(L, paramCount + 1); // remove function and arguments
			return false;
	}
#else
	int type = lua_type(L, functionIndex);
	switch (type) {
		case LUA_TFUNCTION: {
			lua_call(L, paramCount, returnCount);
			break;
		}
		case LUA_TTHREAD: {
			int nres = 0;
			lua_State* co = lua_tothread(L, functionIndex);
			lua_xmove(L, co, paramCount);
			lua_pop(L, 1);
			int res = lua_resume(co, nullptr, paramCount, &nres);
			if (res == LUA_OK || res == LUA_YIELD) {
				lua_xmove(co, L, nres);
			}
			break;
		}
	}
#endif
	return true;
}

bool LuaEngine::execute(lua_State* L, int numArgs) {
	bool result = false;
	int top = lua_gettop(L) - numArgs - 1;
	if (LuaEngine::call(L, numArgs, 1)) {
		switch (lua_type(L, -1)) {
			case LUA_TBOOLEAN:
				result = lua_toboolean(L, -1) != 0;
				break;
			case LUA_TNUMBER:
				result = lua_tonumber(L, -1) != 0;
				break;
		}
	} else
		result = true; // if function call fails, return true to stop schedule related functions
	lua_settop(L, top); // stack clear
	return result;
}

bool LuaEngine::execute(lua_State* L, int handler, int numArgs) {
	tolua_get_function_by_refid(L, handler); // args... func
	if (!tolua_isfunction(L, -1)) {
		Slice name = tolua_typename(L, -1);
		Error("[Lua] function refid '{}' referenced \"{}\" instead of lua function or thread.", handler, name);
		lua_pop(L, 2 + numArgs);
		return true;
	}
	if (numArgs > 0) lua_insert(L, -(numArgs + 1)); // func args...
	return LuaEngine::execute(L, numArgs);
}

bool LuaEngine::invoke(lua_State* L, int handler, int numArgs, int numRets) {
	tolua_get_function_by_refid(L, handler); // args... func
	if (!tolua_isfunction(L, -1)) {
		Slice name = tolua_typename(L, -1);
		Error("[Lua] function refid '{}' referenced \"{}\" instead of lua function or thread.", handler, name);
		lua_pop(L, 2 + numArgs);
		return 1;
	}
	if (numArgs > 0) lua_insert(L, -(numArgs + 1)); // func args...
	return LuaEngine::call(L, numArgs, numRets);
}

NS_DOROTHY_END
