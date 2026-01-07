/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn tic80node_type() -> i32;
	fn tic80node_new(cart_file: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::ISprite;
impl ISprite for TIC80Node { }
use crate::dora::INode;
impl INode for TIC80Node { }
pub struct TIC80Node { raw: i64 }
crate::dora_object!(TIC80Node);
impl TIC80Node {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { tic80node_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(TIC80Node { raw: raw }))
			}
		})
	}
	/// Creates a new TIC80Node object for running a TIC-80 cart.
	///
	/// # Arguments
	///
	/// * `cartFile` - The path to the TIC-80 cart file. It should be a valid TIC-80 cart file (`.tic` or `.png` format).
	///     The TIC-80 cart file contains the complete game or program that will run in the TIC-80 virtual machine.
	///     Supported features:
	///       - Full TIC-80 API support (drawing, sound, input, etc.).
	///       - Keyboard, controller, and touch input handling.
	///       - Audio playback through the TIC-80 sound engine.
	///       - Runs at TIC-80's native resolution (240x136 pixels).
	///       - Fixed frame rate matching TIC-80's specification (60 FPS).
	///
	/// # Returns
	///
	/// * `TIC80Node` - The created TIC80Node instance. Returns `nil` if creation fails.
	pub fn new(cart_file: &str) -> Option<TIC80Node> {
		unsafe { return TIC80Node::from(tic80node_new(crate::dora::from_string(cart_file))); }
	}
}