/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Support/Geometry.h"
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

const float UnitDef::BOTTOM_OFFSET(4.0f);
const float UnitDef::GROUND_SENSOR_HEIGHT(4.0f);
const Slice UnitDef::BulletKey = "bullet"_slice;
const Slice UnitDef::AttackKey = "attack"_slice;
const Slice UnitDef::HitKey = "hit"_slice;

UnitDef::UnitDef() :
tag(),
decisionTree(),
_scale(1.0f),
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
usePreciseHit(true)
{ }

BodyDef* UnitDef::getBodyDef() const
{
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
	UnitDef::updateBodyDef();
}

void UnitDef::setDensity(float density)
{
	_density = density;
	_bodyDef->setDensity(density);
}

float UnitDef::getDensity() const
{
	return _density;
}

void UnitDef::setFriction(float friction)
{
	_friction = friction;
	_bodyDef->setFriction(friction);
}

float UnitDef::getFriction() const
{
	return _friction;
}

void UnitDef::setRestitution(float restitution)
{
	_restitution = restitution;
	_bodyDef->setRestitution(restitution);
}

float UnitDef::getRestitution() const
{
	return _restitution;
}

void UnitDef::setScale(float var)
{
	_scale = var;
	UnitDef::updateBodyDef();
}

float UnitDef::getScale() const
{
	return _scale;
}

void UnitDef::updateBodyDef()
{
	_bodyDef->clearFixtures();
	_bodyDef->fixedRotation = false;
	Size size = _size;
	size.width *= _scale;
	size.height *= _scale;
	if (size.width != 0.0f && size.height != 0.0f)
	{
		_bodyDef->fixedRotation = true;
		float hw = size.width * 0.5f;
		float hh = size.height * 0.5f;
		Vec2 vertices[] =
		{
			Vec2{-hw, hh},
			Vec2{-hw + BOTTOM_OFFSET, -hh},
			Vec2{hw - BOTTOM_OFFSET, -hh},
			Vec2{hw, hh}
		};
		_bodyDef->attachPolygon(vertices, 4, _density, _friction, _restitution);
		_bodyDef->attachPolygonSensor(
			UnitDef::GroundSensorTag,
			size.width - BOTTOM_OFFSET * 2,
			GROUND_SENSOR_HEIGHT,
			Vec2{0, -hh - GROUND_SENSOR_HEIGHT * 0.5f},
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
	_bodyDef->type = var ? b2_staticBody : b2_dynamicBody;
}

bool UnitDef::isStatic() const
{
	return _bodyDef->type == b2_staticBody;
}

NS_DOROTHY_PLATFORMER_END
