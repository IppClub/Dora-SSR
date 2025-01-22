/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Platformer/Define.h"

#include "Platformer/Bullet.h"

#include "Animation/ModelDef.h"
#include "Node/Model.h"
#include "Physics/BodyDef.h"
#include "Physics/PhysicsWorld.h"
#include "Physics/Sensor.h"
#include "Platformer/BulletDef.h"
#include "Platformer/Data.h"
#include "Platformer/Face.h"
#include "Platformer/Unit.h"
#include "Platformer/VisualCache.h"
#include "Support/Dictionary.h"

NS_DORA_PLATFORMER_BEGIN

const Slice Bullet::Def::BulletKey = "bullet"_slice;

Bullet::Bullet(NotNull<BulletDef, 1> bulletDef, NotNull<Unit, 2> unit)
	: Body(bulletDef->getBodyDef(), unit->getPhysicsWorld())
	, _bulletDef(bulletDef)
	, _emitter(unit)
	, _current(0)
	, _lifeTime(bulletDef->lifeTime)
	, _face(nullptr) { }

bool Bullet::init() {
	if (!Body::init()) return false;
	Bullet::setFaceRight(_emitter->isFaceRight());
	Bullet::setTag(_bulletDef->tag);
	Body::setReceivingContact(true);
	Body::setOwner(_emitter);
	filterContact = [](Body*) {
		return false;
	};
	contactStart += std::make_pair(this, &Bullet::onBodyContact);
	Vec2 v = _bulletDef->getVelocity();
	Body::setVelocity((isFaceRight() ? v.x : -v.x), v.y);
	Body::setGroup(SharedData.getGroupDetection());
	Face* face = _bulletDef->getFace();
	if (face) {
		Node* node = face->toNode();
		Bullet::setFace(node);
	}
	Playable* playable = _emitter->getPlayable();
	Vec2 offset = (playable ? playable->getKeyPoint(Def::BulletKey) : Vec2::zero);
	Bullet::setPosition(_emitter->getPosition() + offset);
	if (Body::getBodyDef()->getLinearAcceleration() != Vec2::zero) {
		Bullet::setAngle(-bx::toDeg(std::atan2(v.y, _emitter->isFaceRight() ? v.x : -v.x)));
	}
	hitTarget += [](Bullet* bullet, Unit* target, Vec2 point, Vec2 normal) {
		bullet->emit("HitTarget"_slice, bullet, target, point, normal);
		return bullet->isHitStop();
	};
	this->scheduleUpdate();
	return true;
}

void Bullet::updatePhysics() {
	if (!_pWorld || !_pWorld->getPrWorld()) {
		return;
	}
	auto& world = *_pWorld->getPrWorld();
	if (pd::IsAwake(world, _prBody)) {
		const pr::Vec2& pos = pd::GetLocation(world, _prBody);
		/* Here only Node::setPosition(const Vec2& var) work for modify Node`s position.
		 Other positioning functions have been overridden by Body`s.
		*/
		Node::setPosition(Vec2{PhysicsWorld::Val(pos[0]), PhysicsWorld::Val(pos[1])});
		if (pd::GetLinearAcceleration(world, _prBody) != pr::LinearAcceleration2{}) {
			pd::Velocity velocity = pd::GetVelocity(world, _prBody);
			Node::setAngle(-bx::toDeg(std::atan2(velocity.linear[1], velocity.linear[0])));
		}
	}
}

bool Bullet::update(double deltaTime) {
	if (getGroup() == SharedData.getGroupHide()) return true;
	_current += s_cast<float>(deltaTime);
	if (_current >= _lifeTime) {
		Bullet::destroy();
	}
	return Body::update(deltaTime);
}

Unit* Bullet::getEmitter() const noexcept {
	return _emitter;
}

void Bullet::setFaceRight(bool var) {
	_flags.set(Bullet::FaceRight, var);
}

bool Bullet::isFaceRight() const noexcept {
	return _flags.isOn(Bullet::FaceRight);
}

void Bullet::setHitStop(bool var) {
	_flags.set(Bullet::HitStop, var);
}

bool Bullet::isHitStop() const noexcept {
	return _flags.isOn(Bullet::HitStop);
}

void Bullet::setTargetAllow(uint32_t var) {
	targetAllow = TargetAllow(var);
}

uint32_t Bullet::getTargetAllow() const noexcept {
	return targetAllow.toValue();
}

void Bullet::onBodyContact(Body* body, Vec2 point, Vec2 normal, bool) {
	if (body == _emitter) {
		return;
	}
	Unit* unit = DoraAs<Unit>(body->getOwner());
	bool isHitTerrain = SharedData.isTerrain(body) && targetAllow.isTerrainAllowed();
	bool isHitUnit = unit && targetAllow.isAllow(SharedData.getRelation(_emitter, unit));
	bool isHit = isHitTerrain || isHitUnit;
	if (isHit && hitTarget) {
		bool isRangeDamage = _bulletDef->damageRadius > 0.0f;
		if (isRangeDamage) {
			Vec2 pos = this->getPosition();
			Rect rect(
				pos.x - _bulletDef->damageRadius,
				pos.y - _bulletDef->damageRadius,
				_bulletDef->damageRadius * 2,
				_bulletDef->damageRadius * 2);
			_pWorld->query(rect, [&](Body* body) {
				Unit* unit = DoraAs<Unit>(body->getOwner());
				if (unit && targetAllow.isAllow(SharedData.getRelation(_emitter, unit))) {
					hitTarget(this, unit, unit->getPosition(), normal);
				}
				return false;
			});
		} else if (isHitUnit) {
			/* hitTarget function may cancel this hit by returning false */
			isHit = hitTarget(this, unit, point, normal);
		}
	}
	if (isHit) {
		Bullet::destroy();
	}
}

BulletDef* Bullet::getBulletDef() {
	return _bulletDef;
}

void Bullet::setFace(Node* var) {
	if (_face) {
		_face->slot("Stoped"_slice, nullptr);
		Node::removeChild(_face, true);
	}
	_face = var;
	Node::addChild(var);
	_face->slot("Stoped"_slice, [this](Event*) {
		_face = nullptr;
		removeFromParent();
	});
}

Node* Bullet::getFace() const noexcept {
	return _face;
}

void Bullet::destroy() {
	AssertIf(getGroup() == SharedData.getGroupHide(), "can destroy bullet only once!");
	setGroup(SharedData.getGroupHide());
	Node::unscheduleUpdate();
	if (!_bulletDef->endEffect.empty()) {
		Visual* effect = Visual::create(_bulletDef->endEffect);
		effect->setPosition(this->getPosition());
		effect->addTo(this->getParent());
		effect->autoRemove();
		effect->start();
	}
	Body::setVelocity(0, 0);
	hitTarget.Clear();
	if (_face) {
		_face->emit("Stop"_slice);
	} else {
		removeFromParent(true);
	}
}

NS_DORA_PLATFORMER_END
