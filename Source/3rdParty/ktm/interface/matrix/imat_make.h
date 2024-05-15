//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_MAT_MAKE_H_
#define _KTM_I_MAT_MAKE_H_

#include <utility>
#include "../../setup.h"
#include "../../type/basic.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"

namespace ktm
{
template<class Father, class Child>
struct imat_make;

template<class Father, size_t Row, typename T>
struct imat_make<Father, mat<Row, 2, T>> : Father
{
    static KTM_INLINE mat<Row, 2, T> from_row(const vec<Row, T>& row0, const vec<Row, T>& row1) noexcept
    {
        return from_row(row0, row1, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE mat<Row, 2, T> from_row(const vec<Row, T>& row0, const vec<Row, T>& row1, std::index_sequence<Ns...>) noexcept
    {
        return mat<Row, 2, T>(vec<2, T>(row0[Ns], row1[Ns])...);
    }
};

template<class Father, typename T>
struct imat_make<Father, mat<2, 2, T>> : Father
{
    static KTM_INLINE mat<2, 2, T> from_row(const vec<2, T>& row0, const vec<2, T>& row1) noexcept
    {
        return mat<2, 2, T>(vec<2, T>(row0[0], row1[0]),
                            vec<2, T>(row0[1], row1[1]));
    }

    static KTM_INLINE mat<2, 2, T> from_diag(const vec<2, T>& diag) noexcept
    {
        return mat<2, 2, T>(vec<2, T>(diag[0], zero<T>),
                            vec<2, T>(zero<T>, diag[1]));
    }

    static KTM_INLINE mat<2, 2, T> from_eye() noexcept
    {
        return mat<2, 2, T>(vec<2, T>(one<T>, zero<T>),
                            vec<2, T>(zero<T>, one<T>));
    } 
};

template<class Father, size_t Row, typename T>
struct imat_make<Father, mat<Row, 3, T>> : Father
{
    static KTM_INLINE mat<Row, 3, T> from_row(const vec<Row, T>& row0, const vec<Row, T>& row1, const vec<Row, T>& row2) noexcept
    {
        return from_row(row0, row1, row2, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE mat<Row, 3, T> from_row(const vec<Row, T>& row0, const vec<Row, T>& row1, const vec<Row, T>& row2, std::index_sequence<Ns...>) noexcept
    {
        return mat<Row, 3, T>(vec<3, T>(row0[Ns], row1[Ns], row2[Ns])...);
    }
};

template<class Father, typename T>
struct imat_make<Father, mat<3, 3, T>> : Father
{
    static KTM_INLINE mat<3, 3, T> from_row(const vec<3, T>& row0, const vec<3, T>& row1, const vec<3, T>& row2) noexcept
    {
        return mat<3, 3, T>(vec<3, T>(row0[0], row1[0], row2[0]),
                            vec<3, T>(row0[1], row1[1], row2[1]),
                            vec<3, T>(row0[2], row1[2], row2[2]));
    }

    static KTM_INLINE mat<3, 3, T> from_diag(const vec<3, T>& diag) noexcept
    {
        return mat<3, 3, T>(vec<3, T>(diag[0], zero<T>, zero<T>),
                            vec<3, T>(zero<T>, diag[1], zero<T>), 
                            vec<3, T>(zero<T>, zero<T>, diag[2]));
    }

    static KTM_INLINE mat<3, 3, T> from_eye() noexcept
    {
        return mat<3, 3, T>(vec<3, T>(one<T>, zero<T>, zero<T>),
                            vec<3, T>(zero<T>, one<T>, zero<T>), 
                            vec<3, T>(zero<T>, zero<T>, one<T>)); 
    }
};

template<class Father, size_t Row, typename T>
struct imat_make<Father, mat<Row, 4, T>> : Father
{
    static KTM_INLINE mat<Row, 4, T> from_row(const vec<Row, T>& row0, const vec<Row, T>& row1, const vec<Row, T>& row2, const vec<Row, T>& row3) noexcept
    {
        return from_row(row0, row1, row2, row3, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE mat<Row, 4, T> from_row(const vec<Row, T>& row0, const vec<Row, T>& row1, const vec<Row, T>& row2, const vec<Row, T>& row3, std::index_sequence<Ns...>) noexcept
    {
        return mat<Row, 4, T>(vec<4, T>(row0[Ns], row1[Ns], row2[Ns], row3[Ns])...);
    }
};

template<class Father, typename T>
struct imat_make<Father, mat<4, 4, T>> : Father
{
    static KTM_INLINE mat<4, 4, T> from_row(const vec<4, T>& row0, const vec<4, T>& row1, const vec<4, T>& row2, const vec<4, T>& row3) noexcept
    {
        return mat<4, 4, T>(vec<4, T>(row0[0], row1[0], row2[0], row3[0]),
                            vec<4, T>(row0[1], row1[1], row2[1], row3[1]),
                            vec<4, T>(row0[2], row1[2], row2[2], row3[2]),
                            vec<4, T>(row0[3], row1[3], row2[3], row3[3]));
    }

    static KTM_INLINE mat<4, 4, T> from_diag(const vec<4, T>& diag) noexcept
    {
        return mat<4, 4, T>(vec<4, T>(diag[0], zero<T>, zero<T>, zero<T>),
                            vec<4, T>(zero<T>, diag[1], zero<T>, zero<T>), 
                            vec<4, T>(zero<T>, zero<T>, diag[2], zero<T>),
                            vec<4, T>(zero<T>, zero<T>, zero<T>, diag[3]));
    }

    static KTM_INLINE mat<4, 4, T> from_eye() noexcept
    {
        return mat<4, 4, T>(vec<4, T>(one<T>, zero<T>, zero<T>, zero<T>),
                            vec<4, T>(zero<T>, one<T>, zero<T>, zero<T>), 
                            vec<4, T>(zero<T>, zero<T>, one<T>, zero<T>),
                            vec<4, T>(zero<T>, zero<T>, zero<T>, one<T>)); 
    }
};
}

#endif