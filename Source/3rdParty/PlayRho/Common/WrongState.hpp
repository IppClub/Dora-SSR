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

#ifndef PLAYRHO_COMMON_WRONGSTATE_HPP
#define PLAYRHO_COMMON_WRONGSTATE_HPP

#include <stdexcept>

namespace playrho {

    /// @brief Wrong state logic error.
    /// @details Indicates that a method was called on an object in the wrong state for
    ///   its operation.
    /// @ingroup ExceptionsGroup
    class WrongState: public std::logic_error
    {
    public:
        using std::logic_error::logic_error;
    };

} // namespace playrho

#endif // PLAYRHO_COMMON_WRONGSTATE_HPP
