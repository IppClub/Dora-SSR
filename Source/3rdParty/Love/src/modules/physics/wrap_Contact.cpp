/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 **/
#include "wrap_Contact.h"

namespace love
{
namespace physics
{

Contact *luax_checkcontact(lua_State *L, int idx)
{
	Contact *contact = luax_checktype<Contact>(L, idx);
	if (!contact->isValid()) luaL_error(L, "Attempt to use destroyed contact.");
	return contact;
}

int w_Contact_getPositions(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); int ret = 0;
	luax_catchexcept(L, [&](){ ret = t->getPositions(L); }); return ret;
}
int w_Contact_getNormal(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); int ret = 0;
	luax_catchexcept(L, [&](){ ret = t->getNormal(L); }); return ret;
}
int w_Contact_getFriction(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); float value = 0.0f;
	luax_catchexcept(L, [&](){ value = t->getFriction(); }); lua_pushnumber(L, value); return 1;
}
int w_Contact_getRestitution(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); float value = 0.0f;
	luax_catchexcept(L, [&](){ value = t->getRestitution(); }); lua_pushnumber(L, value); return 1;
}
int w_Contact_isEnabled(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); bool value = false;
	luax_catchexcept(L, [&](){ value = t->isEnabled(); }); luax_pushboolean(L, value); return 1;
}
int w_Contact_isTouching(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); bool value = false;
	luax_catchexcept(L, [&](){ value = t->isTouching(); }); luax_pushboolean(L, value); return 1;
}
int w_Contact_setFriction(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); float value = (float) luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setFriction(value); }); return 0;
}
int w_Contact_setRestitution(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); float value = (float) luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setRestitution(value); }); return 0;
}
int w_Contact_setEnabled(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); bool value = luax_checkboolean(L, 2);
	luax_catchexcept(L, [&](){ t->setEnabled(value); }); return 0;
}
int w_Contact_resetFriction(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); luax_catchexcept(L, [&](){ t->resetFriction(); }); return 0;
}
int w_Contact_resetRestitution(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); luax_catchexcept(L, [&](){ t->resetRestitution(); }); return 0;
}
int w_Contact_setTangentSpeed(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); float value = (float) luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setTangentSpeed(value); }); return 0;
}
int w_Contact_getTangentSpeed(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); float value = 0.0f;
	luax_catchexcept(L, [&](){ value = t->getTangentSpeed(); }); lua_pushnumber(L, value); return 1;
}
int w_Contact_getChildren(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); int a = 0, b = 0;
	luax_catchexcept(L, [&](){ t->getChildren(a, b); });
	lua_pushinteger(L, a + 1); lua_pushinteger(L, b + 1); return 2;
}
int w_Contact_getFixtures(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1); Fixture *a = nullptr, *b = nullptr;
	luax_catchexcept(L, [&](){ t->getFixtures(a, b); });
	luax_pushtype(L, a); luax_pushtype(L, b); return 2;
}
int w_Contact_isDestroyed(lua_State *L)
{
	Contact *contact = luax_checktype<Contact>(L, 1);
	luax_pushboolean(L, !contact->isValid()); return 1;
}

static const luaL_Reg w_Contact_functions[] =
{
	{ "getPositions", w_Contact_getPositions }, { "getNormal", w_Contact_getNormal },
	{ "getFriction", w_Contact_getFriction }, { "getRestitution", w_Contact_getRestitution },
	{ "isEnabled", w_Contact_isEnabled }, { "isTouching", w_Contact_isTouching },
	{ "setFriction", w_Contact_setFriction }, { "setRestitution", w_Contact_setRestitution },
	{ "setEnabled", w_Contact_setEnabled }, { "resetFriction", w_Contact_resetFriction },
	{ "resetRestitution", w_Contact_resetRestitution },
	{ "setTangentSpeed", w_Contact_setTangentSpeed }, { "getTangentSpeed", w_Contact_getTangentSpeed },
	{ "getChildren", w_Contact_getChildren }, { "getFixtures", w_Contact_getFixtures },
	{ "isDestroyed", w_Contact_isDestroyed }, { nullptr, nullptr }
};

extern "C" int luaopen_contact(lua_State *L)
{
	return luax_register_type(L, &Contact::type, w_Contact_functions, nullptr);
}

} // physics
} // love
