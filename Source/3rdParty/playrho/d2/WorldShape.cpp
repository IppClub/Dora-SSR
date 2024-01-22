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

#include <algorithm> // for std::for_each
#include <set>

#include "playrho/BodyID.hpp"
#include "playrho/Contact.hpp" // for MixFriction
#include "playrho/NonNegative.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/ShapeID.hpp"
#include "playrho/Span.hpp"
#include "playrho/Templates.hpp"
#include "playrho/TypeInfo.hpp" // for TypeID
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"

#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Math.hpp" // for InverseTransform
#include "playrho/d2/Shape.hpp"
#include "playrho/d2/UnitVec.hpp"
#include "playrho/d2/World.hpp"
#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/WorldShape.hpp"

namespace playrho::d2 {

using playrho::size;

TypeID GetType(const World& world, ShapeID id)
{
    return GetType(GetShape(world, id));
}

ShapeCounter GetAssociationCount(const World& world)
{
    auto sum = ShapeCounter{0};
    const auto bodies = GetBodies(world);
    for_each(begin(bodies), end(bodies), [&world,&sum](const auto &b) {
        sum += static_cast<ShapeCounter>(size(GetShapes(world, b)));
    });
    return sum;
}

ShapeCounter GetUsedShapesCount(const World& world) noexcept
{
    auto ids = std::set<ShapeID>{};
    for (auto&& bodyId: GetBodies(world)) {
        for (auto&& shapeId: GetShapes(world, bodyId)) {
            ids.insert(shapeId);
        }
    }
    return static_cast<ShapeCounter>(std::size(ids));
}

Filter GetFilterData(const World& world, ShapeID id)
{
    return GetFilter(GetShape(world, id));
}

void SetFriction(World& world, ShapeID id, NonNegative<Real> value)
{
    auto object = GetShape(world, id);
    SetFriction(object, value);
    SetShape(world, id, object);
}

Real GetRestitution(const World& world, ShapeID id)
{
    return GetRestitution(GetShape(world, id));
}

void SetRestitution(World& world, ShapeID id, Real value)
{
    auto object = GetShape(world, id);
    SetRestitution(object, value);
    SetShape(world, id, object);
}

bool IsSensor(const World& world, ShapeID id)
{
    return IsSensor(GetShape(world, id));
}

void SetFilterData(World& world, ShapeID id, const Filter& filter)
{
    auto object = GetShape(world, id);
    SetFilter(object, filter);
    SetShape(world, id, object);
}

NonNegativeFF<Real> GetFriction(const World& world, ShapeID id)
{
    return GetFriction(GetShape(world, id));
}

void SetSensor(World& world, ShapeID id, bool value)
{
    auto object = GetShape(world, id);
    SetSensor(object, value);
    SetShape(world, id, object);
}

NonNegative<AreaDensity> GetDensity(const World& world, ShapeID id)
{
    return GetDensity(GetShape(world, id));
}

void SetDensity(World& world, ShapeID id, NonNegative<AreaDensity> value)
{
    auto object = GetShape(world, id);
    SetDensity(object, value);
    SetShape(world, id, object);
}

void Translate(World& world, ShapeID id, const Length2& value)
{
    auto object = GetShape(world, id);
    Translate(object, value);
    SetShape(world, id, object);
}

void Scale(World& world, ShapeID id, const Vec2& value)
{
    auto object = GetShape(world, id);
    Scale(object, value);
    SetShape(world, id, object);
}

void Rotate(World& world, ShapeID id, const UnitVec& value)
{
    auto object = GetShape(world, id);
    Rotate(object, value);
    SetShape(world, id, object);
}

MassData GetMassData(const World& world, ShapeID id)
{
    return GetMassData(GetShape(world, id));
}

MassData ComputeMassData(const World& world, const Span<const ShapeID>& ids)
{
    auto mass = 0_kg;
    auto I = RotInertia{};
    auto weightedCenter = Length2{};
    for (const auto& shapeId: ids) {
        const auto shape = GetShape(world, shapeId);
        if (GetDensity(shape) > 0_kgpm2) {
            const auto massData = GetMassData(shape);
            mass += Mass{massData.mass};
            weightedCenter += Real{massData.mass / Kilogram} * massData.center;
            I += RotInertia{massData.I};
        }
    }
    const auto center = (mass > 0_kg)? (weightedCenter / (Real{mass/1_kg})): Length2{};
    return MassData{center, mass, I};
}

bool TestPoint(const World& world, BodyID bodyId, ShapeID shapeId, const Length2& p)
{
    return TestPoint(GetShape(world, shapeId), InverseTransform(p, GetTransformation(world, bodyId)));
}

NonNegativeFF<Real> GetDefaultFriction(const Shape& a, const Shape& b)
{
    return MixFriction(GetFriction(a), GetFriction(b));
}

Real GetDefaultRestitution(const Shape& a, const Shape& b)
{
    return MixRestitution(GetRestitution(a), GetRestitution(b));
}

} // namespace playrho::d2
