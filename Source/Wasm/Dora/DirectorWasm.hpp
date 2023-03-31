static void director_set_stat_display(int32_t var) {
	SharedDirector.setDisplayStats(var != 0);
}
static int32_t director_is_stat_display() {
	return SharedDirector.isDisplayStats() ? 1 : 0;
}
static void director_set_clear_color(int32_t var) {
	SharedDirector.setClearColor(Color(s_cast<uint32_t>(var)));
}
static int32_t director_get_clear_color() {
	return SharedDirector.getClearColor().toARGB();
}
static void director_set_scheduler(int64_t var) {
	SharedDirector.setScheduler(r_cast<Scheduler*>(var));
}
static int64_t director_get_scheduler() {
	return from_object(SharedDirector.getScheduler());
}
static int64_t director_get_ui() {
	return from_object(SharedDirector.getUI());
}
static int64_t director_get_ui_3d() {
	return from_object(SharedDirector.getUI3D());
}
static int64_t director_get_entry() {
	return from_object(SharedDirector.getEntry());
}
static int64_t director_get_post_node() {
	return from_object(SharedDirector.getPostNode());
}
static int64_t director_get_post_scheduler() {
	return from_object(SharedDirector.getPostScheduler());
}
static int64_t director_get_current_camera() {
	return from_object(SharedDirector.getCurrentCamera());
}
static double director_get_delta_time() {
	return SharedDirector.getDeltaTime();
}
static void director_push_camera(int64_t camera) {
	SharedDirector.pushCamera(r_cast<Camera*>(camera));
}
static void director_pop_camera() {
	SharedDirector.popCamera();
}
static int32_t director_remove_camera(int64_t camera) {
	return SharedDirector.removeCamera(r_cast<Camera*>(camera)) ? 1 : 0;
}
static void director_clear_camera() {
	SharedDirector.clearCamera();
}
static void director_cleanup() {
	SharedDirector.cleanup();
}
static void linkDirector(wasm3::module& mod) {
	mod.link_optional("*", "director_set_stat_display", director_set_stat_display);
	mod.link_optional("*", "director_is_stat_display", director_is_stat_display);
	mod.link_optional("*", "director_set_clear_color", director_set_clear_color);
	mod.link_optional("*", "director_get_clear_color", director_get_clear_color);
	mod.link_optional("*", "director_set_scheduler", director_set_scheduler);
	mod.link_optional("*", "director_get_scheduler", director_get_scheduler);
	mod.link_optional("*", "director_get_ui", director_get_ui);
	mod.link_optional("*", "director_get_ui_3d", director_get_ui_3d);
	mod.link_optional("*", "director_get_entry", director_get_entry);
	mod.link_optional("*", "director_get_post_node", director_get_post_node);
	mod.link_optional("*", "director_get_post_scheduler", director_get_post_scheduler);
	mod.link_optional("*", "director_get_current_camera", director_get_current_camera);
	mod.link_optional("*", "director_get_delta_time", director_get_delta_time);
	mod.link_optional("*", "director_push_camera", director_push_camera);
	mod.link_optional("*", "director_pop_camera", director_pop_camera);
	mod.link_optional("*", "director_remove_camera", director_remove_camera);
	mod.link_optional("*", "director_clear_camera", director_clear_camera);
	mod.link_optional("*", "director_cleanup", director_cleanup);
}