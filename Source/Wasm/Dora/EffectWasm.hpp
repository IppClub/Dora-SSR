/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t effect_type() {
	return DoraType<Effect>();
}
DORA_EXPORT void effect_add(int64_t self, int64_t pass) {
	r_cast<Effect*>(self)->add(r_cast<Pass*>(pass));
}
DORA_EXPORT int64_t effect_get(int64_t self, int64_t index) {
	return Object_From(Effect_GetPass(r_cast<Effect*>(self), s_cast<int64_t>(index)));
}
DORA_EXPORT void effect_clear(int64_t self) {
	r_cast<Effect*>(self)->clear();
}
DORA_EXPORT int64_t effect_new(int64_t vert_shader, int64_t frag_shader) {
	return Object_From(Effect::create(*Str_From(vert_shader), *Str_From(frag_shader)));
}
} // extern "C"

static void linkEffect(wasm3::module3& mod) {
	mod.link_optional("*", "effect_type", effect_type);
	mod.link_optional("*", "effect_add", effect_add);
	mod.link_optional("*", "effect_get", effect_get);
	mod.link_optional("*", "effect_clear", effect_clear);
	mod.link_optional("*", "effect_new", effect_new);
}