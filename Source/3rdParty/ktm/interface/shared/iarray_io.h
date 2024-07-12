//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_ARRAY_IO_H_
#define _KTM_I_ARRAY_IO_H_

#include <iostream>
#include "../../setup.h"
#include "../../traits/type_single_extends.h"

namespace ktm
{

template<class Father, class Child>
struct iarray_io : Father
{
    using Father::Father;
    using Father::child_ptr;

    friend KTM_FUNC std::ostream& operator<<(std::ostream& out, const Child& x) noexcept { return x.std_out(out); }
    friend KTM_FUNC std::istream& operator>>(std::istream& in, Child& x) noexcept { return x.std_in(in); }
private:
    KTM_FUNC std::ostream& std_out(std::ostream& o) const noexcept
    {
        if constexpr(KTM_CRTP_CHILD_IMPL_VALUE(Child, std_out_impl))
            return child_ptr()->std_out_impl(o);
        else
        {
            auto it = child_ptr()->begin();
            for(; it != child_ptr()->end() - 1; ++it)
                o << *it << " ";
            o << *it;
            return o;
        }
    }

    KTM_FUNC std::istream& std_in(std::istream& i) noexcept
    {
        if constexpr(KTM_CRTP_CHILD_IMPL_VALUE(Child, std_in_impl))
            return child_ptr()->std_in_impl(i);
        else
        {
            for(auto it = child_ptr()->begin(); it != child_ptr()->end(); ++it)
                i >> *it;
            return i;
        }
    }

    KTM_CRTP_CHILD_IMPL_CHECK(std_out, std_out_impl)
    KTM_CRTP_CHILD_IMPL_CHECK(std_in, std_in_impl)
};

}

#endif