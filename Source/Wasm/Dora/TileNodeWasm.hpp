/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t tilenode_type() {
	return DoraType<TileNode>();
}
DORA_EXPORT void tilenode_set_depth_write(int64_t self, int32_t val) {
	r_cast<TileNode*>(self)->setDepthWrite(val != 0);
}
DORA_EXPORT int32_t tilenode_is_depth_write(int64_t self) {
	return r_cast<TileNode*>(self)->isDepthWrite() ? 1 : 0;
}
DORA_EXPORT void tilenode_set_blend_func(int64_t self, int64_t val) {
	r_cast<TileNode*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(val)));
}
DORA_EXPORT int64_t tilenode_get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<TileNode*>(self)->getBlendFunc().toValue());
}
DORA_EXPORT void tilenode_set_effect(int64_t self, int64_t val) {
	r_cast<TileNode*>(self)->setEffect(r_cast<SpriteEffect*>(val));
}
DORA_EXPORT int64_t tilenode_get_effect(int64_t self) {
	return Object_From(r_cast<TileNode*>(self)->getEffect());
}
DORA_EXPORT void tilenode_set_filter(int64_t self, int32_t val) {
	r_cast<TileNode*>(self)->setFilter(s_cast<TextureFilter>(val));
}
DORA_EXPORT int32_t tilenode_get_filter(int64_t self) {
	return s_cast<int32_t>(r_cast<TileNode*>(self)->getFilter());
}
DORA_EXPORT int64_t tilenode_get_layer(int64_t self, int64_t layer_name) {
	return Object_From(r_cast<TileNode*>(self)->getLayer(*Str_From(layer_name)));
}
DORA_EXPORT int64_t tilenode_new(int64_t tmx_file) {
	return Object_From(TileNode::create(*Str_From(tmx_file)));
}
DORA_EXPORT int64_t tilenode_with_with_layer(int64_t tmx_file, int64_t layer_name) {
	return Object_From(TileNode::create(*Str_From(tmx_file), *Str_From(layer_name)));
}
DORA_EXPORT int64_t tilenode_with_with_layers(int64_t tmx_file, int64_t layer_names) {
	return Object_From(TileNode::create(*Str_From(tmx_file), Vec_FromStr(layer_names)));
}
} // extern "C"

static void linkTileNode(wasm3::module3& mod) {
	mod.link_optional("*", "tilenode_type", tilenode_type);
	mod.link_optional("*", "tilenode_set_depth_write", tilenode_set_depth_write);
	mod.link_optional("*", "tilenode_is_depth_write", tilenode_is_depth_write);
	mod.link_optional("*", "tilenode_set_blend_func", tilenode_set_blend_func);
	mod.link_optional("*", "tilenode_get_blend_func", tilenode_get_blend_func);
	mod.link_optional("*", "tilenode_set_effect", tilenode_set_effect);
	mod.link_optional("*", "tilenode_get_effect", tilenode_get_effect);
	mod.link_optional("*", "tilenode_set_filter", tilenode_set_filter);
	mod.link_optional("*", "tilenode_get_filter", tilenode_get_filter);
	mod.link_optional("*", "tilenode_get_layer", tilenode_get_layer);
	mod.link_optional("*", "tilenode_new", tilenode_new);
	mod.link_optional("*", "tilenode_with_with_layer", tilenode_with_with_layer);
	mod.link_optional("*", "tilenode_with_with_layers", tilenode_with_with_layers);
}