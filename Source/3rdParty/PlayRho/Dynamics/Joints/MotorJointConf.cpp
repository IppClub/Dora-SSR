/*
 * Original work Copyright (c) 2006-2012 Erin Catto http://www.box2d.org
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

#include "PlayRho/Dynamics/Joints/MotorJointConf.hpp"

#include "PlayRho/Dynamics/WorldBody.hpp"
#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/Contacts/BodyConstraint.hpp"
#include "PlayRho/Dynamics/Contacts/ConstraintSolverConf.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible<MotorJointConf>::value,
              "MotorJointConf should be default constructible!");
static_assert(std::is_copy_constructible<MotorJointConf>::value,
              "MotorJointConf should be copy constructible!");
static_assert(std::is_copy_assignable<MotorJointConf>::value,
              "MotorJointConf should be copy assignable!");
static_assert(std::is_move_constructible<MotorJointConf>::value,
              "MotorJointConf should be move constructible!");
static_assert(std::is_move_assignable<MotorJointConf>::value,
              "MotorJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible<MotorJointConf>::value,
              "MotorJointConf should be nothrow destructible!");

// Point-to-point constraint
// Cdot = v2 - v1
//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
// J = [-I -r1_skew I r2_skew ]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)
//
// r1 = offset - c1
// r2 = -c2

// Angle constraint
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
// K = invI1 + invI2

MotorJointConf::MotorJointConf(BodyID bA, BodyID bB, Length2 lo, Angle ao) noexcept
    : super{super{}.UseBodyA(bA).UseBodyB(bB)}, linearOffset{lo}, angularOffset{ao}
{
    // Intentionally empty.
}

MotorJointConf GetMotorJointConf(const Joint& joint) noexcept
{
    return TypeCast<MotorJointConf>(joint);
}

MotorJointConf GetMotorJointConf(const World& world, BodyID bA, BodyID bB)
{
    return MotorJointConf{bA, bB, GetLocalPoint(world, bA, GetLocation(world, bB)),
                          GetAngle(world, bB) - GetAngle(world, bA)};
}

void InitVelocity(MotorJointConf& object, std::vector<BodyConstraint>& bodies, const StepConf& step,
                  const ConstraintSolverConf&)
{
    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto posA = bodyConstraintA.GetPosition();
    auto velA = bodyConstraintA.GetVelocity();

    const auto posB = bodyConstraintB.GetPosition();
    auto velB = bodyConstraintB.GetVelocity();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    // Compute the effective mass matrix.
    object.rA = Rotate(object.linearOffset - bodyConstraintA.GetLocalCenter(), qA);
    object.rB = Rotate(-bodyConstraintB.GetLocalCenter(), qB);

    // J = [-I -r1_skew I r2_skew]
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
            InvMass{invMassA + invMassB + invRotInertiaA * Square(GetY(object.rA)) / SquareRadian +
                    invRotInertiaB * Square(GetY(object.rB)) / SquareRadian};
        const auto exy =
            InvMass{-invRotInertiaA * GetX(object.rA) * GetY(object.rA) / SquareRadian +
                    -invRotInertiaB * GetX(object.rB) * GetY(object.rB) / SquareRadian};
        const auto eyy =
            InvMass{invMassA + invMassB + invRotInertiaA * Square(GetX(object.rA)) / SquareRadian +
                    invRotInertiaB * Square(GetX(object.rB)) / SquareRadian};
        // Upper 2 by 2 of K above for point to point
        const auto k22 = InvMass22{Vector<InvMass, 2>{exx, exy}, Vector<InvMass, 2>{exy, eyy}};
        object.linearMass = Invert(k22);
    }

    const auto invRotInertia = invRotInertiaA + invRotInertiaB;
    object.angularMass =
        (invRotInertia > InvRotInertia{0}) ? RotInertia{Real{1} / invRotInertia} : RotInertia{0};

    object.linearError = (posB.linear + object.rB) - (posA.linear + object.rA);
    object.angularError = (posB.angular - posA.angular) - object.angularOffset;

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
        object.angularImpulse = AngularMomentum{0};
    }

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);
}

bool SolveVelocity(MotorJointConf& object, std::vector<BodyConstraint>& bodies,
                   const StepConf& step)
{
    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    auto velA = bodyConstraintA.GetVelocity();
    auto velB = bodyConstraintB.GetVelocity();

    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();

    const auto h = step.deltaTime;
    const auto inv_h = (h != 0_s) ? Real(1) / h : 0_Hz;

    auto solved = true;

    // Solve angular friction
    {
        const auto Cdot = AngularVelocity{(velB.angular - velA.angular) +
                                          inv_h * object.correctionFactor * object.angularError};
        const auto angularImpulse = AngularMomentum{-object.angularMass * Cdot};

        const auto oldAngularImpulse = object.angularImpulse;
        const auto maxAngularImpulse = h * object.maxTorque;
        const auto newAngularImpulse =
            std::clamp(oldAngularImpulse + angularImpulse, -maxAngularImpulse, maxAngularImpulse);
        object.angularImpulse = newAngularImpulse;
        const auto incAngularImpulse = newAngularImpulse - oldAngularImpulse;

        if (incAngularImpulse != AngularMomentum{0}) {
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
        const auto Cdot =
            LinearVelocity2{(vb - va) + inv_h * object.correctionFactor * object.linearError};

        const auto impulse = -Transform(Cdot, object.linearMass);
        const auto oldImpulse = object.linearImpulse;
        object.linearImpulse += impulse;

        const auto maxImpulse = h * object.maxForce;

        if (GetMagnitudeSquared(object.linearImpulse) > Square(maxImpulse)) {
            object.linearImpulse =
                GetUnitVector(object.linearImpulse, UnitVec::GetZero()) * maxImpulse;
        }

        const auto incImpulse = object.linearImpulse - oldImpulse;
        const auto angImpulseA = AngularMomentum{Cross(object.rA, incImpulse) / Radian};
        const auto angImpulseB = AngularMomentum{Cross(object.rB, incImpulse) / Radian};

        if (incImpulse != Momentum2{}) {
            solved = false;
        }

        velA -= Velocity{invMassA * incImpulse, invRotInertiaA * angImpulseA};
        velB += Velocity{invMassB * incImpulse, invRotInertiaB * angImpulseB};
    }

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);

    return solved;
}

bool SolvePosition(const MotorJointConf&, std::vector<BodyConstraint>&, const ConstraintSolverConf&)
{
    return true;
}

} // namespace d2
} // namespace playrho
