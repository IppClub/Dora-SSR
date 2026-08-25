/**
 * Backend-neutral World base adapted from LOVE 11.5's Box2D World object.
 * Dora provides the concrete PlayRho-backed implementation.
 */
#ifndef LOVE_PHYSICS_WORLD_H
#define LOVE_PHYSICS_WORLD_H

#include "common/Object.h"

struct lua_State;

namespace love
{
namespace physics
{

class World : public Object
{
public:
	static love::Type type;
	~World() override = default;
	virtual bool isDestroyed() const = 0;
	virtual void update(float dt) = 0;
	virtual void update(float dt, int velocityIterations, int positionIterations) = 0;
	virtual int setCallbacks(lua_State *L) = 0;
	virtual int getCallbacks(lua_State *L) = 0;
	virtual void setCallbacksL(lua_State *) { }
	virtual void setGravity(float x, float y) = 0;
	virtual int getGravity(lua_State *L) = 0;
	virtual void translateOrigin(float x, float y) = 0;
	virtual void setSleepingAllowed(bool allow) = 0;
	virtual bool isSleepingAllowed() const = 0;
	virtual bool isLocked() const = 0;
	virtual int getBodyCount() const = 0;
	virtual int getJointCount() const = 0;
	virtual int getContactCount() const = 0;
	virtual int getBodies(lua_State *L) const = 0;
	virtual int getJoints(lua_State *L) const = 0;
	virtual int getContacts(lua_State *L) = 0;
	virtual int queryBoundingBox(lua_State *L) = 0;
	virtual int rayCast(lua_State *L) = 0;
	virtual void destroy() = 0;
};

} // physics
} // love

#endif // LOVE_PHYSICS_WORLD_H
