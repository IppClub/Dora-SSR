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

#ifndef PLAYRHO_D2_MATH_HPP
#define PLAYRHO_D2_MATH_HPP

/// @file
/// @brief Declarations of general 2-D math related code.

#include <cassert> // for assert
#include <tuple> // for std::tuple_size_v
#include <type_traits> // for std::decay_t
#include <vector>

// IWYU pragma: begin_exports

#include "playrho/Math.hpp"
#include "playrho/Matrix.hpp"
#include "playrho/Real.hpp"
#include "playrho/UnitInterval.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"

#include "playrho/detail/Checked.hpp"

#include "playrho/d2/UnitVec.hpp"
#include "playrho/d2/Position.hpp"
#include "playrho/d2/Velocity.hpp"
#include "playrho/d2/Transformation.hpp"
#include "playrho/d2/Sweep.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Gets a <code>Vec2</code> representation of the given value.
constexpr Vec2 GetVec2(const UnitVec& value)
{
    return Vec2{get<0>(value), get<1>(value)};
}

/// @brief Gets the angle of the given unit vector.
inline Angle GetAngle(const UnitVec& value)
{
    return Atan2(GetY(value), GetX(value));
}

/// @brief Gets the angle of the given transformation.
inline Angle GetAngle(const Transformation& value)
{
    return GetAngle(value.q);
}

/// @brief Multiplication operator.
template <class T, typename U, bool NoExcept>
constexpr Vector2<T> operator*(const playrho::detail::Checked<T, U, NoExcept>& s, const UnitVec& u) noexcept
{
    return Vector2<T>{u.GetX() * s, u.GetY() * s};
}

/// @brief Multiplication operator.
template <class T>
constexpr Vector2<T> operator*(const T& s, const UnitVec& u) noexcept
{
    return Vector2<T>{u.GetX() * s, u.GetY() * s};
}

/// @brief Multiplication operator.
template <class T, class U, bool NoExcept>
constexpr Vector2<T> operator*(const UnitVec& u, const playrho::detail::Checked<T, U, NoExcept>& s) noexcept
{
    return Vector2<T>{u.GetX() * s, u.GetY() * s};
}

/// @brief Multiplication operator.
template <class T>
constexpr Vector2<T> operator*(const UnitVec& u, const T& s) noexcept
{
    return Vector2<T>{u.GetX() * s, u.GetY() * s};
}

/// @brief Division operator.
constexpr Vec2 operator/(const UnitVec& u, const UnitVec::value_type s) noexcept
{
    const auto inverseS = Real{1} / s;
    return Vec2{GetX(u) * inverseS, GetY(u) * inverseS};
}

/// @brief Rotates a vector by a given angle.
/// @details This rotates a vector by the angle expressed by the angle parameter.
/// @param vector Vector to forward rotate.
/// @param angle Expresses the angle to forward rotate the given vector by.
/// @see InverseRotate.
template <class T>
constexpr auto Rotate(const Vector2<T>& vector, const UnitVec& angle) noexcept
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
/// @see Rotate.
template <class T>
constexpr auto InverseRotate(const Vector2<T>& vector, const UnitVec& angle) noexcept
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
template <class T>
inline UnitVec GetUnitVector(const Vector2<T>& value,
                             const UnitVec& fallback = UnitVec::GetDefaultFallback()) noexcept
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

/// Gets the position between two positions at a given unit interval.
/// @param pos0 Position at unit interval value of 0.
/// @param pos1 Position at unit interval value of 1.
/// @param beta Ratio of travel between position 0 and position 1.
/// @return position 0 if <code>pos0 == pos1</code> or <code>beta == 0</code>,
///   position 1 if <code>beta == 1</code>, or at the given unit interval value
///   between position 0 and position 1.
/// @relatedalso Position
Position GetPosition(const Position& pos0, const Position& pos1, Real beta) noexcept;

/// @brief Caps the given position by the amounts specified in the given configuration.
/// @relatedalso Position
Position Cap(Position pos, const ConstraintSolverConf& conf);

/// @brief Transforms the given 2-D vector with the given transformation.
/// @details
/// Rotate and translate the given 2-D linear position according to the rotation and translation
/// defined by the given transformation.
/// @note Passing the output of this function to <code>InverseTransform</code> (with the same
/// transformation again) will result in the original vector being returned.
/// @note For a 2-D linear position of the origin (0, 0), the result is simply the translation.
/// @see <code>InverseTransform</code>.
/// @param v 2-D position to transform (to rotate and then translate).
/// @param xfm Transformation (a translation and rotation) to apply to the given vector.
/// @return Rotated and translated vector.
constexpr Length2 Transform(const Length2& v, const Transformation& xfm) noexcept
{
    return Rotate(v, xfm.q) + xfm.p;
}

/// @brief Inverse transforms the given 2-D vector with the given transformation.
/// @details
/// Inverse translate and rotate the given 2-D vector according to the translation and rotation
/// defined by the given transformation.
/// @note Passing the output of this function to <code>Transform</code> (with the same
/// transformation again) will result in the original vector being returned.
/// @see <code>Transform</code>.
/// @param v 2-D vector to inverse transform (inverse translate and inverse rotate).
/// @param xfm Transformation (a translation and rotation) to inversely apply to the given vector.
/// @return Inverse transformed vector.
constexpr Length2 InverseTransform(const Length2& v, const Transformation& xfm) noexcept
{
    return InverseRotate(v - xfm.p, xfm.q);
}

/// @brief Multiplies a given transformation by another given transformation.
/// @note <code>v2 = A.q.Rot(B.q.Rot(v1) + B.p) + A.p
///                = (A.q * B.q).Rot(v1) + A.q.Rot(B.p) + A.p</code>
constexpr Transformation Mul(const Transformation& A, const Transformation& B) noexcept
{
    return Transformation{A.p + Rotate(B.p, A.q), A.q.Rotate(B.q)};
}

/// @brief Inverse multiplies a given transformation by another given transformation.
/// @note <code>v2 = A.q' * (B.q * v1 + B.p - A.p)
///                = A.q' * B.q * v1 + A.q' * (B.p - A.p)</code>
constexpr Transformation MulT(const Transformation& A, const Transformation& B) noexcept
{
    const auto dp = B.p - A.p;
    return Transformation{InverseRotate(dp, A.q), B.q.Rotate(A.q.FlipY())};
}

/// @brief Gets the transformation for the given values.
constexpr Transformation GetTransformation(const Length2& ctr, const UnitVec& rot,
                                           const Length2& localCtr) noexcept
{
    assert(IsValid(rot));
    return Transformation{ctr - (Rotate(localCtr, rot)), rot};
}

/// @brief Gets the transformation for the given values.
inline Transformation GetTransformation(const Position& pos, const Length2& local_ctr) noexcept
{
    assert(IsValid(pos));
    assert(IsValid(local_ctr));
    return GetTransformation(pos.linear, UnitVec::Get(pos.angular), local_ctr);
}

/// @brief Gets the interpolated transform at a specific time.
/// @param sweep Sweep data to get the transform from.
/// @param beta Time factor in [0,1], where 0 indicates alpha 0.
/// @return Transformation of the given sweep at the specified time.
inline Transformation GetTransformation(const Sweep& sweep, const UnitIntervalFF<Real> beta) noexcept
{
    return GetTransformation(GetPosition(sweep.pos0, sweep.pos1, beta), sweep.localCenter);
}

/// @brief Gets the transform at "time" zero.
/// @note This is like calling <code>GetTransformation(sweep, 0)</code>, except more efficiently.
/// @see GetTransformation(const Sweep& sweep, Real beta).
/// @param sweep Sweep data to get the transform from.
/// @return Transformation of the given sweep at time zero.
inline Transformation GetTransform0(const Sweep& sweep) noexcept
{
    return GetTransformation(sweep.pos0, sweep.localCenter);
}

/// @brief Gets the transform at "time" one.
/// @note This is like calling <code>GetTransformation(sweep, 1.0)</code>, except more efficiently.
/// @see GetTransformation(const Sweep& sweep, Real beta).
/// @param sweep Sweep data to get the transform from.
/// @return Transformation of the given sweep at time one.
inline Transformation GetTransform1(const Sweep& sweep) noexcept
{
    return GetTransformation(sweep.pos1, sweep.localCenter);
}

/// @brief Gets the contact relative velocity.
/// @note If <code>relA</code> and <code>relB</code> are the zero vectors, the resulting
///    value is simply <code>velB.linear - velA.linear</code>.
LinearVelocity2 GetContactRelVelocity(const Velocity& velA, const Length2& relA, const Velocity& velB,
                                      const Length2& relB) noexcept;

/// @brief Gets whether the given velocity is "under active" based on the given tolerances.
inline bool IsUnderActive(const Velocity& velocity, const LinearVelocity& linSleepTol,
                          const AngularVelocity& angSleepTol) noexcept
{
    const auto linVelSquared = GetMagnitudeSquared(velocity.linear);
    const auto angVelSquared = Square(velocity.angular);
    return (angVelSquared <= Square(angSleepTol)) && (linVelSquared <= Square(linSleepTol));
}

/// @brief Gets the "effective" inverse mass.
inline InvMass GetEffectiveInvMass(const InvRotInertia& invRotI, const Length2& p, const UnitVec& q)
{
    // InvRotInertia is L^-2 M^-1 QP^2. Therefore (L^-2 M^-1 QP^2) * (L^2 / QP^2) gives M^-1.
    return invRotI * Square(Length{Cross(p, q)} / Radian);
}

/// @brief Gets the reflection matrix for the given unit vector that defines the normal of
///   the line through the origin that points should be reflected against.
/// @see https://en.wikipedia.org/wiki/Transformation_matrix
constexpr auto GetReflectionMatrix(const UnitVec& axis)
{
    constexpr auto TupleSize = std::tuple_size_v<std::decay_t<decltype(axis)>>;
    constexpr auto NumRows = TupleSize;
    constexpr auto NumCols = TupleSize;
    auto result = Matrix<Real, NumRows, NumCols>{};
    for (auto row = decltype(NumRows){0}; row < NumRows; ++row) {
        for (auto col = decltype(NumCols){0}; col < NumCols; ++col) {
            result[row][col] = ((row == col) ? Real{1} : Real{0}) - axis[row] * axis[col] * 2;
        }
    }
    return result;
}

/// @brief Gets the forward normals for the given container of vertices.
std::vector<UnitVec> GetFwdNormalsVector(const std::vector<Length2>& vertices);

} // namespace playrho::d2

#endif // PLAYRHO_D2_MATH_HPP
