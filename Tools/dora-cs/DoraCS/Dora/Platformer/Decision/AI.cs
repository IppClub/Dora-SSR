/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


using System.Runtime.InteropServices;
using int64_t = long;
using int32_t = int;

namespace Dora
{
	internal static partial class Native
	{
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_units_by_relation(int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_detected_units();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_detected_bodies();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_nearest_unit(int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_decision_ai_get_nearest_unit_distance(int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_units_in_attack_range();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_bodies_in_attack_range();
	}
} // namespace Dora

namespace Dora.Platformer.Decision
{
	/// The interface to retrieve information while executing the decision tree.
	public static partial class AI
	{
		/// Gets an array of units in detection range that have the specified relation to current AI agent.
		///
		/// # Arguments
		///
		/// * `relation` - The relation to filter the units by.
		///
		/// # Returns
		///
		/// * An array of units with the specified relation.
		public static Array GetUnitsByRelation(Platformer.Relation relation)
		{
			return Array.From(Native.platformer_decision_ai_get_units_by_relation((int)relation));
		}
		/// Gets an array of units that the AI has detected.
		///
		/// # Returns
		///
		/// * An array of detected units.
		public static Array GetDetectedUnits()
		{
			return Array.From(Native.platformer_decision_ai_get_detected_units());
		}
		/// Gets an array of bodies that the AI has detected.
		///
		/// # Returns
		///
		/// * An array of detected bodies.
		public static Array GetDetectedBodies()
		{
			return Array.From(Native.platformer_decision_ai_get_detected_bodies());
		}
		/// Gets the nearest unit that has the specified relation to the AI.
		///
		/// # Arguments
		///
		/// * `relation` - The relation to filter the units by.
		///
		/// # Returns
		///
		/// * The nearest unit with the specified relation.
		public static Platformer.Unit GetNearestUnit(Platformer.Relation relation)
		{
			return Platformer.Unit.From(Native.platformer_decision_ai_get_nearest_unit((int)relation));
		}
		/// Gets the distance to the nearest unit that has the specified relation to the AI agent.
		///
		/// # Arguments
		///
		/// * `relation` - The relation to filter the units by.
		///
		/// # Returns
		///
		/// * The distance to the nearest unit with the specified relation.
		public static float GetNearestUnitDistance(Platformer.Relation relation)
		{
			return Native.platformer_decision_ai_get_nearest_unit_distance((int)relation);
		}
		/// Gets an array of units that are within attack range.
		///
		/// # Returns
		///
		/// * An array of units in attack range.
		public static Array GetUnitsInAttackRange()
		{
			return Array.From(Native.platformer_decision_ai_get_units_in_attack_range());
		}
		/// Gets an array of bodies that are within attack range.
		///
		/// # Returns
		///
		/// * An array of bodies in attack range.
		public static Array GetBodiesInAttackRange()
		{
			return Array.From(Native.platformer_decision_ai_get_bodies_in_attack_range());
		}
	}
} // namespace Dora.Platformer.Decision
