/*
 * Copyright (c) 2021 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COLLISION_SHAPES_SHAPEID_HPP
#define PLAYRHO_COLLISION_SHAPES_SHAPEID_HPP

#include "PlayRho/Common/IndexingNamedType.hpp"
#include "PlayRho/Common/Settings.hpp"

namespace playrho {

/// @brief Shape identifier.
using ShapeID = detail::IndexingNamedType<ShapeCounter, struct ShapeIdentifier>;

/// @brief Invalid fixture ID value.
constexpr auto InvalidShapeID = static_cast<ShapeID>(static_cast<ShapeID::underlying_type>(-1));

/// @brief Gets an invalid value for the ShapeID type.
template <>
constexpr ShapeID GetInvalid() noexcept
{
    return InvalidShapeID;
}

/// @brief Determines if the given value is valid.
template <>
constexpr bool IsValid(const ShapeID& value) noexcept
{
    return value != GetInvalid<ShapeID>();
}

} // namespace playrho

#endif // PLAYRHO_COLLISION_SHAPES_SHAPEID_HPP
