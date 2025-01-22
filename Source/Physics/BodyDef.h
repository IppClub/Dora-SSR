/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Support/Geometry.h"

NS_DORA_BEGIN

namespace pr = playrho;
namespace pd = playrho::d2;

class Body;
class World;

class FixtureDef : public Object {
public:
	FixtureDef(const pd::Shape& shape)
		: shape(shape) { }
	pd::Shape shape;
	CREATE_FUNC_NOT_NULL(FixtureDef);
	DORA_TYPE_OVERRIDE(FixtureDef);
};

class BodyDef : public Object {
public:
	Vec2 offset;
	float angleOffset;
	std::string face;
	Vec2 facePos;
	PROPERTY(pr::BodyType, Type);
	PROPERTY(float, LinearDamping);
	PROPERTY(float, AngularDamping);
	PROPERTY(Vec2, LinearAcceleration);
	PROPERTY_BOOL(FixedRotation);
	PROPERTY_BOOL(Bullet);
	PROPERTY_READONLY_CALL(pd::BodyConf*, Conf);
	virtual ~BodyDef();
	void attachPolygon(
		const Vec2& center,
		float width,
		float height,
		float angle = 0.0f,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachPolygon(
		float width,
		float height,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachPolygon(
		const std::vector<Vec2>& vertices,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachPolygon(
		const Vec2 vertices[],
		int count,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachMulti(
		const std::vector<Vec2>& vertices,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachMulti(
		const Vec2 vertices[],
		int count,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachDisk(
		const Vec2& center,
		float radius,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachDisk(
		float radius,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachChain(
		const std::vector<Vec2>& vertices,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachChain(
		const Vec2 vertices[],
		int count,
		float friction = 0.2f,
		float restitution = 0.0f);
	void attachPolygonSensor(
		int tag,
		float width,
		float height);
	void attachPolygonSensor(
		int tag,
		const Vec2& center,
		float width,
		float height,
		float angle = 0.0f);
	void attachPolygonSensor(
		int tag,
		const std::vector<Vec2>& vertices);
	void attachPolygonSensor(
		int tag,
		const Vec2 vertices[],
		int count);
	void attachDiskSensor(
		int tag,
		const Vec2& center,
		float radius);
	void attachDiskSensor(
		int tag,
		float radius);
	static FixtureDef* disk(
		float radius,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	static FixtureDef* disk(
		const Vec2& center,
		float radius,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	static FixtureDef* polygon(
		const Vec2& center,
		float width,
		float height,
		float angle = 0.0f,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	static FixtureDef* polygon(
		float width,
		float height,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	static FixtureDef* polygon(
		const std::vector<Vec2>& vertices,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	static FixtureDef* polygon(
		const Vec2 vertices[],
		int count,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	static FixtureDef* multi(
		const std::vector<Vec2>& vertices,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	static FixtureDef* multi(
		const Vec2 vertices[],
		int count,
		float density = 0.0f,
		float friction = 0.2f,
		float restitution = 0.0f);
	static FixtureDef* chain(
		const std::vector<Vec2>& vertices,
		float friction = 0.2f,
		float restitution = 0.0f);
	static FixtureDef* chain(
		const Vec2 vertices[],
		int count,
		float friction = 0.2f,
		float restitution = 0.0f);

	struct FixtureConf {
		FixtureConf(int tag, pd::Shape&& shape)
			: tag(tag)
			, shape(std::move(shape)) { }
		int tag;
		pd::Shape shape;
	};
	std::list<FixtureConf>& getFixtureConfs();
	void clearFixtures();

	CREATE_FUNC_NOT_NULL(BodyDef);

protected:
	BodyDef();
	pd::BodyConf _conf;

private:
	std::list<FixtureConf> _fixtureConfs;
	DORA_TYPE_OVERRIDE(BodyDef);
};

NS_DORA_END
