/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Dynamics/WorldImplJoint.hpp"

#include "PlayRho/Dynamics/WorldImpl.hpp"
#include "PlayRho/Dynamics/Body.hpp" // for use of GetBody(BodyID)

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/RevoluteJointConf.hpp"
#include "PlayRho/Dynamics/Joints/PrismaticJointConf.hpp"
#include "PlayRho/Dynamics/Joints/DistanceJointConf.hpp"
#include "PlayRho/Dynamics/Joints/PulleyJointConf.hpp"
#include "PlayRho/Dynamics/Joints/TargetJointConf.hpp"
#include "PlayRho/Dynamics/Joints/GearJointConf.hpp"
#include "PlayRho/Dynamics/Joints/WheelJointConf.hpp"
#include "PlayRho/Dynamics/Joints/WeldJointConf.hpp"
#include "PlayRho/Dynamics/Joints/FrictionJointConf.hpp"
#include "PlayRho/Dynamics/Joints/RopeJointConf.hpp"
#include "PlayRho/Dynamics/Joints/MotorJointConf.hpp"

#include "PlayRho/Common/OptionalValue.hpp" // for Optional

namespace playrho {
namespace d2 {

JointID CreateJoint(WorldImpl& world, const Joint& def)
{
    return world.CreateJoint(def);
}

void Destroy(WorldImpl& world, JointID id)
{
    world.Destroy(id);
}

const Joint& GetJoint(const WorldImpl& world, JointID id)
{
    return world.GetJoint(id);
}

void SetJoint(WorldImpl& world, JointID id, const Joint& def)
{
    world.SetJoint(id, def);
}

} // namespace d2
} // namespace playrho
