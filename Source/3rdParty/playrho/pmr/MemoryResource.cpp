//===----------------------------------------------------------------------===//
//
// Modified work Copyright (c) Louis Langholtz https://github.com/louis-langholtz/PlayRho
//
// Modified from the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#if 1 // !defined(__has_include) || !__has_include(<memory_resource>)

#include <atomic>
#include <new>

#include "playrho/DynamicMemory.hpp"
#include "playrho/pmr/MemoryResource.hpp"

namespace playrho::pmr {

namespace impl {
namespace {

class new_delete_resource: public memory_resource {
    void *do_allocate(std::size_t bytes, std::size_t /*alignment*/) override
    {
        return Alloc(bytes);
    }

    void do_deallocate(void *p, std::size_t /*bytes*/, std::size_t /*alignment*/) override
    {
        Free(p);
    }

    bool do_is_equal(const memory_resource &other) const noexcept override
    {
        return &other == this;
    }
};

class null_memory_resource: public memory_resource {
    void *do_allocate(std::size_t, std::size_t) override
    {
        throw std::bad_alloc{};
    }

    void do_deallocate(void *, std::size_t, std::size_t) override
    {
        // Intentionally empty.
    }

    bool do_is_equal(const memory_resource &other) const noexcept override
    {
        return &other == this;
    }
};

memory_resource* default_resource(bool set = false, memory_resource* new_res = nullptr) noexcept
{
    static std::atomic<memory_resource*> resource{::playrho::pmr::new_delete_resource()};
    if (set) {
        new_res = new_res ? new_res : ::playrho::pmr::new_delete_resource();
        return std::atomic_exchange_explicit(&resource, new_res, std::memory_order_acq_rel);
    }
    return std::atomic_load_explicit(&resource, std::memory_order_acquire);
}

}
}

memory_resource::~memory_resource() = default;

memory_resource* new_delete_resource() noexcept
{
    static impl::new_delete_resource resource;
    return &resource;
}

memory_resource* null_memory_resource() noexcept
{
    static impl::null_memory_resource resource;
    return &resource;
}

memory_resource* set_default_resource(memory_resource* r) noexcept
{
    return impl::default_resource(true, r);
}

memory_resource* get_default_resource() noexcept
{
    return impl::default_resource();
}

}

#endif
