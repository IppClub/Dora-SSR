static int32_t application_get_frame() {
	return s_cast<int32_t>(SharedApplication.getFrame());
}
static int64_t application_get_buffer_size() {
	return size_retain(SharedApplication.getBufferSize());
}
static int64_t application_get_visual_size() {
	return size_retain(SharedApplication.getVisualSize());
}
static float application_get_device_pixel_ratio() {
	return SharedApplication.getDevicePixelRatio();
}
static int64_t application_get_platform() {
	return str_retain(SharedApplication.getPlatform());
}
static int64_t application_get_version() {
	return str_retain(SharedApplication.getVersion());
}
static int64_t application_get_deps() {
	return str_retain(SharedApplication.getDeps());
}
static double application_get_eclapsed_time() {
	return SharedApplication.getEclapsedTime();
}
static double application_get_total_time() {
	return SharedApplication.getTotalTime();
}
static double application_get_running_time() {
	return SharedApplication.getRunningTime();
}
static int32_t application_get_rand() {
	return s_cast<int32_t>(SharedApplication.getRand());
}
static int32_t application_get_max_fps() {
	return s_cast<int32_t>(SharedApplication.getMaxFPS());
}
static int32_t application_is_debugging() {
	return SharedApplication.isDebugging() ? 1 : 0;
}
static void application_set_seed(int32_t var) {
	SharedApplication.setSeed(s_cast<uint32_t>(var));
}
static int32_t application_get_seed() {
	return s_cast<int32_t>(SharedApplication.getSeed());
}
static void application_set_target_fps(int32_t var) {
	SharedApplication.setTargetFPS(s_cast<uint32_t>(var));
}
static int32_t application_get_target_fps() {
	return s_cast<int32_t>(SharedApplication.getTargetFPS());
}
static void application_set_fps_limited(int32_t var) {
	SharedApplication.setFPSLimited(var != 0);
}
static int32_t application_is_fps_limited() {
	return SharedApplication.isFPSLimited() ? 1 : 0;
}
static void application_set_idled(int32_t var) {
	SharedApplication.setIdled(var != 0);
}
static int32_t application_is_idled() {
	return SharedApplication.isIdled() ? 1 : 0;
}
static void application_shutdown() {
	SharedApplication.shutdown();
}
static void linkApplication(wasm3::module& mod) {
	mod.link_optional("*", "application_get_frame", application_get_frame);
	mod.link_optional("*", "application_get_buffer_size", application_get_buffer_size);
	mod.link_optional("*", "application_get_visual_size", application_get_visual_size);
	mod.link_optional("*", "application_get_device_pixel_ratio", application_get_device_pixel_ratio);
	mod.link_optional("*", "application_get_platform", application_get_platform);
	mod.link_optional("*", "application_get_version", application_get_version);
	mod.link_optional("*", "application_get_deps", application_get_deps);
	mod.link_optional("*", "application_get_eclapsed_time", application_get_eclapsed_time);
	mod.link_optional("*", "application_get_total_time", application_get_total_time);
	mod.link_optional("*", "application_get_running_time", application_get_running_time);
	mod.link_optional("*", "application_get_rand", application_get_rand);
	mod.link_optional("*", "application_get_max_fps", application_get_max_fps);
	mod.link_optional("*", "application_is_debugging", application_is_debugging);
	mod.link_optional("*", "application_set_seed", application_set_seed);
	mod.link_optional("*", "application_get_seed", application_get_seed);
	mod.link_optional("*", "application_set_target_fps", application_set_target_fps);
	mod.link_optional("*", "application_get_target_fps", application_get_target_fps);
	mod.link_optional("*", "application_set_fps_limited", application_set_fps_limited);
	mod.link_optional("*", "application_is_fps_limited", application_is_fps_limited);
	mod.link_optional("*", "application_set_idled", application_set_idled);
	mod.link_optional("*", "application_is_idled", application_is_idled);
	mod.link_optional("*", "application_shutdown", application_shutdown);
}