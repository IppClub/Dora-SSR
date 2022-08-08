static void otho_camera_set_position(int64_t self, int64_t var)
{
	r_cast<OthoCamera*>(self)->setPosition(into_vec2(var));
}
static int64_t otho_camera_get_position(int64_t self)
{
	return from_vec2(r_cast<OthoCamera*>(self)->getPosition());
}
static int64_t otho_camera_new(int64_t self, int64_t name)
{
	return from_object(r_cast<OthoCamera*>(self)->create(*str_from(name)));
}
static void linkOthoCamera(wasm3::module& mod)
{
	mod.link_optional("*", "otho_camera_set_position", otho_camera_set_position);
	mod.link_optional("*", "otho_camera_get_position", otho_camera_get_position);
	mod.link_optional("*", "otho_camera_new", otho_camera_new);
}