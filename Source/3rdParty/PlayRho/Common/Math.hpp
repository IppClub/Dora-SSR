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

#ifndef PLAYRHO_COMMON_MATH_HPP
#define PLAYRHO_COMMON_MATH_HPP

#include "PlayRho/Common/Settings.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Span.hpp"
#include "PlayRho/Common/UnitVec.hpp"
#include "PlayRho/Common/Vector2.hpp"
#include "PlayRho/Common/Vector3.hpp"
#include "PlayRho/Common/Position.hpp"
#include "PlayRho/Common/Velocity.hpp"
#include "PlayRho/Common/Acceleration.hpp"
#include "PlayRho/Common/Transformation.hpp"
#include "PlayRho/Common/Sweep.hpp"
#include "PlayRho/Common/Matrix.hpp"
#include "PlayRho/Common/FixedMath.hpp"

#include <cmath>
#include <vector>
#include <numeric>

namespace playrho {

// Import common standard mathematical functions into the playrho namespace...
using std::signbit;
using std::nextafter;
using std::trunc;
using std::fmod;
using std::isfinite;
using std::round;
using std::isnormal;
using std::isnan;
using std::hypot;
using std::cos;
using std::sin;
using std::atan2;
using std::sqrt;
using std::pow;
using std::abs;

// Other templates.

/// @brief Gets the "X" element of the given value - i.e. the first element.
template <typename T>
PLAYRHO_CONSTEXPR inline auto& GetX(T& value)
{
    return get<0>(value);
}

/// @brief Gets the "Y" element of the given value - i.e. the second element.
template <typename T>
PLAYRHO_CONSTEXPR inline auto& GetY(T& value)
{
    return get<1>(value);
}

/// @brief Gets the "Z" element of the given value - i.e. the third element.
template <typename T>
PLAYRHO_CONSTEXPR inline auto& GetZ(T& value)
{
    return get<2>(value);
}

/// @brief Gets the "X" element of the given value - i.e. the first element.
template <typename T>
PLAYRHO_CONSTEXPR inline auto GetX(const T& value)
{
    return get<0>(value);
}

/// @brief Gets the "Y" element of the given value - i.e. the second element.
template <typename T>
PLAYRHO_CONSTEXPR inline auto GetY(const T& value)
{
    return get<1>(value);
}

/// @brief Gets the "Z" element of the given value - i.e. the third element.
template <typename T>
PLAYRHO_CONSTEXPR inline auto GetZ(const T& value)
{
    return get<2>(value);
}

/// @brief Makes the given value into an unsigned value.
/// @note If the given value is negative, this will result in an unsigned value which is the
///   two's complement modulo-wrapped value.
template <typename T>
PLAYRHO_CONSTEXPR inline std::enable_if_t<std::is_signed<T>::value, std::make_unsigned_t<T>>
MakeUnsigned(const T& arg) noexcept
{
    return static_cast<std::make_unsigned_t<T>>(arg);
}

/// @brief Strips the unit from the given value.
template <typename T, LoValueCheck lo, HiValueCheck hi>
PLAYRHO_CONSTEXPR inline auto StripUnit(const BoundedValue<T, lo, hi>& v)
{
    return StripUnit(v.get());
}

/// @defgroup Math Additional Math Functions
/// @brief Additional functions for common mathematical operations.
/// @details These are non-member non-friend functions for mathematical operations
///   especially those with mixed input and output types.
/// @{

/// @brief Secant method.
/// @sa https://en.wikipedia.org/wiki/Secant_method
template <typename T, typename U>
PLAYRHO_CONSTEXPR inline U Secant(T target, U a1, T s1, U a2, T s2) noexcept
{
    static_assert(IsArithmetic<T>::value && IsArithmetic<U>::value, "Arithmetic types required.");
    return (a1 + (target - s1) * (a2 - a1) / (s2 - s1));
}

/// @brief Bisection method.
/// @sa https://en.wikipedia.org/wiki/Bisection_method
template <typename T>
PLAYRHO_CONSTEXPR inline T Bisect(T a1, T a2) noexcept
{
    return (a1 + a2) / 2;
}

/// @brief Is-odd.
/// @details Determines whether the given integral value is odd (as opposed to being even).
template <typename T>
PLAYRHO_CONSTEXPR inline bool IsOdd(T val) noexcept
{
    static_assert(std::is_integral<T>::value, "Integral type required.");
    return val % 2;
}

/// @brief Squares the given value.
template<class TYPE>
PLAYRHO_CONSTEXPR inline auto Square(TYPE t) noexcept { return t * t; }

/// @brief Computes the arc-tangent of the given y and x values.
/// @return Normalized angle - an angle between -Pi and Pi inclusively.
/// @sa http://en.cppreference.com/w/cpp/numeric/math/atan2
template<typename T>
inline auto Atan2(T y, T x)
{
    return Angle{static_cast<Real>(atan2(StripUnit(y), StripUnit(x))) * Radian};
}

/// @brief Computes the average of the given values.
template <typename T, typename = std::enable_if_t<
    IsIterable<T>::value && IsAddable<decltype(*begin(std::declval<T>()))>::value
    > >
inline auto Average(const T& span)
{
    using value_type = decltype(*begin(std::declval<T>()));

    // Relies on C++11 zero initialization to zero initialize value_type.
    // See: http://en.cppreference.com/w/cpp/language/zero_initialization
    PLAYRHO_CONSTEXPR const auto zero = value_type{};
    assert(zero * Real{2} == zero);
    
    // For C++17, switch from using std::accumulate to using std::reduce.
    const auto sum = std::accumulate(begin(span), end(span), zero);
    const auto count = std::max(size(span), std::size_t{1});
    return sum / static_cast<Real>(count);
}

/// @brief Computes the rounded value of the given value.
template <typename T>
inline std::enable_if_t<IsArithmetic<T>::value, T> RoundOff(T value, unsigned precision = 100000)
{
    const auto factor = static_cast<T>(precision);
    return round(value * factor) / factor;
}

/// @brief Computes the rounded value of the given value.
inline Vec2 RoundOff(Vec2 value, std::uint32_t precision = 100000)
{
    return Vec2{RoundOff(value[0], precision), RoundOff(value[1], precision)};
}

/// @brief Absolute value function for vectors.
/// @relatedalso Vector
template <typename T, std::size_t N>
PLAYRHO_CONSTEXPR inline Vector<T, N> abs(const Vector<T, N>& v) noexcept
{
    auto result = Vector<T, N>{};
    for (auto i = decltype(N){0}; i < N; ++i)
    {
        result[i] = abs(v[i]);
    }
    return result;
}

/// @brief Gets the absolute value of the given value.
inline d2::UnitVec abs(const d2::UnitVec& v) noexcept
{
    return v.Absolute();
}

/// @brief Gets whether a given value is almost zero.
/// @details An almost zero value is "subnormal". Dividing by these values can lead to
/// odd results like a divide by zero trap occurring.
/// @return <code>true</code> if the given value is almost zero, <code>false</code> otherwise.
template <typename T>
PLAYRHO_CONSTEXPR inline
std::enable_if_t<std::is_arithmetic<T>::value, bool> AlmostZero(T value)
{
    return abs(value) < std::numeric_limits<T>::min();
}

/// @brief Determines whether the given two values are "almost equal".
template <typename T>
PLAYRHO_CONSTEXPR inline
std::enable_if_t<std::is_floating_point<T>::value, bool> AlmostEqual(T x, T y, int ulp = 2)
{
    // From http://en.cppreference.com/w/cpp/types/numeric_limits/epsilon :
    //   "the machine epsilon has to be scaled to the magnitude of the values used
    //    and multiplied by the desired precision in ULPs (units in the last place)
    //    unless the result is subnormal".
    // Where "subnormal" means almost zero.
    //
    return (abs(x - y) < (std::numeric_limits<T>::epsilon() * abs(x + y) * ulp)) || AlmostZero(x - y);
}

/// @brief Modulo operation using <code>std::fmod</code>.
/// @note Modulo via <code>std::fmod</code> appears slower than via <code>std::trunc</code>.
/// @sa ModuloViaTrunc
template <typename T>
inline auto ModuloViaFmod(T dividend, T divisor) noexcept
{
    // Note: modulo via std::fmod appears slower than via std::trunc.
    return static_cast<T>(fmod(dividend, divisor));
}

/// @brief Modulo operation using <code>std::trunc</code>.
/// @note Modulo via <code>std::fmod</code> appears slower than via <code>std::trunc</code>.
/// @sa ModuloViaFmod
template <typename T>
inline auto ModuloViaTrunc(T dividend, T divisor) noexcept
{
    const auto quotient = dividend / divisor;
    const auto integer = static_cast<T>(trunc(quotient));
    const auto remainder = quotient - integer;
    return remainder * divisor;
}

/// @brief Gets the "normalized" value of the given angle.
/// @return Angle between -Pi and Pi radians inclusively where 0 represents the positive X-axis.
/// @sa Atan2
inline Angle GetNormalized(Angle value) noexcept
{
    PLAYRHO_CONSTEXPR const auto oneRotationInRadians = Real{2 * Pi};
    auto angleInRadians = Real{value / Radian};
#if defined(NORMALIZE_ANGLE_VIA_FMOD)
    // Note: std::fmod appears slower than std::trunc.
    //   See Benchmark ModuloViaFmod for data.
    angleInRadians = ModuloViaFmod(angleInRadians, oneRotationInRadians);
#else
    // Note: std::trunc appears more than twice as fast as std::fmod.
    //   See Benchmark ModuloViaTrunc for data.
    angleInRadians = ModuloViaTrunc(angleInRadians, oneRotationInRadians);
#endif
    if (angleInRadians > Pi)
    {
        // 190_deg becomes 190_deg - 360_deg = -170_deg
        angleInRadians -= Pi * 2;
    }
    else if (angleInRadians < -Pi)
    {
        // -200_deg becomes -200_deg + 360_deg = 100_deg
        angleInRadians += Pi * 2;
    }
    return angleInRadians * Radian;
}

/// @brief Gets the angle.
/// @return Angular value in the range of -Pi to +Pi radians.
template <class T>
inline Angle GetAngle(const Vector2<T> value)
{
    return Atan2(GetY(value), GetX(value));
}

/// @brief Gets the square of the magnitude of the given iterable value.
/// @note For performance, use this instead of <code>GetMagnitude(T value)</code> (if possible).
/// @return Non-negative value from 0 to infinity, or NaN.
template <typename T>
PLAYRHO_CONSTEXPR inline
auto GetMagnitudeSquared(T value) noexcept
{
    using VT = typename T::value_type;
    using OT = decltype(VT{} * VT{});
    auto result = OT{};
    for (auto&& e: value)
    {
        result += Square(e);
    }
    return result;
}

/// @brief Gets the magnitude of the given value.
/// @note Works for any type for which <code>GetMagnitudeSquared</code> also works.
template <typename T>
inline auto GetMagnitude(T value)
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
/// @sa https://en.wikipedia.org/wiki/Dot_product
///
/// @param a Vector A.
/// @param b Vector B.
///
/// @return Dot product of the vectors (0 means the two vectors are perpendicular).
///
template <typename T1, typename T2>
PLAYRHO_CONSTEXPR inline auto Dot(const T1 a, const T2 b) noexcept
{
    static_assert(std::tuple_size<T1>::value == std::tuple_size<T2>::value,
                  "Dot only for same tuple-like sized types");
    using VT1 = typename T1::value_type;
    using VT2 = typename T2::value_type;
    using OT = decltype(VT1{} * VT2{});
    auto result = OT{};
    const auto numElements = size(a);
    for (auto i = decltype(numElements){0}; i < numElements; ++i)
    {
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
/// @sa https://en.wikipedia.org/wiki/Cross_product
///
/// @return Cross product of the two values.
///
template <class T1, class T2, std::enable_if_t<
    std::tuple_size<T1>::value == 2 && std::tuple_size<T2>::value == 2, int> = 0>
PLAYRHO_CONSTEXPR inline auto Cross(T1 a, T2 b) noexcept
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
/// @sa https://en.wikipedia.org/wiki/Cross_product
/// @param a Value A of a 3-element type.
/// @param b Value B of a 3-element type.
/// @return Cross product of the two values.
template <class T1, class T2, std::enable_if_t<
    std::tuple_size<T1>::value == 3 && std::tuple_size<T2>::value == 3, int> = 0>
PLAYRHO_CONSTEXPR inline auto Cross(T1 a, T2 b) noexcept
{
    assert(isfinite(get<0>(a)));
    assert(isfinite(get<1>(a)));
    assert(isfinite(get<2>(a)));
    assert(isfinite(get<0>(b)));
    assert(isfinite(get<1>(b)));
    assert(isfinite(get<2>(b)));

    using OT = decltype(get<0>(a) * get<0>(b));
    return Vector<OT, 3>{
        GetY(a) * GetZ(b) - GetZ(a) * GetY(b),
        GetZ(a) * GetX(b) - GetX(a) * GetZ(b),
        GetX(a) * GetY(b) - GetY(a) * GetX(b)
    };
}

/// @brief Solves A * x = b, where b is a column vector.
/// @note This is more efficient than computing the inverse in one-shot cases.
template <typename T, typename U>
PLAYRHO_CONSTEXPR inline auto Solve(const Matrix22<U> mat, const Vector2<T> b) noexcept
{
    const auto cp = Cross(get<0>(mat), get<1>(mat));
    using OutType = decltype((U{} * T{}) / cp);
    return (!AlmostZero(StripUnit(cp)))?
        Vector2<OutType>{
            (get<1>(mat)[1] * b[0] - get<1>(mat)[0] * b[1]) / cp,
            (get<0>(mat)[0] * b[1] - get<0>(mat)[1] * b[0]) / cp
        }: Vector2<OutType>{};
}

/// @brief Inverts the given value.
template <class IN_TYPE>
PLAYRHO_CONSTEXPR inline auto Invert(const Matrix22<IN_TYPE> value) noexcept
{
    const auto cp = Cross(get<0>(value), get<1>(value));
    using OutType = decltype(get<0>(value)[0] / cp);
    return (!AlmostZero(StripUnit(cp)))?
        Matrix22<OutType>{
            Vector2<OutType>{ get<1>(get<1>(value)) / cp, -get<1>(get<0>(value)) / cp},
            Vector2<OutType>{-get<0>(get<1>(value)) / cp,  get<0>(get<0>(value)) / cp}
        }:
        Matrix22<OutType>{};
}

/// @brief Solves A * x = b, where b is a column vector.
/// @note This is more efficient than computing the inverse in one-shot cases.
PLAYRHO_CONSTEXPR inline Vec3 Solve33(const Mat33& mat, const Vec3 b) noexcept
{
    const auto dp = Dot(GetX(mat), Cross(GetY(mat), GetZ(mat)));
    const auto det = (dp != 0)? 1 / dp: dp;
    const auto x = det * Dot(b, Cross(GetY(mat), GetZ(mat)));
    const auto y = det * Dot(GetX(mat), Cross(b, GetZ(mat)));
    const auto z = det * Dot(GetX(mat), Cross(GetY(mat), b));
    return Vec3{x, y, z};
}
    
/// @brief Solves A * x = b, where b is a column vector.
/// @note This is more efficient than computing the inverse in one-shot cases.
/// @note Solves only the upper 2-by-2 matrix equation.
template <typename T>
PLAYRHO_CONSTEXPR inline T Solve22(const Mat33& mat, const T b) noexcept
{
    const auto cp = GetX(GetX(mat)) * GetY(GetY(mat)) - GetX(GetY(mat)) * GetY(GetX(mat));
    const auto det = (cp != 0)? 1 / cp: cp;
    const auto x = det * (GetY(GetY(mat)) * GetX(b) - GetX(GetY(mat)) * GetY(b));
    const auto y = det * (GetX(GetX(mat)) * GetY(b) - GetY(GetX(mat)) * GetX(b));
    return T{x, y};
}

/// @brief Gets the inverse of the given matrix as a 2-by-2.
/// @return Zero matrix if singular.
PLAYRHO_CONSTEXPR inline Mat33 GetInverse22(const Mat33& value) noexcept
{
    const auto a = GetX(GetX(value)), b = GetX(GetY(value)), c = GetY(GetX(value)), d = GetY(GetY(value));
    auto det = (a * d) - (b * c);
    if (det != Real{0})
    {
        det = Real{1} / det;
    }
    return Mat33{Vec3{det * d, -det * c, Real{0}}, Vec3{-det * b, det * a, 0}, Vec3{0, 0, 0}};
}
    
/// @brief Gets the symmetric inverse of this matrix as a 3-by-3.
/// @return Zero matrix if singular.
PLAYRHO_CONSTEXPR inline Mat33 GetSymInverse33(const Mat33& value) noexcept
{
    auto det = Dot(GetX(value), Cross(GetY(value), GetZ(value)));
    if (det != Real{0})
    {
        det = Real{1} / det;
    }
    
    const auto a11 = GetX(GetX(value)), a12 = GetX(GetY(value)), a13 = GetX(GetZ(value));
    const auto a22 = GetY(GetY(value)), a23 = GetY(GetZ(value));
    const auto a33 = GetZ(GetZ(value));
    
    const auto ex_y = det * (a13 * a23 - a12 * a33);
    const auto ey_z = det * (a13 * a12 - a11 * a23);
    const auto ex_z = det * (a12 * a23 - a13 * a22);
    
    return Mat33{
        Vec3{det * (a22 * a33 - a23 * a23), ex_y, ex_z},
        Vec3{ex_y, det * (a11 * a33 - a13 * a13), ey_z},
        Vec3{ex_z, ey_z, det * (a11 * a22 - a12 * a12)}
    };
}

/// @brief Gets a vector counter-clockwise (reverse-clockwise) perpendicular to the given vector.
/// @details This takes a vector of form (x, y) and returns the vector (-y, x).
/// @param vector Vector to return a counter-clockwise perpendicular equivalent for.
/// @return A counter-clockwise 90-degree rotation of the given vector.
/// @sa GetFwdPerpendicular.
template <class T>
PLAYRHO_CONSTEXPR inline auto GetRevPerpendicular(const T vector) noexcept
{
    // See http://mathworld.wolfram.com/PerpendicularVector.html
    return T{-GetY(vector), GetX(vector)};
}
    
/// @brief Gets a vector clockwise (forward-clockwise) perpendicular to the given vector.
/// @details This takes a vector of form (x, y) and returns the vector (y, -x).
/// @param vector Vector to return a clockwise perpendicular equivalent for.
/// @return A clockwise 90-degree rotation of the given vector.
/// @sa GetRevPerpendicular.
template <class T>
PLAYRHO_CONSTEXPR inline auto GetFwdPerpendicular(const T vector) noexcept
{
    // See http://mathworld.wolfram.com/PerpendicularVector.html
    return T{GetY(vector), -GetX(vector)};
}

/// @brief Multiplies an M-element vector by an M-by-N matrix.
/// @param v Vector that's interpreted as a matrix with 1 row and M-columns.
/// @param m An M-row by N-column *transformation matrix* to multiply the vector by.
/// @sa https://en.wikipedia.org/wiki/Transformation_matrix
template <std::size_t M, typename T1, std::size_t N, typename T2>
PLAYRHO_CONSTEXPR inline auto Transform(const Vector<T1, M> v, const Matrix<T2, M, N>& m) noexcept
{
    return m * v;
}

/// @brief Multiplies a vector by a matrix.
PLAYRHO_CONSTEXPR inline Vec2 Transform(const Vec2 v, const Mat33& A) noexcept
{
    return Vec2{
        get<0>(get<0>(A)) * v[0] + get<0>(get<1>(A)) * v[1],
        get<1>(get<0>(A)) * v[0] + get<1>(get<1>(A)) * v[1]
    };
}

/// Multiply a matrix transpose times a vector. If a rotation matrix is provided,
/// then this transforms the vector from one frame to another (inverse transform).
PLAYRHO_CONSTEXPR inline Vec2 InverseTransform(const Vec2 v, const Mat22& A) noexcept
{
    return Vec2{Dot(v, GetX(A)), Dot(v, GetY(A))};
}

/// @brief Computes A^T * B.
PLAYRHO_CONSTEXPR inline Mat22 MulT(const Mat22& A, const Mat22& B) noexcept
{
    const auto c1 = Vec2{Dot(GetX(A), GetX(B)), Dot(GetY(A), GetX(B))};
    const auto c2 = Vec2{Dot(GetX(A), GetY(B)), Dot(GetY(A), GetY(B))};
    return Mat22{c1, c2};
}

/// @brief Gets the absolute value of the given value.
inline Mat22 abs(const Mat22& A)
{
    return Mat22{abs(GetX(A)), abs(GetY(A))};
}

/// @brief Gets the next largest power of 2
/// @details
/// Given a binary integer value x, the next largest power of 2 can be computed by a S.W.A.R.
/// algorithm that recursively "folds" the upper bits into the lower bits. This process yields
/// a bit vector with the same most significant 1 as x, but all one's below it. Adding 1 to
/// that value yields the next largest power of 2. For a 64-bit value:"
inline std::uint64_t NextPowerOfTwo(std::uint64_t x)
{
    x |= (x >>  1u);
    x |= (x >>  2u);
    x |= (x >>  4u);
    x |= (x >>  8u);
    x |= (x >> 16u);
    x |= (x >> 32u);
    return x + 1;
}

/// @brief Converts the given vector into a unit vector and returns its original length.
inline Real Normalize(Vec2& vector)
{
    const auto length = GetMagnitude(vector);
    if (!AlmostZero(length))
    {
        const auto invLength = 1 / length;
        vector[0] *= invLength;
        vector[1] *= invLength;
        return length;
    }
    return 0;
}

/// @brief Computes the centroid of a counter-clockwise array of 3 or more vertices.
/// @note Behavior is undefined if there are less than 3 vertices or the vertices don't
///   go counter-clockwise.
Length2 ComputeCentroid(const Span<const Length2>& vertices);

/// @brief Gets the modulo next value.
template <typename T>
PLAYRHO_CONSTEXPR inline T GetModuloNext(T value, T count) noexcept
{
    assert(value < count);
    return (value + 1) % count;
}

/// @brief Gets the modulo previous value.
template <typename T>
PLAYRHO_CONSTEXPR inline T GetModuloPrev(T value, T count) noexcept
{
    assert(value < count);
    return (value? value: count) - 1;
}

/// @brief Gets the shortest angular distance to go from angle 1 to angle 2.
/// @details This gets the angle to rotate angle 1 by in order to get to angle 2 with the
///   least amount of rotation.
/// @return Angle between -Pi and Pi radians inclusively.
/// @sa GetNormalized
Angle GetDelta(Angle a1, Angle a2) noexcept;

/// Gets the reverse (counter) clockwise rotational angle to go from angle 1 to angle 2.
/// @return Angular rotation in the counter clockwise direction to go from angle 1 to angle 2.
PLAYRHO_CONSTEXPR inline Angle GetRevRotationalAngle(Angle a1, Angle a2) noexcept
{
    return (a1 > a2)? 360_deg - (a1 - a2): a2 - a1;
}
    
/// @brief Gets the vertices for a circle described by the given parameters.
std::vector<Length2> GetCircleVertices(Length radius, unsigned slices,
                                        Angle start = 0_deg, Real turns = Real{1});

/// @brief Gets the area of a circle.
NonNegative<Area> GetAreaOfCircle(Length radius);

/// @brief Gets the area of a polygon.
/// @note This function is valid for any non-self-intersecting (simple) polygon,
///   which can be convex or concave.
/// @note Winding order doesn't matter.
NonNegative<Area> GetAreaOfPolygon(Span<const Length2> vertices);

/// @brief Gets the polar moment of the area enclosed by the given vertices.
///
/// @warning Behavior is undefined if given collection has less than 3 vertices.
///
/// @param vertices Collection of three or more vertices.
///
SecondMomentOfArea GetPolarMoment(Span<const Length2> vertices);

/// @}

namespace d2 {

/// @brief Gets a <code>Vec2</code> representation of the given value.
PLAYRHO_CONSTEXPR inline Vec2 GetVec2(const UnitVec value)
{
    return Vec2{get<0>(value), get<1>(value)};
}

/// @brief Gets the angle of the given unit vector.
inline Angle GetAngle(const UnitVec value)
{
    return Atan2(GetY(value), GetX(value));
}

/// @brief Multiplication operator.
template <class T, LoValueCheck lo, HiValueCheck hi>
PLAYRHO_CONSTEXPR inline Vector2<T> operator* (BoundedValue<T, lo, hi> s, UnitVec u) noexcept
{
    return Vector2<T>{u.GetX() * s, u.GetY() * T{s}};
}

/// @brief Multiplication operator.
template <class T>
PLAYRHO_CONSTEXPR inline Vector2<T> operator* (const T s, const UnitVec u) noexcept
{
    return Vector2<T>{u.GetX() * s, u.GetY() * s};
}

/// @brief Multiplication operator.
template <class T, LoValueCheck lo, HiValueCheck hi>
PLAYRHO_CONSTEXPR inline Vector2<T> operator* (UnitVec u, BoundedValue<T, lo, hi> s) noexcept
{
    return Vector2<T>{u.GetX() * s, u.GetY() * T{s}};
}

/// @brief Multiplication operator.
template <class T>
PLAYRHO_CONSTEXPR inline Vector2<T> operator* (const UnitVec u, const T s) noexcept
{
    return Vector2<T>{u.GetX() * s, u.GetY() * s};
}

/// @brief Division operator.
PLAYRHO_CONSTEXPR inline Vec2 operator/ (const UnitVec u, const UnitVec::value_type s) noexcept
{
    return Vec2{GetX(u) / s, GetY(u) / s};
}

/// @brief Rotates a vector by a given angle.
/// @details This rotates a vector by the angle expressed by the angle parameter.
/// @param vector Vector to forward rotate.
/// @param angle Expresses the angle to forward rotate the given vector by.
/// @sa InverseRotate.
template <class T>
PLAYRHO_CONSTEXPR inline auto Rotate(const Vector2<T> vector, const UnitVec& angle) noexcept
{
    const auto newX = (GetX(angle) * GetX(vector)) - (GetY(angle) * GetY(vector));
    const auto newY = (GetY(angle) * GetX(vector)) + (GetX(angle) * GetY(vector));
    return Vector2<T>{newX, newY};
}

/// @brief Inverse rotates a vector.
/// @details This is the inverse of rotating a vector - it undoes what rotate does. I.e.
///   this effectively subtracts from the angle of the given vector the angle that's
///   expressed by the angle parameter.
/// @param vector Vector to reverse rotate.
/// @param angle Expresses the angle to reverse rotate the given vector by.
/// @sa Rotate.
template <class T>
PLAYRHO_CONSTEXPR inline auto InverseRotate(const Vector2<T> vector, const UnitVec& angle) noexcept
{
    const auto newX = (GetX(angle) * GetX(vector)) + (GetY(angle) * GetY(vector));
    const auto newY = (GetX(angle) * GetY(vector)) - (GetY(angle) * GetX(vector));
    return Vector2<T>{newX, newY};
}

/// Gets the unit vector for the given value.
/// @param value Value to get the unit vector for.
/// @param fallback Fallback unit vector value to use in case a unit vector can't effectively be
///   calculated from the given value.
/// @return value divided by its length if length not almost zero otherwise invalid value.
/// @sa AlmostEqual.
template <class T>
inline UnitVec GetUnitVector(Vector2<T> value, UnitVec fallback = UnitVec::GetDefaultFallback())
{
    return std::get<0>(UnitVec::Get(StripUnit(GetX(value)), StripUnit(GetY(value)), fallback));
}

/// @brief Gets the "normalized" position.
/// @details Enforces a wrap-around of one rotation on the angular position.
/// @note Use to prevent unbounded angles in positions.
inline Position GetNormalized(const Position& val) noexcept
{
    return Position{val.linear, playrho::GetNormalized(val.angular)};
}

/// @brief Gets a sweep with the given sweep's angles normalized.
/// @param sweep Sweep to return with its angles normalized.
/// @return Sweep with its position 0 angle to be between -2 pi and 2 pi and its
///   position 1 angle reduced by the amount the position 0 angle was reduced by.
/// @relatedalso Sweep
inline Sweep GetNormalized(Sweep sweep) noexcept
{
    const auto pos0a = playrho::GetNormalized(sweep.pos0.angular);
    const auto d = sweep.pos0.angular - pos0a;
    sweep.pos0.angular = pos0a;
    sweep.pos1.angular -= d;
    return sweep;
}

/// @brief Transforms the given 2-D vector with the given transformation.
/// @details
/// Rotate and translate the given 2-D linear position according to the rotation and translation
/// defined by the given transformation.
/// @note Passing the output of this function to <code>InverseTransform</code> (with the same
/// transformation again) will result in the original vector being returned.
/// @note For a 2-D linear position of the origin (0, 0), the result is simply the translation.
/// @sa <code>InverseTransform</code>.
/// @param v 2-D position to transform (to rotate and then translate).
/// @param xfm Transformation (a translation and rotation) to apply to the given vector.
/// @return Rotated and translated vector.
PLAYRHO_CONSTEXPR inline Length2 Transform(const Length2 v, const Transformation xfm) noexcept
{
    return Rotate(v, xfm.q) + xfm.p;
}

/// @brief Inverse transforms the given 2-D vector with the given transformation.
/// @details
/// Inverse translate and rotate the given 2-D vector according to the translation and rotation
/// defined by the given transformation.
/// @note Passing the output of this function to <code>Transform</code> (with the same
/// transformation again) will result in the original vector being returned.
/// @sa <code>Transform</code>.
/// @param v 2-D vector to inverse transform (inverse translate and inverse rotate).
/// @param T Transformation (a translation and rotation) to inversely apply to the given vector.
/// @return Inverse transformed vector.
PLAYRHO_CONSTEXPR inline Length2 InverseTransform(const Length2 v, const Transformation T) noexcept
{
    const auto v2 = v - T.p;
    return InverseRotate(v2, T.q);
}

/// @brief Multiplies a given transformation by another given transformation.
/// @note <code>v2 = A.q.Rot(B.q.Rot(v1) + B.p) + A.p
///                = (A.q * B.q).Rot(v1) + A.q.Rot(B.p) + A.p</code>
PLAYRHO_CONSTEXPR inline Transformation Mul(const Transformation& A, const Transformation& B) noexcept
{
    return Transformation{A.p + Rotate(B.p, A.q), A.q.Rotate(B.q)};
}

/// @brief Inverse multiplies a given transformation by another given transformation.
/// @note <code>v2 = A.q' * (B.q * v1 + B.p - A.p)
///                = A.q' * B.q * v1 + A.q' * (B.p - A.p)</code>
PLAYRHO_CONSTEXPR inline Transformation MulT(const Transformation& A, const Transformation& B) noexcept
{
    const auto dp = B.p - A.p;
    return Transformation{InverseRotate(dp, A.q), B.q.Rotate(A.q.FlipY())};
}

/// @brief Gets the transformation for the given values.
PLAYRHO_CONSTEXPR inline Transformation GetTransformation(const Length2 ctr, const UnitVec rot,
                                                            const Length2 localCtr) noexcept
{
    assert(IsValid(rot));
    return Transformation{ctr - (Rotate(localCtr, rot)), rot};
}

/// @brief Gets the transformation for the given values.
inline Transformation GetTransformation(const Position pos, const Length2 local_ctr) noexcept
{
    assert(IsValid(pos));
    assert(IsValid(local_ctr));
    return GetTransformation(pos.linear, UnitVec::Get(pos.angular), local_ctr);
}

/// @brief Gets the interpolated transform at a specific time.
/// @param sweep Sweep data to get the transform from.
/// @param beta Time factor in [0,1], where 0 indicates alpha 0.
/// @return Transformation of the given sweep at the specified time.
inline Transformation GetTransformation(const Sweep& sweep, const Real beta) noexcept
{
    assert(beta >= 0);
    assert(beta <= 1);
    return GetTransformation(GetPosition(sweep.pos0, sweep.pos1, beta), sweep.GetLocalCenter());
}

/// @brief Gets the transform at "time" zero.
/// @note This is like calling <code>GetTransformation(sweep, 0)</code>, except more efficiently.
/// @sa GetTransformation(const Sweep& sweep, Real beta).
/// @param sweep Sweep data to get the transform from.
/// @return Transformation of the given sweep at time zero.
inline Transformation GetTransform0(const Sweep& sweep) noexcept
{
    return GetTransformation(sweep.pos0, sweep.GetLocalCenter());
}

/// @brief Gets the transform at "time" one.
/// @note This is like calling <code>GetTransformation(sweep, 1.0)</code>, except more efficiently.
/// @sa GetTransformation(const Sweep& sweep, Real beta).
/// @param sweep Sweep data to get the transform from.
/// @return Transformation of the given sweep at time one.
inline Transformation GetTransform1(const Sweep& sweep) noexcept
{
    return GetTransformation(sweep.pos1, sweep.GetLocalCenter());
}

/// @brief Gets the contact relative velocity.
/// @note If <code>relA</code> and <code>relB</code> are the zero vectors, the resulting
///    value is simply <code>velB.linear - velA.linear</code>.
LinearVelocity2 GetContactRelVelocity(const Velocity velA, const Length2 relA,
                                      const Velocity velB, const Length2 relB) noexcept;

/// @brief Gets whether the given velocity is "under active" based on the given tolerances.
inline bool IsUnderActive(Velocity velocity,
                          LinearVelocity linSleepTol, AngularVelocity angSleepTol) noexcept
{
    const auto linVelSquared = GetMagnitudeSquared(velocity.linear);
    const auto angVelSquared = Square(velocity.angular);
    return (angVelSquared <= Square(angSleepTol)) && (linVelSquared <= Square(linSleepTol));
}

/// @brief Gets the reflection matrix for the given unit vector that defines the normal of
///   the line through the origin that points should be reflected against.
/// @sa https://en.wikipedia.org/wiki/Transformation_matrix
PLAYRHO_CONSTEXPR inline auto GetReflectionMatrix(UnitVec axis)
{
    constexpr auto TupleSize = std::tuple_size<decltype(axis)>::value;
    constexpr auto NumRows = TupleSize;
    constexpr auto NumCols = TupleSize;
    auto result = Matrix<Real, NumRows, NumCols>{};
    for (auto row = decltype(NumRows){0}; row < NumRows; ++row)
    {
        for (auto col = decltype(NumCols){0}; col < NumCols; ++col)
        {
            result[row][col] = ((row == col)? Real{1}: Real{0}) - axis[row] * axis[col] * 2;
        }
    }
    return result;
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COMMON_MATH_HPP
