/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/BodyDef.h"
#include "Physics/PhysicsWorld.h"
#include "Physics/Body.h"

NS_DOROTHY_BEGIN

FixtureDef BodyDef::_tempConf;

BodyDef::BodyDef():
angleOffset(0),
offset(Vec2::zero),
facePos(Vec2::zero)
{
	_conf.enabled = false;
}

BodyDef::~BodyDef()
{
	BodyDef::clearFixtures();
}

void BodyDef::attachPolygon(const Vec2& center, float width, float height, float angle, float density, float friction, float restitution)
{
	pd::PolygonShapeConf conf = pd::PolygonShapeConf{}
	.SetAsBox(
		PhysicsWorld::b2Val(width * 0.5f),
		PhysicsWorld::b2Val(height * 0.5f),
		PhysicsWorld::b2Val(center),
		-bx::toRad(angle)
	)
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_fixtureConfs.push_back({pd::Shape{conf}, pd::FixtureConf{}});
}

void BodyDef::attachPolygon(float width, float height, float density, float friction, float restitution)
{
	pd::PolygonShapeConf conf = pd::PolygonShapeConf{}
	.SetAsBox(
		PhysicsWorld::b2Val(width * 0.5f),
		PhysicsWorld::b2Val(height * 0.5f)
	)
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_fixtureConfs.push_back({pd::Shape{conf}, pd::FixtureConf{}});
}

void BodyDef::attachPolygon(const vector<Vec2>& vertices, float density, float friction, float restitution)
{
	vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	pd::PolygonShapeConf conf = pd::PolygonShapeConf{}
	.Set(vs)
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_fixtureConfs.push_back({pd::Shape{conf}, pd::FixtureConf{}});
}

void BodyDef::attachPolygon(const Vec2 vertices[], int count, float density, float friction, float restitution)
{
	vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	pd::PolygonShapeConf conf = pd::PolygonShapeConf{}
	.Set(vs)
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_fixtureConfs.push_back({pd::Shape{conf}, pd::FixtureConf{}});
}

void BodyDef::attachMulti(const vector<Vec2>& vertices, float density, float friction, float restitution)
{
	pd::MultiShapeConf conf = pd::MultiShapeConf{};
	pd::VertexSet vs;
	for (size_t i = 0; i < vertices.size(); i++)
	{
		if (vertices[i] == Vec2::zero)
		{
			if (vs.size() > 0)
			{
				conf.AddConvexHull(vs);
				vs.clear();
			}
		}
		else vs.add(pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		});
	}
	if (vs.size() > 0)
	{
		conf.AddConvexHull(vs);
	}
	conf
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_fixtureConfs.push_back({pd::Shape{conf}, pd::FixtureConf{}});
}

void BodyDef::attachMulti(const Vec2 vertices[], int count, float density, float friction, float restitution)
{
	pd::MultiShapeConf conf = pd::MultiShapeConf{};
	pd::VertexSet vs;
	for (int i = 0; i < count; i++)
	{
		if (vertices[i] == Vec2::zero)
		{
			if (vs.size() > 0)
			{
				conf.AddConvexHull(vs);
				vs.clear();
			}
		}
		else vs.add(pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		});
	}
	if (vs.size() > 0)
	{
		conf.AddConvexHull(vs);
	}
	conf
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_fixtureConfs.push_back({pd::Shape{conf}, pd::FixtureConf{}});
}

void BodyDef::attachDisk(const Vec2& center, float radius, float density, float friction, float restitution)
{
	pd::DiskShapeConf conf = pd::DiskShapeConf{}
	.UseLocation(PhysicsWorld::b2Val(center))
	.UseRadius(PhysicsWorld::b2Val(radius))
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_fixtureConfs.push_back({pd::Shape{conf}, pd::FixtureConf{}});
}

void BodyDef::attachDisk(float radius, float density, float friction, float restitution)
{
	BodyDef::attachDisk(Vec2::zero, radius, density, friction, restitution);
}

void BodyDef::attachChain(const vector<Vec2>& vertices, float friction, float restitution)
{
	vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	pd::ChainShapeConf conf = pd::ChainShapeConf{}
	.Set(vs)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_fixtureConfs.push_back({pd::Shape{conf}, pd::FixtureConf{}});
}

void BodyDef::attachChain(const Vec2 vertices[], int count, float friction, float restitution)
{
	vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	pd::ChainShapeConf conf = pd::ChainShapeConf{}
	.Set(vs)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_fixtureConfs.push_back({pd::Shape{conf}, pd::FixtureConf{}});
}

void BodyDef::attachPolygonSensor(int tag, float width, float height)
{
	BodyDef::attachPolygonSensor(tag, width, height, Vec2::zero, 0);
}

void BodyDef::attachPolygonSensor(int tag, float width, float height, const Vec2& center, float angle)
{
	_fixtureConfs.push_back(
	{
		pd::Shape{
			pd::PolygonShapeConf{}
			.SetAsBox(
				PhysicsWorld::b2Val(width * 0.5f),
				PhysicsWorld::b2Val(height * 0.5f),
				PhysicsWorld::b2Val(center),
				-bx::toRad(angle)
			)
		},
		pd::FixtureConf{}
			.UseUserData(r_cast<void*>(s_cast<intptr_t>(tag)))
			.UseIsSensor(true)
	});
}

void BodyDef::attachPolygonSensor(int tag, const vector<Vec2>& vertices)
{
	vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	_fixtureConfs.push_back(
	{
		pd::Shape{
			pd::PolygonShapeConf{}
				.Set(vs)
		},
		pd::FixtureConf{}
			.UseUserData(r_cast<void*>(s_cast<intptr_t>(tag)))
			.UseIsSensor(true)
	});
}

void BodyDef::attachPolygonSensor(int tag, const Vec2 vertices[], int count)
{
	vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	_fixtureConfs.push_back(
	{
		pd::Shape{
			pd::PolygonShapeConf{}
				.Set(vs)
		},
		pd::FixtureConf{}
			.UseUserData(r_cast<void*>(s_cast<intptr_t>(tag)))
			.UseIsSensor(true)
	});
}

void BodyDef::attachDiskSensor(int tag, const Vec2& center, float radius)
{
	_fixtureConfs.push_back(
	{
		pd::Shape{
			pd::DiskShapeConf{}
				.UseLocation(PhysicsWorld::b2Val(center))
				.UseRadius(PhysicsWorld::b2Val(radius))
		},
		pd::FixtureConf{}
			.UseUserData(r_cast<void*>(s_cast<intptr_t>(tag)))
			.UseIsSensor(true)
	});
}

void BodyDef::attachDiskSensor(int tag, float radius)
{
	BodyDef::attachDiskSensor(tag, Vec2::zero, radius);
}

FixtureDef* BodyDef::polygon(const Vec2& center, float width, float height, float angle, float density, float friction, float restitution)
{
	_tempConf = {
		pd::Shape{
			pd::PolygonShapeConf{}
				.SetAsBox(
					PhysicsWorld::b2Val(width * 0.5f),
					PhysicsWorld::b2Val(height * 0.5f),
					PhysicsWorld::b2Val(center),
					-bx::toRad(angle)
				)
				.UseDensity(density)
				.UseFriction(friction)
				.UseRestitution(restitution)
		},
		pd::FixtureConf{}
	};
	return &_tempConf;
}

FixtureDef* BodyDef::polygon(float width, float height, float density, float friction, float restitution)
{
	_tempConf = {
		pd::Shape{
			pd::PolygonShapeConf{}
				.SetAsBox(
					PhysicsWorld::b2Val(width * 0.5f),
					PhysicsWorld::b2Val(height * 0.5f)
				)
				.UseDensity(density)
				.UseFriction(friction)
				.UseRestitution(restitution)
		},
		pd::FixtureConf{}
	};
	return &_tempConf;
}

FixtureDef* BodyDef::polygon(const vector<Vec2>& vertices, float density, float friction, float restitution)
{
	vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	_tempConf = {
		pd::Shape{
			pd::PolygonShapeConf{}
				.Set(vs)
				.UseDensity(density)
				.UseFriction(friction)
				.UseRestitution(restitution)
		},
		pd::FixtureConf{}
	};
	return &_tempConf;
}

FixtureDef* BodyDef::polygon(const Vec2 vertices[], int count, float density, float friction, float restitution)
{
	vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	_tempConf = {
		pd::Shape{
			pd::PolygonShapeConf{}
				.Set(vs)
				.UseDensity(density)
				.UseFriction(friction)
				.UseRestitution(restitution)
		},
		pd::FixtureConf{}
	};
	return &_tempConf;
}

FixtureDef* BodyDef::multi(const vector<Vec2>& vertices, float density, float friction, float restitution)
{
	pd::MultiShapeConf conf = pd::MultiShapeConf{};
	pd::VertexSet vs;
	for (size_t i = 0; i < vertices.size(); i++)
	{
		if (vertices[i] == Vec2::zero)
		{
			if (vs.size() > 0)
			{
				conf.AddConvexHull(vs);
				vs.clear();
			}
		}
		else vs.add(pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		});
	}
	if (vs.size() > 0)
	{
		conf.AddConvexHull(vs);
	}
	conf
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_tempConf = {pd::Shape{conf}, pd::FixtureConf{}};
	return &_tempConf;
}

FixtureDef* BodyDef::multi(const Vec2 vertices[], int count, float density, float friction, float restitution)
{
	pd::MultiShapeConf conf = pd::MultiShapeConf{};
	pd::VertexSet vs;
	for (int i = 0; i < count; i++)
	{
		if (vertices[i] == Vec2::zero)
		{
			if (vs.size() > 0)
			{
				conf.AddConvexHull(vs);
				vs.clear();
			}
		}
		else vs.add(pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		});
	}
	if (vs.size() > 0)
	{
		conf.AddConvexHull(vs);
	}
	conf
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_tempConf = {pd::Shape{conf}, pd::FixtureConf{}};
	return &_tempConf;
}

FixtureDef* BodyDef::disk(const Vec2& center, float radius, float density, float friction, float restitution)
{
	pd::DiskShapeConf conf = pd::DiskShapeConf{}
	.UseLocation(PhysicsWorld::b2Val(center))
	.UseRadius(PhysicsWorld::b2Val(radius))
	.UseDensity(density)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_tempConf = {pd::Shape{conf}, pd::FixtureConf{}};
	return &_tempConf;
}

FixtureDef* BodyDef::disk(float radius, float density, float friction, float restitution)
{
	return BodyDef::disk(Vec2::zero, radius, density, friction, restitution);
}

FixtureDef* BodyDef::chain(const vector<Vec2>& vertices, float friction, float restitution)
{
	vector<pr::Length2> vs(vertices.size());
	for (size_t i = 0; i < vertices.size(); i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	pd::ChainShapeConf conf = pd::ChainShapeConf{}
	.Set(vs)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_tempConf = {pd::Shape{conf}, pd::FixtureConf{}};
	return &_tempConf;
}

FixtureDef* BodyDef::chain(const Vec2 vertices[], int count, float friction, float restitution)
{
	vector<pr::Length2> vs(count);
	for (int i = 0; i < count; i++)
	{
		vs[i] = pr::Length2{
			PhysicsWorld::b2Val(vertices[i].x),
			PhysicsWorld::b2Val(vertices[i].y)
		};
	}
	pd::ChainShapeConf conf = pd::ChainShapeConf{}
	.Set(vs)
	.UseFriction(friction)
	.UseRestitution(restitution);
	_tempConf = {pd::Shape{conf}, pd::FixtureConf{}};
	return &_tempConf;
}

std::list<FixtureDef>& BodyDef::getFixtureConfs()
{
	return _fixtureConfs;
}

void BodyDef::clearFixtures()
{
	_fixtureConfs.clear();
}

void BodyDef::setLinearDamping(float var)
{
	_conf.UseLinearDamping(var);
}

float BodyDef::getLinearDamping() const
{
	return _conf.linearDamping;
}

void BodyDef::setAngularDamping(float var)
{
	_conf.UseAngularDamping(var);
}

float BodyDef::getAngularDamping() const
{
	return _conf.angularDamping;
}

void BodyDef::setLinearAcceleration(Vec2 var)
{
	_conf.UseLinearAcceleration(pr::LinearAcceleration2{var.x, var.y});
}

Vec2 BodyDef::getLinearAcceleration() const
{
	return {_conf.linearAcceleration[0],_conf.linearAcceleration[1]};
}

void BodyDef::setFixedRotation(bool var)
{
	_conf.UseFixedRotation(var);
}

bool BodyDef::isFixedRotation() const
{
	return _conf.fixedRotation;
}

void BodyDef::setBullet(bool var)
{
	_conf.UseBullet(var);
}

bool BodyDef::isBullet() const
{
	return _conf.bullet;
}

void BodyDef::setType(int var)
{
	_conf.UseType(s_cast<pr::BodyType>(var));
}

int BodyDef::getType() const
{
	return s_cast<int>(_conf.type);
}

pd::BodyConf* BodyDef::getConf()
{
	return &_conf;
}

NS_DOROTHY_END
