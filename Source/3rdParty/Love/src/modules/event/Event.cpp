#include "Event.h"

namespace love::event
{

Message::Message(const std::string &name, const std::vector<Variant> &args)
	: name(name), args(args) { }

int Message::toLua(lua_State *L)
{
	luax_pushstring(L, name);
	for (const Variant &value : args) value.toLua(L);
	return (int) args.size() + 1;
}

Message *Message::fromLua(lua_State *L, int index)
{
	std::string name = luax_checkstring(L, index);
	std::vector<Variant> args;
	const int count = lua_gettop(L) - index;
	for (int i = 0; i < count; ++i)
	{
		if (lua_isnoneornil(L, index + 1 + i)) break;
		const int luaType = lua_type(L, index + 1 + i);
		if (luaType != LUA_TBOOLEAN && luaType != LUA_TNUMBER
			&& luaType != LUA_TSTRING && luaType != LUA_TUSERDATA
			&& luaType != LUA_TLIGHTUSERDATA)
			throw Exception("event arguments must be boolean, number, string, userdata, or nil (argument %d)",
				index + 1 + i);
		Variant value = Variant::fromLua(L, index + 1 + i);
		if (value.getType() == Variant::UNKNOWN)
			throw Exception("event arguments must be boolean, number, string, userdata, or nil (argument %d)",
				index + 1 + i);
		args.push_back(std::move(value));
	}
	return new Message(name, args);
}

}
