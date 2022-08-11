extern "C" {
	fn keyboard_is_key_down(name: i64) -> i32;
	fn keyboard_is_key_up(name: i64) -> i32;
	fn keyboard_is_key_pressed(name: i64) -> i32;
	fn keyboard_update_i_m_e_pos_hint(win_pos: i64);
}
pub struct Keyboard { }
impl Keyboard {
	pub fn is_key_down(name: &str) -> bool {
		unsafe { return keyboard_is_key_down(crate::dora::from_string(name)) != 0; }
	}
	pub fn is_key_up(name: &str) -> bool {
		unsafe { return keyboard_is_key_up(crate::dora::from_string(name)) != 0; }
	}
	pub fn is_key_pressed(name: &str) -> bool {
		unsafe { return keyboard_is_key_pressed(crate::dora::from_string(name)) != 0; }
	}
	pub fn update_i_m_e_pos_hint(win_pos: &crate::dora::Vec2) {
		unsafe { keyboard_update_i_m_e_pos_hint(win_pos.into_i64()); }
	}
}