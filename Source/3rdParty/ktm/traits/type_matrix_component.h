//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TYPE_MATRIX_COMPONENT_H_
#define _KTM_TYPE_MATRIX_COMPONENT_H_

#include <tuple>
#include "../type/vec_fwd.h"
#include "../type/mat_fwd.h"

namespace ktm
{

#define KTM_MATRIX_COMPONENT_ELEMENT(name, index)                                \
    using name##_type = std::tuple_element_t<index, type>;                       \
    inline name##_type& get_##name() noexcept { return std::get<index>(*this); } \
    inline const name##_type& get_##name() const noexcept { return std::get<index>(*this); }

template <class M>
struct reduce_component;

template <size_t N, typename T>
struct reduce_component<mat<N, N, T>> : std::tuple<mat<N, N, T>, mat<N, N, T>>
{
    using type = std::tuple<mat<N, N, T>, mat<N, N, T>>;
    using type::type;

    KTM_MATRIX_COMPONENT_ELEMENT(transform, 0)
    KTM_MATRIX_COMPONENT_ELEMENT(reduce, 1)
};

template <class M>
struct lu_component;

template <size_t N, typename T>
struct lu_component<mat<N, N, T>> : std::tuple<mat<N, N, T>, mat<N, N, T>>
{
    using type = std::tuple<mat<N, N, T>, mat<N, N, T>>;
    using type::type;

    KTM_MATRIX_COMPONENT_ELEMENT(l, 0)
    KTM_MATRIX_COMPONENT_ELEMENT(u, 1)
};

template <class M>
struct qr_component;

template <size_t N, typename T>
struct qr_component<mat<N, N, T>> : std::tuple<mat<N, N, T>, mat<N, N, T>>
{
    using type = std::tuple<mat<N, N, T>, mat<N, N, T>>;
    using type::type;

    KTM_MATRIX_COMPONENT_ELEMENT(q, 0)
    KTM_MATRIX_COMPONENT_ELEMENT(r, 1)
};

template <class M>
struct edv_component;

template <size_t N, typename T>
struct edv_component<mat<N, N, T>> : std::tuple<mat<N, N, T>, vec<N, T>>
{
    using type = std::tuple<mat<N, N, T>, vec<N, T>>;
    using type::type;

    KTM_MATRIX_COMPONENT_ELEMENT(vector, 0)
    KTM_MATRIX_COMPONENT_ELEMENT(value, 1)
};

template <class M>
struct svd_component;

template <size_t Row, size_t Col, typename T>
struct svd_component<mat<Row, Col, T>> : std::tuple<mat<Col, Col, T>, vec<(Row < Col) ? Row : Col, T>, mat<Row, Row, T>>
{
    using type = std::tuple<mat<Col, Col, T>, vec<(Row < Col) ? Row : Col, T>, mat<Row, Row, T>>;
    using type::type;

    KTM_MATRIX_COMPONENT_ELEMENT(u, 0)
    KTM_MATRIX_COMPONENT_ELEMENT(s, 1)
    KTM_MATRIX_COMPONENT_ELEMENT(vt, 2)
};

template <class M>
struct affine_component;

template <size_t N, typename T>
struct affine_component<mat<N, N, T>> : std::tuple<mat<N, N, T>, mat<N, N, T>, mat<N, N, T>, mat<N, N, T>>
{
    using type = std::tuple<mat<N, N, T>, mat<N, N, T>, mat<N, N, T>, mat<N, N, T>>;
    using type::type;

    KTM_MATRIX_COMPONENT_ELEMENT(translate, 0)
    KTM_MATRIX_COMPONENT_ELEMENT(rotate, 1)
    KTM_MATRIX_COMPONENT_ELEMENT(shear, 2)
    KTM_MATRIX_COMPONENT_ELEMENT(scale, 3)
};

#undef KTM_MATRIX_COMPONENT_ELEMENT

} // namespace ktm

#endif