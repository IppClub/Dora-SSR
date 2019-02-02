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

#ifndef PLAYRHO_COMMON_MATRIX_HPP
#define PLAYRHO_COMMON_MATRIX_HPP

#include "PlayRho/Common/Vector.hpp"
#include "PlayRho/Common/Vector2.hpp"
#include "PlayRho/Common/Templates.hpp"
#include "PlayRho/Common/Real.hpp"
#include "PlayRho/Common/Units.hpp"

namespace playrho {

/// @brief Generic M by N matrix.
/// @note M is the number of rows of the matrix.
/// @note N is the number of columns of the matrix.
/// @sa https://en.wikipedia.org/wiki/Matrix_(mathematics)
/// @sa Vector, MatrixTraitsGroup, IsVector
template <typename T, std::size_t M, std::size_t N>
using Matrix = Vector<Vector<T, N>, M>;

/// @defgroup MatrixTraitsGroup Matrix Traits
/// @brief Collection of trait classes for matrices.
/// @sa Matrix
/// @{

/// @brief Trait class for checking if type is a matrix type.
/// @details Trait class for determining whether the given type is a matrix, that is,
///   a vector of vectors.
/// @note This implements the default case where any arbitrary type *is not* a matrix.
/// @note For example the following is false:
/// @code{.cpp}
/// IsMatrix<int>::value || IsMatrix<float>::value
/// @endcode
/// @sa Matrix, IsSquareMatrix, IsVector
template <typename>
struct IsMatrix: std::false_type {};

/// @brief Trait class specialization for checking if type is a matrix type.
/// @details Trait class for determining whether the given type is a matrix, that is,
///   a vector of vectors.
/// @note This implements the specialized case where the given type *is indeed* a matrix.
/// @note For example the following is true:
/// @code{.cpp}
/// IsMatrix<Matrix<int, 2, 3>>::value && IsMatrix<Mat22>::value && IsMatrix<Mat33>::value
/// @endcode
/// @sa Matrix, IsSquareMatrix, IsVector
template <typename T, std::size_t M, std::size_t N>
struct IsMatrix<Vector<Vector<T, N>, M>>: std::true_type {};

/// @brief Trait class for checking if type is a square matrix type.
/// @details Trait class for determining whether the given type is a matrix having an equal
///   number of rows and columns.
/// @note This implements the default case where any arbitrary type *is not* a square matrix.
/// @note For example the following is false:
/// @code{.cpp}
/// IsSquareMatrix<int>::value || IsSquareMatrix<float>::value
/// @endcode
/// @relatedalso Vector
/// @sa IsMatrix, Matrix, Vector
template <typename>
struct IsSquareMatrix: std::false_type {};

/// @brief Trait class specialization for checking if type is a square matrix type.
/// @details This determines whether the given type is a matrix having an equal number
///   of rows and columns.
/// @note This implements the specialized case where the given type *is indeed* a square matrix.
/// @note For example the following is true:
/// @code{.cpp}
/// IsSquareMatrix<Mat22>::value && IsSquareMatrix<Mat33>::value
/// @endcode
/// @sa IsMatrix, Matrix, Vector
template <typename T, std::size_t M>
struct IsSquareMatrix<Vector<Vector<T, M>, M>>: std::true_type {};

/// @}

/// @brief Gets the identity matrix of the template type and size.
/// @sa https://en.wikipedia.org/wiki/Identity_matrix
/// @sa Matrix, IsMatrix, IsSquareMatrix
template <typename T, std::size_t N>
PLAYRHO_CONSTEXPR inline
std::enable_if_t<!IsVector<T>::value, Matrix<T, N, N>> GetIdentityMatrix()
{
    auto result = Matrix<Real, N, N>{};
    for (auto i = std::size_t{0}; i < N; ++i)
    {
        result[i][i] = T{1};
    }
    return result;
}

/// @brief Gets the identity matrix of the template type and size as given by the argument.
/// @sa https://en.wikipedia.org/wiki/Identity_matrix
/// @sa Matrix, IsMatrix, IsSquareMatrix
template <typename T>
PLAYRHO_CONSTEXPR inline std::enable_if_t<IsSquareMatrix<T>::value, T> GetIdentity()
{
    return GetIdentityMatrix<typename T::value_type::value_type, std::tuple_size<T>::value>();
}

/// @brief Gets the specified row of the given matrix as a row matrix.
template <typename T, std::size_t N>
PLAYRHO_CONSTEXPR inline
std::enable_if_t<!IsVector<T>::value, Vector<Vector<T, N>, 1>> GetRowMatrix(Vector<T, N> arg)
{
    return Vector<Vector<T, N>, 1>{arg};
}

/// @brief Gets the specified column of the given matrix as a column matrix.
template <typename T, std::size_t N>
PLAYRHO_CONSTEXPR inline
std::enable_if_t<!IsVector<T>::value, Vector<Vector<T, 1>, N>> GetColumnMatrix(Vector<T, N> arg)
{
    auto result = Vector<Vector<T, 1>, N>{};
    for (auto i = std::size_t{0}; i < N; ++i)
    {
        result[i][0] = arg[i];
    }
    return result;
}

/// @brief Matrix addition operator for two same-type, same-sized matrices.
/// @sa https://en.wikipedia.org/wiki/Matrix_addition
template <typename T, std::size_t M, std::size_t N>
PLAYRHO_CONSTEXPR inline
auto operator+ (const Matrix<T, M, N>& lhs, const Matrix<T, M, N>& rhs) noexcept
{
    auto result = Matrix<T, M, N>{};
    for (auto m = decltype(M){0}; m < M; ++m)
    {
        for (auto n = decltype(N){0}; n < N; ++n)
        {
            result[m][n] = lhs[m][n] + rhs[m][n];
        }
    }
    return result;
}

/// @brief Matrix subtraction operator for two same-type, same-sized matrices.
/// @sa https://en.wikipedia.org/wiki/Matrix_addition
template <typename T, std::size_t M, std::size_t N>
PLAYRHO_CONSTEXPR inline
auto operator- (const Matrix<T, M, N>& lhs, const Matrix<T, M, N>& rhs) noexcept
{
    auto result = Matrix<T, M, N>{};
    for (auto m = decltype(M){0}; m < M; ++m)
    {
        for (auto n = decltype(N){0}; n < N; ++n)
        {
            result[m][n] = lhs[m][n] - rhs[m][n];
        }
    }
    return result;
}

/// @brief 2 by 2 matrix.
template <typename T>
using Matrix22 = Matrix<T, 2, 2>;

/// @brief 3 by 3 matrix.
template <typename T>
using Matrix33 = Matrix<T, 3, 3>;

/// @brief 2 by 2 matrix of Real elements.
using Mat22 = Matrix22<Real>;

/// @brief 2 by 2 matrix of Mass elements.
using Mass22 = Matrix22<Mass>;

/// @brief 2 by 2 matrix of <code>InvMass</code> elements.
using InvMass22 = Matrix22<InvMass>;

/// @brief 3 by 3 matrix of Real elements.
using Mat33 = Matrix33<Real>;

/// @brief Determines if the given value is valid.
template <>
PLAYRHO_CONSTEXPR inline bool IsValid(const Mat22& value) noexcept
{
    return IsValid(get<0>(value)) && IsValid(get<1>(value));
}

/// @brief Gets an invalid value for a <code>Mat22</code>.
template <>
PLAYRHO_CONSTEXPR inline Mat22 GetInvalid() noexcept
{
    return Mat22{GetInvalid<Vec2>(), GetInvalid<Vec2>()};
}

} // namespace playrho

#endif // PLAYRHO_COMMON_MATRIX_HPP
