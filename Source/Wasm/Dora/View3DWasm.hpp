/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t view3d_type() {
	return DoraType<View3D>();
}
DORA_EXPORT int64_t view3d_get_scene(int64_t self) {
	return Object_From(r_cast<View3D*>(self)->getScene());
}
DORA_EXPORT int64_t view3d_get_stats(int64_t self) {
	return r_cast<int64_t>(new RenderStats3D{r_cast<View3D*>(self)->getStats()});
}
DORA_EXPORT void view3d_add_child_3d(int64_t self, int64_t child) {
	r_cast<View3D*>(self)->addChild(r_cast<Node3D*>(child));
}
DORA_EXPORT int32_t view3d_set_environment_map(int64_t self, int64_t path) {
	return r_cast<View3D*>(self)->setEnvironmentMap(*Str_From(path)) ? 1 : 0;
}
DORA_EXPORT void view3d_set_environment_intensity(int64_t self, float diffuse, float specular, float exposure) {
	r_cast<View3D*>(self)->setEnvironmentIntensity(diffuse, specular, exposure);
}
DORA_EXPORT int64_t view3d_new() {
	return Object_From(View3D::create());
}
} // extern "C"

static void linkView3D(wasm3::module3& mod) {
	mod.link_optional("*", "view3d_type", view3d_type);
	mod.link_optional("*", "view3d_get_scene", view3d_get_scene);
	mod.link_optional("*", "view3d_get_stats", view3d_get_stats);
	mod.link_optional("*", "view3d_add_child_3d", view3d_add_child_3d);
	mod.link_optional("*", "view3d_set_environment_map", view3d_set_environment_map);
	mod.link_optional("*", "view3d_set_environment_intensity", view3d_set_environment_intensity);
	mod.link_optional("*", "view3d_new", view3d_new);
}