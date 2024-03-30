extern "C" {
	fn pass_type() -> i32;
	fn pass_set_grab_pass(slf: i64, var: i32);
	fn pass_is_grab_pass(slf: i64) -> i32;
	fn pass_set(slf: i64, name: i64, var: f32);
	fn pass_set_vec4(slf: i64, name: i64, var_1: f32, var_2: f32, var_3: f32, var_4: f32);
	fn pass_set_color(slf: i64, name: i64, var: i32);
	fn pass_new(vert_shader: i64, frag_shader: i64) -> i64;
}
use crate::dora::IObject;
/// A struct representing a shader pass.
pub struct Pass { raw: i64 }
crate::dora_object!(Pass);
impl Pass {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { pass_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Pass { raw: raw }))
			}
		})
	}
	/// Sets whether this Pass should be a grab pass.
	/// A grab pass will render a portion of game scene into a texture frame buffer.
	/// Then use this texture frame buffer as an input for next render pass.
	pub fn set_grab_pass(&mut self, var: bool) {
		unsafe { pass_set_grab_pass(self.raw(), if var { 1 } else { 0 }) };
	}
	/// Gets whether this Pass should be a grab pass.
	/// A grab pass will render a portion of game scene into a texture frame buffer.
	/// Then use this texture frame buffer as an input for next render pass.
	pub fn is_grab_pass(&self) -> bool {
		return unsafe { pass_is_grab_pass(self.raw()) != 0 };
	}
	/// Sets the value of shader parameters.
	///
	/// # Arguments
	///
	/// * `name` - The name of the parameter to set.
	/// * `var` - The numeric value to set.
	pub fn set(&mut self, name: &str, var: f32) {
		unsafe { pass_set(self.raw(), crate::dora::from_string(name), var); }
	}
	/// Sets the values of shader parameters.
	///
	/// # Arguments
	///
	/// * `name` - The name of the parameter to set.
	/// * `var1` - The first numeric value to set.
	/// * `var2` - An optional second numeric value to set.
	/// * `var3` - An optional third numeric value to set.
	/// * `var4` - An optional fourth numeric value to set.
	pub fn set_vec4(&mut self, name: &str, var_1: f32, var_2: f32, var_3: f32, var_4: f32) {
		unsafe { pass_set_vec4(self.raw(), crate::dora::from_string(name), var_1, var_2, var_3, var_4); }
	}
	/// Another function that sets the values of shader parameters.
	///
	/// Works the same as:
	/// pass.set("varName", color.r / 255.0, color.g / 255.0, color.b / 255.0, color.opacity);
	///
	/// # Arguments
	///
	/// * `name` - The name of the parameter to set.
	/// * `var` - The Color object to set.
	pub fn set_color(&mut self, name: &str, var: &crate::dora::Color) {
		unsafe { pass_set_color(self.raw(), crate::dora::from_string(name), var.to_argb() as i32); }
	}
	/// Creates a new Pass object.
	///
	/// # Arguments
	///
	/// * `vert_shader` - The vertex shader in binary form file string.
	/// * `frag_shader` - The fragment shader file string. A shader file string must be one of the formats:
	///     * "builtin:" + theBuiltinShaderName
	///     * "Shader/compiled_shader_file.bin"
	///
	/// # Returns
	///
	/// * `Pass` - A new Pass object.
	pub fn new(vert_shader: &str, frag_shader: &str) -> Pass {
		unsafe { return Pass { raw: pass_new(crate::dora::from_string(vert_shader), crate::dora::from_string(frag_shader)) }; }
	}
}