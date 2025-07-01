/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DORA_BEGIN

namespace pr = playrho;
namespace pd = playrho::d2;

class Body;
class Sensor;
class PhysicsWorld;
class BodyDef;
class Contact;

class FixtureDef;

typedef Acf::Delegate<bool(Body* body)> ContactFilterHandler;
typedef Acf::Delegate<void(Body* body, const Vec2& point, const Vec2& normal, bool enabled)> ContactStartHandler;
typedef Acf::Delegate<void(Body* body, const Vec2& point, const Vec2& normal)> ContactEndHandler;

class Body : public Node {
public:
	virtual ~Body();
	virtual bool init() override;
	virtual void onEnter() override;
	virtual void onExit() override;
	virtual void cleanup() override;
	PROPERTY_EXCEPT(float, LinearDamping);
	PROPERTY_EXCEPT(float, AngularDamping);
	PROPERTY_EXCEPT(float, AngularRate);
	PROPERTY(Object*, Owner);
	PROPERTY_READONLY(PhysicsWorld*, PhysicsWorld);
	PROPERTY_READONLY(BodyDef*, BodyDef);
	PROPERTY_READONLY(pr::BodyID, PrBody);
	PROPERTY_READONLY_EXCEPT(Vec2, Velocity);
	PROPERTY_READONLY_EXCEPT(float, Mass);
	PROPERTY_EXCEPT(float, VelocityX);
	PROPERTY_EXCEPT(float, VelocityY);
	PROPERTY_VIRTUAL(uint8_t, Group);
	PROPERTY_BOOL(ReceivingContact);
	ContactStartHandler contactStart;
	ContactEndHandler contactEnd;
	ContactFilterHandler filterContact;
	void applyLinearImpulse(const Vec2& impulse, const Vec2& pos);
	void applyAngularImpulse(float impulse);
	void setVelocity(float x, float y);
	void setVelocity(const Vec2& velocity);
	virtual void setAngle(float var) override;
	virtual void setPosition(Vec2 var) override;
	Sensor* getSensorByTag(int tag);
	bool removeSensorByTag(int tag);
	bool removeSensor(Sensor* sensor);
	pr::ShapeID attach(NotNull<FixtureDef, 1> fixtureDef);
	Sensor* attachSensor(int tag, NotNull<FixtureDef, 2> fixtureDef);
	bool isSensor() const;
	void onContactFilter(const ContactFilterHandler& handler);
	CREATE_FUNC_NOT_NULL(Body);

protected:
	Body(NotNull<BodyDef, 1> bodyDef, NotNull<PhysicsWorld, 2> world, const Vec2& pos = Vec2::zero, float rot = 0);
	pr::ShapeID attachFixture(const pd::Shape& shape);
	Sensor* attachSensor(int tag, pd::Shape& shape);
	virtual void updatePhysics();
	pr::BodyID _prBody; // weak reference
	WRef<PhysicsWorld> _pWorld;
	uint8_t _group;
	enum : Flag::ValueType {
		ReceivingContact = UserFlag,
		EmittingEvent = UserFlag << 1,
		BodyUserFlag = UserFlag << 2
	};
	void onBodyEnter(Body* other, int sensorTag);
	void onBodyLeave(Body* other, int sensorTag);
	void onContactStart(Body* other, const Vec2& point, const Vec2& normal, bool enabled);
	void onContactEnd(Body* other, const Vec2& point, const Vec2& normal);
	void clearPhysics();

private:
	Ref<BodyDef> _bodyDef;
	Ref<Array> _sensors;
	WRef<Object> _owner;
	friend class PhysicsWorld;
	DORA_TYPE_OVERRIDE(Body);
};

NS_DORA_END
