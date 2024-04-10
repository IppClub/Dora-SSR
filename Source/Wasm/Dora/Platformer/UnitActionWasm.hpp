/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static void platformer_unitaction_set_reaction(int64_t self, float var) {
	r_cast<Platformer::UnitAction*>(self)->reaction = s_cast<float>(var);
}
static float platformer_unitaction_get_reaction(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->reaction;
}
static void platformer_unitaction_set_recovery(int64_t self, float var) {
	r_cast<Platformer::UnitAction*>(self)->recovery = s_cast<float>(var);
}
static float platformer_unitaction_get_recovery(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->recovery;
}
static int64_t platformer_unitaction_get_name(int64_t self) {
	return str_retain(r_cast<Platformer::UnitAction*>(self)->getName());
}
static int32_t platformer_unitaction_is_doing(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->isDoing() ? 1 : 0;
}
static int64_t platformer_unitaction_get_owner(int64_t self) {
	return from_object(r_cast<Platformer::UnitAction*>(self)->getOwner());
}
static float platformer_unitaction_get_elapsed_time(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->getElapsedTime();
}
static void platformer_unitaction_clear() {
	Platformer::UnitAction::clear();
}
static void platformer_unitaction_add(int64_t name, int32_t priority, float reaction, float recovery, int32_t queued, int32_t func, int64_t stack, int32_t func1, int64_t stack1, int32_t func2, int64_t stack2) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	std::shared_ptr<void> deref1(nullptr, [func1](auto) {
		SharedWasmRuntime.deref(func1);
	});
	auto args1 = r_cast<CallStack*>(stack1);
	std::shared_ptr<void> deref2(nullptr, [func2](auto) {
		SharedWasmRuntime.deref(func2);
	});
	auto args2 = r_cast<CallStack*>(stack2);
	platformer_wasm_unit_action_add(*str_from(name), s_cast<int>(priority), reaction, recovery, queued != 0, [func, args, deref](Platformer::Unit* owner, Platformer::UnitAction* action) {
		args->clear();
		args->push(owner);
		args->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}, [func1, args1, deref1](Platformer::Unit* owner, Platformer::UnitAction* action) {
		args1->clear();
		args1->push(owner);
		args1->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func1);
		return s_cast<Platformer::WasmActionUpdate*>(std::get<Object*>(args1->pop()));
	}, [func2, args2, deref2](Platformer::Unit* owner, Platformer::UnitAction* action) {
		args2->clear();
		args2->push(owner);
		args2->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func2);
	});
}
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