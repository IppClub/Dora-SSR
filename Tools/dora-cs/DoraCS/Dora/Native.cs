/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

using System.Runtime.InteropServices;
using int64_t = long;
using int32_t = int;

namespace Dora
{
	internal static partial class Native
	{
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t array_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t array_get_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t array_is_empty(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_add_range(int64_t self, int64_t other);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_remove_from(int64_t self, int64_t other);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_reverse(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_shrink(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_swap(int64_t self, int32_t index_a, int32_t index_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t array_remove_at(int64_t self, int32_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t array_fast_remove_at(int64_t self, int32_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t array_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t dictionary_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t dictionary_get_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dictionary_get_keys(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dictionary_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dictionary_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_origin(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_get_origin(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_size(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_get_size(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_width(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_height(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_left(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_left(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_right(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_right(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_center_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_center_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_center_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_center_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_bottom(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_bottom(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_top(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_top(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_lower_bound(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_get_lower_bound(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_upper_bound(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_get_upper_bound(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set(int64_t self, float x, float y, float width, float height);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t rect_contains_point(int64_t self, int64_t point);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t rect_intersects_rect(int64_t self, int64_t rect);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t rect_equals(int64_t self, int64_t other);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_new(int64_t origin, int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_zero();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_get_frame();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_buffer_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_visual_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float application_get_device_pixel_ratio();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_platform();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_version();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_deps();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern double application_get_delta_time();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern double application_get_elapsed_time();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern double application_get_total_time();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern double application_get_running_time();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_rand();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_get_max_fps();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_debugging();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_locale(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_locale();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_theme_color(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_get_theme_color();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_seed(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_get_seed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_target_fps(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_get_target_fps();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_win_size(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_win_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_win_position(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_win_position();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_fps_limited(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_fps_limited();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_idled(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_idled();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_full_screen(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_full_screen();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_always_on_top(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_always_on_top();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_shutdown();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t entity_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t entity_get_count();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t entity_get_index(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void entity_clear();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void entity_remove(int64_t self, int64_t key);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void entity_destroy(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entity_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t group_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t entitygroup_get_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entitygroup_get_first(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entitygroup_find(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entitygroup_new(int64_t components);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t observer_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entityobserver_new(int32_t event_, int64_t components);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_get_ext(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_get_path(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_get_name(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_get_filename(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_get_relative(int64_t path, int64_t target);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_replace_ext(int64_t path, int64_t new_ext);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_replace_filename(int64_t path, int64_t new_file);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_concat(int64_t paths);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void worksheet_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t worksheet_read(int64_t self, int64_t row);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void workbook_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t workbook_get_sheet(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_set_search_paths(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_search_paths();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_set_asset_path(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_asset_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_set_writable_path(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_writable_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_app_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_save(int64_t filename, int64_t content);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_exist(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_mkdir(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_isdir(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_is_absolute_path(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_copy(int64_t src, int64_t dst);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_move_to(int64_t src, int64_t dst);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_remove(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_full_path(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_add_search_path(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_insert_search_path(int32_t index, int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_remove_search_path(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_clear_path_cache();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_dirs(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_files(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_all_files(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_load_async(int64_t filename, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_copy_async(int64_t src_file, int64_t target_file, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_save_async(int64_t filename, int64_t content, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_zip_async(int64_t folder_path, int64_t zip_file, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_unzip_async(int64_t zip_file, int64_t folder_path, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_load_excel(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t scheduler_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void scheduler_set_time_scale(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float scheduler_get_time_scale(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void scheduler_set_fixed_fps(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t scheduler_get_fixed_fps(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t scheduler_update(int64_t self, double delta_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t scheduler_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t camera_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t camera_get_name(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t camera2d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void camera2d_set_rotation(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float camera2d_get_rotation(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void camera2d_set_zoom(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float camera2d_get_zoom(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void camera2d_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t camera2d_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t camera2d_new(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t cameraotho_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cameraotho_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t cameraotho_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t cameraotho_new(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t pass_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pass_set_grab_pass(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t pass_is_grab_pass(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pass_set(int64_t self, int64_t name, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pass_set_vec4(int64_t self, int64_t name, float val_1, float val_2, float val_3, float val_4);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pass_set_color(int64_t self, int64_t name, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t pass_new(int64_t vert_shader, int64_t frag_shader);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t effect_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void effect_add(int64_t self, int64_t pass);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t effect_get(int64_t self, int64_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void effect_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t effect_new(int64_t vert_shader, int64_t frag_shader);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t spriteeffect_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spriteeffect_new(int64_t vert_shader, int64_t frag_shader);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_set_clear_color(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t director_get_clear_color();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_ui();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_ui_3d();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_entry();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_post_node();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_current_camera();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_set_frustum_culling(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t director_is_frustum_culling();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_schedule(int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_schedule_posted(int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_push_camera(int64_t camera);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_pop_camera();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t director_remove_camera(int64_t camera);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_clear_camera();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_cleanup();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t view_get_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_standard_distance();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_aspect_ratio();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_near_plane_distance(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_near_plane_distance();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_far_plane_distance(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_far_plane_distance();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_field_of_view(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_field_of_view();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_scale(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_scale();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_post_effect(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t view_get_post_effect();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_post_effect_null();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_vsync(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t view_is_vsync();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void actiondef_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_prop(float duration, float start, float stop, int32_t prop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_tint(float duration, int32_t start, int32_t stop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_roll(float duration, float start, float stop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_spawn(int64_t defs);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_sequence(int64_t defs);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_delay(float duration);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_show();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_hide();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_event(int64_t event_name, int64_t msg);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_move_to(float duration, int64_t start, int64_t stop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_scale(float duration, float start, float stop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_frame(int64_t clip_str, float duration);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_frame_with_frames(int64_t clip_str, float duration, int64_t frames);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t action_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float action_get_duration(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t action_is_running(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t action_is_paused(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_set_reversed(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t action_is_reversed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_set_speed(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float action_get_speed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_pause(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_resume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_update_to(int64_t self, float elapsed, int32_t reversed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t action_new(int64_t def);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grabber_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_camera(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grabber_get_camera(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grabber_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grabber_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_clear_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grabber_get_clear_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_pos(int64_t self, int32_t x, int32_t y, int64_t pos, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grabber_get_pos(int64_t self, int32_t x, int32_t y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_color(int64_t self, int32_t x, int32_t y, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grabber_get_color(int64_t self, int32_t x, int32_t y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_move_uv(int64_t self, int32_t x, int32_t y, int64_t offset);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_order(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_order(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_angle(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_angle(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_angle_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_angle_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_angle_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_angle_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_scale_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_scale_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_scale_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_scale_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_z(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_z(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_skew_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_skew_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_skew_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_skew_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_visible(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_visible(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_anchor(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_anchor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_width(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_height(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_size(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_size(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_tag(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_tag(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_opacity(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_opacity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_color3(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_color3(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_pass_opacity(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_pass_opacity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_pass_color3(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_pass_color3(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_transform_target(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_transform_target(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_scheduler(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_scheduler(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_children(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_parent(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_running(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_scheduled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_action_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_data(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_touch_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_touch_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_swallow_touches(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_swallow_touches(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_swallow_mouse_wheel(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_swallow_mouse_wheel(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_keyboard_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_keyboard_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_controller_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_controller_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_render_group(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_render_group(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_show_debug(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_show_debug(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_render_order(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_render_order(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_add_child_with_order_tag(int64_t self, int64_t child, int32_t order, int64_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_add_child_with_order(int64_t self, int64_t child, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_add_child(int64_t self, int64_t child);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_add_to_with_order_tag(int64_t self, int64_t parent, int32_t order, int64_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_add_to_with_order(int64_t self, int64_t parent, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_add_to(int64_t self, int64_t parent);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_remove_child(int64_t self, int64_t child, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_remove_child_by_tag(int64_t self, int64_t tag, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_remove_all_children(int64_t self, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_remove_from_parent(int64_t self, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_move_to_parent(int64_t self, int64_t parent);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_cleanup(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_child_by_tag(int64_t self, int64_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_schedule(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_unschedule(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_convert_to_node_space(int64_t self, int64_t world_point);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_convert_to_world_space(int64_t self, int64_t node_point);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_convert_to_window_space(int64_t self, int64_t node_point, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_each_child(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_traverse(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_traverse_all(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_run_action_def(int64_t self, int64_t def, int32_t looped);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_run_action(int64_t self, int64_t action, int32_t looped);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_stop_all_actions(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_perform_def(int64_t self, int64_t action_def, int32_t looped);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_perform(int64_t self, int64_t action, int32_t looped);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_stop_action(int64_t self, int64_t action);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_vertically(int64_t self, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_vertically_with_size(int64_t self, int64_t size, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_horizontally(int64_t self, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_horizontally_with_size(int64_t self, int64_t size, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items(int64_t self, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_with_size(int64_t self, int64_t size, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_move_and_cull_items(int64_t self, int64_t delta);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_attach_ime(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_detach_ime(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_grab(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_grab_with_size(int64_t self, int32_t grid_x, int32_t grid_y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_stop_grab(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_transform_target_null(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_slot(int64_t self, int64_t event_name, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_gslot(int64_t self, int64_t event_name, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_emit(int64_t self, int64_t name, int64_t stack);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_on_update(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_on_render(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t texture2d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t texture2d_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t texture2d_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t texture2d_with_file(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sprite_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sprite_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_alpha_ref(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float sprite_get_alpha_ref(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_texture_rect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_get_texture_rect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_get_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_uwrap(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sprite_get_uwrap(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_vwrap(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sprite_get_vwrap(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_filter(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sprite_get_filter(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_effect_as_default(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_with_texture_rect(int64_t texture, int64_t texture_rect);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_with_texture(int64_t texture);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_with_file(int64_t clip_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grid_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grid_get_grid_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grid_get_grid_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grid_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_texture_rect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_texture_rect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_texture(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_pos(int64_t self, int32_t x, int32_t y, int64_t pos, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_pos(int64_t self, int32_t x, int32_t y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_color(int64_t self, int32_t x, int32_t y, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grid_get_color(int64_t self, int32_t x, int32_t y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_move_uv(int64_t self, int32_t x, int32_t y, int64_t offset);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_new(float width, float height, int32_t grid_x, int32_t grid_y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_with_texture_rect(int64_t texture, int64_t texture_rect, int32_t grid_x, int32_t grid_y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_with_texture(int64_t texture, int32_t grid_x, int32_t grid_y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_with_file(int64_t clip_str, int32_t grid_x, int32_t grid_y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t touch_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void touch_set_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t touch_is_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t touch_is_first(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t touch_get_id(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t touch_get_delta(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t touch_get_location(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t touch_get_world_location(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float ease_func(int32_t easing, float time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_alignment(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_get_alignment(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_alpha_ref(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_alpha_ref(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_text_width(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_text_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_spacing(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_spacing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_line_gap(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_line_gap(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_outline_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_get_outline_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_outline_width(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_outline_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_smooth(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_smooth(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_text(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_text(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_batched(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_is_batched(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_get_character_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_character(int64_t self, int32_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_automatic_width();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_new(int64_t font_name, int32_t font_size, int32_t sdf);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_with_str(int64_t font_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t rendertarget_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t rendertarget_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t rendertarget_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rendertarget_set_camera(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rendertarget_get_camera(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rendertarget_get_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rendertarget_render(int64_t self, int64_t target);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rendertarget_render_clear(int64_t self, int32_t color, float depth, int32_t stencil);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rendertarget_render_clear_with_target(int64_t self, int64_t target, int32_t color, float depth, int32_t stencil);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rendertarget_save_async(int64_t self, int64_t filename, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rendertarget_new(int32_t width, int32_t height);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t clipnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void clipnode_set_stencil(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t clipnode_get_stencil(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void clipnode_set_alpha_threshold(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float clipnode_get_alpha_threshold(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void clipnode_set_inverted(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t clipnode_is_inverted(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t clipnode_new(int64_t stencil);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vertexcolor_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vertexcolor_set_vertex(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vertexcolor_get_vertex(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vertexcolor_set_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t vertexcolor_get_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vertexcolor_new(int64_t vec, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t drawnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t drawnode_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t drawnode_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_dot(int64_t self, int64_t pos, float radius, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_segment(int64_t self, int64_t from, int64_t to, float radius, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_polygon(int64_t self, int64_t verts, int32_t fill_color, float border_width, int32_t border_color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_vertices(int64_t self, int64_t verts);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t drawnode_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t line_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t line_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t line_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_add(int64_t self, int64_t verts, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_set(int64_t self, int64_t verts, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t line_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t line_with_vec_color(int64_t verts, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t particle_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t particlenode_is_active(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void particlenode_start(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void particlenode_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t particlenode_new(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t playable_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_look(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_look(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_speed(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float playable_get_speed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_recovery(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float playable_get_recovery(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_fliped(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t playable_is_fliped(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_current(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_last_completed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_key(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float playable_play(int64_t self, int64_t name, int32_t looping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_slot(int64_t self, int64_t name, int64_t item);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_slot(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_new(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float model_get_duration(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_set_reversed(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_is_reversed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_is_playing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_is_paused(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_has_animation(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_pause(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_resume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_resume_animation(int64_t self, int64_t name, int32_t looping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_reset(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_update_to(int64_t self, float elapsed, int32_t reversed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_get_node_by_name(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_each_node(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_new(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_dummy();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_get_clip_file(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_get_looks(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_get_animations(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t spine_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void spine_set_hit_test_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t spine_is_hit_test_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t spine_set_bone_rotation(int64_t self, int64_t name, float rotation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_contains_point(int64_t self, float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_intersects_segment(int64_t self, float x_1, float y_1, float x_2, float y_2);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_with_files(int64_t skel_file, int64_t atlas_file);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_new(int64_t spine_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_get_looks(int64_t spine_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_get_animations(int64_t spine_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t dragonbone_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dragonbone_set_hit_test_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t dragonbone_is_hit_test_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_contains_point(int64_t self, float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_intersects_segment(int64_t self, float x_1, float y_1, float x_2, float y_2);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_with_files(int64_t bone_file, int64_t atlas_file);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_new(int64_t bone_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_get_looks(int64_t bone_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_get_animations(int64_t bone_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t alignnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void alignnode_css(int64_t self, int64_t style);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t alignnode_new(int32_t is_window_root);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t effeknode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t effeknode_play(int64_t self, int64_t filename, int64_t pos, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void effeknode_stop(int64_t self, int32_t handle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t effeknode_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t tilenode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void tilenode_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t tilenode_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void tilenode_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void tilenode_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void tilenode_set_filter(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t tilenode_get_filter(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_get_layer(int64_t self, int64_t layer_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_new(int64_t tmx_file);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_with_with_layer(int64_t tmx_file, int64_t layer_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_with_with_layers(int64_t tmx_file, int64_t layer_names);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsworld_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsworld_query(int64_t self, int64_t rect, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsworld_raycast(int64_t self, int64_t start, int64_t stop, int32_t closest, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld_set_iterations(int64_t self, int32_t velocity_iter, int32_t position_iter);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld_set_should_contact(int64_t self, int32_t group_a, int32_t group_b, int32_t contact);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsworld_get_should_contact(int64_t self, int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld_set_scale_factor(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float physicsworld_get_scale_factor();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t fixturedef_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_type(int64_t self, int32_t body_type);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef_get_type(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_angle(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float bodydef_get_angle(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_face(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_get_face(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_face_pos(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_get_face_pos(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_linear_damping(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float bodydef_get_linear_damping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_angular_damping(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float bodydef_get_angular_damping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_linear_acceleration(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_get_linear_acceleration(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_fixed_rotation(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef_is_fixed_rotation(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_bullet(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef_is_bullet(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_polygon_with_center(int64_t center, float width, float height, float angle, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_polygon(float width, float height, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_polygon_with_vertices(int64_t vertices, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_with_center(int64_t self, int64_t center, float width, float height, float angle, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon(int64_t self, float width, float height, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_with_vertices(int64_t self, int64_t vertices, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_multi(int64_t vertices, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_multi(int64_t self, int64_t vertices, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_disk_with_center(int64_t center, float radius, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_disk(float radius, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_disk_with_center(int64_t self, int64_t center, float radius, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_disk(int64_t self, float radius, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_chain(int64_t vertices, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_chain(int64_t self, int64_t vertices, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_sensor(int64_t self, int32_t tag, float width, float height);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_sensor_with_center(int64_t self, int32_t tag, int64_t center, float width, float height, float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_sensor_with_vertices(int64_t self, int32_t tag, int64_t vertices);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_disk_sensor_with_center(int64_t self, int32_t tag, int64_t center, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_disk_sensor(int64_t self, int32_t tag, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sensor_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sensor_set_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sensor_is_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sensor_get_tag(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sensor_get_owner(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sensor_is_sensed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sensor_get_sensed_bodies(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sensor_contains(int64_t self, int64_t body);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_world(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_body_def(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_mass(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_is_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_velocity_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_velocity_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_velocity_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_velocity_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_velocity(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_velocity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_angular_rate(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_angular_rate(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_group(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_get_group(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_linear_damping(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_linear_damping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_angular_damping(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_angular_damping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_owner(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_owner(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_receiving_contact(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_is_receiving_contact(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_apply_linear_impulse(int64_t self, int64_t impulse, int64_t pos);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_apply_angular_impulse(int64_t self, float impulse);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_sensor_by_tag(int64_t self, int32_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_remove_sensor_by_tag(int64_t self, int32_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_remove_sensor(int64_t self, int64_t sensor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_attach(int64_t self, int64_t fixture_def);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_attach_sensor(int64_t self, int32_t tag, int64_t fixture_def);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_on_contact_filter(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_new(int64_t def, int64_t world, int64_t pos, float rot);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t jointdef_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void jointdef_set_center(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_get_center(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void jointdef_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void jointdef_set_angle(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float jointdef_get_angle(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_distance(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_friction(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float max_force, float max_torque);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_gear(int32_t collision, int64_t joint_a, int64_t joint_b, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_spring(int32_t collision, int64_t body_a, int64_t body_b, int64_t linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_prismatic(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_pulley(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, int64_t ground_anchor_a, int64_t ground_anchor_b, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_revolute(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_rope(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float max_length);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_weld(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_wheel(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t joint_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_distance(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_friction(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float max_force, float max_torque);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_gear(int32_t collision, int64_t joint_a, int64_t joint_b, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_spring(int32_t collision, int64_t body_a, int64_t body_b, int64_t linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_move_target(int32_t collision, int64_t body, int64_t target_pos, float max_force, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_prismatic(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_pulley(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, int64_t ground_anchor_a, int64_t ground_anchor_b, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_revolute(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_rope(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float max_length);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_weld(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_wheel(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_get_world(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void joint_destroy(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_new(int64_t def, int64_t item_dict);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t movejoint_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void movejoint_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t movejoint_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t motorjoint_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void motorjoint_set_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t motorjoint_is_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void motorjoint_set_force(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float motorjoint_get_force(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void motorjoint_set_speed(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float motorjoint_get_speed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t cache_load(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_load_async(int64_t filename, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_update_item(int64_t filename, int64_t content);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_update_texture(int64_t filename, int64_t texture);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t cache_unload_item_or_type(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_unload();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_remove_unused();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_remove_unused_by_type(int64_t type_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_sound_speed(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audio_get_sound_speed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_global_volume(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audio_get_global_volume();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audio_get_listener();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audio_play(int64_t filename, int32_t looping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_stop(int32_t handle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_play_stream(int64_t filename, int32_t looping, float cross_fade_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_stop_stream(float fade_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_pause_all_current(int32_t pause);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_at(float at_x, float at_y, float at_z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_up(float up_x, float up_y, float up_z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_velocity(float velocity_x, float velocity_y, float velocity_z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiobus_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_volume(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiobus_get_volume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_pan(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiobus_get_pan(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_play_speed(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiobus_get_play_speed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_volume(int64_t self, double time, float to_volume);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_pan(int64_t self, double time, float to_pan);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_play_speed(int64_t self, double time, float to_play_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_filter(int64_t self, int32_t index, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_filter_parameter(int64_t self, int32_t index, int32_t attr_id, float value);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiobus_get_filter_parameter(int64_t self, int32_t index, int32_t attr_id);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_filter_parameter(int64_t self, int32_t index, int32_t attr_id, float to, double time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audiobus_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_volume(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiosource_get_volume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_pan(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiosource_get_pan(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_looping(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_is_looping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_is_playing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_seek(int64_t self, double start_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_schedule_stop(int64_t self, double time_to_stop);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_stop(int64_t self, double fade_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_with_delay(int64_t self, double delay_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_background(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_3d(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_3d_with_delay(int64_t self, double delay_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_protected(int64_t self, int32_t value);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_loop_point(int64_t self, double loop_start_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_velocity(int64_t self, float vx, float vy, float vz);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_min_max_distance(int64_t self, float min, float max);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_attenuation(int64_t self, int32_t model, float factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_doppler_factor(int64_t self, float factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audiosource_new(int64_t filename, int32_t auto_remove);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audiosource_with_bus(int64_t filename, int32_t auto_remove, int64_t bus);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t keyboard__is_key_down(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t keyboard__is_key_up(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t keyboard__is_key_pressed(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void keyboard_update_ime_pos_hint(int64_t win_pos);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t mouse_get_position();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t mouse_is_left_button_pressed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t mouse_is_right_button_pressed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t mouse_is_middle_button_pressed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t mouse_get_wheel();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t controller__is_button_down(int32_t controller_id, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t controller__is_button_up(int32_t controller_id, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t controller__is_button_pressed(int32_t controller_id, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float controller__get_axis(int32_t controller_id, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t svg_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float svgdef_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float svgdef_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void svgdef_render(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t svgdef_new(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dbparams_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dbparams_add(int64_t self, int64_t params_);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dbparams_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dbrecord_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t dbrecord_is_valid(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t dbrecord_read(int64_t self, int64_t record);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dbquery_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dbquery_add_with_params(int64_t self, int64_t sql, int64_t params_);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dbquery_add(int64_t self, int64_t sql);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dbquery_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exist_db(int64_t db_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exist(int64_t table_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exist_schema(int64_t table_name, int64_t schema);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exec(int64_t sql);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_transaction(int64_t query);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_transaction_async(int64_t query, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t db_query(int64_t sql, int32_t with_columns);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t db_query_with_params(int64_t sql, int64_t params_, int32_t with_columns);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_insert(int64_t table_name, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exec_with_records(int64_t sql, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_query_with_params_async(int64_t sql, int64_t params_, int32_t with_columns, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_insert_async(int64_t table_name, int64_t values, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_exec_async(int64_t sql, int64_t values, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t qlearner_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void mlqlearner_update(int64_t self, int64_t state, int32_t action, double reward);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t mlqlearner_get_best_action(int64_t self, int64_t state);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void mlqlearner_visit_matrix(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t mlqlearner_pack(int64_t hints, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t mlqlearner_unpack(int64_t hints, int64_t state);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t mlqlearner_new(double gamma, double alpha, double max_q);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void c45_build_decision_tree_async(int64_t data, int32_t max_depth, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_post_async(int64_t url, int64_t json, float timeout, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_post_with_headers_async(int64_t url, int64_t headers, int64_t json, float timeout, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_post_with_headers_part_async(int64_t url, int64_t headers, int64_t json, float timeout, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_get_async(int64_t url, float timeout, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_download_async(int64_t url, int64_t full_path, float timeout, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_targetallow_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_targetallow_set_terrain_allowed(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_targetallow_is_terrain_allowed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_targetallow_allow(int64_t self, int32_t relation, int32_t allow);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_targetallow_is_allow(int64_t self, int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_targetallow_to_value(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_targetallow_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_targetallow_with_value(int32_t value);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_face_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_face_add_child(int64_t self, int64_t face);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_face_to_node(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_face_new(int64_t face_str, int64_t point, float scale, float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_face_with_func(int32_t func0, int64_t stack0, int64_t point, float scale, float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bulletdef_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_tag(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_tag(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_end_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_end_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_life_time(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_bulletdef_get_life_time(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_damage_radius(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_bulletdef_get_damage_radius(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_high_speed_fix(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bulletdef_is_high_speed_fix(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_gravity(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_gravity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_face(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_face(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_body_def(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_velocity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_as_circle(int64_t self, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_velocity(int64_t self, float angle, float speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bullet_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bullet_set_target_allow(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bullet_get_target_allow(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bullet_is_face_right(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bullet_set_hit_stop(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bullet_is_hit_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bullet_get_emitter(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bullet_get_bullet_def(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bullet_set_face(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bullet_get_face(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bullet_destroy(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bullet_new(int64_t def, int64_t owner);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_visual_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_visual_is_playing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_visual_start(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_visual_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_visual_auto_remove(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_visual_new(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern double platformer_behavior_blackboard_get_delta_time(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_blackboard_get_owner(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_behavior_tree_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_seq(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_sel(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_con(int64_t name, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_act(int64_t action_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_command(int64_t action_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_wait(double duration);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_countdown(double time, int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_timeout(double time, int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_repeat(int32_t times, int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_repeat_forever(int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_retry(int32_t times, int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_retry_until_pass(int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_decision_tree_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_sel(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_seq(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_con(int64_t name, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_act(int64_t action_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_act_dynamic(int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_accept();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_reject();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_behave(int64_t name, int64_t root);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_units_by_relation(int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_detected_units();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_detected_bodies();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_nearest_unit(int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_decision_ai_get_nearest_unit_distance(int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_units_in_attack_range();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_ai_get_bodies_in_attack_range();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_actionupdate_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_wasmactionupdate_new(int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unitaction_set_reaction(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unitaction_get_reaction(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unitaction_set_recovery(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unitaction_get_recovery(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unitaction_get_name(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unitaction_is_doing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unitaction_get_owner(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unitaction_get_elapsed_time(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unitaction_clear();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unitaction_add(int64_t name, int32_t priority, float reaction, float recovery, int32_t queued, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1, int32_t func2, int64_t stack2);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_playable(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_playable(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_detect_distance(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unit_get_detect_distance(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_attack_range(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_attack_range(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_face_right(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_is_face_right(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_receiving_decision_trace(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_is_receiving_decision_trace(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_decision_tree(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_decision_tree(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_is_on_surface(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_ground_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_detect_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_attack_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_unit_def(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_current_action(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unit_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unit_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_entity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_attach_action(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_remove_action(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_remove_all_actions(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_action(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_each_action(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_start(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_is_doing(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_new(int64_t unit_def, int64_t physics_world, int64_t entity, int64_t pos, float rot);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_with_store(int64_t unit_def_name, int64_t physics_world_name, int64_t entity, int64_t pos, float rot);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_platformcamera_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_rotation(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_platformcamera_get_rotation(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_zoom(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_platformcamera_get_zoom(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_boundary(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_boundary(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_follow_ratio(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_follow_ratio(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_follow_offset(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_follow_offset(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_follow_target(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_follow_target(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_follow_target_null(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_new(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_platformworld_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_get_camera(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_move_child(int64_t self, int64_t child, int32_t new_order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_get_layer(int64_t self, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_set_layer_ratio(int64_t self, int32_t order, int64_t ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_get_layer_ratio(int64_t self, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_set_layer_offset(int64_t self, int32_t order, int64_t offset);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_get_layer_offset(int64_t self, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_swap_layer(int64_t self, int32_t order_a, int32_t order_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_remove_layer(int64_t self, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_remove_all_layers(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_first_player();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_last_player();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_hide();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_detect_player();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_terrain();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_detection();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_data_get_store();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_set_should_contact(int32_t group_a, int32_t group_b, int32_t contact);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_should_contact(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_set_relation(int32_t group_a, int32_t group_b, int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_relation_by_group(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_relation(int64_t body_a, int64_t body_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_enemy_group(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_enemy(int64_t body_a, int64_t body_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_friend_group(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_friend(int64_t body_a, int64_t body_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_neutral_group(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_neutral(int64_t body_a, int64_t body_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_set_damage_factor(int32_t damage_type, int32_t defence_type, float bounus);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_data_get_damage_factor(int32_t damage_type, int32_t defence_type);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_player(int64_t body);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_terrain(int64_t body);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_clear();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t buffer_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void buffer_set_text(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t buffer_get_text(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void buffer_resize(int64_t self, int32_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void buffer_zero_memory(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t buffer_get_size(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_default_font(int64_t ttf_font_file, float font_size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_show_stats();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_show_console();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_opts(int64_t name, int32_t windows_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_child_opts(int64_t str_id, int64_t size, int32_t child_flags, int32_t window_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_child_with_id_opts(int32_t id, int64_t size, int32_t child_flags, int32_t window_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_child();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__set_next_window_pos_center_opts(int32_t set_cond);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__set_next_window_size_opts(int64_t size, int32_t set_cond);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__set_next_window_collapsed_opts(int32_t collapsed, int32_t set_cond);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__set_window_pos_opts(int64_t name, int64_t pos, int32_t set_cond);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__set_window_size_opts(int64_t name, int64_t size, int32_t set_cond);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__set_window_collapsed_opts(int64_t name, int32_t collapsed, int32_t set_cond);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__set_color_edit_options(int32_t color_edit_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__input_text_opts(int64_t label, int64_t buffer, int32_t input_text_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__input_text_multiline_opts(int64_t label, int64_t buffer, int64_t size, int32_t input_text_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__tree_node_ex_opts(int64_t label, int32_t tree_node_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__tree_node_ex_with_id_opts(int64_t str_id, int64_t text, int32_t tree_node_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__set_next_item_open_opts(int32_t is_open, int32_t set_cond);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__collapsing_header_opts(int64_t label, int32_t tree_node_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__selectable_opts(int64_t label, int32_t selectable_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_popup_modal_opts(int64_t name, int32_t windows_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_popup_modal_ret_opts(int64_t name, int64_t stack, int32_t windows_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_popup_context_item_opts(int64_t name, int32_t popup_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_popup_context_window_opts(int64_t name, int32_t popup_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_popup_context_void_opts(int64_t name, int32_t popup_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__push_style_color(int32_t name, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__push_style_float(int32_t name, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__push_style_vec2(int32_t name, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_text(int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_text_colored(int32_t color, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_text_disabled(int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_text_wrapped(int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_label_text(int64_t label, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_bullet_text(int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__tree_node(int64_t str_id, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_tooltip(int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_image(int64_t clip_str, int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_image_with_bg(int64_t clip_str, int64_t size, int32_t bg_col, int32_t tint_col);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_image_button_opts(int64_t str_id, int64_t clip_str, int64_t size, int32_t bg_col, int32_t tint_col);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__color_button_opts(int64_t desc_id, int32_t col, int32_t color_edit_flags, int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_columns(int32_t count);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_columns_opts(int32_t count, int32_t border, int64_t str_id);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_table_opts(int64_t str_id, int32_t column, int64_t outer_size, float inner_width, int32_t table_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__table_next_row_opts(float min_row_height, int32_t table_row_flag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__table_setup_column_opts(int64_t label, float init_width_or_weight, int32_t user_id, int32_t table_column_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_style_bool(int64_t name, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_style_float(int64_t name, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_style_vec2(int64_t name, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_style_color(int64_t name, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_ret_opts(int64_t name, int64_t stack, int32_t windows_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__collapsing_header_ret_opts(int64_t label, int64_t stack, int32_t tree_node_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__selectable_ret_opts(int64_t label, int64_t stack, int64_t size, int32_t selectable_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__combo_ret_opts(int64_t label, int64_t stack, int64_t items, int32_t height_in_items);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__drag_float_ret_opts(int64_t label, int64_t stack, float v_speed, float v_min, float v_max, int64_t display_format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__drag_float2_ret_opts(int64_t label, int64_t stack, float v_speed, float v_min, float v_max, int64_t display_format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__drag_int_ret_opts(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max, int64_t display_format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__drag_int2_ret_opts(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max, int64_t display_format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__input_float_ret_opts(int64_t label, int64_t stack, float step, float step_fast, int64_t display_format, int32_t input_text_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__input_float2_ret_opts(int64_t label, int64_t stack, int64_t display_format, int32_t input_text_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__input_int_ret_opts(int64_t label, int64_t stack, int32_t step, int32_t step_fast, int32_t input_text_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__input_int2_ret_opts(int64_t label, int64_t stack, int32_t input_text_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__slider_float_ret_opts(int64_t label, int64_t stack, float v_min, float v_max, int64_t display_format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__slider_float2_ret_opts(int64_t label, int64_t stack, float v_min, float v_max, int64_t display_format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__slider_int_ret_opts(int64_t label, int64_t stack, int32_t v_min, int32_t v_max, int64_t format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__slider_int2_ret_opts(int64_t label, int64_t stack, int32_t v_min, int32_t v_max, int64_t display_format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__drag_float_range2_ret_opts(int64_t label, int64_t stack, float v_speed, float v_min, float v_max, int64_t format, int64_t format_max, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__drag_int_range2_ret_opts(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max, int64_t format, int64_t format_max, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__v_slider_float_ret_opts(int64_t label, int64_t size, int64_t stack, float v_min, float v_max, int64_t format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__v_slider_int_ret_opts(int64_t label, int64_t size, int64_t stack, int32_t v_min, int32_t v_max, int64_t format, int32_t slider_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__color_edit3_ret_opts(int64_t label, int64_t stack, int32_t color_edit_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__color_edit4_ret_opts(int64_t label, int64_t stack, int32_t color_edit_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_scroll_when_dragging_on_void();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__set_next_window_pos_opts(int64_t pos, int32_t set_cond, int64_t pivot);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_next_window_bg_alpha(float alpha);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_show_demo_window();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_content_region_avail();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_window_pos();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_window_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_window_width();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_window_height();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_window_collapsed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_next_window_size_constraints(int64_t size_min, int64_t size_max);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_next_window_content_size(int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_next_window_focus();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_scroll_x();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_scroll_y();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_scroll_max_x();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_scroll_max_y();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_scroll_x(float scroll_x);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_scroll_y(float scroll_y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_scroll_here_y(float center_y_ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_scroll_from_pos_y(float pos_y, float center_y_ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_keyboard_focus_here(int32_t offset);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__pop_style_color(int32_t count);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__pop_style_var(int32_t count);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_next_item_width(float item_width);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__push_item_width(float item_width);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__pop_item_width();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_calc_item_width();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__push_text_wrap_pos(float wrap_pos_x);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__pop_text_wrap_pos();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__push_item_flag(int32_t flag, int32_t enabled);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__pop_item_flag();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_separator();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_same_line(float pos_x, float spacing_w);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_new_line();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_spacing();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_dummy(int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_indent(float indent_w);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_unindent(float indent_w);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__begin_group();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_group();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_cursor_pos();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_cursor_pos_x();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_cursor_pos_y();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_cursor_pos(int64_t local_pos);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_cursor_pos_x(float x);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_cursor_pos_y(float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_cursor_start_pos();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_cursor_screen_pos();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_cursor_screen_pos(int64_t pos);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_align_text_to_frame_padding();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_text_line_height();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_text_line_height_with_spacing();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_next_column();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_get_column_index();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_column_offset(int32_t column_index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_column_offset(int32_t column_index, float offset_x);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_column_width(int32_t column_index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_get_columns_count();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_table();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_table_next_column();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_table_set_column_index(int32_t column_n);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_table_setup_scroll_freeze(int32_t cols, int32_t rows);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_table_headers_row();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_bullet_item();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_text_link(int64_t label);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_window_focus(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_separator_text(int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_table_header(int64_t label);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__push_id(int64_t str_id);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__pop_id();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_get_id(int64_t str_id);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_button(int64_t label, int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_small_button(int64_t label);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_invisible_button(int64_t str_id, int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__checkbox_ret(int64_t label, int64_t stack);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__radio_button_ret(int64_t label, int64_t stack, int32_t v_button);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_plot_lines(int64_t label, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_plot_lines_opts(int64_t label, int64_t values, int32_t values_offset, int64_t overlay_text, float scale_min, float scale_max, int64_t graph_size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_plot_histogram(int64_t label, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_plot_histogram_opts(int64_t label, int64_t values, int32_t values_offset, int64_t overlay_text, float scale_min, float scale_max, int64_t graph_size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_progress_bar(float fraction);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_progress_bar_opts(float fraction, int64_t size_arg, int64_t overlay);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__list_box_ret_opts(int64_t label, int64_t stack, int64_t items, int32_t height_in_items);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__slider_angle_ret(int64_t label, int64_t stack, float v_degrees_min, float v_degrees_max);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__tree_push(int64_t str_id);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__tree_pop();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_value(int64_t prefix, int32_t b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_menu_item(int64_t label, int64_t shortcut, int32_t selected, int32_t enabled);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_open_popup(int64_t str_id);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_popup(int64_t str_id);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_popup();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float imgui_get_tree_node_to_label_spacing();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_list_box(int64_t label, int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_list_box();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__begin_disabled();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_disabled();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_tooltip();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_tooltip();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_main_menu_bar();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_main_menu_bar();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_menu_bar();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_menu_bar();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_menu(int64_t label, int32_t enabled);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_menu();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_close_current_popup();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__push_clip_rect(int64_t clip_rect_min, int64_t clip_rect_max, int32_t intersect_with_current_clip_rect);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__pop_clip_rect();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_item_hovered();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_item_active();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_item_clicked(int32_t mouse_button);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_item_visible();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_any_item_hovered();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_any_item_active();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_item_rect_min();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_item_rect_max();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_item_rect_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_next_item_allow_overlap();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_window_hovered();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_window_focused();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_rect_visible(int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_mouse_down(int32_t button);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_mouse_clicked(int32_t button, int32_t repeat);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_mouse_double_clicked(int32_t button);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_mouse_released(int32_t button);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_mouse_hovering_rect(int64_t r_min, int64_t r_max, int32_t clip);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_is_mouse_dragging(int32_t button, float lock_threshold);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_mouse_pos();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_mouse_pos_on_opening_current_popup();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t imgui_get_mouse_drag_delta(int32_t button, float lock_threshold);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_reset_mouse_drag_delta(int32_t button);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_tab_bar(int64_t str_id);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_tab_bar_opts(int64_t str_id, int32_t flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_tab_bar();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_tab_item(int64_t label);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_tab_item_opts(int64_t label, int32_t flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_tab_item_ret(int64_t label, int64_t stack);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__begin_tab_item_ret_opts(int64_t label, int64_t stack, int32_t flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui__end_tab_item();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui_tab_item_button(int64_t label);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t imgui__tab_item_button_opts(int64_t label, int32_t flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void imgui_set_tab_item_closed(int64_t tab_or_docked_window_label);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vgpaint_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_save();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_restore();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_reset();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg__create_image(int32_t w, int32_t h, int64_t filename, int32_t image_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg_create_font(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float nvg_text_bounds(float x, float y, int64_t text, int64_t bounds);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_text_box_bounds(float x, float y, float break_row_width, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float nvg_text(float x, float y, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_text_box(float x, float y, float break_row_width, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_stroke_color(int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_stroke_paint(int64_t paint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_fill_color(int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_fill_paint(int64_t paint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_miter_limit(float limit);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_stroke_width(float size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__line_cap(int32_t cap);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__line_join(int32_t join);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_global_alpha(float alpha);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_reset_transform();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_apply_transform(int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_translate(float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_rotate(float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_skew_x(float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_skew_y(float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_scale(float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_image_size(int32_t image);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_delete_image(int32_t image);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_linear_gradient(float sx, float sy, float ex, float ey, int32_t icol, int32_t ocol);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_box_gradient(float x, float y, float w, float h, float r, float f, int32_t icol, int32_t ocol);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_radial_gradient(float cx, float cy, float inr, float outr, int32_t icol, int32_t ocol);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_image_pattern(float ox, float oy, float ex, float ey, float angle, int32_t image, float alpha);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_scissor(float x, float y, float w, float h);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_intersect_scissor(float x, float y, float w, float h);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_reset_scissor();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_begin_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_move_to(float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_line_to(float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_bezier_to(float c_1x, float c_1y, float c_2x, float c_2y, float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_quad_to(float cx, float cy, float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_arc_to(float x_1, float y_1, float x_2, float y_2, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_close_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__path_winding(int32_t dir);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__arc(float cx, float cy, float r, float a_0, float a_1, int32_t dir);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_rect(float x, float y, float w, float h);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_rounded_rect(float x, float y, float w, float h, float r);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_rounded_rect_varying(float x, float y, float w, float h, float rad_top_left, float rad_top_right, float rad_bottom_right, float rad_bottom_left);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_ellipse(float cx, float cy, float rx, float ry);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_circle(float cx, float cy, float r);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_fill();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_stroke();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg_find_font(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg_add_fallback_font_id(int32_t base_font, int32_t fallback_font);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg_add_fallback_font(int64_t base_font, int64_t fallback_font);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_font_size(float size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_font_blur(float blur);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_text_letter_spacing(float spacing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_text_line_height(float line_height);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__text_align(int32_t h_align, int32_t v_align);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_font_face_id(int32_t font);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_font_face(int64_t font);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_dora_ssr();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_get_dora_ssr(float scale);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t vgnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vgnode_get_surface(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vgnode_render(int64_t self, int32_t func0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vgnode_new(float width, float height, float scale, int32_t edge_aa);
	}
} // namespace Dora

