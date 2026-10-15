/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn renderstats3d_release(raw: i64);
	fn renderstats3d_get_scene_nodes(slf: i64) -> i32;
	fn renderstats3d_get_visible_visuals(slf: i64) -> i32;
	fn renderstats3d_get_culled_visuals(slf: i64) -> i32;
	fn renderstats3d_get_opaque_items(slf: i64) -> i32;
	fn renderstats3d_get_transparent_items(slf: i64) -> i32;
	fn renderstats3d_get_draw_calls(slf: i64) -> i32;
	fn renderstats3d_get_triangles(slf: i64) -> i64;
	fn renderstats3d_get_program_switches(slf: i64) -> i32;
	fn renderstats3d_get_material_switches(slf: i64) -> i32;
	fn renderstats3d_get_texture_switches(slf: i64) -> i32;
	fn renderstats3d_get_mesh_switches(slf: i64) -> i32;
	fn renderstats3d_get_node_count(slf: i64) -> i32;
	fn renderstats3d_get_visual_count(slf: i64) -> i32;
	fn renderstats3d_get_model_count(slf: i64) -> i32;
	fn renderstats3d_get_model_instance_count(slf: i64) -> i32;
	fn renderstats3d_get_mesh_count(slf: i64) -> i32;
	fn renderstats3d_get_static_mesh_count(slf: i64) -> i32;
	fn renderstats3d_get_dynamic_mesh_count(slf: i64) -> i32;
	fn renderstats3d_get_material_count(slf: i64) -> i32;
	fn renderstats3d_get_texture_count(slf: i64) -> i32;
	fn renderstats3d_get_animation_count(slf: i64) -> i32;
	fn renderstats3d_get_environment_count(slf: i64) -> i32;
	fn renderstats3d_get_model_resident_bytes(slf: i64) -> i64;
	fn renderstats3d_get_mesh_resident_bytes(slf: i64) -> i64;
	fn renderstats3d_get_texture_resident_bytes(slf: i64) -> i64;
	fn renderstats3d_get_collect_micros(slf: i64) -> i64;
	fn renderstats3d_get_sort_micros(slf: i64) -> i64;
	fn renderstats3d_get_submit_micros(slf: i64) -> i64;
	fn renderstats3d_get_upload_commands(slf: i64) -> i64;
	fn renderstats3d_get_upload_bytes(slf: i64) -> i64;
	fn renderstats3d_get_upload_micros(slf: i64) -> i64;
	fn renderstats3d_get_upload_max_command_micros(slf: i64) -> i64;
}
/// Statistics captured from the most recent 3D render for a View3D.
pub struct RenderStats3D { raw: i64 }
impl Drop for RenderStats3D {
	fn drop(&mut self) { unsafe { renderstats3d_release(self.raw); } }
}
impl RenderStats3D {
	pub(crate) fn raw(&self) -> i64 {
		self.raw
	}
	pub(crate) fn from(raw: i64) -> RenderStats3D {
		RenderStats3D { raw: raw }
	}
	pub fn get_scene_nodes(&self) -> i32 {
		return unsafe { renderstats3d_get_scene_nodes(self.raw()) };
	}
	pub fn get_visible_visuals(&self) -> i32 {
		return unsafe { renderstats3d_get_visible_visuals(self.raw()) };
	}
	pub fn get_culled_visuals(&self) -> i32 {
		return unsafe { renderstats3d_get_culled_visuals(self.raw()) };
	}
	pub fn get_opaque_items(&self) -> i32 {
		return unsafe { renderstats3d_get_opaque_items(self.raw()) };
	}
	pub fn get_transparent_items(&self) -> i32 {
		return unsafe { renderstats3d_get_transparent_items(self.raw()) };
	}
	pub fn get_draw_calls(&self) -> i32 {
		return unsafe { renderstats3d_get_draw_calls(self.raw()) };
	}
	pub fn get_triangles(&self) -> i64 {
		return unsafe { renderstats3d_get_triangles(self.raw()) };
	}
	pub fn get_program_switches(&self) -> i32 {
		return unsafe { renderstats3d_get_program_switches(self.raw()) };
	}
	pub fn get_material_switches(&self) -> i32 {
		return unsafe { renderstats3d_get_material_switches(self.raw()) };
	}
	pub fn get_texture_switches(&self) -> i32 {
		return unsafe { renderstats3d_get_texture_switches(self.raw()) };
	}
	pub fn get_mesh_switches(&self) -> i32 {
		return unsafe { renderstats3d_get_mesh_switches(self.raw()) };
	}
	pub fn get_node_count(&self) -> i32 {
		return unsafe { renderstats3d_get_node_count(self.raw()) };
	}
	pub fn get_visual_count(&self) -> i32 {
		return unsafe { renderstats3d_get_visual_count(self.raw()) };
	}
	pub fn get_model_count(&self) -> i32 {
		return unsafe { renderstats3d_get_model_count(self.raw()) };
	}
	pub fn get_model_instance_count(&self) -> i32 {
		return unsafe { renderstats3d_get_model_instance_count(self.raw()) };
	}
	pub fn get_mesh_count(&self) -> i32 {
		return unsafe { renderstats3d_get_mesh_count(self.raw()) };
	}
	pub fn get_static_mesh_count(&self) -> i32 {
		return unsafe { renderstats3d_get_static_mesh_count(self.raw()) };
	}
	pub fn get_dynamic_mesh_count(&self) -> i32 {
		return unsafe { renderstats3d_get_dynamic_mesh_count(self.raw()) };
	}
	pub fn get_material_count(&self) -> i32 {
		return unsafe { renderstats3d_get_material_count(self.raw()) };
	}
	pub fn get_texture_count(&self) -> i32 {
		return unsafe { renderstats3d_get_texture_count(self.raw()) };
	}
	pub fn get_animation_count(&self) -> i32 {
		return unsafe { renderstats3d_get_animation_count(self.raw()) };
	}
	pub fn get_environment_count(&self) -> i32 {
		return unsafe { renderstats3d_get_environment_count(self.raw()) };
	}
	pub fn get_model_resident_bytes(&self) -> i64 {
		return unsafe { renderstats3d_get_model_resident_bytes(self.raw()) };
	}
	pub fn get_mesh_resident_bytes(&self) -> i64 {
		return unsafe { renderstats3d_get_mesh_resident_bytes(self.raw()) };
	}
	pub fn get_texture_resident_bytes(&self) -> i64 {
		return unsafe { renderstats3d_get_texture_resident_bytes(self.raw()) };
	}
	pub fn get_collect_micros(&self) -> i64 {
		return unsafe { renderstats3d_get_collect_micros(self.raw()) };
	}
	pub fn get_sort_micros(&self) -> i64 {
		return unsafe { renderstats3d_get_sort_micros(self.raw()) };
	}
	pub fn get_submit_micros(&self) -> i64 {
		return unsafe { renderstats3d_get_submit_micros(self.raw()) };
	}
	pub fn get_upload_commands(&self) -> i64 {
		return unsafe { renderstats3d_get_upload_commands(self.raw()) };
	}
	pub fn get_upload_bytes(&self) -> i64 {
		return unsafe { renderstats3d_get_upload_bytes(self.raw()) };
	}
	pub fn get_upload_micros(&self) -> i64 {
		return unsafe { renderstats3d_get_upload_micros(self.raw()) };
	}
	pub fn get_upload_max_command_micros(&self) -> i64 {
		return unsafe { renderstats3d_get_upload_max_command_micros(self.raw()) };
	}
}