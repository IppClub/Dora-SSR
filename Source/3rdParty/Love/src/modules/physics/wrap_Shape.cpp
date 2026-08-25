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
#include "wrap_Shape.h"
namespace love { namespace physics {
Shape *luax_checkshape(lua_State *L,int idx){return luax_checktype<Shape>(L,idx);}
int w_Shape_getType(lua_State *L){auto*t=luax_checkshape(L,1);Shape::Type v=Shape::SHAPE_INVALID;luax_catchexcept(L,[&](){v=t->getType();});const char*n="";Shape::getConstant(v,n);lua_pushstring(L,n);return 1;}
int w_Shape_getRadius(lua_State *L){auto*t=luax_checkshape(L,1);float v=0;luax_catchexcept(L,[&](){v=t->getRadius();});lua_pushnumber(L,v);return 1;}
int w_Shape_getChildCount(lua_State *L){auto*t=luax_checkshape(L,1);int v=0;luax_catchexcept(L,[&](){v=t->getChildCount();});lua_pushinteger(L,v);return 1;}
int w_Shape_testPoint(lua_State *L){auto*t=luax_checkshape(L,1);float x=(float)luaL_checknumber(L,2),y=(float)luaL_checknumber(L,3),r=(float)luaL_checknumber(L,4),px=(float)luaL_checknumber(L,5),py=(float)luaL_checknumber(L,6);bool v=false;luax_catchexcept(L,[&](){v=t->testPoint(x,y,r,px,py);});luax_pushboolean(L,v);return 1;}
int w_Shape_rayCast(lua_State *L){auto*t=luax_checkshape(L,1);lua_remove(L,1);int ret=0;luax_catchexcept(L,[&](){ret=t->rayCast(L);});return ret;}
int w_Shape_computeAABB(lua_State *L){auto*t=luax_checkshape(L,1);lua_remove(L,1);int ret=0;luax_catchexcept(L,[&](){ret=t->computeAABB(L);});return ret;}
int w_Shape_computeMass(lua_State *L){auto*t=luax_checkshape(L,1);lua_remove(L,1);int ret=0;luax_catchexcept(L,[&](){ret=t->computeMass(L);});return ret;}
int w_Shape_setRadius(lua_State *L){auto*t=luax_checkshape(L,1);float v=(float)luaL_checknumber(L,2);luax_catchexcept(L,[&](){t->setRadius(v);});return 0;}
int w_Shape_getPoint(lua_State *L){auto*t=luax_checkshape(L,1);if(lua_gettop(L)==1){float x=0,y=0;luax_catchexcept(L,[&](){t->getPoint(x,y);});lua_pushnumber(L,x);lua_pushnumber(L,y);return 2;}int i=(int)luaL_checkinteger(L,2)-1;float x=0,y=0;luax_catchexcept(L,[&](){t->getPoint(i,x,y);});lua_pushnumber(L,x);lua_pushnumber(L,y);return 2;}
int w_Shape_setPoint(lua_State *L){auto*t=luax_checkshape(L,1);float x=(float)luaL_checknumber(L,2),y=(float)luaL_checknumber(L,3);luax_catchexcept(L,[&](){t->setPoint(x,y);});return 0;}
int w_Shape_getPoints(lua_State *L){auto*t=luax_checkshape(L,1);lua_remove(L,1);int ret=0;luax_catchexcept(L,[&](){ret=t->getPoints(L);});return ret;}
int w_Shape_validate(lua_State *L){auto*t=luax_checkshape(L,1);bool v=false;luax_catchexcept(L,[&](){v=t->validate();});luax_pushboolean(L,v);return 1;}
int w_Shape_getVertexCount(lua_State *L){auto*t=luax_checkshape(L,1);int v=0;luax_catchexcept(L,[&](){v=t->getVertexCount();});lua_pushinteger(L,v);return 1;}
int w_Shape_getChildEdge(lua_State *L){auto*t=luax_checkshape(L,1);int i=(int)luaL_checkinteger(L,2)-1;Shape*edge=nullptr;luax_catchexcept(L,[&](){edge=t->getChildEdge(i);});luax_pushtype(L,edge);edge->release();return 1;}
int w_Shape_setNextVertex(lua_State *L){auto*t=luax_checkshape(L,1);if(lua_isnoneornil(L,2))luax_catchexcept(L,[&](){t->setNextVertex();});else{float x=(float)luaL_checknumber(L,2),y=(float)luaL_checknumber(L,3);luax_catchexcept(L,[&](){t->setNextVertex(x,y);});}return 0;}
int w_Shape_setPreviousVertex(lua_State *L){auto*t=luax_checkshape(L,1);if(lua_isnoneornil(L,2))luax_catchexcept(L,[&](){t->setPreviousVertex();});else{float x=(float)luaL_checknumber(L,2),y=(float)luaL_checknumber(L,3);luax_catchexcept(L,[&](){t->setPreviousVertex(x,y);});}return 0;}
int w_Shape_getNextVertex(lua_State *L){auto*t=luax_checkshape(L,1);float x=0,y=0;bool v=false;luax_catchexcept(L,[&](){v=t->getNextVertex(x,y);});if(!v)return 0;lua_pushnumber(L,x);lua_pushnumber(L,y);return 2;}
int w_Shape_getPreviousVertex(lua_State *L){auto*t=luax_checkshape(L,1);float x=0,y=0;bool v=false;luax_catchexcept(L,[&](){v=t->getPreviousVertex(x,y);});if(!v)return 0;lua_pushnumber(L,x);lua_pushnumber(L,y);return 2;}
static const luaL_Reg functions[]={
{"getType",w_Shape_getType},{"getRadius",w_Shape_getRadius},{"getChildCount",w_Shape_getChildCount},{"testPoint",w_Shape_testPoint},{"rayCast",w_Shape_rayCast},{"computeAABB",w_Shape_computeAABB},{"computeMass",w_Shape_computeMass},
{"setRadius",w_Shape_setRadius},{"getPoint",w_Shape_getPoint},{"setPoint",w_Shape_setPoint},{"getPoints",w_Shape_getPoints},{"validate",w_Shape_validate},{"getVertexCount",w_Shape_getVertexCount},{"getChildEdge",w_Shape_getChildEdge},
{"setNextVertex",w_Shape_setNextVertex},{"setPreviousVertex",w_Shape_setPreviousVertex},{"getNextVertex",w_Shape_getNextVertex},{"getPreviousVertex",w_Shape_getPreviousVertex},{nullptr,nullptr}};
extern "C" int luaopen_shape(lua_State *L){return luax_register_type(L,&Shape::type,functions,nullptr);}
} }
