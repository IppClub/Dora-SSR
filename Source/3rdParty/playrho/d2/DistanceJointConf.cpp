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

#include "playrho/ConstraintSolverConf.hpp"
#include "playrho/StepConf.hpp"

#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/d2/DistanceJointConf.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/d2/WorldBody.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible_v<DistanceJointConf>,
              "DistanceJointConf must be nothrow default constructible!");
static_assert(std::is_copy_constructible_v<DistanceJointConf>,
              "DistanceJointConf must be copy constructible!");
static_assert(std::is_move_constructible_v<DistanceJointConf>,
              "DistanceJointConf must be move constructible!");
static_assert(std::is_copy_assignable_v<DistanceJointConf>,
              "DistanceJointConf must be copy assignable!");
static_assert(std::is_move_assignable_v<DistanceJointConf>,
              "DistanceJointConf must be move assignable!");
static_assert(std::is_nothrow_destructible_v<DistanceJointConf>,
              "DistanceJointConf must be nothrow destructible!");

// 1-D constrained system
// m (v2 - v1) = lambda
// v2 + (beta/h) * x1 + gamma * lambda = 0, gamma has units of inverse mass.
// x2 = x1 + h * v2

// 1-D mass-damper-spring system
// m (v2 - v1) + h * d * v2 + h * k *

// C = norm(p2 - p1) - L
// u = (p2 - p1) / norm(p2 - p1)
// Cdot = dot(u, v2 + cross(w2, r2) - v1 - cross(w1, r1))
// J = [-u -cross(r1, u) u cross(r2, u)]
// K = J * invM * JT
//   = invMass1 + invI1 * cross(r1, u)^2 + invMass2 + invI2 * cross(r2, u)^2

DistanceJointConf::DistanceJointConf(BodyID bA, BodyID bB, // force line-break
                                     const Length2& laA, const Length2& laB, // force line-break
                                     Length l) noexcept
    : super{super{}.UseBodyA(bA).UseBodyB(bB)}, localAnchorA{laA}, localAnchorB{laB}, length{l}
{
    // Intentionally empty.
}

DistanceJointConf GetDistanceJointConf(const Joint& joint)
{
    return TypeCast<DistanceJointConf>(joint);
}

DistanceJointConf GetDistanceJointConf(const World& world, BodyID bodyA, BodyID bodyB, // force line-break
                                       const Length2& anchorA, const Length2& anchorB)
{
    return DistanceJointConf{bodyA, bodyB, GetLocalPoint(world, bodyA, anchorA),
                             GetLocalPoint(world, bodyB, anchorB), GetMagnitude(anchorB - anchorA)};
}

void InitVelocity(DistanceJointConf& object, const Span<BodyConstraint>& bodies,
                  const StepConf& step, const ConstraintSolverConf&)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto invMassA = bodyConstraintA.GetInvMass();
    const auto invRotInertiaA = bodyConstraintA.GetInvRotInertia(); // L^-2 M^-1 QP^2
    const auto posA = bodyConstraintA.GetPosition();
    auto velA = bodyConstraintA.GetVelocity();

    const auto invMassB = bodyConstraintB.GetInvMass();
    const auto invRotInertiaB = bodyConstraintB.GetInvRotInertia(); // L^-2 M^-1 QP^2
    const auto posB = bodyConstraintB.GetPosition();
    auto velB = bodyConstraintB.GetVelocity();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    object.rA = Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA);
    object.rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);
    const auto deltaLocation = Length2{(posB.linear + object.rB) - (posA.linear + object.rA)};

    const auto uvresult = UnitVec::Get(deltaLocation[0], deltaLocation[1]);
    object.u = std::get<UnitVec>(uvresult);
    const auto length = std::get<Length>(uvresult);

    const auto crAu = Length{Cross(object.rA, object.u)} / Radian;
    const auto crBu = Length{Cross(object.rB, object.u)} / Radian;
    const auto invRotMassA = InvMass{invRotInertiaA * Square(crAu)};
    const auto invRotMassB = InvMass{invRotInertiaB * Square(crBu)};
    auto invMass = invMassA + invRotMassA + invMassB + invRotMassB;

    object.mass = (invMass != InvMass{}) ? Real{1} / invMass : 0_kg;

    if (object.frequency > 0_Hz) {
        const auto C = length - object.length; // L

        // Frequency
        const auto omega = Real{2} * Pi * object.frequency;

        // Damping coefficient
        const auto d = Real{2} * object.mass * object.dampingRatio * omega; // M T^-1

        // Spring stiffness
        const auto k = object.mass * Square(omega); // M T^-2

        // magic formulas
        const auto h = step.deltaTime;
        const auto gamma = Mass{h * (d + h * k)}; // T (M T^-1 + T M T^-2) = M
        object.invGamma = (gamma != 0_kg) ? Real{1} / gamma : InvMass{};
        object.bias = C * h * k * object.invGamma; // L T M T^-2 M^-1 = L T^-1

        invMass += object.invGamma;
        object.mass = (invMass != InvMass{}) ? Real{1} / invMass : 0_kg;
    }
    else {
        object.invGamma = InvMass{};
        object.bias = 0_mps;
    }

    if (step.doWarmStart) {
        // Scale the impulse to support a variable time step.
        object.impulse *= step.dtRatio;

        const auto P = object.impulse * object.u;

        // P is M L T^-2
        // Cross(Length2, P) is: M L^2 T^-1
        // inv rotational inertia is: L^-2 M^-1 QP^2
        // Product is: L^-2 M^-1 QP^2 M L^2 T^-1 = QP^2 T^-1
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

bool SolveVelocity(DistanceJointConf& object, const Span<BodyConstraint>& bodies, const StepConf&)
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
    const auto Cdot = LinearVelocity{Dot(object.u, vpB - vpA)};

    const auto impulse =
        Momentum{-object.mass * (Cdot + object.bias + object.invGamma * object.impulse)};
    object.impulse += impulse;

    const auto P = impulse * object.u;
    const auto LA = Cross(object.rA, P) / Radian;
    const auto LB = Cross(object.rB, P) / Radian;

    velA -= Velocity{bodyConstraintA.GetInvMass() * P, bodyConstraintA.GetInvRotInertia() * LA};
    velB += Velocity{bodyConstraintB.GetInvMass() * P, bodyConstraintB.GetInvRotInertia() * LB};

    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);

    return impulse == 0_Ns;
}

bool SolvePosition(const DistanceJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf)
{
    if ((GetBodyA(object) == InvalidBodyID) || (GetBodyB(object) == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    if (object.frequency > 0_Hz) {
        // There is no position correction for soft distance constraints.
        return true;
    }

    auto posA = bodyConstraintA.GetPosition();
    auto posB = bodyConstraintB.GetPosition();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    const auto rA = Length2{Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA)};
    const auto rB = Length2{Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB)};
    const auto relLoc = Length2{(posB.linear + rB) - (posA.linear + rA)};

    const auto uvresult = UnitVec::Get(relLoc[0], relLoc[1]);
    const auto u = std::get<UnitVec>(uvresult);
    const auto length = std::get<Length>(uvresult);
    const auto deltaLength = length - object.length;
    const auto C = std::clamp(deltaLength, -conf.maxLinearCorrection, conf.maxLinearCorrection);

    const auto impulse = -object.mass * C;
    const auto P = impulse * u;
    const auto LA = Cross(rA, P) / Radian;
    const auto LB = Cross(rB, P) / Radian;

    posA -= Position{bodyConstraintA.GetInvMass() * P, bodyConstraintA.GetInvRotInertia() * LA};
    posB += Position{bodyConstraintB.GetInvMass() * P, bodyConstraintB.GetInvRotInertia() * LB};

    bodyConstraintA.SetPosition(posA);
    bodyConstraintB.SetPosition(posB);

    return abs(C) < conf.linearSlop;
}

} // namespace d2
} // namespace playrho
