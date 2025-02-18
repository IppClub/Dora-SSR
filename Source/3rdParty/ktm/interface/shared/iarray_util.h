//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_ARRAY_UTIL_H_
#define _KTM_I_ARRAY_UTIL_H_

#include <tuple>
#include "../../setup.h"
#include "../../traits/type_traits_ext.h"

namespace ktm
{

template <class Father, class Child>
struct iarray_util : Father
{
    using Father::child_ptr;
    using Father::Father;

    KTM_FUNC auto& to_array() noexcept { return child_ptr()->to_array_impl(); }

    KTM_FUNC const auto& to_array() const noexcept { return child_ptr()->to_array_impl(); }

    KTM_FUNC auto begin() noexcept { return to_array().begin(); }

    KTM_FUNC const auto begin() const noexcept { return to_array().begin(); }

    KTM_FUNC auto end() noexcept { return to_array().end(); }

    KTM_FUNC const auto end() const noexcept { return to_array().end(); }

    KTM_FUNC auto rbegin() noexcept { return to_array().rbegin(); }

    KTM_FUNC const auto rbegin() const noexcept { return to_array().rbegin(); }

    KTM_FUNC auto rend() noexcept { return to_array().rend(); }

    KTM_FUNC const auto rend() const noexcept { return to_array().rend(); }

    KTM_FUNC const auto cbegin() const noexcept { return begin(); }

    KTM_FUNC const auto cend() const noexcept { return end(); }

    KTM_FUNC const auto crbegin() const noexcept { return rbegin(); }

    KTM_FUNC const auto crend() const noexcept { return rend(); }

    KTM_FUNC constexpr size_t size() const noexcept { return std::tuple_size_v<std::decay_t<decltype(to_array())>>; }

    KTM_FUNC constexpr size_t max_size() const noexcept { return size(); }

    KTM_FUNC constexpr bool empty() const noexcept { return false; }

    KTM_FUNC auto& at(size_t i) { return to_array().at(i); }

    KTM_FUNC const auto& at(size_t i) const { return to_array().at(i); }

    KTM_FUNC auto& front() noexcept { return to_array().front(); }

    KTM_FUNC const auto& front() const noexcept { return to_array().front(); }

    KTM_FUNC auto& back() noexcept { return to_array().back(); }

    KTM_FUNC const auto& back() const noexcept { return to_array().back(); }

    KTM_FUNC auto data() noexcept { return to_array().data(); }

    KTM_FUNC const auto data() const noexcept { return to_array().data(); }

    KTM_FUNC auto& operator[](size_t i) noexcept { return to_array()[i]; }

    KTM_FUNC const auto& operator[](size_t i) const noexcept { return to_array()[i]; }

    friend KTM_FUNC bool operator==(const Child& x, const Child& y) noexcept { return x.to_array() == y.to_array(); }

    friend KTM_FUNC bool operator!=(const Child& x, const Child& y) noexcept { return x.to_array() != y.to_array(); }

    friend KTM_FUNC bool operator<(const Child& x, const Child& y) noexcept { return x.to_array() < y.to_array(); }

    friend KTM_FUNC bool operator>(const Child& x, const Child& y) noexcept { return x.to_array() > y.to_array(); }

    friend KTM_FUNC bool operator<=(const Child& x, const Child& y) noexcept { return x.to_array() <= y.to_array(); }

    friend KTM_FUNC bool operator>=(const Child& x, const Child& y) noexcept { return x.to_array() >= y.to_array(); }
};

} // namespace ktm

#endif