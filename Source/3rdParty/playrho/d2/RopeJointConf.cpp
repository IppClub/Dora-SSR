/*
 * Original work Copyright (c) 2007-2011 Erin Catto http://www.box2d.org
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

#include "playrho/d2/RopeJointConf.hpp"

#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/ConstraintSolverConf.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible_v<RopeJointConf>,
              "RopeJointConf should be default constructible!");
static_assert(std::is_copy_constructible_v<RopeJointConf>,
              "RopeJointConf should be copy constructible!");
static_assert(std::is_copy_assignable_v<RopeJointConf>,
              "RopeJointConf should be copy assignable!");
static_assert(std::is_move_constructible_v<RopeJointConf>,
              "RopeJointConf should be move constructible!");
static_assert(std::is_move_assignable_v<RopeJointConf>,
              "RopeJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible_v<RopeJointConf>,
              "RopeJointConf should be nothrow destructible!");

RopeJointConf GetRopeJointConf(const Joint& joint)
{
    return TypeCast<RopeJointConf>(joint);
}

// Limit:
// C = norm(pB - pA) - L
// u = (pB - pA) / norm(pB - pA)
// Cdot = dot(u, vB + cross(wB, rB) - vA - cross(wA, rA))
// J = [-u -cross(rA, u) u cross(rB, u)]
// K = J * invM * JT
//   = invMassA + invIA * cross(rA, u)^2 + invMassB + invIB * cross(rB, u)^2

void InitVelocity(RopeJointConf& object, const Span<BodyConstraint>& bodies, const StepConf& step,
                  const ConstraintSolverConf& conf)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia();
    const auto posA = bodyConstraintA.GetPosition();
    auto velA = bodyConstraintA.GetVelocity();

    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia();
    const auto posB = bodyConstraintB.GetPosition();
    auto velB = bodyConstraintB.GetVelocity();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    object.rA = Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA);
    object.rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);
    const auto posDelta = Length2{(posB.linear + object.rB) - (posA.linear + object.rA)};

    const auto uvresult = UnitVec::Get(posDelta[0], posDelta[1]);
    const auto uv = std::get<UnitVec>(uvresult);
    object.length = std::get<Length>(uvresult);

    const auto C = object.length - object.maxLength;
    object.limitState = (C > 0_m) ? LimitState::e_atUpperLimit : LimitState::e_inactiveLimit;

    if (object.length > conf.linearSlop) {
        object.u = uv;
    }
    else {
        object.u = UnitVec::GetZero();
        object.mass = 0_kg;
        object.impulse = 0_Ns;
        return;
    }

    // Compute effective mass.
    const auto crA = Length{Cross(object.rA, object.u)} / Radian;
    const auto crB = Length{Cross(object.rB, object.u)} / Radian;
    const auto invRotMassA = InvMass{invRotInertiaA * Square(crA)};
    const auto invRotMassB = InvMass{invRotInertiaB * Square(crB)};
    const auto invMass = invMassA + invMassB + invRotMassA + invRotMassB;

    object.mass = (invMass != InvMass{}) ? Real{1} / invMass : 0_kg;

    if (step.doWarmStart) {
        // Scale the impulse to support a variable time step.
        object.impulse *= step.dtRatio;

        const auto P = object.impulse * object.u;

        // L * M * L T^-1 / QP is: L^2 M T^-1 QP^-1 which is: AngularMomentum.
        // L * M * L T^-1 is: L^2 M T^-1
        const auto LA = AngularMomentum{Cross(object.rA, P) / Radian};
        const auto LB = AngularMomentum{Cross(object.rB, P) / Radian};
        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else {
        object.impulse = 0_Ns;
    }

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);
}

bool SolveVelocity(RopeJointConf& object, const Span<BodyConstraint>& bodies, const StepConf& step)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    auto velA = bodyConstraintA.GetVelocity();
    auto velB = bodyConstraintB.GetVelocity();

    // Cdot = dot(u, v + cross(w, r))
    const auto vpA = velA.linear + GetRevPerpendicular(object.rA) * (velA.angular / Radian);
    const auto vpB = velB.linear + GetRevPerpendicular(object.rB) * (velB.angular / Radian);
    const auto C = object.length - object.maxLength;

    // Predictive constraint.
    const auto inv_h = (step.deltaTime != 0_s) ? Real(1) / step.deltaTime : 0_Hz;
    const auto Cdot = LinearVelocity{Dot(object.u, vpB - vpA) + ((C < 0_m) ? inv_h * C : 0_mps)};

    auto localImpulse = -object.mass * Cdot;
    const auto oldImpulse = object.impulse;
    object.impulse = std::min(0_Ns, object.impulse + localImpulse);
    localImpulse = object.impulse - oldImpulse;

    // L * M * L T^-1 / QP is: L^2 M T^-1 QP^-1 which is: AngularMomentum.
    // L * M * L T^-1 is: L^2 M T^-1
    const auto P = localImpulse * object.u;
    const auto LA = AngularMomentum{Cross(object.rA, P) / Radian};
    const auto LB = AngularMomentum{Cross(object.rB, P) / Radian};

    velA -= Velocity{bodyConstraintA.GetInvMass() * P, bodyConstraintA.GetInvRotInertia() * LA};
    velB += Velocity{bodyConstraintB.GetInvMass() * P, bodyConstraintB.GetInvRotInertia() * LB};

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);

    return localImpulse == 0_Ns;
}

bool SolvePosition(const RopeJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    auto posA = bodyConstraintA.GetPosition();
    auto posB = bodyConstraintB.GetPosition();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    const auto rA = Length2{Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA)};
    const auto rB = Length2{Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB)};
    const auto posDelta = (posB.linear + rB) - (posA.linear + rA);

    const auto uvresult = UnitVec::Get(posDelta[0], posDelta[1]);
    const auto uv = std::get<UnitVec>(uvresult);
    const auto length = std::get<Length>(uvresult);

    const auto C = std::clamp(length - object.maxLength, 0_m, conf.maxLinearCorrection);

    const auto localImpulse = -object.mass * C;

    const auto P = localImpulse * uv;
    const auto LA = Cross(rA, P) / Radian;
    const auto LB = Cross(rB, P) / Radian;

    posA -= Position{bodyConstraintA.GetInvMass() * P, bodyConstraintA.GetInvRotInertia() * LA};
    posB += Position{bodyConstraintB.GetInvMass() * P, bodyConstraintB.GetInvRotInertia() * LB};

    bodyConstraintA.SetPosition(posA);
    bodyConstraintB.SetPosition(posB);

    return (length - object.maxLength) < conf.linearSlop;
}

} // namespace d2
} // namespace playrho
