/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn ease_func(easing: i32, time: f32) -> f32;
}
/// A struct that defines a set of easing functions for use in animations.
pub struct Ease { }
impl Ease {
	/// Applies an easing function to a given value over a given amount of time.
	///
	/// # Arguments
	///
	/// * `easing` - The easing function to apply.
	/// * `time` - The amount of time to apply the easing function over, should be between 0 and 1.
	///
	/// # Returns
	///
	/// * `f32` - The result of applying the easing function to the value.
	pub fn func(easing: crate::dora::EaseType, time: f32) -> f32 {
		unsafe { return ease_func(easing as i32, time); }
	}
}