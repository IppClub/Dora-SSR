/*
 * Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_FIXTUREID_HPP
#define PLAYRHO_DYNAMICS_FIXTUREID_HPP

#include "PlayRho/Common/StrongType.hpp"
#include "PlayRho/Common/Settings.hpp"

namespace playrho {

/// @brief Fixture identifier.
using FixtureID = strongtype::IndexingNamedType<FixtureCounter, struct FixtureIdentifier>;

/// @brief Invalid fixture ID value.
constexpr auto InvalidFixtureID =
    static_cast<FixtureID>(static_cast<FixtureID::underlying_type>(-1));

/// @brief Gets an invalid value for the FixtureID type.
template <>
constexpr FixtureID GetInvalid() noexcept
{
    return InvalidFixtureID;
}

/// @brief Determines if the given value is valid.
template <>
constexpr bool IsValid(const FixtureID& value) noexcept
{
    return value != GetInvalid<FixtureID>();
}

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_FIXTUREID_HPP
