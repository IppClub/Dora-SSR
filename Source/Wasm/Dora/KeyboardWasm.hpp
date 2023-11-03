static int32_t keyboard_is_key_down(int64_t name) {
	return SharedKeyboard.isKeyDown(*str_from(name)) ? 1 : 0;
}
static int32_t keyboard_is_key_up(int64_t name) {
	return SharedKeyboard.isKeyUp(*str_from(name)) ? 1 : 0;
}
static int32_t keyboard_is_key_pressed(int64_t name) {
	return SharedKeyboard.isKeyPressed(*str_from(name)) ? 1 : 0;
}
static void keyboard_update_i_m_e_pos_hint(int64_t win_pos) {
	SharedKeyboard.updateIMEPosHint(vec2_from(win_pos));
}
static void linkKeyboard(wasm3::module3& mod) {
	mod.link_optional("*", "keyboard_is_key_down", keyboard_is_key_down);
	mod.link_optional("*", "keyboard_is_key_up", keyboard_is_key_up);
	mod.link_optional("*", "keyboard_is_key_pressed", keyboard_is_key_pressed);
	mod.link_optional("*", "keyboard_update_i_m_e_pos_hint", keyboard_update_i_m_e_pos_hint);
}