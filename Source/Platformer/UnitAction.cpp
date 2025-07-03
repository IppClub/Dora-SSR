/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Platformer/Define.h"

#include "Platformer/UnitAction.h"

#include "Animation/ModelDef.h"
#include "Audio/Audio.h"
#include "Entity/Entity.h"
#include "Lua/LuaHandler.h"
#include "Node/Model.h"
#include "Node/Spine.h"
#include "Physics/PhysicsWorld.h"
#include "Physics/Sensor.h"
#include "Platformer/AI.h"
#include "Platformer/AINode.h"
#include "Platformer/Bullet.h"
#include "Platformer/BulletDef.h"
#include "Platformer/Data.h"
#include "Platformer/Unit.h"
#include "Platformer/VisualCache.h"
#include "Support/Dictionary.h"
#include "playrho/d2/Distance.hpp"

NS_DORA_PLATFORMER_BEGIN

// UnitAction

StringMap<Own<UnitActionDef>> UnitAction::_actionDefs;

UnitAction::UnitAction(String name, int priority, bool queued, Unit* owner)
	: _name(name)
	, _priority(priority)
	, _queued(queued)
	, _doing(false)
	, _status(Behavior::Status::Failure)
	, _owner(owner)
	, reaction(0.0f)
	, _elapsedTime(0.0f)
	, _sensity(_owner->getUnitDef()->get(ActionSetting::Sensity, 0.0f)) { }

UnitAction::~UnitAction() {
	_owner = nullptr;
}

const std::string& UnitAction::getName() const noexcept {
	return _name;
}

int UnitAction::getPriority() const noexcept {
	return _priority;
}

bool UnitAction::isDoing() const noexcept {
	return _doing;
}

bool UnitAction::isQueued() const noexcept {
	return _queued;
}

Unit* UnitAction::getOwner() const noexcept {
	return _owner;
}

bool UnitAction::isAvailable() {
	return true;
}

float UnitAction::getElapsedTime() const noexcept {
	return _elapsedTime;
}

Behavior::Status UnitAction::getStatus() const noexcept {
	return _status;
}

void UnitAction::run() {
	_doing = true;
	_decisionDelay = 0.0f;
	_elapsedTime = 0.0f;
}

void UnitAction::update(float dt) {
	_elapsedTime += dt;
	float reactionTime = _sensity * UnitAction::reaction;
	if (reactionTime >= 0) {
		_decisionDelay += dt;
		if (_decisionDelay >= reactionTime) {
			_decisionDelay = 0.0f;
			// Check AI here
			SharedAI.runDecisionTree(_owner);
		}
	}
}

void UnitAction::stop() {
	_doing = false;
	_elapsedTime = 0.0f;
	_decisionDelay = 0.0f;
}

void UnitAction::add(String name, Own<UnitActionDef>&& actionDef) {
	_actionDefs[name.toString()] = std::move(actionDef);
}

void UnitAction::clear() {
	_actionDefs.clear();
}

// Walk

Walk::Walk(Unit* unit)
	: UnitAction(ActionSetting::UnitActionWalk, ActionSetting::PriorityWalk, false, unit) {
	UnitAction::reaction = ActionSetting::ReactionWalk;
	UnitAction::recovery = ActionSetting::RecoveryWalk;
}

bool Walk::isAvailable() {
	return _owner->isOnSurface();
}

void Walk::run() {
	Playable* playable = _owner->getPlayable();
	auto moveSpeed = _owner->getEntity()->get(ActionSetting::MoveSpeed, 1.0f);
	playable->setSpeed(moveSpeed);
	playable->setLook(ActionSetting::LookNormal);
	playable->setRecovery(UnitAction::recovery);
	playable->play(ActionSetting::AnimationWalk, true);
	UnitAction::run();
}

void Walk::update(float dt) {
	if (_owner->isOnSurface()) {
		auto move = _owner->getEntity()->get(ActionSetting::Move, 0.0f);
		auto moveSpeed = _owner->getEntity()->get(ActionSetting::MoveSpeed, 1.0f);
		move *= moveSpeed;
		if (_elapsedTime < UnitAction::recovery) {
			move *= std::min(_elapsedTime / UnitAction::recovery, 1.0f);
		}
		_owner->setVelocityX(_owner->isFaceRight() ? move : -move);
	} else {
		Walk::stop();
	}
	UnitAction::update(dt);
}

void Walk::stop() {
	UnitAction::stop();
}

Own<UnitAction> Walk::alloc(Unit* unit) {
	UnitAction* action = new Walk(unit);
	return MakeOwn(action);
}

// Turn

Turn::Turn(Unit* unit)
	: UnitAction(ActionSetting::UnitActionTurn, ActionSetting::PriorityTurn, true, unit) { }

void Turn::run() {
	_owner->setFaceRight(!_owner->isFaceRight());
}

Own<UnitAction> Turn::alloc(Unit* unit) {
	UnitAction* action = new Turn(unit);
	return MakeOwn(action);
}

Idle::Idle(Unit* unit)
	: UnitAction(ActionSetting::UnitActionIdle, ActionSetting::PriorityIdle, false, unit) {
	UnitAction::reaction = ActionSetting::ReactionIdle;
	UnitAction::recovery = ActionSetting::RecoveryIdle;
}

bool Idle::isAvailable() {
	return _owner->isOnSurface();
}

void Idle::run() {
	UnitAction::run();
	Playable* playable = _owner->getPlayable();
	playable->setSpeed(1.0f);
	playable->setLook(ActionSetting::LookNormal);
	playable->setRecovery(UnitAction::recovery);
	playable->play(ActionSetting::AnimationIdle, true);
}

void Idle::update(float dt) {
	Playable* playable = _owner->getPlayable();
	if (_owner->isOnSurface()) {
		if (_owner->getPlayable()->getCurrent() != ActionSetting::AnimationIdle) {
			playable->play(ActionSetting::AnimationIdle);
		}
	} else {
		Idle::stop();
	}
	UnitAction::update(dt);
}

void Idle::stop() {
	UnitAction::stop();
}

Own<UnitAction> Idle::alloc(Unit* unit) {
	UnitAction* action = new Idle(unit);
	return MakeOwn(action);
}

Jump::Jump(Unit* unit)
	: _duration(0.0f)
	, UnitAction(ActionSetting::UnitActionJump, ActionSetting::PriorityJump, true, unit) {
	UnitAction::reaction = ActionSetting::ReactionJump;
	UnitAction::recovery = ActionSetting::RecoveryJump;
}

bool Jump::isAvailable() {
	return _owner->isOnSurface();
}

void Jump::run() {
	Playable* playable = _owner->getPlayable();
	auto moveSpeed = _owner->getEntity()->get(ActionSetting::MoveSpeed, 1.0f);
	auto jump = _owner->getEntity()->get(ActionSetting::Jump, 0.0f);
	playable->setSpeed(moveSpeed);
	playable->setLook(ActionSetting::LookNormal);
	playable->setRecovery(UnitAction::recovery);
	_duration = playable->play(ActionSetting::AnimationJump, false);
	playable->slot("AnimationEnd"_slice, std::make_pair(this, &Jump::onAnimationEnd));
	_owner->setVelocityY(jump);
	Sensor* sensor = _owner->getGroundSensor();
	if (_owner->getPhysicsWorld()) {
		auto& world = *_owner->getPhysicsWorld()->getPrWorld();
		pr::BodyID self = _owner->getPrBody();
		pr::BodyID target = sensor->getSensedBodies()->get(0)->to<Body>()->getPrBody();
		const auto shapeA = pd::GetShape(world, *pr::begin(pd::GetShapes(world, self)));
		const auto shapeB = pd::GetShape(world, *pr::begin(pd::GetShapes(world, target)));
		const auto proxyA = pd::GetChild(shapeA, 0);
		const auto proxyB = pd::GetChild(shapeB, 0);
		const auto transformA = pd::GetTransformation(world, self);
		const auto transformB = pd::GetTransformation(world, target);
		pd::DistanceOutput output = Distance(proxyA, transformA, proxyB, transformB);
		const auto witnessPoints = pd::GetWitnessPoints(output.simplex);
		const auto velocity = pd::GetVelocity(world, self).linear;
		auto invMass = pd::GetInvMass(world, self);
		pd::ApplyLinearImpulse(world, target,
			pr::Vec2{-velocity[0] / invMass,
				-velocity[1] / invMass},
			std::get<1>(witnessPoints));
	}
	UnitAction::run();
}

void Jump::update(float dt) {
	if (_duration == 0.0f) {
		if (_elapsedTime > 0.2f) // don`t do update for a while, for actor won`t lift immediately.
		{
			Jump::stop();
		} else
			UnitAction::update(dt);
	} else
		UnitAction::update(dt);
}

void Jump::stop() {
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice)->remove(std::make_pair(this, &Jump::onAnimationEnd));
	UnitAction::stop();
}

void Jump::onAnimationEnd(Event* e) {
	std::string name;
	Playable* playable = nullptr;
	if (!e->get(name, playable)) return;
	if (name == ActionSetting::AnimationJump) {
		Jump::stop();
	}
}

Own<UnitAction> Jump::alloc(Unit* unit) {
	UnitAction* action = new Jump(unit);
	return MakeOwn(action);
}

Cancel::Cancel(Unit* unit)
	: UnitAction(ActionSetting::UnitActionCancel, ActionSetting::PriorityCancel, true, unit) { }

void Cancel::run() { }

Own<UnitAction> Cancel::alloc(Unit* unit) {
	UnitAction* action = new Cancel(unit);
	return MakeOwn(action);
}

// Attack

Attack::Attack(String name, Unit* unit)
	: UnitAction(name, ActionSetting::PriorityAttack, true, unit) {
	UnitAction::recovery = ActionSetting::RecoveryAttack;
}

Attack::~Attack() { }

void Attack::run() {
	auto attackDelay = _owner->getUnitDef()->get(ActionSetting::AttackDelay, 0.0f);
	auto attackSpeed = _owner->getEntity()->get(ActionSetting::AttackSpeed, 1.0f);
	auto attackEffectDelay = _owner->getUnitDef()->get(ActionSetting::AttackEffectDelay, 0.0f);
	_attackDelay = attackDelay / attackSpeed;
	_attackEffectDelay = attackEffectDelay / attackSpeed;
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice, std::make_pair(this, &Attack::onAnimationEnd));
	playable->setLook(ActionSetting::LookFight);
	playable->setRecovery(UnitAction::recovery);
	playable->setSpeed(attackSpeed);
	playable->play(ActionSetting::AnimationAttack);
	UnitAction::run();
}

void Attack::update(float dt) {
	_elapsedTime += dt;
	if (_attackDelay >= 0 && _elapsedTime >= _attackDelay) {
		_attackDelay = -1;
		auto sndAttack = _owner->getUnitDef()->get(ActionSetting::SndAttack, Slice::Empty);
		if (!sndAttack.empty()) {
			SharedAudio.play(sndAttack);
		}
		this->onAttack();
	}
	if (_attackEffectDelay >= 0 && _elapsedTime >= _attackEffectDelay) {
		_attackEffectDelay = -1;
		auto attackEffect = _owner->getUnitDef()->get(ActionSetting::AttackEffect, Slice::Empty);
		if (!attackEffect.empty()) {
			Vec2 key = _owner->getPlayable()->getKeyPoint(ActionSetting::AttackKey);
			Visual* effect = Visual::create(attackEffect);
			effect->setPosition(key);
			effect->addTo(_owner);
			effect->autoRemove();
			effect->start();
		}
	}
}

void Attack::stop() {
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice)->remove(std::make_pair(this, &Attack::onAnimationEnd));
	UnitAction::stop();
}

void Attack::onAnimationEnd(Event* e) {
	std::string name;
	Playable* playable = nullptr;
	if (!e->get(name, playable)) return;
	if (name == ActionSetting::AnimationAttack) {
		if (UnitAction::isDoing()) {
			this->stop();
		}
	}
}

float Attack::getDamage(Unit* target) {
	auto damageType = _owner->getUnitDef()->get(ActionSetting::DamageType, 0.0f);
	auto defenceType = target->getUnitDef()->get(ActionSetting::DefenceType, 0.0f);
	auto attackBase = _owner->getUnitDef()->get(ActionSetting::AttackBase, 0.0f);
	auto attackBonus = _owner->getUnitDef()->get(ActionSetting::AttackBonus, 0.0f);
	auto attackFactor = _owner->getUnitDef()->get(ActionSetting::AttackFactor, 1.0f);
	float factor = SharedData.getDamageFactor(s_cast<uint16_t>(damageType), s_cast<uint16_t>(defenceType));
	float damage = (attackBase + attackBonus) * (attackFactor + factor);
	return damage;
}

Vec2 Attack::getHitPoint(Body* self, Body* target, const pd::Shape& selfShape) {
	Vec2 hitPoint{};
	float distance = -1;
	auto selfB = self->getPrBody();
	auto targetB = target->getPrBody();
	if (target->getPhysicsWorld() && target->getPhysicsWorld()->getPrWorld()) {
		auto& world = *target->getPhysicsWorld()->getPrWorld();
		const auto transformA = pd::GetTransformation(world, selfB);
		for (pr::ShapeID f : pd::GetShapes(world, targetB)) {
			if (!pd::IsSensor(world, f)) {
				const auto proxyA = pd::GetChild(selfShape, 0);
				const auto shapeB = pd::GetShape(world, f);
				const auto proxyB = pd::GetChild(shapeB, 0);
				const auto transformB = pd::GetTransformation(world, targetB);
				pd::DistanceOutput output = Distance(proxyA, transformA, proxyB, transformB);
				const auto witnessPoints = pd::GetWitnessPoints(output.simplex);
				const auto outputDistance = pr::GetMagnitude(std::get<0>(witnessPoints) - std::get<1>(witnessPoints));
				if (distance == -1 || distance > outputDistance) {
					distance = outputDistance;
					hitPoint = PhysicsWorld::Val(std::get<1>(witnessPoints));
				}
			}
		}
	}
	return hitPoint;
}

// MeleeAttack

MeleeAttack::MeleeAttack(Unit* unit)
	: Attack(ActionSetting::UnitActionMeleeAttack, unit) {
	pd::PolygonShapeConf conf{PhysicsWorld::prVal(std::max(_owner->getWidth(), 10.0f) * 0.5f), 0.0005f};
	_polygon = pd::Shape{conf};
}

void MeleeAttack::onAttack() {
	Sensor* sensor = _owner->getAttackSensor();
	if (sensor) {
		ARRAY_START(Body, body, sensor->getSensedBodies()) {
			Unit* target = DoraAs<Unit>(body->getOwner());
			BLOCK_START {
				BREAK_UNLESS(target);
				bool attackRight = _owner->getPosition().x < target->getPosition().x;
				bool faceRight = _owner->isFaceRight();
				BREAK_IF(attackRight != faceRight); // !(hitRight == faceRight || hitLeft == faceLeft)
				Relation relation = SharedData.getRelation(_owner, target);
				auto targetAllow = TargetAllow(_owner->getEntity()->get(ActionSetting::TargetAllow, 0u));
				BREAK_IF(!targetAllow.isAllow(relation));
				/* Get hit point */
				Entity* entity = target->getEntity();
				auto usePreciseHit = _owner->getUnitDef()->get(ActionSetting::UsePreciseHit, false);
				auto attackPower = _owner->getEntity()->get(ActionSetting::AttackPower, Vec2::zero);
				Vec2 hitPoint = usePreciseHit ? Attack::getHitPoint(_owner, target, _polygon) : Vec2(target->getPosition());
				auto data = target->getUserData();
				data->set(ActionSetting::HitPoint, Value::alloc(hitPoint));
				data->set(ActionSetting::HitPower, Value::alloc(attackPower));
				data->set(ActionSetting::HitFromRight, Value::alloc(!attackRight));
				/* Make damage */
				float damage = Attack::getDamage(target);
				entity->set(ActionSetting::HP, entity->get<double>(ActionSetting::HP) - damage);
				auto attackTarget = _owner->getEntity()->get(ActionSetting::AttackTarget, Slice::Empty);
				if (attackTarget == "Single"_slice) return true;
			}
			BLOCK_END
		}
		ARRAY_END
	}
}

Own<UnitAction> MeleeAttack::alloc(Unit* unit) {
	UnitAction* action = new MeleeAttack(unit);
	return MakeOwn(action);
}

// RangeAttack

RangeAttack::RangeAttack(Unit* unit)
	: Attack(ActionSetting::UnitActionRangeAttack, unit) { }

Own<UnitAction> RangeAttack::alloc(Unit* unit) {
	UnitAction* action = new RangeAttack(unit);
	return MakeOwn(action);
}

void RangeAttack::onAttack() {
	auto bulletType = _owner->getUnitDef()->get(ActionSetting::BulletType, Slice::Empty);
	BulletDef* bulletDef = SharedData.getStore()->get(bulletType, (BulletDef*)nullptr);
	if (bulletDef) {
		Bullet* bullet = Bullet::create(bulletDef, _owner);
		auto targetAllow = TargetAllow(_owner->getEntity()->get(ActionSetting::TargetAllow, 0u));
		bullet->targetAllow = targetAllow;
		bullet->hitTarget = std::make_pair(this, &RangeAttack::onHitTarget);
		_owner->getPhysicsWorld()->addChild(bullet, _owner->getOrder());
	}
}

bool RangeAttack::onHitTarget(Bullet* bullet, Unit* target, Vec2 hitPoint, Vec2 normal) {
	/* Get hit point */
	bool attackFromRight = false;
	if (bullet->getBulletDef()->damageRadius > 0.0f) {
		attackFromRight = bullet->getX() < hitPoint.x;
	} else {
		attackFromRight = bullet->getVelocityX() < 0.0f;
	}
	Entity* entity = target->getEntity();
	auto attackPower = _owner->getEntity()->get(ActionSetting::AttackPower, Vec2::zero);
	auto data = target->getUserData();
	data->set(ActionSetting::HitPoint, Value::alloc(hitPoint));
	data->set(ActionSetting::HitPower, Value::alloc(attackPower));
	data->set(ActionSetting::HitFromRight, Value::alloc(attackFromRight));
	/* Make damage */
	float damage = Attack::getDamage(target);
	entity->set(ActionSetting::HP, entity->get<double>(ActionSetting::HP) - damage);
	return true;
}

Hit::Hit(Unit* unit)
	: UnitAction(ActionSetting::UnitActionHit, ActionSetting::PriorityHit, true, unit)
	, _effect(nullptr) {
	UnitAction::recovery = ActionSetting::RecoveryHit;
	auto hitEffect = _owner->getUnitDef()->get(ActionSetting::HitEffect, Slice::Empty);
	if (!hitEffect.empty()) {
		_effect = Visual::create(hitEffect);
		_effect->addTo(_owner);
	}
}

Hit::~Hit() { }

void Hit::run() {
	auto data = _owner->getUserData();
	Vec2 hitPoint = data->get(ActionSetting::HitPoint, Vec2::zero);
	Vec2 key = _owner->convertToNodeSpace(hitPoint);
	if (_effect) {
		_effect->setPosition(key);
		_effect->start();
	}
	float mass = _owner->getMass();
	bool hitFromRight = data->get(ActionSetting::HitFromRight, false);
	Vec2 hitPower = data->get(ActionSetting::HitPower, Vec2::zero);
	_owner->setVelocity(Vec2{hitFromRight ? -hitPower.x : hitPower.x, hitPower.y} / mass);
	_owner->setFaceRight(hitFromRight);
	UnitAction::run();
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice, std::make_pair(this, &Hit::onAnimationEnd));
	playable->setLook(ActionSetting::LookHit);
	playable->setRecovery(UnitAction::recovery);
	playable->setSpeed(1.0f);
	float duration = playable->play(ActionSetting::AnimationHit);
	if (duration == 0.0f) {
		Hit::stop();
	}
}

void Hit::update(float dt) { }

void Hit::onAnimationEnd(Event* e) {
	std::string name;
	Playable* playable = nullptr;
	if (!e->get(name, playable)) return;
	if (name == ActionSetting::AnimationHit) {
		if (UnitAction::isDoing()) {
			this->stop();
		}
	}
}

void Hit::stop() {
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice)->remove(std::make_pair(this, &Hit::onAnimationEnd));
	UnitAction::stop();
}

Own<UnitAction> Hit::alloc(Unit* unit) {
	UnitAction* action = new Hit(unit);
	return MakeOwn(action);
}

Fall::Fall(Unit* unit)
	: UnitAction(ActionSetting::UnitActionFall, ActionSetting::PriorityFall, true, unit) {
	UnitAction::recovery = ActionSetting::RecoveryFall;
}

Fall::~Fall() { }

void Fall::run() {
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice, std::make_pair(this, &Fall::onAnimationEnd));
	playable->setLook(ActionSetting::LookFallen);
	playable->setRecovery(UnitAction::recovery);
	playable->setSpeed(1.0f);
	playable->play(ActionSetting::AnimationFall);
	auto hitEffect = _owner->getUnitDef()->get(ActionSetting::HitEffect, Slice::Empty);
	if (!hitEffect.empty()) {
		Visual* effect = Visual::create(hitEffect);
		effect->addTo(_owner);
		effect->autoRemove();
		effect->start();
	}
	auto sndFallen = _owner->getUnitDef()->get(ActionSetting::SndFallen, Slice::Empty);
	if (!sndFallen.empty()) {
		SharedAudio.play(sndFallen);
	}
	UnitAction::run();
}

void Fall::update(float) { }

void Fall::stop() {
	Playable* playable = _owner->getPlayable();
	playable->slot("AnimationEnd"_slice)->remove(std::make_pair(this, &Fall::onAnimationEnd));
	UnitAction::stop();
}

void Fall::onAnimationEnd(Event* e) {
	std::string name;
	Playable* playable = nullptr;
	if (!e->get(name, playable)) return;
	if (name == ActionSetting::AnimationFall) {
		if (UnitAction::isDoing()) {
			this->stop();
		}
	}
}

Own<UnitAction> Fall::alloc(Unit* unit) {
	UnitAction* action = new Fall(unit);
	return MakeOwn(action);
}

const std::string ActionSetting::AnimationWalk = "walk"s;
const std::string ActionSetting::AnimationAttack = "attack"s;
const std::string ActionSetting::AnimationIdle = "idle"s;
const std::string ActionSetting::AnimationJump = "jump"s;
const std::string ActionSetting::AnimationHit = "hit"s;
const std::string ActionSetting::AnimationFall = "fall"s;

const std::string ActionSetting::UnitActionWalk = "walk"s;
const std::string ActionSetting::UnitActionTurn = "turn"s;
const std::string ActionSetting::UnitActionMeleeAttack = "meleeAttack"s;
const std::string ActionSetting::UnitActionRangeAttack = "rangeAttack"s;
const std::string ActionSetting::UnitActionIdle = "idle"s;
const std::string ActionSetting::UnitActionCancel = "cancel"s;
const std::string ActionSetting::UnitActionJump = "jump"s;
const std::string ActionSetting::UnitActionHit = "hit"s;
const std::string ActionSetting::UnitActionFall = "fall"s;

typedef Own<UnitAction> (*UnitActionFunc)(Unit* unit);
static const StringMap<UnitActionFunc> g_createFuncs = {
	{ActionSetting::UnitActionWalk, &Walk::alloc},
	{ActionSetting::UnitActionTurn, &Turn::alloc},
	{ActionSetting::UnitActionMeleeAttack, &MeleeAttack::alloc},
	{ActionSetting::UnitActionRangeAttack, &RangeAttack::alloc},
	{ActionSetting::UnitActionIdle, &Idle::alloc},
	{ActionSetting::UnitActionCancel, &Cancel::alloc},
	{ActionSetting::UnitActionJump, &Jump::alloc},
	{ActionSetting::UnitActionHit, &Hit::alloc},
	{ActionSetting::UnitActionFall, &Fall::alloc}};

Own<UnitAction> UnitAction::alloc(String name, Unit* unit) {
	auto it = _actionDefs.find(name);
	if (it != _actionDefs.end()) {
		return it->second->toAction(unit);
	} else {
		auto it = g_createFuncs.find(name);
		if (it != g_createFuncs.end()) {
			return it->second(unit);
		}
	}
	return Own<UnitAction>();
}

const int ActionSetting::PriorityIdle = 1;
const int ActionSetting::PriorityWalk = 1;
const int ActionSetting::PriorityTurn = 2;
const int ActionSetting::PriorityJump = 2;
const int ActionSetting::PriorityAttack = 3;
const int ActionSetting::PriorityHit = 5;
const int ActionSetting::PriorityFall = 6;
const int ActionSetting::PriorityCancel = std::numeric_limits<int>::max();

const float ActionSetting::ReactionWalk = 1.5f;
const float ActionSetting::ReactionIdle = 2.0f;
const float ActionSetting::ReactionJump = 1.5f;

const float ActionSetting::RecoveryWalk = 0.1f;
const float ActionSetting::RecoveryAttack = 0.2f;
const float ActionSetting::RecoveryIdle = 0.1f;
const float ActionSetting::RecoveryJump = 0.2f;
const float ActionSetting::RecoveryHit = 0.05f;
const float ActionSetting::RecoveryFall = 0.05f;

const Slice ActionSetting::LookNormal = "normal"_slice;
const Slice ActionSetting::LookFight = "fight"_slice;
const Slice ActionSetting::LookHit = "hit"_slice;
const Slice ActionSetting::LookFallen = "fallen"_slice;

const Slice ActionSetting::HP = "hp"_slice;
const Slice ActionSetting::MoveSpeed = "moveSpeed"_slice;
const Slice ActionSetting::Move = "move"_slice;
const Slice ActionSetting::Jump = "jump"_slice;
const Slice ActionSetting::TargetAllow = "targetAllow"_slice;
const Slice ActionSetting::AttackPower = "attackPower"_slice;
const Slice ActionSetting::AttackSpeed = "attackSpeed"_slice;
const Slice ActionSetting::Sensity = "sensity"_slice;
const Slice ActionSetting::AttackDelay = "attackDelay"_slice;
const Slice ActionSetting::AttackEffectDelay = "attackEffectDelay"_slice;
const Slice ActionSetting::AttackEffect = "attackEffect"_slice;
const Slice ActionSetting::SndAttack = "sndAttack"_slice;
const Slice ActionSetting::DamageType = "damageType"_slice;
const Slice ActionSetting::DefenceType = "defenceType"_slice;
const Slice ActionSetting::AttackBase = "attackBase"_slice;
const Slice ActionSetting::AttackBonus = "attackBonus"_slice;
const Slice ActionSetting::AttackFactor = "attackFactor"_slice;
const Slice ActionSetting::UsePreciseHit = "usePreciseHit"_slice;
const Slice ActionSetting::BulletType = "bulletType"_slice;
const Slice ActionSetting::HitEffect = "hitEffect"_slice;
const Slice ActionSetting::SndFallen = "sndFallen"_slice;

const Slice ActionSetting::AttackKey = "attack"_slice;

const Slice ActionSetting::HitPoint = "hitPoint"_slice;
const Slice ActionSetting::HitFromRight = "hitFromRight"_slice;
const Slice ActionSetting::HitPower = "hitPower"_slice;
const Slice ActionSetting::AttackTarget = "attackTarget"_slice;

NS_DORA_PLATFORMER_END
