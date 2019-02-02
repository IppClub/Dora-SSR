/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Lua/LuaHandler.h"

NS_DOROTHY_BEGIN
class Model;
class Body;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

namespace pd = playrho::d2;

class Unit;
class UnitAction;
class Bullet;
class Visual;
typedef Delegate<void (Unit* source, Unit* target, float damage)> DamageHandler;

class UnitActionDef
{
public:
	UnitActionDef(
		LuaFunction<bool> available,
		LuaFunction<LuaFunction<bool>> create,
		LuaFunction<void> stop);
	string name;
	int priority;
	float reaction;
	float recovery;
	LuaFunction<bool> available;
	LuaFunction<LuaFunction<bool>> create;
	LuaFunction<void> stop;
	Own<UnitAction> toAction(Unit* unit);
};

class UnitAction
{
public:
	PROPERTY_READONLY_REF(string, Name);
	PROPERTY_READONLY(int, Priority);
	PROPERTY_READONLY(Unit*, Owner);
	PROPERTY_READONLY(float, EclapsedTime);
	PROPERTY_READONLY_BOOL(Doing);
	virtual ~UnitAction();
	float reaction;
	float recovery;
	virtual bool isAvailable();
	virtual void run();
	virtual void update(float dt);
	virtual void stop();
	static Own<UnitAction> alloc(String name, Unit* unit);
	static void add(
		String name,
		int priority,
		float reaction,
		float recovery,
		LuaFunction<bool> available,
		LuaFunction<LuaFunction<bool>> create,
		LuaFunction<void> stop);
	static void clear();
protected:
	UnitAction(String name, int priority, Unit* owner);
	Unit* _owner;
	float _eclapsedTime;
private:
	bool _isDoing;
	string _name;
	int _priority;
	float _decisionDelay;
	static unordered_map<string, Own<UnitActionDef>> _actionDefs;
};

class ScriptUnitAction : public UnitAction
{
public:
	ScriptUnitAction(String name, int priority, Unit* owner);
	virtual bool isAvailable() override;
	virtual void run() override;
	virtual void update(float dt) override;
	virtual void stop() override;
private:
	function<bool(Unit*,UnitAction*)> _available;
	function<LuaFunction<bool>(Unit*,UnitAction*)> _create;
	function<bool(Unit*,UnitAction*,float)> _update;
	function<void(Unit*,UnitAction*)> _stop;
	friend class UnitActionDef;
};

struct ActionSetting
{
	static const Slice AnimationWalk;
	static const Slice AnimationAttack;
	static const Slice AnimationIdle;
	static const Slice AnimationJump;
	static const Slice AnimationHit;
	static const Slice AnimationFall;

	static const Slice UnitActionWalk;
	static const Slice UnitActionTurn;
	static const Slice UnitActionMeleeAttack;
	static const Slice UnitActionRangeAttack;
	static const Slice UnitActionIdle;
	static const Slice UnitActionCancel;
	static const Slice UnitActionJump;
	static const Slice UnitActionHit;
	static const Slice UnitActionFall;

	static int PriorityWalk;
	static int PriorityTurn;
	static int PriorityJump;
	static int PriorityAttack;
	static int PriorityIdle;
	static int PriorityCancel;
	static int PriorityHit;
	static int PriorityFall;

	static float ReactionWalk;
	static float ReactionIdle;
	static float ReactionJump;

	static float RecoveryWalk;
	static float RecoveryAttack;
	static float RecoveryIdle;
	static float RecoveryJump;
	static float RecoveryHit;
	static float RecoveryFall;

	static const Slice LookNormal;
	static const Slice LookFight;
	static const Slice LookSad;
	static const Slice LookFallen;
};

class Walk : public UnitAction
{
public:
	virtual bool isAvailable() override;
	virtual void run() override;
	virtual void update(float dt) override;
	virtual void stop() override;
	static Own<UnitAction> alloc(Unit* unit);
protected:
	Walk(Unit* unit);
};

class Turn : public UnitAction
{
public:
	Turn(Unit* unit);
	virtual void run();
	static Own<UnitAction> alloc(Unit* unit);
};

class Attack : public UnitAction
{
public:
	virtual ~Attack();
	virtual void run() override;
	virtual void update(float dt) override;
	virtual void stop() override;
	void onAnimationEnd(Model* model);
	float getDamage(Unit* target);
	virtual void onAttack() = 0;
	static Vec2 getHitPoint(Body* self, Body* target, pd::Shape* selfShape);
protected:
	Attack(String name, Unit* unit);
	float _attackDelay;
	float _attackEffectDelay;
};

class MeleeAttack : public Attack
{
public:
	static Own<UnitAction> alloc(Unit* unit);
protected:
	MeleeAttack(Unit* unit);
	virtual void onAttack();
	pd::Shape _polygon;
};

class RangeAttack : public Attack
{
public:
	static Own<UnitAction> alloc(Unit* unit);
	bool onHitTarget(Bullet* bullet, Unit* target, Vec2 hitPoint);
protected:
	RangeAttack(Unit* unit);
	virtual void onAttack();
};

class Idle : public UnitAction
{
public:
	virtual bool isAvailable() override;
	virtual void run() override;
	virtual void update(float dt) override;
	virtual void stop() override;
	static Own<UnitAction> alloc(Unit* unit);
protected:
	Idle(Unit* unit);
};

class Jump : public UnitAction
{
public:
	virtual bool isAvailable() override;
	virtual void run() override;
	virtual void update(float dt) override;
	virtual void stop() override;
	void onAnimationEnd(Model* model);
	static Own<UnitAction> alloc(Unit* unit);
private:
	Jump(Unit* unit);
};

class Cancel : public UnitAction
{
public:
	virtual void run() override;
	static Own<UnitAction> alloc(Unit* unit);
protected:
	Cancel(Unit* unit);
};

class Hit : public UnitAction
{
public:
	virtual ~Hit();
	virtual void run() override;
	virtual void update(float dt) override;
	virtual void stop() override;
	void onAnimationEnd(Model* model);
	static Own<UnitAction> alloc(Unit* unit);
protected:
	Hit(Unit* unit);
	Ref<Visual> _effect;
};

class Fall : public UnitAction
{
public:
	virtual ~Fall();
	virtual void run() override;
	virtual void update(float dt) override;
	virtual void stop() override;
	static Own<UnitAction> alloc(Unit* unit);
	void onAnimationEnd(Model* model);
protected:
	Fall(Unit* unit);
};

NS_DOROTHY_PLATFORMER_END
