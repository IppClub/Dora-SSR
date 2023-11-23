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
pub struct Director { }
impl Director {
	pub fn set_clear_color(var: &crate::dora::Color) {
		unsafe { director_set_clear_color(var.to_argb() as i32) };
	}
	pub fn get_clear_color() -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(director_get_clear_color()) };
	}
	pub fn set_scheduler(var: &crate::dora::Scheduler) {
		unsafe { director_set_scheduler(var.raw()) };
	}
	pub fn get_scheduler() -> crate::dora::Scheduler {
		return unsafe { crate::dora::Scheduler::from(director_get_scheduler()).unwrap() };
	}
	pub fn get_ui() -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(director_get_ui()).unwrap() };
	}
	pub fn get_ui_3d() -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(director_get_ui_3d()).unwrap() };
	}
	pub fn get_entry() -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(director_get_entry()).unwrap() };
	}
	pub fn get_post_node() -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(director_get_post_node()).unwrap() };
	}
	pub fn get_system_scheduler() -> crate::dora::Scheduler {
		return unsafe { crate::dora::Scheduler::from(director_get_system_scheduler()).unwrap() };
	}
	pub fn get_post_scheduler() -> crate::dora::Scheduler {
		return unsafe { crate::dora::Scheduler::from(director_get_post_scheduler()).unwrap() };
	}
	pub fn get_current_camera() -> crate::dora::Camera {
		return unsafe { crate::dora::Camera::from(director_get_current_camera()).unwrap() };
	}
	pub fn push_camera(camera: &dyn crate::dora::ICamera) {
		unsafe { director_push_camera(camera.raw()); }
	}
	pub fn pop_camera() {
		unsafe { director_pop_camera(); }
	}
	pub fn remove_camera(camera: &dyn crate::dora::ICamera) -> bool {
		unsafe { return director_remove_camera(camera.raw()) != 0; }
	}
	pub fn clear_camera() {
		unsafe { director_clear_camera(); }
	}
	pub fn cleanup() {
		unsafe { director_cleanup(); }
	}
}