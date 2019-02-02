/*
 * Original work Copyright (c) 2007-2011 Erin Catto http://www.box2d.org
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

#include "PlayRho/Dynamics/Joints/GearJointConf.hpp"
#include "PlayRho/Dynamics/Joints/GearJoint.hpp"

namespace playrho {
namespace d2 {

GearJointConf::GearJointConf(NonNull<Joint*> j1, NonNull<Joint*> j2) noexcept:
    super{super{JointType::Gear}.UseBodyA(j1->GetBodyB()).UseBodyB(j2->GetBodyB())},
    joint1{j1}, joint2{j2}
{
    // Intentionally empty.
}

GearJointConf GetGearJointConf(const GearJoint& joint) noexcept
{
    auto def = GearJointConf{joint.GetJoint1(), joint.GetJoint2()};
    
    Set(def, joint);
    def.ratio = joint.GetRatio();
    
    return def;
}

} // namespace d2
} // namespace playrho
