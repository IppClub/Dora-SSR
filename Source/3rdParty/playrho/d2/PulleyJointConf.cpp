/*
 * Original work Copyright (c) 2007 Erin Catto http://www.box2d.org
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

#include "playrho/d2/PulleyJointConf.hpp"

#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/ConstraintSolverConf.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible_v<PulleyJointConf>,
              "PulleyJointConf should be default constructible!");
static_assert(std::is_copy_constructible_v<PulleyJointConf>,
              "PulleyJointConf should be copy constructible!");
static_assert(std::is_copy_assignable_v<PulleyJointConf>,
              "PulleyJointConf should be copy assignable!");
static_assert(std::is_move_constructible_v<PulleyJointConf>,
              "PulleyJointConf should be move constructible!");
static_assert(std::is_move_assignable_v<PulleyJointConf>,
              "PulleyJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible_v<PulleyJointConf>,
              "PulleyJointConf should be nothrow destructible!");

// Pulley:
// length1 = norm(p1 - s1)
// length2 = norm(p2 - s2)
// C0 = (length1 + ratio * length2)_initial
// C = C0 - (length1 + ratio * length2)
// u1 = (p1 - s1) / norm(p1 - s1)
// u2 = (p2 - s2) / norm(p2 - s2)
// Cdot = -dot(u1, v1 + cross(w1, r1)) - ratio * dot(u2, v2 + cross(w2, r2))
// J = -[u1 cross(r1, u1) ratio * u2  ratio * cross(r2, u2)]
// K = J * invM * JT
//   = invMass1 + invI1 * cross(r1, u1)^2 + ratio^2 * (invMass2 + invI2 * cross(r2, u2)^2)

PulleyJointConf::PulleyJointConf(BodyID bA, BodyID bB, // force line-break
                                 const Length2& gaA, const Length2& gaB, // force line-break
                                 const Length2& laA, const Length2& laB, // force line-break
                                 Length lA, Length lB)
    : super{super{}.UseBodyA(bA).UseBodyB(bB).UseCollideConnected(true)},
      groundAnchorA{gaA},
      groundAnchorB{gaB},
      localAnchorA{laA},
      localAnchorB{laB},
      lengthA{lA},
      lengthB{lB}
{
    // Intentionally empty.
}

PulleyJointConf GetPulleyJointConf(const Joint& joint)
{
    return TypeCast<PulleyJointConf>(joint);
}

PulleyJointConf GetPulleyJointConf(const World& world, BodyID bA, BodyID bB, // force line-break
                                   const Length2& groundA, const Length2& groundB, // force line-break
                                   const Length2& anchorA, const Length2& anchorB)
{
    return PulleyJointConf{bA,
                           bB,
                           groundA,
                           groundB,
                           GetLocalPoint(world, bA, anchorA),
                           GetLocalPoint(world, bB, anchorB),
                           GetMagnitude(anchorA - groundA),
                           GetMagnitude(anchorB - groundB)};
}

void InitVelocity(PulleyJointConf& object, const Span<BodyConstraint>& bodies,
                  const StepConf& step, const ConstraintSolverConf&)
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

    object.rA = Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA);
    object.rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);

    // Get the pulley axes.
    const auto pulleyAxisA = Length2{posA.linear + object.rA - object.groundAnchorA};
    const auto pulleyAxisB = Length2{posB.linear + object.rB - object.groundAnchorB};

    object.uA = GetUnitVector(pulleyAxisA, UnitVec::GetZero());
    object.uB = GetUnitVector(pulleyAxisB, UnitVec::GetZero());

    // Compute effective mass.
    const auto ruA = Cross(object.rA, object.uA);
    const auto ruB = Cross(object.rB, object.uB);

    const auto totInvMassA = invMassA + (invRotInertiaA * Square(ruA)) / SquareRadian;
    const auto totInvMassB = invMassB + (invRotInertiaB * Square(ruB)) / SquareRadian;

    const auto totalInvMass = totInvMassA + object.ratio * object.ratio * totInvMassB;

    object.mass = (totalInvMass > InvMass{}) ? Real{1} / totalInvMass : 0_kg;

    if (step.doWarmStart) {
        // Scale impulses to support variable time steps.
        object.impulse *= step.dtRatio;

        // Warm starting.
        const auto PA = -(object.impulse) * object.uA;
        const auto PB = (-object.ratio * object.impulse) * object.uB;

        velA += Velocity{invMassA * PA, invRotInertiaA * Cross(object.rA, PA) / Radian};
        velB += Velocity{invMassB * PB, invRotInertiaB * Cross(object.rB, PB) / Radian};
    }
    else {
        object.impulse = 0_Ns;
    }

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);
}

bool SolveVelocity(PulleyJointConf& object, const Span<BodyConstraint>& bodies, const StepConf&)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();
    auto velA = bodyConstraintA.GetVelocity();

    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();
    auto velB = bodyConstraintB.GetVelocity();

    const auto vpA =
        LinearVelocity2{velA.linear + GetRevPerpendicular(object.rA) * (velA.angular / Radian)};
    const auto vpB =
        LinearVelocity2{velB.linear + GetRevPerpendicular(object.rB) * (velB.angular / Radian)};

    const auto Cdot = LinearVelocity{-Dot(object.uA, vpA) - object.ratio * Dot(object.uB, vpB)};
    const auto impulse = -object.mass * Cdot;
    object.impulse += impulse;

    const auto PA = -impulse * object.uA;
    const auto PB = -object.ratio * impulse * object.uB;
    velA += Velocity{invMassA * PA, invRotInertiaA * Cross(object.rA, PA) / Radian};
    velB += Velocity{invMassB * PB, invRotInertiaB * Cross(object.rB, PB) / Radian};

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);

    return impulse == 0_Ns;
}

bool SolvePosition(const PulleyJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();
    auto posA = bodyConstraintA.GetPosition();

    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();
    auto posB = bodyConstraintB.GetPosition();

    const auto rA =
        Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), UnitVec::Get(posA.angular));
    const auto rB =
        Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), UnitVec::Get(posB.angular));

    // Get the pulley axes.
    const auto pA = Length2{posA.linear + rA - object.groundAnchorA};
    const auto uvresultA = UnitVec::Get(pA[0], pA[1]);
    const auto uA = std::get<UnitVec>(uvresultA);
    const auto lengthA = std::get<Length>(uvresultA);

    const auto pB = Length2{posB.linear + rB - object.groundAnchorB};
    const auto uvresultB = UnitVec::Get(pB[0], pB[1]);
    const auto uB = std::get<UnitVec>(uvresultB);
    const auto lengthB = std::get<Length>(uvresultB);

    // Compute effective mass.
    const auto ruA = Length{Cross(rA, uA)};
    const auto ruB = Length{Cross(rB, uB)};

    const auto totalInvMassA = invMassA + invRotInertiaA * Square(ruA) / SquareRadian;
    const auto totalInvMassB = invMassB + invRotInertiaB * Square(ruB) / SquareRadian;

    const auto totalInvMass = totalInvMassA + Square(object.ratio) * totalInvMassB;
    const auto mass = (totalInvMass > InvMass{}) ? Real{1} / totalInvMass : 0_kg;

    const auto srcLengthRatio = object.lengthA + object.ratio * object.lengthB; // constant C0
    const auto dstLengthRatio = lengthA + object.ratio * lengthB;
    const auto C = srcLengthRatio - dstLengthRatio;
    const auto linearError = abs(C);

    const auto impulse = -mass * C;

    const auto PA = -impulse * uA;
    const auto PB = -object.ratio * impulse * uB;

    posA += Position{invMassA * PA, invRotInertiaA * Cross(rA, PA) / Radian};
    posB += Position{invMassB * PB, invRotInertiaB * Cross(rB, PB) / Radian};

    bodyConstraintA.SetPosition(posA);
    bodyConstraintB.SetPosition(posB);

    return linearError < conf.linearSlop;
}

bool ShiftOrigin(PulleyJointConf& object, const Length2& newOrigin) noexcept
{
    object.groundAnchorA -= newOrigin;
    object.groundAnchorB -= newOrigin;
    return true;
}

} // namespace d2
} // namespace playrho
