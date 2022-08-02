static void director_set_stats_display(int32_t var)
{
	SharedDirector.setDisplayStats(var != 0);
}
static int32_t director_is_stats_display()
{
	return SharedDirector.isDisplayStats() ? 1 : 0;
}
static int64_t director_get_ui()
{
	return from_object(SharedDirector.getUI());
}
static int64_t director_get_ui3d()
{
	return from_object(SharedDirector.getUI3D());
}
static int64_t director_get_entry()
{
	return from_object(SharedDirector.getEntry());
}
static int64_t director_get_post_node()
{
	return from_object(SharedDirector.getPostNode());
}
static double director_get_delta_time()
{
	return SharedDirector.getDeltaTime();
}
static void director_pop_camera()
{
	SharedDirector.popCamera();
}
static void director_clear_camera()
{
	SharedDirector.clearCamera();
}
static void director_cleanup()
{
	SharedDirector.cleanup();
}
static void linkDirector(wasm3::module& mod)
{
	mod.link_optional("*", "director_set_stats_display", director_set_stats_display);
	mod.link_optional("*", "director_is_stats_display", director_is_stats_display);
	mod.link_optional("*", "director_get_ui", director_get_ui);
	mod.link_optional("*", "director_get_ui3d", director_get_ui3d);
	mod.link_optional("*", "director_get_entry", director_get_entry);
	mod.link_optional("*", "director_get_post_node", director_get_post_node);
	mod.link_optional("*", "director_get_delta_time", director_get_delta_time);
	mod.link_optional("*", "director_pop_camera", director_pop_camera);
	mod.link_optional("*", "director_clear_camera", director_clear_camera);
	mod.link_optional("*", "director_cleanup", director_cleanup);
}