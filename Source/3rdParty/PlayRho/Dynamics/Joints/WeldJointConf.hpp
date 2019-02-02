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

#ifndef PLAYRHO_DYNAMICS_JOINTS_WELDJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_WELDJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {
namespace d2 {

class WeldJoint;

/// @brief Weld joint definition.
/// @note A weld joint essentially glues two bodies together. A weld joint may
///   distort somewhat because the island constraint solver is approximate.
/// @note You need to specify local anchor points where they are attached and the
///   relative body angle.
/// @note The position of the anchor points is important for computing the reaction torque.
/// @sa WeldJoint
struct WeldJointConf : public JointBuilder<WeldJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<WeldJointConf>;
    
    PLAYRHO_CONSTEXPR inline WeldJointConf() noexcept: super{JointType::Weld} {}
    
    /// @brief Initializing constructor.
    /// @details Initializes the bodies, anchors, and reference angle using a world
    ///   anchor point.
    /// @param bodyA Body A.
    /// @param bodyB Body B.
    /// @param anchor Anchor location in world coordinates.
    WeldJointConf(NonNull<Body*> bodyA, NonNull<Body*> bodyB, const Length2 anchor) noexcept;
    
    /// @brief Uses the given frequency value.
    PLAYRHO_CONSTEXPR inline WeldJointConf& UseFrequency(Frequency v) noexcept;
    
    /// @brief Uses the given damping ratio.
    PLAYRHO_CONSTEXPR inline WeldJointConf& UseDampingRatio(Real v) noexcept;
    
    /// The local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};
    
    /// The local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};
    
    /// The body-B angle minus body-A angle in the reference state (radians).
    Angle referenceAngle = 0_deg;
    
    /// @brief Mass-spring-damper frequency.
    /// @note Rotation only.
    /// @note Disable softness with a value of 0.
    Frequency frequency = 0_Hz;
    
    /// @brief Damping ratio.
    /// @note 0 = no damping, 1 = critical damping.
    Real dampingRatio = 0;
};

PLAYRHO_CONSTEXPR inline WeldJointConf& WeldJointConf::UseFrequency(Frequency v) noexcept
{
    frequency = v;
    return *this;
}

PLAYRHO_CONSTEXPR inline WeldJointConf& WeldJointConf::UseDampingRatio(Real v) noexcept
{
    dampingRatio = v;
    return *this;
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso WeldJoint
WeldJointConf GetWeldJointConf(const WeldJoint& joint) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_WELDJOINTCONF_HPP
