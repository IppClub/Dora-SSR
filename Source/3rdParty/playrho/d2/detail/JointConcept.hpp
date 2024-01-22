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

#ifndef PLAYRHO_D2_DETAIL_JOINTCONCEPT_HPP
#define PLAYRHO_D2_DETAIL_JOINTCONCEPT_HPP

/// @file
/// @brief Definition of the internal @c JointConcept interface class.

#include <memory> // for std::unique_ptr

#include "playrho/BodyID.hpp"
#include "playrho/Span.hpp"
#include "playrho/TypeInfo.hpp" // for TypeID
#include "playrho/Vector2.hpp" // for Length2

namespace playrho {
struct StepConf;
struct ConstraintSolverConf;
}

namespace playrho::d2 {
class BodyConstraint;
}

namespace playrho::d2::detail {

/// @brief Internal joint concept interface.
/// @note Provides the interface for runtime value polymorphism.
struct JointConcept {
    /// @brief Explicitly declared virtual destructor.
    virtual ~JointConcept() = default;

    /// @brief Clones this concept and returns a pointer to a mutable copy.
    /// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
    ///   by the constructor for the model's underlying data type.
    /// @throws std::bad_alloc if there's a failure allocating storage.
    virtual std::unique_ptr<JointConcept> Clone_() const = 0;

    /// @brief Gets the use type information.
    /// @return Type info of the underlying value's type.
    virtual TypeID GetType_() const noexcept = 0;

    /// @brief Gets the data for the underlying configuration.
    virtual const void* GetData_() const noexcept = 0;

    /// @brief Gets the data for the underlying configuration.
    virtual void* GetData_() noexcept = 0;

    /// @brief Equality checking function.
    virtual bool IsEqual_(const JointConcept& other) const noexcept = 0;

    /// @brief Gets the ID of body-A.
    virtual BodyID GetBodyA_() const noexcept = 0;

    /// @brief Gets the ID of body-B.
    virtual BodyID GetBodyB_() const noexcept = 0;

    /// @brief Gets whether collision handling should be done for connected bodies.
    virtual bool GetCollideConnected_() const noexcept = 0;

    /// @brief Call to notify joint of a shift in the world origin.
    virtual bool ShiftOrigin_(const Length2& value) noexcept = 0;

    /// @brief Initializes the velocities for this joint.
    virtual void InitVelocity_(const Span<BodyConstraint>& bodies, const StepConf& step,
                               const ConstraintSolverConf& conf) = 0;

    /// @brief Solves the velocities for this joint.
    virtual bool SolveVelocity_(const Span<BodyConstraint>& bodies, const StepConf& step) = 0;

    /// @brief Solves the positions for this joint.
    virtual bool SolvePosition_(const Span<BodyConstraint>& bodies,
                                const ConstraintSolverConf& conf) const = 0;
};

} // namespace playrho::d2::detail

#endif // PLAYRHO_D2_DETAIL_JOINTCONCEPT_HPP
