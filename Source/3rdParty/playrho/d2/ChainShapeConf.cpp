/*
 * Original work Copyright (c) 2006-2010 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "playrho/Span.hpp"

#include "playrho/d2/ChainShapeConf.hpp"
#include "playrho/d2/AABB.hpp"
#include "playrho/d2/Shape.hpp"

#include <algorithm>
#include <iterator>

namespace playrho {
namespace d2 {

static_assert(detail::IsValidShapeTypeV<ChainShapeConf>);

namespace {

std::vector<UnitVec> ComputeNormals(const Span<const Length2>& vertices)
{
    std::vector<UnitVec> normals;
    if (size(vertices) > std::size_t{1}) {
        auto vprev = Length2{};
        auto first = true;
        for (const auto& v : vertices) {
            if (!first) {
                // Get the normal and push it and its reverse.
                // This "doubling up" of the normals, makes the GetChild() function work.
                const auto normal = GetUnitVector(GetFwdPerpendicular(v - vprev));
                normals.push_back(normal);
                normals.push_back(-normal);
            }
            else {
                first = false;
            }
            vprev = v;
        }
    }
    return normals;
}

} // anonymous namespace

ChainShapeConf::VerticesWithNormals::VerticesWithNormals(std::vector<Length2> vertices)
    : m_vertices(std::move(vertices)), m_normals(ComputeNormals(m_vertices))
{
}

ChainShapeConf& ChainShapeConf::Set(std::vector<Length2> vertices)
{
    if (size(vertices) > MaxChildCount) {
        throw InvalidArgument("too many vertices");
    }

    segments = VerticesWithNormals{std::move(vertices)};
    return *this;
}

ChainShapeConf& ChainShapeConf::Translate(const Length2& value)
{
    auto vertices = segments.GetVertices();
    std::for_each(begin(vertices), end(vertices), [=](Length2& v) { v = v + value; });
    segments = VerticesWithNormals{std::move(vertices)};
    return *this;
}

ChainShapeConf& ChainShapeConf::Scale(const Vec2& value)
{
    auto vertices = segments.GetVertices();
    std::for_each(begin(vertices), end(vertices), [=](Length2& v) {
        v = Length2{GetX(value) * GetX(v), GetY(value) * GetY(v)};
    });
    segments = VerticesWithNormals{std::move(vertices)};
    return *this;
}

ChainShapeConf& ChainShapeConf::Rotate(const UnitVec& value)
{
    auto vertices = segments.GetVertices();
    std::for_each(begin(vertices), end(vertices),
                  [=](Length2& v) { v = ::playrho::d2::Rotate(v, value); });
    segments = VerticesWithNormals{std::move(vertices)};
    return *this;
}

ChainShapeConf& ChainShapeConf::Add(const Length2& vertex)
{
    auto vertices = segments.GetVertices();
    vertices.emplace_back(vertex);
    segments = VerticesWithNormals{std::move(vertices)};
    return *this;
}

MassData ChainShapeConf::GetMassData() const
{
    if (density > 0_kgpm2) {
        const auto vertexCount = GetVertexCount();
        if (vertexCount > 1) {
            // XXX: This overcounts for the overlapping circle shape.
            auto mass = 0_kg;
            auto I = RotInertia{};
            auto area = 0_m2;
            auto center = Length2{};
            auto vprev = GetVertex(0);
            const auto circle_area = Square(vertexRadius) * Pi;
            for (auto i = decltype(vertexCount){1}; i < vertexCount; ++i) {
                const auto v = GetVertex(i);
                const auto massData = playrho::d2::GetMassData(vertexRadius, density, vprev, v);
                mass += Mass{massData.mass};
                center += Real{Mass{massData.mass} / Kilogram} * massData.center;
                I += RotInertia{massData.I};

                const auto d = v - vprev;
                const auto b = GetMagnitude(d);
                const auto h = vertexRadius * Real{2};
                area += b * h + circle_area;

                vprev = v;
            }
            center /= StripUnit(area);
            return MassData{center, mass, I};
        }
        if (vertexCount == 1) {
            return playrho::d2::GetMassData(vertexRadius, density, GetVertex(0));
        }
    }
    return MassData{};
}

DistanceProxy ChainShapeConf::GetChild(ChildCounter index) const
{
    if (index >= GetChildCount()) {
        throw InvalidArgument("index out of range");
    }
    const auto vertexCount = GetVertexCount();
    if (vertexCount > 1) {
        return DistanceProxy{vertexRadius, 2, &segments.GetVertices()[index], &segments.GetNormals()[index * 2]};
    }
    return DistanceProxy{vertexRadius, 1, &segments.GetVertices()[index], nullptr};
}

// Free functions...

ChainShapeConf GetChainShapeConf(const Length2& dimensions)
{
    auto conf = ChainShapeConf{};

    const auto halfWidth = GetX(dimensions) / Real{2};
    const auto halfHeight = GetY(dimensions) / Real{2};

    const auto btmLeft = Length2(-halfWidth, -halfHeight);
    const auto btmRight = Length2(+halfWidth, -halfHeight);
    const auto topLeft = Length2(-halfWidth, +halfHeight);
    const auto topRight = Length2(+halfWidth, +halfHeight);

    conf.Add(btmRight);
    conf.Add(topRight);
    conf.Add(topLeft);
    conf.Add(btmLeft);
    conf.Add(conf.GetVertex(0));

    return conf;
}

ChainShapeConf GetChainShapeConf(const AABB& arg)
{
    auto conf = ChainShapeConf{};

    const auto rangeX = arg.ranges[0];
    const auto rangeY = arg.ranges[1];

    conf.Add(Length2{rangeX.GetMax(), rangeY.GetMin()}); // bottom right
    conf.Add(Length2{rangeX.GetMax(), rangeY.GetMax()}); // top right
    conf.Add(Length2{rangeX.GetMin(), rangeY.GetMax()}); // top left
    conf.Add(Length2{rangeX.GetMin(), rangeY.GetMin()}); // bottom left
    conf.Add(conf.GetVertex(0)); // close the chain around to first point

    return conf;
}

} // namespace d2
} // namespace playrho
