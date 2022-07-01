/* Copyright (c) 2022 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Dorothy.h"
#include "Wasm/WasmRuntime.h"
#include "Lua/LuaManual.h"

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

static int64_t value_create_i32(int32_t value)
{
	return r_cast<int64_t>(new dora_val_t(value));
}

static int64_t value_create_i64(int64_t value)
{
	return r_cast<int64_t>(new dora_val_t(value));
}

static int64_t value_create_f32(float value)
{
	return r_cast<int64_t>(new dora_val_t(value));
}

static int64_t value_create_f64(double value)
{
	return r_cast<int64_t>(new dora_val_t(value));
}

static int64_t value_create_str(int64_t value)
{
	return r_cast<int64_t>(new dora_val_t(value));
}

static int64_t value_create_bool(int32_t value)
{
	return r_cast<int64_t>(new dora_val_t(value));
}

static int64_t value_create_object(int64_t value)
{
	return r_cast<int64_t>(new dora_val_t(r_cast<Object*>(value)));
}

static int64_t value_create_vec2(int64_t value)
{
	return r_cast<int64_t>(new dora_val_t(LightWasmValue{value}.vec2));
}

static int64_t value_create_size(int64_t value)
{
	return r_cast<int64_t>(new dora_val_t(LightWasmValue{value}.size));
}

static void value_release(int64_t value)
{
	delete r_cast<dora_val_t*>(value);
}

static int32_t value_into_i32(int64_t value)
{
	return std::get<int32_t>(*r_cast<dora_val_t*>(value));
}

static int64_t value_into_i64(int64_t value)
{
	return std::get<int64_t>(*r_cast<dora_val_t*>(value));
}

static float value_into_f32(int64_t value)
{
	return std::get<float>(*r_cast<dora_val_t*>(value));
}

static double value_into_f64(int64_t value)
{
	return std::get<double>(*r_cast<dora_val_t*>(value));
}

static int64_t value_into_str(int64_t value)
{
	auto str = std::get<std::string>(*r_cast<dora_val_t*>(value));
	return r_cast<int64_t>(new std::string(str));
}

static int32_t value_into_bool(int64_t value)
{
	return std::get<bool>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int64_t value_into_object(int64_t value)
{
	return r_cast<int64_t>(std::get<Object*>(*r_cast<dora_val_t*>(value)));
}

static int64_t value_into_vec2(int64_t value)
{
	return LightWasmValue{std::get<Vec2>(*r_cast<dora_val_t*>(value))}.value;
}

static int64_t value_into_size(int64_t value)
{
	return LightWasmValue{std::get<Size>(*r_cast<dora_val_t*>(value))}.value;
}

static int32_t value_is_i32(int64_t value)
{
	return std::holds_alternative<int32_t>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_i64(int64_t value)
{
	return std::holds_alternative<int64_t>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_f32(int64_t value)
{
	return std::holds_alternative<float>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_f64(int64_t value)
{
	return std::holds_alternative<double>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_str(int64_t value)
{
	return std::holds_alternative<std::string>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_bool(int64_t value)
{
	return std::holds_alternative<bool>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_object(int64_t value)
{
	return std::holds_alternative<Object*>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_vec2(int64_t value)
{
	return std::holds_alternative<Vec2>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_size(int64_t value)
{
	return std::holds_alternative<Size>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

void CallInfo::push(int32_t value) { _queue.push(value); }
void CallInfo::push(int64_t value) { _queue.push(value); }
void CallInfo::push(float value) { _queue.push(value); }
void CallInfo::push(double value) { _queue.push(value); }
void CallInfo::push(bool value) { _queue.push(value); }
void CallInfo::push(String value) { _queue.push(value.toString()); }
void CallInfo::push(Object* value) { _queue.push(value); }
void CallInfo::push(const Vec2& value) { _queue.push(value); }
void CallInfo::push(const Size& value) { _queue.push(value); }
void CallInfo::push_v(dora_val_t value) { _queue.push(value); }

bool CallInfo::empty() const
{
	return _queue.empty();
}

dora_val_t CallInfo::pop()
{
	auto var = _queue.front();
	_queue.pop();
	return var;
}

dora_val_t& CallInfo::front()
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

static void call_info_push_vec2(int64_t info, int64_t value)
{
	r_cast<CallInfo*>(info)->push(LightWasmValue{value}.vec2);
}

static void call_info_push_size(int64_t info, int64_t value)
{
	r_cast<CallInfo*>(info)->push(LightWasmValue{value}.size);
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

static int64_t call_info_pop_vec2(int64_t call_info)
{
	return LightWasmValue{std::get<Vec2>(r_cast<CallInfo*>(call_info)->pop())}.value;
}

static int64_t call_info_pop_size(int64_t call_info)
{
	return LightWasmValue{std::get<Size>(r_cast<CallInfo*>(call_info)->pop())}.value;
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

static int32_t call_info_front_vec2(int64_t info)
{
	return std::holds_alternative<Vec2>(r_cast<CallInfo*>(info)->front()) ? 1 : 0;
}

static int32_t call_info_front_size(int64_t info)
{
	return std::holds_alternative<Size>(r_cast<CallInfo*>(info)->front()) ? 1 : 0;
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

static void node_set_position(int64_t node, int64_t var)
{
	r_cast<Node*>(node)->setPosition(LightWasmValue{var}.vec2);
}

static int64_t node_get_position(int64_t node)
{
	return LightWasmValue{r_cast<Node*>(node)->getPosition()}.value;
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

static int64_t node_get_children(int64_t node)
{
	if (auto children = r_cast<Node*>(node)->getChildren())
	{
		children->retain();
		return r_cast<int64_t>(children);
	}
	return 0;
}

static int64_t node_get_userdata(int64_t node)
{
	auto userData = r_cast<Node*>(node)->getUserData();
	userData->retain();
	return r_cast<int64_t>(userData);
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

static Own<Value> to_value(const dora_val_t& v)
{
	Own<Value> ov;
	std::visit([&](auto&& arg)
	{
		ov = Value::alloc(arg);
	}, v);
	return ov;
}

static int64_t from_value(Value* v)
{
	switch (v->getType())
	{
		case ValueType::Integral:
			return r_cast<int64_t>(new dora_val_t(v->toVal<int64_t>()));
		case ValueType::FloatingPoint:
			return r_cast<int64_t>(new dora_val_t(v->toVal<double>()));
		case ValueType::Boolean:
			return r_cast<int64_t>(new dora_val_t(v->toVal<bool>()));
		case ValueType::Object:
		{
			auto obj = v->to<Object>();
			obj->retain();
			return r_cast<int64_t>(new dora_val_t(obj));
		}
		case ValueType::Struct:
		{
			if (auto str = v->asVal<std::string>())
			{
				return r_cast<int64_t>(new dora_val_t(*str));
			}
			else if (auto vec2 = v->asVal<Vec2>())
			{
				return r_cast<int64_t>(new dora_val_t(*vec2));
			}
			else if (auto size = v->asVal<Size>())
			{
				return r_cast<int64_t>(new dora_val_t(*size));
			}
		}
	}
	return 0;
}

static int32_t array_type()
{
	return DoraType<Array>();
}

static int64_t array_create()
{
	auto array = Array::create();
	array->retain();
	return r_cast<int64_t>(array);
}

static int32_t array_set(int64_t array, int32_t index, int64_t v)
{
	auto arr = r_cast<Array*>(array);
	if (0 <= index && index < s_cast<int32_t>(arr->getCount()))
	{
		arr->set(index, to_value(*r_cast<dora_val_t*>(v)));
		return 1;
	}
	return 0;
}

static int64_t array_get(int64_t array, int32_t index)
{
	auto arr = r_cast<Array*>(array);
	if (0 <= index && index < s_cast<int32_t>(arr->getCount()))
	{
		return from_value(arr->get(index).get());
	}
	return 0;
}

static int32_t array_len(int64_t array)
{
	return s_cast<int32_t>(r_cast<Array*>(array)->getCount());
}

static int32_t array_capacity(int64_t array)
{
	return s_cast<int32_t>(r_cast<Array*>(array)->getCapacity());
}

static int32_t array_is_empty(int64_t array)
{
	return r_cast<Array*>(array)->isEmpty() ? 1 : 0;
}

static void array_add_range(int64_t array, int64_t other)
{
	r_cast<Array*>(array)->addRange(r_cast<Array*>(other));
}

static void array_remove_from(int64_t array, int64_t other)
{
	r_cast<Array*>(array)->removeFrom(r_cast<Array*>(other));
}

static void array_clear(int64_t array)
{
	r_cast<Array*>(array)->clear();
}

static void array_reverse(int64_t array)
{
	r_cast<Array*>(array)->reverse();
}

static void array_shrink(int64_t array)
{
	r_cast<Array*>(array)->shrink();
}

static void array_swap(int64_t array, int32_t indexA, int32_t indexB)
{
	r_cast<Array*>(array)->swap(indexA, indexB);
}

static int32_t array_remove_at(int64_t array, int32_t index)
{
	return r_cast<Array*>(array)->removeAt(index) ? 1 : 0;
}

static int32_t array_fast_remove_at(int64_t array, int32_t index)
{
	return r_cast<Array*>(array)->fastRemoveAt(index) ? 1 : 0;
}

static int64_t array_first(int64_t array)
{
	auto arr = r_cast<Array*>(array);
	if (!arr->isEmpty())
	{
		return from_value(arr->getFirst().get());
	}
	return 0;
}

static int64_t array_last(int64_t array)
{
	auto arr = r_cast<Array*>(array);
	if (!arr->isEmpty())
	{
		return from_value(arr->getLast().get());
	}
	return 0;
}

static int64_t array_random_object(int64_t array)
{
	auto arr = r_cast<Array*>(array);
	if (!arr->isEmpty())
	{
		return from_value(arr->getRandomObject().get());
	}
	return 0;
}

static void array_add(int64_t array, int64_t item)
{
	r_cast<Array*>(array)->add(to_value(*r_cast<dora_val_t*>(item)));
}

static void array_insert(int64_t array, int32_t index, int64_t item)
{
	r_cast<Array*>(array)->insert(index, to_value(*r_cast<dora_val_t*>(item)));
}

static int32_t array_contains(int64_t array, int64_t item)
{
	return r_cast<Array*>(array)->contains(to_value(*r_cast<dora_val_t*>(item)).get()) ? 1 : 0;
}

static int32_t array_index(int64_t array, int64_t item)
{
	return r_cast<Array*>(array)->index(to_value(*r_cast<dora_val_t*>(item)).get()) ? 1 : 0;
}

static int64_t array_remove_last(int64_t array)
{
	auto arr = r_cast<Array*>(array);
	if (arr->isEmpty()) return 0;
	return from_value(r_cast<Array*>(array)->removeLast().get());
}

static int32_t array_fast_remove(int64_t array, int64_t item)
{
	return r_cast<Array*>(array)->fastRemove(to_value(*r_cast<dora_val_t*>(item)).get()) ? 1 : 0;
}

static int32_t dictionary_type()
{
	return DoraType<Dictionary>();
}

static int64_t dictionary_create()
{
	auto dict = Dictionary::create();
	dict->retain();
	return r_cast<int64_t>(dict);
}

static void dictionary_set(int64_t dict, int64_t key, int64_t value)
{
	std::unique_ptr<std::string> k(r_cast<std::string*>(key));
	auto d = r_cast<Dictionary*>(dict);
	d->set(*k, to_value(*r_cast<dora_val_t*>(value)));
}

static int64_t dictionary_get(int64_t dict, int64_t key)
{
	std::unique_ptr<std::string> k(r_cast<std::string*>(key));
	auto d = r_cast<Dictionary*>(dict);
	return from_value(d->get(*k).get());
}

static int32_t dictionary_len(int64_t dict)
{
	return r_cast<Dictionary*>(dict)->getCount();
}

static int64_t dictionary_get_keys(int64_t dict)
{
	auto keys = __Dictionary_getKeys(r_cast<Dictionary*>(dict));
	keys->retain();
	return r_cast<int64_t>(keys);
}

void dictionary_clear(int64_t dict)
{
	r_cast<Dictionary*>(dict)->clear();
}

static int64_t director_get_entry()
{
	auto entry = SharedDirector.getEntry();
	entry->retain();
	return r_cast<int64_t>(entry);
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

	mod.link_optional("*", "value_create_i32", value_create_i32);
	mod.link_optional("*", "value_create_i64", value_create_i64);
	mod.link_optional("*", "value_create_f32", value_create_f32);
	mod.link_optional("*", "value_create_f64", value_create_f64);
	mod.link_optional("*", "value_create_str", value_create_str);
	mod.link_optional("*", "value_create_bool", value_create_bool);
	mod.link_optional("*", "value_create_object", value_create_object);
	mod.link_optional("*", "value_create_vec2", value_create_vec2);
	mod.link_optional("*", "value_create_size", value_create_size);
	mod.link_optional("*", "value_release", value_release);
	mod.link_optional("*", "value_into_i32", value_into_i32);
	mod.link_optional("*", "value_into_i64", value_into_i64);
	mod.link_optional("*", "value_into_f32", value_into_f32);
	mod.link_optional("*", "value_into_f64", value_into_f64);
	mod.link_optional("*", "value_into_str", value_into_str);
	mod.link_optional("*", "value_into_bool", value_into_bool);
	mod.link_optional("*", "value_into_object", value_into_object);
	mod.link_optional("*", "value_into_vec2", value_into_vec2);
	mod.link_optional("*", "value_into_size", value_into_size);
	mod.link_optional("*", "value_is_i32", value_is_i32);
	mod.link_optional("*", "value_is_i64", value_is_i64);
	mod.link_optional("*", "value_is_f32", value_is_f32);
	mod.link_optional("*", "value_is_f64", value_is_f64);
	mod.link_optional("*", "value_is_str", value_is_str);
	mod.link_optional("*", "value_is_bool", value_is_bool);
	mod.link_optional("*", "value_is_object", value_is_object);
	mod.link_optional("*", "value_is_vec2", value_is_vec2);
	mod.link_optional("*", "value_is_size", value_is_size);

	mod.link_optional("*", "call_info_create", call_info_create);
	mod.link_optional("*", "call_info_release", call_info_release);
	mod.link_optional("*", "call_info_push_i32", call_info_push_i32);
	mod.link_optional("*", "call_info_push_i64", call_info_push_i64);
	mod.link_optional("*", "call_info_push_f32", call_info_push_f32);
	mod.link_optional("*", "call_info_push_f64", call_info_push_f64);
	mod.link_optional("*", "call_info_push_str", call_info_push_str);
	mod.link_optional("*", "call_info_push_bool", call_info_push_bool);
	mod.link_optional("*", "call_info_push_object", call_info_push_object);
	mod.link_optional("*", "call_info_push_vec2", call_info_push_vec2);
	mod.link_optional("*", "call_info_push_size", call_info_push_size);
	mod.link_optional("*", "call_info_pop_i32", call_info_pop_i32);
	mod.link_optional("*", "call_info_pop_i64", call_info_pop_i64);
	mod.link_optional("*", "call_info_pop_f32", call_info_pop_f32);
	mod.link_optional("*", "call_info_pop_f64", call_info_pop_f64);
	mod.link_optional("*", "call_info_pop_str", call_info_pop_str);
	mod.link_optional("*", "call_info_pop_bool", call_info_pop_bool);
	mod.link_optional("*", "call_info_pop_object", call_info_pop_object);
	mod.link_optional("*", "call_info_pop_vec2", call_info_pop_vec2);
	mod.link_optional("*", "call_info_pop_size", call_info_pop_size);
	mod.link_optional("*", "call_info_front_i32", call_info_front_i32);
	mod.link_optional("*", "call_info_front_i64", call_info_front_i64);
	mod.link_optional("*", "call_info_front_f32", call_info_front_f32);
	mod.link_optional("*", "call_info_front_f64", call_info_front_f64);
	mod.link_optional("*", "call_info_front_str", call_info_front_str);
	mod.link_optional("*", "call_info_front_bool", call_info_front_bool);
	mod.link_optional("*", "call_info_front_object", call_info_front_object);
	mod.link_optional("*", "call_info_front_vec2", call_info_front_vec2);
	mod.link_optional("*", "call_info_front_size", call_info_front_size);

	mod.link_optional("*", "array_type", array_type);
	mod.link_optional("*", "array_create", array_create);
	mod.link_optional("*", "array_set", array_set);
	mod.link_optional("*", "array_get", array_get);
	mod.link_optional("*", "array_len", array_len);
	mod.link_optional("*", "array_capacity", array_capacity);
	mod.link_optional("*", "array_is_empty", array_is_empty);
	mod.link_optional("*", "array_add_range", array_add_range);
	mod.link_optional("*", "array_remove_from", array_remove_from);
	mod.link_optional("*", "array_clear", array_clear);
	mod.link_optional("*", "array_reverse", array_reverse);
	mod.link_optional("*", "array_shrink", array_shrink);
	mod.link_optional("*", "array_swap", array_swap);
	mod.link_optional("*", "array_remove_at", array_remove_at);
	mod.link_optional("*", "array_fast_remove_at", array_fast_remove_at);
	mod.link_optional("*", "array_first", array_first);
	mod.link_optional("*", "array_last", array_last);
	mod.link_optional("*", "array_random_object", array_random_object);
	mod.link_optional("*", "array_add", array_add);
	mod.link_optional("*", "array_insert", array_insert);
	mod.link_optional("*", "array_contains", array_contains);
	mod.link_optional("*", "array_index", array_index);
	mod.link_optional("*", "array_remove_last", array_remove_last);
	mod.link_optional("*", "array_fast_remove", array_fast_remove);

	mod.link_optional("*", "dictionary_type", dictionary_type);
	mod.link_optional("*", "dictionary_create", dictionary_create);
	mod.link_optional("*", "dictionary_set", dictionary_set);
	mod.link_optional("*", "dictionary_get", dictionary_get);
	mod.link_optional("*", "dictionary_len", dictionary_len);
	mod.link_optional("*", "dictionary_get_keys", dictionary_get_keys);
	mod.link_optional("*", "dictionary_clear", dictionary_clear);

	mod.link_optional("*", "node_type", node_type);
	mod.link_optional("*", "node_create", node_create);
	mod.link_optional("*", "node_set_x", node_set_x);
	mod.link_optional("*", "node_get_x", node_get_x);
	mod.link_optional("*", "node_set_position", node_set_position);
	mod.link_optional("*", "node_get_position", node_get_position);
	mod.link_optional("*", "node_set_tag", node_set_tag);
	mod.link_optional("*", "node_get_tag", node_get_tag);
	mod.link_optional("*", "node_get_children", node_get_children);
	mod.link_optional("*", "node_get_userdata", node_get_userdata);
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
		auto mod = _env.parse_module(_wasm.first.get(), _wasm.second);
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
				auto mainFn = New<wasm3::function>(_runtime.find_function("_start"));
				return Values::alloc(std::move(mod), std::move(mainFn));
			}
			catch (std::runtime_error& e)
			{
				Error("failed to load wasm module: {}, due to: {}", file, e.what());
				return Values::alloc(Own<wasm3::module>(), Own<wasm3::function>());
			}
		}, [file, handler, this](Own<Values> values)
		{
			try
			{
				Own<wasm3::module> mod;
				Own<wasm3::function> mainFn;
				values->get(mod, mainFn);
				if (mod)
				{
					mainFn->call_argv();
					handler(true);
				}
				else handler(false);
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
