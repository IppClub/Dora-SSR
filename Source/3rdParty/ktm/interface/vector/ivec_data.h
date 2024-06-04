//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_VEC_DATA_H_
#define _KTM_I_VEC_DATA_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../detail/vector/vec_data_fwd.h"

KTM_VEC_ST_ENUM_PACKAGE(x, y, z, w)
KTM_VEC_ST_ENUM_PACKAGE(r, g, b, a)

#define KTM_PERMUTATION_2_2(x, y, n) \
KTM_INLINE vec<2, T> x##y() const noexcept \
{ \
    return detail::vec_data_implement::vec_swizzle<2, n, T>::template call<KTM_VEC_ST_ENUM_GET(x), \
        KTM_VEC_ST_ENUM_GET(y)>(reinterpret_cast<const vec<n, T>&>(*this)); \
} \
KTM_INLINE vec<2, T> y##x() const noexcept \
{ \
    return detail::vec_data_implement::vec_swizzle<2, n, T>::template call<KTM_VEC_ST_ENUM_GET(y), \
        KTM_VEC_ST_ENUM_GET(x)>(reinterpret_cast<const vec<n, T>&>(*this)); \
}

#define KTM_PERMUTATION_3_2(x, y, z, n) \
KTM_INLINE vec<3, T> x##y##z() const noexcept \
{ \
    return detail::vec_data_implement::vec_swizzle<3, n, T>::template call<KTM_VEC_ST_ENUM_GET(x), \
        KTM_VEC_ST_ENUM_GET(y), KTM_VEC_ST_ENUM_GET(z)>(reinterpret_cast<const vec<n, T>&>(*this)); \
} \
KTM_INLINE vec<3, T> x##z##y() const noexcept \
{ \
    return detail::vec_data_implement::vec_swizzle<3, n, T>::template call<KTM_VEC_ST_ENUM_GET(x), \
        KTM_VEC_ST_ENUM_GET(z), KTM_VEC_ST_ENUM_GET(y)>(reinterpret_cast<const vec<n, T>&>(*this)); \
}

#define KTM_PERMUTATION_4_2(x, y, z, w, n) \
KTM_INLINE vec<4, T> x##y##z##w() const noexcept \
{ \
    return detail::vec_data_implement::vec_swizzle<4, n, T>::template call<KTM_VEC_ST_ENUM_GET(x), \
        KTM_VEC_ST_ENUM_GET(y), KTM_VEC_ST_ENUM_GET(z), KTM_VEC_ST_ENUM_GET(w)>(reinterpret_cast<const vec<n, T>&>(*this)); \
} \
KTM_INLINE vec<4, T> x##y##w##z() const noexcept \
{ \
    return detail::vec_data_implement::vec_swizzle<4, n, T>::template call<KTM_VEC_ST_ENUM_GET(x), \
        KTM_VEC_ST_ENUM_GET(y), KTM_VEC_ST_ENUM_GET(w), KTM_VEC_ST_ENUM_GET(z)>(reinterpret_cast<const vec<n, T>&>(*this)); \
}

#define KTM_PERMUTATION_3_3(x, y, z, n) \
KTM_PERMUTATION_3_2(x, y, z, n) \
KTM_PERMUTATION_3_2(y, z, x, n) \
KTM_PERMUTATION_3_2(z, x, y, n)

#define KTM_PERMUTATION_4_3(x, y, z, w, n) \
KTM_PERMUTATION_4_2(x, y, z, w, n) \
KTM_PERMUTATION_4_2(x, z, w, y, n) \
KTM_PERMUTATION_4_2(x, w, y, z, n)

#define KTM_PERMUTATION_4_4(x, y, z, w, n) \
KTM_PERMUTATION_4_3(x, y, z, w, n) \
KTM_PERMUTATION_4_3(y, z, w, x, n) \
KTM_PERMUTATION_4_3(z, w, x, y, n) \
KTM_PERMUTATION_4_3(w, x, y, z, n)

#define KTM_SWIZZLE_VEC2(x, y) \
KTM_PERMUTATION_2_2(x, y, 2)

#define KTM_SWIZZLE_VEC3(x, y, z) \
KTM_PERMUTATION_3_3(x, y, z, 3) \
KTM_PERMUTATION_2_2(x, y, 3) \
KTM_PERMUTATION_2_2(x, z, 3) \
KTM_PERMUTATION_2_2(y, z, 3)

#define KTM_SWIZZLE_VEC4(x, y, z, w) \
KTM_PERMUTATION_4_4(x, y, z, w, 4) \
KTM_PERMUTATION_3_3(x, y, z, 4) \
KTM_PERMUTATION_3_3(x, y, w, 4) \
KTM_PERMUTATION_3_3(x, z, w, 4) \
KTM_PERMUTATION_3_3(y, z, w, 4) \
KTM_PERMUTATION_2_2(x, y, 4) \
KTM_PERMUTATION_2_2(x, z, 4) \
KTM_PERMUTATION_2_2(x, w, 4) \
KTM_PERMUTATION_2_2(y, z, 4) \
KTM_PERMUTATION_2_2(y, w, 4) \
KTM_PERMUTATION_2_2(z, w, 4) \

namespace ktm
{

template<class Father, class Child>
struct ivec_data;

template<class Father, size_t N, typename T>
struct ivec_data<Father, vec<N, T>> : Father
{
    using Father::Father;
    typename detail::vec_data_implement::vec_storage<N, T>::type st;

    template<typename ...Ts, typename = std::enable_if_t<sizeof...(Ts) == N>>
    explicit ivec_data(Ts... elems) noexcept 
    {
        T* st_ptr = reinterpret_cast<T*>(&st);
        int i = 0;
        ((st_ptr[i++] = static_cast<T>(elems)), ...);
    }

    template<typename U, typename = std::enable_if_t<!std::is_same_v<U, T>>>
    explicit ivec_data(const vec<N, U>& v) noexcept
    {
        T* st_ptr = reinterpret_cast<T*>(&st);
        const U* v_ptr = reinterpret_cast<const U*>(&v.st);
        for(int i = 0; i < N; ++i)
            st_ptr[i] = static_cast<T>(v_ptr[i]);
    }

    template<size_t ...Ns, typename = std::enable_if_t<((Ns < N) && ...)>>
    KTM_INLINE std::enable_if_t<sizeof...(Ns) <= N, vec<sizeof...(Ns), T>> swizzle() noexcept
    {
        return detail::vec_data_implement::vec_swizzle<sizeof...(Ns), N, T>::template call<Ns...>(
            reinterpret_cast<const vec<N, T> &>(*this));
    }
};

template<class Father, typename T>
struct ivec_data<Father, vec<2, T>> : Father
{
    using Father::Father;
    union
    {
        struct { T x, y; };
        struct { T r, g; };
        typename detail::vec_data_implement::vec_storage<2, T>::type st;
    };
    constexpr explicit ivec_data(T xi, T yi) noexcept : x(xi), y(yi) { }
    template<typename U, typename = std::enable_if_t<!std::is_same_v<U, T>>>
    explicit ivec_data(const vec<2, U>& v) noexcept : x(static_cast<T>(v.x)), y(static_cast<T>(v.y)) { }

    KTM_SWIZZLE_VEC2(x, y)
    KTM_SWIZZLE_VEC2(r, g)
};

template<class Father, typename T>
struct ivec_data<Father, vec<3, T>> : Father
{
    using Father::Father;
    union
    {
        struct { T x, y, z; };
        struct { T r, g, b; };
        typename detail::vec_data_implement::vec_storage<3, T>::type st;
    };
    constexpr explicit ivec_data(T xi, T yi, T zi) noexcept : x(xi), y(yi), z(zi) { }
    explicit ivec_data(const vec<2, T>& v, T zi) noexcept : x(v.x), y(v.y), z(zi) { }
    template<typename U, typename = std::enable_if_t<!std::is_same_v<U, T>>>
    explicit ivec_data(const vec<3, U>& v) noexcept : x(static_cast<T>(v.x)), y(static_cast<T>(v.y)), z(static_cast<T>(v.z)) { }

    KTM_SWIZZLE_VEC3(x, y, z)
    KTM_SWIZZLE_VEC3(r, g, b) 
};

template<class Father, typename T>
struct ivec_data<Father, vec<4, T>> : Father
{
    using Father::Father;
    union
    {
        struct { T x, y, z, w; };
        struct { T r, g, b, a; };
        typename detail::vec_data_implement::vec_storage<4, T>::type st;
    };
    constexpr explicit ivec_data(T xi, T yi, T zi, T wi) noexcept : x(xi), y(yi), z(zi), w(wi) { }
    explicit ivec_data(const vec<3, T>& v, T wi) noexcept : x(v.x), y(v.y), z(v.z), w(wi) { }
    template<typename U, typename = std::enable_if_t<!std::is_same_v<U, T>>>
    explicit ivec_data(const vec<4, U>& v) noexcept : x(static_cast<T>(v.x)), y(static_cast<T>(v.y)), z(static_cast<T>(v.z)), w(static_cast<T>(v.w)) { }

    KTM_SWIZZLE_VEC4(x, y, z, w)
    KTM_SWIZZLE_VEC4(r, g, b, a)
};

}

#endif