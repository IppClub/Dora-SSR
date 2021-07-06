/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_ISLAND_HPP
#define PLAYRHO_DYNAMICS_ISLAND_HPP

#include "PlayRho/Common/Templates.hpp" // IsFull
#include "PlayRho/Common/Settings.hpp" // BodyCounter, ContactCounter, JointCounter

#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/Joints/JointID.hpp"
#include "PlayRho/Dynamics/Contacts/ContactID.hpp"

#include <vector>

namespace playrho {
namespace d2 {

/// @brief Definition of a self-contained constraint "island".
/// @details A container of bodies contacts and joints relevant to handling world dynamics.
/// @note This is an internal class.
/// @note This data structure is 72-bytes large (on at least one 64-bit platform).
struct Island
{
    /// @brief Container type for body identifiers.
    using Bodies = std::vector<BodyID>;

    /// @brief Container type for contact identifiers.
    using Contacts = std::vector<ContactID>;

    /// @brief Container type for joint identifiers.
    using Joints = std::vector<JointID>;

    Bodies bodies; ///< Container of body identifiers.
    Contacts contacts; ///< Container of contact identifiers.
    Joints joints; ///< Container of joint identifiers.
};

/// @brief Reserves space ahead of time.
/// @relatedalso Island
void Reserve(Island& island, BodyCounter bodies, ContactCounter contacts, JointCounter joints);

/// @brief Clears the island containers.
/// @relatedalso Island
void Clear(Island& island) noexcept;

/// @brief Sorts the island containers.
/// @relatedalso Island
void Sort(Island& island) noexcept;

/// @brief Determines whether the given island is full of bodies.
/// @relatedalso Island
inline bool IsFullOfBodies(const Island& island)
{
    return IsFull(island.bodies);
}

/// @brief Determines whether the given island is full of contacts.
/// @relatedalso Island
inline bool IsFullOfContacts(const Island& island)
{
    return IsFull(island.contacts);
}

/// @brief Counts the number of occurrences of the given entry in the given island.
/// @relatedalso Island
std::size_t Count(const Island& island, BodyID entry);

/// @brief Counts the number of occurrences of the given entry in the given island.
/// @relatedalso Island
std::size_t Count(const Island& island, ContactID entry);

/// @brief Counts the number of occurrences of the given entry in the given island.
/// @relatedalso Island
std::size_t Count(const Island& island, JointID entry);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_ISLAND_HPP
