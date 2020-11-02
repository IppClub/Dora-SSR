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

#include "PlayRho/Dynamics/WorldImplBody.hpp"

#include "PlayRho/Dynamics/WorldImpl.hpp"
#include "PlayRho/Dynamics/WorldImplFixture.hpp" // for GetDensity, GetMassData
#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/MovementConf.hpp"

#include "PlayRho/Dynamics/Contacts/Contact.hpp"

#include "PlayRho/Common/DynamicMemory.hpp"

#include <algorithm>
#include <new>
#include <functional>
#include <type_traits>
#include <memory>
#include <vector>

namespace playrho {
namespace d2 {

BodyCounter GetBodyRange(const WorldImpl& world) noexcept
{
    return world.GetBodyRange();
}

void Destroy(WorldImpl& world, BodyID id)
{
    world.Destroy(id);
}

BodyConf GetBodyConf(const WorldImpl& world, BodyID id)
{
    return GetBodyConf(world.GetBody(id));
}

BodyType GetType(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetType();
}

void SetType(WorldImpl& world, BodyID id, BodyType value)
{
    world.SetType(id, value);
}

bool IsImpenetrable(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).IsImpenetrable();
}

void SetImpenetrable(WorldImpl& world, BodyID id)
{
    world.GetBody(id).SetImpenetrable();
}

void UnsetImpenetrable(WorldImpl& world, BodyID id)
{
    world.GetBody(id).UnsetImpenetrable();
}

bool IsSleepingAllowed(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).IsSleepingAllowed();
}

void SetSleepingAllowed(WorldImpl& world, BodyID id, bool value)
{
    world.GetBody(id).SetSleepingAllowed(value);
}

Angle GetAngle(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetAngle();
}

Transformation GetTransformation(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetTransformation();
}

void SetTransformation(WorldImpl& world, BodyID id, Transformation xfm)
{
    world.SetTransformation(id, xfm);
}

Velocity GetVelocity(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetVelocity();
}

void SetVelocity(WorldImpl& world, BodyID id, const Velocity& value)
{
    world.GetBody(id).SetVelocity(value);
}

void UnsetAwake(WorldImpl& world, BodyID id)
{
    world.GetBody(id).UnsetAwake();
}

void SetAwake(WorldImpl& world, BodyID id)
{
    world.GetBody(id).SetAwake();
}

bool IsAwake(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).IsAwake();
}

Length2 GetLocalCenter(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetLocalCenter();
}

Length2 GetWorldCenter(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetWorldCenter();
}

LinearAcceleration2 GetLinearAcceleration(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetLinearAcceleration();
}

AngularAcceleration GetAngularAcceleration(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetAngularAcceleration();
}

void SetAcceleration(WorldImpl& world, BodyID id, LinearAcceleration2 linear, AngularAcceleration angular)
{
    ::playrho::d2::SetAcceleration(world.GetBody(id), linear, angular);
}

void SetAcceleration(WorldImpl& world, BodyID id, Acceleration value)
{
    ::playrho::d2::SetAcceleration(world.GetBody(id), value);
}

void SetAcceleration(WorldImpl& world, BodyID id, LinearAcceleration2 value)
{
    ::playrho::d2::SetAcceleration(world.GetBody(id), value);
}

void SetAcceleration(WorldImpl& world, BodyID id, AngularAcceleration value)
{
    ::playrho::d2::SetAcceleration(world.GetBody(id), value);
}

MassData ComputeMassData(const WorldImpl& world, BodyID id)
{
    return world.ComputeMassData(id);
}

void SetMassData(WorldImpl& world, BodyID id, const MassData& massData)
{
    world.SetMassData(id, massData);
}

InvMass GetInvMass(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetInvMass();
}

InvRotInertia GetInvRotInertia(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetInvRotInertia();
}

SizedRange<std::vector<std::pair<BodyID, JointID>>::const_iterator>
GetJoints(const WorldImpl& world, BodyID id)
{
    return world.GetJoints(id);
}

SizedRange<WorldImpl::Fixtures::const_iterator> GetFixtures(const WorldImpl& world, BodyID id)
{
    return world.GetFixtures(id);
}

void DestroyFixtures(WorldImpl& world, BodyID id)
{
    world.DestroyFixtures(id);
}

bool IsSpeedable(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).IsSpeedable();
}

bool IsAccelerable(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).IsAccelerable();
}

SizedRange<std::vector<KeyedContactPtr>::const_iterator>
GetContacts(const WorldImpl& world, BodyID id)
{
    return world.GetContacts(id);
}

bool IsMassDataDirty(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).IsMassDataDirty();
}

bool IsFixedRotation(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).IsFixedRotation();
}

void SetFixedRotation(WorldImpl& world, BodyID id, bool value)
{
    auto& body = world.GetBody(id);
    if (body.IsFixedRotation() != value)
    {
        body.SetFixedRotation(value);
        ResetMassData(world, id);
    }
}

bool IsEnabled(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).IsEnabled();
}

void SetEnabled(WorldImpl& world, BodyID body, bool flag)
{
    world.SetEnabled(body, flag);
}

Frequency GetLinearDamping(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetLinearDamping();
}

void SetLinearDamping(WorldImpl& world, BodyID id, NonNegative<Frequency> value)
{
    world.GetBody(id).SetLinearDamping(value);
}

Frequency GetAngularDamping(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id).GetAngularDamping();
}

void SetAngularDamping(WorldImpl& world, BodyID id, NonNegative<Frequency> value)
{
    world.GetBody(id).SetAngularDamping(value);
}

} // namespace d2
} // namespace playrho
