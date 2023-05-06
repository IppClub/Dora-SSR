extern "C" {
	fn platformer_unit_type() -> i32;
	fn platformer_unit_set_playable(slf: i64, var: i64);
	fn platformer_unit_get_playable(slf: i64) -> i64;
	fn platformer_unit_set_detect_distance(slf: i64, var: f32);
	fn platformer_unit_get_detect_distance(slf: i64) -> f32;
	fn platformer_unit_set_attack_range(slf: i64, var: i64);
	fn platformer_unit_get_attack_range(slf: i64) -> i64;
	fn platformer_unit_set_face_right(slf: i64, var: i32);
	fn platformer_unit_is_face_right(slf: i64) -> i32;
	fn platformer_unit_set_receiving_decision_trace(slf: i64, var: i32);
	fn platformer_unit_is_receiving_decision_trace(slf: i64) -> i32;
	fn platformer_unit_set_decision_tree(slf: i64, var: i64);
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
	fn platformer_unit_each_action(slf: i64, func: i32, stack: i64);
	fn platformer_unit_start(slf: i64, name: i64) -> i32;
	fn platformer_unit_stop(slf: i64);
	fn platformer_unit_is_doing(slf: i64, name: i64) -> i32;
	fn platformer_unit_new(unit_def: i64, physicsworld: i64, entity: i64, pos: i64, rot: f32) -> i64;
	fn platformer_unit_with_store(def_name: i64, world_name: i64, entity: i64, pos: i64, rot: f32) -> i64;
}
use crate::dora::IObject;
use crate::dora::IBody;
impl IBody for Unit { }
use crate::dora::INode;
impl INode for Unit { }
pub struct Unit { raw: i64 }
crate::dora_object!(Unit);
impl Unit {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_unit_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Unit { raw: raw }))
			}
		})
	}
	pub fn set_playable(&mut self, var: &dyn crate::dora::IPlayable) {
		unsafe { platformer_unit_set_playable(self.raw(), var.raw()) };
	}
	pub fn get_playable(&self) -> crate::dora::Playable {
		return unsafe { crate::dora::Playable::from(platformer_unit_get_playable(self.raw())).unwrap() };
	}
	pub fn set_detect_distance(&mut self, var: f32) {
		unsafe { platformer_unit_set_detect_distance(self.raw(), var) };
	}
	pub fn get_detect_distance(&self) -> f32 {
		return unsafe { platformer_unit_get_detect_distance(self.raw()) };
	}
	pub fn set_attack_range(&mut self, var: &crate::dora::Size) {
		unsafe { platformer_unit_set_attack_range(self.raw(), var.into_i64()) };
	}
	pub fn get_attack_range(&self) -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(platformer_unit_get_attack_range(self.raw())) };
	}
	pub fn set_face_right(&mut self, var: bool) {
		unsafe { platformer_unit_set_face_right(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_face_right(&self) -> bool {
		return unsafe { platformer_unit_is_face_right(self.raw()) != 0 };
	}
	pub fn set_receiving_decision_trace(&mut self, var: bool) {
		unsafe { platformer_unit_set_receiving_decision_trace(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_receiving_decision_trace(&self) -> bool {
		return unsafe { platformer_unit_is_receiving_decision_trace(self.raw()) != 0 };
	}
	pub fn set_decision_tree(&mut self, var: &str) {
		unsafe { platformer_unit_set_decision_tree(self.raw(), crate::dora::from_string(var)) };
	}
	pub fn get_decision_tree(&self) -> String {
		return unsafe { crate::dora::to_string(platformer_unit_get_decision_tree(self.raw())) };
	}
	pub fn is_on_surface(&self) -> bool {
		return unsafe { platformer_unit_is_on_surface(self.raw()) != 0 };
	}
	pub fn get_ground_sensor(&self) -> crate::dora::Sensor {
		return unsafe { crate::dora::Sensor::from(platformer_unit_get_ground_sensor(self.raw())).unwrap() };
	}
	pub fn get_detect_sensor(&self) -> crate::dora::Sensor {
		return unsafe { crate::dora::Sensor::from(platformer_unit_get_detect_sensor(self.raw())).unwrap() };
	}
	pub fn get_attack_sensor(&self) -> crate::dora::Sensor {
		return unsafe { crate::dora::Sensor::from(platformer_unit_get_attack_sensor(self.raw())).unwrap() };
	}
	pub fn get_unit_def(&self) -> crate::dora::Dictionary {
		return unsafe { crate::dora::Dictionary::from(platformer_unit_get_unit_def(self.raw())).unwrap() };
	}
	pub fn get_current_action(&self) -> crate::dora::platformer::UnitAction {
		return unsafe { crate::dora::platformer::UnitAction::from(platformer_unit_get_current_action(self.raw())).unwrap() };
	}
	pub fn get_width(&self) -> f32 {
		return unsafe { platformer_unit_get_width(self.raw()) };
	}
	pub fn get_height(&self) -> f32 {
		return unsafe { platformer_unit_get_height(self.raw()) };
	}
	pub fn get_entity(&self) -> crate::dora::Entity {
		return unsafe { crate::dora::Entity::from(platformer_unit_get_entity(self.raw())).unwrap() };
	}
	pub fn attach_action(&mut self, name: &str) -> crate::dora::platformer::UnitAction {
		unsafe { return crate::dora::platformer::UnitAction::from(platformer_unit_attach_action(self.raw(), crate::dora::from_string(name))).unwrap(); }
	}
	pub fn remove_action(&mut self, name: &str) {
		unsafe { platformer_unit_remove_action(self.raw(), crate::dora::from_string(name)); }
	}
	pub fn remove_all_actions(&mut self) {
		unsafe { platformer_unit_remove_all_actions(self.raw()); }
	}
	pub fn get_action(&mut self, name: &str) -> Option<crate::dora::platformer::UnitAction> {
		unsafe { return crate::dora::platformer::UnitAction::from(platformer_unit_get_action(self.raw(), crate::dora::from_string(name))); }
	}
	pub fn each_action(&mut self, mut func: Box<dyn FnMut(&crate::dora::platformer::UnitAction)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			func(&crate::dora::platformer::UnitAction::from(stack.pop_i64().unwrap()).unwrap())
		}));
		unsafe { platformer_unit_each_action(self.raw(), func_id, stack_raw); }
	}
	pub fn start(&mut self, name: &str) -> bool {
		unsafe { return platformer_unit_start(self.raw(), crate::dora::from_string(name)) != 0; }
	}
	pub fn stop(&mut self) {
		unsafe { platformer_unit_stop(self.raw()); }
	}
	pub fn is_doing(&mut self, name: &str) -> bool {
		unsafe { return platformer_unit_is_doing(self.raw(), crate::dora::from_string(name)) != 0; }
	}
	pub fn new(unit_def: &crate::dora::Dictionary, physicsworld: &dyn crate::dora::IPhysicsWorld, entity: &crate::dora::Entity, pos: &crate::dora::Vec2, rot: f32) -> Unit {
		unsafe { return Unit { raw: platformer_unit_new(unit_def.raw(), physicsworld.raw(), entity.raw(), pos.into_i64(), rot) }; }
	}
	pub fn with_store(def_name: &str, world_name: &str, entity: &crate::dora::Entity, pos: &crate::dora::Vec2, rot: f32) -> Unit {
		unsafe { return Unit { raw: platformer_unit_with_store(crate::dora::from_string(def_name), crate::dora::from_string(world_name), entity.raw(), pos.into_i64(), rot) }; }
	}
}