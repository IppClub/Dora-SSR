/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once
#include "Support/Geometry.h"

NS_DOROTHY_BEGIN
NS_BEGIN(Soft)

class Particle;

class Constraint
{
public:
	PROPERTY_READONLY(Particle*, NodeA);
	PROPERTY_READONLY(Particle*, NodeB);

	/** @brief Class constructor. Grab references of the two constrained particles, get a specified spring
	 constant for the constraint, and establish a target distance between the particles.
	 @param p1 first particle constrained
	 @param p2 second particle constrained
	 @param s spring constant [0.0, 1.0]
	 @param d distance constraint (default seprerating distance)
	 */
	Constraint(Particle* p1, Particle* p2, float s, std::optional<float> d = std::nullopt);

	/** @brief Attempt to maintain the target distance between the two constrained particles. Calculate the
	 distance between the two particles and apply a restoring impulse to each particle.
	 */
	void Relax();

private:
	// first constrained particle
	Particle* _node1 = nullptr;
	// second constrained particle
	Particle* _node2 = nullptr;
	// target distance the particles try to maintain from one another
	float _target = 0;
	// Hooke's law spring constant [0.0, 1.0] (0 = no spring, 1 = rigid bar)
	float _stiff = 1.0f;
	// Hooke's law dampening constant
	float _damp = 0;
};

NS_END(Soft)
NS_DOROTHY_END

