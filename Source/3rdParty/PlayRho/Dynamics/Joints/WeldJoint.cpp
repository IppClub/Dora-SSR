/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
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

#include "PlayRho/Dynamics/Joints/WeldJoint.hpp"
#include "PlayRho/Dynamics/Joints/JointVisitor.hpp"
#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/Contacts/ContactSolver.hpp"
#include "PlayRho/Dynamics/Contacts/BodyConstraint.hpp"

namespace playrho {
namespace d2 {

namespace {

Mat33 GetMat33(InvMass invMassA, Length2 rA, InvRotInertia invRotInertiaA,
               InvMass invMassB, Length2 rB, InvRotInertia invRotInertiaB)
{
    const auto exx = InvMass{
        invMassA + Square(GetY(rA)) * invRotInertiaA / SquareRadian +
        invMassB + Square(GetY(rB)) * invRotInertiaB / SquareRadian
    };
    const auto eyx = InvMass{
        -GetY(rA) * GetX(rA) * invRotInertiaA / SquareRadian +
        -GetY(rB) * GetX(rB) * invRotInertiaB / SquareRadian
    };
    const auto ezx = InvMass{
        -GetY(rA) * invRotInertiaA * Meter / SquareRadian +
        -GetY(rB) * invRotInertiaB * Meter / SquareRadian
    };
    const auto eyy = InvMass{
        invMassA + Square(GetX(rA)) * invRotInertiaA / SquareRadian +
        invMassB + Square(GetX(rB)) * invRotInertiaB / SquareRadian
    };
    const auto ezy = InvMass{
        GetX(rA) * invRotInertiaA * Meter / SquareRadian +
        GetX(rB) * invRotInertiaB * Meter / SquareRadian
    };
    const auto ezz = InvMass{(invRotInertiaA + invRotInertiaB) * SquareMeter / SquareRadian};
    
    Mat33 K;
    GetX(GetX(K)) = StripUnit(exx);
    GetX(GetY(K)) = StripUnit(eyx);
    GetX(GetZ(K)) = StripUnit(ezx);
    GetY(GetX(K)) = GetX(GetY(K));
    GetY(GetY(K)) = StripUnit(eyy);
    GetY(GetZ(K)) = StripUnit(ezy);
    GetZ(GetX(K)) = GetX(GetZ(K));
    GetZ(GetY(K)) = GetY(GetZ(K));
    GetZ(GetZ(K)) = StripUnit(ezz);
    return K;
}

} // unnamed namespace

// Point-to-point constraint
// C = p2 - p1
// Cdot = v2 - v1
//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
// J = [-I -r1_skew I r2_skew ]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

// Angle constraint
// C = angle2 - angle1 - referenceAngle
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
// K = invI1 + invI2

WeldJoint::WeldJoint(const WeldJointConf& def):
    Joint(def),
    m_localAnchorA(def.localAnchorA),
    m_localAnchorB(def.localAnchorB),
    m_referenceAngle(def.referenceAngle),
    m_frequency(def.frequency),
    m_dampingRatio(def.dampingRatio)
{
    // Intentionally empty.
}

void WeldJoint::Accept(JointVisitor& visitor) const
{
    visitor.Visit(*this);
}

void WeldJoint::Accept(JointVisitor& visitor)
{
    visitor.Visit(*this);
}

void WeldJoint::InitVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step,
                                        const ConstraintSolverConf&)
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    auto velA = bodyConstraintA->GetVelocity();
    const auto posA = bodyConstraintA->GetPosition();
    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();

    auto velB = bodyConstraintB->GetVelocity();
    const auto posB = bodyConstraintB->GetPosition();
    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    m_rA = Rotate(m_localAnchorA - bodyConstraintA->GetLocalCenter(), qA);
    m_rB = Rotate(m_localAnchorB - bodyConstraintB->GetLocalCenter(), qB);

    // J = [-I -r1_skew I r2_skew]
    //     [ 0       -1 0       1]
    // r_skew = [-ry; rx]

    // Matlab
    // K = [ invMassA+r1y^2*invRotInertiaA+invMassB+r2y^2*invRotInertiaB,  -r1y*invRotInertiaA*r1x-r2y*invRotInertiaB*r2x,          -r1y*invRotInertiaA-r2y*invRotInertiaB]
    //     [  -r1y*invRotInertiaA*r1x-r2y*invRotInertiaB*r2x, invMassA+r1x^2*invRotInertiaA+invMassB+r2x^2*invRotInertiaB,           r1x*invRotInertiaA+r2x*invRotInertiaB]
    //     [          -r1y*invRotInertiaA-r2y*invRotInertiaB,           r1x*invRotInertiaA+r2x*invRotInertiaB,                   invRotInertiaA+invRotInertiaB]

    const auto K = GetMat33(invMassA, m_rA, invRotInertiaA, invMassB, m_rB, invRotInertiaB);
    if (m_frequency > 0_Hz)
    {
        m_mass = GetInverse22(K);

        // InvRotInertia is L^-2 M^-1 QP^2
        //    RotInertia is L^2  M    QP^-2
        auto invRotInertia = InvRotInertia{invRotInertiaA + invRotInertiaB};
        const auto rotInertia = (invRotInertia > InvRotInertia{0})? Real{1} / invRotInertia: RotInertia{0};

        const auto C = Angle{posB.angular - posA.angular - m_referenceAngle};
        const auto omega = Real(2) * Pi * m_frequency; // T^-1
        const auto d = Real(2) * rotInertia * m_dampingRatio * omega;

        // Spring stiffness: L^2 M QP^-2 T^-2
        const auto k = rotInertia * omega * omega;

        // magic formulas
        const auto h = step.GetTime();
        const auto invGamma = RotInertia{h * (d + h * k)};
        m_gamma = (invGamma != RotInertia{0})? Real{1} / invGamma: InvRotInertia{0};
        // QP * T * L^2 M QP^-2 T^-2 * L^-2 M^-1 QP^2 is: QP T^-1
        m_bias = AngularVelocity{C * h * k * m_gamma};

        invRotInertia += m_gamma;
        GetZ(GetZ(m_mass)) = StripUnit((invRotInertia != InvRotInertia{0}) ?
                                       Real{1} / invRotInertia : RotInertia{0});
    }
    else if (GetZ(GetZ(K)) == 0)
    {
        m_mass = GetInverse22(K);
        m_gamma = InvRotInertia{0};
        m_bias = 0_rpm;
    }
    else
    {
        m_mass = GetSymInverse33(K);
        m_gamma = InvRotInertia{0};
        m_bias = 0_rpm;
    }

    if (step.doWarmStart)
    {
        // Scale impulses to support a variable time step.
        m_impulse *= step.dtRatio;

        const auto P = Momentum2{GetX(m_impulse) * NewtonSecond, GetY(m_impulse) * NewtonSecond};

        // AngularMomentum is L^2 M T^-1 QP^-1.
        const auto L = AngularMomentum{GetZ(m_impulse) * SquareMeter * Kilogram / (Second * Radian)};
        const auto LA = L + AngularMomentum{Cross(m_rA, P) / Radian};
        const auto LB = L + AngularMomentum{Cross(m_rB, P) / Radian};

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else
    {
        m_impulse = Vec3{};
    }

    bodyConstraintA->SetVelocity(velA);
    bodyConstraintB->SetVelocity(velB);
}

bool WeldJoint::SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf&)
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    const auto oldVelA = bodyConstraintA->GetVelocity();
    auto velA = oldVelA;
    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();

    const auto oldVelB = bodyConstraintB->GetVelocity();
    auto velB = oldVelB;
    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();

    if (m_frequency > 0_Hz)
    {
        const auto Cdot2 = velB.angular - velA.angular;
        
        // InvRotInertia is L^-2 M^-1 QP^2. Angular velocity is QP T^-1
        const auto gamma = AngularVelocity{m_gamma * GetZ(m_impulse) * SquareMeter * Kilogram / (Radian * Second)};

        // AngularMomentum is L^2 M T^-1 QP^-1.
        const auto impulse2 = -GetZ(GetZ(m_mass)) * StripUnit(Cdot2 + m_bias + gamma);
        GetZ(m_impulse) += impulse2;

        velA.angular -= AngularVelocity{invRotInertiaA * impulse2 * SquareMeter * Kilogram / (Second * Radian)};
        velB.angular += AngularVelocity{invRotInertiaB * impulse2 * SquareMeter * Kilogram / (Second * Radian)};

        const auto vb = velB.linear + LinearVelocity2{(GetRevPerpendicular(m_rB) * (velB.angular / Radian))};
        const auto va = velA.linear + LinearVelocity2{(GetRevPerpendicular(m_rA) * (velA.angular / Radian))};

        const auto Cdot1 = vb - va;

        const auto impulse1 = -Transform(Vec2{GetX(Cdot1) / MeterPerSecond, GetY(Cdot1) / MeterPerSecond}, m_mass);
        GetX(m_impulse) += GetX(impulse1);
        GetY(m_impulse) += GetY(impulse1);

        const auto P = Momentum2{GetX(impulse1) * NewtonSecond, GetY(impulse1) * NewtonSecond};
        const auto LA = AngularMomentum{Cross(m_rA, P) / Radian};
        const auto LB = AngularMomentum{Cross(m_rB, P) / Radian};

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else
    {
        const auto vb = velB.linear + LinearVelocity2{(GetRevPerpendicular(m_rB) * (velB.angular / Radian))};
        const auto va = velA.linear + LinearVelocity2{(GetRevPerpendicular(m_rA) * (velA.angular / Radian))};

        const auto Cdot1 = vb - va;
        const auto Cdot2 = Real{(velB.angular - velA.angular) / RadianPerSecond};
        const auto Cdot = Vec3{GetX(Cdot1) / MeterPerSecond, GetY(Cdot1) / MeterPerSecond, Cdot2};

        const auto impulse = -Transform(Cdot, m_mass);
        m_impulse += impulse;

        const auto P = Momentum2{GetX(impulse) * NewtonSecond, GetY(impulse) * NewtonSecond};
        
        // AngularMomentum is L^2 M T^-1 QP^-1.
        const auto L = AngularMomentum{GetZ(impulse) * SquareMeter * Kilogram / (Second * Radian)};
        const auto LA = L + AngularMomentum{Cross(m_rA, P) / Radian};
        const auto LB = L + AngularMomentum{Cross(m_rB, P) / Radian};

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

bool WeldJoint::SolvePositionConstraints(BodyConstraintsMap& bodies, const ConstraintSolverConf& conf) const
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    auto posA = bodyConstraintA->GetPosition();
    auto posB = bodyConstraintB->GetPosition();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();
    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();

    const auto rA = Rotate(m_localAnchorA - bodyConstraintA->GetLocalCenter(), qA);
    const auto rB = Rotate(m_localAnchorB - bodyConstraintB->GetLocalCenter(), qB);

    auto positionError = 0_m;
    auto angularError = 0_deg;

    const auto K = GetMat33(invMassA, rA, invRotInertiaA, invMassB, rB, invRotInertiaB);
    if (m_frequency > 0_Hz)
    {
        const auto C1 = Length2{(posB.linear + rB) - (posA.linear + rA)};

        positionError = GetMagnitude(C1);
        angularError = 0_deg;

        const auto P = -Solve22(K, C1) * Kilogram;
        const auto LA = Cross(rA, P) / Radian;
        const auto LB = Cross(rB, P) / Radian;

        posA -= Position{invMassA * P, invRotInertiaA * LA};
        posB += Position{invMassB * P, invRotInertiaB * LB};
    }
    else
    {
        const auto C1 = Length2{(posB.linear + rB) - (posA.linear + rA)};
        const auto C2 = Angle{posB.angular - posA.angular - m_referenceAngle};

        positionError = GetMagnitude(C1);
        angularError = abs(C2);

        const auto C = Vec3{StripUnit(GetX(C1)), StripUnit(GetY(C1)), StripUnit(C2)};
    
        Vec3 impulse;
        if (GetZ(GetZ(K)) > 0)
        {
            impulse = -Solve33(K, C);
        }
        else
        {
            const auto impulse2 = -Solve22(K, GetVec2(C1));
            impulse = Vec3{GetX(impulse2), GetY(impulse2), 0};
        }

        const auto P = Length2{GetX(impulse) * Meter, GetY(impulse) * Meter} * Kilogram;
        const auto L = GetZ(impulse) * Kilogram * SquareMeter / Radian;
        const auto LA = L + Cross(rA, P) / Radian;
        const auto LB = L + Cross(rB, P) / Radian;

        posA -= Position{invMassA * P, invRotInertiaA * LA};
        posB += Position{invMassB * P, invRotInertiaB * LB};
    }

    bodyConstraintA->SetPosition(posA);
    bodyConstraintB->SetPosition(posB);

    return (positionError <= conf.linearSlop) && (angularError <= conf.angularSlop);
}

Length2 WeldJoint::GetAnchorA() const
{
    return GetWorldPoint(*GetBodyA(), GetLocalAnchorA());
}

Length2 WeldJoint::GetAnchorB() const
{
    return GetWorldPoint(*GetBodyB(), GetLocalAnchorB());
}

Momentum2 WeldJoint::GetLinearReaction() const
{
    return Momentum2{GetX(m_impulse) * NewtonSecond, GetY(m_impulse) * NewtonSecond};
}

AngularMomentum WeldJoint::GetAngularReaction() const
{
    // AngularMomentum is L^2 M T^-1 QP^-1
    return AngularMomentum{GetZ(m_impulse) * SquareMeter * Kilogram / (Second * Radian)};
}

} // namespace d2
} // namespace playrho
