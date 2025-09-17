/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t label_type() {
	return DoraType<Label>();
}
DORA_EXPORT void label_set_alignment(int64_t self, int32_t val) {
	r_cast<Label*>(self)->setAlignment(s_cast<TextAlign>(val));
}
DORA_EXPORT int32_t label_get_alignment(int64_t self) {
	return s_cast<int32_t>(r_cast<Label*>(self)->getAlignment());
}
DORA_EXPORT void label_set_alpha_ref(int64_t self, float val) {
	r_cast<Label*>(self)->setAlphaRef(val);
}
DORA_EXPORT float label_get_alpha_ref(int64_t self) {
	return r_cast<Label*>(self)->getAlphaRef();
}
DORA_EXPORT void label_set_text_width(int64_t self, float val) {
	r_cast<Label*>(self)->setTextWidth(val);
}
DORA_EXPORT float label_get_text_width(int64_t self) {
	return r_cast<Label*>(self)->getTextWidth();
}
DORA_EXPORT void label_set_spacing(int64_t self, float val) {
	r_cast<Label*>(self)->setSpacing(val);
}
DORA_EXPORT float label_get_spacing(int64_t self) {
	return r_cast<Label*>(self)->getSpacing();
}
DORA_EXPORT void label_set_line_gap(int64_t self, float val) {
	r_cast<Label*>(self)->setLineGap(val);
}
DORA_EXPORT float label_get_line_gap(int64_t self) {
	return r_cast<Label*>(self)->getLineGap();
}
DORA_EXPORT void label_set_outline_color(int64_t self, int32_t val) {
	r_cast<Label*>(self)->setOutlineColor(Color(s_cast<uint32_t>(val)));
}
DORA_EXPORT int32_t label_get_outline_color(int64_t self) {
	return r_cast<Label*>(self)->getOutlineColor().toARGB();
}
DORA_EXPORT void label_set_outline_width(int64_t self, float val) {
	r_cast<Label*>(self)->setOutlineWidth(val);
}
DORA_EXPORT float label_get_outline_width(int64_t self) {
	return r_cast<Label*>(self)->getOutlineWidth();
}
DORA_EXPORT void label_set_smooth(int64_t self, int64_t val) {
	r_cast<Label*>(self)->setSmooth(Vec2_From(val));
}
DORA_EXPORT int64_t label_get_smooth(int64_t self) {
	return Vec2_Retain(r_cast<Label*>(self)->getSmooth());
}
DORA_EXPORT void label_set_text(int64_t self, int64_t val) {
	r_cast<Label*>(self)->setText(*Str_From(val));
}
DORA_EXPORT int64_t label_get_text(int64_t self) {
	return Str_Retain(r_cast<Label*>(self)->getText());
}
DORA_EXPORT void label_set_blend_func(int64_t self, int64_t val) {
	r_cast<Label*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(val)));
}
DORA_EXPORT int64_t label_get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<Label*>(self)->getBlendFunc().toValue());
}
DORA_EXPORT void label_set_depth_write(int64_t self, int32_t val) {
	r_cast<Label*>(self)->setDepthWrite(val != 0);
}
DORA_EXPORT int32_t label_is_depth_write(int64_t self) {
	return r_cast<Label*>(self)->isDepthWrite() ? 1 : 0;
}
DORA_EXPORT void label_set_batched(int64_t self, int32_t val) {
	r_cast<Label*>(self)->setBatched(val != 0);
}
DORA_EXPORT int32_t label_is_batched(int64_t self) {
	return r_cast<Label*>(self)->isBatched() ? 1 : 0;
}
DORA_EXPORT void label_set_effect(int64_t self, int64_t val) {
	r_cast<Label*>(self)->setEffect(r_cast<SpriteEffect*>(val));
}
DORA_EXPORT int64_t label_get_effect(int64_t self) {
	return Object_From(r_cast<Label*>(self)->getEffect());
}
DORA_EXPORT int32_t label_get_character_count(int64_t self) {
	return s_cast<int32_t>(r_cast<Label*>(self)->getCharacterCount());
}
DORA_EXPORT int64_t label_get_character(int64_t self, int32_t index) {
	return Object_From(r_cast<Label*>(self)->getCharacter(s_cast<int>(index)));
}
DORA_EXPORT float label_get_automatic_width() {
	return Label::AutomaticWidth;
}
DORA_EXPORT int64_t label_new(int64_t font_name, int32_t font_size, int32_t sdf) {
	return Object_From(Label::create(*Str_From(font_name), s_cast<uint32_t>(font_size), sdf != 0));
}
DORA_EXPORT int64_t label_with_str(int64_t font_str) {
	return Object_From(Label::create(*Str_From(font_str)));
}
} // extern "C"

static void linkLabel(wasm3::module3& mod) {
	mod.link_optional("*", "label_type", label_type);
	mod.link_optional("*", "label_set_alignment", label_set_alignment);
	mod.link_optional("*", "label_get_alignment", label_get_alignment);
	mod.link_optional("*", "label_set_alpha_ref", label_set_alpha_ref);
	mod.link_optional("*", "label_get_alpha_ref", label_get_alpha_ref);
	mod.link_optional("*", "label_set_text_width", label_set_text_width);
	mod.link_optional("*", "label_get_text_width", label_get_text_width);
	mod.link_optional("*", "label_set_spacing", label_set_spacing);
	mod.link_optional("*", "label_get_spacing", label_get_spacing);
	mod.link_optional("*", "label_set_line_gap", label_set_line_gap);
	mod.link_optional("*", "label_get_line_gap", label_get_line_gap);
	mod.link_optional("*", "label_set_outline_color", label_set_outline_color);
	mod.link_optional("*", "label_get_outline_color", label_get_outline_color);
	mod.link_optional("*", "label_set_outline_width", label_set_outline_width);
	mod.link_optional("*", "label_get_outline_width", label_get_outline_width);
	mod.link_optional("*", "label_set_smooth", label_set_smooth);
	mod.link_optional("*", "label_get_smooth", label_get_smooth);
	mod.link_optional("*", "label_set_text", label_set_text);
	mod.link_optional("*", "label_get_text", label_get_text);
	mod.link_optional("*", "label_set_blend_func", label_set_blend_func);
	mod.link_optional("*", "label_get_blend_func", label_get_blend_func);
	mod.link_optional("*", "label_set_depth_write", label_set_depth_write);
	mod.link_optional("*", "label_is_depth_write", label_is_depth_write);
	mod.link_optional("*", "label_set_batched", label_set_batched);
	mod.link_optional("*", "label_is_batched", label_is_batched);
	mod.link_optional("*", "label_set_effect", label_set_effect);
	mod.link_optional("*", "label_get_effect", label_get_effect);
	mod.link_optional("*", "label_get_character_count", label_get_character_count);
	mod.link_optional("*", "label_get_character", label_get_character);
	mod.link_optional("*", "label_get_automatic_width", label_get_automatic_width);
	mod.link_optional("*", "label_new", label_new);
	mod.link_optional("*", "label_with_str", label_with_str);
}