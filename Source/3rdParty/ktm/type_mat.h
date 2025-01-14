//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TYPE_MAT_H_
#define _KTM_TYPE_MAT_H_

#include "type/mat.h"

namespace ktm
{

template <size_t Row, size_t Col>
using fmat = mat<Row, Col, float>;
using fmat2x2 = fmat<2, 2>;
using fmat2x3 = fmat<2, 3>;
using fmat2x4 = fmat<2, 4>;
using fmat3x2 = fmat<3, 2>;
using fmat3x3 = fmat<3, 3>;
using fmat3x4 = fmat<3, 4>;
using fmat4x2 = fmat<4, 2>;
using fmat4x3 = fmat<4, 3>;
using fmat4x4 = fmat<4, 4>;

template <size_t Row, size_t Col>
using smat = mat<Row, Col, int>;
using smat2x2 = smat<2, 2>;
using smat2x3 = smat<2, 3>;
using smat2x4 = smat<2, 4>;
using smat3x2 = smat<3, 2>;
using smat3x3 = smat<3, 3>;
using smat3x4 = smat<3, 4>;
using smat4x2 = smat<4, 2>;
using smat4x3 = smat<4, 3>;
using smat4x4 = smat<4, 4>;

template <size_t Row, size_t Col>
using umat = mat<Row, Col, unsigned int>;
using umat2x2 = umat<2, 2>;
using umat2x3 = umat<2, 3>;
using umat2x4 = umat<2, 4>;
using umat3x2 = umat<3, 2>;
using umat3x3 = umat<3, 3>;
using umat3x4 = umat<3, 4>;
using umat4x2 = umat<4, 2>;
using umat4x3 = umat<4, 3>;
using umat4x4 = umat<4, 4>;

template <size_t Row, size_t Col>
using dmat = mat<Row, Col, double>;
using dmat2x2 = dmat<2, 2>;
using dmat2x3 = dmat<2, 3>;
using dmat2x4 = dmat<2, 4>;
using dmat3x2 = dmat<3, 2>;
using dmat3x3 = dmat<3, 3>;
using dmat3x4 = dmat<3, 4>;
using dmat4x2 = dmat<4, 2>;
using dmat4x3 = dmat<4, 3>;
using dmat4x4 = dmat<4, 4>;

} // namespace ktm

#endif