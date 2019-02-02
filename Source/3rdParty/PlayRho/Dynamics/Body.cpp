/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
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

#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/Fixture.hpp"
#include "PlayRho/Dynamics/World.hpp"
#include "PlayRho/Dynamics/Contacts/Contact.hpp"
#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Common/WrongState.hpp"
#include "PlayRho/Dynamics/WorldAtty.hpp"

#include <iterator>
#include <type_traits>
#include <utility>

namespace playrho {
namespace d2 {

Body::FlagsType Body::GetFlags(const BodyConf& bd) noexcept
{
    // @invariant Only bodies that allow sleeping, can be put to sleep.
    // @invariant Only "speedable" bodies can be awake.
    // @invariant Only "speedable" bodies can have non-zero velocities.
    // @invariant Only "accelerable" bodies can have non-zero accelerations.
    // @invariant Only "accelerable" bodies can have non-zero "under-active" times.

    auto flags = GetFlags(bd.type);
    if (bd.bullet)
    {
        flags |= e_impenetrableFlag;
    }
    if (bd.fixedRotation)
    {
        flags |= e_fixedRotationFlag;
    }
    if (bd.allowSleep)
    {
        flags |= e_autoSleepFlag;
    }
    if (bd.awake)
    {
        if ((flags & e_velocityFlag) != 0)
        {
            flags |= e_awakeFlag;
        }
    }
    else
    {
        if (!bd.allowSleep && ((flags & e_velocityFlag) != 0))
        {
            flags |= e_awakeFlag;
        }
    }
    if (bd.enabled)
    {
        flags |= e_enabledFlag;
    }
    return flags;
}

Body::Body(World* world, const BodyConf& bd):
    m_xf{bd.location, UnitVec::Get(bd.angle)},
    m_sweep{Position{bd.location, bd.angle}},
    m_flags{GetFlags(bd)},
    m_world{world},
    m_userData{bd.userData},
    m_invMass{(bd.type == playrho::BodyType::Dynamic)? InvMass{Real{1} / Kilogram}: InvMass{0}},
    m_linearDamping{bd.linearDamping},
    m_angularDamping{bd.angularDamping}
{
    assert(IsValid(bd.location));
    assert(IsValid(bd.angle));
    assert(IsValid(bd.linearVelocity));
    assert(IsValid(bd.angularVelocity));
    assert(IsValid(m_xf));

    SetVelocity(Velocity{bd.linearVelocity, bd.angularVelocity});
    SetAcceleration(bd.linearAcceleration, bd.angularAcceleration);
    SetUnderActiveTime(bd.underActiveTime);
}

Body::~Body() noexcept
{
    assert(empty(m_joints));
    assert(empty(m_contacts));
    assert(empty(m_fixtures));
}

void Body::SetType(playrho::BodyType type)
{
    WorldAtty::SetType(*m_world, *this, type);
}

Fixture* Body::CreateFixture(const Shape& shape, const FixtureConf& def,
                             bool resetMassData)
{
    return WorldAtty::CreateFixture(*m_world, *this, shape, def, resetMassData);
}

bool Body::Destroy(Fixture* fixture, bool resetMassData)
{
    if (fixture->GetBody() != this)
    {
        return false;
    }
    return WorldAtty::Destroy(*m_world, *fixture, resetMassData);
}

void Body::DestroyFixtures()
{
    while (!empty(m_fixtures))
    {
        const auto fixture = GetPtr(m_fixtures.front());
        Destroy(fixture, false);
    }
    ResetMassData();
}

void Body::ResetMassData()
{
    // Compute mass data from shapes. Each shape has its own density.

    // Non-dynamic bodies (Static and kinematic ones) have zero mass.
    if (!IsAccelerable())
    {
        m_invMass = 0;
        m_invRotI = 0;
        m_sweep = Sweep{Position{GetLocation(), GetAngle()}};
        UnsetMassDataDirty();
        return;
    }

    const auto massData = ComputeMassData(*this);

    // Force all dynamic bodies to have a positive mass.
    const auto mass = (massData.mass > 0_kg)? Mass{massData.mass}: 1_kg;
    m_invMass = Real{1} / mass;

    // Compute center of mass.
    const auto localCenter = massData.center * Real{m_invMass * Kilogram};

    if ((massData.I > RotInertia{0}) && (!IsFixedRotation()))
    {
        // Center the inertia about the center of mass.
        const auto lengthSquared = GetMagnitudeSquared(localCenter);
        const auto I = RotInertia{massData.I} - RotInertia{(mass * lengthSquared / SquareRadian)};
        //assert((massData.I - mass * lengthSquared) > 0);
        m_invRotI = Real{1} / I;
    }
    else
    {
        m_invRotI = 0;
    }

    // Move center of mass.
    const auto oldCenter = GetWorldCenter();
    m_sweep = Sweep{Position{Transform(localCenter, GetTransformation()), GetAngle()}, localCenter};
    const auto newCenter = GetWorldCenter();

    // Update center of mass velocity.
    const auto deltaCenter = newCenter - oldCenter;
    m_velocity.linear += GetRevPerpendicular(deltaCenter) * (m_velocity.angular / Radian);

    UnsetMassDataDirty();
}

void Body::SetMassData(const MassData& massData)
{
    if (m_world->IsLocked())
    {
        throw WrongState("Body::SetMassData: world is locked");
    }

    if (!IsAccelerable())
    {
        return;
    }

    const auto mass = (massData.mass > 0_kg)? Mass{massData.mass}: 1_kg;
    m_invMass = Real{1} / mass;

    if ((massData.I > RotInertia{0}) && (!IsFixedRotation()))
    {
        const auto lengthSquared = GetMagnitudeSquared(massData.center);
        // L^2 M QP^-2
        const auto I = RotInertia{massData.I} - RotInertia{(mass * lengthSquared) / SquareRadian};
        assert(I > RotInertia{0});
        m_invRotI = Real{1} / I;
    }
    else
    {
        m_invRotI = 0;
    }

    // Move center of mass.
    const auto oldCenter = GetWorldCenter();
    m_sweep = Sweep{
        Position{Transform(massData.center, GetTransformation()), GetAngle()},
        massData.center
    };

    // Update center of mass velocity.
    const auto newCenter = GetWorldCenter();
    const auto deltaCenter = newCenter - oldCenter;
    m_velocity.linear += GetRevPerpendicular(deltaCenter) * (m_velocity.angular / Radian);

    UnsetMassDataDirty();
}

void Body::SetVelocity(const Velocity& velocity) noexcept
{
    if ((velocity.linear != LinearVelocity2{}) || (velocity.angular != 0_rpm))
    {
        if (!IsSpeedable())
        {
            return;
        }
        SetAwakeFlag();
        ResetUnderActiveTime();
    }
    m_velocity = velocity;
}

void Body::SetAcceleration(LinearAcceleration2 linear, AngularAcceleration angular) noexcept
{
    assert(IsValid(linear));
    assert(IsValid(angular));

    if ((m_linearAcceleration == linear) && (m_angularAcceleration == angular))
    {
        // no change, bail...
        return;
    }
    
    if (!IsAccelerable())
    {
        if ((linear != LinearAcceleration2{}) || (angular != AngularAcceleration{0}))
        {
            // non-accelerable bodies can only be set to zero acceleration, bail...
            return;
        }
    }
    else
    {
        if ((m_angularAcceleration < angular) ||
            (GetMagnitudeSquared(m_linearAcceleration) < GetMagnitudeSquared(linear)) ||
            (playrho::GetAngle(m_linearAcceleration) != playrho::GetAngle(linear)) ||
            (signbit(m_angularAcceleration) != signbit(angular)))
        {
            // Increasing accel or changing direction of accel, awake & reset time.
            SetAwakeFlag();
            ResetUnderActiveTime();
        }
    }
    
    m_linearAcceleration = linear;
    m_angularAcceleration = angular;
}

void Body::SetTransformation(Transformation value) noexcept
{
    assert(IsValid(value));
    if (m_xf != value)
    {
        m_xf = value;
        std::for_each(cbegin(m_contacts), cend(m_contacts), [&](KeyedContactPtr ci) {
            std::get<Contact*>(ci)->FlagForUpdating();
        });
    }
}

void Body::SetTransform(Length2 location, Angle angle)
{
    assert(IsValid(location));
    assert(IsValid(angle));

    if (GetWorld()->IsLocked())
    {
        throw WrongState("Body::SetTransform: world is locked");
    }

    const auto xfm = Transformation{location, UnitVec::Get(angle)};
    SetTransformation(xfm);

    m_sweep = Sweep{Position{Transform(GetLocalCenter(), xfm), angle}, GetLocalCenter()};
    
    WorldAtty::RegisterForProxies(*GetWorld(), *this);
}

void Body::SetEnabled(bool flag)
{
    if (IsEnabled() == flag)
    {
        return;
    }

    if (m_world->IsLocked())
    {
        throw WrongState("Body::SetEnabled: world is locked");
    }

    if (flag)
    {
        SetEnabledFlag();
    }
    else
    {
        UnsetEnabledFlag();
    }

    // Register for proxies so contacts created or destroyed the next time step.
    std::for_each(begin(m_fixtures), end(m_fixtures), [&](Fixtures::value_type &f) {
        WorldAtty::RegisterForProxies(*m_world, GetRef(f));
    });
}

void Body::SetFixedRotation(bool flag)
{
    const auto status = IsFixedRotation();
    if (status == flag)
    {
        return;
    }

    if (flag)
    {
        m_flags |= e_fixedRotationFlag;
    }
    else
    {
        m_flags &= ~e_fixedRotationFlag;
    }

    m_velocity.angular = 0_rpm;

    ResetMassData();
}

bool Body::Insert(Joint* joint)
{
    const auto bodyA = joint->GetBodyA();
    const auto bodyB = joint->GetBodyB();
    
    const auto other = (this == bodyA)? bodyB: (this == bodyB)? bodyA: nullptr;
    m_joints.push_back(std::make_pair(other, joint));
    return true;
}

bool Body::Insert(ContactKey key, Contact* contact)
{
#ifndef NDEBUG
    // Prevent the same contact from being added more than once...
    const auto it = std::find_if(cbegin(m_contacts), cend(m_contacts), [&](KeyedContactPtr ci) {
        return std::get<Contact*>(ci) == contact;
    });
    assert(it == end(m_contacts));
    if (it != end(m_contacts))
    {
        return false;
    }
#endif

    m_contacts.emplace_back(key, contact);
    return true;
}

bool Body::Erase(const Joint* joint)
{
    const auto it = std::find_if(begin(m_joints), end(m_joints), [&](KeyedJointPtr ji) {
        return std::get<Joint*>(ji) == joint;
    });
    if (it != end(m_joints))
    {
        m_joints.erase(it);
        return true;
    }
    return false;
}

bool Body::Erase(const Contact* contact)
{
    const auto it = std::find_if(begin(m_contacts), end(m_contacts), [&](KeyedContactPtr ci) {
        return std::get<Contact*>(ci) == contact;
    });
    if (it != end(m_contacts))
    {
        m_contacts.erase(it);
        return true;
    }
    return false;
}

void Body::ClearContacts()
{
    m_contacts.clear();
}

void Body::ClearJoints()
{
    m_joints.clear();
}

// Free functions...

bool ShouldCollide(const Body& lhs, const Body& rhs) noexcept
{
    // At least one body should be accelerable/dynamic.
    if (!lhs.IsAccelerable() && !rhs.IsAccelerable())
    {
        return false;
    }

    // Does a joint prevent collision?
    const auto joints = lhs.GetJoints();
    const auto it = std::find_if(cbegin(joints), cend(joints), [&](Body::KeyedJointPtr ji) {
        return (std::get<0>(ji) == &rhs) && !(std::get<Joint*>(ji)->GetCollideConnected());
    });
    return it == end(joints);
}

BodyCounter GetWorldIndex(const Body* body) noexcept
{
    if (body)
    {
        const auto world = body->GetWorld();
        const auto bodies = world->GetBodies();
        auto i = BodyCounter{0};
        const auto it = std::find_if(cbegin(bodies), cend(bodies), [&](const Body *b) {
            return b == body || ((void) ++i, false);
        });
        if (it != end(bodies))
        {
            return i;
        }
    }
    return BodyCounter(-1);
}

Velocity GetVelocity(const Body& body, Time h) noexcept
{
    // Integrate velocity and apply damping.
    auto velocity = body.GetVelocity();
    if (body.IsAccelerable())
    {
        // Integrate velocities.
        velocity.linear += h * body.GetLinearAcceleration();
        velocity.angular += h * body.GetAngularAcceleration();

        // Apply damping.
        // Ordinary differential equation: dv/dt + c * v = 0
        //                       Solution: v(t) = v0 * exp(-c * t)
        // Time step: v(t + dt) = v0 * exp(-c * (t + dt)) = v0 * exp(-c * t) * exp(-c * dt) = v * exp(-c * dt)
        // v2 = exp(-c * dt) * v1
        // Pade approximation (see https://en.wikipedia.org/wiki/Pad%C3%A9_approximant ):
        // v2 = v1 * 1 / (1 + c * dt)
        velocity.linear  /= Real{1 + h * body.GetLinearDamping()};
        velocity.angular /= Real{1 + h * body.GetAngularDamping()};
    }

    return velocity;
}

Velocity Cap(Velocity velocity, Time h, MovementConf conf) noexcept
{
    const auto translation = h * velocity.linear;
    const auto lsquared = GetMagnitudeSquared(translation);
    if (lsquared > Square(conf.maxTranslation))
    {
        // Scale back linear velocity so max translation not exceeded.
        const auto ratio = conf.maxTranslation / sqrt(lsquared);
        velocity.linear *= ratio;
    }
    
    const auto absRotation = abs(h * velocity.angular);
    if (absRotation > conf.maxRotation)
    {
        // Scale back angular velocity so max rotation not exceeded.
        const auto ratio = conf.maxRotation / absRotation;
        velocity.angular *= ratio;
    }
    
    return velocity;
}

std::size_t GetFixtureCount(const Body& body) noexcept
{
    const auto& fixtures = body.GetFixtures();
    return size(fixtures);
}

void RotateAboutWorldPoint(Body& body, Angle amount, Length2 worldPoint)
{
    const auto xfm = body.GetTransformation();
    const auto p = xfm.p - worldPoint;
    const auto c = cos(amount);
    const auto s = sin(amount);
    const auto x = GetX(p) * c - GetY(p) * s;
    const auto y = GetX(p) * s + GetY(p) * c;
    const auto pos = Length2{x, y} + worldPoint;
    const auto angle = GetAngle(xfm.q) + amount;
    body.SetTransform(pos, angle);
}

void RotateAboutLocalPoint(Body& body, Angle amount, Length2 localPoint)
{
    RotateAboutWorldPoint(body, amount, GetWorldPoint(body, localPoint));
}

Force2 GetCentripetalForce(const Body& body, Length2 axis)
{
    // For background on centripetal force, see:
    //   https://en.wikipedia.org/wiki/Centripetal_force

    // Force is M L T^-2.
    const auto velocity = GetLinearVelocity(body);
    const auto magnitudeOfVelocity = GetMagnitude(GetVec2(velocity)) * MeterPerSecond;
    const auto location = body.GetLocation();
    const auto mass = GetMass(body);
    const auto delta = axis - location;
    const auto radius = GetMagnitude(delta);
    const auto dir = delta / radius;
    return Force2{dir * mass * Square(magnitudeOfVelocity) / radius};
}

Acceleration CalcGravitationalAcceleration(const Body& body) noexcept
{
    const auto m1 = GetMass(body);
    if (m1 != 0_kg)
    {
        const auto loc1 = GetLocation(body);
        auto sumForce = Force2{};
        const auto world = body.GetWorld();
        const auto bodies = world->GetBodies();
        for (auto jt = begin(bodies); jt != end(bodies); jt = std::next(jt))
        {
            const auto& b2 = *(*jt);
            if (&b2 == &body)
            {
                continue;
            }
            const auto m2 = GetMass(b2);
            const auto delta = GetLocation(b2) - loc1;
            const auto dir = GetUnitVector(delta);
            const auto rr = GetMagnitudeSquared(delta);
            const auto orderedMass = std::minmax(m1, m2);
            const auto f = (BigG * std::get<0>(orderedMass)) * (std::get<1>(orderedMass) / rr);
            sumForce += f * dir;
        }
        // F = m a... i.e.  a = F / m.
        return Acceleration{sumForce / m1, 0 * RadianPerSquareSecond};
    }
    return Acceleration{};
}

} // namespace d2
} // namespace playrho
