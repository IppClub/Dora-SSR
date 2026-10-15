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

#include "playrho/d2/EdgeShapeConf.hpp"

#include "playrho/d2/Shape.hpp"

namespace playrho::d2 {

static_assert(detail::IsValidShapeTypeV<EdgeShapeConf>);

EdgeShapeConf::EdgeShapeConf(const Length2& vA, const Length2& vB, // force line-break
                             const EdgeShapeConf& conf) noexcept
    : ShapeBuilder{conf}, vertexRadius{conf.vertexRadius},
      previousVertex{conf.previousVertex}, nextVertex{conf.nextVertex}, ngon{{vA, vB}}
{
    // Intentionally empty.
}

EdgeShapeConf& EdgeShapeConf::Set(const Length2& vA, const Length2& vB) noexcept
{
    ngon = NgonWithFwdNormals<2>{{vA, vB}};
    previousVertex.reset();
    nextVertex.reset();
    return *this;
}

EdgeShapeConf& EdgeShapeConf::UsePreviousVertex(const Length2& value) noexcept
{
    previousVertex = value;
    return *this;
}

EdgeShapeConf& EdgeShapeConf::ClearPreviousVertex() noexcept
{
    previousVertex.reset();
    return *this;
}

EdgeShapeConf& EdgeShapeConf::UseNextVertex(const Length2& value) noexcept
{
    nextVertex = value;
    return *this;
}

EdgeShapeConf& EdgeShapeConf::ClearNextVertex() noexcept
{
    nextVertex.reset();
    return *this;
}

EdgeShapeConf& EdgeShapeConf::Translate(const Length2& value) noexcept
{
    ngon = NgonWithFwdNormals<2>{{GetVertexA() + value, GetVertexB() + value}};
    if (previousVertex) *previousVertex += value;
    if (nextVertex) *nextVertex += value;
    return *this;
}

EdgeShapeConf& EdgeShapeConf::Scale(const Vec2& value) noexcept
{
    const auto previous = previousVertex;
    const auto next = nextVertex;
    Set(Length2{GetX(value) * GetX(GetVertexA()), GetY(value) * GetY(GetVertexA())},
        Length2{GetX(value) * GetX(GetVertexB()), GetY(value) * GetY(GetVertexB())});
    if (previous) UsePreviousVertex(Length2{
        GetX(value) * GetX(*previous), GetY(value) * GetY(*previous)});
    if (next) UseNextVertex(Length2{
        GetX(value) * GetX(*next), GetY(value) * GetY(*next)});
    return *this;
}

EdgeShapeConf& EdgeShapeConf::Rotate(const UnitVec& value) noexcept
{
    const auto previous = previousVertex;
    const auto next = nextVertex;
    Set(::playrho::d2::Rotate(GetVertexA(), value),
        ::playrho::d2::Rotate(GetVertexB(), value));
    if (previous) UsePreviousVertex(::playrho::d2::Rotate(*previous, value));
    if (next) UseNextVertex(::playrho::d2::Rotate(*next, value));
    return *this;
}

} // namespace playrho::d2
