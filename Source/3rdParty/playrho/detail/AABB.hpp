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

#ifndef PLAYRHO_DETAIL_AABB_HPP
#define PLAYRHO_DETAIL_AABB_HPP

/// @file
/// @brief Declaration of the AABB class and free functions that return instances of it.

#include <algorithm> // for std::mismatch, lexicographical_compare, etc
#include <cstddef> // for std::size_t
#include <functional> // for std::less, std::greater
#include <ostream>
#include <type_traits>

// IWYU pragma: begin_exports

// IWYU pragma: private
// IWYU pragma: friend "playrho/.*"

#include "playrho/Intervals.hpp" // for LengthInterval, IsIntersecting
#include "playrho/NonNegative.hpp"
#include "playrho/Real.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector.hpp"

// IWYU pragma: end_exports

namespace playrho::detail {

/// @brief N-dimensional Axis Aligned Bounding Box.
///
/// @details This is a concrete value class template for an N-dimensional axis aligned
///   bounding box (AABB) which is a type of bounding volume.
///
/// @note This class satisfies at least the following named requirement: all the basic named
///   requirements, <code>EqualityComparable</code>, and <code>Swappable</code>.
/// @note This class is composed of &mdash; as in contains and owns &mdash; N
///   <code>LengthInterval</code> variables.
/// @note Non-defaulted methods of this class are marked <code>noexcept</code> and expect
///   that the Length type doesn't throw.
///
/// @see https://en.wikipedia.org/wiki/Bounding_volume
/// @see https://en.cppreference.com/w/cpp/named_req
///
template <std::size_t N>
struct AABB {
    /// @brief Alias for the location type.
    using Location = Vector<Length, N>;

    /// @brief Default constructor.
    /// @details Constructs an "unset" AABB.
    /// @note If an unset AABB is added to another AABB, the result will be the other AABB.
    constexpr AABB() = default;

    /// @brief Initializing constructor.
    /// @details Initializing constructor supporting construction by the same number of elements
    ///   as this AABB template type is defined for.
    /// @note For example this enables a 2-dimensional AABB to be constructed as:
    /// @code{.cpp}
    /// const auto aabb = AABB<2>{LengthInterval{1_m, 4_m}, LengthInterval{-3_m, 3_m}};
    /// @endcode
    template <typename... Tail>
    constexpr AABB(std::enable_if_t<sizeof...(Tail) + 1 == N, LengthInterval> head,
                   Tail... tail) noexcept
        : ranges{head, LengthInterval(tail)...}
    {
        // Intentionally empty.
    }

    /// @brief Initializing constructor for a single point.
    /// @param p Point location to initialize this AABB with.
    /// @post <code>rangeX</code> will have its min and max values both set to the
    ///   given point's X value.
    /// @post <code>rangeY</code> will have its min and max values both set to the
    ///   given point's Y value.
    constexpr explicit AABB(const Location p) noexcept
    {
        for (auto i = decltype(N){0}; i < N; ++i) {
            ranges[i] = LengthInterval{p[i]};
        }
    }

    /// @brief Initializing constructor for two points.
    /// @param a Point location "A" to initialize this AABB with.
    /// @param b Point location "B" to initialize this AABB with.
    constexpr AABB(const Location a, const Location b) noexcept
    {
        for (auto i = decltype(N){0}; i < N; ++i) {
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
constexpr bool operator==(const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i) {
        if (lhs.ranges[i] != rhs.ranges[i]) {
            return false;
        }
    }
    return true;
}

/// @brief Gets whether the two AABB objects are not equal.
/// @return <code>true</code> if the two values are not equal, <code>false</code> otherwise.
/// @relatedalso AABB
template <std::size_t N>
constexpr bool operator!=(const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Less-than operator.
/// @relatedalso AABB
template <std::size_t N>
inline bool operator<(const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    return std::lexicographical_compare(cbegin(lhs.ranges), cend(lhs.ranges), cbegin(rhs.ranges),
                                        cend(rhs.ranges), std::less<LengthInterval>{});
}

/// @brief Less-than or equal-to operator.
/// @relatedalso AABB
template <std::size_t N>
inline bool operator<=(const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    const auto lhsEnd = cend(lhs.ranges);
    const auto rhsEnd = cend(rhs.ranges);
    const auto diff = std::mismatch(cbegin(lhs.ranges), lhsEnd, cbegin(rhs.ranges), rhsEnd);
    return (std::get<0>(diff) == lhsEnd) || (*std::get<0>(diff) < *std::get<1>(diff));
}

/// @brief Greater-than operator.
/// @relatedalso AABB
template <std::size_t N>
inline bool operator>(const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    return std::lexicographical_compare(cbegin(lhs.ranges), cend(lhs.ranges), cbegin(rhs.ranges),
                                        cend(rhs.ranges), std::greater<LengthInterval>{});
}

/// @brief Greater-than or equal-to operator.
/// @relatedalso AABB
template <std::size_t N>
inline bool operator>=(const AABB<N>& lhs, const AABB<N>& rhs) noexcept
{
    const auto lhsEnd = cend(lhs.ranges);
    const auto rhsEnd = cend(rhs.ranges);
    const auto diff = std::mismatch(cbegin(lhs.ranges), lhsEnd, cbegin(rhs.ranges), rhsEnd);
    return (std::get<0>(diff) == lhsEnd) || (*std::get<0>(diff) > *std::get<1>(diff));
}

/// @brief Tests for overlap between two axis aligned bounding boxes.
/// @note This function's complexity is constant.
/// @relatedalso AABB
template <std::size_t N>
constexpr bool TestOverlap(const AABB<N>& a, const AABB<N>& b) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i) {
        if (!IsIntersecting(a.ranges[i], b.ranges[i])) {
            return false;
        }
    }
    return true;
}

/// @brief Gets the intersecting AABB of the two given AABBs'.
template <std::size_t N>
constexpr AABB<N> GetIntersectingAABB(const AABB<N>& a, const AABB<N>& b) noexcept
{
    auto result = AABB<N>{};
    for (auto i = decltype(N){0}; i < N; ++i) {
        result.ranges[i] = GetIntersection(a.ranges[i], b.ranges[i]);
    }
    return result;
}

/// @brief Gets the center of the AABB.
/// @relatedalso AABB
template <std::size_t N>
constexpr Vector<Length, N> GetCenter(const AABB<N>& aabb) noexcept
{
    auto result = Vector<Length, N>{};
    for (auto i = decltype(N){0}; i < N; ++i) {
        result[i] = GetCenter(aabb.ranges[i]);
    }
    return result;
}

/// @brief Gets dimensions of the given AABB.
/// @relatedalso AABB
template <std::size_t N>
constexpr Vector<Length, N> GetDimensions(const AABB<N>& aabb) noexcept
{
    auto result = Vector<Length, N>{};
    for (auto i = decltype(N){0}; i < N; ++i) {
        result[i] = GetSize(aabb.ranges[i]);
    }
    return result;
}

/// @brief Gets the extents of the AABB (half-widths).
/// @relatedalso AABB
template <std::size_t N>
constexpr Vector<Length, N> GetExtents(const AABB<N>& aabb) noexcept
{
    constexpr auto RealInverseOfTwo = Real{1} / Real{2};
    return GetDimensions(aabb) * RealInverseOfTwo;
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
constexpr bool Contains(const AABB<N>& a, const AABB<N>& b) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i) {
        if (!IsEntirelyEnclosing(a.ranges[i], b.ranges[i])) {
            return false;
        }
    }
    return true;
}

/// @brief Includes the given location into the given AABB.
/// @relatedalso AABB
template <std::size_t N>
constexpr AABB<N>& Include(AABB<N>& var, const Vector<Length, N>& value) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i) {
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
constexpr AABB<N>& Include(AABB<N>& var, const AABB<N>& val) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i) {
        var.ranges[i].Include(val.ranges[i]);
    }
    return var;
}

/// @brief Moves the given AABB by the given value.
template <std::size_t N>
constexpr AABB<N>& Move(AABB<N>& var, const Vector<Length, N> value) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i) {
        var.ranges[i].Move(value[i]);
    }
    return var;
}

/// @brief Fattens an AABB by the given amount.
/// @relatedalso AABB
template <std::size_t N>
constexpr AABB<N>& Fatten(AABB<N>& var, const NonNegative<Length> amount) noexcept
{
    for (auto i = decltype(N){0}; i < N; ++i) {
        var.ranges[i].ExpandEqually(amount);
    }
    return var;
}

/// @brief Gets the AABB that the result of displacing the given AABB by the given
///   displacement amount.
/// @relatedalso AABB
template <std::size_t N>
constexpr AABB<N> GetDisplacedAABB(AABB<N> aabb, const Vector<Length, N> displacement)
{
    for (auto i = decltype(N){0}; i < N; ++i) {
        aabb.ranges[i].Expand(displacement[i]);
    }
    return aabb;
}

/// @brief Gets the fattened AABB result.
/// @relatedalso AABB
template <std::size_t N>
constexpr AABB<N> GetFattenedAABB(AABB<N> aabb, const Length amount)
{
    return Fatten(aabb, amount);
}

/// @brief Gets the result of moving the given AABB by the given value.
/// @relatedalso AABB
template <std::size_t N>
constexpr AABB<N> GetMovedAABB(AABB<N> aabb, const Vector<Length, N> value) noexcept
{
    return Move(aabb, value);
}

/// @brief Gets the AABB that minimally encloses the given AABBs.
/// @relatedalso AABB
template <std::size_t N>
constexpr AABB<N> GetEnclosingAABB(AABB<N> a, const AABB<N>& b)
{
    return Include(a, b);
}

/// @brief Gets the lower bound.
/// @relatedalso AABB
template <std::size_t N>
constexpr Vector<Length, N> GetLowerBound(const AABB<N>& aabb) noexcept
{
    auto result = Vector<Length, N>{};
    for (auto i = decltype(N){0}; i < N; ++i) {
        result[i] = aabb.ranges[i].GetMin();
    }
    return result;
}

/// @brief Gets the upper bound.
/// @relatedalso AABB
template <std::size_t N>
constexpr Vector<Length, N> GetUpperBound(const AABB<N>& aabb) noexcept
{
    auto result = Vector<Length, N>{};
    for (auto i = decltype(N){0}; i < N; ++i) {
        result[i] = aabb.ranges[i].GetMax();
    }
    return result;
}

/// @brief Output stream operator.
template <std::size_t N>
inline ::std::ostream& operator<<(::std::ostream& os, const AABB<N>& value)
{
    os << "{";
    auto multiple = false;
    for (const auto& range : value.ranges) {
        if (multiple) {
            os << ',';
        }
        else {
            multiple = true;
        }
        os << range;
    }
    os << "}";
    return os;
}

} // namespace playrho::detail

#endif // PLAYRHO_DETAIL_AABB_HPP
