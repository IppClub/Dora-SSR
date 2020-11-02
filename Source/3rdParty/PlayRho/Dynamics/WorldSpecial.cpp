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

#include "PlayRho/Dynamics/World.hpp"

#include "PlayRho/Dynamics/WorldImpl.hpp" // for completing WorldImpl type
#include "PlayRho/Dynamics/WorldImplMisc.hpp"
#include "PlayRho/Dynamics/Body.hpp" // for completing WorldImpl type
#include "PlayRho/Dynamics/Contacts/Contact.hpp" // for completing WorldImpl type
#include "PlayRho/Collision/Manifold.hpp" // for completing WorldImpl type

namespace playrho {
namespace d2 {

World::World(const WorldConf& def): m_impl{CreateWorldImpl(def)}
{
}

World::World(const World& other): m_impl{CreateWorldImpl(*other.m_impl)}
{
}

World::~World() noexcept
{
    if (m_impl) {
        // Call implementation's clear while World still valid to give destruction
        // listening callbacks chance to run while world data is still valid.
        m_impl->Clear();
    }
}

World& World::operator= (const World& other)
{
    *m_impl = *other.m_impl;
    return *this;
}

} // namespace d2
} // namespace playrho
