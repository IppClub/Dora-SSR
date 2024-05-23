//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MAT_CALC_SIMD_H_
#define _KTM_MAT_CALC_SIMD_H_

#include "mat_calc_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::mat_mul_vec<Row, Col, float, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, float>;
    using ColV = vec<Col, float>;
    using RowV = vec<Row, float>;
    static KTM_INLINE ColV call(const M& m, const RowV& v) noexcept
    {
        return call(m, v, std::make_index_sequence<Row - 1>());
    }
private:

    template<size_t ...Ns>
    static KTM_INLINE ColV call(const M& m, const RowV& v, std::index_sequence<Ns...>) noexcept
    {
        ColV ret;
        ret.st = _mul128_f32(m[0].st, _dup128_f32(v[0]));
        ((ret.st = _madd128_f32(ret.st, m[Ns + 1].st, _dup128_f32(v[Ns + 1]))), ...);
        return ret; 
    }
};

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::vec_mul_mat<Row, Col, float, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, float>;
    using ColV = vec<Col, float>;
    using RowV = vec<Row, float>;
    static KTM_INLINE RowV call(const ColV& v, const M& m) noexcept
    {
        return call(v, m, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE RowV call(const ColV& v, const M& m, std::index_sequence<Ns...>) noexcept
    {
        RowV ret;
        if constexpr(Col == 3) 
        {
            ((ret[Ns] = skv::radd_fv3(_mul128_f32(v.st, m[Ns].st))), ...);
        }
        else 
        {
            ((ret[Ns] = skv::radd_fv4(_mul128_f32(v.st, m[Ns].st))), ...);
        }
        return ret;
    }
};

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::add<Row, Col, float, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, float>;
    using ColV = vec<Col, float>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _add128_f32(m1[Ns].st, m2[Ns].st)), ...);
        return ret;
    }
};

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::minus<Row, Col, float, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, float>;
    using ColV = vec<Col, float>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
   template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _sub128_f32(m1[Ns].st, m2[Ns].st)), ...);
        return ret;
    }
};

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::opposite<Row, Col, float, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, float>;
    using ColV = vec<Col, float>;
    static KTM_INLINE M call(const M& m) noexcept
    {
        return call(m, std::make_index_sequence<Row>());
    }
private:
   template<size_t ...Ns>
    static KTM_INLINE M call(const M& m, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _neg128_f32(m[Ns].st)), ...);
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::add<Row, Col, int, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, int>;
    using ColV = vec<Col, int>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _add128_s32(m1[Ns].st, m2[Ns].st)), ...);
        return ret;
    }
};

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::minus<Row, Col, int, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, int>;
    using ColV = vec<Col, int>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
   template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _sub128_s32(m1[Ns].st, m2[Ns].st)), ...);
        return ret;
    }
};

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::opposite<Row, Col, int, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, int>;
    using ColV = vec<Col, int>;
    static KTM_INLINE M call(const M& m) noexcept
    {
        return call(m, std::make_index_sequence<Row>());
    }
private:
   template<size_t ...Ns>
    static KTM_INLINE M call(const M& m, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _neg128_s32(m[Ns].st)), ...);
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::mat_mul_vec<Row, Col, int, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, int>;
    using ColV = vec<Col, int>;
    using RowV = vec<Row, int>;
    static KTM_INLINE ColV call(const M& m, const RowV& v) noexcept
    {
        return call(m, v, std::make_index_sequence<Row - 1>());
    }
private:

    template<size_t ...Ns>
    static KTM_INLINE ColV call(const M& m, const RowV& v, std::index_sequence<Ns...>) noexcept
    {
        ColV ret;
        ret.st = _mul128_s32(m[0].st, _dup128_s32(v[0]));
        ((ret.st = _madd128_s32(ret.st, m[Ns + 1].st, _dup128_s32(v[Ns + 1]))), ...);
        return ret; 
    }
};

template<size_t Row, size_t Col>
struct ktm::detail::mat_opt_implement::vec_mul_mat<Row, Col, int, std::enable_if_t<Col == 3 || Col == 4>>
{
    using M = mat<Row, Col, int>;
    using ColV = vec<Col, int>;
    using RowV = vec<Row, int>;
    static KTM_INLINE RowV call(const ColV& v, const M& m) noexcept
    {
        return call(v, m, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE RowV call(const ColV& v, const M& m, std::index_sequence<Ns...>) noexcept
    {
        RowV ret;
        if constexpr(Col == 3)
        {
            ((ret[Ns] = skv::radd_sv3(_mul128_s32(v.st, m[Ns].st))), ...);
        }
        else 
        {
            ((ret[Ns] = skv::radd_sv4(_mul128_s32(v.st, m[Ns].st))), ...);
        }
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

template<size_t Row>
struct ktm::detail::mat_opt_implement::mat_mul_vec<Row, 2, float>
{
    using M = mat<Row, 2, float>;
    using ColV = vec<2, float>;
    using RowV = vec<Row, float>;
    static KTM_INLINE ColV call(const M& m, const RowV& v) noexcept
    {
        return call(m, v, std::make_index_sequence<Row - 1>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE ColV call(const M& m, const RowV& v, std::index_sequence<Ns...>) noexcept
    {
        ColV ret;
        ret.st = _mul64_f32(m[0].st, _dup64_f32(v[0]));
        ((ret.st = _madd64_f32(ret.st, m[Ns + 1].st, _dup64_f32(v[Ns + 1]))), ...);
        return ret; 
    }
};

template<size_t Row>
struct ktm::detail::mat_opt_implement::vec_mul_mat<Row, 2, float>
{
    using M = mat<Row, 2, float>;
    using ColV = vec<2, float>;
    using RowV = vec<Row, float>;
    static KTM_INLINE RowV call(const ColV& v, const M& m) noexcept
    {
        return call(v, m, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE RowV call(const ColV& v, const M& m, std::index_sequence<Ns...>) noexcept
    {
        RowV ret;
        ((ret[Ns] = skv::radd_fv2(_mul64_f32(v.st, m[Ns].st))), ...);
        return ret;
    }
};

template<size_t Row>
struct ktm::detail::mat_opt_implement::add<Row, 2, float>
{
    using M = mat<Row, 2, float>;
    using ColV = vec<2, float>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _add64_f32(m1[Ns].st, m2[Ns].st)), ...);
        return ret;
    }
};

template<size_t Row>
struct ktm::detail::mat_opt_implement::minus<Row, 2, float>
{
    using M = mat<Row, 2, float>;
    using ColV = vec<2, float>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
   template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _sub64_f32(m1[Ns].st, m2[Ns].st)), ...);
        return ret;
    }
};

template<size_t Row>
struct ktm::detail::mat_opt_implement::opposite<Row, 2, float>
{
    using M = mat<Row, 2, float>;
    using ColV = vec<2, float>;
    static KTM_INLINE M call(const M& m) noexcept
    {
        return call(m, std::make_index_sequence<Row>());
    }
private:
   template<size_t ...Ns>
    static KTM_INLINE M call(const M& m, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _neg64_f32(m[Ns].st)), ...);
        return ret;
    }
};

template<size_t Row>
struct ktm::detail::mat_opt_implement::mat_mul_vec<Row, 2, int>
{
    using M = mat<Row, 2, int>;
    using ColV = vec<2, int>;
    using RowV = vec<Row, int>;
    static KTM_INLINE ColV call(const M& m, const RowV& v) noexcept
    {
        return call(m, v, std::make_index_sequence<Row - 1>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE ColV call(const M& m, const RowV& v, std::index_sequence<Ns...>) noexcept
    {
        ColV ret;
        ret.st = _mul64_s32(m[0].st, _dup64_s32(v[0]));
        ((ret.st = _madd64_s32(ret.st, m[Ns + 1].st, _dup64_s32(v[Ns + 1]))), ...);
        return ret; 
    }
};

template<size_t Row>
struct ktm::detail::mat_opt_implement::vec_mul_mat<Row, 2, int>
{
    using M = mat<Row, 2, int>;
    using ColV = vec<2, int>;
    using RowV = vec<Row, int>;
    static KTM_INLINE RowV call(const ColV& v, const M& m) noexcept
    {
        return call(v, m, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE RowV call(const ColV& v, const M& m, std::index_sequence<Ns...>) noexcept
    {
        RowV ret;
        ((ret[Ns] = skv::radd_sv2(_mul64_s32(v.st, m[Ns].st))), ...);
        return ret;
    }
};

template<size_t Row>
struct ktm::detail::mat_opt_implement::add<Row, 2, int>
{
    using M = mat<Row, 2, int>;
    using ColV = vec<2, int>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _add64_s32(m1[Ns].st, m2[Ns].st)), ...);
        return ret;
    }
};

template<size_t Row>
struct ktm::detail::mat_opt_implement::minus<Row, 2, int>
{
    using M = mat<Row, 2, int>;
    using ColV = vec<2, int>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
   template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _sub64_s32(m1[Ns].st, m2[Ns].st)), ...);
        return ret;
    }
};

template<size_t Row>
struct ktm::detail::mat_opt_implement::opposite<Row, 2, int>
{
    using M = mat<Row, 2, int>;
    using ColV = vec<2, int>;
    static KTM_INLINE M call(const M& m) noexcept
    {
        return call(m, std::make_index_sequence<Row>());
    }
private:
   template<size_t ...Ns>
    static KTM_INLINE M call(const M& m, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        ((ret[Ns].st = _neg64_s32(m[Ns].st)), ...);
        return ret;
    }
};

#endif

#endif