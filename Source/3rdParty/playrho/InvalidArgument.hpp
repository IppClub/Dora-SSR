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

#ifndef PLAYRHO_INVALIDARGUMENT_HPP
#define PLAYRHO_INVALIDARGUMENT_HPP

/// @file
/// @brief Definition of the @c InvalidArgument class.

#include <stdexcept>
#include <string>
#include <utility> // for std::move

namespace playrho {

/// @brief Invalid argument logic error.
/// @details Indicates that an argument to a function was invalid.
/// @ingroup ExceptionsGroup
class InvalidArgument: public std::invalid_argument
{
public:
    using std::invalid_argument::invalid_argument;
};

/// @brief Was destroyed invalid argument logic error.
/// @details Indicates that an argument was invalid because it's destroyed or associated
///   with something that has been destroyed and is not currently valid for the requested
///   functionality.
/// @ingroup ExceptionsGroup
template <class T>
struct WasDestroyed: public InvalidArgument
{
    using type = T; ///< Type of the argument that was destroyed.

    /// @brief Initializing constructor.
    WasDestroyed(type v, const std::string& msg): InvalidArgument{msg}, value{std::move(v)} {}

    /// @brief Initializing constructor.
    WasDestroyed(type v, const char* msg): InvalidArgument{msg}, value{std::move(v)} {}

    type value{}; ///< Value of the type that was destroyed.
};

} // namespace playrho

#endif // PLAYRHO_INVALIDARGUMENT_HPP
