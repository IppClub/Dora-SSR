extern "C" {
	fn dragonbone_type() -> i32;
	fn dragonbone_set_show_debug(slf: i64, var: i32);
	fn dragonbone_is_show_debug(slf: i64) -> i32;
	fn dragonbone_set_hit_test_enabled(slf: i64, var: i32);
	fn dragonbone_is_hit_test_enabled(slf: i64) -> i32;
	fn dragonbone_contains_point(slf: i64, x: f32, y: f32) -> i64;
	fn dragonbone_intersects_segment(slf: i64, x_1: f32, y_1: f32, x_2: f32, y_2: f32) -> i64;
	fn dragonbone_with_files(bone_file: i64, atlas_file: i64) -> i64;
	fn dragonbone_new(bone_str: i64) -> i64;
	fn dragonbone_get_looks(bone_str: i64);
	fn dragonbone_get_animations(bone_str: i64);
}
use crate::dora::Object;
use crate::dora::IPlayable;
impl IPlayable for DragonBone { }
use crate::dora::INode;
impl INode for DragonBone { }
pub struct DragonBone { raw: i64 }
crate::dora_object!(DragonBone);
impl DragonBone {
	pub fn set_show_debug(&mut self, var: bool) {
		unsafe { dragonbone_set_show_debug(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_show_debug(&self) -> bool {
		return unsafe { dragonbone_is_show_debug(self.raw()) != 0 };
	}
	pub fn set_hit_test_enabled(&mut self, var: bool) {
		unsafe { dragonbone_set_hit_test_enabled(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_hit_test_enabled(&self) -> bool {
		return unsafe { dragonbone_is_hit_test_enabled(self.raw()) != 0 };
	}
	pub fn contains_point(&mut self, x: f32, y: f32) -> String {
		return crate::dora::to_string(unsafe { dragonbone_contains_point(self.raw(), x, y) });
	}
	pub fn intersects_segment(&mut self, x_1: f32, y_1: f32, x_2: f32, y_2: f32) -> String {
		return crate::dora::to_string(unsafe { dragonbone_intersects_segment(self.raw(), x_1, y_1, x_2, y_2) });
	}
	pub fn with_files(bone_file: &str, atlas_file: &str) -> DragonBone {
		return DragonBone { raw: unsafe { dragonbone_with_files(crate::dora::from_string(bone_file), crate::dora::from_string(atlas_file)) } };
	}
	pub fn new(bone_str: &str) -> DragonBone {
		return DragonBone { raw: unsafe { dragonbone_new(crate::dora::from_string(bone_str)) } };
	}
	pub fn get_looks(bone_str: &str) {
		unsafe { dragonbone_get_looks(crate::dora::from_string(bone_str)) };
	}
	pub fn get_animations(bone_str: &str) {
		unsafe { dragonbone_get_animations(crate::dora::from_string(bone_str)) };
	}
}