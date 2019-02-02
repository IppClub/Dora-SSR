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
#include "PlayRho/Dynamics/Joints/TypeJointVisitor.hpp"

namespace playrho {
namespace d2 {

JointType GetType(const Joint& joint) noexcept
{
    auto visitor = TypeJointVisitor{};
    joint.Accept(visitor);
    return visitor.GetType().value_or(JointType::Unknown);
}

const char* ToString(JointType type) noexcept
{
    switch (type)
    {
        case JointType::Revolute: return "Revolute";
        case JointType::Prismatic: return "Prismatic";
        case JointType::Distance: return "Distance";
        case JointType::Pulley: return "Pulley";
        case JointType::Target: return "Target";
        case JointType::Gear: return "Gear";
        case JointType::Wheel: return "Wheel";
        case JointType::Weld: return "Weld";
        case JointType::Friction: return "Friction";
        case JointType::Rope: return "Rope";
        case JointType::Motor: return "Motor";
        case JointType::Unknown: break;
    }
    assert(type == JointType::Unknown);
    return "Unknown";
}

} // namespace d2
} // namespace playrho
