/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_JOINTS_JOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_JOINTCONF_HPP

#include "PlayRho/Dynamics/BodyID.hpp"

#include <cstdint>

namespace playrho {
namespace d2 {

/// @brief Base joint definition class.
/// @details Joint definitions are used to construct joints.
struct JointConf {
    /// @brief 1st attached body.
    BodyID bodyA = InvalidBodyID;

    /// @brief 2nd attached body.
    BodyID bodyB = InvalidBodyID;

    /// @brief Collide connected.
    /// @details Set this flag to true if the attached bodies should collide.
    bool collideConnected = false;
};

/// @brief Gets the first body attached to this joint.
constexpr BodyID GetBodyA(const JointConf& object) noexcept
{
    return object.bodyA;
}

/// @brief Gets the second body attached to this joint.
constexpr BodyID GetBodyB(const JointConf& object) noexcept
{
    return object.bodyB;
}

/// @brief Gets whether attached bodies should collide or not.
constexpr bool GetCollideConnected(const JointConf& object) noexcept
{
    return object.collideConnected;
}

/// @brief Joint builder definition structure.
/// @details This is a builder structure of chainable methods for building a shape
///   configuration.
/// @note This is a templated nested value class for initializing joints that
///   uses the Curiously Recurring Template Pattern (CRTP) to provide method chaining
///   via static polymorphism.
/// @see https://en.wikipedia.org/wiki/Curiously_recurring_template_pattern
template <class T>
struct JointBuilder : JointConf {
    /// @brief Value type.
    using value_type = T;

    /// @brief Reference type.
    using reference = value_type&;

    /// @brief Use value for body A setting.
    constexpr reference UseBodyA(BodyID b) noexcept
    {
        bodyA = b;
        return static_cast<reference>(*this);
    }

    /// @brief Use value for body B setting.
    constexpr reference UseBodyB(BodyID b) noexcept
    {
        bodyB = b;
        return static_cast<reference>(*this);
    }

    /// @brief Use value for collide connected setting.
    constexpr reference UseCollideConnected(bool v) noexcept
    {
        collideConnected = v;
        return static_cast<reference>(*this);
    }
};

class Joint;

/// @brief Sets the joint definition data for the given joint.
/// @relatedalso JointConf
void Set(JointConf& def, const Joint& joint) noexcept;

template <typename T>
constexpr auto IsLimitEnabled(const T& conf) noexcept -> decltype(std::declval<T>().enableLimit)
{
    return conf.enableLimit;
}

template <typename T>
constexpr auto EnableLimit(T& conf, bool v) noexcept
    -> decltype(std::declval<T>().UseEnableLimit(bool{}))
{
    return conf.UseEnableLimit(v);
}

template <typename T>
constexpr auto GetLength(const T& conf) noexcept -> decltype(std::declval<T>().length)
{
    return conf.length;
}

template <typename T>
constexpr auto GetMaxForce(const T& conf) noexcept -> decltype(std::declval<T>().maxForce)
{
    return conf.maxForce;
}

template <typename T>
constexpr auto GetMaxTorque(const T& conf) noexcept -> decltype(std::declval<T>().maxTorque)
{
    return conf.maxTorque;
}

template <typename T>
constexpr auto GetRatio(const T& conf) noexcept -> decltype(std::declval<T>().ratio)
{
    return conf.ratio;
}

template <typename T>
constexpr auto GetDampingRatio(const T& conf) noexcept -> decltype(std::declval<T>().dampingRatio)
{
    return conf.dampingRatio;
}

template <typename T>
constexpr auto GetReferenceAngle(const T& conf) noexcept
    -> decltype(std::declval<T>().referenceAngle)
{
    return conf.referenceAngle;
}

template <typename T>
constexpr auto GetLinearReaction(const T& conf) noexcept
    -> decltype(std::declval<T>().linearImpulse)
{
    return conf.linearImpulse;
}

template <typename T>
constexpr auto GetLinearOffset(const T& conf) noexcept -> decltype(std::declval<T>().linearOffset)
{
    return conf.linearOffset;
}

template <typename T>
constexpr auto GetLimitState(const T& conf) noexcept -> decltype(std::declval<T>().limitState)
{
    return conf.limitState;
}

template <typename T>
constexpr auto GetGroundAnchorA(const T& conf) noexcept -> decltype(std::declval<T>().groundAnchorA)
{
    return conf.groundAnchorA;
}

template <typename T>
constexpr auto GetGroundAnchorB(const T& conf) noexcept -> decltype(std::declval<T>().groundAnchorB)
{
    return conf.groundAnchorB;
}

template <typename T>
constexpr auto GetLocalAnchorA(const T& conf) noexcept -> decltype(std::declval<T>().localAnchorA)
{
    return conf.localAnchorA;
}

template <typename T>
constexpr auto GetLocalAnchorB(const T& conf) noexcept -> decltype(std::declval<T>().localAnchorB)
{
    return conf.localAnchorB;
}

template <typename T>
constexpr auto GetLocalXAxisA(const T& conf) noexcept -> decltype(std::declval<T>().localXAxisA)
{
    return conf.localXAxisA;
}

template <typename T>
constexpr auto GetLocalYAxisA(const T& conf) noexcept -> decltype(std::declval<T>().localYAxisA)
{
    return conf.localYAxisA;
}

template <typename T>
constexpr auto GetFrequency(const T& conf) noexcept -> decltype(std::declval<T>().frequency)
{
    return conf.frequency;
}

template <typename T>
constexpr auto IsMotorEnabled(const T& conf) noexcept -> decltype(std::declval<T>().enableMotor)
{
    return conf.enableMotor;
}

template <typename T>
constexpr auto EnableMotor(T& conf, bool v) noexcept
    -> decltype(std::declval<T>().UseEnableMotor(bool{}))
{
    return conf.UseEnableMotor(v);
}

template <typename T>
constexpr auto GetMotorSpeed(const T& conf) noexcept -> decltype(std::declval<T>().motorSpeed)
{
    return conf.motorSpeed;
}

template <typename T>
constexpr auto SetMotorSpeed(T& conf, AngularVelocity v) noexcept
    -> decltype(std::declval<T>().UseMotorSpeed(AngularVelocity{}))
{
    return conf.UseMotorSpeed(v);
}

template <typename T>
constexpr auto GetLinearMotorImpulse(const T& conf) noexcept
    -> decltype(std::declval<T>().motorImpulse)
{
    return conf.motorImpulse;
}

template <typename T>
constexpr auto GetMaxMotorForce(const T& conf) noexcept -> decltype(std::declval<T>().maxMotorForce)
{
    return conf.maxMotorForce;
}

template <typename T>
constexpr auto GetMaxMotorTorque(const T& conf) noexcept
    -> decltype(std::declval<T>().maxMotorTorque)
{
    return conf.maxMotorTorque;
}

template <typename T>
constexpr auto GetAngularOffset(const T& conf) noexcept -> decltype(std::declval<T>().angularOffset)
{
    return conf.angularOffset;
}

template <typename T>
constexpr auto GetAngularReaction(const T& conf) noexcept
    -> decltype(std::declval<T>().angularImpulse)
{
    return conf.angularImpulse;
}

template <typename T>
constexpr auto GetAngularMass(const T& conf) noexcept -> decltype(std::declval<T>().angularMass)
{
    return conf.angularMass;
}

template <typename T>
constexpr auto GetAngularMotorImpulse(const T& conf) noexcept
    -> decltype(std::declval<T>().angularMotorImpulse)
{
    return conf.angularMotorImpulse;
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_JOINTCONF_HPP
