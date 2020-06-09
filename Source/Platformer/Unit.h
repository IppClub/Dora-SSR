/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Physics/Body.h"

NS_DOROTHY_BEGIN
class Sensor;
class PhysicsWorld;
class Entity;
class EntityWorld;
class Playable;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN
class UnitAction;
class Property;
class Instinct;
class BulletDef;
class AILeaf;
class UnitDef;

typedef Delegate<void (UnitAction* action)> UnitActionHandler;

class Unit : public Body
{
	typedef unordered_map<string, Own<UnitAction>> ActionMap;
public:
	// Class properties
	PROPERTY(Playable*, Playable);
	PROPERTY(BulletDef*, BulletDef);
	PROPERTY(float, DetectDistance);
	PROPERTY_CREF(Size, AttackRange);
	PROPERTY_BOOL(FaceRight);
	PROPERTY_BOOL(ReceivingDecisionTrace);
	PROPERTY_READONLY(Entity*, Entity);
	PROPERTY_READONLY(Sensor*, GroundSensor);
	PROPERTY_READONLY(Sensor*, DetectSensor);
	PROPERTY_READONLY(Sensor*, AttackSensor);
	PROPERTY_READONLY(UnitDef*, UnitDef);
	PROPERTY_READONLY(UnitAction*, CurrentAction);
	PROPERTY_READONLY(float, Width);
	PROPERTY_READONLY(float, Height);
	virtual bool init() override;
	virtual void setGroup(Uint8 group) override;
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
	// Dynamic properties
	float sensity;
	float move;
	float moveSpeed;
	float jump;
	float maxHp;
	float attackBase;
	float attackBonus;
	float attackFactor;
	float attackSpeed;
	Vec2 attackPower;
	AttackType attackType;
	AttackTarget attackTarget;
	TargetAllow targetAllow;
	Uint16 damageType;
	Uint16 defenceType;
	// Decision tree AI nodes
	void setDecisionTreeName(String name);
	const string& getDecisionTreeName() const;
	AILeaf* getDecisionTree() const;
	CREATE_FUNC(Unit);
protected:
	Unit(UnitDef* unitDef, PhysicsWorld* physicsWorld, Entity* entity, const Vec2& pos, float rot);
	Unit(String defName, String worldName, Entity* entity, const Vec2& pos, float rot);
private:
	WRef<Entity> _entity;
	float _detectDistance;
	Size _attackRange;
	string _decisionTreeName;
	Ref<AILeaf> _decisionTree;
	Ref<UnitDef> _unitDef;
	Ref<BulletDef> _bulletDef;
	WRef<Playable> _playable;
	Size _size;
	Sensor* _groundSensor;
	Sensor* _detectSensor;
	Sensor* _attackSensor;
	UnitAction* _currentAction;
	ActionMap _actions;
	enum
	{
		FaceRight = BodyUserFlag,
		ReceivingDecisionTrace = BodyUserFlag << 1
	};
	DORA_TYPE_OVERRIDE(Unit);
};

NS_DOROTHY_PLATFORMER_END
