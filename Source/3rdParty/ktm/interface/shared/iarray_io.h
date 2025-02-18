//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_ARRAY_IO_H_
#define _KTM_I_ARRAY_IO_H_

#include <iosfwd>
#include "../../setup.h"
#include "../../traits/type_single_extends.h"

namespace ktm
{

template <class Father, class Child>
struct iarray_io : Father
{
    using Father::child_ptr;
    using Father::Father;

    friend KTM_FUNC std::basic_ostream<char>& operator<<(std::basic_ostream<char>& out, const Child& x) noexcept
    {
        return x.stream_out(out);
    }

    friend KTM_FUNC std::basic_istream<char>& operator>>(std::basic_istream<char>& in, Child& x) noexcept
    {
        return x.stream_in(in);
    }

    friend KTM_FUNC std::basic_ostream<wchar_t>& operator<<(std::basic_ostream<wchar_t>& out, const Child& x) noexcept
    {
        return x.wstream_out(out);
    }

    friend KTM_FUNC std::basic_istream<wchar_t>& operator>>(std::basic_istream<wchar_t>& in, Child& x) noexcept
    {
        return x.wstream_in(in);
    }

private:
    KTM_CRTP_INTERFACE_REGISTER(stream_out, stream_out_impl)

    KTM_FUNC std::basic_ostream<char>& stream_out(std::basic_ostream<char>& o) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, stream_out_impl))
            return child_ptr()->stream_out_impl(o);
        else
            return stream_out_default<char>(o);
    }

    KTM_CRTP_INTERFACE_REGISTER(stream_in, stream_in_impl)

    KTM_FUNC std::basic_istream<char>& stream_in(std::basic_istream<char>& i) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, stream_in_impl))
            return child_ptr()->stream_in_impl(i);
        else
            return stream_in_default<char>(i);
    }

    KTM_CRTP_INTERFACE_REGISTER(wstream_out, wstream_out_impl)

    KTM_FUNC std::basic_ostream<wchar_t>& wstream_out(std::basic_ostream<wchar_t>& o) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, wstream_out_impl))
            return child_ptr()->wstream_out_impl(o);
        else
            return stream_out_default<wchar_t>(o);
    }

    KTM_CRTP_INTERFACE_REGISTER(wstream_in, wstream_in_impl)

    KTM_FUNC std::basic_istream<wchar_t>& wstream_in(std::basic_istream<wchar_t>& i) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, wstream_in_impl))
            return child_ptr()->wstream_in_impl(i);
        else
            return stream_in_default<wchar_t>(i);
    }

    template <typename T>
    KTM_FUNC std::basic_ostream<T>& stream_out_default(std::basic_ostream<T>& o) const noexcept
    {
        auto it = child_ptr()->begin();
        for (; it != child_ptr()->end() - 1; ++it)
            o << *it << " ";
        o << *it;
        return o;
    }

    template <typename T>
    KTM_FUNC std::basic_istream<T>& stream_in_default(std::basic_istream<T>& i) noexcept
    {
        for (auto it = child_ptr()->begin(); it != child_ptr()->end(); ++it)
            i >> *it;
        return i;
    }
};

} // namespace ktm

#endif