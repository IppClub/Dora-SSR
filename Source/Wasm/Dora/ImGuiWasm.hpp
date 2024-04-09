/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static void imgui_load_font_ttf_async(int64_t ttf_font_file, float font_size, int64_t glyph_ranges, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	ImGui::Binding::LoadFontTTFAsync(*str_from(ttf_font_file), font_size, *str_from(glyph_ranges), [func, args, deref](bool success) {
		args->clear();
		args->push(success);
		SharedWasmRuntime.invoke(func);
	});
}
static int32_t imgui_is_font_loaded() {
	return ImGui::Binding::IsFontLoaded() ? 1 : 0;
}
static void imgui_show_stats() {
	ImGui::Binding::ShowStats();
}
static void imgui_show_console() {
	ImGui::Binding::ShowConsole();
}
static int32_t imgui__begin_opts(int64_t name, int32_t windows_flags) {
	return ImGui::Binding::Begin(*str_from(name), s_cast<uint32_t>(windows_flags)) ? 1 : 0;
}
static void imgui__end() {
	ImGui::End();
}
static int32_t imgui__begin_child_opts(int64_t str_id, int64_t size, int32_t child_flags, int32_t window_flags) {
	return ImGui::Binding::BeginChild(*str_from(str_id), vec2_from(size), s_cast<uint32_t>(child_flags), s_cast<uint32_t>(window_flags)) ? 1 : 0;
}
static int32_t imgui__begin_child_with_id_opts(int32_t id, int64_t size, int32_t child_flags, int32_t window_flags) {
	return ImGui::Binding::BeginChild(s_cast<uint32_t>(id), vec2_from(size), s_cast<uint32_t>(child_flags), s_cast<uint32_t>(window_flags)) ? 1 : 0;
}
static void imgui__end_child() {
	ImGui::EndChild();
}
static void imgui__set_next_window_pos_center_opts(int32_t set_cond) {
	ImGui::Binding::SetNextWindowPosCenter(s_cast<uint32_t>(set_cond));
}
static void imgui__set_next_window_size_opts(int64_t size, int32_t set_cond) {
	ImGui::SetNextWindowSize(vec2_from(size), s_cast<uint32_t>(set_cond));
}
static void imgui__set_next_window_collapsed_opts(int32_t collapsed, int32_t set_cond) {
	ImGui::SetNextWindowCollapsed(collapsed != 0, s_cast<uint32_t>(set_cond));
}
static void imgui__set_window_pos_opts(int64_t name, int64_t pos, int32_t set_cond) {
	ImGui::Binding::SetWindowPos(*str_from(name), vec2_from(pos), s_cast<uint32_t>(set_cond));
}
static void imgui__set_window_size_opts(int64_t name, int64_t size, int32_t set_cond) {
	ImGui::Binding::SetWindowSize(*str_from(name), vec2_from(size), s_cast<uint32_t>(set_cond));
}
static void imgui__set_window_collapsed_opts(int64_t name, int32_t collapsed, int32_t set_cond) {
	ImGui::Binding::SetWindowCollapsed(*str_from(name), collapsed != 0, s_cast<uint32_t>(set_cond));
}
static void imgui__set_color_edit_options(int32_t color_edit_flags) {
	ImGui::SetColorEditOptions(s_cast<uint32_t>(color_edit_flags));
}
static int32_t imgui__input_text_opts(int64_t label, int64_t buffer, int32_t input_text_flags) {
	return ImGui::Binding::InputText(*str_from(label), r_cast<Buffer*>(buffer), s_cast<uint32_t>(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__input_text_multiline_opts(int64_t label, int64_t buffer, int64_t size, int32_t input_text_flags) {
	return ImGui::Binding::InputTextMultiline(*str_from(label), r_cast<Buffer*>(buffer), vec2_from(size), s_cast<uint32_t>(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__tree_node_ex_opts(int64_t label, int32_t tree_node_flags) {
	return ImGui::Binding::TreeNodeEx(*str_from(label), s_cast<uint32_t>(tree_node_flags)) ? 1 : 0;
}
static int32_t imgui__tree_node_ex_with_id_opts(int64_t str_id, int64_t text, int32_t tree_node_flags) {
	return ImGui::Binding::TreeNodeEx(*str_from(str_id), *str_from(text), s_cast<uint32_t>(tree_node_flags)) ? 1 : 0;
}
static void imgui__set_next_item_open_opts(int32_t is_open, int32_t set_cond) {
	ImGui::SetNextItemOpen(is_open != 0, s_cast<uint32_t>(set_cond));
}
static int32_t imgui__collapsing_header_opts(int64_t label, int32_t tree_node_flags) {
	return ImGui::Binding::CollapsingHeader(*str_from(label), s_cast<uint32_t>(tree_node_flags)) ? 1 : 0;
}
static int32_t imgui__selectable_opts(int64_t label, int32_t selectable_flags) {
	return ImGui::Binding::Selectable(*str_from(label), s_cast<uint32_t>(selectable_flags)) ? 1 : 0;
}
static int32_t imgui__begin_popup_modal_opts(int64_t name, int32_t windows_flags) {
	return ImGui::Binding::BeginPopupModal(*str_from(name), s_cast<uint32_t>(windows_flags)) ? 1 : 0;
}
static int32_t imgui__begin_popup_modal_ret_opts(int64_t name, int64_t stack, int32_t windows_flags) {
	return ImGui::Binding::BeginPopupModal(*str_from(name), r_cast<CallStack*>(stack), s_cast<uint32_t>(windows_flags)) ? 1 : 0;
}
static int32_t imgui__begin_popup_context_item_opts(int64_t name, int32_t popup_flags) {
	return ImGui::Binding::BeginPopupContextItem(*str_from(name), s_cast<uint32_t>(popup_flags)) ? 1 : 0;
}
static int32_t imgui__begin_popup_context_window_opts(int64_t name, int32_t popup_flags) {
	return ImGui::Binding::BeginPopupContextWindow(*str_from(name), s_cast<uint32_t>(popup_flags)) ? 1 : 0;
}
static int32_t imgui__begin_popup_context_void_opts(int64_t name, int32_t popup_flags) {
	return ImGui::Binding::BeginPopupContextVoid(*str_from(name), s_cast<uint32_t>(popup_flags)) ? 1 : 0;
}
static void imgui__push_style_color(int32_t name, int32_t color) {
	ImGui::Binding::PushStyleColor(s_cast<uint32_t>(name), Color(s_cast<uint32_t>(color)));
}
static void imgui__push_style_float(int32_t name, float val) {
	ImGui::PushStyleVar(s_cast<uint32_t>(name), val);
}
static void imgui__push_style_vec2(int32_t name, int64_t val) {
	ImGui::PushStyleVar(s_cast<uint32_t>(name), vec2_from(val));
}
static void imgui_text(int64_t text) {
	ImGui::Binding::Text(*str_from(text));
}
static void imgui_text_colored(int32_t color, int64_t text) {
	ImGui::Binding::TextColored(Color(s_cast<uint32_t>(color)), *str_from(text));
}
static void imgui_text_disabled(int64_t text) {
	ImGui::Binding::TextDisabled(*str_from(text));
}
static void imgui_text_wrapped(int64_t text) {
	ImGui::Binding::TextWrapped(*str_from(text));
}
static void imgui_label_text(int64_t label, int64_t text) {
	ImGui::Binding::LabelText(*str_from(label), *str_from(text));
}
static void imgui_bullet_text(int64_t text) {
	ImGui::Binding::BulletText(*str_from(text));
}
static int32_t imgui__tree_node(int64_t str_id, int64_t text) {
	return ImGui::Binding::TreeNode(*str_from(str_id), *str_from(text)) ? 1 : 0;
}
static void imgui_set_tooltip(int64_t text) {
	ImGui::Binding::SetTooltip(*str_from(text));
}
static void imgui_image_opts(int64_t clip_str, int64_t size, int32_t tint_col, int32_t border_col) {
	ImGui::Binding::Image(*str_from(clip_str), vec2_from(size), Color(s_cast<uint32_t>(tint_col)), Color(s_cast<uint32_t>(border_col)));
}
static int32_t imgui_image_button_opts(int64_t str_id, int64_t clip_str, int64_t size, int32_t bg_col, int32_t tint_col) {
	return ImGui::Binding::ImageButton(*str_from(str_id), *str_from(clip_str), vec2_from(size), Color(s_cast<uint32_t>(bg_col)), Color(s_cast<uint32_t>(tint_col))) ? 1 : 0;
}
static int32_t imgui__color_button_opts(int64_t desc_id, int32_t col, int32_t color_edit_flags, int64_t size) {
	return ImGui::Binding::ColorButton(*str_from(desc_id), Color(s_cast<uint32_t>(col)), s_cast<uint32_t>(color_edit_flags), vec2_from(size)) ? 1 : 0;
}
static void imgui_columns(int32_t count) {
	ImGui::Binding::Columns(s_cast<int>(count));
}
static void imgui_columns_opts(int32_t count, int32_t border, int64_t str_id) {
	ImGui::Binding::Columns(s_cast<int>(count), border != 0, *str_from(str_id));
}
static int32_t imgui__begin_table_opts(int64_t str_id, int32_t column, int64_t outer_size, float inner_width, int32_t table_flags) {
	return ImGui::Binding::BeginTable(*str_from(str_id), s_cast<int>(column), vec2_from(outer_size), inner_width, s_cast<uint32_t>(table_flags)) ? 1 : 0;
}
static void imgui__table_next_row_opts(float min_row_height, int32_t table_row_flag) {
	ImGui::TableNextRow(min_row_height, s_cast<uint32_t>(table_row_flag));
}
static void imgui__table_setup_column_opts(int64_t label, float init_width_or_weight, int32_t user_id, int32_t table_column_flags) {
	ImGui::Binding::TableSetupColumn(*str_from(label), init_width_or_weight, s_cast<uint32_t>(user_id), s_cast<uint32_t>(table_column_flags));
}
static void imgui_set_style_bool(int64_t name, int32_t var) {
	ImGui::Binding::SetStyleVar(*str_from(name), var != 0);
}
static void imgui_set_style_float(int64_t name, float var) {
	ImGui::Binding::SetStyleVar(*str_from(name), var);
}
static void imgui_set_style_vec2(int64_t name, int64_t var) {
	ImGui::Binding::SetStyleVar(*str_from(name), vec2_from(var));
}
static void imgui_set_style_color(int64_t name, int32_t color) {
	ImGui::Binding::SetStyleColor(*str_from(name), Color(s_cast<uint32_t>(color)));
}
static int32_t imgui__begin_ret_opts(int64_t name, int64_t stack, int32_t windows_flags) {
	return ImGui::Binding::Begin(*str_from(name), r_cast<CallStack*>(stack), s_cast<uint32_t>(windows_flags)) ? 1 : 0;
}
static int32_t imgui__collapsing_header_ret_opts(int64_t label, int64_t stack, int32_t tree_node_flags) {
	return ImGui::Binding::CollapsingHeader(*str_from(label), r_cast<CallStack*>(stack), s_cast<uint32_t>(tree_node_flags)) ? 1 : 0;
}
static int32_t imgui__selectable_ret_opts(int64_t label, int64_t stack, int64_t size, int32_t selectable_flags) {
	return ImGui::Binding::Selectable(*str_from(label), r_cast<CallStack*>(stack), vec2_from(size), s_cast<uint32_t>(selectable_flags)) ? 1 : 0;
}
static int32_t imgui__combo_ret_opts(int64_t label, int64_t stack, int64_t items, int32_t height_in_items) {
	return ImGui::Binding::Combo(*str_from(label), r_cast<CallStack*>(stack), from_str_vec(items), s_cast<int>(height_in_items)) ? 1 : 0;
}
static int32_t imgui__drag_float_ret_opts(int64_t label, int64_t stack, float v_speed, float v_min, float v_max, int64_t display_format, int32_t slider_flags) {
	return ImGui::Binding::DragFloat(*str_from(label), r_cast<CallStack*>(stack), v_speed, v_min, v_max, *str_from(display_format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_float2_ret_opts(int64_t label, int64_t stack, float v_speed, float v_min, float v_max, int64_t display_format, int32_t slider_flags) {
	return ImGui::Binding::DragFloat2(*str_from(label), r_cast<CallStack*>(stack), v_speed, v_min, v_max, *str_from(display_format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_int_ret_opts(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max, int64_t display_format, int32_t slider_flags) {
	return ImGui::Binding::DragInt(*str_from(label), r_cast<CallStack*>(stack), v_speed, s_cast<int>(v_min), s_cast<int>(v_max), *str_from(display_format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_int2_ret_opts(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max, int64_t display_format, int32_t slider_flags) {
	return ImGui::Binding::DragInt2(*str_from(label), r_cast<CallStack*>(stack), v_speed, s_cast<int>(v_min), s_cast<int>(v_max), *str_from(display_format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__input_float_ret_opts(int64_t label, int64_t stack, float step, float step_fast, int64_t display_format, int32_t input_text_flags) {
	return ImGui::Binding::InputFloat(*str_from(label), r_cast<CallStack*>(stack), step, step_fast, *str_from(display_format), s_cast<uint32_t>(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__input_float2_ret_opts(int64_t label, int64_t stack, int64_t display_format, int32_t input_text_flags) {
	return ImGui::Binding::InputFloat2(*str_from(label), r_cast<CallStack*>(stack), *str_from(display_format), s_cast<uint32_t>(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__input_int_ret_opts(int64_t label, int64_t stack, int32_t step, int32_t step_fast, int32_t input_text_flags) {
	return ImGui::Binding::InputInt(*str_from(label), r_cast<CallStack*>(stack), s_cast<int>(step), s_cast<int>(step_fast), s_cast<uint32_t>(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__input_int2_ret_opts(int64_t label, int64_t stack, int32_t input_text_flags) {
	return ImGui::Binding::InputInt2(*str_from(label), r_cast<CallStack*>(stack), s_cast<uint32_t>(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__slider_float_ret_opts(int64_t label, int64_t stack, float v_min, float v_max, int64_t display_format, int32_t slider_flags) {
	return ImGui::Binding::SliderFloat(*str_from(label), r_cast<CallStack*>(stack), v_min, v_max, *str_from(display_format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__slider_float2_ret_opts(int64_t label, int64_t stack, float v_min, float v_max, int64_t display_format, int32_t slider_flags) {
	return ImGui::Binding::SliderFloat2(*str_from(label), r_cast<CallStack*>(stack), v_min, v_max, *str_from(display_format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__slider_int_ret_opts(int64_t label, int64_t stack, int32_t v_min, int32_t v_max, int64_t format, int32_t slider_flags) {
	return ImGui::Binding::SliderInt(*str_from(label), r_cast<CallStack*>(stack), s_cast<int>(v_min), s_cast<int>(v_max), *str_from(format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__slider_int2_ret_opts(int64_t label, int64_t stack, int32_t v_min, int32_t v_max, int64_t display_format, int32_t slider_flags) {
	return ImGui::Binding::SliderInt2(*str_from(label), r_cast<CallStack*>(stack), s_cast<int>(v_min), s_cast<int>(v_max), *str_from(display_format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_float_range2_ret_opts(int64_t label, int64_t stack, float v_speed, float v_min, float v_max, int64_t format, int64_t format_max, int32_t slider_flags) {
	return ImGui::Binding::DragFloatRange2(*str_from(label), r_cast<CallStack*>(stack), v_speed, v_min, v_max, *str_from(format), *str_from(format_max), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_int_range2_ret_opts(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max, int64_t format, int64_t format_max, int32_t slider_flags) {
	return ImGui::Binding::DragIntRange2(*str_from(label), r_cast<CallStack*>(stack), v_speed, s_cast<int>(v_min), s_cast<int>(v_max), *str_from(format), *str_from(format_max), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__v_slider_float_ret_opts(int64_t label, int64_t size, int64_t stack, float v_min, float v_max, int64_t format, int32_t slider_flags) {
	return ImGui::Binding::VSliderFloat(*str_from(label), vec2_from(size), r_cast<CallStack*>(stack), v_min, v_max, *str_from(format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__v_slider_int_ret_opts(int64_t label, int64_t size, int64_t stack, int32_t v_min, int32_t v_max, int64_t format, int32_t slider_flags) {
	return ImGui::Binding::VSliderInt(*str_from(label), vec2_from(size), r_cast<CallStack*>(stack), s_cast<int>(v_min), s_cast<int>(v_max), *str_from(format), s_cast<uint32_t>(slider_flags)) ? 1 : 0;
}
static int32_t imgui__color_edit3_ret_opts(int64_t label, int64_t stack, int32_t color_edit_flags) {
	return ImGui::Binding::ColorEdit3(*str_from(label), r_cast<CallStack*>(stack), s_cast<uint32_t>(color_edit_flags)) ? 1 : 0;
}
static int32_t imgui__color_edit4_ret_opts(int64_t label, int64_t stack, int32_t color_edit_flags) {
	return ImGui::Binding::ColorEdit4(*str_from(label), r_cast<CallStack*>(stack), s_cast<uint32_t>(color_edit_flags)) ? 1 : 0;
}
static void imgui_scroll_when_dragging_on_void() {
	ImGui::Binding::ScrollWhenDraggingOnVoid();
}
static void imgui__set_next_window_pos_opts(int64_t pos, int32_t set_cond, int64_t pivot) {
	ImGui::SetNextWindowPos(vec2_from(pos), s_cast<uint32_t>(set_cond), vec2_from(pivot));
}
static void imgui_set_next_window_bg_alpha(float alpha) {
	ImGui::SetNextWindowBgAlpha(alpha);
}
static void imgui_show_demo_window() {
	ImGui::ShowDemoWindow();
}
static int64_t imgui_get_content_region_max() {
	return vec2_retain(ImGui::GetContentRegionMax());
}
static int64_t imgui_get_content_region_avail() {
	return vec2_retain(ImGui::GetContentRegionAvail());
}
static int64_t imgui_get_window_content_region_min() {
	return vec2_retain(ImGui::GetWindowContentRegionMin());
}
static int64_t imgui_get_window_content_region_max() {
	return vec2_retain(ImGui::GetWindowContentRegionMax());
}
static int64_t imgui_get_window_pos() {
	return vec2_retain(ImGui::GetWindowPos());
}
static int64_t imgui_get_window_size() {
	return vec2_retain(ImGui::GetWindowSize());
}
static float imgui_get_window_width() {
	return ImGui::GetWindowWidth();
}
static float imgui_get_window_height() {
	return ImGui::GetWindowHeight();
}
static int32_t imgui_is_window_collapsed() {
	return ImGui::IsWindowCollapsed() ? 1 : 0;
}
static void imgui_set_window_font_scale(float scale) {
	ImGui::SetWindowFontScale(scale);
}
static void imgui_set_next_window_size_constraints(int64_t size_min, int64_t size_max) {
	ImGui::SetNextWindowSizeConstraints(vec2_from(size_min), vec2_from(size_max));
}
static void imgui_set_next_window_content_size(int64_t size) {
	ImGui::SetNextWindowContentSize(vec2_from(size));
}
static void imgui_set_next_window_focus() {
	ImGui::SetNextWindowFocus();
}
static float imgui_get_scroll_x() {
	return ImGui::GetScrollX();
}
static float imgui_get_scroll_y() {
	return ImGui::GetScrollY();
}
static float imgui_get_scroll_max_x() {
	return ImGui::GetScrollMaxX();
}
static float imgui_get_scroll_max_y() {
	return ImGui::GetScrollMaxY();
}
static void imgui_set_scroll_x(float scroll_x) {
	ImGui::SetScrollX(scroll_x);
}
static void imgui_set_scroll_y(float scroll_y) {
	ImGui::SetScrollY(scroll_y);
}
static void imgui_set_scroll_here_y(float center_y_ratio) {
	ImGui::SetScrollHereY(center_y_ratio);
}
static void imgui_set_scroll_from_pos_y(float pos_y, float center_y_ratio) {
	ImGui::SetScrollFromPosY(pos_y, center_y_ratio);
}
static void imgui_set_keyboard_focus_here(int32_t offset) {
	ImGui::SetKeyboardFocusHere(s_cast<int>(offset));
}
static void imgui__pop_style_color(int32_t count) {
	ImGui::PopStyleColor(s_cast<int>(count));
}
static void imgui__pop_style_var(int32_t count) {
	ImGui::PopStyleVar(s_cast<int>(count));
}
static void imgui_set_next_item_width(float item_width) {
	ImGui::SetNextItemWidth(item_width);
}
static void imgui__push_item_width(float item_width) {
	ImGui::PushItemWidth(item_width);
}
static void imgui__pop_item_width() {
	ImGui::PopItemWidth();
}
static float imgui_calc_item_width() {
	return ImGui::CalcItemWidth();
}
static void imgui__push_text_wrap_pos(float wrap_pos_x) {
	ImGui::PushTextWrapPos(wrap_pos_x);
}
static void imgui__pop_text_wrap_pos() {
	ImGui::PopTextWrapPos();
}
static void imgui__push_tab_stop(int32_t v) {
	ImGui::PushTabStop(v != 0);
}
static void imgui__pop_tab_stop() {
	ImGui::PopTabStop();
}
static void imgui__push_button_repeat(int32_t repeat) {
	ImGui::PushButtonRepeat(repeat != 0);
}
static void imgui__pop_button_repeat() {
	ImGui::PopButtonRepeat();
}
static void imgui_separator() {
	ImGui::Separator();
}
static void imgui_same_line(float pos_x, float spacing_w) {
	ImGui::SameLine(pos_x, spacing_w);
}
static void imgui_new_line() {
	ImGui::NewLine();
}
static void imgui_spacing() {
	ImGui::Spacing();
}
static void imgui_dummy(int64_t size) {
	ImGui::Dummy(vec2_from(size));
}
static void imgui_indent(float indent_w) {
	ImGui::Indent(indent_w);
}
static void imgui_unindent(float indent_w) {
	ImGui::Unindent(indent_w);
}
static void imgui__begin_group() {
	ImGui::BeginGroup();
}
static void imgui__end_group() {
	ImGui::EndGroup();
}
static int64_t imgui_get_cursor_pos() {
	return vec2_retain(ImGui::GetCursorPos());
}
static float imgui_get_cursor_pos_x() {
	return ImGui::GetCursorPosX();
}
static float imgui_get_cursor_pos_y() {
	return ImGui::GetCursorPosY();
}
static void imgui_set_cursor_pos(int64_t local_pos) {
	ImGui::SetCursorPos(vec2_from(local_pos));
}
static void imgui_set_cursor_pos_x(float x) {
	ImGui::SetCursorPosX(x);
}
static void imgui_set_cursor_pos_y(float y) {
	ImGui::SetCursorPosY(y);
}
static int64_t imgui_get_cursor_start_pos() {
	return vec2_retain(ImGui::GetCursorStartPos());
}
static int64_t imgui_get_cursor_screen_pos() {
	return vec2_retain(ImGui::GetCursorScreenPos());
}
static void imgui_set_cursor_screen_pos(int64_t pos) {
	ImGui::SetCursorScreenPos(vec2_from(pos));
}
static void imgui_align_text_to_frame_padding() {
	ImGui::AlignTextToFramePadding();
}
static float imgui_get_text_line_height() {
	return ImGui::GetTextLineHeight();
}
static float imgui_get_text_line_height_with_spacing() {
	return ImGui::GetTextLineHeightWithSpacing();
}
static void imgui_next_column() {
	ImGui::NextColumn();
}
static int32_t imgui_get_column_index() {
	return s_cast<int32_t>(ImGui::GetColumnIndex());
}
static float imgui_get_column_offset(int32_t column_index) {
	return ImGui::GetColumnOffset(s_cast<int>(column_index));
}
static void imgui_set_column_offset(int32_t column_index, float offset_x) {
	ImGui::SetColumnOffset(s_cast<int>(column_index), offset_x);
}
static float imgui_get_column_width(int32_t column_index) {
	return ImGui::GetColumnWidth(s_cast<int>(column_index));
}
static int32_t imgui_get_columns_count() {
	return s_cast<int32_t>(ImGui::GetColumnsCount());
}
static void imgui__end_table() {
	ImGui::EndTable();
}
static int32_t imgui_table_next_column() {
	return ImGui::TableNextColumn() ? 1 : 0;
}
static int32_t imgui_table_set_column_index(int32_t column_n) {
	return ImGui::TableSetColumnIndex(s_cast<int>(column_n)) ? 1 : 0;
}
static void imgui_table_setup_scroll_freeze(int32_t cols, int32_t rows) {
	ImGui::TableSetupScrollFreeze(s_cast<int>(cols), s_cast<int>(rows));
}
static void imgui_table_headers_row() {
	ImGui::TableHeadersRow();
}
static void imgui_bullet_item() {
	ImGui::Bullet();
}
static void imgui_set_window_focus(int64_t name) {
	ImGui::Binding::SetWindowFocus(*str_from(name));
}
static void imgui_separator_text(int64_t text) {
	ImGui::Binding::SeparatorText(*str_from(text));
}
static void imgui_table_header(int64_t label) {
	ImGui::Binding::TableHeader(*str_from(label));
}
static void imgui__push_id(int64_t str_id) {
	ImGui::Binding::PushID(*str_from(str_id));
}
static void imgui__pop_id() {
	ImGui::PopID();
}
static int32_t imgui_get_id(int64_t str_id) {
	return s_cast<int32_t>(ImGui::Binding::GetID(*str_from(str_id)));
}
static int32_t imgui_button(int64_t label, int64_t size) {
	return ImGui::Binding::Button(*str_from(label), vec2_from(size)) ? 1 : 0;
}
static int32_t imgui_small_button(int64_t label) {
	return ImGui::Binding::SmallButton(*str_from(label)) ? 1 : 0;
}
static int32_t imgui_invisible_button(int64_t str_id, int64_t size) {
	return ImGui::Binding::InvisibleButton(*str_from(str_id), vec2_from(size)) ? 1 : 0;
}
static int32_t imgui__checkbox_ret(int64_t label, int64_t stack) {
	return ImGui::Binding::Checkbox(*str_from(label), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__radio_button_ret(int64_t label, int64_t stack, int32_t v_button) {
	return ImGui::Binding::RadioButton(*str_from(label), r_cast<CallStack*>(stack), s_cast<int>(v_button)) ? 1 : 0;
}
static void imgui_plot_lines(int64_t label, int64_t values) {
	ImGui::Binding::PlotLines(*str_from(label), from_float_vec(values));
}
static void imgui_plot_lines_opts(int64_t label, int64_t values, int32_t values_offset, int64_t overlay_text, float scale_min, float scale_max, int64_t graph_size) {
	ImGui::Binding::PlotLines(*str_from(label), from_float_vec(values), s_cast<int>(values_offset), *str_from(overlay_text), scale_min, scale_max, vec2_from(graph_size));
}
static void imgui_plot_histogram(int64_t label, int64_t values) {
	ImGui::Binding::PlotHistogram(*str_from(label), from_float_vec(values));
}
static void imgui_plot_histogram_opts(int64_t label, int64_t values, int32_t values_offset, int64_t overlay_text, float scale_min, float scale_max, int64_t graph_size) {
	ImGui::Binding::PlotHistogram(*str_from(label), from_float_vec(values), s_cast<int>(values_offset), *str_from(overlay_text), scale_min, scale_max, vec2_from(graph_size));
}
static void imgui_progress_bar(float fraction) {
	ImGui::Binding::ProgressBar(fraction);
}
static void imgui_progress_bar_opts(float fraction, int64_t size_arg, int64_t overlay) {
	ImGui::Binding::ProgressBar(fraction, vec2_from(size_arg), *str_from(overlay));
}
static int32_t imgui__list_box_ret_opts(int64_t label, int64_t stack, int64_t items, int32_t height_in_items) {
	return ImGui::Binding::ListBox(*str_from(label), r_cast<CallStack*>(stack), from_str_vec(items), s_cast<int>(height_in_items)) ? 1 : 0;
}
static int32_t imgui__slider_angle_ret(int64_t label, int64_t stack, float v_degrees_min, float v_degrees_max) {
	return ImGui::Binding::SliderAngle(*str_from(label), r_cast<CallStack*>(stack), v_degrees_min, v_degrees_max) ? 1 : 0;
}
static void imgui__tree_push(int64_t str_id) {
	ImGui::Binding::TreePush(*str_from(str_id));
}
static void imgui__tree_pop() {
	ImGui::TreePop();
}
static void imgui_value(int64_t prefix, int32_t b) {
	ImGui::Binding::Value(*str_from(prefix), b != 0);
}
static int32_t imgui_menu_item(int64_t label, int64_t shortcut, int32_t selected, int32_t enabled) {
	return ImGui::Binding::MenuItem(*str_from(label), *str_from(shortcut), selected != 0, enabled != 0) ? 1 : 0;
}
static void imgui_open_popup(int64_t str_id) {
	ImGui::Binding::OpenPopup(*str_from(str_id));
}
static int32_t imgui__begin_popup(int64_t str_id) {
	return ImGui::Binding::BeginPopup(*str_from(str_id)) ? 1 : 0;
}
static void imgui__end_popup() {
	ImGui::EndPopup();
}
static float imgui_get_tree_node_to_label_spacing() {
	return ImGui::GetTreeNodeToLabelSpacing();
}
static int32_t imgui__begin_list_box(int64_t label, int64_t size) {
	return ImGui::Binding::BeginListBox(*str_from(label), vec2_from(size)) ? 1 : 0;
}
static void imgui__end_list_box() {
	ImGui::EndListBox();
}
static void imgui__begin_disabled() {
	ImGui::BeginDisabled();
}
static void imgui__end_disabled() {
	ImGui::EndDisabled();
}
static int32_t imgui__begin_tooltip() {
	return ImGui::BeginTooltip() ? 1 : 0;
}
static void imgui__end_tooltip() {
	ImGui::EndTooltip();
}
static int32_t imgui__begin_main_menu_bar() {
	return ImGui::BeginMainMenuBar() ? 1 : 0;
}
static void imgui__end_main_menu_bar() {
	ImGui::EndMainMenuBar();
}
static int32_t imgui__begin_menu_bar() {
	return ImGui::BeginMenuBar() ? 1 : 0;
}
static void imgui__end_menu_bar() {
	ImGui::EndMenuBar();
}
static int32_t imgui__begin_menu(int64_t label, int32_t enabled) {
	return ImGui::Binding::BeginMenu(*str_from(label), enabled != 0) ? 1 : 0;
}
static void imgui__end_menu() {
	ImGui::EndMenu();
}
static void imgui_close_current_popup() {
	ImGui::CloseCurrentPopup();
}
static void imgui__push_clip_rect(int64_t clip_rect_min, int64_t clip_rect_max, int32_t intersect_with_current_clip_rect) {
	ImGui::PushClipRect(vec2_from(clip_rect_min), vec2_from(clip_rect_max), intersect_with_current_clip_rect != 0);
}
static void imgui__pop_clip_rect() {
	ImGui::PopClipRect();
}
static int32_t imgui_is_item_hovered() {
	return ImGui::IsItemHovered() ? 1 : 0;
}
static int32_t imgui_is_item_active() {
	return ImGui::IsItemActive() ? 1 : 0;
}
static int32_t imgui_is_item_clicked(int32_t mouse_button) {
	return ImGui::IsItemClicked(s_cast<int>(mouse_button)) ? 1 : 0;
}
static int32_t imgui_is_item_visible() {
	return ImGui::IsItemVisible() ? 1 : 0;
}
static int32_t imgui_is_any_item_hovered() {
	return ImGui::IsAnyItemHovered() ? 1 : 0;
}
static int32_t imgui_is_any_item_active() {
	return ImGui::IsAnyItemActive() ? 1 : 0;
}
static int64_t imgui_get_item_rect_min() {
	return vec2_retain(ImGui::GetItemRectMin());
}
static int64_t imgui_get_item_rect_max() {
	return vec2_retain(ImGui::GetItemRectMax());
}
static int64_t imgui_get_item_rect_size() {
	return vec2_retain(ImGui::GetItemRectSize());
}
static void imgui_set_next_item_allow_overlap() {
	ImGui::SetNextItemAllowOverlap();
}
static int32_t imgui_is_window_hovered() {
	return ImGui::IsWindowHovered() ? 1 : 0;
}
static int32_t imgui_is_window_focused() {
	return ImGui::IsWindowFocused() ? 1 : 0;
}
static int32_t imgui_is_rect_visible(int64_t size) {
	return ImGui::IsRectVisible(vec2_from(size)) ? 1 : 0;
}
static int32_t imgui_is_mouse_down(int32_t button) {
	return ImGui::IsMouseDown(s_cast<int>(button)) ? 1 : 0;
}
static int32_t imgui_is_mouse_clicked(int32_t button, int32_t repeat) {
	return ImGui::IsMouseClicked(s_cast<int>(button), repeat != 0) ? 1 : 0;
}
static int32_t imgui_is_mouse_double_clicked(int32_t button) {
	return ImGui::IsMouseDoubleClicked(s_cast<int>(button)) ? 1 : 0;
}
static int32_t imgui_is_mouse_released(int32_t button) {
	return ImGui::IsMouseReleased(s_cast<int>(button)) ? 1 : 0;
}
static int32_t imgui_is_mouse_hovering_rect(int64_t r_min, int64_t r_max, int32_t clip) {
	return ImGui::IsMouseHoveringRect(vec2_from(r_min), vec2_from(r_max), clip != 0) ? 1 : 0;
}
static int32_t imgui_is_mouse_dragging(int32_t button, float lock_threshold) {
	return ImGui::IsMouseDragging(s_cast<int>(button), lock_threshold) ? 1 : 0;
}
static int64_t imgui_get_mouse_pos() {
	return vec2_retain(ImGui::GetMousePos());
}
static int64_t imgui_get_mouse_pos_on_opening_current_popup() {
	return vec2_retain(ImGui::GetMousePosOnOpeningCurrentPopup());
}
static int64_t imgui_get_mouse_drag_delta(int32_t button, float lock_threshold) {
	return vec2_retain(ImGui::GetMouseDragDelta(s_cast<int>(button), lock_threshold));
}
static void imgui_reset_mouse_drag_delta(int32_t button) {
	ImGui::ResetMouseDragDelta(s_cast<int>(button));
}
static void linkImGui(wasm3::module3& mod) {
	mod.link_optional("*", "imgui_load_font_ttf_async", imgui_load_font_ttf_async);
	mod.link_optional("*", "imgui_is_font_loaded", imgui_is_font_loaded);
	mod.link_optional("*", "imgui_show_stats", imgui_show_stats);
	mod.link_optional("*", "imgui_show_console", imgui_show_console);
	mod.link_optional("*", "imgui__begin_opts", imgui__begin_opts);
	mod.link_optional("*", "imgui__end", imgui__end);
	mod.link_optional("*", "imgui__begin_child_opts", imgui__begin_child_opts);
	mod.link_optional("*", "imgui__begin_child_with_id_opts", imgui__begin_child_with_id_opts);
	mod.link_optional("*", "imgui__end_child", imgui__end_child);
	mod.link_optional("*", "imgui__set_next_window_pos_center_opts", imgui__set_next_window_pos_center_opts);
	mod.link_optional("*", "imgui__set_next_window_size_opts", imgui__set_next_window_size_opts);
	mod.link_optional("*", "imgui__set_next_window_collapsed_opts", imgui__set_next_window_collapsed_opts);
	mod.link_optional("*", "imgui__set_window_pos_opts", imgui__set_window_pos_opts);
	mod.link_optional("*", "imgui__set_window_size_opts", imgui__set_window_size_opts);
	mod.link_optional("*", "imgui__set_window_collapsed_opts", imgui__set_window_collapsed_opts);
	mod.link_optional("*", "imgui__set_color_edit_options", imgui__set_color_edit_options);
	mod.link_optional("*", "imgui__input_text_opts", imgui__input_text_opts);
	mod.link_optional("*", "imgui__input_text_multiline_opts", imgui__input_text_multiline_opts);
	mod.link_optional("*", "imgui__tree_node_ex_opts", imgui__tree_node_ex_opts);
	mod.link_optional("*", "imgui__tree_node_ex_with_id_opts", imgui__tree_node_ex_with_id_opts);
	mod.link_optional("*", "imgui__set_next_item_open_opts", imgui__set_next_item_open_opts);
	mod.link_optional("*", "imgui__collapsing_header_opts", imgui__collapsing_header_opts);
	mod.link_optional("*", "imgui__selectable_opts", imgui__selectable_opts);
	mod.link_optional("*", "imgui__begin_popup_modal_opts", imgui__begin_popup_modal_opts);
	mod.link_optional("*", "imgui__begin_popup_modal_ret_opts", imgui__begin_popup_modal_ret_opts);
	mod.link_optional("*", "imgui__begin_popup_context_item_opts", imgui__begin_popup_context_item_opts);
	mod.link_optional("*", "imgui__begin_popup_context_window_opts", imgui__begin_popup_context_window_opts);
	mod.link_optional("*", "imgui__begin_popup_context_void_opts", imgui__begin_popup_context_void_opts);
	mod.link_optional("*", "imgui__push_style_color", imgui__push_style_color);
	mod.link_optional("*", "imgui__push_style_float", imgui__push_style_float);
	mod.link_optional("*", "imgui__push_style_vec2", imgui__push_style_vec2);
	mod.link_optional("*", "imgui_text", imgui_text);
	mod.link_optional("*", "imgui_text_colored", imgui_text_colored);
	mod.link_optional("*", "imgui_text_disabled", imgui_text_disabled);
	mod.link_optional("*", "imgui_text_wrapped", imgui_text_wrapped);
	mod.link_optional("*", "imgui_label_text", imgui_label_text);
	mod.link_optional("*", "imgui_bullet_text", imgui_bullet_text);
	mod.link_optional("*", "imgui__tree_node", imgui__tree_node);
	mod.link_optional("*", "imgui_set_tooltip", imgui_set_tooltip);
	mod.link_optional("*", "imgui_image_opts", imgui_image_opts);
	mod.link_optional("*", "imgui_image_button_opts", imgui_image_button_opts);
	mod.link_optional("*", "imgui__color_button_opts", imgui__color_button_opts);
	mod.link_optional("*", "imgui_columns", imgui_columns);
	mod.link_optional("*", "imgui_columns_opts", imgui_columns_opts);
	mod.link_optional("*", "imgui__begin_table_opts", imgui__begin_table_opts);
	mod.link_optional("*", "imgui__table_next_row_opts", imgui__table_next_row_opts);
	mod.link_optional("*", "imgui__table_setup_column_opts", imgui__table_setup_column_opts);
	mod.link_optional("*", "imgui_set_style_bool", imgui_set_style_bool);
	mod.link_optional("*", "imgui_set_style_float", imgui_set_style_float);
	mod.link_optional("*", "imgui_set_style_vec2", imgui_set_style_vec2);
	mod.link_optional("*", "imgui_set_style_color", imgui_set_style_color);
	mod.link_optional("*", "imgui__begin_ret_opts", imgui__begin_ret_opts);
	mod.link_optional("*", "imgui__collapsing_header_ret_opts", imgui__collapsing_header_ret_opts);
	mod.link_optional("*", "imgui__selectable_ret_opts", imgui__selectable_ret_opts);
	mod.link_optional("*", "imgui__combo_ret_opts", imgui__combo_ret_opts);
	mod.link_optional("*", "imgui__drag_float_ret_opts", imgui__drag_float_ret_opts);
	mod.link_optional("*", "imgui__drag_float2_ret_opts", imgui__drag_float2_ret_opts);
	mod.link_optional("*", "imgui__drag_int_ret_opts", imgui__drag_int_ret_opts);
	mod.link_optional("*", "imgui__drag_int2_ret_opts", imgui__drag_int2_ret_opts);
	mod.link_optional("*", "imgui__input_float_ret_opts", imgui__input_float_ret_opts);
	mod.link_optional("*", "imgui__input_float2_ret_opts", imgui__input_float2_ret_opts);
	mod.link_optional("*", "imgui__input_int_ret_opts", imgui__input_int_ret_opts);
	mod.link_optional("*", "imgui__input_int2_ret_opts", imgui__input_int2_ret_opts);
	mod.link_optional("*", "imgui__slider_float_ret_opts", imgui__slider_float_ret_opts);
	mod.link_optional("*", "imgui__slider_float2_ret_opts", imgui__slider_float2_ret_opts);
	mod.link_optional("*", "imgui__slider_int_ret_opts", imgui__slider_int_ret_opts);
	mod.link_optional("*", "imgui__slider_int2_ret_opts", imgui__slider_int2_ret_opts);
	mod.link_optional("*", "imgui__drag_float_range2_ret_opts", imgui__drag_float_range2_ret_opts);
	mod.link_optional("*", "imgui__drag_int_range2_ret_opts", imgui__drag_int_range2_ret_opts);
	mod.link_optional("*", "imgui__v_slider_float_ret_opts", imgui__v_slider_float_ret_opts);
	mod.link_optional("*", "imgui__v_slider_int_ret_opts", imgui__v_slider_int_ret_opts);
	mod.link_optional("*", "imgui__color_edit3_ret_opts", imgui__color_edit3_ret_opts);
	mod.link_optional("*", "imgui__color_edit4_ret_opts", imgui__color_edit4_ret_opts);
	mod.link_optional("*", "imgui_scroll_when_dragging_on_void", imgui_scroll_when_dragging_on_void);
	mod.link_optional("*", "imgui__set_next_window_pos_opts", imgui__set_next_window_pos_opts);
	mod.link_optional("*", "imgui_set_next_window_bg_alpha", imgui_set_next_window_bg_alpha);
	mod.link_optional("*", "imgui_show_demo_window", imgui_show_demo_window);
	mod.link_optional("*", "imgui_get_content_region_max", imgui_get_content_region_max);
	mod.link_optional("*", "imgui_get_content_region_avail", imgui_get_content_region_avail);
	mod.link_optional("*", "imgui_get_window_content_region_min", imgui_get_window_content_region_min);
	mod.link_optional("*", "imgui_get_window_content_region_max", imgui_get_window_content_region_max);
	mod.link_optional("*", "imgui_get_window_pos", imgui_get_window_pos);
	mod.link_optional("*", "imgui_get_window_size", imgui_get_window_size);
	mod.link_optional("*", "imgui_get_window_width", imgui_get_window_width);
	mod.link_optional("*", "imgui_get_window_height", imgui_get_window_height);
	mod.link_optional("*", "imgui_is_window_collapsed", imgui_is_window_collapsed);
	mod.link_optional("*", "imgui_set_window_font_scale", imgui_set_window_font_scale);
	mod.link_optional("*", "imgui_set_next_window_size_constraints", imgui_set_next_window_size_constraints);
	mod.link_optional("*", "imgui_set_next_window_content_size", imgui_set_next_window_content_size);
	mod.link_optional("*", "imgui_set_next_window_focus", imgui_set_next_window_focus);
	mod.link_optional("*", "imgui_get_scroll_x", imgui_get_scroll_x);
	mod.link_optional("*", "imgui_get_scroll_y", imgui_get_scroll_y);
	mod.link_optional("*", "imgui_get_scroll_max_x", imgui_get_scroll_max_x);
	mod.link_optional("*", "imgui_get_scroll_max_y", imgui_get_scroll_max_y);
	mod.link_optional("*", "imgui_set_scroll_x", imgui_set_scroll_x);
	mod.link_optional("*", "imgui_set_scroll_y", imgui_set_scroll_y);
	mod.link_optional("*", "imgui_set_scroll_here_y", imgui_set_scroll_here_y);
	mod.link_optional("*", "imgui_set_scroll_from_pos_y", imgui_set_scroll_from_pos_y);
	mod.link_optional("*", "imgui_set_keyboard_focus_here", imgui_set_keyboard_focus_here);
	mod.link_optional("*", "imgui__pop_style_color", imgui__pop_style_color);
	mod.link_optional("*", "imgui__pop_style_var", imgui__pop_style_var);
	mod.link_optional("*", "imgui_set_next_item_width", imgui_set_next_item_width);
	mod.link_optional("*", "imgui__push_item_width", imgui__push_item_width);
	mod.link_optional("*", "imgui__pop_item_width", imgui__pop_item_width);
	mod.link_optional("*", "imgui_calc_item_width", imgui_calc_item_width);
	mod.link_optional("*", "imgui__push_text_wrap_pos", imgui__push_text_wrap_pos);
	mod.link_optional("*", "imgui__pop_text_wrap_pos", imgui__pop_text_wrap_pos);
	mod.link_optional("*", "imgui__push_tab_stop", imgui__push_tab_stop);
	mod.link_optional("*", "imgui__pop_tab_stop", imgui__pop_tab_stop);
	mod.link_optional("*", "imgui__push_button_repeat", imgui__push_button_repeat);
	mod.link_optional("*", "imgui__pop_button_repeat", imgui__pop_button_repeat);
	mod.link_optional("*", "imgui_separator", imgui_separator);
	mod.link_optional("*", "imgui_same_line", imgui_same_line);
	mod.link_optional("*", "imgui_new_line", imgui_new_line);
	mod.link_optional("*", "imgui_spacing", imgui_spacing);
	mod.link_optional("*", "imgui_dummy", imgui_dummy);
	mod.link_optional("*", "imgui_indent", imgui_indent);
	mod.link_optional("*", "imgui_unindent", imgui_unindent);
	mod.link_optional("*", "imgui__begin_group", imgui__begin_group);
	mod.link_optional("*", "imgui__end_group", imgui__end_group);
	mod.link_optional("*", "imgui_get_cursor_pos", imgui_get_cursor_pos);
	mod.link_optional("*", "imgui_get_cursor_pos_x", imgui_get_cursor_pos_x);
	mod.link_optional("*", "imgui_get_cursor_pos_y", imgui_get_cursor_pos_y);
	mod.link_optional("*", "imgui_set_cursor_pos", imgui_set_cursor_pos);
	mod.link_optional("*", "imgui_set_cursor_pos_x", imgui_set_cursor_pos_x);
	mod.link_optional("*", "imgui_set_cursor_pos_y", imgui_set_cursor_pos_y);
	mod.link_optional("*", "imgui_get_cursor_start_pos", imgui_get_cursor_start_pos);
	mod.link_optional("*", "imgui_get_cursor_screen_pos", imgui_get_cursor_screen_pos);
	mod.link_optional("*", "imgui_set_cursor_screen_pos", imgui_set_cursor_screen_pos);
	mod.link_optional("*", "imgui_align_text_to_frame_padding", imgui_align_text_to_frame_padding);
	mod.link_optional("*", "imgui_get_text_line_height", imgui_get_text_line_height);
	mod.link_optional("*", "imgui_get_text_line_height_with_spacing", imgui_get_text_line_height_with_spacing);
	mod.link_optional("*", "imgui_next_column", imgui_next_column);
	mod.link_optional("*", "imgui_get_column_index", imgui_get_column_index);
	mod.link_optional("*", "imgui_get_column_offset", imgui_get_column_offset);
	mod.link_optional("*", "imgui_set_column_offset", imgui_set_column_offset);
	mod.link_optional("*", "imgui_get_column_width", imgui_get_column_width);
	mod.link_optional("*", "imgui_get_columns_count", imgui_get_columns_count);
	mod.link_optional("*", "imgui__end_table", imgui__end_table);
	mod.link_optional("*", "imgui_table_next_column", imgui_table_next_column);
	mod.link_optional("*", "imgui_table_set_column_index", imgui_table_set_column_index);
	mod.link_optional("*", "imgui_table_setup_scroll_freeze", imgui_table_setup_scroll_freeze);
	mod.link_optional("*", "imgui_table_headers_row", imgui_table_headers_row);
	mod.link_optional("*", "imgui_bullet_item", imgui_bullet_item);
	mod.link_optional("*", "imgui_set_window_focus", imgui_set_window_focus);
	mod.link_optional("*", "imgui_separator_text", imgui_separator_text);
	mod.link_optional("*", "imgui_table_header", imgui_table_header);
	mod.link_optional("*", "imgui__push_id", imgui__push_id);
	mod.link_optional("*", "imgui__pop_id", imgui__pop_id);
	mod.link_optional("*", "imgui_get_id", imgui_get_id);
	mod.link_optional("*", "imgui_button", imgui_button);
	mod.link_optional("*", "imgui_small_button", imgui_small_button);
	mod.link_optional("*", "imgui_invisible_button", imgui_invisible_button);
	mod.link_optional("*", "imgui__checkbox_ret", imgui__checkbox_ret);
	mod.link_optional("*", "imgui__radio_button_ret", imgui__radio_button_ret);
	mod.link_optional("*", "imgui_plot_lines", imgui_plot_lines);
	mod.link_optional("*", "imgui_plot_lines_opts", imgui_plot_lines_opts);
	mod.link_optional("*", "imgui_plot_histogram", imgui_plot_histogram);
	mod.link_optional("*", "imgui_plot_histogram_opts", imgui_plot_histogram_opts);
	mod.link_optional("*", "imgui_progress_bar", imgui_progress_bar);
	mod.link_optional("*", "imgui_progress_bar_opts", imgui_progress_bar_opts);
	mod.link_optional("*", "imgui__list_box_ret_opts", imgui__list_box_ret_opts);
	mod.link_optional("*", "imgui__slider_angle_ret", imgui__slider_angle_ret);
	mod.link_optional("*", "imgui__tree_push", imgui__tree_push);
	mod.link_optional("*", "imgui__tree_pop", imgui__tree_pop);
	mod.link_optional("*", "imgui_value", imgui_value);
	mod.link_optional("*", "imgui_menu_item", imgui_menu_item);
	mod.link_optional("*", "imgui_open_popup", imgui_open_popup);
	mod.link_optional("*", "imgui__begin_popup", imgui__begin_popup);
	mod.link_optional("*", "imgui__end_popup", imgui__end_popup);
	mod.link_optional("*", "imgui_get_tree_node_to_label_spacing", imgui_get_tree_node_to_label_spacing);
	mod.link_optional("*", "imgui__begin_list_box", imgui__begin_list_box);
	mod.link_optional("*", "imgui__end_list_box", imgui__end_list_box);
	mod.link_optional("*", "imgui__begin_disabled", imgui__begin_disabled);
	mod.link_optional("*", "imgui__end_disabled", imgui__end_disabled);
	mod.link_optional("*", "imgui__begin_tooltip", imgui__begin_tooltip);
	mod.link_optional("*", "imgui__end_tooltip", imgui__end_tooltip);
	mod.link_optional("*", "imgui__begin_main_menu_bar", imgui__begin_main_menu_bar);
	mod.link_optional("*", "imgui__end_main_menu_bar", imgui__end_main_menu_bar);
	mod.link_optional("*", "imgui__begin_menu_bar", imgui__begin_menu_bar);
	mod.link_optional("*", "imgui__end_menu_bar", imgui__end_menu_bar);
	mod.link_optional("*", "imgui__begin_menu", imgui__begin_menu);
	mod.link_optional("*", "imgui__end_menu", imgui__end_menu);
	mod.link_optional("*", "imgui_close_current_popup", imgui_close_current_popup);
	mod.link_optional("*", "imgui__push_clip_rect", imgui__push_clip_rect);
	mod.link_optional("*", "imgui__pop_clip_rect", imgui__pop_clip_rect);
	mod.link_optional("*", "imgui_is_item_hovered", imgui_is_item_hovered);
	mod.link_optional("*", "imgui_is_item_active", imgui_is_item_active);
	mod.link_optional("*", "imgui_is_item_clicked", imgui_is_item_clicked);
	mod.link_optional("*", "imgui_is_item_visible", imgui_is_item_visible);
	mod.link_optional("*", "imgui_is_any_item_hovered", imgui_is_any_item_hovered);
	mod.link_optional("*", "imgui_is_any_item_active", imgui_is_any_item_active);
	mod.link_optional("*", "imgui_get_item_rect_min", imgui_get_item_rect_min);
	mod.link_optional("*", "imgui_get_item_rect_max", imgui_get_item_rect_max);
	mod.link_optional("*", "imgui_get_item_rect_size", imgui_get_item_rect_size);
	mod.link_optional("*", "imgui_set_next_item_allow_overlap", imgui_set_next_item_allow_overlap);
	mod.link_optional("*", "imgui_is_window_hovered", imgui_is_window_hovered);
	mod.link_optional("*", "imgui_is_window_focused", imgui_is_window_focused);
	mod.link_optional("*", "imgui_is_rect_visible", imgui_is_rect_visible);
	mod.link_optional("*", "imgui_is_mouse_down", imgui_is_mouse_down);
	mod.link_optional("*", "imgui_is_mouse_clicked", imgui_is_mouse_clicked);
	mod.link_optional("*", "imgui_is_mouse_double_clicked", imgui_is_mouse_double_clicked);
	mod.link_optional("*", "imgui_is_mouse_released", imgui_is_mouse_released);
	mod.link_optional("*", "imgui_is_mouse_hovering_rect", imgui_is_mouse_hovering_rect);
	mod.link_optional("*", "imgui_is_mouse_dragging", imgui_is_mouse_dragging);
	mod.link_optional("*", "imgui_get_mouse_pos", imgui_get_mouse_pos);
	mod.link_optional("*", "imgui_get_mouse_pos_on_opening_current_popup", imgui_get_mouse_pos_on_opening_current_popup);
	mod.link_optional("*", "imgui_get_mouse_drag_delta", imgui_get_mouse_drag_delta);
	mod.link_optional("*", "imgui_reset_mouse_drag_delta", imgui_reset_mouse_drag_delta);
}