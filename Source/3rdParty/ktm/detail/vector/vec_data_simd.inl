//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_DATA_SIMD_INL_
#define _KTM_VEC_DATA_SIMD_INL_

#include "vec_data_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

template <>
struct ktm::detail::vec_data_implement::vec_storage<2, float>
{
    typedef skv::fv2 type;
};

template <>
struct ktm::detail::vec_data_implement::vec_storage<2, int>
{
    typedef skv::sv2 type;
};

template <>
struct ktm::detail::vec_data_implement::vec_swizzle<2, 2, float>
{
    using V = vec<2, float>;
    using RetV = vec<2, float>;

    template <size_t S0, size_t S1>
    static KTM_INLINE RetV call(const V& v) noexcept
    {
        RetV ret;
        ret.st = _shuffo64_f32(v.st, S1, S0);
        return ret;
    }
};

template <size_t ISize>
struct ktm::detail::vec_data_implement::vec_swizzle<2, ISize, float, std::enable_if_t<ISize == 3 || ISize == 4>>
{
    using V = vec<ISize, float>;
    using RetV = vec<2, float>;

    template <size_t S0, size_t S1>
    static KTM_INLINE RetV call(const V& v) noexcept
    {
        RetV ret;
        ret.st = _cast128to64_f32(_shuffo128_f32(v.st, S1, S0, S1, S0));
        return ret;
    }
};

template <size_t ISize, typename T>
struct ktm::detail::vec_data_implement::vec_swizzle<
    2, ISize, T, std::enable_if_t<sizeof(T) == sizeof(float) && !std::is_same_v<T, float> && ISize >= 2 && ISize <= 4>>
{
    using V = vec<ISize, T>;
    using RetV = vec<2, T>;
    using FV = vec<ISize, float>;
    using FRetV = vec<2, float>;

    template <size_t S0, size_t S1>
    static KTM_INLINE RetV call(const V& v) noexcept
    {
        FRetV ret = vec_swizzle<2, ISize, float>::template call<S0, S1>(reinterpret_cast<const FV&>(v));
        return *reinterpret_cast<RetV*>(&ret);
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template <>
struct ktm::detail::vec_data_implement::vec_storage<3, float>
{
    typedef skv::fv4 type;
};

template <>
struct ktm::detail::vec_data_implement::vec_storage<4, float>
{
    typedef skv::fv4 type;
};

template <size_t ISize>
struct ktm::detail::vec_data_implement::vec_swizzle<3, ISize, float, std::enable_if_t<ISize == 3 || ISize == 4>>
{
    using V = vec<ISize, float>;
    using RetV = vec<3, float>;

    template <size_t S0, size_t S1, size_t S2>
    static KTM_INLINE RetV call(const V& v) noexcept
    {
        RetV ret;
        ret.st = _shuffo128_f32(v.st, 0, S2, S1, S0);
        return ret;
    }
};

template <size_t ISize, typename T>
struct ktm::detail::vec_data_implement::vec_swizzle<
    3, ISize, T, std::enable_if_t<sizeof(T) == sizeof(float) && !std::is_same_v<T, float> && ISize >= 3 && ISize <= 4>>
{
    using V = vec<ISize, T>;
    using RetV = vec<3, T>;
    using FV = vec<ISize, float>;
    using FRetV = vec<3, float>;

    template <size_t S0, size_t S1, size_t S2>
    static KTM_INLINE RetV call(const V& v) noexcept
    {
        FRetV ret = vec_swizzle<3, ISize, float>::template call<S0, S1, S2>(reinterpret_cast<const FV&>(v));
        return *reinterpret_cast<RetV*>(&ret);
    }
};

template <>
struct ktm::detail::vec_data_implement::vec_swizzle<4, 4, float>
{
    using V = vec<4, float>;
    using RetV = vec<4, float>;

    template <size_t S0, size_t S1, size_t S2, size_t S3>
    static KTM_INLINE RetV call(const V& v) noexcept
    {
        RetV ret;
        ret.st = _shuffo128_f32(v.st, S3, S2, S1, S0);
        return ret;
    }
};

template <typename T>
struct ktm::detail::vec_data_implement::vec_swizzle<
    4, 4, T, std::enable_if_t<sizeof(T) == sizeof(float) && !std::is_same_v<T, float>>>
{
    using V = vec<4, T>;
    using RetV = vec<4, T>;
    using FV = vec<4, float>;
    using FRetV = vec<4, float>;

    template <size_t S0, size_t S1, size_t S2, size_t S3>
    static KTM_INLINE RetV call(const V& v) noexcept
    {
        FRetV ret = vec_swizzle<4, 4, float>::template call<S0, S1, S2, S3>(reinterpret_cast<const FV&>(v));
        return *reinterpret_cast<RetV*>(&ret);
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

template <>
struct ktm::detail::vec_data_implement::vec_storage<3, int>
{
    typedef skv::sv4 type;
};

template <>
struct ktm::detail::vec_data_implement::vec_storage<4, int>
{
    typedef skv::sv4 type;
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

#endif