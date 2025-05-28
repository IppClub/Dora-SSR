/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn imgui_load_font_ttf_async(ttf_font_file: i64, font_size: f32, glyph_ranges: i64, func0: i32, stack0: i64);
	fn imgui_is_font_loaded() -> i32;
	fn imgui_show_stats();
	fn imgui_show_console();
	fn imgui__begin_opts(name: i64, windows_flags: i32) -> i32;
	fn imgui__end();
	fn imgui__begin_child_opts(str_id: i64, size: i64, child_flags: i32, window_flags: i32) -> i32;
	fn imgui__begin_child_with_id_opts(id: i32, size: i64, child_flags: i32, window_flags: i32) -> i32;
	fn imgui__end_child();
	fn imgui__set_next_window_pos_center_opts(set_cond: i32);
	fn imgui__set_next_window_size_opts(size: i64, set_cond: i32);
	fn imgui__set_next_window_collapsed_opts(collapsed: i32, set_cond: i32);
	fn imgui__set_window_pos_opts(name: i64, pos: i64, set_cond: i32);
	fn imgui__set_window_size_opts(name: i64, size: i64, set_cond: i32);
	fn imgui__set_window_collapsed_opts(name: i64, collapsed: i32, set_cond: i32);
	fn imgui__set_color_edit_options(color_edit_flags: i32);
	fn imgui__input_text_opts(label: i64, buffer: i64, input_text_flags: i32) -> i32;
	fn imgui__input_text_multiline_opts(label: i64, buffer: i64, size: i64, input_text_flags: i32) -> i32;
	fn imgui__tree_node_ex_opts(label: i64, tree_node_flags: i32) -> i32;
	fn imgui__tree_node_ex_with_id_opts(str_id: i64, text: i64, tree_node_flags: i32) -> i32;
	fn imgui__set_next_item_open_opts(is_open: i32, set_cond: i32);
	fn imgui__collapsing_header_opts(label: i64, tree_node_flags: i32) -> i32;
	fn imgui__selectable_opts(label: i64, selectable_flags: i32) -> i32;
	fn imgui__begin_popup_modal_opts(name: i64, windows_flags: i32) -> i32;
	fn imgui__begin_popup_modal_ret_opts(name: i64, stack: i64, windows_flags: i32) -> i32;
	fn imgui__begin_popup_context_item_opts(name: i64, popup_flags: i32) -> i32;
	fn imgui__begin_popup_context_window_opts(name: i64, popup_flags: i32) -> i32;
	fn imgui__begin_popup_context_void_opts(name: i64, popup_flags: i32) -> i32;
	fn imgui__push_style_color(name: i32, color: i32);
	fn imgui__push_style_float(name: i32, val: f32);
	fn imgui__push_style_vec2(name: i32, val: i64);
	fn imgui_text(text: i64);
	fn imgui_text_colored(color: i32, text: i64);
	fn imgui_text_disabled(text: i64);
	fn imgui_text_wrapped(text: i64);
	fn imgui_label_text(label: i64, text: i64);
	fn imgui_bullet_text(text: i64);
	fn imgui__tree_node(str_id: i64, text: i64) -> i32;
	fn imgui_set_tooltip(text: i64);
	fn imgui_image(clip_str: i64, size: i64);
	fn imgui_image_with_bg(clip_str: i64, size: i64, tint_col: i32, border_col: i32);
	fn imgui_image_button_opts(str_id: i64, clip_str: i64, size: i64, bg_col: i32, tint_col: i32) -> i32;
	fn imgui__color_button_opts(desc_id: i64, col: i32, color_edit_flags: i32, size: i64) -> i32;
	fn imgui_columns(count: i32);
	fn imgui_columns_opts(count: i32, border: i32, str_id: i64);
	fn imgui__begin_table_opts(str_id: i64, column: i32, outer_size: i64, inner_width: f32, table_flags: i32) -> i32;
	fn imgui__table_next_row_opts(min_row_height: f32, table_row_flag: i32);
	fn imgui__table_setup_column_opts(label: i64, init_width_or_weight: f32, user_id: i32, table_column_flags: i32);
	fn imgui_set_style_bool(name: i64, val: i32);
	fn imgui_set_style_float(name: i64, val: f32);
	fn imgui_set_style_vec2(name: i64, val: i64);
	fn imgui_set_style_color(name: i64, color: i32);
	fn imgui__begin_ret_opts(name: i64, stack: i64, windows_flags: i32) -> i32;
	fn imgui__collapsing_header_ret_opts(label: i64, stack: i64, tree_node_flags: i32) -> i32;
	fn imgui__selectable_ret_opts(label: i64, stack: i64, size: i64, selectable_flags: i32) -> i32;
	fn imgui__combo_ret_opts(label: i64, stack: i64, items: i64, height_in_items: i32) -> i32;
	fn imgui__drag_float_ret_opts(label: i64, stack: i64, v_speed: f32, v_min: f32, v_max: f32, display_format: i64, slider_flags: i32) -> i32;
	fn imgui__drag_float2_ret_opts(label: i64, stack: i64, v_speed: f32, v_min: f32, v_max: f32, display_format: i64, slider_flags: i32) -> i32;
	fn imgui__drag_int_ret_opts(label: i64, stack: i64, v_speed: f32, v_min: i32, v_max: i32, display_format: i64, slider_flags: i32) -> i32;
	fn imgui__drag_int2_ret_opts(label: i64, stack: i64, v_speed: f32, v_min: i32, v_max: i32, display_format: i64, slider_flags: i32) -> i32;
	fn imgui__input_float_ret_opts(label: i64, stack: i64, step: f32, step_fast: f32, display_format: i64, input_text_flags: i32) -> i32;
	fn imgui__input_float2_ret_opts(label: i64, stack: i64, display_format: i64, input_text_flags: i32) -> i32;
	fn imgui__input_int_ret_opts(label: i64, stack: i64, step: i32, step_fast: i32, input_text_flags: i32) -> i32;
	fn imgui__input_int2_ret_opts(label: i64, stack: i64, input_text_flags: i32) -> i32;
	fn imgui__slider_float_ret_opts(label: i64, stack: i64, v_min: f32, v_max: f32, display_format: i64, slider_flags: i32) -> i32;
	fn imgui__slider_float2_ret_opts(label: i64, stack: i64, v_min: f32, v_max: f32, display_format: i64, slider_flags: i32) -> i32;
	fn imgui__slider_int_ret_opts(label: i64, stack: i64, v_min: i32, v_max: i32, format: i64, slider_flags: i32) -> i32;
	fn imgui__slider_int2_ret_opts(label: i64, stack: i64, v_min: i32, v_max: i32, display_format: i64, slider_flags: i32) -> i32;
	fn imgui__drag_float_range2_ret_opts(label: i64, stack: i64, v_speed: f32, v_min: f32, v_max: f32, format: i64, format_max: i64, slider_flags: i32) -> i32;
	fn imgui__drag_int_range2_ret_opts(label: i64, stack: i64, v_speed: f32, v_min: i32, v_max: i32, format: i64, format_max: i64, slider_flags: i32) -> i32;
	fn imgui__v_slider_float_ret_opts(label: i64, size: i64, stack: i64, v_min: f32, v_max: f32, format: i64, slider_flags: i32) -> i32;
	fn imgui__v_slider_int_ret_opts(label: i64, size: i64, stack: i64, v_min: i32, v_max: i32, format: i64, slider_flags: i32) -> i32;
	fn imgui__color_edit3_ret_opts(label: i64, stack: i64, color_edit_flags: i32) -> i32;
	fn imgui__color_edit4_ret_opts(label: i64, stack: i64, color_edit_flags: i32) -> i32;
	fn imgui_scroll_when_dragging_on_void();
	fn imgui__set_next_window_pos_opts(pos: i64, set_cond: i32, pivot: i64);
	fn imgui_set_next_window_bg_alpha(alpha: f32);
	fn imgui_show_demo_window();
	fn imgui_get_content_region_avail() -> i64;
	fn imgui_get_window_pos() -> i64;
	fn imgui_get_window_size() -> i64;
	fn imgui_get_window_width() -> f32;
	fn imgui_get_window_height() -> f32;
	fn imgui_is_window_collapsed() -> i32;
	fn imgui_set_window_font_scale(scale: f32);
	fn imgui_set_next_window_size_constraints(size_min: i64, size_max: i64);
	fn imgui_set_next_window_content_size(size: i64);
	fn imgui_set_next_window_focus();
	fn imgui_get_scroll_x() -> f32;
	fn imgui_get_scroll_y() -> f32;
	fn imgui_get_scroll_max_x() -> f32;
	fn imgui_get_scroll_max_y() -> f32;
	fn imgui_set_scroll_x(scroll_x: f32);
	fn imgui_set_scroll_y(scroll_y: f32);
	fn imgui_set_scroll_here_y(center_y_ratio: f32);
	fn imgui_set_scroll_from_pos_y(pos_y: f32, center_y_ratio: f32);
	fn imgui_set_keyboard_focus_here(offset: i32);
	fn imgui__pop_style_color(count: i32);
	fn imgui__pop_style_var(count: i32);
	fn imgui_set_next_item_width(item_width: f32);
	fn imgui__push_item_width(item_width: f32);
	fn imgui__pop_item_width();
	fn imgui_calc_item_width() -> f32;
	fn imgui__push_text_wrap_pos(wrap_pos_x: f32);
	fn imgui__pop_text_wrap_pos();
	fn imgui__push_item_flag(flag: i32, enabled: i32);
	fn imgui__pop_item_flag();
	fn imgui_separator();
	fn imgui_same_line(pos_x: f32, spacing_w: f32);
	fn imgui_new_line();
	fn imgui_spacing();
	fn imgui_dummy(size: i64);
	fn imgui_indent(indent_w: f32);
	fn imgui_unindent(indent_w: f32);
	fn imgui__begin_group();
	fn imgui__end_group();
	fn imgui_get_cursor_pos() -> i64;
	fn imgui_get_cursor_pos_x() -> f32;
	fn imgui_get_cursor_pos_y() -> f32;
	fn imgui_set_cursor_pos(local_pos: i64);
	fn imgui_set_cursor_pos_x(x: f32);
	fn imgui_set_cursor_pos_y(y: f32);
	fn imgui_get_cursor_start_pos() -> i64;
	fn imgui_get_cursor_screen_pos() -> i64;
	fn imgui_set_cursor_screen_pos(pos: i64);
	fn imgui_align_text_to_frame_padding();
	fn imgui_get_text_line_height() -> f32;
	fn imgui_get_text_line_height_with_spacing() -> f32;
	fn imgui_next_column();
	fn imgui_get_column_index() -> i32;
	fn imgui_get_column_offset(column_index: i32) -> f32;
	fn imgui_set_column_offset(column_index: i32, offset_x: f32);
	fn imgui_get_column_width(column_index: i32) -> f32;
	fn imgui_get_columns_count() -> i32;
	fn imgui__end_table();
	fn imgui_table_next_column() -> i32;
	fn imgui_table_set_column_index(column_n: i32) -> i32;
	fn imgui_table_setup_scroll_freeze(cols: i32, rows: i32);
	fn imgui_table_headers_row();
	fn imgui_bullet_item();
	fn imgui_text_link(label: i64) -> i32;
	fn imgui_text_link_open_url(label: i64, url: i64) -> i32;
	fn imgui_set_window_focus(name: i64);
	fn imgui_separator_text(text: i64);
	fn imgui_table_header(label: i64);
	fn imgui__push_id(str_id: i64);
	fn imgui__pop_id();
	fn imgui_get_id(str_id: i64) -> i32;
	fn imgui_button(label: i64, size: i64) -> i32;
	fn imgui_small_button(label: i64) -> i32;
	fn imgui_invisible_button(str_id: i64, size: i64) -> i32;
	fn imgui__checkbox_ret(label: i64, stack: i64) -> i32;
	fn imgui__radio_button_ret(label: i64, stack: i64, v_button: i32) -> i32;
	fn imgui_plot_lines(label: i64, values: i64);
	fn imgui_plot_lines_opts(label: i64, values: i64, values_offset: i32, overlay_text: i64, scale_min: f32, scale_max: f32, graph_size: i64);
	fn imgui_plot_histogram(label: i64, values: i64);
	fn imgui_plot_histogram_opts(label: i64, values: i64, values_offset: i32, overlay_text: i64, scale_min: f32, scale_max: f32, graph_size: i64);
	fn imgui_progress_bar(fraction: f32);
	fn imgui_progress_bar_opts(fraction: f32, size_arg: i64, overlay: i64);
	fn imgui__list_box_ret_opts(label: i64, stack: i64, items: i64, height_in_items: i32) -> i32;
	fn imgui__slider_angle_ret(label: i64, stack: i64, v_degrees_min: f32, v_degrees_max: f32) -> i32;
	fn imgui__tree_push(str_id: i64);
	fn imgui__tree_pop();
	fn imgui_value(prefix: i64, b: i32);
	fn imgui_menu_item(label: i64, shortcut: i64, selected: i32, enabled: i32) -> i32;
	fn imgui_open_popup(str_id: i64);
	fn imgui__begin_popup(str_id: i64) -> i32;
	fn imgui__end_popup();
	fn imgui_get_tree_node_to_label_spacing() -> f32;
	fn imgui__begin_list_box(label: i64, size: i64) -> i32;
	fn imgui__end_list_box();
	fn imgui__begin_disabled();
	fn imgui__end_disabled();
	fn imgui__begin_tooltip() -> i32;
	fn imgui__end_tooltip();
	fn imgui__begin_main_menu_bar() -> i32;
	fn imgui__end_main_menu_bar();
	fn imgui__begin_menu_bar() -> i32;
	fn imgui__end_menu_bar();
	fn imgui__begin_menu(label: i64, enabled: i32) -> i32;
	fn imgui__end_menu();
	fn imgui_close_current_popup();
	fn imgui__push_clip_rect(clip_rect_min: i64, clip_rect_max: i64, intersect_with_current_clip_rect: i32);
	fn imgui__pop_clip_rect();
	fn imgui_is_item_hovered() -> i32;
	fn imgui_is_item_active() -> i32;
	fn imgui_is_item_clicked(mouse_button: i32) -> i32;
	fn imgui_is_item_visible() -> i32;
	fn imgui_is_any_item_hovered() -> i32;
	fn imgui_is_any_item_active() -> i32;
	fn imgui_get_item_rect_min() -> i64;
	fn imgui_get_item_rect_max() -> i64;
	fn imgui_get_item_rect_size() -> i64;
	fn imgui_set_next_item_allow_overlap();
	fn imgui_is_window_hovered() -> i32;
	fn imgui_is_window_focused() -> i32;
	fn imgui_is_rect_visible(size: i64) -> i32;
	fn imgui_is_mouse_down(button: i32) -> i32;
	fn imgui_is_mouse_clicked(button: i32, repeat: i32) -> i32;
	fn imgui_is_mouse_double_clicked(button: i32) -> i32;
	fn imgui_is_mouse_released(button: i32) -> i32;
	fn imgui_is_mouse_hovering_rect(r_min: i64, r_max: i64, clip: i32) -> i32;
	fn imgui_is_mouse_dragging(button: i32, lock_threshold: f32) -> i32;
	fn imgui_get_mouse_pos() -> i64;
	fn imgui_get_mouse_pos_on_opening_current_popup() -> i64;
	fn imgui_get_mouse_drag_delta(button: i32, lock_threshold: f32) -> i64;
	fn imgui_reset_mouse_drag_delta(button: i32);
}
use crate::dora::IObject;
pub struct ImGui { }
impl ImGui {
	pub fn load_font_ttf_async(ttf_font_file: &str, font_size: f32, glyph_ranges: &str, mut handler: Box<dyn FnMut(bool)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(stack0.pop_bool().unwrap())
		}));
		unsafe { imgui_load_font_ttf_async(crate::dora::from_string(ttf_font_file), font_size, crate::dora::from_string(glyph_ranges), func_id0, stack_raw0); }
	}
	pub fn is_font_loaded() -> bool {
		unsafe { return imgui_is_font_loaded() != 0; }
	}
	pub fn show_stats() {
		unsafe { imgui_show_stats(); }
	}
	pub fn show_console() {
		unsafe { imgui_show_console(); }
	}
	pub(crate) fn _begin_opts(name: &str, windows_flags: i32) -> bool {
		unsafe { return imgui__begin_opts(crate::dora::from_string(name), windows_flags) != 0; }
	}
	pub(crate) fn _end() {
		unsafe { imgui__end(); }
	}
	pub(crate) fn _begin_child_opts(str_id: &str, size: &crate::dora::Vec2, child_flags: i32, window_flags: i32) -> bool {
		unsafe { return imgui__begin_child_opts(crate::dora::from_string(str_id), size.into_i64(), child_flags, window_flags) != 0; }
	}
	pub(crate) fn _begin_child_with_id_opts(id: i32, size: &crate::dora::Vec2, child_flags: i32, window_flags: i32) -> bool {
		unsafe { return imgui__begin_child_with_id_opts(id, size.into_i64(), child_flags, window_flags) != 0; }
	}
	pub(crate) fn _end_child() {
		unsafe { imgui__end_child(); }
	}
	pub(crate) fn _set_next_window_pos_center_opts(set_cond: i32) {
		unsafe { imgui__set_next_window_pos_center_opts(set_cond); }
	}
	pub(crate) fn _set_next_window_size_opts(size: &crate::dora::Vec2, set_cond: i32) {
		unsafe { imgui__set_next_window_size_opts(size.into_i64(), set_cond); }
	}
	pub(crate) fn _set_next_window_collapsed_opts(collapsed: bool, set_cond: i32) {
		unsafe { imgui__set_next_window_collapsed_opts(if collapsed { 1 } else { 0 }, set_cond); }
	}
	pub(crate) fn _set_window_pos_opts(name: &str, pos: &crate::dora::Vec2, set_cond: i32) {
		unsafe { imgui__set_window_pos_opts(crate::dora::from_string(name), pos.into_i64(), set_cond); }
	}
	pub(crate) fn _set_window_size_opts(name: &str, size: &crate::dora::Vec2, set_cond: i32) {
		unsafe { imgui__set_window_size_opts(crate::dora::from_string(name), size.into_i64(), set_cond); }
	}
	pub(crate) fn _set_window_collapsed_opts(name: &str, collapsed: bool, set_cond: i32) {
		unsafe { imgui__set_window_collapsed_opts(crate::dora::from_string(name), if collapsed { 1 } else { 0 }, set_cond); }
	}
	pub(crate) fn _set_color_edit_options(color_edit_flags: i32) {
		unsafe { imgui__set_color_edit_options(color_edit_flags); }
	}
	pub(crate) fn _input_text_opts(label: &str, buffer: &crate::dora::Buffer, input_text_flags: i32) -> bool {
		unsafe { return imgui__input_text_opts(crate::dora::from_string(label), buffer.raw(), input_text_flags) != 0; }
	}
	pub(crate) fn _input_text_multiline_opts(label: &str, buffer: &crate::dora::Buffer, size: &crate::dora::Vec2, input_text_flags: i32) -> bool {
		unsafe { return imgui__input_text_multiline_opts(crate::dora::from_string(label), buffer.raw(), size.into_i64(), input_text_flags) != 0; }
	}
	pub(crate) fn _tree_node_ex_opts(label: &str, tree_node_flags: i32) -> bool {
		unsafe { return imgui__tree_node_ex_opts(crate::dora::from_string(label), tree_node_flags) != 0; }
	}
	pub(crate) fn _tree_node_ex_with_id_opts(str_id: &str, text: &str, tree_node_flags: i32) -> bool {
		unsafe { return imgui__tree_node_ex_with_id_opts(crate::dora::from_string(str_id), crate::dora::from_string(text), tree_node_flags) != 0; }
	}
	pub(crate) fn _set_next_item_open_opts(is_open: bool, set_cond: i32) {
		unsafe { imgui__set_next_item_open_opts(if is_open { 1 } else { 0 }, set_cond); }
	}
	pub(crate) fn _collapsing_header_opts(label: &str, tree_node_flags: i32) -> bool {
		unsafe { return imgui__collapsing_header_opts(crate::dora::from_string(label), tree_node_flags) != 0; }
	}
	pub(crate) fn _selectable_opts(label: &str, selectable_flags: i32) -> bool {
		unsafe { return imgui__selectable_opts(crate::dora::from_string(label), selectable_flags) != 0; }
	}
	pub(crate) fn _begin_popup_modal_opts(name: &str, windows_flags: i32) -> bool {
		unsafe { return imgui__begin_popup_modal_opts(crate::dora::from_string(name), windows_flags) != 0; }
	}
	pub(crate) fn _begin_popup_modal_ret_opts(name: &str, stack: &crate::dora::CallStack, windows_flags: i32) -> bool {
		unsafe { return imgui__begin_popup_modal_ret_opts(crate::dora::from_string(name), stack.raw(), windows_flags) != 0; }
	}
	pub(crate) fn _begin_popup_context_item_opts(name: &str, popup_flags: i32) -> bool {
		unsafe { return imgui__begin_popup_context_item_opts(crate::dora::from_string(name), popup_flags) != 0; }
	}
	pub(crate) fn _begin_popup_context_window_opts(name: &str, popup_flags: i32) -> bool {
		unsafe { return imgui__begin_popup_context_window_opts(crate::dora::from_string(name), popup_flags) != 0; }
	}
	pub(crate) fn _begin_popup_context_void_opts(name: &str, popup_flags: i32) -> bool {
		unsafe { return imgui__begin_popup_context_void_opts(crate::dora::from_string(name), popup_flags) != 0; }
	}
	pub(crate) fn _push_style_color(name: i32, color: &crate::dora::Color) {
		unsafe { imgui__push_style_color(name, color.to_argb() as i32); }
	}
	pub(crate) fn _push_style_float(name: i32, val: f32) {
		unsafe { imgui__push_style_float(name, val); }
	}
	pub(crate) fn _push_style_vec2(name: i32, val: &crate::dora::Vec2) {
		unsafe { imgui__push_style_vec2(name, val.into_i64()); }
	}
	pub fn text(text: &str) {
		unsafe { imgui_text(crate::dora::from_string(text)); }
	}
	pub fn text_colored(color: &crate::dora::Color, text: &str) {
		unsafe { imgui_text_colored(color.to_argb() as i32, crate::dora::from_string(text)); }
	}
	pub fn text_disabled(text: &str) {
		unsafe { imgui_text_disabled(crate::dora::from_string(text)); }
	}
	pub fn text_wrapped(text: &str) {
		unsafe { imgui_text_wrapped(crate::dora::from_string(text)); }
	}
	pub fn label_text(label: &str, text: &str) {
		unsafe { imgui_label_text(crate::dora::from_string(label), crate::dora::from_string(text)); }
	}
	pub fn bullet_text(text: &str) {
		unsafe { imgui_bullet_text(crate::dora::from_string(text)); }
	}
	pub(crate) fn _tree_node(str_id: &str, text: &str) -> bool {
		unsafe { return imgui__tree_node(crate::dora::from_string(str_id), crate::dora::from_string(text)) != 0; }
	}
	pub fn set_tooltip(text: &str) {
		unsafe { imgui_set_tooltip(crate::dora::from_string(text)); }
	}
	pub fn image(clip_str: &str, size: &crate::dora::Vec2) {
		unsafe { imgui_image(crate::dora::from_string(clip_str), size.into_i64()); }
	}
	pub fn image_with_bg(clip_str: &str, size: &crate::dora::Vec2, tint_col: &crate::dora::Color, border_col: &crate::dora::Color) {
		unsafe { imgui_image_with_bg(crate::dora::from_string(clip_str), size.into_i64(), tint_col.to_argb() as i32, border_col.to_argb() as i32); }
	}
	pub fn image_button_opts(str_id: &str, clip_str: &str, size: &crate::dora::Vec2, bg_col: &crate::dora::Color, tint_col: &crate::dora::Color) -> bool {
		unsafe { return imgui_image_button_opts(crate::dora::from_string(str_id), crate::dora::from_string(clip_str), size.into_i64(), bg_col.to_argb() as i32, tint_col.to_argb() as i32) != 0; }
	}
	pub(crate) fn _color_button_opts(desc_id: &str, col: &crate::dora::Color, color_edit_flags: i32, size: &crate::dora::Vec2) -> bool {
		unsafe { return imgui__color_button_opts(crate::dora::from_string(desc_id), col.to_argb() as i32, color_edit_flags, size.into_i64()) != 0; }
	}
	pub fn columns(count: i32) {
		unsafe { imgui_columns(count); }
	}
	pub fn columns_opts(count: i32, border: bool, str_id: &str) {
		unsafe { imgui_columns_opts(count, if border { 1 } else { 0 }, crate::dora::from_string(str_id)); }
	}
	pub(crate) fn _begin_table_opts(str_id: &str, column: i32, outer_size: &crate::dora::Vec2, inner_width: f32, table_flags: i32) -> bool {
		unsafe { return imgui__begin_table_opts(crate::dora::from_string(str_id), column, outer_size.into_i64(), inner_width, table_flags) != 0; }
	}
	pub(crate) fn _table_next_row_opts(min_row_height: f32, table_row_flag: i32) {
		unsafe { imgui__table_next_row_opts(min_row_height, table_row_flag); }
	}
	pub(crate) fn _table_setup_column_opts(label: &str, init_width_or_weight: f32, user_id: i32, table_column_flags: i32) {
		unsafe { imgui__table_setup_column_opts(crate::dora::from_string(label), init_width_or_weight, user_id, table_column_flags); }
	}
	pub fn set_style_bool(name: &str, val: bool) {
		unsafe { imgui_set_style_bool(crate::dora::from_string(name), if val { 1 } else { 0 }); }
	}
	pub fn set_style_float(name: &str, val: f32) {
		unsafe { imgui_set_style_float(crate::dora::from_string(name), val); }
	}
	pub fn set_style_vec2(name: &str, val: &crate::dora::Vec2) {
		unsafe { imgui_set_style_vec2(crate::dora::from_string(name), val.into_i64()); }
	}
	pub fn set_style_color(name: &str, color: &crate::dora::Color) {
		unsafe { imgui_set_style_color(crate::dora::from_string(name), color.to_argb() as i32); }
	}
	pub(crate) fn _begin_ret_opts(name: &str, stack: &crate::dora::CallStack, windows_flags: i32) -> bool {
		unsafe { return imgui__begin_ret_opts(crate::dora::from_string(name), stack.raw(), windows_flags) != 0; }
	}
	pub(crate) fn _collapsing_header_ret_opts(label: &str, stack: &crate::dora::CallStack, tree_node_flags: i32) -> bool {
		unsafe { return imgui__collapsing_header_ret_opts(crate::dora::from_string(label), stack.raw(), tree_node_flags) != 0; }
	}
	pub(crate) fn _selectable_ret_opts(label: &str, stack: &crate::dora::CallStack, size: &crate::dora::Vec2, selectable_flags: i32) -> bool {
		unsafe { return imgui__selectable_ret_opts(crate::dora::from_string(label), stack.raw(), size.into_i64(), selectable_flags) != 0; }
	}
	pub(crate) fn _combo_ret_opts(label: &str, stack: &crate::dora::CallStack, items: &Vec<&str>, height_in_items: i32) -> bool {
		unsafe { return imgui__combo_ret_opts(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(items), height_in_items) != 0; }
	}
	pub(crate) fn _drag_float_ret_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__drag_float_ret_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), slider_flags) != 0; }
	}
	pub(crate) fn _drag_float2_ret_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__drag_float2_ret_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), slider_flags) != 0; }
	}
	pub(crate) fn _drag_int_ret_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__drag_int_ret_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), slider_flags) != 0; }
	}
	pub(crate) fn _drag_int2_ret_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__drag_int2_ret_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), slider_flags) != 0; }
	}
	pub(crate) fn _input_float_ret_opts(label: &str, stack: &crate::dora::CallStack, step: f32, step_fast: f32, display_format: &str, input_text_flags: i32) -> bool {
		unsafe { return imgui__input_float_ret_opts(crate::dora::from_string(label), stack.raw(), step, step_fast, crate::dora::from_string(display_format), input_text_flags) != 0; }
	}
	pub(crate) fn _input_float2_ret_opts(label: &str, stack: &crate::dora::CallStack, display_format: &str, input_text_flags: i32) -> bool {
		unsafe { return imgui__input_float2_ret_opts(crate::dora::from_string(label), stack.raw(), crate::dora::from_string(display_format), input_text_flags) != 0; }
	}
	pub(crate) fn _input_int_ret_opts(label: &str, stack: &crate::dora::CallStack, step: i32, step_fast: i32, input_text_flags: i32) -> bool {
		unsafe { return imgui__input_int_ret_opts(crate::dora::from_string(label), stack.raw(), step, step_fast, input_text_flags) != 0; }
	}
	pub(crate) fn _input_int2_ret_opts(label: &str, stack: &crate::dora::CallStack, input_text_flags: i32) -> bool {
		unsafe { return imgui__input_int2_ret_opts(crate::dora::from_string(label), stack.raw(), input_text_flags) != 0; }
	}
	pub(crate) fn _slider_float_ret_opts(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32, display_format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__slider_float_ret_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(display_format), slider_flags) != 0; }
	}
	pub(crate) fn _slider_float2_ret_opts(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32, display_format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__slider_float2_ret_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(display_format), slider_flags) != 0; }
	}
	pub(crate) fn _slider_int_ret_opts(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32, format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__slider_int_ret_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(format), slider_flags) != 0; }
	}
	pub(crate) fn _slider_int2_ret_opts(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32, display_format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__slider_int2_ret_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(display_format), slider_flags) != 0; }
	}
	pub(crate) fn _drag_float_range2_ret_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32, format: &str, format_max: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__drag_float_range2_ret_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(format), crate::dora::from_string(format_max), slider_flags) != 0; }
	}
	pub(crate) fn _drag_int_range2_ret_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32, format: &str, format_max: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__drag_int_range2_ret_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(format), crate::dora::from_string(format_max), slider_flags) != 0; }
	}
	pub(crate) fn _v_slider_float_ret_opts(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: f32, v_max: f32, format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__v_slider_float_ret_opts(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max, crate::dora::from_string(format), slider_flags) != 0; }
	}
	pub(crate) fn _v_slider_int_ret_opts(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: i32, v_max: i32, format: &str, slider_flags: i32) -> bool {
		unsafe { return imgui__v_slider_int_ret_opts(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max, crate::dora::from_string(format), slider_flags) != 0; }
	}
	pub(crate) fn _color_edit3_ret_opts(label: &str, stack: &crate::dora::CallStack, color_edit_flags: i32) -> bool {
		unsafe { return imgui__color_edit3_ret_opts(crate::dora::from_string(label), stack.raw(), color_edit_flags) != 0; }
	}
	pub(crate) fn _color_edit4_ret_opts(label: &str, stack: &crate::dora::CallStack, color_edit_flags: i32) -> bool {
		unsafe { return imgui__color_edit4_ret_opts(crate::dora::from_string(label), stack.raw(), color_edit_flags) != 0; }
	}
	pub fn scroll_when_dragging_on_void() {
		unsafe { imgui_scroll_when_dragging_on_void(); }
	}
	pub(crate) fn _set_next_window_pos_opts(pos: &crate::dora::Vec2, set_cond: i32, pivot: &crate::dora::Vec2) {
		unsafe { imgui__set_next_window_pos_opts(pos.into_i64(), set_cond, pivot.into_i64()); }
	}
	pub fn set_next_window_bg_alpha(alpha: f32) {
		unsafe { imgui_set_next_window_bg_alpha(alpha); }
	}
	pub fn show_demo_window() {
		unsafe { imgui_show_demo_window(); }
	}
	pub fn get_content_region_avail() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_content_region_avail()); }
	}
	pub fn get_window_pos() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_window_pos()); }
	}
	pub fn get_window_size() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_window_size()); }
	}
	pub fn get_window_width() -> f32 {
		unsafe { return imgui_get_window_width(); }
	}
	pub fn get_window_height() -> f32 {
		unsafe { return imgui_get_window_height(); }
	}
	pub fn is_window_collapsed() -> bool {
		unsafe { return imgui_is_window_collapsed() != 0; }
	}
	pub fn set_window_font_scale(scale: f32) {
		unsafe { imgui_set_window_font_scale(scale); }
	}
	pub fn set_next_window_size_constraints(size_min: &crate::dora::Vec2, size_max: &crate::dora::Vec2) {
		unsafe { imgui_set_next_window_size_constraints(size_min.into_i64(), size_max.into_i64()); }
	}
	pub fn set_next_window_content_size(size: &crate::dora::Vec2) {
		unsafe { imgui_set_next_window_content_size(size.into_i64()); }
	}
	pub fn set_next_window_focus() {
		unsafe { imgui_set_next_window_focus(); }
	}
	pub fn get_scroll_x() -> f32 {
		unsafe { return imgui_get_scroll_x(); }
	}
	pub fn get_scroll_y() -> f32 {
		unsafe { return imgui_get_scroll_y(); }
	}
	pub fn get_scroll_max_x() -> f32 {
		unsafe { return imgui_get_scroll_max_x(); }
	}
	pub fn get_scroll_max_y() -> f32 {
		unsafe { return imgui_get_scroll_max_y(); }
	}
	pub fn set_scroll_x(scroll_x: f32) {
		unsafe { imgui_set_scroll_x(scroll_x); }
	}
	pub fn set_scroll_y(scroll_y: f32) {
		unsafe { imgui_set_scroll_y(scroll_y); }
	}
	pub fn set_scroll_here_y(center_y_ratio: f32) {
		unsafe { imgui_set_scroll_here_y(center_y_ratio); }
	}
	pub fn set_scroll_from_pos_y(pos_y: f32, center_y_ratio: f32) {
		unsafe { imgui_set_scroll_from_pos_y(pos_y, center_y_ratio); }
	}
	pub fn set_keyboard_focus_here(offset: i32) {
		unsafe { imgui_set_keyboard_focus_here(offset); }
	}
	pub(crate) fn _pop_style_color(count: i32) {
		unsafe { imgui__pop_style_color(count); }
	}
	pub(crate) fn _pop_style_var(count: i32) {
		unsafe { imgui__pop_style_var(count); }
	}
	pub fn set_next_item_width(item_width: f32) {
		unsafe { imgui_set_next_item_width(item_width); }
	}
	pub(crate) fn _push_item_width(item_width: f32) {
		unsafe { imgui__push_item_width(item_width); }
	}
	pub(crate) fn _pop_item_width() {
		unsafe { imgui__pop_item_width(); }
	}
	pub fn calc_item_width() -> f32 {
		unsafe { return imgui_calc_item_width(); }
	}
	pub(crate) fn _push_text_wrap_pos(wrap_pos_x: f32) {
		unsafe { imgui__push_text_wrap_pos(wrap_pos_x); }
	}
	pub(crate) fn _pop_text_wrap_pos() {
		unsafe { imgui__pop_text_wrap_pos(); }
	}
	pub(crate) fn _push_item_flag(flag: i32, enabled: bool) {
		unsafe { imgui__push_item_flag(flag, if enabled { 1 } else { 0 }); }
	}
	pub(crate) fn _pop_item_flag() {
		unsafe { imgui__pop_item_flag(); }
	}
	pub fn separator() {
		unsafe { imgui_separator(); }
	}
	pub fn same_line(pos_x: f32, spacing_w: f32) {
		unsafe { imgui_same_line(pos_x, spacing_w); }
	}
	pub fn new_line() {
		unsafe { imgui_new_line(); }
	}
	pub fn spacing() {
		unsafe { imgui_spacing(); }
	}
	pub fn dummy(size: &crate::dora::Vec2) {
		unsafe { imgui_dummy(size.into_i64()); }
	}
	pub fn indent(indent_w: f32) {
		unsafe { imgui_indent(indent_w); }
	}
	pub fn unindent(indent_w: f32) {
		unsafe { imgui_unindent(indent_w); }
	}
	pub(crate) fn _begin_group() {
		unsafe { imgui__begin_group(); }
	}
	pub(crate) fn _end_group() {
		unsafe { imgui__end_group(); }
	}
	pub fn get_cursor_pos() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_cursor_pos()); }
	}
	pub fn get_cursor_pos_x() -> f32 {
		unsafe { return imgui_get_cursor_pos_x(); }
	}
	pub fn get_cursor_pos_y() -> f32 {
		unsafe { return imgui_get_cursor_pos_y(); }
	}
	pub fn set_cursor_pos(local_pos: &crate::dora::Vec2) {
		unsafe { imgui_set_cursor_pos(local_pos.into_i64()); }
	}
	pub fn set_cursor_pos_x(x: f32) {
		unsafe { imgui_set_cursor_pos_x(x); }
	}
	pub fn set_cursor_pos_y(y: f32) {
		unsafe { imgui_set_cursor_pos_y(y); }
	}
	pub fn get_cursor_start_pos() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_cursor_start_pos()); }
	}
	pub fn get_cursor_screen_pos() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_cursor_screen_pos()); }
	}
	pub fn set_cursor_screen_pos(pos: &crate::dora::Vec2) {
		unsafe { imgui_set_cursor_screen_pos(pos.into_i64()); }
	}
	pub fn align_text_to_frame_padding() {
		unsafe { imgui_align_text_to_frame_padding(); }
	}
	pub fn get_text_line_height() -> f32 {
		unsafe { return imgui_get_text_line_height(); }
	}
	pub fn get_text_line_height_with_spacing() -> f32 {
		unsafe { return imgui_get_text_line_height_with_spacing(); }
	}
	pub fn next_column() {
		unsafe { imgui_next_column(); }
	}
	pub fn get_column_index() -> i32 {
		unsafe { return imgui_get_column_index(); }
	}
	pub fn get_column_offset(column_index: i32) -> f32 {
		unsafe { return imgui_get_column_offset(column_index); }
	}
	pub fn set_column_offset(column_index: i32, offset_x: f32) {
		unsafe { imgui_set_column_offset(column_index, offset_x); }
	}
	pub fn get_column_width(column_index: i32) -> f32 {
		unsafe { return imgui_get_column_width(column_index); }
	}
	pub fn get_columns_count() -> i32 {
		unsafe { return imgui_get_columns_count(); }
	}
	pub(crate) fn _end_table() {
		unsafe { imgui__end_table(); }
	}
	pub fn table_next_column() -> bool {
		unsafe { return imgui_table_next_column() != 0; }
	}
	pub fn table_set_column_index(column_n: i32) -> bool {
		unsafe { return imgui_table_set_column_index(column_n) != 0; }
	}
	pub fn table_setup_scroll_freeze(cols: i32, rows: i32) {
		unsafe { imgui_table_setup_scroll_freeze(cols, rows); }
	}
	pub fn table_headers_row() {
		unsafe { imgui_table_headers_row(); }
	}
	pub fn bullet_item() {
		unsafe { imgui_bullet_item(); }
	}
	pub fn text_link(label: &str) -> bool {
		unsafe { return imgui_text_link(crate::dora::from_string(label)) != 0; }
	}
	pub fn text_link_open_url(label: &str, url: &str) -> bool {
		unsafe { return imgui_text_link_open_url(crate::dora::from_string(label), crate::dora::from_string(url)) != 0; }
	}
	pub fn set_window_focus(name: &str) {
		unsafe { imgui_set_window_focus(crate::dora::from_string(name)); }
	}
	pub fn separator_text(text: &str) {
		unsafe { imgui_separator_text(crate::dora::from_string(text)); }
	}
	pub fn table_header(label: &str) {
		unsafe { imgui_table_header(crate::dora::from_string(label)); }
	}
	pub(crate) fn _push_id(str_id: &str) {
		unsafe { imgui__push_id(crate::dora::from_string(str_id)); }
	}
	pub(crate) fn _pop_id() {
		unsafe { imgui__pop_id(); }
	}
	pub fn get_id(str_id: &str) -> i32 {
		unsafe { return imgui_get_id(crate::dora::from_string(str_id)); }
	}
	pub fn button(label: &str, size: &crate::dora::Vec2) -> bool {
		unsafe { return imgui_button(crate::dora::from_string(label), size.into_i64()) != 0; }
	}
	pub fn small_button(label: &str) -> bool {
		unsafe { return imgui_small_button(crate::dora::from_string(label)) != 0; }
	}
	pub fn invisible_button(str_id: &str, size: &crate::dora::Vec2) -> bool {
		unsafe { return imgui_invisible_button(crate::dora::from_string(str_id), size.into_i64()) != 0; }
	}
	pub(crate) fn _checkbox_ret(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__checkbox_ret(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub(crate) fn _radio_button_ret(label: &str, stack: &crate::dora::CallStack, v_button: i32) -> bool {
		unsafe { return imgui__radio_button_ret(crate::dora::from_string(label), stack.raw(), v_button) != 0; }
	}
	pub fn plot_lines(label: &str, values: &Vec<f32>) {
		unsafe { imgui_plot_lines(crate::dora::from_string(label), crate::dora::Vector::from_num(values)); }
	}
	pub fn plot_lines_opts(label: &str, values: &Vec<f32>, values_offset: i32, overlay_text: &str, scale_min: f32, scale_max: f32, graph_size: &crate::dora::Vec2) {
		unsafe { imgui_plot_lines_opts(crate::dora::from_string(label), crate::dora::Vector::from_num(values), values_offset, crate::dora::from_string(overlay_text), scale_min, scale_max, graph_size.into_i64()); }
	}
	pub fn plot_histogram(label: &str, values: &Vec<f32>) {
		unsafe { imgui_plot_histogram(crate::dora::from_string(label), crate::dora::Vector::from_num(values)); }
	}
	pub fn plot_histogram_opts(label: &str, values: &Vec<f32>, values_offset: i32, overlay_text: &str, scale_min: f32, scale_max: f32, graph_size: &crate::dora::Vec2) {
		unsafe { imgui_plot_histogram_opts(crate::dora::from_string(label), crate::dora::Vector::from_num(values), values_offset, crate::dora::from_string(overlay_text), scale_min, scale_max, graph_size.into_i64()); }
	}
	pub fn progress_bar(fraction: f32) {
		unsafe { imgui_progress_bar(fraction); }
	}
	pub fn progress_bar_opts(fraction: f32, size_arg: &crate::dora::Vec2, overlay: &str) {
		unsafe { imgui_progress_bar_opts(fraction, size_arg.into_i64(), crate::dora::from_string(overlay)); }
	}
	pub(crate) fn _list_box_ret_opts(label: &str, stack: &crate::dora::CallStack, items: &Vec<&str>, height_in_items: i32) -> bool {
		unsafe { return imgui__list_box_ret_opts(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(items), height_in_items) != 0; }
	}
	pub(crate) fn _slider_angle_ret(label: &str, stack: &crate::dora::CallStack, v_degrees_min: f32, v_degrees_max: f32) -> bool {
		unsafe { return imgui__slider_angle_ret(crate::dora::from_string(label), stack.raw(), v_degrees_min, v_degrees_max) != 0; }
	}
	pub(crate) fn _tree_push(str_id: &str) {
		unsafe { imgui__tree_push(crate::dora::from_string(str_id)); }
	}
	pub(crate) fn _tree_pop() {
		unsafe { imgui__tree_pop(); }
	}
	pub fn value(prefix: &str, b: bool) {
		unsafe { imgui_value(crate::dora::from_string(prefix), if b { 1 } else { 0 }); }
	}
	pub fn menu_item(label: &str, shortcut: &str, selected: bool, enabled: bool) -> bool {
		unsafe { return imgui_menu_item(crate::dora::from_string(label), crate::dora::from_string(shortcut), if selected { 1 } else { 0 }, if enabled { 1 } else { 0 }) != 0; }
	}
	pub fn open_popup(str_id: &str) {
		unsafe { imgui_open_popup(crate::dora::from_string(str_id)); }
	}
	pub(crate) fn _begin_popup(str_id: &str) -> bool {
		unsafe { return imgui__begin_popup(crate::dora::from_string(str_id)) != 0; }
	}
	pub(crate) fn _end_popup() {
		unsafe { imgui__end_popup(); }
	}
	pub fn get_tree_node_to_label_spacing() -> f32 {
		unsafe { return imgui_get_tree_node_to_label_spacing(); }
	}
	pub(crate) fn _begin_list_box(label: &str, size: &crate::dora::Vec2) -> bool {
		unsafe { return imgui__begin_list_box(crate::dora::from_string(label), size.into_i64()) != 0; }
	}
	pub(crate) fn _end_list_box() {
		unsafe { imgui__end_list_box(); }
	}
	pub(crate) fn _begin_disabled() {
		unsafe { imgui__begin_disabled(); }
	}
	pub(crate) fn _end_disabled() {
		unsafe { imgui__end_disabled(); }
	}
	pub(crate) fn _begin_tooltip() -> bool {
		unsafe { return imgui__begin_tooltip() != 0; }
	}
	pub(crate) fn _end_tooltip() {
		unsafe { imgui__end_tooltip(); }
	}
	pub(crate) fn _begin_main_menu_bar() -> bool {
		unsafe { return imgui__begin_main_menu_bar() != 0; }
	}
	pub(crate) fn _end_main_menu_bar() {
		unsafe { imgui__end_main_menu_bar(); }
	}
	pub(crate) fn _begin_menu_bar() -> bool {
		unsafe { return imgui__begin_menu_bar() != 0; }
	}
	pub(crate) fn _end_menu_bar() {
		unsafe { imgui__end_menu_bar(); }
	}
	pub(crate) fn _begin_menu(label: &str, enabled: bool) -> bool {
		unsafe { return imgui__begin_menu(crate::dora::from_string(label), if enabled { 1 } else { 0 }) != 0; }
	}
	pub(crate) fn _end_menu() {
		unsafe { imgui__end_menu(); }
	}
	pub fn close_current_popup() {
		unsafe { imgui_close_current_popup(); }
	}
	pub(crate) fn _push_clip_rect(clip_rect_min: &crate::dora::Vec2, clip_rect_max: &crate::dora::Vec2, intersect_with_current_clip_rect: bool) {
		unsafe { imgui__push_clip_rect(clip_rect_min.into_i64(), clip_rect_max.into_i64(), if intersect_with_current_clip_rect { 1 } else { 0 }); }
	}
	pub(crate) fn _pop_clip_rect() {
		unsafe { imgui__pop_clip_rect(); }
	}
	pub fn is_item_hovered() -> bool {
		unsafe { return imgui_is_item_hovered() != 0; }
	}
	pub fn is_item_active() -> bool {
		unsafe { return imgui_is_item_active() != 0; }
	}
	pub fn is_item_clicked(mouse_button: i32) -> bool {
		unsafe { return imgui_is_item_clicked(mouse_button) != 0; }
	}
	pub fn is_item_visible() -> bool {
		unsafe { return imgui_is_item_visible() != 0; }
	}
	pub fn is_any_item_hovered() -> bool {
		unsafe { return imgui_is_any_item_hovered() != 0; }
	}
	pub fn is_any_item_active() -> bool {
		unsafe { return imgui_is_any_item_active() != 0; }
	}
	pub fn get_item_rect_min() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_item_rect_min()); }
	}
	pub fn get_item_rect_max() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_item_rect_max()); }
	}
	pub fn get_item_rect_size() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_item_rect_size()); }
	}
	pub fn set_next_item_allow_overlap() {
		unsafe { imgui_set_next_item_allow_overlap(); }
	}
	pub fn is_window_hovered() -> bool {
		unsafe { return imgui_is_window_hovered() != 0; }
	}
	pub fn is_window_focused() -> bool {
		unsafe { return imgui_is_window_focused() != 0; }
	}
	pub fn is_rect_visible(size: &crate::dora::Vec2) -> bool {
		unsafe { return imgui_is_rect_visible(size.into_i64()) != 0; }
	}
	pub fn is_mouse_down(button: i32) -> bool {
		unsafe { return imgui_is_mouse_down(button) != 0; }
	}
	pub fn is_mouse_clicked(button: i32, repeat: bool) -> bool {
		unsafe { return imgui_is_mouse_clicked(button, if repeat { 1 } else { 0 }) != 0; }
	}
	pub fn is_mouse_double_clicked(button: i32) -> bool {
		unsafe { return imgui_is_mouse_double_clicked(button) != 0; }
	}
	pub fn is_mouse_released(button: i32) -> bool {
		unsafe { return imgui_is_mouse_released(button) != 0; }
	}
	pub fn is_mouse_hovering_rect(r_min: &crate::dora::Vec2, r_max: &crate::dora::Vec2, clip: bool) -> bool {
		unsafe { return imgui_is_mouse_hovering_rect(r_min.into_i64(), r_max.into_i64(), if clip { 1 } else { 0 }) != 0; }
	}
	pub fn is_mouse_dragging(button: i32, lock_threshold: f32) -> bool {
		unsafe { return imgui_is_mouse_dragging(button, lock_threshold) != 0; }
	}
	pub fn get_mouse_pos() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_mouse_pos()); }
	}
	pub fn get_mouse_pos_on_opening_current_popup() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_mouse_pos_on_opening_current_popup()); }
	}
	pub fn get_mouse_drag_delta(button: i32, lock_threshold: f32) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_mouse_drag_delta(button, lock_threshold)); }
	}
	pub fn reset_mouse_drag_delta(button: i32) {
		unsafe { imgui_reset_mouse_drag_delta(button); }
	}
}