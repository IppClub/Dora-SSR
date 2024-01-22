/*
 * Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * Erin Catto's http://www.box2d.org was the origin for this software.
 * TypeCast code originated from the LLVM Project https://llvm.org/LICENSE.txt.
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

#ifndef PLAYRHO_D2_JOINT_HPP
#define PLAYRHO_D2_JOINT_HPP

/// @file
/// @brief Definition of the @c Joint class and closely related code.

#include <memory> // for std::unique_ptr
#include <utility> // for std::move, std::forward
#include <typeinfo> // for std::bad_cast
#include <type_traits> // for std::void_t, std::add_pointer_t, etc.

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/LimitState.hpp"
#include "playrho/Real.hpp"
#include "playrho/Span.hpp"
#include "playrho/Templates.hpp" // for DecayedTypeIfNotSame
#include "playrho/TypeInfo.hpp" // for GetTypeID
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"

#include "playrho/d2/UnitVec.hpp"

#include "playrho/d2/detail/JointConcept.hpp"
#include "playrho/d2/detail/JointModel.hpp"

// IWYU pragma: end_exports

namespace playrho {
struct StepConf;
struct ConstraintSolverConf;
}

namespace playrho::d2 {

class Joint;
class BodyConstraint;

// Forward declare functions.
// Note that these may be friend functions but that declaring these within the class that
// they're to be friends of, doesn't also insure that they're found within the namespace
// in terms of lookup.

/// @brief Gets the identifier of the type of data this can be casted to.
TypeID GetType(const Joint& object) noexcept;

/// @brief Converts the given joint into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> code from the LLVM Project.
/// @see https://llvm.org/
template <typename T>
std::add_pointer_t<std::add_const_t<T>> TypeCast(const Joint* value) noexcept;

/// @brief Converts the given joint into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> implementation from the LLVM Project.
/// @see https://llvm.org/
template <typename T>
std::add_pointer_t<T> TypeCast(Joint* value) noexcept;

/// @brief Equality operator for joint comparisons.
bool operator==(const Joint& lhs, const Joint& rhs) noexcept;

/// @brief Inequality operator for joint comparisons.
bool operator!=(const Joint& lhs, const Joint& rhs) noexcept;

/// @brief Gets the first body attached to this joint.
BodyID GetBodyA(const Joint& object) noexcept;

/// @brief Gets the second body attached to this joint.
BodyID GetBodyB(const Joint& object) noexcept;

/// @brief Gets collide connected.
/// @note Modifying the collide connect flag won't work correctly because
///   the flag is only checked when fixture AABBs begin to overlap.
bool GetCollideConnected(const Joint& object) noexcept;

/// @brief Shifts the origin for any points stored in world coordinates.
/// @return <code>true</code> if shift done, <code>false</code> otherwise.
bool ShiftOrigin(Joint& object, const Length2& value) noexcept;

/// @brief Initializes velocity constraint data based on the given solver data.
/// @note This MUST be called prior to calling <code>SolveVelocity</code>.
/// @see SolveVelocity.
void InitVelocity(Joint& object, const Span<BodyConstraint>& bodies, const StepConf& step,
                  const ConstraintSolverConf& conf);

/// @brief Solves velocity constraint.
/// @pre <code>InitVelocity</code> has been called.
/// @see InitVelocity.
/// @return <code>true</code> if velocity is "solved", <code>false</code> otherwise.
bool SolveVelocity(Joint& object, const Span<BodyConstraint>& bodies, const StepConf& step);

/// @brief Solves the position constraint.
/// @return <code>true</code> if the position errors are within tolerance.
bool SolvePosition(const Joint& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @example Joint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::Joint</code>.

/// @defgroup JointsGroup Joint Classes
/// @brief The user creatable classes that specify constraints on one or more body instances.
/// @ingroup ConstraintsGroup

/// @brief A joint-like constraint on one or more bodies.
/// @details This is a concrete manifestation of the joint concept. Joints are constraints
///   that are used to constrain one or more bodies in various fashions. Some joints also
///   feature limits and motors.
/// @note This class's design provides a "polymorphic value type" offering polymorphism
///   without public inheritance. This is based on a technique that's described by Sean Parent
///   in his January 2017 Norwegian Developers Conference London talk "Better Code: Runtime
///   Polymorphism".
/// @note A joint can be constructed from or have its value set to any value whose type
/// <code>T</code> has at least the following function definitions available for it:
///   - <code>bool operator==(const T& lhs, const T& rhs) noexcept;</code>
///   - <code>BodyID GetBodyA(const T& object) noexcept;</code>
///   - <code>BodyID GetBodyB(const T& object) noexcept;</code>
///   - <code>bool GetCollideConnected(const T& object) noexcept;</code>
///   - <code>bool ShiftOrigin(T& object, Length2 value) noexcept;</code>
///   - <code>void InitVelocity(T& object, const Span<BodyConstraint>& bodies,
///       const StepConf& step, const ConstraintSolverConf& conf);</code>
///   - <code>bool SolveVelocity(T& object, const Span<BodyConstraint>& bodies,
///       const StepConf& step);</code>
///   - <code>bool SolvePosition(const T& object, const Span<BodyConstraint>& bodies,
///       const ConstraintSolverConf& conf);</code>
/// @ingroup JointsGroup
/// @ingroup PhysicalEntities
/// @see JointsGroup, PhysicalEntities.
/// @see https://youtu.be/QGcVXgEVMJg
/// @see https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Polymorphic_Value_Types
class Joint
{
public:
    /// @brief Default constructor.
    /// @details Constructs a joint that contains no value.
    /// @post <code>has_value()</code> returns false.
    /// @post <code>GetType(const Joint&)</code> returns <code>GetTypeID<void>()</code>.
    Joint() noexcept = default;

    /// @brief Copy constructor.
    /// @details This constructor copies all the details of \a other.
    Joint(const Joint& other) : m_impl{other.m_impl ? other.m_impl->Clone_() : nullptr}
    {
        // Intentionally empty.
    }

    /// @brief Move constructor.
    /// @details This constructor moves all the details of \a other into <code>*this</code> and
    ///   leaves \a other in the default constructed state.
    Joint(Joint&& other) noexcept : m_impl{std::move(other.m_impl)}
    {
        // Intentionally empty.
    }

    /// @brief Initializing constructor.
    /// @param arg Value to construct a joint instance for.
    /// @note See the class notes section for an explanation of requirements on a type
    ///   <code>T</code> for its values to be valid candidates for this function.
    /// @note This constructor is marked <code>explicit</code> to prevent implicit conversions and
    ///   to provide preferable error messages from the compiler with less to-do when a type doesn't
    ///   support one or more of the required functions. For instance, if there exists no function
    ///   <code>GetBodyA(const T&)</code> for the type <code>T</code>, then clang issues the error:
    ///   <b>No matching function for call to 'GetBodyA'</b>.
    /// @note If this constructor was not marked <code>explicit</code> and nothing else is done,
    ///   then <code>GetBodyA(const Joint&)</code> becomes eligible to satisfy that requirement
    ///   (because of implicit conversion from <code>T</code> to <code>Joint</code>). This results
    ///   in an exhaustive loop which is decidely less desirable than a compile time error.
    /// @note If this constructor is not marked <code>explicit</code> and <code>const</code> rvalue
    ///   reference taking versions of the required functions are deleted with definitions like
    ///   <code>BodyID GetBodyA(const Joint&&) noexcept = delete</code>, then clang issues an error
    ///   of: <b>Call to deleted function 'GetBodyA'</b>. The idea for these deleted functions came
    ///   from the article <a href="https://foonathan.net/2015/10/overload-resolution-1/">
    ///   Controlling overload resolution #1: Preventing implicit conversions</a>. While this would
    ///   be preferable to discovering the issue at runtime, that's not as preferable as the error
    ///   clang generates when this constructor is marked <code>explicit</code> since this message
    ///   points to the deleted function as the problem rather than directly to there being "no
    ///   matching function".
    /// @note While allowing implicit conversion would be preferable from a syntactic perspective
    ///   and its similarity to the behavior of <code>std::any</code>, dealing with overload
    ///   resolution of the required functions is less appealing than marking this constuctor
    ///   <code>explicit</code> as explained above.
    /// @note This constructor allows code like the following to work:
    /// @code{.cpp}
    /// auto def = WheelJointConf{};
    /// auto joint = Joint{def}; Joint{WheelJointConf{}};
    /// void f(Joint j);
    /// f(joint); f(Joint{def}); // but not f(def);
    /// @endcode
    /// @post <code>has_value()</code> returns true.
    /// @throws std::bad_alloc if there's a failure allocating storage.
    /// @see https://foonathan.net/2015/10/overload-resolution-1/
    template <typename T, typename Tp = DecayedTypeIfNotSame<T, Joint>,
              typename = std::enable_if_t<std::is_constructible_v<Tp, T>>>
    explicit Joint(T&& arg) : m_impl{std::make_unique<detail::JointModel<Tp>>(std::forward<T>(arg))}
    {
        // Intentionally empty.
    }

    /// @brief Copy assignment.
    /// @details This operator copies all the details of \a other into <code>*this</code>.
    Joint& operator=(const Joint& other)
    {
        m_impl = other.m_impl ? other.m_impl->Clone_() : nullptr;
        return *this;
    }

    /// @brief Move assignment.
    /// @details This operator moves all the details of \a other into <code>*this</code> and
    ///   leaves \a other in the default constructed state.
    Joint& operator=(Joint&& other) noexcept
    {
        m_impl = std::move(other.m_impl);
        return *this;
    }

    /// @brief Move assignment support for any valid underlying configuration.
    /// @note See the class notes section for an explanation of requirements on a type
    ///   <code>T</code> for its values to be valid candidates for this function.
    /// @post <code>has_value()</code> returns true.
    template <typename T, typename Tp = DecayedTypeIfNotSame<T, Joint>,
              typename = std::enable_if_t<std::is_constructible_v<Tp, T>>>
    Joint& operator=(T&& arg)
    {
        Joint(std::forward<T>(arg)).swap(*this);
        return *this;
    }

    /// @brief Swap function.
    void swap(Joint& other) noexcept
    {
        std::swap(m_impl, other.m_impl);
    }

    /// @brief Checks whether this instance contains a value.
    bool has_value() const noexcept
    {
        return static_cast<bool>(m_impl);
    }

    friend TypeID GetType(const Joint& object) noexcept
    {
        return object.m_impl ? object.m_impl->GetType_() : GetTypeID<void>();
    }

    template <typename T>
    friend std::add_pointer_t<std::add_const_t<T>> TypeCast(const Joint* value) noexcept;

    template <typename T>
    friend std::add_pointer_t<T> TypeCast(Joint* value) noexcept;

    friend bool operator==(const Joint& lhs, const Joint& rhs) noexcept
    {
        return (lhs.m_impl == rhs.m_impl) ||
               ((lhs.m_impl && rhs.m_impl) && (lhs.m_impl->IsEqual_(*rhs.m_impl)));
    }

    friend bool operator!=(const Joint& lhs, const Joint& rhs) noexcept
    {
        return !(lhs == rhs);
    }

    friend BodyID GetBodyA(const Joint& object) noexcept
    {
        return object.m_impl ? object.m_impl->GetBodyA_() : InvalidBodyID;
    }

    friend BodyID GetBodyB(const Joint& object) noexcept
    {
        return object.m_impl ? object.m_impl->GetBodyB_() : InvalidBodyID;
    }

    friend bool GetCollideConnected(const Joint& object) noexcept
    {
        return object.m_impl ? object.m_impl->GetCollideConnected_() : false;
    }

    friend bool ShiftOrigin(Joint& object, const Length2& value) noexcept
    {
        return object.m_impl ? object.m_impl->ShiftOrigin_(value) : false;
    }

    friend void InitVelocity(Joint& object, const Span<BodyConstraint>& bodies,
                             const playrho::StepConf& step, const ConstraintSolverConf& conf)
    {
        if (object.m_impl) {
            object.m_impl->InitVelocity_(bodies, step, conf);
        }
    }

    friend bool SolveVelocity(Joint& object, const Span<BodyConstraint>& bodies,
                              const playrho::StepConf& step)
    {
        return object.m_impl ? object.m_impl->SolveVelocity_(bodies, step) : false;
    }

    friend bool SolvePosition(const Joint& object, const Span<BodyConstraint>& bodies,
                              const ConstraintSolverConf& conf)
    {
        return object.m_impl ? object.m_impl->SolvePosition_(bodies, conf) : false;
    }

private:
    std::unique_ptr<detail::JointConcept> m_impl; ///< Pointer to implementation.
};

// Traits...

namespace detail {

/// @brief An "is valid joint type" trait.
/// @note This is the general false template type.
template <typename T, class = void>
struct IsValidJointType : std::false_type {
};

/// @brief An "is valid joint type" trait.
/// @note This is the specialized true template type.
template <typename T>
struct IsValidJointType<
    T,
    std::void_t<
        decltype(GetBodyA(std::declval<T>())), //
        decltype(GetBodyB(std::declval<T>())), //
        decltype(GetCollideConnected(std::declval<T>())), //
        decltype(ShiftOrigin(std::declval<T&>(), std::declval<Length2>())), //
        decltype(InitVelocity(std::declval<T&>(), std::declval<const Span<BodyConstraint>&>(),
                              std::declval<StepConf>(), std::declval<ConstraintSolverConf>())), //
        decltype(SolveVelocity(std::declval<T&>(), std::declval<const Span<BodyConstraint>&>(),
                               std::declval<StepConf>())), //
        decltype(SolvePosition(std::declval<T>(), std::declval<const Span<BodyConstraint>&>(),
                               std::declval<ConstraintSolverConf>())), //
        decltype(std::declval<T>() == std::declval<T>()), //
        decltype(Joint{std::declval<T>()})>> : std::true_type {
};

} // namespace detail

/// @brief Boolean value for whether the specified type is a valid joint type.
/// @see Joint.
template <class T>
inline constexpr bool IsValidJointTypeV = detail::IsValidJointType<T>::value;

// Free functions...

/// @brief Provides referenced access to the identified element of the given container.
BodyConstraint& At(const Span<BodyConstraint>& container, BodyID key);

/// @brief Converts the given joint into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> implementation from the LLVM Project.
/// @throws std::bad_cast If the given template parameter type isn't the type of this
///   joint's configuration value.
/// @see https://llvm.org/
/// @relatedalso Joint
template <typename T>
inline T TypeCast(const Joint& value)
{
    using RawType = std::remove_cv_t<std::remove_reference_t<T>>;
    static_assert(std::is_constructible_v<T, RawType const&>,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<std::add_const_t<RawType>>(&value);
    if (!tmp) {
        throw std::bad_cast();
    }
    return static_cast<T>(*tmp);
}

/// @brief Converts the given joint into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> implementation from the LLVM Project.
/// @see https://llvm.org/
/// @relatedalso Joint
template <typename T>
inline T TypeCast(Joint& value)
{
    using RawType = std::remove_cv_t<std::remove_reference_t<T>>;
    static_assert(std::is_constructible_v<T, RawType&>,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<RawType>(&value);
    if (!tmp) {
        throw std::bad_cast();
    }
    return static_cast<T>(*tmp);
}

/// @brief Converts the given joint into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> implementation from the LLVM Project.
/// @see https://llvm.org/
/// @relatedalso Joint
template <typename T>
inline T TypeCast(Joint&& value)
{
    using RawType = std::remove_cv_t<std::remove_reference_t<T>>;
    static_assert(std::is_constructible_v<T, RawType>,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<RawType>(&value);
    if (!tmp) {
        throw std::bad_cast();
    }
    return static_cast<T>(std::move(*tmp));
}

template <typename T>
inline std::add_pointer_t<std::add_const_t<T>> TypeCast(const Joint* value) noexcept
{
    static_assert(!std::is_reference_v<T>, "T may not be a reference.");
    using ReturnType = std::add_pointer_t<T>;
    if (value && value->m_impl && (GetType(*value) == GetTypeID<T>())) {
        return static_cast<ReturnType>(value->m_impl->GetData_());
    }
    return nullptr;
}

template <typename T>
inline std::add_pointer_t<T> TypeCast(Joint* value) noexcept
{
    static_assert(!std::is_reference_v<T>, "T may not be a reference.");
    using ReturnType = std::add_pointer_t<T>;
    if (value && value->m_impl && (GetType(*value) == GetTypeID<T>())) {
        return static_cast<ReturnType>(value->m_impl->GetData_());
    }
    return nullptr;
}

/// @brief Gets whether the given entity is in the is-destroyed state.
/// @relatedalso Joint
inline auto IsDestroyed(const Joint &object) noexcept -> bool
{
    return !object.has_value();
}

/// Get the anchor point on body-A in local coordinates.
/// @relatedalso Joint
Length2 GetLocalAnchorA(const Joint& object);

/// Get the anchor point on body-B in local coordinates.
/// @relatedalso Joint
Length2 GetLocalAnchorB(const Joint& object);

/// Get the linear reaction on body-B at the joint anchor.
/// @relatedalso Joint
Momentum2 GetLinearReaction(const Joint& object);

/// Get the angular reaction on body-B.
/// @relatedalso Joint
AngularMomentum GetAngularReaction(const Joint& object);

/// @brief Gets the reference angle of the joint if it has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Angle GetReferenceAngle(const Joint& object);

/// @brief Gets the given joint's local X axis A if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
UnitVec GetLocalXAxisA(const Joint& object);

/// @brief Gets the given joint's local Y axis A if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
UnitVec GetLocalYAxisA(const Joint& object);

/// @brief Gets the given joint's motor speed if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
AngularVelocity GetMotorSpeed(const Joint& object);

/// @brief Sets the given joint's motor speed if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void SetMotorSpeed(Joint& object, AngularVelocity value);

/// @brief Gets the given joint's max force if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Force GetMaxForce(const Joint& object);

/// @brief Gets the given joint's max torque if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Torque GetMaxTorque(const Joint& object);

/// @brief Gets the given joint's max motor force if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Force GetMaxMotorForce(const Joint& object);

/// @brief Sets the given joint's max motor force if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void SetMaxMotorForce(Joint& object, Force value);

/// @brief Gets the given joint's max motor torque if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Torque GetMaxMotorTorque(const Joint& object);

/// @brief Sets the given joint's max motor torque if its type supports that.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void SetMaxMotorTorque(Joint& object, Torque value);

/// @brief Gets the given joint's angular mass.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
RotInertia GetAngularMass(const Joint& object);

/// @brief Gets the given joint's ratio property if it has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Real GetRatio(const Joint& object);

/// @brief Gets the given joint's damping ratio property if it has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Real GetDampingRatio(const Joint& object);

/// @brief Gets the frequency of the joint if it has this property.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Frequency GetFrequency(const Joint& object);

/// @brief Sets the frequency of the joint if it has this property.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void SetFrequency(Joint& object, Frequency value);

/// @brief Gets the angular motor impulse of the joint if it has this property.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
AngularMomentum GetAngularMotorImpulse(const Joint& object);

/// @brief Gets the given joint's target property if it has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Length2 GetTarget(const Joint& object);

/// @brief Sets the given joint's target property if it has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void SetTarget(Joint& object, const Length2& value);

/// Gets the lower linear joint limit.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Length GetLinearLowerLimit(const Joint& object);

/// Gets the upper linear joint limit.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Length GetLinearUpperLimit(const Joint& object);

/// Sets the joint limits.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void SetLinearLimits(Joint& object, Length lower, Length upper);

/// Gets the lower joint limit.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Angle GetAngularLowerLimit(const Joint& object);

/// @brief Gets the upper joint limit.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Angle GetAngularUpperLimit(const Joint& object);

/// @brief Sets the joint limits.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void SetAngularLimits(Joint& object, Angle lower, Angle upper);

/// @brief Gets the specified joint's limit property if it supports one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
bool IsLimitEnabled(const Joint& object);

/// @brief Enables the specified joint's limit property if it supports one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void EnableLimit(Joint& object, bool value);

/// @brief Gets the specified joint's motor property value if it supports one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
bool IsMotorEnabled(const Joint& object);

/// @brief Enables the specified joint's motor property if it supports one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void EnableMotor(Joint& object, bool value);

/// @brief Gets the linear offset property of the specified joint if its type has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Length2 GetLinearOffset(const Joint& object);

/// @brief Sets the linear offset property of the specified joint if its type has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void SetLinearOffset(Joint& object, const Length2& value);

/// @brief Gets the angular offset property of the specified joint if its type has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Angle GetAngularOffset(const Joint& object);

/// @brief Sets the angular offset property of the specified joint if its type has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
void SetAngularOffset(Joint& object, Angle value);

/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
LimitState GetLimitState(const Joint& object);

/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Length2 GetGroundAnchorA(const Joint& object);

/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Length2 GetGroundAnchorB(const Joint& object);

/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Momentum GetLinearMotorImpulse(const Joint& object);

/// @brief Gets the length property of the specified joint if its type has one.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
Length GetLength(const Joint& object);

/// @brief Gets the current motor torque for the given joint given the inverse time step.
/// @throws std::invalid_argument If not supported for the given joint's type.
/// @relatedalso Joint
inline Torque GetMotorTorque(const Joint& joint, Frequency inv_dt)
{
    return GetAngularMotorImpulse(joint) * inv_dt;
}

} // namespace playrho::d2

#endif // PLAYRHO_D2_JOINT_HPP
