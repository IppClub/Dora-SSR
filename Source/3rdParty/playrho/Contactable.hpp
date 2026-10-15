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

#ifndef PLAYRHO_CONTACTABLE_HPP
#define PLAYRHO_CONTACTABLE_HPP

/// @file
/// @brief Definition of the <code>Contactable</code> class and closely related code.

#include <ostream>
#include <type_traits> // for std::is_nothrow_default_constructible_v, etc

// IWYU pragma: begin_exports

#include "playrho/Settings.hpp" // for ChildCounter
#include "playrho/ShapeID.hpp"
#include "playrho/BodyID.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Aggregate data for identifying one side (of two) in a contact.
/// @see Contact.
struct Contactable {
    /// @brief Identifier of the contactable body.
    BodyID bodyId;

    /// @brief Identifier of the contactable shape.
    ShapeID shapeId;

    /// @brief Child index of contactable Shape.
    ChildCounter childId;
};

// Confirms desired compile-time qualities & traits of Contactable...
static_assert(std::is_nothrow_default_constructible_v<Contactable>);
static_assert(std::is_nothrow_copy_constructible_v<Contactable>);
static_assert(std::is_nothrow_move_constructible_v<Contactable>);
static_assert(std::is_nothrow_copy_assignable_v<Contactable>);
static_assert(std::is_nothrow_move_assignable_v<Contactable>);
static_assert(std::is_trivially_copyable_v<Contactable>);

/// @brief Equality operator.
/// @relatedalso Contactable
constexpr bool operator==(const Contactable& lhs, const Contactable& rhs) noexcept
{
    return (lhs.bodyId == rhs.bodyId) // force line-break
        && (lhs.shapeId == rhs.shapeId) // force line-break
        && (lhs.childId == rhs.childId);
}

/// @brief Inequality operator.
/// @relatedalso Contactable
constexpr bool operator!=(const Contactable& lhs, const Contactable& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Less-than operator.
/// @relatedalso Contactable
constexpr bool operator<(const Contactable& lhs, const Contactable& rhs) noexcept
{
    if (lhs.bodyId < rhs.bodyId) {
        return true;
    }
    if (lhs.bodyId > rhs.bodyId) {
        return false;
    }
    if (lhs.shapeId < rhs.shapeId) {
        return true;
    }
    if (lhs.shapeId > rhs.shapeId) {
        return false;
    }
    return lhs.childId < rhs.childId;
}

/// @brief Is-for convenience function.
/// @return true if contactable is for the identified body and shape, else false.
constexpr bool IsFor(const Contactable& c, BodyID bodyID, ShapeID shapeID) noexcept
{
    return (c.bodyId == bodyID) && (c.shapeId == shapeID);
}

/// @brief Output stream operator support.
/// @relatedalso Contactable
inline auto operator<< (std::ostream &os, const Contactable &c) -> std::ostream&
{
    os << "{";
    os << to_underlying(c.bodyId);
    os << ",";
    os << to_underlying(c.shapeId);
    os << ",";
    os << c.childId;
    os << "}";
    return os;
}

}

#endif /* PLAYRHO_CONTACTABLE_HPP */
