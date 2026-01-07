/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

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
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
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