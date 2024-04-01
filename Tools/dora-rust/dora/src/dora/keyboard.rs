extern "C" {
	fn keyboard__is_key_down(name: i64) -> i32;
	fn keyboard__is_key_up(name: i64) -> i32;
	fn keyboard__is_key_pressed(name: i64) -> i32;
	fn keyboard_update_ime_pos_hint(win_pos: i64);
}
/// An interface for handling keyboard inputs.
pub struct Keyboard { }
impl Keyboard {
	pub(crate) fn _is_key_down(name: &str) -> bool {
		unsafe { return keyboard__is_key_down(crate::dora::from_string(name)) != 0; }
	}
	pub(crate) fn _is_key_up(name: &str) -> bool {
		unsafe { return keyboard__is_key_up(crate::dora::from_string(name)) != 0; }
	}
	pub(crate) fn _is_key_pressed(name: &str) -> bool {
		unsafe { return keyboard__is_key_pressed(crate::dora::from_string(name)) != 0; }
	}
	/// Updates the input method editor (IME) position hint.
	///
	/// # Arguments
	///
	/// * `win_pos` - The position of the keyboard window.
	pub fn update_ime_pos_hint(win_pos: &crate::dora::Vec2) {
		unsafe { keyboard_update_ime_pos_hint(win_pos.into_i64()); }
	}
}