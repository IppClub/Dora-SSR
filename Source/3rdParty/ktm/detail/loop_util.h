//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_LOOP_UTIL_H_
#define _KTM_LOOP_UTIL_H_

#include <utility>
#include <functional>
#include "../setup.h"

namespace ktm
{
namespace detail
{

template <size_t LoopN, typename T>
struct loop_op
{
    template <typename OP, typename... As>
    static KTM_FUNC void call(T& out, OP&& op, As&&... ls)
    {
        if constexpr (LoopN <= 4)
            call(out, std::forward<OP>(op), std::make_index_sequence<LoopN>(), std::forward<As>(ls)...);
        else
            call(out, std::forward<OP>(op), LoopN, std::forward<As>(ls)...);
    }

private:
    template <typename OP, typename... As, size_t... Ns>
    static KTM_FUNC void call(T& out, OP&& op, std::index_sequence<Ns...>, As&&... ls)
    {
        constexpr auto apply_lambda = [](T& out, OP&& op, As&&... ls, size_t index) -> void
        {
            out[index] = op(ls[index]...);
        };
        (apply_lambda(out, std::forward<OP>(op), std::forward<As>(ls)..., Ns), ...);
    }

    template <typename OP, typename... As>
    static KTM_FUNC void call(T& out, OP&& op, size_t loop, As&&... ls)
    {
        for (int i = 0; i < loop; ++i)
            out[i] = op(ls[i]...);
    }
};

template <size_t LoopN>
struct loop_op<LoopN, void>
{
    template <typename OP, typename... As>
    static KTM_FUNC void call(OP&& op, As&&... ls)
    {
        if constexpr (LoopN <= 4)
            call(std::forward<OP>(op), std::make_index_sequence<LoopN>(), std::forward<As>(ls)...);
        else
            call(std::forward<OP>(op), LoopN, std::forward<As>(ls)...);
    }

private:
    template <typename OP, typename... As, size_t... Ns>
    static KTM_FUNC void call(OP&& op, std::index_sequence<Ns...>, As&&... ls)
    {
        constexpr auto apply_lambda = [](OP&& op, As&&... ls, size_t index) -> void
        {
            op(ls[index]...);
        };
        (apply_lambda(std::forward<OP>(op), std::forward<As>(ls)..., Ns), ...);
    }

    template <typename OP, typename... As>
    static KTM_FUNC void call(OP&& op, size_t loop, As&&... ls)
    {
        for (int i = 0; i < loop; ++i)
            op(ls[i]...);
    }
};

} // namespace detail
} // namespace ktm

#endif