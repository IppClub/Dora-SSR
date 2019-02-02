/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_CONTACTIMPULSESLIST_HPP
#define PLAYRHO_DYNAMICS_CONTACTIMPULSESLIST_HPP

#include "PlayRho/Common/Settings.hpp"
#include <algorithm>

namespace playrho {
namespace d2 {

class VelocityConstraint;

/// Contact Impulse.
/// @details
/// Used for reporting. Impulses are used instead of forces because
/// sub-step forces may approach infinity for rigid body collisions. These
/// match up one-to-one with the contact points in Manifold.
class ContactImpulsesList
{
public:
    
    /// @brief Counter type.
    using Counter = std::remove_const<decltype(MaxManifoldPoints)>::type;
    
    /// @brief Gets the count.
    Counter GetCount() const noexcept { return count; }
    
    /// @brief Gets the given indexed entry normal.
    Momentum GetEntryNormal(Counter index) const noexcept { return normalImpulses[index]; }
    
    /// @brief Gets the given indexed entry tangent.
    Momentum GetEntryTanget(Counter index) const noexcept { return tangentImpulses[index]; }
    
    /// @brief Adds an entry of the given data.
    void AddEntry(Momentum normal, Momentum tangent) noexcept
    {
        assert(count < MaxManifoldPoints);
        normalImpulses[count] = normal;
        tangentImpulses[count] = tangent;
        ++count;
    }
    
private:
    Momentum normalImpulses[MaxManifoldPoints]; ///< Normal impulses.
    Momentum tangentImpulses[MaxManifoldPoints]; ///< Tangent impulses.
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

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTIMPULSESLIST_HPP
