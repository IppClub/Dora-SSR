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

#ifndef PLAYRHO_D2_WORLDSHAPE_HPP
#define PLAYRHO_D2_WORLDSHAPE_HPP

/// @file
/// @brief Declarations of free functions of World for shapes identified by <code>ShapeID</code>.
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

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/ShapeID.hpp"
#include "playrho/Span.hpp"
#include "playrho/TypeInfo.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"

#include "playrho/d2/MassData.hpp"
#include "playrho/d2/UnitVec.hpp"

// IWYU pragma: end_exports

namespace playrho {
struct Filter;
}

namespace playrho::d2 {

class Shape;
class World;

/// @example WorldShape.cpp
/// This is the <code>googletest</code> based unit testing file for the free function
///   interfaces to <code>playrho::d2::World</code> shape member functions and additional
///   functionality.

/// @brief Gets the type of the shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
TypeID GetType(const World& world, ShapeID id);

/// @brief Gets the count of body-shape associations in the given world.
/// @param world The world in which to get the shape association count for.
/// @see GetUsedShapesCount.
/// @relatedalso World
ShapeCounter GetAssociationCount(const World& world);

/// @brief Gets the count of uniquely identified shapes that are in use -
///   i.e. that are attached to bodies.
/// @param world The world in which to get the used shapes count for.
/// @see GetAssociationCount.
/// @relatedalso World
ShapeCounter GetUsedShapesCount(const World& world) noexcept;

/// @brief Gets the filter data for the identified shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @see SetFilterData.
/// @relatedalso World
Filter GetFilterData(const World& world, ShapeID id);

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
NonNegativeFF<Real> GetFriction(const World& world, ShapeID id);

/// @brief Convenience function for setting the coefficient of friction of the specified shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @see GetFriction.
/// @relatedalso World
void SetFriction(World& world, ShapeID id, NonNegative<Real> value);

/// @brief Gets the coefficient of restitution of the specified shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
Real GetRestitution(const World& world, ShapeID id);

/// @brief Sets the coefficient of restitution of the specified shape.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
void SetRestitution(World& world, ShapeID id, Real value);

/// @brief Is the specified shape a sensor (non-solid)?
/// @return the true if the shape is a sensor.
/// @throws std::out_of_range If given an invalid identifier.
/// @see SetSensor.
/// @relatedalso World
bool IsSensor(const World& world, ShapeID id);

/// @brief Convenience function for setting whether the shape is a sensor or not.
/// @throws std::out_of_range If given an invalid identifier.
/// @see IsSensor.
/// @relatedalso World
void SetSensor(World& world, ShapeID id, bool value);

/// @brief Gets the density of this shape.
/// @return Non-negative density (in mass per area).
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso World
NonNegative<AreaDensity> GetDensity(const World& world, ShapeID id);

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
MassData GetMassData(const World& world, ShapeID id);

/// @brief Computes the mass data total of the identified shapes.
/// @details This basically accumulates the mass data over all shapes.
/// @note The center is the mass weighted sum of all shape centers. Divide it by the
///   mass to get the averaged center.
/// @return accumulated mass data for all shapes identified.
/// @throws std::out_of_range If given an invalid shape identifier.
/// @relatedalso World
MassData ComputeMassData(const World& world, const Span<const ShapeID>& ids);

/// @brief Tests a point for containment in a shape associated with a body.
/// @param world The world that the given shape ID exists within.
/// @param bodyId Body to use for test.
/// @param shapeId Shape to use for test.
/// @param p Point in world coordinates.
/// @throws std::out_of_range If given an invalid body or shape identifier.
/// @relatedalso World
/// @ingroup TestPointGroup
bool TestPoint(const World& world, BodyID bodyId, ShapeID shapeId, const Length2& p);

/// @brief Gets the default friction amount for the given shapes.
/// @relatedalso Shape
NonNegativeFF<Real> GetDefaultFriction(const Shape& a, const Shape& b);

/// @brief Gets the default restitution amount for the given shapes.
/// @relatedalso Shape
Real GetDefaultRestitution(const Shape& a, const Shape& b);

} // namespace playrho::d2

#endif // PLAYRHO_D2_WORLDSHAPE_HPP
