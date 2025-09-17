/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t particle_type() {
	return DoraType<ParticleNode>();
}
DORA_EXPORT int32_t particlenode_is_active(int64_t self) {
	return r_cast<ParticleNode*>(self)->isActive() ? 1 : 0;
}
DORA_EXPORT void particlenode_start(int64_t self) {
	r_cast<ParticleNode*>(self)->start();
}
DORA_EXPORT void particlenode_stop(int64_t self) {
	r_cast<ParticleNode*>(self)->stop();
}
DORA_EXPORT int64_t particlenode_new(int64_t filename) {
	return Object_From(ParticleNode::create(*Str_From(filename)));
}
} // extern "C"

static void linkParticleNode(wasm3::module3& mod) {
	mod.link_optional("*", "particle_type", particle_type);
	mod.link_optional("*", "particlenode_is_active", particlenode_is_active);
	mod.link_optional("*", "particlenode_start", particlenode_start);
	mod.link_optional("*", "particlenode_stop", particlenode_stop);
	mod.link_optional("*", "particlenode_new", particlenode_new);
}