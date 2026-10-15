/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_D2_JOINTCONF_HPP
#define PLAYRHO_D2_JOINTCONF_HPP

/// @file
/// @brief Definition of the @c JointConf class and closely related code.

#include <cstddef> // for std::max_align_t

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/Units.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

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

#ifdef _MSC_VER
#pragma warning( push )
#endif

// Disable MSVC from warning "structure was padded due to alignment specifier".
// The possibly additional space usage is preferable to U.B. from returning
// possibly misaligned references.
#ifdef _MSC_VER
#pragma warning( disable : 4324 )
#endif

/// @brief Joint builder definition structure.
/// @details This is a builder structure of chainable methods for building a shape
///   configuration.
/// @note Alignment requirement specified to ensure proper alignment of references
///   returned for function chaining.
/// @note This is a templated nested value class for initializing joints that
///   uses the Curiously Recurring Template Pattern (CRTP) to provide function chaining
///   via static polymorphism.
/// @see https://en.wikipedia.org/wiki/Curiously_recurring_template_pattern
template <class T>
struct alignas(std::max_align_t) JointBuilder : JointConf {
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

#ifdef _MSC_VER
#pragma warning( pop )
#endif

class Joint;

/// @brief Sets the joint definition data for the given joint.
/// @relatedalso JointConf
void Set(JointConf& def, const Joint& joint) noexcept;

/// @brief Gets whether or not the limit property of the given object is enabled.
template <typename T>
constexpr auto IsLimitEnabled(const T& conf) noexcept -> decltype(std::declval<T>().enableLimit)
{
    return conf.enableLimit;
}

/// @brief Enables or disables the limit based on the given value.
template <typename T>
constexpr auto EnableLimit(T& conf, bool v) noexcept
    -> decltype(std::declval<T>().UseEnableLimit(bool{}))
{
    return conf.UseEnableLimit(v);
}

/// @brief Gets the length property of the given object.
template <typename T>
constexpr auto GetLength(const T& conf) noexcept -> decltype(std::declval<T>().length)
{
    return conf.length;
}

/// @brief Gets the max force property of the given object.
template <typename T>
constexpr auto GetMaxForce(const T& conf) noexcept -> decltype(std::declval<T>().maxForce)
{
    return conf.maxForce;
}

/// @brief Gets the max torque property of the given object.
template <typename T>
constexpr auto GetMaxTorque(const T& conf) noexcept -> decltype(std::declval<T>().maxTorque)
{
    return conf.maxTorque;
}

/// @brief Gets the ratio property of the given object.
template <typename T>
constexpr auto GetRatio(const T& conf) noexcept -> decltype(std::declval<T>().ratio)
{
    return conf.ratio;
}

/// @brief Gets the damping ratio property of the given object.
template <typename T>
constexpr auto GetDampingRatio(const T& conf) noexcept -> decltype(std::declval<T>().dampingRatio)
{
    return conf.dampingRatio;
}

/// @brief Gets the reference angle property of the given object.
template <typename T>
constexpr auto GetReferenceAngle(const T& conf) noexcept
    -> decltype(std::declval<T>().referenceAngle)
{
    return conf.referenceAngle;
}

/// @brief Gets the linear reaction property of the given object.
template <typename T>
constexpr auto GetLinearReaction(const T& conf) noexcept
    -> decltype(std::declval<T>().linearImpulse)
{
    return conf.linearImpulse;
}

/// @brief Gets the linear offset property of the given object.
template <typename T>
constexpr auto GetLinearOffset(const T& conf) noexcept -> decltype(std::declval<T>().linearOffset)
{
    return conf.linearOffset;
}

/// @brief Gets the limit state property of the given object.
template <typename T>
constexpr auto GetLimitState(const T& conf) noexcept -> decltype(std::declval<T>().limitState)
{
    return conf.limitState;
}

/// @brief Gets the ground anchor A property of the given object.
template <typename T>
constexpr auto GetGroundAnchorA(const T& conf) noexcept -> decltype(std::declval<T>().groundAnchorA)
{
    return conf.groundAnchorA;
}

/// @brief Gets the ground anchor B property of the given object.
template <typename T>
constexpr auto GetGroundAnchorB(const T& conf) noexcept -> decltype(std::declval<T>().groundAnchorB)
{
    return conf.groundAnchorB;
}

/// @brief Gets the local anchor A property of the given object.
template <typename T>
constexpr auto GetLocalAnchorA(const T& conf) noexcept -> decltype(std::declval<T>().localAnchorA)
{
    return conf.localAnchorA;
}

/// @brief Gets the local anchor B property of the given object.
template <typename T>
constexpr auto GetLocalAnchorB(const T& conf) noexcept -> decltype(std::declval<T>().localAnchorB)
{
    return conf.localAnchorB;
}

/// @brief Gets the local X axis A property of the given object.
template <typename T>
constexpr auto GetLocalXAxisA(const T& conf) noexcept -> decltype(std::declval<T>().localXAxisA)
{
    return conf.localXAxisA;
}

/// @brief Gets the local Y axis A property of the given object.
template <typename T>
constexpr auto GetLocalYAxisA(const T& conf) noexcept -> decltype(std::declval<T>().localYAxisA)
{
    return conf.localYAxisA;
}

/// @brief Gets the frequency property of the given object.
template <typename T>
constexpr auto GetFrequency(const T& conf) noexcept -> decltype(std::declval<T>().frequency)
{
    return conf.frequency;
}

/// @brief Gets the motor enabled property of the given object.
template <typename T>
constexpr auto IsMotorEnabled(const T& conf) noexcept -> decltype(std::declval<T>().enableMotor)
{
    return conf.enableMotor;
}

/// @brief Enables or disables the motor property of the given object.
template <typename T>
constexpr auto EnableMotor(T& conf, bool v) noexcept
    -> decltype(std::declval<T>().UseEnableMotor(bool{}))
{
    return conf.UseEnableMotor(v);
}

/// @brief Gets the motor speed property of the given object.
template <typename T>
constexpr auto GetMotorSpeed(const T& conf) noexcept -> decltype(std::declval<T>().motorSpeed)
{
    return conf.motorSpeed;
}

/// @brief Sets the motor speed property of the given object.
template <typename T>
constexpr auto SetMotorSpeed(T& conf, AngularVelocity v) noexcept
    -> decltype(std::declval<T>().UseMotorSpeed(AngularVelocity{}))
{
    return conf.UseMotorSpeed(v);
}

/// @brief Gets the linear motor impulse property of the given object.
template <typename T>
constexpr auto GetLinearMotorImpulse(const T& conf) noexcept
    -> decltype(std::declval<T>().motorImpulse)
{
    return conf.motorImpulse;
}

/// @brief Gets the max motor force property of the given object.
template <typename T>
constexpr auto GetMaxMotorForce(const T& conf) noexcept -> decltype(std::declval<T>().maxMotorForce)
{
    return conf.maxMotorForce;
}

/// @brief Gets the max motor torque property of the given object.
template <typename T>
constexpr auto GetMaxMotorTorque(const T& conf) noexcept
    -> decltype(std::declval<T>().maxMotorTorque)
{
    return conf.maxMotorTorque;
}

/// @brief Gets the angular offset property of the given object.
template <typename T>
constexpr auto GetAngularOffset(const T& conf) noexcept -> decltype(std::declval<T>().angularOffset)
{
    return conf.angularOffset;
}

/// @brief Gets the angular reaction property of the given object.
template <typename T>
constexpr auto GetAngularReaction(const T& conf) noexcept
    -> decltype(std::declval<T>().angularImpulse)
{
    return conf.angularImpulse;
}

/// @brief Gets the angular mass property of the given object.
template <typename T>
constexpr auto GetAngularMass(const T& conf) noexcept -> decltype(std::declval<T>().angularMass)
{
    return conf.angularMass;
}

/// @brief Gets the angular motor impulse property of the given object.
template <typename T>
constexpr auto GetAngularMotorImpulse(const T& conf) noexcept
    -> decltype(std::declval<T>().angularMotorImpulse)
{
    return conf.angularMotorImpulse;
}

} // namespace playrho::d2

#endif // PLAYRHO_D2_JOINTCONF_HPP
