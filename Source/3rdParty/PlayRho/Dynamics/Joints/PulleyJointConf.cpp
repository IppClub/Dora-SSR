/*
 * Original work Copyright (c) 2007 Erin Catto http://www.box2d.org
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

#include "PlayRho/Dynamics/Joints/PulleyJointConf.hpp"
#include "PlayRho/Dynamics/Joints/PulleyJoint.hpp"
#include "PlayRho/Dynamics/Body.hpp"

namespace playrho {
namespace d2 {

PulleyJointConf::PulleyJointConf(NonNull<Body*> bA, NonNull<Body*> bB,
                               const Length2 groundA, const Length2 groundB,
                               const Length2 anchorA, const Length2 anchorB):
    super{super{JointType::Pulley}.UseBodyA(bA).UseBodyB(bB).UseCollideConnected(true)},
    groundAnchorA{groundA},
    groundAnchorB{groundB},
    localAnchorA{GetLocalPoint(*bA, anchorA)},
    localAnchorB{GetLocalPoint(*bB, anchorB)},
    lengthA{GetMagnitude(anchorA - groundA)},
    lengthB{GetMagnitude(anchorB - groundB)}
{
    // Intentionally empty.
}

PulleyJointConf GetPulleyJointConf(const PulleyJoint& joint) noexcept
{
    auto def = PulleyJointConf{};
    
    Set(def, joint);
    
    def.groundAnchorA = joint.GetGroundAnchorA();
    def.groundAnchorB = joint.GetGroundAnchorB();
    def.localAnchorA = joint.GetLocalAnchorA();
    def.localAnchorB = joint.GetGroundAnchorB();
    def.lengthA = joint.GetLengthA();
    def.lengthB = joint.GetLengthB();
    def.ratio = joint.GetRatio();
    
    return def;
}

} // namespace d2
} // namespace playrho
