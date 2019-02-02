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

#ifndef PLAYRHO_DYNAMICS_JOINTS_JOINTKEY_HPP
#define PLAYRHO_DYNAMICS_JOINTS_JOINTKEY_HPP

/// @file
/// Definition of the JointKey class and any associated free functions.

#include "PlayRho/Common/Settings.hpp"
#include <utility>
#include <functional>

namespace playrho {
namespace d2 {

class Joint;
class Body;

/// @brief Joint key.
class JointKey
{
public:
    
    /// @brief Gets the <code>JointKey</code> for the given bodies.
    static PLAYRHO_CONSTEXPR inline JointKey Get(const Body* bodyA, const Body* bodyB) noexcept
    {
        return (bodyA < bodyB)? JointKey{bodyA, bodyB}: JointKey{bodyB, bodyA};
    }
    
    /// @brief Gets body 1.
    PLAYRHO_CONSTEXPR const Body* GetBody1() const noexcept
    {
        return m_body1;
    }
    
    /// @brief Gets body 2.
    PLAYRHO_CONSTEXPR const Body* GetBody2() const
    {
        return m_body2;
    }

private:
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline JointKey(const Body* body1, const Body* body2):
        m_body1(body1), m_body2(body2)
    {
        // Intentionally empty.
    }

    /// @brief Body 1.
    /// @details This is the body with the lower-than or equal-to address.
    const Body* m_body1;

    /// @brief Body 2.
    /// @details This is the body with the higher-than or equal-to address.
    const Body* m_body2;
};

/// @brief Gets the <code>JointKey</code> for the given joint.
JointKey GetJointKey(const Joint& joint) noexcept;

/// @brief Compares the given joint keys.
PLAYRHO_CONSTEXPR inline int Compare(const JointKey& lhs, const JointKey& rhs) noexcept
{
    if (lhs.GetBody1() < rhs.GetBody1())
    {
        return -1;
    }
    if (lhs.GetBody1() > rhs.GetBody1())
    {
        return +1;
    }
    if (lhs.GetBody2() < rhs.GetBody2())
    {
        return -1;
    }
    if (lhs.GetBody2() > rhs.GetBody2())
    {
        return +1;
    }
    return 0;
}

/// @brief Determines whether the given key is for the given body.
/// @relatedalso JointKey
PLAYRHO_CONSTEXPR inline bool IsFor(const JointKey key, const Body* body) noexcept
{
    return body == key.GetBody1() || body == key.GetBody2();
}

/// @brief Gets the joint pointer from the given value.
inline Joint* GetJointPtr(std::pair<JointKey, Joint*> value)
{
    return std::get<Joint*>(value);
}

} // namespace d2
} // namespace playrho

namespace std
{
    /// @brief Function object for performing less-than comparisons between two joint keys.
    template <>
    struct less<playrho::d2::JointKey>
    {
        /// @brief Function object operator.
        PLAYRHO_CONSTEXPR inline
        bool operator()(const playrho::d2::JointKey& lhs, const playrho::d2::JointKey& rhs) const
        {
            return playrho::d2::Compare(lhs, rhs) < 0;
        }
    };
    
    /// @brief Function object for performing equal-to comparisons between two joint keys.
    template <>
    struct equal_to<playrho::d2::JointKey>
    {
        
        /// @brief Function object operator.
        PLAYRHO_CONSTEXPR inline
        bool operator()( const playrho::d2::JointKey& lhs, const playrho::d2::JointKey& rhs ) const
        {
            return playrho::d2::Compare(lhs, rhs) == 0;
        }
    };

} // namespace std

#endif // PLAYRHO_DYNAMICS_JOINTS_JOINTKEY_HPP
