/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t entity_type() {
	return DoraType<Entity>();
}
DORA_EXPORT int32_t entity_get_count() {
	return s_cast<int32_t>(Entity::getCount());
}
DORA_EXPORT int32_t entity_get_index(int64_t self) {
	return s_cast<int32_t>(r_cast<Entity*>(self)->getIndex());
}
DORA_EXPORT void entity_clear() {
	Entity::clear();
}
DORA_EXPORT void entity_remove(int64_t self, int64_t key) {
	r_cast<Entity*>(self)->remove(*Str_From(key));
}
DORA_EXPORT void entity_destroy(int64_t self) {
	r_cast<Entity*>(self)->destroy();
}
DORA_EXPORT int64_t entity_new() {
	return Object_From(Entity::create());
}
} // extern "C"

static void linkEntity(wasm3::module3& mod) {
	mod.link_optional("*", "entity_type", entity_type);
	mod.link_optional("*", "entity_get_count", entity_get_count);
	mod.link_optional("*", "entity_get_index", entity_get_index);
	mod.link_optional("*", "entity_clear", entity_clear);
	mod.link_optional("*", "entity_remove", entity_remove);
	mod.link_optional("*", "entity_destroy", entity_destroy);
	mod.link_optional("*", "entity_new", entity_new);
}