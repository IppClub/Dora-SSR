/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_unit_type() -> i32;
	fn platformer_unit_set_playable(slf: i64, val: i64);
	fn platformer_unit_get_playable(slf: i64) -> i64;
	fn platformer_unit_set_detect_distance(slf: i64, val: f32);
	fn platformer_unit_get_detect_distance(slf: i64) -> f32;
	fn platformer_unit_set_attack_range(slf: i64, val: i64);
	fn platformer_unit_get_attack_range(slf: i64) -> i64;
	fn platformer_unit_set_face_right(slf: i64, val: i32);
	fn platformer_unit_is_face_right(slf: i64) -> i32;
	fn platformer_unit_set_receiving_decision_trace(slf: i64, val: i32);
	fn platformer_unit_is_receiving_decision_trace(slf: i64) -> i32;
	fn platformer_unit_set_decision_tree(slf: i64, val: i64);
	fn platformer_unit_get_decision_tree(slf: i64) -> i64;
	fn platformer_unit_is_on_surface(slf: i64) -> i32;
	fn platformer_unit_get_ground_sensor(slf: i64) -> i64;
	fn platformer_unit_get_detect_sensor(slf: i64) -> i64;
	fn platformer_unit_get_attack_sensor(slf: i64) -> i64;
	fn platformer_unit_get_unit_def(slf: i64) -> i64;
	fn platformer_unit_get_current_action(slf: i64) -> i64;
	fn platformer_unit_get_width(slf: i64) -> f32;
	fn platformer_unit_get_height(slf: i64) -> f32;
	fn platformer_unit_get_entity(slf: i64) -> i64;
	fn platformer_unit_attach_action(slf: i64, name: i64) -> i64;
	fn platformer_unit_remove_action(slf: i64, name: i64);
	fn platformer_unit_remove_all_actions(slf: i64);
	fn platformer_unit_get_action(slf: i64, name: i64) -> i64;
	fn platformer_unit_each_action(slf: i64, func0: i32, stack0: i64);
	fn platformer_unit_start(slf: i64, name: i64) -> i32;
	fn platformer_unit_stop(slf: i64);
	fn platformer_unit_is_doing(slf: i64, name: i64) -> i32;
	fn platformer_unit_new(unit_def: i64, physics_world: i64, entity: i64, pos: i64, rot: f32) -> i64;
	fn platformer_unit_with_store(unit_def_name: i64, physics_world_name: i64, entity: i64, pos: i64, rot: f32) -> i64;
}
use crate::dora::IObject;
use crate::dora::IBody;
impl IBody for Unit { }
use crate::dora::INode;
impl INode for Unit { }
/// A struct represents a character or other interactive item in a game scene.
pub struct Unit { raw: i64 }
crate::dora_object!(Unit);
impl Unit {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_unit_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Unit { raw: raw }))
			}
		})
	}
	/// Sets the property that references a "Playable" object for managing the animation state and playback of the "Unit".
	pub fn set_playable(&mut self, val: &dyn crate::dora::IPlayable) {
		unsafe { platformer_unit_set_playable(self.raw(), val.raw()) };
	}
	/// Gets the property that references a "Playable" object for managing the animation state and playback of the "Unit".
	pub fn get_playable(&self) -> crate::dora::Playable {
		return unsafe { crate::dora::Playable::from(platformer_unit_get_playable(self.raw())).unwrap() };
	}
	/// Sets the property that specifies the maximum distance at which the "Unit" can detect other "Unit" or objects.
	pub fn set_detect_distance(&mut self, val: f32) {
		unsafe { platformer_unit_set_detect_distance(self.raw(), val) };
	}
	/// Gets the property that specifies the maximum distance at which the "Unit" can detect other "Unit" or objects.
	pub fn get_detect_distance(&self) -> f32 {
		return unsafe { platformer_unit_get_detect_distance(self.raw()) };
	}
	/// Sets the property that specifies the size of the attack range for the "Unit".
	pub fn set_attack_range(&mut self, val: &crate::dora::Size) {
		unsafe { platformer_unit_set_attack_range(self.raw(), val.into_i64()) };
	}
	/// Gets the property that specifies the size of the attack range for the "Unit".
	pub fn get_attack_range(&self) -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(platformer_unit_get_attack_range(self.raw())) };
	}
	/// Sets the boolean property that specifies whether the "Unit" is facing right or not.
	pub fn set_face_right(&mut self, val: bool) {
		unsafe { platformer_unit_set_face_right(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets the boolean property that specifies whether the "Unit" is facing right or not.
	pub fn is_face_right(&self) -> bool {
		return unsafe { platformer_unit_is_face_right(self.raw()) != 0 };
	}
	/// Sets the boolean property that specifies whether the "Unit" is receiving a trace of the decision tree for debugging purposes.
	pub fn set_receiving_decision_trace(&mut self, val: bool) {
		unsafe { platformer_unit_set_receiving_decision_trace(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets the boolean property that specifies whether the "Unit" is receiving a trace of the decision tree for debugging purposes.
	pub fn is_receiving_decision_trace(&self) -> bool {
		return unsafe { platformer_unit_is_receiving_decision_trace(self.raw()) != 0 };
	}
	/// Sets the string property that specifies the decision tree to use for the "Unit's" AI behavior.
	/// the decision tree object will be searched in The singleton instance Data.store.
	pub fn set_decision_tree(&mut self, val: &str) {
		unsafe { platformer_unit_set_decision_tree(self.raw(), crate::dora::from_string(val)) };
	}
	/// Gets the string property that specifies the decision tree to use for the "Unit's" AI behavior.
	/// the decision tree object will be searched in The singleton instance Data.store.
	pub fn get_decision_tree(&self) -> String {
		return unsafe { crate::dora::to_string(platformer_unit_get_decision_tree(self.raw())) };
	}
	/// Gets whether the "Unit" is currently on a surface or not.
	pub fn is_on_surface(&self) -> bool {
		return unsafe { platformer_unit_is_on_surface(self.raw()) != 0 };
	}
	/// Gets the "Sensor" object for detecting ground surfaces.
	pub fn get_ground_sensor(&self) -> crate::dora::Sensor {
		return unsafe { crate::dora::Sensor::from(platformer_unit_get_ground_sensor(self.raw())).unwrap() };
	}
	/// Gets the "Sensor" object for detecting other "Unit" objects or physics bodies in the game world.
	pub fn get_detect_sensor(&self) -> crate::dora::Sensor {
		return unsafe { crate::dora::Sensor::from(platformer_unit_get_detect_sensor(self.raw())).unwrap() };
	}
	/// Gets the "Sensor" object for detecting other "Unit" objects within the attack senser area.
	pub fn get_attack_sensor(&self) -> crate::dora::Sensor {
		return unsafe { crate::dora::Sensor::from(platformer_unit_get_attack_sensor(self.raw())).unwrap() };
	}
	/// Gets the "Dictionary" object for defining the properties and behavior of the "Unit".
	pub fn get_unit_def(&self) -> crate::dora::Dictionary {
		return unsafe { crate::dora::Dictionary::from(platformer_unit_get_unit_def(self.raw())).unwrap() };
	}
	/// Gets the property that specifies the current action being performed by the "Unit".
	pub fn get_current_action(&self) -> crate::dora::platformer::UnitAction {
		return unsafe { crate::dora::platformer::UnitAction::from(platformer_unit_get_current_action(self.raw())).unwrap() };
	}
	/// Gets the width of the "Unit".
	pub fn get_width(&self) -> f32 {
		return unsafe { platformer_unit_get_width(self.raw()) };
	}
	/// Gets the height of the "Unit".
	pub fn get_height(&self) -> f32 {
		return unsafe { platformer_unit_get_height(self.raw()) };
	}
	/// Gets the "Entity" object for representing the "Unit" in the ECS system.
	pub fn get_entity(&self) -> crate::dora::Entity {
		return unsafe { crate::dora::Entity::from(platformer_unit_get_entity(self.raw())).unwrap() };
	}
	/// Adds a new `UnitAction` to the `Unit` with the specified name, and returns the new `UnitAction`.
	///
	/// # Arguments
	///
	/// * `name` - The name of the new `UnitAction`.
	///
	/// # Returns
	///
	/// * The newly created `UnitAction`.
	pub fn attach_action(&mut self, name: &str) -> crate::dora::platformer::UnitAction {
		unsafe { return crate::dora::platformer::UnitAction::from(platformer_unit_attach_action(self.raw(), crate::dora::from_string(name))).unwrap(); }
	}
	/// Removes the `UnitAction` with the specified name from the `Unit`.
	///
	/// # Arguments
	///
	/// * `name` - The name of the `UnitAction` to remove.
	pub fn remove_action(&mut self, name: &str) {
		unsafe { platformer_unit_remove_action(self.raw(), crate::dora::from_string(name)); }
	}
	/// Removes all "UnitAction" objects from the "Unit".
	pub fn remove_all_actions(&mut self) {
		unsafe { platformer_unit_remove_all_actions(self.raw()); }
	}
	/// Returns the `UnitAction` with the specified name, or `None` if the `UnitAction` does not exist.
	///
	/// # Arguments
	///
	/// * `name` - The name of the `UnitAction` to retrieve.
	///
	/// # Returns
	///
	/// * The `UnitAction` with the specified name, or `None`.
	pub fn get_action(&mut self, name: &str) -> Option<crate::dora::platformer::UnitAction> {
		unsafe { return crate::dora::platformer::UnitAction::from(platformer_unit_get_action(self.raw(), crate::dora::from_string(name))); }
	}
	/// Calls the specified function for each `UnitAction` attached to the `Unit`.
	///
	/// # Arguments
	///
	/// * `visitorFunc` - A function to call for each `UnitAction`.
	pub fn each_action(&mut self, mut visitor_func: Box<dyn FnMut(&crate::dora::platformer::UnitAction)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			visitor_func(&crate::dora::platformer::UnitAction::from(stack0.pop_i64().unwrap()).unwrap())
		}));
		unsafe { platformer_unit_each_action(self.raw(), func_id0, stack_raw0); }
	}
	/// Starts the `UnitAction` with the specified name, and returns true if the `UnitAction` was started successfully.
	///
	/// # Arguments
	///
	/// * `name` - The name of the `UnitAction` to start.
	///
	/// # Returns
	///
	/// * `true` if the `UnitAction` was started successfully, `false` otherwise.
	pub fn start(&mut self, name: &str) -> bool {
		unsafe { return platformer_unit_start(self.raw(), crate::dora::from_string(name)) != 0; }
	}
	/// Stops the currently running "UnitAction".
	pub fn stop(&mut self) {
		unsafe { platformer_unit_stop(self.raw()); }
	}
	/// Returns true if the `Unit` is currently performing the specified `UnitAction`, false otherwise.
	///
	/// # Arguments
	///
	/// * `name` - The name of the `UnitAction` to check.
	///
	/// # Returns
	///
	/// * `true` if the `Unit` is currently performing the specified `UnitAction`, `false` otherwise.
	pub fn is_doing(&mut self, name: &str) -> bool {
		unsafe { return platformer_unit_is_doing(self.raw(), crate::dora::from_string(name)) != 0; }
	}
	/// A method that creates a new `Unit` object.
	///
	/// # Arguments
	///
	/// * `unit_def` - A `Dictionary` object that defines the properties and behavior of the `Unit`.
	/// * `physics_world` - A `PhysicsWorld` object that represents the physics simulation world.
	/// * `entity` - An `Entity` object that represents the `Unit` in ECS system.
	/// * `pos` - A `Vec2` object that specifies the initial position of the `Unit`.
	/// * `rot` - A number that specifies the initial rotation of the `Unit`.
	///
	/// # Returns
	///
	/// * The newly created `Unit` object.
	pub fn new(unit_def: &crate::dora::Dictionary, physics_world: &dyn crate::dora::IPhysicsWorld, entity: &crate::dora::Entity, pos: &crate::dora::Vec2, rot: f32) -> Unit {
		unsafe { return Unit { raw: platformer_unit_new(unit_def.raw(), physics_world.raw(), entity.raw(), pos.into_i64(), rot) }; }
	}
	/// A method that creates a new `Unit` object.
	///
	/// # Arguments
	///
	/// * `unit_def_name` - A string that specifies the name of the `Unit` definition to retrieve from `Data.store` table.
	/// * `physics_world_name` - A string that specifies the name of the `PhysicsWorld` object to retrieve from `Data.store` table.
	/// * `entity` - An `Entity` object that represents the `Unit` in ECS system.
	/// * `pos` - A `Vec2` object that specifies the initial position of the `Unit`.
	/// * `rot` - An optional number that specifies the initial rotation of the `Unit` (default is 0.0).
	///
	/// # Returns
	///
	/// * The newly created `Unit` object.
	pub fn with_store(unit_def_name: &str, physics_world_name: &str, entity: &crate::dora::Entity, pos: &crate::dora::Vec2, rot: f32) -> Unit {
		unsafe { return Unit { raw: platformer_unit_with_store(crate::dora::from_string(unit_def_name), crate::dora::from_string(physics_world_name), entity.raw(), pos.into_i64(), rot) }; }
	}
}