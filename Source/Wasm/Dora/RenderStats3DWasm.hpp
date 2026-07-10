/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT void renderstats3d_release(int64_t raw) {
	delete r_cast<RenderStats3D*>(raw);
}
DORA_EXPORT int32_t renderstats3d_get_scene_nodes(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getSceneNodes());
}
DORA_EXPORT int32_t renderstats3d_get_visible_visuals(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getVisibleVisuals());
}
DORA_EXPORT int32_t renderstats3d_get_culled_visuals(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getCulledVisuals());
}
DORA_EXPORT int32_t renderstats3d_get_opaque_items(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getOpaqueItems());
}
DORA_EXPORT int32_t renderstats3d_get_transparent_items(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getTransparentItems());
}
DORA_EXPORT int32_t renderstats3d_get_draw_calls(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getDrawCalls());
}
DORA_EXPORT int64_t renderstats3d_get_triangles(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getTriangles());
}
DORA_EXPORT int32_t renderstats3d_get_program_switches(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getProgramSwitches());
}
DORA_EXPORT int32_t renderstats3d_get_material_switches(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getMaterialSwitches());
}
DORA_EXPORT int32_t renderstats3d_get_texture_switches(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getTextureSwitches());
}
DORA_EXPORT int32_t renderstats3d_get_mesh_switches(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getMeshSwitches());
}
DORA_EXPORT int32_t renderstats3d_get_node_count(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getNodeCount());
}
DORA_EXPORT int32_t renderstats3d_get_visual_count(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getVisualCount());
}
DORA_EXPORT int32_t renderstats3d_get_model_count(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getModelCount());
}
DORA_EXPORT int32_t renderstats3d_get_model_instance_count(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getModelInstanceCount());
}
DORA_EXPORT int32_t renderstats3d_get_mesh_count(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getMeshCount());
}
DORA_EXPORT int32_t renderstats3d_get_material_count(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getMaterialCount());
}
DORA_EXPORT int32_t renderstats3d_get_texture_count(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getTextureCount());
}
DORA_EXPORT int32_t renderstats3d_get_animation_count(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getAnimationCount());
}
DORA_EXPORT int32_t renderstats3d_get_environment_count(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderStats3D*>(self)->getEnvironmentCount());
}
DORA_EXPORT int64_t renderstats3d_get_model_resident_bytes(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getModelResidentBytes());
}
DORA_EXPORT int64_t renderstats3d_get_mesh_resident_bytes(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getMeshResidentBytes());
}
DORA_EXPORT int64_t renderstats3d_get_texture_resident_bytes(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getTextureResidentBytes());
}
DORA_EXPORT int64_t renderstats3d_get_collect_micros(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getCollectMicros());
}
DORA_EXPORT int64_t renderstats3d_get_sort_micros(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getSortMicros());
}
DORA_EXPORT int64_t renderstats3d_get_submit_micros(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getSubmitMicros());
}
DORA_EXPORT int64_t renderstats3d_get_upload_commands(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getUploadCommands());
}
DORA_EXPORT int64_t renderstats3d_get_upload_bytes(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getUploadBytes());
}
DORA_EXPORT int64_t renderstats3d_get_upload_micros(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getUploadMicros());
}
DORA_EXPORT int64_t renderstats3d_get_upload_max_command_micros(int64_t self) {
	return s_cast<int64_t>(r_cast<RenderStats3D*>(self)->getUploadMaxCommandMicros());
}
} // extern "C"

static void linkRenderStats3D(wasm3::module3& mod) {
	mod.link_optional("*", "renderstats3d_release", renderstats3d_release);
	mod.link_optional("*", "renderstats3d_get_scene_nodes", renderstats3d_get_scene_nodes);
	mod.link_optional("*", "renderstats3d_get_visible_visuals", renderstats3d_get_visible_visuals);
	mod.link_optional("*", "renderstats3d_get_culled_visuals", renderstats3d_get_culled_visuals);
	mod.link_optional("*", "renderstats3d_get_opaque_items", renderstats3d_get_opaque_items);
	mod.link_optional("*", "renderstats3d_get_transparent_items", renderstats3d_get_transparent_items);
	mod.link_optional("*", "renderstats3d_get_draw_calls", renderstats3d_get_draw_calls);
	mod.link_optional("*", "renderstats3d_get_triangles", renderstats3d_get_triangles);
	mod.link_optional("*", "renderstats3d_get_program_switches", renderstats3d_get_program_switches);
	mod.link_optional("*", "renderstats3d_get_material_switches", renderstats3d_get_material_switches);
	mod.link_optional("*", "renderstats3d_get_texture_switches", renderstats3d_get_texture_switches);
	mod.link_optional("*", "renderstats3d_get_mesh_switches", renderstats3d_get_mesh_switches);
	mod.link_optional("*", "renderstats3d_get_node_count", renderstats3d_get_node_count);
	mod.link_optional("*", "renderstats3d_get_visual_count", renderstats3d_get_visual_count);
	mod.link_optional("*", "renderstats3d_get_model_count", renderstats3d_get_model_count);
	mod.link_optional("*", "renderstats3d_get_model_instance_count", renderstats3d_get_model_instance_count);
	mod.link_optional("*", "renderstats3d_get_mesh_count", renderstats3d_get_mesh_count);
	mod.link_optional("*", "renderstats3d_get_material_count", renderstats3d_get_material_count);
	mod.link_optional("*", "renderstats3d_get_texture_count", renderstats3d_get_texture_count);
	mod.link_optional("*", "renderstats3d_get_animation_count", renderstats3d_get_animation_count);
	mod.link_optional("*", "renderstats3d_get_environment_count", renderstats3d_get_environment_count);
	mod.link_optional("*", "renderstats3d_get_model_resident_bytes", renderstats3d_get_model_resident_bytes);
	mod.link_optional("*", "renderstats3d_get_mesh_resident_bytes", renderstats3d_get_mesh_resident_bytes);
	mod.link_optional("*", "renderstats3d_get_texture_resident_bytes", renderstats3d_get_texture_resident_bytes);
	mod.link_optional("*", "renderstats3d_get_collect_micros", renderstats3d_get_collect_micros);
	mod.link_optional("*", "renderstats3d_get_sort_micros", renderstats3d_get_sort_micros);
	mod.link_optional("*", "renderstats3d_get_submit_micros", renderstats3d_get_submit_micros);
	mod.link_optional("*", "renderstats3d_get_upload_commands", renderstats3d_get_upload_commands);
	mod.link_optional("*", "renderstats3d_get_upload_bytes", renderstats3d_get_upload_bytes);
	mod.link_optional("*", "renderstats3d_get_upload_micros", renderstats3d_get_upload_micros);
	mod.link_optional("*", "renderstats3d_get_upload_max_command_micros", renderstats3d_get_upload_max_command_micros);
}