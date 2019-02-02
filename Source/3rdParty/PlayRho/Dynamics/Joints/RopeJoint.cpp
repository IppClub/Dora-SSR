/*
 * Original work Copyright (c) 2007-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Dynamics/Joints/RopeJoint.hpp"
#include "PlayRho/Dynamics/Joints/JointVisitor.hpp"
#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/Contacts/ContactSolver.hpp"
#include "PlayRho/Dynamics/Contacts/BodyConstraint.hpp"

#include <algorithm>

namespace playrho {
namespace d2 {

// Limit:
// C = norm(pB - pA) - L
// u = (pB - pA) / norm(pB - pA)
// Cdot = dot(u, vB + cross(wB, rB) - vA - cross(wA, rA))
// J = [-u -cross(rA, u) u cross(rB, u)]
// K = J * invM * JT
//   = invMassA + invIA * cross(rA, u)^2 + invMassB + invIB * cross(rB, u)^2

RopeJoint::RopeJoint(const RopeJointConf& def):
    Joint{def},
    m_localAnchorA{def.localAnchorA},
    m_localAnchorB{def.localAnchorB},
    m_maxLength{def.maxLength}
{
}

void RopeJoint::Accept(JointVisitor& visitor) const
{
    visitor.Visit(*this);
}

void RopeJoint::Accept(JointVisitor& visitor)
{
    visitor.Visit(*this);
}

void RopeJoint::InitVelocityConstraints(BodyConstraintsMap& bodies,
                                        const StepConf& step,
                                        const ConstraintSolverConf& conf)
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();
    const auto posA = bodyConstraintA->GetPosition();
    auto velA = bodyConstraintA->GetVelocity();

    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();
    const auto posB = bodyConstraintB->GetPosition();
    auto velB = bodyConstraintB->GetVelocity();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    m_rA = Rotate(m_localAnchorA - bodyConstraintA->GetLocalCenter(), qA);
    m_rB = Rotate(m_localAnchorB - bodyConstraintB->GetLocalCenter(), qB);
    const auto posDelta = Length2{(posB.linear + m_rB) - (posA.linear + m_rA)};
    
    const auto uvresult = UnitVec::Get(posDelta[0], posDelta[1]);
    const auto uv = std::get<UnitVec>(uvresult);
    m_length = std::get<Length>(uvresult);

    const auto C = m_length - m_maxLength;
    m_state = (C > 0_m)? e_atUpperLimit: e_inactiveLimit;

    if (m_length > conf.linearSlop)
    {
        m_u = uv;
    }
    else
    {
        m_u = UnitVec::GetZero();
        m_mass = 0_kg;
        m_impulse = 0;
        return;
    }

    // Compute effective mass.
    const auto crA = Cross(m_rA, m_u);
    const auto crB = Cross(m_rB, m_u);
    const auto invRotMassA = InvMass{invRotInertiaA * Square(crA) / SquareRadian};
    const auto invRotMassB = InvMass{invRotInertiaB * Square(crB) / SquareRadian};
    const auto invMass = invMassA + invMassB + invRotMassA + invRotMassB;

    m_mass = (invMass != InvMass{0}) ? Real{1} / invMass : 0_kg;

    if (step.doWarmStart)
    {
        // Scale the impulse to support a variable time step.
        m_impulse *= step.dtRatio;

        const auto P = m_impulse * m_u;
        
        // L * M * L T^-1 / QP is: L^2 M T^-1 QP^-1 which is: AngularMomentum.
        const auto crossAP = AngularMomentum{Cross(m_rA, P) / Radian};
        const auto crossBP = AngularMomentum{Cross(m_rB, P) / Radian}; // L * M * L T^-1 is: L^2 M T^-1

        velA -= Velocity{bodyConstraintA->GetInvMass() * P, invRotInertiaA * crossAP};
        velB += Velocity{bodyConstraintB->GetInvMass() * P, invRotInertiaB * crossBP};
    }
    else
    {
        m_impulse = 0;
    }

    bodyConstraintA->SetVelocity(velA);
    bodyConstraintB->SetVelocity(velB);
}

bool RopeJoint::SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step)
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    auto velA = bodyConstraintA->GetVelocity();
    auto velB = bodyConstraintB->GetVelocity();

    // Cdot = dot(u, v + cross(w, r))
    const auto vpA = velA.linear + GetRevPerpendicular(m_rA) * (velA.angular / Radian);
    const auto vpB = velB.linear + GetRevPerpendicular(m_rB) * (velB.angular / Radian);
    const auto C = m_length - m_maxLength;
    const auto vpDelta = LinearVelocity2{vpB - vpA};

    // Predictive constraint.
    const auto Cdot = LinearVelocity{Dot(m_u, vpDelta)}
                    + ((C < 0_m)? LinearVelocity{step.GetInvTime() * C}: 0_mps);

    auto impulse = -m_mass * Cdot;
    const auto oldImpulse = m_impulse;
    m_impulse = std::min(0_Ns, m_impulse + impulse);
    impulse = m_impulse - oldImpulse;

    const auto P = impulse * m_u;
    
    // L * M * L T^-1 / QP is: L^2 M T^-1 QP^-1 which is: AngularMomentum.
    const auto crossAP = AngularMomentum{Cross(m_rA, P) / Radian};
    const auto crossBP = AngularMomentum{Cross(m_rB, P) / Radian}; // L * M * L T^-1 is: L^2 M T^-1

    velA -= Velocity{bodyConstraintA->GetInvMass() * P, bodyConstraintA->GetInvRotInertia() * crossAP};
    velB += Velocity{bodyConstraintB->GetInvMass() * P, bodyConstraintB->GetInvRotInertia() * crossBP};

    bodyConstraintA->SetVelocity(velA);
    bodyConstraintB->SetVelocity(velB);
    
    return impulse == 0_Ns;
}

bool RopeJoint::SolvePositionConstraints(BodyConstraintsMap& bodies, const ConstraintSolverConf& conf) const
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    auto posA = bodyConstraintA->GetPosition();
    auto posB = bodyConstraintB->GetPosition();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    const auto rA = Length2{Rotate(m_localAnchorA - bodyConstraintA->GetLocalCenter(), qA)};
    const auto rB = Length2{Rotate(m_localAnchorB - bodyConstraintB->GetLocalCenter(), qB)};
    const auto posDelta = (posB.linear + rB) - (posA.linear + rA);
    
    const auto uvresult = UnitVec::Get(posDelta[0], posDelta[1]);
    const auto u = std::get<UnitVec>(uvresult);
    const auto length = std::get<Length>(uvresult);
    
    const auto C = std::clamp(length - m_maxLength, 0_m, conf.maxLinearCorrection);

    const auto impulse = -m_mass * C;
    const auto linImpulse = impulse * u;
    
    const auto angImpulseA = Cross(rA, linImpulse) / Radian;
    const auto angImpulseB = Cross(rB, linImpulse) / Radian;

    posA -= Position{bodyConstraintA->GetInvMass() * linImpulse, bodyConstraintA->GetInvRotInertia() * angImpulseA};
    posB += Position{bodyConstraintB->GetInvMass() * linImpulse, bodyConstraintB->GetInvRotInertia() * angImpulseB};

    bodyConstraintA->SetPosition(posA);
    bodyConstraintB->SetPosition(posB);

    return (length - m_maxLength) < conf.linearSlop;
}

Length2 RopeJoint::GetAnchorA() const
{
    return GetWorldPoint(*GetBodyA(), GetLocalAnchorA());
}

Length2 RopeJoint::GetAnchorB() const
{
    return GetWorldPoint(*GetBodyB(), GetLocalAnchorB());
}

Momentum2 RopeJoint::GetLinearReaction() const
{
    return m_impulse * m_u;
}

AngularMomentum RopeJoint::GetAngularReaction() const
{
    return AngularMomentum{0};
}

Length RopeJoint::GetMaxLength() const
{
    return m_maxLength;
}

Joint::LimitState RopeJoint::GetLimitState() const
{
    return m_state;
}

} // namespace d2
} // namespace playrho
