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

#ifndef PLAYRHO_DYNAMICS_JOINTS_REVOLUTEJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_REVOLUTEJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {
namespace d2 {

class RevoluteJoint;

/// @brief Revolute joint definition.
/// @details This requires defining an
/// anchor point where the bodies are joined. The definition
/// uses local anchor points so that the initial configuration
/// can violate the constraint slightly. You also need to
/// specify the initial relative angle for joint limits. This
/// helps when saving and loading a game.
/// @note The local anchor points are measured from the body's origin
///   rather than the center of mass because:
///    1. you might not know where the center of mass will be;
///    2. if you add/remove shapes from a body and recompute the mass,
///       the joints will be broken.
struct RevoluteJointConf : public JointBuilder<RevoluteJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<RevoluteJointConf>;
    
    PLAYRHO_CONSTEXPR inline RevoluteJointConf() noexcept: super{JointType::Revolute} {}
    
    /// @brief Initialize the bodies, anchors, and reference angle using a world anchor point.
    RevoluteJointConf(NonNull<Body*> bodyA, NonNull<Body*> bodyB, const Length2 anchor) noexcept;
    
    /// @brief Uses the given enable limit state value.
    PLAYRHO_CONSTEXPR inline RevoluteJointConf& UseEnableLimit(bool v) noexcept;
    
    /// @brief Uses the given lower angle value.
    PLAYRHO_CONSTEXPR inline RevoluteJointConf& UseLowerAngle(Angle v) noexcept;
    
    /// @brief Uses the given upper angle value.
    PLAYRHO_CONSTEXPR inline RevoluteJointConf& UseUpperAngle(Angle v) noexcept;
    
    /// @brief Uses the given enable motor state value.
    PLAYRHO_CONSTEXPR inline RevoluteJointConf& UseEnableMotor(bool v) noexcept;

    /// @brief Local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};
    
    /// @brief Local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};
    
    /// @brief Reference angle.
    /// @details This is the body-B angle minus body-A angle in the reference state (radians).
    Angle referenceAngle = 0_deg;
    
    /// @brief Flag to enable joint limits.
    bool enableLimit = false;
    
    /// @brief Lower angle for the joint limit.
    Angle lowerAngle = 0_deg;
    
    /// @brief Upper angle for the joint limit.
    Angle upperAngle = 0_deg;
    
    /// @brief Flag to enable the joint motor.
    bool enableMotor = false;
    
    /// @brief Desired motor speed.
    AngularVelocity motorSpeed = 0_rpm;
    
    /// @brief Maximum motor torque used to achieve the desired motor speed.
    Torque maxMotorTorque = 0;
};

PLAYRHO_CONSTEXPR inline RevoluteJointConf& RevoluteJointConf::UseEnableLimit(bool v) noexcept
{
    enableLimit = v;
    return *this;
}

PLAYRHO_CONSTEXPR inline RevoluteJointConf& RevoluteJointConf::UseLowerAngle(Angle v) noexcept
{
    lowerAngle = v;
    return *this;
}

PLAYRHO_CONSTEXPR inline RevoluteJointConf& RevoluteJointConf::UseUpperAngle(Angle v) noexcept
{
    upperAngle = v;
    return *this;
}

PLAYRHO_CONSTEXPR inline RevoluteJointConf& RevoluteJointConf::UseEnableMotor(bool v) noexcept
{
    enableMotor = v;
    return *this;
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso RevoluteJoint
RevoluteJointConf GetRevoluteJointConf(const RevoluteJoint& joint) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_REVOLUTEJOINTCONF_HPP
