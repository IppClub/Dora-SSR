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

#ifndef PLAYRHO_D2_DETAIL_WORLDMODEL_HPP
#define PLAYRHO_D2_DETAIL_WORLDMODEL_HPP

/// @file
/// @brief Definitions of the WorldModel class and closely related code.

#include <type_traits> // for std::is_same_v, is_nothrow_constructible_v, etc.
#include <utility> // for std::forward

#include "playrho/d2/detail/WorldConcept.hpp"

namespace playrho::d2::detail {

/// @brief Interface between type class template instantiated for and the WorldConcept class.
/// @see WorldConcept.
template <class T>
struct WorldModel final: WorldConcept {
    /// @brief Type alias for the type of the data held.
    using data_type = T;

    /// @brief Initializing constructor.
    template <typename U, std::enable_if_t<!std::is_same_v<U, WorldModel>, int> = 0>
    explicit WorldModel(U&& arg) noexcept(std::is_nothrow_constructible_v<T, U>)
        : data{std::forward<U>(arg)}
    {
        // Intentionally empty.
    }

    // Listener Member Functions

    /// @copydoc WorldConcept::SetShapeDestructionListener_
    void SetShapeDestructionListener_(ShapeFunction listener) noexcept override
    {
        SetShapeDestructionListener(data, std::move(listener));
    }

    /// @copydoc WorldConcept::SetDetachListener_
    void SetDetachListener_(BodyShapeFunction listener) noexcept override
    {
        SetDetachListener(data, std::move(listener));
    }

    /// @copydoc WorldConcept::SetJointDestructionListener_
    void SetJointDestructionListener_(JointFunction listener) noexcept override
    {
        SetJointDestructionListener(data, std::move(listener));
    }

    /// @copydoc WorldConcept::SetBeginContactListener_
    void SetBeginContactListener_(ContactFunction listener) noexcept override
    {
        SetBeginContactListener(data, std::move(listener));
    }

    /// @copydoc WorldConcept::SetEndContactListener_
    void SetEndContactListener_(ContactFunction listener) noexcept override
    {
        SetEndContactListener(data, std::move(listener));
    }

    /// @copydoc WorldConcept::SetPreSolveContactListener_
    void SetPreSolveContactListener_(ContactManifoldFunction listener) noexcept override
    {
        SetPreSolveContactListener(data, std::move(listener));
    }

    /// @copydoc WorldConcept::SetPostSolveContactListener_
    void SetPostSolveContactListener_(ContactImpulsesFunction listener) noexcept override
    {
        SetPostSolveContactListener(data, std::move(listener));
    }

    // Miscellaneous Member Functions

    /// @copydoc WorldConcept::Clone_
    std::unique_ptr<WorldConcept> Clone_() const override
    {
        return std::make_unique<WorldModel<T>>(data);
    }

    /// @copydoc WorldConcept::GetType_
    TypeID GetType_() const noexcept override
    {
        return GetTypeID<data_type>();
    }

    /// @copydoc WorldConcept::GetData_
    const void* GetData_() const noexcept override
    {
        // Note address of "data" not necessarily same as address of "this" since
        // base class is virtual.
        return &data;
    }

    /// @copydoc WorldConcept::GetData_
    void* GetData_() noexcept override
    {
        // Note address of "data" not necessarily same as address of "this" since
        // base class is virtual.
        return &data;
    }

    bool IsEqual_(const WorldConcept& other) const noexcept override
    {
        // Would be preferable to do this without using any kind of RTTI system.
        // But how would that be done?
        return (GetType_() == other.GetType_()) &&
               (data == *static_cast<const T*>(other.GetData_()));
    }

    /// @copydoc WorldConcept::GetResourceStats_
    std::optional<pmr::StatsResource::Stats> GetResourceStats_() const noexcept override
    {
        return GetResourceStats(data);
    }

    /// @copydoc WorldConcept::Clear_
    void Clear_() noexcept override
    {
        Clear(data);
    }

    /// @copydoc WorldConcept::Step_
    StepStats Step_(const StepConf& conf) override
    {
        return Step(data, conf);
    }

    /// @copydoc WorldConcept::IsStepComplete_
    bool IsStepComplete_() const noexcept override
    {
        return IsStepComplete(data);
    }

    /// @copydoc WorldConcept::GetSubStepping_
    bool GetSubStepping_() const noexcept override
    {
        return GetSubStepping(data);
    }

    /// @copydoc WorldConcept::SetSubStepping_
    void SetSubStepping_(bool flag) noexcept override
    {
        SetSubStepping(data, flag);
    }

    /// @copydoc WorldConcept::GetTree_
    const DynamicTree& GetTree_() const noexcept override
    {
        return GetTree(data);
    }

    /// @copydoc WorldConcept::IsLocked_
    bool IsLocked_() const noexcept override
    {
        return IsLocked(data);
    }

    /// @copydoc WorldConcept::ShiftOrigin_
    void ShiftOrigin_(const Length2& newOrigin) override
    {
        ShiftOrigin(data, newOrigin);
    }

    /// @copydoc WorldConcept::GetVertexRadiusInterval_
    Interval<Positive<Length>> GetVertexRadiusInterval_() const noexcept override
    {
        return GetVertexRadiusInterval(data);
    }

    /// @copydoc WorldConcept::GetInvDeltaTime_
    Frequency GetInvDeltaTime_() const noexcept override
    {
        return GetInvDeltaTime(data);
    }

    // Body Member Functions.

    /// @copydoc WorldConcept::GetBodyRange_
    BodyCounter GetBodyRange_() const noexcept override
    {
        return GetBodyRange(data);
    }

    /// @copydoc WorldConcept::GetBodies_
    std::vector<BodyID> GetBodies_() const override
    {
        return GetBodies(data);
    }

    /// @copydoc WorldConcept::GetBodiesForProxies_
    std::vector<BodyID> GetBodiesForProxies_() const override
    {
        return GetBodiesForProxies(data);
    }

    /// @copydoc WorldConcept::CreateBody_
    BodyID CreateBody_(const Body& body) override
    {
        return CreateBody(data, body);
    }

    /// @copydoc WorldConcept::GetBody_
    Body GetBody_(BodyID id) const override
    {
        return GetBody(data, id);
    }

    /// @copydoc WorldConcept::SetBody_
    void SetBody_(BodyID id, const Body& value) override
    {
        SetBody(data, id, value);
    }

    /// @copydoc WorldConcept::Destroy_(BodyID)
    void Destroy_(BodyID id) override
    {
        Destroy(data, id);
    }

    /// @copydoc WorldConcept::GetJoints_(BodyID) const
    std::vector<std::pair<BodyID, JointID>> GetJoints_(BodyID id) const override
    {
        return GetJoints(data, id);
    }

    /// @copydoc WorldConcept::GetContacts_(BodyID) const
    std::vector<std::tuple<ContactKey, ContactID>> GetContacts_(BodyID id) const override
    {
        return GetContacts(data, id);
    }

    /// @copydoc WorldConcept::GetShapes_
    std::vector<ShapeID> GetShapes_(BodyID id) const override
    {
        return GetShapes(data, id);
    }

    // Joint Member Functions

    /// @copydoc WorldConcept::GetJointRange_
    JointCounter GetJointRange_() const noexcept override
    {
        return GetJointRange(data);
    }

    /// @copydoc WorldConcept::GetJoints_
    std::vector<JointID> GetJoints_() const override
    {
        return GetJoints(data);
    }

    /// @copydoc WorldConcept::CreateJoint_
    JointID CreateJoint_(const Joint& def) override
    {
        return CreateJoint(data, def);
    }

    /// @copydoc WorldConcept::GetJoint_
    Joint GetJoint_(JointID id) const override
    {
        return GetJoint(data, id);
    }

    /// @copydoc WorldConcept::SetJoint_
    void SetJoint_(JointID id, const Joint& def) override
    {
        return SetJoint(data, id, def);
    }

    /// @copydoc WorldConcept::Destroy_
    void Destroy_(JointID id) override
    {
        return Destroy(data, id);
    }

    // Shape Member Functions

    /// @copydoc WorldConcept::GetShapeRange_
    ShapeCounter GetShapeRange_() const noexcept override
    {
        return GetShapeRange(data);
    }

    /// @copydoc WorldConcept::CreateShape_
    ShapeID CreateShape_(const Shape& def) override
    {
        return CreateShape(data, def);
    }

    /// @copydoc WorldConcept::GetShape_
    Shape GetShape_(ShapeID id) const override
    {
        return GetShape(data, id);
    }

    /// @copydoc WorldConcept::SetShape_
    void SetShape_(ShapeID id, const Shape& def) override
    {
        SetShape(data, id, def);
    }

    /// @copydoc WorldConcept::Destroy_
    void Destroy_(ShapeID id) override
    {
        Destroy(data, id);
    }

    // Contact Member Functions

    /// @copydoc WorldConcept::GetContactRange_
    ContactCounter GetContactRange_() const noexcept override
    {
        return GetContactRange(data);
    }

    /// @copydoc WorldConcept::GetContacts_
    std::vector<KeyedContactID> GetContacts_() const override
    {
        return GetContacts(data);
    }

    /// @copydoc WorldConcept::GetContact_
    Contact GetContact_(ContactID id) const override
    {
        return GetContact(data, id);
    }

    /// @copydoc WorldConcept::SetContact_
    void SetContact_(ContactID id, const Contact& value) override
    {
        SetContact(data, id, value);
    }

    /// @copydoc WorldConcept::GetManifold_
    Manifold GetManifold_(ContactID id) const override
    {
        return GetManifold(data, id);
    }

    /// @copydoc WorldConcept::SetManifold_
    void SetManifold_(ContactID id, const Manifold& value) override
    {
        SetManifold(data, id, value);
    }

    // Member variables

    data_type data; ///< Data.
};

} // namespace playrho::d2::detail

#endif // PLAYRHO_D2_DETAIL_WORLDMODEL_HPP
