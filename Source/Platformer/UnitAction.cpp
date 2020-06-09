/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

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
#include "Node/Spine.h"
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
	Playable* playable = _owner->getPlayable();
	playable->setSpeed(_owner->moveSpeed);
	playable->setLook(ActionSetting::LookNormal);
	playable->setRecovery(UnitAction::recovery);
	playable->play(ActionSetting::AnimationWalk, true);
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
		Playable* playable = _owner->getPlayable();
		playable->setSpeed(1.0f);
		playable->setLook(ActionSetting::LookNormal);
		playable->setRecovery(UnitAction::recovery);
		playable->play(ActionSetting::AnimationIdle, true);
	}
	else
	{
		Idle::stop();
	}
}

void Idle::update(float dt)
{
	Playable* playable = _owner->getPlayable();
	if (_owner->isOnSurface())
	{
		if (_owner->getPlayable()->getCurrentAnimationName() != ActionSetting::AnimationIdle)
		{
			playable->play(ActionSetting::AnimationIdle);
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
}

Own<UnitAction> Idle::alloc(Unit* unit)
{
	UnitAction* action = new Idle(unit);
	return MakeOwn(action);
}

Jump::Jump(Unit* unit):
_duration(0.0f),
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
	Playable* playable = _owner->getPlayable();
	playable->setSpeed(_owner->moveSpeed);
	playable->setLook(ActionSetting::LookNormal);
	playable->setRecovery(UnitAction::recovery);
	_duration = playable->play(ActionSetting::AnimationJump, false);
	playable->slot("AnimationEnd"_slice, std::make_pair(this, &Jump::onAnimationEnd));
	_owner->setVelocityY(_owner->jump);
	Sensor* sensor = _owner->getGroundSensor();
	pd::Body* self = _owner->getPrBody();
	pd::Body* target = sensor->getSensedBodies()->get(0).to<Body>()->getPrBody();
	const auto shapeA = pr::GetPtr(*pr::begin(self->GetFixtures()))->GetShape();
	const auto shapeB = pr::GetPtr(*pr::begin(target->GetFixtures()))->GetShape();
	const auto proxyA = pd::GetChild(shapeA, 0);
	const auto proxyB = pd::GetChild(shapeB, 0);
	const auto transformA = self->GetTransformation();
	const auto transformB = target->GetTransformation();
	pd::DistanceOutput output = Distance(proxyA, transformA, proxyB, transformB);
	const auto witnessPoints = pd::GetWitnessPoints(output.simplex);
	const auto velocity = self->GetVelocity().linear;
	pd::ApplyLinearImpulse(pr::GetRef(target),
		pr::Vec2{-velocity[0] / self->GetInvMass(),
		-velocity[1] / self->GetInvMass()},
		std::get<1>(witnessPoints));
	UnitAction::run();
}

void Jump::update(float dt)
{
	if (_duration == 0.0f)
	{
		if (_eclapsedTime > 0.2f) // don`t do update for a while, for actor won`t lift immediately.
		{
			Jump::stop();
		}
		else UnitAction::update(dt);
	}
	else UnitAction::update(dt);
}

void Jump::stop()
{
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice)->remove(std::make_pair(this, &Jump::onAnimationEnd));
	UnitAction::stop();
}

void Jump::onAnimationEnd(Event* e)
{
	string name;
	Playable* playable = nullptr;
	e->get(name, playable);
	if (name == ActionSetting::AnimationJump)
	{
		Jump::stop();
	}
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
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice, std::make_pair(this, &Attack::onAnimationEnd));
	playable->setLook(ActionSetting::LookFight);
	playable->setRecovery(UnitAction::recovery);
	playable->setSpeed(_owner->attackSpeed);
	playable->play(ActionSetting::AnimationAttack);
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
			Vec2 key = _owner->getPlayable()->getKeyPoint(UnitDef::AttackKey);
			if (!_owner->isFaceRight())
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
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice)->remove(std::make_pair(this, &Attack::onAnimationEnd));
	UnitAction::stop();
}

void Attack::onAnimationEnd(Event* e)
{
	string name;
	Playable* playable = nullptr;
	e->get(name, playable);
	if (name == ActionSetting::AnimationAttack)
	{
		if (UnitAction::isDoing())
		{
			this->stop();
		}
	}
}

float Attack::getDamage(Unit* target)
{
	float factor = SharedData.getDamageFactor(_owner->damageType, target->defenceType);
	float damage = (_owner->attackBase + _owner->attackBonus) * (_owner->attackFactor + factor);
	return damage;
}

Vec2 Attack::getHitPoint(Body* self, Body* target, pd::Shape* selfShape)
{
	Vec2 hitPoint{};
	float distance = -1;
	for (pd::Fixture* f : target->getPrBody()->GetFixtures())
	{
		if (!f->IsSensor())
		{
			const auto proxyA = pd::GetChild(pr::GetRef(selfShape), 0);
			const auto proxyB = pd::GetChild(f->GetShape(), 0);
			const auto transformA = self->getPrBody()->GetTransformation();
			const auto transformB = target->getPrBody()->GetTransformation();
			pd::DistanceOutput output = Distance(proxyA, transformA, proxyB, transformB);
			const auto witnessPoints = pd::GetWitnessPoints(output.simplex);
			const auto outputDistance = pr::GetMagnitude(std::get<0>(witnessPoints) - std::get<1>(witnessPoints));
			if (distance == -1 || distance > outputDistance)
			{
				distance = outputDistance;
				hitPoint = PhysicsWorld::oVal(std::get<1>(witnessPoints));
			}
		}
	}
	return hitPoint;
}

// MeleeAttack

MeleeAttack::MeleeAttack(Unit* unit):
Attack(ActionSetting::UnitActionMeleeAttack, unit)
{
	pd::PolygonShapeConf conf{PhysicsWorld::b2Val(_owner->getWidth()*0.5f), 0.0005f};
	_polygon = pd::Shape{conf};
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
				Entity* entity = target->getEntity();
				Vec2 hitPoint = _owner->getUnitDef()->usePreciseHit ? Attack::getHitPoint(_owner, target, &_polygon) : Vec2(target->getPosition());
				entity->set("hitPoint"_slice, hitPoint);
				entity->set("hitPower"_slice, _owner->attackPower);
				entity->set("hitFromRight"_slice, !attackRight);
				/* Make damage */
				float damage = Attack::getDamage(target);
				entity->set("hp"_slice, entity->get<double>("hp"_slice) - damage);
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
	bool attackFromRight = false;
	if (bullet->getBulletDef()->damageRadius > 0.0f)
	{
		attackFromRight = bullet->getX() < hitPoint.x;
	}
	else
	{
		attackFromRight = bullet->getVelocityX() < 0.0f;
	}
	Entity* entity = target->getEntity();
	entity->set("hitPoint"_slice, hitPoint);
	entity->set("hitPower"_slice, _owner->attackPower);
	entity->set("hitFromRight"_slice, attackFromRight);
	/* Make damage */
	float damage = Attack::getDamage(target);
	entity->set("hp"_slice, entity->get<double>("hp"_slice) - damage);
	return true;
}

Hit::Hit(Unit* unit):
UnitAction(ActionSetting::UnitActionHit, ActionSetting::PriorityHit, unit),
_effect(nullptr)
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
	Entity* entity = _owner->getEntity();
	Vec2 hitPoint = entity->tryGet<Vec2>("hitPoint"_slice, Vec2::zero);
	Vec2 key = _owner->convertToNodeSpace(hitPoint);
	if (_effect)
	{
		_effect->setPosition(key);
		_effect->start();
	}
	float mass = _owner->getMass();
	bool hitFromRight = entity->tryGet<bool>("hitFromRight"_slice, false);
	Vec2 hitPower = entity->tryGet<Vec2>("hitPower"_slice, Vec2::zero);
	_owner->setVelocity(Vec2{hitFromRight ? -hitPower.x : hitPower.x, hitPower.y} / mass);
	_owner->setFaceRight(hitFromRight);
	UnitAction::run();
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice, std::make_pair(this, &Hit::onAnimationEnd));
	playable->setLook(ActionSetting::LookFailure);
	playable->setRecovery(UnitAction::recovery);
	playable->setSpeed(1.0f);
	float duration = playable->play(ActionSetting::AnimationHit);
	if (duration == 0.0f)
	{
		Hit::stop();
	}
}

void Hit::update(float dt)
{ }

void Hit::onAnimationEnd(Event* e)
{
	string name;
	Playable* playable = nullptr;
	e->get(name, playable);
	if (name == ActionSetting::AnimationHit)
	{
		if (UnitAction::isDoing())
		{
			this->stop();
		}
	}
}

void Hit::stop()
{
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice)->remove(std::make_pair(this, &Hit::onAnimationEnd));
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
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice, std::make_pair(this, &Fall::onAnimationEnd));
	playable->setLook(ActionSetting::LookFallen);
	playable->setRecovery(UnitAction::recovery);
	playable->setSpeed(1.0f);
	playable->play(ActionSetting::AnimationFall);
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

void Fall::update(float)
{ }

void Fall::stop()
{
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice)->remove(std::make_pair(this, &Fall::onAnimationEnd));
	UnitAction::stop();
}

void Fall::onAnimationEnd(Event* e)
{
	string name;
	Playable* playable = nullptr;
	e->get(name, playable);
	if (name == ActionSetting::AnimationFall)
	{
		if (UnitAction::isDoing())
		{
			this->stop();
		}
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
const Slice ActionSetting::LookFailure = "fail"_slice;
const Slice ActionSetting::LookFallen = "fallen"_slice;

NS_DOROTHY_PLATFORMER_END
