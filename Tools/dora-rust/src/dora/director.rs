extern "C" {
	fn director_set_stats_display(var: i32);
	fn director_is_stats_display() -> i32;
	fn director_get_ui() -> i64;
	fn director_get_ui3d() -> i64;
	fn director_get_entry() -> i64;
	fn director_get_post_node() -> i64;
	fn director_get_delta_time() -> f64;
	fn director_pop_camera();
	fn director_clear_camera();
	fn director_cleanup();
}
pub struct Director {  }
impl Director {
	pub fn set_stats_display(var: bool) {
		unsafe { director_set_stats_display(if var { 1 } else { 0 }) };
	}
	pub fn is_stats_display() -> bool {
		return unsafe { director_is_stats_display() } != 0;
	}
	pub fn get_ui() -> crate::dora::Node {
		return crate::dora::Node::from(unsafe { director_get_ui() }).unwrap();
	}
	pub fn get_ui3d() -> crate::dora::Node {
		return crate::dora::Node::from(unsafe { director_get_ui3d() }).unwrap();
	}
	pub fn get_entry() -> crate::dora::Node {
		return crate::dora::Node::from(unsafe { director_get_entry() }).unwrap();
	}
	pub fn get_post_node() -> crate::dora::Node {
		return crate::dora::Node::from(unsafe { director_get_post_node() }).unwrap();
	}
	pub fn get_delta_time() -> f64 {
		return unsafe { director_get_delta_time() };
	}
	pub fn pop_camera() {
		unsafe { director_pop_camera() };
	}
	pub fn clear_camera() {
		unsafe { director_clear_camera() };
	}
	pub fn cleanup() {
		unsafe { director_cleanup() };
	}
}