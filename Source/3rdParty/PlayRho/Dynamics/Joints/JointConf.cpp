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

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Dynamics/Joints/Joint.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible<JointConf>::value,
              "JointConf should be default constructible!");
static_assert(std::is_copy_constructible<JointConf>::value,
              "JointConf should be copy constructible!");
static_assert(std::is_copy_assignable<JointConf>::value,
              "JointConf should be copy assignable!");
static_assert(std::is_nothrow_move_constructible<JointConf>::value,
              "JointConf should be nothrow move constructible!");
static_assert(std::is_nothrow_move_assignable<JointConf>::value,
              "JointConf should be nothrow move assignable!");
static_assert(std::is_nothrow_destructible<JointConf>::value,
              "JointConf should be nothrow destructible!");

void Set(JointConf& def, const Joint& joint) noexcept
{
    def.bodyA = GetBodyA(joint);
    def.bodyB = GetBodyB(joint);
    def.collideConnected = GetCollideConnected(joint);
}

} // namespace d2
} // namespace playrho
