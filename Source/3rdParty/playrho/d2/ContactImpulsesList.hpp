/*
 * Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_D2_CONTACTIMPULSESLIST_HPP
#define PLAYRHO_D2_CONTACTIMPULSESLIST_HPP

/// @file
/// @brief Definition of the @c ContactImpulsesList class and closely related code.

#include <algorithm>
#include <cassert>
#include <type_traits> // for std::remove_const_t

// IWYU pragma: begin_exports

#include "playrho/Settings.hpp"
#include "playrho/Units.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

class VelocityConstraint;

/// The contact impulse.
/// @details
/// Used for reporting. Impulses are used instead of forces because
/// sub-step forces may approach infinity for rigid body collisions. These
/// match up one-to-one with the contact points in Manifold.
class ContactImpulsesList
{
public:
    
    /// @brief Counter type.
    using Counter = std::remove_const_t<decltype(MaxManifoldPoints)>;
    
    /// @brief Gets the count.
    Counter GetCount() const noexcept { return count; }
    
    /// @brief Gets the given indexed entry normal.
    Momentum GetEntryNormal(Counter index) const noexcept
    {
        assert(index < MaxManifoldPoints);
        return normalImpulses[index]; // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
    }

    /// @brief Gets the given indexed entry tangent.
    Momentum GetEntryTanget(Counter index) const noexcept
    {
        assert(index < MaxManifoldPoints);
        return tangentImpulses[index]; // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
    }

    /// @brief Adds an entry of the given data.
    void AddEntry(Momentum normal, Momentum tangent) noexcept
    {
        assert(count < MaxManifoldPoints);
        normalImpulses[count] = normal; // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
        tangentImpulses[count] = tangent; // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
        ++count;
    }
    
private:
    Momentum normalImpulses[MaxManifoldPoints] = {}; ///< Normal impulses.
    Momentum tangentImpulses[MaxManifoldPoints] = {}; ///< Tangent impulses.
    Counter count = 0; ///< Count of entries added.
};

/// @brief Gets the maximum normal impulse from the given contact impulses list.
/// @relatedalso ContactImpulsesList
inline Momentum GetMaxNormalImpulse(const ContactImpulsesList& impulses) noexcept
{
    auto maxImpulse = 0_Ns;
    const auto count = impulses.GetCount();
    for (auto i = decltype(count){0}; i < count; ++i)
    {
        maxImpulse = std::max(maxImpulse, impulses.GetEntryNormal(i));
    }
    return maxImpulse;
}

/// @brief Gets the contact impulses for the given velocity constraint.
ContactImpulsesList GetContactImpulses(const VelocityConstraint& vc);

} // namespace playrho::d2

#endif // PLAYRHO_D2_CONTACTIMPULSESLIST_HPP
