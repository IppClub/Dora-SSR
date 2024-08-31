/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
void director_set_clear_color(int32_t var) {
	SharedDirector.setClearColor(Color(s_cast<uint32_t>(var)));
}
int32_t director_get_clear_color() {
	return SharedDirector.getClearColor().toARGB();
}
int64_t director_get_ui() {
	return Object_From(SharedDirector.getUI());
}
int64_t director_get_ui_3d() {
	return Object_From(SharedDirector.getUI3D());
}
int64_t director_get_entry() {
	return Object_From(SharedDirector.getEntry());
}
int64_t director_get_post_node() {
	return Object_From(SharedDirector.getPostNode());
}
int64_t director_get_current_camera() {
	return Object_From(SharedDirector.getCurrentCamera());
}
void director_set_frustum_culling(int32_t var) {
	SharedDirector.setFrustumCulling(var != 0);
}
int32_t director_is_frustum_culling() {
	return SharedDirector.isFrustumCulling() ? 1 : 0;
}
int64_t director_get_scheduler() {
	return Object_From(Director_GetScheduler());
}
int64_t director_get_post_scheduler() {
	return Object_From(Director_GetPostScheduler());
}
void director_push_camera(int64_t camera) {
	SharedDirector.pushCamera(r_cast<Camera*>(camera));
}
void director_pop_camera() {
	SharedDirector.popCamera();
}
int32_t director_remove_camera(int64_t camera) {
	return SharedDirector.removeCamera(r_cast<Camera*>(camera)) ? 1 : 0;
}
void director_clear_camera() {
	SharedDirector.clearCamera();
}
void director_cleanup() {
	Director_Cleanup();
}
} // extern "C"

static void linkDirector(wasm3::module3& mod) {
	mod.link_optional("*", "director_set_clear_color", director_set_clear_color);
	mod.link_optional("*", "director_get_clear_color", director_get_clear_color);
	mod.link_optional("*", "director_get_ui", director_get_ui);
	mod.link_optional("*", "director_get_ui_3d", director_get_ui_3d);
	mod.link_optional("*", "director_get_entry", director_get_entry);
	mod.link_optional("*", "director_get_post_node", director_get_post_node);
	mod.link_optional("*", "director_get_current_camera", director_get_current_camera);
	mod.link_optional("*", "director_set_frustum_culling", director_set_frustum_culling);
	mod.link_optional("*", "director_is_frustum_culling", director_is_frustum_culling);
	mod.link_optional("*", "director_get_scheduler", director_get_scheduler);
	mod.link_optional("*", "director_get_post_scheduler", director_get_post_scheduler);
	mod.link_optional("*", "director_push_camera", director_push_camera);
	mod.link_optional("*", "director_pop_camera", director_pop_camera);
	mod.link_optional("*", "director_remove_camera", director_remove_camera);
	mod.link_optional("*", "director_clear_camera", director_clear_camera);
	mod.link_optional("*", "director_cleanup", director_cleanup);
}