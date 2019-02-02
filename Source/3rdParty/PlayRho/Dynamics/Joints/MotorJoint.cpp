/*
 * Original work Copyright (c) 2006-2012 Erin Catto http://www.box2d.org
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

#include "PlayRho/Dynamics/Joints/MotorJoint.hpp"
#include "PlayRho/Dynamics/Joints/JointVisitor.hpp"
#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/Contacts/BodyConstraint.hpp"

namespace playrho {
namespace d2 {

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

MotorJoint::MotorJoint(const MotorJointConf& def):
    Joint(def),
    m_linearOffset(def.linearOffset),
    m_angularOffset(def.angularOffset),
    m_maxForce(def.maxForce),
    m_maxTorque(def.maxTorque),
    m_correctionFactor(def.correctionFactor)
{
    // Intentionally empty.
}

void MotorJoint::Accept(JointVisitor& visitor) const
{
    visitor.Visit(*this);
}

void MotorJoint::Accept(JointVisitor& visitor)
{
    visitor.Visit(*this);
}

void MotorJoint::InitVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step, const ConstraintSolverConf&)
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    const auto posA = bodyConstraintA->GetPosition();
    auto velA = bodyConstraintA->GetVelocity();

    const auto posB = bodyConstraintB->GetPosition();
    auto velB = bodyConstraintB->GetVelocity();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    // Compute the effective mass matrix.
    m_rA = Rotate(m_linearOffset - bodyConstraintA->GetLocalCenter(), qA);
    m_rB = Rotate(-bodyConstraintB->GetLocalCenter(), qB);

    // J = [-I -r1_skew I r2_skew]
    // r_skew = [-ry; rx]

    // Matlab
    // K = [ mA+r1y^2*iA+mB+r2y^2*iB,  -r1y*iA*r1x-r2y*iB*r2x,          -r1y*iA-r2y*iB]
    //     [  -r1y*iA*r1x-r2y*iB*r2x, mA+r1x^2*iA+mB+r2x^2*iB,           r1x*iA+r2x*iB]
    //     [          -r1y*iA-r2y*iB,           r1x*iA+r2x*iB,                   iA+iB]

    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();

    {
        const auto exx = InvMass{
            invMassA + invMassB +
            invRotInertiaA * Square(GetY(m_rA)) / SquareRadian +
            invRotInertiaB * Square(GetY(m_rB)) / SquareRadian
        };
        const auto exy = InvMass{
            -invRotInertiaA * GetX(m_rA) * GetY(m_rA) / SquareRadian +
            -invRotInertiaB * GetX(m_rB) * GetY(m_rB) / SquareRadian
        };
        const auto eyy = InvMass{
            invMassA + invMassB +
            invRotInertiaA * Square(GetX(m_rA)) / SquareRadian +
            invRotInertiaB * Square(GetX(m_rB)) / SquareRadian
        };
        // Upper 2 by 2 of K above for point to point
        const auto k22 = InvMass22{Vector<InvMass, 2>{exx, exy}, Vector<InvMass, 2>{exy, eyy}};
        m_linearMass = Invert(k22);
    }
    
    const auto invRotInertia = invRotInertiaA + invRotInertiaB;
    m_angularMass = (invRotInertia > InvRotInertia{0})? RotInertia{Real{1} / invRotInertia}: RotInertia{0};
    
    m_linearError = (posB.linear + m_rB) - (posA.linear + m_rA);
    m_angularError = (posB.angular - posA.angular) - m_angularOffset;

    if (step.doWarmStart)
    {
        // Scale impulses to support a variable time step.
        m_linearImpulse *= step.dtRatio;
        m_angularImpulse *= step.dtRatio;

        const auto P = m_linearImpulse;
        // L * M * L T^-1 / QP is: L^2 M T^-1 QP^-1 which is: AngularMomentum.
        const auto crossAP = AngularMomentum{Cross(m_rA, P) / Radian};
        const auto crossBP = AngularMomentum{Cross(m_rB, P) / Radian}; // L * M * L T^-1 is: L^2 M T^-1

        velA -= Velocity{invMassA * P, invRotInertiaA * (crossAP + m_angularImpulse)};
        velB += Velocity{invMassB * P, invRotInertiaB * (crossBP + m_angularImpulse)};
    }
    else
    {
        m_linearImpulse = Momentum2{};
        m_angularImpulse = AngularMomentum{0};
    }

    bodyConstraintA->SetVelocity(velA);
    bodyConstraintB->SetVelocity(velB);
}

bool MotorJoint::SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step)
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    auto velA = bodyConstraintA->GetVelocity();
    auto velB = bodyConstraintB->GetVelocity();

    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();

    const auto h = step.GetTime();
    const auto inv_h = step.GetInvTime();

    auto solved = true;

    // Solve angular friction
    {
        const auto Cdot = AngularVelocity{(velB.angular - velA.angular) + inv_h * m_correctionFactor * m_angularError};
        const auto angularImpulse = AngularMomentum{-m_angularMass * Cdot};

        const auto oldAngularImpulse = m_angularImpulse;
        const auto maxAngularImpulse = h * m_maxTorque;
        const auto newAngularImpulse = std::clamp(oldAngularImpulse + angularImpulse,
                                                  -maxAngularImpulse, maxAngularImpulse);
        m_angularImpulse = newAngularImpulse;
        const auto incAngularImpulse = newAngularImpulse - oldAngularImpulse;

        if (incAngularImpulse != AngularMomentum{0})
        {
            solved = false;
        }
        velA.angular -= invRotInertiaA * incAngularImpulse;
        velB.angular += invRotInertiaB * incAngularImpulse;
    }

    // Solve linear friction
    {
        const auto vb = LinearVelocity2{velB.linear + (GetRevPerpendicular(m_rB) * (velB.angular / Radian))};
        const auto va = LinearVelocity2{velA.linear + (GetRevPerpendicular(m_rA) * (velA.angular / Radian))};
        const auto Cdot = LinearVelocity2{(vb - va) + inv_h * m_correctionFactor * m_linearError};

        const auto impulse = -Transform(Cdot, m_linearMass);
        const auto oldImpulse = m_linearImpulse;
        m_linearImpulse += impulse;

        const auto maxImpulse = h * m_maxForce;

        if (GetMagnitudeSquared(m_linearImpulse) > Square(maxImpulse))
        {
            m_linearImpulse = GetUnitVector(m_linearImpulse, UnitVec::GetZero()) * maxImpulse;
        }

        const auto incImpulse = m_linearImpulse - oldImpulse;
        const auto angImpulseA = AngularMomentum{Cross(m_rA, incImpulse) / Radian};
        const auto angImpulseB = AngularMomentum{Cross(m_rB, incImpulse) / Radian};

        if (incImpulse != Momentum2{})
        {
            solved = false;
        }

        velA -= Velocity{invMassA * incImpulse, invRotInertiaA * angImpulseA};
        velB += Velocity{invMassB * incImpulse, invRotInertiaB * angImpulseB};
    }

    bodyConstraintA->SetVelocity(velA);
    bodyConstraintB->SetVelocity(velB);
    
    return solved;
}

bool MotorJoint::SolvePositionConstraints(BodyConstraintsMap&, const ConstraintSolverConf&) const
{
    return true;
}

Length2 MotorJoint::GetAnchorA() const
{
    return GetBodyA()->GetLocation();
}

Length2 MotorJoint::GetAnchorB() const
{
    return GetBodyB()->GetLocation();
}

void MotorJoint::SetCorrectionFactor(Real factor)
{
    assert(IsValid(factor) && (0 <= factor) && (factor <= Real{1}));
    m_correctionFactor = factor;
}

void MotorJoint::SetLinearOffset(const Length2 linearOffset)
{
    if (m_linearOffset != linearOffset)
    {
        m_linearOffset = linearOffset;
        GetBodyA()->SetAwake();
        GetBodyB()->SetAwake();
    }
}

void MotorJoint::SetAngularOffset(Angle angularOffset)
{
    if (angularOffset != m_angularOffset)
    {
        m_angularOffset = angularOffset;
        GetBodyA()->SetAwake();
        GetBodyB()->SetAwake();
    }
}

} // namespace d2
} // namespace playrho
