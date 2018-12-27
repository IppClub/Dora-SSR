/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Support/Geometry.h"
#include "Platformer/UnitAction.h"
#include "Platformer/Unit.h"
#include "Platformer/UnitDef.h"
#include "Platformer/Data.h"
#include "Platformer/BulletDef.h"
#include "Platformer/Bullet.h"
#include "Platformer/AI.h"
#include "Animation/ModelDef.h"
#include "Node/Model.h"
#include "Physics/Sensor.h"
#include "Physics/PhysicsWorld.h"
#include "Platformer/VisualCache.h"
#include "Lua/LuaHandler.h"
#include "Audio/Sound.h"
#include "Entity/Entity.h"

NS_DOROTHY_PLATFORMER_BEGIN

UnitActionDef::UnitActionDef(
	LuaFunction<bool> available,
	LuaFunction<LuaFunction<bool>> create,
	LuaFunction<void> stop):
available(available),
create(create),
stop(stop)
{ }

Own<UnitAction> UnitActionDef::toAction(Unit* unit)
{
	ScriptUnitAction* action = new ScriptUnitAction(name, priority, unit);
	action->reaction = reaction;
	action->recovery = recovery;
	action->_available = available;
	action->_create = create;
	action->_stop = stop;
	return MakeOwn(s_cast<UnitAction*>(action));
}

// UnitAction

unordered_map<string, Own<UnitActionDef>> UnitAction::_actionDefs;

UnitAction::UnitAction(String name, int priority, Unit* owner):
_name(name),
_priority(priority),
_isDoing(false),
_owner(owner),
reaction(-1.0f),
_eclapsedTime(0.0f)
{ }

UnitAction::~UnitAction()
{
	_owner = nullptr;
}

const string& UnitAction::getName() const
{
	return _name;
}

int UnitAction::getPriority() const
{
	return _priority;
}

bool UnitAction::isDoing() const
{
	return _isDoing;
}

Unit* UnitAction::getOwner() const
{
	return _owner;
}

bool UnitAction::isAvailable()
{
	return true;
}

float UnitAction::getEclapsedTime() const
{
	return _eclapsedTime;
}

void UnitAction::run()
{
	_isDoing = true;
	_decisionDelay = 0.0f;
	_eclapsedTime = 0.0f;
}

void UnitAction::update(float dt)
{
	_eclapsedTime += dt;
	float reactionTime = _owner->sensity * UnitAction::reaction;
	if (reactionTime >= 0)
	{
		_decisionDelay += dt;
		if (_decisionDelay >= reactionTime)
		{
			_decisionDelay = 0.0f;
			// Check AI here
			SharedAI.runDecisionTree(_owner);
		}
	}
}

void UnitAction::stop()
{
	_isDoing = false;
	_eclapsedTime = 0.0f;
	_decisionDelay = 0.0f;
}

void UnitAction::add(
	String name, int priority, float reaction, float recovery,
	LuaFunction<bool> available,
	LuaFunction<LuaFunction<bool>> create,
	LuaFunction<void> stop)
{
	UnitActionDef* actionDef = new UnitActionDef(available, create, stop);
	actionDef->name = name;
	actionDef->priority = priority;
	actionDef->reaction = reaction;
	actionDef->recovery = recovery;
	_actionDefs[name] = MakeOwn(actionDef);
}

void UnitAction::clear()
{
	_actionDefs.clear();
}

ScriptUnitAction::ScriptUnitAction(String name, int priority, Unit* owner):
UnitAction(name, priority, owner)
{ }

bool ScriptUnitAction::isAvailable()
{
	return _available(_owner, s_cast<UnitAction*>(this));
}

void ScriptUnitAction::run()
{
	UnitAction::run();
	_update = _create(_owner, s_cast<UnitAction*>(this));
	if (_update(_owner, s_cast<UnitAction*>(this), 0.0f))
	{
		ScriptUnitAction::stop();
	}
}

void ScriptUnitAction::update(float dt)
{
	if (_update && _update(_owner, s_cast<UnitAction*>(this), dt))
	{
		ScriptUnitAction::stop();
	}
	UnitAction::update(dt);
}

void ScriptUnitAction::stop()
{
	_update = nullptr;
	_stop(_owner, s_cast<UnitAction*>(this));
	UnitAction::stop();
}

// Walk

Walk::Walk(Unit* unit):
UnitAction(ActionSetting::UnitActionWalk, ActionSetting::PriorityWalk, unit)
{
	UnitAction::reaction = ActionSetting::ReactionWalk;
	UnitAction::recovery = ActionSetting::RecoveryWalk;
}

bool Walk::isAvailable()
{
	return _owner->isOnSurface();
}

void Walk::run()
{
	Model* model = _owner->getModel();
	model->setSpeed(_owner->moveSpeed);
	model->setLoop(true);
	model->setLook(ActionSetting::LookNormal);
	model->setRecovery(UnitAction::recovery);
	model->resume(ActionSetting::AnimationWalk);
	UnitAction::run();
}

void Walk::update(float dt)
{
	if (_owner->isOnSurface())
	{
		float move = _owner->move * _owner->moveSpeed;
		if (_eclapsedTime < UnitAction::recovery)
		{
			move *= std::min(_eclapsedTime / UnitAction::recovery, 1.0f);
		}
		_owner->setVelocityX(_owner->isFaceRight() ? move : -move);
	}
	else
	{
		Walk::stop();
	}
	UnitAction::update(dt);
}

void Walk::stop()
{
	UnitAction::stop();
	_owner->getModel()->pause();
}

Own<UnitAction> Walk::alloc(Unit* unit)
{
	UnitAction* action = new Walk(unit);
	return MakeOwn(action);
}

// Turn

Turn::Turn(Unit* unit):
UnitAction(ActionSetting::UnitActionTurn, ActionSetting::PriorityTurn, unit)
{ }

void Turn::run()
{
	_owner->setFaceRight(!_owner->isFaceRight());
}

Own<UnitAction> Turn::alloc(Unit* unit)
{
	UnitAction* action = new Turn(unit);
	return MakeOwn(action);
}

Idle::Idle(Unit* unit):
UnitAction(ActionSetting::UnitActionIdle, ActionSetting::PriorityIdle, unit)
{
	UnitAction::reaction = ActionSetting::ReactionIdle;
	UnitAction::recovery = ActionSetting::RecoveryIdle;
}

bool Idle::isAvailable()
{
	return _owner->isOnSurface();
}

void Idle::run()
{
	UnitAction::run();
	if (_owner->isOnSurface())
	{
		Model* model = _owner->getModel();
		model->setSpeed(1.0f);
		model->setLoop(true);
		model->setLook(ActionSetting::LookNormal);
		model->setRecovery(UnitAction::recovery);
		model->resume(ActionSetting::AnimationIdle);
	}
	else
	{
		Idle::stop();
	}
}

void Idle::update(float dt)
{
	Model* model = _owner->getModel();
	if (_owner->isOnSurface())
	{
		if (_owner->getModel()->getCurrentAnimationName() != ActionSetting::AnimationIdle)
		{
			model->resume(ActionSetting::AnimationIdle);
		}
	}
	else
	{
		Idle::stop();
	}
	UnitAction::update(dt);
}

void Idle::stop()
{
	UnitAction::stop();
	_owner->getModel()->pause();
}

Own<UnitAction> Idle::alloc(Unit* unit)
{
	UnitAction* action = new Idle(unit);
	return MakeOwn(action);
}

Jump::Jump(Unit* unit):
UnitAction(ActionSetting::UnitActionJump, ActionSetting::PriorityJump, unit)
{
	UnitAction::reaction = ActionSetting::ReactionJump;
	UnitAction::recovery = ActionSetting::RecoveryJump;
}

bool Jump::isAvailable()
{
	return _owner->isOnSurface();
}

void Jump::run()
{
	Model* model = _owner->getModel();
	model->setSpeed(1.0f);
	model->setLoop(false);
	model->setLook(ActionSetting::LookNormal);
	model->setRecovery(UnitAction::recovery);
	model->resume(ActionSetting::AnimationJump);
	model->handlers[ActionSetting::AnimationJump] += std::make_pair(this, &Jump::onAnimationEnd);
	_owner->setVelocityY(_owner->jump);
	Sensor* sensor = _owner->getGroundSensor();
	b2Body* self = _owner->getB2Body();
	b2Body* target = sensor->getSensedBodies()->get(0).to<Body>()->getB2Body();
	b2DistanceInput input =
	{
		b2DistanceProxy(self->GetFixtureList()->GetShape(), 0),
		b2DistanceProxy(target->GetFixtureList()->GetShape(), 0),
		self->GetTransform(),
		target->GetTransform()
	};
	b2DistanceOutput output;
	b2Distance(&output, &input);
	target->ApplyLinearImpulse(
		b2Vec2(-self->GetMass() * self->GetLinearVelocityX(),
			-self->GetMass() * self->GetLinearVelocityY()),
			output.pointB, true);
	UnitAction::run();
}

void Jump::update(float dt)
{
	if (_eclapsedTime > 0.2f) // don`t do update for a while, for actor won`t lift immediately.
	{
		UnitAction::update(dt);
	}
	else _eclapsedTime += dt;
}

void Jump::stop()
{
	UnitAction::stop();
	_owner->getModel()->pause();
}

void Jump::onAnimationEnd(Model* model)
{
	Jump::stop();
}

Own<UnitAction> Jump::alloc(Unit* unit)
{
	UnitAction* action = new Jump(unit);
	return MakeOwn(action);
}

Cancel::Cancel(Unit* unit):
UnitAction(ActionSetting::UnitActionCancel, ActionSetting::PriorityCancel, unit)
{ }

void Cancel::run()
{ }

Own<UnitAction> Cancel::alloc(Unit* unit)
{
	UnitAction* action = new Cancel(unit);
	return MakeOwn(action);
}

// Attack

Attack::Attack(String name, Unit* unit ):
UnitAction(name, ActionSetting::PriorityAttack, unit)
{
	UnitAction::recovery = ActionSetting::RecoveryAttack;
}

Attack::~Attack()
{ }

void Attack::run()
{
	_attackDelay = _owner->getUnitDef()->attackDelay / _owner->attackSpeed;
	_attackEffectDelay = _owner->getUnitDef()->attackEffectDelay / _owner->attackSpeed;
	Model* model = _owner->getModel();
	model->handlers[ActionSetting::AnimationAttack] += std::make_pair(this, &Attack::onAnimationEnd);
	model->setLoop(false);
	model->setLook(ActionSetting::LookFight);
	model->setRecovery(UnitAction::recovery);
	model->setSpeed(_owner->attackSpeed);
	model->play(ActionSetting::AnimationAttack);
	UnitAction::run();
}

void Attack::update(float dt)
{
	_eclapsedTime += dt;
	if (_attackDelay >= 0 && _eclapsedTime >= _attackDelay)
	{
		_attackDelay = -1;
		if (!_owner->getUnitDef()->sndAttack.empty())
		{
			SharedAudio.play(_owner->getUnitDef()->sndAttack);
		}
		this->onAttack();
	}
	if (_attackEffectDelay >= 0 && _eclapsedTime >= _attackEffectDelay)
	{
		_attackEffectDelay = -1;
		const string& attackEffect = _owner->getUnitDef()->attackEffect;
		if (!attackEffect.empty())
		{
			Vec2 key = _owner->getModel()->getModelDef()->getKeyPoint(UnitDef::AttackKey);
			if (_owner->getModel()->getModelDef()->isFaceRight() != _owner->isFaceRight())
			{
				key.x = -key.x;
			}
			Visual* effect = Visual::create(attackEffect);
			effect->setPosition(key);
			effect->addTo(_owner);
			effect->autoRemove();
			effect->start();
		}
	}
}

void Attack::stop()
{
	Model* model = _owner->getModel();
	model->handlers[ActionSetting::AnimationAttack] -= std::make_pair(this, &Attack::onAnimationEnd);
	model->stop();
	UnitAction::stop();
}

void Attack::onAnimationEnd(Model* model)
{
	if (UnitAction::isDoing())
	{
		this->stop();
	}
}

float Attack::getDamage(Unit* target)
{
	float factor = SharedData.getDamageFactor(_owner->damageType, target->defenceType);
	float damage = (_owner->attackBase + _owner->attackBonus) * (_owner->attackFactor + factor);
	return damage;
}

Vec2 Attack::getHitPoint(Body* self, Body* target, b2Shape* selfShape)
{
	Vec2 hitPoint{};
	float distance = -1;
	for (b2Fixture* f = target->getB2Body()->GetFixtureList();f;f = f->GetNext())
	{
		if (!f->IsSensor())
		{
			b2DistanceInput input =
			{
				b2DistanceProxy(selfShape, 0),
				b2DistanceProxy(f->GetShape(), 0),
				self->getB2Body()->GetTransform(),
				target->getB2Body()->GetTransform()
			};
			b2DistanceOutput output;
			b2Distance(&output, &input);
			if (distance == -1 || distance > output.distance)
			{
				distance = output.distance;
				hitPoint = PhysicsWorld::oVal(output.pointB);
			}
		}
	}
	return hitPoint;
}

// MeleeAttack

MeleeAttack::MeleeAttack(Unit* unit):
Attack(ActionSetting::UnitActionMeleeAttack, unit)
{
	_polygon.SetAsBox(PhysicsWorld::b2Val(_owner->getWidth()*0.5f), 0.0005f);
}

void MeleeAttack::onAttack()
{
	Sensor* sensor = _owner->getAttackSensor();
	if (sensor)
	{
		ARRAY_START(Body, body, sensor->getSensedBodies())
		{
			Unit* target = DoraCast<Unit>(body->getOwner());
			BLOCK_START
			{
				BREAK_UNLESS(target);
				bool attackRight = _owner->getPosition().x < target->getPosition().x;
				bool faceRight = _owner->isFaceRight();
				BREAK_IF(attackRight != faceRight); // !(hitRight == faceRight || hitLeft == faceLeft)
				Relation relation = SharedData.getRelation(_owner, target);
				BREAK_IF(!_owner->targetAllow.isAllow(relation));
				/* Get hit point */
				Hit* hitUnitAction = s_cast<Hit*>(target->getAction(ActionSetting::UnitActionHit));
				if (hitUnitAction)
				{
					Vec2 hitPoint = _owner->getUnitDef()->usePreciseHit ? Attack::getHitPoint(_owner, target, &_polygon) : Vec2(target->getPosition());
					hitUnitAction->setHitInfo(hitPoint, _owner->attackPower, !attackRight);
				}
				/* Make damage */
				float damage = Attack::getDamage(target);
				Entity* entity = target->getEntity();
				entity->set("hp"_slice, entity->get<double>("hp"_slice) - damage);
				if (damaged)
				{
					damaged(_owner, target, damage);
				}
				if (_owner->attackTarget == AttackTarget::Single) return;
			}
			BLOCK_END
		}
		ARRAY_END
	}
}

Own<UnitAction> MeleeAttack::alloc(Unit* unit)
{
	UnitAction* action = new MeleeAttack(unit);
	return MakeOwn(action);
}

// RangeAttack

RangeAttack::RangeAttack(Unit* unit):
Attack(ActionSetting::UnitActionRangeAttack, unit)
{ }

Own<UnitAction> RangeAttack::alloc(Unit* unit)
{
	UnitAction* action = new RangeAttack(unit);
	return MakeOwn(action);
}

void RangeAttack::onAttack()
{
	BulletDef* bulletDef = _owner->getBulletDef();
	if (bulletDef)
	{
		Bullet* bullet = Bullet::create(bulletDef, _owner);
		bullet->targetAllow = _owner->targetAllow;
		bullet->hitTarget = std::make_pair(this, &RangeAttack::onHitTarget);
		_owner->getWorld()->addChild(bullet, _owner->getOrder());
	}
}

bool RangeAttack::onHitTarget(Bullet* bullet, Unit* target, Vec2 hitPoint)
{
	/* Get hit point */
	Hit* hitUnitAction = s_cast<Hit*>(target->getAction(ActionSetting::UnitActionHit));
	if (hitUnitAction)
	{
		bool attackFromRight = false;
		if (bullet->getBulletDef()->damageRadius > 0.0f)
		{
			attackFromRight = bullet->getX() < hitPoint.x;
		}
		else
		{
			attackFromRight = bullet->getVelocityX() < 0.0f;
		}
		hitUnitAction->setHitInfo(hitPoint, _owner->attackPower, attackFromRight);
	}
	/* Make damage */
	float damage = Attack::getDamage(target);
	Entity* entity = target->getEntity();
	entity->set("hp"_slice, entity->get<double>("hp"_slice) - damage);
	if (damaged)
	{
		damaged(_owner, target, damage);
	}
	return true;
}

Hit::Hit(Unit* unit):
UnitAction(ActionSetting::UnitActionHit, ActionSetting::PriorityHit, unit),
_effect(nullptr),
_hitFromRight(true),
_attackPower{},
_hitPoint{}
{
	UnitAction::recovery = ActionSetting::RecoveryHit;
	const string& hitEffect = _owner->getUnitDef()->hitEffect;
	if (!hitEffect.empty())
	{
		_effect = Visual::create(hitEffect);
		_effect->addTo(_owner);
	}
}

Hit::~Hit()
{ }

void Hit::run()
{
	Vec2 key = _owner->convertToNodeSpace(_hitPoint);
	if (_effect)
	{
		_effect->setPosition(key);
		_effect->start();
	}
	_owner->applyLinearImpulse({_hitFromRight ? -_attackPower.x : _attackPower.x, _attackPower.y}, Vec2::zero);
	_owner->setFaceRight(_hitFromRight);
	UnitAction::run();
	Model* model = _owner->getModel();
	if (model->hasAnimation(ActionSetting::AnimationHit))
	{
		model->handlers[ActionSetting::AnimationHit] += std::make_pair(this, &Hit::onAnimationEnd);
		model->setLook(ActionSetting::LookSad);
		model->setLoop(false);
		model->setRecovery(UnitAction::recovery);
		model->setSpeed(1.0f);
		model->play(ActionSetting::AnimationHit);
	}
	else
	{
		UnitAction::stop();
	}
}

void Hit::update(float dt)
{ }

void Hit::setHitInfo(const Vec2& hitPoint, const Vec2& attackPower, bool hitFromRight)
{
	_hitPoint = hitPoint;
	_hitFromRight = hitFromRight;
	_attackPower = attackPower;
}

void Hit::onAnimationEnd(Model* model)
{
	if (UnitAction::isDoing())
	{
		this->stop();
	}
}

void Hit::stop()
{
	Model* model = _owner->getModel();
	if (model->hasAnimation(ActionSetting::AnimationHit))
	{
		model->handlers[ActionSetting::AnimationHit] -= std::make_pair(this, &Hit::onAnimationEnd);
		model->stop();
	}
	UnitAction::stop();
}

Own<UnitAction> Hit::alloc(Unit* unit)
{
	UnitAction* action = new Hit(unit);
	return MakeOwn(action);
}

Fall::Fall(Unit* unit):
UnitAction(ActionSetting::UnitActionFall, ActionSetting::PriorityFall, unit)
{
	UnitAction::recovery = ActionSetting::RecoveryFall;
}

Fall::~Fall()
{ }

void Fall::run()
{
	Model* model = _owner->getModel();
	model->handlers[ActionSetting::AnimationFall] += std::make_pair(this, &Fall::onAnimationEnd);
	model->setLook(ActionSetting::LookFallen);
	model->setLoop(false);
	model->setRecovery(UnitAction::recovery);
	model->setSpeed(1.0f);
	model->play(ActionSetting::AnimationFall);
	const string& hitEffect = _owner->getUnitDef()->hitEffect;
	if (!hitEffect.empty())
	{
		Visual* effect = Visual::create(hitEffect);
		effect->addTo(_owner);
		effect->autoRemove();
		effect->start();
	}
	if (!_owner->getUnitDef()->sndFallen.empty())
	{
		SharedAudio.play(_owner->getUnitDef()->sndFallen);
	}
	UnitAction::run();
}

void Fall::update(float dt)
{ }

void Fall::stop()
{
	Model* model = _owner->getModel();
	model->handlers[ActionSetting::AnimationFall] -= std::make_pair(this, &Fall::onAnimationEnd);
	model->stop();
	UnitAction::stop();
}

void Fall::onAnimationEnd(Model* model)
{
	if (UnitAction::isDoing())
	{
		this->stop();
	}
}

Own<UnitAction> Fall::alloc(Unit* unit)
{
	UnitAction* action = new Fall(unit);
	return MakeOwn(action);
}

const Slice ActionSetting::AnimationWalk = "walk"_slice;
const Slice ActionSetting::AnimationAttack = "attack"_slice;
const Slice ActionSetting::AnimationIdle = "idle"_slice;
const Slice ActionSetting::AnimationJump = "jump"_slice;
const Slice ActionSetting::AnimationHit = "hit"_slice;
const Slice ActionSetting::AnimationFall = "fall"_slice;

const Slice ActionSetting::UnitActionWalk = "walk"_slice;
const Slice ActionSetting::UnitActionTurn = "turn"_slice;
const Slice ActionSetting::UnitActionMeleeAttack = "meleeAttack"_slice;
const Slice ActionSetting::UnitActionRangeAttack = "rangeAttack"_slice;
const Slice ActionSetting::UnitActionIdle = "idle"_slice;
const Slice ActionSetting::UnitActionCancel = "cancel"_slice;
const Slice ActionSetting::UnitActionJump = "jump"_slice;
const Slice ActionSetting::UnitActionHit = "hit"_slice;
const Slice ActionSetting::UnitActionFall = "fall"_slice;

typedef Own<UnitAction> (*UnitActionFunc)(Unit* unit);
static const unordered_map<string,UnitActionFunc> g_createFuncs =
{
	{ActionSetting::UnitActionWalk, &Walk::alloc},
	{ActionSetting::UnitActionTurn, &Turn::alloc},
	{ActionSetting::UnitActionMeleeAttack, &MeleeAttack::alloc},
	{ActionSetting::UnitActionRangeAttack, &RangeAttack::alloc},
	{ActionSetting::UnitActionIdle, &Idle::alloc},
	{ActionSetting::UnitActionCancel, &Cancel::alloc},
	{ActionSetting::UnitActionJump, &Jump::alloc},
	{ActionSetting::UnitActionHit, &Hit::alloc},
	{ActionSetting::UnitActionFall, &Fall::alloc}
};

Own<UnitAction> UnitAction::alloc(String name, Unit* unit)
{
	auto it = _actionDefs.find(name);
	if (it != _actionDefs.end())
	{
		return it->second->toAction(unit);
	}
	else
	{
		auto it = g_createFuncs.find(name);
		if (it != g_createFuncs.end())
		{
			return it->second(unit);
		}
	}
	return Own<UnitAction>();
}

int ActionSetting::PriorityIdle = 0;
int ActionSetting::PriorityWalk = 1;
int ActionSetting::PriorityTurn = 2;
int ActionSetting::PriorityJump = 2;
int ActionSetting::PriorityAttack = 3;
int ActionSetting::PriorityCancel = std::numeric_limits<int>::max();
int ActionSetting::PriorityHit = 4;
int ActionSetting::PriorityFall = 5;

float ActionSetting::ReactionWalk = 1.5f;
float ActionSetting::ReactionIdle = 2.0f;
float ActionSetting::ReactionJump = 1.5f;

float ActionSetting::RecoveryWalk = 0.1f;
float ActionSetting::RecoveryAttack = 0.2f;
float ActionSetting::RecoveryIdle = 0.1f;
float ActionSetting::RecoveryJump = 0.2f;
float ActionSetting::RecoveryHit = 0.05f;
float ActionSetting::RecoveryFall = 0.05f;

const Slice ActionSetting::LookNormal = "normal"_slice;
const Slice ActionSetting::LookFight = "fight"_slice;
const Slice ActionSetting::LookSad = "sad"_slice;
const Slice ActionSetting::LookFallen = "fallen"_slice;

NS_DOROTHY_PLATFORMER_END
