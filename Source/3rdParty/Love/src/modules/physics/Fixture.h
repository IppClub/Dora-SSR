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
// Backend-neutral Fixture base adapted from LOVE 11.5's Box2D Fixture.
#ifndef LOVE_PHYSICS_FIXTURE_H
#define LOVE_PHYSICS_FIXTURE_H

#include "Body.h"
#include "Shape.h"
#include "common/Object.h"

struct lua_State;

namespace love
{
namespace physics
{

class Fixture : public Object
{
public:
	static love::Type type;
	~Fixture() override = default;
	virtual Shape::Type getType() = 0;
	virtual Shape *getShape() = 0;
	virtual bool isValid() const = 0;
	virtual bool isSensor() const = 0;
	virtual void setSensor(bool sensor) = 0;
	virtual Body *getBody() const = 0;
	virtual void setFilterData(int *values) = 0;
	virtual void getFilterData(int *values) = 0;
	virtual int setUserData(lua_State *L) = 0;
	virtual int getUserData(lua_State *L) = 0;
	virtual void setFriction(float friction) = 0;
	virtual void setRestitution(float restitution) = 0;
	virtual void setDensity(float density) = 0;
	virtual float getFriction() const = 0;
	virtual float getRestitution() const = 0;
	virtual float getDensity() const = 0;
	virtual bool testPoint(float x, float y) const = 0;
	virtual int rayCast(lua_State *L) const = 0;
	virtual void setGroupIndex(int index) = 0;
	virtual int getGroupIndex() const = 0;
	virtual int setCategory(lua_State *L) = 0;
	virtual int setMask(lua_State *L) = 0;
	virtual int getCategory(lua_State *L) = 0;
	virtual int getMask(lua_State *L) = 0;
	virtual int getBoundingBox(lua_State *L) const = 0;
	virtual int getMassData(lua_State *L) const = 0;
	virtual void destroy() = 0;
};

} // physics
} // love

#endif // LOVE_PHYSICS_FIXTURE_H
