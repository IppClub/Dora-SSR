/*
 * Original work Copyright (c) 2006-2010 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include "PlayRho/Collision/Shapes/EdgeShapeConf.hpp"

namespace playrho {
namespace d2 {

EdgeShapeConf::EdgeShapeConf(Length2 vA, Length2 vB, const EdgeShapeConf& conf) noexcept:
    ShapeBuilder{conf}, vertexRadius{conf.vertexRadius}, m_vertices{vA, vB}
{
    const auto normal = GetUnitVector(GetFwdPerpendicular(vB - vA));
    m_normals[0] = normal;
    m_normals[1] = -normal;
}

EdgeShapeConf& EdgeShapeConf::Set(Length2 vA, Length2 vB) noexcept
{
    m_vertices[0] = vA;
    m_vertices[1] = vB;
    const auto normal = GetUnitVector(GetFwdPerpendicular(vB - vA));
    m_normals[0] = normal;
    m_normals[1] = -normal;
    return *this;
}

EdgeShapeConf& EdgeShapeConf::Transform(const Mat22& m) noexcept
{
    const auto newA = m * GetVertexA();
    const auto newB = m * GetVertexB();
    return Set(newA, newB);
}

} // namespace d2
} // namespace playrho
