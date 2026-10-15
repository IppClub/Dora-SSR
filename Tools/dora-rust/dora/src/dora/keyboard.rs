/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn keyboard__is_key_down(name: i64) -> i32;
	fn keyboard__is_key_up(name: i64) -> i32;
	fn keyboard__is_key_pressed(name: i64) -> i32;
	fn keyboard_update_ime_pos_hint(win_pos: i64);
}
/// An interface for handling keyboard inputs.
pub struct Keyboard { }
impl Keyboard {
	/// Checks whether a key is currently pressed.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the key is pressed, `false` otherwise.
	pub(crate) fn _is_key_down(name: &str) -> bool {
		unsafe { return keyboard__is_key_down(crate::dora::from_string(name)) != 0; }
	}
	/// Checks whether a key is currently released.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the key is released, `false` otherwise.
	pub(crate) fn _is_key_up(name: &str) -> bool {
		unsafe { return keyboard__is_key_up(crate::dora::from_string(name)) != 0; }
	}
	/// Checks whether a key is currently being pressed.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the key is being pressed, `false` otherwise.
	pub(crate) fn _is_key_pressed(name: &str) -> bool {
		unsafe { return keyboard__is_key_pressed(crate::dora::from_string(name)) != 0; }
	}
	/// Updates the input method editor (IME) position hint.
	///
	/// # Arguments
	///
	/// * `win_pos` - The position of the keyboard window.
	pub fn update_ime_pos_hint(win_pos: &crate::dora::Vec2) {
		unsafe { keyboard_update_ime_pos_hint(win_pos.into_i64()); }
	}
}