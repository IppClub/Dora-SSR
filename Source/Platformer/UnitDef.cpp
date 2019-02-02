/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Support/Geometry.h"
#include "Support/Array.h"
#include "Support/Value.h"
#include "Platformer/UnitDef.h"
#include "Platformer/Unit.h"
#include "Platformer/BulletDef.h"
#include "Platformer/AI.h"

#include "Animation/ModelDef.h"
#include "Cache/ModelCache.h"
#include "Physics/BodyDef.h"
#include "Physics/PhysicsWorld.h"
#include "Platformer/VisualCache.h"
#include "Physics/Sensor.h"

NS_DOROTHY_PLATFORMER_BEGIN

const float UnitDef::BOTTOM_OFFSET(1.0f);
const float UnitDef::GROUND_SENSOR_HEIGHT(1.0f);
const Slice UnitDef::BulletKey = "bullet"_slice;
const Slice UnitDef::AttackKey = "attack"_slice;
const Slice UnitDef::HitKey = "hit"_slice;

UnitDef::UnitDef() :
tag(),
decisionTree(),
_scale(1.0f),
_physicsDirty(true),
sensity(0),
move(0),
jump(0),
maxHp(0),
detectDistance(0),
attackBase(0),
attackDelay(0),
attackEffect(),
attackEffectDelay(0),
attackRange(),
attackPower(),
attackType(AttackType::Melee),
attackTarget(AttackTarget::Single),
damageType(0),
defenceType(0),
hitEffect(),
bulletType(),
_bodyDef(BodyDef::create()),
_density(1.0f),
_friction(0.4f),
_restitution(0.4f),
usePreciseHit(true),
_size{}
{ }

BodyDef* UnitDef::getBodyDef()
{
	UnitDef::updateBodyDef();
	return _bodyDef;
}

ModelDef* UnitDef::getModelDef() const
{
	return _modelDef;
}

const Size& UnitDef::getSize() const
{
	return _size;
}

void UnitDef::setSize(const Size& size)
{
	_size = size;
	_physicsDirty = true;
}

void UnitDef::setDensity(float density)
{
	_density = density;
	_physicsDirty = true;
}

float UnitDef::getDensity() const
{
	return _density;
}

void UnitDef::setFriction(float friction)
{
	_friction = friction;
	_physicsDirty = true;
}

float UnitDef::getFriction() const
{
	return _friction;
}

void UnitDef::setRestitution(float restitution)
{
	_restitution = restitution;
	_physicsDirty = true;
}

float UnitDef::getRestitution() const
{
	return _restitution;
}

void UnitDef::setScale(float var)
{
	_scale = var;
}

float UnitDef::getScale() const
{
	return _scale;
}

void UnitDef::updateBodyDef()
{
	if (_size == Size::zero) return;
	_bodyDef->clearFixtures();
	_bodyDef->setFixedRotation(false);
	if (_size.width != 0.0f && _size.height != 0.0f)
	{
		_bodyDef->setFixedRotation(true);
		float hw = _size.width * 0.5f;
		float hh = _size.height * 0.5f;
		Vec2 vertices[] =
		{
			Vec2{-hw, hh},
			Vec2{-hw, BOTTOM_OFFSET - hh},
			Vec2{-hw + BOTTOM_OFFSET, -hh},
			Vec2{hw - BOTTOM_OFFSET, -hh},
			Vec2{hw, BOTTOM_OFFSET - hh},
			Vec2{hw, hh}
		};
		_bodyDef->attachPolygon(vertices, 6, _density, _friction, _restitution);
		_bodyDef->attachPolygonSensor(
			UnitDef::GroundSensorTag,
			_size.width - BOTTOM_OFFSET * 2,
			GROUND_SENSOR_HEIGHT,
			Vec2{0, -hh},
			0);
	}
}

void UnitDef::setModel(String modelFile)
{
	_model = modelFile;
	if (!modelFile.empty())
	{
		_modelDef = SharedModelCache.load(modelFile);
		if (_size == Size::zero)
		{
			UnitDef::setSize(_modelDef->getSize());
		}
	}
}

const string& UnitDef::getModel() const
{
	return _model;
}

void UnitDef::setStatic(bool var)
{
	_bodyDef->setType(var ? BodyDef::Static : BodyDef::Dynamic);
}

bool UnitDef::isStatic() const
{
	return _bodyDef->getType() == BodyDef::Static;
}

NS_DOROTHY_PLATFORMER_END
