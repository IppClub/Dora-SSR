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

#ifndef PLAYRHO_OUTOFRANGE_HPP
#define PLAYRHO_OUTOFRANGE_HPP

#include <stdexcept> // for std::out_of_range
#include <string>

namespace playrho {

/// @brief Out-of-range exception with a range type & value.
/// @see std::out_of_range.
template <class T>
class OutOfRange: public std::out_of_range {
public:
    using type = T; ///< Type of the index whose value was out-of-range.

    using std::out_of_range::out_of_range;

    /// @brief Initializing constructor.
    OutOfRange(type v, const std::string& msg): out_of_range{msg}, value{v} {}

    /// @brief Initializing constructor.
    OutOfRange(type v, const char* msg): out_of_range{msg}, value{v} {}

    type value{}; ///< Value of the index that was out-of-range.
};

} // namespace playrho

#endif // PLAYRHO_OUTOFRANGE_HPP
