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

#ifndef PLAYRHO_DYNAMICS_CONTACTS_CONTACTID_HPP
#define PLAYRHO_DYNAMICS_CONTACTS_CONTACTID_HPP

#include "PlayRho/Common/StrongType.hpp"
#include "PlayRho/Common/Settings.hpp"

namespace playrho {

/// @brief Contact identifier.
using ContactID = strongtype::IndexingNamedType<ContactCounter, struct ContactIdentifier>;

/// @brief Invalid contact ID value.
constexpr auto InvalidContactID =
    static_cast<ContactID>(static_cast<ContactID::underlying_type>(-1));

/// @brief Gets an invalid value for the ContactID type.
template <>
constexpr ContactID GetInvalid() noexcept
{
    return InvalidContactID;
}

/// @brief Determines if the given value is valid.
template <>
constexpr bool IsValid(const ContactID& value) noexcept
{
    return value != GetInvalid<ContactID>();
}

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTS_CONTACTID_HPP
