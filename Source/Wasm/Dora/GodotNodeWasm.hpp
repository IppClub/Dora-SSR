/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t godotnode_type() {
	return DoraType<GodotNode>();
}
DORA_EXPORT int64_t godotnode_get_unsupported_reason() {
	return Str_Retain(GodotNode::getUnsupportedReason());
}
DORA_EXPORT int64_t godotnode_get_project_path(int64_t self) {
	return Str_Retain(r_cast<GodotNode*>(self)->getProjectPath());
}
DORA_EXPORT int64_t godotnode_get_scene_file(int64_t self) {
	return Str_Retain(r_cast<GodotNode*>(self)->getSceneFile());
}
DORA_EXPORT int64_t godotnode_get_last_error(int64_t self) {
	return Str_Retain(r_cast<GodotNode*>(self)->getLastError());
}
DORA_EXPORT int32_t godotnode_is_running(int64_t self) {
	return r_cast<GodotNode*>(self)->isRunning() ? 1 : 0;
}
DORA_EXPORT int32_t godotnode_is_paused(int64_t self) {
	return r_cast<GodotNode*>(self)->isPaused() ? 1 : 0;
}
DORA_EXPORT int64_t godotnode_get_viewport_size(int64_t self) {
	return Size_Retain(r_cast<GodotNode*>(self)->getViewportSize());
}
DORA_EXPORT int32_t godotnode_resize_viewport(int64_t self, int32_t width, int32_t height) {
	return r_cast<GodotNode*>(self)->resizeViewport(s_cast<int>(width), s_cast<int>(height)) ? 1 : 0;
}
DORA_EXPORT void godotnode_pause(int64_t self) {
	r_cast<GodotNode*>(self)->pause();
}
DORA_EXPORT void godotnode_resume(int64_t self) {
	r_cast<GodotNode*>(self)->resume();
}
DORA_EXPORT int32_t godotnode_restart(int64_t self, int64_t scene_file) {
	return r_cast<GodotNode*>(self)->restart(*Str_From(scene_file)) ? 1 : 0;
}
DORA_EXPORT void godotnode_send_pointer(int64_t self, double x, double y, int32_t button, int32_t pressed) {
	r_cast<GodotNode*>(self)->sendPointer(x, y, s_cast<int>(button), pressed != 0);
}
DORA_EXPORT void godotnode_send_pointer_move(int64_t self, double x, double y) {
	r_cast<GodotNode*>(self)->sendPointerMove(x, y);
}
DORA_EXPORT void godotnode_send_key(int64_t self, int64_t name, int32_t pressed) {
	r_cast<GodotNode*>(self)->sendKey(*Str_From(name), pressed != 0);
}
DORA_EXPORT void godotnode_send_text(int64_t self, int64_t text) {
	r_cast<GodotNode*>(self)->sendText(*Str_From(text));
}
DORA_EXPORT int64_t godotnode_new(int64_t project_path, int64_t scene_file, int32_t width, int32_t height, int32_t buffers) {
	return Object_From(GodotNode::create(*Str_From(project_path), *Str_From(scene_file), s_cast<int>(width), s_cast<int>(height), s_cast<int>(buffers)));
}
} // extern "C"

static void linkGodotNode(wasm3::module3& mod) {
	mod.link_optional("*", "godotnode_type", godotnode_type);
	mod.link_optional("*", "godotnode_get_unsupported_reason", godotnode_get_unsupported_reason);
	mod.link_optional("*", "godotnode_get_project_path", godotnode_get_project_path);
	mod.link_optional("*", "godotnode_get_scene_file", godotnode_get_scene_file);
	mod.link_optional("*", "godotnode_get_last_error", godotnode_get_last_error);
	mod.link_optional("*", "godotnode_is_running", godotnode_is_running);
	mod.link_optional("*", "godotnode_is_paused", godotnode_is_paused);
	mod.link_optional("*", "godotnode_get_viewport_size", godotnode_get_viewport_size);
	mod.link_optional("*", "godotnode_resize_viewport", godotnode_resize_viewport);
	mod.link_optional("*", "godotnode_pause", godotnode_pause);
	mod.link_optional("*", "godotnode_resume", godotnode_resume);
	mod.link_optional("*", "godotnode_restart", godotnode_restart);
	mod.link_optional("*", "godotnode_send_pointer", godotnode_send_pointer);
	mod.link_optional("*", "godotnode_send_pointer_move", godotnode_send_pointer_move);
	mod.link_optional("*", "godotnode_send_key", godotnode_send_key);
	mod.link_optional("*", "godotnode_send_text", godotnode_send_text);
	mod.link_optional("*", "godotnode_new", godotnode_new);
}