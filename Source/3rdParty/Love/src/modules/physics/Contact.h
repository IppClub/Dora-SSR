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
// Backend-neutral Contact base adapted from LOVE 11.5's Box2D Contact.
#ifndef LOVE_PHYSICS_CONTACT_H
#define LOVE_PHYSICS_CONTACT_H

#include "Fixture.h"
#include "common/Object.h"

struct lua_State;

namespace love
{
namespace physics
{

class Contact : public Object
{
public:
	static love::Type type;
	~Contact() override = default;
	virtual bool isValid() const = 0;
	virtual int getPositions(lua_State *L) = 0;
	virtual int getNormal(lua_State *L) = 0;
	virtual float getFriction() const = 0;
	virtual float getRestitution() const = 0;
	virtual bool isEnabled() const = 0;
	virtual bool isTouching() const = 0;
	virtual void setFriction(float friction) = 0;
	virtual void setRestitution(float restitution) = 0;
	virtual void setEnabled(bool enabled) = 0;
	virtual void resetFriction() = 0;
	virtual void resetRestitution() = 0;
	virtual void setTangentSpeed(float speed) = 0;
	virtual float getTangentSpeed() const = 0;
	virtual void getChildren(int &childA, int &childB) = 0;
	virtual void getFixtures(Fixture *&fixtureA, Fixture *&fixtureB) = 0;
};

} // physics
} // love

#endif // LOVE_PHYSICS_CONTACT_H
