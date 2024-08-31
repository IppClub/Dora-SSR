/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t platformer_actionupdate_type() {
	return DoraType<Platformer::WasmActionUpdate>();
}
int64_t platformer_wasmactionupdate_new(int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return Object_From(Platformer::WasmActionUpdate::create([func, args, deref](Platformer::Unit* owner, Platformer::UnitAction* action, float deltaTime) {
		args->clear();
		args->push(owner);
		args->push(r_cast<int64_t>(action));
		args->push(deltaTime);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}));
}
} // extern "C"

static void linkPlatformerWasmActionUpdate(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_actionupdate_type", platformer_actionupdate_type);
	mod.link_optional("*", "platformer_wasmactionupdate_new", platformer_wasmactionupdate_new);
}