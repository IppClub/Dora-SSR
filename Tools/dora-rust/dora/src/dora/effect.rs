extern "C" {
	fn effect_type() -> i32;
	fn effect_add(slf: i64, pass: i64);
	fn effect_get(slf: i64, index: i64) -> i64;
	fn effect_clear(slf: i64);
	fn effect_new(vert_shader: i64, frag_shader: i64) -> i64;
}
use crate::dora::IObject;
/// A struct for managing multiple render pass objects.
/// Effect objects allow you to combine multiple passes to create more complex shader effects.
pub struct Effect { raw: i64 }
crate::dora_object!(Effect);
impl IEffect for Effect { }
pub trait IEffect: IObject {
	/// Adds a Pass object to this Effect.
	///
	/// # Arguments
	///
	/// * `pass` - The Pass object to add.
	fn add(&mut self, pass: &crate::dora::Pass) {
		unsafe { effect_add(self.raw(), pass.raw()); }
	}
	/// Retrieves a Pass object from this Effect by index.
	///
	/// # Arguments
	///
	/// * `index` - The index of the Pass object to retrieve.
	///
	/// # Returns
	///
	/// * `Pass` - The Pass object at the given index.
	fn get(&self, index: i64) -> Option<crate::dora::Pass> {
		unsafe { return crate::dora::Pass::from(effect_get(self.raw(), index)); }
	}
	/// Removes all Pass objects from this Effect.
	fn clear(&mut self) {
		unsafe { effect_clear(self.raw()); }
	}
}
impl Effect {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { effect_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Effect { raw: raw }))
			}
		})
	}
	/// A method that allows you to create a new Effect object.
	///
	/// # Arguments
	///
	/// * `vert_shader` - The vertex shader file string.
	/// * `frag_shader` - The fragment shader file string. A shader file string must be one of the formats:
	///     * "builtin:" + theBuiltinShaderName
	///     * "Shader/compiled_shader_file.bin"
	///
	/// # Returns
	///
	/// * `Effect` - A new Effect object.
	pub fn new(vert_shader: &str, frag_shader: &str) -> Effect {
		unsafe { return Effect { raw: effect_new(crate::dora::from_string(vert_shader), crate::dora::from_string(frag_shader)) }; }
	}
}