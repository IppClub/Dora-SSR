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

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Dynamics/Joints/DistanceJoint.hpp"
#include "PlayRho/Dynamics/Joints/WheelJoint.hpp"
#include "PlayRho/Dynamics/Joints/TargetJoint.hpp"
#include "PlayRho/Dynamics/Joints/RevoluteJoint.hpp"
#include "PlayRho/Dynamics/Joints/PrismaticJoint.hpp"
#include "PlayRho/Dynamics/Joints/PulleyJoint.hpp"
#include "PlayRho/Dynamics/Joints/GearJoint.hpp"
#include "PlayRho/Dynamics/Joints/WeldJoint.hpp"
#include "PlayRho/Dynamics/Joints/FrictionJoint.hpp"
#include "PlayRho/Dynamics/Joints/RopeJoint.hpp"
#include "PlayRho/Dynamics/Joints/MotorJoint.hpp"
#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/World.hpp"
#include "PlayRho/Dynamics/Contacts/Contact.hpp"
#include "PlayRho/Defines.hpp"

#include <algorithm>

namespace playrho {
namespace d2 {

Joint* Joint::Create(const JointConf& def)
{
    switch (def.type)
    {
        case JointType::Distance:
            return Create<DistanceJoint>(static_cast<const DistanceJointConf&>(def));
        case JointType::Target:
            return Create<TargetJoint>(static_cast<const TargetJointConf&>(def));
        case JointType::Prismatic:
            return Create<PrismaticJoint>(static_cast<const PrismaticJointConf&>(def));
        case JointType::Revolute:
            return Create<RevoluteJoint>(static_cast<const RevoluteJointConf&>(def));
        case JointType::Pulley:
            return Create<PulleyJoint>(static_cast<const PulleyJointConf&>(def));
        case JointType::Gear:
            return Create<GearJoint>(static_cast<const GearJointConf&>(def));
        case JointType::Wheel:
            return Create<WheelJoint>(static_cast<const WheelJointConf&>(def));
        case JointType::Weld:
            return Create<WeldJoint>(static_cast<const WeldJointConf&>(def));
        case JointType::Friction:
            return Create<FrictionJoint>(static_cast<const FrictionJointConf&>(def));
        case JointType::Rope:
            return Create<RopeJoint>(static_cast<const RopeJointConf&>(def));
        case JointType::Motor:
            return Create<MotorJoint>(static_cast<const MotorJointConf&>(def));
        case JointType::Unknown:
            break;
    }
    throw InvalidArgument("Joint::Create: Unknown joint type");
}

Joint::FlagsType Joint::GetFlags(const JointConf& def) noexcept
{
    auto flags = Joint::FlagsType{0};
    if (def.collideConnected)
    {
        flags |= e_collideConnectedFlag;
    }
    return flags;
}

Joint::Joint(const JointConf& def):
    m_bodyA{def.bodyA}, m_bodyB{def.bodyB}, m_userData{def.userData}, m_flags{GetFlags(def)}
{
    // Intentionally empty.
}

void Joint::Destroy(const Joint* joint) noexcept
{
    delete joint;
}

bool Joint::IsOkay(const JointConf& def) noexcept
{
    return def.bodyA != def.bodyB;
}

// Free functions...

bool IsEnabled(const Joint& j) noexcept
{
    const auto bA = j.GetBodyA();
    const auto bB = j.GetBodyB();
    return (!bA || bA->IsEnabled()) && (!bB || bB->IsEnabled());
}

void SetAwake(Joint& j) noexcept
{
    const auto bA = j.GetBodyA();
    const auto bB = j.GetBodyB();
    if (bA)
    {
        bA->SetAwake();
    }
    if (bB)
    {
        bB->SetAwake();
    }
}

JointCounter GetWorldIndex(const Joint* joint)
{
    if (joint)
    {
        const auto bA = joint->GetBodyA();
        const auto bB = joint->GetBodyB();
        const auto world = bA? bA->GetWorld():
            bB? bB->GetWorld(): static_cast<const World*>(nullptr);
        if (world)
        {
            auto i = JointCounter{0};
            const auto joints = world->GetJoints();
            const auto it = std::find_if(cbegin(joints), cend(joints), [&](const Joint *j) {
                return (j == joint) || ((void) ++i, false);
            });
            if (it != end(joints))
            {
                return i;
            }
        }
    }
    return JointCounter(-1);
}

#ifdef PLAYRHO_PROVIDE_VECTOR_AT
BodyConstraintPtr& At(std::vector<BodyConstraintPair>& container, const Body* key)
{
    auto last = end(container);
    auto first = begin(container);
    first = std::lower_bound(first, last, key, [](const BodyConstraintPair &a, const Body* b){
        return std::get<const Body*>(a) < b;
    });
    if ((first == last) || (key != std::get<const Body*>(*first)))
    {
        throw std::out_of_range{"invalid key"};
    }
    return std::get<BodyConstraintPtr>(*first);
}
#endif

BodyConstraintPtr& At(std::unordered_map<const Body*, BodyConstraint*>& container,
                      const Body* key)
{
    return container.at(key);
}

const char* ToString(Joint::LimitState val) noexcept
{
    switch (val)
    {
        case Joint::e_atLowerLimit: return "at lower";
        case Joint::e_atUpperLimit: return "at upper";
        case Joint::e_equalLimits: return "equal";
        case Joint::e_inactiveLimit: break;
    }
    assert(val == Joint::e_inactiveLimit);
    return "inactive";
}

} // namespace d2
} // namespace playrho
