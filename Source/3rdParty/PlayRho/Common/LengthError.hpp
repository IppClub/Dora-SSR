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

#ifndef PLAYRHO_COMMON_LENGTHERROR_HPP
#define PLAYRHO_COMMON_LENGTHERROR_HPP

#include <stdexcept>

namespace playrho {

/// @brief Length based logic error.
/// @details The exception used to indicate that an operation would produce a
///   result that exceeded an object's maximum size.
/// @ingroup ExceptionsGroup
class LengthError: public std::length_error
{
public:
    using std::length_error::length_error;
};

} // namespace playrho


#endif // PLAYRHO_COMMON_LENGTHERROR_HPP
