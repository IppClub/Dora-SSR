extern "C" {
	fn application_get_frame() -> i32;
	fn application_get_buffer_size() -> i64;
	fn application_get_visual_size() -> i64;
	fn application_get_device_ratio() -> f32;
	fn application_get_platform() -> i64;
	fn application_get_version() -> i64;
	fn application_get_deps() -> i64;
	fn application_get_eclapsed_time() -> f64;
	fn application_get_total_time() -> f64;
	fn application_get_running_time() -> f64;
	fn application_get_rand() -> i32;
	fn application_is_debugging() -> i32;
	fn application_set_seed(var: i32);
	fn application_get_seed() -> i32;
	fn application_shutdown();
}
pub struct App { }
impl App {
	pub fn get_frame() -> i32 {
		return unsafe { application_get_frame() };
	}
	pub fn get_buffer_size() -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(application_get_buffer_size()) };
	}
	pub fn get_visual_size() -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(application_get_visual_size()) };
	}
	pub fn get_device_ratio() -> f32 {
		return unsafe { application_get_device_ratio() };
	}
	pub fn get_platform() -> String {
		return unsafe { crate::dora::to_string(application_get_platform()) };
	}
	pub fn get_version() -> String {
		return unsafe { crate::dora::to_string(application_get_version()) };
	}
	pub fn get_deps() -> String {
		return unsafe { crate::dora::to_string(application_get_deps()) };
	}
	pub fn get_eclapsed_time() -> f64 {
		return unsafe { application_get_eclapsed_time() };
	}
	pub fn get_total_time() -> f64 {
		return unsafe { application_get_total_time() };
	}
	pub fn get_running_time() -> f64 {
		return unsafe { application_get_running_time() };
	}
	pub fn get_rand() -> i32 {
		return unsafe { application_get_rand() };
	}
	pub fn is_debugging() -> bool {
		return unsafe { application_is_debugging() != 0 };
	}
	pub fn set_seed(var: i32) {
		unsafe { application_set_seed(var) };
	}
	pub fn get_seed() -> i32 {
		return unsafe { application_get_seed() };
	}
	pub fn shutdown() {
		unsafe { application_shutdown(); }
	}
}