//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_EXPONENTIAL_H_
#define _KTM_VECTOR_EXPONENTIAL_H_

#include "../../setup.h"
#include "../../type/vec.h"
#include "../../traits/type_traits_math.h"
#include "../../detail/function/vector_exponential_fwd.h"

namespace ktm
{

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> sqrt(const V& x) noexcept
{
    return detail::vector_exponential_implement::sqrt<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> rsqrt(const V& x) noexcept
{
    return detail::vector_exponential_implement::rsqrt<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> recip(const V& x) noexcept
{
    return detail::vector_exponential_implement::recip<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> cbrt(const V& x) noexcept
{
    return detail::vector_exponential_implement::cbrt<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> pow(const V& x, const V& y) noexcept
{
    return detail::vector_exponential_implement::pow<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> exp(const V& x) noexcept
{
    return detail::vector_exponential_implement::exp<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> exp2(const V& x) noexcept
{
    return detail::vector_exponential_implement::exp2<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> expm1(const V& x) noexcept
{
    return detail::vector_exponential_implement::expm1<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> log(const V& x) noexcept
{
    return detail::vector_exponential_implement::log<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> log10(const V& x) noexcept
{
    return detail::vector_exponential_implement::log10<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> log2(const V& x) noexcept
{
    return detail::vector_exponential_implement::log2<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> log1p(const V& x) noexcept
{
    return detail::vector_exponential_implement::log1p<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> logb(const V& x) noexcept
{
    return detail::vector_exponential_implement::logb<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

namespace fast
{

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_listing_type_base_v<type_list<float, double>, V>, V>
sqrt(const V& x) noexcept
{
    return detail::vector_exponential_implement::fast_sqrt<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_listing_type_base_v<type_list<float, double>, V>, V>
rsqrt(const V& x) noexcept
{
    return detail::vector_exponential_implement::fast_rsqrt<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_listing_type_base_v<type_list<float, double>, V>, V>
recip(const V& x) noexcept
{
    return detail::vector_exponential_implement::fast_recip<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

} // namespace fast

} // namespace ktm

#include "../../detail/function/vector_exponential.inl"
#include "../../detail/function/vector_exponential_simd.inl"

#endif
