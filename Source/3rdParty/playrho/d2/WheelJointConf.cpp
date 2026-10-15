/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include <algorithm> // for std::clamp
#include <type_traits> // for std::is_default_constructible_v

#include "playrho/BodyID.hpp"
#include "playrho/ConstraintSolverConf.hpp"
#include "playrho/Math.hpp"
#include "playrho/Real.hpp"
#include "playrho/RealConstants.hpp" // for Pi
#include "playrho/Span.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"

#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/d2/JointConf.hpp"
#include "playrho/d2/Math.hpp"
#include "playrho/d2/Position.hpp"
#include "playrho/d2/UnitVec.hpp"
#include "playrho/d2/Velocity.hpp"
#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/WheelJointConf.hpp"

namespace playrho::d2 {

static_assert(std::is_default_constructible_v<WheelJointConf>,
              "WheelJointConf should be default constructible!");
static_assert(std::is_copy_constructible_v<WheelJointConf>,
              "WheelJointConf should be copy constructible!");
static_assert(std::is_copy_assignable_v<WheelJointConf>,
              "WheelJointConf should be copy assignable!");
static_assert(std::is_move_constructible_v<WheelJointConf>,
              "WheelJointConf should be move constructible!");
static_assert(std::is_move_assignable_v<WheelJointConf>,
              "WheelJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible_v<WheelJointConf>,
              "WheelJointConf should be nothrow destructible!");

// Linear constraint (point-to-line)
// d = pB - pA = xB + rB - xA - rA
// C = dot(ay, d)
// Cdot = dot(d, cross(wA, ay)) + dot(ay, vB + cross(wB, rB) - vA - cross(wA, rA))
//      = -dot(ay, vA) - dot(cross(d + rA, ay), wA) + dot(ay, vB) + dot(cross(rB, ay), vB)
// J = [-ay, -cross(d + rA, ay), ay, cross(rB, ay)]

// Spring linear constraint
// C = dot(ax, d)
// Cdot = = -dot(ax, vA) - dot(cross(d + rA, ax), wA) + dot(ax, vB) + dot(cross(rB, ax), vB)
// J = [-ax -cross(d+rA, ax) ax cross(rB, ax)]

// Motor rotational constraint
// Cdot = wB - wA
// J = [0 0 -1 0 0 1]

WheelJointConf::WheelJointConf(BodyID bA, BodyID bB, // force line-break
                               const Length2& laA, const Length2& laB,
                               const UnitVec& axis) noexcept
    : super{super{}.UseBodyA(bA).UseBodyB(bB)},
      localAnchorA{laA},
      localAnchorB{laB},
      localXAxisA{axis},
      localYAxisA{GetRevPerpendicular(axis)}
{
    // Intentionally empty.
}

WheelJointConf GetWheelJointConf(const Joint& joint)
{
    return TypeCast<WheelJointConf>(joint);
}

WheelJointConf GetWheelJointConf(const World& world, BodyID bodyA, BodyID bodyB, // force line-break
                                 const Length2& anchor, const UnitVec& axis)
{
    return WheelJointConf{bodyA, bodyB, GetLocalPoint(world, bodyA, anchor),
                          GetLocalPoint(world, bodyB, anchor), GetLocalVector(world, bodyA, axis)};
}

AngularVelocity GetAngularVelocity(const World& world, const WheelJointConf& conf)
{
    return GetVelocity(world, GetBodyB(conf)).angular - GetVelocity(world, GetBodyA(conf)).angular;
}

void InitVelocity(WheelJointConf& object, const Span<BodyConstraint>& bodies, const StepConf& step,
                  const ConstraintSolverConf&)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto posA = bodyConstraintA.GetPosition();
    auto velA = bodyConstraintA.GetVelocity();
    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();

    const auto posB = bodyConstraintB.GetPosition();
    auto velB = bodyConstraintB.GetVelocity();
    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    // Compute the effective masses.
    const auto rA = Length2{Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA)};
    const auto rB = Length2{Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB)};
    const auto dd = Length2{(posB.linear + rB) - (posA.linear + rA)};

    // Point to line constraint
    {
        object.ay = Rotate(object.localYAxisA, qA);
        object.sAy = Cross(dd + rA, object.ay);
        object.sBy = Cross(rB, object.ay);

        const auto invRotMassA = invRotInertiaA * Square(object.sAy) / SquareRadian;
        const auto invRotMassB = invRotInertiaB * Square(object.sBy) / SquareRadian;
        const auto invMass = invMassA + invMassB + invRotMassA + invRotMassB;

        object.mass = (invMass > InvMass{}) ? Real{1} / invMass : 0_kg;
    }

    // Spring constraint
    object.springMass = 0_kg;
    object.bias = 0_mps;
    object.gamma = {};
    if (object.frequency > 0_Hz) {
        object.ax = Rotate(object.localXAxisA, qA);
        object.sAx = Cross(dd + rA, object.ax);
        object.sBx = Cross(rB, object.ax);

        const auto invRotMassA = invRotInertiaA * Square(object.sAx) / SquareRadian;
        const auto invRotMassB = invRotInertiaB * Square(object.sBx) / SquareRadian;
        const auto invMass = invMassA + invMassB + invRotMassA + invRotMassB;

        if (invMass > InvMass{}) {
            object.springMass = Real{1} / invMass;

            const auto C = Length{Dot(dd, object.ax)};

            // Frequency
            const auto omega = Real{2} * Pi * object.frequency;

            // Damping coefficient
            const auto d = Real{2} * object.springMass * object.dampingRatio * omega;

            // Spring stiffness
            const auto k = object.springMass * omega * omega;

            // magic formulas
            const auto h = step.deltaTime;

            const auto invGamma = Mass{h * (d + h * k)};
            object.gamma = (invGamma > 0_kg) ? Real{1} / invGamma : InvMass{};
            object.bias = LinearVelocity{C * h * k * object.gamma};

            const auto totalInvMass = invMass + object.gamma;
            object.springMass = (totalInvMass > InvMass{}) ? Real{1} / totalInvMass : 0_kg;
        }
    }
    else {
        object.springImpulse = 0_Ns;
        object.ax = UnitVec::GetZero();
        object.sAx = 0_m;
        object.sBx = 0_m;
    }

    // Rotational motor
    if (object.enableMotor) {
        const auto invRotInertia = invRotInertiaA + invRotInertiaB;
        object.angularMass =
            (invRotInertia > InvRotInertia{}) ? Real{1} / invRotInertia : RotInertia{};
    }
    else {
        object.angularMass = RotInertia{};
        object.angularImpulse = AngularMomentum{};
    }

    if (step.doWarmStart) {
        // Account for variable time step.
        object.impulse *= step.dtRatio;
        object.springImpulse *= step.dtRatio;
        object.angularImpulse *= step.dtRatio;

        const auto P = object.impulse * object.ay + object.springImpulse * object.ax;

        // Momentum is M L T^-1. Length * momentum is L^2 M T^-1
        // Angular momentum is L^2 M T^-1 QP^-1
        const auto LA = AngularMomentum{
            (object.impulse * object.sAy + object.springImpulse * object.sAx) / Radian +
            object.angularImpulse};
        const auto LB = AngularMomentum{
            (object.impulse * object.sBy + object.springImpulse * object.sBx) / Radian +
            object.angularImpulse};

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else {
        object.impulse = 0_Ns;
        object.springImpulse = 0_Ns;
        object.angularImpulse = AngularMomentum{};
    }

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);
}

bool SolveVelocity(WheelJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto oldVelA = bodyConstraintA.GetVelocity();
    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();

    const auto oldVelB = bodyConstraintB.GetVelocity();
    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();

    auto velA = oldVelA;
    auto velB = oldVelB;

    // Solve spring constraint
    {
        const auto dot = LinearVelocity{Dot(object.ax, velB.linear - velA.linear)};
        const auto Cdot =
            dot + object.sBx * velB.angular / Radian - object.sAx * velA.angular / Radian;
        const auto impulse =
            -object.springMass * (Cdot + object.bias + object.gamma * object.springImpulse);
        object.springImpulse += impulse;

        const auto P = impulse * object.ax;
        const auto LA = AngularMomentum{impulse * object.sAx / Radian};
        const auto LB = AngularMomentum{impulse * object.sBx / Radian};

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }

    // Solve rotational motor constraint
    {
        const auto Cdot = (velB.angular - velA.angular - object.motorSpeed);
        auto impulse = AngularMomentum{-object.angularMass * Cdot};

        const auto oldImpulse = object.angularImpulse;
        const auto maxImpulse = AngularMomentum{step.deltaTime * object.maxMotorTorque};
        object.angularImpulse =
            std::clamp(object.angularImpulse + impulse, -maxImpulse, maxImpulse);
        impulse = object.angularImpulse - oldImpulse;

        velA.angular -= AngularVelocity{invRotInertiaA * impulse};
        velB.angular += AngularVelocity{invRotInertiaB * impulse};
    }

    // Solve point to line constraint
    {
        const auto dot = LinearVelocity{Dot(object.ay, velB.linear - velA.linear)};
        const auto Cdot =
            dot + object.sBy * velB.angular / Radian - object.sAy * velA.angular / Radian;
        const auto impulse = -object.mass * Cdot;
        object.impulse += impulse;

        const auto P = impulse * object.ay;
        const auto LA = AngularMomentum{impulse * object.sAy / Radian};
        const auto LB = AngularMomentum{impulse * object.sBy / Radian};

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }

    if ((velA != oldVelA) || (velB != oldVelB)) {
        bodyConstraintA.SetVelocity(velA);
        bodyConstraintB.SetVelocity(velB);
        return false;
    }
    return true;
}

bool SolvePosition(const WheelJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    auto posA = bodyConstraintA.GetPosition();
    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();

    auto posB = bodyConstraintB.GetPosition();
    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    const auto rA = Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA);
    const auto rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);
    const auto d = Length2{(posB.linear - posA.linear) + (rB - rA)};

    const auto ay = Rotate(object.localYAxisA, qA);

    const auto sAy = Cross(d + rA, ay);
    const auto sBy = Cross(rB, ay);

    const auto C = Length{Dot(d, ay)};

    const auto invRotMassA = invRotInertiaA * Square(object.sAy) / SquareRadian;
    const auto invRotMassB = invRotInertiaB * Square(object.sBy) / SquareRadian;

    const auto k = InvMass{invMassA + invMassB + invRotMassA + invRotMassB};

    const auto impulse = (k != InvMass{}) ? -(C / k) : 0 * Kilogram * Meter;

    const auto P = impulse * ay;
    const auto LA = impulse * sAy / Radian;
    const auto LB = impulse * sBy / Radian;

    posA -= Position{invMassA * P, invRotInertiaA * LA};
    posB += Position{invMassB * P, invRotInertiaB * LB};

    bodyConstraintA.SetPosition(posA);
    bodyConstraintB.SetPosition(posB);

    return abs(C) <= conf.linearSlop;
}

} // namespace playrho::d2
