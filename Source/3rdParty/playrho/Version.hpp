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

#ifndef PLAYRHO_VERSION_HPP
#define PLAYRHO_VERSION_HPP

/// @file
/// @brief Definition of the @c Version class and closely related code.

#include <cstdint> // for std::std::int32_t
#include <string>

namespace playrho {

/// @brief Version numbering scheme.
/// @details Version class for numbering the PlayRho library releases. Follows
///   Semantic Versioning 2.0.0.
/// @see https://en.wikipedia.org/wiki/Software_versioning
/// @see https://semver.org
struct Version {
    /// @brief Revision number type.
    using Revnum = std::int32_t;

    /// @brief Major version number.
    /// @details Changed to represent significant changes. Specifically this field
    ///   is incremented when backwards incompatible changes are introduced to the
    ///   public API. The minor and revision fields are reset to 0 when this field
    ///   is incremented.
    /// @note Started at 0.
    Revnum major;

    /// @brief Minor version number.
    /// @details Changed to represent incremental changes. Specifically this field
    ///   is incremented when new, backwards compatible functionality is introduced
    ///   to the public API, or when any public API functionality is marked as
    ///   deprecated.
    Revnum minor;

    /// @brief Revision version number.
    /// @details Changed to represent bug fixes.
    /// @note Also known as the patch version.
    Revnum revision;
};

/// @brief Comparison function.
/// @return Less-than zero if left-hand-side argument is less than the right. Greater-than zero if left-hand-side argument is greater than the right.
///    Or zero if both arguments are the same.
constexpr auto compare(const Version& lhs, const Version& rhs) noexcept
{
    if (const auto diff = lhs.major - rhs.major) {
        return diff;
    }
    if (const auto diff = lhs.minor - rhs.minor) {
        return diff;
    }
    return lhs.revision - rhs.revision;
}

/// @brief Equality operator.
constexpr auto operator==(const Version& lhs, const Version& rhs) noexcept
{
    return compare(lhs, rhs) == 0;
}

/// @brief Inequality operator.
constexpr auto operator!=(const Version& lhs, const Version& rhs) noexcept
{
    return compare(lhs, rhs) != 0;
}

/// @brief Less-than  operator.
constexpr auto operator<(const Version& lhs, const Version& rhs) noexcept
{
    return compare(lhs, rhs) < 0;
}

/// @brief Less-than or equal-to  operator.
constexpr auto operator<=(const Version& lhs, const Version& rhs) noexcept
{
    return compare(lhs, rhs) <= 0;
}

/// @brief Greater-than  operator.
constexpr auto operator>(const Version& lhs, const Version& rhs) noexcept
{
    return compare(lhs, rhs) > 0;
}

/// @brief Greater-than or equal-to  operator.
constexpr auto operator>=(const Version& lhs, const Version& rhs) noexcept
{
    return compare(lhs, rhs) >= 0;
}

/// @brief Gets the version information of the library.
Version GetVersion() noexcept;

/// @brief Gets the build details of the library.
std::string GetBuildDetails();

} // namespace playrho

#endif // PLAYRHO_VERSION_HPP
