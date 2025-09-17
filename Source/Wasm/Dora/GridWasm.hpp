/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t grid_type() {
	return DoraType<Grid>();
}
DORA_EXPORT int32_t grid_get_grid_x(int64_t self) {
	return s_cast<int32_t>(r_cast<Grid*>(self)->getGridX());
}
DORA_EXPORT int32_t grid_get_grid_y(int64_t self) {
	return s_cast<int32_t>(r_cast<Grid*>(self)->getGridY());
}
DORA_EXPORT void grid_set_depth_write(int64_t self, int32_t val) {
	r_cast<Grid*>(self)->setDepthWrite(val != 0);
}
DORA_EXPORT int32_t grid_is_depth_write(int64_t self) {
	return r_cast<Grid*>(self)->isDepthWrite() ? 1 : 0;
}
DORA_EXPORT void grid_set_blend_func(int64_t self, int64_t val) {
	r_cast<Grid*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(val)));
}
DORA_EXPORT int64_t grid_get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<Grid*>(self)->getBlendFunc().toValue());
}
DORA_EXPORT void grid_set_effect(int64_t self, int64_t val) {
	r_cast<Grid*>(self)->setEffect(r_cast<SpriteEffect*>(val));
}
DORA_EXPORT int64_t grid_get_effect(int64_t self) {
	return Object_From(r_cast<Grid*>(self)->getEffect());
}
DORA_EXPORT void grid_set_texture_rect(int64_t self, int64_t val) {
	r_cast<Grid*>(self)->setTextureRect(*r_cast<Rect*>(val));
}
DORA_EXPORT int64_t grid_get_texture_rect(int64_t self) {
	return r_cast<int64_t>(new Rect{r_cast<Grid*>(self)->getTextureRect()});
}
DORA_EXPORT void grid_set_texture(int64_t self, int64_t val) {
	r_cast<Grid*>(self)->setTexture(r_cast<Texture2D*>(val));
}
DORA_EXPORT int64_t grid_get_texture(int64_t self) {
	return Object_From(r_cast<Grid*>(self)->getTexture());
}
DORA_EXPORT void grid_set_pos(int64_t self, int32_t x, int32_t y, int64_t pos, float z) {
	r_cast<Grid*>(self)->setPos(s_cast<int>(x), s_cast<int>(y), Vec2_From(pos), z);
}
DORA_EXPORT int64_t grid_get_pos(int64_t self, int32_t x, int32_t y) {
	return Vec2_Retain(r_cast<Grid*>(self)->getPos(s_cast<int>(x), s_cast<int>(y)));
}
DORA_EXPORT void grid_set_color(int64_t self, int32_t x, int32_t y, int32_t color) {
	r_cast<Grid*>(self)->setColor(s_cast<int>(x), s_cast<int>(y), Color(s_cast<uint32_t>(color)));
}
DORA_EXPORT int32_t grid_get_color(int64_t self, int32_t x, int32_t y) {
	return r_cast<Grid*>(self)->getColor(s_cast<int>(x), s_cast<int>(y)).toARGB();
}
DORA_EXPORT void grid_move_uv(int64_t self, int32_t x, int32_t y, int64_t offset) {
	r_cast<Grid*>(self)->moveUV(s_cast<int>(x), s_cast<int>(y), Vec2_From(offset));
}
DORA_EXPORT int64_t grid_new(float width, float height, int32_t grid_x, int32_t grid_y) {
	return Object_From(Grid::create(width, height, s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
DORA_EXPORT int64_t grid_with_texture_rect(int64_t texture, int64_t texture_rect, int32_t grid_x, int32_t grid_y) {
	return Object_From(Grid::create(r_cast<Texture2D*>(texture), *r_cast<Rect*>(texture_rect), s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
DORA_EXPORT int64_t grid_with_texture(int64_t texture, int32_t grid_x, int32_t grid_y) {
	return Object_From(Grid::create(r_cast<Texture2D*>(texture), s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
DORA_EXPORT int64_t grid_with_file(int64_t clip_str, int32_t grid_x, int32_t grid_y) {
	return Object_From(Grid::from(*Str_From(clip_str), s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
} // extern "C"

static void linkGrid(wasm3::module3& mod) {
	mod.link_optional("*", "grid_type", grid_type);
	mod.link_optional("*", "grid_get_grid_x", grid_get_grid_x);
	mod.link_optional("*", "grid_get_grid_y", grid_get_grid_y);
	mod.link_optional("*", "grid_set_depth_write", grid_set_depth_write);
	mod.link_optional("*", "grid_is_depth_write", grid_is_depth_write);
	mod.link_optional("*", "grid_set_blend_func", grid_set_blend_func);
	mod.link_optional("*", "grid_get_blend_func", grid_get_blend_func);
	mod.link_optional("*", "grid_set_effect", grid_set_effect);
	mod.link_optional("*", "grid_get_effect", grid_get_effect);
	mod.link_optional("*", "grid_set_texture_rect", grid_set_texture_rect);
	mod.link_optional("*", "grid_get_texture_rect", grid_get_texture_rect);
	mod.link_optional("*", "grid_set_texture", grid_set_texture);
	mod.link_optional("*", "grid_get_texture", grid_get_texture);
	mod.link_optional("*", "grid_set_pos", grid_set_pos);
	mod.link_optional("*", "grid_get_pos", grid_get_pos);
	mod.link_optional("*", "grid_set_color", grid_set_color);
	mod.link_optional("*", "grid_get_color", grid_get_color);
	mod.link_optional("*", "grid_move_uv", grid_move_uv);
	mod.link_optional("*", "grid_new", grid_new);
	mod.link_optional("*", "grid_with_texture_rect", grid_with_texture_rect);
	mod.link_optional("*", "grid_with_texture", grid_with_texture);
	mod.link_optional("*", "grid_with_file", grid_with_file);
}