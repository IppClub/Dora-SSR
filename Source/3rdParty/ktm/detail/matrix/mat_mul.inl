//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MAT_MUL_INL_
#define _KTM_MAT_MUL_INL_

#include "mat_mul_fwd.h"
#include "../loop_util.h"
#include "../../function/common.h"

template <size_t Row, size_t Col, typename T>
KTM_INLINE void ktm::detail::mat_mul_implement::mat_mul_vec(vec<Col, T>& out, const mat<Row, Col, T>& m,
                                                            const vec<Row, T>& v) noexcept
{
    out = m[0] * v[0];
    loop_op<Row - 1, void>::call([&out](const vec<Col, T>& m_col, const T& v_val) -> void
    { ktm_op_smadd(out, m_col, v_val); }, &m[1], &v[1]);
}

template <size_t Row, size_t Col, typename T>
KTM_INLINE void ktm::detail::mat_mul_implement::vec_mul_mat(vec<Row, T>& out, const vec<Col, T>& v,
                                                            const mat<Row, Col, T>& m) noexcept
{
    loop_op<Row, vec<Row, T>>::call(out, [&v](const vec<Col, T>& m_col) -> T { return ktm::reduce_add(m_col * v); }, m);
}

template <size_t U, size_t Row, size_t Col, typename T>
KTM_INLINE void ktm::detail::mat_mul_implement::mat_mul_mat(mat<U, Col, T>& out, const mat<Row, Col, T>& m1,
                                                            const mat<U, Row, T>& m2) noexcept
{
    loop_op<U, void>::call([&m1](vec<Col, T>& out_col, const vec<Row, T>& m2_col) -> void
    { mat_mul_vec(out_col, m1, m2_col); }, out, m2);
}

#endif
