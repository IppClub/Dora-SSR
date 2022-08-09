static int64_t view_get_size()
{
	return size_retain(SharedView.getSize());
}
static float view_get_standard_distance()
{
	return SharedView.getStandardDistance();
}
static float view_get_aspect_ratio()
{
	return SharedView.getAspectRatio();
}
static void view_set_near_plane_distance(float var)
{
	SharedView.setNearPlaneDistance(var);
}
static float view_get_near_plane_distance()
{
	return SharedView.getNearPlaneDistance();
}
static void view_set_far_plane_distance(float var)
{
	SharedView.setFarPlaneDistance(var);
}
static float view_get_far_plane_distance()
{
	return SharedView.getFarPlaneDistance();
}
static void view_set_field_of_view(float var)
{
	SharedView.setFieldOfView(var);
}
static float view_get_field_of_view()
{
	return SharedView.getFieldOfView();
}
static void view_set_scale(float var)
{
	SharedView.setScale(var);
}
static float view_get_scale()
{
	return SharedView.getScale();
}
static void view_set_post_effect(int64_t var)
{
	SharedView.setPostEffect(r_cast<SpriteEffect*>(var));
}
static int64_t view_get_post_effect()
{
	return from_object(SharedView.getPostEffect());
}
static void view_set_vsync(int32_t var)
{
	SharedView.setVSync(var != 0);
}
static int32_t view_is_vsync()
{
	return SharedView.isVSync() ? 1 : 0;
}
static void linkView(wasm3::module& mod)
{
	mod.link_optional("*", "view_get_size", view_get_size);
	mod.link_optional("*", "view_get_standard_distance", view_get_standard_distance);
	mod.link_optional("*", "view_get_aspect_ratio", view_get_aspect_ratio);
	mod.link_optional("*", "view_set_near_plane_distance", view_set_near_plane_distance);
	mod.link_optional("*", "view_get_near_plane_distance", view_get_near_plane_distance);
	mod.link_optional("*", "view_set_far_plane_distance", view_set_far_plane_distance);
	mod.link_optional("*", "view_get_far_plane_distance", view_get_far_plane_distance);
	mod.link_optional("*", "view_set_field_of_view", view_set_field_of_view);
	mod.link_optional("*", "view_get_field_of_view", view_get_field_of_view);
	mod.link_optional("*", "view_set_scale", view_set_scale);
	mod.link_optional("*", "view_get_scale", view_get_scale);
	mod.link_optional("*", "view_set_post_effect", view_set_post_effect);
	mod.link_optional("*", "view_get_post_effect", view_get_post_effect);
	mod.link_optional("*", "view_set_vsync", view_set_vsync);
	mod.link_optional("*", "view_is_vsync", view_is_vsync);
}