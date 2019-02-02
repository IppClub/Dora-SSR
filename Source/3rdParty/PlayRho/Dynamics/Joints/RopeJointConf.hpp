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

#ifndef PLAYRHO_DYNAMICS_JOINTS_ROPEJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_ROPEJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {
namespace d2 {

class RopeJoint;

/// @brief Rope joint definition.
/// @details This requires two body anchor points and a maximum lengths.
/// @note By default the connected objects will not collide.
/// @see collideConnected in JointConf.
struct RopeJointConf : public JointBuilder<RopeJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<RopeJointConf>;
    
    PLAYRHO_CONSTEXPR inline RopeJointConf() noexcept: super{JointType::Rope} {}
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline RopeJointConf(Body* bodyA, Body* bodyB) noexcept:
        super{super{JointType::Rope}.UseBodyA(bodyA).UseBodyB(bodyB)}
    {
        // Intentionally empty.
    }
    
    /// @brief Uses the given max length value.
    PLAYRHO_CONSTEXPR inline RopeJointConf& UseMaxLength(Length v) noexcept;
    
    /// The local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{-1_m, 0_m};
    
    /// The local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{+1_m, 0_m};
    
    /// The maximum length of the rope.
    Length maxLength = 0_m;
};

PLAYRHO_CONSTEXPR inline RopeJointConf& RopeJointConf::UseMaxLength(Length v) noexcept
{
    maxLength = v;
    return *this;
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso RopeJoint
RopeJointConf GetRopeJointConf(const RopeJoint& joint) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_ROPEJOINTCONF_HPP
