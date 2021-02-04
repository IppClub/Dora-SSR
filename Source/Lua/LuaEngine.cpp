/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Lua/LuaEngine.h"
#include "Lua/LuaBinding.h"
#include "Lua/LuaManual.h"
#include "Lua/LuaHandler.h"
#include "Lua/LuaFromXml.h"
#include "Support/Value.h"
#include "Node/Node.h"
#include "Common/Async.h"
using namespace Dorothy::Platformer;

extern "C" {
int luaopen_yue(lua_State* L);
}

NS_DOROTHY_BEGIN

int LuaEngine::_callFromLua = 0;

static int dora_print(lua_State* L)
{
	int nargs = lua_gettop(L);
	lua_getglobal(L, "tostring");
	int funcIndex = lua_gettop(L);
	string t;
	for (int i = 1; i <= nargs; i++)
	{
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

static int dora_traceback(lua_State* L)
{
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

static int dora_loadfile(lua_State* L, String filename)
{
	AssertIf(filename.empty(), "passing empty filename string to lua loader.");
	string extension = Path::getExt(filename);
	string targetFile = filename;
	if (extension.empty() && targetFile.back() != '.')
	{
		string fullPath = SharedContent.getFullPath(targetFile + ".lua");
		if (SharedContent.isExist(fullPath))
		{
			targetFile = fullPath;
			extension = "lua";
		}
		else
		{
			fullPath = SharedContent.getFullPath(targetFile + ".xml");
			if (SharedContent.isExist(fullPath))
			{
				targetFile = fullPath;
				extension = "xml";
			}
			else
			{
				lua_pushnil(L);
				lua_pushfstring(L, "xml or lua file not found for filename \"%s\"", filename.toString().c_str());
				return 2;
			}
		}
	}

	const char* codeBuffer = nullptr;
	size_t codeBufferSize = 0;
	OwnArray<Uint8> buffer;
	string codes;
	switch (Switch::hash(extension))
	{
		case "xml"_hash:
		{
			codes = SharedXmlLoader.load(targetFile);
			if (codes.empty())
			{
				luaL_error(L, "error parsing xml file: %s\n%s", filename.toString().c_str(), SharedXmlLoader.getLastError().c_str());
			}
			else
			{
				codeBuffer = codes.c_str();
				codeBufferSize = codes.size();
			}
			break;
		}
		default:
		{
			auto data = SharedContent.loadFile(targetFile);
			buffer = std::move(data.first);
			codeBuffer = r_cast<char*>(buffer.get());
			codeBufferSize = data.second;
			break;
		}
	}

	if (codeBuffer)
	{
		if (luaL_loadbuffer(L, codeBuffer, codeBufferSize, filename.toString().c_str()) != 0)
		{
			luaL_error(L, "error loading module \"%s\" from file \"%s\" :\n\t%s",
				lua_tostring(L, 1), filename.toString().c_str(), lua_tostring(L, -1));
		}
	}
	else
	{
		luaL_error(L, "can not get data from file \"%s\"", filename.toString().c_str());
		return 2;
	}
	return 1;
}

static int dora_loadfile(lua_State* L)
{
	size_t size = 0;
	const char* str = luaL_checklstring(L, 1, &size);
	Slice filename(str, size);
	return dora_loadfile(L, filename);
}

static int dora_dofile(lua_State* L)
{
	size_t size = 0;
	const char* str = luaL_checklstring(L, 1, &size);
	Slice filename(str, size);
	dora_loadfile(L, filename);
	if (lua_isnil(L, -2) && lua_isstring(L, -1))
	{
		luaL_error(L, lua_tostring(L, -1));
	}
	int top = lua_gettop(L) - 1;
	LuaEngine::call(L, 0, LUA_MULTRET);
	int newTop = lua_gettop(L);
	return newTop - top;
}

static int dora_loader(lua_State* L)
{
	size_t size = 0;
	const char* str = luaL_checklstring(L, 1, &size);
	Slice filename(str, size);
	bool convertToPath = true;
	for (auto ch : filename)
	{
		if (ch == '\\' || ch == '/')
		{
			convertToPath = false;
			break;
		}
	}
	if (convertToPath)
	{
		auto tokens = filename.split("."_slice);
		auto file = Path::concat(tokens);
		return dora_loadfile(L, file);
	}
	return dora_loadfile(L, filename);
}

static int dora_doxml(lua_State* L)
{
	string codes(luaL_checkstring(L, 1));
	codes = SharedXmlLoader.load(codes);
	if (codes.empty())
	{
		luaL_error(L, "error parsing local xml, %s\n", SharedXmlLoader.getLastError().c_str());
	}
	if (luaL_loadbuffer(L, codes.c_str(), codes.size(), "xml") != 0)
	{
		Error("[Lua] {}", codes);
		luaL_error(L, "error loading module %s from file %s :\n\t%s",
			lua_tostring(L, 1), "xml", lua_tostring(L, -1));
	}
	int top = lua_gettop(L) - 1;
	LuaEngine::call(L, 0, LUA_MULTRET);
	int newTop = lua_gettop(L);
	return newTop - top;
}

static int dora_xmltolua(lua_State* L)
{
	string codes(luaL_checkstring(L, 1));
	codes = SharedXmlLoader.loadXml(codes);
	if (codes.empty())
	{
		const string& lastError = SharedXmlLoader.getLastError();
		lua_pushnil(L);
		lua_pushlstring(L, lastError.c_str(), lastError.size());
		return 2;
	}
	lua_pushlstring(L, codes.c_str(), codes.size());
	return 1;
}

static int dora_file_exist(lua_State* L)
{
	size_t size = 0;
	auto str = luaL_checklstring(L, 1, &size);
	lua_pushboolean(L, SharedContent.isExist({ str, size }) ? 1 : 0);
	return 1;
}

static int dora_read_file(lua_State* L)
{
	size_t size = 0;
	auto str = luaL_checklstring(L, 1, &size);
	auto data = SharedContent.loadFile({ str, size });
	lua_pushlstring(L, r_cast<char*>(data.first.get()), data.second);
	return 1;
}

static int dora_loadlibs(lua_State* L)
{
	const luaL_Reg lualibs[] =
	{
		{ LUA_GNAME, luaopen_base },
		{ LUA_LOADLIBNAME, luaopen_package },
		{ LUA_COLIBNAME, luaopen_coroutine },
		{ LUA_TABLIBNAME, luaopen_table },
		{ LUA_STRLIBNAME, luaopen_string },
		{ LUA_MATHLIBNAME, luaopen_math },
		{ LUA_UTF8LIBNAME, luaopen_utf8 },
		{ LUA_DBLIBNAME, luaopen_debug },
		{ NULL, NULL}
	};
	for (const luaL_Reg* lib = lualibs; lib->func; lib++)
	{
		luaL_requiref(L, lib->name, lib->func, 1);
		lua_pop(L, 1);
	}
	lua_pushcfunction(L, luaopen_yue);
	if (lua_pcall(L, 0, 0, 0) != 0) {
		string err = lua_tostring(L, -1);
		lua_pop(L, 1);
		Error("failed to open lib yue.\n{}", err);
	}
	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "loaded"); // package loaded
	lua_getfield(L, -1, "yue"); // package loaded yue
	lua_pushcfunction(L, dora_file_exist);
	lua_setfield(L, -2, "file_exist");
	lua_pushcfunction(L, dora_read_file);
	lua_setfield(L, -2, "read_file");
	lua_pop(L, 3);
	return 0;
}

static void dora_open_compiler(void* state)
{
	lua_State* L = s_cast<lua_State*>(state);
	dora_loadlibs(L);
	const luaL_Reg global_functions[] =
	{
		{ "print", dora_print },
		{ NULL, NULL }
	};
	lua_pushglobaltable(L);
	luaL_setfuncs(L, global_functions, 0);
	lua_pop(L, 1);

	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "loaded"); // package loaded
	lua_getfield(L, -1, "yue"); // package loaded yue
	lua_pushcfunction(L, dora_file_exist);
	lua_setfield(L, -2, "file_exist");
	lua_pushcfunction(L, dora_read_file);
	lua_setfield(L, -2, "read_file");
	lua_pop(L, 3);
}

static int dora_yuecompile(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(L, 1, 0, &tolua_err) ||
		!tolua_isstring(L, 2, 0, &tolua_err) ||
		!tolua_isfunction(L, 3, &tolua_err) ||
		!tolua_isfunction(L, 4, &tolua_err) ||
		!tolua_isnoobj(L, 5, &tolua_err))
	{
		goto tolua_lerror;
	}
	else
#endif
	{
		string src = tolua_toslice(L, 1, 0);
		string dest = tolua_toslice(L, 2, 0);
		Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 3)));
		LuaFunction<void> callback(tolua_ref_function(L, 4));
		SharedContent.loadFileAsyncData(src, [src,dest,handler,callback](OwnArray<Uint8>&& codes, size_t size)
		{
			if (!codes)
			{
				Warn("failed to get yue source codes from \"{}\".", src);
			}
			else
			{
				auto input = std::make_shared<std::tuple<
					string, string, OwnArray<Uint8>, size_t>>(
					src, dest, std::move(codes), size);
				SharedAsyncThread.run([input]()
				{
					yue::YueConfig config;
					config.implicitReturnRoot = true;
					config.reserveLineNumber = true;
					config.lintGlobalVariable = true;
					size_t size = std::get<3>(*input);
					const auto& codes = std::get<2>(*input);
					auto result = yue::YueCompiler{nullptr, dora_open_compiler}.compile({r_cast<char*>(codes.get()), size}, config);
					return Values::create(std::move(result));
				}, [input, handler, callback](Own<Values> values)
				{
					yue::CompileInfo result;
					values->get(result);
					lua_State* L = SharedLuaEngine.getState();
					int top = lua_gettop(L);
					if (result.codes.empty())
					{
						lua_pushnil(L);
						lua_pushlstring(L, result.error.c_str(), result.error.size());
					}
					else
					{
						lua_pushlstring(L, result.codes.c_str(), result.codes.size());
						lua_pushnil(L);
					}
					if (result.globals)
					{
						lua_createtable(L, s_cast<int>(result.globals->size()), 0);
						int i = 1;
						for (const auto& var : *result.globals)
						{
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
					}
					else lua_pushnil(L);
					string ret;
					SharedLuaEngine.executeReturn(ret, handler->get(), 3);
					lua_settop(L, top);
					if (!ret.empty()) {
						SharedContent.saveToFileAsync(std::get<1>(*input), ret, callback);
					}
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

static int dora_ubox(lua_State* L)
{
	lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_UBOX); // ubox
	return 1;
}

lua_State* LuaEngine::getState() const
{
	return L;
}

yue::YueCompiler& LuaEngine::getYue()
{
	if (!_yueCompiler)
	{
		_yueCompiler = New<yue::YueCompiler>(L);
	}
	return *_yueCompiler;
}

LuaEngine::LuaEngine()
{
	L = luaL_newstate();
	dora_loadlibs(L);
	tolua_open(L);

	// Register our version of the global "print" function
	const luaL_Reg global_functions[] =
	{
		{ "print", dora_print },
		{ "loadfile", dora_loadfile },
		{ "dofile", dora_dofile },
		{ "doxml", dora_doxml },
		{ "xmltolua", dora_xmltolua },
		{ "yuecompile", dora_yuecompile },
		{ "ubox", dora_ubox },
		{ "emit", dora_emit },
		{ NULL, NULL }
	};
	lua_pushglobaltable(L);
	luaL_setfuncs(L, global_functions, 0);
	lua_pop(L, 1);

	// add dorothy loader
	LuaEngine::insertLuaLoader(dora_loader);

	// load cpp binding
	tolua_LuaBinding_open(L);

	// add manual binding
	tolua_beginmodule(L, nullptr); // stack: package.loaded
		tolua_beginmodule(L, "Path");
			tolua_call(L, MT_CALL, Path_create);
		tolua_endmodule(L);

		tolua_beginmodule(L, "Content");
			tolua_variable(L, "searchPaths", Content_GetSearchPaths, Content_SetSearchPaths);
		tolua_endmodule(L);

		tolua_beginmodule(L, "Node");
			tolua_function(L, "gslot", Node_gslot);
			tolua_function(L, "slot", Node_slot);
			tolua_function(L, "emit", Node_emit);
		tolua_endmodule(L);

		tolua_beginmodule(L, "Action");
			tolua_call(L, MT_CALL, Action_create);
		tolua_endmodule(L);

		tolua_beginmodule(L, "Dictionary");
			tolua_function(L, "set", Dictionary_set);
			tolua_function(L, "get", Dictionary_get);
		tolua_endmodule(L);

		tolua_beginmodule(L, "Array");
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
		tolua_endmodule(L);

		tolua_beginmodule(L, "Entity");
			tolua_function(L, "set", Entity_set);
			tolua_function(L, "setNext", Entity_setNext);
			tolua_function(L, "get", Entity_get);
			tolua_function(L, "getOld", Entity_getOld);
		tolua_endmodule(L);

		tolua_beginmodule(L, "BodyDef");
			tolua_variable(L, "type", BodyDef_GetType, BodyDef_SetType);
		tolua_endmodule(L);

		tolua_beginmodule(L, "Sprite");
			tolua_variable(L, "uwrap", Sprite_GetUWrap, Sprite_SetUWrap);
			tolua_variable(L, "vwrap", Sprite_GetVWrap, Sprite_SetVWrap);
			tolua_variable(L, "filter", Sprite_GetTextureFilter, Sprite_SetTextureFilter);
		tolua_endmodule(L);

		tolua_beginmodule(L, "Label");
			tolua_variable(L, "alignment", Label_GetTextAlign, Label_SetTextAlign);
		tolua_endmodule(L);

	tolua_endmodule(L);

	// load binding codes
	tolua_LuaCode_open(L);

	lua_settop(L, 0); // clear stack
}

LuaEngine::~LuaEngine()
{
	lua_close(L);
}

void LuaEngine::insertLuaLoader(lua_CFunction func)
{
	if (!func) return;
	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "searchers"); // package, searchers
	// insert searcher into index 1
	lua_pushcfunction(L, func); // package, searchers, func
	for (int i = s_cast<int>(lua_rawlen(L, -2)) + 1; i > 1; --i)
	{
		lua_rawgeti(L, -2, i - 1); // package, searchers, func, function
		// we call lua_rawgeti, so the searchers table now is at -3
		lua_rawseti(L, -3, i); // package, searchers, func
	}
	lua_rawseti(L, -2, 1); // searchers[1] = func, package searchers
	lua_pop(L, 2); // stack empty
}

void LuaEngine::removeScriptHandler(int handler)
{
	tolua_remove_function_by_refid(L, handler);
}

void LuaEngine::removePeer(Object* object)
{
	if (object->isLuaReferenced())
	{
		int refid = object->getLuaRef();
		lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_UBOX); // ubox
		lua_rawgeti(L, -1, refid); // ubox ud
		if (!lua_toboolean(L, -1))
		{
			lua_pushvalue(L, TOLUA_NOPEER); // ubox ud nopeer
			lua_setuservalue(L, -2); // ud<nopeer>, ubox ud
		}
		lua_pop(L, 2); // empty
	}
}

bool LuaEngine::executeString(String codes)
{
	luaL_loadstring(L, codes.toString().c_str());
	return LuaEngine::execute(L, 0);
}

bool LuaEngine::executeScriptFile(String filename)
{
	int top = lua_gettop(L);
	lua_getglobal(L, "dofile"); // file, dofile
	lua_pushlstring(L, filename.toString().c_str(), filename.size());
	int result = LuaEngine::call(L, 1, LUA_MULTRET); // dofile(file)
	lua_settop(L, top);
	return result;
}

void LuaEngine::pop(int count)
{
	lua_pop(L, count);
}

void LuaEngine::push(bool value)
{
	lua_pushboolean(L, value ? 1 : 0);
}

void LuaEngine::push(int value)
{
	lua_pushinteger(L, s_cast<lua_Integer>(value));
}

void LuaEngine::push(Uint16 value)
{
	lua_pushinteger(L, s_cast<lua_Integer>(value));
}

void LuaEngine::push(lua_Integer value)
{
	lua_pushinteger(L, s_cast<lua_Integer>(value));
}

void LuaEngine::push(float value)
{
	lua_pushnumber(L, s_cast<lua_Number>(value));
}

void LuaEngine::push(lua_Number value)
{
	lua_pushnumber(L, s_cast<lua_Number>(value));
}

void LuaEngine::push(Value* value)
{
	if (value)
	{
		value->pushToLua(L);
	}
	else
	{
		lua_pushnil(L);
	}
}

void LuaEngine::push(Object* value)
{
	tolua_pushobject(L, value);
}

void LuaEngine::push(String value)
{
	lua_pushlstring(L, value.begin(), value.size());
}

void LuaEngine::push(const string& value)
{
	lua_pushlstring(L, value.c_str(), value.size());
}

void LuaEngine::push(std::nullptr_t)
{
	lua_pushnil(L);
}

void LuaEngine::push(lua_State* L, bool value)
{
	lua_pushboolean(L, value ? 1 : 0);
}

void LuaEngine::push(lua_State* L, int value)
{
	lua_pushinteger(L, s_cast<lua_Integer>(value));
}

void LuaEngine::push(lua_State* L, Uint16 value)
{
	lua_pushinteger(L, s_cast<lua_Integer>(value));
}

void LuaEngine::push(lua_State* L, lua_Integer value)
{
	lua_pushinteger(L, s_cast<lua_Integer>(value));
}

void LuaEngine::push(lua_State* L, float value)
{
	lua_pushnumber(L, s_cast<lua_Number>(value));
}

void LuaEngine::push(lua_State* L, lua_Number value)
{
	lua_pushnumber(L, s_cast<lua_Number>(value));
}

void LuaEngine::push(lua_State* L, Value* value)
{
	if (value)
	{
		value->pushToLua(L);
	}
	else
	{
		lua_pushnil(L);
	}
}

void LuaEngine::push(lua_State* L, Object* value)
{
	tolua_pushobject(L, value);
}

void LuaEngine::push(lua_State* L, String value)
{
	lua_pushlstring(L, value.begin(), value.size());
}

void LuaEngine::push(lua_State* L, const string& value)
{
	lua_pushlstring(L, value.c_str(), value.size());
}

void LuaEngine::push(lua_State* L, std::nullptr_t)
{
	lua_pushnil(L);
}

bool LuaEngine::to(bool& value, int index)
{
	if (lua_isboolean(L, index))
	{
		value = lua_toboolean(L, index) != 0;
		return true;
	}
	return false;
}

bool LuaEngine::to(int& value, int index)
{
	if (lua_isnumber(L, index))
	{
		value = s_cast<int>(lua_tonumber(L, index));
		return true;
	}
	return false;
}

bool LuaEngine::to(Uint16& value, int index)
{
	if (lua_isinteger(L, index))
	{
		value = s_cast<Uint16>(lua_tointeger(L, index));
		return true;
	}
	return false;
}

bool LuaEngine::to(Sint64& value, int index)
{
	if (lua_isinteger(L, index))
	{
		value = s_cast<Sint64>(lua_tointeger(L, index));
		return true;
	}
	return false;
}

bool LuaEngine::to(float& value, int index)
{
	if (lua_isnumber(L, index))
	{
		value = s_cast<float>(lua_tonumber(L, index));
		return true;
	}
	return false;
}

bool LuaEngine::to(double& value, int index)
{
	if (lua_isnumber(L, index))
	{
		value = lua_tonumber(L, index);
		return true;
	}
	return false;
}

bool LuaEngine::to(Object*& value, int index)
{
	if (tolua_isobject(L, index))
	{
		value = r_cast<Object*>(tolua_tousertype(L, index, nullptr));
		return true;
	}
	return false;
}

bool LuaEngine::to(string& value, int index)
{
	if (lua_isstring(L, index))
	{
		value = tolua_toslice(L, index, 0);
		return true;
	}
	return false;
}

bool LuaEngine::executeFunction(int handler, int paramCount)
{
	return LuaEngine::execute(L, handler, paramCount);
}

void LuaEngine::executeReturn(LuaHandler*& luaHandler, int handler, int paramCount)
{
	int top = lua_gettop(L);
	if (LuaEngine::invoke(L, handler, paramCount, 1))
	{
		int funcRef = tolua_ref_function(L, -1);
		if (funcRef)
		{
			luaHandler = LuaHandler::create(funcRef);
		}
		else Error("Lua callback should return another function.");
	}
	lua_settop(L, top);
}

bool LuaEngine::isInLua() const
{
	return _callFromLua > 0;
}

bool LuaEngine::scriptHandlerEqual(int handlerA, int handlerB)
{
	tolua_get_function_by_refid(L, handlerA);
	tolua_get_function_by_refid(L, handlerB);
	int result = lua_rawequal(L, -1, -2);
	lua_pop(L, 2);
	return result != 0;
}

bool LuaEngine::call(lua_State* L, int paramCount, int returnCount)
{
	int functionIndex = -(paramCount + 1);
#ifndef TOLUA_RELEASE
	int top = lua_gettop(L);
	int traceIndex = std::max(functionIndex + top, 1);
	int type = lua_type(L, functionIndex);
	switch (type)
	{
		case LUA_TFUNCTION:
		{
			lua_pushcfunction(L, dora_traceback); // func args... traceback
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
		case LUA_TTHREAD:
		{
			int nres = 0;
			lua_State* co = lua_tothread(L, functionIndex);
			lua_xmove(L, co, paramCount);
			lua_pop(L, 1);
			++_callFromLua;
			int res = lua_resume(co, nullptr, paramCount, &nres);
			--_callFromLua;
			if (res != LUA_OK && res != LUA_YIELD)
			{
				dora_traceback(co);
				return false;
			}
			else lua_xmove(co, L, nres);
			break;
		}
		default:
			Error("[Lua] value at stack [{}] is not function or thread in LuaEngine::call", functionIndex);
			lua_pop(L, paramCount + 1); // remove function and arguments
			return false;
	}
#else
	int type = lua_type(L, functionIndex);
	switch (type)
	{
		case LUA_TFUNCTION:
		{
			lua_call(L, paramCount, returnCount);
			break;
		}
		case LUA_TTHREAD:
		{
			int nres = 0;
			lua_State* co = lua_tothread(L, functionIndex);
			lua_xmove(L, co, paramCount);
			lua_pop(L, 1);
			int res = lua_resume(co, nullptr, paramCount, &nres);
			if (res == LUA_OK || res == LUA_YIELD)
			{
				lua_xmove(co, L, nres);
			}
			break;
		}
	}
#endif
	return true;
}

bool LuaEngine::execute(lua_State* L, int numArgs)
{
	bool result = false;
	int top = lua_gettop(L) - numArgs - 1;
	if (LuaEngine::call(L, numArgs, 1))
	{
		switch (lua_type(L, -1))
		{
			case LUA_TBOOLEAN:
				result = lua_toboolean(L, -1) != 0;
				break;
			case LUA_TNUMBER:
				result = lua_tonumber(L, -1) != 0;
				break;
		}
	}
	else result = true; // if function call fails, return true to stop schedule related functions
	lua_settop(L, top); // stack clear
	return result;
}

bool LuaEngine::execute(lua_State* L, int handler, int numArgs)
{
	tolua_get_function_by_refid(L, handler); // args... func
	if (!tolua_isfunction(L, -1))
	{
		Slice name = tolua_typename(L, -1);
		Error("[Lua] function refid '{}' referenced \"{}\" instead of lua function or thread.", handler, name);
		lua_pop(L, 2 + numArgs);
		return 1;
	}
	if (numArgs > 0) lua_insert(L, -(numArgs + 1)); // func args...
	return LuaEngine::execute(L, numArgs);
}

bool LuaEngine::invoke(lua_State* L, int handler, int numArgs, int numRets)
{
	tolua_get_function_by_refid(L, handler); // args... func
	if (!tolua_isfunction(L, -1))
	{
		Slice name = tolua_typename(L, -1);
		Error("[Lua] function refid '{}' referenced \"{}\" instead of lua function or thread.", handler, name);
		lua_pop(L, 2 + numArgs);
		return 1;
	}
	if (numArgs > 0) lua_insert(L, -(numArgs + 1)); // func args...
	return LuaEngine::call(L, numArgs, numRets);
}

NS_DOROTHY_END
