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

#ifndef PLAYRHO_MATH_HPP
#define PLAYRHO_MATH_HPP

/// @file
/// @brief Conventional and custom math related code.

#include <cassert>
#include <cmath>
#include <cstdint> // for std::int64_t
#include <cstdlib> // for std::size_t
#include <limits> // for std::numeric_limits
#include <numeric>
#include <type_traits> // for std::decay_t
#include <vector>

// IWYU pragma: begin_exports

#include "playrho/Matrix.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/Real.hpp"
#include "playrho/Span.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector.hpp"
#include "playrho/Vector2.hpp"
#include "playrho/Vector3.hpp"

// IWYU pragma: end_exports

namespace playrho {

struct ConstraintSolverConf;

// Import common standard mathematical functions into the playrho namespace...
using std::abs;
using std::atan2;
using std::cos;
using std::fmod;
using std::hypot;
using std::isfinite;
using std::isnan;
using std::isnormal;
using std::nextafter;
using std::pow;
using std::round;
using std::signbit;
using std::sin;
using std::sqrt;
using std::trunc;

// Other templates.

/// @brief Makes the given **value** into an **unsigned value**.
/// @note If the given value is negative, this will result in an unsigned value which is the
///   two's complement modulo-wrapped value.
/// @note This is different from <code>std::make_unsigned</code> in that this changes the **value**
///   to the value in the type that's the unsigned type equivalent of the input value.
///   <code>std::make_unsigned</code> merely provides the unsigned **type** equivalent.
template <typename T>
constexpr auto MakeUnsigned(const T& arg) noexcept
-> std::enable_if_t<std::is_signed_v<T>, std::make_unsigned_t<T>>
{
    return static_cast<std::make_unsigned_t<T>>(arg);
}

/// @defgroup Math Additional Math Functions
/// @brief Additional functions for common mathematical operations.
/// @details These are non-member non-friend functions for mathematical operations
///   especially those with mixed input and output types.
/// @{

/// @brief Secant method.
/// @see https://en.wikipedia.org/wiki/Secant_method
template <typename T, typename U>
constexpr auto Secant(const T& target, const U& a1, const T& s1, const U& a2, const T& s2)
-> decltype(a1 + (target - s1) * (a2 - a1) / (s2 - s1))
{
    return a1 + (target - s1) * (a2 - a1) / (s2 - s1);
}

/// @brief Bisection method.
/// @see https://en.wikipedia.org/wiki/Bisection_method
template <typename T>
constexpr auto Bisect(const T& a1, const T& a2)
-> decltype((a1 + a2) / 2)
{
    return (a1 + a2) / 2;
}

/// @brief Is-odd.
/// @details Determines whether the given integral value is odd (as opposed to being even).
template <typename T>
constexpr auto IsOdd(const T& val) -> decltype((val % 2) != T{})
{
    return (val % 2) != T{};
}

/// @brief Squares the given value.
template <class T>
constexpr auto Square(T t) noexcept(noexcept(t * t)) -> decltype(t * t)
{
    return t * t;
}

/// @brief Computes the arc-tangent of the given y and x values.
/// @return Normalized angle - an angle between -Pi and Pi inclusively.
/// @see https://en.cppreference.com/w/cpp/numeric/math/atan2
template <typename T>
inline auto Atan2(T y, T x)
{
    return Angle{static_cast<Real>(atan2(StripUnit(y), StripUnit(x))) * Radian};
}

/// @brief Computes the average of the given values.
template <typename T,
typename = std::enable_if_t<IsIterableV<T> &&
IsAddableV<decltype(*begin(std::declval<T>()))>>>
auto Average(const T& span)
{
    using value_type = decltype(*begin(std::declval<T>()));

    // Relies on C++11 zero initialization to zero initialize value_type.
    // See: http://en.cppreference.com/w/cpp/language/zero_initialization
    constexpr auto zero = value_type{};
    assert(zero * Real{2} == zero);

    // For C++17, switch from using std::accumulate to using std::reduce.
    const auto sum = std::accumulate(begin(span), end(span), zero);
    const auto count = std::max(size(span), std::size_t{1});
    return sum / static_cast<Real>(count);
}

/// @brief Default round-off precision.
constexpr auto DefaultRoundOffPrecission = unsigned{100000};

/// @brief Computes the rounded value of the given value.
template <typename T>
auto RoundOff(const T& value, unsigned precision = DefaultRoundOffPrecission) ->
decltype(round(value * static_cast<T>(precision)) / static_cast<T>(precision))
{
    const auto factor = static_cast<T>(precision);
    return round(value * factor) / factor;
}

/// @brief Computes the rounded value of the given value.
/// @todo Consider making this function generic to any <code>Vector</code>.
inline auto RoundOff(const Vec2& value, std::uint32_t precision = DefaultRoundOffPrecission) -> Vec2
{
    return {RoundOff(value[0], precision), RoundOff(value[1], precision)};
}

/// @brief Gets whether a given value is almost zero.
/// @details An almost zero value is "subnormal". Dividing by these values can lead to
/// odd results like a divide by zero trap occurring.
/// @return <code>true</code> if the given value is almost zero, <code>false</code> otherwise.
template <typename T>
constexpr auto AlmostZero(const T& value) -> decltype(abs(value) < std::numeric_limits<T>::min())
{
    return abs(value) < std::numeric_limits<T>::min();
}

/// @brief Determines whether the given two values are "almost equal".
/// @note A default ULP of 4 is what googletest uses in its @c kMaxUlps setting for its
///   @c AlmostEquals function found in its @c gtest/internal/gtest-internal.h file.
/// @see https://github.com/google/googletest/blob/main/googletest/include/gtest/internal/gtest-internal.h
template <typename T>
constexpr auto AlmostEqual(T a, T b, int ulp = 4)
    -> std::enable_if_t<IsArithmeticV<T>, bool>
{
    for (; (a != b) && (ulp > 0); --ulp) {
        a = nextafter(a, b);
    }
    return a == b;
}

/// @brief Constant expression enhanced truncate function.
/// @note Unlike <code>std::trunc</code>, this function is only defined for finite values.
/// @see https://en.cppreference.com/w/cpp/numeric/math/trunc
template <class T>
constexpr auto ctrunc(T v) noexcept
{
    assert(isfinite(v));
    return T(std::int64_t(v));
}

/// @brief Constant expression enhanced floor function.
/// @note Unlike <code>std::floor</code>, this function is only defined for finite values.
/// @see https://en.cppreference.com/w/cpp/numeric/math/floor
template <class T>
constexpr auto cfloor(T v) noexcept
{
    assert(isfinite(v));
    return T((v >= T{}) ? static_cast<std::int64_t>(v) : static_cast<std::int64_t>(v) - 1);
}

#if defined(PLAYRHO_USE_BOOST_UNITS)
/// @brief Constant expression enhanced floor function for boost units.
/// @note Unlike <code>std::floor</code>, this function is only defined for finite values.
/// @see https://en.cppreference.com/w/cpp/numeric/math/floor
template <class Unit>
constexpr auto cfloor(const boost::units::quantity<Unit, Real>& v) noexcept
{
    using quantity = boost::units::quantity<Unit, Real>;
    return quantity::from_value(cfloor(v.value()));
}
#endif

/// @brief Modulo operation using <code>std::fmod</code>.
/// @note Modulo via <code>std::fmod</code> appears slower than via <code>std::trunc</code>.
/// @see ModuloViaTrunc
template <typename T>
auto ModuloViaFmod(T dividend, T divisor)
{
    // Note: modulo via std::fmod appears slower than via std::trunc.
    return static_cast<T>(fmod(dividend, divisor));
}

/// @brief Modulo operation using <code>std::trunc</code>.
/// @note Modulo via <code>std::fmod</code> appears slower than via <code>std::trunc</code>.
/// @note This function won't behave like <code>ModuloViaFmod</code> when divisor is infinite.
/// @param dividend Dividend value for which <code>isfinite</code> returns true.
/// @param divisor Divisor value for which <code>isfinite</code> returns true.
/// @see ModuloViaFmod
template <typename T>
auto ModuloViaTrunc(T dividend, T divisor) noexcept
{
    const auto quotient = dividend / divisor;
    return (quotient - trunc(quotient)) * divisor;
}

/// @brief Gets the "normalized" value of the given angle.
/// @note An angle of zero (0), represents the positive X-axis.
/// @note Both -Pi and +Pi normalize to -Pi.
/// @param value A finite angular value. Behavior of this function is not defined if given a
///   non-finite value.
/// @return Angle that's greater than or equal to -Pi and that's less than +Pi radians. I.e. the
///   value returned will be a value within the half-open interval of [-Pi, +Pi).
/// @see Atan2
Angle GetNormalized(Angle value) noexcept;

/// @brief Gets the angle.
/// @return Angular value in the range of -Pi to +Pi radians.
template <class T>
inline Angle GetAngle(const Vector2<T>& value)
{
    return Atan2(GetY(value), GetX(value));
}

/// @brief Gets the square of the magnitude of the given iterable value.
/// @note For performance, use this instead of <code>GetMagnitude(T value)</code> (if possible).
/// @return Non-negative value from 0 to infinity, or NaN.
/// @see GetMagnitude.
template <typename T>
constexpr auto GetMagnitudeSquared(const T& value) noexcept
{
    using VT = typename T::value_type;
    using OT = decltype(VT{} * VT{});
    auto result = OT{};
    for (auto&& e : value) {
        result += Square(e);
    }
    return result;
}

/// @brief Gets the magnitude of the given value.
/// @note Works for any type for which <code>GetMagnitudeSquared</code> also works.
/// @see GetMagnitudeSquared.
template <typename T>
inline auto GetMagnitude(const T& value) noexcept(noexcept(sqrt(GetMagnitudeSquared(value))))
-> decltype(sqrt(GetMagnitudeSquared(value)))
{
    return sqrt(GetMagnitudeSquared(value));
}

/// @brief Performs the dot product on two vectors (A and B).
///
/// @details The dot product of two vectors is defined as:
///   the magnitude of vector A, multiplied by, the magnitude of vector B,
///   multiplied by, the cosine of the angle between the two vectors (A and B).
///   Thus the dot product of two vectors is a value ranging between plus and minus the
///   magnitudes of each vector times each other.
///   The middle value of 0 indicates that two vectors are perpendicular to each other
///   (at an angle of +/- 90 degrees from each other).
///
/// @note This operation is commutative. I.e. Dot(a, b) == Dot(b, a).
/// @note If A and B are the same vectors, <code>GetMagnitudeSquared(Vec2)</code> returns
///   the same value using effectively one less input parameter.
/// @note This is similar to the <code>std::inner_product</code> standard library algorithm
///   except benchmark tests suggest this implementation is faster at least for
///   <code>Vec2</code> like instances.
///
/// @see https://en.wikipedia.org/wiki/Dot_product
///
/// @param a Vector A.
/// @param b Vector B.
///
/// @return Dot product of the vectors (0 means the two vectors are perpendicular).
///
template <typename T1, typename T2>
constexpr auto Dot(const T1& a, const T2& b) noexcept
{
    static_assert(std::tuple_size_v<T1> == std::tuple_size_v<T2>,
                  "Dot only for same tuple-like sized types");
    using VT1 = typename T1::value_type;
    using VT2 = typename T2::value_type;
    using OT = decltype(VT1{} * VT2{});
    auto result = OT{};
    const auto numElements = size(a);
    for (auto i = decltype(numElements){0}; i < numElements; ++i) {
        result += a[i] * b[i];
    }
    return result;
}

/// @brief Performs the 2-element analog of the cross product of two vectors.
///
/// @details Defined as the result of: <code>(a.x * b.y) - (a.y * b.x)</code>.
///
/// @note This operation is dimension squashing. I.e. A cross of a 2-D length by a 2-D unit
///   vector results in a 1-D length value.
/// @note The unit of the result is the 1-D product of the inputs.
/// @note This operation is anti-commutative. I.e. Cross(a, b) == -Cross(b, a).
/// @note The result will be 0 if any of the following are true:
///   vector A or vector B has a length of zero;
///   vectors A and B point in the same direction; or
///   vectors A and B point in exactly opposite direction of each other.
/// @note The result will be positive if:
///   neither vector A nor B has a length of zero; and
///   vector B is at an angle from vector A of greater than 0 and less than 180 degrees
///   (counter-clockwise from A being a positive angle).
/// @note Result will be negative if:
///   neither vector A nor B has a length of zero; and
///   vector B is at an angle from vector A of less than 0 and greater than -180 degrees
///   (clockwise from A being a negative angle).
/// @note The absolute value of the result is the area of the parallelogram formed by
///   the vectors A and B.
///
/// @see https://en.wikipedia.org/wiki/Cross_product
///
/// @return Cross product of the two values.
///
template <
class T1, class T2,
std::enable_if_t<std::tuple_size_v<T1> == 2 && std::tuple_size_v<T2> == 2, int> = 0>
constexpr auto Cross(const T1& a, const T2& b) noexcept
{
    assert(isfinite(StripUnit(get<0>(a))));
    assert(isfinite(StripUnit(get<1>(a))));
    assert(isfinite(StripUnit(get<0>(b))));
    assert(isfinite(StripUnit(get<1>(b))));
    // Both vectors of same direction...
    // If a = Vec2{1, 2} and b = Vec2{1, 2} then: a x b = 1 * 2 - 2 * 1 = 0.
    // If a = Vec2{1, 2} and b = Vec2{2, 4} then: a x b = 1 * 4 - 2 * 2 = 0.
    //
    // Vectors at +/- 90 degrees of each other...
    // If a = Vec2{1, 2} and b = Vec2{-2, 1} then: a x b = 1 * 1 - 2 * (-2) = 1 + 4 = 5.
    // If a = Vec2{1, 2} and b = Vec2{2, -1} then: a x b = 1 * (-1) - 2 * 2 = -1 - 4 = -5.
    //
    // Vectors between 0 and 180 degrees of each other excluding 90 degrees...
    // If a = Vec2{1, 2} and b = Vec2{-1, 2} then: a x b = 1 * 2 - 2 * (-1) = 2 + 2 = 4.
    const auto minuend = get<0>(a) * get<1>(b);
    const auto subtrahend = get<1>(a) * get<0>(b);
    assert(isfinite(StripUnit(minuend)));
    assert(isfinite(StripUnit(subtrahend)));
    return minuend - subtrahend;
}

/// @brief Cross-products the given two values.
/// @note This operation is anti-commutative. I.e. Cross(a, b) == -Cross(b, a).
/// @see https://en.wikipedia.org/wiki/Cross_product
/// @param a Value A of a 3-element type.
/// @param b Value B of a 3-element type.
/// @return Cross product of the two values.
template <
class T1, class T2,
std::enable_if_t<std::tuple_size_v<T1> == 3 && std::tuple_size_v<T2> == 3, int> = 0>
constexpr auto Cross(const T1& a, const T2& b) noexcept
{
    assert(isfinite(get<0>(a)));
    assert(isfinite(get<1>(a)));
    assert(isfinite(get<2>(a)));
    assert(isfinite(get<0>(b)));
    assert(isfinite(get<1>(b)));
    assert(isfinite(get<2>(b)));
    using OT = decltype(get<0>(a) * get<0>(b));
    return Vector<OT, 3>{GetY(a) * GetZ(b) - GetZ(a) * GetY(b),
        GetZ(a) * GetX(b) - GetX(a) * GetZ(b),
        GetX(a) * GetY(b) - GetY(a) * GetX(b)};
}

/// @brief Solves A * x = b, where b is a column vector.
/// @note This is more efficient than computing the inverse in one-shot cases.
template <typename T, typename U>
constexpr auto Solve(const Matrix22<U>& mat, const Vector2<T>& b) noexcept
{
    const auto cp = Cross(get<0>(mat), get<1>(mat));
    using OutType = decltype((U{} * T{}) / cp);
    if (!AlmostZero(StripUnit(cp))) {
        const auto inverse = 1 / cp;
        return Vector2<OutType>{
            (get<1>(mat)[1] * b[0] - get<1>(mat)[0] * b[1]) * inverse,
            (get<0>(mat)[0] * b[1] - get<0>(mat)[1] * b[0]) * inverse
        };
    }
    return Vector2<OutType>{};
}

/// @brief Inverts the given value.
template <class IN_TYPE>
constexpr auto Invert(const Matrix22<IN_TYPE>& value) noexcept
{
    const auto cp = Cross(get<0>(value), get<1>(value));
    using OutType = decltype(get<0>(value)[0] / cp);
    if (!AlmostZero(StripUnit(cp))) {
        const auto inverse = 1 / cp;
        return Matrix22<OutType>{
            Vector2<OutType>{get<1>(get<1>(value)) * inverse, -get<1>(get<0>(value)) * inverse},
            Vector2<OutType>{-get<0>(get<1>(value)) * inverse, get<0>(get<0>(value)) * inverse}
        };
    }
    return Matrix22<OutType>{};
}

/// @brief Solves A * x = b, where b is a column vector.
/// @note This is more efficient than computing the inverse in one-shot cases.
template <typename T>
constexpr auto Solve33(const Mat33& mat, const Vector3<T>& b) noexcept -> Vector3<T>
{
    const auto dp = Dot(GetX(mat), Cross(GetY(mat), GetZ(mat)));
    const auto det = (dp != 0) ? (1 / dp) : dp;
    return { // line break
        det * Dot(b, Cross(GetY(mat), GetZ(mat))), // x-component
        det * Dot(GetX(mat), Cross(b, GetZ(mat))), // y-component
        det * Dot(GetX(mat), Cross(GetY(mat), b))  // z-component
    };
}

/// @brief Solves A * x = b, where b is a column vector.
/// @note This is more efficient than computing the inverse in one-shot cases.
/// @note Solves only the upper 2-by-2 matrix equation.
template <typename T>
constexpr auto Solve22(const Mat33& mat, const Vector2<T>& b) noexcept -> Vector2<T>
{
    const auto matXX = GetX(GetX(mat));
    const auto matXY = GetX(GetY(mat));
    const auto matYX = GetY(GetX(mat));
    const auto matYY = GetY(GetY(mat));
    const auto cp = matXX * matYY - matXY * matYX;
    const auto det = (cp != 0) ? (1 / cp) : cp;
    return { // line break
        det * (matYY * GetX(b) - matXY * GetY(b)), // x-component
        det * (matXX * GetY(b) - matYX * GetX(b))  // y-component
    };
}

/// @brief Gets the inverse of the given matrix as a 2-by-2.
/// @return Zero matrix if singular.
constexpr auto GetInverse22(const Mat33& value) noexcept -> Mat33
{
    const auto a = GetX(GetX(value));
    const auto b = GetX(GetY(value));
    const auto c = GetY(GetX(value));
    const auto d = GetY(GetY(value));
    auto det = (a * d) - (b * c);
    if (det != Real{0}) {
        det = Real{1} / det;
    }
    return {Vec3{det * d, -det * c, Real{0}}, Vec3{-det * b, det * a, 0}, Vec3{0, 0, 0}};
}

/// @brief Gets the symmetric inverse of this matrix as a 3-by-3.
/// @return Zero matrix if singular.
constexpr auto GetSymInverse33(const Mat33& value) noexcept -> Mat33
{
    const auto invDet = Dot(GetX(value), Cross(GetY(value), GetZ(value)));
    const auto det = (invDet != Real{0})? (Real{1} / invDet): invDet;
    const auto a11 = GetX(GetX(value));
    const auto a12 = GetX(GetY(value));
    const auto a13 = GetX(GetZ(value));
    const auto a22 = GetY(GetY(value));
    const auto a23 = GetY(GetZ(value));
    const auto a33 = GetZ(GetZ(value));
    const auto ex_y = det * (a13 * a23 - a12 * a33);
    const auto ey_z = det * (a13 * a12 - a11 * a23);
    const auto ex_z = det * (a12 * a23 - a13 * a22);
    return {Vec3{det * (a22 * a33 - a23 * a23), ex_y, ex_z},
        Vec3{ex_y, det * (a11 * a33 - a13 * a13), ey_z},
        Vec3{ex_z, ey_z, det * (a11 * a22 - a12 * a12)}};
}

/// @brief Multiplies an M-element vector by an M-by-N matrix.
/// @param v Vector that's interpreted as a matrix with 1 row and M-columns.
/// @param m An M-row by N-column *transformation matrix* to multiply the vector by.
/// @see https://en.wikipedia.org/wiki/Transformation_matrix
template <std::size_t M, typename T1, std::size_t N, typename T2>
constexpr auto Transform(const Vector<T1, M>& v, const Matrix<T2, M, N>& m) noexcept
{
    return m * v;
}

/// @brief Multiplies a vector by a matrix.
constexpr Vec2 Transform(const Vec2& v, const Mat33& A) noexcept
{
    return {get<0>(get<0>(A)) * v[0] + get<0>(get<1>(A)) * v[1],
        get<1>(get<0>(A)) * v[0] + get<1>(get<1>(A)) * v[1]};
}

/// Multiply a matrix transpose times a vector. If a rotation matrix is provided,
/// then this transforms the vector from one frame to another (inverse transform).
constexpr Vec2 InverseTransform(const Vec2& v, const Mat22& A) noexcept
{
    return {Dot(v, GetX(A)), Dot(v, GetY(A))};
}

/// @brief Computes A^T * B.
constexpr Mat22 MulT(const Mat22& A, const Mat22& B) noexcept
{
    const auto c1 = Vec2{Dot(GetX(A), GetX(B)), Dot(GetY(A), GetX(B))};
    const auto c2 = Vec2{Dot(GetX(A), GetY(B)), Dot(GetY(A), GetY(B))};
    return {c1, c2};
}

/// @brief Gets the next largest power of 2
/// @details
/// Given a binary integer value x, the next largest power of 2 can be computed by a S.W.A.R.
/// algorithm that recursively "folds" the upper bits into the lower bits. This process yields
/// a bit vector with the same most significant 1 as x, but all one's below it. Adding 1 to
/// that value yields the next largest power of 2.
template <typename T>
constexpr auto NextPowerOfTwo(T x) -> decltype((x | (x >> 1u)), T(++x))
{
    constexpr auto MaxTypeSizeInBytesSupported = 32u;
    constexpr auto BitsPerByte = 8u;
    static_assert(sizeof(T) < MaxTypeSizeInBytesSupported);
    for (auto shift = 1u; shift < (sizeof(T) * BitsPerByte); shift <<= 1u) {
        x |= (x >> shift);
    }
    return ++x;
}

/// @brief Reports whether or not the given value is a power of two.
template <typename T>
constexpr auto IsPowerOfTwo(const T& n) -> decltype(n && !(n & (n - 1)))
{
    return n && !(n & (n - 1));
}

/// @brief Converts the given vector into a unit vector and returns its original length.
Real Normalize(Vec2& vector);

/// @brief Computes the centroid of a counter-clockwise array of 3 or more vertices.
/// @pre @p vertices Has 3 or more elements and they're in counter-clockwise order.
Length2 ComputeCentroid(const Span<const Length2>& vertices);

/// @brief Gets the modulo next value.
/// @param value To get the modulo next value for.
/// @param count Count to wrap around at. Must be greater-than zero.
/// @pre @p value is less than @p count.
/// @pre @p count is greater-than zero.
/// @pre @p value plus one is greater-than zero.
/// @see GetModuloPrev.
template <typename T>
constexpr auto GetModuloNext(T value, const T count) noexcept
-> decltype(++value, (value < count)? value: static_cast<T>(0), T())
{
    assert(value < count);
    assert(count > static_cast<T>(0));
    assert((value + static_cast<T>(1)) > static_cast<T>(0));
    ++value;
    return (value < count)? value: static_cast<T>(0);
}

/// @brief Gets the modulo previous value.
/// @param value To get the modulo previous value for.
/// @param count Count to wrap around at. Must be greater-than zero.
/// @pre @p count is greater-than zero and @p value is less than @p count.
/// @see GetModuloNext.
template <typename T>
constexpr auto GetModuloPrev(const T value, const T count) noexcept
-> decltype((value ? value : count) - static_cast<T>(1), T())
{
    assert(value < count);
    assert(count > static_cast<T>(0));
    assert((value + static_cast<T>(1)) > static_cast<T>(0));
    return (value ? value : count) - static_cast<T>(1);
}

/// @brief Converts the given value to its closest signed equivalent.
template< class T >
constexpr auto ToSigned(const T& value) -> decltype(static_cast<std::make_signed_t<T>>(value))
{
    return static_cast<std::make_signed_t<T>>(value);
}

/// @brief Gets the shortest angular distance to go from angle 0 to angle 1.
/// @details This gets the angle to rotate angle 0 by, in order to get to angle 1, with the
///   least amount of rotation.
/// @return Angle between -Pi and Pi radians inclusively.
/// @see GetNormalized
Angle GetShortestDelta(Angle a0, Angle a1) noexcept;

/// @brief Gets the forward/clockwise rotational angle to go from angle 1 to angle 2.
/// @return Angular rotation in the clockwise direction to go from angle 1 to angle 2.
constexpr Angle GetFwdRotationalAngle(const Angle& a1, const Angle& a2) noexcept
{
    constexpr auto FullCircleAngle = 360_deg;
    return (a1 < a2) ? (a2 - a1) - FullCircleAngle : a2 - a1;
}

/// @brief Gets the reverse (counter) clockwise rotational angle to go from angle 1 to angle 2.
/// @return Angular rotation in the counter clockwise direction to go from angle 1 to angle 2.
constexpr Angle GetRevRotationalAngle(const Angle& a1, const Angle& a2) noexcept
{
    constexpr auto FullCircleAngle = 360_deg;
    return (a1 > a2) ? FullCircleAngle - (a1 - a2) : a2 - a1;
}

/// @brief Gets the vertices for a circle described by the given parameters.
std::vector<Length2> GetCircleVertices(Length radius, std::size_t slices, Angle start = 0_deg,
                                       Real turns = Real(1));

/// @brief Gets the area of a circle.
NonNegativeFF<Area> GetAreaOfCircle(Length radius);

/// @brief Gets the area of a polygon.
/// @note This function is valid for any non-self-intersecting (simple) polygon,
///   which can be convex or concave.
/// @note Winding order doesn't matter.
NonNegativeFF<Area> GetAreaOfPolygon(const Span<const Length2>& vertices);

/// @brief Gets the polar moment of the area enclosed by the given vertices.
/// @param vertices Collection of three or more vertices.
/// @pre @p vertices has 3 or more elements.
SecondMomentOfArea GetPolarMoment(const Span<const Length2>& vertices);

/// @}

} // namespace playrho

#endif // PLAYRHO_MATH_HPP
