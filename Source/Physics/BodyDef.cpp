/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Physics/BodyDef.h"

#include "Physics/Body.h"
#include "Physics/PhysicsWorld.h"

NS_DORA_BEGIN

BodyDef::BodyDef()
	: angleOffset(0)
	, offset(Vec2::zero)
	, facePos(Vec2::zero) {
	_conf.enabled = false;
}

BodyDef::~BodyDef() {
	BodyDef::clearFixtures();
}

void BodyDef::attachPolygon(const Vec2& center, float width, float height, float angle, float density, float friction, float restitution) {
	pd::PolygonShapeConf conf = pd::PolygonShapeConf{}
									.SetAsBox(
										PhysicsWorld::prVal(width * 0.5f),
										PhysicsWorld::prVal(height * 0.5f),
										PhysicsWorld::prVal(center),
										-bx::toRad(angle))
									.UseDensity(density)
									.UseFriction(friction)
									.UseRestitution(restitution);
	_fixtureConfs.emplace_back(0, pd::Shape{conf});
}

void BodyDef::attachPolygon(float width, float height, float density, float friction, float restitution) {
	pd::PolygonShapeConf conf = pd::PolygonShapeConf{}
									.SetAsBox(
										PhysicsWorld::prVal(width * 0.5f),
										PhysicsWorld::prVal(height * 0.5f))
									.UseDensity(density)
									.UseFriction(friction)
									.UseRestitution(restitution);
	_fixtureConfs.emplace_back(0, pd::Shape{conf});
}

void BodyDef::attachPolygon(const std::vector<Vec2>& vertices, float density, float friction, float restitution) {
	std::vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	pd::PolygonShapeConf conf = pd::PolygonShapeConf{}
									.Set(vs)
									.UseDensity(density)
									.UseFriction(friction)
									.UseRestitution(restitution);
	_fixtureConfs.emplace_back(0, pd::Shape{conf});
}

void BodyDef::attachPolygon(const Vec2 vertices[], int count, float density, float friction, float restitution) {
	std::vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	pd::PolygonShapeConf conf = pd::PolygonShapeConf{}
									.Set(vs)
									.UseDensity(density)
									.UseFriction(friction)
									.UseRestitution(restitution);
	_fixtureConfs.emplace_back(0, pd::Shape{conf});
}

void BodyDef::attachMulti(const std::vector<Vec2>& vertices, float density, float friction, float restitution) {
	pd::MultiShapeConf conf = pd::MultiShapeConf{};
	pd::VertexSet vs;
	for (size_t i = 0; i < vertices.size(); i++) {
		if (vertices[i] == Vec2::zero) {
			if (vs.size() > 0) {
				conf.AddConvexHull(vs);
				vs.clear();
			}
		} else
			vs.add(pr::Length2{
				PhysicsWorld::prVal(vertices[i].x),
				PhysicsWorld::prVal(vertices[i].y)});
	}
	if (vs.size() > 0) {
		conf.AddConvexHull(vs);
	}
	conf
		.UseDensity(density)
		.UseFriction(friction)
		.UseRestitution(restitution);
	_fixtureConfs.emplace_back(0, pd::Shape{conf});
}

void BodyDef::attachMulti(const Vec2 vertices[], int count, float density, float friction, float restitution) {
	pd::MultiShapeConf conf = pd::MultiShapeConf{};
	pd::VertexSet vs;
	for (int i = 0; i < count; i++) {
		if (vertices[i] == Vec2::zero) {
			if (vs.size() > 0) {
				conf.AddConvexHull(vs);
				vs.clear();
			}
		} else
			vs.add(pr::Length2{
				PhysicsWorld::prVal(vertices[i].x),
				PhysicsWorld::prVal(vertices[i].y)});
	}
	if (vs.size() > 0) {
		conf.AddConvexHull(vs);
	}
	conf
		.UseDensity(density)
		.UseFriction(friction)
		.UseRestitution(restitution);
	_fixtureConfs.emplace_back(0, pd::Shape{conf});
}

void BodyDef::attachDisk(const Vec2& center, float radius, float density, float friction, float restitution) {
	pd::DiskShapeConf conf = pd::DiskShapeConf{}
								 .UseLocation(PhysicsWorld::prVal(center))
								 .UseRadius(PhysicsWorld::prVal(radius))
								 .UseDensity(density)
								 .UseFriction(friction)
								 .UseRestitution(restitution);
	_fixtureConfs.emplace_back(0, pd::Shape{conf});
}

void BodyDef::attachDisk(float radius, float density, float friction, float restitution) {
	BodyDef::attachDisk(Vec2::zero, radius, density, friction, restitution);
}

void BodyDef::attachChain(const std::vector<Vec2>& vertices, float friction, float restitution) {
	std::vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	pd::ChainShapeConf conf = pd::ChainShapeConf{}
								  .Set(vs)
								  .UseFriction(friction)
								  .UseRestitution(restitution);
	_fixtureConfs.emplace_back(0, pd::Shape{conf});
}

void BodyDef::attachChain(const Vec2 vertices[], int count, float friction, float restitution) {
	std::vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	pd::ChainShapeConf conf = pd::ChainShapeConf{}
								  .Set(vs)
								  .UseFriction(friction)
								  .UseRestitution(restitution);
	_fixtureConfs.emplace_back(0, pd::Shape{conf});
}

void BodyDef::attachPolygonSensor(int tag, float width, float height) {
	BodyDef::attachPolygonSensor(tag, Vec2::zero, width, height, 0);
}

void BodyDef::attachPolygonSensor(int tag, const Vec2& center, float width, float height, float angle) {
	_fixtureConfs.emplace_back(
		tag,
		pd::Shape{
			pd::PolygonShapeConf{}
				.SetAsBox(
					PhysicsWorld::prVal(width * 0.5f),
					PhysicsWorld::prVal(height * 0.5f),
					PhysicsWorld::prVal(center),
					-bx::toRad(angle))
				.UseIsSensor(true)});
}

void BodyDef::attachPolygonSensor(int tag, const std::vector<Vec2>& vertices) {
	std::vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	_fixtureConfs.emplace_back(
		tag,
		pd::Shape{
			pd::PolygonShapeConf{}
				.Set(vs)
				.UseIsSensor(true)});
}

void BodyDef::attachPolygonSensor(int tag, const Vec2 vertices[], int count) {
	std::vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	_fixtureConfs.emplace_back(
		tag,
		pd::Shape{
			pd::PolygonShapeConf{}
				.Set(vs)
				.UseIsSensor(true)});
}

void BodyDef::attachDiskSensor(int tag, const Vec2& center, float radius) {
	_fixtureConfs.emplace_back(
		tag,
		pd::Shape{
			pd::DiskShapeConf{}
				.UseLocation(PhysicsWorld::prVal(center))
				.UseRadius(PhysicsWorld::prVal(radius))
				.UseIsSensor(true)});
}

void BodyDef::attachDiskSensor(int tag, float radius) {
	BodyDef::attachDiskSensor(tag, Vec2::zero, radius);
}

FixtureDef* BodyDef::polygon(const Vec2& center, float width, float height, float angle, float density, float friction, float restitution) {
	return FixtureDef::create(
		pd::Shape{
			pd::PolygonShapeConf{}
				.SetAsBox(
					PhysicsWorld::prVal(width * 0.5f),
					PhysicsWorld::prVal(height * 0.5f),
					PhysicsWorld::prVal(center),
					-bx::toRad(angle))
				.UseDensity(density)
				.UseFriction(friction)
				.UseRestitution(restitution)});
}

FixtureDef* BodyDef::polygon(float width, float height, float density, float friction, float restitution) {
	return FixtureDef::create(
		pd::Shape{
			pd::PolygonShapeConf{}
				.SetAsBox(
					PhysicsWorld::prVal(width * 0.5f),
					PhysicsWorld::prVal(height * 0.5f))
				.UseDensity(density)
				.UseFriction(friction)
				.UseRestitution(restitution)});
}

FixtureDef* BodyDef::polygon(const std::vector<Vec2>& vertices, float density, float friction, float restitution) {
	std::vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	return FixtureDef::create(
		pd::Shape{
			pd::PolygonShapeConf{}
				.Set(vs)
				.UseDensity(density)
				.UseFriction(friction)
				.UseRestitution(restitution)});
}

FixtureDef* BodyDef::polygon(const Vec2 vertices[], int count, float density, float friction, float restitution) {
	std::vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	return FixtureDef::create(
		pd::Shape{
			pd::PolygonShapeConf{}
				.Set(vs)
				.UseDensity(density)
				.UseFriction(friction)
				.UseRestitution(restitution)});
}

FixtureDef* BodyDef::multi(const std::vector<Vec2>& vertices, float density, float friction, float restitution) {
	pd::MultiShapeConf conf = pd::MultiShapeConf{};
	pd::VertexSet vs;
	for (size_t i = 0; i < vertices.size(); i++) {
		if (vertices[i] == Vec2::zero) {
			if (vs.size() > 0) {
				conf.AddConvexHull(vs);
				vs.clear();
			}
		} else
			vs.add(pr::Length2{
				PhysicsWorld::prVal(vertices[i].x),
				PhysicsWorld::prVal(vertices[i].y)});
	}
	if (vs.size() > 0) {
		conf.AddConvexHull(vs);
	}
	conf
		.UseDensity(density)
		.UseFriction(friction)
		.UseRestitution(restitution);
	return FixtureDef::create(pd::Shape{conf});
}

FixtureDef* BodyDef::multi(const Vec2 vertices[], int count, float density, float friction, float restitution) {
	pd::MultiShapeConf conf = pd::MultiShapeConf{};
	pd::VertexSet vs;
	for (int i = 0; i < count; i++) {
		if (vertices[i] == Vec2::zero) {
			if (vs.size() > 0) {
				conf.AddConvexHull(vs);
				vs.clear();
			}
		} else
			vs.add(pr::Length2{
				PhysicsWorld::prVal(vertices[i].x),
				PhysicsWorld::prVal(vertices[i].y)});
	}
	if (vs.size() > 0) {
		conf.AddConvexHull(vs);
	}
	conf
		.UseDensity(density)
		.UseFriction(friction)
		.UseRestitution(restitution);
	return FixtureDef::create(pd::Shape{conf});
}

FixtureDef* BodyDef::disk(const Vec2& center, float radius, float density, float friction, float restitution) {
	pd::DiskShapeConf conf = pd::DiskShapeConf{}
								 .UseLocation(PhysicsWorld::prVal(center))
								 .UseRadius(PhysicsWorld::prVal(radius))
								 .UseDensity(density)
								 .UseFriction(friction)
								 .UseRestitution(restitution);
	return FixtureDef::create(pd::Shape{conf});
}

FixtureDef* BodyDef::disk(float radius, float density, float friction, float restitution) {
	return BodyDef::disk(Vec2::zero, radius, density, friction, restitution);
}

FixtureDef* BodyDef::chain(const std::vector<Vec2>& vertices, float friction, float restitution) {
	std::vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	pd::ChainShapeConf conf = pd::ChainShapeConf{}
								  .Set(vs)
								  .UseFriction(friction)
								  .UseRestitution(restitution);
	return FixtureDef::create(pd::Shape{conf});
}

FixtureDef* BodyDef::chain(const Vec2 vertices[], int count, float friction, float restitution) {
	std::vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++) {
		vs[i] = pr::Length2{
			PhysicsWorld::prVal(vertices[i].x),
			PhysicsWorld::prVal(vertices[i].y)};
	}
	pd::ChainShapeConf conf = pd::ChainShapeConf{}
								  .Set(vs)
								  .UseFriction(friction)
								  .UseRestitution(restitution);
	return FixtureDef::create(pd::Shape{conf});
}

std::list<BodyDef::FixtureConf>& BodyDef::getFixtureConfs() {
	return _fixtureConfs;
}

void BodyDef::clearFixtures() {
	_fixtureConfs.clear();
}

void BodyDef::setLinearDamping(float var) {
	_conf.UseLinearDamping(var);
}

float BodyDef::getLinearDamping() const noexcept {
	return _conf.linearDamping;
}

void BodyDef::setAngularDamping(float var) {
	_conf.UseAngularDamping(var);
}

float BodyDef::getAngularDamping() const noexcept {
	return _conf.angularDamping;
}

void BodyDef::setLinearAcceleration(Vec2 var) {
	_conf.UseLinearAcceleration(pr::LinearAcceleration2{var.x, var.y});
}

Vec2 BodyDef::getLinearAcceleration() const noexcept {
	return {_conf.linearAcceleration[0], _conf.linearAcceleration[1]};
}

void BodyDef::setFixedRotation(bool var) {
	_conf.UseFixedRotation(var);
}

bool BodyDef::isFixedRotation() const noexcept {
	return _conf.fixedRotation;
}

void BodyDef::setBullet(bool var) {
	_conf.UseBullet(var);
}

bool BodyDef::isBullet() const noexcept {
	return _conf.bullet;
}

void BodyDef::setType(pr::BodyType var) {
	_conf.Use(var);
}

pr::BodyType BodyDef::getType() const noexcept {
	return _conf.type;
}

pd::BodyConf* BodyDef::getConf() {
	return &_conf;
}

NS_DORA_END
