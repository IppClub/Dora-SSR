//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TYPE_TRAITS_MATH_H_
#define _KTM_TYPE_TRAITS_MATH_H_

#include "../type/vec_fwd.h"
#include "../type/mat_fwd.h"
#include "../type/quat_fwd.h"
#include "../type/comp_fwd.h"
#include "type_single_extends.h"

namespace ktm
{

// ktm type traits
template <typename T>
struct is_vector : std::false_type
{
};

template <size_t N, typename T>
struct is_vector<vec<N, T>> : std::true_type
{
};

template <typename T>
struct is_matrix : std::false_type
{
};

template <size_t Row, size_t Col, typename T>
struct is_matrix<mat<Row, Col, T>> : std::true_type
{
};

template <typename T>
struct is_square_matrix : std::false_type
{
};

template <size_t N, typename T>
struct is_square_matrix<mat<N, N, T>> : std::true_type
{
};

template <typename T>
struct is_quaternion : std::false_type
{
};

template <typename T>
struct is_quaternion<quat<T>> : std::true_type
{
};

template <typename T>
struct is_complex : std::false_type
{
};

template <typename T>
struct is_complex<comp<T>> : std::true_type
{
};

template <typename T>
struct is_floating_point_base : std::false_type
{
};

template <size_t N, typename T>
struct is_floating_point_base<vec<N, T>> : std::is_floating_point<T>
{
};

template <size_t Row, size_t Col, typename T>
struct is_floating_point_base<mat<Row, Col, T>> : std::is_floating_point<T>
{
};

template <typename T>
struct is_floating_point_base<quat<T>> : std::true_type
{
};

template <typename T>
struct is_floating_point_base<comp<T>> : std::true_type
{
};

template <typename T>
struct is_unsigned_base : std::false_type
{
};

template <size_t N, typename T>
struct is_unsigned_base<vec<N, T>> : std::is_unsigned<T>
{
};

template <size_t Row, size_t Col, typename T>
struct is_unsigned_base<mat<Row, Col, T>> : std::is_unsigned<T>
{
};

template <typename TList, typename T>
struct is_listing_type;

template <typename T, typename... Ts>
struct is_listing_type<type_list<Ts...>, T>
{
    static inline constexpr bool value = std::is_exist_same_vs<Ts..., T>;
};

template <typename TList, typename T>
struct is_listing_type_base;

template <typename T, typename... Ts>
struct is_listing_type_base<type_list<Ts...>, T> : std::false_type
{
};

template <size_t N, typename T, typename... Ts>
struct is_listing_type_base<type_list<Ts...>, vec<N, T>> : is_listing_type<type_list<Ts...>, T>
{
};

template <size_t Row, size_t Col, typename T, typename... Ts>
struct is_listing_type_base<type_list<Ts...>, mat<Row, Col, T>> : is_listing_type<type_list<Ts...>, T>
{
};

template <typename T, typename... Ts>
struct is_listing_type_base<type_list<Ts...>, quat<T>> : is_listing_type<type_list<Ts...>, T>
{
};

template <typename T>
inline constexpr bool is_vector_v = is_vector<T>::value;

template <typename T>
inline constexpr bool is_matrix_v = is_matrix<T>::value;

template <typename T>
inline constexpr bool is_square_matrix_v = is_square_matrix<T>::value;

template <typename T>
inline constexpr bool is_quaternion_v = is_quaternion<T>::value;

template <typename T>
inline constexpr bool is_complex_v = is_complex<T>::value;

template <typename T>
inline constexpr bool is_floating_point_base_v = is_floating_point_base<T>::value;

template <typename T>
inline constexpr bool is_unsigned_base_v = is_unsigned_base<T>::value;

template <typename TList, typename T>
inline constexpr bool is_listing_type_v = is_listing_type<TList, T>::value;

template <typename TList, typename T>
inline constexpr bool is_listing_type_base_v = is_listing_type_base<TList, T>::value;

// math traits
template <typename T>
struct math_traits;

// vec traits
template <size_t N, typename T>
struct math_traits<vec<N, T>>
{
    using base_type = T;
    static inline constexpr size_t len = N;
};

template <typename T, typename = std::enable_if_t<is_vector_v<T>>>
using vec_traits_base_t = typename math_traits<T>::base_type;

template <typename T, typename = std::enable_if_t<is_vector_v<T>>>
inline constexpr size_t vec_traits_len = math_traits<T>::len;

// mat traits
template <size_t Row, size_t Col, typename T>
struct math_traits<mat<Row, Col, T>>
{
    using base_type = T;
    using tp_type = mat<Col, Row, T>;
    using col_type = vec<Col, T>;
    using row_type = vec<Row, T>;
    static inline constexpr size_t col_value = Col;
    static inline constexpr size_t row_value = Row;
};

template <typename T, typename = std::enable_if_t<is_matrix_v<T>>>
using mat_traits_base_t = typename math_traits<T>::base_type;

template <typename T, typename = std::enable_if_t<is_matrix_v<T>>>
using mat_traits_tp_t = typename math_traits<T>::tp_type;

template <typename T, typename = std::enable_if_t<is_matrix_v<T>>>
using mat_traits_col_t = typename math_traits<T>::col_type;

template <typename T, typename = std::enable_if_t<is_matrix_v<T>>>
using mat_traits_row_t = typename math_traits<T>::row_type;

template <typename T, typename = std::enable_if_t<is_matrix_v<T>>>
inline constexpr size_t mat_traits_col_v = math_traits<T>::col_value;

template <typename T, typename = std::enable_if_t<is_matrix_v<T>>>
inline constexpr size_t mat_traits_row_v = math_traits<T>::row_value;

// quat traits
template <typename T>
struct math_traits<quat<T>>
{
    using base_type = T;
    static inline constexpr size_t len = 4;
};

template <typename T, typename = std::enable_if_t<is_quaternion_v<T>>>
using quat_traits_base_t = typename math_traits<T>::base_type;

template <typename T, typename = std::enable_if_t<is_quaternion_v<T>>>
inline constexpr size_t quat_traits_len = math_traits<T>::len;

// comp traits
template <typename T>
struct math_traits<comp<T>>
{
    using base_type = T;
    static inline constexpr size_t len = 2;
};

template <typename T, typename = std::enable_if_t<is_complex_v<T>>>
using comp_traits_base_t = typename math_traits<T>::base_type;

template <typename T, typename = std::enable_if_t<is_complex_v<T>>>
inline constexpr size_t comp_traits_len = math_traits<T>::len;

} // namespace ktm

#endif