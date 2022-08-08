static int32_t camera_type()
{
	return DoraType<Camera>();
}
static int64_t camera_get_name(int64_t self)
{
	return str_retain(r_cast<Camera*>(self)->getName());
}
static void linkCamera(wasm3::module& mod)
{
	mod.link_optional("*", "camera_type", camera_type);
	mod.link_optional("*", "camera_get_name", camera_get_name);
}