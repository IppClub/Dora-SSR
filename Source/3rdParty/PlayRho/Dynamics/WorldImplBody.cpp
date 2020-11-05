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

BodyID CreateBody(WorldImpl& world, const BodyConf& def)
{
    return world.CreateBody(def);
}

const Body& GetBody(const WorldImpl& world, BodyID id)
{
    return world.GetBody(id);
}

void SetBody(WorldImpl& world, BodyID id, const Body& value)
{
    world.SetBody(id, value);
}

void Destroy(WorldImpl& world, BodyID id)
{
    world.Destroy(id);
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

SizedRange<std::vector<KeyedContactPtr>::const_iterator>
GetContacts(const WorldImpl& world, BodyID id)
{
    return world.GetContacts(id);
}

} // namespace d2
} // namespace playrho
