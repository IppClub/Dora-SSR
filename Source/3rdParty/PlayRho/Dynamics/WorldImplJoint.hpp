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

#ifndef PLAYRHO_DYNAMICS_WORLDIMPLJOINT_HPP
#define PLAYRHO_DYNAMICS_WORLDIMPLJOINT_HPP

/// @file
/// Declarations of free functions of WorldImpl for joints.

#include "PlayRho/Common/Units.hpp"
#include "PlayRho/Common/UnitVec.hpp"
#include "PlayRho/Common/Vector2.hpp" // for Momentum2, Length2

#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/Joints/JointID.hpp"
#include "PlayRho/Dynamics/Joints/JointType.hpp"

namespace playrho {
namespace d2 {

class WorldImpl;
class Joint;

/// @brief Creates a new joint.
/// @relatedalso WorldImpl
JointID CreateJoint(WorldImpl& world, const Joint& def);

/// @brief Destroys the identified joint.
/// @relatedalso WorldImpl
void Destroy(WorldImpl& world, JointID id);

/// @brief Gets the identified joint's value.
/// @relatedalso WorldImpl
const Joint& GetJoint(const WorldImpl& world, JointID id);

/// @brief Sets the identified joint's new value.
/// @relatedalso WorldImpl
void SetJoint(WorldImpl& world, JointID id, const Joint& def);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDIMPLJOINT_HPP
