extern "C" {
	fn spine_type() -> i32;
	fn spine_set_show_debug(slf: i64, var: i32);
	fn spine_is_show_debug(slf: i64) -> i32;
	fn spine_set_hit_test_enabled(slf: i64, var: i32);
	fn spine_is_hit_test_enabled(slf: i64) -> i32;
	fn spine_set_bone_rotation(slf: i64, name: i64, rotation: f32) -> i32;
	fn spine_contains_point(slf: i64, x: f32, y: f32) -> i64;
	fn spine_intersects_segment(slf: i64, x_1: f32, y_1: f32, x_2: f32, y_2: f32) -> i64;
	fn spine_with_files(skel_file: i64, atlas_file: i64) -> i64;
	fn spine_new(spine_str: i64) -> i64;
	fn spine_get_looks(spine_str: i64);
	fn spine_get_animations(spine_str: i64);
}
use crate::dora::IObject;
use crate::dora::IPlayable;
impl IPlayable for Spine { }
use crate::dora::INode;
impl INode for Spine { }
pub struct Spine { raw: i64 }
crate::dora_object!(Spine);
impl Spine {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { spine_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Spine { raw: raw }))
			}
		})
	}
	pub fn set_show_debug(&mut self, var: bool) {
		unsafe { spine_set_show_debug(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_show_debug(&self) -> bool {
		return unsafe { spine_is_show_debug(self.raw()) != 0 };
	}
	pub fn set_hit_test_enabled(&mut self, var: bool) {
		unsafe { spine_set_hit_test_enabled(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_hit_test_enabled(&self) -> bool {
		return unsafe { spine_is_hit_test_enabled(self.raw()) != 0 };
	}
	pub fn set_bone_rotation(&mut self, name: &str, rotation: f32) -> bool {
		unsafe { return spine_set_bone_rotation(self.raw(), crate::dora::from_string(name), rotation) != 0; }
	}
	pub fn contains_point(&mut self, x: f32, y: f32) -> String {
		unsafe { return crate::dora::to_string(spine_contains_point(self.raw(), x, y)); }
	}
	pub fn intersects_segment(&mut self, x_1: f32, y_1: f32, x_2: f32, y_2: f32) -> String {
		unsafe { return crate::dora::to_string(spine_intersects_segment(self.raw(), x_1, y_1, x_2, y_2)); }
	}
	pub fn with_files(skel_file: &str, atlas_file: &str) -> Spine {
		unsafe { return Spine { raw: spine_with_files(crate::dora::from_string(skel_file), crate::dora::from_string(atlas_file)) }; }
	}
	pub fn new(spine_str: &str) -> Spine {
		unsafe { return Spine { raw: spine_new(crate::dora::from_string(spine_str)) }; }
	}
	pub fn get_looks(spine_str: &str) {
		unsafe { spine_get_looks(crate::dora::from_string(spine_str)); }
	}
	pub fn get_animations(spine_str: &str) {
		unsafe { spine_get_animations(crate::dora::from_string(spine_str)); }
	}
}