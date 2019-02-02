/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
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

#include "PlayRho/Dynamics/Joints/WheelJoint.hpp"
#include "PlayRho/Dynamics/Joints/JointVisitor.hpp"
#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/Contacts/ContactSolver.hpp"
#include "PlayRho/Dynamics/Contacts/BodyConstraint.hpp"

namespace playrho {
namespace d2 {

// Linear constraint (point-to-line)
// d = pB - pA = xB + rB - xA - rA
// C = dot(ay, d)
// Cdot = dot(d, cross(wA, ay)) + dot(ay, vB + cross(wB, rB) - vA - cross(wA, rA))
//      = -dot(ay, vA) - dot(cross(d + rA, ay), wA) + dot(ay, vB) + dot(cross(rB, ay), vB)
// J = [-ay, -cross(d + rA, ay), ay, cross(rB, ay)]

// Spring linear constraint
// C = dot(ax, d)
// Cdot = = -dot(ax, vA) - dot(cross(d + rA, ax), wA) + dot(ax, vB) + dot(cross(rB, ax), vB)
// J = [-ax -cross(d+rA, ax) ax cross(rB, ax)]

// Motor rotational constraint
// Cdot = wB - wA
// J = [0 0 -1 0 0 1]

WheelJoint::WheelJoint(const WheelJointConf& def):
    Joint(def),
    m_localAnchorA(def.localAnchorA),
    m_localAnchorB(def.localAnchorB),
    m_localXAxisA(def.localAxisA),
    m_localYAxisA(GetRevPerpendicular(m_localXAxisA)),
    m_frequency(def.frequency),
    m_dampingRatio(def.dampingRatio),
    m_maxMotorTorque(def.maxMotorTorque),
    m_motorSpeed(def.motorSpeed),
    m_enableMotor(def.enableMotor)
{
    // Intentionally empty.
}

void WheelJoint::Accept(JointVisitor& visitor) const
{
    visitor.Visit(*this);
}

void WheelJoint::Accept(JointVisitor& visitor)
{
    visitor.Visit(*this);
}

void WheelJoint::InitVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step, const ConstraintSolverConf&)
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    const auto posA = bodyConstraintA->GetPosition();
    auto velA = bodyConstraintA->GetVelocity();
    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();

    const auto posB = bodyConstraintB->GetPosition();
    auto velB = bodyConstraintB->GetVelocity();
    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    // Compute the effective masses.
    const auto rA = Length2{Rotate(m_localAnchorA - bodyConstraintA->GetLocalCenter(), qA)};
    const auto rB = Length2{Rotate(m_localAnchorB - bodyConstraintB->GetLocalCenter(), qB)};
    const auto dd = Length2{(posB.linear + rB) - (posA.linear + rA)};

    // Point to line constraint
    {
        m_ay = Rotate(m_localYAxisA, qA);
        m_sAy = Cross(dd + rA, m_ay);
        m_sBy = Cross(rB, m_ay);

        const auto invRotMassA = invRotInertiaA * Square(m_sAy) / SquareRadian;
        const auto invRotMassB = invRotInertiaB * Square(m_sBy) / SquareRadian;
        const auto invMass = invMassA + invMassB + invRotMassA + invRotMassB;

        m_mass = (invMass > InvMass{0})? Real{1} / invMass: 0;
    }

    // Spring constraint
    m_springMass = 0_kg;
    m_bias = 0;
    m_gamma = 0;
    if (m_frequency > 0_Hz)
    {
        m_ax = Rotate(m_localXAxisA, qA);
        m_sAx = Cross(dd + rA, m_ax);
        m_sBx = Cross(rB, m_ax);

        const auto invRotMassA = invRotInertiaA * Square(m_sAx) / SquareRadian;
        const auto invRotMassB = invRotInertiaB * Square(m_sBx) / SquareRadian;
        const auto invMass = invMassA + invMassB + invRotMassA + invRotMassB;

        if (invMass > InvMass{0})
        {
            m_springMass = Real{1} / invMass;

            const auto C = Length{Dot(dd, m_ax)};

            // Frequency
            const auto omega = Real{2} * Pi * m_frequency;

            // Damping coefficient
            const auto d = Real{2} * m_springMass * m_dampingRatio * omega;

            // Spring stiffness
            const auto k = m_springMass * omega * omega;

            // magic formulas
            const auto h = step.GetTime();
            
            const auto invGamma = Mass{h * (d + h * k)};
            m_gamma = (invGamma > 0_kg)? Real{1} / invGamma: 0;
            m_bias = LinearVelocity{C * h * k * m_gamma};

            const auto totalInvMass = invMass + m_gamma;
            m_springMass = (totalInvMass > InvMass{0})? Real{1} / totalInvMass: 0_kg;
        }
    }
    else
    {
        m_springImpulse = 0;

        m_ax = UnitVec::GetZero();
        m_sAx = 0_m;
        m_sBx = 0_m;
    }

    // Rotational motor
    if (m_enableMotor)
    {
        const auto invRotInertia = invRotInertiaA + invRotInertiaB;
        m_motorMass = (invRotInertia > InvRotInertia{0})? Real{1} / invRotInertia: RotInertia{0};
    }
    else
    {
        m_motorMass = RotInertia{0};
        m_motorImpulse = 0;
    }

    if (step.doWarmStart)
    {
        // Account for variable time step.
        m_impulse *= step.dtRatio;
        m_springImpulse *= step.dtRatio;
        m_motorImpulse *= step.dtRatio;

        const auto P = m_impulse * m_ay + m_springImpulse * m_ax;
        
        // Momentum is M L T^-1. Length * momentum is L^2 M T^-1
        // Angular momentum is L^2 M T^-1 QP^-1
        const auto LA = AngularMomentum{(m_impulse * m_sAy + m_springImpulse * m_sAx) / Radian + m_motorImpulse};
        const auto LB = AngularMomentum{(m_impulse * m_sBy + m_springImpulse * m_sBx) / Radian + m_motorImpulse};

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else
    {
        m_impulse = 0;
        m_springImpulse = 0;
        m_motorImpulse = 0;
    }

    bodyConstraintA->SetVelocity(velA);
    bodyConstraintB->SetVelocity(velB);
}

bool WheelJoint::SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step)
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    const auto oldVelA = bodyConstraintA->GetVelocity();
    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();

    const auto oldVelB = bodyConstraintB->GetVelocity();
    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();

    auto velA = oldVelA;
    auto velB = oldVelB;

    // Solve spring constraint
    {
        const auto dot = LinearVelocity{Dot(m_ax, velB.linear - velA.linear)};
        const auto Cdot = dot + m_sBx * velB.angular / Radian - m_sAx * velA.angular / Radian;
        const auto impulse = -m_springMass * (Cdot + m_bias + m_gamma * m_springImpulse);
        m_springImpulse += impulse;

        const auto P = impulse * m_ax;
        const auto LA = AngularMomentum{impulse * m_sAx / Radian};
        const auto LB = AngularMomentum{impulse * m_sBx / Radian};

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }

    // Solve rotational motor constraint
    {
        const auto Cdot = (velB.angular - velA.angular - m_motorSpeed);
        auto impulse = AngularMomentum{-m_motorMass * Cdot};

        const auto oldImpulse = m_motorImpulse;
        const auto maxImpulse = AngularMomentum{step.GetTime() * m_maxMotorTorque};
        m_motorImpulse = std::clamp(m_motorImpulse + impulse, -maxImpulse, maxImpulse);
        impulse = m_motorImpulse - oldImpulse;

        velA.angular -= AngularVelocity{invRotInertiaA * impulse};
        velB.angular += AngularVelocity{invRotInertiaB * impulse};
    }

    // Solve point to line constraint
    {
        const auto dot = LinearVelocity{Dot(m_ay, velB.linear - velA.linear)};
        const auto Cdot = dot + m_sBy * velB.angular / Radian - m_sAy * velA.angular / Radian;
        const auto impulse = -m_mass * Cdot;
        m_impulse += impulse;

        const auto P = impulse * m_ay;
        const auto LA = AngularMomentum{impulse * m_sAy / Radian};
        const auto LB = AngularMomentum{impulse * m_sBy / Radian};

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }

    if ((velA != oldVelA) || (velB != oldVelB))
    {
	    bodyConstraintA->SetVelocity(velA);
    	bodyConstraintB->SetVelocity(velB);
        return false;
    }
    return true;
}

bool WheelJoint::SolvePositionConstraints(BodyConstraintsMap& bodies, const ConstraintSolverConf& conf) const
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    auto posA = bodyConstraintA->GetPosition();
    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();
    
    auto posB = bodyConstraintB->GetPosition();
    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    const auto rA = Rotate(m_localAnchorA - bodyConstraintA->GetLocalCenter(), qA);
    const auto rB = Rotate(m_localAnchorB - bodyConstraintB->GetLocalCenter(), qB);
    const auto d = Length2{(posB.linear - posA.linear) + (rB - rA)};

    const auto ay = Rotate(m_localYAxisA, qA);

    const auto sAy = Cross(d + rA, ay);
    const auto sBy = Cross(rB, ay);

    const auto C = Length{Dot(d, ay)};

    const auto invRotMassA = invRotInertiaA * Square(m_sAy) / SquareRadian;
    const auto invRotMassB = invRotInertiaB * Square(m_sBy) / SquareRadian;

    const auto k = InvMass{invMassA + invMassB + invRotMassA + invRotMassB};

    const auto impulse = (k != InvMass{0})? -(C / k): 0 * Kilogram * Meter;

    const auto P = impulse * ay;
    const auto LA = impulse * sAy / Radian;
    const auto LB = impulse * sBy / Radian;

    posA -= Position{invMassA * P, invRotInertiaA * LA};
    posB += Position{invMassB * P, invRotInertiaB * LB};

    bodyConstraintA->SetPosition(posA);
    bodyConstraintB->SetPosition(posB);

    return abs(C) <= conf.linearSlop;
}

Length2 WheelJoint::GetAnchorA() const
{
    return GetWorldPoint(*GetBodyA(), GetLocalAnchorA());
}

Length2 WheelJoint::GetAnchorB() const
{
    return GetWorldPoint(*GetBodyB(), GetLocalAnchorB());
}

Momentum2 WheelJoint::GetLinearReaction() const
{
    return m_impulse * m_ay + m_springImpulse * m_ax;
}

void WheelJoint::EnableMotor(bool flag)
{
    if (m_enableMotor != flag)
    {
	    m_enableMotor = flag;

        // XXX Should these be called regardless of whether the state changed?
    	GetBodyA()->SetAwake();
    	GetBodyB()->SetAwake();
    }
}

void WheelJoint::SetMotorSpeed(AngularVelocity speed)
{
    if (m_motorSpeed != speed)
    {
	    m_motorSpeed = speed;

        // XXX Should these be called regardless of whether the state changed?
    	GetBodyA()->SetAwake();
    	GetBodyB()->SetAwake();
    }
}

void WheelJoint::SetMaxMotorTorque(Torque torque)
{
    if (m_maxMotorTorque != torque)
    {
	    m_maxMotorTorque = torque;

        // XXX Should these be called regardless of whether the state changed?
    	GetBodyA()->SetAwake();
    	GetBodyB()->SetAwake();
    }
}

Length GetJointTranslation(const WheelJoint& joint) noexcept
{
    const auto pA = GetWorldPoint(*joint.GetBodyA(), joint.GetLocalAnchorA());
    const auto pB = GetWorldPoint(*joint.GetBodyB(), joint.GetLocalAnchorB());
    const auto d = pB - pA;
    const auto axis = GetWorldVector(*joint.GetBodyA(), joint.GetLocalAxisA());
    return Length{Dot(d, axis)};
}

AngularVelocity GetAngularVelocity(const WheelJoint& joint) noexcept
{
    return joint.GetBodyB()->GetVelocity().angular - joint.GetBodyA()->GetVelocity().angular;
}

} // namespace d2
} // namespace playrho
