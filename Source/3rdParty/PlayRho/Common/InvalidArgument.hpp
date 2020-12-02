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

#ifndef PLAYRHO_COMMON_INVALIDARGUMENT_HPP
#define PLAYRHO_COMMON_INVALIDARGUMENT_HPP

#include "PlayRho/Defines.hpp"
#include <stdexcept>

namespace playrho {

/// @brief Invalid argument logic error.
/// @details Indicates that an argument to a function or method was invalid.
/// @ingroup ExceptionsGroup
class InvalidArgument: public std::invalid_argument
{
public:
    using std::invalid_argument::invalid_argument;
};

} // namespace playrho

#endif // PLAYRHO_COMMON_INVALIDARGUMENT_HPP
