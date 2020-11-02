/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Dynamics/Contacts/Contact.hpp"

#include "PlayRho/Collision/Collision.hpp"
#include "PlayRho/Collision/Distance.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible<Contact>::value,
              "Contact must be default constructible!");
static_assert(std::is_copy_constructible<Contact>::value,
              "Contact must be copy constructible!");
static_assert(std::is_move_constructible<Contact>::value,
              "Contact must be move constructible!");
static_assert(std::is_copy_assignable<Contact>::value,
              "Contact must be copy assignable!");
static_assert(std::is_move_assignable<Contact>::value,
              "Contact must be move assignable!");
static_assert(std::is_nothrow_destructible<Contact>::value,
              "Contact must be nothrow destructible!");

Contact::Contact(BodyID bA, FixtureID fA, ChildCounter iA,
                 BodyID bB, FixtureID fB, ChildCounter iB) noexcept:
    m_bodyA{bA}, m_bodyB{bB}, m_fixtureA{fA}, m_fixtureB{fB}, m_indexA{iA}, m_indexB{iB}
{
    assert(bA != bB);
    assert(fA != fB);
}

// Free functions...

} // namespace d2
} // namespace playrho
