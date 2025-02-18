/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t application_get_frame() {
	return s_cast<int32_t>(SharedApplication.getFrame());
}
int64_t application_get_buffer_size() {
	return Size_Retain(SharedApplication.getBufferSize());
}
int64_t application_get_visual_size() {
	return Size_Retain(SharedApplication.getVisualSize());
}
float application_get_device_pixel_ratio() {
	return SharedApplication.getDevicePixelRatio();
}
int64_t application_get_platform() {
	return Str_Retain(SharedApplication.getPlatform());
}
int64_t application_get_version() {
	return Str_Retain(SharedApplication.getVersion());
}
int64_t application_get_deps() {
	return Str_Retain(SharedApplication.getDeps());
}
double application_get_delta_time() {
	return SharedApplication.getDeltaTime();
}
double application_get_elapsed_time() {
	return SharedApplication.getElapsedTime();
}
double application_get_total_time() {
	return SharedApplication.getTotalTime();
}
double application_get_running_time() {
	return SharedApplication.getRunningTime();
}
int64_t application_get_rand() {
	return s_cast<int64_t>(SharedApplication.getRand());
}
int32_t application_get_max_fps() {
	return s_cast<int32_t>(SharedApplication.getMaxFPS());
}
int32_t application_is_debugging() {
	return SharedApplication.isDebugging() ? 1 : 0;
}
void application_set_locale(int64_t val) {
	SharedApplication.setLocale(*Str_From(val));
}
int64_t application_get_locale() {
	return Str_Retain(SharedApplication.getLocale());
}
void application_set_theme_color(int32_t val) {
	SharedApplication.setThemeColor(Color(s_cast<uint32_t>(val)));
}
int32_t application_get_theme_color() {
	return SharedApplication.getThemeColor().toARGB();
}
void application_set_seed(int32_t val) {
	SharedApplication.setSeed(s_cast<uint32_t>(val));
}
int32_t application_get_seed() {
	return s_cast<int32_t>(SharedApplication.getSeed());
}
void application_set_target_fps(int32_t val) {
	SharedApplication.setTargetFPS(s_cast<uint32_t>(val));
}
int32_t application_get_target_fps() {
	return s_cast<int32_t>(SharedApplication.getTargetFPS());
}
void application_set_win_size(int64_t val) {
	SharedApplication.setWinSize(Size_From(val));
}
int64_t application_get_win_size() {
	return Size_Retain(SharedApplication.getWinSize());
}
void application_set_win_position(int64_t val) {
	SharedApplication.setWinPosition(Vec2_From(val));
}
int64_t application_get_win_position() {
	return Vec2_Retain(SharedApplication.getWinPosition());
}
void application_set_fps_limited(int32_t val) {
	SharedApplication.setFPSLimited(val != 0);
}
int32_t application_is_fps_limited() {
	return SharedApplication.isFPSLimited() ? 1 : 0;
}
void application_set_idled(int32_t val) {
	SharedApplication.setIdled(val != 0);
}
int32_t application_is_idled() {
	return SharedApplication.isIdled() ? 1 : 0;
}
void application_set_full_screen(int32_t val) {
	SharedApplication.setFullScreen(val != 0);
}
int32_t application_is_full_screen() {
	return SharedApplication.isFullScreen() ? 1 : 0;
}
void application_set_always_on_top(int32_t val) {
	SharedApplication.setAlwaysOnTop(val != 0);
}
int32_t application_is_always_on_top() {
	return SharedApplication.isAlwaysOnTop() ? 1 : 0;
}
void application_shutdown() {
	SharedApplication.shutdown();
}
} // extern "C"

static void linkApplication(wasm3::module3& mod) {
	mod.link_optional("*", "application_get_frame", application_get_frame);
	mod.link_optional("*", "application_get_buffer_size", application_get_buffer_size);
	mod.link_optional("*", "application_get_visual_size", application_get_visual_size);
	mod.link_optional("*", "application_get_device_pixel_ratio", application_get_device_pixel_ratio);
	mod.link_optional("*", "application_get_platform", application_get_platform);
	mod.link_optional("*", "application_get_version", application_get_version);
	mod.link_optional("*", "application_get_deps", application_get_deps);
	mod.link_optional("*", "application_get_delta_time", application_get_delta_time);
	mod.link_optional("*", "application_get_elapsed_time", application_get_elapsed_time);
	mod.link_optional("*", "application_get_total_time", application_get_total_time);
	mod.link_optional("*", "application_get_running_time", application_get_running_time);
	mod.link_optional("*", "application_get_rand", application_get_rand);
	mod.link_optional("*", "application_get_max_fps", application_get_max_fps);
	mod.link_optional("*", "application_is_debugging", application_is_debugging);
	mod.link_optional("*", "application_set_locale", application_set_locale);
	mod.link_optional("*", "application_get_locale", application_get_locale);
	mod.link_optional("*", "application_set_theme_color", application_set_theme_color);
	mod.link_optional("*", "application_get_theme_color", application_get_theme_color);
	mod.link_optional("*", "application_set_seed", application_set_seed);
	mod.link_optional("*", "application_get_seed", application_get_seed);
	mod.link_optional("*", "application_set_target_fps", application_set_target_fps);
	mod.link_optional("*", "application_get_target_fps", application_get_target_fps);
	mod.link_optional("*", "application_set_win_size", application_set_win_size);
	mod.link_optional("*", "application_get_win_size", application_get_win_size);
	mod.link_optional("*", "application_set_win_position", application_set_win_position);
	mod.link_optional("*", "application_get_win_position", application_get_win_position);
	mod.link_optional("*", "application_set_fps_limited", application_set_fps_limited);
	mod.link_optional("*", "application_is_fps_limited", application_is_fps_limited);
	mod.link_optional("*", "application_set_idled", application_set_idled);
	mod.link_optional("*", "application_is_idled", application_is_idled);
	mod.link_optional("*", "application_set_full_screen", application_set_full_screen);
	mod.link_optional("*", "application_is_full_screen", application_is_full_screen);
	mod.link_optional("*", "application_set_always_on_top", application_set_always_on_top);
	mod.link_optional("*", "application_is_always_on_top", application_is_always_on_top);
	mod.link_optional("*", "application_shutdown", application_shutdown);
}