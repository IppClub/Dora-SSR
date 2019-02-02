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

#ifndef PLAYRHO_COMMON_BOUNDEDVALUE_HPP
#define PLAYRHO_COMMON_BOUNDEDVALUE_HPP

#include "PlayRho/Common/InvalidArgument.hpp"
#include "PlayRho/Common/Templates.hpp"

#include <limits>
#include <type_traits>
#include <iostream>
#include <utility>

namespace playrho {
    
    /// @brief Lo value check.
    enum class LoValueCheck
    {
        Any,
        AboveZero,
        ZeroOrMore,
        AboveNegInf,
        NonZero
    };

    /// @brief Hi value check.
    enum class HiValueCheck
    {
        Any,
        BelowZero,
    	ZeroOrLess,
        OneOrLess,
        BelowPosInf
    };

    /// @brief Value check helper.
    template <typename T, class Enable = void>
    struct ValueCheckHelper
    {
        /// @brief Has one.
        static PLAYRHO_CONSTEXPR const bool has_one = false;
        
        /// @brief Gets the "one" value.
        static PLAYRHO_CONSTEXPR inline T one() noexcept { return T{0}; }
    };

    template<class T, class = void>
    struct HasOne: std::false_type {};
    
    /// @brief Template specialization for valid/acceptable "arithmetic" types.
    template<class T>
    struct HasOne<T, detail::VoidT<decltype(T{1}) > >: std::true_type {};

    /// @brief Specialization of the value check helper.
    template <typename T>
    struct ValueCheckHelper<T, std::enable_if_t<HasOne<T>::value>>
    {
        /// @brief Has one.
        static PLAYRHO_CONSTEXPR const bool has_one = true;

        /// @brief Gets the "one" value.
        static PLAYRHO_CONSTEXPR inline T one() noexcept { return T{1}; }
    };

    /// @brief Checks if the given value is above negative infinity.
    template <typename T>
    PLAYRHO_CONSTEXPR inline std::enable_if_t<std::numeric_limits<T>::has_infinity, void>
    CheckIfAboveNegInf(T value)
    {
        if (!(value > -std::numeric_limits<T>::infinity()))
        {
            throw InvalidArgument{"BoundedValue: value not > -inf"};;
        }
    }
    
    /// @brief Checks if the given value is above negative infinity.
    template <typename T>
    PLAYRHO_CONSTEXPR inline std::enable_if_t<!std::numeric_limits<T>::has_infinity, void>
    CheckIfAboveNegInf(T /*value*/)
    {
        // Intentionally empty.
    }

    /// @brief Checks that the given value is below positive infinity.
    template <typename T>
    PLAYRHO_CONSTEXPR inline std::enable_if_t<std::numeric_limits<T>::has_infinity, void>
    CheckIfBelowPosInf(T value)
    {
        if (!(value < +std::numeric_limits<T>::infinity()))
        {
            throw InvalidArgument{"BoundedValue: value not < +inf"};;
        }
    }

    /// @brief Checks that the given value is below positive infinity.
    template <typename T>
    PLAYRHO_CONSTEXPR inline std::enable_if_t<!std::numeric_limits<T>::has_infinity, void>
    CheckIfBelowPosInf(T /*value*/)
    {
        // Intentionally empty.
    }

    /// @brief Bounded value.
    /// @note While this works well enough for use in the PlayRho library, I'm not keen on
    ///   its current implementation.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    class BoundedValue
    {
    public:
        /// @brief Value type.
        using value_type = T;

        /// @brief Remove pointer type.
        using remove_pointer_type = typename std::remove_pointer<T>::type;
        
        /// @brief Exception type.
        using exception_type = InvalidArgument;
        
        /// @brief This type.
        using this_type = BoundedValue<value_type, lo, hi>;

        /// @brief Gets the lo check.
        static PLAYRHO_CONSTEXPR inline LoValueCheck GetLoCheck() { return lo; }

        /// @brief Gets the hi check.
        static PLAYRHO_CONSTEXPR inline HiValueCheck GetHiCheck() { return hi; }

        /// @brief Performs the lo check.
        static PLAYRHO_CONSTEXPR inline void DoLoCheck(value_type value)
        {
            switch (GetLoCheck())
            {
                case LoValueCheck::Any:
                    return;
                case LoValueCheck::AboveZero:
                    if (!(value > value_type{0}))
                    {
                        throw exception_type{"BoundedValue: value not > 0"};
                    }
                    return;
                case LoValueCheck::ZeroOrMore:
                    if (!(value >= value_type{0}))
                    {
                        throw exception_type{"BoundedValue: value not >= 0"};
                    }
                    return;
                case LoValueCheck::AboveNegInf:
                    CheckIfAboveNegInf<T>(value);
                    return;
                case LoValueCheck::NonZero:
                    if (value == static_cast<value_type>(0))
                    {
                        throw exception_type{"BoundedValue: value may not be 0"};
                    }
                    return;
            }
        }
        
        /// @brief Performs the hi check.
        static PLAYRHO_CONSTEXPR inline void DoHiCheck(value_type value)
        {
            switch (GetHiCheck())
            {
                case HiValueCheck::Any:
                    return;
                case HiValueCheck::BelowZero:
                    if (!(value < value_type{0}))
                    {
                        throw exception_type{"BoundedValue: value not < 0"};
                    }
                    return;
                case HiValueCheck::ZeroOrLess:
                    if (!(value <= value_type{0}))
                    {
                        throw exception_type{"BoundedValue: value not <= 0"};
                    }
                    return;
                case HiValueCheck::OneOrLess:
                    if (!ValueCheckHelper<value_type>::has_one)
                    {
                        throw exception_type{"BoundedValue: value's type does not have trivial 1"};
                    }
                    if (!(value <= ValueCheckHelper<value_type>::one()))
                    {
                        throw exception_type{"BoundedValue: value not <= 1"};
                    }
                    return;
                case HiValueCheck::BelowPosInf:
                    CheckIfBelowPosInf(value);
                    return;
            }
        }

        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline BoundedValue(value_type value): m_value{value}
        {
            DoLoCheck(value);
            DoHiCheck(value);
        }

        /// @brief Initializing constructor for implicitly convertible types.
        template <typename U>
        PLAYRHO_CONSTEXPR inline BoundedValue(U value): m_value{value_type(value)}
        {
            DoLoCheck(value_type(value));
            DoHiCheck(value_type(value));
        }

        /// @brief Copy constructor.
        PLAYRHO_CONSTEXPR inline BoundedValue(const this_type& value) = default;

        /// @brief Move constructor.
        PLAYRHO_CONSTEXPR inline BoundedValue(this_type&& value) noexcept:
            m_value{std::move(value.m_value)}
        {
            // Intentionally empty.
            // Note that the exception specification of this constructor
            //   doesn't match the defaulted one (when built with boost units).
        }

        ~BoundedValue() noexcept = default;

        /// @brief Assignment operator.
        PLAYRHO_CONSTEXPR inline BoundedValue& operator= (const this_type& other) noexcept
        {
            m_value = other.m_value;
            return *this;
        }

        /// @brief Assignment operator.
        PLAYRHO_CONSTEXPR inline BoundedValue& operator= (const T& value)
        {
            DoLoCheck(value);
            DoHiCheck(value);
            m_value = value;
            return *this;
        }

        /// @brief Assignment operator for implicitly convertible types.
        template <typename U>
        PLAYRHO_CONSTEXPR inline std::enable_if_t<std::is_convertible<U, T>::value, BoundedValue&>
        operator= (const U& tmpVal)
        {
            const auto value = T(tmpVal);
            DoLoCheck(value);
            DoHiCheck(value);
            m_value = value;
            return *this;
        }

        /// @brief Move assignment operator.
        PLAYRHO_CONSTEXPR inline BoundedValue& operator= (this_type&& value) noexcept
        {
            // Note that the exception specification of this method
            //   doesn't match the defaulted one (when built with boost units).
            m_value = std::move(value.m_value);
            return *this;
        }

        /// @brief Gets the underlying value.
        PLAYRHO_CONSTEXPR inline value_type get() const noexcept
        {
            return m_value;
        }

        /// @brief Gets the underlying value.
        PLAYRHO_CONSTEXPR inline operator value_type () const noexcept
        {
            return m_value;
        }

        /// @brief Member of pointer operator.
        template <typename U = T>
        PLAYRHO_CONSTEXPR inline std::enable_if_t<std::is_pointer<U>::value, U> operator-> () const
        {
            return m_value;
        }

        /// @brief Indirection operator.
        template <typename U = T>
        PLAYRHO_CONSTEXPR inline std::enable_if_t<std::is_pointer<U>::value, remove_pointer_type>&
        operator* () const
        {
            return *m_value;
        }

    private:
        value_type m_value; ///< Underlying value.
    };
    
    // Common logical operations for BoundedValue<T, lo, hi> OP BoundedValue<T, lo, hi>

    /// @brief Bounded value equality operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator== (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} == T{rhs};
    }
    
    /// @brief Bounded value inequality operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator!= (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} != T{rhs};
    }

    // Logical operations for numerical BoundedValue<T, lo, hi> OP BoundedValue<T, lo, hi>

    /// @brief Bounded value less-than or equal-to operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator<= (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} <= T{rhs};
    }
    
    /// @brief Bounded value greater-than or equal-to operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator>= (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} >= T{rhs};
    }
    
    /// @brief Bounded value less-than operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator< (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} < T{rhs};
    }
    
    /// @brief Bounded value greater-than operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator> (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} > T{rhs};
    }
    
    /// @brief Bounded value multiplication operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator* (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} * T{rhs};
    }
    
    /// @brief Bounded value division operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator/ (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} / T{rhs};
    }
    
    /// @brief Bounded value addition operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator+ (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} + T{rhs};
    }
    
    /// @brief Bounded value subtraction operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator- (const BoundedValue<T, lo, hi> lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return T{lhs} - T{rhs};
    }

    // Commmon logical operations for BoundedValue<T, lo, hi> OP T

    /// @brief Bounded value equality operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator== (const BoundedValue<T, lo, hi> lhs, const T rhs)
    {
        return T{lhs} == rhs;
    }
    
    /// @brief Bounded value inequality operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator!= (const BoundedValue<T, lo, hi> lhs, const T rhs)
    {
        return T{lhs} != rhs;
    }
    
    // Logical operations for numerical BoundedValue<T, lo, hi> OP T

    /// @brief Bounded value less-than or equal-to operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator<= (const BoundedValue<T, lo, hi> lhs, const T rhs)
    {
        return T{lhs} <= rhs;
    }
    
    /// @brief Bounded value greater-than or equal-to operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator>= (const BoundedValue<T, lo, hi> lhs, const T rhs)
    {
        return T{lhs} >= rhs;
    }
    
    /// @brief Bounded value less-than operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator< (const BoundedValue<T, lo, hi> lhs, const T rhs)
    {
        return T{lhs} < rhs;
    }
    
    /// @brief Bounded value greater-than operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator> (const BoundedValue<T, lo, hi> lhs, const T rhs)
    {
        return T{lhs} > rhs;
    }
    
    /// @brief Bounded value multiplication operator.
    template <typename T, typename U, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator* (const BoundedValue<T, lo, hi> lhs, const U rhs)
    {
        return T{lhs} * rhs;
    }
    
    /// @brief Bounded value division operator.
    template <typename T, typename U, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator/ (const BoundedValue<T, lo, hi> lhs, const U rhs)
    {
        return T{lhs} / rhs;
    }
    
    /// @brief Bounded value addition operator.
    template <typename T, typename U, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator+ (const BoundedValue<T, lo, hi> lhs, const U rhs)
    {
        return T{lhs} + rhs;
    }
    
    /// @brief Bounded value subtraction operator.
    template <typename T, typename U, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator- (const BoundedValue<T, lo, hi> lhs, const U rhs)
    {
        return T{lhs} - T{rhs};
    }

    // Commmon logical operations for T OP BoundedValue<T, lo, hi>

    /// @brief Bounded value equality operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator== (const T lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs == T{rhs};
    }
    
    /// @brief Bounded value inequality operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator!= (const T lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs != T{rhs};
    }
    
    // Logical operations for numerical T OP BoundedValue<T, lo, hi>

    /// @brief Bounded value less-than or equal-to operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator<= (const T lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs <= T{rhs};
    }
    
    /// @brief Bounded value greater-than or equal-to operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator>= (const T lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs >= T{rhs};
    }
    
    /// @brief Bounded value less-than operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator< (const T lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs < T{rhs};
    }
    
    /// @brief Bounded value greater-than operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline bool operator> (const T lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs > T{rhs};
    }
    
    /// @brief Bounded value multiplication operator.
    template <typename T, typename U, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator* (const U lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs * T{rhs};
    }
    
    /// @brief Bounded value division operator.
    template <typename T, typename U, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator/ (const U lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs / T{rhs};
    }
    
    /// @brief Bounded value addition operator.
    template <typename T, typename U, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator+ (const U lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs + T{rhs};
    }
    
    /// @brief Bounded value subtraction operator.
    template <typename T, typename U, LoValueCheck lo, HiValueCheck hi>
    PLAYRHO_CONSTEXPR inline auto operator- (const U lhs, const BoundedValue<T, lo, hi> rhs)
    {
        return lhs - T{rhs};
    }

    // Unary operations for BoundedValue<T, lo, hi>
    
    // Common useful aliases...

    /// @defgroup BoundedAliases Bounded Value Types
    /// @brief Types for bounding values.
    /// @details Type aliases for bounding values via on-construction checks that
    ///   throw the <code>InvalidArgument</code> exception if an attempt is made
    ///   to construct the bounded value type with a value not allowed by the specific
    ///   alias.
    /// @sa BoundedValue, InvalidArgument
    /// @{
    
    /// @brief Non negative bounded value type.
    template <typename T>
    using NonNegative = std::enable_if_t<!std::is_pointer<T>::value,
        BoundedValue<T, LoValueCheck::ZeroOrMore, HiValueCheck::Any>>;

    /// @brief Non positive bounded value type.
    template <typename T>
    using NonPositive = BoundedValue<T, LoValueCheck::Any, HiValueCheck::ZeroOrLess>;

    /// @brief Positive bounded value type.
    template <typename T>
    using Positive = BoundedValue<T, LoValueCheck::AboveZero, HiValueCheck::Any>;

    /// @brief Negative bounded value type.
    template <typename T>
    using Negative = BoundedValue<T, LoValueCheck::Any, HiValueCheck::BelowZero>;

    /// @brief Finite bounded value type.
    template <typename T>
    using Finite = BoundedValue<T, LoValueCheck::AboveNegInf, HiValueCheck::BelowPosInf>;
    
    /// @brief Non zero bounded value type.
    template <typename T>
    using NonZero = std::enable_if_t<!std::is_pointer<T>::value,
        BoundedValue<T, LoValueCheck::NonZero, HiValueCheck::Any>>;

    /// @brief Non-null pointer type.
    /// @note Clang will error with "no type named 'type'" if used to bound a non-pointer.
    template <typename T>
    using NonNull = std::enable_if_t<std::is_pointer<T>::value,
        BoundedValue<T, LoValueCheck::NonZero, HiValueCheck::Any>>;
    
    /// @brief Unit interval bounded value type.
    template <typename T>
    using UnitInterval = BoundedValue<T, LoValueCheck::ZeroOrMore, HiValueCheck::OneOrLess>;
    
    /// @}
 
    /// @brief Bounded value stream output operator.
    template <typename T, LoValueCheck lo, HiValueCheck hi>
    ::std::ostream& operator<<(::std::ostream& os, const BoundedValue<T, lo, hi>& value)
    {
        return os << T{value};
    }

} // namespace playrho

#endif // PLAYRHO_COMMON_BOUNDEDVALUE_HPP
