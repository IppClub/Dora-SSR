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

#ifndef PLAYRHO_DYNAMICS_JOINTS_PRISMATICJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_PRISMATICJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {
namespace d2 {

class PrismaticJoint;

/// @brief Prismatic joint definition.
/// @details This requires defining a line of
/// motion using an axis and an anchor point. The definition uses local
/// anchor points and a local axis so that the initial configuration
/// can violate the constraint slightly. The joint translation is zero
/// when the local anchor points coincide in world space. Using local
/// anchors and a local axis helps when saving and loading a game.
struct PrismaticJointConf : public JointBuilder<PrismaticJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<PrismaticJointConf>;
    
    PLAYRHO_CONSTEXPR inline PrismaticJointConf() noexcept: super{JointType::Prismatic} {}
    
    /// @brief Copy constructor.
    PrismaticJointConf(const PrismaticJointConf& copy) = default;
    
    /// @brief Initializing constructor.
    /// @details Initializes the bodies, anchors, axis, and reference angle using the world
    ///   anchor and unit world axis.
    PrismaticJointConf(NonNull<Body*> bodyA, NonNull<Body*> bodyB, const Length2 anchor,
                      const UnitVec axis) noexcept;
    
    /// @brief Uses the given enable limit state value.
    PrismaticJointConf& UseEnableLimit(bool v) noexcept;
    
    /// @brief Uses the given lower translation value.
    PrismaticJointConf& UseLowerTranslation(Length v) noexcept;
    
    /// @brief Uses the given upper translation value.
    PrismaticJointConf& UseUpperTranslation(Length v) noexcept;
    
    /// @brief Uses the given enable motor state value.
    PrismaticJointConf& UseEnableMotor(bool v) noexcept;
    
    /// The local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};
    
    /// The local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};
    
    /// The local translation unit axis in body A.
    UnitVec localAxisA = UnitVec::GetRight();
    
    /// The constrained angle between the bodies: body B's angle minus body A's angle.
    Angle referenceAngle = 0_deg;
    
    /// Enable/disable the joint limit.
    bool enableLimit = false;
    
    /// The lower translation limit.
    Length lowerTranslation = 0_m;
    
    /// The upper translation limit.
    Length upperTranslation = 0_m;
    
    /// Enable/disable the joint motor.
    bool enableMotor = false;
    
    /// The maximum motor force.
    Force maxMotorForce = 0_N;
    
    /// The desired angular motor speed.
    AngularVelocity motorSpeed = 0_rpm;
};

inline PrismaticJointConf& PrismaticJointConf::UseEnableLimit(bool v) noexcept
{
    enableLimit = v;
    return *this;
}

inline PrismaticJointConf& PrismaticJointConf::UseLowerTranslation(Length v) noexcept
{
    lowerTranslation = v;
    return *this;
}

inline PrismaticJointConf& PrismaticJointConf::UseUpperTranslation(Length v) noexcept
{
    upperTranslation = v;
    return *this;
}

inline PrismaticJointConf& PrismaticJointConf::UseEnableMotor(bool v) noexcept
{
    enableMotor = v;
    return *this;
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso PrismaticJoint
PrismaticJointConf GetPrismaticJointConf(const PrismaticJoint& joint) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_PRISMATICJOINTCONF_HPP
