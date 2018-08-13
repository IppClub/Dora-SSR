/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Lua/LuaEngine.h"
#include "Lua/LuaBinding.h"
#include "Lua/LuaManual.h"
#include "Lua/LuaFromXml.h"
#include "Support/Value.h"

extern int luaopen_lpeg(lua_State* L);

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
	lua_call(L, 1, 1); // traceback(err), err debug tace
	LogPrint(tolua_toslice(L, -1, nullptr).toString());
	lua_pop(L, 3); // empty
	return 0;
}

static int dora_loadfile(lua_State* L, String filename)
{
	AssertIf(filename.empty(), "passing empty filename string to lua loader.");
	string extension = filename.getFileExtension();
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
	Sint64 codeBufferSize = 0;
	OwnArray<Uint8> buffer;
	string codes;
	switch (Switch::hash(extension))
	{
		case "xml"_hash:
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
		default:
			buffer = SharedContent.loadFile(targetFile);
			codeBuffer = r_cast<char*>(buffer.get());
			codeBufferSize = buffer.size();
			break;
	}

	if (codeBuffer)
	{
		if (luaL_loadbuffer(L, codeBuffer, s_cast<size_t>(codeBufferSize), filename.toString().c_str()) != 0)
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
	string filename(luaL_checkstring(L, 1));
	return dora_loadfile(L, filename);
}

static int dora_dofile(lua_State* L)
{
	string filename(luaL_checkstring(L, 1));
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
	string filename(luaL_checkstring(L, 1));
	size_t pos = 0;
	while ((pos = filename.find('.', pos)) != string::npos)
	{
		filename[pos] = '/';
	}
	return dora_loadfile(L, filename);
}

static int dora_doxml(lua_State* L)
{
	string codes(luaL_checkstring(L, 1));
	codes = SharedXmlLoader.load(codes);
	if (codes.empty())
	{
		luaL_error(L, "error parsing local xml\n");
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

static int dora_ubox(lua_State* L)
{
	lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_UBOX); // ubox
	return 1;
}

static int dora_loadlibs(lua_State* L)
{
	const luaL_Reg lualibs[] =
	{
		{ "", luaopen_base },
		{ LUA_LOADLIBNAME, luaopen_package },
		{ LUA_TABLIBNAME, luaopen_table },
		{ LUA_STRLIBNAME, luaopen_string },
		{ LUA_MATHLIBNAME, luaopen_math },
		{ LUA_DBLIBNAME, luaopen_debug },
		{ NULL, NULL }
	};
	for (const luaL_Reg* lib = lualibs; lib->func; lib++)
	{
		lua_pushcfunction(L, lib->func);
		lua_pushstring(L, lib->name);
		lua_call(L, 1, 0);
	}
	return 1;
}

lua_State* LuaEngine::getState() const
{
	return L;
}

LuaEngine::LuaEngine()
{
	L = luaL_newstate();
	dora_loadlibs(L);
	luaopen_lpeg(L);
	tolua_open(L);

	// Register our version of the global "print" function
	const luaL_reg global_functions[] =
	{
		{ "print", dora_print },
		{ "loadfile", dora_loadfile },
		{ "dofile", dora_dofile },
		{ "doxml", dora_doxml },
		{ "xmltolua", dora_xmltolua },
		{ "ubox", dora_ubox },
		{ "emit", dora_emit },
		{ NULL, NULL }
	};
	luaL_register(L, "_G", global_functions);

	// add dorothy loader
	LuaEngine::insertLuaLoader(dora_loader);

	// load cpp binding
	tolua_LuaBinding_open(L);

	// add manual binding
	tolua_beginmodule(L, nullptr); // stack: package.loaded
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

		tolua_beginmodule(L, "Entity");
			tolua_function(L, "set", Entity_set);
			tolua_function(L, "nextSet", Entity_setNext);
			tolua_function(L, "get", Entity_get);
			tolua_function(L, "getCache", Entity_getCache);
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
	lua_getfield(L, -1, "loaders"); // package loaders
	// insert loader into index 1
	lua_pushcfunction(L, func); // package loaders func
	for (int i = s_cast<int>(lua_objlen(L, -2)) + 1; i > 1; --i)
	{
		lua_rawgeti(L, -2, i - 1); // package loaders func function
		// we call lua_rawgeti, so the loader table now is at -3
		lua_rawseti(L, -3, i); // package loaders func
	}
	lua_rawseti(L, -2, 1); // loaders[1] = func, package loaders
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
			lua_setfenv(L, -2); // ud<nopeer>, ubox ud
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

void LuaEngine::push(Uint16 value)
{
	lua_pushinteger(L, s_cast<lua_Integer>(value));
}

void LuaEngine::push(int value)
{
	lua_pushinteger(L, s_cast<lua_Integer>(value));
}

void LuaEngine::push(float value)
{
	lua_pushnumber(L, s_cast<lua_Number>(value));
}

void LuaEngine::push(double value)
{
	lua_pushnumber(L, s_cast<lua_Number>(value));
}

void LuaEngine::push(Value* value)
{
	if (value)
	{
		value->pushToLua();
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

void LuaEngine::push(Ref<> value)
{
	tolua_pushobject(L, value);
}

void LuaEngine::push(String value)
{
	lua_pushlstring(L, value.rawData(), value.size());
}

void LuaEngine::push(std::nullptr_t)
{
	lua_pushnil(L);
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

bool LuaEngine::to(Slice& value, int index)
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

int LuaEngine::executeReturnFunction(int handler, int paramCount)
{
	LuaEngine::invoke(L, handler, paramCount, 1);
	int funcHandler = tolua_ref_function(L, -1);
	lua_pop(L, 1);
	return funcHandler;
}

bool LuaEngine::executeAssert(bool cond, String msg)
{
	if (_callFromLua == 0)
	{
		return false;
	}
	luaL_error(L, "assert failed with C++ condition: %s", msg.empty() ? "unknown" : msg.toString().c_str());
	return true;
}

bool LuaEngine::scriptHandlerEqual(int handlerA, int handlerB)
{
	tolua_get_function_by_refid(L, handlerA);
	tolua_get_function_by_refid(L, handlerB);
	int result = lua_equal(L, -1, -2);
	lua_pop(L, 2);
	return result != 0;
}

bool LuaEngine::call(lua_State* L, int paramCount, int returnCount)
{
#ifndef TOLUA_RELEASE
	int functionIndex = -(paramCount + 1);
	int top = lua_gettop(L);
	int traceIndex = std::max(functionIndex + top, 1);
	if (!lua_isfunction(L, functionIndex))
	{
		Error("[Lua] value at stack [{}] is not function in LuaEngine::call", functionIndex);
		lua_pop(L, paramCount + 1); // remove function and arguments
		return false;
	}

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
#else
	lua_call(L, paramCount, returnCount);
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
	if (!lua_isfunction(L, -1))
	{
		Slice name = tolua_typename(L, -1);
		Error("[Lua] function refid '{}' referenced \"{}\" instead of lua function.", handler, name);
		lua_pop(L, 2 + numArgs);
		return 1;
	}
	if (numArgs > 0) lua_insert(L, -(numArgs + 1)); // func args...
	return LuaEngine::execute(L, numArgs);
}

bool LuaEngine::invoke(lua_State* L, int handler, int numArgs, int numRets)
{
	tolua_get_function_by_refid(L, handler); // args... func
	if (!lua_isfunction(L, -1))
	{
		Slice name = tolua_typename(L, -1);
		Error("[Lua] function refid '{}' referenced \"{}\" instead of lua function.", handler, name);
		lua_pop(L, 2 + numArgs);
		return 1;
	}
	if (numArgs > 0) lua_insert(L, -(numArgs + 1)); // func args...
	return LuaEngine::call(L, numArgs, numRets);
}

NS_DOROTHY_END
