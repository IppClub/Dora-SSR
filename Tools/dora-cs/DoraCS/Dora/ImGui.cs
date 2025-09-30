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
	}
} // namespace Dora

namespace Dora
{
	public static partial class ImGui
	{
		public static void SetDefaultFont(string ttf_font_file, float font_size)
		{
			Native.imgui_set_default_font(Bridge.FromString(ttf_font_file), font_size);
		}
		public static void ShowStats()
		{
			Native.imgui_show_stats();
		}
		public static void ShowConsole()
		{
			Native.imgui_show_console();
		}
		public static bool _BeginOpts(string name, int windows_flags)
		{
			return Native.imgui__begin_opts(Bridge.FromString(name), windows_flags) != 0;
		}
		public static void _End()
		{
			Native.imgui__end();
		}
		public static bool _BeginChildOpts(string str_id, Vec2 size, int child_flags, int window_flags)
		{
			return Native.imgui__begin_child_opts(Bridge.FromString(str_id), size.Raw, child_flags, window_flags) != 0;
		}
		public static bool _BeginChildWithIdOpts(int id, Vec2 size, int child_flags, int window_flags)
		{
			return Native.imgui__begin_child_with_id_opts(id, size.Raw, child_flags, window_flags) != 0;
		}
		public static void _EndChild()
		{
			Native.imgui__end_child();
		}
		public static void _SetNextWindowPosCenterOpts(int set_cond)
		{
			Native.imgui__set_next_window_pos_center_opts(set_cond);
		}
		public static void _SetNextWindowSizeOpts(Vec2 size, int set_cond)
		{
			Native.imgui__set_next_window_size_opts(size.Raw, set_cond);
		}
		public static void _SetNextWindowCollapsedOpts(bool collapsed, int set_cond)
		{
			Native.imgui__set_next_window_collapsed_opts(collapsed ? 1 : 0, set_cond);
		}
		public static void _SetWindowPosOpts(string name, Vec2 pos, int set_cond)
		{
			Native.imgui__set_window_pos_opts(Bridge.FromString(name), pos.Raw, set_cond);
		}
		public static void _SetWindowSizeOpts(string name, Vec2 size, int set_cond)
		{
			Native.imgui__set_window_size_opts(Bridge.FromString(name), size.Raw, set_cond);
		}
		public static void _SetWindowCollapsedOpts(string name, bool collapsed, int set_cond)
		{
			Native.imgui__set_window_collapsed_opts(Bridge.FromString(name), collapsed ? 1 : 0, set_cond);
		}
		public static void _SetColorEditOptions(int color_edit_flags)
		{
			Native.imgui__set_color_edit_options(color_edit_flags);
		}
		public static bool _InputTextOpts(string label, Buffer buffer, int input_text_flags)
		{
			return Native.imgui__input_text_opts(Bridge.FromString(label), buffer.Raw, input_text_flags) != 0;
		}
		public static bool _InputTextMultilineOpts(string label, Buffer buffer, Vec2 size, int input_text_flags)
		{
			return Native.imgui__input_text_multiline_opts(Bridge.FromString(label), buffer.Raw, size.Raw, input_text_flags) != 0;
		}
		public static bool _TreeNodeExOpts(string label, int tree_node_flags)
		{
			return Native.imgui__tree_node_ex_opts(Bridge.FromString(label), tree_node_flags) != 0;
		}
		public static bool _TreeNodeExWithIdOpts(string str_id, string text, int tree_node_flags)
		{
			return Native.imgui__tree_node_ex_with_id_opts(Bridge.FromString(str_id), Bridge.FromString(text), tree_node_flags) != 0;
		}
		public static void _SetNextItemOpenOpts(bool is_open, int set_cond)
		{
			Native.imgui__set_next_item_open_opts(is_open ? 1 : 0, set_cond);
		}
		public static bool _CollapsingHeaderOpts(string label, int tree_node_flags)
		{
			return Native.imgui__collapsing_header_opts(Bridge.FromString(label), tree_node_flags) != 0;
		}
		public static bool _SelectableOpts(string label, int selectable_flags)
		{
			return Native.imgui__selectable_opts(Bridge.FromString(label), selectable_flags) != 0;
		}
		public static bool _BeginPopupModalOpts(string name, int windows_flags)
		{
			return Native.imgui__begin_popup_modal_opts(Bridge.FromString(name), windows_flags) != 0;
		}
		public static bool _BeginPopupModalRetOpts(string name, CallStack stack, int windows_flags)
		{
			return Native.imgui__begin_popup_modal_ret_opts(Bridge.FromString(name), stack.Raw, windows_flags) != 0;
		}
		public static bool _BeginPopupContextItemOpts(string name, int popup_flags)
		{
			return Native.imgui__begin_popup_context_item_opts(Bridge.FromString(name), popup_flags) != 0;
		}
		public static bool _BeginPopupContextWindowOpts(string name, int popup_flags)
		{
			return Native.imgui__begin_popup_context_window_opts(Bridge.FromString(name), popup_flags) != 0;
		}
		public static bool _BeginPopupContextVoidOpts(string name, int popup_flags)
		{
			return Native.imgui__begin_popup_context_void_opts(Bridge.FromString(name), popup_flags) != 0;
		}
		public static void _PushStyleColor(int name, Color color)
		{
			Native.imgui__push_style_color(name, (int)color.ToARGB());
		}
		public static void _PushStyleFloat(int name, float val)
		{
			Native.imgui__push_style_float(name, val);
		}
		public static void _PushStyleVec2(int name, Vec2 val)
		{
			Native.imgui__push_style_vec2(name, val.Raw);
		}
		public static void Text(string text)
		{
			Native.imgui_text(Bridge.FromString(text));
		}
		public static void TextColored(Color color, string text)
		{
			Native.imgui_text_colored((int)color.ToARGB(), Bridge.FromString(text));
		}
		public static void TextDisabled(string text)
		{
			Native.imgui_text_disabled(Bridge.FromString(text));
		}
		public static void TextWrapped(string text)
		{
			Native.imgui_text_wrapped(Bridge.FromString(text));
		}
		public static void LabelText(string label, string text)
		{
			Native.imgui_label_text(Bridge.FromString(label), Bridge.FromString(text));
		}
		public static void BulletText(string text)
		{
			Native.imgui_bullet_text(Bridge.FromString(text));
		}
		public static bool _TreeNode(string str_id, string text)
		{
			return Native.imgui__tree_node(Bridge.FromString(str_id), Bridge.FromString(text)) != 0;
		}
		public static void SetTooltip(string text)
		{
			Native.imgui_set_tooltip(Bridge.FromString(text));
		}
		public static void Image(string clip_str, Vec2 size)
		{
			Native.imgui_image(Bridge.FromString(clip_str), size.Raw);
		}
		public static void ImageWithBg(string clip_str, Vec2 size, Color bg_col, Color tint_col)
		{
			Native.imgui_image_with_bg(Bridge.FromString(clip_str), size.Raw, (int)bg_col.ToARGB(), (int)tint_col.ToARGB());
		}
		public static bool ImageButtonOpts(string str_id, string clip_str, Vec2 size, Color bg_col, Color tint_col)
		{
			return Native.imgui_image_button_opts(Bridge.FromString(str_id), Bridge.FromString(clip_str), size.Raw, (int)bg_col.ToARGB(), (int)tint_col.ToARGB()) != 0;
		}
		public static bool _ColorButtonOpts(string desc_id, Color col, int color_edit_flags, Vec2 size)
		{
			return Native.imgui__color_button_opts(Bridge.FromString(desc_id), (int)col.ToARGB(), color_edit_flags, size.Raw) != 0;
		}
		public static void Columns(int count)
		{
			Native.imgui_columns(count);
		}
		public static void ColumnsOpts(int count, bool border, string str_id)
		{
			Native.imgui_columns_opts(count, border ? 1 : 0, Bridge.FromString(str_id));
		}
		public static bool _BeginTableOpts(string str_id, int column, Vec2 outer_size, float inner_width, int table_flags)
		{
			return Native.imgui__begin_table_opts(Bridge.FromString(str_id), column, outer_size.Raw, inner_width, table_flags) != 0;
		}
		public static void _TableNextRowOpts(float min_row_height, int table_row_flag)
		{
			Native.imgui__table_next_row_opts(min_row_height, table_row_flag);
		}
		public static void _TableSetupColumnOpts(string label, float init_width_or_weight, int user_id, int table_column_flags)
		{
			Native.imgui__table_setup_column_opts(Bridge.FromString(label), init_width_or_weight, user_id, table_column_flags);
		}
		public static void SetStyleBool(string name, bool val)
		{
			Native.imgui_set_style_bool(Bridge.FromString(name), val ? 1 : 0);
		}
		public static void SetStyleFloat(string name, float val)
		{
			Native.imgui_set_style_float(Bridge.FromString(name), val);
		}
		public static void SetStyleVec2(string name, Vec2 val)
		{
			Native.imgui_set_style_vec2(Bridge.FromString(name), val.Raw);
		}
		public static void SetStyleColor(string name, Color color)
		{
			Native.imgui_set_style_color(Bridge.FromString(name), (int)color.ToARGB());
		}
		public static bool _BeginRetOpts(string name, CallStack stack, int windows_flags)
		{
			return Native.imgui__begin_ret_opts(Bridge.FromString(name), stack.Raw, windows_flags) != 0;
		}
		public static bool _CollapsingHeaderRetOpts(string label, CallStack stack, int tree_node_flags)
		{
			return Native.imgui__collapsing_header_ret_opts(Bridge.FromString(label), stack.Raw, tree_node_flags) != 0;
		}
		public static bool _SelectableRetOpts(string label, CallStack stack, Vec2 size, int selectable_flags)
		{
			return Native.imgui__selectable_ret_opts(Bridge.FromString(label), stack.Raw, size.Raw, selectable_flags) != 0;
		}
		public static bool _ComboRetOpts(string label, CallStack stack, IEnumerable<string> items, int height_in_items)
		{
			return Native.imgui__combo_ret_opts(Bridge.FromString(label), stack.Raw, Bridge.FromArray(items), height_in_items) != 0;
		}
		public static bool _DragFloatRetOpts(string label, CallStack stack, float v_speed, float v_min, float v_max, string display_format, int slider_flags)
		{
			return Native.imgui__drag_float_ret_opts(Bridge.FromString(label), stack.Raw, v_speed, v_min, v_max, Bridge.FromString(display_format), slider_flags) != 0;
		}
		public static bool _DragFloat2RetOpts(string label, CallStack stack, float v_speed, float v_min, float v_max, string display_format, int slider_flags)
		{
			return Native.imgui__drag_float2_ret_opts(Bridge.FromString(label), stack.Raw, v_speed, v_min, v_max, Bridge.FromString(display_format), slider_flags) != 0;
		}
		public static bool _DragIntRetOpts(string label, CallStack stack, float v_speed, int v_min, int v_max, string display_format, int slider_flags)
		{
			return Native.imgui__drag_int_ret_opts(Bridge.FromString(label), stack.Raw, v_speed, v_min, v_max, Bridge.FromString(display_format), slider_flags) != 0;
		}
		public static bool _DragInt2RetOpts(string label, CallStack stack, float v_speed, int v_min, int v_max, string display_format, int slider_flags)
		{
			return Native.imgui__drag_int2_ret_opts(Bridge.FromString(label), stack.Raw, v_speed, v_min, v_max, Bridge.FromString(display_format), slider_flags) != 0;
		}
		public static bool _InputFloatRetOpts(string label, CallStack stack, float step, float step_fast, string display_format, int input_text_flags)
		{
			return Native.imgui__input_float_ret_opts(Bridge.FromString(label), stack.Raw, step, step_fast, Bridge.FromString(display_format), input_text_flags) != 0;
		}
		public static bool _InputFloat2RetOpts(string label, CallStack stack, string display_format, int input_text_flags)
		{
			return Native.imgui__input_float2_ret_opts(Bridge.FromString(label), stack.Raw, Bridge.FromString(display_format), input_text_flags) != 0;
		}
		public static bool _InputIntRetOpts(string label, CallStack stack, int step, int step_fast, int input_text_flags)
		{
			return Native.imgui__input_int_ret_opts(Bridge.FromString(label), stack.Raw, step, step_fast, input_text_flags) != 0;
		}
		public static bool _InputInt2RetOpts(string label, CallStack stack, int input_text_flags)
		{
			return Native.imgui__input_int2_ret_opts(Bridge.FromString(label), stack.Raw, input_text_flags) != 0;
		}
		public static bool _SliderFloatRetOpts(string label, CallStack stack, float v_min, float v_max, string display_format, int slider_flags)
		{
			return Native.imgui__slider_float_ret_opts(Bridge.FromString(label), stack.Raw, v_min, v_max, Bridge.FromString(display_format), slider_flags) != 0;
		}
		public static bool _SliderFloat2RetOpts(string label, CallStack stack, float v_min, float v_max, string display_format, int slider_flags)
		{
			return Native.imgui__slider_float2_ret_opts(Bridge.FromString(label), stack.Raw, v_min, v_max, Bridge.FromString(display_format), slider_flags) != 0;
		}
		public static bool _SliderIntRetOpts(string label, CallStack stack, int v_min, int v_max, string format, int slider_flags)
		{
			return Native.imgui__slider_int_ret_opts(Bridge.FromString(label), stack.Raw, v_min, v_max, Bridge.FromString(format), slider_flags) != 0;
		}
		public static bool _SliderInt2RetOpts(string label, CallStack stack, int v_min, int v_max, string display_format, int slider_flags)
		{
			return Native.imgui__slider_int2_ret_opts(Bridge.FromString(label), stack.Raw, v_min, v_max, Bridge.FromString(display_format), slider_flags) != 0;
		}
		public static bool _DragFloatRange2RetOpts(string label, CallStack stack, float v_speed, float v_min, float v_max, string format, string format_max, int slider_flags)
		{
			return Native.imgui__drag_float_range2_ret_opts(Bridge.FromString(label), stack.Raw, v_speed, v_min, v_max, Bridge.FromString(format), Bridge.FromString(format_max), slider_flags) != 0;
		}
		public static bool _DragIntRange2RetOpts(string label, CallStack stack, float v_speed, int v_min, int v_max, string format, string format_max, int slider_flags)
		{
			return Native.imgui__drag_int_range2_ret_opts(Bridge.FromString(label), stack.Raw, v_speed, v_min, v_max, Bridge.FromString(format), Bridge.FromString(format_max), slider_flags) != 0;
		}
		public static bool _VSliderFloatRetOpts(string label, Vec2 size, CallStack stack, float v_min, float v_max, string format, int slider_flags)
		{
			return Native.imgui__v_slider_float_ret_opts(Bridge.FromString(label), size.Raw, stack.Raw, v_min, v_max, Bridge.FromString(format), slider_flags) != 0;
		}
		public static bool _VSliderIntRetOpts(string label, Vec2 size, CallStack stack, int v_min, int v_max, string format, int slider_flags)
		{
			return Native.imgui__v_slider_int_ret_opts(Bridge.FromString(label), size.Raw, stack.Raw, v_min, v_max, Bridge.FromString(format), slider_flags) != 0;
		}
		public static bool _ColorEdit3RetOpts(string label, CallStack stack, int color_edit_flags)
		{
			return Native.imgui__color_edit3_ret_opts(Bridge.FromString(label), stack.Raw, color_edit_flags) != 0;
		}
		public static bool _ColorEdit4RetOpts(string label, CallStack stack, int color_edit_flags)
		{
			return Native.imgui__color_edit4_ret_opts(Bridge.FromString(label), stack.Raw, color_edit_flags) != 0;
		}
		public static void ScrollWhenDraggingOnVoid()
		{
			Native.imgui_scroll_when_dragging_on_void();
		}
		public static void _SetNextWindowPosOpts(Vec2 pos, int set_cond, Vec2 pivot)
		{
			Native.imgui__set_next_window_pos_opts(pos.Raw, set_cond, pivot.Raw);
		}
		public static void SetNextWindowBgAlpha(float alpha)
		{
			Native.imgui_set_next_window_bg_alpha(alpha);
		}
		public static void ShowDemoWindow()
		{
			Native.imgui_show_demo_window();
		}
		public static Vec2 GetContentRegionAvail()
		{
			return Vec2.From(Native.imgui_get_content_region_avail());
		}
		public static Vec2 GetWindowPos()
		{
			return Vec2.From(Native.imgui_get_window_pos());
		}
		public static Vec2 GetWindowSize()
		{
			return Vec2.From(Native.imgui_get_window_size());
		}
		public static float GetWindowWidth()
		{
			return Native.imgui_get_window_width();
		}
		public static float GetWindowHeight()
		{
			return Native.imgui_get_window_height();
		}
		public static bool IsWindowCollapsed()
		{
			return Native.imgui_is_window_collapsed() != 0;
		}
		public static void SetNextWindowSizeConstraints(Vec2 size_min, Vec2 size_max)
		{
			Native.imgui_set_next_window_size_constraints(size_min.Raw, size_max.Raw);
		}
		public static void SetNextWindowContentSize(Vec2 size)
		{
			Native.imgui_set_next_window_content_size(size.Raw);
		}
		public static void SetNextWindowFocus()
		{
			Native.imgui_set_next_window_focus();
		}
		public static float GetScrollX()
		{
			return Native.imgui_get_scroll_x();
		}
		public static float GetScrollY()
		{
			return Native.imgui_get_scroll_y();
		}
		public static float GetScrollMaxX()
		{
			return Native.imgui_get_scroll_max_x();
		}
		public static float GetScrollMaxY()
		{
			return Native.imgui_get_scroll_max_y();
		}
		public static void SetScrollX(float scroll_x)
		{
			Native.imgui_set_scroll_x(scroll_x);
		}
		public static void SetScrollY(float scroll_y)
		{
			Native.imgui_set_scroll_y(scroll_y);
		}
		public static void SetScrollHereY(float center_y_ratio)
		{
			Native.imgui_set_scroll_here_y(center_y_ratio);
		}
		public static void SetScrollFromPosY(float pos_y, float center_y_ratio)
		{
			Native.imgui_set_scroll_from_pos_y(pos_y, center_y_ratio);
		}
		public static void SetKeyboardFocusHere(int offset)
		{
			Native.imgui_set_keyboard_focus_here(offset);
		}
		public static void _PopStyleColor(int count)
		{
			Native.imgui__pop_style_color(count);
		}
		public static void _PopStyleVar(int count)
		{
			Native.imgui__pop_style_var(count);
		}
		public static void SetNextItemWidth(float item_width)
		{
			Native.imgui_set_next_item_width(item_width);
		}
		public static void _PushItemWidth(float item_width)
		{
			Native.imgui__push_item_width(item_width);
		}
		public static void _PopItemWidth()
		{
			Native.imgui__pop_item_width();
		}
		public static float CalcItemWidth()
		{
			return Native.imgui_calc_item_width();
		}
		public static void _PushTextWrapPos(float wrap_pos_x)
		{
			Native.imgui__push_text_wrap_pos(wrap_pos_x);
		}
		public static void _PopTextWrapPos()
		{
			Native.imgui__pop_text_wrap_pos();
		}
		public static void _PushItemFlag(int flag, bool enabled)
		{
			Native.imgui__push_item_flag(flag, enabled ? 1 : 0);
		}
		public static void _PopItemFlag()
		{
			Native.imgui__pop_item_flag();
		}
		public static void Separator()
		{
			Native.imgui_separator();
		}
		public static void SameLine(float pos_x, float spacing_w)
		{
			Native.imgui_same_line(pos_x, spacing_w);
		}
		public static void NewLine()
		{
			Native.imgui_new_line();
		}
		public static void Spacing()
		{
			Native.imgui_spacing();
		}
		public static void Dummy(Vec2 size)
		{
			Native.imgui_dummy(size.Raw);
		}
		public static void Indent(float indent_w)
		{
			Native.imgui_indent(indent_w);
		}
		public static void Unindent(float indent_w)
		{
			Native.imgui_unindent(indent_w);
		}
		public static void _BeginGroup()
		{
			Native.imgui__begin_group();
		}
		public static void _EndGroup()
		{
			Native.imgui__end_group();
		}
		public static Vec2 GetCursorPos()
		{
			return Vec2.From(Native.imgui_get_cursor_pos());
		}
		public static float GetCursorPosX()
		{
			return Native.imgui_get_cursor_pos_x();
		}
		public static float GetCursorPosY()
		{
			return Native.imgui_get_cursor_pos_y();
		}
		public static void SetCursorPos(Vec2 local_pos)
		{
			Native.imgui_set_cursor_pos(local_pos.Raw);
		}
		public static void SetCursorPosX(float x)
		{
			Native.imgui_set_cursor_pos_x(x);
		}
		public static void SetCursorPosY(float y)
		{
			Native.imgui_set_cursor_pos_y(y);
		}
		public static Vec2 GetCursorStartPos()
		{
			return Vec2.From(Native.imgui_get_cursor_start_pos());
		}
		public static Vec2 GetCursorScreenPos()
		{
			return Vec2.From(Native.imgui_get_cursor_screen_pos());
		}
		public static void SetCursorScreenPos(Vec2 pos)
		{
			Native.imgui_set_cursor_screen_pos(pos.Raw);
		}
		public static void AlignTextToFramePadding()
		{
			Native.imgui_align_text_to_frame_padding();
		}
		public static float GetTextLineHeight()
		{
			return Native.imgui_get_text_line_height();
		}
		public static float GetTextLineHeightWithSpacing()
		{
			return Native.imgui_get_text_line_height_with_spacing();
		}
		public static void NextColumn()
		{
			Native.imgui_next_column();
		}
		public static int GetColumnIndex()
		{
			return Native.imgui_get_column_index();
		}
		public static float GetColumnOffset(int column_index)
		{
			return Native.imgui_get_column_offset(column_index);
		}
		public static void SetColumnOffset(int column_index, float offset_x)
		{
			Native.imgui_set_column_offset(column_index, offset_x);
		}
		public static float GetColumnWidth(int column_index)
		{
			return Native.imgui_get_column_width(column_index);
		}
		public static int GetColumnsCount()
		{
			return Native.imgui_get_columns_count();
		}
		public static void _EndTable()
		{
			Native.imgui__end_table();
		}
		public static bool TableNextColumn()
		{
			return Native.imgui_table_next_column() != 0;
		}
		public static bool TableSetColumnIndex(int column_n)
		{
			return Native.imgui_table_set_column_index(column_n) != 0;
		}
		public static void TableSetupScrollFreeze(int cols, int rows)
		{
			Native.imgui_table_setup_scroll_freeze(cols, rows);
		}
		public static void TableHeadersRow()
		{
			Native.imgui_table_headers_row();
		}
		public static void BulletItem()
		{
			Native.imgui_bullet_item();
		}
		public static bool TextLink(string label)
		{
			return Native.imgui_text_link(Bridge.FromString(label)) != 0;
		}
		public static void SetWindowFocus(string name)
		{
			Native.imgui_set_window_focus(Bridge.FromString(name));
		}
		public static void SeparatorText(string text)
		{
			Native.imgui_separator_text(Bridge.FromString(text));
		}
		public static void TableHeader(string label)
		{
			Native.imgui_table_header(Bridge.FromString(label));
		}
		public static void _PushId(string str_id)
		{
			Native.imgui__push_id(Bridge.FromString(str_id));
		}
		public static void _PopId()
		{
			Native.imgui__pop_id();
		}
		public static int GetId(string str_id)
		{
			return Native.imgui_get_id(Bridge.FromString(str_id));
		}
		public static bool Button(string label, Vec2 size)
		{
			return Native.imgui_button(Bridge.FromString(label), size.Raw) != 0;
		}
		public static bool SmallButton(string label)
		{
			return Native.imgui_small_button(Bridge.FromString(label)) != 0;
		}
		public static bool InvisibleButton(string str_id, Vec2 size)
		{
			return Native.imgui_invisible_button(Bridge.FromString(str_id), size.Raw) != 0;
		}
		public static bool _CheckboxRet(string label, CallStack stack)
		{
			return Native.imgui__checkbox_ret(Bridge.FromString(label), stack.Raw) != 0;
		}
		public static bool _RadioButtonRet(string label, CallStack stack, int v_button)
		{
			return Native.imgui__radio_button_ret(Bridge.FromString(label), stack.Raw, v_button) != 0;
		}
		public static void PlotLines(string label, IEnumerable<float> values)
		{
			Native.imgui_plot_lines(Bridge.FromString(label), Bridge.FromArray(values));
		}
		public static void PlotLinesOpts(string label, IEnumerable<float> values, int values_offset, string overlay_text, float scale_min, float scale_max, Vec2 graph_size)
		{
			Native.imgui_plot_lines_opts(Bridge.FromString(label), Bridge.FromArray(values), values_offset, Bridge.FromString(overlay_text), scale_min, scale_max, graph_size.Raw);
		}
		public static void PlotHistogram(string label, IEnumerable<float> values)
		{
			Native.imgui_plot_histogram(Bridge.FromString(label), Bridge.FromArray(values));
		}
		public static void PlotHistogramOpts(string label, IEnumerable<float> values, int values_offset, string overlay_text, float scale_min, float scale_max, Vec2 graph_size)
		{
			Native.imgui_plot_histogram_opts(Bridge.FromString(label), Bridge.FromArray(values), values_offset, Bridge.FromString(overlay_text), scale_min, scale_max, graph_size.Raw);
		}
		public static void ProgressBar(float fraction)
		{
			Native.imgui_progress_bar(fraction);
		}
		public static void ProgressBarOpts(float fraction, Vec2 size_arg, string overlay)
		{
			Native.imgui_progress_bar_opts(fraction, size_arg.Raw, Bridge.FromString(overlay));
		}
		public static bool _ListBoxRetOpts(string label, CallStack stack, IEnumerable<string> items, int height_in_items)
		{
			return Native.imgui__list_box_ret_opts(Bridge.FromString(label), stack.Raw, Bridge.FromArray(items), height_in_items) != 0;
		}
		public static bool _SliderAngleRet(string label, CallStack stack, float v_degrees_min, float v_degrees_max)
		{
			return Native.imgui__slider_angle_ret(Bridge.FromString(label), stack.Raw, v_degrees_min, v_degrees_max) != 0;
		}
		public static void _TreePush(string str_id)
		{
			Native.imgui__tree_push(Bridge.FromString(str_id));
		}
		public static void _TreePop()
		{
			Native.imgui__tree_pop();
		}
		public static void Value(string prefix, bool b)
		{
			Native.imgui_value(Bridge.FromString(prefix), b ? 1 : 0);
		}
		public static bool MenuItem(string label, string shortcut, bool selected, bool enabled)
		{
			return Native.imgui_menu_item(Bridge.FromString(label), Bridge.FromString(shortcut), selected ? 1 : 0, enabled ? 1 : 0) != 0;
		}
		public static void OpenPopup(string str_id)
		{
			Native.imgui_open_popup(Bridge.FromString(str_id));
		}
		public static bool _BeginPopup(string str_id)
		{
			return Native.imgui__begin_popup(Bridge.FromString(str_id)) != 0;
		}
		public static void _EndPopup()
		{
			Native.imgui__end_popup();
		}
		public static float GetTreeNodeToLabelSpacing()
		{
			return Native.imgui_get_tree_node_to_label_spacing();
		}
		public static bool _BeginListBox(string label, Vec2 size)
		{
			return Native.imgui__begin_list_box(Bridge.FromString(label), size.Raw) != 0;
		}
		public static void _EndListBox()
		{
			Native.imgui__end_list_box();
		}
		public static void _BeginDisabled()
		{
			Native.imgui__begin_disabled();
		}
		public static void _EndDisabled()
		{
			Native.imgui__end_disabled();
		}
		public static bool _BeginTooltip()
		{
			return Native.imgui__begin_tooltip() != 0;
		}
		public static void _EndTooltip()
		{
			Native.imgui__end_tooltip();
		}
		public static bool _BeginMainMenuBar()
		{
			return Native.imgui__begin_main_menu_bar() != 0;
		}
		public static void _EndMainMenuBar()
		{
			Native.imgui__end_main_menu_bar();
		}
		public static bool _BeginMenuBar()
		{
			return Native.imgui__begin_menu_bar() != 0;
		}
		public static void _EndMenuBar()
		{
			Native.imgui__end_menu_bar();
		}
		public static bool _BeginMenu(string label, bool enabled)
		{
			return Native.imgui__begin_menu(Bridge.FromString(label), enabled ? 1 : 0) != 0;
		}
		public static void _EndMenu()
		{
			Native.imgui__end_menu();
		}
		public static void CloseCurrentPopup()
		{
			Native.imgui_close_current_popup();
		}
		public static void _PushClipRect(Vec2 clip_rect_min, Vec2 clip_rect_max, bool intersect_with_current_clip_rect)
		{
			Native.imgui__push_clip_rect(clip_rect_min.Raw, clip_rect_max.Raw, intersect_with_current_clip_rect ? 1 : 0);
		}
		public static void _PopClipRect()
		{
			Native.imgui__pop_clip_rect();
		}
		public static bool IsItemHovered()
		{
			return Native.imgui_is_item_hovered() != 0;
		}
		public static bool IsItemActive()
		{
			return Native.imgui_is_item_active() != 0;
		}
		public static bool IsItemClicked(int mouse_button)
		{
			return Native.imgui_is_item_clicked(mouse_button) != 0;
		}
		public static bool IsItemVisible()
		{
			return Native.imgui_is_item_visible() != 0;
		}
		public static bool IsAnyItemHovered()
		{
			return Native.imgui_is_any_item_hovered() != 0;
		}
		public static bool IsAnyItemActive()
		{
			return Native.imgui_is_any_item_active() != 0;
		}
		public static Vec2 GetItemRectMin()
		{
			return Vec2.From(Native.imgui_get_item_rect_min());
		}
		public static Vec2 GetItemRectMax()
		{
			return Vec2.From(Native.imgui_get_item_rect_max());
		}
		public static Vec2 GetItemRectSize()
		{
			return Vec2.From(Native.imgui_get_item_rect_size());
		}
		public static void SetNextItemAllowOverlap()
		{
			Native.imgui_set_next_item_allow_overlap();
		}
		public static bool IsWindowHovered()
		{
			return Native.imgui_is_window_hovered() != 0;
		}
		public static bool IsWindowFocused()
		{
			return Native.imgui_is_window_focused() != 0;
		}
		public static bool IsRectVisible(Vec2 size)
		{
			return Native.imgui_is_rect_visible(size.Raw) != 0;
		}
		public static bool IsMouseDown(int button)
		{
			return Native.imgui_is_mouse_down(button) != 0;
		}
		public static bool IsMouseClicked(int button, bool repeat)
		{
			return Native.imgui_is_mouse_clicked(button, repeat ? 1 : 0) != 0;
		}
		public static bool IsMouseDoubleClicked(int button)
		{
			return Native.imgui_is_mouse_double_clicked(button) != 0;
		}
		public static bool IsMouseReleased(int button)
		{
			return Native.imgui_is_mouse_released(button) != 0;
		}
		public static bool IsMouseHoveringRect(Vec2 r_min, Vec2 r_max, bool clip)
		{
			return Native.imgui_is_mouse_hovering_rect(r_min.Raw, r_max.Raw, clip ? 1 : 0) != 0;
		}
		public static bool IsMouseDragging(int button, float lock_threshold)
		{
			return Native.imgui_is_mouse_dragging(button, lock_threshold) != 0;
		}
		public static Vec2 GetMousePos()
		{
			return Vec2.From(Native.imgui_get_mouse_pos());
		}
		public static Vec2 GetMousePosOnOpeningCurrentPopup()
		{
			return Vec2.From(Native.imgui_get_mouse_pos_on_opening_current_popup());
		}
		public static Vec2 GetMouseDragDelta(int button, float lock_threshold)
		{
			return Vec2.From(Native.imgui_get_mouse_drag_delta(button, lock_threshold));
		}
		public static void ResetMouseDragDelta(int button)
		{
			Native.imgui_reset_mouse_drag_delta(button);
		}
		public static bool _BeginTabBar(string str_id)
		{
			return Native.imgui__begin_tab_bar(Bridge.FromString(str_id)) != 0;
		}
		public static bool _BeginTabBarOpts(string str_id, int flags)
		{
			return Native.imgui__begin_tab_bar_opts(Bridge.FromString(str_id), flags) != 0;
		}
		public static void _EndTabBar()
		{
			Native.imgui__end_tab_bar();
		}
		public static bool _BeginTabItem(string label)
		{
			return Native.imgui__begin_tab_item(Bridge.FromString(label)) != 0;
		}
		public static bool _BeginTabItemOpts(string label, int flags)
		{
			return Native.imgui__begin_tab_item_opts(Bridge.FromString(label), flags) != 0;
		}
		public static bool _BeginTabItemRet(string label, CallStack stack)
		{
			return Native.imgui__begin_tab_item_ret(Bridge.FromString(label), stack.Raw) != 0;
		}
		public static bool _BeginTabItemRetOpts(string label, CallStack stack, int flags)
		{
			return Native.imgui__begin_tab_item_ret_opts(Bridge.FromString(label), stack.Raw, flags) != 0;
		}
		public static void _EndTabItem()
		{
			Native.imgui__end_tab_item();
		}
		public static bool TabItemButton(string label)
		{
			return Native.imgui_tab_item_button(Bridge.FromString(label)) != 0;
		}
		public static bool _TabItemButtonOpts(string label, int flags)
		{
			return Native.imgui__tab_item_button_opts(Bridge.FromString(label), flags) != 0;
		}
		public static void SetTabItemClosed(string tab_or_docked_window_label)
		{
			Native.imgui_set_tab_item_closed(Bridge.FromString(tab_or_docked_window_label));
		}
	}
} // namespace Dora
