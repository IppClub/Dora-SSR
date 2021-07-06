/*
 * Copyright (c) 2021 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_WORLDSHAPE_HPP
#define PLAYRHO_DYNAMICS_WORLDSHAPE_HPP

/// @file
/// Declarations of free functions of World for shapes identified by <code>ShapeID</code>.
/// @details This is a collection of non-member non-friend functions - also called "free"
///   functions - that are related to shapes within an instance of a <code>World</code>.
///   Many are just "wrappers" to similarly named member functions but some are additional
///   functionality built on those member functions. A benefit to using free functions that
///   are now just wrappers, is that of helping to isolate your code from future changes that
///   might occur to the underlying <code>World</code> member functions. Free functions in
///   this sense are "cheap" abstractions. While using these incurs extra run-time overhead
///   when compiled without any compiler optimizations enabled, enabling optimizations
///   should entirely eliminate that overhead.
/// @note The four basic categories of these functions are "CRUD": create, read, update,
///   and delete.
/// @see World, ShapeID.
/// @see https://en.wikipedia.org/wiki/Create,_read,_update_and_delete.

#include "PlayRho/Common/Math.hpp"

#include "PlayRho/Collision/MassData.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"
#include "PlayRho/Collision/Shapes/ShapeID.hpp"

#include <iterator>
#include <vector>

namespace playrho {

struct Filter;

namespace d2 {

class World;

/// @example WorldShape.cpp
/// This is the <code>googletest</code> based unit testing file for the free function
///   interfaces to <code>playrho::d2::World</code> shape member functions and additional
///   functionality.

/// @brief Gets the extent of the currently valid shape range.
/// @note This is one higher than the maxium <code>ShapeID</code> that is in range
///   for shape related functions.
/// @relatedalso World
ShapeCounter GetShapeRange(const World& world) noexcept;

/// @brief Creates a shape within the specified world.
/// @throws WrongState if called while the world is "locked".
/// @relatedalso World
ShapeID CreateShape(World& world, const Shape& def);

/// @brief Creates a shape within the specified world using a configuration of the shape.
/// @details This is a convenience function for allowing limited implicit conversions to shapes.
/// @throws WrongState if called while the world is "locked".
/// @see CreateShape(World& world, const Shape& def).
/// @relatedalso World
template <typename T>
auto CreateShape(World& world, const T& shapeConf) ->
    decltype(CreateShape(world, Shape{shapeConf}))
{
    return CreateShape(world, Shape{shapeConf});
}

/// @brief Destroys the identified shape.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
void Destroy(World& world, ShapeID id);

/// @brief Gets the shape associated with the identifier.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
const Shape& GetShape(const World& world, ShapeID id);

/// @brief Sets the identified shape to the new value.
/// @throws std::out_of_range If given an invalid shape identifier.
/// @see CreateShape.
/// @relatedalso World
void SetShape(World& world, ShapeID, const Shape& def);

/// @brief Gets the type of the shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
TypeID GetType(const World& world, ShapeID id);

/// @brief Gets the count of body-shape associations in the given world.
/// @relatedalso World
ShapeCounter GetAssociationCount(const World& world) noexcept;

/// @brief Gets the count of uniquely identified shapes that are in use -
///   i.e. that are attached to bodies.
/// @relatedalso World
ShapeCounter GetUsedShapesCount(const World& world) noexcept;

/// @brief Gets the filter data for the identified shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @see SetFilterData.
/// @relatedalso World
inline Filter GetFilterData(const World& world, ShapeID id)
{
    return GetFilter(GetShape(world, id));
}

/// @brief Convenience function for setting the contact filtering data.
/// @note This won't update contacts until the next time step when either parent body
///    is speedable and awake.
/// @note This automatically refilters contacts.
/// @throws std::out_of_range If given an invalid identifier.
/// @see GetFilterData.
/// @relatedalso World
void SetFilterData(World& world, ShapeID id, const Filter& filter);

/// @brief Gets the coefficient of friction of the specified shape.
/// @return Value of 0 or higher.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
inline Real GetFriction(const World& world, ShapeID id)
{
    return GetFriction(GetShape(world, id));
}

/// @brief Convenience function for setting the coefficient of friction of the specified shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @see GetFriction.
/// @relatedalso World
void SetFriction(World& world, ShapeID id, Real value);

/// @brief Gets the coefficient of restitution of the specified shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
inline Real GetRestitution(const World& world, ShapeID id)
{
    return GetRestitution(GetShape(world, id));
}

/// @brief Sets the coefficient of restitution of the specified shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
void SetRestitution(World& world, ShapeID id, Real value);

/// @brief Is the specified shape a sensor (non-solid)?
/// @return the true if the shape is a sensor.
/// @throws std::out_of_range If given an invalid identifier.
/// @see SetSensor.
/// @relatedalso World
inline bool IsSensor(const World& world, ShapeID id)
{
    return IsSensor(GetShape(world, id));
}

/// @brief Convenience function for setting whether the shape is a sensor or not.
/// @throws std::out_of_range If given an invalid identifier.
/// @see IsSensor.
/// @relatedalso World
void SetSensor(World& world, ShapeID id, bool value);

/// @brief Gets the density of this shape.
/// @return Non-negative density (in mass per area).
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
inline NonNegative<AreaDensity> GetDensity(const World& world, ShapeID id)
{
    return GetDensity(GetShape(world, id));
}

/// @brief Sets the density of this shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
void SetDensity(World& world, ShapeID id, NonNegative<AreaDensity> value);

/// @brief Translates all of the given shape's vertices by the given amount.
/// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
///   by the constructor for the model's underlying data type.
/// @throws std::bad_alloc if there's a failure allocating storage.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
void Translate(World& world, ShapeID id, const Length2& value);

/// @brief Scales all of the given shape's vertices by the given amount.
/// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
///   by the constructor for the model's underlying data type.
/// @throws std::bad_alloc if there's a failure allocating storage.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
void Scale(World& world, ShapeID id, const Vec2& value);

/// @brief Rotates all of the given shape's vertices by the given amount.
/// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
///   by the constructor for the model's underlying data type.
/// @throws std::bad_alloc if there's a failure allocating storage.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
void Rotate(World& world, ShapeID id, const UnitVec& value);

/// @brief Gets the mass data for the identified shape in the given world.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
inline MassData GetMassData(const World& world, ShapeID id)
{
    return GetMassData(GetShape(world, id));
}

/// @brief Tests a point for containment in a shape associated with a body.
/// @param world The world that the given shape ID exists within.
/// @param bodyId Body to use for test.
/// @param shapeId Shape to use for test.
/// @param p Point in world coordinates.
/// @throws std::out_of_range If given an invalid body or shape identifier.
/// @relatedalso World
/// @ingroup TestPointGroup
bool TestPoint(const World& world, BodyID bodyId, ShapeID shapeId, Length2 p);

/// @brief Gets the default friction amount for the given shapes.
/// @relatedalso Shape
Real GetDefaultFriction(const Shape& a, const Shape& b);

/// @brief Gets the default restitution amount for the given shapes.
/// @relatedalso Shape
Real GetDefaultRestitution(const Shape& a, const Shape& b);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDSHAPE_HPP
