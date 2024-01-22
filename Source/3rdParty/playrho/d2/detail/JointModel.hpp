/*
 * Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_D2_DETAIL_JOINTMODEL_HPP
#define PLAYRHO_D2_DETAIL_JOINTMODEL_HPP

/// @file
/// @brief Definition of the internal @c JointModel class.

#include <utility> // for std::move, std::forward
#include <type_traits> // for std::is_nothrow_constructible_v

#include "playrho/d2/detail/JointConcept.hpp"

namespace playrho::d2::detail {

/// @brief Internal joint model type.
/// @note Provides the implementation for runtime value polymorphism.
template <typename T>
struct JointModel final : JointConcept {
    /// @brief Type alias for the type of the data held.
    using data_type = T;

    /// @brief Initializing constructor.
    template <typename U, std::enable_if_t<!std::is_same_v<U, JointModel>, int> = 0>
    explicit JointModel(U&& arg) noexcept(std::is_nothrow_constructible_v<T, U>)
        : data{std::forward<U>(arg)}
    {
        // Intentionally empty.
    }

    /// @copydoc JointConcept::Clone_
    std::unique_ptr<JointConcept> Clone_() const override
    {
        return std::make_unique<JointModel<T>>(data);
    }

    /// @copydoc JointConcept::GetType_
    TypeID GetType_() const noexcept override
    {
        return GetTypeID<data_type>();
    }

    /// @copydoc JointConcept::GetData_
    const void* GetData_() const noexcept override
    {
        // Note address of "data" not necessarily same as address of "this" since
        // base class is virtual.
        return &data;
    }

    /// @copydoc JointConcept::GetData_
    void* GetData_() noexcept override
    {
        // Note address of "data" not necessarily same as address of "this" since
        // base class is virtual.
        return &data;
    }

    bool IsEqual_(const JointConcept& other) const noexcept override
    {
        // Would be preferable to do this without using any kind of RTTI system.
        // But how would that be done?
        return (GetType_() == other.GetType_()) &&
               (data == *static_cast<const T*>(other.GetData_()));
    }

    /// @copydoc JointConcept::GetBodyA_
    BodyID GetBodyA_() const noexcept override
    {
        return GetBodyA(data);
    }

    /// @copydoc JointConcept::GetBodyB_
    BodyID GetBodyB_() const noexcept override
    {
        return GetBodyB(data);
    }

    /// @copydoc JointConcept::GetCollideConnected_
    bool GetCollideConnected_() const noexcept override
    {
        return GetCollideConnected(data);
    }

    /// @copydoc JointConcept::ShiftOrigin_
    bool ShiftOrigin_(const Length2& value) noexcept override
    {
        return ShiftOrigin(data, value);
    }

    /// @copydoc JointConcept::InitVelocity_
    void InitVelocity_(const Span<BodyConstraint>& bodies, const playrho::StepConf& step,
                       const ConstraintSolverConf& conf) override
    {
        InitVelocity(data, bodies, step, conf);
    }

    /// @copydoc JointConcept::SolveVelocity_
    bool SolveVelocity_(const Span<BodyConstraint>& bodies, const playrho::StepConf& step) override
    {
        return SolveVelocity(data, bodies, step);
    }

    /// @copydoc JointConcept::SolvePosition_
    bool SolvePosition_(const Span<BodyConstraint>& bodies,
                        const ConstraintSolverConf& conf) const override
    {
        return SolvePosition(data, bodies, conf);
    }

    data_type data; ///< Data.
};

} // namespace playrho::d2::detail

#endif // PLAYRHO_D2_DETAIL_JOINTMODEL_HPP
