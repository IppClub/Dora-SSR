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

#ifndef PLAYRHO_DYNAMICS_JOINTS_GEARJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_GEARJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {
namespace d2 {

class Joint;
class GearJoint;

/// @brief Gear joint definition.
/// @details This definition requires two existing
/// revolute or prismatic joints (any combination will work).
struct GearJointConf : public JointBuilder<GearJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<GearJointConf>;
    
    /// @brief Initializing constructor.
    GearJointConf(NonNull<Joint*> j1, NonNull<Joint*> j2) noexcept;
    
    /// @brief Uses the given ratio value.
    GearJointConf& UseRatio(Real v) noexcept;
    
    /// The first revolute/prismatic joint attached to the gear joint.
    NonNull<Joint*> joint1;
    
    /// The second revolute/prismatic joint attached to the gear joint.
    NonNull<Joint*> joint2;
    
    /// The gear ratio.
    /// @see GearJoint for explanation.
    Real ratio = Real{1};
};

inline GearJointConf& GearJointConf::UseRatio(Real v) noexcept
{
    ratio = v;
    return *this;
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso GearJoint
GearJointConf GetGearJointConf(const GearJoint& joint) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_GEARJOINTCONF_HPP
