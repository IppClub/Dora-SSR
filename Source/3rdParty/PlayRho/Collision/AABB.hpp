/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COLLISION_AABB_HPP
#define PLAYRHO_COLLISION_AABB_HPP

/// @file
/// Declaration of the AABB class and free functions that return instances of it.

#include "PlayRho/Common/Intervals.hpp"
#include "PlayRho/Common/Vector2.hpp"
#include "PlayRho/Common/Templates.hpp"
#include <array>
#include <algorithm>
#include <functional>

namespace playrho {

namespace detail {

template <std::size_t N> struct RayCastInput;

/// @brief N-dimensional Axis Aligned Bounding Box.
///
/// @details This is a concrete value class template for an N-dimensional axis aligned
///   bounding box (AABB) which is a type of bounding volume.
///
/// @note This class satisfies at least the following concepts: all the basic concepts,
///   <code>EqualityComparable</code>, and <code>Swappable</code>.
/// @note This class is composed of &mdash; as in contains and owns &mdash; N
///   <code>LengthInterval</code> variables.
/// @note Non-defaulted methods of this class are marked <code>noexcept</code> and expect
///   that the Length type doesn't throw.
///
/// @sa https://en.wikipedia.org/wiki/Bounding_volume
/// @sa http://en.cppreference.com/w/cpp/concept
///
template <std::size_t N>
struct AABB
{
    /// @brief Alias for the location type.
    using Location = Vector<Length, N>;

    /// @brief Default constructor.
    /// @details Constructs an "unset" AABB.
    /// @note If an unset AABB is added to another AABB, the result will be the other AABB.
    PLAYRHO_CONSTEXPR inline AABB() = default;
    
    /// @brief Initializing constructor.
    /// @details Initializing constructor supporting construction by the same number of elements
    ///   as this AABB template type is defined for.
    /// @note For example this enables a 2-dimensional AABB to be constructed as:
    /// @code{.cpp}
    /// const auto aabb = AABB<2>{LengthInterval{1_m, 4_m}, LengthInterval{-3_m, 3_m}};
    /// @endcode
    template<typename... Tail>
    PLAYRHO_CONSTEXPR inline AABB(std::enable_if_t<sizeof...(Tail)+1 == N, LengthInterval> head,
                                  Tail... tail) noexcept:
        ranges{head, LengthInterval(tail)...}
    {
        // Intentionally empty.
    }

    /// @brief Initializing constructor for a single point.
    /// @param p Point location to initialize this AABB with.
    /// @post <code>rangeX</code> will have its min and max values both set to the
    ///   given point's X value.
    /// @post <code>rangeY</code> will have its min and max values both set to the
    ///   given point's Y value.
    PLAYRHO_CONSTEXPR inline explicit AABB(const Location p) noexcept
    {
        for (auto i = decltype(N){0}; i < N; ++i)
        {
            ranges[i] = LengthInterval{p[i]};
        }
    }

    /// @brief Initializing constructor for two points.
    /// @param a Point location "A" to initialize this AABB with.
    /// @param b Point location "B" to initialize this AABB with.
    PLAYRHO_CONSTEXPR inline AABB(const Location a, const Location b) noexcept
    {
        for (auto i = decltype(N){0}; i < N; ++i)
        {
            ranges[i] = LengthInterval{a[i], b[i]};
        }
    }

    /// @brief Holds the value range of each dimension from 0 to N-1.
    LengthInterval ranges[N];
};

/// @brief Gets whether the two AABB objects are equal.
/// @return <code>true</code> if the two values are equal, <code>false</code> otherwise.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline bool operator== (const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        if (lhs.ranges[i] != rhs.ranges[i])
        {
            return false;
        }
    }
    return true;
}

/// @brief Gets whether the two AABB objects are not equal.
/// @return <code>true</code> if the two values are not equal, <code>false</code> otherwise.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline bool operator!= (const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Less-than operator.
/// @relatedalso AABB
template <std::size_t N>
inline bool operator< (const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    return std::lexicographical_compare(cbegin(lhs.ranges), cend(lhs.ranges),
                                        cbegin(rhs.ranges), cend(rhs.ranges),
                                        std::less<LengthInterval>{});
}

/// @brief Less-than or equal-to operator.
/// @relatedalso AABB
template <std::size_t N>
inline bool operator<= (const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    const auto lhsEnd = cend(lhs.ranges);
    const auto rhsEnd = cend(rhs.ranges);
    const auto diff = std::mismatch(cbegin(lhs.ranges), lhsEnd,
                                    cbegin(rhs.ranges), rhsEnd);
    return (std::get<0>(diff) == lhsEnd) || (*std::get<0>(diff) < *std::get<1>(diff));
}

/// @brief Greater-than operator.
/// @relatedalso AABB
template <std::size_t N>
inline bool operator> (const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    return std::lexicographical_compare(cbegin(lhs.ranges), cend(lhs.ranges),
                                        cbegin(rhs.ranges), cend(rhs.ranges),
                                        std::greater<LengthInterval>{});
}

/// @brief Greater-than or equal-to operator.
/// @relatedalso AABB
template <std::size_t N>
inline bool operator>= (const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    const auto lhsEnd = cend(lhs.ranges);
    const auto rhsEnd = cend(rhs.ranges);
    const auto diff = std::mismatch(cbegin(lhs.ranges), lhsEnd,
                                    cbegin(rhs.ranges), rhsEnd);
    return (std::get<0>(diff) == lhsEnd) || (*std::get<0>(diff) > *std::get<1>(diff));
}

/// @brief Tests for overlap between two axis aligned bounding boxes.
/// @note This function's complexity is constant.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline bool TestOverlap(const AABB<N>& a, const AABB<N>& b) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        if (!IsIntersecting(a.ranges[i], b.ranges[i]))
        {
            return false;
        }
    }
    return true;
}

/// @brief Gets the intersecting AABB of the two given AABBs'.
template <std::size_t N>
PLAYRHO_CONSTEXPR inline AABB<N> GetIntersectingAABB(const AABB<N>& a, const AABB<N>& b) noexcept
{
    auto result = AABB<N>{};
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        result.ranges[i] = GetIntersection(a.ranges[i], b.ranges[i]);
    }
    return result;
}

/// @brief Gets the center of the AABB.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline Vector<Length, N> GetCenter(const AABB<N>& aabb) noexcept
{
    auto result = Vector<Length, N>{};
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        result[i] = GetCenter(aabb.ranges[i]);
    }
    return result;
}

/// @brief Gets dimensions of the given AABB.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline Vector<Length, N> GetDimensions(const AABB<N>& aabb) noexcept
{
    auto result = Vector<Length, N>{};
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        result[i] = GetSize(aabb.ranges[i]);
    }
    return result;
}

/// @brief Gets the extents of the AABB (half-widths).
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline Vector<Length, N> GetExtents(const AABB<N>& aabb) noexcept
{
    return GetDimensions(aabb) / 2;
}

/// @brief Checks whether the first AABB fully contains the second AABB.
/// @details Whether the first AABB contains the entirety of the second AABB where
///   containment is defined as being equal-to or within an AABB.
/// @note The "unset" AABB is contained by all valid AABBs including the "unset"
///   AABB itself.
/// @param a AABB to test whether it contains the second AABB.
/// @param b AABB to test whether it's contained by the first AABB.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline bool Contains(const AABB<N>& a, const AABB<N>& b) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        if (!IsEntirelyEnclosing(a.ranges[i], b.ranges[i]))
        {
            return false;
        }
    }
    return true;
}

/// @brief Includes the given location into the given AABB.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline AABB<N>& Include(AABB<N>& var, const Vector<Length, N>& value) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        var.ranges[i].Include(value[i]);
    }
    return var;
}

/// @brief Includes the second AABB into the first one.
/// @note If an unset AABB is added to the first AABB, the result will be the first AABB.
/// @note If the first AABB is unset and another AABB is added to it, the result will be
///   the other AABB.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline AABB<N>& Include(AABB<N>& var, const AABB<N>& val) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        var.ranges[i].Include(val.ranges[i]);
    }
    return var;
}

/// @brief Moves the given AABB by the given value.
template <std::size_t N>
PLAYRHO_CONSTEXPR inline AABB<N>& Move(AABB<N>& var, const Vector<Length, N> value) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        var.ranges[i].Move(value[i]);
    }
    return var;
}

/// @brief Fattens an AABB by the given amount.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline AABB<N>& Fatten(AABB<N>& var, const NonNegative<Length> amount) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        var.ranges[i].ExpandEqually(amount);
    }
    return var;
}

/// @brief Gets the AABB that the result of displacing the given AABB by the given
///   displacement amount.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline AABB<N> GetDisplacedAABB(AABB<N> aabb, const Vector<Length, N> displacement)
{
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        aabb.ranges[i].Expand(displacement[i]);
    }
    return aabb;
}

/// @brief Gets the fattened AABB result.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline AABB<N> GetFattenedAABB(AABB<N> aabb, const Length amount)
{
    return Fatten(aabb, amount);
}

/// @brief Gets the result of moving the given AABB by the given value.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline AABB<N> GetMovedAABB(AABB<N> aabb, const Vector<Length, N> value) noexcept
{
    return Move(aabb, value);
}

/// @brief Gets the AABB that minimally encloses the given AABBs.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline AABB<N> GetEnclosingAABB(AABB<N> a, const AABB<N>& b)
{
    return Include(a, b);
}

/// @brief Gets the lower bound.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline Vector<Length, N> GetLowerBound(const AABB<N>& aabb) noexcept
{
    auto result = Vector<Length, N>{};
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        result[i] = aabb.ranges[i].GetMin();
    }
    return result;
}

/// @brief Gets the upper bound.
/// @relatedalso AABB
template <std::size_t N>
PLAYRHO_CONSTEXPR inline Vector<Length, N> GetUpperBound(const AABB<N>& aabb) noexcept
{
    auto result = Vector<Length, N>{};
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        result[i] = aabb.ranges[i].GetMax();
    }
    return result;
}

/// @brief Output stream operator.
template <std::size_t N>
inline ::std::ostream& operator<< (::std::ostream& os, const AABB<N>& value)
{
    os << "{";
    auto multiple = false;
    for (const auto& range: value.ranges)
    {
        if (multiple)
        {
            os << ',';
        }
        else
        {
            multiple = true;
        }
        os << range;
    }
    os << "}";
    return os;
}

} // namespace detail

namespace d2 {

class Shape;
class Fixture;
class Body;
class Contact;
class DistanceProxy;
struct Transformation;

using detail::TestOverlap;
using detail::Contains;

/// @brief 2-Dimensional Axis Aligned Bounding Box.
/// @note This data structure is 16-bytes large (on at least one 64-bit platform).
using AABB = detail::AABB<2>;

/// @brief Gets the perimeter length of the 2-dimensional AABB.
/// @warning Behavior is undefined for an invalid AABB.
/// @return Twice the sum of the width and height.
/// @relatedalso playrho::detail::AABB
/// @sa https://en.wikipedia.org/wiki/Perimeter
PLAYRHO_CONSTEXPR inline Length GetPerimeter(const AABB& aabb) noexcept
{
    return (GetSize(aabb.ranges[0]) + GetSize(aabb.ranges[1])) * 2;
}

/// @brief Computes the AABB.
/// @details Computes the Axis Aligned Bounding Box (AABB) for the given child shape
///   at a given a transform.
/// @warning Behavior is undefined if the given transformation is invalid.
/// @param proxy Distance proxy for the child shape.
/// @param xf World transform of the shape.
/// @return AABB for the proxy shape or the default AABB if the proxy has a zero vertex count.
/// @relatedalso DistanceProxy
AABB ComputeAABB(const DistanceProxy& proxy, const Transformation& xf) noexcept;

/// @brief Computes the AABB.
/// @details Computes the Axis Aligned Bounding Box (AABB) for the given child shape
///   at the given transforms.
/// @warning Behavior is undefined if a given transformation is invalid.
/// @param proxy Distance proxy for the child shape.
/// @param xfm0 World transform 0 of the shape.
/// @param xfm1 World transform 1 of the shape.
/// @return AABB for the proxy shape or the default AABB if the proxy has a zero vertex count.
/// @relatedalso DistanceProxy
AABB ComputeAABB(const DistanceProxy& proxy,
                 const Transformation& xfm0, const Transformation& xfm1) noexcept;

/// @brief Computes the AABB for the given shape with the given transformation.
/// @relatedalso Shape
AABB ComputeAABB(const Shape& shape, const Transformation& xf) noexcept;

/// @brief Computes the AABB for the given fixture.
/// @details This is the AABB of the entire shape of the given fixture at the body's
///   location for the given fixture.
/// @relatedalso Fixture
AABB ComputeAABB(const Fixture& fixture) noexcept;

/// @brief Computes the AABB for the given body.
/// @relatedalso Body
AABB ComputeAABB(const Body& body);

/// @brief Computes the intersecting AABB for the given pair of fixtures and indexes.
/// @details The intersecting AABB for the given pair of fixtures is the intersection
///   of the AABB for child A of the shape of fixture A with the AABB for child B of
///   the shape of fixture B.
AABB ComputeIntersectingAABB(const Fixture& fA, ChildCounter iA,
                             const Fixture& fB, ChildCounter iB) noexcept;

/// @brief Computes the intersecting AABB for the given contact.
/// @relatedalso Contact
AABB ComputeIntersectingAABB(const Contact& contact);
    
/// @brief Gets the AABB for the given ray cast input data.
/// @relatedalso playrho::detail::RayCastInput<2>
AABB GetAABB(const playrho::detail::RayCastInput<2>& input) noexcept;

} // namespace d2

/// @brief Gets an invalid AABB value.
/// @relatedalso detail::AABB
template <>
PLAYRHO_CONSTEXPR inline d2::AABB GetInvalid() noexcept
{
    return d2::AABB{LengthInterval{GetInvalid<Length>()}, LengthInterval{GetInvalid<Length>()}};
}

} // namespace playrho

#endif // PLAYRHO_COLLISION_AABB_HPP
