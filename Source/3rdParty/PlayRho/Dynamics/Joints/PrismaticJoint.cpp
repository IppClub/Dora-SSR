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

#include "PlayRho/Dynamics/Joints/PrismaticJoint.hpp"
#include "PlayRho/Dynamics/Joints/JointVisitor.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/Contacts/ContactSolver.hpp"
#include "PlayRho/Dynamics/Contacts/BodyConstraint.hpp"

#include <algorithm>

namespace playrho {
namespace d2 {

// Linear constraint (point-to-line)
// d = p2 - p1 = x2 + r2 - x1 - r1
// C = dot(perp, d)
// Cdot = dot(d, cross(w1, perp)) + dot(perp, v2 + cross(w2, r2) - v1 - cross(w1, r1))
//      = -dot(perp, v1) - dot(cross(d + r1, perp), w1) + dot(perp, v2) + dot(cross(r2, perp), v2)
// J = [-perp, -cross(d + r1, perp), perp, cross(r2,perp)]
//
// Angular constraint
// C = a2 - a1 + a_initial
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
//
// K = J * invM * JT
//
// J = [-a -s1 a s2]
//     [0  -1  0  1]
// a = perp
// s1 = cross(d + r1, a) = cross(p2 - x1, a)
// s2 = cross(r2, a) = cross(p2 - x2, a)


// Motor/Limit linear constraint
// C = dot(ax1, d)
// Cdot = = -dot(ax1, v1) - dot(cross(d + r1, ax1), w1) + dot(ax1, v2) + dot(cross(r2, ax1), v2)
// J = [-ax1 -cross(d+r1,ax1) ax1 cross(r2,ax1)]

// Block Solver
// We develop a block solver that includes the joint limit. This makes the limit stiff (inelastic) even
// when the mass has poor distribution (leading to large torques about the joint anchor points).
//
// The Jacobian has 3 rows:
// J = [-uT -s1 uT s2] // linear
//     [0   -1   0  1] // angular
//     [-vT -a1 vT a2] // limit
//
// u = perp
// v = axis
// s1 = cross(d + r1, u), s2 = cross(r2, u)
// a1 = cross(d + r1, v), a2 = cross(r2, v)

// M * (v2 - v1) = JT * df
// J * v2 = bias
//
// v2 = v1 + invM * JT * df
// J * (v1 + invM * JT * df) = bias
// K * df = bias - J * v1 = -Cdot
// K = J * invM * JT
// Cdot = J * v1 - bias
//
// Now solve for f2.
// df = f2 - f1
// K * (f2 - f1) = -Cdot
// f2 = invK * (-Cdot) + f1
//
// Clamp accumulated limit impulse.
// lower: f2(3) = max(f2(3), 0)
// upper: f2(3) = min(f2(3), 0)
//
// Solve for correct f2(1:2)
// K(1:2, 1:2) * f2(1:2) = -Cdot(1:2) - K(1:2,3) * f2(3) + K(1:2,1:3) * f1
//                       = -Cdot(1:2) - K(1:2,3) * f2(3) + K(1:2,1:2) * f1(1:2) + K(1:2,3) * f1(3)
// K(1:2, 1:2) * f2(1:2) = -Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3)) + K(1:2,1:2) * f1(1:2)
// f2(1:2) = invK(1:2,1:2) * (-Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3))) + f1(1:2)
//
// Now compute impulse to be applied:
// df = f2 - f1

PrismaticJoint::PrismaticJoint(const PrismaticJointConf& def):
    Joint(def),
    m_localAnchorA{def.localAnchorA},
    m_localAnchorB{def.localAnchorB},
    m_localXAxisA{def.localAxisA},
    m_localYAxisA{GetRevPerpendicular(m_localXAxisA)},
    m_referenceAngle{def.referenceAngle},
    m_lowerTranslation{def.lowerTranslation},
    m_upperTranslation{def.upperTranslation},
    m_maxMotorForce{def.maxMotorForce},
    m_motorSpeed{def.motorSpeed},
    m_enableLimit{def.enableLimit},
    m_enableMotor{def.enableMotor}
{
    // Intentionally empty.
}

void PrismaticJoint::Accept(JointVisitor& visitor) const
{
    visitor.Visit(*this);
}

void PrismaticJoint::Accept(JointVisitor& visitor)
{
    visitor.Visit(*this);
}

void PrismaticJoint::InitVelocityConstraints(BodyConstraintsMap& bodies,
                                             const StepConf& step,
                                             const ConstraintSolverConf& conf)
{
    auto& bodyConstraintA = At(bodies, GetBodyA());
    auto& bodyConstraintB = At(bodies, GetBodyB());

    const auto posA = bodyConstraintA->GetPosition();
    const auto invMassA = bodyConstraintA->GetInvMass();
    const auto invRotInertiaA = bodyConstraintA->GetInvRotInertia();
    auto velA = bodyConstraintA->GetVelocity();

    const auto posB = bodyConstraintB->GetPosition();
    const auto invMassB = bodyConstraintB->GetInvMass();
    const auto invRotInertiaB = bodyConstraintB->GetInvRotInertia();
    auto velB = bodyConstraintB->GetVelocity();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);

    // Compute the effective masses.
    const auto rA = Rotate(m_localAnchorA - bodyConstraintA->GetLocalCenter(), qA); // Length2
    const auto rB = Rotate(m_localAnchorB - bodyConstraintB->GetLocalCenter(), qB); // Length2
    const auto d = (posB.linear - posA.linear) + rB - rA; // Length2

    // Compute motor Jacobian and effective mass.
    m_axis = Rotate(m_localXAxisA, qA);
    m_a1 = Cross(d + rA, m_axis); // Length
    m_a2 = Cross(rB, m_axis); // Length

    const auto invRotMassA = InvMass{invRotInertiaA * m_a1 * m_a1 / SquareRadian};
    const auto invRotMassB = InvMass{invRotInertiaB * m_a2 * m_a2 / SquareRadian};
    const auto totalInvMass = invMassA + invMassB + invRotMassA + invRotMassB;
    m_motorMass = (totalInvMass > InvMass{0})? Real{1} / totalInvMass: 0_kg;

    // Prismatic constraint.
    {
        m_perp = Rotate(m_localYAxisA, qA);

        m_s1 = Cross(d + rA, m_perp);
        m_s2 = Cross(rB, m_perp);

        const auto invRotMassA2 = InvMass{invRotInertiaA * m_s1 * m_s1 / SquareRadian};
        const auto invRotMassB2 = InvMass{invRotInertiaB * m_s2 * m_s2 / SquareRadian};
        const auto k11 = StripUnit(invMassA + invMassB + invRotMassA2 + invRotMassB2);
        
        // L^-2 M^-1 QP^2 * L is: L^-1 M^-1 QP^2.
        const auto k12 = (invRotInertiaA * m_s1 + invRotInertiaB * m_s2) * Meter * Kilogram / SquareRadian;
        const auto k13 = StripUnit(InvMass{(invRotInertiaA * m_s1 * m_a1 + invRotInertiaB * m_s2 * m_a2) / SquareRadian});
        const auto totalInvRotInertia = invRotInertiaA + invRotInertiaB;
        
        const auto k22 = (totalInvRotInertia == InvRotInertia{0})? Real{1}: StripUnit(totalInvRotInertia);
        const auto k23 = (invRotInertiaA * m_a1 + invRotInertiaB * m_a2) * Meter * Kilogram / SquareRadian;
        const auto k33 = StripUnit(totalInvMass);

        GetX(m_K) = Vec3{k11, k12, k13};
        GetY(m_K) = Vec3{k12, k22, k23};
        GetZ(m_K) = Vec3{k13, k23, k33};
    }

    // Compute motor and limit terms.
    if (m_enableLimit)
    {
        const auto jointTranslation = Length{Dot(m_axis, d)};
        if (abs(m_upperTranslation - m_lowerTranslation) < (conf.linearSlop * Real{2}))
        {
            m_limitState = e_equalLimits;
        }
        else if (jointTranslation <= m_lowerTranslation)
        {
            if (m_limitState != e_atLowerLimit)
            {
                m_limitState = e_atLowerLimit;
                GetZ(m_impulse) = 0;
            }
        }
        else if (jointTranslation >= m_upperTranslation)
        {
            if (m_limitState != e_atUpperLimit)
            {
                m_limitState = e_atUpperLimit;
                GetZ(m_impulse) = 0;
            }
        }
        else
        {
            m_limitState = e_inactiveLimit;
            GetZ(m_impulse) = 0;
        }
    }
    else
    {
        m_limitState = e_inactiveLimit;
        GetZ(m_impulse) = 0;
    }

    if (!m_enableMotor)
    {
        m_motorImpulse = 0;
    }

    if (step.doWarmStart)
    {
        // Account for variable time step.
        m_impulse *= step.dtRatio;
        m_motorImpulse *= step.dtRatio;

        const auto ulImpulseX = GetX(m_impulse) * m_perp;
        const auto Px = Momentum2{GetX(ulImpulseX) * NewtonSecond, GetY(ulImpulseX) * NewtonSecond};
        const auto Pxs1 = Momentum{GetX(m_impulse) * m_s1 * Kilogram / Second};
        const auto Pxs2 = Momentum{GetX(m_impulse) * m_s2 * Kilogram / Second};
        const auto PzLength = Momentum{m_motorImpulse + GetZ(m_impulse) * NewtonSecond};
        const auto Pz = Momentum2{PzLength * m_axis};
        const auto P = Px + Pz;
        
        // AngularMomentum is L^2 M T^-1 QP^-1.
        const auto L = AngularMomentum{GetY(m_impulse) * SquareMeter * Kilogram / (Second * Radian)};
        const auto LA = L + (Pxs1 * Meter + PzLength * m_a1) / Radian;
        const auto LB = L + (Pxs2 * Meter + PzLength * m_a2) / Radian;

        // InvRotInertia is L^-2 M^-1 QP^2
        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else
    {
        m_impulse = Vec3{};
        m_motorImpulse = 0;
    }

    bodyConstraintA->SetVelocity(velA);
    bodyConstraintB->SetVelocity(velB);
}

bool PrismaticJoint::SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step)
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

    // Solve linear motor constraint.
    if (m_enableMotor && m_limitState != e_equalLimits)
    {
        const auto vDot = LinearVelocity{Dot(m_axis, velB.linear - velA.linear)};
        const auto Cdot = vDot + (m_a2 * velB.angular - m_a1 * velA.angular) / Radian;
        auto impulse = Momentum{m_motorMass * (m_motorSpeed * Meter / Radian - Cdot)};
        const auto oldImpulse = m_motorImpulse;
        const auto maxImpulse = step.GetTime() * m_maxMotorForce;
        m_motorImpulse = std::clamp(m_motorImpulse + impulse, -maxImpulse, maxImpulse);
        impulse = m_motorImpulse - oldImpulse;

        const auto P = Momentum2{impulse * m_axis};
        
        // Momentum is L^2 M T^-1. AngularMomentum is L^2 M T^-1 QP^-1.
        const auto LA = impulse * m_a1 / Radian;
        const auto LB = impulse * m_a2 / Radian;

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }

    const auto velDelta = velB.linear - velA.linear;
    const auto sRotSpeed = LinearVelocity{(m_s2 * velB.angular - m_s1 * velA.angular) / Radian};
    const auto Cdot1 = Vec2{
        StripUnit(Dot(m_perp, velDelta) + sRotSpeed),
        StripUnit(velB.angular - velA.angular)
    };

    if (m_enableLimit && (m_limitState != e_inactiveLimit))
    {
        // Solve prismatic and limit constraint in block form.
        const auto deltaDot = LinearVelocity{Dot(m_axis, velDelta)};
        const auto aRotSpeed = LinearVelocity{(m_a2 * velB.angular - m_a1 * velA.angular) / Radian};
        const auto Cdot2 = StripUnit(deltaDot + aRotSpeed);
        const auto Cdot = Vec3{GetX(Cdot1), GetY(Cdot1), Cdot2};

        const auto f1 = m_impulse;
        m_impulse += Solve33(m_K, -Cdot);

        if (m_limitState == e_atLowerLimit)
        {
            GetZ(m_impulse) = std::max(GetZ(m_impulse), Real{0});
        }
        else if (m_limitState == e_atUpperLimit)
        {
            GetZ(m_impulse) = std::min(GetZ(m_impulse), Real{0});
        }

        // f2(1:2) = invK(1:2,1:2) * (-Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3))) + f1(1:2)
        const auto b = -Cdot1 - (GetZ(m_impulse) - GetZ(f1)) * Vec2{GetX(GetZ(m_K)), GetY(GetZ(m_K))};
        const auto f2r = Solve22(m_K, b) + Vec2{GetX(f1), GetY(f1)};
        GetX(m_impulse) = GetX(f2r);
        GetY(m_impulse) = GetY(f2r);

        const auto df = m_impulse - f1;

        const auto ulP = GetX(df) * m_perp + GetZ(df) * m_axis;
        const auto P = Momentum2{GetX(ulP) * NewtonSecond, GetY(ulP) * NewtonSecond};
        const auto LA = AngularMomentum{
            (GetX(df) * m_s1 + GetY(df) * Meter + GetZ(df) * m_a1) * NewtonSecond / Radian
        };
        const auto LB = AngularMomentum{
            (GetX(df) * m_s2 + GetY(df) * Meter + GetZ(df) * m_a2) * NewtonSecond / Radian
        };

        velA -= Velocity{invMassA * P, invRotInertiaA * LA};
        velB += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    else
    {
        // Limit is inactive, just solve the prismatic constraint in block form.
        const auto df = Solve22(m_K, -Cdot1);
        
        // m_impulse is a Vec3 while df is a Vec2; so can't just m_impulse += df
        GetX(m_impulse) += GetX(df);
        GetY(m_impulse) += GetY(df);

        const auto ulP = GetX(df) * m_perp;
        const auto P = Momentum2{GetX(ulP) * NewtonSecond, GetY(ulP) * NewtonSecond};
        const auto LA = AngularMomentum{
            (GetX(df) * m_s1 + GetY(df) * Meter) * NewtonSecond / Radian
        };
        const auto LB = AngularMomentum{
            (GetX(df) * m_s2 + GetY(df) * Meter) * NewtonSecond / Radian
        };

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

// A velocity based solver computes reaction forces(impulses) using the velocity constraint solver.
// Under this context, the position solver is not there to resolve forces. It is only there to cope
// with integration error.
//
// Therefore, the pseudo impulses in the position solver do not have any physical meaning. Thus it
// is okay if they suck.
//
// We could take the active state from the velocity solver. However, the joint might push past the
// limit when the velocity solver indicates the limit is inactive.
//
bool PrismaticJoint::SolvePositionConstraints(BodyConstraintsMap& bodies, const ConstraintSolverConf& conf) const
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

    // Compute fresh Jacobians
    const auto rA = Rotate(m_localAnchorA - bodyConstraintA->GetLocalCenter(), qA);
    const auto rB = Rotate(m_localAnchorB - bodyConstraintB->GetLocalCenter(), qB);
    const auto d = Length2{(posB.linear + rB) - (posA.linear + rA)};

    const auto axis = Rotate(m_localXAxisA, qA);
    const auto a1 = Length{Cross(d + rA, axis)};
    const auto a2 = Length{Cross(rB, axis)};
    const auto perp = Rotate(m_localYAxisA, qA);

    const auto s1 = Length{Cross(d + rA, perp)};
    const auto s2 = Length{Cross(rB, perp)};

    const auto C1 = Vec2{
        Dot(perp, d) / Meter,
        (posB.angular - posA.angular - m_referenceAngle) / Radian
    };

    auto linearError = Length{abs(GetX(C1)) * Meter};
    const auto angularError = Angle{abs(GetY(C1)) * Radian};

    auto active = false;
    auto C2 = Real{0};
    if (m_enableLimit)
    {
        const auto translation = Length{Dot(axis, d)};
        if (abs(m_upperTranslation - m_lowerTranslation) < (Real{2} * conf.linearSlop))
        {
            // Prevent large angular corrections
            C2 = StripUnit(std::clamp(translation, -conf.maxLinearCorrection, conf.maxLinearCorrection));
            linearError = std::max(linearError, abs(translation));
            active = true;
        }
        else if (translation <= m_lowerTranslation)
        {
            // Prevent large linear corrections and allow some slop.
            C2 = StripUnit(std::clamp(translation - m_lowerTranslation + conf.linearSlop, -conf.maxLinearCorrection, 0_m));
            linearError = std::max(linearError, m_lowerTranslation - translation);
            active = true;
        }
        else if (translation >= m_upperTranslation)
        {
            // Prevent large linear corrections and allow some slop.
            C2 = StripUnit(std::clamp(translation - m_upperTranslation - conf.linearSlop, 0_m, conf.maxLinearCorrection));
            linearError = std::max(linearError, translation - m_upperTranslation);
            active = true;
        }
    }

    Vec3 impulse;
    if (active)
    {
        const auto k11 = StripUnit(InvMass{
            invMassA + invRotInertiaA * s1 * s1 / SquareRadian +
            invMassB + invRotInertiaB * s2 * s2 / SquareRadian
        });
        const auto k12 = StripUnit(InvMass{
            invRotInertiaA * s1 * Meter / SquareRadian +
            invRotInertiaB * s2 * Meter / SquareRadian
        });
        const auto k13 = StripUnit(InvMass{
            invRotInertiaA * s1 * a1 / SquareRadian +
            invRotInertiaB * s2 * a2 / SquareRadian
        });
    
        // InvRotInertia is L^-2 M^-1 QP^2
        auto k22 = StripUnit(invRotInertiaA + invRotInertiaB);
        if (k22 == Real{0})
        {
            // For fixed rotation
            k22 = StripUnit(Real{1} * SquareRadian / (Kilogram * SquareMeter));
        }
        const auto k23 = StripUnit(InvMass{
            invRotInertiaA * a1 * Meter / SquareRadian +
            invRotInertiaB * a2 * Meter / SquareRadian
        });
        const auto k33 = StripUnit(InvMass{
            invMassA + invRotInertiaA * Square(a1) / SquareRadian +
            invMassB + invRotInertiaB * Square(a2) / SquareRadian
        });

        const auto K = Mat33{Vec3{k11, k12, k13}, Vec3{k12, k22, k23}, Vec3{k13, k23, k33}};
        const auto C = Vec3{GetX(C1), GetY(C1), C2};

        impulse = Solve33(K, -C);
    }
    else
    {
        const auto k11 = StripUnit(InvMass{
            invMassA + invRotInertiaA * s1 * s1 / SquareRadian +
            invMassB + invRotInertiaB * s2 * s2 / SquareRadian
        });
        const auto k12 = StripUnit(InvMass{
            invRotInertiaA * s1 * Meter / SquareRadian +
            invRotInertiaB * s2 * Meter / SquareRadian
        });
        auto k22 = StripUnit(invRotInertiaA + invRotInertiaB);
        if (k22 == 0)
        {
            k22 = 1;
        }

        const auto K = Mat22{Vec2{k11, k12}, Vec2{k12, k22}};

        const auto impulse1 = Solve(K, -C1);
        GetX(impulse) = GetX(impulse1);
        GetY(impulse) = GetY(impulse1);
        GetZ(impulse) = 0;
    }

    const auto P = (GetX(impulse) * perp + GetZ(impulse) * axis) * Kilogram * Meter;
    const auto LA = (GetX(impulse) * s1 + GetY(impulse) * Meter + GetZ(impulse) * a1) * Kilogram * Meter / Radian;
    const auto LB = (GetX(impulse) * s2 + GetY(impulse) * Meter + GetZ(impulse) * a2) * Kilogram * Meter / Radian;

    posA -= Position{Length2{invMassA * P}, invRotInertiaA * LA};
    posB += Position{invMassB * P, invRotInertiaB * LB};

    bodyConstraintA->SetPosition(posA);
    bodyConstraintB->SetPosition(posB);

    return (linearError <= conf.linearSlop) && (angularError <= conf.angularSlop);
}

Length2 PrismaticJoint::GetAnchorA() const
{
    return GetWorldPoint(*GetBodyA(), GetLocalAnchorA());
}

Length2 PrismaticJoint::GetAnchorB() const
{
    return GetWorldPoint(*GetBodyB(), GetLocalAnchorB());
}

Momentum2 PrismaticJoint::GetLinearReaction() const
{
    const auto ulImpulse = GetX(m_impulse) * m_perp;
    const auto impulse = Momentum2{GetX(ulImpulse) * NewtonSecond, GetY(ulImpulse) * NewtonSecond};
    return Momentum2{impulse + (m_motorImpulse + GetZ(m_impulse) * NewtonSecond) * m_axis};
}

AngularMomentum PrismaticJoint::GetAngularReaction() const
{
    return GetY(m_impulse) * SquareMeter * Kilogram / (Second * Radian);
}

void PrismaticJoint::EnableLimit(bool flag) noexcept
{
    if (m_enableLimit != flag)
    {
        m_enableLimit = flag;
        GetZ(m_impulse) = 0;

        GetBodyA()->SetAwake();
        GetBodyB()->SetAwake();
    }
}

void PrismaticJoint::SetLimits(Length lower, Length upper) noexcept
{
    assert(lower <= upper);
    if ((lower != m_lowerTranslation) || (upper != m_upperTranslation))
    {
        m_lowerTranslation = lower;
        m_upperTranslation = upper;
        GetZ(m_impulse) = 0;
        
        GetBodyA()->SetAwake();
        GetBodyB()->SetAwake();
    }
}

void PrismaticJoint::EnableMotor(bool flag) noexcept
{
    if (m_enableMotor != flag)
    {
        m_enableMotor = flag;

        // XXX Should these be called regardless of whether the state changed?
        GetBodyA()->SetAwake();
        GetBodyB()->SetAwake();
    }
}

void PrismaticJoint::SetMotorSpeed(AngularVelocity speed) noexcept
{
    if (m_motorSpeed != speed)
    {
        m_motorSpeed = speed;

        // XXX Should these be called regardless of whether the state changed?
	    GetBodyA()->SetAwake();
    	GetBodyB()->SetAwake();
    }
}

void PrismaticJoint::SetMaxMotorForce(Force force) noexcept
{
    if (m_maxMotorForce != force)
    {
        m_maxMotorForce = force;

        // XXX Should these be called regardless of whether the state changed?
        GetBodyA()->SetAwake();
        GetBodyB()->SetAwake();
    }
}

Length GetJointTranslation(const PrismaticJoint& joint) noexcept
{
    const auto pA = GetWorldPoint(*joint.GetBodyA(), joint.GetLocalAnchorA());
    const auto pB = GetWorldPoint(*joint.GetBodyB(), joint.GetLocalAnchorB());
    return Dot(pB - pA, GetWorldVector(*joint.GetBodyA(), joint.GetLocalAxisA()));
}

LinearVelocity GetLinearVelocity(const PrismaticJoint& joint) noexcept
{
    const auto bA = joint.GetBodyA();
    const auto bB = joint.GetBodyB();
    
    const auto rA = Rotate(joint.GetLocalAnchorA() - bA->GetLocalCenter(), bA->GetTransformation().q);
    const auto rB = Rotate(joint.GetLocalAnchorB() - bB->GetLocalCenter(), bB->GetTransformation().q);
    const auto p1 = bA->GetWorldCenter() + rA;
    const auto p2 = bB->GetWorldCenter() + rB;
    const auto d = p2 - p1;
    const auto axis = Rotate(joint.GetLocalAxisA(), bA->GetTransformation().q);
    
    const auto vA = bA->GetVelocity().linear;
    const auto vB = bB->GetVelocity().linear;
    const auto wA = bA->GetVelocity().angular;
    const auto wB = bB->GetVelocity().angular;
    
    const auto vel = (vB + (GetRevPerpendicular(rB) * (wB / Radian))) -
    (vA + (GetRevPerpendicular(rA) * (wA / Radian)));
    return Dot(d, (GetRevPerpendicular(axis) * (wA / Radian))) + Dot(axis, vel);
}
    
} // namespace d2
} // namespace playrho
