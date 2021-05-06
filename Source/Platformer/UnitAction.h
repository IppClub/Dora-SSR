/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

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

NS_BEHAVIOR_BEGIN
enum class Status;
NS_BEHAVIOR_END

namespace pd = playrho::d2;

class Unit;
class UnitAction;
class Bullet;
class Visual;
typedef Acf::Delegate<void (Unit* source, Unit* target, float damage)> DamageHandler;

class UnitActionDef
{
public:
	UnitActionDef(
		LuaFunction<bool> available,
		LuaFunction<LuaFunction<bool>> create,
		LuaFunction<void> stop);
	std::string name;
	int priority = 0;
	float reaction = 0;
	float recovery = 0;
	bool queued = false;
	LuaFunction<bool> available;
	LuaFunction<LuaFunction<bool>> create;
	LuaFunction<void> stop;
	Own<UnitAction> toAction(Unit* unit);
};

class UnitAction
{
public:
	PROPERTY_READONLY(Behavior::Status, Status);
	PROPERTY_READONLY_CREF(std::string, Name);
	PROPERTY_READONLY(int, Priority);
	PROPERTY_READONLY(Unit*, Owner);
	PROPERTY_READONLY(float, EclapsedTime);
	PROPERTY_READONLY_BOOL(Queued);
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
		bool queued,
		LuaFunction<bool> available,
		LuaFunction<LuaFunction<bool>> create,
		LuaFunction<void> stop);
	static void clear();
protected:
	UnitAction(String name, int priority, bool queued, Unit* owner);
	Unit* _owner;
	float _sensity;
	float _eclapsedTime;
private:
	bool _doing;
	bool _queued;
	Behavior::Status _status;
	int _priority;
	float _decisionDelay;
	std::string _name;
	static std::unordered_map<std::string, Own<UnitActionDef>> _actionDefs;
	friend class Unit;
};

class ScriptUnitAction : public UnitAction
{
public:
	ScriptUnitAction(String name, int priority, bool queued, Unit* owner);
	virtual bool isAvailable() override;
	virtual void run() override;
	virtual void update(float dt) override;
	virtual void stop() override;
private:
	std::function<bool(Unit*,UnitAction*)> _available;
	std::function<LuaFunction<bool>(Unit*,UnitAction*)> _create;
	std::function<bool(Unit*,UnitAction*,float)> _update;
	std::function<void(Unit*,UnitAction*)> _stop;
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

	static const int PriorityWalk;
	static const int PriorityTurn;
	static const int PriorityJump;
	static const int PriorityAttack;
	static const int PriorityIdle;
	static const int PriorityCancel;
	static const int PriorityHit;
	static const int PriorityFall;

	static const float ReactionWalk;
	static const float ReactionIdle;
	static const float ReactionJump;

	static const float RecoveryWalk;
	static const float RecoveryAttack;
	static const float RecoveryIdle;
	static const float RecoveryJump;
	static const float RecoveryHit;
	static const float RecoveryFall;

	static const Slice LookNormal;
	static const Slice LookFight;
	static const Slice LookHit;
	static const Slice LookFallen;

	static const Slice HP; // mutable
	static const Slice MoveSpeed; // mutable
	static const Slice Move; // mutable
	static const Slice Jump; // mutable
	static const Slice TargetAllow; // mutable
	static const Slice AttackPower; // mutable
	static const Slice AttackSpeed; // mutable
	static const Slice Sensity;
	static const Slice AttackDelay;
	static const Slice AttackEffectDelay;
	static const Slice AttackEffect;
	static const Slice SndAttack;
	static const Slice DamageType;
	static const Slice DefenceType;
	static const Slice AttackBase;
	static const Slice AttackBonus;
	static const Slice AttackFactor;
	static const Slice UsePreciseHit;
	static const Slice BulletType;
	static const Slice HitEffect;
	static const Slice SndFallen;

	static const Slice AttackKey;

	static const Slice HitPoint;
	static const Slice HitFromRight;
	static const Slice HitPower;
	static const Slice AttackTarget;
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
	void onAnimationEnd(Event* e);
	float getDamage(Unit* target);
	virtual void onAttack() = 0;
	static Vec2 getHitPoint(Body* self, Body* target, const pd::Shape& selfShape);
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
	void onAnimationEnd(Event* event);
	static Own<UnitAction> alloc(Unit* unit);
private:
	Jump(Unit* unit);
	float _duration;
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
	void onAnimationEnd(Event* e);
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
	void onAnimationEnd(Event* e);
protected:
	Fall(Unit* unit);
};

NS_DOROTHY_PLATFORMER_END
