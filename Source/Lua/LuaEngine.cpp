/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Lua/LuaEngine.h"
#include "Lua/LuaBinding.h"

NS_DOROTHY_BEGIN

int LuaEngine::_callFromLua = 0;

static int dora_print(lua_State* L)
{
	int nargs = lua_gettop(L);
	string t;
	for (int i = 1; i <= nargs; i++)
	{
		if (lua_isnone(L, i)) t += "none";
		else if (lua_isnil(L, i)) t += "nil";
		else if (lua_isboolean(L, i))
		{
			if (lua_toboolean(L, i) != 0) t += "true";
			else t += "false";
		}
		else if (lua_isfunction(L, i)) t += "function";
		else if (lua_islightuserdata(L, i)) t += "lightuserdata";
		else if (lua_isthread(L, i)) t += "thread";
		else
		{
			const char* str = lua_tostring(L, i);
			if (str) t += lua_tostring(L, i);
			else t += tolua_typename(L, i);
		}
		if (i != nargs) t += "\t";
	}
	Print("%s\n", t);
	return 0;
}

static int dora_traceback(lua_State* L)
{
	// -1 error_string
	lua_getglobal(L, "debug"); // err debug
	lua_getfield(L, -1, "traceback"); // err debug traceback
	lua_pushvalue(L, -3); // err debug traceback err
	lua_call(L, 1, 1); // traceback(err), err debug tace
	Print(lua_tostring(L, -1));
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
		if (SharedContent.isFileExist(targetFile + ".lua"))
		{
			targetFile.append(".lua");
		}
		else
		{
			if (SharedContent.isFileExist(targetFile + ".xml"))
			{
				targetFile.append(".xml");
				extension = "xml";
			}
			else
			{
				lua_pushnil(L);
				lua_pushfstring(L, "xml or lua file not found for filename \"%s\"", filename.c_str());
				return 2;
			}
		}
	}

	Sint64 codeBufferSize = 0;
	OwnArray<Uint8> buffer;
	const char* codeBuffer = nullptr;
	string codes;
	SWITCH_STR_START(extension)
	{
		CASE_STR(xml)
		{
			//codes = oSharedXMLLoader.load(filename.c_str());
			if (codes.empty())
			{
				//luaL_error(L, "error parsing xml file: %s\n%s", filename.c_str(), oSharedXMLLoader.getLastError().c_str());
			}
			else
			{
				codeBuffer = codes.c_str();
				codeBufferSize = codes.size();
			}
			break;
		}
		CASE_DEFAULT
		{
			buffer = SharedContent.loadFile(targetFile, codeBufferSize);
			codeBuffer = (const char*)buffer.get();
			break;
		}
	}
	SWITCH_STR_END

	if (codeBuffer)
	{
		if (luaL_loadbuffer(L, codeBuffer, (size_t)codeBufferSize, filename.c_str()) != 0)
		{
			luaL_error(L, "error loading module \"%s\" from file \"%s\" :\n\t%s",
				lua_tostring(L, 1), filename.c_str(), lua_tostring(L, -1));
		}
	}
	else
	{
		luaL_error(L, "can not get data from file \"%s\"", filename.c_str());
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

/*
static int cclua_doXml(lua_State* L)
{
	string codes(luaL_checkstring(L, 1));
	codes = oSharedXMLLoader.load(codes);
	if (codes.empty())
	{
		luaL_error(L, "error parsing local xml\n");
	}
	if (luaL_loadbuffer(L, codes.c_str(), codes.size(), "xml") != 0)
	{
		CCLOG("%s", codes.c_str());
		luaL_error(L, "error loading module %s from file %s :\n\t%s",
			lua_tostring(L, 1), "xml", lua_tostring(L, -1));
	}
	int top = lua_gettop(L) - 1;
	CCLuaEngine::call(L, 0, LUA_MULTRET);
	int newTop = lua_gettop(L);
	return newTop - top;
}

static int cclua_xmlToLua(lua_State* L)
{
	string codes(luaL_checkstring(L, 1));
	codes = oSharedXMLLoader.load(codes);
	if (codes.empty())
	{
		luaL_error(L, oSharedXMLLoader.getLastError().c_str());
	}
	lua_pushlstring(L, codes.c_str(), codes.size());
	return 1;
}
*/

static int dora_ubox(lua_State* L)
{
	lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_UBOX); // ubox
	return 1;
}

static int dora_loadlibs(lua_State* L)
{
	const luaL_Reg lualibs[] =
	{
		{ "", luaopen_base },
		{ LUA_LOADLIBNAME, luaopen_package },
		{ LUA_TABLIBNAME, luaopen_table },
		{ LUA_IOLIBNAME, luaopen_io },
		{ LUA_OSLIBNAME, luaopen_os },
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
	tolua_open(L);
	//luaopen_lpeg(L);

	// Register our version of the global "print" function
	const luaL_reg global_functions[] =
	{
		{ "print", dora_print },
		{ "loadfile", dora_loadfile },
		{ "dofile", dora_dofile },
		/*
		{ "doXml", olua_doXml },
		{ "xmlToLua", olua_xmlToLua },
		*/
		{ "ubox", dora_ubox },
		{ NULL, NULL }
	};
	luaL_register(L, "_G", global_functions);

	// add dorothy loader
	LuaEngine::addLuaLoader(dora_loader);

	// load binding codes
	tolua_LuaBinding_open(L);
	tolua_LuaCode_open(L);
/*
	tolua_beginmodule(L, 0);//stack: package.loaded
	tolua_beginmodule(L, "CCNode");
	tolua_function(L, "gslot", CCNode_gslot);
	tolua_function(L, "slot", CCNode_slot);
	tolua_function(L, "emit", CCNode_emit);
	tolua_function(L, "traverse", CCNode_traverse);
	tolua_function(L, "eachChild", CCNode_eachChild);
	tolua_endmodule(L);
	tolua_beginmodule(L, "CCDictionary");//stack: package.loaded CCDictionary
	tolua_variable(L, "randomObject", CCDictionary_randomObject, nullptr);
	tolua_function(L, "set", CCDictionary_set);
	tolua_function(L, "get", CCDictionary_get);
	tolua_function(L, "each", CCDictionary_each);
	tolua_endmodule(L);
	tolua_beginmodule(L, "CCArray");
	tolua_function(L, "each", CCArray_each);
	tolua_endmodule(L);
	tolua_beginmodule(L, "CCTextureCache");
	tolua_function(L, "loadAsync", CCTextureCache_loadAsync);
	tolua_endmodule(L);
	tolua_endmodule(L);

	tolua_LuaCode_open(L);
*/
	lua_settop(L, 0); // clear stack
}

void LuaEngine::addLuaLoader(lua_CFunction func)
{
	if (!func) return;
	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "loaders"); // package, loaders
	// insert loader into index 1
	lua_pushcfunction(L, func); // package, loaders, func
	for (int i = (int)lua_objlen(L, -2) + 1; i > 1; --i)
	{
		lua_rawgeti(L, -2, i - 1); // package, loaders, func, function
		// we call lua_rawgeti, so the loader table now is at -3
		lua_rawseti(L, -3, i); // package, loaders, func
	}
	lua_rawseti(L, -2, 1); // package, loaders
	// set loaders into package
	lua_setfield(L, -2, "loaders"); // package
	lua_pop(L, 1); // stack empty
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
		lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_UBOX); // ubox
		lua_rawgeti(L, -1, refid); // ubox ud
		if (!lua_isnil(L, -1))
		{
			lua_pushvalue(L, TOLUA_NOPEER); // ubox ud nopeer
			lua_setfenv(L, -2); // ud<nopeer>, ubox ud
		}
		lua_pop(L, 2); // empty
	}
}

int LuaEngine::executeString(String codes)
{
	luaL_loadstring(L, codes.c_str());
	return LuaEngine::execute(L, 0);
}

int LuaEngine::executeScriptFile(String filename)
{
	int top = lua_gettop(L);
	lua_getglobal(L, "dofile"); // file, dofile
	lua_pushlstring(L, filename.c_str(), filename.size());
	int result = LuaEngine::call(L, 1, LUA_MULTRET); // dofile(file)
	lua_settop(L, top);
	return result;
}

void LuaEngine::push(int value)
{
	lua_pushinteger(L, (lua_Integer)value);
}

void LuaEngine::push(float value)
{
	lua_pushnumber(L, (lua_Number)value);
}

void LuaEngine::push(double value)
{
	lua_pushnumber(L, (lua_Number)value);
}

void LuaEngine::push(Object* value)
{
	tolua_pushobject(L, value);
}

void LuaEngine::push(String value)
{
	lua_pushlstring(L, value.c_str(), value.size());
}

int LuaEngine::executeFunction(int handler, int paramCount)
{
	return LuaEngine::execute(L, handler, paramCount);
}

bool LuaEngine::executeAssert(bool cond, String msg)
{
	if (_callFromLua == 0)
	{
		return false;
	}
	luaL_error(L, "assert failed with C++ condition: %s", msg.empty() ? "unknown" : msg.c_str());
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

int LuaEngine::call(lua_State* L, int paramCount, int returnCount)
{
#ifndef TOLUA_RELEASE
	int functionIndex = -(paramCount + 1);
	int top = lua_gettop(L);
	int traceIndex = max(functionIndex + top, 1);
	if (!lua_isfunction(L, functionIndex))
	{
		Log("[Lua Error] value at stack [%d] is not function in LuaEngine::call", functionIndex);
		lua_pop(L, paramCount + 1); // remove function and arguments
		return 0;
	}

	lua_pushcfunction(L, dora_traceback);// func args... traceback
	lua_insert(L, traceIndex);// traceback func args...

	++_callFromLua;
	int error = lua_pcall(L, paramCount, returnCount, traceIndex);// traceback error ret
	--_callFromLua;

	lua_remove(L, traceIndex);

	if (error)// traceback error
	{
		return 0;
	}
#else
	lua_call(L, paramCount, returnCount);
#endif
	return 1;
}

int LuaEngine::execute(lua_State* L, int numArgs)
{
	int ret = 0;
	int top = lua_gettop(L) - numArgs - 1;
	if (LuaEngine::call(L, numArgs, 1))
	{
		// get return value
		if (lua_isnumber(L, -1))// traceback ret
		{
			ret = (int)(lua_tointeger(L, -1));
		}
		else if (lua_isboolean(L, -1))
		{
			ret = lua_toboolean(L, -1);
		}
	}
	else ret = 1;
	lua_settop(L, top);// stack clear
	return ret;
}

int LuaEngine::execute(lua_State* L, int handler, int numArgs)
{
	tolua_get_function_by_refid(L, handler);// args... func
	if (!lua_isfunction(L, -1))
	{
		Log("[Lua Error] function refid '%d' does not reference a Lua function", handler);
		lua_pop(L, 1 + numArgs);
		return 1;
	}
	if (numArgs > 0) lua_insert(L, -(numArgs + 1));// func args...

	return LuaEngine::execute(L, numArgs);
}

int LuaEngine::invoke(lua_State* L, int nHandler, int numArgs, int numRets)
{
	tolua_get_function_by_refid(L, nHandler);// args... func
	if (!lua_isfunction(L, -1))
	{
		Log("[Lua Error] function refid '%d' does not reference a Lua function", nHandler);
		lua_pop(L, 1 + numArgs);
		return 0;
	}
	if (numArgs > 0) lua_insert(L, -(numArgs + 1));// func args...

	return LuaEngine::call(L, numArgs, numRets);
}

NS_DOROTHY_END
