/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include "PlayRho/Dynamics/Contacts/ContactSolver.hpp"
#include "PlayRho/Collision/Collision.hpp"
#include "PlayRho/Collision/WorldManifold.hpp"
#include "PlayRho/Dynamics/Contacts/PositionSolverManifold.hpp"
#include "PlayRho/Dynamics/Contacts/VelocityConstraint.hpp"
#include "PlayRho/Dynamics/Contacts/PositionConstraint.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Common/OptionalValue.hpp"

#include <algorithm>

#if !defined(NDEBUG)
// Solver debugging is normally disabled because the block solver sometimes has to deal with a
// poorly conditioned effective mass matrix.
//#define PLAYRHO_DEBUG_SOLVER 1
#endif

namespace playrho {
namespace d2 {
namespace {

#if defined(B2_DEBUG_SOLVER)
static PLAYRHO_CONSTEXPR inline auto k_errorTol = 1e-3_mps; ///< error tolerance
#endif

/// Impulse change.
///
/// @details
/// This describes the change in impulse necessary for a solution.
/// To apply this: let P = magnitude * direction, then
///   the change to body A's velocity is
///   -Velocity{vc.GetBodyA()->GetInvMass() * P,
///       Radian * vc.GetBodyA()->GetInvRotInertia() * Cross(vcp.relA, P)}
///   the change to body B's velocity is
///   +Velocity{vc.GetBodyB()->GetInvMass() * P,
///       Radian * vc.GetBodyB()->GetInvRotInertia() * Cross(vcp.relB, P)}
///   and the new impulse = oldImpulse + magnitude.
///
struct ImpulseChange
{
    Momentum magnitude; ///< Magnitude.
    UnitVec direction; ///< Direction.
};

VelocityPair GetVelocityDelta(const VelocityConstraint& vc, const Momentum2 impulses)
{
    assert(IsValid(impulses));

    const auto bodyA = vc.GetBodyA();
    const auto bodyB = vc.GetBodyB();
    const auto normal = vc.GetNormal();

    const auto invRotInertiaA = bodyA->GetInvRotInertia();
    const auto invMassA = bodyA->GetInvMass();

    const auto invRotInertiaB = bodyB->GetInvRotInertia();
    const auto invMassB = bodyB->GetInvMass();

    // Apply incremental impulse
    const auto P0 = impulses[0] * normal;
    const auto P1 = impulses[1] * normal;
    const auto P = P0 + P1;
    const auto LA = AngularMomentum{
        (Cross(GetPointRelPosA(vc, 0), P0) + Cross(GetPointRelPosA(vc, 1), P1)) / Radian
    };
    const auto LB = AngularMomentum{
        (Cross(GetPointRelPosB(vc, 0), P0) + Cross(GetPointRelPosB(vc, 1), P1)) / Radian
    };
    return VelocityPair{
        -Velocity{invMassA * P, invRotInertiaA * LA},
        +Velocity{invMassB * P, invRotInertiaB * LB}
    };
}

Momentum BlockSolveUpdate(VelocityConstraint& vc, const Momentum2 newImpulses)
{
    const auto delta_v = GetVelocityDelta(vc, newImpulses - GetNormalImpulses(vc));
    vc.GetBodyA()->SetVelocity(vc.GetBodyA()->GetVelocity() + std::get<0>(delta_v));
    vc.GetBodyB()->SetVelocity(vc.GetBodyB()->GetVelocity() + std::get<1>(delta_v));
    SetNormalImpulses(vc, newImpulses);
    return std::max(abs(newImpulses[0]), abs(newImpulses[1]));
}

Optional<Momentum> BlockSolveNormalCase1(VelocityConstraint& vc,
                                         const LinearVelocity2 b_prime)
{
    //
    // Case 1: vn = 0
    //
    // 0 = A * x + b'
    //
    // Solve for x:
    //
    // x = -inv(A) * b'
    //
    const auto normalMass = vc.GetNormalMass();
    const auto newImpulses = -Transform(b_prime, normalMass);
    if ((newImpulses[0] >= 0_Ns) && (newImpulses[1] >= 0_Ns))
    {
        const auto max = BlockSolveUpdate(vc, newImpulses);

#if defined(B2_DEBUG_SOLVER)
        auto& vcp0 = vc.GetPointAt(0);
        auto& vcp1 = vc.GetPointAt(1);
        const auto velA = vc.GetBodyA()->GetVelocity();
        const auto velB = vc.GetBodyB()->GetVelocity();

        // Postconditions
        const auto dv0 = GetContactRelVelocity(velA, vcp0.relA, velB, vcp0.relB);
        const auto dv1 = GetContactRelVelocity(velA, vcp1.relA, velB, vcp1.relB);

        // Compute normal velocity
        const auto vn0 = Dot(dv0, vc.GetNormal());
        const auto vn1 = Dot(dv1, vc.GetNormal());

        assert(abs(vn0 - vcp0.velocityBias) < k_errorTol);
        assert(abs(vn1 - vcp1.velocityBias) < k_errorTol);
#endif
        return Optional<Momentum>{max};
    }
    return Optional<Momentum>{};
}

Optional<Momentum> BlockSolveNormalCase2(VelocityConstraint& vc, const LinearVelocity2 b_prime)
{
    //
    // Case 2: vn1 = 0 and x2 = 0
    //
    //   0 = a11 * x1 + a12 * 0 + b1'
    // vn2 = a21 * x1 + a22 * 0 + b2'
    //
    const auto newImpulses = Momentum2{
        -GetNormalMassAtPoint(vc, 0) * get<0>(b_prime), 0_Ns
    };
    const auto K = vc.GetK();
    const auto vn2 = get<1>(get<0>(K)) * get<0>(newImpulses) + get<1>(b_prime);
    if ((get<0>(newImpulses) >= 0_Ns) && (vn2 >= 0_mps))
    {
        const auto max = BlockSolveUpdate(vc, newImpulses);

#if defined(B2_DEBUG_SOLVER)
        auto& vcp1 = vc.GetPointAt(0);
        const auto velA = vc.GetBodyA()->GetVelocity();
        const auto velB = vc.GetBodyB()->GetVelocity();

        // Postconditions
        const auto dv1 = GetContactRelVelocity(velA, vcp1.relA, velB, vcp1.relB);
        
        // Compute normal velocity
        const auto vn1 = Dot(dv1, vc.GetNormal());

        assert(abs(vn1 - vcp1.velocityBias) < k_errorTol);
#endif
        return Optional<Momentum>{max};
    }
    return Optional<Momentum>{};
}

Optional<Momentum> BlockSolveNormalCase3(VelocityConstraint& vc, const LinearVelocity2 b_prime)
{
    //
    // Case 3: vn2 = 0 and x1 = 0
    //
    // vn1 = a11 * 0 + a12 * x2 + b1'
    //   0 = a21 * 0 + a22 * x2 + b2'
    //
    const auto newImpulses = Momentum2{
        0_Ns, -GetNormalMassAtPoint(vc, 1) * get<1>(b_prime)
    };
    const auto K = vc.GetK();
    const auto vn1 = get<0>(get<1>(K)) * get<1>(newImpulses) + get<0>(b_prime);
    if ((get<1>(newImpulses) >= 0_Ns) && (vn1 >= 0_mps))
    {
        const auto max = BlockSolveUpdate(vc, newImpulses);

#if defined(B2_DEBUG_SOLVER)
        auto& vcp2 = vc.GetPointAt(1);
        const auto velA = vc.GetBodyA()->GetVelocity();
        const auto velB = vc.GetBodyB()->GetVelocity();

        // Postconditions
        const auto dv2 = GetContactRelVelocity(velA, vcp2.relA, velB, vcp2.relB);

        // Compute normal velocity
        const auto vn2 = Dot(dv2, vc.GetNormal());

        assert(abs(vn2 - vcp2.velocityBias) < k_errorTol);
#endif
        return Optional<Momentum>{max};
    }
    return Optional<Momentum>{};
}

Optional<Momentum> BlockSolveNormalCase4(VelocityConstraint& vc, const LinearVelocity2 b_prime)
{
    //
    // Case 4: x1 = 0 and x2 = 0
    //
    // vn1 = b1
    // vn2 = b2;
    const auto vn1 = get<0>(b_prime);
    const auto vn2 = get<1>(b_prime);
    if ((vn1 >= 0_mps) && (vn2 >= 0_mps))
    {
        return Optional<Momentum>{BlockSolveUpdate(vc, Momentum2{0_Ns, 0_Ns})};
    }
    return Optional<Momentum>{};
}

inline Momentum BlockSolveNormalConstraint(VelocityConstraint& vc)
{
    assert(vc.GetPointCount() == 2);

    // Block solver developed in collaboration with Dirk Gregorius (back in 01/07 on Box2D_Lite).
    // Build the mini LCP for this contact patch
    //
    // vn = A * x + b, vn >= 0, x >= 0 and vn_i * x_i = 0 with i = 1..2
    //
    // A = J * W * JT and J = ( -n, -r1 x n, n, r2 x n )
    // b = vn0 - velocityBias
    //
    // The system is solved using the "Total enumeration method" (s. Murty). The complementary constraint vn_i * x_i
    // implies that we must have in any solution either vn_i = 0 or x_i = 0. So for the 2-D contact problem the cases
    // vn1 = 0 and vn2 = 0, x1 = 0 and x2 = 0, x1 = 0 and vn2 = 0, x2 = 0 and vn1 = 0 need to be tested. The first valid
    // solution that satisfies the problem is chosen.
    //
    // In order to account of the accumulated impulse 'a' (because of the iterative nature of the solver which only requires
    // that the accumulated impulse is clamped and not the incremental impulse) we change the impulse variable (x_i).
    //
    // Substitute:
    //
    // x = a + d
    //
    // a := old total impulse
    // x := new total impulse
    // d := incremental impulse
    //
    // For the current iteration we extend the formula for the incremental impulse
    // to compute the new total impulse:
    //
    // vn = A * d + b
    //    = A * (x - a) + b
    //    = A * x + b - A * a
    //    = A * x + b'
    // b' = b - A * a;
    
    const auto b_prime = [=]() {
        const auto normal = vc.GetNormal();
        
        const auto velA = vc.GetBodyA()->GetVelocity();
        const auto velB = vc.GetBodyB()->GetVelocity();
        const auto ra0 = vc.GetPointRelPosA(0);
        const auto rb0 = vc.GetPointRelPosB(0);
        const auto ra1 = vc.GetPointRelPosA(1);
        const auto rb1 = vc.GetPointRelPosB(1);
        
        const auto dv0 = GetContactRelVelocity(velA, ra0, velB, rb0);
        const auto dv1 = GetContactRelVelocity(velA, ra1, velB, rb1);
        
        // Compute normal velocities
        const auto vn0 = Dot(dv0, normal);
        const auto vn1 = Dot(dv1, normal);
        
        // Compute b
        const auto b = LinearVelocity2{
            vn0 - vc.GetVelocityBiasAtPoint(0),
            vn1 - vc.GetVelocityBiasAtPoint(1)
        };
        
        // Return b'
        const auto K = vc.GetK();
        return b - Transform(GetNormalImpulses(vc), K);
    }();
    
    auto maxIncImpulse = Optional<Momentum>{};
    maxIncImpulse = BlockSolveNormalCase1(vc, b_prime);
    if (maxIncImpulse.has_value())
    {
        return *maxIncImpulse;
    }
    maxIncImpulse = BlockSolveNormalCase2(vc, b_prime);
    if (maxIncImpulse.has_value())
    {
        return *maxIncImpulse;
    }
    maxIncImpulse = BlockSolveNormalCase3(vc, b_prime);
    if (maxIncImpulse.has_value())
    {
        return *maxIncImpulse;
    }
    maxIncImpulse = BlockSolveNormalCase4(vc, b_prime);
    if (maxIncImpulse.has_value())
    {
        return *maxIncImpulse;
    }
    
    // No solution, give up. This is hit sometimes, but it doesn't seem to matter.
    return 0;
}

inline Momentum SeqSolveNormalConstraint(VelocityConstraint& vc)
{
    auto maxIncImpulse = 0_Ns;
    
    const auto direction = vc.GetNormal();
    const auto count = vc.GetPointCount();
    const auto bodyA = vc.GetBodyA();
    const auto bodyB = vc.GetBodyB();
    
    const auto invRotInertiaA = bodyA->GetInvRotInertia();
    const auto invMassA = bodyA->GetInvMass();
    const auto oldVelA = bodyA->GetVelocity();
    
    const auto invRotInertiaB = bodyB->GetInvRotInertia();
    const auto invMassB = bodyB->GetInvMass();
    const auto oldVelB = bodyB->GetVelocity();
    
    auto newVelA = oldVelA;
    auto newVelB = oldVelB;
    
    auto solverProc = [&](VelocityConstraint::size_type index) {
        const auto vcp = vc.GetPointAt(index);
        const auto closingVel = GetContactRelVelocity(newVelA, vcp.relA, newVelB, vcp.relB);
        const auto directionalVel = LinearVelocity{Dot(closingVel, direction)};
        const auto lambda = Momentum{vcp.normalMass * (vcp.velocityBias - directionalVel)};
        const auto oldImpulse = vcp.normalImpulse;
        const auto newImpulse = std::max(oldImpulse + lambda, 0_Ns);
#if 0
        // Note: using AlmostEqual here results in increased iteration counts and is slower.
        const auto incImpulse = AlmostEqual(newImpulse, oldImpulse)? 0_Ns: newImpulse - oldImpulse;
#else
        const auto incImpulse = newImpulse - oldImpulse;
#endif
        const auto P = incImpulse * direction;
        const auto LA = AngularMomentum{Cross(vcp.relA, P) / Radian};
        const auto LB = AngularMomentum{Cross(vcp.relB, P) / Radian};
        newVelA -= Velocity{invMassA * P, invRotInertiaA * LA};
        newVelB += Velocity{invMassB * P, invRotInertiaB * LB};
        maxIncImpulse = std::max(maxIncImpulse, abs(incImpulse));

        // Note: using newImpulse, instead of oldImpulse + incImpulse, results in
        //   iteration count increases for the World.TilesComesToRest unit test.
        vc.SetNormalImpulseAtPoint(index, oldImpulse + incImpulse);
    };

    if (count == 2)
    {
        solverProc(1);
    }
    solverProc(0);
    
    bodyA->SetVelocity(newVelA);
    bodyB->SetVelocity(newVelB);
    
    return maxIncImpulse;
}

inline Momentum SolveTangentConstraint(VelocityConstraint& vc)
{
    auto maxIncImpulse = 0_Ns;
    
    const auto direction = vc.GetTangent();
    const auto friction = vc.GetFriction();
    const auto tangentSpeed = vc.GetTangentSpeed();
    const auto count = vc.GetPointCount();
    const auto bodyA = vc.GetBodyA();
    const auto bodyB = vc.GetBodyB();
    
    const auto invRotInertiaA = bodyA->GetInvRotInertia();
    const auto invMassA = bodyA->GetInvMass();
    const auto oldVelA = bodyA->GetVelocity();
    
    const auto invRotInertiaB = bodyB->GetInvRotInertia();
    const auto invMassB = bodyB->GetInvMass();
    const auto oldVelB = bodyB->GetVelocity();
    
    auto newVelA = oldVelA;
    auto newVelB = oldVelB;
    
    auto solverProc = [&](VelocityConstraint::size_type index) {
        const auto vcp = vc.GetPointAt(index);
        const auto closingVel = GetContactRelVelocity(newVelA, vcp.relA, newVelB, vcp.relB);
        const auto directionalVel = LinearVelocity{tangentSpeed - Dot(closingVel, direction)};
        const auto lambda = vcp.tangentMass * directionalVel;
        const auto maxImpulse = friction * vcp.normalImpulse;
        const auto oldImpulse = vcp.tangentImpulse;
        const auto newImpulse = std::clamp(oldImpulse + lambda, -maxImpulse, maxImpulse);
#if 0
        // Note: using AlmostEqual here results in increased iteration counts and is slower.
        const auto incImpulse = AlmostEqual(newImpulse, oldImpulse)? 0_Ns: newImpulse - oldImpulse;
#else
        const auto incImpulse = newImpulse - oldImpulse;
#endif
        const auto P = incImpulse * direction;
        const auto LA = AngularMomentum{Cross(vcp.relA, P) / Radian};
        const auto LB = AngularMomentum{Cross(vcp.relB, P) / Radian};
        newVelA -= Velocity{invMassA * P, invRotInertiaA * LA};
        newVelB += Velocity{invMassB * P, invRotInertiaB * LB};
        maxIncImpulse = std::max(maxIncImpulse, abs(incImpulse));
        
        // Note: using newImpulse, instead of oldImpulse + incImpulse, results in
        //   iteration count increases for the World.TilesComesToRest unit test.
        vc.SetTangentImpulseAtPoint(index, oldImpulse + incImpulse);
    };
    assert((count == 1) || (count == 2));
    if (count == 2)
    {
        solverProc(1);
    }
    solverProc(0);

    bodyA->SetVelocity(newVelA);
    bodyB->SetVelocity(newVelB);
    
    return maxIncImpulse;
}

inline Momentum SolveNormalConstraint(VelocityConstraint& vc)
{
#if 1
    // Note: Block solving reduces World.TilesComesToRest iteration counts and is faster.
    //   This is because the block solver provides more stable solutions per iteration.
    //   The difference is especially pronounced in the Vertical Stack Testbed demo.
    const auto count = vc.GetPointCount();
    assert((count == 1) || (count == 2));
    if ((count == 1) || (vc.GetK() == InvMass22{}))
    {
        return SeqSolveNormalConstraint(vc);
    }
    return BlockSolveNormalConstraint(vc);
#else
    return SeqSolveNormalConstraint(vc);
#endif
}

}; // anonymous namespace
    
} // namespace d2

ConstraintSolverConf GetRegConstraintSolverConf(const StepConf& conf) noexcept
{
    return ConstraintSolverConf{}
        .UseResolutionRate(conf.regResolutionRate)
        .UseLinearSlop(conf.linearSlop)
        .UseAngularSlop(conf.angularSlop)
        .UseMaxLinearCorrection(conf.maxLinearCorrection)
        .UseMaxAngularCorrection(conf.maxAngularCorrection);
}

ConstraintSolverConf GetToiConstraintSolverConf(const StepConf& conf) noexcept
{
    return ConstraintSolverConf{}
        .UseResolutionRate(conf.toiResolutionRate)
        .UseLinearSlop(conf.linearSlop)
        .UseAngularSlop(conf.angularSlop)
        .UseMaxLinearCorrection(conf.maxLinearCorrection)
        .UseMaxAngularCorrection(conf.maxAngularCorrection);
}

namespace GaussSeidel {

Momentum SolveVelocityConstraint(d2::VelocityConstraint& vc)
{
    auto maxIncImpulse = 0_Ns;
    
    // Applies frictional changes to velocity.
    maxIncImpulse = std::max(maxIncImpulse, d2::SolveTangentConstraint(vc));
    
    // Applies restitutional changes to velocity.
    maxIncImpulse = std::max(maxIncImpulse, d2::SolveNormalConstraint(vc));
    
    return maxIncImpulse;
}

d2::PositionSolution SolvePositionConstraint(const d2::PositionConstraint& pc,
                                           const bool moveA, const bool moveB,
                                           ConstraintSolverConf conf)
{
    assert(IsValid(conf.resolutionRate));
    assert(IsValid(conf.linearSlop));
    assert(IsValid(conf.maxLinearCorrection));
    
    const auto bodyA = pc.GetBodyA();
    const auto bodyB = pc.GetBodyB();
    
    const auto invMassA = moveA? bodyA->GetInvMass(): InvMass{0};
    const auto invRotInertiaA = moveA? bodyA->GetInvRotInertia(): InvRotInertia{0};
    const auto localCenterA = bodyA->GetLocalCenter();
    
    const auto invMassB = moveB? bodyB->GetInvMass(): InvMass{0};
    const auto invRotInertiaB = moveB? bodyB->GetInvRotInertia(): InvRotInertia{0};
    const auto localCenterB = bodyB->GetLocalCenter();
    
    // Compute inverse mass total.
    // This must be > 0 unless doing TOI solving and neither bodies were the bodies specified.
    const auto invMassTotal = invMassA + invMassB;
    assert(invMassTotal >= InvMass{0});
    
    const auto totalRadius = pc.GetRadiusA() + pc.GetRadiusB();
    
    const auto solver_fn = [&](const d2::PositionSolverManifold psm,
                               const Length2 pA, const Length2 pB) {
        const auto separation = psm.m_separation - totalRadius;
        // Positive separation means shapes not overlapping and not touching.
        // Zero separation means shapes are touching.
        // Negative separation means shapes are overlapping.
        
        const auto rA = Length2{psm.m_point - pA};
        const auto rB = Length2{psm.m_point - pB};
        
        // Compute the effective mass.
        const auto K = InvMass{[&]() {
            const auto rnA = Length{Cross(rA, psm.m_normal)} / Radian;
            const auto rnB = Length{Cross(rB, psm.m_normal)} / Radian;
            // InvRotInertia is L^-2 M^-1 QP^2
            // L^-2 M^-1 QP^2 * L^2 is: M^-1 QP^2
            const auto invRotMassA = InvMass{invRotInertiaA * Square(rnA)};
            const auto invRotMassB = InvMass{invRotInertiaB * Square(rnB)};
            return invMassTotal + invRotMassA + invRotMassB;
        }()};
        
        assert(K >= InvMass{0});
        
        // Prevent large corrections & don't push separation above -conf.linearSlop.
        const auto C = -std::clamp(conf.resolutionRate * (separation + conf.linearSlop),
                                   -conf.maxLinearCorrection, 0_m);
        
        // Compute response factors...
        const auto P = Length2{psm.m_normal * C} / K; // L M
        const auto LA = Cross(rA, P) / Radian; // L^2 M QP^-1
        const auto LB = Cross(rB, P) / Radian; // L^2 M QP^-1
        
        // InvMass is M^-1, and InvRotInertia is L^-2 M^-1 QP^2.
        // Product of InvMass * P is: L
        // Product of InvRotInertia * L{A,B} is: QP
        return d2::PositionSolution{
            -d2::Position{invMassA * P, invRotInertiaA * LA},
            +d2::Position{invMassB * P, invRotInertiaB * LB},
            separation
        };
    };
    
    auto posA = bodyA->GetPosition();
    auto posB = bodyB->GetPosition();
    
    // Solve normal constraints
    const auto pointCount = pc.manifold.GetPointCount();
    switch (pointCount)
    {
        case 1:
        {
            const auto psm0 = GetPSM(pc.manifold, 0,
                                     GetTransformation(posA, localCenterA),
                                     GetTransformation(posB, localCenterB));
            return d2::PositionSolution{posA, posB, 0} + solver_fn(psm0, posA.linear, posB.linear);
        }
        case 2:
        {
#if 0
            const auto psm0 = GetPSM(pc.manifold, 0,
                                     GetTransformation(posA, localCenterA),
                                     GetTransformation(posB, localCenterB));
            const auto s0 = solver_fn(psm0, posA.linear, posB.linear);
            posA += s0.pos_a;
            posB += s0.pos_b;
            
            const auto psm1 = GetPSM(pc.manifold, 1,
                                     GetTransformation(posA, localCenterA),
                                     GetTransformation(posB, localCenterB));
            const auto s1 = solver_fn(psm1, posA.linear, posB.linear);
            posA += s1.pos_a;
            posB += s1.pos_b;
            
            return PositionSolution{posA, posB, std::min(s0.min_separation, s1.min_separation)};
#else
            const auto xfA = GetTransformation(posA, localCenterA);
            const auto xfB = GetTransformation(posB, localCenterB);
            
            // solve most penatrating point first or solve simultaneously if about the same penetration
            const auto psm0 = GetPSM(pc.manifold, 0, xfA, xfB);
            const auto psm1 = GetPSM(pc.manifold, 1, xfA, xfB);
            
            assert(IsValid(psm0.m_separation) && IsValid(psm1.m_separation));
            
            if (AlmostEqual(StripUnit(psm0.m_separation), StripUnit(psm1.m_separation)))
            {
                const auto s0 = solver_fn(psm0, posA.linear, posB.linear);
                const auto s1 = solver_fn(psm1, posA.linear, posB.linear);
                //assert(s0.pos_a.angular == -s1.pos_a.angular);
                //assert(s0.pos_b.angular == -s1.pos_b.angular);
                return d2::PositionSolution{
                    posA + s0.pos_a + s1.pos_a,
                    posB + s0.pos_b + s1.pos_b,
                    s0.min_separation
                };
            }
            if (psm0.m_separation < psm1.m_separation)
            {
                const auto s0 = solver_fn(psm0, posA.linear, posB.linear);
                posA += s0.pos_a;
                posB += s0.pos_b;
                const auto psm1_prime = GetPSM(pc.manifold, 1,
                                               GetTransformation(posA, localCenterA),
                                               GetTransformation(posB, localCenterB));
                const auto s1 = solver_fn(psm1_prime, posA.linear, posB.linear);
                posA += s1.pos_a;
                posB += s1.pos_b;
                return d2::PositionSolution{posA, posB, s0.min_separation};
            }
            if (psm1.m_separation < psm0.m_separation)
            {
                const auto s1 = solver_fn(psm1, posA.linear, posB.linear);
                posA += s1.pos_a;
                posB += s1.pos_b;
                const auto psm0_prime = GetPSM(pc.manifold, 0,
                                               GetTransformation(posA, localCenterA),
                                               GetTransformation(posB, localCenterB));
                const auto s0 = solver_fn(psm0_prime, posA.linear, posB.linear);
                posA += s0.pos_a;
                posB += s0.pos_b;
                return d2::PositionSolution{posA, posB, s1.min_separation};
            }
#endif
            // reaches here if one or both psm separation values was NaN (and NDEBUG is defined).
        }
        default: break;
    }
    return d2::PositionSolution{posA, posB, std::numeric_limits<Length>::infinity()};
}

} // namespace GaussSeidel

} // namespace playrho
