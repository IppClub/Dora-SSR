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

#ifndef PLAYRHO_TOUNDERLYING_HPP
#define PLAYRHO_TOUNDERLYING_HPP

/// @file
/// @brief Definition of @c to_underlying function template.

// IWYU pragma: begin_exports

#include "playrho/detail/underlying_type.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// Underlying-type convenience alias.
template <class T>
using underlying_type_t = typename detail::underlying_type<T>::type;

/// Converts the given value to the value as the underlying type.
/// @note This is like <code>std::to_underlying</code> slated for C++23.
template <typename T>
constexpr auto to_underlying(T value) noexcept -> underlying_type_t<T>
{
    return static_cast<underlying_type_t<T>>(value);
}

} // namespace playrho

#endif // PLAYRHO_TOUNDERLYING_HPP
