/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn godotnode_type() -> i32;
	fn godotnode_get_unsupported_reason() -> i64;
	fn godotnode_get_project_path(slf: i64) -> i64;
	fn godotnode_get_scene_file(slf: i64) -> i64;
	fn godotnode_get_last_error(slf: i64) -> i64;
	fn godotnode_is_running(slf: i64) -> i32;
	fn godotnode_is_paused(slf: i64) -> i32;
	fn godotnode_get_viewport_size(slf: i64) -> i64;
	fn godotnode_resize_viewport(slf: i64, width: i32, height: i32) -> i32;
	fn godotnode_pause(slf: i64);
	fn godotnode_resume(slf: i64);
	fn godotnode_restart(slf: i64, scene_file: i64) -> i32;
	fn godotnode_send_pointer(slf: i64, x: f64, y: f64, button: i32, pressed: i32);
	fn godotnode_send_pointer_move(slf: i64, x: f64, y: f64);
	fn godotnode_send_key(slf: i64, name: i64, pressed: i32);
	fn godotnode_send_text(slf: i64, text: i64);
	fn godotnode_new(project_path: i64, scene_file: i64, width: i32, height: i32, buffers: i32) -> i64;
}
use crate::dora::IObject;
use crate::dora::ISprite;
impl ISprite for GodotNode { }
use crate::dora::INode;
impl INode for GodotNode { }
pub struct GodotNode { raw: i64 }
crate::dora_object!(GodotNode);
impl GodotNode {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { godotnode_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(GodotNode { raw: raw }))
			}
		})
	}
	/// Empty when the current GPU/backend supports GodotNode; does not load the runtime library.
	pub fn get_unsupported_reason() -> String {
		unsafe { return crate::dora::to_string(godotnode_get_unsupported_reason()); }
	}
	/// Gets Resolved Godot project directory or exported .pck path.
	pub fn get_project_path(&self) -> String {
		return unsafe { crate::dora::to_string(godotnode_get_project_path(self.raw())) };
	}
	/// Gets Requested Godot scene path; empty uses the project main scene.
	pub fn get_scene_file(&self) -> String {
		return unsafe { crate::dora::to_string(godotnode_get_scene_file(self.raw())) };
	}
	/// Gets Most recent asynchronous runtime error, or an empty string.
	pub fn get_last_error(&self) -> String {
		return unsafe { crate::dora::to_string(godotnode_get_last_error(self.raw())) };
	}
	/// Gets Whether asynchronous startup completed and the node is active.
	pub fn is_running(&self) -> bool {
		return unsafe { godotnode_is_running(self.raw()) != 0 };
	}
	/// Gets Requested native SceneTree pause state.
	pub fn is_paused(&self) -> bool {
		return unsafe { godotnode_is_paused(self.raw()) != 0 };
	}
	/// Gets Committed native viewport pixel size; updated after asynchronous texture publication.
	pub fn get_viewport_size(&self) -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(godotnode_get_viewport_size(self.raw())) };
	}
	/// Request a native viewport resize; false when invalid, busy or unsupported.
	pub fn resize_viewport(&mut self, width: i32, height: i32) -> bool {
		unsafe { return godotnode_resize_viewport(self.raw(), width, height) != 0; }
	}
	/// Pause the SceneTree; Always-process nodes continue running. Works before startup completes.
	pub fn pause(&mut self) {
		unsafe { godotnode_pause(self.raw()); }
	}
	/// Resume the SceneTree without rebuilding the project.
	pub fn resume(&mut self) {
		unsafe { godotnode_resume(self.raw()); }
	}
	/// Request scene reload; empty reloads the current scene. Errors are asynchronous.
	pub fn restart(&mut self, scene_file: &str) -> bool {
		unsafe { return godotnode_restart(self.raw(), crate::dora::from_string(scene_file)) != 0; }
	}
	/// Forward a pointer button in viewport pixels, with top-left origin. Godot button numbering applies.
	pub fn send_pointer(&mut self, x: f64, y: f64, button: i32, pressed: bool) {
		unsafe { godotnode_send_pointer(self.raw(), x, y, button, if pressed { 1 } else { 0 }); }
	}
	/// Forward pointer motion in viewport pixels, with top-left origin.
	pub fn send_pointer_move(&mut self, x: f64, y: f64) {
		unsafe { godotnode_send_pointer_move(self.raw(), x, y); }
	}
	/// Forward a named key, such as Space. Pair presses with releases.
	pub fn send_key(&mut self, name: &str, pressed: bool) {
		unsafe { godotnode_send_key(self.raw(), crate::dora::from_string(name), if pressed { 1 } else { 0 }); }
	}
	/// Forward committed UTF-8 text. IME composition is not implemented.
	pub fn send_text(&mut self, text: &str) {
		unsafe { godotnode_send_text(self.raw(), crate::dora::from_string(text)); }
	}
	/// Create an experimental embedded Godot node. Requires a matching optional runtime and supported GPU backend. Only one active node/project is supported.
	pub fn new(project_path: &str, scene_file: &str, width: i32, height: i32, buffers: i32) -> Option<GodotNode> {
		unsafe { return GodotNode::from(godotnode_new(crate::dora::from_string(project_path), crate::dora::from_string(scene_file), width, height, buffers)); }
	}
}