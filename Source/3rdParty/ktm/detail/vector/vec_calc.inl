//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_CALC_INL_
#define _KTM_VEC_CALC_INL_

#include <utility>
#include "vec_calc_fwd.h"
#include "../../setup.h"
#include "../../type/basic.h"
#include "../../type/vec_fwd.h"

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::add
{
    using V = vec<N, T>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        return call(x, y, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE V call(const V& x, const V& y, std::index_sequence<Ns...>) noexcept
    {
        V ret;
        ((ret[Ns] = x[Ns] + y[Ns]), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::add_to_self
{
    using V = vec<N, T>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        call(x, y, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE void call(V& x, const V& y, std::index_sequence<Ns...>) noexcept
    {
        ((x[Ns] += y[Ns]), ...);
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::minus
{
    using V = vec<N, T>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        return call(x, y, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE V call(const V& x, const V& y, std::index_sequence<Ns...>) noexcept
    {
        V ret;
        ((ret[Ns] = x[Ns] - y[Ns]), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::minus_to_self
{
    using V = vec<N, T>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        call(x, y, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE void call(V& x, const V& y, std::index_sequence<Ns...>) noexcept
    {
        ((x[Ns] -= y[Ns]), ...);
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::mul
{
    using V = vec<N, T>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        return call(x, y, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE V call(const V& x, const V& y, std::index_sequence<Ns...>) noexcept
    {
        V ret;
        ((ret[Ns] = x[Ns] * y[Ns]), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::mul_to_self
{
    using V = vec<N, T>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        call(x, y, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE void call(V& x, const V& y, std::index_sequence<Ns...>) noexcept
    {
        ((x[Ns] *= y[Ns]), ...);
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::div
{
    using V = vec<N, T>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        return call(x, y, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE V call(const V& x, const V& y, std::index_sequence<Ns...>) noexcept
    {
        V ret;
        ((ret[Ns] = x[Ns] / y[Ns]), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::div_to_self
{
    using V = vec<N, T>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        call(x, y, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE void call(V& x, const V& y, std::index_sequence<Ns...>) noexcept
    {
        ((x[Ns] /= y[Ns]), ...);
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::opposite
{
    using V = vec<N, T>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        return call(x, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE V call(const V& x, std::index_sequence<Ns...>) noexcept
    {
        V ret;
        ((ret[Ns] = -x[Ns]), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::add_scalar
{
    using V = vec<N, T>;
    static KTM_INLINE V call(const V& x, T scalar) noexcept
    {
        return call(x, scalar, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE V call(const V& x, T scalar, std::index_sequence<Ns...>) noexcept
    {
        V ret;
        ((ret[Ns] = x[Ns] + scalar), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::add_scalar_to_self
{
    using V = vec<N, T>;
    static KTM_INLINE void call(V& x, T scalar) noexcept
    {
        call(x, scalar, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE void call(V& x, T scalar, std::index_sequence<Ns...>) noexcept
    {
        ((x[Ns] += scalar), ...);
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::minus_scalar
{
    using V = vec<N, T>;
    static KTM_INLINE V call(const V& x, T scalar) noexcept
    {
        return call(x, scalar, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE V call(const V& x, T scalar, std::index_sequence<Ns...>) noexcept
    {
        V ret;
        ((ret[Ns] = x[Ns] - scalar), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::minus_scalar_to_self
{
    using V = vec<N, T>;
    static KTM_INLINE void call(V& x, T scalar) noexcept
    {
        call(x, scalar, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE void call(V& x, T scalar, std::index_sequence<Ns...>) noexcept
    {
        ((x[Ns] -= scalar), ...);
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::mul_scalar
{
    using V = vec<N, T>;
    static KTM_INLINE V call(const V& x, T scalar) noexcept
    {
        return call(x, scalar, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE V call(const V& x, T scalar, std::index_sequence<Ns...>) noexcept
    {
        V ret;
        ((ret[Ns] = x[Ns] * scalar), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::mul_scalar_to_self
{
    using V = vec<N, T>;
    static KTM_INLINE void call(V& x, T scalar) noexcept
    {
        call(x, scalar, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE void call(V& x, T scalar, std::index_sequence<Ns...>) noexcept
    {
        ((x[Ns] *= scalar), ...);
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::div_scalar
{
    using V = vec<N, T>;
    static KTM_INLINE V call(const V& x, T scalar) noexcept
    {   
        if constexpr(std::is_floating_point_v<T>)
            return mul_scalar<N, T>::call(x, one<T> / scalar);
        else 
            return call(x, scalar, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE V call(const V& x, T scalar, std::index_sequence<Ns...>) noexcept
    {
        V ret;
        ((ret[Ns] = x[Ns] / scalar), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::vec_calc_implement::div_scalar_to_self
{
    using V = vec<N, T>;
    static KTM_INLINE void call(V& x, T scalar) noexcept
    {
        if constexpr(std::is_floating_point_v<T>)
            mul_scalar_to_self<N, T>::call(x, one<T> / scalar);
        else 
            call(x, scalar, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE void call(V& x, T scalar, std::index_sequence<Ns...>) noexcept
    {
        ((x[Ns] /= scalar), ...);
    }
};

#endif
