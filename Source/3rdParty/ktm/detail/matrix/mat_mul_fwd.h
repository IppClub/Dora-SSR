//  MIT License
//
//  Copyright (c) 2023-2026 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MAT_MUL_FWD_H_
#define _KTM_MAT_MUL_FWD_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"

namespace ktm
{
namespace detail
{
namespace mat_mul_implement
{

template <size_t Row, size_t Col, typename T>
KTM_CORE_FUNC void mat_mul_vec(vec<Col, T>& out, const mat<Row, Col, T>& m, const vec<Row, T>& v) noexcept;

template <size_t Row, size_t Col, typename T>
KTM_CORE_FUNC void vec_mul_mat(vec<Row, T>& out, const vec<Col, T>& v, const mat<Row, Col, T>& m) noexcept;

template <size_t U, size_t Row, size_t Col, typename T>
KTM_CORE_FUNC void mat_mul_mat(mat<U, Col, T>& out, const mat<Row, Col, T>& m1, const mat<U, Row, T>& m2) noexcept;

} // namespace mat_mul_implement
} // namespace detail
} // namespace ktm

#endif
