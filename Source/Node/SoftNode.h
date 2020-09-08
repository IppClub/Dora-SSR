/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "Physics/Soft/World.h"
#include "Physics/Soft/Particle.h"

NS_DOROTHY_BEGIN

class Line;

class SoftNode : public Node
{
public:
	virtual bool init() override;
	virtual bool update(double deltaTime) override;
	CREATE_FUNC(SoftNode);
protected:
	SoftNode(float minX, float maxX, float minY, float maxY, float step);
private:
	float _minX;
	float _maxX;
	float _minY;
	float _maxY;
	int _step;
	Vec2 _size;
	Own<Soft::World> _world;
	Own<Soft::Material> _originMaterial;
	Ref<Line> _line;
	vector<vector<Soft::Particle*>> _nodes;
	DORA_TYPE_OVERRIDE(SoftNode);
};

NS_DOROTHY_END
