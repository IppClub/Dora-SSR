/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#include "PlayRho/Collision/MassData.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"
#include "PlayRho/Collision/Shapes/EdgeShapeConf.hpp"
#include "PlayRho/Collision/Shapes/PolygonShapeConf.hpp"
#include "PlayRho/Collision/Shapes/ChainShapeConf.hpp"
#include "PlayRho/Collision/Shapes/DiskShapeConf.hpp"
#include "PlayRho/Dynamics/Fixture.hpp"
#include "PlayRho/Dynamics/Body.hpp"

namespace playrho {
namespace d2 {

MassData GetMassData(Length r, NonNegative<AreaDensity> density, Length2 location)
{
    // Uses parallel axis theorem, perpendicular axis theorem, and the second moment of area.
    // See: https://en.wikipedia.org/wiki/Second_moment_of_area
    //
    // Ixp = Ix + A * dx^2
    // Iyp = Iy + A * dy^2
    // Iz = Ixp + Iyp = Ix + A * dx^2 + Iy + A * dy^2
    // Ix = Pi * r^4 / 4
    // Iy = Pi * r^4 / 4
    // Iz = (Pi * r^4 / 4) + (Pi * r^4 / 4) + (A * dx^2) + (A * dy^2)
    //    = (Pi * r^4 / 2) + (A * (dx^2 + dy^2))
    // A = Pi * r^2
    // Iz = (Pi * r^4 / 2) + (2 * (Pi * r^2) * (dx^2 + dy^2))
    // Iz = Pi * r^2 * ((r^2 / 2) + (dx^2 + dy^2))
    const auto r_squared = r * r;
    const auto area = r_squared * Pi;
    const auto mass = Mass{AreaDensity{density} * area};
    const auto Iz = SecondMomentOfArea{area * ((r_squared / Real{2}) + GetMagnitudeSquared(location))};
    const auto I = RotInertia{Iz * AreaDensity{density} / SquareRadian};
    return MassData{location, mass, I};
}

MassData GetMassData(Length r, NonNegative<AreaDensity> density, Length2 v0, Length2 v1)
{
    const auto r_squared = Area{r * r};
    const auto circle_area = r_squared * Pi;
    const auto circle_mass = density * circle_area;
    const auto d = v1 - v0;
    const auto offset = GetRevPerpendicular(GetUnitVector(d, UnitVec::GetZero())) * r;
    const auto b = GetMagnitude(d);
    const auto h = r * Real{2};
    const auto rect_mass = density * b * h;
    const auto totalMass = circle_mass + rect_mass;
    const auto center = (v0 + v1) / 2;

    /// Use the fixture's areal mass density times the shape's second moment of area to derive I.
    /// @sa https://en.wikipedia.org/wiki/Second_moment_of_area
    const auto halfCircleArea = circle_area / 2;
    const auto halfRSquared = r_squared / 2;
    
    const auto vertices = Vector<const Length2, 4>{
        Length2{v0 + offset},
        Length2{v0 - offset},
        Length2{v1 - offset},
        Length2{v1 + offset}
    };
    const auto I_z = GetPolarMoment(vertices);
    const auto I0 = SecondMomentOfArea{halfCircleArea * (halfRSquared + GetMagnitudeSquared(v0))};
    const auto I1 = SecondMomentOfArea{halfCircleArea * (halfRSquared + GetMagnitudeSquared(v1))};
    assert(I0 >= SecondMomentOfArea{0});
    assert(I1 >= SecondMomentOfArea{0});
    assert(I_z >= SecondMomentOfArea{0});
    const auto I = RotInertia{(I0 + I1 + I_z) * density / SquareRadian};
    return MassData{center, totalMass, I};
}

MassData GetMassData(Length vertexRadius, NonNegative<AreaDensity> density,
                     Span<const Length2> vertices)
{    
    // See: https://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon
    
    // Polygon mass, centroid, and inertia.
    // Let rho be the polygon density in mass per unit area.
    // Then:
    // mass = rho * int(dA)
    // centroid.x = (1/mass) * rho * int(x * dA)
    // centroid.y = (1/mass) * rho * int(y * dA)
    // I = rho * int((x*x + y*y) * dA)
    //
    // We can compute these integrals by summing all the integrals
    // for each triangle of the polygon. To evaluate the integral
    // for a single triangle, we make a change of variables to
    // the (u,v) coordinates of the triangle:
    // x = x0 + e1x * u + e2x * v
    // y = y0 + e1y * u + e2y * v
    // where 0 <= u && 0 <= v && u + v <= 1.
    //
    // We integrate u from [0,1-v] and then v from [0,1].
    // We also need to use the Jacobian of the transformation:
    // D = cross(e1, e2)
    //
    // Simplification: triangle centroid = (1/3) * (p1 + p2 + p3)
    //
    // The rest of the derivation is handled by computer algebra.
    
    const auto count = size(vertices);
    switch (count)
    {
        case 0:
            return MassData{};
        case 1:
            return playrho::d2::GetMassData(vertexRadius, density, vertices[0]);
        case 2:
            return playrho::d2::GetMassData(vertexRadius, density, vertices[0], vertices[1]);
        default:
            break;
    }
    
    auto center = Length2{};
    auto area = 0_m2;
    auto I = SecondMomentOfArea{0};
    
    // s is the reference point for forming triangles.
    // It's location doesn't change the result (except for rounding error).
    // This code puts the reference point inside the polygon.
    const auto s = Average(vertices);
    
    for (auto i = decltype(count){0}; i < count; ++i)
    {
        // Triangle vertices.
        const auto e1 = vertices[i] - s;
        const auto e2 = vertices[GetModuloNext(i, count)] - s;
        
        const auto D = Cross(e1, e2);
        
        const auto triangleArea = D / Real{2};
        area += triangleArea;
        
        // Area weighted centroid
        center += StripUnit(triangleArea) * (e1 + e2) / Real{3};
        
        const auto intx2 = Square(GetX(e1)) + GetX(e2) * GetX(e1) + Square(GetX(e2));
        const auto inty2 = Square(GetY(e1)) + GetY(e2) * GetY(e1) + Square(GetY(e2));
        
        const auto triangleI = D * (intx2 + inty2) / Real{3 * 4};
        I += triangleI;
    }
    
    // Total mass
    const auto mass = Mass{AreaDensity{density} * area};
    
    // Center of mass
    assert((area > 0_m2) && !AlmostZero(StripUnit(area)));
    center /= StripUnit(area);
    const auto massDataCenter = center + s;
    
    // Inertia tensor relative to the local origin (point s).
    // Shift to center of mass then to original body origin.
    const auto massCenterOffset = GetMagnitudeSquared(massDataCenter);
    const auto centerOffset = GetMagnitudeSquared(center);
    const auto inertialLever = massCenterOffset - centerOffset;
    const auto massDataI = RotInertia{((AreaDensity{density} * I) + (mass * inertialLever)) / SquareRadian};
    
    return MassData{massDataCenter, mass, massDataI};
}

MassData GetMassData(const Fixture& f)
{
    return GetMassData(f.GetShape());
}

MassData ComputeMassData(const Body& body) noexcept
{
    auto mass = 0_kg;
    auto I = RotInertia{0};
    auto center = Length2{};
    for (auto&& f: body.GetFixtures())
    {
        const auto& fixture = GetRef(f);
        if (fixture.GetDensity() > 0_kgpm2)
        {
            const auto massData = GetMassData(fixture);
            mass += Mass{massData.mass};
            center += Real{Mass{massData.mass} / Kilogram} * massData.center;
            I += RotInertia{massData.I};
        }
    }
    return MassData{center, mass, I};
}

MassData GetMassData(const Body& body) noexcept
{
    const auto I = GetLocalRotInertia(body);
    return MassData{body.GetLocalCenter(), GetMass(body), I};
}

} // namespace d2
} // namespace playrho
