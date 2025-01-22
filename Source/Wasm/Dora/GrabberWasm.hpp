/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t grabber_type() {
	return DoraType<Grabber>();
}
void grabber_set_camera(int64_t self, int64_t val) {
	r_cast<Grabber*>(self)->setCamera(r_cast<Camera*>(val));
}
int64_t grabber_get_camera(int64_t self) {
	return Object_From(r_cast<Grabber*>(self)->getCamera());
}
void grabber_set_effect(int64_t self, int64_t val) {
	r_cast<Grabber*>(self)->setEffect(r_cast<SpriteEffect*>(val));
}
int64_t grabber_get_effect(int64_t self) {
	return Object_From(r_cast<Grabber*>(self)->getEffect());
}
void grabber_set_blend_func(int64_t self, int64_t val) {
	r_cast<Grabber*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(val)));
}
int64_t grabber_get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<Grabber*>(self)->getBlendFunc().toValue());
}
void grabber_set_clear_color(int64_t self, int32_t val) {
	r_cast<Grabber*>(self)->setClearColor(Color(s_cast<uint32_t>(val)));
}
int32_t grabber_get_clear_color(int64_t self) {
	return r_cast<Grabber*>(self)->getClearColor().toARGB();
}
void grabber_set_pos(int64_t self, int32_t x, int32_t y, int64_t pos, float z) {
	r_cast<Grabber*>(self)->setPos(s_cast<int>(x), s_cast<int>(y), Vec2_From(pos), z);
}
int64_t grabber_get_pos(int64_t self, int32_t x, int32_t y) {
	return Vec2_Retain(r_cast<Grabber*>(self)->getPos(s_cast<int>(x), s_cast<int>(y)));
}
void grabber_set_color(int64_t self, int32_t x, int32_t y, int32_t color) {
	r_cast<Grabber*>(self)->setColor(s_cast<int>(x), s_cast<int>(y), Color(s_cast<uint32_t>(color)));
}
int32_t grabber_get_color(int64_t self, int32_t x, int32_t y) {
	return r_cast<Grabber*>(self)->getColor(s_cast<int>(x), s_cast<int>(y)).toARGB();
}
void grabber_move_uv(int64_t self, int32_t x, int32_t y, int64_t offset) {
	r_cast<Grabber*>(self)->moveUV(s_cast<int>(x), s_cast<int>(y), Vec2_From(offset));
}
} // extern "C"

static void linkGrabber(wasm3::module3& mod) {
	mod.link_optional("*", "grabber_type", grabber_type);
	mod.link_optional("*", "grabber_set_camera", grabber_set_camera);
	mod.link_optional("*", "grabber_get_camera", grabber_get_camera);
	mod.link_optional("*", "grabber_set_effect", grabber_set_effect);
	mod.link_optional("*", "grabber_get_effect", grabber_get_effect);
	mod.link_optional("*", "grabber_set_blend_func", grabber_set_blend_func);
	mod.link_optional("*", "grabber_get_blend_func", grabber_get_blend_func);
	mod.link_optional("*", "grabber_set_clear_color", grabber_set_clear_color);
	mod.link_optional("*", "grabber_get_clear_color", grabber_get_clear_color);
	mod.link_optional("*", "grabber_set_pos", grabber_set_pos);
	mod.link_optional("*", "grabber_get_pos", grabber_get_pos);
	mod.link_optional("*", "grabber_set_color", grabber_set_color);
	mod.link_optional("*", "grabber_get_color", grabber_get_color);
	mod.link_optional("*", "grabber_move_uv", grabber_move_uv);
}