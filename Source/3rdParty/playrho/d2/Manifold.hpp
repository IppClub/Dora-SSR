/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_D2_MANIFOLD_HPP
#define PLAYRHO_D2_MANIFOLD_HPP

/// @file
/// @brief Definition of the @c Manifold class and closely related code.

#include <cassert> // for assert
#include <cstddef> // for std::size_t
#include <cstdint> // for std::uint8_t
#include <type_traits> // for std::remove_const_t

// IWYU pragma: begin_exports

#include "playrho/ContactFeature.hpp"
#include "playrho/Vector.hpp" // for playrho::get
#include "playrho/Vector2.hpp" // for Length2

#include "playrho/d2/IndexPair.hpp" // for VertexCounter2
#include "playrho/d2/UnitVec.hpp"

// IWYU pragma: end_exports

namespace playrho {
struct StepConf;
}

namespace playrho::d2 {

class DistanceProxy;
struct Transformation;

/// @brief A collision response oriented description of the intersection of two convex shapes.
///
/// @details
/// This describes zero, one, or two points of contact for which impulses should be applied to
/// most naturally resolve those contacts. Ideally the manifold is calculated at the earliest
/// point in time of contact occurring. The further past that time, the less natural contact
/// resolution of solid bodies will be - eventually resulting in oddities like tunneling.
///
/// Multiple types of contact are supported: clip point versus plane with radius, point versus
/// point with radius (circles). Contacts are stored in this way so that position correction can
/// account for movement, which is critical for continuous physics. All contact scenarios must
/// be expressed in one of these types.
///
/// Conceptually, a manifold represents the intersection of two convex sets (which is itself
/// a convex set) and a solution for moving the sets away from each other to eliminate the
/// intersection.
///
/// @note The local point and local normal usage depends on the manifold type. For details, see
///   the documentation associated with the different manifold types.
/// @note Every point adds computational overhead to the collision response calculation - so
///   express collision manifolds with one point if possible instead of two.
///
/// @image html manifolds.png
///
/// @see Contact, PositionConstraint, VelocityConstraint
/// @see https://en.wikipedia.org/wiki/Convex_set
/// @see http://box2d.org/files/GDC2007/GDC2007_Catto_Erin_Physics2.ppt
///
class Manifold
{
public:
    /// @brief Size type.
    using size_type = std::remove_const_t<decltype(MaxManifoldPoints)>;

    /// The contact feature index.
    using CfIndex = ContactFeature::Index;

    struct Conf;

    /// Manifold type.
    enum Type : std::uint8_t {
        /// Unset type.
        /// @details Manifold is unset. For manifolds of this type: the point count is zero,
        ///   point data is not defined, and all other properties are invalid.
        e_unset,

        /// Circles type.
        /// @details Manifold is for circle-to-circle like collisions.
        /// @note For manifolds of this type: the local point is local center of "circle-A"
        ///     (where shape A wasn't necessarily a circle but treating it as such is useful),
        ///     the local normal is invalid (and unused) and, the point count will be zero or
        ///     one where the contact feature will be
        ///               <code>ContactFeature{e_vertex, i, e_vertex, j}</code>
        ///     where i and j are indexes of the vertexes of shapes A and B respectively.
        e_circles,

        /// Face-A type.
        /// @details Indicates: local point is center of face A, local normal is normal on shape A,
        /// and the
        ///   local points of Point instances are the local center of circle B or a clip point of
        ///   polygon B where the contact feature will be <code>ContactFeature{e_face, i, e_vertex,
        ///   j}</code> or <code>ContactFeature{e_face, i, e_face, j} where i and j are indexes for
        ///   the vertex or edge of shapes A and B respectively.</code>.
        e_faceA,

        /// Face-B type.
        /// @details Indicates: local point is center of face B, local normal is normal on shape B,
        /// and the
        ///   local points of Point instances are the local center of circle A or a clip point of
        ///   polygon A where the contact feature will be <code>ContactFeature{e_face, i, e_vertex,
        ///   j}</code> or <code>ContactFeature{e_face, i, e_face, j} where i and j are indexes for
        ///   the vertex or edge of shapes A and B respectively.</code>.
        e_faceB
    };

    /// @brief Data for a point of collision in a Manifold.
    /// @details This is a contact point belonging to a contact manifold. It holds details
    /// related to the geometry and dynamics of the contact points.
    /// @note The impulses are used for internal caching and may not provide reliable contact
    ///    forces especially for high speed collisions.
    struct Point {
        /// @brief Local point.
        /// @details Usage depends on manifold type.
        /// @note For circles type manifolds, this is the local center of circle B.
        /// @note For face-A type manifolds, this is the local center of "circle" B or a clip
        /// point of shape B. It is also the point at which impulse forces should be relatively
        /// applied for position resolution.
        /// @note For face-B type manifolds, this is the local center of "circle" A or a clip
        /// point of shape A. It is also the point at which impulse forces should be relatively
        /// applied for position resolution.
        Length2 localPoint{};

        /// @brief The contact feature.
        /// @details Uniquely identifies a contact point between two shapes - A and B.
        /// @see GetPointStates.
        ContactFeature contactFeature{};

        /// @brief Normal impulse.
        /// @details This is the non-penetration impulse.
        /// @note This is only used for velocity constraint resolution.
        Momentum normalImpulse{};

        /// @brief Tangent impulse.
        /// @details This is the friction impulse.
        /// @note This is only used for velocity constraint resolution.
        Momentum tangentImpulse{};
    };

    // For Circles type manifolds...

    /// Gets a circles-typed manifold with one point.
    /// @param vA Local center of "circle" A.
    /// @param iA Index of vertex from shape A representing the local center of "circle" A.
    /// @param vB Local center of "circle" B.
    /// @param iB Index of vertex from shape B representing the local center of "circle" B.
    static Manifold GetForCircles(const Length2& vA, CfIndex iA, const Length2& vB, CfIndex iB) noexcept
    {
        return {e_circles, UnitVec(), vA, {{Point{vB, GetVertexVertexContactFeature(iA, iB)}}}};
    }

    // For Face A type manifolds...

    /// Gets a face A typed manifold.
    /// @param normalA Local normal of the face from polygon A.
    /// @param faceA Any point in local coordinates on the face whose normal was provided.
    static Manifold GetForFaceA(const UnitVec& normalA, const Length2& faceA) noexcept
    {
        return {e_faceA, normalA, faceA, {{}}};
    }

    /// Gets a face A typed manifold.
    /// @param ln Normal on polygon A.
    /// @param lp Center of face A.
    /// @param mp1 Manifold point 1 (of 1).
    static Manifold GetForFaceA(const UnitVec& ln, const Length2& lp, const Point& mp1) noexcept
    {
        // assert(mp1.contactFeature.typeA == ContactFeature::e_face || mp1.contactFeature.typeB ==
        // ContactFeature::e_face);
        return {e_faceA, ln, lp, {{mp1}}};
    }

    /// Gets a face A typed manifold.
    /// @param ln Normal on polygon A.
    /// @param lp Center of face A.
    /// @param mp1 Manifold point 1 (of 2).
    /// @param mp2 Manifold point 2 (of 2).
    static Manifold GetForFaceA(const UnitVec& ln, const Length2& lp, const Point& mp1,
                                const Point& mp2) noexcept
    {
        // assert(mp1.contactFeature.typeA == ContactFeature::e_face || mp1.contactFeature.typeB ==
        // ContactFeature::e_face); assert(mp2.contactFeature.typeA == ContactFeature::e_face ||
        // mp2.contactFeature.typeB == ContactFeature::e_face); assert(mp1.contactFeature !=
        // mp2.contactFeature);
        return {e_faceA, ln, lp, {{mp1, mp2}}};
    }

    // For Face B...

    /// Gets a face B typed manifold.
    /// @param ln Normal on polygon B.
    /// @param lp Center of face B.
    static Manifold GetForFaceB(const UnitVec& ln, const Length2& lp) noexcept
    {
        return {e_faceB, ln, lp, {{}}};
    }

    /// Gets a face B typed manifold.
    /// @param ln Normal on polygon B.
    /// @param lp Center of face B.
    /// @param mp1 Manifold point 1.
    static Manifold GetForFaceB(const UnitVec& ln, const Length2& lp, const Point& mp1) noexcept
    {
        // assert(mp1.contactFeature.typeA == ContactFeature::e_face || mp1.contactFeature.typeB ==
        // ContactFeature::e_face);
        return {e_faceB, ln, lp, {{mp1}}};
    }

    /// Gets a face B typed manifold.
    /// @param ln Normal on polygon B.
    /// @param lp Center of face B.
    /// @param mp1 Manifold point 1 (of 2).
    /// @param mp2 Manifold point 2 (of 2).
    static Manifold GetForFaceB(const UnitVec& ln, const Length2& lp, // newline
                                const Point& mp1, const Point& mp2) noexcept
    {
        // assert(mp1.contactFeature.typeA == ContactFeature::e_face || mp1.contactFeature.typeB ==
        // ContactFeature::e_face); assert(mp2.contactFeature.typeA == ContactFeature::e_face ||
        // mp2.contactFeature.typeB == ContactFeature::e_face); assert(mp1.contactFeature !=
        // mp2.contactFeature);
        return {e_faceB, ln, lp, {{mp1, mp2}}};
    }

    /// Default constructor.
    /// @details
    /// Constructs an unset-type manifold.
    /// For an unset-type manifold:
    /// point count is zero, point data is not defined, and all other properties are invalid.
    Manifold() = default;

    /// Gets the type of this manifold.
    ///
    /// @note This must be a constant expression in order to use it in the context
    ///   of the <code>IsValid</code> specialized template function for it.
    ///
    constexpr Type GetType() const noexcept
    {
        return m_points.GetType();
    }

    /// Gets the manifold point count.
    /// @details This is the count of contact points for this manifold.
    ///   Only up to this many points can be validly accessed using the
    ///   <code>GetPoint()</code> function.
    /// @note Non-zero values indicate that the two shapes are touching.
    /// @return Value between 0 and <code>MaxManifoldPoints</code>.
    /// @see MaxManifoldPoints, AddPoint(), GetPoint().
    constexpr size_type GetPointCount() const noexcept
    {
        return m_points.size();
    }

    /// @brief Gets the contact feature for the given index.
    /// @pre @p index is less than <code>GetPointCount()</code>.
    constexpr ContactFeature GetContactFeature(size_type index) const noexcept
    {
        assert(index < GetPointCount());
        return m_points[index].contactFeature;
    }

    /// @brief Gets the impulses for the given index.
    /// @pre @p index is less than <code>GetPointCount()</code>.
    /// @return Pair of impulses where the first impulse is the "normal impulse"
    ///   and the second impulse is the "tangent impulse".
    constexpr Momentum2 GetImpulses(size_type index) const noexcept
    {
        assert(index < GetPointCount());
        return Momentum2{m_points[index].normalImpulse, m_points[index].tangentImpulse};
    }

    /// @brief Sets the impulses for the given index.
    /// @details Sets the contact impulses for the given index where the first impulse
    ///   is the "normal impulse" and the second impulse is the "tangent impulse".
    /// @pre @p index is less than <code>GetPointCount()</code>.
    void SetImpulses(size_type index, const Momentum2& value) noexcept
    {
        assert(index < GetPointCount());
        m_points[index].normalImpulse = get<0>(value);
        m_points[index].tangentImpulse = get<1>(value);
    }

    /// @brief Sets the impulses for the given index.
    /// @pre @p index is less than <code>GetPointCount()</code>.
    void SetImpulses(size_type index, Momentum n, Momentum t) noexcept
    {
        assert(index < GetPointCount());
        m_points[index].normalImpulse = n;
        m_points[index].tangentImpulse = t;
    }

    /// @brief Gets the point identified by the given index.
    /// @pre @p index is less than <code>GetPointCount()</code>.
    const Point& GetPoint(size_type index) const noexcept
    {
        assert(index < GetPointCount());
        return m_points[index];
    }

    /// Adds a new point.
    /// @details This can be called once for circle type manifolds,
    ///   and up to twice for face-A or face-B type manifolds. <code>GetPointCount()</code>
    ///   can be called to find out how many points have already been added.
    /// @pre <code>GetType()</code> is not <code>e_unset</code>.
    /// @pre <code>GetPointCount()</code> is less than <code>MaxManifoldPoints</code>.
    void AddPoint(const Point& mp) noexcept;

    /// @brief Gets the local normal for a face-type manifold.
    /// @note Only valid for face-A or face-B type manifolds.
    /// @pre This is a face manifold, i.e.:
    ///   <code>GetType() == e_faceA || GetType() == e_faceB</code>.
    /// @return Local normal if the manifold type is face A or face B, else invalid value.
    constexpr UnitVec GetLocalNormal() const noexcept
    {
        assert(GetType() == e_faceA || GetType() == e_faceB);
        return m_localNormal;
    }

    /// @brief Gets the local point.
    /// @details
    /// This is the: local center of "circle" A for circles-type manifolds;
    /// the center of face A for face-A-type manifolds; or
    /// the center of face B for face-B-type manifolds.
    /// @note Only valid for circle, face-A, or face-B type manifolds.
    /// @pre This is not an unset manifold, i.e. <code>GetType() != e_unset</code>.
    /// @return Local point.
    constexpr Length2 GetLocalPoint() const noexcept
    {
        assert(GetType() != e_unset);
        return m_localPoint;
    }

    /// @brief Gets the opposing point.
    /// @pre @p index is less than <code>GetPointCount()</code>.
    constexpr Length2 GetOpposingPoint(size_type index) const noexcept
    {
        assert(index < GetPointCount());
        return m_points[index].localPoint;
    }

private:
    /// @brief Point array structure.
    struct PointArray {
        Point elements[MaxManifoldPoints]; ///< Elements.

        /// @brief Retrieves the type value.
        constexpr auto GetType() const noexcept -> Type
        {
            return static_cast<Type>(elements[0].contactFeature.other);
        }

        /// @brief Stores the given type in this.
        constexpr void SetType(Type t) noexcept
        {
            elements[0].contactFeature.other = static_cast<ContactFeature::Type>(t);
        }

        /// @brief Size in number of elements.
        constexpr auto size() const noexcept -> size_type
        {
            const auto v0 = elements[0].contactFeature.indexA != InvalidVertex;
            const auto v1 = elements[1].contactFeature.indexA != InvalidVertex;
            return static_cast<size_type>((v0? 1u: 0u) + (v1? 1u: 0u));
        }

        /// @brief Array indexing operator.
        constexpr Point& operator[](std::size_t i)
        {
            assert(i < MaxManifoldPoints);
            return elements[i]; // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
        }

        /// @brief Array indexing operator.
        constexpr const Point& operator[](std::size_t i) const
        {
            assert(i < MaxManifoldPoints);
            return elements[i]; // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
        }
    };

    /// Constructs manifold with array of points using the given values.
    /// @param t Manifold type.
    /// @param ln Local normal.
    /// @param lp Local point.
    /// @param mpa Manifold point array.
    constexpr Manifold(Type t, const UnitVec& ln, const Length2& lp, const PointArray& mpa) noexcept;

    /// Local normal.
    /// @details Exact usage depends on manifold type.
    /// @note Invalid for the unset and circle manifold types.
    UnitVec m_localNormal;

    /// Local point.
    /// @details Exact usage depends on manifold type.
    /// @note Invalid for the unset manifold type.
    Length2 m_localPoint{InvalidLength2};

    PointArray m_points; ///< Points of contact. @see pointCount.
};

// State & confirm expected traits...
static_assert(std::is_default_constructible_v<Manifold>);
static_assert(std::is_copy_constructible_v<Manifold>);
static_assert(std::is_copy_assignable_v<Manifold>);

/// @brief Configuration data for manifold calculation.
struct Manifold::Conf {
    /// @brief Linear slop.
    Length linearSlop = DefaultLinearSlop;

    /// Max. circles ratio.
    /// @details When the ratio of the closest face's length to the vertex radius is
    ///   more than this amount, then face-manifolds are forced, else circles-manifolds
    ///   may be computed for new contact manifolds.
    Real maxCirclesRatio = DefaultCirclesRatio;
};

/// @brief Gets the default manifold configuration.
/// @relatedalso Manifold::Conf
constexpr Manifold::Conf GetDefaultManifoldConf() noexcept
{
    return Manifold::Conf{};
}

/// @brief Gets the manifold configuration for the given step configuration.
/// @relatedalso Manifold::Conf
Manifold::Conf GetManifoldConf(const StepConf& conf) noexcept;

constexpr Manifold::Manifold(Type t, const UnitVec& ln, const Length2& lp, const PointArray& mpa) noexcept
    : m_localNormal{ln}, m_localPoint{lp}, m_points{mpa}
{
    assert(t != e_unset || mpa.size() == 0);
    assert(t == e_unset || IsValid(lp));
    assert((t == e_unset) || (t == e_circles) || IsValid(ln));
    assert((t != e_circles) || ((mpa.size() == 1) && !IsValid(ln)));
    // assert((t != e_circles) || (n == 1 && !IsValid(ln) && mpa[0].contactFeature.typeA ==
    // ContactFeature::e_vertex && mpa[0].contactFeature.typeB == ContactFeature::e_vertex));
    m_points.SetType(t);
}

inline void Manifold::AddPoint(const Point& mp) noexcept
{
    assert(GetType() != e_unset);
    assert(GetType() != e_circles || GetPointCount() == 0);
    assert(GetPointCount() < MaxManifoldPoints);
    assert(mp.contactFeature.other == 0u);
    assert(mp.contactFeature.indexA != InvalidVertex);
    assert(mp.contactFeature.indexB != InvalidVertex);
    // assert((GetPointCount() == 0) || (mp.contactFeature != m_points[0].contactFeature));
    // assert((GetType() != e_circles) || (mp.contactFeature.typeA == ContactFeature::e_vertex ||
    // mp.contactFeature.typeB == ContactFeature::e_vertex)); assert((GetType() != e_faceA) ||
    // ((mp.contactFeature.typeA == ContactFeature::e_face) && (GetPointCount() == 0 ||
    // mp.contactFeature.indexA == m_points[0].contactFeature.indexA))); assert((GetType() != e_faceB)
    // || (mp.contactFeature.typeB == ContactFeature::e_face));
    auto cf = mp.contactFeature;
    cf.other = static_cast<decltype(cf.other)>(GetType());
    m_points[GetPointCount()] = {mp.localPoint, cf, mp.normalImpulse, mp.tangentImpulse};
}

// Free functions...

/// @brief Determines whether the two given manifold points are equal.
/// @relatedalso Manifold::Point
bool operator==(const Manifold::Point& lhs, const Manifold::Point& rhs) noexcept;

/// @brief Determines whether the two given manifold points are not equal.
/// @relatedalso Manifold::Point
bool operator!=(const Manifold::Point& lhs, const Manifold::Point& rhs) noexcept;

/// @brief Manifold equality operator.
/// @note In-so-far as manifold points are concerned, order doesn't matter;
///    only whether the two manifolds have the same point set.
/// @relatedalso Manifold
bool operator==(const Manifold& lhs, const Manifold& rhs) noexcept;

/// @brief Manifold inequality operator.
/// @details Determines whether the two given manifolds are not equal.
/// @relatedalso Manifold
bool operator!=(const Manifold& lhs, const Manifold& rhs) noexcept;

/// @brief Gets a face-to-face based manifold.
/// @param flipped Whether to flip the resulting manifold (between face-A and face-B).
/// @param shape0 Shape 0. This should be shape A for face-A type manifold or shape B for face-B
///   type manifold. Must have a vertex count of more than one.
/// @param xf0 Transform 0. This should be transform A for face-A type manifold or transform B
///   for face-B type manifold.
/// @param idx0 Index 0. This should be the index of the vertex and normal of shape0 that had
///   the maximal separation distance from any vertex in shape1.
/// @param shape1 Shape 1. This should be shape B for face-A type manifold or shape A for face-B
///   type manifold. Must have a vertex count of more than one.
/// @param xf1 Transform 1. This should be transform B for face-A type manifold or transform A
///   for face-B type manifold.
/// @param indices1 Index 1. This is the first and possibly second index of the vertex of shape1
///   that had the maximal separation distance from the edge of shape0 identified by idx0.
/// @param conf Manifold configuration data.
Manifold GetManifold(bool flipped, const DistanceProxy& shape0, const Transformation& xf0,
                     VertexCounter idx0, const DistanceProxy& shape1,
                     const Transformation& xf1, VertexCounter2 indices1,
                     const Manifold::Conf& conf);

/// @brief Computes manifolds for face-to-point collision.
/// @pre The given distance proxy <code>GetVertexCount()</code> must be one or greater.
Manifold GetManifold(bool flipped, Length totalRadius, const DistanceProxy& shape,
                     const Transformation& sxf, const Length2& point, const Transformation& xfm);

/// @brief Gets a point-to-point based manifold.
Manifold GetManifold(const Length2& locationA, const Transformation& xfA, // force line-break
                     const Length2& locationB, const Transformation& xfB, // force line-break
                     Length totalRadius) noexcept;

/// @brief Calculates the relevant collision manifold.
/// @note The returned touching state information typically agrees with that returned from
///   the distance-proxy-based <code>TestOverlap</code> function. This is not always the
///   case however especially when the separation or overlap distance is closer to zero.
/// @relatedalso Manifold
Manifold CollideShapes(const DistanceProxy& shapeA, const Transformation& xfA,
                       const DistanceProxy& shapeB, const Transformation& xfB,
                       const Manifold::Conf& conf = GetDefaultManifoldConf());
#if 0
Manifold CollideCached(const DistanceProxy& shapeA, const Transformation& xfA,
                       const DistanceProxy& shapeB, const Transformation& xfB,
                       Manifold::Conf conf = GetDefaultManifoldConf());
#endif

#ifdef DEFINE_GET_MANIFOLD
Manifold GetManifold(const DistanceProxy& proxyA, const Transformation& transformA,
                     const DistanceProxy& proxyB, const Transformation& transformB);
#endif

#if 0
Length2 GetLocalPoint(const DistanceProxy& proxy, ContactFeature::Type type,
                      ContactFeature::Index index);
#endif

/// @brief Gets a unique name for the given manifold type.
/// @param type Manifold type to get name for. Must be one of the enumerated values.
const char* GetName(Manifold::Type type) noexcept;

} // namespace playrho::d2

namespace playrho {

/// @brief Gets whether the given manifold is valid.
/// @relatedalso d2::Manifold
constexpr auto IsValid(const d2::Manifold& value) noexcept -> bool
{
    return value.GetType() != d2::Manifold::e_unset;
}

} // namespace playrho

#endif // PLAYRHO_D2_MANIFOLD_HPP
