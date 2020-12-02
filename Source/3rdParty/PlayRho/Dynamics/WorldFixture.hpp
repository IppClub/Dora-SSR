/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_WORLDFIXTURE_HPP
#define PLAYRHO_DYNAMICS_WORLDFIXTURE_HPP

/// @file
/// Declarations of free functions of World for fixtures identified by <code>FixtureID</code>.
/// @details This is a collection of non-member non-friend functions - also called "free"
///   functions - that are related to fixtures within an instance of a <code>World</code>.
///   Many are just "wrappers" to similarly named member functions but some are additional
///   functionality built on those member functions. A benefit to using free functions that
///   are now just wrappers, is that of helping to isolate your code from future changes that
///   might occur to the underlying <code>World</code> member functions. Free functions in
///   this sense are "cheap" abstractions. While using these incurs extra run-time overhead
///   when compiled without any compiler optimizations enabled, enabling optimizations
///   should entirely eliminate that overhead.
/// @note The four basic categories of these functions are "CRUD": create, read, update,
///   and delete.
/// @see World, FixtureID.
/// @see https://en.wikipedia.org/wiki/Create,_read,_update_and_delete.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Range.hpp" // for SizedRange

#include "PlayRho/Collision/MassData.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"

#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/FixtureID.hpp"
#include "PlayRho/Dynamics/FixtureConf.hpp"

#include <iterator>
#include <vector>

namespace playrho {

struct Filter;

namespace d2 {

class World;

/// @example WorldFixture.cpp
/// This is the <code>googletest</code> based unit testing file for the free function
///   interfaces to <code>playrho::d2::World</code> fixture member functions and additional
///   functionality.

/// @brief Gets the extent of the currently valid fixture range.
/// @note This is one higher than the maxium <code>FixtureID</code> that is in range
///   for fixture related functions.
/// @see CreateFixture(World& world, FixtureConf).
/// @relatedalso World
FixtureCounter GetFixtureRange(const World& world) noexcept;

/// @brief Gets the count of fixtures in the given world.
/// @return Value that's less than or equal to what's returned by
///   <code>GetFixtureRange(const World& world)</code>.
/// @throws WrongState if called while the world is "locked".
/// @see GetFixtureRange(const World& world).
/// @relatedalso World
FixtureCounter GetFixtureCount(const World& world) noexcept;

/// @brief Creates a fixture within the specified world.
/// @throws WrongState if called while the world is "locked".
/// @throws std::out_of_range If given an invalid body identifier in the configuration.
/// @see CreateFixture(World&, BodyID, const Shape&,FixtureConf,bool).
/// @relatedalso World
FixtureID CreateFixture(World& world, FixtureConf def = FixtureConf{}, bool resetMassData = true);

/// @brief Creates a fixture within the specified world.
/// @throws WrongState if called while the world is "locked".
/// @throws std::out_of_range If given an invalid body identifier.
/// @see CreateFixture(World& world, FixtureConf def).
/// @relatedalso World
FixtureID CreateFixture(World& world, BodyID id, const Shape& shape,
                        FixtureConf def = FixtureConf{},
                        bool resetMassData = true);

/// @brief Creates a fixture within the specified world using a configuration of a shape.
/// @details This is a convenience function for allowing limited implicit conversions to shapes.
/// @throws WrongState if called while the world is "locked".
/// @throws std::out_of_range If given an invalid body identifier.
/// @see CreateFixture(World& world, FixtureConf def).
/// @relatedalso World
template <typename T>
FixtureID CreateFixture(World& world, BodyID id, const T& shapeConf,
                        FixtureConf def = FixtureConf{},
                        bool resetMassData = true)
{
    return CreateFixture(world, id, Shape{shapeConf}, def, resetMassData);
}

/// @brief Destroys the identified fixture.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @relatedalso World
bool Destroy(World& world, FixtureID id, bool resetMassData = true);

/// @brief Gets the filter data for the identified fixture.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @see SetFilterData.
/// @relatedalso World
Filter GetFilterData(const World& world, FixtureID id);

/// @brief Sets the contact filtering data.
/// @note This won't update contacts until the next time step when either parent body
///    is speedable and awake.
/// @note This automatically refilters contacts.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @see GetFilterData.
/// @relatedalso World
void SetFilterData(World& world, FixtureID id, const Filter& filter);

/// @brief Gets the identifier of the body associated with the identified fixture.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @relatedalso World
BodyID GetBody(const World& world, FixtureID id);

/// @brief Gets the transformation associated with the given fixture.
/// @warning Behavior is undefined if the fixture doesn't have an associated body - i.e.
///   behavior is undefined if the fixture has <code>nullptr</code> as its associated body.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @relatedalso World
Transformation GetTransformation(const World& world, FixtureID id);

/// @brief Gets the shape associated with the identified fixture.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @relatedalso World
const Shape& GetShape(const World& world, FixtureID id);

/// @brief Gets the coefficient of friction of the specified fixture.
/// @return Value of 0 or higher.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @relatedalso World
inline Real GetFriction(const World& world, FixtureID id)
{
    return GetFriction(GetShape(world, id));
}

/// @brief Gets the coefficient of restitution of the specified fixture.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @relatedalso World
inline Real GetRestitution(const World& world, FixtureID id)
{
    return GetRestitution(GetShape(world, id));
}

/// @brief Is the specified fixture a sensor (non-solid)?
/// @return the true if the fixture is a sensor.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @see SetSensor.
/// @relatedalso World
bool IsSensor(const World& world, FixtureID id);

/// @brief Sets whether the fixture is a sensor or not.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @see IsSensor.
/// @relatedalso World
void SetSensor(World& world, FixtureID id, bool value);

/// @brief Gets the density of this fixture.
/// @return Non-negative density (in mass per area).
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @relatedalso World
AreaDensity GetDensity(const World& world, FixtureID id);

/// @brief Gets the mass data for the identified fixture in the given world.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @relatedalso World
inline MassData GetMassData(const World& world, FixtureID id)
{
    return GetMassData(GetShape(world, id));
}

/// @brief Tests a point for containment in a fixture.
/// @param world The world that the given fixture ID exists within.
/// @param id Fixture to use for test.
/// @param p Point in world coordinates.
/// @throws std::out_of_range If given an invalid fixture identifier.
/// @relatedalso World
/// @ingroup TestPointGroup
bool TestPoint(const World& world, FixtureID id, Length2 p);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDFIXTURE_HPP
