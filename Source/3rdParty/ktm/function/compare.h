//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMPARE_H_
#define _KTM_COMPARE_H_

#include "../setup.h"
#include "../type/basic.h"
#include "../traits/type_traits_math.h"
#include "common.h"

namespace ktm
{

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> equal_zero(T x, T e = epsilon<T>) noexcept
{
    return abs(x) <= e;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> equal(T x, T y, T e = epsilon<T>) noexcept
{
    return equal_zero(x - y, e);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> less_zero(T x, T e = epsilon<T>) noexcept
{
    return x < -e;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> less(T x, T y, T e = epsilon<T>) noexcept
{
    return less_zero(x - y, e);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> greater_zero(T x, T e = epsilon<T>) noexcept
{
    return x > e;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> greater(T x, T y, T e = epsilon<T>) noexcept
{
    return greater_zero(x - y, e);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool>
equal_zero(const V& x, vec_traits_base_t<V> e = epsilon<vec_traits_base_t<V>>) noexcept
{
    return equal_zero(reduce_add(abs(x)), e);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool>
equal(const V& x, const V& y, vec_traits_base_t<V> e = epsilon<vec_traits_base_t<V>>) noexcept
{
    return equal_zero(x - y, e);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool>
less_zero(const V& x, vec_traits_base_t<V> e = epsilon<vec_traits_base_t<V>>) noexcept
{
    return less_zero(reduce_max(x), e);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool>
less(const V& x, const V& y, vec_traits_base_t<V> e = epsilon<vec_traits_base_t<V>>) noexcept
{
    return less_zero(x - y, e);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool>
greater_zero(const V& x, vec_traits_base_t<V> e = epsilon<vec_traits_base_t<V>>) noexcept
{
    return greater_zero(reduce_min(x), e);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool>
greater(const V& x, const V& y, vec_traits_base_t<V> e = epsilon<vec_traits_base_t<V>>) noexcept
{
    return greater_zero(x - y, e);
}

} // namespace ktm

#endif