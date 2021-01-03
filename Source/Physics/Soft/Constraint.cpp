/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/Soft/Constraint.h"
#include "Physics/Soft/Particle.h"

NS_DOROTHY_BEGIN
NS_BEGIN(Soft)

Particle* Constraint::getNodeA() const
{
	return _node1;
}

Particle* Constraint::getNodeB() const
{
	return _node2;
}

Constraint::Constraint(Particle* p1, Particle* p2, float s, std::optional<float> d):
_node1(p1),
_node2(p2),
_stiff(s)
{
	if (d)
	{
		_target = d.value();
	}
	else
	{
		_target = std::sqrt(std::pow(p2->getPosition().x - p1->getPosition().x, 2) + std::pow(p2->getPosition().y - p1->getPosition().y, 2));
	}
}

void Constraint::Relax()
{
	Vec2 D = _node2->getPosition() - _node1->getPosition();
	Vec2 F = Vec2::normalize(D) * (0.5f * _stiff * (D.length() - _target));
	if (F == Vec2::zero) return;
	if (_node1->getMaterial()->mass > 0 && _node2->getMaterial()->mass == 0)
	{
		_node1->ApplyImpulse(F * 2.0f);
	}
	else if (_node1->getMaterial()->mass == 0 && _node2->getMaterial()->mass > 0)
	{
		_node2->ApplyImpulse(-F * 2.0f);
	}
	else
	{
		_node1->ApplyImpulse(F);
		_node2->ApplyImpulse(-F);
	}
}

NS_END(Soft)
NS_DOROTHY_END

