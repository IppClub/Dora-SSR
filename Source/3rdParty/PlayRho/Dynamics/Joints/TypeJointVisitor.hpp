/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_JOINTS_TYPEJOINTVISITOR_HPP
#define PLAYRHO_DYNAMICS_JOINTS_TYPEJOINTVISITOR_HPP

#include "PlayRho/Dynamics/Joints/JointVisitor.hpp"
#include "PlayRho/Dynamics/Joints/JointType.hpp"
#include "PlayRho/Common/OptionalValue.hpp"

namespace playrho {
namespace d2 {

/// @brief Typing <code>JointVisitor</code>.
/// @details Records the type of joint that gets visited.
class TypeJointVisitor: public JointVisitor
{
public:
    
    void Visit(const RevoluteJoint& /*joint*/) override
    {
        m_type = JointType::Revolute;
    }
    
    void Visit(RevoluteJoint& /*joint*/) override
    {
        m_type = JointType::Revolute;
        m_writable = true;
    }

    void Visit(const PrismaticJoint& /*joint*/) override
    {
        m_type = JointType::Prismatic;
    }
    
    void Visit(PrismaticJoint& /*joint*/) override
    {
        m_type = JointType::Prismatic;
        m_writable = true;
    }

    void Visit(const DistanceJoint& /*joint*/) override
    {
        m_type = JointType::Distance;
    }
    
    void Visit(DistanceJoint& /*joint*/) override
    {
        m_type = JointType::Distance;
        m_writable = true;
    }
    
    void Visit(const PulleyJoint& /*joint*/) override
    {
        m_type = JointType::Pulley;
    }
    
    void Visit(PulleyJoint& /*joint*/) override
    {
        m_type = JointType::Pulley;
        m_writable = true;
    }

    void Visit(const TargetJoint& /*joint*/) override
    {
        m_type = JointType::Target;
    }

    void Visit(TargetJoint& /*joint*/) override
    {
        m_type = JointType::Target;
        m_writable = true;
    }
    
    void Visit(const GearJoint& /*joint*/) override
    {
        m_type = JointType::Gear;
    }
    
    void Visit(GearJoint& /*joint*/) override
    {
        m_type = JointType::Gear;
        m_writable = true;
    }

    void Visit(const WheelJoint& /*joint*/) override
    {
        m_type = JointType::Wheel;
    }

    void Visit(WheelJoint& /*joint*/) override
    {
        m_type = JointType::Wheel;
        m_writable = true;
    }

    void Visit(const WeldJoint& /*joint*/) override
    {
        m_type = JointType::Weld;
    }

    void Visit(WeldJoint& /*joint*/) override
    {
        m_type = JointType::Weld;
        m_writable = true;
    }

    void Visit(const FrictionJoint& /*joint*/) override
    {
        m_type = JointType::Friction;
    }

    void Visit(FrictionJoint& /*joint*/) override
    {
        m_type = JointType::Friction;
        m_writable = true;
    }
    
    void Visit(const RopeJoint& /*joint*/) override
    {
        m_type = JointType::Rope;
    }
    
    void Visit(RopeJoint& /*joint*/) override
    {
        m_type = JointType::Rope;
        m_writable = true;
    }
    
    void Visit(const MotorJoint& /*joint*/) override
    {
        m_type = JointType::Motor;
    }
    
    void Visit(MotorJoint& /*joint*/) override
    {
        m_type = JointType::Motor;
        m_writable = true;
    }

    /// @brief Gets the type of joint that had been visited.
    Optional<JointType> GetType() const noexcept
    {
        return m_type;
    }
    
    /// @brief Gets whether the visited type was writable or not.
    bool GetWritable() const noexcept
    {
        return m_writable;
    }
    
private:
    Optional<JointType> m_type; ///< Optional type of the joint (set if visited).
    bool m_writable = false; ///< Whether visited type was writable.
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_TYPEJOINTVISITOR_HPP
