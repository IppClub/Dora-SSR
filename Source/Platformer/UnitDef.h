/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN
class BodyDef;
class ModelDef;
class World;
class Array;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN
class Unit;
class BulletDef;

class UnitDef : public Object
{
public:
	enum {GroundSensorTag = 0, DetectSensorTag = 1, AttackSensorTag = 2};
	static const Slice BulletKey;
	static const Slice AttackKey;
	static const Slice HitKey;
	//Most are static properties below.
	PROPERTY_STRING(Model);
	PROPERTY_REF(Size, Size);
	PROPERTY(float, Density);
	PROPERTY(float, Friction);
	PROPERTY(float, Restitution);
	PROPERTY(float, Scale);
	PROPERTY_BOOL(Static);
	PROPERTY_READONLY(ModelDef*, ModelDef);
	PROPERTY_READONLY_CALL(BodyDef*, BodyDef);
	string tag;
	float sensity;
	float move;
	float jump;
	float detectDistance;
	float maxHp;
	float attackBase;
	float attackDelay;
	float attackEffectDelay;
	string decisionTree;
	Size attackRange;
	Vec2 attackPower;
	AttackType attackType;
	AttackTarget attackTarget;
	TargetAllow targetAllow;
	Uint16 damageType;
	Uint16 defenceType;
	string bulletType;
	string attackEffect;
	string hitEffect;
	string name;
	string desc;
	string sndAttack;
	string sndFallen;
	vector<string> actions;
	bool usePreciseHit;
	CREATE_FUNC(UnitDef);
protected:
	UnitDef();
	void updateBodyDef();
	bool _physicsDirty;
	float _scale;
	Size _size;
	string _model;
	Ref<BodyDef> _bodyDef;
	Ref<ModelDef> _modelDef;
	float _density;
	float _friction;
	float _restitution;
	static const float BOTTOM_OFFSET;
	static const float GROUND_SENSOR_HEIGHT;
	DORA_TYPE_OVERRIDE(UnitDef);
};

NS_DOROTHY_PLATFORMER_END
