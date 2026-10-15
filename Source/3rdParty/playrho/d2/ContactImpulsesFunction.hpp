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

#ifndef PLAYRHO_D2_CONTACTIMPULSESFUNCTION_HPP
#define PLAYRHO_D2_CONTACTIMPULSESFUNCTION_HPP

/// @file
/// @brief Definition of the <code>ContactImpulsesFunction</code> type alias.

#include <functional> // for std::function

// IWYU pragma: begin_exports

#include "playrho/ContactID.hpp"

#include "playrho/d2/ContactImpulsesList.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Contact-impulses function.
using ContactImpulsesFunction =
    std::function<void(ContactID, const ContactImpulsesList&, unsigned)>;

} // namespace playrho::d2

#endif // PLAYRHO_D2_CONTACTIMPULSESFUNCTION_HPP
