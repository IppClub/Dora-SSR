/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn director_set_clear_color(var: i32);
	fn director_get_clear_color() -> i32;
	fn director_set_scheduler(var: i64);
	fn director_get_scheduler() -> i64;
	fn director_get_ui() -> i64;
	fn director_get_ui_3d() -> i64;
	fn director_get_entry() -> i64;
	fn director_get_post_node() -> i64;
	fn director_get_system_scheduler() -> i64;
	fn director_get_post_scheduler() -> i64;
	fn director_get_current_camera() -> i64;
	fn director_push_camera(camera: i64);
	fn director_pop_camera();
	fn director_remove_camera(camera: i64) -> i32;
	fn director_clear_camera();
	fn director_cleanup();
}
use crate::dora::IObject;
/// A struct manages the game scene trees and provides access to root scene nodes for different game uses.
pub struct Director { }
impl Director {
	/// Sets the background color for the game world.
	pub fn set_clear_color(var: &crate::dora::Color) {
		unsafe { director_set_clear_color(var.to_argb() as i32) };
	}
	/// Gets the background color for the game world.
	pub fn get_clear_color() -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(director_get_clear_color()) };
	}
	/// Sets the game scheduler which is used for scheduling tasks like animations and gameplay events.
	pub fn set_scheduler(var: &crate::dora::Scheduler) {
		unsafe { director_set_scheduler(var.raw()) };
	}
	/// Gets the game scheduler which is used for scheduling tasks like animations and gameplay events.
	pub fn get_scheduler() -> crate::dora::Scheduler {
		return unsafe { crate::dora::Scheduler::from(director_get_scheduler()).unwrap() };
	}
	/// Gets the root node for 2D user interface elements like buttons and labels.
	pub fn get_ui() -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(director_get_ui()).unwrap() };
	}
	/// Gets the root node for 3D user interface elements with 3D projection effect.
	pub fn get_ui_3d() -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(director_get_ui_3d()).unwrap() };
	}
	/// Gets the root node for the starting point of a game.
	pub fn get_entry() -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(director_get_entry()).unwrap() };
	}
	/// Gets the root node for post-rendering scene tree.
	pub fn get_post_node() -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(director_get_post_node()).unwrap() };
	}
	/// Gets the system scheduler which is used for low-level system tasks, should not put any game logic in it.
	pub fn get_system_scheduler() -> crate::dora::Scheduler {
		return unsafe { crate::dora::Scheduler::from(director_get_system_scheduler()).unwrap() };
	}
	/// Gets the scheduler used for processing post game logic.
	pub fn get_post_scheduler() -> crate::dora::Scheduler {
		return unsafe { crate::dora::Scheduler::from(director_get_post_scheduler()).unwrap() };
	}
	/// Gets the current active camera in Director's camera stack.
	pub fn get_current_camera() -> crate::dora::Camera {
		return unsafe { crate::dora::Camera::from(director_get_current_camera()).unwrap() };
	}
	/// Adds a new camera to Director's camera stack and sets it to the current camera.
	///
	/// # Arguments
	///
	/// * `camera` - The camera to add.
	pub fn push_camera(camera: &dyn crate::dora::ICamera) {
		unsafe { director_push_camera(camera.raw()); }
	}
	/// Removes the current camera from Director's camera stack.
	pub fn pop_camera() {
		unsafe { director_pop_camera(); }
	}
	/// Removes a specified camera from Director's camera stack.
	///
	/// # Arguments
	///
	/// * `camera` - The camera to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the camera was removed, `false` otherwise.
	pub fn remove_camera(camera: &dyn crate::dora::ICamera) -> bool {
		unsafe { return director_remove_camera(camera.raw()) != 0; }
	}
	/// Removes all cameras from Director's camera stack.
	pub fn clear_camera() {
		unsafe { director_clear_camera(); }
	}
	/// Cleans up all resources managed by the Director, including scene trees and cameras.
	pub fn cleanup() {
		unsafe { director_cleanup(); }
	}
}