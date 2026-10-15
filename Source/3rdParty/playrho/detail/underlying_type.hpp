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

#ifndef PLAYRHO_DETAIL_UNDERLYINGTYPE_HPP
#define PLAYRHO_DETAIL_UNDERLYINGTYPE_HPP

/// @file
/// @brief Definition of @c underlying_type trait class and related code.

// IWYU pragma: private, include "playrho/to_underlying.hpp"

#include <type_traits> // for std::void_t, std::is_nothrow_default_constructible_v

namespace playrho::detail {

/// Primary template handles types that have no nested @c type member.
/// @see https://en.cppreference.com/w/cpp/types/void_t
template<class, class = void>
struct has_underlying_type_member : std::false_type {};

/// Specialization recognizes types that do have a nested @c type member.
/// @see https://en.cppreference.com/w/cpp/types/void_t
template<class T>
struct has_underlying_type_member<T, std::void_t<typename T::underlying_type>> : std::true_type {};

/// Underlying-type template class.
template <class T, class Enable = void>
struct underlying_type {};

/// Underlying-type class specialization for enum types.
template <class T>
struct underlying_type<T, std::enable_if_t<std::is_enum_v<T>>>
{
    /// @brief Type alias of the underlying type.
    using type = std::underlying_type_t<T>;
};

/// Underlying-type template class for <code>detail::IndexingNamedType</code> types.
template <class T>
struct underlying_type<T, std::enable_if_t<has_underlying_type_member<T>::value>>
{
    /// @brief Type alias of the underlying type.
    using type = typename T::underlying_type;
};

} // namespace playrho::detail

#endif // PLAYRHO_DETAIL_UNDERLYINGTYPE_HPP

