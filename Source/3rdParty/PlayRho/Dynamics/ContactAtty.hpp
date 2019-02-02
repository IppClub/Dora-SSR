/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_CONTACTATTY_HPP
#define PLAYRHO_DYNAMICS_CONTACTATTY_HPP

/// @file
/// Declaration of the ContactAtty class.

#include "PlayRho/Dynamics/Contacts/Contact.hpp"

namespace playrho {
namespace d2 {

/// @brief Contact attorney.
///
/// @details This is the "contact attorney" which provides limited privileged access to the
///   Contact class for the World class.
///
/// @note This class uses the "attorney-client" idiom to control the granularity of
///   friend-based access to the Contact class. This is meant to help preserve and enforce
///   the invariants of the Contact class.
///
/// @sa https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Friendship_and_the_Attorney-Client
///
class ContactAtty
{
private:

    /// @brief Gets the mutable manifold.
    static Manifold& GetMutableManifold(Contact& c) noexcept
    {
        return c.GetMutableManifold();
    }
    
    /// @brief Copies the flags from the given from contact to the given to contact.
    static void CopyFlags(Contact& to, const Contact& from) noexcept
    {
        to.m_flags = from.m_flags;
    }

    /// @brief Calls the contact's set TOI method.
    static void SetToi(Contact& c, Real value) noexcept
    {
        c.SetToi(value);
    }
    
    /// @brief Calls the contacts unset TOI method.
    static void UnsetToi(Contact& c) noexcept
    {
        c.UnsetToi();
    }
    
    /// @brief Increments the given contact's TOI count.
    static void IncrementToiCount(Contact& c) noexcept
    {
        ++c.m_toiCount;
    }
    
    /// @brief Calls the given contact's set TOI count method.
    static void SetToiCount(Contact& c, Contact::substep_type value) noexcept
    {
        c.SetToiCount(value);
    }

    /// @brief Calls the given contact's set TOI count method with a value of 0.
    static void ResetToiCount(Contact& c) noexcept
    {
        c.SetToiCount(0);
    }
    
    /// @brief Unflags the given contact's for filtering state.
    static void UnflagForFiltering(Contact& c) noexcept
    {
        c.UnflagForFiltering();
    }
    
    /// @brief Calls the given contact's <code>Contact::Update</code> method.
    static void Update(Contact& c, const Contact::UpdateConf& conf, ContactListener* listener)
    {
        c.Update(conf, listener);
    }
    
    /// @brief Whether the given contact is in the is-in-island state.
    static bool IsIslanded(const Contact& c) noexcept
    {
        return c.IsIslanded();
    }
    
    /// @brief Sets the given contact's is-in-island state.
    static void SetIslanded(Contact& c) noexcept
    {
        c.SetIslanded();
    }
    
    /// @brief Unsets the given contact's is-in-island state.
    static void UnsetIslanded(Contact& c) noexcept
    {
        c.UnsetIslanded();
    }
    
    friend class World;
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTATTY_HPP
