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

#ifndef PLAYRHO_COLLISION_WORLDMANIFOLD_HPP
#define PLAYRHO_COLLISION_WORLDMANIFOLD_HPP

#include "PlayRho/Common/Math.hpp"

namespace playrho {
namespace d2 {

class Manifold;
class Contact;

/// @brief Essentially a Manifold expressed in world coordinate terms.
///
/// @details Used to recognize the current state of a contact manifold in world coordinates.
///
/// @note This data structure is 48-bytes large (on at least one 64-bit platform).
///
/// @sa GetWorldManifold
///
class WorldManifold
{
private:
    UnitVec m_normal = GetInvalid<UnitVec>(); ///< world vector pointing from A to B
    
    /// @brief Points.
    /// @details Manifold's contact points in world coordinates (mid-point of intersection)
    /// @note 16-bytes.
    Length2 m_points[MaxManifoldPoints] = {GetInvalid<Length2>(), GetInvalid<Length2>()};

    /// @brief Impulses.
    /// @note 16-bytes.
    Momentum2 m_impulses[MaxManifoldPoints] = {Momentum2{}, Momentum2{}};
    
    /// @brief Separations.
    /// @details A negative value indicates overlap.
    Length m_separations[MaxManifoldPoints] = {GetInvalid<Length>(), GetInvalid<Length>()};
    
public:
    
    /// @brief Size type.
    using size_type = std::remove_const<decltype(MaxManifoldPoints)>::type;

    /// @brief Point data for world manifold.
    /// @note This data structure is 20-bytes large at least on one 64-bit architecture.
    struct PointData
    {
        Length2 location; ///< Location of point or the invalid value.
        Momentum2 impulse; ///< "Normal" and "tangent" impulses at the point.
        Length separation; ///< Separation at point or the invalid value.
    };
    
    /// Default constructor.
    /// @details
    /// A default constructed world manifold will gave a point count of zero, an invalid
    /// normal, invalid points, and invalid separations.
    WorldManifold() = default;
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline explicit WorldManifold(UnitVec normal) noexcept:
        m_normal{normal}
    {
        assert(IsValid(normal));
        // Intentionally empty.
    }
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline explicit WorldManifold(UnitVec normal, PointData ps0) noexcept:
        m_normal{normal},
        m_points{ps0.location, GetInvalid<Length2>()},
        m_impulses{ps0.impulse, Momentum2{}},
        m_separations{ps0.separation, GetInvalid<Length>()}
    {
        assert(IsValid(normal));
        // Intentionally empty.
    }
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline explicit WorldManifold(UnitVec normal, PointData ps0, PointData ps1) noexcept:
        m_normal{normal},
        m_points{ps0.location, ps1.location},
        m_impulses{ps0.impulse, ps1.impulse},
        m_separations{ps0.separation, ps1.separation}
    {
        assert(IsValid(normal));
        // Intentionally empty.
    }
    
    /// @brief Gets the point count.
    ///
    /// @details This is the maximum index value that can be used to access valid point or
    ///   separation information.
    ///
    /// @return Value between 0 and 2.
    ///
    size_type GetPointCount() const noexcept
    {
        return (IsValid(m_separations[0])? 1: 0) + (IsValid(m_separations[1])? 1: 0);
    }
    
    /// Gets the normal of the contact.
    /// @details This is a directional unit-vector.
    /// @return Normal of the contact or an invalid value.
    UnitVec GetNormal() const noexcept { return m_normal; }
    
    /// Gets the indexed point's location in world coordinates.
    ///
    /// @warning Behavior is undefined if the index value is not less than
    ///   <code>MaxManifoldPoints</code>
    ///
    /// @param index Index to return point for. This must be between 0 and
    ///   <code>GetPointCount()</code> to get a valid point from this method.
    ///
    /// @return Point or an invalid value if the given index was invalid.
    ///
    Length2 GetPoint(size_type index) const noexcept
    {
        assert(index < MaxManifoldPoints);
        return m_points[index];
    }
    
    /// Gets the amount of separation at the given indexed point.
    ///
    /// @warning Behavior is undefined if the index value is not less than
    ///   <code>MaxManifoldPoints</code>
    /// @param index Index to return separation for. This must be between 0 and
    ///   <code>GetPointCount()</code>.
    ///
    /// @return Separation amount (a negative value), or an invalid value if the given index
    ///   was invalid.
    ///
    Length GetSeparation(size_type index) const noexcept
    {
        assert(index < MaxManifoldPoints);
        return m_separations[index];
    }
    
    /// @brief Gets the given index contact impulses.
    /// @return "Normal impulse" and "tangent impulse" pair.
    Momentum2 GetImpulses(size_type index) const noexcept
    {
        assert(index < MaxManifoldPoints);
        return m_impulses[index];
    }
};

/// @brief Gets the world manifold for the given data.
///
/// @pre The given manifold input has between 0 and 2 points.
///
/// @param manifold Manifold to use.
///   Uses the manifold's type, local point, local normal, point-count,
///   and the indexed-points' local point data.
/// @param xfA Transformation A.
/// @param radiusA Radius of shape A.
/// @param xfB Transformation B.
/// @param radiusB Radius of shape B.
///
/// @return World manifold value for the given inputs which will have the same number of points as
///   the given manifold has. The returned world manifold points will be the mid-points of the
///   manifold intersection.
///
/// @relatedalso Manifold
///
WorldManifold GetWorldManifold(const Manifold& manifold,
                               Transformation xfA, Length radiusA,
                               Transformation xfB, Length radiusB);

/// Gets the world manifold for the given data.
///
/// @note This is a convenience function that in turn calls the
///    <code>GetWorldManifold(const Manifold&, const Transformation&, const Real,
///                           const Transformation& xfB, const Real)</code>
///    function.
///
/// @param contact Contact to return a world manifold for.
///
/// @return World manifold value for the given inputs which will have the same number of points as
///   the given manifold has. The returned world manifold points will be the mid-points of the
///   contact's intersection.
///
/// @relatedalso Contact
///
WorldManifold GetWorldManifold(const Contact& contact);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_WORLDMANIFOLD_HPP
