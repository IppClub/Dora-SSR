static int32_t controller_is_button_down(int32_t controller_id, int64_t name) {
	return SharedController.isButtonDown(s_cast<int>(controller_id), *str_from(name)) ? 1 : 0;
}
static int32_t controller_is_button_up(int32_t controller_id, int64_t name) {
	return SharedController.isButtonUp(s_cast<int>(controller_id), *str_from(name)) ? 1 : 0;
}
static int32_t controller_is_button_pressed(int32_t controller_id, int64_t name) {
	return SharedController.isButtonPressed(s_cast<int>(controller_id), *str_from(name)) ? 1 : 0;
}
static float controller_get_axis(int32_t controller_id, int64_t name) {
	return SharedController.getAxis(s_cast<int>(controller_id), *str_from(name));
}
static void linkController(wasm3::module3& mod) {
	mod.link_optional("*", "controller_is_button_down", controller_is_button_down);
	mod.link_optional("*", "controller_is_button_up", controller_is_button_up);
	mod.link_optional("*", "controller_is_button_pressed", controller_is_button_pressed);
	mod.link_optional("*", "controller_get_axis", controller_get_axis);
}