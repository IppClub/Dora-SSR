/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_FIXTURE_HPP
#define PLAYRHO_DYNAMICS_FIXTURE_HPP

/// @file
/// Declarations of the Fixture class, and free functions associated with it.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Span.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Dynamics/Filter.hpp"
#include "PlayRho/Dynamics/FixtureConf.hpp"
#include "PlayRho/Dynamics/FixtureProxy.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"
#include <limits>
#include <memory>
#include <vector>
#include <array>

namespace playrho {
namespace d2 {

class Body;

/// @brief An association between a body and a shape.
///
/// @details A fixture is used to attach a shape to a body for collision detection. A fixture
/// inherits its transform from its parent. Fixtures hold additional non-geometric data
/// such as collision filters, etc.
///
/// @warning you cannot reuse fixtures.
/// @note Fixtures should be created using the <code>Body::CreateFixture</code> method.
/// @note Destroy these using the <code>Body::Destroy(Fixture*, bool)</code> method.
/// @note This structure is 56-bytes large (using a 4-byte Real on at least one 64-bit
///   architecture/build).
///
/// @ingroup PhysicalEntities
///
/// @sa Body, Shape
///
class Fixture
{
public:
    /// @brief Gets the parent body of this fixture.
    /// @return Non-null pointer to the parent body.
    NonNull<Body*> GetBody() const noexcept;
    
    /// @brief Gets the child shape.
    /// @details The shape is not modifiable. Use a new fixture instead.
    Shape GetShape() const noexcept;
    
    /// @brief Set if this fixture is a sensor.
    void SetSensor(bool sensor) noexcept;

    /// @brief Is this fixture a sensor (non-solid)?
    /// @return the true if the shape is a sensor.
    bool IsSensor() const noexcept;

    /// @brief Sets the contact filtering data.
    /// @note This won't update contacts until the next time step when either parent body
    ///    is speedable and awake.
    /// @note This automatically calls <code>Refilter</code>.
    void SetFilterData(Filter filter);

    /// @brief Gets the contact filtering data.
    Filter GetFilterData() const noexcept;

    /// @brief Re-filter the fixture.
    /// @note Call this if you want to establish collision that was previously disabled by
    ///   <code>ShouldCollide(const Fixture&, const Fixture&)</code>.
    /// @sa bool ShouldCollide(const Fixture& fixtureA, const Fixture& fixtureB) noexcept
    void Refilter();

    /// Get the user data that was assigned in the fixture definition. Use this to
    /// store your application specific data.
    void* GetUserData() const noexcept;

    /// @brief Sets the user data.
    /// @note Use this to store your application specific data.
    void SetUserData(void* data) noexcept;

    /// @brief Gets the density of this fixture.
    /// @return Non-negative density (in mass per area).
    AreaDensity GetDensity() const noexcept;

    /// @brief Gets the coefficient of friction.
    /// @return Value of 0 or higher.
    Real GetFriction() const noexcept;

    /// @brief Gets the coefficient of restitution.
    Real GetRestitution() const noexcept;

    /// @brief Gets the proxy count.
    /// @note This will be zero until a world step has been run since this fixture's
    ///   creation.
    ChildCounter GetProxyCount() const noexcept;

    /// @brief Gets the proxy for the given index.
    /// @warning Behavior is undefined if given an invalid index.
    /// @return Fixture proxy value.
    FixtureProxy GetProxy(ChildCounter index) const noexcept;
    
    /// @brief Gets the proxies.
    Span<const FixtureProxy> GetProxies() const noexcept;

private:

    friend class FixtureAtty;
    
    Fixture() = delete; // explicitly deleted
    
    /// @brief Copy constructor (explicitly deleted).
    Fixture(const Fixture& other) = delete;
    
    /// @brief Initializing constructor.
    ///
    /// @note This is not meant to be called by normal user code. Use the
    ///   <code>Body::CreateFixture</code> method instead.
    ///
    /// @param body Body the new fixture is to be associated with.
    /// @param def Initial fixture settings.
    ///    Friction must be greater-than-or-equal-to zero.
    ///    <code>AreaDensity</code> must be greater-than-or-equal-to zero.
    /// @param shape Shareable shape to associate fixture with. Must be non-null.
    ///
    Fixture(NonNull<Body*> body, const FixtureConf& def, const Shape& shape):
        m_body{body},
        m_userData{def.userData},
        m_shape{shape},
        m_filter{def.filter},
        m_isSensor{def.isSensor}
    {
        // Intentionally empty.
    }
    
    /// @brief Destructor.
    /// @pre Proxy count is zero.
    /// @warning Behavior is undefined if proxy count is greater than zero.
    ~Fixture()
    {
        // Intentionally empty.
    }
    
    /// @brief Fixture proxies union.
    union FixtureProxies {
        FixtureProxies() noexcept: asArray{} {}
        ~FixtureProxies() noexcept {}

        std::array<FixtureProxy, 2> asArray; ///< Values accessed as a local array.
        std::unique_ptr<FixtureProxy[]> asBuffer; ///< Values accessed as pointer to array.
    };
    
    /// @brief Sets the proxies.
    void SetProxies(std::unique_ptr<FixtureProxy[]> value, std::size_t count) noexcept;

    /// @brief Resets the proxies.
    void ResetProxies() noexcept;

    // Data ordered here for memory compaction.
    
    NonNull<Body*> const m_body; ///< Parent body. Set on construction. 8-bytes.

    void* m_userData = nullptr; ///< User data. 8-bytes.

    /// Shape (of fixture).
    /// @note Set on construction.
    /// @note Either null or pointer to a heap-memory private copy of the assigned shape.
    /// @note 16-bytes.
    Shape m_shape;
    
    FixtureProxies m_proxies; ///< Collection of fixture proxies for the assigned shape. 8-bytes.
    
    /// Proxy count.
    /// @details This is the fixture shape's child count after proxy creation. 4-bytes.
    ChildCounter m_proxyCount = 0;

    Filter m_filter; ///< Filter object. 6-bytes.
    
    bool m_isSensor = false; ///< Is/is-not sensor. 1-bytes.
};

inline Shape Fixture::GetShape() const noexcept
{
    return m_shape;
}

inline bool Fixture::IsSensor() const noexcept
{
    return m_isSensor;
}

inline Filter Fixture::GetFilterData() const noexcept
{
    return m_filter;
}

inline void* Fixture::GetUserData() const noexcept
{
    return m_userData;
}

inline void Fixture::SetUserData(void* data) noexcept
{
    m_userData = data;
}

inline NonNull<Body*> Fixture::GetBody() const noexcept
{
    return m_body;
}

inline ChildCounter Fixture::GetProxyCount() const noexcept
{
    return m_proxyCount;
}

inline void Fixture::SetFilterData(Filter filter)
{
    m_filter = filter;
    Refilter();
}

inline Span<const FixtureProxy> Fixture::GetProxies() const noexcept
{
    const auto ptr = (m_proxyCount <= 2)? &(m_proxies.asArray[0]): m_proxies.asBuffer.get();
    return Span<const FixtureProxy>(ptr, m_proxyCount);
}

inline void Fixture::SetProxies(std::unique_ptr<FixtureProxy[]> value, std::size_t count) noexcept
{
    assert(count < std::numeric_limits<ChildCounter>::max());
    switch (count)
    {
        case 2:
            m_proxies.asArray[1] = value[1];
            [[fallthrough]];
        case 1:
            m_proxies.asArray[0] = value[0];
            [[fallthrough]];
        case 0:
            break;
        default:
            m_proxies.asBuffer = std::move(value);
            break;
    }
    m_proxyCount = static_cast<decltype(m_proxyCount)>(count);
}

inline void Fixture::ResetProxies() noexcept
{
    if (m_proxyCount > 2)
    {
        m_proxies.asBuffer.reset();
    }
    m_proxyCount = 0;
}

inline Real Fixture::GetFriction() const noexcept
{
    return playrho::d2::GetFriction(m_shape);
}

inline Real Fixture::GetRestitution() const noexcept
{
    return playrho::d2::GetRestitution(m_shape);
}

inline AreaDensity Fixture::GetDensity() const noexcept
{
    return playrho::d2::GetDensity(m_shape);
}

// Free functions...

/// @brief Tests a point for containment in a fixture.
/// @param f Fixture to use for test.
/// @param p Point in world coordinates.
/// @relatedalso Fixture
/// @ingroup TestPointGroup
bool TestPoint(const Fixture& f, Length2 p) noexcept;

/// @brief Sets the associated body's sleep status to awake.
/// @note This is a convenience function that simply looks up the fixture's body and
///   calls that body' <code>SetAwake</code> method.
/// @param f Fixture whose body should be awoken.
/// @relatedalso Fixture
void SetAwake(const Fixture& f) noexcept;

/// @brief Gets the transformation associated with the given fixture.
/// @warning Behavior is undefined if the fixture doesn't have an associated body - i.e.
///   behavior is undefined if the fixture has <code>nullptr</code> as its associated body.
/// @relatedalso Fixture
Transformation GetTransformation(const Fixture& f) noexcept;

/// @brief Whether contact calculations should be performed between the two fixtures.
/// @return <code>true</code> if contact calculations should be performed between these
///   two fixtures; <code>false</code> otherwise.
/// @relatedalso Fixture
inline bool ShouldCollide(const Fixture& fixtureA, const Fixture& fixtureB) noexcept
{
    return ShouldCollide(fixtureA.GetFilterData(), fixtureB.GetFilterData());
}
    
} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_FIXTURE_HPP
