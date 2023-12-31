extern "C" {
	fn model_type() -> i32;
	fn model_get_duration(slf: i64) -> f32;
	fn model_set_reversed(slf: i64, var: i32);
	fn model_is_reversed(slf: i64) -> i32;
	fn model_is_playing(slf: i64) -> i32;
	fn model_is_paused(slf: i64) -> i32;
	fn model_has_animation(slf: i64, name: i64) -> i32;
	fn model_pause(slf: i64);
	fn model_resume(slf: i64);
	fn model_resume_animation(slf: i64, name: i64, looping: i32);
	fn model_reset(slf: i64);
	fn model_update_to(slf: i64, elapsed: f32, reversed: i32);
	fn model_get_node_by_name(slf: i64, name: i64) -> i64;
	fn model_each_node(slf: i64, func: i32, stack: i64) -> i32;
	fn model_new(filename: i64) -> i64;
	fn model_get_clip_file(filename: i64) -> i64;
	fn model_get_looks(filename: i64) -> i64;
	fn model_get_animations(filename: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IPlayable;
impl IPlayable for Model { }
use crate::dora::INode;
impl INode for Model { }
pub struct Model { raw: i64 }
crate::dora_object!(Model);
impl Model {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { model_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Model { raw: raw }))
			}
		})
	}
	pub fn get_duration(&self) -> f32 {
		return unsafe { model_get_duration(self.raw()) };
	}
	pub fn set_reversed(&mut self, var: bool) {
		unsafe { model_set_reversed(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_reversed(&self) -> bool {
		return unsafe { model_is_reversed(self.raw()) != 0 };
	}
	pub fn is_playing(&self) -> bool {
		return unsafe { model_is_playing(self.raw()) != 0 };
	}
	pub fn is_paused(&self) -> bool {
		return unsafe { model_is_paused(self.raw()) != 0 };
	}
	pub fn has_animation(&mut self, name: &str) -> bool {
		unsafe { return model_has_animation(self.raw(), crate::dora::from_string(name)) != 0; }
	}
	pub fn pause(&mut self) {
		unsafe { model_pause(self.raw()); }
	}
	pub fn resume(&mut self) {
		unsafe { model_resume(self.raw()); }
	}
	pub fn resume_animation(&mut self, name: &str, looping: bool) {
		unsafe { model_resume_animation(self.raw(), crate::dora::from_string(name), if looping { 1 } else { 0 }); }
	}
	pub fn reset(&mut self) {
		unsafe { model_reset(self.raw()); }
	}
	pub fn update_to(&mut self, elapsed: f32, reversed: bool) {
		unsafe { model_update_to(self.raw(), elapsed, if reversed { 1 } else { 0 }); }
	}
	pub fn get_node_by_name(&mut self, name: &str) -> crate::dora::Node {
		unsafe { return crate::dora::Node::from(model_get_node_by_name(self.raw(), crate::dora::from_string(name))).unwrap(); }
	}
	pub fn each_node(&mut self, mut func: Box<dyn FnMut(&dyn crate::dora::INode) -> bool>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = func(&stack.pop_cast::<crate::dora::Node>().unwrap());
			stack.push_bool(result);
		}));
		unsafe { return model_each_node(self.raw(), func_id, stack_raw) != 0; }
	}
	pub fn new(filename: &str) -> Model {
		unsafe { return Model { raw: model_new(crate::dora::from_string(filename)) }; }
	}
	pub fn get_clip_file(filename: &str) -> String {
		unsafe { return crate::dora::to_string(model_get_clip_file(crate::dora::from_string(filename))); }
	}
	pub fn get_looks(filename: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(model_get_looks(crate::dora::from_string(filename))); }
	}
	pub fn get_animations(filename: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(model_get_animations(crate::dora::from_string(filename))); }
	}
}