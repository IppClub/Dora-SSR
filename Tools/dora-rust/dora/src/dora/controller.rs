extern "C" {
	fn controller_is_button_down(controller_id: i32, name: i64) -> i32;
	fn controller_is_button_up(controller_id: i32, name: i64) -> i32;
	fn controller_is_button_pressed(controller_id: i32, name: i64) -> i32;
	fn controller_get_axis(controller_id: i32, name: i64) -> f32;
}
pub struct Controller { }
impl Controller {
	pub fn is_button_down(controller_id: i32, name: &str) -> bool {
		unsafe { return controller_is_button_down(controller_id, crate::dora::from_string(name)) != 0; }
	}
	pub fn is_button_up(controller_id: i32, name: &str) -> bool {
		unsafe { return controller_is_button_up(controller_id, crate::dora::from_string(name)) != 0; }
	}
	pub fn is_button_pressed(controller_id: i32, name: &str) -> bool {
		unsafe { return controller_is_button_pressed(controller_id, crate::dora::from_string(name)) != 0; }
	}
	pub fn get_axis(controller_id: i32, name: &str) -> f32 {
		unsafe { return controller_get_axis(controller_id, crate::dora::from_string(name)); }
	}
}