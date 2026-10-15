/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "playrho/d2/Body.hpp"
#include "playrho/d2/BodyConf.hpp"
#include "playrho/d2/Transformation.hpp"
#include "playrho/d2/UnitVec.hpp"

namespace playrho::d2 {

BodyConf GetBodyConf(const Body& body)
{
    auto def = BodyConf{};
    def.type = GetType(body);
    def.sweep = GetSweep(body);
    def.invMass = GetInvMass(body);
    def.invRotI = GetInvRotInertia(body);
    def.linearVelocity = GetLinearVelocity(body);
    def.angularVelocity = GetAngularVelocity(body);
    def.linearAcceleration = GetLinearAcceleration(body);
    def.angularAcceleration = GetAngularAcceleration(body);
    def.linearDamping = GetLinearDamping(body);
    def.angularDamping = GetAngularDamping(body);
    def.underActiveTime = GetUnderActiveTime(body);
    def.shapes = GetShapes(body);
    def.allowSleep = IsSleepingAllowed(body);
    def.awake = IsAwake(body);
    def.fixedRotation = IsFixedRotation(body);
    def.bullet = IsAccelerable(body) && IsImpenetrable(body);
    def.enabled = IsEnabled(body);
    def.massDataDirty = IsMassDataDirty(body);
    return def;
}

} // namespace playrho::d2
