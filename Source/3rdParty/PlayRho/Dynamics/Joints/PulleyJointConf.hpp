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

#ifndef PLAYRHO_DYNAMICS_JOINTS_PULLEYJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_PULLEYJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {
namespace d2 {

class PulleyJoint;

/// @brief Pulley joint definition.
/// @details This requires two ground anchors, two dynamic body anchor points, and a pulley ratio.
struct PulleyJointConf : public JointBuilder<PulleyJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<PulleyJointConf>;
    
    PulleyJointConf() noexcept: super{JointType::Pulley}
    {
        collideConnected = true;
    }
    
    /// Initialize the bodies, anchors, lengths, max lengths, and ratio using the world anchors.
    PulleyJointConf(NonNull<Body*> bodyA, NonNull<Body*> bodyB,
                   const Length2 groundAnchorA, const Length2 groundAnchorB,
                   const Length2 anchorA, const Length2 anchorB);
    
    /// @brief Uses the given ratio value.
    PulleyJointConf& UseRatio(Real v) noexcept;
    
    /// The first ground anchor in world coordinates. This point never moves.
    Length2 groundAnchorA = Length2{-1_m, +1_m};
    
    /// The second ground anchor in world coordinates. This point never moves.
    Length2 groundAnchorB = Length2{+1_m, +1_m};
    
    /// The local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{-1_m, 0_m};
    
    /// The local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{+1_m, 0_m};
    
    /// The a reference length for the segment attached to body-A.
    Length lengthA = 0_m;
    
    /// The a reference length for the segment attached to body-B.
    Length lengthB = 0_m;
    
    /// The pulley ratio, used to simulate a block-and-tackle.
    Real ratio = 1;
};

inline PulleyJointConf& PulleyJointConf::UseRatio(Real v) noexcept
{
    ratio = v;
    return *this;
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso PulleyJoint
PulleyJointConf GetPulleyJointConf(const PulleyJoint& joint) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_PULLEYJOINTCONF_HPP
