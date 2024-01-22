/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_FILTER_HPP
#define PLAYRHO_FILTER_HPP

/// @file
/// @brief Declarations of the Filter class and any free functions associated with it.

#include <cstdint> // for std::int16_t

namespace playrho {

/// @brief A holder for contact filtering data.
/// @note This data structure size is 9-bytes.
struct Filter {
    /// @brief Bits type definition.
    using bits_type = std::uint32_t;

    /// @brief Index type definition.
    using index_type = std::int8_t;

    /// @brief Default category bits.
    static constexpr auto DefaultCategoryBits = bits_type(0x1);

    /// @brief Default mask bits.
    static constexpr auto DefaultMaskBits = bits_type(~0u);

    /// @brief Default group index.
    static constexpr auto DefaultGroupIndex = index_type{0};

    /// @brief The collision category bits.
    /// @note Normally you would just set one bit.
    bits_type categoryBits = DefaultCategoryBits;

    /// @brief The collision mask bits.
    /// @details This states the categories that this shape would accept for collision.
    bits_type maskBits = DefaultMaskBits;

    /// @brief Group index.
    /// @details Collision groups allow a certain group of objects to never collide
    ///   (negative) or always collide (positive). Zero means no collision group.
    ///    Non-zero group filtering always wins against the mask bits.
    index_type groupIndex = DefaultGroupIndex;
};

/// @brief Equality operator.
/// @relatedalso Filter
constexpr bool operator==(const Filter lhs, const Filter rhs) noexcept
{
    return lhs.categoryBits == rhs.categoryBits && lhs.maskBits == rhs.maskBits &&
           lhs.groupIndex == rhs.groupIndex;
}

/// @brief Inequality operator.
/// @relatedalso Filter
constexpr bool operator!=(const Filter lhs, const Filter rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Determines whether collision processing should be performed.
/// @relatedalso Filter
inline bool ShouldCollide(const Filter filterA, const Filter filterB) noexcept
{
    return ((filterA.maskBits & filterB.categoryBits) != 0) &&
           ((filterB.maskBits & filterA.categoryBits) != 0);
}

} // namespace playrho

#endif // PLAYRHO_FILTER_HPP
