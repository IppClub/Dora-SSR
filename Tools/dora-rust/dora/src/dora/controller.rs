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