/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DOROTHY_BEGIN

namespace pr = playrho;
namespace pd = playrho::d2;

class Body;
class Sensor;
class PhysicsWorld;
class BodyDef;
class Contact;

struct FixtureDef;

typedef Delegate<bool(Body* body)> ContactFilterHandler;
typedef Delegate<void(Body* body,const Vec2& point,const Vec2& normal)> ContactHandler;
typedef Delegate<void(Sensor* sensor,Body* body)> SensorHandler;

class Body : public Node
{
public:
	virtual ~Body();
	virtual bool init() override;
	virtual void onEnter() override;
	virtual void onExit() override;
	virtual void cleanup() override;
	PROPERTY(float, LinearDamping);
	PROPERTY(float, AngularDamping);
	PROPERTY(float, AngularRate);
	PROPERTY(Object*, Owner);
	PROPERTY_READONLY(PhysicsWorld*, World);
	PROPERTY_READONLY(BodyDef*, BodyDef);
	PROPERTY_READONLY(pd::Body*, PrBody);
	PROPERTY_READONLY(Vec2, Velocity);
	PROPERTY_READONLY(float, Mass);
	PROPERTY(float, VelocityX);
	PROPERTY(float, VelocityY);
	PROPERTY_VIRTUAL(Uint8, Group);
	PROPERTY_BOOL(ReceivingContact);
	PROPERTY_BOOL(EmittingEvent);
	ContactHandler contactStart;
	ContactHandler contactEnd;
	ContactFilterHandler filterContact;
	SensorHandler sensorAdded;
	void applyLinearImpulse(const Vec2& impulse, const Vec2& pos);
	void applyAngularImpulse(float impulse);
	void setVelocity(float x, float y);
	void setVelocity(const Vec2& velocity);
	virtual void setAngle(float var) override;
	virtual void setPosition(const Vec2& var) override;
	virtual Rect getBoundingBox() override;
	Sensor* getSensorByTag(int tag);
	void eachSensor(const SensorHandler& func);
	bool removeSensorByTag(int tag);
	bool removeSensor(Sensor* sensor);
	pd::Fixture* attach(FixtureDef* fixtureDef);
	Sensor* attachSensor(int tag, FixtureDef* fixtureDef);
	bool isSensor() const;
	CREATE_FUNC(Body);
protected:
	Body(BodyDef* bodyDef, PhysicsWorld* world, const Vec2& pos = Vec2::zero, float rot = 0);
	pd::Fixture* attachFixture(FixtureDef* fixtureDef);
	virtual void updatePhysics();
	pd::Body* _prBody; // weak reference
	PhysicsWorld* _world;
	Uint8 _group;
	enum
	{
		ReceivingContact = UserFlag,
		EmittingEvent = UserFlag << 1,
		BodyUserFlag = UserFlag << 2
	};
	void onSensorAdded(Sensor* sensor, Body* body);
	void onBodyEnter(Sensor* sensor, Body* other);
	void onBodyLeave(Sensor* sensor, Body* other);
	void onContactStart(Body* other, const Vec2& point, const Vec2& normal);
	void onContactEnd(Body* other, const Vec2& point, const Vec2& normal);
private:
	Ref<BodyDef> _bodyDef;
	Ref<Array> _sensors;
	WRef<Object> _owner;
	friend class PhysicsWorld;
	DORA_TYPE_OVERRIDE(Body);
};

NS_DOROTHY_END
