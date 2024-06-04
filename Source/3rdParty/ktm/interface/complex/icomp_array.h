//  MIT License
//
//  Copyright (c) 2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_COMP_ARRAY_H_
#define _KTM_I_COMP_ARRAY_H_

#include <array>
#include "../../setup.h"
#include "../../type/comp_fwd.h"

namespace ktm
{

template<class Father, class Child>
struct icomp_array;

template<class Father,typename T>
struct icomp_array<Father, comp<T>> : Father
{
    using Father::Father;
    using array_type = std::array<T, 2>;
};

}

#endif