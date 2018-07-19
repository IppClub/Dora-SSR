/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Physics/Body.h"

NS_DOROTHY_BEGIN
class Sensor;
class Model;
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
	typedef unordered_map<string, Property*> PropertyMap;
public:
	//Class properties
	PROPERTY(Model*, Model);
	PROPERTY(BulletDef*, BulletDef);
	PROPERTY(float, DetectDistance);
	PROPERTY_REF(Size, AttackRange);
	PROPERTY_BOOL(FaceRight);
	PROPERTY_READONLY(Sensor*, GroundSensor);
	PROPERTY_READONLY(Sensor*, DetectSensor);
	PROPERTY_READONLY(Sensor*, AttackSensor);
	PROPERTY_READONLY(UnitDef*, UnitDef);
	PROPERTY_READONLY(UnitAction*, CurrentAction);
	PROPERTY_READONLY(float, Width);
	PROPERTY_READONLY(float, Height);
	//
	virtual bool init() override;
	virtual void setGroup(int group) override;
	virtual bool update(double deltaTime) override;
	// Actions
	UnitAction* attachAction(String name);
	void removeAction(String name);
	void removeAllActions();
	UnitAction* getAction(String name) const;
	void eachAction(const UnitActionHandler& func);
	UnitActionHandler actionAdded;

	bool start(String name);
	void stop();
	bool isDoing(String name);
	//
	bool isOnSurface() const;

	//Named properties
	class PropertySet
	{
	public:
		~PropertySet();
		Property& operator[](String name);
		const Property& operator[](String name) const;
		Property* add(String name);
		Property* get(String name) const;
		void remove(String name);
		void clear();
	private:
		void operator()(Unit* owner);
		Unit* _owner;
		PropertyMap _items;
		friend class Unit;
	} properties;
	//Methods for script to use properties
	void set(String name, float value);
	float get(String name);
	void remove(String name);
	void clear();
	//Dynamic properties
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
	//Instinct for script
	void attachInstinct(String id);
	void removeInstinct(String id);
	void removeAllInstincts();
	//Conditioned Reflex
	void setReflexArc(String name);
	const string& getReflexArc() const;
	AILeaf* getReflexArcNode();

	static Unit* create(UnitDef* unitDef, World* world, const Vec2& pos = Vec2::zero, float rot = 0.0f);
protected:
	Unit(UnitDef* unitDef, World* world);
	//Instinct
	class InstinctSet
	{
	public:
		void add(Instinct* instinct);
		void remove(Instinct* instinct);
		void reinstall();
		void clear();
	private:
		void operator()(Unit* owner);
		Unit* _owner;
		RefVector<Instinct> _instincts;
		friend class Unit;
	} _instincts;
private:
	bool _isFaceRight;
	float _detectDistance;
	Size _attackRange;
	string _reflexArcName;
	Ref<UnitDef> _unitDef;
	Ref<AILeaf> _reflexArc;
	Ref<BulletDef> _bulletDef;
	Ref<Model> _model;
	Size _size;
	Sensor* _groundSensor;
	Sensor* _detectSensor;
	Sensor* _attackSensor;
	UnitAction* _currentAction;
	ActionMap _actions;
	DORA_TYPE_OVERRIDE(Unit);
};

NS_DOROTHY_PLATFORMER_END
