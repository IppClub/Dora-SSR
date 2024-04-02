/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn controller__is_button_down(controller_id: i32, name: i64) -> i32;
	fn controller__is_button_up(controller_id: i32, name: i64) -> i32;
	fn controller__is_button_pressed(controller_id: i32, name: i64) -> i32;
	fn controller__get_axis(controller_id: i32, name: i64) -> f32;
}
/// An interface for handling game controller inputs.
pub struct Controller { }
impl Controller {
	pub(crate) fn _is_button_down(controller_id: i32, name: &str) -> bool {
		unsafe { return controller__is_button_down(controller_id, crate::dora::from_string(name)) != 0; }
	}
	pub(crate) fn _is_button_up(controller_id: i32, name: &str) -> bool {
		unsafe { return controller__is_button_up(controller_id, crate::dora::from_string(name)) != 0; }
	}
	pub(crate) fn _is_button_pressed(controller_id: i32, name: &str) -> bool {
		unsafe { return controller__is_button_pressed(controller_id, crate::dora::from_string(name)) != 0; }
	}
	pub(crate) fn _get_axis(controller_id: i32, name: &str) -> f32 {
		unsafe { return controller__get_axis(controller_id, crate::dora::from_string(name)); }
	}
}