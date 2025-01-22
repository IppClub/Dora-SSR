/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Platformer/Define.h"

#include "Platformer/BulletDef.h"

#include "Physics/BodyDef.h"
#include "Platformer/Face.h"
#include "Support/Geometry.h"

NS_DORA_PLATFORMER_BEGIN

BulletDef::BulletDef()
	: tag()
	, lifeTime(0)
	, damageRadius(0)
	, endEffect()
	, _bodyDef(BodyDef::create()) {
	_bodyDef->setType(pr::BodyType::Dynamic);
}

BodyDef* BulletDef::getBodyDef() const {
	return _bodyDef;
}

void BulletDef::setVelocity(float angle, float speed) {
	angle = bx::toRad(angle);
	_velocity.x = std::cos(angle) * speed;
	_velocity.y = std::sin(angle) * speed;
}

void BulletDef::setVelocity(const Vec2& velocity) {
	_velocity = velocity;
}

const Vec2& BulletDef::getVelocity() const noexcept {
	return _velocity;
}

void BulletDef::setHighSpeedFix(bool var) {
	_bodyDef->setBullet(var);
}

bool BulletDef::isHighSpeedFix() const {
	return _bodyDef->isBullet();
}

void BulletDef::setGravity(Vec2 var) {
	_bodyDef->setLinearAcceleration(var);
}

Vec2 BulletDef::getGravity() const noexcept {
	return _bodyDef->getLinearAcceleration();
}

void BulletDef::setAsCircle(float radius) {
	_bodyDef->clearFixtures();
	_bodyDef->attachDisk(radius);
}

void BulletDef::setFace(Face* var) {
	_face = var;
}

Face* BulletDef::getFace() const noexcept {
	return _face;
}

NS_DORA_PLATFORMER_END
