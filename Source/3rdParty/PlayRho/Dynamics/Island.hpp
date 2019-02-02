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

#ifndef PLAYRHO_DYNAMICS_ISLAND_HPP
#define PLAYRHO_DYNAMICS_ISLAND_HPP

#include "PlayRho/Common/Math.hpp"
#include <vector>

namespace playrho {
namespace d2 {

class Body;
class Contact;
class Joint;

/// @brief Definition of a self-contained constraint "island".
/// @details A container of bodies contacts and joints relevant to handling world dynamics.
/// @note This is an internal class.
/// @note This data structure is 72-bytes large (on at least one 64-bit platform).
struct Island
{   
    /// @brief Body container type.
    using Bodies = std::vector<Body*>;

    /// @brief Contact container type.
    using Contacts = std::vector<Contact*>;
    
    /// @brief Joint container type.
    using Joints = std::vector<Joint*>;
    
    /// @brief Initializing constructor.
    Island(Bodies::size_type bodyCapacity, Contacts::size_type contactCapacity,
           Joints::size_type jointCapacity);

    /// @brief Copy constructor.
    Island(const Island& copy) = default;

    /// @brief Move constructor.
    Island(Island&& other) noexcept = default;

    /// Destructor.
    ~Island() = default;

    /// @brief Copy assignment operator.
    Island& operator= (const Island& other) = default;

    /// @brief Assignment operator.
    Island& operator= (Island&& other) noexcept = default;

    Bodies m_bodies; ///< Body container.
    Contacts m_contacts; ///< Contact container.
    Joints m_joints; ///< Joint container.
};

/// @brief Determines whether the given island is full of bodies.
/// @relatedalso Island
inline bool IsFullOfBodies(const Island& island)
{
    return IsFull(island.m_bodies);
}

/// @brief Determines whether the given island is full of contacts.
/// @relatedalso Island
inline bool IsFullOfContacts(const Island& island)
{
    return IsFull(island.m_contacts);
}

/// @brief Counts the number of occurrences of the given entry in the given island.
/// @relatedalso Island
std::size_t Count(const Island& island, const Body* entry);

/// @brief Counts the number of occurrences of the given entry in the given island.
/// @relatedalso Island
std::size_t Count(const Island& island, const Contact* entry);

/// @brief Counts the number of occurrences of the given entry in the given island.
/// @relatedalso Island
std::size_t Count(const Island& island, const Joint* entry);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_ISLAND_HPP
