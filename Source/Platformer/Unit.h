/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Physics/Body.h"

NS_DORA_BEGIN
class Sensor;
class PhysicsWorld;
class Entity;
class EntityWorld;
class Playable;
class Dictionary;
NS_DORA_END

NS_DORA_PLATFORMER_BEGIN
class UnitAction;
class Property;
class Instinct;

namespace Decision {
class Leaf;
}
namespace Behavior {
class Leaf;
class Blackboard;
} // namespace Behavior

typedef std::function<void(UnitAction* action)> UnitActionHandler;

class Unit : public Body {
	typedef StringMap<Own<UnitAction>> ActionMap;

public:
	enum { GroundSensorTag = 0,
		DetectSensorTag = 1,
		AttackSensorTag = 2 };
	// Class properties
	PROPERTY(Playable*, Playable);
	PROPERTY(float, DetectDistance);
	PROPERTY_CREF(Size, AttackRange);
	PROPERTY_BOOL(FaceRight);
	PROPERTY_BOOL(ReceivingDecisionTrace);
	PROPERTY_READONLY(Entity*, Entity);
	PROPERTY_READONLY(Sensor*, GroundSensor);
	PROPERTY_READONLY(Sensor*, DetectSensor);
	PROPERTY_READONLY(Sensor*, AttackSensor);
	PROPERTY_READONLY(Dictionary*, UnitDef);
	PROPERTY_READONLY(UnitAction*, CurrentAction);
	PROPERTY_READONLY(float, Width);
	PROPERTY_READONLY(float, Height);
	virtual bool init() override;
	virtual void setGroup(uint8_t group) override;
	virtual bool update(double deltaTime) override;
	virtual void onEnter() override;
	virtual void cleanup() override;
	// Actions
	UnitAction* attachAction(String name);
	void removeAction(String name);
	void removeAllActions();
	UnitAction* getAction(String name) const;
	void eachAction(const UnitActionHandler& func);
	// Run actions
	bool start(String name);
	void stop();
	bool isDoing(String name);
	// Physics state
	bool isOnSurface() const;
	// Decision tree AI nodes
	PROPERTY_STRING(DecisionTreeName);
	PROPERTY_READONLY(Decision::Leaf*, DecisionTree);
	PROPERTY(Behavior::Leaf*, BehaviorTree);
	struct Def {
		static const Slice Size;
		static const Slice Density;
		static const Slice Friction;
		static const Slice Restitution;
		static const Slice BodyDef;
		static const Slice LinearAcceleration;
		static const Slice LinearDamping;
		static const Slice AngularDamping;
		static const Slice BodyType;
		static const Slice DetectDistance;
		static const Slice AttackRange;
		static const Slice Tag;
		static const Slice Playable;
		static const Slice Scale;
		static const Slice Actions;
		static const Slice DecisionTree;
		static const Slice DefaultFaceRight;
	};
	CREATE_FUNC_NOT_NULL(Unit);

protected:
	Unit(NotNull<Dictionary, 1> unitDef, NotNull<PhysicsWorld, 2> physicsWorld, NotNull<Entity, 3> entity, const Vec2& pos, float rot);
	Unit(String defName, String worldName, NotNull<Entity, 3> entity, const Vec2& pos, float rot);

private:
	BodyDef* getBodyDef(Dictionary* def) const;
	WRef<Entity> _entity;
	float _detectDistance;
	Size _attackRange;
	std::string _decisionTreeName;
	Ref<Decision::Leaf> _decisionTree;
	Ref<Behavior::Leaf> _behaviorTree;
	Own<Behavior::Blackboard> _blackboard;
	Ref<Dictionary> _unitDef;
	WRef<Playable> _playable;
	Size _size;
	Sensor* _groundSensor;
	Sensor* _detectSensor;
	Sensor* _attackSensor;
	UnitAction* _currentAction;
	ActionMap _actions;
	enum {
		FaceRight = BodyUserFlag,
		DefaultFaceRight = BodyUserFlag << 1,
		ReceivingDecisionTrace = BodyUserFlag << 2
	};
	DORA_TYPE_OVERRIDE(Unit);
};

NS_DORA_PLATFORMER_END
