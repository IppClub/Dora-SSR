/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
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

#include "playrho/d2/RevoluteJointConf.hpp"

#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/ConstraintSolverConf.hpp"

namespace playrho {
namespace d2 {

namespace {

Mat33 GetMat33(InvMass invMassA, const Length2& rA, InvRotInertia invRotInertiaA, InvMass invMassB,
               const Length2& rB, InvRotInertia invRotInertiaB)
{
    const auto totInvI = invRotInertiaA + invRotInertiaB;

    const auto exx = InvMass{invMassA + (Square(GetY(rA)) * invRotInertiaA / SquareRadian) +
                             invMassB + (Square(GetY(rB)) * invRotInertiaB / SquareRadian)};
    const auto eyx = InvMass{(-GetY(rA) * GetX(rA) * invRotInertiaA / SquareRadian) +
                             (-GetY(rB) * GetX(rB) * invRotInertiaB / SquareRadian)};
    const auto ezx = InvMass{(-GetY(rA) * invRotInertiaA * Meter / SquareRadian) +
                             (-GetY(rB) * invRotInertiaB * Meter / SquareRadian)};
    const auto eyy = InvMass{invMassA + (Square(GetX(rA)) * invRotInertiaA / SquareRadian) +
                             invMassB + (Square(GetX(rB)) * invRotInertiaB / SquareRadian)};
    const auto ezy = InvMass{(GetX(rA) * invRotInertiaA * Meter / SquareRadian) +
                             (GetX(rB) * invRotInertiaB * Meter / SquareRadian)};

    auto mass = Mat33{};
    GetX(GetX(mass)) = StripUnit(exx);
    GetX(GetY(mass)) = StripUnit(eyx);
    GetX(GetZ(mass)) = StripUnit(ezx);
    GetY(GetX(mass)) = GetX(GetY(mass));
    GetY(GetY(mass)) = StripUnit(eyy);
    GetY(GetZ(mass)) = StripUnit(ezy);
    GetZ(GetX(mass)) = GetX(GetZ(mass));
    GetZ(GetY(mass)) = GetY(GetZ(mass));
    GetZ(GetZ(mass)) = StripUnit(totInvI);
    return mass;
}

} // unnamed namespace

static_assert(std::is_default_constructible_v<RevoluteJointConf>,
              "RevoluteJointConf should be default constructible!");
static_assert(std::is_copy_constructible_v<RevoluteJointConf>,
              "RevoluteJointConf should be copy constructible!");
static_assert(std::is_copy_assignable_v<RevoluteJointConf>,
              "RevoluteJointConf should be copy assignable!");
static_assert(std::is_move_constructible_v<RevoluteJointConf>,
              "RevoluteJointConf should be move constructible!");
static_assert(std::is_move_assignable_v<RevoluteJointConf>,
              "RevoluteJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible_v<RevoluteJointConf>,
              "RevoluteJointConf should be nothrow destructible!");

// Point-to-point constraint
// C = p2 - p1
// Cdot = v2 - v1
//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
// J = [-I -r1_skew I r2_skew ]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

// Motor constraint
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
// K = invI1 + invI2

RevoluteJointConf::RevoluteJointConf(BodyID bA, BodyID bB, // force line-break
                                     const Length2& laA, const Length2& laB,
                                     Angle ra) noexcept
    : super{super{}.UseBodyA(bA).UseBodyB(bB)},
      localAnchorA{laA},
      localAnchorB{laB},
      referenceAngle{ra}
{
    // Intentionally empty.
}

RevoluteJointConf GetRevoluteJointConf(const Joint& joint)
{
    return TypeCast<RevoluteJointConf>(joint);
}

RevoluteJointConf GetRevoluteJointConf(const World& world, BodyID bodyA, BodyID bodyB,
                                       const Length2& anchor)
{
    return RevoluteJointConf{bodyA, bodyB, GetLocalPoint(world, bodyA, anchor),
                             GetLocalPoint(world, bodyB, anchor),
                             GetAngle(world, bodyB) - GetAngle(world, bodyA)};
}

Angle GetAngle(const World& world, const RevoluteJointConf& conf)
{
    return GetAngle(world, GetBodyB(conf)) - GetAngle(world, GetBodyA(conf)) -
           GetReferenceAngle(conf);
}

AngularVelocity GetAngularVelocity(const World& world, const RevoluteJointConf& conf)
{
    return GetVelocity(world, GetBodyB(conf)).angular - GetVelocity(world, GetBodyA(conf)).angular;
}

void InitVelocity(RevoluteJointConf& object, const Span<BodyConstraint>& bodies,
                  const StepConf& step, const ConstraintSolverConf& conf)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();
    const auto aA = bodyConstraintA.GetPosition().angular;
    auto velA = bodyConstraintA.GetVelocity();

    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();
    const auto aB = bodyConstraintB.GetPosition().angular;
    auto velB = bodyConstraintB.GetVelocity();

    const auto qA = UnitVec::Get(aA);
    const auto qB = UnitVec::Get(aB);

    object.rA = Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA);
    object.rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);

    // J = [-I -r1_skew I r2_skew]
    //     [ 0       -1 0       1]
    // r_skew = [-ry; rx]

    // Matlab
    // K = [ mA+r1y^2*iA+mB+r2y^2*iB,  -r1y*iA*r1x-r2y*iB*r2x,          -r1y*iA-r2y*iB]
    //     [  -r1y*iA*r1x-r2y*iB*r2x, mA+r1x^2*iA+mB+r2x^2*iB,           r1x*iA+r2x*iB]
    //     [          -r1y*iA-r2y*iB,           r1x*iA+r2x*iB,                   iA+iB]

    const auto totInvI = invRotInertiaA + invRotInertiaB;
    const auto fixedRotation = (totInvI == InvRotInertia{});

    object.mass =
        GetMat33(invMassA, object.rA, invRotInertiaA, invMassB, object.rB, invRotInertiaB);
    object.angularMass =
        (totInvI > InvRotInertia{}) ? RotInertia{Real{1} / totInvI} : RotInertia{};

    if (!object.enableMotor || fixedRotation) {
        object.angularMotorImpulse = {};
    }

    if (object.enableLimit && !fixedRotation) {
        const auto jointAngle = aB - aA - GetReferenceAngle(object);
        if (abs(object.upperAngle - object.lowerAngle) < (conf.angularSlop * 2)) {
            object.limitState = LimitState::e_equalLimits;
        }
        else if (jointAngle <= object.lowerAngle) {
            if (object.limitState != LimitState::e_atLowerLimit) {
                object.limitState = LimitState::e_atLowerLimit;
                GetZ(object.impulse) = 0;
            }
        }
        else if (jointAngle >= object.upperAngle) {
            if (object.limitState != LimitState::e_atUpperLimit) {
                object.limitState = LimitState::e_atUpperLimit;
                GetZ(object.impulse) = 0;
            }
        }
        else // jointAngle > object.lowerAngle && jointAngle < object.upperAngle
        {
            object.limitState = LimitState::e_inactiveLimit;
            GetZ(object.impulse) = 0;
        }
    }
    else {
        object.limitState = LimitState::e_inactiveLimit;
    }

    if (step.doWarmStart) {
        // Scale impulses to support a variable time step.
        object.impulse *= step.dtRatio;
        object.angularMotorImpulse *= step.dtRatio;

        const auto P =
            Momentum2{GetX(object.impulse) * NewtonSecond, GetY(object.impulse) * NewtonSecond};

        // AngularMomentum is L^2 M T^-1 QP^-1.
        const auto L =
            AngularMomentum{object.angularMotorImpulse +
                            (GetZ(object.impulse) * SquareMeter * Kilogram / (Second * Radian))};
        const auto LA = AngularMomentum{Cross(object.rA, P) / Radian} + L;
        const auto LB = AngularMomentum{Cross(object.rB, P) / Radian} + L;

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else {
        object.impulse = Vec3{};
        object.angularMotorImpulse = {};
    }

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);
}

bool SolveVelocity(RevoluteJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto oldVelA = bodyConstraintA.GetVelocity();
    auto velA = oldVelA;
    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();

    const auto oldVelB = bodyConstraintB.GetVelocity();
    auto velB = oldVelB;
    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();

    const auto fixedRotation = (invRotInertiaA + invRotInertiaB == InvRotInertia{});

    // Solve motor constraint.
    if (object.enableMotor && (object.limitState != LimitState::e_equalLimits) && !fixedRotation) {
        const auto impulse = AngularMomentum{-object.angularMass *
                                             (velB.angular - velA.angular - object.motorSpeed)};
        const auto oldImpulse = object.angularMotorImpulse;
        const auto maxImpulse = step.deltaTime * object.maxMotorTorque;
        object.angularMotorImpulse =
            std::clamp(object.angularMotorImpulse + impulse, -maxImpulse, maxImpulse);
        const auto incImpulse = object.angularMotorImpulse - oldImpulse;

        velA.angular -= invRotInertiaA * incImpulse;
        velB.angular += invRotInertiaB * incImpulse;
    }

    const auto vb = velB.linear + GetRevPerpendicular(object.rB) * (velB.angular / Radian);
    const auto va = velA.linear + GetRevPerpendicular(object.rA) * (velA.angular / Radian);
    const auto vDelta = vb - va;

    // Solve limit constraint.
    if (object.enableLimit && (object.limitState != LimitState::e_inactiveLimit) &&
        !fixedRotation) {
        const auto Cdot = Vec3{GetX(vDelta) / MeterPerSecond, GetY(vDelta) / MeterPerSecond,
                               (velB.angular - velA.angular) / RadianPerSecond};
        auto impulse = -Solve33(object.mass, Cdot);

        const auto UpdateImpulse = [&vDelta,&object](Vec3 &imp) -> Vec3 {
            const auto rhs =
                -Vec2{GetX(vDelta) / MeterPerSecond, GetY(vDelta) / MeterPerSecond} +
                GetZ(object.impulse) * Vec2{GetX(GetZ(object.mass)), GetY(GetZ(object.mass))};
            const auto reduced = Solve22(object.mass, rhs);
            imp = {GetX(reduced), GetY(reduced), -GetZ(object.impulse)};
            return {GetX(object.impulse) + GetX(reduced), GetY(object.impulse) + GetY(reduced), 0};
        };

        switch (object.limitState) {
        case LimitState::e_atLowerLimit: {
            const auto newZ = GetZ(object.impulse) + GetZ(impulse);
            object.impulse = (newZ < 0)? UpdateImpulse(impulse): object.impulse + impulse;
            break;
        }
        case LimitState::e_atUpperLimit: {
            const auto newZ = GetZ(object.impulse) + GetZ(impulse);
            object.impulse = (newZ > 0)? UpdateImpulse(impulse): object.impulse + impulse;
            break;
        }
        default:
            assert(object.limitState == LimitState::e_equalLimits);
            object.impulse += impulse;
            break;
        }

        const auto P = Momentum2{GetX(impulse) * NewtonSecond, GetY(impulse) * NewtonSecond};
        const auto L = AngularMomentum{GetZ(impulse) * SquareMeter * Kilogram / (Second * Radian)};
        const auto LA = AngularMomentum{Cross(object.rA, P) / Radian} + L;
        const auto LB = AngularMomentum{Cross(object.rB, P) / Radian} + L;

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else {
        // Solve point-to-point constraint
        const auto impulse = Solve22(
            object.mass, -Vec2{get<0>(vDelta) / MeterPerSecond, get<1>(vDelta) / MeterPerSecond});

        GetX(object.impulse) += GetX(impulse);
        GetY(object.impulse) += GetY(impulse);

        const auto P = Momentum2{GetX(impulse) * NewtonSecond, GetY(impulse) * NewtonSecond};
        const auto LA = AngularMomentum{Cross(object.rA, P) / Radian};
        const auto LB = AngularMomentum{Cross(object.rB, P) / Radian};

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

bool SolvePosition(const RevoluteJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    auto posA = bodyConstraintA.GetPosition();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();

    auto posB = bodyConstraintB.GetPosition();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();

    const auto fixedRotation = ((invRotInertiaA + invRotInertiaB) == InvRotInertia{});

    // Solve angular limit constraint.
    auto angularError = 0_rad;
    if (object.enableLimit && (object.limitState != LimitState::e_inactiveLimit) &&
        !fixedRotation) {
        const auto angle = posB.angular - posA.angular - GetReferenceAngle(object);

        // RotInertia is L^2 M QP^-2, Angle is QP, so RotInertia * Angle is L^2 M QP^-1.
        auto limitImpulse = Real{0} * SquareMeter * Kilogram / Radian;

        switch (object.limitState) {
        case LimitState::e_atLowerLimit: {
            auto C = angle - object.lowerAngle;
            angularError = -C;

            // Prevent large angular corrections and allow some slop.
            C = std::clamp(C + conf.angularSlop, -conf.maxAngularCorrection, 0_rad);
            limitImpulse = -object.angularMass * C;
            break;
        }
        case LimitState::e_atUpperLimit: {
            auto C = angle - object.upperAngle;
            angularError = C;

            // Prevent large angular corrections and allow some slop.
            C = std::clamp(C - conf.angularSlop, 0_rad, conf.maxAngularCorrection);
            limitImpulse = -object.angularMass * C;
            break;
        }
        default: {
            assert(object.limitState == LimitState::e_equalLimits);
            // Prevent large angular corrections
            const auto C = std::clamp(angle - object.lowerAngle, -conf.maxAngularCorrection,
                                      conf.maxAngularCorrection);
            limitImpulse = -object.angularMass * C;
            angularError = abs(C);
            break;
        }
        }

        // InvRotInertia is L^-2 M^-1 QP^2, limitImpulse is L^2 M QP^-1, so product is QP.
        posA.angular -= invRotInertiaA * limitImpulse;
        posB.angular += invRotInertiaB * limitImpulse;
    }

    // Solve point-to-point constraint.
    auto positionError = 0_m2;
    {
        const auto qA = UnitVec::Get(posA.angular);
        const auto qB = UnitVec::Get(posB.angular);

        const auto rA = Length2{Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA)};
        const auto rB = Length2{Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB)};

        const auto C = (posB.linear + rB) - (posA.linear + rA);
        positionError = GetMagnitudeSquared(C);

        const auto invMassA = bodyConstraintA.GetInvMass();
        const auto invMassB = bodyConstraintB.GetInvMass();

        const auto exx = InvMass{invMassA + (invRotInertiaA * Square(GetY(rA)) / SquareRadian) +
                                 invMassB + (invRotInertiaB * Square(GetY(rB)) / SquareRadian)};
        const auto exy = InvMass{(-invRotInertiaA * GetX(rA) * GetY(rA) / SquareRadian) +
                                 (-invRotInertiaB * GetX(rB) * GetY(rB) / SquareRadian)};
        const auto eyy = InvMass{invMassA + (invRotInertiaA * Square(GetX(rA)) / SquareRadian) +
                                 invMassB + (invRotInertiaB * Square(GetX(rB)) / SquareRadian)};

        InvMass22 K;
        GetX(GetX(K)) = exx;
        GetY(GetX(K)) = exy;
        GetX(GetY(K)) = exy;
        GetY(GetY(K)) = eyy;
        const auto P = -Solve(K, C);

        posA -= Position{invMassA * P, invRotInertiaA * Cross(rA, P) / Radian};
        posB += Position{invMassB * P, invRotInertiaB * Cross(rB, P) / Radian};
    }

    bodyConstraintA.SetPosition(posA);
    bodyConstraintB.SetPosition(posB);

    return (positionError <= Square(conf.linearSlop)) && (angularError <= conf.angularSlop);
}

} // namespace d2
} // namespace playrho
