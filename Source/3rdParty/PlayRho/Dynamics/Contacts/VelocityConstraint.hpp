/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#ifndef PLAYRHO_DYNAMICS_CONTACTS_VELOCITYCONSTRAINT_HPP
#define PLAYRHO_DYNAMICS_CONTACTS_VELOCITYCONSTRAINT_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Dynamics/Contacts/BodyConstraint.hpp"

namespace playrho {

class StepConf;

namespace d2 {

class WorldManifold;

/// Contact velocity constraint.
///
/// @note A valid contact velocity constraint must have a point count of either 1 or 2.
/// @note This data structure is 136-bytes large (on at least one 64-bit platform).
///
/// @invariant The "K" value cannot be changed independent of: the total inverse mass,
///   the normal, and the point relative positions.
/// @invariant The normal mass cannot be changed independent of: the "K" value.
/// @invariant The velocity biases cannot be changed independent of: the normal, and the
///   point relative positions.
///
class VelocityConstraint
{
public:
    
    /// @brief Size type.
    using size_type = std::remove_const<decltype(MaxManifoldPoints)>::type;
    
    /// @brief Configuration data for velocity constraints.
    struct Conf
    {
        Real dtRatio = 1; ///< Delta time ratio.
        LinearVelocity velocityThreshold = DefaultVelocityThreshold; ///< Velocity threshold.
        bool blockSolve = true; ///< Whether to block solve.
    };
    
    /// @brief Gets the default configuration for a <code>VelocityConstraint</code>.
    static PLAYRHO_CONSTEXPR inline Conf GetDefaultConf() noexcept
    {
        return Conf{};
    }

    /// Default constructor.
    /// @details
    /// Initializes object with: a zero point count, an invalid K, an invalid normal mass,
    /// an invalid normal, invalid friction, invalid restitution, an invalid tangent speed.
    VelocityConstraint() = default;
    
    /// @brief Copy constructor.
    VelocityConstraint(const VelocityConstraint& copy) = default;
    
    /// @brief Assignment operator.
    VelocityConstraint& operator= (const VelocityConstraint& copy) = default;
    
    /// @brief Initializing constructor.
    VelocityConstraint(Real friction, Real restitution, LinearVelocity tangentSpeed,
                       const WorldManifold& worldManifold,
                       BodyConstraint& bA,
                       BodyConstraint& bB,
                       Conf conf = GetDefaultConf());
    
    /// Gets the normal of the contact in world coordinates.
    /// @note This value is set on construction.
    /// @return Contact normal (in world coordinates) if previously set, an invalid value
    ///   otherwise.
    UnitVec GetNormal() const noexcept { return m_normal; }
    
    /// @brief Gets the tangent.
    UnitVec GetTangent() const noexcept { return GetFwdPerpendicular(m_normal); }
    
    /// Gets the count of points added to this object.
    /// @return Value between 0 and <code>MaxManifoldPoints</code>.
    /// @sa MaxManifoldPoints.
    /// @sa AddPoint.
    size_type GetPointCount() const noexcept { return m_pointCount; }
    
    /// Gets the "K" value.
    /// @note This value is only valid if previously set to a valid value.
    /// @return "K" value previously set or the zero initialized value.
    InvMass22 GetK() const noexcept;
    
    /// Gets the normal mass.
    /// @note This value is only valid if previously set.
    /// @return normal mass previously set or the zero initialized value.
    Mass22 GetNormalMass() const noexcept;
    
    /// Gets the combined friction of the associated contact.
    Real GetFriction() const noexcept { return m_friction; }
    
    /// Gets the combined restitution of the associated contact.
    Real GetRestitution() const noexcept { return m_restitution; }
    
    /// Gets the tangent speed of the associated contact.
    LinearVelocity GetTangentSpeed() const noexcept { return m_tangentSpeed; }
    
    /// @brief Gets body A.
    BodyConstraint* GetBodyA() const noexcept { return m_bodyA; }
    
    /// @brief Gets body B.
    BodyConstraint* GetBodyB() const noexcept { return m_bodyB; }
    
    /// Gets the normal impulse at the given point.
    /// @note Call the <code>AddPoint</code> or <code>SetNormalImpulseAtPoint</code> method
    ///   to set this value.
    /// @return Value previously set, or an invalid value.
    /// @sa SetNormalImpulseAtPoint.
    Momentum GetNormalImpulseAtPoint(size_type index) const noexcept;
    
    /// Gets the tangent impulse at the given point.
    /// @note Call the <code>AddPoint</code> or <code>SetTangentImpulseAtPoint</code> method
    ///   to set this value.
    /// @return Value previously set, or an invalid value.
    /// @sa SetTangentImpulseAtPoint.
    Momentum GetTangentImpulseAtPoint(size_type index) const noexcept;
    
    /// Gets the velocity bias at the given point.
    /// @note The <code>AddPoint</code> method sets this value.
    /// @return Previously set value or an invalid value.
    LinearVelocity GetVelocityBiasAtPoint(size_type index) const noexcept;
    
    /// Gets the normal mass at the given point.
    /// @note This value depends on the values of:
    ///   the sum of the inverse-masses of the two bodies,
    ///   the bodies' inverse-rotational-inertia,
    ///   the point-relative A and B positions, and
    ///   the normal.
    /// @note The <code>AddPoint</code> method sets this value.
    Mass GetNormalMassAtPoint(size_type index) const noexcept;
    
    /// Gets the tangent mass at the given point.
    /// @note This value depends on the values of:
    ///   the sum of the inverse-masses of the two bodies,
    ///   the bodies' inverse-rotational-inertia,
    ///   the point-relative A and B positions, and
    ///   the tangent.
    /// @note The <code>AddPoint</code> method sets this value.
    Mass GetTangentMassAtPoint(size_type index) const noexcept;
    
    /// Gets the point relative position of A.
    /// @note The <code>AddPoint</code> method sets this value.
    /// @return Previously set value or an invalid value.
    Length2 GetPointRelPosA(size_type index) const noexcept;
    
    /// Gets the point relative position of B.
    /// @note The <code>AddPoint</code> method sets this value.
    /// @return Previously set value or an invalid value.
    Length2 GetPointRelPosB(size_type index) const noexcept;
    
    /// @brief Sets the normal impulse at the given point.
    void SetNormalImpulseAtPoint(size_type index, Momentum value);
    
    /// @brief Sets the tangent impulse at the given point.
    void SetTangentImpulseAtPoint(size_type index, Momentum value);
    
    /// @brief Velocity constraint point.
    ///
    /// @note Default initialized to values that make this point ineffective if it got
    ///   processed counter to being a valid point per the point count property.
    ///   This allows both points to be unconditionally processed which may be faster
    ///   if it'd otherwise cause branch misprediction and depending on the cost of
    ///   branch misprediction.
    /// @note This structure is at least 36-bytes large.
    ///
    struct Point
    {
        /// Position of body A relative to world manifold point.
        Length2 relA = Length2{};
        
        /// Position of body B relative to world manifold point.
        Length2 relB = Length2{};
        
        /// Normal impulse.
        Momentum normalImpulse = 0_Ns;
        
        /// Tangent impulse.
        Momentum tangentImpulse = 0_Ns;
        
        /// Normal mass.
        /// @note 0 or greater.
        /// @note Dependent on <code>relA</code> and <code>relB</code>.
        Mass normalMass = 0_kg;
        
        /// Tangent mass.
        /// @note 0 or greater.
        /// @note Dependent on <code>relA</code> and <code>relB</code>.
        Mass tangentMass = 0_kg;
        
        /// Velocity bias.
        /// @note A product of the contact restitution.
        LinearVelocity velocityBias = 0_mps;
    };
    
    /// @brief Accesses the point identified by the given index.
    /// @warning Behavior is undefined if given index is not less than
    ///   <code>MaxManifoldPoints</code>.
    /// @param index Index of the point to return. This should be a value less than returned
    ///   by <code>GetPointCount</code>.
    /// @return velocity constraint point for the given index. This point's data will be invalid
    ///   unless previously added and set.
    /// @sa GetPointCount.
    const Point& GetPointAt(size_type index) const
    {
        assert(index < MaxManifoldPoints);
        return m_points[index];
    }
    
private:
    
    /// @brief Adds the given point to this contact velocity constraint object.
    /// @details Adds up to <code>MaxManifoldPoints</code> points. To find out how many points
    ///   have already been added, call <code>GetPointCount</code>.
    /// @warning Behavior is undefined if an attempt is made to add more than
    ///   <code>MaxManifoldPoints</code> points.
    /// @sa GetPointCount().
    void AddPoint(Momentum normalImpulse, Momentum tangentImpulse,
                  Length2 relA, Length2 relB, Conf conf);
    
    /// Removes the last point added.
    void RemovePoint() noexcept;
    
    /// @brief Gets a point instance for the given parameters.
    Point GetPoint(Momentum normalImpulse, Momentum tangentImpulse,
                   Length2 relA, Length2 relB, Conf conf) const noexcept;
    
    /// Accesses the point identified by the given index.
    /// @warning Behavior is undefined if given index is not less than
    ///   <code>MaxManifoldPoints</code>.
    /// @param index Index of the point to return. This should be a value less than returned
    ///   by <code>GetPointCount</code>.
    /// @return velocity constraint point for the given index. This point's data will be invalid
    ///   unless previously added and set.
    /// @sa GetPointCount.
    Point& PointAt(size_type index)
    {
        assert(index < MaxManifoldPoints);
        return m_points[index];
    }
    
    Point m_points[MaxManifoldPoints]; ///< Velocity constraint points array (at least 72-bytes).
    
    // K and normalMass fields are only used for the block solver.
    
    /// Block solver "K" info.
    /// @note Depends on the total inverse mass, the normal, and the point relative positions.
    /// @note Only used by block solver.
    /// @note This field is 12-bytes (on at least one 64-bit platform).
    InvMass3 m_K = InvMass3{};
    
    /// Normal mass information.
    /// @details This is the cached inverse of the K value or the zero initialized value.
    /// @note Depends on the K value.
    /// @note Only used by block solver.
    /// @note This field is 12-bytes (on at least one 64-bit platform).
    Mass3 m_normalMass = Mass3{};
    
    BodyConstraint* m_bodyA = nullptr; ///< Body A contact velocity constraint data.
    BodyConstraint* m_bodyB = nullptr; ///< Body B contact velocity constraint data.
    
    UnitVec m_normal = GetInvalid<UnitVec>(); ///< Normal of the world manifold. 8-bytes.
    
    /// Friction coefficient (4-bytes). Usually in the range of [0,1].
    Real m_friction = GetInvalid<Real>();
    
    Real m_restitution = GetInvalid<Real>(); ///< Restitution coefficient (4-bytes).
    
    LinearVelocity m_tangentSpeed = GetInvalid<decltype(m_tangentSpeed)>(); ///< Tangent speed (4-bytes).
    
    size_type m_pointCount = 0; ///< Point count (at least 1-byte).
};

inline void VelocityConstraint::RemovePoint() noexcept
{
    assert(m_pointCount > 0);
    m_points[m_pointCount - 1] = Point{};
    --m_pointCount;
}

inline InvMass22 VelocityConstraint::GetK() const noexcept
{
    return InvMass22{
        InvMass2{get<0>(m_K), get<2>(m_K)},
        InvMass2{get<2>(m_K), get<1>(m_K)}
    };
}

inline Mass22 VelocityConstraint::GetNormalMass() const noexcept
{
    return Mass22{
        Mass2{get<0>(m_normalMass), get<2>(m_normalMass)},
        Mass2{get<2>(m_normalMass), get<1>(m_normalMass)}
    };
}

inline Length2 VelocityConstraint::GetPointRelPosA(VelocityConstraint::size_type index) const noexcept
{
    return GetPointAt(index).relA;
}

inline Length2 VelocityConstraint::GetPointRelPosB(VelocityConstraint::size_type index) const noexcept
{
    return GetPointAt(index).relB;
}

inline LinearVelocity VelocityConstraint::GetVelocityBiasAtPoint(size_type index) const noexcept
{
    return GetPointAt(index).velocityBias;
}

inline Mass VelocityConstraint::GetNormalMassAtPoint(VelocityConstraint::size_type index) const noexcept
{
    return GetPointAt(index).normalMass;
}

inline Mass VelocityConstraint::GetTangentMassAtPoint(VelocityConstraint::size_type index) const noexcept
{
    return GetPointAt(index).tangentMass;
}

inline Momentum VelocityConstraint::GetNormalImpulseAtPoint(VelocityConstraint::size_type index) const noexcept
{
    return GetPointAt(index).normalImpulse;
}

inline Momentum VelocityConstraint::GetTangentImpulseAtPoint(VelocityConstraint::size_type index) const noexcept
{
    return GetPointAt(index).tangentImpulse;
}

inline void VelocityConstraint::SetNormalImpulseAtPoint(VelocityConstraint::size_type index, Momentum value)
{
    PointAt(index).normalImpulse = value;
}

inline void VelocityConstraint::SetTangentImpulseAtPoint(VelocityConstraint::size_type index, Momentum value)
{
    PointAt(index).tangentImpulse = value;
}

// Free functions...

/// @brief Gets the regular phase velocity constraint configuration from the given
///   step configuration.
VelocityConstraint::Conf GetRegVelocityConstraintConf(const StepConf& conf) noexcept;

/// @brief Gets the TOI phase velocity constraint configuration from the given
///   step configuration.
VelocityConstraint::Conf GetToiVelocityConstraintConf(const StepConf& conf) noexcept;

/// Gets the normal of the velocity constraint contact in world coordinates.
/// @note This value is set via the velocity constraint's <code>SetNormal</code> method.
/// @return Contact normal (in world coordinates) if previously set, an invalid value
///   otherwise.
inline UnitVec GetNormal(const VelocityConstraint& vc) noexcept
{
    return vc.GetNormal();
}

/// @brief Gets the tangent from the given velocity constraint data.
inline UnitVec GetTangent(const VelocityConstraint& vc) noexcept
{
    return vc.GetTangent();
}

/// @brief Gets the inverse mass from the given velocity constraint data.
inline InvMass GetInvMass(const VelocityConstraint& vc) noexcept
{
    return vc.GetBodyA()->GetInvMass() + vc.GetBodyB()->GetInvMass();
}

/// @brief Gets the point relative position A data.
inline Length2 GetPointRelPosA(const VelocityConstraint& vc,
                                VelocityConstraint::size_type index)
{
    return vc.GetPointRelPosA(index);
}

/// @brief Gets the point relative position B data.
inline Length2 GetPointRelPosB(const VelocityConstraint& vc,
                                VelocityConstraint::size_type index)
{
    return vc.GetPointRelPosB(index);
}

/// @brief Gets the velocity bias at the given point from the given velocity constraint.
inline LinearVelocity GetVelocityBiasAtPoint(const VelocityConstraint& vc, VelocityConstraint::size_type index)
{
    return vc.GetVelocityBiasAtPoint(index);
}

/// @brief Gets the normal mass at the given point from the given velocity constraint.
inline Mass GetNormalMassAtPoint(const VelocityConstraint& vc,
                                 VelocityConstraint::size_type index)
{
    return vc.GetNormalMassAtPoint(index);
}

/// @brief Gets the tangent mass at the given point from the given velocity constraint.
inline Mass GetTangentMassAtPoint(const VelocityConstraint& vc,
                                  VelocityConstraint::size_type index)
{
    return vc.GetTangentMassAtPoint(index);
}

/// @brief Gets the normal impulse at the given point from the given velocity constraint.
inline Momentum GetNormalImpulseAtPoint(const VelocityConstraint& vc,
                                        VelocityConstraint::size_type index)
{
    return vc.GetNormalImpulseAtPoint(index);
}

/// @brief Gets the tangent impulse at the given point from the given velocity constraint.
inline Momentum GetTangentImpulseAtPoint(const VelocityConstraint& vc,
                                         VelocityConstraint::size_type index)
{
    return vc.GetTangentImpulseAtPoint(index);
}

/// @brief Gets the normal impulses of the given velocity constraint.
inline Momentum2 GetNormalImpulses(const VelocityConstraint& vc)
{
    return Momentum2{GetNormalImpulseAtPoint(vc, 0), GetNormalImpulseAtPoint(vc, 1)};
}

/// @brief Gets the tangent impulses of the given velocity constraint.
inline Momentum2 GetTangentImpulses(const VelocityConstraint& vc)
{
    return Momentum2{GetTangentImpulseAtPoint(vc, 0), GetTangentImpulseAtPoint(vc, 1)};
}

/// @brief Sets the normal impulse at the given point of the given velocity constraint.
inline void SetNormalImpulseAtPoint(VelocityConstraint& vc, VelocityConstraint::size_type index, Momentum value)
{
    vc.SetNormalImpulseAtPoint(index, value);
}

/// @brief Sets the tangent impulse at the given point of the given velocity constraint.
inline void SetTangentImpulseAtPoint(VelocityConstraint& vc, VelocityConstraint::size_type index, Momentum value)
{
    vc.SetTangentImpulseAtPoint(index, value);
}

/// @brief Sets the normal impulses of the given velocity constraint.
inline void SetNormalImpulses(VelocityConstraint& vc, const Momentum2 impulses)
{
    SetNormalImpulseAtPoint(vc, 0, impulses[0]);
    SetNormalImpulseAtPoint(vc, 1, impulses[1]);
}

/// @brief Sets the tangent impulses of the given velocity constraint.
inline void SetTangentImpulses(VelocityConstraint& vc, const Momentum2 impulses)
{
    SetTangentImpulseAtPoint(vc, 0, impulses[0]);
    SetTangentImpulseAtPoint(vc, 1, impulses[1]);
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTS_VELOCITYCONSTRAINT_HPP
