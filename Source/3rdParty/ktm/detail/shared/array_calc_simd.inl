//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_ARRAY_CALC_SIMD_INL_
#define _KTM_ARRAY_CALC_SIMD_INL_

#include "array_calc_fwd.h"
#include "../loop_util.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

template <>
struct ktm::detail::array_calc_implement::add<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        _store64_f32(out.data(), _add64_f32(_load64_f32(x.data()), _load64_f32(y.data())));
    }
};

template <>
struct ktm::detail::array_calc_implement::sub<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        _store64_f32(out.data(), _sub64_f32(_load64_f32(x.data()), _load64_f32(y.data())));
    }
};

template <>
struct ktm::detail::array_calc_implement::neg<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x) noexcept
    {
        _store64_f32(out.data(), _neg64_f32(_load64_f32(x.data())));
    }
};

template <>
struct ktm::detail::array_calc_implement::mul<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        _store64_f32(out.data(), _mul64_f32(_load64_f32(x.data()), _load64_f32(y.data())));
    }
};

template <>
struct ktm::detail::array_calc_implement::div<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        _store64_f32(out.data(), _div64_f32(_load64_f32(x.data()), _load64_f32(y.data())));
    }
};

template <>
struct ktm::detail::array_calc_implement::madd<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y, const A& z) noexcept
    {
        _store64_f32(out.data(), _madd64_f32(_load64_f32(x.data()), _load64_f32(y.data()), _load64_f32(z.data())));
    }
};

template <>
struct ktm::detail::array_calc_implement::add_scalar<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, float scalar) noexcept
    {
        _store64_f32(out.data(), _add64_f32(_load64_f32(x.data()), _dup64_f32(scalar)));
    }
};

template <>
struct ktm::detail::array_calc_implement::sub_scalar<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, float scalar) noexcept
    {
        _store64_f32(out.data(), _sub64_f32(_load64_f32(x.data()), _dup64_f32(scalar)));
    }
};

template <>
struct ktm::detail::array_calc_implement::mul_scalar<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, float scalar) noexcept
    {
        _store64_f32(out.data(), _mul64_f32(_load64_f32(x.data()), _dup64_f32(scalar)));
    }
};

template <>
struct ktm::detail::array_calc_implement::div_scalar<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, float scalar) noexcept
    {
        _store64_f32(out.data(), _div64_f32(_load64_f32(x.data()), _dup64_f32(scalar)));
    }
};

template <>
struct ktm::detail::array_calc_implement::madd_scalar<float, 2>
{
    using A = std::array<float, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y, float scalar) noexcept
    {
        _store64_f32(out.data(), _madd64_f32(_load64_f32(x.data()), _load64_f32(y.data()), _dup64_f32(scalar)));
    }
};

template <>
struct ktm::detail::array_calc_implement::add<int, 2>
{
    using A = std::array<int, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        skv::sv2 x_st = _cast64_s32_f32(_load64_f32(x.data()));
        skv::sv2 y_st = _cast64_s32_f32(_load64_f32(y.data()));
        _store64_f32(out.data(), _cast64_f32_s32(_add64_s32(x_st, y_st)));
    }
};

template <>
struct ktm::detail::array_calc_implement::sub<int, 2>
{
    using A = std::array<int, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        skv::sv2 x_st = _cast64_s32_f32(_load64_f32(x.data()));
        skv::sv2 y_st = _cast64_s32_f32(_load64_f32(y.data()));
        _store64_f32(out.data(), _cast64_f32_s32(_sub64_s32(x_st, y_st)));
    }
};

template <>
struct ktm::detail::array_calc_implement::neg<int, 2>
{
    using A = std::array<int, 2>;

    static KTM_INLINE void call(A& out, const A& x) noexcept
    {
        skv::sv2 x_st = _cast64_s32_f32(_load64_f32(x.data()));
        _store64_f32(out.data(), _cast64_f32_s32(_neg64_s32(x_st)));
    }
};

template <>
struct ktm::detail::array_calc_implement::mul<int, 2>
{
    using A = std::array<int, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        skv::sv2 x_st = _cast64_s32_f32(_load64_f32(x.data()));
        skv::sv2 y_st = _cast64_s32_f32(_load64_f32(y.data()));
        _store64_f32(out.data(), _cast64_f32_s32(_mul64_s32(x_st, y_st)));
    }
};

template <>
struct ktm::detail::array_calc_implement::madd<int, 2>
{
    using A = std::array<int, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y, const A& z) noexcept
    {
        skv::sv2 x_st = _cast64_s32_f32(_load64_f32(x.data()));
        skv::sv2 y_st = _cast64_s32_f32(_load64_f32(y.data()));
        skv::sv2 z_st = _cast64_s32_f32(_load64_f32(z.data()));
        _store64_f32(out.data(), _cast64_f32_s32(_madd64_s32(x_st, y_st, z_st)));
    }
};

template <>
struct ktm::detail::array_calc_implement::add_scalar<int, 2>
{
    using A = std::array<int, 2>;

    static KTM_INLINE void call(A& out, const A& x, int scalar) noexcept
    {
        skv::sv2 x_st = _cast64_s32_f32(_load64_f32(x.data()));
        _store64_f32(out.data(), _cast64_f32_s32(_add64_s32(x_st, _dup64_s32(scalar))));
    }
};

template <>
struct ktm::detail::array_calc_implement::sub_scalar<int, 2>
{
    using A = std::array<int, 2>;

    static KTM_INLINE void call(A& out, const A& x, int scalar) noexcept
    {
        skv::sv2 x_st = _cast64_s32_f32(_load64_f32(x.data()));
        _store64_f32(out.data(), _cast64_f32_s32(_sub64_s32(x_st, _dup64_s32(scalar))));
    }
};

template <>
struct ktm::detail::array_calc_implement::mul_scalar<int, 2>
{
    using A = std::array<int, 2>;

    static KTM_INLINE void call(A& out, const A& x, int scalar) noexcept
    {
        skv::sv2 x_st = _cast64_s32_f32(_load64_f32(x.data()));
        _store64_f32(out.data(), _cast64_f32_s32(_mul64_s32(x_st, _dup64_s32(scalar))));
    }
};

template <>
struct ktm::detail::array_calc_implement::madd_scalar<int, 2>
{
    using A = std::array<int, 2>;

    static KTM_INLINE void call(A& out, const A& x, const A& y, int scalar) noexcept
    {
        skv::sv2 x_st = _cast64_s32_f32(_load64_f32(x.data()));
        skv::sv2 y_st = _cast64_s32_f32(_load64_f32(y.data()));
        _store64_f32(out.data(), _cast64_f32_s32(_madd64_s32(x_st, y_st, _dup64_s32(scalar))));
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#    define KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_UNARY(...) A &out, const A &x
#    define KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_UNARY(impl_name, type, num, ...) impl_name<type, num>::call
#    define KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_UNARY(cast_type, index, ...) \
        reinterpret_cast<cast_type&>(out[index]), reinterpret_cast<const cast_type&>(x[index])
#    define KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_UNARY(cast_type, index, ...) \
        KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_UNARY(cast_type, index)

#    define KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_BINARY(...) KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_UNARY(), const A& y
#    define KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_BINARY(impl_name, type, num, ...) impl_name<type, num>::call
#    define KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_BINARY(cast_type, index, ...) \
        KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_UNARY(cast_type, index), reinterpret_cast<const cast_type&>(y[index])
#    define KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_BINARY(cast_type, index, ...) \
        KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_BINARY(cast_type, index)

#    define KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_TERNARY(...) KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_BINARY(), const A& z
#    define KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_TERNARY(impl_name, type, num, ...) impl_name<type, num>::call
#    define KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_TERNARY(cast_type, index, ...) \
        KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_BINARY(cast_type, index), reinterpret_cast<const cast_type&>(z[index])
#    define KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_TERNARY(cast_type, index, ...) \
        KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_TERNARY(cast_type, index)

#    define KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_BINARY_SCALAR(type, ...) \
        KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_UNARY(), type scalar
#    define KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_BINARY_SCALAR(impl_name, type, num, ...) \
        [&scalar](std::array<type, num>& out, const std::array<type, num>& x) -> void     \
        {                                                                                 \
            impl_name<type, num>::call(out, x, scalar);                                   \
        }
#    define KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_BINARY_SCALAR(cast_type, index, ...) \
        KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_UNARY(cast_type, index)
#    define KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_BINARY_SCALAR(cast_type, index, ...) \
        KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_BINARY_SCALAR(cast_type, index), scalar

#    define KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_TERNARY_SCALAR(type, ...) \
        KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_BINARY(), type scalar
#    define KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_TERNARY_SCALAR(impl_name, type, num, ...)                            \
        [&scalar](std::array<type, num>& out, const std::array<type, num>& x, const std::array<type, num>& y) -> void \
        {                                                                                                             \
            impl_name<type, num>::call(out, x, y, scalar);                                                            \
        }
#    define KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_TERNARY_SCALAR(cast_type, index, ...) \
        KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_BINARY(cast_type, index)
#    define KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_TERNARY_SCALAR(cast_type, index, ...) \
        KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_TERNARY_SCALAR(cast_type, index), scalar

#    define KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(impl_name, type, enum)                                      \
        template <size_t N>                                                                             \
        struct ktm::detail::array_calc_implement::impl_name<type, N, std::enable_if_t<(N > 4)>>         \
        {                                                                                               \
            using A = std::array<type, N>;                                                              \
            static KTM_INLINE void call(KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_##enum(type)) noexcept        \
            {                                                                                           \
                constexpr size_t K = N / 4;                                                             \
                using AA4K = std::array<std::array<type, 4>, K>;                                        \
                loop_op<K, void>::call(KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_##enum(impl_name, type, 4), \
                                       KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_##enum(AA4K, 0));              \
                if constexpr (constexpr size_t J = N % 4)                                               \
                {                                                                                       \
                    using ATJ = std::array<type, J>;                                                    \
                    impl_name<type, J>::call(KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_##enum(ATJ, K * 4));     \
                }                                                                                       \
            }                                                                                           \
        };

template <>
struct ktm::detail::array_calc_implement::add<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        _store128_f32(out.data(), _add128_f32(_load128_f32(x.data()), _load128_f32(y.data())));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(add, float, BINARY)

template <>
struct ktm::detail::array_calc_implement::sub<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        _store128_f32(out.data(), _sub128_f32(_load128_f32(x.data()), _load128_f32(y.data())));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(sub, float, BINARY)

template <>
struct ktm::detail::array_calc_implement::neg<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x) noexcept
    {
        _store128_f32(out.data(), _neg128_f32(_load128_f32(x.data())));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(neg, float, UNARY)

template <>
struct ktm::detail::array_calc_implement::mul<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        _store128_f32(out.data(), _mul128_f32(_load128_f32(x.data()), _load128_f32(y.data())));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(mul, float, BINARY)

template <>
struct ktm::detail::array_calc_implement::madd<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y, const A& z) noexcept
    {
        _store128_f32(out.data(), _madd128_f32(_load128_f32(x.data()), _load128_f32(y.data()), _load128_f32(z.data())));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(madd, float, TERNARY)

template <>
struct ktm::detail::array_calc_implement::div<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        _store128_f32(out.data(), _div128_f32(_load128_f32(x.data()), _load128_f32(y.data())));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(div, float, BINARY)

template <>
struct ktm::detail::array_calc_implement::add_scalar<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, float scalar) noexcept
    {
        _store128_f32(out.data(), _add128_f32(_load128_f32(x.data()), _dup128_f32(scalar)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(add_scalar, float, BINARY_SCALAR)

template <>
struct ktm::detail::array_calc_implement::sub_scalar<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, float scalar) noexcept
    {
        _store128_f32(out.data(), _sub128_f32(_load128_f32(x.data()), _dup128_f32(scalar)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(sub_scalar, float, BINARY_SCALAR)

template <>
struct ktm::detail::array_calc_implement::mul_scalar<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, float scalar) noexcept
    {
        _store128_f32(out.data(), _mul128_f32(_load128_f32(x.data()), _dup128_f32(scalar)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(mul_scalar, float, BINARY_SCALAR)

template <>
struct ktm::detail::array_calc_implement::div_scalar<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, float scalar) noexcept
    {
        _store128_f32(out.data(), _div128_f32(_load128_f32(x.data()), _dup128_f32(scalar)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(div_scalar, float, BINARY_SCALAR)

template <>
struct ktm::detail::array_calc_implement::madd_scalar<float, 4>
{
    using A = std::array<float, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y, float scalar) noexcept
    {
        _store128_f32(out.data(), _madd128_f32(_load128_f32(x.data()), _load128_f32(y.data()), _dup128_f32(scalar)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(madd_scalar, float, TERNARY_SCALAR)

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2)

template <>
struct ktm::detail::array_calc_implement::add<int, 4>
{
    using A = std::array<int, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        skv::sv4 x_st = _cast128_s32_f32(_load128_f32(x.data()));
        skv::sv4 y_st = _cast128_s32_f32(_load128_f32(y.data()));
        _store128_f32(out.data(), _cast128_f32_s32(_add128_s32(x_st, y_st)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(add, int, BINARY)

template <>
struct ktm::detail::array_calc_implement::sub<int, 4>
{
    using A = std::array<int, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        skv::sv4 x_st = _cast128_s32_f32(_load128_f32(x.data()));
        skv::sv4 y_st = _cast128_s32_f32(_load128_f32(y.data()));
        _store128_f32(out.data(), _cast128_f32_s32(_sub128_s32(x_st, y_st)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(sub, int, BINARY)

template <>
struct ktm::detail::array_calc_implement::neg<int, 4>
{
    using A = std::array<int, 4>;

    static KTM_INLINE void call(A& out, const A& x) noexcept
    {
        skv::sv4 x_st = _cast128_s32_f32(_load128_f32(x.data()));
        _store128_f32(out.data(), _cast128_f32_s32(_neg128_s32(x_st)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(neg, int, UNARY)

template <>
struct ktm::detail::array_calc_implement::add_scalar<int, 4>
{
    using A = std::array<int, 4>;

    static KTM_INLINE void call(A& out, const A& x, int scalar) noexcept
    {
        skv::sv4 x_st = _cast128_s32_f32(_load128_f32(x.data()));
        _store128_f32(out.data(), _cast128_f32_s32(_add128_s32(x_st, _dup128_s32(scalar))));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(add_scalar, int, BINARY_SCALAR)

template <>
struct ktm::detail::array_calc_implement::sub_scalar<int, 4>
{
    using A = std::array<int, 4>;

    static KTM_INLINE void call(A& out, const A& x, int scalar) noexcept
    {
        skv::sv4 x_st = _cast128_s32_f32(_load128_f32(x.data()));
        _store128_f32(out.data(), _cast128_f32_s32(_sub128_s32(x_st, _dup128_s32(scalar))));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(sub_scalar, int, BINARY_SCALAR)

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1)

template <>
struct ktm::detail::array_calc_implement::mul<int, 4>
{
    using A = std::array<int, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        skv::sv4 x_st = _cast128_s32_f32(_load128_f32(x.data()));
        skv::sv4 y_st = _cast128_s32_f32(_load128_f32(y.data()));
        _store128_f32(out.data(), _cast128_f32_s32(_mul128_s32(x_st, y_st)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(mul, int, BINARY)

template <>
struct ktm::detail::array_calc_implement::madd<int, 4>
{
    using A = std::array<int, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y, const A& z) noexcept
    {
        skv::sv4 x_st = _cast128_s32_f32(_load128_f32(x.data()));
        skv::sv4 y_st = _cast128_s32_f32(_load128_f32(y.data()));
        skv::sv4 z_st = _cast128_s32_f32(_load128_f32(z.data()));
        _store128_f32(out.data(), _cast128_f32_s32(_madd128_s32(x_st, y_st, z_st)));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(madd, int, TERNARY)

template <>
struct ktm::detail::array_calc_implement::mul_scalar<int, 4>
{
    using A = std::array<int, 4>;

    static KTM_INLINE void call(A& out, const A& x, int scalar) noexcept
    {
        skv::sv4 x_st = _cast128_s32_f32(_load128_f32(x.data()));
        _store128_f32(out.data(), _cast128_f32_s32(_mul128_s32(x_st, _dup128_s32(scalar))));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(mul_scalar, int, BINARY_SCALAR)

template <>
struct ktm::detail::array_calc_implement::madd_scalar<int, 4>
{
    using A = std::array<int, 4>;

    static KTM_INLINE void call(A& out, const A& x, const A& y, int scalar) noexcept
    {
        skv::sv4 x_st = _cast128_s32_f32(_load128_f32(x.data()));
        skv::sv4 y_st = _cast128_s32_f32(_load128_f32(y.data()));
        _store128_f32(out.data(), _cast128_f32_s32(_madd128_s32(x_st, y_st, _dup128_s32(scalar))));
    }
};

KTM_DETAIL_ARRAY_CALC_SIMD_IMPL(madd_scalar, int, TERNARY_SCALAR)

#    undef KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_UNARY
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_UNARY
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_UNARY
#    undef KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_UNARY

#    undef KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_BINARY
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_BINARY
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_BINARY
#    undef KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_BINARY

#    undef KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_TERNARY
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_TERNARY
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_TERNARY
#    undef KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_TERNARY

#    undef KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_BINARY_SCALAR
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_BINARY_SCALAR
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_BINARY_SCALAR
#    undef KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_BINARY_SCALAR

#    undef KTM_DETAIL_ARRAY_CALC_FUNC_PARAMS_TERNARY_SCALAR
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_OPERATION_TERNARY_SCALAR
#    undef KTM_DETAIL_ARRAY_CALC_LOOP_PARAMS_TERNARY_SCALAR
#    undef KTM_DETAIL_ARRAY_CALC_LAST_PARAMS_TERNARY_SCALAR

#    undef KTM_DETAIL_ARRAY_CALC_SIMD_IMPL

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

#endif
