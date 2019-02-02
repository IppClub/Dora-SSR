/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#ifndef PLAYRHO_COMMON_OPTIONALVALUE_HPP
#define PLAYRHO_COMMON_OPTIONALVALUE_HPP

#include "PlayRho/Defines.hpp"
#include <cassert>
#include <utility>

namespace playrho {
    
    /// @brief Optional value template class.
    /// @details An implementation of the optional value type idea.
    /// @note This is meant to be compatible with <code>std::optional</code> from C++ 17.
    /// @note Use of this type directly is discouraged. Use the Optional type alias instead.
    template<typename T>
    class OptionalValue
    {
    public:
        
        /// @brief Value type.
        using value_type = T;
        
        PLAYRHO_CONSTEXPR inline OptionalValue() = default;
        
        /// @brief Copy constructor.
        PLAYRHO_CONSTEXPR inline OptionalValue(const OptionalValue& other) = default;

        /// @brief Move constructor.
        PLAYRHO_CONSTEXPR inline OptionalValue(OptionalValue&& other) noexcept:
            m_value{std::move(other.m_value)}, m_set{other.m_set}
        {
            // Intentionally empty.
            // Note that the exception specification of this constructor
            //   doesn't match the defaulted one (when built with boost units).
        }

        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline explicit OptionalValue(T v);

        ~OptionalValue() = default;

        /// @brief Indirection operator.
        PLAYRHO_CONSTEXPR const T& operator* () const;

        /// @brief Indirection operator.
        PLAYRHO_CONSTEXPR inline T& operator* ();
        
        /// @brief Member of pointer operator.
        PLAYRHO_CONSTEXPR const T* operator-> () const;
        
        /// @brief Member of pointer operator.
        PLAYRHO_CONSTEXPR inline T* operator-> ();

        /// @brief Boolean operator.
        PLAYRHO_CONSTEXPR inline explicit operator bool() const noexcept;

        /// @brief Whether this optional value has a value.
        PLAYRHO_CONSTEXPR inline bool has_value() const noexcept;
        
        /// @brief Assignment operator.
        OptionalValue& operator= (const OptionalValue& other) = default;

        /// @brief Move assignment operator.
        OptionalValue& operator= (OptionalValue&& other) noexcept
        {
            // Note that the exception specification of this method
            //   doesn't match the defaulted one (when built with boost units).
            m_value = std::move(other.m_value);
            m_set = other.m_set;
            return *this;
        }

        /// @brief Assignment operator.
        OptionalValue& operator= (T v);

        /// @brief Accesses the value.
        PLAYRHO_CONSTEXPR inline T& value();

        /// @brief Accesses the value.
        PLAYRHO_CONSTEXPR const T& value() const;
        
        /// @brief Gets the value or provides the alternate given value instead.
        PLAYRHO_CONSTEXPR inline T value_or(const T& alt) const;
        
        /// @brief Resets the optional value back to its default constructed state.
        void reset() noexcept
        {
            m_value = value_type{};
            m_set = false;
        }
        
    private:
        value_type m_value = value_type{}; ///< Underlying value.
        bool m_set = false; ///< Whether <code>m_value</code> is set.
    };
    
    template<typename T>
    PLAYRHO_CONSTEXPR inline OptionalValue<T>::OptionalValue(T v): m_value{v}, m_set{true} {}
    
    template<typename T>
    PLAYRHO_CONSTEXPR inline bool OptionalValue<T>::has_value() const noexcept
    {
        return m_set;
    }
    
    template<typename T>
    PLAYRHO_CONSTEXPR inline OptionalValue<T>::operator bool() const noexcept
    {
        return m_set;
    }
    
    template<typename T>
    OptionalValue<T>& OptionalValue<T>::operator=(T v)
    {
        m_value = v;
        m_set = true;
        return *this;
    }
    
    template<typename T>
    PLAYRHO_CONSTEXPR const T* OptionalValue<T>::operator->() const
    {
        assert(m_set);
        return &m_value;
    }
    
    template<typename T>
    PLAYRHO_CONSTEXPR inline T* OptionalValue<T>::operator->()
    {
        assert(m_set);
        return &m_value;
    }

    template<typename T>
    PLAYRHO_CONSTEXPR const T& OptionalValue<T>::operator*() const
    {
        assert(m_set);
        return m_value;
    }
    
    template<typename T>
    PLAYRHO_CONSTEXPR inline T& OptionalValue<T>::operator*()
    {
        assert(m_set);
        return m_value;
    }

    template<typename T>
    PLAYRHO_CONSTEXPR inline T& OptionalValue<T>::value()
    {
        return m_value;
    }
    
    template<typename T>
    PLAYRHO_CONSTEXPR const T& OptionalValue<T>::value() const
    {
        return m_value;
    }

    template<typename T>
    PLAYRHO_CONSTEXPR inline T OptionalValue<T>::value_or(const T& alt) const
    {
        return m_set? m_value: alt;
    }
    
    /// @brief Optional type alias.
    /// @details An alias setup to facilitate switching between implementations of the
    ///   optional type idea.
    /// @note This is meant to be used directly for optional values.
    template <typename T>
    using Optional = OptionalValue<T>;
    
} // namespace playrho

#endif // PLAYRHO_COMMON_OPTIONALVALUE_HPP
