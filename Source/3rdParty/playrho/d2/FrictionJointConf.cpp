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

#include "playrho/d2/FrictionJointConf.hpp"

#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/ConstraintSolverConf.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible_v<FrictionJointConf>,
              "FrictionJointConf should be default constructible!");
static_assert(std::is_copy_constructible_v<FrictionJointConf>,
              "FrictionJointConf should be copy constructible!");
static_assert(std::is_copy_assignable_v<FrictionJointConf>,
              "FrictionJointConf should be copy assignable!");
static_assert(std::is_move_constructible_v<FrictionJointConf>,
              "FrictionJointConf should be move constructible!");
static_assert(std::is_move_assignable_v<FrictionJointConf>,
              "FrictionJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible_v<FrictionJointConf>,
              "FrictionJointConf should be nothrow destructible!");

// Point-to-point constraint
// Cdot = v2 - v1
//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
// J = [-I -r1_skew I r2_skew ]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

// Angle constraint
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
// K = invI1 + invI2

FrictionJointConf::FrictionJointConf(BodyID bA, BodyID bB, // force line-break
                                     const Length2& laA, const Length2& laB) noexcept
    : super{super{}.UseBodyA(bA).UseBodyB(bB)}, localAnchorA{laA}, localAnchorB{laB}
{
    // Intentionally empty.
}

FrictionJointConf GetFrictionJointConf(const Joint& joint)
{
    return TypeCast<FrictionJointConf>(joint);
}

FrictionJointConf GetFrictionJointConf(const World& world, BodyID bodyA, BodyID bodyB,
                                       const Length2& anchor)
{
    return FrictionJointConf{bodyA, bodyB, GetLocalPoint(world, bodyA, anchor),
                             GetLocalPoint(world, bodyB, anchor)};
}

void InitVelocity(FrictionJointConf& object, const Span<BodyConstraint>& bodies,
                  const StepConf& step, const ConstraintSolverConf&)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));
    const auto posA = bodyConstraintA.GetPosition();
    auto velA = bodyConstraintA.GetVelocity();
    const auto posB = bodyConstraintB.GetPosition();
    auto velB = bodyConstraintB.GetVelocity();

    // Compute the effective mass matrix.
    object.rA =
        Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), UnitVec::Get(posA.angular));
    object.rB =
        Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), UnitVec::Get(posB.angular));

    // J = [-I -r1_skew I r2_skew]
    //     [ 0       -1 0       1]
    // r_skew = [-ry; rx]

    // Matlab
    // K = [ mA+r1y^2*iA+mB+r2y^2*iB,  -r1y*iA*r1x-r2y*iB*r2x,          -r1y*iA-r2y*iB]
    //     [  -r1y*iA*r1x-r2y*iB*r2x, mA+r1x^2*iA+mB+r2x^2*iB,           r1x*iA+r2x*iB]
    //     [          -r1y*iA-r2y*iB,           r1x*iA+r2x*iB,                   iA+iB]

    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();

    {
        const auto exx =
            InvMass{invMassA + invRotInertiaA * Square(GetY(object.rA)) / SquareRadian + invMassB +
                    invRotInertiaB * Square(GetY(object.rB)) / SquareRadian};
        const auto exy =
            InvMass{-invRotInertiaA * GetX(object.rA) * GetY(object.rA) / SquareRadian +
                    -invRotInertiaB * GetX(object.rB) * GetY(object.rB) / SquareRadian};
        const auto eyy =
            InvMass{invMassA + invRotInertiaA * Square(GetX(object.rA)) / SquareRadian + invMassB +
                    invRotInertiaB * Square(GetX(object.rB)) / SquareRadian};
        InvMass22 K;
        GetX(GetX(K)) = exx;
        GetY(GetX(K)) = exy;
        GetX(GetY(K)) = exy;
        GetY(GetY(K)) = eyy;
        object.linearMass = Invert(K);
    }

    const auto invRotInertia = invRotInertiaA + invRotInertiaB;
    object.angularMass =
        (invRotInertia > InvRotInertia{}) ? RotInertia{Real{1} / invRotInertia} : RotInertia{};

    if (step.doWarmStart) {
        // Scale impulses to support a variable time step.
        object.linearImpulse *= step.dtRatio;
        object.angularImpulse *= step.dtRatio;

        const auto P = object.linearImpulse;

        // L * M * L T^-1 / QP is: L^2 M T^-1 QP^-1 which is: AngularMomentum.
        const auto crossAP = AngularMomentum{Cross(object.rA, P) / Radian};
        const auto crossBP =
            AngularMomentum{Cross(object.rB, P) / Radian}; // L * M * L T^-1 is: L^2 M T^-1

        velA -= Velocity{invMassA * P, invRotInertiaA * (crossAP + object.angularImpulse)};
        velB += Velocity{invMassB * P, invRotInertiaB * (crossBP + object.angularImpulse)};
    }
    else {
        object.linearImpulse = Momentum2{};
        object.angularImpulse = AngularMomentum{};
    }

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);
}

bool SolveVelocity(FrictionJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    auto velA = bodyConstraintA.GetVelocity();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();

    auto velB = bodyConstraintB.GetVelocity();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();

    const auto h = step.deltaTime;

    auto solved = true;

    // Solve angular friction
    {
        // L^2 M QP^-2 * QP T^-1 is: L^2 M QP^-1 T^-1 (SquareMeter * Kilogram / Second) / Radian
        //                           L^2 M QP^-1 T^-1
        const auto angularImpulse =
            AngularMomentum{-object.angularMass * (velB.angular - velA.angular)};

        const auto oldAngularImpulse = object.angularImpulse;
        const auto maxAngularImpulse = h * object.maxTorque;
        object.angularImpulse = std::clamp(object.angularImpulse + angularImpulse,
                                           -maxAngularImpulse, maxAngularImpulse);
        const auto incAngularImpulse = object.angularImpulse - oldAngularImpulse;

        if (incAngularImpulse != AngularMomentum{}) {
            solved = false;
        }

        velA.angular -= invRotInertiaA * incAngularImpulse;
        velB.angular += invRotInertiaB * incAngularImpulse;
    }

    // Solve linear friction
    {
        const auto vb = LinearVelocity2{velB.linear +
                                        (GetRevPerpendicular(object.rB) * (velB.angular / Radian))};
        const auto va = LinearVelocity2{velA.linear +
                                        (GetRevPerpendicular(object.rA) * (velA.angular / Radian))};

        const auto impulse = -Transform(vb - va, object.linearMass);
        const auto oldImpulse = object.linearImpulse;
        object.linearImpulse += impulse;

        const auto maxImpulse = h * object.maxForce;

        if (GetMagnitudeSquared(object.linearImpulse) > Square(maxImpulse)) {
            object.linearImpulse =
                GetUnitVector(object.linearImpulse, UnitVec::GetZero()) * maxImpulse;
        }

        const auto incImpulse = Momentum2{object.linearImpulse - oldImpulse};
        const auto angImpulseA = AngularMomentum{Cross(object.rA, incImpulse) / Radian};
        const auto angImpulseB = AngularMomentum{Cross(object.rB, incImpulse) / Radian};

        if (incImpulse != Momentum2{0_Ns, 0_Ns}) {
            solved = false;
        }

        velA -= Velocity{bodyConstraintA.GetInvMass() * incImpulse, invRotInertiaA * angImpulseA};
        velB += Velocity{bodyConstraintB.GetInvMass() * incImpulse, invRotInertiaB * angImpulseB};
    }

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);

    return solved;
}

bool SolvePosition(const FrictionJointConf&, const Span<BodyConstraint>&,
                   const ConstraintSolverConf&)
{
    return true;
}

} // namespace d2
} // namespace playrho
