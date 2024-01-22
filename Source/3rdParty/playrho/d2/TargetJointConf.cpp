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

#include <cassert> // for assert

#include "playrho/ConstraintSolverConf.hpp"
#include "playrho/StepConf.hpp"

#include "playrho/d2/TargetJointConf.hpp"
#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/d2/BodyConstraint.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible_v<TargetJointConf>,
              "TargetJointConf should be default constructible!");
static_assert(std::is_copy_constructible_v<TargetJointConf>,
              "TargetJointConf should be copy constructible!");
static_assert(std::is_copy_assignable_v<TargetJointConf>,
              "TargetJointConf should be copy assignable!");
static_assert(std::is_move_constructible_v<TargetJointConf>,
              "TargetJointConf should be move constructible!");
static_assert(std::is_move_assignable_v<TargetJointConf>,
              "TargetJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible_v<TargetJointConf>,
              "TargetJointConf should be nothrow destructible!");

TargetJointConf GetTargetJointConf(const Joint& joint)
{
    return TypeCast<TargetJointConf>(joint);
}

Mass22 GetEffectiveMassMatrix(const TargetJointConf& object, const BodyConstraint& body) noexcept
{
    // K    = [(1/m1 + 1/m2) * eye(2) - skew(r1) * invI1 * skew(r1) - skew(r2) * invI2 * skew(r2)]
    //      = [1/m1+1/m2     0    ] + invI1 * [r1.y*r1.y -r1.x*r1.y] + invI2 * [r1.y*r1.y
    //      -r1.x*r1.y]
    //        [    0     1/m1+1/m2]           [-r1.x*r1.y r1.x*r1.x]           [-r1.x*r1.y
    //        r1.x*r1.x]

    const auto invMass = body.GetInvMass();
    const auto invRotInertia = body.GetInvRotInertia();

    const auto exx =
        InvMass{invMass + (invRotInertia * Square(GetY(object.rB)) / SquareRadian) + object.gamma};
    const auto exy = InvMass{-invRotInertia * GetX(object.rB) * GetY(object.rB) / SquareRadian};
    const auto eyy =
        InvMass{invMass + (invRotInertia * Square(GetX(object.rB)) / SquareRadian) + object.gamma};

    InvMass22 K;
    GetX(GetX(K)) = exx;
    GetY(GetX(K)) = exy;
    GetX(GetY(K)) = exy;
    GetY(GetY(K)) = eyy;
    return Invert(K);
}

// p = attached point, m = mouse point
// C = p - m
// Cdot = v
//      = v + cross(w, r)
// J = [I r_skew]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

void InitVelocity(TargetJointConf& object, const Span<BodyConstraint>& bodies,
                  const StepConf& step, const ConstraintSolverConf&)
{
    if (GetBodyB(object) == InvalidBodyID) {
        return;
    }

    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    const auto posB = bodyConstraintB.GetPosition();
    auto velB = bodyConstraintB.GetVelocity();

    const auto qB = UnitVec::Get(posB.angular);

    const auto mass = (bodyConstraintB.GetInvMass() != InvMass{})
                          ? (Real{1} / bodyConstraintB.GetInvMass())
                          : 0_kg;

    // Frequency
    const auto omega = Real{2} * Pi * object.frequency; // T^-1

    // Damping coefficient
    const auto d = Real{2} * mass * object.dampingRatio * omega; // M T^-1

    // Spring stiffness
    const auto k = mass * Square(omega); // M T^-2

    // magic formulas
    // gamma has units of inverse mass.
    // beta has units of inverse time.
    const auto h = step.deltaTime;
    const auto tmp = d + h * k; // M T^-1
    assert(IsValid(Real{tmp * Second / Kilogram}));
    const auto invGamma = Mass{h * tmp}; // M T^-1 * T is simply M.
    object.gamma = (invGamma != 0_kg) ? Real{1} / invGamma : InvMass{};
    const auto beta = Frequency{h * k * object.gamma}; // T * M T^-2 * M^-1 is T^-1

    // Compute the effective mass matrix.
    object.rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);

    object.mass = GetEffectiveMassMatrix(object, bodyConstraintB);

    object.C = LinearVelocity2{((posB.linear + object.rB) - object.target) * beta};
    assert(IsValid(object.C));

    // Cheat with some damping
    static constexpr auto DampingAmount = static_cast<Real>(0.98f);
    velB.angular *= DampingAmount;

    if (step.doWarmStart) {
        object.impulse *= step.dtRatio;
        const auto P = object.impulse;
        const auto crossBP =
            AngularMomentum{Cross(object.rB, P) / Radian}; // L * M * L T^-1 is: L^2 M T^-1
        velB += Velocity{bodyConstraintB.GetInvMass() * P,
                         bodyConstraintB.GetInvRotInertia() * crossBP};
    }
    else {
        object.impulse = Momentum2{};
    }

    bodyConstraintB.SetVelocity(velB);
}

bool SolveVelocity(TargetJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step)
{
    if (GetBodyB(object) == InvalidBodyID) {
        return true;
    }

    auto& bodyConstraintB = At(bodies, GetBodyB(object));

    auto velB = bodyConstraintB.GetVelocity();
    assert(IsValid(velB));

    const auto Cdot =
        LinearVelocity2{velB.linear + (GetRevPerpendicular(object.rB) * (velB.angular / Radian))};
    const auto ev = Cdot + LinearVelocity2{object.C + (object.gamma * object.impulse)};
    const auto oldImpulse = object.impulse;
    const auto addImpulse = Transform(-ev, object.mass);
    assert(IsValid(addImpulse));
    object.impulse += addImpulse;
    const auto maxImpulse = step.deltaTime * Force{object.maxForce};
    if (GetMagnitudeSquared(object.impulse) > Square(maxImpulse)) {
        object.impulse = GetUnitVector(object.impulse, UnitVec::GetZero()) * maxImpulse;
    }

    const auto incImpulse = (object.impulse - oldImpulse);
    const auto angImpulseB = AngularMomentum{Cross(object.rB, incImpulse) / Radian};

    velB += Velocity{bodyConstraintB.GetInvMass() * incImpulse,
                     bodyConstraintB.GetInvRotInertia() * angImpulseB};

    bodyConstraintB.SetVelocity(velB);

    return incImpulse == Momentum2{0_Ns, 0_Ns};
}

bool SolvePosition(const TargetJointConf&, const Span<BodyConstraint>&,
                   const ConstraintSolverConf&)
{
    return true;
}

} // namespace d2
} // namespace playrho
