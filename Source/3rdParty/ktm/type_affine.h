//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TYPE_AFFINE_H_
#define _KTM_TYPE_AFFINE_H_

#include "type/affine2d.h"
#include "type/affine3d.h"

namespace ktm
{

using faffine2d = affine2d<float>;
using daffine2d = affine2d<double>;

using faffine3d = affine3d<float>;
using daffine3d = affine3d<double>;

} // namespace ktm

#endif