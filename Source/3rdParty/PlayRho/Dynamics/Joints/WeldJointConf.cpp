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

#include "PlayRho/Dynamics/Joints/WeldJointConf.hpp"
#include "PlayRho/Dynamics/Joints/WeldJoint.hpp"
#include "PlayRho/Dynamics/Body.hpp"

namespace playrho {
namespace d2 {

WeldJointConf::WeldJointConf(NonNull<Body*> bA, NonNull<Body*> bB, const Length2 anchor) noexcept:
    super{super{JointType::Weld}.UseBodyA(bA).UseBodyB(bB)},
    localAnchorA{GetLocalPoint(*bA, anchor)},
    localAnchorB{GetLocalPoint(*bB, anchor)},
    referenceAngle{bB->GetAngle() - bA->GetAngle()}
{
    // Intentionally empty.
}

WeldJointConf GetWeldJointConf(const WeldJoint& joint) noexcept
{
    auto def = WeldJointConf{};
    
    Set(def, joint);
    
    def.localAnchorA = joint.GetLocalAnchorA();
    def.localAnchorB = joint.GetLocalAnchorB();
    def.referenceAngle = joint.GetReferenceAngle();
    def.frequency = joint.GetFrequency();
    def.dampingRatio = joint.GetDampingRatio();
    
    return def;
}

} // namespace d2
} // namespace playrho
