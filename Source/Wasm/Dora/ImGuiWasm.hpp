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
static int32_t imgui_begin(int64_t name) {
	return ImGui::Binding::Begin(*str_from(name)) ? 1 : 0;
}
static int32_t imgui_begin_opts(int64_t name, int64_t windows_flags) {
	return ImGui::Binding::Begin(*str_from(name), from_str_vec(windows_flags)) ? 1 : 0;
}
static void imgui_end() {
	ImGui::End();
}
static int32_t imgui_begin_child(int64_t str_id) {
	return ImGui::Binding::BeginChild(*str_from(str_id)) ? 1 : 0;
}
static int32_t imgui_begin_child_opts(int64_t str_id, int64_t size, int64_t child_flags, int64_t window_flags) {
	return ImGui::Binding::BeginChild(*str_from(str_id), vec2_from(size), from_str_vec(child_flags), from_str_vec(window_flags)) ? 1 : 0;
}
static int32_t imgui_begin_child_with_id(int32_t id) {
	return ImGui::Binding::BeginChild(s_cast<uint32_t>(id)) ? 1 : 0;
}
static int32_t imgui_begin_child_with_id_opts(int32_t id, int64_t size, int64_t child_flags, int64_t window_flags) {
	return ImGui::Binding::BeginChild(s_cast<uint32_t>(id), vec2_from(size), from_str_vec(child_flags), from_str_vec(window_flags)) ? 1 : 0;
}
static void imgui_end_child() {
	ImGui::EndChild();
}
static void imgui_set_next_window_pos_center() {
	ImGui::Binding::SetNextWindowPosCenter();
}
static void imgui_set_next_window_pos_center_with_cond(int64_t set_cond) {
	ImGui::Binding::SetNextWindowPosCenter(*str_from(set_cond));
}
static void imgui_set_next_window_size(int64_t size) {
	ImGui::Binding::SetNextWindowSize(vec2_from(size));
}
static void imgui_set_next_window_size_with_cond(int64_t size, int64_t set_cond) {
	ImGui::Binding::SetNextWindowSize(vec2_from(size), *str_from(set_cond));
}
static void imgui_set_next_window_collapsed(int32_t collapsed) {
	ImGui::Binding::SetNextWindowCollapsed(collapsed != 0);
}
static void imgui_set_next_window_collapsed_with_cond(int32_t collapsed, int64_t set_cond) {
	ImGui::Binding::SetNextWindowCollapsed(collapsed != 0, *str_from(set_cond));
}
static void imgui_set_window_pos(int64_t name, int64_t pos) {
	ImGui::Binding::SetWindowPos(*str_from(name), vec2_from(pos));
}
static void imgui_set_window_pos_with_cond(int64_t name, int64_t pos, int64_t set_cond) {
	ImGui::Binding::SetWindowPos(*str_from(name), vec2_from(pos), *str_from(set_cond));
}
static void imgui_set_window_size(int64_t name, int64_t size) {
	ImGui::Binding::SetWindowSize(*str_from(name), vec2_from(size));
}
static void imgui_set_window_size_with_cond(int64_t name, int64_t size, int64_t set_cond) {
	ImGui::Binding::SetWindowSize(*str_from(name), vec2_from(size), *str_from(set_cond));
}
static void imgui_set_window_collapsed(int64_t name, int32_t collapsed) {
	ImGui::Binding::SetWindowCollapsed(*str_from(name), collapsed != 0);
}
static void imgui_set_window_collapsed_with_cond(int64_t name, int32_t collapsed, int64_t set_cond) {
	ImGui::Binding::SetWindowCollapsed(*str_from(name), collapsed != 0, *str_from(set_cond));
}
static void imgui_set_color_edit_options(int64_t color_edit_mode) {
	ImGui::Binding::SetColorEditOptions(*str_from(color_edit_mode));
}
static int32_t imgui_input_text(int64_t label, int64_t buffer) {
	return ImGui::Binding::InputText(*str_from(label), r_cast<Buffer*>(buffer)) ? 1 : 0;
}
static int32_t imgui_input_text_opts(int64_t label, int64_t buffer, int64_t input_text_flags) {
	return ImGui::Binding::InputText(*str_from(label), r_cast<Buffer*>(buffer), from_str_vec(input_text_flags)) ? 1 : 0;
}
static int32_t imgui_input_text_multiline(int64_t label, int64_t buffer) {
	return ImGui::Binding::InputTextMultiline(*str_from(label), r_cast<Buffer*>(buffer)) ? 1 : 0;
}
static int32_t imgui_input_text_multiline_opts(int64_t label, int64_t buffer, int64_t size, int64_t input_text_flags) {
	return ImGui::Binding::InputTextMultiline(*str_from(label), r_cast<Buffer*>(buffer), vec2_from(size), from_str_vec(input_text_flags)) ? 1 : 0;
}
static int32_t imgui_tree_node_ex(int64_t label) {
	return ImGui::Binding::TreeNodeEx(*str_from(label)) ? 1 : 0;
}
static int32_t imgui_tree_node_ex_opts(int64_t label, int64_t tree_node_flags) {
	return ImGui::Binding::TreeNodeEx(*str_from(label), from_str_vec(tree_node_flags)) ? 1 : 0;
}
static int32_t imgui_tree_node_ex_with_id(int64_t str_id, int64_t text) {
	return ImGui::Binding::TreeNodeEx(*str_from(str_id), *str_from(text)) ? 1 : 0;
}
static int32_t imgui_tree_node_ex_with_id_opts(int64_t str_id, int64_t text, int64_t tree_node_flags) {
	return ImGui::Binding::TreeNodeEx(*str_from(str_id), *str_from(text), from_str_vec(tree_node_flags)) ? 1 : 0;
}
static void imgui_set_next_item_open(int32_t is_open) {
	ImGui::Binding::SetNextItemOpen(is_open != 0);
}
static void imgui_set_next_item_open_with_cond(int32_t is_open, int64_t set_cond) {
	ImGui::Binding::SetNextItemOpen(is_open != 0, *str_from(set_cond));
}
static int32_t imgui_collapsing_header(int64_t label) {
	return ImGui::Binding::CollapsingHeader(*str_from(label)) ? 1 : 0;
}
static int32_t imgui_collapsing_header_opts(int64_t label, int64_t tree_node_flags) {
	return ImGui::Binding::CollapsingHeader(*str_from(label), from_str_vec(tree_node_flags)) ? 1 : 0;
}
static int32_t imgui_selectable(int64_t label) {
	return ImGui::Binding::Selectable(*str_from(label)) ? 1 : 0;
}
static int32_t imgui_selectable_opts(int64_t label, int64_t selectable_flags) {
	return ImGui::Binding::Selectable(*str_from(label), from_str_vec(selectable_flags)) ? 1 : 0;
}
static int32_t imgui_begin_popup_modal(int64_t name) {
	return ImGui::Binding::BeginPopupModal(*str_from(name)) ? 1 : 0;
}
static int32_t imgui_begin_popup_modal_opts(int64_t name, int64_t windows_flags) {
	return ImGui::Binding::BeginPopupModal(*str_from(name), from_str_vec(windows_flags)) ? 1 : 0;
}
static int32_t imgui_begin_popup_context_item(int64_t name) {
	return ImGui::Binding::BeginPopupContextItem(*str_from(name)) ? 1 : 0;
}
static int32_t imgui_begin_popup_context_item_opts(int64_t name, int64_t popup_flags) {
	return ImGui::Binding::BeginPopupContextItem(*str_from(name), from_str_vec(popup_flags)) ? 1 : 0;
}
static int32_t imgui_begin_popup_context_window(int64_t name) {
	return ImGui::Binding::BeginPopupContextWindow(*str_from(name)) ? 1 : 0;
}
static int32_t imgui_begin_popup_context_window_opts(int64_t name, int64_t popup_flags) {
	return ImGui::Binding::BeginPopupContextWindow(*str_from(name), from_str_vec(popup_flags)) ? 1 : 0;
}
static int32_t imgui_begin_popup_context_void(int64_t name) {
	return ImGui::Binding::BeginPopupContextVoid(*str_from(name)) ? 1 : 0;
}
static int32_t imgui_begin_popup_context_void_opts(int64_t name, int64_t popup_flags) {
	return ImGui::Binding::BeginPopupContextVoid(*str_from(name), from_str_vec(popup_flags)) ? 1 : 0;
}
static void imgui_bush_style_color(int64_t name, int32_t color) {
	ImGui::Binding::PushStyleColor(*str_from(name), Color(s_cast<uint32_t>(color)));
}
static void imgui_push_style_float(int64_t name, float val) {
	ImGui::Binding::PushStyleVar(*str_from(name), val);
}
static void imgui_push_style_vec2(int64_t name, int64_t val) {
	ImGui::Binding::PushStyleVar(*str_from(name), vec2_from(val));
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
static int32_t imgui_tree_node(int64_t str_id, int64_t text) {
	return ImGui::Binding::TreeNode(*str_from(str_id), *str_from(text)) ? 1 : 0;
}
static void imgui_set_tooltip(int64_t text) {
	ImGui::Binding::SetTooltip(*str_from(text));
}
static void imgui_image(int64_t clip_str, int64_t size) {
	ImGui::Binding::Image(*str_from(clip_str), vec2_from(size));
}
static void imgui_image_opts(int64_t clip_str, int64_t size, int32_t tint_col, int32_t border_col) {
	ImGui::Binding::Image(*str_from(clip_str), vec2_from(size), Color(s_cast<uint32_t>(tint_col)), Color(s_cast<uint32_t>(border_col)));
}
static int32_t imgui_image_button(int64_t str_id, int64_t clip_str, int64_t size) {
	return ImGui::Binding::ImageButton(*str_from(str_id), *str_from(clip_str), vec2_from(size)) ? 1 : 0;
}
static int32_t imgui_image_button_opts(int64_t str_id, int64_t clip_str, int64_t size, int32_t bg_col, int32_t tint_col) {
	return ImGui::Binding::ImageButton(*str_from(str_id), *str_from(clip_str), vec2_from(size), Color(s_cast<uint32_t>(bg_col)), Color(s_cast<uint32_t>(tint_col))) ? 1 : 0;
}
static int32_t imgui_color_button(int64_t desc_id, int32_t col) {
	return ImGui::Binding::ColorButton(*str_from(desc_id), Color(s_cast<uint32_t>(col))) ? 1 : 0;
}
static int32_t imgui_color_button_opts(int64_t desc_id, int32_t col, int64_t flags, int64_t size) {
	return ImGui::Binding::ColorButton(*str_from(desc_id), Color(s_cast<uint32_t>(col)), *str_from(flags), vec2_from(size)) ? 1 : 0;
}
static void imgui_columns(int32_t count) {
	ImGui::Binding::Columns(s_cast<int>(count));
}
static void imgui_columns_opts(int32_t count, int32_t border, int64_t str_id) {
	ImGui::Binding::Columns(s_cast<int>(count), border != 0, *str_from(str_id));
}
static int32_t imgui_begin_table(int64_t str_id, int32_t column) {
	return ImGui::Binding::BeginTable(*str_from(str_id), s_cast<int>(column)) ? 1 : 0;
}
static int32_t imgui_begin_table_opts(int64_t str_id, int32_t column, int64_t outer_size, float inner_width, int64_t table_flags) {
	return ImGui::Binding::BeginTable(*str_from(str_id), s_cast<int>(column), vec2_from(outer_size), inner_width, from_str_vec(table_flags)) ? 1 : 0;
}
static void imgui_table_next_row() {
	ImGui::Binding::TableNextRow();
}
static void imgui_table_next_row_opts(float min_row_height, int64_t table_row_flag) {
	ImGui::Binding::TableNextRow(min_row_height, *str_from(table_row_flag));
}
static void imgui_table_setup_column(int64_t label) {
	ImGui::Binding::TableSetupColumn(*str_from(label));
}
static void imgui_table_setup_column_opts(int64_t label, float init_width_or_weight, int32_t user_id, int64_t table_column_flags) {
	ImGui::Binding::TableSetupColumn(*str_from(label), init_width_or_weight, s_cast<uint32_t>(user_id), from_str_vec(table_column_flags));
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
static int32_t imgui__begin(int64_t name, int64_t stack) {
	return ImGui::Binding::Begin(*str_from(name), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__begin_opts(int64_t name, int64_t stack, int64_t windows_flags) {
	return ImGui::Binding::Begin(*str_from(name), r_cast<CallStack*>(stack), from_str_vec(windows_flags)) ? 1 : 0;
}
static int32_t imgui__collapsing_header(int64_t label, int64_t stack) {
	return ImGui::Binding::CollapsingHeader(*str_from(label), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__collapsing_header_opts(int64_t label, int64_t stack, int64_t tree_node_flags) {
	return ImGui::Binding::CollapsingHeader(*str_from(label), r_cast<CallStack*>(stack), from_str_vec(tree_node_flags)) ? 1 : 0;
}
static int32_t imgui__selectable(int64_t label, int64_t stack) {
	return ImGui::Binding::Selectable(*str_from(label), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__selectable_opts(int64_t label, int64_t stack, int64_t size, int64_t selectable_flags) {
	return ImGui::Binding::Selectable(*str_from(label), r_cast<CallStack*>(stack), vec2_from(size), from_str_vec(selectable_flags)) ? 1 : 0;
}
static int32_t imgui__begin_popup_modal(int64_t name, int64_t stack) {
	return ImGui::Binding::BeginPopupModal(*str_from(name), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__begin_popup_modal_opts(int64_t name, int64_t stack, int64_t windows_flags) {
	return ImGui::Binding::BeginPopupModal(*str_from(name), r_cast<CallStack*>(stack), from_str_vec(windows_flags)) ? 1 : 0;
}
static int32_t imgui__combo(int64_t label, int64_t stack, int64_t items) {
	return ImGui::Binding::Combo(*str_from(label), r_cast<CallStack*>(stack), from_str_vec(items)) ? 1 : 0;
}
static int32_t imgui__combo_opts(int64_t label, int64_t stack, int64_t items, int32_t height_in_items) {
	return ImGui::Binding::Combo(*str_from(label), r_cast<CallStack*>(stack), from_str_vec(items), s_cast<int>(height_in_items)) ? 1 : 0;
}
static int32_t imgui__drag_float(int64_t label, int64_t stack, float v_speed, float v_min, float v_max) {
	return ImGui::Binding::DragFloat(*str_from(label), r_cast<CallStack*>(stack), v_speed, v_min, v_max) ? 1 : 0;
}
static int32_t imgui__drag_float_opts(int64_t label, int64_t stack, float v_speed, float v_min, float v_max, int64_t display_format, int64_t slider_flags) {
	return ImGui::Binding::DragFloat(*str_from(label), r_cast<CallStack*>(stack), v_speed, v_min, v_max, *str_from(display_format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_float2(int64_t label, int64_t stack, float v_speed, float v_min, float v_max) {
	return ImGui::Binding::DragFloat2(*str_from(label), r_cast<CallStack*>(stack), v_speed, v_min, v_max) ? 1 : 0;
}
static int32_t imgui__drag_float2_opts(int64_t label, int64_t stack, float v_speed, float v_min, float v_max, int64_t display_format, int64_t slider_flags) {
	return ImGui::Binding::DragFloat2(*str_from(label), r_cast<CallStack*>(stack), v_speed, v_min, v_max, *str_from(display_format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_int(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max) {
	return ImGui::Binding::DragInt(*str_from(label), r_cast<CallStack*>(stack), v_speed, s_cast<int>(v_min), s_cast<int>(v_max)) ? 1 : 0;
}
static int32_t imgui__drag_int_opts(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max, int64_t display_format, int64_t slider_flags) {
	return ImGui::Binding::DragInt(*str_from(label), r_cast<CallStack*>(stack), v_speed, s_cast<int>(v_min), s_cast<int>(v_max), *str_from(display_format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_int2(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max) {
	return ImGui::Binding::DragInt2(*str_from(label), r_cast<CallStack*>(stack), v_speed, s_cast<int>(v_min), s_cast<int>(v_max)) ? 1 : 0;
}
static int32_t imgui__drag_int2_opts(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max, int64_t display_format, int64_t slider_flags) {
	return ImGui::Binding::DragInt2(*str_from(label), r_cast<CallStack*>(stack), v_speed, s_cast<int>(v_min), s_cast<int>(v_max), *str_from(display_format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__input_float(int64_t label, int64_t stack) {
	return ImGui::Binding::InputFloat(*str_from(label), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__input_float_opts(int64_t label, int64_t stack, float step, float step_fast, int64_t display_format, int64_t input_text_flags) {
	return ImGui::Binding::InputFloat(*str_from(label), r_cast<CallStack*>(stack), step, step_fast, *str_from(display_format), from_str_vec(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__input_float2(int64_t label, int64_t stack) {
	return ImGui::Binding::InputFloat2(*str_from(label), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__input_float2_opts(int64_t label, int64_t stack, int64_t display_format, int64_t input_text_flags) {
	return ImGui::Binding::InputFloat2(*str_from(label), r_cast<CallStack*>(stack), *str_from(display_format), from_str_vec(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__input_int(int64_t label, int64_t stack) {
	return ImGui::Binding::InputInt(*str_from(label), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__input_int_opts(int64_t label, int64_t stack, int32_t step, int32_t step_fast, int64_t input_text_flags) {
	return ImGui::Binding::InputInt(*str_from(label), r_cast<CallStack*>(stack), s_cast<int>(step), s_cast<int>(step_fast), from_str_vec(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__input_int2(int64_t label, int64_t stack) {
	return ImGui::Binding::InputInt2(*str_from(label), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__input_int2_opts(int64_t label, int64_t stack, int64_t input_text_flags) {
	return ImGui::Binding::InputInt2(*str_from(label), r_cast<CallStack*>(stack), from_str_vec(input_text_flags)) ? 1 : 0;
}
static int32_t imgui__slider_float(int64_t label, int64_t stack, float v_min, float v_max) {
	return ImGui::Binding::SliderFloat(*str_from(label), r_cast<CallStack*>(stack), v_min, v_max) ? 1 : 0;
}
static int32_t imgui__slider_float_opts(int64_t label, int64_t stack, float v_min, float v_max, int64_t display_format, int64_t slider_flags) {
	return ImGui::Binding::SliderFloat(*str_from(label), r_cast<CallStack*>(stack), v_min, v_max, *str_from(display_format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__slider_float2(int64_t label, int64_t stack, float v_min, float v_max) {
	return ImGui::Binding::SliderFloat2(*str_from(label), r_cast<CallStack*>(stack), v_min, v_max) ? 1 : 0;
}
static int32_t imgui__slider_float2_opts(int64_t label, int64_t stack, float v_min, float v_max, int64_t display_format, int64_t slider_flags) {
	return ImGui::Binding::SliderFloat2(*str_from(label), r_cast<CallStack*>(stack), v_min, v_max, *str_from(display_format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__slider_int(int64_t label, int64_t stack, int32_t v_min, int32_t v_max) {
	return ImGui::Binding::SliderInt(*str_from(label), r_cast<CallStack*>(stack), s_cast<int>(v_min), s_cast<int>(v_max)) ? 1 : 0;
}
static int32_t imgui__slider_int_opts(int64_t label, int64_t stack, int32_t v_min, int32_t v_max, int64_t format, int64_t slider_flags) {
	return ImGui::Binding::SliderInt(*str_from(label), r_cast<CallStack*>(stack), s_cast<int>(v_min), s_cast<int>(v_max), *str_from(format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__slider_int2(int64_t label, int64_t stack, int32_t v_min, int32_t v_max) {
	return ImGui::Binding::SliderInt2(*str_from(label), r_cast<CallStack*>(stack), s_cast<int>(v_min), s_cast<int>(v_max)) ? 1 : 0;
}
static int32_t imgui__slider_int2_opts(int64_t label, int64_t stack, int32_t v_min, int32_t v_max, int64_t display_format, int64_t slider_flags) {
	return ImGui::Binding::SliderInt2(*str_from(label), r_cast<CallStack*>(stack), s_cast<int>(v_min), s_cast<int>(v_max), *str_from(display_format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_float_range2(int64_t label, int64_t stack, float v_speed, float v_min, float v_max) {
	return ImGui::Binding::DragFloatRange2(*str_from(label), r_cast<CallStack*>(stack), v_speed, v_min, v_max) ? 1 : 0;
}
static int32_t imgui__drag_float_range2_opts(int64_t label, int64_t stack, float v_speed, float v_min, float v_max, int64_t format, int64_t format_max, int64_t slider_flags) {
	return ImGui::Binding::DragFloatRange2(*str_from(label), r_cast<CallStack*>(stack), v_speed, v_min, v_max, *str_from(format), *str_from(format_max), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__drag_int_range2(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max) {
	return ImGui::Binding::DragIntRange2(*str_from(label), r_cast<CallStack*>(stack), v_speed, s_cast<int>(v_min), s_cast<int>(v_max)) ? 1 : 0;
}
static int32_t imgui__drag_int_range2_opts(int64_t label, int64_t stack, float v_speed, int32_t v_min, int32_t v_max, int64_t format, int64_t format_max, int64_t slider_flags) {
	return ImGui::Binding::DragIntRange2(*str_from(label), r_cast<CallStack*>(stack), v_speed, s_cast<int>(v_min), s_cast<int>(v_max), *str_from(format), *str_from(format_max), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__v_slider_float(int64_t label, int64_t size, int64_t stack, float v_min, float v_max) {
	return ImGui::Binding::VSliderFloat(*str_from(label), vec2_from(size), r_cast<CallStack*>(stack), v_min, v_max) ? 1 : 0;
}
static int32_t imgui__v_slider_float_opts(int64_t label, int64_t size, int64_t stack, float v_min, float v_max, int64_t format, int64_t slider_flags) {
	return ImGui::Binding::VSliderFloat(*str_from(label), vec2_from(size), r_cast<CallStack*>(stack), v_min, v_max, *str_from(format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__v_slider_int(int64_t label, int64_t size, int64_t stack, int32_t v_min, int32_t v_max) {
	return ImGui::Binding::VSliderInt(*str_from(label), vec2_from(size), r_cast<CallStack*>(stack), s_cast<int>(v_min), s_cast<int>(v_max)) ? 1 : 0;
}
static int32_t imgui__v_slider_int_opts(int64_t label, int64_t size, int64_t stack, int32_t v_min, int32_t v_max, int64_t format, int64_t slider_flags) {
	return ImGui::Binding::VSliderInt(*str_from(label), vec2_from(size), r_cast<CallStack*>(stack), s_cast<int>(v_min), s_cast<int>(v_max), *str_from(format), from_str_vec(slider_flags)) ? 1 : 0;
}
static int32_t imgui__color_edit3(int64_t label, int64_t stack) {
	return ImGui::Binding::ColorEdit3(*str_from(label), r_cast<CallStack*>(stack)) ? 1 : 0;
}
static int32_t imgui__color_edit4(int64_t label, int64_t stack, int32_t show_alpha) {
	return ImGui::Binding::ColorEdit4(*str_from(label), r_cast<CallStack*>(stack), show_alpha != 0) ? 1 : 0;
}
static void linkImGui(wasm3::module3& mod) {
	mod.link_optional("*", "imgui_load_font_ttf_async", imgui_load_font_ttf_async);
	mod.link_optional("*", "imgui_is_font_loaded", imgui_is_font_loaded);
	mod.link_optional("*", "imgui_show_stats", imgui_show_stats);
	mod.link_optional("*", "imgui_show_console", imgui_show_console);
	mod.link_optional("*", "imgui_begin", imgui_begin);
	mod.link_optional("*", "imgui_begin_opts", imgui_begin_opts);
	mod.link_optional("*", "imgui_end", imgui_end);
	mod.link_optional("*", "imgui_begin_child", imgui_begin_child);
	mod.link_optional("*", "imgui_begin_child_opts", imgui_begin_child_opts);
	mod.link_optional("*", "imgui_begin_child_with_id", imgui_begin_child_with_id);
	mod.link_optional("*", "imgui_begin_child_with_id_opts", imgui_begin_child_with_id_opts);
	mod.link_optional("*", "imgui_end_child", imgui_end_child);
	mod.link_optional("*", "imgui_set_next_window_pos_center", imgui_set_next_window_pos_center);
	mod.link_optional("*", "imgui_set_next_window_pos_center_with_cond", imgui_set_next_window_pos_center_with_cond);
	mod.link_optional("*", "imgui_set_next_window_size", imgui_set_next_window_size);
	mod.link_optional("*", "imgui_set_next_window_size_with_cond", imgui_set_next_window_size_with_cond);
	mod.link_optional("*", "imgui_set_next_window_collapsed", imgui_set_next_window_collapsed);
	mod.link_optional("*", "imgui_set_next_window_collapsed_with_cond", imgui_set_next_window_collapsed_with_cond);
	mod.link_optional("*", "imgui_set_window_pos", imgui_set_window_pos);
	mod.link_optional("*", "imgui_set_window_pos_with_cond", imgui_set_window_pos_with_cond);
	mod.link_optional("*", "imgui_set_window_size", imgui_set_window_size);
	mod.link_optional("*", "imgui_set_window_size_with_cond", imgui_set_window_size_with_cond);
	mod.link_optional("*", "imgui_set_window_collapsed", imgui_set_window_collapsed);
	mod.link_optional("*", "imgui_set_window_collapsed_with_cond", imgui_set_window_collapsed_with_cond);
	mod.link_optional("*", "imgui_set_color_edit_options", imgui_set_color_edit_options);
	mod.link_optional("*", "imgui_input_text", imgui_input_text);
	mod.link_optional("*", "imgui_input_text_opts", imgui_input_text_opts);
	mod.link_optional("*", "imgui_input_text_multiline", imgui_input_text_multiline);
	mod.link_optional("*", "imgui_input_text_multiline_opts", imgui_input_text_multiline_opts);
	mod.link_optional("*", "imgui_tree_node_ex", imgui_tree_node_ex);
	mod.link_optional("*", "imgui_tree_node_ex_opts", imgui_tree_node_ex_opts);
	mod.link_optional("*", "imgui_tree_node_ex_with_id", imgui_tree_node_ex_with_id);
	mod.link_optional("*", "imgui_tree_node_ex_with_id_opts", imgui_tree_node_ex_with_id_opts);
	mod.link_optional("*", "imgui_set_next_item_open", imgui_set_next_item_open);
	mod.link_optional("*", "imgui_set_next_item_open_with_cond", imgui_set_next_item_open_with_cond);
	mod.link_optional("*", "imgui_collapsing_header", imgui_collapsing_header);
	mod.link_optional("*", "imgui_collapsing_header_opts", imgui_collapsing_header_opts);
	mod.link_optional("*", "imgui_selectable", imgui_selectable);
	mod.link_optional("*", "imgui_selectable_opts", imgui_selectable_opts);
	mod.link_optional("*", "imgui_begin_popup_modal", imgui_begin_popup_modal);
	mod.link_optional("*", "imgui_begin_popup_modal_opts", imgui_begin_popup_modal_opts);
	mod.link_optional("*", "imgui_begin_popup_context_item", imgui_begin_popup_context_item);
	mod.link_optional("*", "imgui_begin_popup_context_item_opts", imgui_begin_popup_context_item_opts);
	mod.link_optional("*", "imgui_begin_popup_context_window", imgui_begin_popup_context_window);
	mod.link_optional("*", "imgui_begin_popup_context_window_opts", imgui_begin_popup_context_window_opts);
	mod.link_optional("*", "imgui_begin_popup_context_void", imgui_begin_popup_context_void);
	mod.link_optional("*", "imgui_begin_popup_context_void_opts", imgui_begin_popup_context_void_opts);
	mod.link_optional("*", "imgui_bush_style_color", imgui_bush_style_color);
	mod.link_optional("*", "imgui_push_style_float", imgui_push_style_float);
	mod.link_optional("*", "imgui_push_style_vec2", imgui_push_style_vec2);
	mod.link_optional("*", "imgui_text", imgui_text);
	mod.link_optional("*", "imgui_text_colored", imgui_text_colored);
	mod.link_optional("*", "imgui_text_disabled", imgui_text_disabled);
	mod.link_optional("*", "imgui_text_wrapped", imgui_text_wrapped);
	mod.link_optional("*", "imgui_label_text", imgui_label_text);
	mod.link_optional("*", "imgui_bullet_text", imgui_bullet_text);
	mod.link_optional("*", "imgui_tree_node", imgui_tree_node);
	mod.link_optional("*", "imgui_set_tooltip", imgui_set_tooltip);
	mod.link_optional("*", "imgui_image", imgui_image);
	mod.link_optional("*", "imgui_image_opts", imgui_image_opts);
	mod.link_optional("*", "imgui_image_button", imgui_image_button);
	mod.link_optional("*", "imgui_image_button_opts", imgui_image_button_opts);
	mod.link_optional("*", "imgui_color_button", imgui_color_button);
	mod.link_optional("*", "imgui_color_button_opts", imgui_color_button_opts);
	mod.link_optional("*", "imgui_columns", imgui_columns);
	mod.link_optional("*", "imgui_columns_opts", imgui_columns_opts);
	mod.link_optional("*", "imgui_begin_table", imgui_begin_table);
	mod.link_optional("*", "imgui_begin_table_opts", imgui_begin_table_opts);
	mod.link_optional("*", "imgui_table_next_row", imgui_table_next_row);
	mod.link_optional("*", "imgui_table_next_row_opts", imgui_table_next_row_opts);
	mod.link_optional("*", "imgui_table_setup_column", imgui_table_setup_column);
	mod.link_optional("*", "imgui_table_setup_column_opts", imgui_table_setup_column_opts);
	mod.link_optional("*", "imgui_set_style_bool", imgui_set_style_bool);
	mod.link_optional("*", "imgui_set_style_float", imgui_set_style_float);
	mod.link_optional("*", "imgui_set_style_vec2", imgui_set_style_vec2);
	mod.link_optional("*", "imgui_set_style_color", imgui_set_style_color);
	mod.link_optional("*", "imgui__begin", imgui__begin);
	mod.link_optional("*", "imgui__begin_opts", imgui__begin_opts);
	mod.link_optional("*", "imgui__collapsing_header", imgui__collapsing_header);
	mod.link_optional("*", "imgui__collapsing_header_opts", imgui__collapsing_header_opts);
	mod.link_optional("*", "imgui__selectable", imgui__selectable);
	mod.link_optional("*", "imgui__selectable_opts", imgui__selectable_opts);
	mod.link_optional("*", "imgui__begin_popup_modal", imgui__begin_popup_modal);
	mod.link_optional("*", "imgui__begin_popup_modal_opts", imgui__begin_popup_modal_opts);
	mod.link_optional("*", "imgui__combo", imgui__combo);
	mod.link_optional("*", "imgui__combo_opts", imgui__combo_opts);
	mod.link_optional("*", "imgui__drag_float", imgui__drag_float);
	mod.link_optional("*", "imgui__drag_float_opts", imgui__drag_float_opts);
	mod.link_optional("*", "imgui__drag_float2", imgui__drag_float2);
	mod.link_optional("*", "imgui__drag_float2_opts", imgui__drag_float2_opts);
	mod.link_optional("*", "imgui__drag_int", imgui__drag_int);
	mod.link_optional("*", "imgui__drag_int_opts", imgui__drag_int_opts);
	mod.link_optional("*", "imgui__drag_int2", imgui__drag_int2);
	mod.link_optional("*", "imgui__drag_int2_opts", imgui__drag_int2_opts);
	mod.link_optional("*", "imgui__input_float", imgui__input_float);
	mod.link_optional("*", "imgui__input_float_opts", imgui__input_float_opts);
	mod.link_optional("*", "imgui__input_float2", imgui__input_float2);
	mod.link_optional("*", "imgui__input_float2_opts", imgui__input_float2_opts);
	mod.link_optional("*", "imgui__input_int", imgui__input_int);
	mod.link_optional("*", "imgui__input_int_opts", imgui__input_int_opts);
	mod.link_optional("*", "imgui__input_int2", imgui__input_int2);
	mod.link_optional("*", "imgui__input_int2_opts", imgui__input_int2_opts);
	mod.link_optional("*", "imgui__slider_float", imgui__slider_float);
	mod.link_optional("*", "imgui__slider_float_opts", imgui__slider_float_opts);
	mod.link_optional("*", "imgui__slider_float2", imgui__slider_float2);
	mod.link_optional("*", "imgui__slider_float2_opts", imgui__slider_float2_opts);
	mod.link_optional("*", "imgui__slider_int", imgui__slider_int);
	mod.link_optional("*", "imgui__slider_int_opts", imgui__slider_int_opts);
	mod.link_optional("*", "imgui__slider_int2", imgui__slider_int2);
	mod.link_optional("*", "imgui__slider_int2_opts", imgui__slider_int2_opts);
	mod.link_optional("*", "imgui__drag_float_range2", imgui__drag_float_range2);
	mod.link_optional("*", "imgui__drag_float_range2_opts", imgui__drag_float_range2_opts);
	mod.link_optional("*", "imgui__drag_int_range2", imgui__drag_int_range2);
	mod.link_optional("*", "imgui__drag_int_range2_opts", imgui__drag_int_range2_opts);
	mod.link_optional("*", "imgui__v_slider_float", imgui__v_slider_float);
	mod.link_optional("*", "imgui__v_slider_float_opts", imgui__v_slider_float_opts);
	mod.link_optional("*", "imgui__v_slider_int", imgui__v_slider_int);
	mod.link_optional("*", "imgui__v_slider_int_opts", imgui__v_slider_int_opts);
	mod.link_optional("*", "imgui__color_edit3", imgui__color_edit3);
	mod.link_optional("*", "imgui__color_edit4", imgui__color_edit4);
}