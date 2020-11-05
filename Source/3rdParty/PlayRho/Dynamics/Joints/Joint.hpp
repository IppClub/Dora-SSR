/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 * TypeCast code derived from the LLVM Project https://llvm.org/LICENSE.txt
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

#ifndef PLAYRHO_DYNAMICS_JOINTS_JOINT_HPP
#define PLAYRHO_DYNAMICS_JOINTS_JOINT_HPP

#include "PlayRho/Common/Math.hpp"

#include "PlayRho/Dynamics/Joints/JointType.hpp"
#include "PlayRho/Dynamics/Joints/LimitState.hpp"
#include "PlayRho/Dynamics/BodyID.hpp"

#include <memory> // for std::unique_ptr
#include <vector>
#include <utility>
#include <stdexcept> // for std::bad_cast

namespace playrho {

struct StepConf;
struct ConstraintSolverConf;

namespace d2 {

class Joint;
class BodyConstraint;

// Forward declare functions.
// Note that these may be friend functions but that declaring these within the class that
// they're to be friends of, doesn't also insure that they're found within the namespace
// in terms of lookup.

/// @brief Gets the identifier of the type of data this can be casted to.
JointType GetType(const Joint& object) noexcept;

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
bool ShiftOrigin(Joint& object, Length2 value) noexcept;

/// @brief Initializes velocity constraint data based on the given solver data.
/// @note This MUST be called prior to calling <code>SolveVelocity</code>.
/// @see SolveVelocity.
void InitVelocity(Joint& object, std::vector<BodyConstraint>& bodies,
                  const StepConf& step,
                  const ConstraintSolverConf& conf);

/// @brief Solves velocity constraint.
/// @pre <code>InitVelocity</code> has been called.
/// @see InitVelocity.
/// @return <code>true</code> if velocity is "solved", <code>false</code> otherwise.
bool SolveVelocity(Joint& object, std::vector<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @return <code>true</code> if the position errors are within tolerance.
bool SolvePosition(const Joint& object, std::vector<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @defgroup JointsGroup Joint Classes
/// @brief The user creatable classes that specify constraints on one or more body instances.
/// @ingroup ConstraintsGroup

/// @brief Joint class.
/// @details This is a concrete manifestation of the joint concept. Joints are constraints
///   that are used to constrain one or more bodies in various fashions. Some joints also
///   feature limits and motors.
/// @note This class's design provides a "polymorphic value type" offering polymorphism
///   without public inheritance. This is based on a technique that's described by Sean Parent
///   in his January 2017 Norwegian Developers Conference London talk "Better Code: Runtime
///   Polymorphism".
/// @ingroup JointsGroup
/// @ingroup PhysicalEntities
/// @see https://youtu.be/QGcVXgEVMJg
/// @see https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Polymorphic_Value_Types
class Joint
{
public:
    /// @brief Body constraints map type alias.
    using BodyConstraintsMap = std::vector<BodyConstraint>;

    /// @brief Default constructor.
    Joint() noexcept = default;

    /// @brief Initializing constructor.
    template <typename T>
    Joint(T arg): m_self{std::make_unique<Model<T>>(std::move(arg))}
    {
        // Intentionally empty.
    }

    /// @brief Copy constructor.
    Joint(const Joint& other): m_self{other.m_self? other.m_self->Clone_(): nullptr}
    {
        // Intentionally empty.
    }

    /// @brief Move constructor.
    Joint(Joint&& other) noexcept: m_self{std::move(other.m_self)}
    {
        // Intentionally empty.
    }

    /// @brief Copy assignment.
    Joint& operator= (const Joint& other)
    {
        m_self = other.m_self? other.m_self->Clone_(): nullptr;
        return *this;
    }

    /// @brief Move assignment.
    Joint& operator= (Joint&& other) noexcept
    {
        m_self = std::move(other.m_self);
        return *this;
    }

    /// @brief Move assignment support for any valid underlying configuration.
    template <typename T, typename Tp = std::decay_t<T>,
        typename = std::enable_if_t<
            !std::is_same<Tp, Joint>::value && std::is_copy_constructible<Tp>::value
        >
    >
    Joint& operator= (T&& other) noexcept
    {
        Joint(std::forward<T>(other)).swap(*this);
        return *this;
    }

    /// @brief Swap function.
    void swap(Joint& other) noexcept
    {
        std::swap(m_self, other.m_self);
    }

    friend JointType GetType(const Joint& object) noexcept
    {
        return object.m_self? object.m_self->GetType_(): GetTypeID<void>();
    }

    template <typename T>
    friend std::add_pointer_t<std::add_const_t<T>> TypeCast(const Joint* value) noexcept;

    template <typename T>
    friend std::add_pointer_t<T> TypeCast(Joint* value) noexcept;

    friend BodyID GetBodyA(const Joint& object) noexcept
    {
        return object.m_self? object.m_self->GetBodyA_(): InvalidBodyID;
    }

    friend BodyID GetBodyB(const Joint& object) noexcept
    {
        return object.m_self? object.m_self->GetBodyB_(): InvalidBodyID;
    }

    friend bool GetCollideConnected(const Joint& object) noexcept
    {
        return object.m_self? object.m_self->GetCollideConnected_(): false;
    }

    friend bool ShiftOrigin(Joint& object, Length2 value) noexcept
    {
        return object.m_self? object.m_self->ShiftOrigin_(value): false;
    }

    friend void InitVelocity(Joint& object, std::vector<BodyConstraint>& bodies,
                             const playrho::StepConf& step,
                             const ConstraintSolverConf& conf)
    {
        if (object.m_self) object.m_self->InitVelocity_(bodies, step, conf);
    }

    friend bool SolveVelocity(Joint& object, std::vector<BodyConstraint>& bodies,
                              const playrho::StepConf& step)
    {
        return object.m_self? object.m_self->SolveVelocity_(bodies, step): false;
    }

    friend bool SolvePosition(const Joint& object, std::vector<BodyConstraint>& bodies,
                              const ConstraintSolverConf& conf)
    {
        return object.m_self? object.m_self->SolvePosition_(bodies, conf): false;
    }

private:
    /// @brief Internal configuration concept.
    /// @note Provides the interface for runtime value polymorphism.
    struct Concept
    {
        /// @brief Explicitly declared virtual destructor.
        virtual ~Concept() = default;

        /// @brief Clones this concept and returns a pointer to a mutable copy.
        /// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
        ///   by the constructor for the model's underlying data type.
        /// @throws std::bad_alloc if there's a failure allocating storage.
        virtual std::unique_ptr<Concept> Clone_() const = 0;

        /// @brief Gets the use type information.
        /// @return Type info of the underlying value's type.
        virtual TypeID GetType_() const noexcept = 0;

        /// @brief Gets the data for the underlying configuration.
        virtual const void* GetData_() const noexcept = 0;

        /// @brief Gets the data for the underlying configuration.
        virtual void* GetData_() noexcept = 0;

        /// @brief Gets the ID of body-A.
        virtual BodyID GetBodyA_() const noexcept = 0;

        /// @brief Gets the ID of body-B.
        virtual BodyID GetBodyB_() const noexcept = 0;

        /// @brief Gets whether collision handling should be done for connected bodies.
        virtual bool GetCollideConnected_() const noexcept = 0;

        /// @brief Call to notify joint of a shift in the world origin.
        virtual bool ShiftOrigin_(Length2 value) noexcept = 0;

        /// @brief Initializes the velocities for this joint.
        virtual void InitVelocity_(BodyConstraintsMap& bodies,
                                   const playrho::StepConf& step,
                                   const ConstraintSolverConf& conf) = 0;

        /// @brief Solves the velocities for this joint.
        virtual bool SolveVelocity_(BodyConstraintsMap& bodies,
                                    const playrho::StepConf& step) = 0;

        /// @brief Solves the positions for this joint.
        virtual bool SolvePosition_(BodyConstraintsMap& bodies,
                                    const ConstraintSolverConf& conf) const = 0;
    };

    /// @brief Internal model configuration concept.
    /// @note Provides the implementation for runtime value polymorphism.
    template <typename T>
    struct Model final: Concept
    {
        /// @brief Type alias for the type of the data held.
        using data_type = T;

        /// @brief Initializing constructor.
        Model(T arg): data{std::move(arg)} {}

        /// @copydoc Concept::Clone_
        std::unique_ptr<Concept> Clone_() const override
        {
            return std::make_unique<Model>(data);
        }

        /// @copydoc Concept::GetType_
        TypeID GetType_() const noexcept override
        {
            return GetTypeID<data_type>();
        }

        /// @copydoc Concept::GetData_
        const void* GetData_() const noexcept override
        {
            // Note address of "data" not necessarily same as address of "this" since
            // base class is virtual.
            return &data;
        }

        /// @copydoc Concept::GetData_
        void* GetData_() noexcept override
        {
            // Note address of "data" not necessarily same as address of "this" since
            // base class is virtual.
            return &data;
        }

        /// @copydoc Concept::GetBodyA_
        BodyID GetBodyA_() const noexcept override
        {
            return GetBodyA(data);
        }

        /// @copydoc Concept::GetBodyB_
        BodyID GetBodyB_() const noexcept override
        {
            return GetBodyB(data);
        }

        /// @copydoc Concept::GetCollideConnected_
        bool GetCollideConnected_() const noexcept override
        {
            return GetCollideConnected(data);
        }

        /// @copydoc Concept::ShiftOrigin_
        bool ShiftOrigin_(Length2 value) noexcept override
        {
            return ShiftOrigin(data, value);
        }

        /// @copydoc Concept::InitVelocity_
        void InitVelocity_(BodyConstraintsMap& bodies,
                           const playrho::StepConf& step,
                           const ConstraintSolverConf& conf) override
        {
            InitVelocity(data, bodies, step, conf);
        }

        /// @copydoc Concept::SolveVelocity_
        bool SolveVelocity_(BodyConstraintsMap& bodies,
                            const playrho::StepConf& step) override
        {
            return SolveVelocity(data, bodies, step);
        }

        /// @copydoc Concept::SolvePosition_
        bool SolvePosition_(BodyConstraintsMap& bodies,
                            const ConstraintSolverConf& conf) const override
        {
            return SolvePosition(data, bodies, conf);
        }

        data_type data; ///< Data.
    };

    std::unique_ptr<Concept> m_self; ///< Self pointer.
};

// Free functions...

/// @brief Provides referenced access to the identified element of the given container.
BodyConstraint& At(std::vector<BodyConstraint>& container, BodyID key);

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
    static_assert(std::is_constructible<T, RawType const &>::value,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<std::add_const_t<RawType>>(&value);
    if (tmp == nullptr)
        throw std::bad_cast();
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
    static_assert(std::is_constructible<T, RawType &>::value,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<RawType>(&value);
    if (tmp == nullptr)
        throw std::bad_cast();
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
    static_assert(std::is_constructible<T, RawType>::value,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<RawType>(&value);
    if (tmp == nullptr)
        throw std::bad_cast();
    return static_cast<T>(std::move(*tmp));
}

template <typename T>
inline std::add_pointer_t<std::add_const_t<T>> TypeCast(const Joint* value) noexcept
{
    static_assert(!std::is_reference<T>::value, "T may not be a reference.");
    return ::playrho::d2::TypeCast<T>(const_cast<Joint*>(value));
}

template <typename T>
inline std::add_pointer_t<T> TypeCast(Joint* value) noexcept
{
    static_assert(!std::is_reference<T>::value, "T may not be a reference.");
    using ReturnType = std::add_pointer_t<T>;
    if (value && value->m_self && (GetType(*value) == GetTypeID<T>())) {
        return static_cast<ReturnType>(value->m_self->GetData_());
    }
    return nullptr;
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
void SetTarget(Joint& object, Length2 value);

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
void SetLinearOffset(Joint& object, Length2 value);

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

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_JOINT_HPP
