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

#ifndef PLAYRHO_COMMON_FIXED_HPP
#define PLAYRHO_COMMON_FIXED_HPP

#include "PlayRho/Common/Wider.hpp"
#include "PlayRho/Common/Templates.hpp"

#include <cstdint>
#include <limits>
#include <cassert>
#include <type_traits>
#include <iostream>

namespace playrho {

    /// @brief Template class for fixed-point numbers.
    ///
    /// @details This is a fixed point type template for a given base type using a given number
    ///   of fraction bits that satisfies the <code>LiteralType</code> concept.
    ///
    /// @sa https://en.wikipedia.org/wiki/Fixed-point_arithmetic
    /// @sa http://en.cppreference.com/w/cpp/concept/LiteralType
    ///
    template <typename BASE_TYPE, unsigned int FRACTION_BITS>
    class Fixed
    {
    public:
        
        /// @brief Value type.
        using value_type = BASE_TYPE;
        
        /// @brief Total number of bits.
        static PLAYRHO_CONSTEXPR const unsigned int TotalBits = sizeof(BASE_TYPE) * 8;

        /// @brief Fraction bits.
        static PLAYRHO_CONSTEXPR const unsigned int FractionBits = FRACTION_BITS;
        
        /// @brief Whole value bits.
        static PLAYRHO_CONSTEXPR const unsigned int WholeBits = TotalBits - FractionBits;

        /// @brief Scale factor.
        static PLAYRHO_CONSTEXPR const value_type ScaleFactor = static_cast<value_type>(1u << FractionBits);

        /// @brief Compare result enumeration.
        enum class CmpResult
        {
            Incomparable,
            Equal,
            LessThan,
            GreaterThan
        };

        /// @brief Gets the min value this type is capable of expressing.
        static PLAYRHO_CONSTEXPR inline Fixed GetMin() noexcept
        {
            return Fixed{1, scalar_type{1}};
        }
        
        /// @brief Gets an infinite value for this type.
        static PLAYRHO_CONSTEXPR inline Fixed GetInfinity() noexcept
        {
            return Fixed{numeric_limits::max(), scalar_type{1}};
        }
        
        /// @brief Gets the max value this type is capable of expressing.
        static PLAYRHO_CONSTEXPR inline Fixed GetMax() noexcept
        {
            // max reserved for +inf
            return Fixed{numeric_limits::max() - 1, scalar_type{1}};
        }

        /// @brief Gets a NaN value for this type.
        static PLAYRHO_CONSTEXPR inline Fixed GetNaN() noexcept
        {
            return Fixed{numeric_limits::lowest(), scalar_type{1}};
        }

        /// @brief Gets the negative infinity value for this type.
        static PLAYRHO_CONSTEXPR inline Fixed GetNegativeInfinity() noexcept
        {
            // lowest reserved for NaN
            return Fixed{numeric_limits::lowest() + 1, scalar_type{1}};
        }
        
        /// @brief Gets the lowest value this type is capable of expressing.
        static PLAYRHO_CONSTEXPR inline Fixed GetLowest() noexcept
        {
            // lowest reserved for NaN
            // lowest + 1 reserved for -inf
            return Fixed{numeric_limits::lowest() + 2, scalar_type{1}};
        }

        /// @brief Gets the value from a floating point value.
        template <typename T>
        static PLAYRHO_CONSTEXPR inline value_type GetFromFloat(T val) noexcept
        {
            static_assert(std::is_floating_point<T>::value, "floating point value required");
            // Note: std::isnan(val) *NOT* constant expression, so can't use here!
            return !(val <= 0 || val >= 0)? GetNaN().m_value:
                (val > static_cast<long double>(GetMax()))? GetInfinity().m_value:
                (val < static_cast<long double>(GetLowest()))? GetNegativeInfinity().m_value:
                static_cast<value_type>(val * ScaleFactor);
        }
        
        /// @brief Gets the value from a signed integral value.
        template <typename T>
        static PLAYRHO_CONSTEXPR inline value_type GetFromSignedInt(T val) noexcept
        {
            static_assert(std::is_integral<T>::value, "integral value required");
            static_assert(std::is_signed<T>::value, "must be signed");
            return (val > (GetMax().m_value / ScaleFactor))? GetInfinity().m_value:
                (val < (GetLowest().m_value / ScaleFactor))? GetNegativeInfinity().m_value:
                static_cast<value_type>(val * ScaleFactor);
        }
        
        /// @brief Gets the value from an unsigned integral value.
        template <typename T>
        static PLAYRHO_CONSTEXPR inline value_type GetFromUnsignedInt(T val) noexcept
        {
            static_assert(std::is_integral<T>::value, "integral value required");
            static_assert(!std::is_signed<T>::value, "must be unsigned");
            const auto max = static_cast<unsigned_wider_type>(GetMax().m_value / ScaleFactor);
            return (val > max)? GetInfinity().m_value: static_cast<value_type>(val) * ScaleFactor;
        }
        
        Fixed() = default;
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(long double val) noexcept:
            m_value{GetFromFloat(val)}
        {
            // Intentionally empty
        }
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(double val) noexcept:
            m_value{GetFromFloat(val)}
        {
            // Intentionally empty
        }

        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(float val) noexcept:
            m_value{GetFromFloat(val)}
        {
            // Intentionally empty
        }
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(unsigned long long val) noexcept:
            m_value{GetFromUnsignedInt(val)}
        {
            // Intentionally empty.
        }

        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(unsigned long val) noexcept:
            m_value{GetFromUnsignedInt(val)}
        {
            // Intentionally empty.
        }
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(unsigned int val) noexcept:
            m_value{GetFromUnsignedInt(val)}
        {
            // Intentionally empty.
        }

        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(long long val) noexcept:
            m_value{GetFromSignedInt(val)}
        {
            // Intentionally empty.
        }

        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(long val) noexcept:
            m_value{GetFromSignedInt(val)}
        {
            // Intentionally empty.
        }
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(int val) noexcept:
            m_value{GetFromSignedInt(val)}
        {
            // Intentionally empty.
        }
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(short val) noexcept:
            m_value{GetFromSignedInt(val)}
        {
            // Intentionally empty.
        }
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(value_type val, unsigned int fraction) noexcept:
            m_value{static_cast<value_type>(static_cast<std::uint32_t>(val * ScaleFactor) | fraction)}
        {
            // Intentionally empty.
        }
        
        /// @brief Initializing constructor.
        template <typename BT, unsigned int FB>
        PLAYRHO_CONSTEXPR inline Fixed(const Fixed<BT, FB> val) noexcept:
            Fixed(static_cast<long double>(val))
        {
            // Intentionally empty
        }
        
        // Methods
        
        /// @brief Converts the value to the expressed type.
        template <typename T>
        PLAYRHO_CONSTEXPR inline T ConvertTo() const noexcept
        {
            return isnan()? std::numeric_limits<T>::signaling_NaN():
                !isfinite()? std::numeric_limits<T>::infinity() * getsign():
                    m_value / static_cast<T>(ScaleFactor);
        }

        /// @brief Compares this value to the given one.
        PLAYRHO_CONSTEXPR inline CmpResult Compare(const Fixed other) const noexcept
        {
            if (isnan() || other.isnan())
            {
                return CmpResult::Incomparable;
            }
            if (m_value < other.m_value)
            {
                return CmpResult::LessThan;
            }
            if (m_value > other.m_value)
            {
                return CmpResult::GreaterThan;
            }
            return CmpResult::Equal;
        }

        // Unary operations

        /// @brief Long double operator.
        explicit PLAYRHO_CONSTEXPR inline operator long double() const noexcept
        {
            return ConvertTo<long double>();
        }
        
        /// @brief Double operator.
        explicit PLAYRHO_CONSTEXPR inline operator double() const noexcept
        {
            return ConvertTo<double>();
        }
        
        /// @brief Float operator.
        explicit PLAYRHO_CONSTEXPR inline operator float() const noexcept
        {
            return ConvertTo<float>();
        }
    
        /// @brief Long long operator.
        explicit PLAYRHO_CONSTEXPR inline operator long long() const noexcept
        {
            return m_value / ScaleFactor;
        }
        
        /// @brief Long operator.
        explicit PLAYRHO_CONSTEXPR inline operator long() const noexcept
        {
            return m_value / ScaleFactor;
        }

        /// @brief Unsigned long long operator.
        explicit PLAYRHO_CONSTEXPR inline operator unsigned long long() const noexcept
        {
            // Behavior is undefined if m_value is negative
            return static_cast<unsigned long long>(m_value / ScaleFactor);
        }

        /// @brief Unsigned long operator.
        explicit PLAYRHO_CONSTEXPR inline operator unsigned long() const noexcept
        {
            // Behavior is undefined if m_value is negative
            return static_cast<unsigned long>(m_value / ScaleFactor);
        }
        
        /// @brief Unsigned int operator.
        explicit PLAYRHO_CONSTEXPR inline operator unsigned int() const noexcept
        {
            // Behavior is undefined if m_value is negative
            return static_cast<unsigned int>(m_value / ScaleFactor);
        }

        /// @brief int operator.
        explicit PLAYRHO_CONSTEXPR inline operator int() const noexcept
        {
            return static_cast<int>(m_value / ScaleFactor);
        }
        
        /// @brief short operator.
        explicit PLAYRHO_CONSTEXPR inline operator short() const noexcept
        {
            return static_cast<short>(m_value / ScaleFactor);
        }
        
        /// @brief Negation operator.
        PLAYRHO_CONSTEXPR inline Fixed operator- () const noexcept
        {
            return (isnan())? *this: Fixed{-m_value, scalar_type{1}};
        }
        
        /// @brief Positive operator.
        PLAYRHO_CONSTEXPR inline Fixed operator+ () const noexcept
        {
            return *this;
        }
        
        /// @brief Boolean operator.
        explicit PLAYRHO_CONSTEXPR inline operator bool() const noexcept
        {
            return m_value != 0;
        }
        
        /// @brief Logical not operator.
        PLAYRHO_CONSTEXPR inline bool operator! () const noexcept
        {
            return m_value == 0;
        }
        
        /// @brief Addition assignment operator.
        PLAYRHO_CONSTEXPR inline Fixed& operator+= (Fixed val) noexcept
        {
            if (isnan() || val.isnan()
                || ((m_value == GetInfinity().m_value) && (val.m_value == GetNegativeInfinity().m_value))
                || ((m_value == GetNegativeInfinity().m_value) && (val.m_value == GetInfinity().m_value))
                )
            {
                *this = GetNaN();
            }
            else if (val.m_value == GetInfinity().m_value)
            {
                m_value = GetInfinity().m_value;
            }
            else if (val.m_value == GetNegativeInfinity().m_value)
            {
                m_value = GetNegativeInfinity().m_value;
            }
            else if (isfinite() && val.isfinite())
            {
                const auto result = wider_type{m_value} + val.m_value;
                if (result > GetMax().m_value)
                {
                    // overflow from max
                    m_value = GetInfinity().m_value;
                }
                else if (result < GetLowest().m_value)
                {
                    // overflow from lowest
                    m_value = GetNegativeInfinity().m_value;
                }
                else
                {
                    m_value = static_cast<value_type>(result);
                }
            }
            return *this;
        }

        /// @brief Subtraction assignment operator.
        PLAYRHO_CONSTEXPR inline Fixed& operator-= (Fixed val) noexcept
        {
            if (isnan() || val.isnan()
                || ((m_value == GetInfinity().m_value) && (val.m_value == GetInfinity().m_value))
                || ((m_value == GetNegativeInfinity().m_value) && (val.m_value == GetNegativeInfinity().m_value))
            )
            {
                *this = GetNaN();
            }
            else if (val.m_value == GetInfinity().m_value)
            {
                m_value = GetNegativeInfinity().m_value;
            }
            else if (val.m_value == GetNegativeInfinity().m_value)
            {
                m_value = GetInfinity().m_value;
            }
            else if (isfinite() && val.isfinite())
            {
                const auto result = wider_type{m_value} - val.m_value;
                if (result > GetMax().m_value)
                {
                    // overflow from max
                    m_value = GetInfinity().m_value;
                }
                else if (result < GetLowest().m_value)
                {
                    // overflow from lowest
                    m_value = GetNegativeInfinity().m_value;
                }
                else
                {
                    m_value = static_cast<value_type>(result);
                }
            }
            return *this;
        }

        /// @brief Multiplication assignment operator.
        PLAYRHO_CONSTEXPR inline Fixed& operator*= (Fixed val) noexcept
        {
            if (isnan() || val.isnan())
            {
                *this = GetNaN();
            }
            else if (!isfinite() || !val.isfinite())
            {
                if (m_value == 0 || val.m_value == 0)
                {
                    *this = GetNaN();
                }
                else
                {
                    *this = ((m_value > 0) != (val.m_value > 0))? -GetInfinity(): GetInfinity();
                }
            }
            else
            {
                const auto product = wider_type{m_value} * wider_type{val.m_value};
                const auto result = product / ScaleFactor;
                
                if (product != 0 && result == 0)
                {
                    // underflow
                    m_value = static_cast<value_type>(result);
                }
                else if (result > GetMax().m_value)
                {
                    // overflow from max
                    m_value = GetInfinity().m_value;
                }
                else if (result < GetLowest().m_value)
                {
                    // overflow from lowest
                    m_value = GetNegativeInfinity().m_value;
                }
                else
                {
                    m_value = static_cast<value_type>(result);
                }
            }
            return *this;
        }

        /// @brief Division assignment operator.
        PLAYRHO_CONSTEXPR inline Fixed& operator/= (Fixed val) noexcept
        {
            if (isnan() || val.isnan())
            {
                *this = GetNaN();
            }
            else if (!isfinite() && !val.isfinite())
            {
                *this = GetNaN();
            }
            else if (!isfinite())
            {
                *this = ((m_value > 0) != (val.m_value > 0))? -GetInfinity(): GetInfinity();
            }
            else if (!val.isfinite())
            {
                *this = 0;
            }
            else
            {
                const auto product = wider_type{m_value} * ScaleFactor;
                const auto result = product / val.m_value;
                
                if (product != 0 && result == 0)
                {
                    // underflow
                    m_value = static_cast<value_type>(result);
                }
                else if (result > GetMax().m_value)
                {
                    // overflow from max
                    m_value = GetInfinity().m_value;
                }
                else if (result < GetLowest().m_value)
                {
                    // overflow from lowest
                    m_value = GetNegativeInfinity().m_value;
                }
                else
                {
                    m_value = static_cast<value_type>(result);
                }
            }
            return *this;
        }
        
        /// @brief Modulo operator.
        PLAYRHO_CONSTEXPR inline Fixed& operator%= (Fixed val) noexcept
        {
            assert(!isnan());
            assert(!val.isnan());

            m_value %= val.m_value;
            return *this;
        }
        
        /// @brief Is finite.
        PLAYRHO_CONSTEXPR inline bool isfinite() const noexcept
        {
            return (m_value > GetNegativeInfinity().m_value)
            && (m_value < GetInfinity().m_value);
        }
        
        /// @brief Is NaN.
        PLAYRHO_CONSTEXPR inline bool isnan() const noexcept
        {
            return m_value == GetNaN().m_value;
        }
        
        /// @brief Gets this value's sign.
        PLAYRHO_CONSTEXPR inline int getsign() const noexcept
        {
            return (m_value >= 0)? +1: -1;
        }

    private:
        
        /// @brief Widened type alias.
        using wider_type = typename Wider<value_type>::type;

        /// @brief Unsigned widened type alias.
        using unsigned_wider_type = typename std::make_unsigned<wider_type>::type;

        /// @brief Scalar type.
        struct scalar_type
        {
            value_type value = 1; ///< Value.
        };
        
        /// @brief Numeric limits type alias.
        using numeric_limits = std::numeric_limits<value_type>;
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Fixed(value_type val, scalar_type scalar) noexcept:
            m_value{val * scalar.value}
        {
            // Intentionally empty.
        }
        
        value_type m_value; ///< Value in internal form.
    };

    /// @brief Equality operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline bool operator== (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        return lhs.Compare(rhs) == Fixed<BT, FB>::CmpResult::Equal;
    }
    
    /// @brief Inequality operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline bool operator!= (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        return lhs.Compare(rhs) != Fixed<BT, FB>::CmpResult::Equal;
    }
    
    /// @brief Less-than operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline bool operator< (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        return lhs.Compare(rhs) == Fixed<BT, FB>::CmpResult::LessThan;
    }

    /// @brief Greater-than operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline bool operator> (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        return lhs.Compare(rhs) == Fixed<BT, FB>::CmpResult::GreaterThan;
    }
    
    /// @brief Less-than or equal-to operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline bool operator<= (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return result == Fixed<BT, FB>::CmpResult::LessThan ||
               result == Fixed<BT, FB>::CmpResult::Equal;
    }
    
    /// @brief Greater-than or equal-to operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline bool operator>= (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return result == Fixed<BT, FB>::CmpResult::GreaterThan || result == Fixed<BT, FB>::CmpResult::Equal;
    }

    /// @brief Addition operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline Fixed<BT, FB> operator+ (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        lhs += rhs;
        return lhs;
    }
    
    /// @brief Subtraction operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline Fixed<BT, FB> operator- (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        lhs -= rhs;
        return lhs;
    }
    
    /// @brief Multiplication operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline Fixed<BT, FB> operator* (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        lhs *= rhs;
        return lhs;
    }
    
    /// @brief Division operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline Fixed<BT, FB> operator/ (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        lhs /= rhs;
        return lhs;
    }
    
    /// @brief Modulo operator.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline Fixed<BT, FB> operator% (Fixed<BT, FB> lhs, Fixed<BT, FB> rhs) noexcept
    {
        lhs %= rhs;
        return lhs;
    }

    /// @brief Gets whether a given value is almost zero.
    /// @details An almost zero value is "subnormal". Dividing by these values can lead to
    /// odd results like a divide by zero trap occurring.
    /// @return <code>true</code> if the given value is almost zero, <code>false</code> otherwise.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline bool AlmostZero(Fixed<BT, FB> value)
    {
        return value == 0;
    }

    /// @brief Determines whether the given two values are "almost equal".
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline bool AlmostEqual(Fixed<BT, FB> x, Fixed<BT, FB> y, int ulp = 2)
    {
        return abs(x - y) <= Fixed<BT, FB>{0, static_cast<std::uint32_t>(ulp)};
    }
    
#ifdef CONFLICT_WITH_GETINVALID
    /// @brief Gets an invalid value.
    template <typename BT, unsigned int FB>
    PLAYRHO_CONSTEXPR inline Fixed<BT, FB> GetInvalid() noexcept
    {
        return Fixed<BT, FB>::GetNaN();
    }
#endif // CONFLICT_WITH_GETINVALID

    /// @brief Output stream operator.
    template <typename BT, unsigned int FB>
    inline ::std::ostream& operator<<(::std::ostream& os, const Fixed<BT, FB>& value)
    {
        return os << static_cast<double>(value);
    }

    /// @brief 32-bit fixed precision type.
    /// @details This is a 32-bit fixed precision type with a Q number-format of
    ///   <code>Q23.9</code>.
    ///
    /// @warning The available numeric fidelity of any 32-bit fixed point type is very limited.
    ///   Using a 32-bit fixed point type for Real should only be considered for simulations
    ///   where it's been found to work and where the dynamics won't be changing between runs.
    ///
    /// @note Maximum value (with 9 fraction bits) is approximately 4194303.99609375.
    /// @note Minimum value (with 9 fraction bits) is approximately 0.001953125.
    ///
    /// @sa Fixed, Real
    /// @sa https://en.wikipedia.org/wiki/Q_(number_format)
    ///
    using Fixed32 = Fixed<std::int32_t,9>;

    // Fixed32 free functions.
    
    /// @brief Gets an invalid value.
    template <>
    PLAYRHO_CONSTEXPR inline Fixed32 GetInvalid() noexcept
    {
        return Fixed32::GetNaN();
    }
    
    /// @brief Addition operator.
    PLAYRHO_CONSTEXPR inline Fixed32 operator+ (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        lhs += rhs;
        return lhs;
    }

    /// @brief Subtraction operator.
    PLAYRHO_CONSTEXPR inline Fixed32 operator- (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        lhs -= rhs;
        return lhs;
    }
    
    /// @brief Multiplication operator.
    PLAYRHO_CONSTEXPR inline Fixed32 operator* (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        lhs *= rhs;
        return lhs;
    }
    
    /// @brief Division operator.
    PLAYRHO_CONSTEXPR inline Fixed32 operator/ (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        lhs /= rhs;
        return lhs;
    }
    
    /// @brief Modulo operator.
    PLAYRHO_CONSTEXPR inline Fixed32 operator% (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        lhs %= rhs;
        return lhs;
    }    
    
    /// @brief Equality operator.
    PLAYRHO_CONSTEXPR inline bool operator== (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        return lhs.Compare(rhs) == Fixed32::CmpResult::Equal;
    }
    
    /// @brief Inequality operator.
    PLAYRHO_CONSTEXPR inline bool operator!= (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        return lhs.Compare(rhs) != Fixed32::CmpResult::Equal;
    }
    
    /// @brief Less-than or equal-to operator.
    PLAYRHO_CONSTEXPR inline bool operator <= (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return (result == Fixed32::CmpResult::LessThan) || (result == Fixed32::CmpResult::Equal);
    }
    
    /// @brief Greater-than or equal-to operator.
    PLAYRHO_CONSTEXPR inline bool operator >= (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return (result == Fixed32::CmpResult::GreaterThan) || (result == Fixed32::CmpResult::Equal);
    }
    
    /// @brief Less-than operator.
    PLAYRHO_CONSTEXPR inline bool operator < (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return result == Fixed32::CmpResult::LessThan;
    }
    
    /// @brief Greater-than operator.
    PLAYRHO_CONSTEXPR inline bool operator > (Fixed32 lhs, Fixed32 rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return result == Fixed32::CmpResult::GreaterThan;
    }
    
    /// @brief Gets the specialized name for the <code>Fixed32</code> type.
    /// @details Provides an interface to a specialized function for getting C-style
    ///   null-terminated array of characters that names the <code>Fixed32</code> type.
    /// @return Non-null pointer to C-style string name of specified type.
    template <>
    inline const char* GetTypeName<Fixed32>() noexcept
    {
        return "Fixed32";
    }

#ifdef PLAYRHO_INT128
    // Fixed64 free functions.

    /// @brief 64-bit fixed precision type.
    /// @details This is a 64-bit fixed precision type with a Q number-format of
    ///   <code>Q40.24</code>.
    ///
    /// @note Minimum value (with 24 fraction bits) is approximately
    ///   <code>5.9604644775390625e-08</code>.
    /// @note Maximum value (with 24 fraction bits) is approximately
    ///   <code>549755813888</code>.
    ///
    /// @sa Fixed, Real
    /// @sa https://en.wikipedia.org/wiki/Q_(number_format)
    ///
    using Fixed64 = Fixed<std::int64_t,24>;
    
    /// @brief Gets an invalid value.
    template <>
    PLAYRHO_CONSTEXPR inline Fixed64 GetInvalid() noexcept
    {
        return Fixed64::GetNaN();
    }

    /// @brief Addition operator.
    PLAYRHO_CONSTEXPR inline Fixed64 operator+ (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        lhs += rhs;
        return lhs;
    }
    
    /// @brief Subtraction operator.
    PLAYRHO_CONSTEXPR inline Fixed64 operator- (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        lhs -= rhs;
        return lhs;
    }
    
    /// @brief Multiplication operator.
    PLAYRHO_CONSTEXPR inline Fixed64 operator* (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        lhs *= rhs;
        return lhs;
    }
    
    /// @brief Division operator.
    PLAYRHO_CONSTEXPR inline Fixed64 operator/ (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        lhs /= rhs;
        return lhs;
    }
    
    PLAYRHO_CONSTEXPR inline Fixed64 operator% (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        lhs %= rhs;
        return lhs;
    }
    
    /// @brief Equality operator.
    PLAYRHO_CONSTEXPR inline bool operator== (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        return lhs.Compare(rhs) == Fixed64::CmpResult::Equal;
    }
    
    /// @brief Inequality operator.
    PLAYRHO_CONSTEXPR inline bool operator!= (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        return lhs.Compare(rhs) != Fixed64::CmpResult::Equal;
    }
    
    PLAYRHO_CONSTEXPR inline bool operator <= (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return (result == Fixed64::CmpResult::LessThan) || (result == Fixed64::CmpResult::Equal);
    }
    
    PLAYRHO_CONSTEXPR inline bool operator >= (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return (result == Fixed64::CmpResult::GreaterThan) || (result == Fixed64::CmpResult::Equal);
    }
    
    PLAYRHO_CONSTEXPR inline bool operator < (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return result == Fixed64::CmpResult::LessThan;
    }
    
    PLAYRHO_CONSTEXPR inline bool operator > (Fixed64 lhs, Fixed64 rhs) noexcept
    {
        const auto result = lhs.Compare(rhs);
        return result == Fixed64::CmpResult::GreaterThan;
    }

    /// @brief Specialization of the Wider trait for the <code>Fixed32</code> type.
    template<> struct Wider<Fixed32> {
        using type = Fixed64; ///< Wider type.
    };
    
    /// @brief Gets the specialized name for the <code>Fixed64</code> type.
    /// @details Provides an interface to a specialized function for getting C-style
    ///   null-terminated array of characters that names the <code>Fixed64</code> type.
    /// @return Non-null pointer to C-style string name of specified type.
    template <>
    inline const char* GetTypeName<Fixed64>() noexcept
    {
        return "Fixed64";
    }

#endif /* PLAYRHO_INT128 */

} // namespace playrho

#endif // PLAYRHO_COMMON_FIXED_HPP
