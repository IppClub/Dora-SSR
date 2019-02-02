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

#ifndef PLAYRHO_DYNAMICS_WORLDCONF_HPP
#define PLAYRHO_DYNAMICS_WORLDCONF_HPP

/// @file
/// Declarations of the WorldConf class.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/BoundedValue.hpp"

namespace playrho {
namespace d2 {

/// @brief World configuration data.
struct WorldConf
{
    /// @brief Uses the given min vertex radius value.
    PLAYRHO_CONSTEXPR inline WorldConf& UseMinVertexRadius(Positive<Length> value) noexcept;
    
    /// @brief Uses the given max vertex radius value.
    PLAYRHO_CONSTEXPR inline WorldConf& UseMaxVertexRadius(Positive<Length> value) noexcept;
    
    /// @brief Uses the given value as the initial dynamic tree size.
    PLAYRHO_CONSTEXPR inline WorldConf& UseInitialTreeSize(ContactCounter value) noexcept;
    
    /// @brief Minimum vertex radius.
    /// @details This is the minimum vertex radius that this world establishes which bodies
    ///    shall allow fixtures to be created with. Trying to create a fixture with a shape
    ///    having a smaller vertex radius shall be rejected with a <code>nullptr</code>
    ///    returned value.
    /// @note This value probably should not be changed except to experiment with what
    ///    can happen.
    /// @note Making it smaller means some shapes could have insufficient buffer for
    ///    continuous collision.
    /// @note Making it larger may create artifacts for vertex collision.
    Positive<Length> minVertexRadius = DefaultMinVertexRadius;
    
    /// @brief Maximum vertex radius.
    /// @details This is the maximum vertex radius that this world establishes which bodies
    ///    shall allow fixtures to be created with. Trying to create a fixture with a shape
    ///    having a larger vertex radius shall be rejected with a <code>nullptr</code>
    ///    returned value.
    Positive<Length> maxVertexRadius = DefaultMaxVertexRadius;
    
    /// @brief Initial tree size.
    ContactCounter initialTreeSize = 4096;
};

PLAYRHO_CONSTEXPR inline WorldConf& WorldConf::UseMinVertexRadius(Positive<Length> value) noexcept
{
    minVertexRadius = value;
    return *this;
}

PLAYRHO_CONSTEXPR inline WorldConf& WorldConf::UseMaxVertexRadius(Positive<Length> value) noexcept
{
    maxVertexRadius = value;
    return *this;
}

PLAYRHO_CONSTEXPR inline WorldConf& WorldConf::UseInitialTreeSize(ContactCounter value) noexcept
{
    initialTreeSize = value;
    return *this;
}

/// Gets the default definitions value.
/// @note This method exists as a work-around for providing the World constructor a default
///   value without otherwise getting a compiler error such as:
///     "cannot use defaulted constructor of '<code>Conf</code>' within '<code>World</code>'
///     outside of member functions because 'gravity' has an initializer"
/// @relatedalso WorldConf
PLAYRHO_CONSTEXPR inline WorldConf GetDefaultWorldConf() noexcept
{
    return WorldConf{};
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDCONF_HPP
