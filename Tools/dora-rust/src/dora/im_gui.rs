extern "C" {
	fn imgui_load_font_ttf_async(ttf_font_file: i64, font_size: f32, glyph_ranges: i64, func: i32, stack: i64);
	fn imgui_is_font_loaded() -> i32;
	fn imgui_show_stats();
	fn imgui_show_console();
	fn imgui_begin(name: i64) -> i32;
	fn imgui_begin_opts(name: i64, windows_flags: i64) -> i32;
	fn imgui_begin_child(str_id: i64) -> i32;
	fn imgui_begin_child_opts(str_id: i64, size: i64, border: i32, windows_flags: i64) -> i32;
	fn imgui_begin_child_with_id(id: i32) -> i32;
	fn imgui_begin_child_with_id_opts(id: i32, size: i64, border: i32, windows_flags: i64) -> i32;
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
	fn imgui_begin_child_frame(id: i32, size: i64) -> i32;
	fn imgui_begin_child_frame_opts(id: i32, size: i64, windows_flags: i64) -> i32;
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
	pub fn begin_child(str_id: &str) -> bool {
		unsafe { return imgui_begin_child(crate::dora::from_string(str_id)) != 0; }
	}
	pub fn begin_child_opts(str_id: &str, size: &crate::dora::Vec2, border: bool, windows_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_child_opts(crate::dora::from_string(str_id), size.into_i64(), if border { 1 } else { 0 }, crate::dora::Vector::from_str(windows_flags)) != 0; }
	}
	pub fn begin_child_with_id(id: i32) -> bool {
		unsafe { return imgui_begin_child_with_id(id) != 0; }
	}
	pub fn begin_child_with_id_opts(id: i32, size: &crate::dora::Vec2, border: bool, windows_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_child_with_id_opts(id, size.into_i64(), if border { 1 } else { 0 }, crate::dora::Vector::from_str(windows_flags)) != 0; }
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
	pub fn begin_child_frame(id: i32, size: &crate::dora::Vec2) -> bool {
		unsafe { return imgui_begin_child_frame(id, size.into_i64()) != 0; }
	}
	pub fn begin_child_frame_opts(id: i32, size: &crate::dora::Vec2, windows_flags: &Vec<&str>) -> bool {
		unsafe { return imgui_begin_child_frame_opts(id, size.into_i64(), crate::dora::Vector::from_str(windows_flags)) != 0; }
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
	pub fn _begin(name: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__begin(crate::dora::from_string(name), stack.raw()) != 0; }
	}
	pub fn _begin_opts(name: &str, stack: &crate::dora::CallStack, windows_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__begin_opts(crate::dora::from_string(name), stack.raw(), crate::dora::Vector::from_str(windows_flags)) != 0; }
	}
	pub fn _collapsing_header(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__collapsing_header(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub fn _collapsing_header_opts(label: &str, stack: &crate::dora::CallStack, tree_node_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__collapsing_header_opts(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(tree_node_flags)) != 0; }
	}
	pub fn _selectable(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__selectable(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub fn _selectable_opts(label: &str, stack: &crate::dora::CallStack, size: &crate::dora::Vec2, selectable_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__selectable_opts(crate::dora::from_string(label), stack.raw(), size.into_i64(), crate::dora::Vector::from_str(selectable_flags)) != 0; }
	}
	pub fn _begin_popup_modal(name: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__begin_popup_modal(crate::dora::from_string(name), stack.raw()) != 0; }
	}
	pub fn _begin_popup_modal_opts(name: &str, stack: &crate::dora::CallStack, windows_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__begin_popup_modal_opts(crate::dora::from_string(name), stack.raw(), crate::dora::Vector::from_str(windows_flags)) != 0; }
	}
	pub fn _combo(label: &str, stack: &crate::dora::CallStack, items: &Vec<&str>) -> bool {
		unsafe { return imgui__combo(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(items)) != 0; }
	}
	pub fn _combo_opts(label: &str, stack: &crate::dora::CallStack, items: &Vec<&str>, height_in_items: i32) -> bool {
		unsafe { return imgui__combo_opts(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(items), height_in_items) != 0; }
	}
	pub fn _drag_float(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__drag_float(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub fn _drag_float_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_float_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _drag_float2(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__drag_float2(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub fn _drag_float2_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_float2_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _drag_int(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__drag_int(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub fn _drag_int_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_int_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _drag_int2(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__drag_int2(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub fn _drag_int2_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_int2_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _input_float(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__input_float(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub fn _input_float_opts(label: &str, stack: &crate::dora::CallStack, step: f32, step_fast: f32, display_format: &str, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__input_float_opts(crate::dora::from_string(label), stack.raw(), step, step_fast, crate::dora::from_string(display_format), crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub fn _input_float2(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__input_float2(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub fn _input_float2_opts(label: &str, stack: &crate::dora::CallStack, display_format: &str, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__input_float2_opts(crate::dora::from_string(label), stack.raw(), crate::dora::from_string(display_format), crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub fn _input_int(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__input_int(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub fn _input_int_opts(label: &str, stack: &crate::dora::CallStack, step: i32, step_fast: i32, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__input_int_opts(crate::dora::from_string(label), stack.raw(), step, step_fast, crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub fn _input_int2(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__input_int2(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub fn _input_int2_opts(label: &str, stack: &crate::dora::CallStack, input_text_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__input_int2_opts(crate::dora::from_string(label), stack.raw(), crate::dora::Vector::from_str(input_text_flags)) != 0; }
	}
	pub fn _slider_float(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__slider_float(crate::dora::from_string(label), stack.raw(), v_min, v_max) != 0; }
	}
	pub fn _slider_float_opts(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__slider_float_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _slider_float2(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__slider_float2(crate::dora::from_string(label), stack.raw(), v_min, v_max) != 0; }
	}
	pub fn _slider_float2_opts(label: &str, stack: &crate::dora::CallStack, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__slider_float2_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _slider_int(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__slider_int(crate::dora::from_string(label), stack.raw(), v_min, v_max) != 0; }
	}
	pub fn _slider_int_opts(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32, format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__slider_int_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _slider_int2(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__slider_int2(crate::dora::from_string(label), stack.raw(), v_min, v_max) != 0; }
	}
	pub fn _slider_int2_opts(label: &str, stack: &crate::dora::CallStack, v_min: i32, v_max: i32, display_format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__slider_int2_opts(crate::dora::from_string(label), stack.raw(), v_min, v_max, crate::dora::from_string(display_format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _drag_float_range2(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__drag_float_range2(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub fn _drag_float_range2_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: f32, v_max: f32, format: &str, format_max: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_float_range2_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(format), crate::dora::from_string(format_max), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _drag_int_range2(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__drag_int_range2(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max) != 0; }
	}
	pub fn _drag_int_range2_opts(label: &str, stack: &crate::dora::CallStack, v_speed: f32, v_min: i32, v_max: i32, format: &str, format_max: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__drag_int_range2_opts(crate::dora::from_string(label), stack.raw(), v_speed, v_min, v_max, crate::dora::from_string(format), crate::dora::from_string(format_max), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _v_slider_float(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: f32, v_max: f32) -> bool {
		unsafe { return imgui__v_slider_float(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max) != 0; }
	}
	pub fn _v_slider_float_opts(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: f32, v_max: f32, format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__v_slider_float_opts(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max, crate::dora::from_string(format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _v_slider_int(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: i32, v_max: i32) -> bool {
		unsafe { return imgui__v_slider_int(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max) != 0; }
	}
	pub fn _v_slider_int_opts(label: &str, size: &crate::dora::Vec2, stack: &crate::dora::CallStack, v_min: i32, v_max: i32, format: &str, slider_flags: &Vec<&str>) -> bool {
		unsafe { return imgui__v_slider_int_opts(crate::dora::from_string(label), size.into_i64(), stack.raw(), v_min, v_max, crate::dora::from_string(format), crate::dora::Vector::from_str(slider_flags)) != 0; }
	}
	pub fn _color_edit3(label: &str, stack: &crate::dora::CallStack) -> bool {
		unsafe { return imgui__color_edit3(crate::dora::from_string(label), stack.raw()) != 0; }
	}
	pub fn _color_edit4(label: &str, stack: &crate::dora::CallStack, show_alpha: bool) -> bool {
		unsafe { return imgui__color_edit4(crate::dora::from_string(label), stack.raw(), if show_alpha { 1 } else { 0 }) != 0; }
	}
}