/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t sprite_type() {
	return DoraType<Sprite>();
}
DORA_EXPORT void sprite_set_depth_write(int64_t self, int32_t val) {
	r_cast<Sprite*>(self)->setDepthWrite(val != 0);
}
DORA_EXPORT int32_t sprite_is_depth_write(int64_t self) {
	return r_cast<Sprite*>(self)->isDepthWrite() ? 1 : 0;
}
DORA_EXPORT void sprite_set_alpha_ref(int64_t self, float val) {
	r_cast<Sprite*>(self)->setAlphaRef(val);
}
DORA_EXPORT float sprite_get_alpha_ref(int64_t self) {
	return r_cast<Sprite*>(self)->getAlphaRef();
}
DORA_EXPORT void sprite_set_texture_rect(int64_t self, int64_t val) {
	r_cast<Sprite*>(self)->setTextureRect(*r_cast<Rect*>(val));
}
DORA_EXPORT int64_t sprite_get_texture_rect(int64_t self) {
	return r_cast<int64_t>(new Rect{r_cast<Sprite*>(self)->getTextureRect()});
}
DORA_EXPORT int64_t sprite_get_texture(int64_t self) {
	return Object_From(r_cast<Sprite*>(self)->getTexture());
}
DORA_EXPORT void sprite_set_blend_func(int64_t self, int64_t val) {
	r_cast<Sprite*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(val)));
}
DORA_EXPORT int64_t sprite_get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<Sprite*>(self)->getBlendFunc().toValue());
}
DORA_EXPORT void sprite_set_effect(int64_t self, int64_t val) {
	r_cast<Sprite*>(self)->setEffect(r_cast<SpriteEffect*>(val));
}
DORA_EXPORT int64_t sprite_get_effect(int64_t self) {
	return Object_From(r_cast<Sprite*>(self)->getEffect());
}
DORA_EXPORT void sprite_set_uwrap(int64_t self, int32_t val) {
	r_cast<Sprite*>(self)->setUWrap(s_cast<TextureWrap>(val));
}
DORA_EXPORT int32_t sprite_get_uwrap(int64_t self) {
	return s_cast<int32_t>(r_cast<Sprite*>(self)->getUWrap());
}
DORA_EXPORT void sprite_set_vwrap(int64_t self, int32_t val) {
	r_cast<Sprite*>(self)->setVWrap(s_cast<TextureWrap>(val));
}
DORA_EXPORT int32_t sprite_get_vwrap(int64_t self) {
	return s_cast<int32_t>(r_cast<Sprite*>(self)->getVWrap());
}
DORA_EXPORT void sprite_set_filter(int64_t self, int32_t val) {
	r_cast<Sprite*>(self)->setFilter(s_cast<TextureFilter>(val));
}
DORA_EXPORT int32_t sprite_get_filter(int64_t self) {
	return s_cast<int32_t>(r_cast<Sprite*>(self)->getFilter());
}
DORA_EXPORT void sprite_set_effect_as_default(int64_t self) {
	Sprite_SetEffectNullptr(r_cast<Sprite*>(self));
}
DORA_EXPORT int64_t sprite_new() {
	return Object_From(Sprite::create());
}
DORA_EXPORT int64_t sprite_with_texture_rect(int64_t texture, int64_t texture_rect) {
	return Object_From(Sprite::create(r_cast<Texture2D*>(texture), *r_cast<Rect*>(texture_rect)));
}
DORA_EXPORT int64_t sprite_with_texture(int64_t texture) {
	return Object_From(Sprite::create(r_cast<Texture2D*>(texture)));
}
DORA_EXPORT int64_t sprite_with_file(int64_t clip_str) {
	return Object_From(Sprite::from(*Str_From(clip_str)));
}
} // extern "C"

static void linkSprite(wasm3::module3& mod) {
	mod.link_optional("*", "sprite_type", sprite_type);
	mod.link_optional("*", "sprite_set_depth_write", sprite_set_depth_write);
	mod.link_optional("*", "sprite_is_depth_write", sprite_is_depth_write);
	mod.link_optional("*", "sprite_set_alpha_ref", sprite_set_alpha_ref);
	mod.link_optional("*", "sprite_get_alpha_ref", sprite_get_alpha_ref);
	mod.link_optional("*", "sprite_set_texture_rect", sprite_set_texture_rect);
	mod.link_optional("*", "sprite_get_texture_rect", sprite_get_texture_rect);
	mod.link_optional("*", "sprite_get_texture", sprite_get_texture);
	mod.link_optional("*", "sprite_set_blend_func", sprite_set_blend_func);
	mod.link_optional("*", "sprite_get_blend_func", sprite_get_blend_func);
	mod.link_optional("*", "sprite_set_effect", sprite_set_effect);
	mod.link_optional("*", "sprite_get_effect", sprite_get_effect);
	mod.link_optional("*", "sprite_set_uwrap", sprite_set_uwrap);
	mod.link_optional("*", "sprite_get_uwrap", sprite_get_uwrap);
	mod.link_optional("*", "sprite_set_vwrap", sprite_set_vwrap);
	mod.link_optional("*", "sprite_get_vwrap", sprite_get_vwrap);
	mod.link_optional("*", "sprite_set_filter", sprite_set_filter);
	mod.link_optional("*", "sprite_get_filter", sprite_get_filter);
	mod.link_optional("*", "sprite_set_effect_as_default", sprite_set_effect_as_default);
	mod.link_optional("*", "sprite_new", sprite_new);
	mod.link_optional("*", "sprite_with_texture_rect", sprite_with_texture_rect);
	mod.link_optional("*", "sprite_with_texture", sprite_with_texture);
	mod.link_optional("*", "sprite_with_file", sprite_with_file);
}