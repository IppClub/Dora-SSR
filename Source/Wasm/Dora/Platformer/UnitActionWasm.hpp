/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
void platformer_unitaction_set_reaction(int64_t self, float val) {
	r_cast<Platformer::UnitAction*>(self)->reaction = s_cast<float>(val);
}
float platformer_unitaction_get_reaction(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->reaction;
}
void platformer_unitaction_set_recovery(int64_t self, float val) {
	r_cast<Platformer::UnitAction*>(self)->recovery = s_cast<float>(val);
}
float platformer_unitaction_get_recovery(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->recovery;
}
int64_t platformer_unitaction_get_name(int64_t self) {
	return Str_Retain(r_cast<Platformer::UnitAction*>(self)->getName());
}
int32_t platformer_unitaction_is_doing(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->isDoing() ? 1 : 0;
}
int64_t platformer_unitaction_get_owner(int64_t self) {
	return Object_From(r_cast<Platformer::UnitAction*>(self)->getOwner());
}
float platformer_unitaction_get_elapsed_time(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->getElapsedTime();
}
void platformer_unitaction_clear() {
	Platformer::UnitAction::clear();
}
void platformer_unitaction_add(int64_t name, int32_t priority, float reaction, float recovery, int32_t queued, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1, int32_t func2, int64_t stack2) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	std::shared_ptr<void> deref1(nullptr, [func1](auto) {
		SharedWasmRuntime.deref(func1);
	});
	auto args1 = r_cast<CallStack*>(stack1);
	std::shared_ptr<void> deref2(nullptr, [func2](auto) {
		SharedWasmRuntime.deref(func2);
	});
	auto args2 = r_cast<CallStack*>(stack2);
	Platformer_UnitAction_Add(*Str_From(name), s_cast<int>(priority), reaction, recovery, queued != 0, [func0, args0, deref0](Platformer::Unit* owner, Platformer::UnitAction* action) {
		args0->clear();
		args0->push(owner);
		args0->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}, [func1, args1, deref1](Platformer::Unit* owner, Platformer::UnitAction* action) {
		args1->clear();
		args1->push(owner);
		args1->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func1);
		return args1->empty()? Platformer::WasmActionUpdate::create([](Platformer::Unit*, Platformer::UnitAction*, float) { return true; }) : s_cast<Platformer::WasmActionUpdate*>(std::get<Object*>(args1->pop()));
	}, [func2, args2, deref2](Platformer::Unit* owner, Platformer::UnitAction* action) {
		args2->clear();
		args2->push(owner);
		args2->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func2);
	});
}
} // extern "C"

static void linkPlatformerUnitAction(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_unitaction_set_reaction", platformer_unitaction_set_reaction);
	mod.link_optional("*", "platformer_unitaction_get_reaction", platformer_unitaction_get_reaction);
	mod.link_optional("*", "platformer_unitaction_set_recovery", platformer_unitaction_set_recovery);
	mod.link_optional("*", "platformer_unitaction_get_recovery", platformer_unitaction_get_recovery);
	mod.link_optional("*", "platformer_unitaction_get_name", platformer_unitaction_get_name);
	mod.link_optional("*", "platformer_unitaction_is_doing", platformer_unitaction_is_doing);
	mod.link_optional("*", "platformer_unitaction_get_owner", platformer_unitaction_get_owner);
	mod.link_optional("*", "platformer_unitaction_get_elapsed_time", platformer_unitaction_get_elapsed_time);
	mod.link_optional("*", "platformer_unitaction_clear", platformer_unitaction_clear);
	mod.link_optional("*", "platformer_unitaction_add", platformer_unitaction_add);
}