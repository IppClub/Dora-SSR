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

#ifndef LOVE_PHYSICS_BODY_H
#define LOVE_PHYSICS_BODY_H

// LOVE
#include "common/Object.h"
#include "common/StringMap.h"

struct lua_State;

namespace love
{
namespace physics
{

class World;

class Body : public Object
{
public:

	static love::Type type;

	enum Type
	{
		BODY_INVALID,
		BODY_STATIC,
		BODY_DYNAMIC,
		BODY_KINEMATIC,
		BODY_MAX_ENUM
	};

	virtual ~Body();
	virtual bool isDestroyed() const = 0;
	virtual float getX() = 0;
	virtual float getY() = 0;
	virtual float getAngle() = 0;
	virtual void getPosition(float &x, float &y) = 0;
	virtual void getLinearVelocity(float &x, float &y) = 0;
	virtual void getWorldCenter(float &x, float &y) = 0;
	virtual void getLocalCenter(float &x, float &y) = 0;
	virtual float getAngularVelocity() const = 0;
	virtual float getMass() const = 0;
	virtual float getInertia() const = 0;
	virtual int getMassData(lua_State *L) = 0;
	virtual float getAngularDamping() const = 0;
	virtual float getLinearDamping() const = 0;
	virtual float getGravityScale() const = 0;
	virtual Type getType() const = 0;
	virtual void applyLinearImpulse(float x, float y, bool wake) = 0;
	virtual void applyLinearImpulse(float x, float y, float px, float py, bool wake) = 0;
	virtual void applyAngularImpulse(float impulse, bool wake) = 0;
	virtual void applyTorque(float torque, bool wake) = 0;
	virtual void applyForce(float x, float y, bool wake) = 0;
	virtual void applyForce(float x, float y, float px, float py, bool wake) = 0;
	virtual void setX(float x) = 0;
	virtual void setY(float y) = 0;
	virtual void setLinearVelocity(float x, float y) = 0;
	virtual void setAngle(float angle) = 0;
	virtual void setAngularVelocity(float velocity) = 0;
	virtual void setPosition(float x, float y) = 0;
	virtual void resetMassData() = 0;
	virtual void setMassData(float x, float y, float mass, float inertia) = 0;
	virtual void setMass(float mass) = 0;
	virtual void setInertia(float inertia) = 0;
	virtual void setAngularDamping(float damping) = 0;
	virtual void setLinearDamping(float damping) = 0;
	virtual void setGravityScale(float scale) = 0;
	virtual void setType(Type type) = 0;
	virtual void getWorldPoint(float x, float y, float &outX, float &outY) = 0;
	virtual void getWorldVector(float x, float y, float &outX, float &outY) = 0;
	virtual int getWorldPoints(lua_State *L) = 0;
	virtual void getLocalPoint(float x, float y, float &outX, float &outY) = 0;
	virtual void getLocalVector(float x, float y, float &outX, float &outY) = 0;
	virtual int getLocalPoints(lua_State *L) = 0;
	virtual void getLinearVelocityFromWorldPoint(float x, float y, float &outX, float &outY) = 0;
	virtual void getLinearVelocityFromLocalPoint(float x, float y, float &outX, float &outY) = 0;
	virtual bool isBullet() const = 0;
	virtual void setBullet(bool bullet) = 0;
	virtual bool isActive() const = 0;
	virtual bool isAwake() const = 0;
	virtual void setSleepingAllowed(bool allow) = 0;
	virtual bool isSleepingAllowed() const = 0;
	virtual void setActive(bool active) = 0;
	virtual void setAwake(bool awake) = 0;
	virtual void setFixedRotation(bool fixed) = 0;
	virtual bool isFixedRotation() const = 0;
	virtual bool isTouching(Body *other) const = 0;
	virtual World *getWorld() const = 0;
	virtual int getFixtures(lua_State *L) const = 0;
	virtual int getJoints(lua_State *L) const = 0;
	virtual int getContacts(lua_State *L) const = 0;
	virtual void destroy() = 0;
	virtual int setUserData(lua_State *L) = 0;
	virtual int getUserData(lua_State *L) = 0;

	static bool getConstant(const char *in, Type &out);
	static bool getConstant(Type in, const char  *&out);
	static std::vector<std::string> getConstants(Type);

private:

	static StringMap<Type, BODY_MAX_ENUM>::Entry typeEntries[];
	static StringMap<Type, BODY_MAX_ENUM> types;
};

} // physics
} // love

#endif // LOVE_PHYSICS_BODY_H
