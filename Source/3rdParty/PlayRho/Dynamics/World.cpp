/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include "PlayRho/Dynamics/World.hpp"

#include "PlayRho/Dynamics/WorldImplBody.hpp"
#include "PlayRho/Dynamics/WorldImplContact.hpp"
#include "PlayRho/Dynamics/WorldImplFixture.hpp"
#include "PlayRho/Dynamics/WorldImplJoint.hpp"
#include "PlayRho/Dynamics/WorldImplMisc.hpp"

#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible<World>::value, "World must be default constructible!");
static_assert(std::is_copy_constructible<World>::value, "World must be copy constructible!");
static_assert(std::is_copy_assignable<World>::value, "World must be copy assignable!");
static_assert(std::is_move_constructible<World>::value, "World must be move constructible!");
static_assert(std::is_move_assignable<World>::value, "World must be move assignable!");
static_assert(std::is_nothrow_destructible<World>::value, "World must be nothrow destructible!");

// Special member functions are off in their own .cpp file to avoid their
// necessary includes being in this file!!

void World::Clear() noexcept
{
    ::playrho::d2::Clear(*m_impl);
}

void World::SetFixtureDestructionListener(const FixtureListener& listener) noexcept
{
    ::playrho::d2::SetFixtureDestructionListener(*m_impl, listener);
}

void World::SetJointDestructionListener(const JointListener& listener) noexcept
{
    ::playrho::d2::SetJointDestructionListener(*m_impl, listener);
}

void World::SetBeginContactListener(ContactListener listener) noexcept
{
    ::playrho::d2::SetBeginContactListener(*m_impl, listener);
}

void World::SetEndContactListener(ContactListener listener) noexcept
{
    ::playrho::d2::SetEndContactListener(*m_impl, listener);
}

void World::SetPreSolveContactListener(ManifoldContactListener listener) noexcept
{
    ::playrho::d2::SetPreSolveContactListener(*m_impl, listener);
}

void World::SetPostSolveContactListener(ImpulsesContactListener listener) noexcept
{
    ::playrho::d2::SetPostSolveContactListener(*m_impl, listener);
}

BodyID World::CreateBody(const BodyConf& def)
{
    return ::playrho::d2::CreateBody(*m_impl, def);
}

void World::Destroy(BodyID id)
{
    ::playrho::d2::Destroy(*m_impl, id);
}

JointID World::CreateJoint(const Joint& def)
{
    return ::playrho::d2::CreateJoint(*m_impl, def);
}

void World::Destroy(JointID id)
{
    ::playrho::d2::Destroy(*m_impl, id);
}

StepStats World::Step(const StepConf& conf)
{
    return ::playrho::d2::Step(*m_impl, conf);
}

void World::ShiftOrigin(Length2 newOrigin)
{
    ::playrho::d2::ShiftOrigin(*m_impl, newOrigin);
}

BodyCounter World::GetBodyRange() const noexcept
{
    return ::playrho::d2::GetBodyRange(*m_impl);
}

SizedRange<World::Bodies::const_iterator> World::GetBodies() const noexcept
{
    return ::playrho::d2::GetBodies(*m_impl);
}

SizedRange<World::Bodies::const_iterator> World::GetBodiesForProxies() const noexcept
{
    return ::playrho::d2::GetBodiesForProxies(*m_impl);
}

SizedRange<World::Joints::const_iterator> World::GetJoints() const noexcept
{
    return ::playrho::d2::GetJoints(*m_impl);
}

SizedRange<World::BodyJoints::const_iterator> World::GetJoints(BodyID id) const
{
    return ::playrho::d2::GetJoints(*m_impl, id);
}

bool World::IsSpeedable(BodyID id) const
{
    return ::playrho::d2::IsSpeedable(*m_impl, id);
}

bool World::IsAccelerable(BodyID id) const
{
    return ::playrho::d2::IsAccelerable(*m_impl, id);
}

bool World::IsImpenetrable(BodyID id) const
{
    return ::playrho::d2::IsImpenetrable(*m_impl, id);
}

void World::SetImpenetrable(BodyID id)
{
    ::playrho::d2::SetImpenetrable(*m_impl, id);
}

void World::UnsetImpenetrable(BodyID id)
{
    ::playrho::d2::UnsetImpenetrable(*m_impl, id);
}

bool World::IsSleepingAllowed(BodyID id) const
{
    return ::playrho::d2::IsSleepingAllowed(*m_impl, id);
}

void World::SetSleepingAllowed(BodyID id, bool value)
{
    ::playrho::d2::SetSleepingAllowed(*m_impl, id, value);
}

SizedRange<World::Contacts::const_iterator> World::GetContacts(BodyID id) const
{
    return ::playrho::d2::GetContacts(*m_impl, id);
}

SizedRange<World::Contacts::const_iterator> World::GetContacts() const noexcept
{
    return ::playrho::d2::GetContacts(*m_impl);
}

bool World::IsLocked() const noexcept
{
    return m_impl && ::playrho::d2::IsLocked(*m_impl);
}

bool World::IsStepComplete() const noexcept
{
    return ::playrho::d2::IsStepComplete(*m_impl);
}

bool World::GetSubStepping() const noexcept
{
    return ::playrho::d2::GetSubStepping(*m_impl);
}

void World::SetSubStepping(bool flag) noexcept
{
    ::playrho::d2::SetSubStepping(*m_impl, flag);
}

Length World::GetMinVertexRadius() const noexcept
{
    return ::playrho::d2::GetMinVertexRadius(*m_impl);
}

Length World::GetMaxVertexRadius() const noexcept
{
    return ::playrho::d2::GetMaxVertexRadius(*m_impl);
}

Frequency World::GetInvDeltaTime() const noexcept
{
    return ::playrho::d2::GetInvDeltaTime(*m_impl);
}

const DynamicTree& World::GetTree() const noexcept
{
    return ::playrho::d2::GetTree(*m_impl);
}

void World::Refilter(FixtureID id)
{
    ::playrho::d2::Refilter(*m_impl, id);
}

void World::SetType(BodyID id, BodyType type)
{
    ::playrho::d2::SetType(*m_impl, id, type);
}

FixtureID World::CreateFixture(const FixtureConf& def, bool resetMassData)
{
    return ::playrho::d2::CreateFixture(*m_impl, def, resetMassData);
}

const FixtureConf& World::GetFixture(FixtureID id) const
{
    return ::playrho::d2::GetFixture(*m_impl, id);
}

void World::SetFixture(FixtureID id, const FixtureConf& value)
{
    ::playrho::d2::SetFixture(*m_impl, id, value);
}

bool World::Destroy(FixtureID id, bool resetMassData)
{
    return ::playrho::d2::Destroy(*m_impl, id, resetMassData);
}

void World::DestroyFixtures(BodyID id)
{
    ::playrho::d2::DestroyFixtures(*m_impl, id);
}

bool World::IsEnabled(BodyID id) const
{
    return ::playrho::d2::IsEnabled(*m_impl, id);
}

void World::SetEnabled(BodyID id, bool flag)
{
    ::playrho::d2::SetEnabled(*m_impl, id, flag);
}

MassData World::ComputeMassData(BodyID id) const
{
    return ::playrho::d2::ComputeMassData(*m_impl, id);
}

void World::SetMassData(BodyID id, const MassData& massData)
{
    ::playrho::d2::SetMassData(*m_impl, id, massData);
}

Frequency World::GetLinearDamping(BodyID id) const
{
    return ::playrho::d2::GetLinearDamping(*m_impl, id);
}

void World::SetLinearDamping(BodyID id, NonNegative<Frequency> value)
{
    ::playrho::d2::SetLinearDamping(*m_impl, id, value);
}

Frequency World::GetAngularDamping(BodyID id) const
{
    return ::playrho::d2::GetAngularDamping(*m_impl, id);
}

void World::SetAngularDamping(BodyID id, NonNegative<Frequency> value)
{
    ::playrho::d2::SetAngularDamping(*m_impl, id, value);
}

SizedRange<World::Fixtures::const_iterator> World::GetFixtures(BodyID id) const
{
    return ::playrho::d2::GetFixtures(*m_impl, id);
}

FixtureCounter World::GetShapeCount() const noexcept
{
    return ::playrho::d2::GetShapeCount(*m_impl);
}

BodyConf World::GetBodyConf(BodyID id) const
{
    return ::playrho::d2::GetBodyConf(*m_impl, id);
}

Angle World::GetAngle(BodyID id) const
{
    return ::playrho::d2::GetAngle(*m_impl, id);
}

Transformation World::GetTransformation(BodyID id) const
{
    return ::playrho::d2::GetTransformation(*m_impl, id);
}

void World::SetTransformation(BodyID id, Transformation xfm)
{
    return ::playrho::d2::SetTransformation(*m_impl, id, xfm);
}

Length2 World::GetLocalCenter(BodyID id) const
{
    return ::playrho::d2::GetLocalCenter(*m_impl, id);
}

Length2 World::GetWorldCenter(BodyID id) const
{
    return ::playrho::d2::GetWorldCenter(*m_impl, id);
}

Velocity World::GetVelocity(BodyID id) const
{
    return ::playrho::d2::GetVelocity(*m_impl, id);
}

void World::SetVelocity(BodyID id, const Velocity& value)
{
    ::playrho::d2::SetVelocity(*m_impl, id, value);
}

void World::UnsetAwake(BodyID id)
{
    ::playrho::d2::UnsetAwake(*m_impl, id);
}

void World::SetAwake(BodyID id)
{
    ::playrho::d2::SetAwake(*m_impl, id);
}

bool World::IsAwake(ContactID id) const
{
    return ::playrho::d2::IsAwake(*m_impl, id);
}

void World::SetAwake(ContactID id)
{
    ::playrho::d2::SetAwake(*m_impl, id);
}

LinearVelocity World::GetTangentSpeed(ContactID id) const
{
    return ::playrho::d2::GetTangentSpeed(*m_impl, id);
}

void World::SetTangentSpeed(ContactID id, LinearVelocity value)
{
    ::playrho::d2::SetTangentSpeed(*m_impl, id, value);
}

bool World::IsMassDataDirty(BodyID id) const
{
    return ::playrho::d2::IsMassDataDirty(*m_impl, id);
}

bool World::IsFixedRotation(BodyID id) const
{
    return ::playrho::d2::IsFixedRotation(*m_impl, id);
}

void World::SetFixedRotation(BodyID id, bool value)
{
    ::playrho::d2::SetFixedRotation(*m_impl, id, value);
}

BodyType World::GetType(BodyID id) const
{
    return ::playrho::d2::GetType(*m_impl, id);
}

bool World::IsAwake(BodyID id) const
{
    return ::playrho::d2::IsAwake(*m_impl, id);
}

LinearAcceleration2 World::GetLinearAcceleration(BodyID id) const
{
    return ::playrho::d2::GetLinearAcceleration(*m_impl, id);
}

AngularAcceleration World::GetAngularAcceleration(BodyID id) const
{
    return ::playrho::d2::GetAngularAcceleration(*m_impl, id);
}

void World::SetAcceleration(BodyID id, LinearAcceleration2 linear, AngularAcceleration angular)
{
    ::playrho::d2::SetAcceleration(*m_impl, id, linear, angular);
}

InvMass World::GetInvMass(BodyID id) const
{
    return ::playrho::d2::GetInvMass(*m_impl, id);
}

InvRotInertia World::GetInvRotInertia(BodyID id) const
{
    return ::playrho::d2::GetInvRotInertia(*m_impl, id);
}

const Joint& World::GetJoint(JointID id) const
{
    return ::playrho::d2::GetJoint(*m_impl, id);
}

void World::SetJoint(JointID id, const Joint& def)
{
    ::playrho::d2::SetJoint(*m_impl, id, def);
}

bool World::IsTouching(ContactID id) const
{
    return ::playrho::d2::IsTouching(*m_impl, id);
}

bool World::NeedsFiltering(ContactID id) const
{
    return ::playrho::d2::NeedsFiltering(*m_impl, id);
}

bool World::NeedsUpdating(ContactID id) const
{
    return ::playrho::d2::NeedsUpdating(*m_impl, id);
}

bool World::HasValidToi(ContactID id) const
{
    return ::playrho::d2::HasValidToi(*m_impl, id);
}

Real World::GetToi(ContactID id) const
{
    return ::playrho::d2::GetToi(*m_impl, id);
}

FixtureID World::GetFixtureA(ContactID id) const
{
    return ::playrho::d2::GetFixtureA(*m_impl, id);
}

FixtureID World::GetFixtureB(ContactID id) const
{
    return ::playrho::d2::GetFixtureB(*m_impl, id);
}

BodyID World::GetBodyA(ContactID id) const
{
    return ::playrho::d2::GetBodyA(*m_impl, id);
}

BodyID World::GetBodyB(ContactID id) const
{
    return ::playrho::d2::GetBodyB(*m_impl, id);
}

ChildCounter World::GetChildIndexA(ContactID id) const
{
    return ::playrho::d2::GetChildIndexA(*m_impl, id);
}

ChildCounter World::GetChildIndexB(ContactID id) const
{
    return ::playrho::d2::GetChildIndexB(*m_impl, id);
}

TimestepIters World::GetToiCount(ContactID id) const
{
    return ::playrho::d2::GetToiCount(*m_impl, id);
}

Real World::GetDefaultFriction(ContactID id) const
{
    return ::playrho::d2::GetDefaultFriction(*m_impl, id);
}

Real World::GetDefaultRestitution(ContactID id) const
{
    return ::playrho::d2::GetDefaultRestitution(*m_impl, id);
}

Real World::GetFriction(ContactID id) const
{
    return ::playrho::d2::GetFriction(*m_impl, id);
}

Real World::GetRestitution(ContactID id) const
{
    return ::playrho::d2::GetRestitution(*m_impl, id);
}

void World::SetFriction(ContactID id, Real value)
{
    ::playrho::d2::SetFriction(*m_impl, id, value);
}

void World::SetRestitution(ContactID id, Real value)
{
    ::playrho::d2::SetRestitution(*m_impl, id, value);
}

const Manifold& World::GetManifold(ContactID id) const
{
    return ::playrho::d2::GetManifold(*m_impl, id);
}

bool World::IsEnabled(ContactID id) const
{
    return ::playrho::d2::IsEnabled(*m_impl, id);
}

void World::SetEnabled(ContactID id)
{
    ::playrho::d2::SetEnabled(*m_impl, id);
}

void World::UnsetEnabled(ContactID id)
{
    ::playrho::d2::UnsetEnabled(*m_impl, id);
}

} // namespace d2
} // namespace playrho
