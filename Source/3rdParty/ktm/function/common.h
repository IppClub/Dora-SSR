//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMMON_H_
#define _KTM_COMMON_H_

#include "../setup.h"
#include "../type/vec.h"
#include "../traits/type_traits_math.h"
#include "../detail/function/common_fwd.h"

namespace ktm
{

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, vec_traits_base_t<V>> reduce_add(const V& x) noexcept
{
    return detail::common_implement::reduce_add<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, vec_traits_base_t<V>> reduce_min(const V& x) noexcept
{
    return detail::common_implement::reduce_min<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, vec_traits_base_t<V>> reduce_max(const V& x) noexcept
{
    return detail::common_implement::reduce_max<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && !is_unsigned_base_v<V>, V> abs(const V& x) noexcept
{
    return detail::common_implement::abs<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, V> min(const V& x, const V& y) noexcept
{
    return detail::common_implement::min<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, V> max(const V& x, const V& y) noexcept
{
    return detail::common_implement::max<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, V> clamp(const V& v, const V& min, const V& max) noexcept
{
    return detail::common_implement::clamp<vec_traits_len<V>, vec_traits_base_t<V>>::call(v, min, max);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> floor(const V& x) noexcept
{
    return detail::common_implement::floor<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> ceil(const V& x) noexcept
{
    return detail::common_implement::ceil<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> round(const V& x) noexcept
{
    return detail::common_implement::round<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> fract(const V& x) noexcept
{
    return detail::common_implement::fract<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> mod(const V& x, const V& y) noexcept
{
    return detail::common_implement::mod<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> lerp(const V& x, const V& y, vec_traits_base_t<V> t) noexcept
{
    return detail::common_implement::lerp<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y, t);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> mix(const V& x, const V& y, const V& t) noexcept
{
    return detail::common_implement::mix<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y, t);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> step(const V& edge, const V& x) noexcept
{
    return detail::common_implement::step<vec_traits_len<V>, vec_traits_base_t<V>>::call(edge, x);
} 

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> smoothstep(const V& edge0, const V& edge1, const V& x) noexcept
{
    return detail::common_implement::smoothstep<vec_traits_len<V>, vec_traits_base_t<V>>::call(edge0, edge1, x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> sqrt(const V& x) noexcept
{
    return detail::common_implement::sqrt<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> rsqrt(const V& x) noexcept
{
    return detail::common_implement::rsqrt<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> recip(const V& x) noexcept
{
    return detail::common_implement::recip<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

namespace fast
{

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_listing_type_base_v<type_list<float, double>, V>, V> sqrt(const V& x) noexcept
{
    return detail::common_implement::fast_sqrt<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_listing_type_base_v<type_list<float, double>, V>, V> rsqrt(const V& x) noexcept
{
    return detail::common_implement::fast_rsqrt<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_listing_type_base_v<type_list<float, double>, V>, V> recip(const V& x) noexcept
{
    return detail::common_implement::fast_recip<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

}

}   

#include "../detail/function/common.inl"
#include "../detail/function/common_simd.inl"

#endif
