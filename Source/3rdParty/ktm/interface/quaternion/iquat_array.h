//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_QUAT_ARRAY_H_
#define _KTM_I_QUAT_ARRAY_H_

#include <array>
#include "../../setup.h"
#include "../../type/quat_fwd.h"

namespace ktm
{

template<class Father, class Child>
struct iquat_array;

template<class Father,typename T>
struct iquat_array<Father, quat<T>> : Father
{
    using Father::Father;
    using array_type = std::array<T, 4>;
};

}

#endif