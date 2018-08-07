/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Platformer/Unit.h"
#include "Platformer/UnitDef.h"
#include "Platformer/UnitAction.h"
#include "Platformer/Data.h"
#include "Platformer/BulletDef.h"
#include "Platformer/AINode.h"
#include "Platformer/AI.h"

#include "Animation/ModelDef.h"
#include "Node/Model.h"
#include "Physics/Sensor.h"
#include "Physics/Body.h"
#include "Physics/BodyDef.h"
#include "Physics/PhysicsWorld.h"
#include "Platformer/Property.h"

NS_DOROTHY_PLATFORMER_BEGIN

Unit::Unit(UnitDef* unitDef, PhysicsWorld* world) :
Body(unitDef->getBodyDef(), world),
_model(nullptr),
_detectSensor(nullptr),
_attackSensor(nullptr),
_currentAction(nullptr),
_size(unitDef->getSize()),
move(unitDef->move),
moveSpeed(1.0f),
jump(unitDef->jump),
attackSpeed(1.0f),
maxHp(unitDef->maxHp),
attackBase(unitDef->attackBase),
attackBonus(0),
attackFactor(1.0f),
attackType(unitDef->attackType),
attackTarget(unitDef->attackTarget),
attackPower(unitDef->attackPower),
targetAllow(unitDef->targetAllow),
damageType(unitDef->damageType),
defenceType(unitDef->defenceType),
sensity(unitDef->sensity),
_unitDef(unitDef)
{ }

bool Unit::init()
{
	if (!Body::init()) return false;
	properties(this);
	_instincts(this);
	Unit::setDetectDistance(_unitDef->detectDistance);
	Unit::setAttackRange(_unitDef->attackRange);
	Unit::setTag(_unitDef->tag);
	_groundSensor = Body::getSensorByTag(UnitDef::GroundSensorTag);
	Unit::setAngle(-bx::toDeg(Body::getBodyDef()->angle));
	ModelDef* modelDef = _unitDef->getModelDef();
	Model* model = modelDef ? Model::create(modelDef) : Model::none();
	_isFaceRight = !modelDef || modelDef->isFaceRight();
	model->setScaleX(_unitDef->getScale());
	model->setScaleY(_unitDef->getScale());
	Unit::setModel(model);
	Body::setOwner(this);
	for (const string& name : _unitDef->actions)
	{
		Unit::attachAction(name);
	}
	for (const string& id : _unitDef->instincts)
	{
		Unit::attachInstinct(id);
	}
	Unit::setReflexArc(_unitDef->reflexArc);
	this->scheduleUpdate();
	return true;
}

UnitDef* Unit::getUnitDef() const
{
	return _unitDef;
}

void Unit::setFaceRight(bool var)
{
	if (_isFaceRight != var)
	{
		_isFaceRight = var;
		if (_model)
		{
			_model->setFaceRight(var);
		}
	}
}

bool Unit::isFaceRight() const
{
	return _isFaceRight;
}

void Unit::setModel(Model* model)
{
	if (_model != model)
	{
		if (_model != nullptr)
		{
			this->removeChild(_model, true);
		}
		if (model)
		{
			this->addChild(model);
			model->setFaceRight(_isFaceRight);
		}
		_model = model;
	}
}

Model* Unit::getModel() const
{
	return _model;
}

Unit* Unit::create(UnitDef* unitDef, PhysicsWorld* world, const Vec2& pos, float rot)
{
	unitDef->getBodyDef()->position = PhysicsWorld::b2Val(pos);
	unitDef->getBodyDef()->angle = -bx::toRad(rot);
    Unit* unit = new Unit(unitDef, world);
    if (unit && unit->init())
	{
		unit->autorelease();
	}
	else
	{
		delete unit;
		unit = nullptr;
	}
	return unit;
}

bool Unit::update(double deltaTime)
{
	if (!_bodyB2->IsActive()) return false;
	if (_currentAction != nullptr)
	{
		_currentAction->update(s_cast<float>(deltaTime));
		if (_currentAction && !_currentAction->isDoing())
		{
			_currentAction = nullptr;
		}
	}
	else
	{
		SharedAI.conditionedReflex(this);
	}
	return Body::update(deltaTime);
}

void Unit::setGroup(int group)
{
	_group = group;
	for (b2Fixture* f = _bodyB2->GetFixtureList();f;f = f->GetNext())
	{
		if (f->IsSensor())
		{
			Sensor* sensor = r_cast<Sensor*>(f->GetUserData());
			if (sensor->getTag() != UnitDef::GroundSensorTag)
			{
				continue;
			}
		}
		f->SetFilterData(Body::getWorld()->getFilter(group));
	}
}

float Unit::getWidth() const
{
	return _size.width;
}

float Unit::getHeight() const
{
	return _size.height;
}

UnitAction* Unit::attachAction(String name)
{
	auto it = _actions.find(name);
	if (it == _actions.end())
	{
		Own<UnitAction> action = UnitAction::alloc(name, this);
		if (action)
		{
			_actions[name] = std::move(action);
		}
		actionAdded(action);
		return action;
	}
	return it->second;
}

void Unit::removeAction(String name)
{
	auto it = _actions.find(name);
	if (it != _actions.end())
	{
		_actions.erase(it);
	}
}

void Unit::removeAllActions()
{
	_actions.clear();
}

UnitAction* Unit::getAction(String name) const
{
	auto it = _actions.find(name);
	return it == _actions.end() ? nullptr : it->second.get();
}

void Unit::eachAction(const UnitActionHandler& func)
{
	for (const auto& pair : _actions)
	{
		func(pair.second);
	}
}

bool Unit::start(String name)
{
	auto it = _actions.find(name);
	if (it != _actions.end())
	{
		UnitAction* action = it->second;
		if (action->isDoing()) return true;
		if (action->isAvailable())
		{
			if (_currentAction != nullptr && _currentAction->isDoing())
			{
				if (_currentAction->getPriority() < action->getPriority())
				{
					_currentAction->stop();
					_currentAction = nullptr;
				}
				else
				{
					return false;
				}
			}
			action->run();
			if (action->isDoing())
			{
				_currentAction = action;
			}
			return true;
		}
	}
	return false;
}

void Unit::stop()
{
	if (_currentAction && _currentAction->isDoing())
	{
		_currentAction->stop();
	}
}

bool Unit::isDoing(String name)
{
	return _currentAction && _currentAction->getName() == name && _currentAction->isDoing();
}

bool Unit::isOnSurface() const
{
	return _groundSensor && _groundSensor->isSensed();
}

void Unit::setDetectDistance(float var)
{
	_detectDistance = var;
	if (_detectSensor)
	{
		Body::removeSensor(_detectSensor);
		_detectSensor = nullptr;
	}
	if (var > 0)
	{
		_detectSensor = Body::attachSensor(UnitDef::DetectSensorTag, BodyDef::circle(var));
		_detectSensor->setGroup(SharedData.getGroupDetectPlayer());
	}
}

void Unit::setAttackRange(const Size& var)
{
	_attackRange = var;
	if (_attackSensor)
	{
		Body::removeSensor(_attackSensor);
		_attackSensor = nullptr;
	}
	if (var.width != 0.0f && var.height != 0.0f)
	{
		_attackSensor = Body::attachSensor(UnitDef::AttackSensorTag, BodyDef::polygon(var.width*2, var.height));
		_attackSensor->setGroup(SharedData.getGroupDetectPlayer());
	}
}

const Size& Unit::getAttackRange() const
{
	return _attackRange;
}

float Unit::getDetectDistance() const
{
	return _detectDistance;
}

Sensor* Unit::getGroundSensor() const
{
	return _groundSensor;
}

Sensor* Unit::getDetectSensor() const
{
	return _detectSensor;
}

Sensor* Unit::getAttackSensor() const
{
	return _attackSensor;
}

void Unit::setBulletDef(BulletDef* var)
{
	_bulletDef = var;
}

BulletDef* Unit::getBulletDef() const
{
	return _bulletDef;
}

UnitAction* Unit::getCurrentAction() const
{
	return _currentAction;
}

// PropertySet
Unit::PropertySet::~PropertySet()
{
	for (auto it : _items) delete it.second;
}

void Unit::PropertySet::operator()(Unit* owner)
{
	_owner = owner;
	_items["hp"] = new Property(_owner, _owner->maxHp); // Add the default property "hp"
}

Property& Unit::PropertySet::operator[](String name)
{
	return *(PropertySet::add(name));
}

const Property& Unit::PropertySet::operator[](String name) const
{
	return *(_items.find(name)->second);
}

void Unit::PropertySet::remove(String name)
{
	if (name != "hp")
	{
		auto it = _items.find(name);
		if (it != _items.end())
		{
			_items.erase(it);
		}
	}
}

void Unit::PropertySet::clear()
{
	float temp = *_items["hp"];
	_items.clear();
	for (auto it : _items) delete it.second;
	_items["hp"] = new Property(_owner, temp); // Add the default property "hp"
}

Property* Unit::PropertySet::add(String name)
{
	auto it = _items.find(name);
	if (it != _items.end())
	{
		return it->second;
	}
	else
	{
		Property* prop = new Property(_owner);
		_items[name] = prop;
		_owner->_instincts.reinstall();
		return prop;
	}
}

Property* Unit::PropertySet::get(String name) const
{
	auto it = _items.find(name);
	return it == _items.end() ? nullptr : it->second;
}

// InstinctSet
void Unit::InstinctSet::add(Instinct* instinct)
{
	_instincts.push_back(instinct);
	instinct->install(_owner);
}

void Unit::InstinctSet::remove(Instinct* instinct)
{
	Ref<Instinct> temp(instinct);
	if (_instincts.remove(instinct))
	{
		instinct->uninstall(_owner);
	}
}

void Unit::InstinctSet::clear()
{
	for (Instinct* instinct : _instincts)
	{
		instinct->uninstall(_owner);
	}
	_instincts.clear();
}

void Unit::InstinctSet::operator()(Unit* owner)
{
	_owner = owner;
}

void Unit::InstinctSet::reinstall()
{
	for (Instinct* instinct : _instincts)
	{
		instinct->install(_owner);
	}
}

void Unit::setReflexArc(String name)
{
	_reflexArcName = name;
	AILeaf* leaf = SharedAI.get(name);
	if (leaf)
	{
		_reflexArc = leaf;
		SharedAI.conditionedReflex(this);
	}
}

const string& Unit::getReflexArc() const
{
	return _reflexArcName;
}

AILeaf* Unit::getReflexArcNode()
{
	return _reflexArc;
}

void Unit::set(String name, float value)
{
	properties[name] = value;
}

float Unit::get(String name)
{
	return *(properties.add(name));
}

void Unit::remove(String name)
{
	properties.remove(name);
}

void Unit::clear()
{
	properties.clear();
}

void Unit::attachInstinct(String id)
{
	Instinct* instinct = Instinct::get(id);
	if (instinct)
	{
		_instincts.add(instinct);
	}
}

void Unit::removeInstinct(String id)
{
	Instinct* instinct = Instinct::get(id);
	if (instinct)
	{
		_instincts.remove(instinct);
	}
}

void Unit::removeAllInstincts()
{
	_instincts.clear();
}

NS_DOROTHY_PLATFORMER_END
