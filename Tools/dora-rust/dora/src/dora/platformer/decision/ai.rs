/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_decision_ai_get_units_by_relation(relation: i32) -> i64;
	fn platformer_decision_ai_get_detected_units() -> i64;
	fn platformer_decision_ai_get_detected_bodies() -> i64;
	fn platformer_decision_ai_get_nearest_unit(relation: i32) -> i64;
	fn platformer_decision_ai_get_nearest_unit_distance(relation: i32) -> f32;
	fn platformer_decision_ai_get_units_in_attack_range() -> i64;
	fn platformer_decision_ai_get_bodies_in_attack_range() -> i64;
}
/// The interface to retrieve information while executing the decision tree.
pub struct AI { }
impl AI {
	/// Gets an array of units in detection range that have the specified relation to current AI agent.
	///
	/// # Arguments
	///
	/// * `relation` - The relation to filter the units by.
	///
	/// # Returns
	///
	/// * An array of units with the specified relation.
	pub fn get_units_by_relation(relation: crate::dora::platformer::Relation) -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_units_by_relation(relation as i32)).unwrap(); }
	}
	/// Gets an array of units that the AI has detected.
	///
	/// # Returns
	///
	/// * An array of detected units.
	pub fn get_detected_units() -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_detected_units()).unwrap(); }
	}
	/// Gets an array of bodies that the AI has detected.
	///
	/// # Returns
	///
	/// * An array of detected bodies.
	pub fn get_detected_bodies() -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_detected_bodies()).unwrap(); }
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
	pub fn get_nearest_unit(relation: crate::dora::platformer::Relation) -> crate::dora::platformer::Unit {
		unsafe { return crate::dora::platformer::Unit::from(platformer_decision_ai_get_nearest_unit(relation as i32)).unwrap(); }
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
	pub fn get_nearest_unit_distance(relation: crate::dora::platformer::Relation) -> f32 {
		unsafe { return platformer_decision_ai_get_nearest_unit_distance(relation as i32); }
	}
	/// Gets an array of units that are within attack range.
	///
	/// # Returns
	///
	/// * An array of units in attack range.
	pub fn get_units_in_attack_range() -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_units_in_attack_range()).unwrap(); }
	}
	/// Gets an array of bodies that are within attack range.
	///
	/// # Returns
	///
	/// * An array of bodies in attack range.
	pub fn get_bodies_in_attack_range() -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_bodies_in_attack_range()).unwrap(); }
	}
}