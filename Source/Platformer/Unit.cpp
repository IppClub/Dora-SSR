/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Platformer/Unit.h"
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
#include "Entity/Entity.h"
#include "Support/Dictionary.h"

NS_DOROTHY_PLATFORMER_BEGIN

const float Unit::BOTTOM_OFFSET(1.0f);
const float Unit::GROUND_SENSOR_HEIGHT(1.0f);

const Slice Unit::Def::Size = "size"_slice;
const Slice Unit::Def::Density = "density"_slice;
const Slice Unit::Def::Friction = "friction"_slice;
const Slice Unit::Def::Restitution = "restitution"_slice;
const Slice Unit::Def::BodyDef = "bodyDef"_slice;
const Slice Unit::Def::LinearAcceleration = "linearAcceleration"_slice;
const Slice Unit::Def::LinearDamping = "linearDamping"_slice;
const Slice Unit::Def::AngularDamping = "angularDamping"_slice;
const Slice Unit::Def::BodyType = "bodyType"_slice;
const Slice Unit::Def::DetectDistance = "detectDistance"_slice;
const Slice Unit::Def::AttackRange = "attackRange"_slice;
const Slice Unit::Def::Tag = "tag"_slice;
const Slice Unit::Def::Playable = "playable"_slice;
const Slice Unit::Def::Scale = "scale"_slice;
const Slice Unit::Def::Actions = "actions"_slice;
const Slice Unit::Def::DecisionTree = "decisionTree"_slice;
const Slice Unit::Def::DefaultFaceRight = "defaultFaceRight"_slice;

BodyDef* Unit::getBodyDef(Dictionary* def) const
{
	auto bodyDef = def->get(Def::BodyDef, (BodyDef*)nullptr);
	if (bodyDef) return bodyDef;
	bodyDef = BodyDef::create();
	bodyDef->setFixedRotation(false);
	auto size = def->get(Unit::Def::Size, Size::zero);
	if (size.width != 0.0f && size.height != 0.0f)
	{
		bodyDef->setFixedRotation(true);
		float hw = size.width * 0.5f;
		float hh = size.height * 0.5f;
		Vec2 vertices[] =
		{
			Vec2{-hw, hh},
			Vec2{-hw, BOTTOM_OFFSET - hh},
			Vec2{-hw + BOTTOM_OFFSET, -hh},
			Vec2{hw - BOTTOM_OFFSET, -hh},
			Vec2{hw, BOTTOM_OFFSET - hh},
			Vec2{hw, hh}
		};
		auto density = def->get(Def::Density, 0.0f);
		auto friction = def->get(Def::Friction, 0.2f);
		auto restitution = def->get(Def::Restitution, 0.0f);
		bodyDef->attachPolygon(vertices, 6, density, friction, restitution);
		bodyDef->attachPolygonSensor(
			Unit::GroundSensorTag,
			size.width - BOTTOM_OFFSET * 2,
			GROUND_SENSOR_HEIGHT,
			Vec2{0, -hh},
			0);
		auto linearAcceleration = def->get(Def::LinearAcceleration, Vec2{0.0f, -10.0f});
		bodyDef->setLinearAcceleration(linearAcceleration);
		auto linearDamping = def->get(Def::LinearDamping, 0.0f);
		bodyDef->setLinearDamping(linearDamping);
		auto angularDamping = def->get(Def::AngularDamping, 0.0f);
		bodyDef->setAngularDamping(angularDamping);
		auto bodyType = def->get(Def::BodyType, Slice::Empty);
		switch (Switch::hash(bodyType))
		{
			case "Static"_hash: bodyDef->setType(pr::BodyType::Static); break;
			case "Dynamic"_hash: bodyDef->setType(pr::BodyType::Dynamic); break;
			case "Kinematic"_hash: bodyDef->setType(pr::BodyType::Kinematic); break;
		}
	}
	return bodyDef;
}

Unit::Unit(Dictionary* unitDef, PhysicsWorld* physicsWorld, Entity* entity, const Vec2& pos, float rot) :
Body(getBodyDef(unitDef), physicsWorld, pos, rot),
_playable(nullptr),
_groundSensor(nullptr),
_detectSensor(nullptr),
_attackSensor(nullptr),
_currentAction(nullptr),
_unitDef(unitDef),
_entity(entity),
_size(unitDef->get(Def::Size, Size::zero))
{ }

Unit::Unit(String defName, String worldName, Entity* entity, const Vec2& pos, float rot):
Unit(
	&SharedData.getStore()->get(defName)->to<Dictionary>(),
	&SharedData.getStore()->get(worldName)->to<PhysicsWorld>(),
	entity, pos, rot)
{ }

bool Unit::init()
{
	if (!Body::init()) return false;
	auto defaultFaceRight = _unitDef->get(Def::DefaultFaceRight, true);
	auto detectDistance = _unitDef->get(Def::DetectDistance, 0.0f);
	auto attackRange = _unitDef->get(Def::AttackRange, Size::zero);
	auto tag = _unitDef->get(Def::Tag, Slice::Empty);
	auto playableStr = _unitDef->get(Def::Playable, Slice::Empty);
	auto scale = _unitDef->get(Def::Scale, 1.0f);
	auto actions = _unitDef->get(Def::Actions, s_cast<Array*>(nullptr));
	_flags.set(Unit::DefaultFaceRight, defaultFaceRight);
	Unit::setDetectDistance(detectDistance);
	Unit::setAttackRange(attackRange);
	Unit::setTag(tag);
	_groundSensor = Body::getSensorByTag(Unit::GroundSensorTag);
	Playable* playable = Playable::create(playableStr);
	playable->setScaleX(scale);
	playable->setScaleY(scale);
	Unit::setPlayable(playable);
	Unit::setFaceRight(true);
	Body::setOwner(this);
	ARRAY_START(std::string, action, actions)
	{
		Unit::attachAction(*action);
	}
	ARRAY_END
	_entity->set("unit"_slice, s_cast<Object*>(this));
	this->scheduleUpdate();
	return true;
}

void Unit::onEnter()
{
	Body::onEnter();
	if (_decisionTree == nullptr)
	{
		auto decisionTree = _unitDef->get(Def::DecisionTree, Slice::Empty);
		Unit::setDecisionTreeName(decisionTree);
	}
}

Dictionary* Unit::getUnitDef() const
{
	return _unitDef;
}

void Unit::setFaceRight(bool var)
{
	_flags.set(Unit::FaceRight, var);
	if (_playable)
	{
		if (_flags.isOn(Unit::DefaultFaceRight))
		{
			_playable->setFliped(!var);
		}
		else
		{
			_playable->setFliped(var);
		}
	}
}

bool Unit::isFaceRight() const
{
	return _flags.isOn(Unit::FaceRight);
}

void Unit::setReceivingDecisionTrace(bool var)
{
	_flags.set(Unit::ReceivingDecisionTrace, var);
}

bool Unit::isReceivingDecisionTrace() const
{
	return _flags.isOn(Unit::ReceivingDecisionTrace);
}

void Unit::setPlayable(Playable* playable)
{
	if (_playable != playable)
	{
		if (_playable != nullptr)
		{
			this->removeChild(_playable, true);
		}
		if (playable)
		{
			this->addChild(playable);
			playable->setFliped(_flags.isOn(Unit::FaceRight));
		}
		_playable = playable;
	}
}

Playable* Unit::getPlayable() const
{
	return _playable;
}

bool Unit::update(double deltaTime)
{
	if (_currentAction)
	{
		if (_currentAction->isDoing())
		{
			_currentAction->update(s_cast<float>(deltaTime));
			if (_currentAction)
			{
				if (_currentAction->isDoing())
				{
					_currentAction->_status = Behavior::Status::Running;
				}
				else
				{
					_currentAction->_status = Behavior::Status::Success;
					_currentAction = nullptr;
				}
			}
		}
		else
		{
			_currentAction->_status = Behavior::Status::Success;
			_currentAction = nullptr;
		}
	}
	else SharedAI.runDecisionTree(this);
	if (_behaviorTree)
	{
		_blackboard->setDeltaTime(deltaTime);
		auto status = _behaviorTree->tick(_blackboard.get());
		if (status != Behavior::Status::Running)
		{
			_blackboard->clear();
			_behaviorTree = nullptr;
		}
	}
	return Body::update(deltaTime);
}

void Unit::cleanup()
{
	if (_entity)
	{
		_entity->destroy();
		_entity = nullptr;
	}
	_currentAction = nullptr;
	_decisionTree = nullptr;
	_unitDef = nullptr;
	_actions.clear();
	Body::cleanup();
}

void Unit::setGroup(Uint8 group)
{
	_group = group;
	auto& world = _pWorld->getPrWorld();
	for (pr::FixtureID f : pd::GetFixtures(world, _prBody))
	{
		if (pd::IsSensor(world, f))
		{
			Sensor* sensor = _pWorld->getFixtureData(f);
			if (sensor && sensor->getTag() != Unit::GroundSensorTag)
			{
				continue;
			}
		}
		pd::SetFilterData(world, f, _pWorld->getFilter(group));
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

Entity* Unit::getEntity() const
{
	return _entity;
}

UnitAction* Unit::attachAction(String name)
{
	auto it = _actions.find(name);
	if (it == _actions.end())
	{
		Own<UnitAction> action = UnitAction::alloc(name, this);
		UnitAction* temp = action.get();
		if (action)
		{
			_actions[name] = std::move(action);
		}
		return temp;
	}
	return it->second.get();
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
		func(pair.second.get());
	}
}

bool Unit::start(String name)
{
	auto it = _actions.find(name);
	if (it != _actions.end())
	{
		UnitAction* action = it->second.get();
		if (action->isDoing()) return true;
		if (action->isAvailable())
		{
			if (_currentAction && _currentAction->isDoing())
			{
				if (_currentAction->getPriority() <= action->getPriority())
				{
					_currentAction->stop();
					_currentAction->_status = Behavior::Status::Failure;
				}
				else
				{
					action->_status = Behavior::Status::Failure;
					return false;
				}
			}
			action->run();
			if (action->isDoing())
			{
				action->_status = Behavior::Status::Running;
				_currentAction = action;
			}
			else
			{
				action->_status = Behavior::Status::Success;
				_currentAction = nullptr;
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
		_currentAction = nullptr;
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
		_detectSensor = Body::attachSensor(Unit::DetectSensorTag, BodyDef::disk(var));
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
		_attackSensor = Body::attachSensor(Unit::AttackSensorTag, BodyDef::polygon(var.width*2, var.height));
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

UnitAction* Unit::getCurrentAction() const
{
	return _currentAction;
}

void Unit::setDecisionTreeName(String name)
{
	_decisionTreeName = name;
	if (const auto& item = SharedData.getStore()->get(name))
	{
		Decision::Leaf* leaf = &item->to<Decision::Leaf>();
		_decisionTree = leaf;
		SharedAI.runDecisionTree(this);
	}
}

const std::string& Unit::getDecisionTreeName() const
{
	return _decisionTreeName;
}

Decision::Leaf* Unit::getDecisionTree() const
{
	return _decisionTree;
}

void Unit::setBehaviorTree(Behavior::Leaf* var)
{
	_behaviorTree = var;
	if (!_blackboard)
	{
		_blackboard = New<Behavior::Blackboard>(this);
	}
	else _blackboard->clear();
}

Behavior::Leaf* Unit::getBehaviorTree() const
{
	return _behaviorTree;
}

NS_DOROTHY_PLATFORMER_END
