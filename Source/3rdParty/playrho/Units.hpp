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

/**
 * @file
 *
 * @brief Declarations for physical units possibly backed by strong types.
 *
 * @details This file establishes quantity aliases, unit constants, and associated code
 *   for the expression of physical quantities using recognizably named units of those
 *   quantities. Quantities, as used herein, are types associated with physical quantities
 *   like time and length. Conceptually a given quantity is only expressable in units that
 *   relate to that quantity. For every quantity defined herein, there's typically at least
 *   one conceptually typed unit asscociated with it.
 *
 * @note In the simplest way that the PlayRho library can be configured, there's no compiler
 *   enforcement on the usage of the units for their associated quantities beyond the usage
 *   of the Real type.
 */

#ifndef PLAYRHO_UNITS_HPP
#define PLAYRHO_UNITS_HPP

#include <cmath>
#include <type_traits>

// IWYU pragma: begin_exports

#include "playrho/Real.hpp"
#include "playrho/RealConstants.hpp"
#include "playrho/Templates.hpp"
#include "playrho/to_underlying.hpp"

// IWYU pragma: end_exports

// #define PLAYRHO_USE_BOOST_UNITS
#if defined(PLAYRHO_USE_BOOST_UNITS)
#include <boost/units/io.hpp>
#include <boost/units/limits.hpp>
#include <boost/units/cmath.hpp>
#include <boost/units/systems/si/length.hpp>
#include <boost/units/systems/si/time.hpp>
#include <boost/units/systems/si/velocity.hpp>
#include <boost/units/systems/si/acceleration.hpp>
#include <boost/units/systems/si/frequency.hpp>
#include <boost/units/systems/si/mass.hpp>
#include <boost/units/systems/si/momentum.hpp>
#include <boost/units/systems/si/area.hpp>
#include <boost/units/systems/si/plane_angle.hpp>
#include <boost/units/systems/si/angular_momentum.hpp>
#include <boost/units/systems/si/angular_velocity.hpp>
#include <boost/units/systems/si/angular_acceleration.hpp>
#include <boost/units/systems/si/surface_density.hpp>
#include <boost/units/systems/si/moment_of_inertia.hpp>
#include <boost/units/systems/si/force.hpp>
#include <boost/units/systems/si/torque.hpp>
#include <boost/units/systems/angle/degrees.hpp>

/// Name space for PlayRho declarations and definitions of units.
/// @note This serves as a safer, less-invasive alternative to extending the
///   <code>boost::units</code> name space.
namespace playrho::units {

/// Derived dimension for inverse mass : M^-1
using inverse_mass_dimension =
    boost::units::derived_dimension<boost::units::mass_base_dimension, -1>::type;

/// Derived dimension for area : L^4
using second_moment_of_area_dimension =
    boost::units::derived_dimension<boost::units::length_base_dimension, 4>::type;

/// Derived dimension for inverse moment of inertia : L^-2 M^-1 QP^2
using inverse_moment_of_inertia_dimension =
    boost::units::derived_dimension<boost::units::length_base_dimension, -2,
                                    boost::units::mass_base_dimension, -1,
                                    boost::units::plane_angle_base_dimension, 2>::type;

} // namespace playrho::units

/// Name space for PlayRho declarations and definitions for the International System of Units.
/// @note This serves as a safer, less-invasive alternative to extending the
///   <code>boost::units::si</code> name space.
namespace playrho::units::si {

/// Inverse mass.
using inverse_mass =
    boost::units::unit<playrho::units::inverse_mass_dimension, boost::units::si::system>;

/// Second moment of area.
using second_moment_of_area =
    boost::units::unit<playrho::units::second_moment_of_area_dimension, boost::units::si::system>;

/// Inverse moment of inertia.
using inverse_moment_of_inertia =
    boost::units::unit<playrho::units::inverse_moment_of_inertia_dimension,
                       boost::units::si::system>;

} // namespace playrho::units::si

#endif // defined(PLAYRHO_USE_BOOST_UNITS)

namespace playrho {

namespace detail {

/// @brief Seconds per minute.
constexpr auto SecondsPerMinute = 60;

/// @brief Minutes per hour.
constexpr auto MinutesPerHour = 60;

/// @brief Hours per day.
constexpr auto HoursPerDay = 24;

// Setup quantity types...
#if defined(PLAYRHO_USE_BOOST_UNITS)
using time = boost::units::quantity<boost::units::si::time, Real>;
using frequency = boost::units::quantity<boost::units::si::frequency, Real>;
using length = boost::units::quantity<boost::units::si::length, Real>;
using velocity = boost::units::quantity<boost::units::si::velocity, Real>;
using acceleration = boost::units::quantity<boost::units::si::acceleration, Real>;
using mass = boost::units::quantity<boost::units::si::mass, Real>;
using inverse_mass = boost::units::quantity<playrho::units::si::inverse_mass, Real>;
using area = boost::units::quantity<boost::units::si::area, Real>;
using surface_density = boost::units::quantity<boost::units::si::surface_density, Real>;
using plane_angle = boost::units::quantity<boost::units::si::plane_angle, Real>;
using angular_velocity = boost::units::quantity<boost::units::si::angular_velocity, Real>;
using angular_acceleration = boost::units::quantity<boost::units::si::angular_acceleration, Real>;
using force = boost::units::quantity<boost::units::si::force, Real>;
using torque = boost::units::quantity<boost::units::si::torque, Real>;
using second_moment_of_area = boost::units::quantity<playrho::units::si::second_moment_of_area, Real>;
using moment_of_inertia = boost::units::quantity<boost::units::si::moment_of_inertia, Real>;
using inverse_moment_of_inertia = boost::units::quantity<playrho::units::si::inverse_moment_of_inertia, Real>;
using momentum = boost::units::quantity<boost::units::si::momentum, Real>;
using angular_momentum = boost::units::quantity<boost::units::si::angular_momentum, Real>;
#else // !defined(PLAYRHO_USE_BOOST_UNITS)
using time = Real; ///< Time quantity type.
using frequency = Real; ///< Frequency quantity type.
using length = Real; ///< Length quantity type.
using velocity = Real; ///< Velocity quantity type.
using acceleration = Real; ///< Acceleration quantity type.
using mass = Real; ///< Mass quantity type.
using inverse_mass = Real; ///< Inverse mass quantity type.
using area = Real; ///< Area quantity type.
using surface_density = Real; ///< Surface density quantity type.
using plane_angle = Real; ///< Plane angle quantity type.
using angular_velocity = Real; ///< Angular velocity quantity type.
using angular_acceleration = Real; ///< Angular acceleration quantity type.
using force = Real; ///< Force quantity type.
using torque = Real; ///< Torque quantity type.
using second_moment_of_area = Real; ///< 2nd moment of area quantity type.
using moment_of_inertia = Real; ///< 2nd momemnt of inertia quantity type.
using inverse_moment_of_inertia = Real; ///< Inverse moment of inertia quantity type.
using momentum = Real; ///< Linear momentum quantity type.
using angular_momentum = Real; ///< Angular momemntum quantity type.
#endif // defined(PLAYRHO_USE_BOOST_UNITS)

// Setup unit types...
#if defined(PLAYRHO_USE_BOOST_UNITS)
constexpr auto second = 1 * boost::units::si::second;
constexpr auto hertz = 1 * boost::units::si::hertz;
constexpr auto meter = 1 * boost::units::si::meter;
constexpr auto meter_per_second = 1 * boost::units::si::meter_per_second;
constexpr auto meter_per_second_squared = 1 * boost::units::si::meter_per_second_squared;
constexpr auto kilogram = 1 * boost::units::si::kilogram;
constexpr auto square_meter = 1 * boost::units::si::square_meter;
constexpr auto kilogram_per_square_meter = 1 * boost::units::si::kilogram_per_square_meter;
constexpr auto radian = 1 * boost::units::si::radian;
constexpr auto radian_per_second = 1 * boost::units::si::radian_per_second;
constexpr auto newton = 1 * boost::units::si::newton;
constexpr auto newton_meter = 1 * boost::units::si::newton_meter;
#else // !defined(PLAYRHO_USE_BOOST_UNITS)
constexpr auto second = 1; ///< Second unit value.
constexpr auto hertz = 1; ///< Hertz unit value.
constexpr auto meter = 1; ///< Meter unit value.
constexpr auto meter_per_second = 1; ///< Meter per second unit value.
constexpr auto meter_per_second_squared = 1; ///< Meter per second^2 unit value.
constexpr auto kilogram = 1; ///< Kilogram unit value.
constexpr auto square_meter = 1; ///< Square meter unit value.
constexpr auto kilogram_per_square_meter = 1; ///< Kilogram per meter^2 unit value.
constexpr auto radian = 1; ///< Radian unit value.
constexpr auto radian_per_second = 1; ///< Radian per second unit value.
constexpr auto newton = 1; ///< Newton unit value.
constexpr auto newton_meter = 1; ///< Newton meter unit value.
#endif // defined(PLAYRHO_USE_BOOST_UNITS)

/// @brief Alias for getting the return type of a @c get() member function.
template<class T>
using get_member_type = decltype(std::declval<T&>().get());

}

/// @defgroup PhysicalQuantities Physical Quantity Types
/// @brief Types for physical quantities.
/// @details These are the type aliases for physical quantities like time and length
///   that are used by the PlayRho library.
///   Conceptually a given quantity is only expressable in the units that are defined
///   for that quantity.
/// @see PhysicalUnits
/// @see https://en.wikipedia.org/wiki/List_of_physical_quantities
/// @{

/// @brief Time quantity.
/// @details This is the type alias for the time base quantity.
/// @note This quantity's dimension is: time (<code>T</code>).
/// @note The SI unit of time is the second.
/// @see Second.
/// @see https://en.wikipedia.org/wiki/Time_in_physics
using Time = detail::time;

/// @brief Frequency quantity.
/// @details This is the type alias for the frequency quantity. It's a derived quantity
///   that's the inverse of time.
/// @note This quantity's dimension is: inverse time (<code>T^-1</code>).
/// @note The SI unit of frequency is the hertz.
/// @see Time.
/// @see Hertz.
/// @see https://en.wikipedia.org/wiki/Frequency
using Frequency = detail::frequency;

/// @brief Length quantity.
/// @details This is the type alias for the length base quantity.
/// @note This quantity's dimension is: length (<code>L</code>).
/// @note The SI unit of length is the meter.
/// @see Meter.
/// @see https://en.wikipedia.org/wiki/Length
using Length = detail::length;

/// @brief Linear velocity quantity.
/// @details This is the type alias for the linear velocity derived quantity.
/// @note This quantity's dimensions are: length over time (<code>L T^-1</code>).
/// @note The SI unit of linear velocity is meters per second.
/// @see Length, Time.
/// @see MeterPerSecond.
/// @see https://en.wikipedia.org/wiki/Speed
using LinearVelocity = detail::velocity;

/// @brief Linear acceleration quantity.
/// @details This is the type alias for the linear acceleration derived quantity.
/// @note This quantity's dimensions are: length over time squared (<code>L T^-2</code>).
/// @note The SI unit of linear acceleration is meters per second squared.
/// @see Length, Time, LinearVelocity.
/// @see MeterPerSquareSecond.
/// @see https://en.wikipedia.org/wiki/Acceleration
using LinearAcceleration = detail::acceleration;

/// @brief Mass quantity.
/// @details This is the type alias for the mass base quantity.
/// @note This quantity's dimension is: mass (<code>M</code>).
/// @note The SI unit of mass is the kilogram.
/// @see Kilogram.
/// @see https://en.wikipedia.org/wiki/Mass
using Mass = detail::mass;

/// @brief Inverse mass quantity.
/// @details This is the type alias for the inverse mass quantity. It's a derived quantity
///   that's the inverse of mass.
/// @note This quantity's dimension is: inverse mass (<code>M^-1</code>).
/// @see Mass.
using InvMass = detail::inverse_mass;

/// @brief Area quantity.
/// @details This is the type alias for the area quantity. It's a derived quantity.
/// @note This quantity's dimension is: length squared (<code>L^2</code>).
/// @note The SI unit of area is the square-meter.
/// @see Length.
/// @see SquareMeter.
/// @see https://en.wikipedia.org/wiki/Area
using Area = detail::area;

/// @brief Area (surface) density quantity.
/// @details This is the type alias for the area density quantity. It's a derived quantity.
/// @note This quantity's dimensions are: mass per area (<code>M L^-2</code>).
/// @note The SI derived unit of area density is kilogram per meter-squared.
/// @see Mass, Area.
/// @see KilogramPerSquareMeter.
/// @see https://en.wikipedia.org/wiki/Area_density
using AreaDensity = detail::surface_density;

/// @brief Angle quantity.
/// @details This is the type alias for the plane angle base quantity.
/// @note This quantity's dimension is: plane angle (<code>QP</code>).
/// @see Radian, Degree.
using Angle = detail::plane_angle;

/// @brief Angular velocity quantity.
/// @details This is the type alias for the plane angular velocity quantity. It's a
///   derived quantity.
/// @note This quantity's dimensions are: plane angle per time (<code>QP T^-1</code>).
/// @note The SI derived unit of angular velocity is the radian per second.
/// @see Angle, Time.
/// @see RadianPerSecond, DegreePerSecond.
/// @see https://en.wikipedia.org/wiki/Angular_velocity
using AngularVelocity = detail::angular_velocity;

/// @brief Angular acceleration quantity.
/// @details This is the type alias for the angular acceleration quantity. It's a
///   derived quantity.
/// @note This quantity's dimensions are: plane angle per time squared (<code>QP T^-2</code>).
/// @note The SI derived unit of angular acceleration is the radian per second-squared.
/// @see Angle, Time, AngularVelocity.
/// @see RadianPerSquareSecond, DegreePerSquareSecond.
/// @see https://en.wikipedia.org/wiki/Angular_acceleration
using AngularAcceleration = detail::angular_acceleration;

/// @brief Force quantity.
/// @details This is the type alias for the force quantity. It's a derived quantity.
/// @note This quantity's dimensions are: length mass per time squared (<code>L M T^-2</code>).
/// @note The SI derived unit of force is the newton.
/// @see Length, Mass, Time.
/// @see Newton.
/// @see https://en.wikipedia.org/wiki/Force
using Force = detail::force;

/// @brief Torque quantity.
/// @details This is the type alias for the torque quantity. It's a derived quantity
///   that's a rotational force.
/// @note This quantity's dimensions are: length-squared mass per time-squared per
///   angle (<code>L^2 M T^-2 QP^-1</code>).
/// @note The SI derived unit of torque is the newton meter.
/// @see Length, Mass, Time, Angle.
/// @see NewtonMeter.
/// @see https://en.wikipedia.org/wiki/Torque
using Torque = detail::torque;

/// @brief Second moment of area quantity.
/// @details This is the type alias for the second moment of area quantity. It's a
///   derived quantity.
/// @note This quantity's dimensions are: length-squared-squared (<code>L^4</code>).
/// @see Length.
/// @see https://en.wikipedia.org/wiki/Second_moment_of_area
using SecondMomentOfArea = detail::second_moment_of_area;

/// @brief Rotational inertia quantity.
/// @details This is the type alias for the rotational inertia quantity. It's a
///   derived quantity that's also called the moment of inertia or angular mass.
/// @note This quantity's dimensions are: length-squared mass per angle-squared
///   (<code>L^2 M QP^-2</code>).
/// @note The SI derived unit of rotational inertia is the kilogram meter-squared
///   (<code>kg * m^2</code>).
/// @see Length, Mass, Angle, InvRotInertia.
/// @see https://en.wikipedia.org/wiki/Moment_of_inertia
using RotInertia = detail::moment_of_inertia;

/// @brief Inverse rotational inertia quantity.
/// @details This is the type alias for the inverse rotational inertia quantity. It's
///   a derived quantity.
/// @note This quantity's dimensions are: angle-squared per length-squared per mass
///    (<code>L^-2 M^-1 QP^2</code>).
/// @see Length, Mass, Angle, RotInertia.
using InvRotInertia = detail::inverse_moment_of_inertia;

/// @brief Momentum quantity.
/// @details This is the type alias for the momentum quantity. It's a derived quantity.
/// @note This quantity's dimensions are: length mass per time (<code>L M T^-1</code>).
/// @note The SI derived unit of momentum is the kilogram meter per second.
/// @note If <code>p</code> is momentum, <code>m</code> is mass, and <code>v</code> is
///   velocity, then <code>p = m * v</code>.
/// @see Length, Mass, Time.
/// @see NewtonSecond.
/// @see https://en.wikipedia.org/wiki/Momentum
using Momentum = detail::momentum;

/// @brief Angular momentum quantity.
/// @details This is the type alias for the angular momentum quantity. It's a derived
///   quantity.
/// @note This quantity's dimensions are: length-squared mass per time per angle
///    (<code>L^2 M T^-1 QP^-1</code>).
/// @note The SI derived unit of angular momentum is the kilogram meter-squared per second.
/// @see Length, Mass, Time, Angle, Momentum.
/// @see NewtonMeterSecond.
/// @see https://en.wikipedia.org/wiki/Angular_momentum
using AngularMomentum = detail::angular_momentum;

/// @}

/// @defgroup PhysicalUnits Units For Physical Quantities
/// @brief Units for expressing physical quantities like time and length.
/// @details These are the unit definitions for expressing physical quantities like time
///   and length. Conceptually a given unit is only usable with the quantities that are
///   made up of the dimensions which the unit is associated with.
/// @see PhysicalQuantities.
/// @{

/// @brief Second unit of time.
/// @note This is the SI base unit of time.
/// @see Time.
/// @see https://en.wikipedia.org/wiki/Second
constexpr auto Second = Time(detail::second);

/// @brief Square second unit.
/// @see Second
constexpr auto SquareSecond = Second * Second;

/// @brief Hertz unit of Frequency.
/// @details Represents the hertz unit of frequency (Hz).
/// @see Frequency.
/// @see https://en.wikipedia.org/wiki/Hertz
constexpr auto Hertz = Frequency(detail::hertz);

/// @brief Meter unit of Length.
/// @details A unit of the length quantity.
/// @note This is the SI base unit of length.
/// @see Length.
/// @see https://en.wikipedia.org/wiki/Metre
constexpr auto Meter = Length(detail::meter);

/// @brief Meter per second unit of linear velocity.
/// @see LinearVelocity.
constexpr auto MeterPerSecond = LinearVelocity(detail::meter_per_second);

/// @brief Meter per square second unit of linear acceleration.
/// @see LinearAcceleration.
constexpr auto MeterPerSquareSecond = LinearAcceleration(detail::meter_per_second_squared);

/// @brief Kilogram unit of mass.
/// @note This is the SI base unit of mass.
/// @see Mass.
/// @see https://en.wikipedia.org/wiki/Kilogram
constexpr auto Kilogram = Mass(detail::kilogram);

/// @brief Square meter unit of area.
/// @see Area.
constexpr auto SquareMeter = Area(detail::square_meter);

/// @brief Cubic meter unit of volume.
constexpr auto CubicMeter = Meter * Meter * Meter;

/// @brief Kilogram per square meter unit of area density.
/// @see AreaDensity.
constexpr auto KilogramPerSquareMeter = AreaDensity(detail::kilogram_per_square_meter);

/// @brief Radian unit of angle.
/// @see Angle.
/// @see Degree.
constexpr auto Radian = Angle(detail::radian);

/// @brief Degree unit of angle quantity.
/// @see Angle.
/// @see Radian.
constexpr auto Degree = Angle{Radian * Pi / Real{180}};

/// @brief Square radian unit type.
/// @see Angle.
/// @see Radian.
constexpr auto SquareRadian = Radian * Radian;

/// @brief Radian per second unit of angular velocity.
/// @see AngularVelocity.
/// @see Radian, Second.
constexpr auto RadianPerSecond = AngularVelocity(detail::radian_per_second);

/// @brief Degree per second unit of angular velocity.
/// @see AngularVelocity.
/// @see Degree, Second.
constexpr auto DegreePerSecond = AngularVelocity{RadianPerSecond * Degree / Radian};

/// @brief Radian per square second unit of angular acceleration.
/// @see AngularAcceleration.
/// @see Radian, Second.
constexpr auto RadianPerSquareSecond = Radian / (Second * Second);

/// @brief Degree per square second unit of angular acceleration.
/// @see AngularAcceleration.
/// @see Degree, Second.
constexpr auto DegreePerSquareSecond = Degree / (Second * Second);

/// @brief Newton unit of force.
/// @see Force.
constexpr auto Newton = Force(detail::newton);

/// @brief Newton meter unit of torque.
/// @see Torque.
/// @see Newton, Meter.
constexpr auto NewtonMeter = Torque(detail::newton_meter);

/// @brief Newton second unit of momentum.
/// @see Momentum.
/// @see Newton, Second.
constexpr auto NewtonSecond = Newton * Second;

/// @brief Newton meter second unit of angular momentum.
/// @see AngularMomentum.
/// @see Newton, Meter, Second.
constexpr auto NewtonMeterSecond = NewtonMeter * Second;

/// @brief Revolutions per minute units of angular velocity.
/// @see AngularVelocity, Time
/// @see Minute.
constexpr auto RevolutionsPerMinute = 2 * Pi * Radian / (Real{detail::SecondsPerMinute} * Second);

/// @}

inline namespace literals {
inline namespace units {

/// @defgroup Unitsymbols Literals For Unit Symbols
/// @brief User defined literals for more conveniently setting the value of physical
///   quantities.
/// @see PhysicalQuantities
/// @see PhysicalUnits
/// @{

/// @brief SI unit symbol for a gram unit of Mass.
/// @see https://en.wikipedia.org/wiki/Gram
constexpr Mass operator"" _g(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * (Kilogram / Kilo);
}

/// @brief SI unit symbol for a gram unit of Mass.
/// @see https://en.wikipedia.org/wiki/Gram
constexpr Mass operator"" _g(long double v) noexcept
{
    return static_cast<Real>(v) * (Kilogram / Kilo);
}

/// @brief SI unit symbol for a kilogram unit of Mass.
/// @see Kilogram
/// @see https://en.wikipedia.org/wiki/Kilogram
constexpr Mass operator"" _kg(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Kilogram;
}

/// @brief SI unit symbol for a kilogram unit of Mass.
/// @see Kilogram
/// @see https://en.wikipedia.org/wiki/Kilogram
constexpr Mass operator"" _kg(long double v) noexcept
{
    return static_cast<Real>(v) * Kilogram;
}

/// @brief SI unit symbol for a petagram unit of Mass.
/// @see https://en.wikipedia.org/wiki/Orders_of_magnitude_(mass)
constexpr Mass operator"" _Pg(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Peta * (Kilogram / Kilo);
}

/// @brief SI unit symbol for a petagram unit of Mass.
/// @see https://en.wikipedia.org/wiki/Orders_of_magnitude_(mass)
constexpr Mass operator"" _Pg(long double v) noexcept
{
    return static_cast<Real>(v) * Peta * (Kilogram / Kilo);
}

/// @brief SI unit symbol for a yottagram unit of Mass.
/// @see https://en.wikipedia.org/wiki/Orders_of_magnitude_(mass)
constexpr Mass operator"" _Yg(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Yotta * (Kilogram / Kilo);
}

/// @brief SI unit symbol for a yottagram unit of Mass.
/// @see https://en.wikipedia.org/wiki/Orders_of_magnitude_(mass)
constexpr Mass operator"" _Yg(long double v) noexcept
{
    return static_cast<Real>(v) * Yotta * (Kilogram / Kilo);
}

/// @brief SI unit symbol for a meter of Length.
/// @see Meter
/// @see https://en.wikipedia.org/wiki/Metre
constexpr Length operator"" _m(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Meter;
}

/// @brief SI unit symbol for a meter of Length.
/// @see Meter
/// @see https://en.wikipedia.org/wiki/Metre
constexpr Length operator"" _m(long double v) noexcept
{
    return static_cast<Real>(v) * Meter;
}

/// @brief SI unit symbol for a decimeter of Length.
/// @see https://en.wikipedia.org/wiki/Decimetre
constexpr Length operator"" _dm(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Deci * Meter;
}

/// @brief SI unit symbol for a decimeter of Length.
/// @see https://en.wikipedia.org/wiki/Decimetre
constexpr Length operator"" _dm(long double v) noexcept
{
    return static_cast<Real>(v) * Deci * Meter;
}

/// @brief SI unit symbol for a centimeter of Length.
/// @see https://en.wikipedia.org/wiki/Centimetre
constexpr Length operator"" _cm(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Centi * Meter;
}

/// @brief SI unit symbol for a centimeter of Length.
/// @see https://en.wikipedia.org/wiki/Centimetre
constexpr Length operator"" _cm(long double v) noexcept
{
    return static_cast<Real>(v) * Centi * Meter;
}

/// @brief SI unit symbol for a gigameter unit of Length.
/// @see https://en.wikipedia.org/wiki/Gigametre
constexpr Length operator"" _Gm(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Giga * Meter;
}

/// @brief SI unit symbol for a gigameter unit of Length.
/// @see https://en.wikipedia.org/wiki/Gigametre
constexpr Length operator"" _Gm(long double v) noexcept
{
    return static_cast<Real>(v) * Giga * Meter;
}

/// @brief SI unit symbol for a megameter unit of Length.
/// @see https://en.wikipedia.org/wiki/Megametre
constexpr Length operator"" _Mm(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Mega * Meter;
}

/// @brief SI unit symbol for a megameter unit of Length.
/// @see https://en.wikipedia.org/wiki/Megametre
constexpr Length operator"" _Mm(long double v) noexcept
{
    return static_cast<Real>(v) * Mega * Meter;
}

/// @brief SI symbol for a kilometer unit of Length.
/// @see https://en.wikipedia.org/wiki/Kilometre
constexpr Length operator"" _km(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Kilo * Meter;
}

/// @brief SI symbol for a kilometer unit of Length.
/// @see https://en.wikipedia.org/wiki/Kilometre
constexpr Length operator"" _km(long double v) noexcept
{
    return static_cast<Real>(v) * Kilo * Meter;
}

/// @brief SI symbol for a second unit of Time.
/// @see Second
/// @see https://en.wikipedia.org/wiki/Second
constexpr Time operator"" _s(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Second;
}

/// @brief SI symbol for a second unit of Time.
/// @see Second
/// @see https://en.wikipedia.org/wiki/Second
constexpr Time operator"" _s(long double v) noexcept
{
    return static_cast<Real>(v) * Second;
}

/// @brief SI symbol for a minute unit of Time.
/// @see https://en.wikipedia.org/wiki/Minute
constexpr Time operator"" _min(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * detail::SecondsPerMinute * Second;
}

/// @brief SI symbol for a minute unit of Time.
/// @see https://en.wikipedia.org/wiki/Minute
constexpr Time operator"" _min(long double v) noexcept
{
    return static_cast<Real>(v) * detail::SecondsPerMinute * Second;
}

/// @brief Symbol for an hour unit of Time.
/// @see https://en.wikipedia.org/wiki/Hour
constexpr Time operator"" _h(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * detail::MinutesPerHour * detail::SecondsPerMinute * Second;
}

/// @brief Symbol for an hour unit of Time.
/// @see https://en.wikipedia.org/wiki/Hour
constexpr Time operator"" _h(long double v) noexcept
{
    return static_cast<Real>(v) * detail::MinutesPerHour * detail::SecondsPerMinute * Second;
}

/// @brief Symbol for a day unit of Time.
/// @see https://en.wikipedia.org/wiki/Day
constexpr Time operator"" _d(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * detail::HoursPerDay * detail::MinutesPerHour * detail::SecondsPerMinute * Second;
}

/// @brief Symbol for a day unit of Time.
/// @see https://en.wikipedia.org/wiki/Day
constexpr Time operator"" _d(long double v) noexcept
{
    return static_cast<Real>(v) * detail::HoursPerDay * detail::MinutesPerHour * detail::SecondsPerMinute * Second;
}

/// @brief SI symbol for a radian unit of Angle.
/// @see Radian.
/// @see https://en.wikipedia.org/wiki/Radian
constexpr Angle operator"" _rad(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Radian;
}

/// @brief SI symbol for a radian unit of Angle.
/// @see Radian.
/// @see https://en.wikipedia.org/wiki/Radian
constexpr Angle operator"" _rad(long double v) noexcept
{
    return static_cast<Real>(v) * Radian;
}

/// @brief Abbreviation for a degree unit of Angle.
/// @see Degree.
/// @see https://en.wikipedia.org/wiki/Degree_(angle)
constexpr Angle operator"" _deg(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Degree;
}

/// @brief Abbreviation for a degree unit of Angle.
/// @see Degree.
/// @see https://en.wikipedia.org/wiki/Degree_(angle)
constexpr Angle operator"" _deg(long double v) noexcept
{
    return static_cast<Real>(v) * Degree;
}

/// @brief SI symbol for a newton unit of Force.
/// @see Newton
/// @see https://en.wikipedia.org/wiki/Newton_(unit)
constexpr Force operator"" _N(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Newton;
}

/// @brief SI symbol for a newton unit of Force.
/// @see Newton
/// @see https://en.wikipedia.org/wiki/Newton_(unit)
constexpr Force operator"" _N(long double v) noexcept
{
    return static_cast<Real>(v) * Newton;
}

/// @brief Abbreviation for meter squared unit of Area.
/// @see SquareMeter
constexpr Area operator"" _m2(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * SquareMeter;
}

/// @brief Abbreviation for meter squared unit of Area.
/// @see SquareMeter
constexpr Area operator"" _m2(long double v) noexcept
{
    return static_cast<Real>(v) * SquareMeter;
}

/// @brief Abbreviation for meter per second.
/// @see https://en.wikipedia.org/wiki/Metre_per_second
/// @see Meter
/// @see Second
/// @see MeterPerSecond
constexpr LinearVelocity operator"" _mps(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * MeterPerSecond;
}

/// @brief Abbreviation for meter per second.
/// @see https://en.wikipedia.org/wiki/Metre_per_second
/// @see Meter
/// @see Second
/// @see MeterPerSecond
constexpr LinearVelocity operator"" _mps(long double v) noexcept
{
    return static_cast<Real>(v) * MeterPerSecond;
}

/// @brief Abbreviation for kilometer per second.
/// @see https://en.wikipedia.org/wiki/Metre_per_second
/// @see Second
constexpr LinearVelocity operator"" _kps(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Kilo * MeterPerSecond;
}

/// @brief Abbreviation for kilometer per second.
/// @see https://en.wikipedia.org/wiki/Metre_per_second
/// @see Second
constexpr LinearVelocity operator"" _kps(long double v) noexcept
{
    return static_cast<Real>(v) * Kilo * MeterPerSecond;
}

/// @brief Abbreviation for meter per second squared.
/// @see https://en.wikipedia.org/wiki/Metre_per_second_squared
/// @see MeterPerSquareSecond
constexpr LinearAcceleration operator"" _mps2(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * MeterPerSquareSecond;
}

/// @brief Abbreviation for meter per second squared.
/// @see https://en.wikipedia.org/wiki/Metre_per_second_squared
/// @see MeterPerSquareSecond
constexpr LinearAcceleration operator"" _mps2(long double v) noexcept
{
    return static_cast<Real>(v) * MeterPerSquareSecond;
}

/// @brief SI symbol for a hertz unit of Frequency.
/// @see Hertz
/// @see https://en.wikipedia.org/wiki/Hertz
constexpr Frequency operator"" _Hz(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * Hertz;
}

/// @brief SI symbol for a hertz unit of Frequency.
/// @see Hertz
/// @see https://en.wikipedia.org/wiki/Hertz
constexpr Frequency operator"" _Hz(long double v) noexcept
{
    return static_cast<Real>(v) * Hertz;
}

/// @brief Abbreviation for newton-meter unit of torque.
/// @see NewtonMeter
/// @see https://en.wikipedia.org/wiki/Newton_metre
constexpr Torque operator"" _Nm(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * NewtonMeter;
}

/// @brief Abbreviation for newton-meter unit of torque.
/// @see NewtonMeter
/// @see https://en.wikipedia.org/wiki/Newton_metre
constexpr Torque operator"" _Nm(long double v) noexcept
{
    return static_cast<Real>(v) * NewtonMeter;
}

/// @brief SI symbol for a newton second of impulse.
/// @see NewtonSecond
/// @see https://en.wikipedia.org/wiki/Newton_second
constexpr Momentum operator"" _Ns(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * NewtonSecond;
}

/// @brief SI symbol for a newton second of impulse.
/// @see NewtonSecond
/// @see https://en.wikipedia.org/wiki/Newton_second
constexpr Momentum operator"" _Ns(long double v) noexcept
{
    return static_cast<Real>(v) * NewtonSecond;
}

/// @brief Abbreviation for kilogram per square meter.
constexpr AreaDensity operator"" _kgpm2(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * KilogramPerSquareMeter;
}

/// @brief Abbreviation for kilogram per square meter.
constexpr AreaDensity operator"" _kgpm2(long double v) noexcept
{
    return static_cast<Real>(v) * KilogramPerSquareMeter;
}

/// @brief Abbreviation for revolutions per minute.
/// @see RevolutionsPerMinute
constexpr AngularVelocity operator"" _rpm(unsigned long long int v) noexcept
{
    return static_cast<Real>(v) * RevolutionsPerMinute;
}

/// @brief Abbreviation for revolutions per minute.
/// @see RevolutionsPerMinute
constexpr AngularVelocity operator"" _rpm(long double v) noexcept
{
    return static_cast<Real>(v) * RevolutionsPerMinute;
}

/// @}

} // namespace units
} // namespace literals

} // namespace playrho

namespace playrho { // hoist the unit literals into namespace playrho
using namespace literals::units;
} // namespace playrho

namespace playrho {

/// @brief Strips the units off of the given value.
template <class T>
constexpr auto StripUnit(const T& value)
-> std::enable_if_t<IsArithmeticV<T> && !detail::is_detected_v<detail::get_member_type, T>, T>
{
    return value;
}

/// @defgroup UnitConstants Physical Constants
/// @brief Definitions of universal and Earthly physical constants.
/// @see PhysicalQuantities
/// @see PhysicalUnits
/// @{

/// @brief Earthly gravity.
/// @details An approximation of the average acceleration of Earthly objects towards
///   the Earth due to the Earth's gravity.
/// @note This constant is only appropriate for use for objects of low mass and close
///   distance relative to the Earth.
/// @see https://en.wikipedia.org/wiki/Gravity_of_Earth
constexpr auto EarthlyLinearAcceleration = static_cast<Real>(-9.8f) * MeterPerSquareSecond;

/// @brief Big "G".
/// @details Gravitational constant used in calculating the attractive force on a mass
///   to another mass at a given distance due to gravity.
/// @see https://en.wikipedia.org/wiki/Gravitational_constant
constexpr auto BigG = static_cast<Real>(6.67408e-11f) * CubicMeter / (Kilogram * SquareSecond);

/// @}

#if defined(PLAYRHO_USE_BOOST_UNITS)
using boost::units::cos;
using boost::units::isfinite;
using boost::units::isnormal;
using boost::units::sin;

// Don't use boost's hypot since it does type promotion which is problematic.
// using boost::units::hypot;

/// @brief Gets the hypotenuse.
/// @note Don't use boost's hypot since it does type promotion which is problematic.
/// @see https://en.cppreference.com/w/cpp/numeric/math/hypot
/// @see https://en.wikipedia.org/wiki/Hypotenuse
template <class Unit>
inline auto hypot(const boost::units::quantity<Unit, Real>& x,
                  const boost::units::quantity<Unit, Real>& y)
{
    using std::hypot;
    return boost::units::quantity<Unit, Real>::from_value(hypot(x.value(), y.value()));
}

/// @brief Square roots the given value.
/// @note Don't use boost's sqrt implementation as it promotes the quantity's given
///   underlying floating-point type which seems contrary in this case to the
///   specification of <code>std::sqrt</code>.
/// @see https://en.cppreference.com/w/cpp/numeric/math/sqrt
template <class Unit>
inline auto sqrt(const boost::units::quantity<Unit, Real>& q)
{
    using std::sqrt;
    using quantity_type =
        typename boost::units::root_typeof_helper<boost::units::quantity<Unit, Real>,
                                                  boost::units::static_rational<2>>::type;
    using unit_type = typename quantity_type::unit_type;

    return boost::units::quantity<unit_type, Real>::from_value(sqrt(q.value()));
}

/// @brief Almost zero.
template <class Y>
inline auto AlmostZero(const boost::units::quantity<Y, Real> v)
{
    return abs(v) < std::numeric_limits<boost::units::quantity<Y, Real>>::min();
}

/// @brief Strips the units off of the given value.
template <class Unit, class Y>
constexpr auto StripUnit(const boost::units::quantity<Unit, Y> source)
{
    return source.value();
}

#endif // defined(PLAYRHO_USE_BOOST_UNITS)

/// @brief Strips the unit from the given value.
/// @note This definition is for two step stripping of units. As such, it has to be after
///   all other overloads of the @c StripUnit functions have been declared so it can use any
///   of those as needed.
template <typename T>
constexpr auto StripUnit(const T& v) -> decltype(StripUnit(to_underlying(v)))
{
    return StripUnit(to_underlying(v));
}

} // namespace playrho

#if defined(PLAYRHO_USE_BOOST_UNITS)
namespace boost::units {

// Define division and multiplication templated operators in boost::units namespace since
//   boost::units is the consistent namespace of operands for these and this aids with
//   argument dependent lookup (ADL).
//
// Note that while boost::units already defines division and multiplication operator support,
//   that's only for division or multiplication with the same type that the quantity is based
//   on. For example when Real is float, Length{0.0f} * 2.0f is already supported but
//   Length{0.0f} * 2 is not.

/// @brief Division operator.
///
/// @details Supports the division of a playrho::Real based boost::units::quantity
///   by any arithmetic type except playrho::Real.
/// @note This intentionally excludes the playrho::Real type since the playrho::Real
///   type is already supported and supporting it again in this template causes
///   ambiguous overload support.
///
template <class Dimension, typename X,
          typename = std::enable_if_t<
              playrho::IsArithmeticV<X> && !std::is_same_v<X, playrho::Real> &&
              std::is_same_v<decltype(playrho::Real{} / X{}), playrho::Real>>>
constexpr auto operator/(quantity<Dimension, playrho::Real> lhs, X rhs)
{
    return lhs / playrho::Real(rhs);
}

template <class Dimension, typename X,
          typename = std::enable_if_t<
              playrho::IsArithmeticV<X> && !std::is_same_v<X, playrho::Real> &&
              std::is_same_v<decltype(X{} / playrho::Real{}), playrho::Real>>>
constexpr auto operator/(X lhs, quantity<Dimension, playrho::Real> rhs)
{
    return playrho::Real(lhs) / rhs;
}

/// @brief Multiplication operator.
///
/// @details Supports the multiplication of a playrho::Real based boost::units::quantity
///   by any arithmetic type except playrho::Real.
/// @note This intentionally excludes the playrho::Real type since the playrho::Real
///   type is already supported and supporting it again in this template causes
///   ambiguous overload support.
///
template <class Dimension, typename X,
          typename = std::enable_if_t<
              playrho::IsArithmeticV<X> && !std::is_same_v<X, playrho::Real> &&
              std::is_same_v<decltype(playrho::Real{} * X{}), playrho::Real>>>
constexpr auto operator*(quantity<Dimension, playrho::Real> lhs, X rhs)
{
    return lhs * playrho::Real(rhs);
}

/// @brief Multiplication operator.
///
/// @details Supports the multiplication of a playrho::Real based boost::units::quantity
///   by any arithmetic type except playrho::Real.
/// @note This intentionally excludes the playrho::Real type since the playrho::Real
///   type is already supported and supporting it again in this template causes
///   ambiguous overload support.
///
template <class Dimension, typename X,
          typename = std::enable_if_t<
              playrho::IsArithmeticV<X> && !std::is_same_v<X, playrho::Real> &&
              std::is_same_v<decltype(playrho::Real{} * X{}), playrho::Real>>>
constexpr auto operator*(X lhs, quantity<Dimension, playrho::Real> rhs)
{
    return playrho::Real(lhs) * rhs;
}

} // namespace boost::units

#endif // defined(PLAYRHO_USE_BOOST_UNITS)

#endif // PLAYRHO_UNITS_HPP
