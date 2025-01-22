/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t platformer_actionupdate_type() {
	return DoraType<Platformer::WasmActionUpdate>();
}
int64_t platformer_wasmactionupdate_new(int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return Object_From(Platformer::WasmActionUpdate::create([func0, args0, deref0](Platformer::Unit* owner, Platformer::UnitAction* action, float deltaTime) {
		args0->clear();
		args0->push(owner);
		args0->push(r_cast<int64_t>(action));
		args0->push(deltaTime);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(true);
	}));
}
} // extern "C"

static void linkPlatformerWasmActionUpdate(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_actionupdate_type", platformer_actionupdate_type);
	mod.link_optional("*", "platformer_wasmactionupdate_new", platformer_wasmactionupdate_new);
}