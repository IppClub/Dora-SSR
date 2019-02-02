/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#ifndef PLAYRHO_DYNAMICS_FIXTUREPROXY_HPP
#define PLAYRHO_DYNAMICS_FIXTUREPROXY_HPP

#include "PlayRho/Common/Settings.hpp"
#include "PlayRho/Collision/AABB.hpp"

namespace playrho {

/// @brief Fixture proxy.
/// @details This proxy is used internally to connect fixtures to the broad-phase.
/// @note This data structure is 4-bytes large (on at least one 64-bit platform).
struct FixtureProxy
{
    
    /// @brief Size type.
    using size_type = std::remove_const<decltype(MaxContacts)>::type;

    /// @brief Tree ID.
    /// @details This is the ID of the leaf node in the dynamic tree for this "proxy".
    /// @note 4-bytes.
    size_type treeId;
};

/// @brief Equality operator
/// @relatedalso FixtureProxy
PLAYRHO_CONSTEXPR inline bool operator== (const FixtureProxy& lhs, const FixtureProxy& rhs) noexcept
{
    return lhs.treeId == rhs.treeId;
}

/// @brief Inequality operator
/// @relatedalso FixtureProxy
PLAYRHO_CONSTEXPR inline bool operator!= (const FixtureProxy& lhs, const FixtureProxy& rhs) noexcept
{
    return !(lhs.treeId == rhs.treeId);
}

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_FIXTUREPROXY_HPP
