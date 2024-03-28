extern "C" {
	fn imgui_load_font_ttf_async(ttf_font_file: i64, font_size: f32, glyph_ranges: i64, func: i32, stack: i64);
	fn imgui_is_font_loaded() -> i32;
	fn imgui_show_stats();
	fn imgui_show_console();
	fn imgui_begin(name: i64) -> i32;
	fn imgui_begin_opts(name: i64, windows_flags: i64) -> i32;
	fn imgui_end();
	fn imgui_begin_child(str_id: i64) -> i32;
	fn imgui_begin_child_opts(str_id: i64, size: i64, child_flags: i64, window_flags: i64) -> i32;
	fn imgui_begin_child_with_id(id: i32) -> i32;
	fn imgui_begin_child_with_id_opts(id: i32, size: i64, child_flags: i64, window_flags: i64) -> i32;
	fn imgui_end_child();
	fn imgui_set_next_window_pos_center();
	fn imgui_set_next_window_pos_center_with_cond(set_cond: i64);
	fn imgui_set_next_window_size(size: i64);
	fn imgui_set_next_window_size_with_cond(size: i64, set_cond: i64);
	fn imgui_set_next_window_collapsed(collapsed: i32);
	fn imgui_set_next_window_collapsed_with_cond(collapsed: i32, set_cond: i64);
	fn imgui_set_window_pos(name: i64, pos: i64);
	fn imgui_set_window_pos_with_cond(name: i64, pos: i64, set_cond: i64);
	fn imgui_set_window_size(name: i64, size: i64);
	fn imgui_set_window_size_with_cond(name: i64, size: i64, set_cond: i64);
	fn imgui_set_window_collapsed(name: i64, collapsed: i32);
	fn imgui_set_window_collapsed_with_cond(name: i64, collapsed: i32, set_cond: i64);
	fn imgui_set_color_edit_options(color_edit_mode: i64);
	fn imgui_input_text(label: i64, buffer: i64) -> i32;
	fn imgui_input_text_opts(label: i64, buffer: i64, input_text_flags: i64) -> i32;
	fn imgui_input_text_multiline(label: i64, buffer: i64) -> i32;
	fn imgui_input_text_multiline_opts(label: i64, buffer: i64, size: i64, input_text_flags: i64) -> i32;
	fn imgui_tree_node_ex(label: i64) -> i32;
	fn imgui_tree_node_ex_opts(label: i64, tree_node_flags: i64) -> i32;
	fn imgui_tree_node_ex_with_id(str_id: i64, text: i64) -> i32;
	fn imgui_tree_node_ex_with_id_opts(str_id: i64, text: i64, tree_node_flags: i64) -> i32;
	fn imgui_set_next_item_open(is_open: i32);
	fn imgui_set_next_item_open_with_cond(is_open: i32, set_cond: i64);
	fn imgui_collapsing_header(label: i64) -> i32;
	fn imgui_collapsing_header_opts(label: i64, tree_node_flags: i64) -> i32;
	fn imgui_selectable(label: i64) -> i32;
	fn imgui_selectable_opts(label: i64, selectable_flags: i64) -> i32;
	fn imgui_begin_popup_modal(name: i64) -> i32;
	fn imgui_begin_popup_modal_opts(name: i64, windows_flags: i64) -> i32;
	fn imgui_begin_popup_context_item(name: i64) -> i32;
	fn imgui_begin_popup_context_item_opts(name: i64, popup_flags: i64) -> i32;
	fn imgui_begin_popup_context_window(name: i64) -> i32;
	fn imgui_begin_popup_context_window_opts(name: i64, popup_flags: i64) -> i32;
	fn imgui_begin_popup_context_void(name: i64) -> i32;
	fn imgui_begin_popup_context_void_opts(name: i64, popup_flags: i64) -> i32;
	fn imgui_bush_style_color(name: i64, color: i32);
	fn imgui_push_style_float(name: i64, val: f32);
	fn imgui_push_style_vec2(name: i64, val: i64);
	fn imgui_text(text: i64);
	fn imgui_text_colored(color: i32, text: i64);
	fn imgui_text_disabled(text: i64);
	fn imgui_text_wrapped(text: i64);
	fn imgui_label_text(label: i64, text: i64);
	fn imgui_bullet_text(text: i64);
	fn imgui_tree_node(str_id: i64, text: i64) -> i32;
	fn imgui_set_tooltip(text: i64);
	fn imgui_image(clip_str: i64, size: i64);
	fn imgui_image_opts(clip_str: i64, size: i64, tint_col: i32, border_col: i32);
	fn imgui_image_button(str_id: i64, clip_str: i64, size: i64) -> i32;
	fn imgui_image_button_opts(str_id: i64, clip_str: i64, size: i64, bg_col: i32, tint_col: i32) -> i32;
	fn imgui_color_button(desc_id: i64, col: i32) -> i32;
	fn imgui_color_button_opts(desc_id: i64, col: i32, flags: i64, size: i64) -> i32;
	fn imgui_columns(count: i32);
	fn imgui_columns_opts(count: i32, border: i32, str_id: i64);
	fn imgui_begin_table(str_id: i64, column: i32) -> i32;
	fn imgui_begin_table_opts(str_id: i64, column: i32, outer_size: i64, inner_width: f32, table_flags: i64) -> i32;
	fn imgui_table_next_row();
	fn imgui_table_next_row_opts(min_row_height: f32, table_row_flag: i64);
	fn imgui_table_setup_column(label: i64);
	fn imgui_table_setup_column_opts(label: i64, init_width_or_weight: f32, user_id: i32, table_column_flags: i64);
	fn imgui_set_style_bool(name: i64, var: i32);
	fn imgui_set_style_float(name: i64, var: f32);
	fn imgui_set_style_vec2(name: i64, var: i64);
	fn imgui_set_style_color(name: i64, color: i32);
	fn imgui__begin(name: i64, stack: i64) -> i32;
	fn imgui__begin_opts(name: i64, stack: i64, windows_flags: i64) -> i32;
	fn imgui__collapsing_header(label: i64, stack: i64) -> i32;
	fn imgui__collapsing_header_opts(label: i64, stack: i64, tree_node_flags: i64) -> i32;
	fn imgui__selectable(label: i64, stack: i64) -> i32;
	fn imgui__selectable_opts(label: i64, stack: i64, size: i64, selectable_flags: i64) -> i32;
	fn imgui__begin_popup_modal(name: i64, stack: i64) -> i32;
	fn imgui__begin_popup_modal_opts(name: i64, stack: i64, windows_flags: i64) -> i32;
	fn imgui__combo(label: i64, stack: i64, items: i64) -> i32;
	fn imgui__combo_opts(label: i64, stack: i64, items: i64, height_in_items: i32) -> i32;
	fn imgui__drag_float(label: i64, stack: i64, v_speed: f32, v_min: f32, v_max: f32) -> i32;
	fn imgui__drag_float_opts(label: i64, stack: i64, v_speed: f32, v_min: f32, v_max: f32, display_format: i64, slider_flags: i64) -> i32;
	fn imgui__drag_float2(label: i64, stack: i64, v_speed: f32, v_min: f32, v_max: f32) -> i32;
	fn imgui__drag_float2_opts(label: i64, stack: i64, v_speed: f32, v_min: f32, v_max: f32, display_format: i64, slider_flags: i64) -> i32;
	fn imgui__drag_int(label: i64, stack: i64, v_speed: f32, v_min: i32, v_max: i32) -> i32;
	fn imgui__drag_int_opts(label: i64, stack: i64, v_speed: f32, v_min: i32, v_max: i32, display_format: i64, slider_flags: i64) -> i32;
	fn imgui__drag_int2(label: i64, stack: i64, v_speed: f32, v_min: i32, v_max: i32) -> i32;
	fn imgui__drag_int2_opts(label: i64, stack: i64, v_speed: f32, v_min: i32, v_max: i32, display_format: i64, slider_flags: i64) -> i32;
	fn imgui__input_float(label: i64, stack: i64) -> i32;
	fn imgui__input_float_opts(label: i64, stack: i64, step: f32, step_fast: f32, display_format: i64, input_text_flags: i64) -> i32;
	fn imgui__input_float2(label: i64, stack: i64) -> i32;
	fn imgui__input_float2_opts(label: i64, stack: i64, display_format: i64, input_text_flags: i64) -> i32;
	fn imgui__input_int(label: i64, stack: i64) -> i32;
	fn imgui__input_int_opts(label: i64, stack: i64, step: i32, step_fast: i32, input_text_flags: i64) -> i32;
	fn imgui__input_int2(label: i64, stack: i64) -> i32;
	fn imgui__input_int2_opts(label: i64, stack: i64, input_text_flags: i64) -> i32;
	fn imgui__slider_float(label: i64, stack: i64, v_min: f32, v_max: f32) -> i32;
	fn imgui__slider_float_opts(label: i64, stack: i64, v_min: f32, v_max: f32, display_format: i64, slider_flags: i64) -> i32;
	fn imgui__slider_float2(label: i64, stack: i64, v_min: f32, v_max: f32) -> i32;
	fn imgui__slider_float2_opts(label: i64, stack: i64, v_min: f32, v_max: f32, display_format: i64, slider_flags: i64) -> i32;
	fn imgui__slider_int(label: i64, stack: i64, v_min: i32, v_max: i32) -> i32;
	fn imgui__slider_int_opts(label: i64, stack: i64, v_min: i32, v_max: i32, format: i64, slider_flags: i64) -> i32;
	fn imgui__slider_int2(label: i64, stack: i64, v_min: i32, v_max: i32) -> i32;
	fn imgui__slider_int2_opts(label: i64, stack: i64, v_min: i32, v_max: i32, display_format: i64, slider_flags: i64) -> i32;
	fn imgui__drag_float_range2(label: i64, stack: i64, v_speed: f32, v_min: f32, v_max: f32) -> i32;
	fn imgui__drag_float_range2_opts(label: i64, stack: i64, v_speed: f32, v_min: f32, v_max: f32, format: i64, format_max: i64, slider_flags: i64) -> i32;
	fn imgui__drag_int_range2(label: i64, stack: i64, v_speed: f32, v_min: i32, v_max: i32) -> i32;
	fn imgui__drag_int_range2_opts(label: i64, stack: i64, v_speed: f32, v_min: i32, v_max: i32, format: i64, format_max: i64, slider_flags: i64) -> i32;
	fn imgui__v_slider_float(label: i64, size: i64, stack: i64, v_min: f32, v_max: f32) -> i32;
	fn imgui__v_slider_float_opts(label: i64, size: i64, stack: i64, v_min: f32, v_max: f32, format: i64, slider_flags: i64) -> i32;
	fn imgui__v_slider_int(label: i64, size: i64, stack: i64, v_min: i32, v_max: i32) -> i32;
	fn imgui__v_slider_int_opts(label: i64, size: i64, stack: i64, v_min: i32, v_max: i32, format: i64, slider_flags: i64) -> i32;
	fn imgui__color_edit3(label: i64, stack: i64) -> i32;
	fn imgui__color_edit4(label: i64, stack: i64, show_alpha: i32) -> i32;
	fn imgui_scroll_when_dragging_on_void();
	fn imgui_set_next_window_pos(pos: i64, set_cond: i64, pivot: i64);
	fn imgui_set_next_window_bg_alpha(alpha: f32);
	fn imgui_show_demo_window();
	fn imgui_get_content_region_max() -> i64;
	fn imgui_get_content_region_avail() -> i64;
	fn imgui_get_window_content_region_min() -> i64;
	fn imgui_get_window_content_region_max() -> i64;
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
	fn imgui_pop_style_color(count: i32);
	fn imgui_pop_style_var(count: i32);
	fn imgui_set_next_item_width(item_width: f32);
	fn imgui_push_item_width(item_width: f32);
	fn imgui_pop_item_width();
	fn imgui_calc_item_width() -> f32;
	fn imgui_push_text_wrap_pos(wrap_pos_x: f32);
	fn imgui_pop_text_wrap_pos();
	fn imgui_push_tab_stop(v: i32);
	fn imgui_pop_tab_stop();
	fn imgui_push_button_repeat(repeat: i32);
	fn imgui_pop_button_repeat();
	fn imgui_separator();
	fn imgui_same_line(pos_x: f32, spacing_w: f32);
	fn imgui_new_line();
	fn imgui_spacing();
	fn imgui_dummy(size: i64);
	fn imgui_indent(indent_w: f32);
	fn imgui_unindent(indent_w: f32);
	fn imgui_begin_group();
	fn imgui_end_group();
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
	fn imgui_end_table();
	fn imgui_table_next_column() -> i32;
	fn imgui_table_set_column_index(column_n: i32) -> i32;
	fn imgui_table_setup_scroll_freeze(cols: i32, rows: i32);
	fn imgui_table_headers_row();
	fn imgui_pop_id();
	fn imgui_bullet_item();
	fn imgui_set_window_focus(name: i64);
	fn imgui_separator_text(text: i64);
	fn imgui_table_header(label: i64);
	fn imgui_push_id(str_id: i64);
	fn imgui_get_id(str_id: i64) -> i32;
	fn imgui_button(label: i64, size: i64) -> i32;
	fn imgui_small_button(label: i64) -> i32;
	fn imgui_invisible_button(str_id: i64, size: i64) -> i32;
	fn imgui__checkbox(label: i64, stack: i64) -> i32;
	fn imgui__radio_button(label: i64, stack: i64, v_button: i32) -> i32;
	fn imgui_plot_lines(label: i64, values: i64);
	fn imgui_plot_lines_with_scale(label: i64, values: i64, values_offset: i32, overlay_text: i64, scale_min: f32, scale_max: f32, graph_size: i64);
	fn imgui_plot_histogram(label: i64, values: i64);
	fn imgui_plot_histogram_with_scale(label: i64, values: i64, values_offset: i32, overlay_text: i64, scale_min: f32, scale_max: f32, graph_size: i64);
	fn imgui_progress_bar(fraction: f32);
	fn imgui_progress_bar_with_overlay(fraction: f32, size_arg: i64, overlay: i64);
	fn imgui__list_box(label: i64, stack: i64, items: i64) -> i32;
	fn imgui__list_box_with_height(label: i64, stack: i64, items: i64, height_in_items: i32) -> i32;
	fn imgui_slider_angle(label: i64, stack: i64, v_degrees_min: f32, v_degrees_max: f32) -> i32;
	fn imgui_tree_push(str_id: i64);
	fn imgui_begin_list_box(label: i64, size: i64) -> i32;
	fn imgui_value(prefix: i64, b: i32);
	fn imgui_begin_menu(label: i64, enabled: i32) -> i32;
	fn imgui_menu_item(label: i64, shortcut: i64, selected: i32, enabled: i32) -> i32;
	fn imgui_open_popup(str_id: i64);
	fn imgui_begin_popup(str_id: i64) -> i32;
	fn imgui_tree_pop();
	fn imgui_get_tree_node_to_label_spacing() -> f32;
	fn imgui_end_list_box();
	fn imgui_begin_disabled();
	fn imgui_end_disabled();
	fn imgui_begin_tooltip();
	fn imgui_end_tooltip();
	fn imgui_begin_main_menu_bar() -> i32;
	fn imgui_end_main_menu_bar();
	fn imgui_begin_menu_bar() -> i32;
	fn imgui_end_menu_bar();
	fn imgui_end_menu();
	fn imgui_end_popup();
	fn imgui_close_current_popup();
	fn imgui_push_clip_rect(clip_rect_min: i64, clip_rect_max: i64, intersect_with_current_clip_rect: i32);
	fn imgui_pop_clip_rect();
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
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			handler(stack.pop_bool().unwrap())
		}));
		unsafe { imgui_load_font_ttf_async(crate::dora::from_string(ttf_font_file), font_size, crate::dora::from_string(glyph_ranges), func_id, stack_raw); }
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
	pub fn begin(name: &str) -> bool {
		unsafe { return imgui_begin(crate::dora::from_string(name)) != 0; }
	}
	pub fn begin_opts(name: &str, windows_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_opts(crate::dora::from_string(name), crate::dora::Vector::from_str(windows_flags)) != 0; }
	}
	pub fn end() {
		unsafe { imgui_end(); }
	}
	pub fn begin_child(str_id: &str) -> bool {
		unsafe { return imgui_begin_child(crate::dora::from_string(str_id)) != 0; }
	}
	pub fn begin_child_opts(str_id: &str, size: &crate::dora::Vec2, child_flags: &Vec<&str>, window_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_child_opts(crate::dora::from_string(str_id), size.into_i64(), crate::dora::Vector::from_str(child_flags), crate::dora::Vector::from_str(window_flags)) != 0; }
	}
	pub fn begin_child_with_id(id: i32) -> bool {
		unsafe { return imgui_begin_child_with_id(id) != 0; }
	}
	pub fn begin_child_with_id_opts(id: i32, size: &crate::dora::Vec2, child_flags: &Vec<&str>, window_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_child_with_id_opts(id, size.into_i64(), crate::dora::Vector::from_str(child_flags), crate::dora::Vector::from_str(window_flags)) != 0; }
	}
	pub fn end_child() {
		unsafe { imgui_end_child(); }
	}
	pub fn set_next_window_pos_center() {
		unsafe { imgui_set_next_window_pos_center(); }
	}
	pub fn set_next_window_pos_center_with_cond(set_cond: &str) {
		unsafe { imgui_set_next_window_pos_center_with_cond(crate::dora::from_string(set_cond)); }
	}
	pub fn set_next_window_size(size: &crate::dora::Vec2) {
		unsafe { imgui_set_next_window_size(size.into_i64()); }
	}
	pub fn set_next_window_size_with_cond(size: &crate::dora::Vec2, set_cond: &str) {
		unsafe { imgui_set_next_window_size_with_cond(size.into_i64(), crate::dora::from_string(set_cond)); }
	}
	pub fn set_next_window_collapsed(collapsed: bool) {
		unsafe { imgui_set_next_window_collapsed(if collapsed { 1 } else { 0 }); }
	}
	pub fn set_next_window_collapsed_with_cond(collapsed: bool, set_cond: &str) {
		unsafe { imgui_set_next_window_collapsed_with_cond(if collapsed { 1 } else { 0 }, crate::dora::from_string(set_cond)); }
	}
	pub fn set_window_pos(name: &str, pos: &crate::dora::Vec2) {
		unsafe { imgui_set_window_pos(crate::dora::from_string(name), pos.into_i64()); }
	}
	pub fn set_window_pos_with_cond(name: &str, pos: &crate::dora::Vec2, set_cond: &str) {
		unsafe { imgui_set_window_pos_with_cond(crate::dora::from_string(name), pos.into_i64(), crate::dora::from_string(set_cond)); }
	}
	pub fn set_window_size(name: &str, size: &crate::dora::Vec2) {
		unsafe { imgui_set_window_size(crate::dora::from_string(name), size.into_i64()); }
	}
	pub fn set_window_size_with_cond(name: &str, size: &crate::dora::Vec2, set_cond: &str) {
		unsafe { imgui_set_window_size_with_cond(crate::dora::from_string(name), size.into_i64(), crate::dora::from_string(set_cond)); }
	}
	pub fn set_window_collapsed(name: &str, collapsed: bool) {
		unsafe { imgui_set_window_collapsed(crate::dora::from_string(name), if collapsed { 1 } else { 0 }); }
	}
	pub fn set_window_collapsed_with_cond(name: &str, collapsed: bool, set_cond: &str) {
		unsafe { imgui_set_window_collapsed_with_cond(crate::dora::from_string(name), if collapsed { 1 } else { 0 }, crate::dora::from_string(set_cond)); }
	}
	pub fn set_color_edit_options(color_edit_mode: &str) {
		unsafe { imgui_set_color_edit_options(crate::dora::from_string(color_edit_mode)); }
	}
	pub fn input_text(label: &str, buffer: &crate::dora::Buffer) -> bool {
		unsafe { return imgui_input_text(crate::dora::from_string(label), buffer.raw()) != 0; }
	}
	pub fn input_text_opts(label: &str, buffer: &crate::dora::Buffer, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_input_text_opts(crate::dora::from_string(label), buffer.raw(), crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub fn input_text_multiline(label: &str, buffer: &crate::dora::Buffer) -> bool {
		unsafe { return imgui_input_text_multiline(crate::dora::from_string(label), buffer.raw()) != 0; }
	}
	pub fn input_text_multiline_opts(label: &str, buffer: &crate::dora::Buffer, size: &crate::dora::Vec2, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_input_text_multiline_opts(crate::dora::from_string(label), buffer.raw(), size.into_i64(), crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub fn tree_node_ex(label: &str) -> bool {
		unsafe { return imgui_tree_node_ex(crate::dora::from_string(label)) != 0; }
	}
	pub fn tree_node_ex_opts(label: &str, tree_node_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_tree_node_ex_opts(crate::dora::from_string(label), crate::dora::Vector::from_str(tree_node_flags)) != 0; }
	}
	pub fn tree_node_ex_with_id(str_id: &str, text: &str) -> bool {
		unsafe { return imgui_tree_node_ex_with_id(crate::dora::from_string(str_id), crate::dora::from_string(text)) != 0; }
	}
	pub fn tree_node_ex_with_id_opts(str_id: &str, text: &str, tree_node_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_tree_node_ex_with_id_opts(crate::dora::from_string(str_id), crate::dora::from_string(text), crate::dora::Vector::from_str(tree_node_flags)) != 0; }
	}
	pub fn set_next_item_open(is_open: bool) {
		unsafe { imgui_set_next_item_open(if is_open { 1 } else { 0 }); }
	}
	pub fn set_next_item_open_with_cond(is_open: bool, set_cond: &str) {
		unsafe { imgui_set_next_item_open_with_cond(if is_open { 1 } else { 0 }, crate::dora::from_string(set_cond)); }
	}
	pub fn collapsing_header(label: &str) -> bool {
		unsafe { return imgui_collapsing_header(crate::dora::from_string(label)) != 0; }
	}
	pub fn collapsing_header_opts(label: &str, tree_node_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_collapsing_header_opts(crate::dora::from_string(label), crate::dora::Vector::from_str(tree_node_flags)) != 0; }
	}
	pub fn selectable(label: &str) -> bool {
		unsafe { return imgui_selectable(crate::dora::from_string(label)) != 0; }
	}
	pub fn selectable_opts(label: &str, selectable_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_selectable_opts(crate::dora::from_string(label), crate::dora::Vector::from_str(selectable_flags)) != 0; }
	}
	pub fn begin_popup_modal(name: &str) -> bool {
		unsafe { return imgui_begin_popup_modal(crate::dora::from_string(name)) != 0; }
	}
	pub fn begin_popup_modal_opts(name: &str, windows_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_popup_modal_opts(crate::dora::from_string(name), crate::dora::Vector::from_str(windows_flags)) != 0; }
	}
	pub fn begin_popup_context_item(name: &str) -> bool {
		unsafe { return imgui_begin_popup_context_item(crate::dora::from_string(name)) != 0; }
	}
	pub fn begin_popup_context_item_opts(name: &str, popup_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_popup_context_item_opts(crate::dora::from_string(name), crate::dora::Vector::from_str(popup_flags)) != 0; }
	}
	pub fn begin_popup_context_window(name: &str) -> bool {
		unsafe { return imgui_begin_popup_context_window(crate::dora::from_string(name)) != 0; }
	}
	pub fn begin_popup_context_window_opts(name: &str, popup_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_popup_context_window_opts(crate::dora::from_string(name), crate::dora::Vector::from_str(popup_flags)) != 0; }
	}
	pub fn begin_popup_context_void(name: &str) -> bool {
		unsafe { return imgui_begin_popup_context_void(crate::dora::from_string(name)) != 0; }
	}
	pub fn begin_popup_context_void_opts(name: &str, popup_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_popup_context_void_opts(crate::dora::from_string(name), crate::dora::Vector::from_str(popup_flags)) != 0; }
	}
	pub fn bush_style_color(name: &str, color: &crate::dora::Color) {
		unsafe { imgui_bush_style_color(crate::dora::from_string(name), color.to_argb() as i32); }
	}
	pub fn push_style_float(name: &str, val: f32) {
		unsafe { imgui_push_style_float(crate::dora::from_string(name), val); }
	}
	pub fn push_style_vec2(name: &str, val: &crate::dora::Vec2) {
		unsafe { imgui_push_style_vec2(crate::dora::from_string(name), val.into_i64()); }
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
	pub fn tree_node(str_id: &str, text: &str) -> bool {
		unsafe { return imgui_tree_node(crate::dora::from_string(str_id), crate::dora::from_string(text)) != 0; }
	}
	pub fn set_tooltip(text: &str) {
		unsafe { imgui_set_tooltip(crate::dora::from_string(text)); }
	}
	pub fn image(clip_str: &str, size: &crate::dora::Vec2) {
		unsafe { imgui_image(crate::dora::from_string(clip_str), size.into_i64()); }
	}
	pub fn image_opts(clip_str: &str, size: &crate::dora::Vec2, tint_col: &crate::dora::Color, border_col: &crate::dora::Color) {
		unsafe { imgui_image_opts(crate::dora::from_string(clip_str), size.into_i64(), tint_col.to_argb() as i32, border_col.to_argb() as i32); }
	}
	pub fn image_button(str_id: &str, clip_str: &str, size: &crate::dora::Vec2) -> bool {
		unsafe { return imgui_image_button(crate::dora::from_string(str_id), crate::dora::from_string(clip_str), size.into_i64()) != 0; }
	}
	pub fn image_button_opts(str_id: &str, clip_str: &str, size: &crate::dora::Vec2, bg_col: &crate::dora::Color, tint_col: &crate::dora::Color) -> bool {
		unsafe { return imgui_image_button_opts(crate::dora::from_string(str_id), crate::dora::from_string(clip_str), size.into_i64(), bg_col.to_argb() as i32, tint_col.to_argb() as i32) != 0; }
	}
	pub fn color_button(desc_id: &str, col: &crate::dora::Color) -> bool {
		unsafe { return imgui_color_button(crate::dora::from_string(desc_id), col.to_argb() as i32) != 0; }
	}
	pub fn color_button_opts(desc_id: &str, col: &crate::dora::Color, flags: &str, size: &crate::dora::Vec2) -> bool {
		unsafe { return imgui_color_button_opts(crate::dora::from_string(desc_id), col.to_argb() as i32, crate::dora::from_string(flags), size.into_i64()) != 0; }
	}
	pub fn columns(count: i32) {
		unsafe { imgui_columns(count); }
	}
	pub fn columns_opts(count: i32, border: bool, str_id: &str) {
		unsafe { imgui_columns_opts(count, if border { 1 } else { 0 }, crate::dora::from_string(str_id)); }
	}
	pub fn begin_table(str_id: &str, column: i32) -> bool {
		unsafe { return imgui_begin_table(crate::dora::from_string(str_id), column) != 0; }
	}
	pub fn begin_table_opts(str_id: &str, column: i32, outer_size: &crate::dora::Vec2, inner_width: f32, table_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_table_opts(crate::dora::from_string(str_id), column, outer_size.into_i64(), inner_width, crate::dora::Vector::from_str(table_flags)) != 0; }
	}
	pub fn table_next_row() {
		unsafe { imgui_table_next_row(); }
	}
	pub fn table_next_row_opts(min_row_height: f32, table_row_flag: &str) {
		unsafe { imgui_table_next_row_opts(min_row_height, crate::dora::from_string(table_row_flag)); }
	}
	pub fn table_setup_column(label: &str) {
		unsafe { imgui_table_setup_column(crate::dora::from_string(label)); }
	}
	pub fn table_setup_column_opts(label: &str, init_width_or_weight: f32, user_id: i32, table_column_flags: &Vec<&str>) {
		unsafe { imgui_table_setup_column_opts(crate::dora::from_string(label), init_width_or_weight, user_id, crate::dora::Vector::from_str(table_column_flags)); }
	}
	pub fn set_style_bool(name: &str, var: bool) {
		unsafe { imgui_set_style_bool(crate::dora::from_string(name), if var { 1 } else { 0 }); }
	}
	pub fn set_style_float(name: &str, var: f32) {
		unsafe { imgui_set_style_float(crate::dora::from_string(name), var); }
	}
	pub fn set_style_vec2(name: &str, var: &crate::dora::Vec2) {
		unsafe { imgui_set_style_vec2(crate::dora::from_string(name), var.into_i64()); }
	}
	pub fn set_style_color(name: &str, color: &crate::dora::Color) {
		unsafe { imgui_set_style_color(crate::dora::from_string(name), color.to_argb() as i32); }
	}
	pub(crate) fn _begin(name: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__begin(crate::dora::from_string(name), stack.raw()) != 0; }
	}
	pub(crate) fn _begin_opts(name: &str, stack: &crate::dora::CallStack, windows_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__begin_opts(crate::dora::from_string(name), stack.raw(), crate::dora::Vector::from_str(windows_flags)) != 0; }
	}
	pub(crate) fn _collapsing_header(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__collapsing_header(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub(crate) fn _collapsing_header_opts(label: &str, stack: &crate::dora::CallStack, tree_node_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__collapsing_header_opts(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(tree_node_flags)) != 0; }
	}
	pub(crate) fn _selectable(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__selectable(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub(crate) fn _selectable_opts(label: &str, stack: &crate::dora::CallStack, size: &crate::dora::Vec2, selectable_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__selectable_opts(crate::dora::from_string(label), stack.raw(), size.into_i64(), crate::dora::Vector::from_str(selectable_flags)) != 0; }
	}
	pub(crate) fn _begin_popup_modal(name: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__begin_popup_modal(crate::dora::from_string(name), stack.raw()) != 0; }
	}
	pub(crate) fn _begin_popup_modal_opts(name: &str, stack: &crate::dora::CallStack, windows_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__begin_popup_modal_opts(crate::dora::from_string(name), stack.raw(), crate::dora::Vector::from_str(windows_flags)) != 0; }
	}
	pub(crate) fn _combo(label: &str, stack: &crate::dora::CallStack, items: &Vec<&str>) -> bool {
		unsafe { return imgui__combo(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(items)) != 0; }
	}
	pub(crate) fn _combo_opts(label: &str, stack: &crate::dora::CallStack, items: &Vec<&str>, height_in_items: i32) -> bool {
		unsafe { return imgui__combo_opts(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(items), height_in_items) != 0; }
	}
	pub(crate) fn _drag_float(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__drag_float(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub(crate) fn _drag_float_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_float_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _drag_float2(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__drag_float2(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub(crate) fn _drag_float2_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_float2_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _drag_int(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__drag_int(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub(crate) fn _drag_int_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_int_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _drag_int2(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__drag_int2(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub(crate) fn _drag_int2_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_int2_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _input_float(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__input_float(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub(crate) fn _input_float_opts(label: &str, stack: &crate::dora::CallStack, step: f32, step_fast: f32, display_format: &str, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__input_float_opts(crate::dora::from_string(label), stack.raw(), step, step_fast, crate::dora::from_string(display_format), crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub(crate) fn _input_float2(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__input_float2(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub(crate) fn _input_float2_opts(label: &str, stack: &crate::dora::CallStack, display_format: &str, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__input_float2_opts(crate::dora::from_string(label), stack.raw(), crate::dora::from_string(display_format), crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub(crate) fn _input_int(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__input_int(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub(crate) fn _input_int_opts(label: &str, stack: &crate::dora::CallStack, step: i32, step_fast: i32, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__input_int_opts(crate::dora::from_string(label), stack.raw(), step, step_fast, crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub(crate) fn _input_int2(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__input_int2(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub(crate) fn _input_int2_opts(label: &str, stack: &crate::dora::CallStack, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__input_int2_opts(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub(crate) fn _slider_float(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__slider_float(crate::dora::from_string(label), stack.raw(), v_min, v_max) != 0; }
	}
	pub(crate) fn _slider_float_opts(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__slider_float_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _slider_float2(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__slider_float2(crate::dora::from_string(label), stack.raw(), v_min, v_max) != 0; }
	}
	pub(crate) fn _slider_float2_opts(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__slider_float2_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _slider_int(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__slider_int(crate::dora::from_string(label), stack.raw(), v_min, v_max) != 0; }
	}
	pub(crate) fn _slider_int_opts(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32, format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__slider_int_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _slider_int2(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__slider_int2(crate::dora::from_string(label), stack.raw(), v_min, v_max) != 0; }
	}
	pub(crate) fn _slider_int2_opts(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__slider_int2_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _drag_float_range2(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__drag_float_range2(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub(crate) fn _drag_float_range2_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32, format: &str, format_max: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_float_range2_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(format), crate::dora::from_string(format_max), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _drag_int_range2(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__drag_int_range2(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub(crate) fn _drag_int_range2_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32, format: &str, format_max: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_int_range2_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(format), crate::dora::from_string(format_max), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _v_slider_float(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__v_slider_float(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max) != 0; }
	}
	pub(crate) fn _v_slider_float_opts(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: f32, v_max: f32, format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__v_slider_float_opts(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max, crate::dora::from_string(format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _v_slider_int(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__v_slider_int(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max) != 0; }
	}
	pub(crate) fn _v_slider_int_opts(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: i32, v_max: i32, format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__v_slider_int_opts(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max, crate::dora::from_string(format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub(crate) fn _color_edit3(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__color_edit3(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub(crate) fn _color_edit4(label: &str, stack: &crate::dora::CallStack, show_alpha: bool) -> bool {
		unsafe { return imgui__color_edit4(crate::dora::from_string(label), stack.raw(), if show_alpha { 1 } else { 0 }) != 0; }
	}
	pub fn scroll_when_dragging_on_void() {
		unsafe { imgui_scroll_when_dragging_on_void(); }
	}
	pub fn set_next_window_pos(pos: &crate::dora::Vec2, set_cond: &str, pivot: &crate::dora::Vec2) {
		unsafe { imgui_set_next_window_pos(pos.into_i64(), crate::dora::from_string(set_cond), pivot.into_i64()); }
	}
	pub fn set_next_window_bg_alpha(alpha: f32) {
		unsafe { imgui_set_next_window_bg_alpha(alpha); }
	}
	pub fn show_demo_window() {
		unsafe { imgui_show_demo_window(); }
	}
	pub fn get_content_region_max() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_content_region_max()); }
	}
	pub fn get_content_region_avail() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_content_region_avail()); }
	}
	pub fn get_window_content_region_min() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_window_content_region_min()); }
	}
	pub fn get_window_content_region_max() -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(imgui_get_window_content_region_max()); }
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
	pub fn pop_style_color(count: i32) {
		unsafe { imgui_pop_style_color(count); }
	}
	pub fn pop_style_var(count: i32) {
		unsafe { imgui_pop_style_var(count); }
	}
	pub fn set_next_item_width(item_width: f32) {
		unsafe { imgui_set_next_item_width(item_width); }
	}
	pub fn push_item_width(item_width: f32) {
		unsafe { imgui_push_item_width(item_width); }
	}
	pub fn pop_item_width() {
		unsafe { imgui_pop_item_width(); }
	}
	pub fn calc_item_width() -> f32 {
		unsafe { return imgui_calc_item_width(); }
	}
	pub fn push_text_wrap_pos(wrap_pos_x: f32) {
		unsafe { imgui_push_text_wrap_pos(wrap_pos_x); }
	}
	pub fn pop_text_wrap_pos() {
		unsafe { imgui_pop_text_wrap_pos(); }
	}
	pub fn push_tab_stop(v: bool) {
		unsafe { imgui_push_tab_stop(if v { 1 } else { 0 }); }
	}
	pub fn pop_tab_stop() {
		unsafe { imgui_pop_tab_stop(); }
	}
	pub fn push_button_repeat(repeat: bool) {
		unsafe { imgui_push_button_repeat(if repeat { 1 } else { 0 }); }
	}
	pub fn pop_button_repeat() {
		unsafe { imgui_pop_button_repeat(); }
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
	pub fn begin_group() {
		unsafe { imgui_begin_group(); }
	}
	pub fn end_group() {
		unsafe { imgui_end_group(); }
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
	pub fn end_table() {
		unsafe { imgui_end_table(); }
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
	pub fn pop_id() {
		unsafe { imgui_pop_id(); }
	}
	pub fn bullet_item() {
		unsafe { imgui_bullet_item(); }
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
	pub fn push_id(str_id: &str) {
		unsafe { imgui_push_id(crate::dora::from_string(str_id)); }
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
	pub(crate) fn _checkbox(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__checkbox(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub(crate) fn _radio_button(label: &str, stack: &crate::dora::CallStack, v_button: i32) -> bool {
		unsafe { return imgui__radio_button(crate::dora::from_string(label), stack.raw(), v_button) != 0; }
	}
	pub fn plot_lines(label: &str, values: &Vec<f32>) {
		unsafe { imgui_plot_lines(crate::dora::from_string(label), crate::dora::Vector::from_f32(values)); }
	}
	pub fn plot_lines_with_scale(label: &str, values: &Vec<f32>, values_offset: i32, overlay_text: &str, scale_min: f32, scale_max: f32, graph_size: &crate::dora::Vec2) {
		unsafe { imgui_plot_lines_with_scale(crate::dora::from_string(label), crate::dora::Vector::from_f32(values), values_offset, crate::dora::from_string(overlay_text), scale_min, scale_max, graph_size.into_i64()); }
	}
	pub fn plot_histogram(label: &str, values: &Vec<f32>) {
		unsafe { imgui_plot_histogram(crate::dora::from_string(label), crate::dora::Vector::from_f32(values)); }
	}
	pub fn plot_histogram_with_scale(label: &str, values: &Vec<f32>, values_offset: i32, overlay_text: &str, scale_min: f32, scale_max: f32, graph_size: &crate::dora::Vec2) {
		unsafe { imgui_plot_histogram_with_scale(crate::dora::from_string(label), crate::dora::Vector::from_f32(values), values_offset, crate::dora::from_string(overlay_text), scale_min, scale_max, graph_size.into_i64()); }
	}
	pub fn progress_bar(fraction: f32) {
		unsafe { imgui_progress_bar(fraction); }
	}
	pub fn progress_bar_with_overlay(fraction: f32, size_arg: &crate::dora::Vec2, overlay: &str) {
		unsafe { imgui_progress_bar_with_overlay(fraction, size_arg.into_i64(), crate::dora::from_string(overlay)); }
	}
	pub(crate) fn _list_box(label: &str, stack: &crate::dora::CallStack, items: &Vec<&str>) -> bool {
		unsafe { return imgui__list_box(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(items)) != 0; }
	}
	pub(crate) fn _list_box_with_height(label: &str, stack: &crate::dora::CallStack, items: &Vec<&str>, height_in_items: i32) -> bool {
		unsafe { return imgui__list_box_with_height(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(items), height_in_items) != 0; }
	}
	pub fn slider_angle(label: &str, stack: &crate::dora::CallStack, v_degrees_min: f32, v_degrees_max: f32) -> bool {
		unsafe { return imgui_slider_angle(crate::dora::from_string(label), stack.raw(), v_degrees_min, v_degrees_max) != 0; }
	}
	pub fn tree_push(str_id: &str) {
		unsafe { imgui_tree_push(crate::dora::from_string(str_id)); }
	}
	pub fn begin_list_box(label: &str, size: &crate::dora::Vec2) -> bool {
		unsafe { return imgui_begin_list_box(crate::dora::from_string(label), size.into_i64()) != 0; }
	}
	pub fn value(prefix: &str, b: bool) {
		unsafe { imgui_value(crate::dora::from_string(prefix), if b { 1 } else { 0 }); }
	}
	pub fn begin_menu(label: &str, enabled: bool) -> bool {
		unsafe { return imgui_begin_menu(crate::dora::from_string(label), if enabled { 1 } else { 0 }) != 0; }
	}
	pub fn menu_item(label: &str, shortcut: &str, selected: bool, enabled: bool) -> bool {
		unsafe { return imgui_menu_item(crate::dora::from_string(label), crate::dora::from_string(shortcut), if selected { 1 } else { 0 }, if enabled { 1 } else { 0 }) != 0; }
	}
	pub fn open_popup(str_id: &str) {
		unsafe { imgui_open_popup(crate::dora::from_string(str_id)); }
	}
	pub fn begin_popup(str_id: &str) -> bool {
		unsafe { return imgui_begin_popup(crate::dora::from_string(str_id)) != 0; }
	}
	pub fn tree_pop() {
		unsafe { imgui_tree_pop(); }
	}
	pub fn get_tree_node_to_label_spacing() -> f32 {
		unsafe { return imgui_get_tree_node_to_label_spacing(); }
	}
	pub fn end_list_box() {
		unsafe { imgui_end_list_box(); }
	}
	pub fn begin_disabled() {
		unsafe { imgui_begin_disabled(); }
	}
	pub fn end_disabled() {
		unsafe { imgui_end_disabled(); }
	}
	pub fn begin_tooltip() {
		unsafe { imgui_begin_tooltip(); }
	}
	pub fn end_tooltip() {
		unsafe { imgui_end_tooltip(); }
	}
	pub fn begin_main_menu_bar() -> bool {
		unsafe { return imgui_begin_main_menu_bar() != 0; }
	}
	pub fn end_main_menu_bar() {
		unsafe { imgui_end_main_menu_bar(); }
	}
	pub fn begin_menu_bar() -> bool {
		unsafe { return imgui_begin_menu_bar() != 0; }
	}
	pub fn end_menu_bar() {
		unsafe { imgui_end_menu_bar(); }
	}
	pub fn end_menu() {
		unsafe { imgui_end_menu(); }
	}
	pub fn end_popup() {
		unsafe { imgui_end_popup(); }
	}
	pub fn close_current_popup() {
		unsafe { imgui_close_current_popup(); }
	}
	pub fn push_clip_rect(clip_rect_min: &crate::dora::Vec2, clip_rect_max: &crate::dora::Vec2, intersect_with_current_clip_rect: bool) {
		unsafe { imgui_push_clip_rect(clip_rect_min.into_i64(), clip_rect_max.into_i64(), if intersect_with_current_clip_rect { 1 } else { 0 }); }
	}
	pub fn pop_clip_rect() {
		unsafe { imgui_pop_clip_rect(); }
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