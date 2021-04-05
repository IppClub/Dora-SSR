/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once
#include "Support/Geometry.h"
#include "Physics/Soft/Particle.h"
#include "Physics/Soft/Constraint.h"

NS_DOROTHY_BEGIN
NS_BEGIN(Soft)

class World
{
public:
	PROPERTY_READONLY_CREF(std::vector<Own<Particle>>, Particles);
	PROPERTY_READONLY_CREF(std::vector<Own<Constraint>>, Constraints);
	PROPERTY_READONLY_CREF(Vec2, Size);

	/** @brief Class constructor. Initialize the simulation world. Set global constants.
	 @param s simulation world size
	 @param g global acceleration constant
	 @param t number of time steps to simulate per simlation step
	 */
	World(const Vec2& s = Vec2::zero, const Vec2& g = {0.0, 9.8});

	/** @brief Simulate a number of time steps on our simulation world. For each time step, we satisfy
	 constraints between particles, accelerate all particles by the universal gravitational
	 acceleration, simulate motion of each particle, then constraint the particles to the
	 simulation world boundaries.
	 */
	void Simulate(float deltaTime);

	/** @brief Create and add a particle to the simulation world.
	 @param x horizontal position of the particle
	 @param y vertical position of the particle
	 */
	Particle* AddParticle(float x, float y, Material* mat = nullptr);

	/** @brief Create and add a constraint between two particles in the simulation world.
	 @param p1 first particle to be constrained
	 @param p2 second particle to be constrained
	 @param s constraint spring stiffness [0.0, 1.0]
	 @param d distance constraint (default seperating distance)
	 */
	Constraint* AddConstraint(Particle* p1, Particle* p2, float s, std::optional<float> d = std::nullopt);

	void clear();

private:
	// world size/boundaries
	Vec2 _size;
	// half-size world size/boundaries
	Vec2 _hsize;
	// global gravitational acceleration
	Vec2 _gravity;
	// list of all particles being simulated
	std::vector<Own<Particle>> _particles;
	// list of all constraints being simulated
	std::vector<Own<Constraint>> _constraints;
};

NS_END(Soft)
NS_DOROTHY_END
