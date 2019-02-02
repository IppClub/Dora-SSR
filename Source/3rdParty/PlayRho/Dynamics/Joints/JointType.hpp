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

#ifndef PLAYRHO_DYNAMICS_JOINTS_JOINTTYPE_HPP
#define PLAYRHO_DYNAMICS_JOINTS_JOINTTYPE_HPP

#include "PlayRho/Defines.hpp"

#include <cstdint>

namespace playrho {
namespace d2 {

/// @brief Enumeration of joint types.
enum class JointType : std::uint8_t
{
    Unknown,
    Revolute,
    Prismatic,
    Distance,
    Pulley,
    Target,
    Gear,
    Wheel,
    Weld,
    Friction,
    Rope,
    Motor
};

class Joint;

/// @brief Gets the type of the given joint.
/// @relatedalso Joint
JointType GetType(const Joint& joint) noexcept;

/// @brief Provides a C-style (null-terminated) string name for given joint type.
/// @return C-style English-language human-readable string uniquely identifying the joint type.
const char* ToString(JointType type) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_JOINTTYPE_HPP
