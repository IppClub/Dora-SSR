extern "C" {
	fn pass_type() -> i32;
	fn pass_set_grab_pass(slf: i64, var: i32);
	fn pass_is_grab_pass(slf: i64) -> i32;
	fn pass_set(slf: i64, name: i64, var: f32);
	fn pass_set_vec4(slf: i64, name: i64, var_1: f32, var_2: f32, var_3: f32, var_4: f32);
	fn pass_set_color(slf: i64, name: i64, var: i32);
	fn pass_new(vert_shader: i64, frag_shader: i64) -> i64;
}
use crate::dora::Object;
pub struct Pass { raw: i64 }
crate::dora_object!(Pass);
impl Pass {
	pub fn set_grab_pass(&mut self, var: bool) {
		unsafe { pass_set_grab_pass(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_grab_pass(&self) -> bool {
		return unsafe { pass_is_grab_pass(self.raw()) != 0 };
	}
	pub fn set(&mut self, name: &str, var: f32) {
		unsafe { pass_set(self.raw(), crate::dora::from_string(name), var) };
	}
	pub fn set_vec4(&mut self, name: &str, var_1: f32, var_2: f32, var_3: f32, var_4: f32) {
		unsafe { pass_set_vec4(self.raw(), crate::dora::from_string(name), var_1, var_2, var_3, var_4) };
	}
	pub fn set_color(&mut self, name: &str, var: &crate::dora::Color) {
		unsafe { pass_set_color(self.raw(), crate::dora::from_string(name), var.to_argb() as i32) };
	}
	pub fn new(vert_shader: &str, frag_shader: &str) -> Pass {
		return Pass { raw: unsafe { pass_new(crate::dora::from_string(vert_shader), crate::dora::from_string(frag_shader)) } };
	}
}