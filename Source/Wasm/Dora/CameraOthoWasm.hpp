static int32_t cameraotho_type() {
	return DoraType<CameraOtho>();
}
static void cameraotho_set_position(int64_t self, int64_t var) {
	r_cast<CameraOtho*>(self)->setPosition(vec2_from(var));
}
static int64_t cameraotho_get_position(int64_t self) {
	return vec2_retain(r_cast<CameraOtho*>(self)->getPosition());
}
static int64_t cameraotho_new(int64_t name) {
	return from_object(CameraOtho::create(*str_from(name)));
}
static void linkCameraOtho(wasm3::module3& mod) {
	mod.link_optional("*", "cameraotho_type", cameraotho_type);
	mod.link_optional("*", "cameraotho_set_position", cameraotho_set_position);
	mod.link_optional("*", "cameraotho_get_position", cameraotho_get_position);
	mod.link_optional("*", "cameraotho_new", cameraotho_new);
}