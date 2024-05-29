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

#ifndef PLAYRHO_D2_UNITVEC2_HPP
#define PLAYRHO_D2_UNITVEC2_HPP

/// @file
/// @brief Declarations of the UnitVec class and free functions associated with it.

#include <cassert> // for assert
#include <cmath> // for std::sqrt, etc
#include <cstdlib>
#include <iostream>
#include <utility>
#include <type_traits>

// IWYU pragma: begin_exports

#include "playrho/InvalidArgument.hpp"
#include "playrho/Real.hpp"
#include "playrho/RealConstants.hpp"
#include "playrho/Templates.hpp" // for IsValid
#include "playrho/Units.hpp"
#include "playrho/Vector.hpp"

#include "playrho/detail/UnitMagnitudeChecker.hpp"

// IWYU pragma: end_exports

namespace playrho {

// Explicitly import needed functions into this namespace to avoid including the math
//  header which itself expects UnitVec to already be defined.
using std::isnormal;
using std::sqrt;
using std::hypot;
using std::abs;

namespace d2 {

/// @brief 2-D unit vector.
/// @details This is a 2-dimensional directional vector.
/// @invariant The magnitude of a non-oriented unit vector is zero. The magnitude of an
///   oriented unit vector is approximately one, and is always more than zero.
class UnitVec
{
public:
    /// @brief Dimensionality of this type.
    static constexpr auto N = std::size_t{2};

    /// @brief Value type used for the coordinate values of this vector.
    using value_type = Real;

    /// @brief Alias for the underlying type of this object.
    using underlying_type = Vector<value_type, N>;

    /// @brief Size type.
    using size_type = underlying_type::size_type;

    /// @brief Constant reference type.
    using const_reference = underlying_type::const_reference;

    /// @brief Constant pointer type.
    using const_pointer = underlying_type::const_pointer;

    /// @brief Constant iterator type.
    using const_iterator = underlying_type::const_iterator;

    /// @brief Constant reverse iterator type.
    using const_reverse_iterator = underlying_type::const_reverse_iterator;

    /// @brief Alias for checker type this class template was instantiated for.
    using checker_type = detail::UnitMagnitudeChecker<underlying_type>;

    /// @brief Alias for the exception type possibly thrown by this class.
    using exception_type = InvalidArgument;

    /// @brief Throws this class's exception type if the given value is invalid.
    /// @throws exception_type Constructed with the returned error - if the checker
    ///   returned a non-null explanatory string.
    /// @see exception_type.
    static auto ThrowIfInvalid(const underlying_type& value) -> void
    {
        if (const auto error = checker_type{}(value)) {
            throw exception_type(error);
        }
    }

    // @brief Validator function.
    /// @details Validates the given value using the @c checker_type type and returns
    ///   the value given if it checks out.
    /// @throws exception_type Constructed with the returned error - if the checker
    ///   returned a non-null explanatory string.
    /// @return Value given.
    static auto Validate(const underlying_type& value) -> underlying_type
    {
        ThrowIfInvalid(value);
        return value;
    }

    /// @brief Gets the right-ward oriented unit vector.
    /// @note This is the value for the 0/4 turned (0 angled) unit vector.
    /// @note This is the reverse perpendicular unit vector of the down oriented vector.
    /// @note This is the forward perpendicular unit vector of the up oriented vector.
    static constexpr UnitVec GetRight() noexcept { return UnitVec{1, 0, {}}; }

    /// @brief Gets the up-ward oriented unit vector.
    /// @note This is the actual value for the 1/4 turned (90 degree angled) unit vector.
    /// @note This is the reverse perpendicular unit vector of the right oriented vector.
    /// @note This is the forward perpendicular unit vector of the left oriented vector.
    static constexpr UnitVec GetUp() noexcept { return UnitVec{0, 1, {}}; }

    /// @brief Gets the left-ward oriented unit vector.
    /// @note This is the actual value for the 2/4 turned (180 degree angled) unit vector.
    /// @note This is the reverse perpendicular unit vector of the up oriented vector.
    /// @note This is the forward perpendicular unit vector of the down oriented vector.
    static constexpr UnitVec GetLeft() noexcept { return UnitVec{-1, 0, {}}; }

    /// @brief Gets the down-ward oriented unit vector.
    /// @note This is the actual value for the 3/4 turned (270 degree angled) unit vector.
    /// @note This is the reverse perpendicular unit vector of the left oriented vector.
    /// @note This is the forward perpendicular unit vector of the right oriented vector.
    static constexpr UnitVec GetDown() noexcept { return UnitVec{0, -1, {}}; }

    /// @brief Gets the non-oriented unit vector.
    static constexpr UnitVec GetZero() noexcept { return UnitVec{}; }

    /// @brief Gets the 45 degree unit vector.
    /// @details This is the unit vector in the positive X and Y quadrant where X == Y.
    static constexpr UnitVec GetUpRight() noexcept
    {
        // Note that 1/sqrt(2) == sqrt(2)/(sqrt(2)*sqrt(2)) == sqrt(2)/2
        return UnitVec{+SquareRootTwo/Real(2), +SquareRootTwo/Real(2), {}};
    }

    /// @brief Gets the -45 degree unit vector.
    /// @details This is the unit vector in the positive X and negative Y quadrant
    ///   where |X| == |Y|.
    static constexpr UnitVec GetDownRight() noexcept
    {
        // Note that 1/sqrt(2) == sqrt(2)/(sqrt(2)*sqrt(2)) == sqrt(2)/2
        return UnitVec{+SquareRootTwo/Real(2), -SquareRootTwo/Real(2), {}};
    }

    /// @brief Gets the default fallback.
    static constexpr UnitVec GetDefaultFallback() noexcept { return UnitVec{}; }

    /// @brief Polar coordinate.
    /// @details This is a direction and magnitude pair defined by the unit vector class.
    /// @note A magnitude of 0 indicates that no conclusive direction could be determined.
    ///   The magnitude will otherwise be a normal value.
    template <typename T>
    using PolarCoord = std::enable_if_t<IsArithmeticV<T>, std::pair<UnitVec, T>>;

    /// @brief Gets the unit vector & magnitude from the given parameters.
    /// @see HypotGet.
    template <typename T>
    static PolarCoord<T> Get(const T x, const T y,
                             const UnitVec& fallback = GetDefaultFallback()) noexcept
    {
#if 0
        // Try the fastest way first...
        static constexpr auto t0 = T{};
        enum: unsigned { None = 0x0, Left = 0x1, Right = 0x2, Up = 0x4, Down = 0x8, NaN = 0xF };
        const auto xBits = (x > t0)? Right: (x < t0)? Left: (x == t0)? None: NaN;
        const auto yBits = (y > t0)? Up: (y < t0)? Down: (y == t0)? None: NaN;
        switch (xBits | yBits) {
        case Right: return std::make_pair(GetRight(), x);
        case Left: return std::make_pair(GetLeft(), -x);
        case Up: return std::make_pair(GetUp(), y);
        case Down: return std::make_pair(GetDown(), -y);
        case None: return std::make_pair(fallback, T{});
        case NaN: return std::make_pair(fallback, T{});
        default: break;
        }
#endif

        // Try the faster way next...
        const auto magnitudeSquared = x * x + y * y;
#if 0
        // UnitVectorFromVector/1000                      9562 ns         9472 ns        74858
        // UnitVectorFromVectorAndBack/1000               9549 ns         9438 ns        72501
        // UnitVecFromAngle/1000                          3360 ns         3351 ns       193443

        // UnitVectorFromVector/1000                      9417 ns         9363 ns        73743
        // UnitVectorFromVectorAndBack/1000               9224 ns         9195 ns        74121
        // UnitVecFromAngle/1000                          3327 ns         3312 ns       208817
        if (nextafter(nextafter(Real(StripUnit(magnitudeSquared)), Real(1)), Real(1)) == Real(1)) {
            return {UnitVec{value_type{StripUnit(x)}, value_type{StripUnit(y)}}, Real(1)};
        }
#else
        // UnitVectorFromVector/1000                      2291 ns         2279 ns       321588
        // UnitVectorFromVectorAndBack/1000               2136 ns         2123 ns       335097
        // UnitVecFromAngle/1000                          3575 ns         3556 ns       200317

        // UnitVectorFromVector/1000                      2316 ns         2307 ns       320174
        // UnitVectorFromVectorAndBack/1000               2309 ns         2302 ns       299427
        // UnitVecFromAngle/1000                          3327 ns         3312 ns       198916

        // UnitVectorFromVector/1000                      1714 ns         1711 ns       408220
        // UnitVectorFromVectorAndBack/1000               1722 ns         1712 ns       408537
        // UnitVecFromAngle/1000                          3412 ns         3384 ns       195707
#endif
        if (isnormal(magnitudeSquared))
        {
            const auto magnitude = sqrt(magnitudeSquared);
            assert(isnormal(magnitude));
            const auto invMagnitude = Real{1} / magnitude;
            return {UnitVec{value_type{x * invMagnitude}, value_type{y * invMagnitude}, {}}, magnitude};
        }

        // Finally, try the more accurate and robust way...
        const auto magnitude = hypot(x, y);
        if (!isnormal(magnitude)) {
            return std::make_pair(fallback, T{});
        }
        return std::make_pair(UnitVec{x / magnitude, y / magnitude, {}}, magnitude);
    }

    /// @brief Gets the given angled unit vector.
    /// @note For angles that are meant to be at exact multiples of the quarter turn,
    ///   better accuracy will be had by using one of the four oriented unit
    ///   vector returning methods - for the right, up, left, down orientations.
    static UnitVec Get(Angle angle) noexcept;

    /// @brief Default constructor.
    /// @details Constructs a non-oriented unit vector.
    /// @post <code>GetX()</code> and <code>GetY()</code> return zero.
    constexpr UnitVec() noexcept = default;

    /// @brief Initializing constructor.
    /// @details Explicitly converts a vector of unit magnitude to an object or throws.
    /// @note This function is intended for use with values having a magnitude believed to already
    ///   be within two ULPs of the real value of 1. Use a function like the polar coordinate
    ///   returning @c Get function instead for arbitrary values.
    /// @post @c GetX and @c GetY return the X and Y components respectively of the given value,
    ///   exactly.
    /// @throws exception_type Constructed with the returned error - if the checker
    ///   returned a non-null explanatory string.
    explicit UnitVec(const underlying_type& v) : m_elems{Validate(v)}
    {
        // Intentionally empty.
    }

    /// @brief Gets the max size.
    static constexpr size_type max_size() noexcept { return N; }

    /// @brief Gets the size.
    static constexpr size_type size() noexcept { return N; }

    /// @brief Whether empty.
    /// @note Always false for N > 0.
    static constexpr bool empty() noexcept { return false; }

    /// @brief Gets a "begin" iterator.
    const_iterator begin() const noexcept { return m_elems.begin(); }

    /// @brief Gets an "end" iterator.
    const_iterator end() const noexcept { return m_elems.end(); }

    /// @brief Gets a "begin" iterator.
    const_iterator cbegin() const noexcept { return m_elems.cbegin(); }

    /// @brief Gets an "end" iterator.
    const_iterator cend() const noexcept { return m_elems.cend(); }

    /// @brief Gets a reverse "begin" iterator.
    const_reverse_iterator crbegin() const noexcept
    {
        return m_elems.crbegin();
    }

    /// @brief Gets a reverse "end" iterator.
    const_reverse_iterator crend() const noexcept
    {
        return m_elems.crend();
    }

    /// @brief Gets a reverse "begin" iterator.
    const_reverse_iterator rbegin() const noexcept
    {
        return m_elems.rbegin();
    }

    /// @brief Gets a reverse "end" iterator.
    const_reverse_iterator rend() const noexcept
    {
        return m_elems.rend();
    }

    /// @brief Gets a constant reference to the requested element.
    /// @note No bounds checking is performed.
    /// @param pos Valid element index to get value for.
    /// @pre The given position parameter (@p pos), is less than <code>size()</code>.
    constexpr const_reference operator[](size_type pos) const noexcept
    {
        return m_elems[pos];
    }

    /// @brief Gets a constant reference to the requested element.
    /// @throws InvalidArgument if given a position that's >= size().
    constexpr const_reference at(size_type pos) const
    {
        return m_elems.at(pos);
    }

    /// @brief Direct access to data.
    constexpr const_pointer data() const noexcept
    {
        // Cast to be more explicit about wanting to decay array into pointer...
        return m_elems.data();
    }

    /// @brief Gets the "X" value.
    constexpr auto GetX() const noexcept { return m_elems[0]; }

    /// @brief Gets the "Y" value.
    constexpr auto GetY() const noexcept { return m_elems[1]; }

    /// @brief Flips the X and Y values.
    constexpr UnitVec FlipXY() const noexcept { return UnitVec{-GetX(), -GetY(), {}}; }

    /// @brief Flips the X value.
    constexpr UnitVec FlipX() const noexcept { return UnitVec{-GetX(), GetY(), {}}; }

    /// @brief Flips the Y value.
    constexpr UnitVec FlipY() const noexcept { return UnitVec{GetX(), -GetY(), {}}; }

    /// @brief Rotates the unit vector by the given amount.
    ///
    /// @param amount Expresses the angular difference from the right-ward oriented unit
    ///   vector to rotate this unit vector by.
    ///
    /// @return Result of rotating this unit vector by the given amount.
    ///
    constexpr UnitVec Rotate(const UnitVec& amount) const noexcept
    {
        return UnitVec{GetX() * amount.GetX() - GetY() * amount.GetY(), // newline
                       GetY() * amount.GetX() + GetX() * amount.GetY(), // newline
                       {}};
    }

    /// @brief Gets a vector counter-clockwise (reverse-clockwise) perpendicular to this vector.
    /// @details This returns the unit vector (-y, x).
    /// @return A counter-clockwise 90-degree rotation of this vector.
    /// @see GetFwdPerpendicular.
    constexpr UnitVec GetRevPerpendicular() const noexcept
    {
        // See http://mathworld.wolfram.com/PerpendicularVector.html
        return UnitVec{-GetY(), GetX(), {}};
    }

    /// @brief Gets a vector clockwise (forward-clockwise) perpendicular to this vector.
    /// @details This returns the unit vector (y, -x).
    /// @return A clockwise 90-degree rotation of this vector.
    /// @see GetRevPerpendicular.
    constexpr UnitVec GetFwdPerpendicular() const noexcept
    {
        // See http://mathworld.wolfram.com/PerpendicularVector.html
        return UnitVec{GetY(), -GetX(), {}};
    }

    /// @brief Implicitly gets the underlying value via a cast or implicit conversion.
    constexpr operator underlying_type () const noexcept
    {
        return m_elems;
    }

    /// @brief Negation operator.
    constexpr UnitVec operator-() const noexcept { return UnitVec{-GetX(), -GetY(), {}}; }

    /// @brief Positive operator.
    constexpr UnitVec operator+() const noexcept { return UnitVec{+GetX(), +GetY(), {}}; }

    /// @brief Gets the absolute value.
    constexpr UnitVec Absolute() const noexcept
    {
        return UnitVec{abs(GetX()), abs(GetY()), {}};
    }

private:
    struct Hidden {};

    /// @brief Initializing constructor.
    constexpr UnitVec(value_type x, value_type y, Hidden) noexcept : m_elems{x, y}
    {
        // Intentionally empty.
    }

    underlying_type m_elems = {}; ///< Element values.
};

// Free functions...

/// @brief Gets the "X-axis".
constexpr UnitVec GetXAxis(const UnitVec& rot) noexcept { return rot; }

/// @brief Gets the "Y-axis".
/// @note This is the reverse perpendicular vector of the given unit vector.
constexpr UnitVec GetYAxis(const UnitVec& rot) noexcept { return rot.GetRevPerpendicular(); }

/// @brief Equality operator.
constexpr bool operator==(const UnitVec& a, const UnitVec& b) noexcept
{
    return (a.GetX() == b.GetX()) && (a.GetY() == b.GetY());
}

/// @brief Inequality operator.
constexpr bool operator!=(const UnitVec& a, const UnitVec& b) noexcept
{
    return (a.GetX() != b.GetX()) || (a.GetY() != b.GetY());
}

/// @brief Gets a vector counter-clockwise (reverse-clockwise) perpendicular to the
///   given vector.
/// @details This takes a vector of form (x, y) and returns the vector (-y, x).
/// @param vector Vector to return a counter-clockwise perpendicular equivalent for.
/// @return A counter-clockwise 90-degree rotation of the given vector.
/// @see GetFwdPerpendicular.
constexpr UnitVec GetRevPerpendicular(const UnitVec& vector) noexcept
{
    return vector.GetRevPerpendicular();
}

/// @brief Gets a vector clockwise (forward-clockwise) perpendicular to the given vector.
/// @details This takes a vector of form (x, y) and returns the vector (y, -x).
/// @param vector Vector to return a clockwise perpendicular equivalent for.
/// @return A clockwise 90-degree rotation of the given vector.
/// @see GetRevPerpendicular.
constexpr UnitVec GetFwdPerpendicular(const UnitVec& vector) noexcept
{
    return vector.GetFwdPerpendicular();
}

/// @brief Rotates a unit vector by the angle expressed by the second unit vector.
/// @return Unit vector for the angle that's the sum of the two angles expressed by
///   the input unit vectors.
constexpr UnitVec Rotate(const UnitVec& vector, const UnitVec& angle) noexcept
{
    return vector.Rotate(angle);
}

/// @brief Inverse rotates a vector.
constexpr UnitVec InverseRotate(const UnitVec& vector, const UnitVec& angle) noexcept
{
    return vector.Rotate(angle.FlipY());
}

/// @brief Gets the specified element of the given collection.
template <std::size_t I>
constexpr UnitVec::value_type get(const UnitVec& v) noexcept
{
    static_assert(I < UnitVec::size(), "Index out of bounds in playrho::get<> (playrho::UnitVec)");
    switch (I)
    {
        case 0: return v.GetX();
        case 1: return v.GetY();
    }
}

/// @brief Gets element 0 of the given collection.
template <>
constexpr UnitVec::value_type get<0>(const UnitVec& v) noexcept
{
    return v.GetX();
}

/// @brief Gets element 1 of the given collection.
template <>
constexpr UnitVec::value_type get<1>(const UnitVec& v) noexcept
{
    return v.GetY();
}

/// @brief Gets the "X" element of the given value - i.e. the first element.
constexpr auto GetX(const UnitVec& value)
{
    return value.GetX();
}

/// @brief Gets the "Y" element of the given value - i.e. the second element.
constexpr auto GetY(const UnitVec& value) -> decltype(get<1>(value))
{
    return value.GetY();
}

/// @brief Output stream operator.
inline ::std::ostream& operator<<(::std::ostream& os, const UnitVec& value)
{
    return os << "UnitVec(" << get<0>(value) << "," << get<1>(value) << ")";
}

} // namespace d2

/// @brief Determines if the given value is valid.
constexpr auto IsValid(const d2::UnitVec& value) noexcept -> bool
{
    return IsValid(value.GetX()) && IsValid(value.GetY()) && (value != d2::UnitVec::GetZero());
}

/// @brief Gets the absolute value of the given value.
inline d2::UnitVec abs(const d2::UnitVec& v) noexcept
{
    return v.Absolute();
}

} // namespace playrho

/// @brief Tuple size info for <code>playrho::d2::UnitVec</code>.
template<>
class std::tuple_size< playrho::d2::UnitVec >: public std::integral_constant<std::size_t, playrho::d2::UnitVec::size()> {};

/// @brief Tuple element type info for <code>playrho::d2::UnitVec</code>.
template<std::size_t I>
class std::tuple_element<I, playrho::d2::UnitVec>
{
public:
    /// @brief Type alias revealing the actual type of the element.
    using type = playrho::Real;
};

#endif // PLAYRHO_D2_UNITVEC2_HPP
