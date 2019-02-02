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

#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/Body.hpp"

namespace playrho {
namespace d2 {

BodyConf GetBodyConf(const Body& body) noexcept
{
    auto def = BodyConf{};
    def.type = body.GetType();
    def.location = body.GetLocation();
    def.angle = body.GetAngle();
    def.linearVelocity = GetLinearVelocity(body);
    def.angularVelocity = GetAngularVelocity(body);
    def.linearAcceleration = body.GetLinearAcceleration();
    def.angularAcceleration = body.GetAngularAcceleration();
    def.linearDamping = body.GetLinearDamping();
    def.angularDamping = body.GetAngularDamping();
    def.underActiveTime = body.GetUnderActiveTime();
    def.allowSleep = body.IsSleepingAllowed();
    def.awake = body.IsAwake();
    def.fixedRotation = body.IsFixedRotation();
    def.bullet = body.IsAccelerable() && body.IsImpenetrable();
    def.enabled = body.IsEnabled();
    def.userData = body.GetUserData();
    return def;
}

} // namespace d2
} // namespace playrho
