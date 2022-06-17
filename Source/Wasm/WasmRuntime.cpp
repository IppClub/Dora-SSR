/* Copyright (c) 2022 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Dorothy.h"
#include "Wasm/WasmRuntime.h"

NS_DOROTHY_BEGIN

static int64_t str_retain(String str)
{
	return r_cast<int64_t>(new std::string(str.rawData(), str.size()));
}

static int64_t str_new(int32_t len)
{
	return r_cast<int64_t>(new std::string(len, 0));
}

static int32_t str_len(int64_t str)
{
	return s_cast<int32_t>(r_cast<std::string*>(str)->length());
}

static void str_read(void* dest, int64_t src)
{
	auto str = r_cast<std::string*>(src);
	std::memcpy(dest, str->c_str(), str->length());
}

static void str_write(int64_t dest, const void* src)
{
	auto str = r_cast<std::string*>(dest);
	std::memcpy(&str->front(), src, str->length());
}

static void str_release(int64_t str)
{
	delete r_cast<std::string*>(str);
}

static int32_t object_get_id(int64_t obj)
{
	return s_cast<int32_t>(r_cast<Object*>(obj)->getId());
}

static int32_t object_get_type(int64_t obj)
{
	if (obj) return r_cast<Object*>(obj)->getDoraType();
	return 0;
}

static void object_release(int64_t obj)
{
	r_cast<Object*>(obj)->release();
}

void CallInfo::push(int32_t value) { _queue.push(value); }
void CallInfo::push(int64_t value) { _queue.push(value); }
void CallInfo::push(float value) { _queue.push(value); }
void CallInfo::push(double value) { _queue.push(value); }
void CallInfo::push(bool value) { _queue.push(value); }
void CallInfo::push(String value) { _queue.push(value.toString()); }
void CallInfo::push(Object* value) { _queue.push(value); }
void CallInfo::push(const Vec2& value) { _queue.push(value); }
void CallInfo::push_v(var_t value) { _queue.push(value); }

bool CallInfo::empty() const
{
	return _queue.empty();
}

CallInfo::var_t CallInfo::pop()
{
	auto var = _queue.front();
	_queue.pop();
	return var;
}

CallInfo::var_t& CallInfo::front()
{
	return _queue.front();
}

static int64_t call_info_create()
{
	return r_cast<int64_t>(new CallInfo());
}

static void call_info_release(int64_t stack)
{
	delete r_cast<CallInfo*>(stack);
}

static void call_info_push_i32(int64_t info, int32_t value)
{
	r_cast<CallInfo*>(info)->push(value);
}

static void call_info_push_i64(int64_t info, int64_t value)
{
	r_cast<CallInfo*>(info)->push(value);
}

static void call_info_push_f32(int64_t info, float value)
{
	r_cast<CallInfo*>(info)->push(value);
}

static void call_info_push_f64(int64_t info, double value)
{
	r_cast<CallInfo*>(info)->push(value);
}

static void call_info_push_str(int64_t info, int64_t value)
{
	std::unique_ptr<std::string> ptr(r_cast<std::string*>(value));
	r_cast<CallInfo*>(info)->push(*ptr);
}

static void call_info_push_bool(int64_t info, int32_t value)
{
	r_cast<CallInfo*>(info)->push(value > 0);
}

static void call_info_push_object(int64_t info, int64_t value)
{
	r_cast<CallInfo*>(info)->push(r_cast<Object*>(value));
}

static int32_t call_info_pop_i32(int64_t info)
{
	return std::get<int32_t>(r_cast<CallInfo*>(info)->pop());
}

static int64_t call_info_pop_i64(int64_t call_info)
{
	return std::get<int64_t>(r_cast<CallInfo*>(call_info)->pop());
}

static float call_info_pop_f32(int64_t call_info)
{
	return std::get<float>(r_cast<CallInfo*>(call_info)->pop());
}

static double call_info_pop_f64(int64_t call_info)
{
	return std::get<double>(r_cast<CallInfo*>(call_info)->pop());
}

static int64_t call_info_pop_str(int64_t call_info)
{
	return r_cast<int64_t>(new std::string(std::get<std::string>(r_cast<CallInfo*>(call_info)->pop())));
}

static int32_t call_info_pop_bool(int64_t call_info)
{
	return std::get<bool>(r_cast<CallInfo*>(call_info)->pop()) ? 1 : 0;
}

static int64_t call_info_pop_object(int64_t call_info)
{
	return r_cast<int64_t>(std::get<Object*>(r_cast<CallInfo*>(call_info)->pop()));
}

static int32_t call_info_front_i32(int64_t info)
{
	return std::holds_alternative<int32_t>(r_cast<CallInfo*>(info)->front()) ? 1 : 0;
}

static int32_t call_info_front_i64(int64_t info)
{
	return std::holds_alternative<int64_t>(r_cast<CallInfo*>(info)->front()) ? 1 : 0;
}

static int32_t call_info_front_f32(int64_t info)
{
	return std::holds_alternative<float>(r_cast<CallInfo*>(info)->front()) ? 1 : 0;
}

static int32_t call_info_front_f64(int64_t info)
{
	return std::holds_alternative<double>(r_cast<CallInfo*>(info)->front()) ? 1 : 0;
}

static int32_t call_info_front_bool(int64_t info)
{
	return std::holds_alternative<bool>(r_cast<CallInfo*>(info)->front()) ? 1 : 0;
}

static int32_t call_info_front_str(int64_t info)
{
	return std::holds_alternative<std::string>(r_cast<CallInfo*>(info)->front()) ? 1 : 0;
}

static int32_t call_info_front_object(int64_t info)
{
	return std::holds_alternative<Object*>(r_cast<CallInfo*>(info)->front()) ? 1 : 0;
}

static int32_t node_type()
{
	return DoraType<Node>();
}

static int64_t node_create()
{
	auto node = Node::create();
	node->retain();
	return r_cast<int64_t>(node);
}

static void node_set_x(int64_t node, float var)
{
	r_cast<Node*>(node)->setX(var);
}

static float node_get_x(int64_t node)
{
	return r_cast<Node*>(node)->getX();
}

static void node_set_tag(int64_t node, int64_t var)
{
	std::unique_ptr<std::string> ptr(r_cast<std::string*>(var));
	r_cast<Node*>(node)->setTag(*ptr);
}

static int64_t node_get_tag(int64_t node)
{
	return str_retain(r_cast<Node*>(node)->getTag());
}

static void node_add_child(int64_t node, int64_t child)
{
	r_cast<Node*>(node)->addChild(r_cast<Node*>(child));
}

static void node_schedule(int64_t node, int32_t func, int64_t stack)
{
	std::shared_ptr<void> deref(nullptr, [func](auto)
	{
		SharedWasmRuntime.deref(func);
	});
	r_cast<Node*>(node)->schedule([func, stack, deref](double deltaTime)
	{
		auto info = r_cast<CallInfo*>(stack);
		info->push(deltaTime);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(info->pop());
	});
}

static void node_emit(int64_t node, int64_t name, int64_t stack)
{
	std::unique_ptr<std::string> ptr(r_cast<std::string*>(name));
	WasmEventArgs event(*ptr, r_cast<CallInfo*>(stack));
	r_cast<Node*>(node)->emit(&event);
}

static void node_slot(int64_t node, int64_t name, int32_t func, int64_t stack)
{
	std::unique_ptr<std::string> ptr(r_cast<std::string*>(name));
	std::shared_ptr<void> deref(nullptr, [func](auto)
	{
		SharedWasmRuntime.deref(func);
	});
	r_cast<Node*>(node)->slot(*ptr, [func, stack, deref](Event* e)
	{
		auto info = r_cast<CallInfo*>(stack);
		e->pushArgsToWasm(info);
		SharedWasmRuntime.invoke(func);
	});
}

static int64_t director_get_entry()
{
	return r_cast<int64_t>(SharedDirector.getEntry());
}

static void linkDoraModule(wasm3::module& mod)
{
	mod.link_optional("*", "str_new", str_new);
	mod.link_optional("*", "str_len", str_len);
	mod.link_optional("*", "str_read", str_read);
	mod.link_optional("*", "str_write", str_write);
	mod.link_optional("*", "str_release", str_release);

	mod.link_optional("*", "object_get_id", object_get_id);
	mod.link_optional("*", "object_get_type", object_get_type);
	mod.link_optional("*", "object_release", object_release);

	mod.link_optional("*", "call_info_create", call_info_create);
	mod.link_optional("*", "call_info_release", call_info_release);
	mod.link_optional("*", "call_info_push_i32", call_info_push_i32);
	mod.link_optional("*", "call_info_push_i64", call_info_push_i64);
	mod.link_optional("*", "call_info_push_f32", call_info_push_f32);
	mod.link_optional("*", "call_info_push_f64", call_info_push_f64);
	mod.link_optional("*", "call_info_push_str", call_info_push_str);
	mod.link_optional("*", "call_info_push_bool", call_info_push_bool);
	mod.link_optional("*", "call_info_push_object", call_info_push_object);
	mod.link_optional("*", "call_info_pop_i32", call_info_pop_i32);
	mod.link_optional("*", "call_info_pop_i64", call_info_pop_i64);
	mod.link_optional("*", "call_info_pop_f32", call_info_pop_f32);
	mod.link_optional("*", "call_info_pop_f64", call_info_pop_f64);
	mod.link_optional("*", "call_info_pop_str", call_info_pop_str);
	mod.link_optional("*", "call_info_pop_bool", call_info_pop_bool);
	mod.link_optional("*", "call_info_pop_object", call_info_pop_object);
	mod.link_optional("*", "call_info_front_i32", call_info_front_i32);
	mod.link_optional("*", "call_info_front_i64", call_info_front_i64);
	mod.link_optional("*", "call_info_front_f32", call_info_front_f32);
	mod.link_optional("*", "call_info_front_f64", call_info_front_f64);
	mod.link_optional("*", "call_info_front_str", call_info_front_str);
	mod.link_optional("*", "call_info_front_bool", call_info_front_bool);
	mod.link_optional("*", "call_info_front_object", call_info_front_object);

	mod.link_optional("*", "node_type", node_type);
	mod.link_optional("*", "node_create", node_create);
	mod.link_optional("*", "node_set_x", node_set_x);
	mod.link_optional("*", "node_get_x", node_get_x);
	mod.link_optional("*", "node_set_tag", node_set_tag);
	mod.link_optional("*", "node_get_tag", node_get_tag);
	mod.link_optional("*", "node_add_child", node_add_child);
	mod.link_optional("*", "node_schedule", node_schedule);
	mod.link_optional("*", "node_emit", node_emit);
	mod.link_optional("*", "node_slot", node_slot);

	mod.link_optional("*", "director_get_entry", director_get_entry);
}

WasmRuntime::WasmRuntime():
_runtime(_env.new_runtime(1024 * 1024))
{ }

WasmRuntime::~WasmRuntime()
{ }

bool WasmRuntime::executeMainFile(String filename)
{
	if (_wasm.first)
	{
		Warn("only one wasm module can be executed.");
		return false;
	}
	try
	{
		_wasm = SharedContent.load(filename);
		wasm3::module mod = _env.parse_module(_wasm.first.get(), _wasm.second);
		_runtime.load(mod);
		mod.link_default();
		linkDoraModule(mod);
		_callFunc = New<wasm3::function>(_runtime.find_function("call_function"));
		_derefFunc = New<wasm3::function>(_runtime.find_function("deref_function"));
		wasm3::function mainFn = _runtime.find_function("_start");
		mainFn.call_argv();
		return true;
	}
	catch (std::runtime_error& e)
	{
		Error("failed to load wasm module: {}", e.what());
		return false;
	}
}

void WasmRuntime::executeMainFileAsync(String filename, const std::function<void(bool)>& handler)
{
	if (_wasm.first)
	{
		Warn("only one wasm module can be executed.");
		return;
	}
	auto file = filename.toString();
	SharedContent.loadAsyncData(filename, [file, handler, this](OwnArray<uint8_t>&& data, size_t size)
	{
		if (!data)
		{
			Warn("failed to load wasm file \"{}\".", file);
			handler(false);
			return;
		}
		_wasm = {std::move(data), size};
		SharedAsyncThread.run([file, this]
		{
			try
			{
				auto mod = New<wasm3::module>(_env.parse_module(_wasm.first.get(), _wasm.second));
				_runtime.load(*mod);
				mod->link_default();
				linkDoraModule(*mod);
				_callFunc = New<wasm3::function>(_runtime.find_function("call_function"));
				_derefFunc = New<wasm3::function>(_runtime.find_function("deref_function"));
				return Values::alloc(std::move(mod));
			}
			catch (std::runtime_error& e)
			{
				Error("failed to load wasm module: {}, due to: {}", file, e.what());
				return Values::alloc(Own<wasm3::module>());
			}
		}, [file, handler, this](Own<Values> values)
		{
			try
			{
				Own<wasm3::module> mod;
				values->get(mod);
				wasm3::function mainFn = _runtime.find_function("_start");
				mainFn.call_argv();
				handler(true);
			}
			catch (std::runtime_error& e)
			{
				Error("failed to execute wasm module: {}, due to: {}", file, e.what());
				handler(false);
			}
		});
	});
}

void WasmRuntime::invoke(int32_t funcId)
{
	_callFunc->call(funcId);
}

void WasmRuntime::deref(int32_t funcId)
{
	_derefFunc->call(funcId);
}

NS_DOROTHY_END
