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

#ifndef PLAYRHO_CONTACTKEY_HPP
#define PLAYRHO_CONTACTKEY_HPP

/// @file
/// @brief Declaration of the <code>ContactKey</code> class and closely related code.

#include <cstdlib> // for std::size_t
#include <algorithm>
#include <functional>
#include <utility>

// IWYU pragma: begin_exports

#include "playrho/Settings.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Key value class for contacts.
class ContactKey
{
public:
    /// @brief Default constructor.
    constexpr ContactKey() noexcept = default;

    /// @brief Initializing constructor.
    constexpr ContactKey(ContactCounter fp1, ContactCounter fp2) noexcept
        : m_ids{std::minmax(fp1, fp2)}
    {
        // Intentionally empty
    }

    /// @brief Gets the minimum index value.
    constexpr ContactCounter GetMin() const noexcept
    {
        return std::get<0>(m_ids);
    }

    /// @brief Gets the maximum index value.
    constexpr ContactCounter GetMax() const noexcept
    {
        return std::get<1>(m_ids);
    }

private:
    /// @brief The contact counter ID pair.
    /// @note Uses <code>std::pair</code> given that <code>std::minmax</code> returns
    ///   this type making it the most natural type for this class.
    std::pair<ContactCounter, ContactCounter> m_ids{static_cast<ContactCounter>(-1),
                                                    static_cast<ContactCounter>(-1)};
};

/// @brief Equality operator.
constexpr bool operator==(const ContactKey& lhs, const ContactKey& rhs) noexcept
{
    return (lhs.GetMin() == rhs.GetMin()) && (lhs.GetMax() == rhs.GetMax());
}

/// @brief Inequality operator.
constexpr bool operator!=(const ContactKey& lhs, const ContactKey& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Less-than operator.
constexpr bool operator<(const ContactKey& lhs, const ContactKey& rhs) noexcept
{
    return (lhs.GetMin() < rhs.GetMin()) ||
           ((lhs.GetMin() == rhs.GetMin()) && (lhs.GetMax() < rhs.GetMax()));
}

/// @brief Less-than or equal-to operator.
constexpr bool operator<=(const ContactKey& lhs, const ContactKey& rhs) noexcept
{
    return (lhs.GetMin() < rhs.GetMin()) ||
           ((lhs.GetMin() == rhs.GetMin()) && (lhs.GetMax() <= rhs.GetMax()));
}

/// @brief Greater-than operator.
constexpr bool operator>(const ContactKey& lhs, const ContactKey& rhs) noexcept
{
    return (lhs.GetMin() > rhs.GetMin()) ||
           ((lhs.GetMin() == rhs.GetMin()) && (lhs.GetMax() > rhs.GetMax()));
}

/// @brief Greater-than or equal-to operator.
constexpr bool operator>=(const ContactKey& lhs, const ContactKey& rhs) noexcept
{
    return (lhs.GetMin() > rhs.GetMin()) ||
           ((lhs.GetMin() == rhs.GetMin()) && (lhs.GetMax() >= rhs.GetMax()));
}

} // namespace playrho

/// @brief Hash function object specialization for <code>ContactKey</code>.
template <>
struct std::hash<playrho::ContactKey> {
    /// @brief Argument type.
    using argument_type = playrho::ContactKey;

    /// @brief Result type.
    using result_type = std::size_t;

    /// @brief Function object operator.
    constexpr std::size_t operator()(const playrho::ContactKey& key) const
    {
        // Use simple and fast Knuth multiplicative hash...
        const auto a = std::size_t{key.GetMin()} * 2654435761u;
        const auto b = std::size_t{key.GetMax()} * 2654435761u;
        return a ^ b;
    }
};

#endif // PLAYRHO_CONTACTKEY_HPP
