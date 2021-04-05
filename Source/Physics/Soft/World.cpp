/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/Soft/World.h"

NS_DOROTHY_BEGIN
NS_BEGIN(Soft)

const std::vector<Own<Particle>>& World::getParticles() const
{
	return _particles;
}

const std::vector<Own<Constraint>>& World::getConstraints() const
{
	return _constraints;
}

const Vec2& World::getSize() const
{
	return _size;
}

World::World(const Vec2& s, const Vec2& g):
_size(s),
_hsize(s * 0.5f),
_gravity(g)
{ }

void World::Simulate(float deltaTime)
{
	for (auto& particle : _particles)
	{
		particle->Accelerate(_gravity);
		particle->Simulate(deltaTime);
		particle->Restrain();
		particle->ResetForces();
	}
	for (auto& constraint : _constraints)
	{
		constraint->Relax();
	}
}

Particle* World::AddParticle(float x, float y, Material* mat)
{
	_particles.push_back(New<Particle>(this, x, y, mat));
	return _particles.back().get();
}

Constraint* World::AddConstraint(Particle* p1, Particle* p2, float s, std::optional<float> d)
{
	_constraints.push_back(New<Constraint>(p1, p2, s, d));
	return _constraints.back().get();
}

void World::clear()
{
	_particles.clear();
	_constraints.clear();
}

NS_END(Soft)
NS_DOROTHY_END

