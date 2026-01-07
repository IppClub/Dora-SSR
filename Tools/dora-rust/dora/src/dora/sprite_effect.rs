/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn spriteeffect_type() -> i32;
	fn spriteeffect_new(vert_shader: i64, frag_shader: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IEffect;
impl IEffect for SpriteEffect { }
/// A struct that is a specialization of Effect for rendering 2D sprites.
pub struct SpriteEffect { raw: i64 }
crate::dora_object!(SpriteEffect);
impl SpriteEffect {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { spriteeffect_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(SpriteEffect { raw: raw }))
			}
		})
	}
	/// A method that allows you to create a new SpriteEffect object.
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
	/// * `SpriteEffect` - A new SpriteEffect object.
	pub fn new(vert_shader: &str, frag_shader: &str) -> SpriteEffect {
		unsafe { return SpriteEffect { raw: spriteeffect_new(crate::dora::from_string(vert_shader), crate::dora::from_string(frag_shader)) }; }
	}
}