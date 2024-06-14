/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t grid_type() {
	return DoraType<Grid>();
}
static int32_t grid_get_grid_x(int64_t self) {
	return s_cast<int32_t>(r_cast<Grid*>(self)->getGridX());
}
static int32_t grid_get_grid_y(int64_t self) {
	return s_cast<int32_t>(r_cast<Grid*>(self)->getGridY());
}
static void grid_set_depth_write(int64_t self, int32_t var) {
	r_cast<Grid*>(self)->setDepthWrite(var != 0);
}
static int32_t grid_is_depth_write(int64_t self) {
	return r_cast<Grid*>(self)->isDepthWrite() ? 1 : 0;
}
static void grid__set_blend_func(int64_t self, int64_t func) {
	r_cast<Grid*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(func)));
}
static int64_t grid__get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<Grid*>(self)->getBlendFunc().toValue());
}
static void grid_set_effect(int64_t self, int64_t var) {
	r_cast<Grid*>(self)->setEffect(r_cast<SpriteEffect*>(var));
}
static int64_t grid_get_effect(int64_t self) {
	return from_object(r_cast<Grid*>(self)->getEffect());
}
static void grid_set_texture_rect(int64_t self, int64_t var) {
	r_cast<Grid*>(self)->setTextureRect(*r_cast<Rect*>(var));
}
static int64_t grid_get_texture_rect(int64_t self) {
	return r_cast<int64_t>(new Rect{r_cast<Grid*>(self)->getTextureRect()});
}
static void grid_set_texture(int64_t self, int64_t var) {
	r_cast<Grid*>(self)->setTexture(r_cast<Texture2D*>(var));
}
static int64_t grid_get_texture(int64_t self) {
	return from_object(r_cast<Grid*>(self)->getTexture());
}
static void grid_set_pos(int64_t self, int32_t x, int32_t y, int64_t pos, float z) {
	r_cast<Grid*>(self)->setPos(s_cast<int>(x), s_cast<int>(y), vec2_from(pos), z);
}
static int64_t grid_get_pos(int64_t self, int32_t x, int32_t y) {
	return vec2_retain(r_cast<Grid*>(self)->getPos(s_cast<int>(x), s_cast<int>(y)));
}
static void grid_set_color(int64_t self, int32_t x, int32_t y, int32_t color) {
	r_cast<Grid*>(self)->setColor(s_cast<int>(x), s_cast<int>(y), Color(s_cast<uint32_t>(color)));
}
static int32_t grid_get_color(int64_t self, int32_t x, int32_t y) {
	return r_cast<Grid*>(self)->getColor(s_cast<int>(x), s_cast<int>(y)).toARGB();
}
static void grid_move_uv(int64_t self, int32_t x, int32_t y, int64_t offset) {
	r_cast<Grid*>(self)->moveUV(s_cast<int>(x), s_cast<int>(y), vec2_from(offset));
}
static int64_t grid_new(float width, float height, int32_t grid_x, int32_t grid_y) {
	return from_object(Grid::create(width, height, s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
static int64_t grid_with_texture_rect(int64_t texture, int64_t texture_rect, int32_t grid_x, int32_t grid_y) {
	return from_object(Grid::create(r_cast<Texture2D*>(texture), *r_cast<Rect*>(texture_rect), s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
static int64_t grid_with_texture(int64_t texture, int32_t grid_x, int32_t grid_y) {
	return from_object(Grid::create(r_cast<Texture2D*>(texture), s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
static int64_t grid_with_file(int64_t clip_str, int32_t grid_x, int32_t grid_y) {
	return from_object(Grid::from(*str_from(clip_str), s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
static void linkGrid(wasm3::module3& mod) {
	mod.link_optional("*", "grid_type", grid_type);
	mod.link_optional("*", "grid_get_grid_x", grid_get_grid_x);
	mod.link_optional("*", "grid_get_grid_y", grid_get_grid_y);
	mod.link_optional("*", "grid_set_depth_write", grid_set_depth_write);
	mod.link_optional("*", "grid_is_depth_write", grid_is_depth_write);
	mod.link_optional("*", "grid__set_blend_func", grid__set_blend_func);
	mod.link_optional("*", "grid__get_blend_func", grid__get_blend_func);
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