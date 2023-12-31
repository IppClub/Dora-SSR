extern "C" {
	fn application_get_frame() -> i32;
	fn application_get_buffer_size() -> i64;
	fn application_get_visual_size() -> i64;
	fn application_get_device_pixel_ratio() -> f32;
	fn application_get_platform() -> i64;
	fn application_get_version() -> i64;
	fn application_get_deps() -> i64;
	fn application_get_delta_time() -> f64;
	fn application_get_elapsed_time() -> f64;
	fn application_get_total_time() -> f64;
	fn application_get_running_time() -> f64;
	fn application_get_rand() -> i32;
	fn application_get_max_fps() -> i32;
	fn application_is_debugging() -> i32;
	fn application_set_locale(var: i64);
	fn application_get_locale() -> i64;
	fn application_set_theme_color(var: i32);
	fn application_get_theme_color() -> i32;
	fn application_set_seed(var: i32);
	fn application_get_seed() -> i32;
	fn application_set_target_fps(var: i32);
	fn application_get_target_fps() -> i32;
	fn application_set_win_size(var: i64);
	fn application_get_win_size() -> i64;
	fn application_set_win_position(var: i64);
	fn application_get_win_position() -> i64;
	fn application_set_fps_limited(var: i32);
	fn application_is_fps_limited() -> i32;
	fn application_set_idled(var: i32);
	fn application_is_idled() -> i32;
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
	pub fn get_device_pixel_ratio() -> f32 {
		return unsafe { application_get_device_pixel_ratio() };
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
	pub fn get_delta_time() -> f64 {
		return unsafe { application_get_delta_time() };
	}
	pub fn get_elapsed_time() -> f64 {
		return unsafe { application_get_elapsed_time() };
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
	pub fn get_max_fps() -> i32 {
		return unsafe { application_get_max_fps() };
	}
	pub fn is_debugging() -> bool {
		return unsafe { application_is_debugging() != 0 };
	}
	pub fn set_locale(var: &str) {
		unsafe { application_set_locale(crate::dora::from_string(var)) };
	}
	pub fn get_locale() -> String {
		return unsafe { crate::dora::to_string(application_get_locale()) };
	}
	pub fn set_theme_color(var: &crate::dora::Color) {
		unsafe { application_set_theme_color(var.to_argb() as i32) };
	}
	pub fn get_theme_color() -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(application_get_theme_color()) };
	}
	pub fn set_seed(var: i32) {
		unsafe { application_set_seed(var) };
	}
	pub fn get_seed() -> i32 {
		return unsafe { application_get_seed() };
	}
	pub fn set_target_fps(var: i32) {
		unsafe { application_set_target_fps(var) };
	}
	pub fn get_target_fps() -> i32 {
		return unsafe { application_get_target_fps() };
	}
	pub fn set_win_size(var: &crate::dora::Size) {
		unsafe { application_set_win_size(var.into_i64()) };
	}
	pub fn get_win_size() -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(application_get_win_size()) };
	}
	pub fn set_win_position(var: &crate::dora::Vec2) {
		unsafe { application_set_win_position(var.into_i64()) };
	}
	pub fn get_win_position() -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(application_get_win_position()) };
	}
	pub fn set_fps_limited(var: bool) {
		unsafe { application_set_fps_limited(if var { 1 } else { 0 }) };
	}
	pub fn is_fps_limited() -> bool {
		return unsafe { application_is_fps_limited() != 0 };
	}
	pub fn set_idled(var: bool) {
		unsafe { application_set_idled(if var { 1 } else { 0 }) };
	}
	pub fn is_idled() -> bool {
		return unsafe { application_is_idled() != 0 };
	}
	pub fn shutdown() {
		unsafe { application_shutdown(); }
	}
}