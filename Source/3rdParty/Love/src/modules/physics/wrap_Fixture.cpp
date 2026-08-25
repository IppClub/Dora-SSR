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
#include "wrap_Fixture.h"
namespace love { namespace physics {

Fixture *luax_checkfixture(lua_State *L, int idx)
{
	Fixture *fixture = luax_checktype<Fixture>(L, idx);
	if (!fixture->isValid()) luaL_error(L, "Attempt to use destroyed fixture.");
	return fixture;
}
int w_Fixture_getType(lua_State *L) { Fixture *t=luax_checkfixture(L,1); Shape::Type value=Shape::SHAPE_INVALID; luax_catchexcept(L,[&](){value=t->getType();}); const char *name=""; Shape::getConstant(value,name); lua_pushstring(L,name); return 1; }
int w_Fixture_setFriction(lua_State *L) { Fixture *t=luax_checkfixture(L,1); float v=(float)luaL_checknumber(L,2); luax_catchexcept(L,[&](){t->setFriction(v);}); return 0; }
int w_Fixture_setRestitution(lua_State *L) { Fixture *t=luax_checkfixture(L,1); float v=(float)luaL_checknumber(L,2); luax_catchexcept(L,[&](){t->setRestitution(v);}); return 0; }
int w_Fixture_setDensity(lua_State *L) { Fixture *t=luax_checkfixture(L,1); float v=(float)luaL_checknumber(L,2); luax_catchexcept(L,[&](){t->setDensity(v);}); return 0; }
int w_Fixture_setSensor(lua_State *L) { Fixture *t=luax_checkfixture(L,1); bool v=luax_checkboolean(L,2); luax_catchexcept(L,[&](){t->setSensor(v);}); return 0; }
int w_Fixture_getFriction(lua_State *L) { Fixture *t=luax_checkfixture(L,1); float v=0; luax_catchexcept(L,[&](){v=t->getFriction();}); lua_pushnumber(L,v); return 1; }
int w_Fixture_getRestitution(lua_State *L) { Fixture *t=luax_checkfixture(L,1); float v=0; luax_catchexcept(L,[&](){v=t->getRestitution();}); lua_pushnumber(L,v); return 1; }
int w_Fixture_getDensity(lua_State *L) { Fixture *t=luax_checkfixture(L,1); float v=0; luax_catchexcept(L,[&](){v=t->getDensity();}); lua_pushnumber(L,v); return 1; }
int w_Fixture_isSensor(lua_State *L) { Fixture *t=luax_checkfixture(L,1); bool v=false; luax_catchexcept(L,[&](){v=t->isSensor();}); luax_pushboolean(L,v); return 1; }
int w_Fixture_getBody(lua_State *L) { Fixture *t=luax_checkfixture(L,1); Body *v=nullptr; luax_catchexcept(L,[&](){v=t->getBody();}); if (!v) return 0; luax_pushtype(L,v); return 1; }
int w_Fixture_getShape(lua_State *L) { Fixture *t=luax_checkfixture(L,1); Shape *v=nullptr; luax_catchexcept(L,[&](){v=t->getShape();}); if (!v) return 0; luax_pushtype(L,v); return 1; }
int w_Fixture_testPoint(lua_State *L) { Fixture *t=luax_checkfixture(L,1); float x=(float)luaL_checknumber(L,2),y=(float)luaL_checknumber(L,3); bool v=false; luax_catchexcept(L,[&](){v=t->testPoint(x,y);}); luax_pushboolean(L,v); return 1; }
int w_Fixture_rayCast(lua_State *L) { Fixture *t=luax_checkfixture(L,1); lua_remove(L,1); int ret=0; luax_catchexcept(L,[&](){ret=t->rayCast(L);}); return ret; }
int w_Fixture_setFilterData(lua_State *L) { Fixture *t=luax_checkfixture(L,1); int v[3]={(int)luaL_checkinteger(L,2),(int)luaL_checkinteger(L,3),(int)luaL_checkinteger(L,4)}; luax_catchexcept(L,[&](){t->setFilterData(v);}); return 0; }
int w_Fixture_getFilterData(lua_State *L) { Fixture *t=luax_checkfixture(L,1); int v[3]={}; luax_catchexcept(L,[&](){t->getFilterData(v);}); lua_pushinteger(L,v[0]); lua_pushinteger(L,v[1]); lua_pushinteger(L,v[2]); return 3; }
int w_Fixture_setCategory(lua_State *L) { Fixture *t=luax_checkfixture(L,1); lua_remove(L,1); int ret=0; luax_catchexcept(L,[&](){ret=t->setCategory(L);}); return ret; }
int w_Fixture_getCategory(lua_State *L) { Fixture *t=luax_checkfixture(L,1); lua_remove(L,1); int ret=0; luax_catchexcept(L,[&](){ret=t->getCategory(L);}); return ret; }
int w_Fixture_setMask(lua_State *L) { Fixture *t=luax_checkfixture(L,1); lua_remove(L,1); int ret=0; luax_catchexcept(L,[&](){ret=t->setMask(L);}); return ret; }
int w_Fixture_getMask(lua_State *L) { Fixture *t=luax_checkfixture(L,1); lua_remove(L,1); int ret=0; luax_catchexcept(L,[&](){ret=t->getMask(L);}); return ret; }
int w_Fixture_setUserData(lua_State *L) { Fixture *t=luax_checkfixture(L,1); lua_remove(L,1); return t->setUserData(L); }
int w_Fixture_getUserData(lua_State *L) { Fixture *t=luax_checkfixture(L,1); lua_remove(L,1); return t->getUserData(L); }
int w_Fixture_getBoundingBox(lua_State *L) { Fixture *t=luax_checkfixture(L,1); lua_remove(L,1); int ret=0; luax_catchexcept(L,[&](){ret=t->getBoundingBox(L);}); return ret; }
int w_Fixture_getMassData(lua_State *L) { Fixture *t=luax_checkfixture(L,1); lua_remove(L,1); int ret=0; luax_catchexcept(L,[&](){ret=t->getMassData(L);}); return ret; }
int w_Fixture_getGroupIndex(lua_State *L) { Fixture *t=luax_checkfixture(L,1); int v=0; luax_catchexcept(L,[&](){v=t->getGroupIndex();}); lua_pushinteger(L,v); return 1; }
int w_Fixture_setGroupIndex(lua_State *L) { Fixture *t=luax_checkfixture(L,1); int v=(int)luaL_checkinteger(L,2); luax_catchexcept(L,[&](){t->setGroupIndex(v);}); return 0; }
int w_Fixture_destroy(lua_State *L) { Fixture *t=luax_checkfixture(L,1); luax_catchexcept(L,[&](){t->destroy();}); return 0; }
int w_Fixture_isDestroyed(lua_State *L) { Fixture *t=luax_checktype<Fixture>(L,1); luax_pushboolean(L,!t->isValid()); return 1; }

static const luaL_Reg w_Fixture_functions[] = {
	{"getType",w_Fixture_getType},{"setFriction",w_Fixture_setFriction},{"setRestitution",w_Fixture_setRestitution},
	{"setDensity",w_Fixture_setDensity},{"setSensor",w_Fixture_setSensor},{"getFriction",w_Fixture_getFriction},
	{"getRestitution",w_Fixture_getRestitution},{"getDensity",w_Fixture_getDensity},{"getBody",w_Fixture_getBody},
	{"getShape",w_Fixture_getShape},{"isSensor",w_Fixture_isSensor},{"testPoint",w_Fixture_testPoint},
	{"rayCast",w_Fixture_rayCast},{"setFilterData",w_Fixture_setFilterData},{"getFilterData",w_Fixture_getFilterData},
	{"setCategory",w_Fixture_setCategory},{"getCategory",w_Fixture_getCategory},{"setMask",w_Fixture_setMask},
	{"getMask",w_Fixture_getMask},{"setUserData",w_Fixture_setUserData},{"getUserData",w_Fixture_getUserData},
	{"getBoundingBox",w_Fixture_getBoundingBox},{"getMassData",w_Fixture_getMassData},
	{"getGroupIndex",w_Fixture_getGroupIndex},{"setGroupIndex",w_Fixture_setGroupIndex},
	{"destroy",w_Fixture_destroy},{"isDestroyed",w_Fixture_isDestroyed},{nullptr,nullptr}
};
extern "C" int luaopen_fixture(lua_State *L) { return luax_register_type(L,&Fixture::type,w_Fixture_functions,nullptr); }
} }
