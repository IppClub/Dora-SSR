//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_ARRAY_H_
#define _KTM_I_ARRAY_H_

#include <array>
#include <cstring>
#include <iostream>
#include "../../setup.h"

namespace ktm
{

template<class Father, class Child>
struct iarray : Father
{
    using Father::Father;
    using typename Father::array_type;

#if defined(KTM_DEFAULT_CONSTRUCT_INIT)
    KTM_FUNC iarray() noexcept { fill(typename array_type::value_type { }); }
#endif
    KTM_FUNC iarray(std::initializer_list<typename array_type::value_type> li) noexcept
    {
        const size_t offset = li.size() < size() ? li.size() : size();
        std::copy(li.begin(), li.begin() + offset, begin());
#if defined(KTM_DEFAULT_CONSTRUCT_INIT)
        std::fill(begin() + offset, end(), typename array_type::value_type { });
#endif
    };
    KTM_FUNC iarray(const iarray& copy) noexcept { std::memcpy(data(), copy.data(), sizeof(array_type)); }
    KTM_FUNC iarray(iarray&& copy) noexcept { std::memmove(data(), copy.data(), sizeof(array_type)); };
    KTM_FUNC iarray& operator=(const iarray& copy) noexcept { std::memcpy(data(), copy.data(), sizeof(array_type)); return *this; }
    KTM_FUNC iarray& operator=(iarray&& copy) noexcept { std::memmove(data(), copy.data(), sizeof(array_type)); return *this; }

    template<size_t Index> 
    KTM_FUNC typename array_type::value_type get() const noexcept 
    { 
        static_assert(Index < size());
        return reinterpret_cast<typename array_type::const_pointer>(this)[Index]; 
    }
    template<size_t Index> 
    KTM_FUNC void set(typename array_type::const_reference v) noexcept 
    { 
        static_assert(Index < size());
        reinterpret_cast<typename array_type::pointer>(this)[Index] = v; 
    }

    KTM_FUNC array_type& to_array() noexcept { return reinterpret_cast<array_type&>(*this); }
    KTM_FUNC const array_type& to_array() const noexcept { return reinterpret_cast<const array_type&>(*this); }

    KTM_FUNC void fill(typename array_type::const_reference v) noexcept { to_array().fill(v); };
    KTM_FUNC void swap(Child& other) noexcept { to_array().swap(other.to_array()); }

    KTM_FUNC typename array_type::iterator begin() noexcept { return to_array().begin(); }
    KTM_FUNC typename array_type::const_iterator begin() const noexcept { return to_array().begin(); }
    KTM_FUNC typename array_type::iterator end() noexcept { return to_array().end(); }
    KTM_FUNC typename array_type::const_iterator end() const noexcept { return to_array().end(); }

    KTM_FUNC typename array_type::reverse_iterator rbegin() noexcept { return to_array().rbegin(); }
    KTM_FUNC typename array_type::const_reverse_iterator rbegin() const noexcept { return to_array().rbegin(); }
    KTM_FUNC typename array_type::reverse_iterator rend() noexcept { return to_array().rend(); }
    KTM_FUNC typename array_type::const_reverse_iterator rend() const noexcept { return to_array().rend(); }

    KTM_FUNC typename array_type::const_iterator cbegin() const noexcept { return begin(); }
    KTM_FUNC typename array_type::const_iterator cend() const noexcept { return end(); }
    KTM_FUNC typename array_type::const_reverse_iterator crbegin() const noexcept { return rbegin(); }
    KTM_FUNC typename array_type::const_reverse_iterator crend() const noexcept { return rend(); }

    constexpr KTM_FUNC size_t size() const noexcept { return to_array().size(); }
    constexpr KTM_FUNC size_t max_size() const noexcept { return to_array().max_size(); }
    constexpr KTM_FUNC bool empty() const noexcept { return false; }

    KTM_FUNC typename array_type::reference at(size_t i) { return to_array().at(i); }
    KTM_FUNC typename array_type::const_reference at(size_t i) const { return to_array().at(i); }
    KTM_FUNC typename array_type::reference front() noexcept { return to_array().front(); }
    KTM_FUNC typename array_type::const_reference front() const noexcept { return to_array().front(); }
    KTM_FUNC typename array_type::reference back() noexcept { return to_array().back(); }
    KTM_FUNC typename array_type::const_reference back() const noexcept { return to_array().back(); }

    KTM_FUNC typename array_type::pointer data() noexcept { return to_array().data(); }
    KTM_FUNC typename array_type::const_pointer data() const noexcept { return to_array().data(); }

    KTM_FUNC typename array_type::reference operator[](size_t i) noexcept { return to_array()[i]; }
    KTM_FUNC typename array_type::const_reference operator[](size_t i) const noexcept { return to_array()[i]; }

    friend KTM_FUNC bool operator==(const Child& x, const Child& y) { return x.to_array() == y.to_array(); }
    friend KTM_FUNC bool operator!=(const Child& x, const Child& y) { return x.to_array() != y.to_array(); }
    friend KTM_FUNC bool operator< (const Child& x, const Child& y) { return x.to_array() <  y.to_array(); }
    friend KTM_FUNC bool operator> (const Child& x, const Child& y) { return x.to_array() >  y.to_array(); }
    friend KTM_FUNC bool operator<=(const Child& x, const Child& y) { return x.to_array() <= y.to_array(); }
    friend KTM_FUNC bool operator>=(const Child& x, const Child& y) { return x.to_array() >= y.to_array(); }

    friend KTM_FUNC std::ostream& operator<<(std::ostream& o, const Child& x) noexcept 
    {
        auto it = x.begin();
        for(; it != x.end() - 1; ++it)
            o << *it << " ";
        o << *it;
        return o;
    }
    friend KTM_FUNC std::istream& operator>>(std::istream& i, const Child& x) noexcept
    {
        for(auto it = x.begin(); it != x.end(); ++it)
            i >> *it;
        return i;
    }

};

}

#endif