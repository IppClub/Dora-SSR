/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include <type_traits>
#include <utility>

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible<Body>::value, "Body must be default constructible!");
static_assert(std::is_copy_constructible<Body>::value, "Body must be copy constructible!");
static_assert(std::is_move_constructible<Body>::value, "Body must be move constructible!");
static_assert(std::is_copy_assignable<Body>::value, "Body must be copy assignable!");
static_assert(std::is_move_assignable<Body>::value, "Body must be move assignable!");
static_assert(std::is_nothrow_destructible<Body>::value, "Body must be nothrow destructible!");

Body::FlagsType Body::GetFlags(BodyType type) noexcept
{
    auto flags = FlagsType{0};
    switch (type) {
    case BodyType::Dynamic:
        flags |= (e_velocityFlag | e_accelerationFlag);
        break;
    case BodyType::Kinematic:
        flags |= (e_impenetrableFlag | e_velocityFlag);
        break;
    case BodyType::Static:
        flags |= (e_impenetrableFlag);
        break;
    }
    return flags;
}

Body::FlagsType Body::GetFlags(const BodyConf& bd) noexcept
{
    // @invariant Only bodies that allow sleeping, can be put to sleep.
    // @invariant Only "speedable" bodies can be awake.
    // @invariant Only "speedable" bodies can have non-zero velocities.
    // @invariant Only "accelerable" bodies can have non-zero accelerations.
    // @invariant Only "accelerable" bodies can have non-zero "under-active" times.

    auto flags = GetFlags(bd.type);
    if (bd.bullet) {
        flags |= e_impenetrableFlag;
    }
    if (bd.fixedRotation) {
        flags |= e_fixedRotationFlag;
    }
    if (bd.allowSleep) {
        flags |= e_autoSleepFlag;
    }
    if (bd.awake) {
        if ((flags & e_velocityFlag) != 0) {
            flags |= e_awakeFlag;
        }
    }
    else {
        if (!bd.allowSleep && ((flags & e_velocityFlag) != 0)) {
            flags |= e_awakeFlag;
        }
    }
    if (bd.enabled) {
        flags |= e_enabledFlag;
    }
    return flags;
}

Body::Body(const BodyConf& bd) noexcept
    : m_xf{::playrho::d2::GetTransformation(bd)},
      m_sweep{Position{bd.location, bd.angle}},
      m_flags{GetFlags(bd)},
      m_invMass{(bd.type == playrho::BodyType::Dynamic) ? InvMass{Real{1} / Kilogram} : InvMass{0}},
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
    if (bd.shape != InvalidShapeID) {
        m_shapes.push_back(bd.shape);
    }
}

BodyType Body::GetType() const noexcept
{
    switch (m_flags & (e_accelerationFlag | e_velocityFlag)) {
    case e_velocityFlag | e_accelerationFlag:
        return BodyType::Dynamic;
    case e_velocityFlag:
        return BodyType::Kinematic;
    default:
        break; // handle case 0 this way so compiler doesn't warn of no default handling.
    }
    return BodyType::Static;
}

void Body::SetType(BodyType value) noexcept
{
    m_flags &= ~(e_impenetrableFlag | e_velocityFlag | e_accelerationFlag);
    m_flags |= GetFlags(value);
    switch (value) {
    case BodyType::Dynamic: // IsSpeedable() && IsAccelerable()
        SetAwakeFlag();
        break;
    case BodyType::Kinematic: // IsSpeedable() && !IsAccelerable()
        SetAwakeFlag();
        m_linearAcceleration = LinearAcceleration2{};
        m_angularAcceleration = AngularAcceleration{};
        SetInvMassData(InvMass{}, InvRotInertia{});
        break;
    case BodyType::Static: // !IsSpeedable() && !IsAccelerable()
        UnsetAwakeFlag();
        m_linearVelocity = LinearVelocity2{};
        m_angularVelocity = 0_rpm;
        m_sweep.pos0 = m_sweep.pos1;
        m_linearAcceleration = LinearAcceleration2{};
        m_angularAcceleration = AngularAcceleration{};
        SetInvMassData(InvMass{}, InvRotInertia{});
        break;
    }
    m_underActiveTime = 0;
}

void Body::SetSleepingAllowed(bool flag) noexcept
{
    if (flag) {
        m_flags |= e_autoSleepFlag;
    }
    else if (IsSpeedable()) {
        m_flags &= ~e_autoSleepFlag;
        SetAwakeFlag();
        ResetUnderActiveTime();
    }
}

void Body::SetAwake() noexcept
{
    // Ignore this request unless this body is speedable so as to maintain the body's invariant
    // that only "speedable" bodies can be awake.
    if (IsSpeedable()) {
        SetAwakeFlag();
        ResetUnderActiveTime();
    }
}

void Body::UnsetAwake() noexcept
{
    if (!IsSpeedable() || IsSleepingAllowed()) {
        UnsetAwakeFlag();
        m_underActiveTime = 0;
        m_linearVelocity = LinearVelocity2{};
        m_angularVelocity = 0_rpm;
    }
}

void Body::SetVelocity(const Velocity& velocity) noexcept
{
    if (velocity != Velocity{}) {
        if (!IsSpeedable()) {
            return;
        }
        SetAwakeFlag();
        ResetUnderActiveTime();
    }
    JustSetVelocity(velocity);
}

void Body::JustSetVelocity(Velocity value) noexcept
{
    assert(IsSpeedable() || (value == Velocity{}));
    m_linearVelocity = value.linear;
    m_angularVelocity = value.angular;
}

void Body::SetAcceleration(LinearAcceleration2 linear, AngularAcceleration angular) noexcept
{
    assert(IsValid(linear));
    assert(IsValid(angular));

    if ((m_linearAcceleration == linear) && (m_angularAcceleration == angular)) {
        // no change, bail...
        return;
    }

    if (!IsAccelerable()) {
        if ((linear != LinearAcceleration2{}) || (angular != AngularAcceleration{0})) {
            // non-accelerable bodies can only be set to zero acceleration, bail...
            return;
        }
    }
    else {
        if ((m_angularAcceleration < angular) ||
            (GetMagnitudeSquared(m_linearAcceleration) < GetMagnitudeSquared(linear)) ||
            (playrho::GetAngle(m_linearAcceleration) != playrho::GetAngle(linear)) ||
            (signbit(m_angularAcceleration) != signbit(angular))) {
            // Increasing accel or changing direction of accel, awake & reset time.
            SetAwakeFlag();
            ResetUnderActiveTime();
        }
    }

    m_linearAcceleration = linear;
    m_angularAcceleration = angular;
}

void Body::SetFixedRotation(bool flag)
{
    if (flag) {
        m_flags |= e_fixedRotationFlag;
    }
    else {
        m_flags &= ~e_fixedRotationFlag;
    }
    m_angularVelocity = 0_rpm;
}

Body& Body::Attach(ShapeID shapeId)
{
    m_shapes.push_back(shapeId);
    SetMassDataDirty();
    return *this;
}

bool Body::Detach(ShapeID shapeId)
{
    const auto endIt = end(m_shapes);
    const auto it = find(begin(m_shapes), endIt, shapeId);
    if (it != endIt) {
        m_shapes.erase(it);
        SetMassDataDirty();
        return true;
    }
    return false;
}

// Free functions...

void SetTransformation(Body& body, const Transformation& value) noexcept
{
    SetSweep(body, Sweep{Position{value.p, GetAngle(value.q)}, GetSweep(body).GetLocalCenter()});
}

void SetLocation(Body& body, Length2 value)
{
    SetTransformation(body, Transformation{value, GetTransformation(body).q});
}

Angle GetAngle(const Body& body) noexcept
{
    return GetSweep(body).pos1.angular;
}

void SetAngle(Body& body, Angle value)
{
    SetSweep(body, Sweep{Position{GetSweep(body).pos1.linear, value}, GetLocalCenter(body)});
}

Velocity GetVelocity(const Body& body, Time h) noexcept
{
    // Integrate velocity and apply damping.
    auto velocity = body.GetVelocity();
    if (body.IsAccelerable()) {
        // Integrate velocities.
        velocity.linear += h * body.GetLinearAcceleration();
        velocity.angular += h * body.GetAngularAcceleration();

        // Apply damping.
        // Ordinary differential equation: dv/dt + c * v = 0
        //                       Solution: v(t) = v0 * exp(-c * t)
        // Time step: v(t + dt) = v0 * exp(-c * (t + dt)) = v0 * exp(-c * t) * exp(-c * dt) = v *
        // exp(-c * dt) v2 = exp(-c * dt) * v1 Pade approximation (see
        // https://en.wikipedia.org/wiki/Pad%C3%A9_approximant ): v2 = v1 * 1 / (1 + c * dt)
        velocity.linear /= Real{1 + h * body.GetLinearDamping()};
        velocity.angular /= Real{1 + h * body.GetAngularDamping()};
    }
    return velocity;
}

void ApplyLinearImpulse(Body& body, Momentum2 impulse, Length2 point) noexcept
{
    auto velocity = body.GetVelocity();
    velocity.linear += body.GetInvMass() * impulse;
    const auto invRotI = body.GetInvRotInertia();
    const auto dp = point - GetWorldCenter(body);
    velocity.angular += AngularVelocity{invRotI * Cross(dp, impulse) / Radian};
    body.SetVelocity(velocity);
}

void ApplyAngularImpulse(Body& body, AngularMomentum impulse) noexcept
{
    auto velocity = body.GetVelocity();
    const auto invRotI = body.GetInvRotInertia();
    velocity.angular += AngularVelocity{invRotI * impulse};
    body.SetVelocity(velocity);
}

bool operator==(const Body& lhs, const Body& rhs)
{
    return GetTransformation(lhs) == GetTransformation(rhs) && //
           GetSweep(lhs) == GetSweep(rhs) && //
           GetType(lhs) == GetType(rhs) && //
           GetVelocity(lhs) == GetVelocity(rhs) && //
           GetAcceleration(lhs) == GetAcceleration(rhs) && //
           GetInvMass(lhs) == GetInvMass(rhs) && //
           GetInvRotInertia(lhs) == GetInvRotInertia(rhs) && //
           GetLinearDamping(lhs) == GetLinearDamping(rhs) && //
           GetAngularDamping(lhs) == GetAngularDamping(rhs) && //
           GetUnderActiveTime(lhs) == GetUnderActiveTime(rhs) && //
           GetShapes(lhs) == GetShapes(rhs);
}

} // namespace d2
} // namespace playrho
