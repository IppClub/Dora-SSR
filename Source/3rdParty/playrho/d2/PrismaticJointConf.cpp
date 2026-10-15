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

#include "playrho/d2/PrismaticJointConf.hpp"

#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/ConstraintSolverConf.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible_v<PrismaticJointConf>,
              "PrismaticJointConf should be default constructible!");
static_assert(std::is_copy_constructible_v<PrismaticJointConf>,
              "PrismaticJointConf should be copy constructible!");
static_assert(std::is_copy_assignable_v<PrismaticJointConf>,
              "PrismaticJointConf should be copy assignable!");
static_assert(std::is_move_constructible_v<PrismaticJointConf>,
              "PrismaticJointConf should be move constructible!");
static_assert(std::is_move_assignable_v<PrismaticJointConf>,
              "PrismaticJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible_v<PrismaticJointConf>,
              "PrismaticJointConf should be nothrow destructible!");

// Linear constraint (point-to-line)
// d = p2 - p1 = x2 + r2 - x1 - r1
// C = dot(perp, d)
// Cdot = dot(d, cross(w1, perp)) + dot(perp, v2 + cross(w2, r2) - v1 - cross(w1, r1))
//      = -dot(perp, v1) - dot(cross(d + r1, perp), w1) + dot(perp, v2) + dot(cross(r2, perp), v2)
// J = [-perp, -cross(d + r1, perp), perp, cross(r2,perp)]
//
// Angular constraint
// C = a2 - a1 + a_initial
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
//
// K = J * invM * JT
//
// J = [-a -s1 a s2]
//     [0  -1  0  1]
// a = perp
// s1 = cross(d + r1, a) = cross(p2 - x1, a)
// s2 = cross(r2, a) = cross(p2 - x2, a)


// Motor/Limit linear constraint
// C = dot(ax1, d)
// Cdot = = -dot(ax1, v1) - dot(cross(d + r1, ax1), w1) + dot(ax1, v2) + dot(cross(r2, ax1), v2)
// J = [-ax1 -cross(d+r1,ax1) ax1 cross(r2,ax1)]

// Block Solver
// We develop a block solver that includes the joint limit. This makes the limit stiff (inelastic)
// even when the mass has poor distribution (leading to large torques about the joint anchor
// points).
//
// The Jacobian has 3 rows:
// J = [-uT -s1 uT s2] // linear
//     [0   -1   0  1] // angular
//     [-vT -a1 vT a2] // limit
//
// u = perp
// v = axis
// s1 = cross(d + r1, u), s2 = cross(r2, u)
// a1 = cross(d + r1, v), a2 = cross(r2, v)

// M * (v2 - v1) = JT * df
// J * v2 = bias
//
// v2 = v1 + invM * JT * df
// J * (v1 + invM * JT * df) = bias
// K * df = bias - J * v1 = -Cdot
// K = J * invM * JT
// Cdot = J * v1 - bias
//
// Now solve for f2.
// df = f2 - f1
// K * (f2 - f1) = -Cdot
// f2 = invK * (-Cdot) + f1
//
// Clamp accumulated limit impulse.
// lower: f2(3) = max(f2(3), 0)
// upper: f2(3) = min(f2(3), 0)
//
// Solve for correct f2(1:2)
// K(1:2, 1:2) * f2(1:2) = -Cdot(1:2) - K(1:2,3) * f2(3) + K(1:2,1:3) * f1
//                       = -Cdot(1:2) - K(1:2,3) * f2(3) + K(1:2,1:2) * f1(1:2) + K(1:2,3) * f1(3)
// K(1:2, 1:2) * f2(1:2) = -Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3)) + K(1:2,1:2) * f1(1:2)
// f2(1:2) = invK(1:2,1:2) * (-Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3))) + f1(1:2)
//
// Now compute impulse to be applied:
// df = f2 - f1

PrismaticJointConf::PrismaticJointConf(BodyID bA, BodyID bB, // force line-break
                                       const Length2& laA, const Length2& laB, // force line-break
                                       const UnitVec& axisA, Angle angle) noexcept
    : super{super{}.UseBodyA(bA).UseBodyB(bB)},
      localAnchorA{laA},
      localAnchorB{laB},
      localXAxisA{axisA},
      localYAxisA{GetRevPerpendicular(axisA)},
      referenceAngle{angle}
{
    // Intentionally empty.
}

PrismaticJointConf GetPrismaticJointConf(const Joint& joint)
{
    return TypeCast<PrismaticJointConf>(joint);
}

PrismaticJointConf GetPrismaticJointConf(const World& world, BodyID bA, BodyID bB,
                                         const Length2& anchor, const UnitVec& axis)
{
    return PrismaticJointConf{bA,
                              bB,
                              GetLocalPoint(world, bA, anchor),
                              GetLocalPoint(world, bB, anchor),
                              GetLocalVector(world, bA, axis),
                              GetAngle(world, bB) - GetAngle(world, bA)};
}

Momentum2 GetLinearReaction(const PrismaticJointConf& conf)
{
    const auto ulImpulse = GetX(conf.impulse) * conf.perp;
    const auto impulse = Momentum2{GetX(ulImpulse) * NewtonSecond, GetY(ulImpulse) * NewtonSecond};
    return Momentum2{impulse + (conf.motorImpulse + GetZ(conf.impulse) * NewtonSecond) * conf.axis};
}

AngularMomentum GetAngularReaction(const PrismaticJointConf& conf)
{
    return GetY(conf.impulse) * SquareMeter * Kilogram / (Second * Radian);
}

void InitVelocity(PrismaticJointConf& object, const Span<BodyConstraint>& bodies,
                  const StepConf& step, const ConstraintSolverConf& conf)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto posA = bodyConstraintA.GetPosition();
    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();
    auto velA = bodyConstraintA.GetVelocity();

    const auto posB = bodyConstraintB.GetPosition();
    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();
    auto velB = bodyConstraintB.GetVelocity();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    // Compute the effective masses.
    const auto rA = Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA); // Length2
    const auto rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB); // Length2
    const auto d = (posB.linear - posA.linear) + rB - rA; // Length2

    // Compute motor Jacobian and effective mass.
    object.axis = Rotate(object.localXAxisA, qA);
    object.a1 = Cross(d + rA, object.axis); // Length
    object.a2 = Cross(rB, object.axis); // Length

    const auto invRotMassA = InvMass{invRotInertiaA * Square(object.a1) / SquareRadian};
    const auto invRotMassB = InvMass{invRotInertiaB * Square(object.a2) / SquareRadian};
    const auto totalInvMass = invMassA + invMassB + invRotMassA + invRotMassB;
    object.motorMass = (totalInvMass > InvMass{}) ? Real{1} / totalInvMass : 0_kg;

    // Prismatic constraint.
    {
        object.perp = Rotate(object.localYAxisA, qA);

        object.s1 = Cross(d + rA, object.perp);
        object.s2 = Cross(rB, object.perp);

        const auto invRotMassA2 = InvMass{invRotInertiaA * Square(object.s1) / SquareRadian};
        const auto invRotMassB2 = InvMass{invRotInertiaB * Square(object.s2) / SquareRadian};
        const auto k11 = StripUnit(invMassA + invMassB + invRotMassA2 + invRotMassB2);

        // L^-2 M^-1 QP^2 * L is: L^-1 M^-1 QP^2.
        const auto k12 = (invRotInertiaA * object.s1 + invRotInertiaB * object.s2) * Meter *
                         Kilogram / SquareRadian;
        const auto k13 = StripUnit(InvMass{
            (invRotInertiaA * object.s1 * object.a1 + invRotInertiaB * object.s2 * object.a2) /
            SquareRadian});
        const auto totalInvRotInertia = invRotInertiaA + invRotInertiaB;

        const auto k22 =
            (totalInvRotInertia == InvRotInertia{}) ? Real{1} : StripUnit(totalInvRotInertia);
        const auto k23 = (invRotInertiaA * object.a1 + invRotInertiaB * object.a2) * Meter *
                         Kilogram / SquareRadian;
        const auto k33 = StripUnit(totalInvMass);

        GetX(object.K) = Vec3{k11, k12, k13};
        GetY(object.K) = Vec3{k12, k22, k23};
        GetZ(object.K) = Vec3{k13, k23, k33};
    }

    // Compute motor and limit terms.
    if (object.enableLimit) {
        const auto jointTranslation = Length{Dot(object.axis, d)};
        if (abs(object.upperTranslation - object.lowerTranslation) < (conf.linearSlop * Real{2})) {
            object.limitState = LimitState::e_equalLimits;
        }
        else if (jointTranslation <= object.lowerTranslation) {
            if (object.limitState != LimitState::e_atLowerLimit) {
                object.limitState = LimitState::e_atLowerLimit;
                GetZ(object.impulse) = 0;
            }
        }
        else if (jointTranslation >= object.upperTranslation) {
            if (object.limitState != LimitState::e_atUpperLimit) {
                object.limitState = LimitState::e_atUpperLimit;
                GetZ(object.impulse) = 0;
            }
        }
        else {
            object.limitState = LimitState::e_inactiveLimit;
            GetZ(object.impulse) = 0;
        }
    }
    else {
        object.limitState = LimitState::e_inactiveLimit;
        GetZ(object.impulse) = 0;
    }

    if (!object.enableMotor) {
        object.motorImpulse = 0_Ns;
    }

    if (step.doWarmStart) {
        // Account for variable time step.
        object.impulse *= step.dtRatio;
        object.motorImpulse *= step.dtRatio;

        const auto ulImpulseX = GetX(object.impulse) * object.perp;
        const auto Px = Momentum2{GetX(ulImpulseX) * NewtonSecond, GetY(ulImpulseX) * NewtonSecond};
        const auto Pxs1 = Momentum{GetX(object.impulse) * object.s1 * Kilogram / Second};
        const auto Pxs2 = Momentum{GetX(object.impulse) * object.s2 * Kilogram / Second};
        const auto PzLength = Momentum{object.motorImpulse + GetZ(object.impulse) * NewtonSecond};
        const auto Pz = Momentum2{PzLength * object.axis};
        const auto P = Px + Pz;

        // AngularMomentum is L^2 M T^-1 QP^-1.
        const auto L =
            AngularMomentum{GetY(object.impulse) * SquareMeter * Kilogram / (Second * Radian)};
        const auto LA = L + (Pxs1 * Meter + PzLength * object.a1) / Radian;
        const auto LB = L + (Pxs2 * Meter + PzLength * object.a2) / Radian;

        // InvRotInertia is L^-2 M^-1 QP^2
        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else {
        object.impulse = Vec3{};
        object.motorImpulse = 0_Ns;
    }

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);
}

bool SolveVelocity(PrismaticJointConf& object, const Span<BodyConstraint>& bodies,
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

    // Solve linear motor constraint.
    if (object.enableMotor && object.limitState != LimitState::e_equalLimits) {
        const auto vDot = LinearVelocity{Dot(object.axis, velB.linear - velA.linear)};
        const auto Cdot = vDot + (object.a2 * velB.angular - object.a1 * velA.angular) / Radian;
        auto impulse = Momentum{object.motorMass * (object.motorSpeed * Meter / Radian - Cdot)};
        const auto oldImpulse = object.motorImpulse;
        const auto maxImpulse = step.deltaTime * object.maxMotorForce;
        object.motorImpulse = std::clamp(object.motorImpulse + impulse, -maxImpulse, maxImpulse);
        impulse = object.motorImpulse - oldImpulse;

        const auto P = Momentum2{impulse * object.axis};

        // Momentum is L^2 M T^-1. AngularMomentum is L^2 M T^-1 QP^-1.
        const auto LA = impulse * object.a1 / Radian;
        const auto LB = impulse * object.a2 / Radian;

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }

    const auto velDelta = velB.linear - velA.linear;
    const auto sRotSpeed =
        LinearVelocity{(object.s2 * velB.angular - object.s1 * velA.angular) / Radian};
    const auto Cdot1 = Vec2{StripUnit(Dot(object.perp, velDelta) + sRotSpeed),
                            StripUnit(velB.angular - velA.angular)};

    if (object.enableLimit && (object.limitState != LimitState::e_inactiveLimit)) {
        // Solve prismatic and limit constraint in block form.
        const auto deltaDot = LinearVelocity{Dot(object.axis, velDelta)};
        const auto aRotSpeed =
            LinearVelocity{(object.a2 * velB.angular - object.a1 * velA.angular) / Radian};
        const auto Cdot2 = StripUnit(deltaDot + aRotSpeed);
        const auto Cdot = Vec3{GetX(Cdot1), GetY(Cdot1), Cdot2};

        const auto f1 = object.impulse;
        object.impulse += Solve33(object.K, -Cdot);

        if (object.limitState == LimitState::e_atLowerLimit) {
            GetZ(object.impulse) = std::max(GetZ(object.impulse), Real{0});
        }
        else if (object.limitState == LimitState::e_atUpperLimit) {
            GetZ(object.impulse) = std::min(GetZ(object.impulse), Real{0});
        }

        // f2(1:2) = invK(1:2,1:2) * (-Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3))) + f1(1:2)
        const auto b = -Cdot1 - (GetZ(object.impulse) - GetZ(f1)) *
                                    Vec2{GetX(GetZ(object.K)), GetY(GetZ(object.K))};
        const auto f2r = Solve22(object.K, b) + Vec2{GetX(f1), GetY(f1)};
        GetX(object.impulse) = GetX(f2r);
        GetY(object.impulse) = GetY(f2r);

        const auto df = object.impulse - f1;

        const auto ulP = GetX(df) * object.perp + GetZ(df) * object.axis;
        const auto P = Momentum2{GetX(ulP) * NewtonSecond, GetY(ulP) * NewtonSecond};
        const auto LA =
            AngularMomentum{(GetX(df) * object.s1 + GetY(df) * Meter + GetZ(df) * object.a1) *
                            NewtonSecond / Radian};
        const auto LB =
            AngularMomentum{(GetX(df) * object.s2 + GetY(df) * Meter + GetZ(df) * object.a2) *
                            NewtonSecond / Radian};

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else {
        // Limit is inactive, just solve the prismatic constraint in block form.
        const auto df = Solve22(object.K, -Cdot1);

        // object.impulse is a Vec3 while df is a Vec2; so can't just object.impulse += df
        GetX(object.impulse) += GetX(df);
        GetY(object.impulse) += GetY(df);

        const auto ulP = GetX(df) * object.perp;
        const auto P = Momentum2{GetX(ulP) * NewtonSecond, GetY(ulP) * NewtonSecond};
        const auto LA =
            AngularMomentum{(GetX(df) * object.s1 + GetY(df) * Meter) * NewtonSecond / Radian};
        const auto LB =
            AngularMomentum{(GetX(df) * object.s2 + GetY(df) * Meter) * NewtonSecond / Radian};

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

// A velocity based solver computes reaction forces(impulses) using the velocity constraint solver.
// Under this context, the position solver is not there to resolve forces. It is only there to cope
// with integration error.
//
// Therefore, the pseudo impulses in the position solver do not have any physical meaning. Thus it
// is okay if they suck.
//
// We could take the active state from the velocity solver. However, the joint might push past the
// limit when the velocity solver indicates the limit is inactive.
//
bool SolvePosition(const PrismaticJointConf& object, const Span<BodyConstraint>& bodies,
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

    // Compute fresh Jacobians
    const auto rA = Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA);
    const auto rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);
    const auto d = Length2{(posB.linear + rB) - (posA.linear + rA)};

    const auto axis = Rotate(object.localXAxisA, qA);
    const auto a1 = Length{Cross(d + rA, axis)};
    const auto a2 = Length{Cross(rB, axis)};
    const auto perp = Rotate(object.localYAxisA, qA);

    const auto s1 = Length{Cross(d + rA, perp)};
    const auto s2 = Length{Cross(rB, perp)};

    const auto C1 =
        Vec2{Dot(perp, d) / Meter, (posB.angular - posA.angular - object.referenceAngle) / Radian};

    auto linearError = Length{abs(GetX(C1)) * Meter};
    const auto angularError = Angle{abs(GetY(C1)) * Radian};

    auto active = false;
    auto C2 = Real{0};
    if (object.enableLimit) {
        const auto translation = Length{Dot(axis, d)};
        if (abs(object.upperTranslation - object.lowerTranslation) < (Real{2} * conf.linearSlop)) {
            // Prevent large angular corrections
            C2 = StripUnit(
                std::clamp(translation, -conf.maxLinearCorrection, conf.maxLinearCorrection));
            linearError = std::max(linearError, abs(translation));
            active = true;
        }
        else if (translation <= object.lowerTranslation) {
            // Prevent large linear corrections and allow some slop.
            C2 = StripUnit(std::clamp(translation - object.lowerTranslation + conf.linearSlop,
                                      -conf.maxLinearCorrection, 0_m));
            linearError = std::max(linearError, object.lowerTranslation - translation);
            active = true;
        }
        else if (translation >= object.upperTranslation) {
            // Prevent large linear corrections and allow some slop.
            C2 = StripUnit(std::clamp(translation - object.upperTranslation - conf.linearSlop, 0_m,
                                      conf.maxLinearCorrection));
            linearError = std::max(linearError, translation - object.upperTranslation);
            active = true;
        }
    }

    Vec3 impulse;
    if (active) {
        const auto k11 = StripUnit(InvMass{invMassA + invRotInertiaA * Square(s1) / SquareRadian +
                                           invMassB + invRotInertiaB * Square(s2) / SquareRadian});
        const auto k12 = StripUnit(InvMass{invRotInertiaA * s1 * Meter / SquareRadian +
                                           invRotInertiaB * s2 * Meter / SquareRadian});
        const auto k13 = StripUnit(InvMass{invRotInertiaA * s1 * a1 / SquareRadian +
                                           invRotInertiaB * s2 * a2 / SquareRadian});

        // InvRotInertia is L^-2 M^-1 QP^2
        auto k22 = StripUnit(invRotInertiaA + invRotInertiaB);
        if (k22 == Real{0}) {
            // For fixed rotation
            k22 = StripUnit(Real{1} * SquareRadian / (Kilogram * SquareMeter));
        }
        const auto k23 = StripUnit(InvMass{invRotInertiaA * a1 * Meter / SquareRadian +
                                           invRotInertiaB * a2 * Meter / SquareRadian});
        const auto k33 = StripUnit(InvMass{invMassA + invRotInertiaA * Square(a1) / SquareRadian +
                                           invMassB + invRotInertiaB * Square(a2) / SquareRadian});

        const auto K = Mat33{Vec3{k11, k12, k13}, Vec3{k12, k22, k23}, Vec3{k13, k23, k33}};
        const auto C = Vec3{GetX(C1), GetY(C1), C2};

        impulse = Solve33(K, -C);
    }
    else {
        const auto k11 = StripUnit(InvMass{invMassA + invRotInertiaA * s1 * s1 / SquareRadian +
                                           invMassB + invRotInertiaB * s2 * s2 / SquareRadian});
        const auto k12 = StripUnit(InvMass{invRotInertiaA * s1 * Meter / SquareRadian +
                                           invRotInertiaB * s2 * Meter / SquareRadian});
        auto k22 = StripUnit(invRotInertiaA + invRotInertiaB);
        if (k22 == 0) {
            k22 = 1;
        }

        const auto K = Mat22{Vec2{k11, k12}, Vec2{k12, k22}};

        const auto impulse1 = Solve(K, -C1);
        GetX(impulse) = GetX(impulse1);
        GetY(impulse) = GetY(impulse1);
        GetZ(impulse) = 0;
    }

    const auto P = (GetX(impulse) * perp + GetZ(impulse) * axis) * Kilogram * Meter;
    const auto LA = (GetX(impulse) * s1 + GetY(impulse) * Meter + GetZ(impulse) * a1) * Kilogram *
                    Meter / Radian;
    const auto LB = (GetX(impulse) * s2 + GetY(impulse) * Meter + GetZ(impulse) * a2) * Kilogram *
                    Meter / Radian;

    posA -= Position{Length2{invMassA * P}, invRotInertiaA * LA};
    posB += Position{invMassB * P, invRotInertiaB * LB};

    bodyConstraintA.SetPosition(posA);
    bodyConstraintB.SetPosition(posB);

    return (linearError <= conf.linearSlop) && (angularError <= conf.angularSlop);
}

LinearVelocity GetLinearVelocity(const World& world, const PrismaticJointConf& joint) noexcept
{
    const auto bA = GetBodyA(joint);
    const auto bB = GetBodyB(joint);
    const auto rA =
        Rotate(GetLocalAnchorA(joint) - GetLocalCenter(world, bA), GetTransformation(world, bA).q);
    const auto rB =
        Rotate(GetLocalAnchorB(joint) - GetLocalCenter(world, bB), GetTransformation(world, bB).q);
    const auto p1 = GetWorldCenter(world, bA) + rA;
    const auto p2 = GetWorldCenter(world, bB) + rB;
    const auto d = p2 - p1;
    const auto axis = Rotate(GetLocalXAxisA(joint), GetTransformation(world, bA).q);
    const auto vA = GetVelocity(world, bA).linear;
    const auto vB = GetVelocity(world, bB).linear;
    const auto wA = GetVelocity(world, bA).angular;
    const auto wB = GetVelocity(world, bB).angular;
    const auto vel = (vB + (GetRevPerpendicular(rB) * (wB / Radian))) -
                     (vA + (GetRevPerpendicular(rA) * (wA / Radian)));
    return Dot(d, (GetRevPerpendicular(axis) * (wA / Radian))) + Dot(axis, vel);
}

} // namespace d2
} // namespace playrho
