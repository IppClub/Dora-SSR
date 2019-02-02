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

#ifndef PLAYRHO_DYNAMICS_JOINTS_FRICTIONJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_FRICTIONJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {
namespace d2 {

class Body;
class FrictionJoint;

/// @brief Friction joint definition.
struct FrictionJointConf : public JointBuilder<FrictionJointConf>
{
    
    /// @brief Super type.
    using super = JointBuilder<FrictionJointConf>;
    
    PLAYRHO_CONSTEXPR inline FrictionJointConf() noexcept: super{JointType::Friction} {}
    
    /// @brief Initializing constructor.
    /// @details Initialize the bodies, anchors, axis, and reference angle using the world
    ///   anchor and world axis.
    FrictionJointConf(Body* bodyA, Body* bodyB, const Length2 anchor) noexcept;
    
    /// @brief Uses the given maximum force value.
    PLAYRHO_CONSTEXPR inline FrictionJointConf& UseMaxForce(NonNegative<Force> v) noexcept;
    
    /// @brief Uses the given maximum torque value.
    PLAYRHO_CONSTEXPR inline FrictionJointConf& UseMaxTorque(NonNegative<Torque> v) noexcept;
    
    /// @brief Local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};
    
    /// @brief Local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};
    
    /// @brief Maximum friction force.
    NonNegative<Force> maxForce = NonNegative<Force>{0_N};
    
    /// @brief Maximum friction torque.
    NonNegative<Torque> maxTorque = NonNegative<Torque>{0_Nm};
};

PLAYRHO_CONSTEXPR inline FrictionJointConf& FrictionJointConf::UseMaxForce(NonNegative<Force> v) noexcept
{
    maxForce = v;
    return *this;
}

PLAYRHO_CONSTEXPR inline FrictionJointConf& FrictionJointConf::UseMaxTorque(NonNegative<Torque> v) noexcept
{
    maxTorque = v;
    return *this;
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso FrictionJoint
FrictionJointConf GetFrictionJointConf(const FrictionJoint& joint) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_FRICTIONJOINTCONF_HPP
