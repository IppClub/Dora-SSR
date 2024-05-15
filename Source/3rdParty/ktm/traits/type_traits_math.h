//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TYPE_TRAITS_MATH_H_
#define _KTM_TYPE_TRAITS_MATH_H_

#include "../type/vec_fwd.h"
#include "../type/mat_fwd.h"
#include "../type/quat_fwd.h"
#include "../type/comp_fwd.h"
#include "type_single_extend.h"

namespace ktm
{

// vec traits
template<typename T>
struct vec_traits;

template<size_t N, typename T>
struct vec_traits<vec<N, T>>
{
    using base_type = T;
    static inline constexpr size_t len = N;
};

template<typename T>
using vec_traits_base_t = typename vec_traits<T>::base_type;

template<typename T>
inline constexpr size_t vec_traits_len = vec_traits<T>::len;

// mat traits
template<typename T>
struct mat_traits;

template<size_t Row, size_t Col, typename T>
struct mat_traits<mat<Row, Col, T>>
{
    using base_type = T;
    using tp_type = mat<Col, Row, T>;
    using col_type = vec<Col, T>;
    using row_type = vec<Row, T>;
    static inline constexpr size_t col = Col;
    static inline constexpr size_t row = Row;
};

template<typename T>
using mat_traits_base_t = typename mat_traits<T>::base_type;

template<typename T>
using mat_traits_tp_t = typename mat_traits<T>::tp_type;

template<typename T>
using mat_traits_col_t = typename mat_traits<T>::col_type;

template<typename T>
using mat_traits_row_t = typename mat_traits<T>::row_type;

template<typename T>
inline constexpr size_t mat_traits_col_n = mat_traits<T>::col;

template<typename T>
inline constexpr size_t mat_traits_row_n = mat_traits<T>::row;

// quat traits
template<typename T>
struct quat_traits;

template<typename T>
struct quat_traits<quat<T>>
{
    using base_type = T;
    using storage_type = vec<4, T>;
};

template<typename T>
using quat_traits_base_t = typename quat_traits<T>::base_type;

template<typename T>
using quat_traits_storage_t = typename quat_traits<T>::storage_type;

// comp traits
template<typename T>
struct comp_traits;

template<typename T>
struct comp_traits<comp<T>>
{
    using base_type = T;
    using storage_type = vec<2, T>;
};

template<typename T>
using comp_traits_base_t = typename comp_traits<T>::base_type;

template<typename T>
using comp_traits_storage_t = typename comp_traits<T>::storage_type;

// ktm type traits
template<typename T>
struct is_vector : std::false_type { };

template<size_t N, typename T>
struct is_vector<vec<N, T>> : std::true_type{ };

template<typename T>
struct is_matrix : std::false_type { };

template<size_t Row, size_t Col, typename T>
struct is_matrix<mat<Row, Col, T>> : std::true_type { };

template<typename T>
struct is_square_matrix : std::false_type { };

template<size_t N, typename T>
struct is_square_matrix<mat<N, N, T>> : std::true_type { };

template<typename T>
struct is_quaternion : std::false_type { };

template<typename T>
struct is_quaternion<quat<T>> : std::true_type { };

template<typename T>
struct is_complex : std::false_type { };

template<typename T>
struct is_complex<comp<T>> : std::true_type { };

template<typename T>
struct is_floating_point_base : std::false_type { };

template<size_t N, typename T>
struct is_floating_point_base<vec<N, T>> : std::is_floating_point<T> { };

template<size_t Row, size_t Col, typename T>
struct is_floating_point_base<mat<Row, Col, T>> : std::is_floating_point<T> { };

template<typename T>
struct is_floating_point_base<quat<T>> : std::true_type { };

template<typename T>
struct is_floating_point_base<comp<T>> : std::true_type { };

template<typename T>
struct is_unsigned_base : std::false_type { };

template<size_t N, typename T>
struct is_unsigned_base<vec<N, T>> : std::is_unsigned<T> { };

template<size_t Row, size_t Col, typename T>
struct is_unsigned_base<mat<Row, Col, T>> : std::is_unsigned<T> { };

template<typename TList, typename T>
struct is_listing_type;

template<typename T, typename ...Ts>
struct is_listing_type<type_list<Ts...>, T> { static inline constexpr bool value = std::is_exist_same_vs<Ts..., T>; };

template<typename TList, typename T>
struct is_listing_type_base;

template<typename T, typename ...Ts>
struct is_listing_type_base<type_list<Ts...>, T> : std::false_type { };

template<size_t N, typename T, typename ...Ts>
struct is_listing_type_base<type_list<Ts...>, vec<N, T>> : is_listing_type<type_list<Ts...>, T> { };

template<size_t Row, size_t Col, typename T, typename ...Ts>
struct is_listing_type_base<type_list<Ts...>, mat<Row, Col, T>> : is_listing_type<type_list<Ts...>, T> { };

template<typename T, typename ...Ts>
struct is_listing_type_base<type_list<Ts...>, quat<T>> : is_listing_type<type_list<Ts...>, T> { };

template<typename T>
inline constexpr bool is_vector_v = is_vector<T>::value;

template<typename T>
inline constexpr bool is_matrix_v = is_matrix<T>::value;

template<typename T>
inline constexpr bool is_square_matrix_v = is_square_matrix<T>::value;

template<typename T>
inline constexpr bool is_quaternion_v = is_quaternion<T>::value;

template<typename T>
inline constexpr bool is_complex_v = is_complex<T>::value;

template<typename T>
inline constexpr bool is_floating_point_base_v = is_floating_point_base<T>::value;

template<typename T>
inline constexpr bool is_unsigned_base_v = is_unsigned_base<T>::value;

template<typename TList, typename T>
inline constexpr bool is_listing_type_v = is_listing_type<TList, T>::value;

template<typename TList, typename T>
inline constexpr bool is_listing_type_base_v = is_listing_type_base<TList, T>::value;
}

#endif