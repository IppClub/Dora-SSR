/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/SoftNode.h"
#include "Physics/Soft/Constraint.h"
#include "Common/Utils.h"
#include "Node/DrawNode.h"
#include "Physics/PhysicsWorld.h"

NS_DOROTHY_BEGIN

SoftNode::SoftNode(float minX, float maxX, float minY, float maxY, float step):
_minX(minX/PhysicsWorld::b2Factor),
_maxX(maxX/PhysicsWorld::b2Factor),
_minY(minY/PhysicsWorld::b2Factor),
_maxY(maxY/PhysicsWorld::b2Factor),
_step(step)
{ }

bool SoftNode::init()
{
	_world = New<Soft::World>(Vec2{640/PhysicsWorld::b2Factor, 480/PhysicsWorld::b2Factor}, Vec2{0, 10});
	_originMaterial = New<Soft::Material>();
	_originMaterial->mass = 0;
	_size = {(_maxX - _minX) / _step, (_maxY - _minY) / _step};
	_nodes.resize(_step);
	for (auto& row : _nodes)
	{
		row.resize(_step);
	}
	// generate particles in a grid
	for (int y = 0; y < _step; y++)
	{
		for (int x = 0; x < _step; x++)
		{
			auto par = _world->AddParticle(_minX + x * _size.x, _minY + y * _size.y);
			_nodes[y][x] = par;
			if (y == 0)
			{
				par->setMaterial(_originMaterial.get());
			}
			else if (y == _step - 1)
			{
				par->ApplyForce(Vec2{Math::rand0to1() * 500.0f, 500.0f});
			}
		}
	}
	// add horizontal constraints
	for (int y = 0; y < _step; y++)
	{
		for (int x = 1; x < _step; x++)
		{
			_world->AddConstraint(_nodes[y][x-1], _nodes[y][x], 0.1f);
		}
	}
	// add vertical constraints
	for (int y = 1; y < _step; y++)
	{
		for (int x = 0; x < _step; x++)
		{
			_world->AddConstraint(_nodes[y-1][x], _nodes[y][x], 1.0f);
		}
	}
	scheduleUpdate();
	_line = Line::create();
	addChild(_line);
	return true;
}

bool SoftNode::update(double deltaTime)
{
	_world->Simulate(deltaTime);
	_line->clear();
	for (const auto& contrant : _world->getConstraints())
	{
		Vec2 posA = contrant->getNodeA()->getPosition();
		Vec2 posB = contrant->getNodeB()->getPosition();
		_line->add({
			PhysicsWorld::oVal(Vec2{posA.x,-posA.y}),
			PhysicsWorld::oVal(Vec2{posB.x,-posB.y})},
			Color(0xff00ffff));
	}
	return false;
}

NS_DOROTHY_END
