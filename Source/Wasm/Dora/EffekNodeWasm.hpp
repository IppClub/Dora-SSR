/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t effeknode_type() {
	return DoraType<EffekNode>();
}
DORA_EXPORT int32_t effeknode_play(int64_t self, int64_t filename, int64_t pos, float z) {
	return s_cast<int32_t>(r_cast<EffekNode*>(self)->play(*Str_From(filename), Vec2_From(pos), z));
}
DORA_EXPORT void effeknode_stop(int64_t self, int32_t handle) {
	r_cast<EffekNode*>(self)->stop(s_cast<int>(handle));
}
DORA_EXPORT int64_t effeknode_new() {
	return Object_From(EffekNode::create());
}
} // extern "C"

static void linkEffekNode(wasm3::module3& mod) {
	mod.link_optional("*", "effeknode_type", effeknode_type);
	mod.link_optional("*", "effeknode_play", effeknode_play);
	mod.link_optional("*", "effeknode_stop", effeknode_stop);
	mod.link_optional("*", "effeknode_new", effeknode_new);
}