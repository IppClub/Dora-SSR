/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once
#include "Support/Geometry.h"

NS_DOROTHY_BEGIN
NS_BEGIN(Soft)

/** @brief Each simulated particle has a unique material. The material specifies physical properties about
 that particle, including it's coefficient of friction, it's coefficient of restitution, and it's
 physical mass.
 */
struct Material
{
	// coefficient of friction [0.0, 1.0] (0 = ice, 1 = glue)
	float friction = 1.0f;
	// coefficient of resitution [0.0, 1.0] (0 = inelastic, 1 = elastic)
	float bounce = 0.0f;
	// physical mass
	float mass = 1.0f;
};

class World;

/** @brief A single point whose motion is simulated through space. Each particle is simulated using a
 Verlet integration method; each particle contains a reference to it's current position and it's
 position relative to the last time step. Velocity is implicitly claculated with direction and
 magnitude as the difference between this particle's current and previous position.
 */
class Particle
{
public:
	PROPERTY(Material*, Material);
	PROPERTY_READONLY_CREF(Vec2, Position);

	/** @brief Class constructor. Initialize the particle within the simulation world.
	 @param world reference to the simulation world this particle resides in
	 @param x particle horizontal position relative to the world
	 @param y particle vertical position relative to the world
	 @param material specify this particle's material; default if none provided
	 */
	Particle(World* world, float x = 0, float y = 0, Material* material = nullptr);

	/** @brief Simulate this particle's motion. A mass of zero denotes that the particle is 'pinned', and cannot move.
	 */
	void Simulate(float deltaTime);

	/** @brief Accelerate this particle. This method affects the particle's acceleration, disregarding mass.
	 Use this if you need to immediately affect the particle's acceleration.
	 @param rate applied acceleration (m/s^2)
	 */
	void Accelerate(const Vec2& rate);

	/** @brief Apply a force to this particle. This method affect's the particle's acceleration, taking it's
	 mass into account. To move an object, a large enough force must be applied to immediately
	 move it, or a smaller force over time must be applied.
	 @param force   force applied to the particle (N)
	 */
	void ApplyForce(const Vec2& force);

	/** @brief Apply an impulse to this particle. This method affect's the particle's velocity, taking it's
	 mass into account. Since the particle is simulated via Verlet integration, a change in the
	 particle's position results in an immediate change in velocity. Use this method to
	 immediately affect the particle's velocity.
	 @param impulse impulse directly applied to the particle (a*dt / m)
	 */
	void ApplyImpulse(const Vec2& impulse);

	/** @brief Set the acceleration of this particle to zero. By applying forces and resetting them after,
	 we ensure that the forces must be applied every time step of the simulation in order to be
	 regarded as a continuous force.
	 */
	void ResetForces();

	/** @brief Restrain this particle to the simulation world boundaries. If a particle exceeds the world
	 boundaries, we bounce it back into the world. We do this by correcting the particle's current
	 position to the boundary line, and adjust the previous position so that next time step the
	 particle maintains a velocity that is accurate as such the particle takes into account
	 restitution and friction.
	 */
	void Restrain();

private:
	Material* _material = nullptr; // particle material
	World* _world = nullptr; // world particle is simulated in
	Vec2 _position; // current position
	Vec2 _previous; // previous time-step [t-dt] position
	Vec2 _velocity; // [readme] particle velocity
	Vec2 _acceleration; // acceleration of the particle
	static Material defaultMaterial;
};

NS_END(Soft)
NS_DOROTHY_END

