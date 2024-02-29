/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Wasm/WasmRuntime.h"

#include "Dora.h"
#include "GUI/ImGuiBinding.h"

NS_DORA_BEGIN

union LightWasmValue {
	Vec2 vec2;
	Size size;
	int64_t value;
	explicit LightWasmValue(const Size& v)
		: size(v) { }
	explicit LightWasmValue(const Vec2& v)
		: vec2(v) { }
	explicit LightWasmValue(int64_t v)
		: value(v) { }
};

static_assert(sizeof(LightWasmValue) == sizeof(int64_t), "encode item with greater size than int64_t for wasm.");

static inline int64_t vec2_retain(const Vec2& vec2) {
	return LightWasmValue{vec2}.value;
}

static inline Vec2 vec2_from(int64_t value) {
	return LightWasmValue{value}.vec2;
}

static inline int64_t size_retain(const Size& size) {
	return LightWasmValue{size}.value;
}

static inline Size size_from(int64_t value) {
	return LightWasmValue{value}.size;
}

static int64_t str_retain(String str) {
	return r_cast<int64_t>(new std::string(str.rawData(), str.size()));
}

static std::unique_ptr<std::string> str_from(int64_t var) {
	return std::unique_ptr<std::string>(r_cast<std::string*>(var));
}

static int64_t str_new(int32_t len) {
	return r_cast<int64_t>(new std::string(len, 0));
}

static int32_t str_len(int64_t str) {
	return s_cast<int32_t>(r_cast<std::string*>(str)->length());
}

static void str_read(void* dest, int64_t src) {
	auto str = r_cast<std::string*>(src);
	std::memcpy(dest, str->c_str(), str->length());
}

static void str_write(int64_t dest, const void* src) {
	auto str = r_cast<std::string*>(dest);
	std::memcpy(&str->front(), src, str->length());
}

static void str_release(int64_t str) {
	delete r_cast<std::string*>(str);
}

using dora_vec_t = std::variant<
	std::vector<int32_t>,
	std::vector<int64_t>,
	std::vector<float>,
	std::vector<double>>;

static int64_t buf_retain(dora_vec_t&& vec) {
	auto new_vec = new dora_vec_t(std::move(vec));
	return r_cast<int64_t>(new_vec);
}

static int64_t buf_new_i32(int32_t len) {
	auto new_vec = new dora_vec_t(std::vector<int32_t>(len));
	return r_cast<int64_t>(new_vec);
}

static int64_t buf_new_i64(int32_t len) {
	auto new_vec = new dora_vec_t(std::vector<int64_t>(len));
	return r_cast<int64_t>(new_vec);
}

static int64_t buf_new_f32(int32_t len) {
	auto new_vec = new dora_vec_t(std::vector<float>(len));
	return r_cast<int64_t>(new_vec);
}

static int64_t buf_new_f64(int32_t len) {
	auto new_vec = new dora_vec_t(std::vector<double>(len));
	return r_cast<int64_t>(new_vec);
}

static int32_t buf_len(int64_t v) {
	auto vec = r_cast<dora_vec_t*>(v);
	int32_t size = 0;
	std::visit([&](const auto& arg) {
		size = s_cast<int32_t>(arg.size());
	},
		*vec);
	return size;
}

static void buf_read(void* dest, int64_t src) {
	auto vec = r_cast<dora_vec_t*>(src);
	std::visit([&](const auto& arg) {
		std::memcpy(dest, arg.data(), arg.size() * sizeof(arg[0]));
	},
		*vec);
}

static void buf_write(int64_t dest, const void* src) {
	auto vec = r_cast<dora_vec_t*>(dest);
	std::visit([&](auto& arg) {
		std::memcpy(&arg.front(), src, arg.size() * sizeof(arg[0]));
	},
		*vec);
}

static void buf_release(int64_t v) {
	delete r_cast<dora_vec_t*>(v);
}

static int64_t to_vec(const std::vector<Slice>& vec) {
	std::vector<int64_t> buf(vec.size());
	for (size_t i = 0; i < vec.size(); i++) {
		buf[i] = str_retain(vec[i]);
	}
	return buf_retain(dora_vec_t(std::move(buf)));
}

static int64_t to_vec(const std::vector<std::string>& vec) {
	std::vector<int64_t> buf(vec.size());
	for (size_t i = 0; i < vec.size(); i++) {
		buf[i] = str_retain(vec[i]);
	}
	return buf_retain(dora_vec_t(std::move(buf)));
}

static int64_t to_vec(const std::list<std::string>& vec) {
	std::vector<int64_t> buf;
	buf.reserve(vec.size());
	for (const auto& item : vec) {
		buf.push_back(str_retain(item));
	}
	return buf_retain(dora_vec_t(std::move(buf)));
}

static int64_t to_vec(const std::vector<uint32_t>& vec) {
	std::vector<int32_t> buf;
	buf.reserve(vec.size());
	for (const auto& item : vec) {
		buf.push_back(s_cast<int32_t>(item));
	}
	return buf_retain(dora_vec_t(std::move(buf)));
}

static std::vector<std::string> from_str_vec(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<std::string> strs;
	strs.reserve(vecInt.size());
	for (auto item : vecInt) {
		strs.push_back(*str_from(item));
	}
	return strs;
}

static std::vector<Vec2> from_vec2_vec(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<Vec2> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(vec2_from(item));
	}
	return vs;
}

static std::vector<uint32_t> from_uint32_vec(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int32_t>>(*vec);
	std::vector<uint32_t> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(s_cast<uint32_t>(item));
	}
	return vs;
}

static std::vector<VertexColor> from_vertex_color_vec(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<VertexColor> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(*r_cast<VertexColor*>(item));
	}
	return vs;
}

using ActionDef = Own<ActionDuration>;
static std::vector<ActionDef> from_action_def_vec(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<ActionDef> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(std::move(*r_cast<ActionDef*>(item)));
	}
	return vs;
}

static std::vector<Platformer::Behavior::Leaf*> from_btree_vec(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<Platformer::Behavior::Leaf*> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(r_cast<Platformer::Behavior::Leaf*>(item));
	}
	return vs;
}

static std::vector<Platformer::Decision::Leaf*> from_dtree_vec(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<Platformer::Decision::Leaf*> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(r_cast<Platformer::Decision::Leaf*>(item));
	}
	return vs;
}

static int32_t object_get_id(int64_t obj) {
	return s_cast<int32_t>(r_cast<Object*>(obj)->getId());
}

static int32_t object_get_type(int64_t obj) {
	if (obj) return r_cast<Object*>(obj)->getDoraType();
	return 0;
}

static void object_retain(int64_t obj) {
	r_cast<Object*>(obj)->retain();
}

static void object_release(int64_t obj) {
	r_cast<Object*>(obj)->release();
}

static int64_t from_object(Object* obj) {
	if (obj) obj->retain();
	return r_cast<int64_t>(obj);
}

static int64_t value_create_i64(int64_t value) {
	return r_cast<int64_t>(new dora_val_t(value));
}

static int64_t value_create_f64(double value) {
	return r_cast<int64_t>(new dora_val_t(value));
}

static int64_t value_create_str(int64_t value) {
	return r_cast<int64_t>(new dora_val_t(value));
}

static int64_t value_create_bool(int32_t value) {
	return r_cast<int64_t>(new dora_val_t(value != 0));
}

static int64_t value_create_object(int64_t value) {
	auto obj = r_cast<Object*>(value);
	obj->retain();
	return r_cast<int64_t>(new dora_val_t(obj));
}

static int64_t value_create_vec2(int64_t value) {
	return r_cast<int64_t>(new dora_val_t(vec2_from(value)));
}

static int64_t value_create_size(int64_t value) {
	return r_cast<int64_t>(new dora_val_t(size_from(value)));
}

static void value_release(int64_t value) {
	auto v = r_cast<dora_val_t*>(value);
	if (std::holds_alternative<Object*>(*v)) {
		std::get<Object*>(*v)->release();
	}
	delete v;
}

static int64_t value_into_i64(int64_t value) {
	return std::get<int64_t>(*r_cast<dora_val_t*>(value));
}

static double value_into_f64(int64_t value) {
	const auto& v = *r_cast<dora_val_t*>(value);
	if (std::holds_alternative<int64_t>(v)) {
		return s_cast<double>(std::get<int64_t>(v));
	}
	return std::get<double>(v);
}

static int64_t value_into_str(int64_t value) {
	auto str = std::get<std::string>(*r_cast<dora_val_t*>(value));
	return r_cast<int64_t>(new std::string(str));
}

static int32_t value_into_bool(int64_t value) {
	return std::get<bool>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int64_t value_into_object(int64_t value) {
	return from_object(std::get<Object*>(*r_cast<dora_val_t*>(value)));
}

static int64_t value_into_vec2(int64_t value) {
	return vec2_retain(std::get<Vec2>(*r_cast<dora_val_t*>(value)));
}

static int64_t value_into_size(int64_t value) {
	return size_retain(std::get<Size>(*r_cast<dora_val_t*>(value)));
}

static int32_t value_is_i64(int64_t value) {
	return std::holds_alternative<int64_t>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_f64(int64_t value) {
	const auto& v = *r_cast<dora_val_t*>(value);
	return std::holds_alternative<double>(v) || std::holds_alternative<int64_t>(v) ? 1 : 0;
}

static int32_t value_is_str(int64_t value) {
	return std::holds_alternative<std::string>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_bool(int64_t value) {
	return std::holds_alternative<bool>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_object(int64_t value) {
	return std::holds_alternative<Object*>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_vec2(int64_t value) {
	return std::holds_alternative<Vec2>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

static int32_t value_is_size(int64_t value) {
	return std::holds_alternative<Size>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

void CallStack::push(int64_t value) { _stack.push_back(value); }
void CallStack::push(double value) { _stack.push_back(value); }
void CallStack::push(bool value) { _stack.push_back(value); }
void CallStack::push(String value) { _stack.push_back(value.toString()); }
void CallStack::push(Object* value) { _stack.push_back(value); }
void CallStack::push(const Vec2& value) { _stack.push_back(value); }
void CallStack::push(const Size& value) { _stack.push_back(value); }
void CallStack::push_v(dora_val_t value) { _stack.push_back(value); }

bool CallStack::empty() const {
	return _stack.empty();
}

dora_val_t CallStack::pop() {
	auto var = _stack.front();
	_stack.pop_front();
	return var;
}

dora_val_t& CallStack::front() {
	return _stack.front();
}

void CallStack::clear() {
	_stack.clear();
}

static int64_t call_stack_create() {
	return r_cast<int64_t>(new CallStack());
}

static void call_stack_release(int64_t stack) {
	delete r_cast<CallStack*>(stack);
}

static void call_stack_push_i64(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(value);
}

static void call_stack_push_f64(int64_t stack, double value) {
	r_cast<CallStack*>(stack)->push(value);
}

static void call_stack_push_str(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(*str_from(value));
}

static void call_stack_push_bool(int64_t stack, int32_t value) {
	r_cast<CallStack*>(stack)->push(value != 0);
}

static void call_stack_push_object(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(r_cast<Object*>(value));
}

static void call_stack_push_vec2(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(vec2_from(value));
}

static void call_stack_push_size(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(size_from(value));
}

static int64_t call_stack_pop_i64(int64_t stack) {
	return std::get<int64_t>(r_cast<CallStack*>(stack)->pop());
}

static double call_stack_pop_f64(int64_t stack) {
	auto v = r_cast<CallStack*>(stack)->pop();
	if (std::holds_alternative<int64_t>(v)) {
		return s_cast<double>(std::get<int64_t>(v));
	}
	return std::get<double>(v);
}

static int64_t call_stack_pop_str(int64_t stack) {
	return str_retain(std::get<std::string>(r_cast<CallStack*>(stack)->pop()));
}

static int32_t call_stack_pop_bool(int64_t stack) {
	return std::get<bool>(r_cast<CallStack*>(stack)->pop()) ? 1 : 0;
}

static int64_t call_stack_pop_object(int64_t stack) {
	return from_object(std::get<Object*>(r_cast<CallStack*>(stack)->pop()));
}

static int64_t call_stack_pop_vec2(int64_t stack) {
	return vec2_retain(std::get<Vec2>(r_cast<CallStack*>(stack)->pop()));
}

static int64_t call_stack_pop_size(int64_t stack) {
	return size_retain(std::get<Size>(r_cast<CallStack*>(stack)->pop()));
}

static int32_t call_stack_pop(int64_t stack) {
	auto cs = r_cast<CallStack*>(stack);
	if (cs->empty()) return 0;
	cs->pop();
	return 1;
}

static int32_t call_stack_front_i64(int64_t stack) {
	return std::holds_alternative<int64_t>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}

static int32_t call_stack_front_f64(int64_t stack) {
	const auto& v = r_cast<CallStack*>(stack)->front();
	return std::holds_alternative<int64_t>(v) || std::holds_alternative<double>(v) ? 1 : 0;
}

static int32_t call_stack_front_bool(int64_t stack) {
	return std::holds_alternative<bool>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}

static int32_t call_stack_front_str(int64_t stack) {
	return std::holds_alternative<std::string>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}

static int32_t call_stack_front_object(int64_t stack) {
	return std::holds_alternative<Object*>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}

static int32_t call_stack_front_vec2(int64_t stack) {
	return std::holds_alternative<Vec2>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}

static int32_t call_stack_front_size(int64_t stack) {
	return std::holds_alternative<Size>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}

static Own<Value> to_value(const dora_val_t& v) {
	Own<Value> ov;
	std::visit([&](auto&& arg) {
		ov = Value::alloc(arg);
	},
		v);
	return ov;
}

static int64_t from_value(Value* v) {
	switch (v->getType()) {
		case ValueType::Integral:
			return r_cast<int64_t>(new dora_val_t(v->toVal<int64_t>()));
		case ValueType::FloatingPoint:
			return r_cast<int64_t>(new dora_val_t(v->toVal<double>()));
		case ValueType::Boolean:
			return r_cast<int64_t>(new dora_val_t(v->toVal<bool>()));
		case ValueType::Object: {
			auto obj = v->to<Object>();
			obj->retain();
			return r_cast<int64_t>(new dora_val_t(obj));
		}
		case ValueType::Struct: {
			if (auto str = v->asVal<std::string>()) {
				return r_cast<int64_t>(new dora_val_t(*str));
			} else if (auto vec2 = v->asVal<Vec2>()) {
				return r_cast<int64_t>(new dora_val_t(*vec2));
			} else if (auto size = v->asVal<Size>()) {
				return r_cast<int64_t>(new dora_val_t(*size));
			}
		}
	}
	return 0;
}

static void push_value(CallStack* stack, Value* v) {
	switch (v->getType()) {
		case ValueType::Integral:
			stack->push(v->toVal<int64_t>());
			break;
		case ValueType::FloatingPoint:
			stack->push(v->toVal<double>());
			break;
		case ValueType::Boolean:
			stack->push(v->toVal<bool>());
			break;
		case ValueType::Object:
			stack->push(v->to<Object>());
			break;
		case ValueType::Struct: {
			if (auto str = v->asVal<std::string>()) {
				stack->push(*str);
				break;
			} else if (auto vec2 = v->asVal<Vec2>()) {
				stack->push(*vec2);
				break;
			} else if (auto size = v->asVal<Size>()) {
				stack->push(*size);
				break;
			} else
				stack->push_v(dora_val_t());
		}
	}
}

static void dora_print(int64_t var) {
	LogPrintInThread(*str_from(var));
}

/* Array */

static int32_t array_set(int64_t array, int32_t index, int64_t v) {
	auto arr = r_cast<Array*>(array);
	if (0 <= index && index < s_cast<int32_t>(arr->getCount())) {
		arr->set(index, to_value(*r_cast<dora_val_t*>(v)));
		return 1;
	}
	return 0;
}
static int64_t array_get(int64_t array, int32_t index) {
	auto arr = r_cast<Array*>(array);
	if (0 <= index && index < s_cast<int32_t>(arr->getCount())) {
		return from_value(arr->get(index).get());
	}
	return 0;
}
static int64_t array_first(int64_t array) {
	auto arr = r_cast<Array*>(array);
	if (!arr->isEmpty()) {
		return from_value(arr->getFirst().get());
	}
	return 0;
}
static int64_t array_last(int64_t array) {
	auto arr = r_cast<Array*>(array);
	if (!arr->isEmpty()) {
		return from_value(arr->getLast().get());
	}
	return 0;
}
static int64_t array_random_object(int64_t array) {
	auto arr = r_cast<Array*>(array);
	if (!arr->isEmpty()) {
		return from_value(arr->getRandomObject().get());
	}
	return 0;
}
static void array_add(int64_t array, int64_t item) {
	r_cast<Array*>(array)->add(to_value(*r_cast<dora_val_t*>(item)));
}
static void array_insert(int64_t array, int32_t index, int64_t item) {
	r_cast<Array*>(array)->insert(index, to_value(*r_cast<dora_val_t*>(item)));
}
static int32_t array_contains(int64_t array, int64_t item) {
	return r_cast<Array*>(array)->contains(to_value(*r_cast<dora_val_t*>(item)).get()) ? 1 : 0;
}
static int32_t array_index(int64_t array, int64_t item) {
	return r_cast<Array*>(array)->index(to_value(*r_cast<dora_val_t*>(item)).get());
}
static int64_t array_remove_last(int64_t array) {
	auto arr = r_cast<Array*>(array);
	if (arr->isEmpty()) return 0;
	return from_value(r_cast<Array*>(array)->removeLast().get());
}
static int32_t array_fast_remove(int64_t array, int64_t item) {
	return r_cast<Array*>(array)->fastRemove(to_value(*r_cast<dora_val_t*>(item)).get()) ? 1 : 0;
}

/* Dictionary */

static void dictionary_set(int64_t dict, int64_t key, int64_t value) {
	r_cast<Dictionary*>(dict)->set(*str_from(key), to_value(*r_cast<dora_val_t*>(value)));
}
static int64_t dictionary_get(int64_t dict, int64_t key) {
	return from_value(r_cast<Dictionary*>(dict)->get(*str_from(key)).get());
}

/* Rect */

inline const Rect& rect_get_zero() { return Rect::zero; }

/* Entity */

static void entity_set(int64_t e, int64_t k, int64_t v) {
	r_cast<Entity*>(e)->set(*str_from(k), to_value(*r_cast<dora_val_t*>(v)));
}
static int64_t entity_get(int64_t e, int64_t k) {
	if (auto com = r_cast<Entity*>(e)->getComponent(*str_from(k))) {
		return from_value(com);
	} else {
		return 0;
	}
}
static int64_t entity_get_old(int64_t e, int64_t k) {
	if (auto com = r_cast<Entity*>(e)->getOldCom(*str_from(k))) {
		return from_value(com);
	} else {
		return 0;
	}
}

// EntityGroup

static void group_watch(int64_t group, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	auto entityGroup = r_cast<EntityGroup*>(group);
	entityGroup->watch([entityGroup, func, args, deref](Entity* e) {
		args->clear();
		args->push(e);
		for (int index : entityGroup->getComponents()) {
			push_value(args, e->getComponent(index));
		}
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	});
}
static int64_t group_find(int64_t group, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return from_object(r_cast<EntityGroup*>(group)->find([func, args, deref](Entity* e) {
		args->clear();
		args->push(e);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}));
}

// EntityObserver

static void observer_watch(int64_t observer, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	auto entityObserver = r_cast<EntityObserver*>(observer);
	entityObserver->watch([entityObserver, func, args, deref](Entity* e) {
		args->clear();
		args->push(e);
		for (int index : entityObserver->getComponents()) {
			push_value(args, e->getComponent(index));
		}
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	});
}

// Node

using Grabber = Node::Grabber;
static void node_emit(int64_t node, int64_t name, int64_t stack) {
	WasmEventArgs event(*str_from(name), r_cast<CallStack*>(stack));
	r_cast<Node*>(node)->emit(&event);
}
static Grabber* node_start_grabbing(Node* node) {
	return node->grab(true);
}
static void node_stop_grabbing(Node* node) {
	node->grab(false);
}
static void node_set_transform_target_nullptr(Node* node) {
	node->setTransformTarget(nullptr);
}
static Action* node_run_action_def(Node* node, ActionDef def) {
	if (def) {
		auto action = Action::create(std::move(def));
		node->runAction(action);
		return action;
	}
	return nullptr;
}
static Action* node_perform_def(Node* node, ActionDef def) {
	if (def) {
		auto action = Action::create(std::move(def));
		node->perform(action);
		return action;
	}
	return nullptr;
}

// Texture2D

static inline Texture2D* texture_2d_create(String name) {
	return SharedTextureCache.load(name);
}

// Sprite

static inline void sprite_set_effect_nullptr(Sprite* self) {
	self->setEffect(nullptr);
}

// Platformer::PlatformCamera

static void platform_camera_set_follow_target_nullptr(Platformer::PlatformCamera* self) {
	self->setFollowTarget(nullptr);
}

// View

static void view_set_post_effect_nullptr() {
	SharedView.setPostEffect(nullptr);
}

// Effect

static Pass* effect_get_pass(Effect* self, size_t index) {
	const auto& passes = self->getPasses();
	if (index < passes.size()) {
		return self->get(index);
	}
	return nullptr;
}

// Action

#define action_def_prop PropertyAction::alloc
#define action_def_tint Tint::alloc
#define action_def_roll Roll::alloc
#define action_def_spawn Spawn::alloc
#define action_def_sequence Sequence::alloc
#define action_def_delay Delay::alloc
#define action_def_show Show::alloc
#define action_def_hide Hide::alloc
#define action_def_emit Emit::alloc
#define action_def_move Move::alloc
#define action_def_scale Scale::alloc

// Model

static std::string model_get_clip_filename(String filename) {
	if (ModelDef* modelDef = SharedModelCache.load(filename)) {
		return modelDef->getClipFile();
	}
	return Slice::Empty;
}
static std::vector<std::string> model_get_look_names(String filename) {
	if (ModelDef* modelDef = SharedModelCache.load(filename)) {
		return modelDef->getLookNames();
	}
	return std::vector<std::string>();
}
static std::vector<std::string> model_get_animation_names(String filename) {
	if (ModelDef* modelDef = SharedModelCache.load(filename)) {
		return modelDef->getAnimationNames();
	}
	return std::vector<std::string>();
}

// Spine

static std::vector<std::string> spine_get_look_names(String spineStr) {
	if (auto skelData = SharedSkeletonCache.load(spineStr)) {
		auto& skins = skelData->getSkel()->getSkins();
		std::vector<std::string> res;
		res.reserve(skins.size());
		for (size_t i = 0; i < skins.size(); i++) {
			const auto& name = skins[i]->getName();
			res.push_back(std::string(name.buffer(), name.length()));
		}
		return res;
	}
	return std::vector<std::string>();
}
static std::vector<std::string> spine_get_animation_names(String spineStr) {
	if (auto skelData = SharedSkeletonCache.load(spineStr)) {
		auto& anims = skelData->getSkel()->getAnimations();
		std::vector<std::string> res;
		res.reserve(anims.size());
		for (size_t i = 0; i < anims.size(); i++) {
			const auto& name = anims[i]->getName();
			res.push_back(std::string(name.buffer(), name.length()));
		}
		return res;
	}
	return std::vector<std::string>();
}

// DragonBones

static std::vector<std::string> dragon_bone_get_look_names(String boneStr) {
	auto boneData = SharedDragonBoneCache.load(boneStr);
	if (boneData.first) {
		if (boneData.second.empty()) {
			boneData.second = boneData.first->getArmatureNames().front();
		}
		const auto& skins = boneData.first->getArmature(boneData.second)->skins;
		std::vector<std::string> res;
		res.reserve(skins.size());
		for (const auto& item : skins) {
			res.push_back(item.first);
		}
		return res;
	}
	return std::vector<std::string>();
}
static std::vector<std::string> dragon_bone_get_animation_names(String boneStr) {
	auto boneData = SharedDragonBoneCache.load(boneStr);
	if (boneData.first) {
		if (boneData.second.empty()) {
			boneData.second = boneData.first->getArmatureNames().front();
		}
		return boneData.first->getArmature(boneData.second)->animationNames;
	}
	return std::vector<std::string>();
}

// QLearner

#define MLBuildDecisionTreeAsync ML::BuildDecisionTreeAsync
using MLQLearner = ML::QLearner;
using MLQState = ML::QLearner::QState;
using MLQAction = ML::QLearner::QAction;
static void ml_qlearner_visit_state_action_q(MLQLearner* qlearner, const std::function<void(MLQState, MLQAction, double)>& handler) {
	const auto& matrix = qlearner->getMatrix();
	for (const auto& row : matrix) {
		ML::QLearner::QState state = row.first;
		for (const auto& col : row.second) {
			ML::QLearner::QAction action = col.first;
			double q = col.second;
			handler(state, action, q);
		}
	}
}

// Blackboard

static void blackboard_set(int64_t b, int64_t k, int64_t v) {
	r_cast<Platformer::Behavior::Blackboard*>(b)->set(*str_from(k), to_value(*r_cast<dora_val_t*>(v)));
}
static int64_t blackboard_get(int64_t b, int64_t k) {
	if (auto value = r_cast<Platformer::Behavior::Blackboard*>(b)->get(*str_from(k))) {
		return from_value(value);
	} else {
		return 0;
	}
}

// Behavior

#define BSeq Platformer::Behavior::Seq
#define BSel Platformer::Behavior::Sel
#define BCon Platformer::Behavior::Con
#define BAct Platformer::Behavior::Act
#define BCommand Platformer::Behavior::Command
#define BWait Platformer::Behavior::Wait
#define BCountdown Platformer::Behavior::Countdown
#define BTimeout Platformer::Behavior::Timeout
#define BRepeat Platformer::Behavior::Repeat
#define BRetry Platformer::Behavior::Retry

// Decision

#define DSeq Platformer::Decision::Sel
#define DSel Platformer::Decision::Seq
#define DCon Platformer::Decision::Con
#define DAct Platformer::Decision::Act
#define DAccept Platformer::Decision::Accept
#define DReject Platformer::Decision::Reject
#define DBehave Platformer::Decision::Behave

// UnitAction

namespace Platformer {
class WasmActionUpdate {
public:
	WasmActionUpdate(const std::function<bool(Unit*, UnitAction*, float)>& update)
		: _update(update) { }
	bool operator()(Unit* owner, UnitAction* action, float deltaTime) {
		return _update(owner, action, deltaTime);
	}

private:
	std::function<bool(Unit*, UnitAction*, float)> _update;
};
class WasmUnitAction : public UnitAction {
public:
	WasmUnitAction(String name, int priority, bool queued, Unit* owner)
		: UnitAction(name, priority, queued, owner) { }
	virtual bool isAvailable() override {
		return _available(_owner, s_cast<UnitAction*>(this));
	}
	virtual void run() override {
		UnitAction::run();
		if (auto playable = _owner->getPlayable()) {
			playable->setRecovery(recovery);
		}
		_update = _create(_owner, s_cast<UnitAction*>(this));
		if (_update(_owner, s_cast<UnitAction*>(this), 0.0f)) {
			WasmUnitAction::stop();
		}
	}
	virtual void update(float dt) override {
		if (_update && _update(_owner, s_cast<UnitAction*>(this), dt)) {
			WasmUnitAction::stop();
		}
		UnitAction::update(dt);
	}
	virtual void stop() override {
		_update = nullptr;
		_stop(_owner, s_cast<UnitAction*>(this));
		UnitAction::stop();
	}

private:
	std::function<bool(Unit*, UnitAction*)> _available;
	std::function<WasmActionUpdate(Unit*, UnitAction*)> _create;
	std::function<bool(Unit*, UnitAction*, float)> _update;
	std::function<void(Unit*, UnitAction*)> _stop;
	friend class WasmActionDef;
};
class WasmActionDef : public UnitActionDef {
public:
	WasmActionDef(
		const std::function<bool(Unit*, UnitAction*)>& available,
		const std::function<WasmActionUpdate(Unit*, UnitAction*)>& create,
		const std::function<void(Unit*, UnitAction*)>& stop)
		: available(available)
		, create(create)
		, stop(stop) { }
	std::function<bool(Unit*, UnitAction*)> available;
	std::function<WasmActionUpdate(Unit*, UnitAction*)> create;
	std::function<void(Unit*, UnitAction*)> stop;
	virtual Own<UnitAction> toAction(Unit* unit) override {
		WasmUnitAction* action = new WasmUnitAction(name, priority, queued, unit);
		action->reaction = reaction;
		action->recovery = recovery;
		action->_available = available;
		action->_create = create;
		action->_stop = stop;
		return MakeOwn(s_cast<UnitAction*>(action));
	}
};
static void wasm_unit_action_add(
	String name, int priority, float reaction, float recovery, bool queued,
	const std::function<bool(Unit*, UnitAction*)>& available,
	const std::function<WasmActionUpdate(Unit*, UnitAction*)>& create,
	const std::function<void(Unit*, UnitAction*)>& stop) {
	UnitActionDef* actionDef = new WasmActionDef(available, create, stop);
	actionDef->name = name.toString();
	actionDef->priority = priority;
	actionDef->reaction = reaction;
	actionDef->recovery = recovery;
	actionDef->queued = queued;
	UnitAction::add(name, MakeOwn(actionDef));
}
} // namespace Platformer
#define platformer_wasm_unit_action_add Platformer::wasm_unit_action_add

// DB

struct DBParams {
	void add(Array* params) {
		auto& record = records.emplace_back();
		for (size_t i = 0; i < params->getCount(); ++i) {
			record.emplace_back(params->get(i)->clone());
		}
	}
	std::deque<std::vector<Own<Value>>> records;
};
struct DBRecord {
	bool read(Array* record) {
		if (records.empty()) return false;
		for (const auto& value : records.front()) {
			record->add(DB::col(value));
		}
		records.pop_front();
		return true;
	}
	std::deque<std::vector<DB::Col>> records;
};
struct DBQuery {
	void addWithParams(String sql, DBParams& params) {
		auto& query = queries.emplace_back();
		query.first = sql.toString();
		for (auto& rec : params.records) {
			query.second.emplace_back(std::move(rec));
		}
	}
	void add(String sql) {
		auto& query = queries.emplace_back();
		query.first = sql.toString();
	}
	std::list<std::pair<std::string, std::deque<std::vector<Own<Value>>>>> queries;
};
static bool db_do_transaction(DBQuery& query) {
	return SharedDB.transaction([&](SQLite::Database* db) {
		for (const auto& sql : query.queries) {
			if (sql.second.empty()) {
				DB::execUnsafe(db, sql.first);
			} else {
				DB::execUnsafe(db, sql.first, sql.second);
			}
		}
	});
}
static void db_do_transaction_async(DBQuery& query, const std::function<void(bool result)>& callback) {
	SharedDB.transactionAsync([&](SQLite::Database* db) {
		for (const auto& sql : query.queries) {
			if (sql.second.empty()) {
				DB::execUnsafe(db, sql.first);
			} else {
				DB::execUnsafe(db, sql.first, sql.second);
			}
		}
	},
		callback);
}
static DBRecord db_do_query(String sql, bool withColumns) {
	std::vector<Own<Value>> args;
	auto result = SharedDB.query(sql, args, withColumns);
	DBRecord record;
	record.records = std::move(result);
	return record;
}
static DBRecord db_do_query_with_params(String sql, Array* param, bool withColumns) {
	std::vector<Own<Value>> args;
	for (size_t i = 0; i < param->getCount(); ++i) {
		args.emplace_back(param->get(i)->clone());
	}
	auto result = SharedDB.query(sql, args, withColumns);
	DBRecord record;
	record.records = std::move(result);
	return record;
}
static void db_do_insert(String tableName, const DBParams& params) {
	SharedDB.insert(tableName, params.records);
}
static int32_t db_do_exec_with_records(String sql, const DBParams& params) {
	return SharedDB.exec(sql, params.records);
}
static void db_do_query_with_params_async(String sql, Array* param, bool withColumns, const std::function<void(DBRecord& result)>& callback) {
	std::vector<Own<Value>> args;
	for (size_t i = 0; i < param->getCount(); ++i) {
		args.emplace_back(param->get(i)->clone());
	}
	SharedDB.queryAsync(sql, std::move(args), withColumns, [callback](std::deque<std::vector<DB::Col>>& result) {
		DBRecord record;
		record.records = std::move(result);
		callback(record);
	});
}
static void db_do_insert_async(String tableName, DBParams& params, const std::function<void(bool)>& callback) {
	SharedDB.insertAsync(tableName, std::move(params.records), callback);
}
static void db_do_exec_async(String sql, DBParams& params, const std::function<void(int64_t)>& callback) {
	SharedDB.execAsync(sql, std::move(params.records), [callback](int rows) {
		callback(s_cast<int64_t>(rows));
	});
}

#include "Dora/ActionDefWasm.hpp"
#include "Dora/ActionWasm.hpp"
#include "Dora/ApplicationWasm.hpp"
#include "Dora/ArrayWasm.hpp"
#include "Dora/AudioWasm.hpp"
#include "Dora/BodyDefWasm.hpp"
#include "Dora/BodyWasm.hpp"
#include "Dora/BufferWasm.hpp"
#include "Dora/C45Wasm.hpp"
#include "Dora/CacheWasm.hpp"
#include "Dora/Camera2DWasm.hpp"
#include "Dora/CameraOthoWasm.hpp"
#include "Dora/CameraWasm.hpp"
#include "Dora/ClipNodeWasm.hpp"
#include "Dora/ContentWasm.hpp"
#include "Dora/DBParamsWasm.hpp"
#include "Dora/DBQueryWasm.hpp"
#include "Dora/DBRecordWasm.hpp"
#include "Dora/DBWasm.hpp"
#include "Dora/DictionaryWasm.hpp"
#include "Dora/DirectorWasm.hpp"
#include "Dora/DragonBoneWasm.hpp"
#include "Dora/DrawNodeWasm.hpp"
#include "Dora/EaseWasm.hpp"
#include "Dora/EffectWasm.hpp"
#include "Dora/EntityGroupWasm.hpp"
#include "Dora/EntityObserverWasm.hpp"
#include "Dora/EntityWasm.hpp"
#include "Dora/FixtureDefWasm.hpp"
#include "Dora/GrabberWasm.hpp"
#include "Dora/GridWasm.hpp"
#include "Dora/ImGuiWasm.hpp"
#include "Dora/JointDefWasm.hpp"
#include "Dora/JointWasm.hpp"
#include "Dora/KeyboardWasm.hpp"
#include "Dora/LabelWasm.hpp"
#include "Dora/LineWasm.hpp"
#include "Dora/MLQLearnerWasm.hpp"
#include "Dora/ModelWasm.hpp"
#include "Dora/MotorJointWasm.hpp"
#include "Dora/MoveJointWasm.hpp"
#include "Dora/NodeWasm.hpp"
#include "Dora/ParticleNodeWasm.hpp"
#include "Dora/PassWasm.hpp"
#include "Dora/PathWasm.hpp"
#include "Dora/PhysicsWorldWasm.hpp"
#include "Dora/Platformer/Behavior/BlackboardWasm.hpp"
#include "Dora/Platformer/Behavior/LeafWasm.hpp"
#include "Dora/Platformer/BulletDefWasm.hpp"
#include "Dora/Platformer/BulletWasm.hpp"
#include "Dora/Platformer/DataWasm.hpp"
#include "Dora/Platformer/Decision/AIWasm.hpp"
#include "Dora/Platformer/Decision/LeafWasm.hpp"
#include "Dora/Platformer/FaceWasm.hpp"
#include "Dora/Platformer/PlatformCameraWasm.hpp"
#include "Dora/Platformer/PlatformWorldWasm.hpp"
#include "Dora/Platformer/TargetAllowWasm.hpp"
#include "Dora/Platformer/UnitActionWasm.hpp"
#include "Dora/Platformer/UnitWasm.hpp"
#include "Dora/Platformer/VisualWasm.hpp"
#include "Dora/Platformer/WasmActionUpdateWasm.hpp"
#include "Dora/PlayableWasm.hpp"
#include "Dora/RectWasm.hpp"
#include "Dora/RenderTargetWasm.hpp"
#include "Dora/SVGDefWasm.hpp"
#include "Dora/SchedulerWasm.hpp"
#include "Dora/SensorWasm.hpp"
#include "Dora/SpineWasm.hpp"
#include "Dora/SpriteEffectWasm.hpp"
#include "Dora/SpriteWasm.hpp"
#include "Dora/Texture2DWasm.hpp"
#include "Dora/TouchWasm.hpp"
#include "Dora/VertexColorWasm.hpp"
#include "Dora/ViewWasm.hpp"

static void linkAutoModule(wasm3::module3& mod) {
	linkArray(mod);
	linkDictionary(mod);
	linkRect(mod);
	linkApplication(mod);
	linkDirector(mod);
	linkEntity(mod);
	linkEntityGroup(mod);
	linkEntityObserver(mod);
	linkContent(mod);
	linkPath(mod);
	linkScheduler(mod);
	linkCamera(mod);
	linkCamera2D(mod);
	linkCameraOtho(mod);
	linkPass(mod);
	linkEffect(mod);
	linkSpriteEffect(mod);
	linkView(mod);
	linkActionDef(mod);
	linkAction(mod);
	linkGrabber(mod);
	linkNode(mod);
	linkTexture2D(mod);
	linkSprite(mod);
	linkGrid(mod);
	linkTouch(mod);
	linkEase(mod);
	linkLabel(mod);
	linkRenderTarget(mod);
	linkClipNode(mod);
	linkVertexColor(mod);
	linkDrawNode(mod);
	linkLine(mod);
	linkParticleNode(mod);
	linkPlayable(mod);
	linkModel(mod);
	linkSpine(mod);
	linkDragonBone(mod);
	linkPhysicsWorld(mod);
	linkFixtureDef(mod);
	linkBodyDef(mod);
	linkSensor(mod);
	linkBody(mod);
	linkJointDef(mod);
	linkJoint(mod);
	linkMoveJoint(mod);
	linkMotorJoint(mod);
	linkCache(mod);
	linkAudio(mod);
	linkKeyboard(mod);
	linkSVGDef(mod);
	linkDBQuery(mod);
	linkDBParams(mod);
	linkDBRecord(mod);
	linkDB(mod);
	linkC45(mod);
	linkMLQLearner(mod);
	linkPlatformerTargetAllow(mod);
	linkPlatformerFace(mod);
	linkPlatformerBulletDef(mod);
	linkPlatformerBullet(mod);
	linkPlatformerVisual(mod);
	linkPlatformerBehaviorBlackboard(mod);
	linkPlatformerBehaviorLeaf(mod);
	linkPlatformerDecisionAI(mod);
	linkPlatformerDecisionLeaf(mod);
	linkPlatformerWasmActionUpdate(mod);
	linkPlatformerUnitAction(mod);
	linkPlatformerUnit(mod);
	linkPlatformerPlatformCamera(mod);
	linkPlatformerPlatformWorld(mod);
	linkPlatformerData(mod);
	linkBuffer(mod);
	linkImGui(mod);
}

static void linkDoraModule(wasm3::module3& mod) {
	linkAutoModule(mod);

	mod.link_optional("*", "str_new", str_new);
	mod.link_optional("*", "str_len", str_len);
	mod.link_optional("*", "str_read", str_read);
	mod.link_optional("*", "str_write", str_write);
	mod.link_optional("*", "str_release", str_release);

	mod.link_optional("*", "buf_new_i32", buf_new_i32);
	mod.link_optional("*", "buf_new_i64", buf_new_i64);
	mod.link_optional("*", "buf_new_f32", buf_new_f32);
	mod.link_optional("*", "buf_new_f64", buf_new_f64);
	mod.link_optional("*", "buf_len", buf_len);
	mod.link_optional("*", "buf_read", buf_read);
	mod.link_optional("*", "buf_write", buf_write);
	mod.link_optional("*", "buf_release", buf_release);

	mod.link_optional("*", "object_get_id", object_get_id);
	mod.link_optional("*", "object_get_type", object_get_type);
	mod.link_optional("*", "object_retain", object_retain);
	mod.link_optional("*", "object_release", object_release);

	mod.link_optional("*", "value_create_i64", value_create_i64);
	mod.link_optional("*", "value_create_f64", value_create_f64);
	mod.link_optional("*", "value_create_str", value_create_str);
	mod.link_optional("*", "value_create_bool", value_create_bool);
	mod.link_optional("*", "value_create_object", value_create_object);
	mod.link_optional("*", "value_create_vec2", value_create_vec2);
	mod.link_optional("*", "value_create_size", value_create_size);
	mod.link_optional("*", "value_release", value_release);
	mod.link_optional("*", "value_into_i64", value_into_i64);
	mod.link_optional("*", "value_into_f64", value_into_f64);
	mod.link_optional("*", "value_into_str", value_into_str);
	mod.link_optional("*", "value_into_bool", value_into_bool);
	mod.link_optional("*", "value_into_object", value_into_object);
	mod.link_optional("*", "value_into_vec2", value_into_vec2);
	mod.link_optional("*", "value_into_size", value_into_size);
	mod.link_optional("*", "value_is_i64", value_is_i64);
	mod.link_optional("*", "value_is_f64", value_is_f64);
	mod.link_optional("*", "value_is_str", value_is_str);
	mod.link_optional("*", "value_is_bool", value_is_bool);
	mod.link_optional("*", "value_is_object", value_is_object);
	mod.link_optional("*", "value_is_vec2", value_is_vec2);
	mod.link_optional("*", "value_is_size", value_is_size);

	mod.link_optional("*", "call_stack_create", call_stack_create);
	mod.link_optional("*", "call_stack_release", call_stack_release);
	mod.link_optional("*", "call_stack_push_i64", call_stack_push_i64);
	mod.link_optional("*", "call_stack_push_f64", call_stack_push_f64);
	mod.link_optional("*", "call_stack_push_str", call_stack_push_str);
	mod.link_optional("*", "call_stack_push_bool", call_stack_push_bool);
	mod.link_optional("*", "call_stack_push_object", call_stack_push_object);
	mod.link_optional("*", "call_stack_push_vec2", call_stack_push_vec2);
	mod.link_optional("*", "call_stack_push_size", call_stack_push_size);
	mod.link_optional("*", "call_stack_pop_i64", call_stack_pop_i64);
	mod.link_optional("*", "call_stack_pop_f64", call_stack_pop_f64);
	mod.link_optional("*", "call_stack_pop_str", call_stack_pop_str);
	mod.link_optional("*", "call_stack_pop_bool", call_stack_pop_bool);
	mod.link_optional("*", "call_stack_pop_object", call_stack_pop_object);
	mod.link_optional("*", "call_stack_pop_vec2", call_stack_pop_vec2);
	mod.link_optional("*", "call_stack_pop_size", call_stack_pop_size);
	mod.link_optional("*", "call_stack_pop", call_stack_pop);
	mod.link_optional("*", "call_stack_front_i64", call_stack_front_i64);
	mod.link_optional("*", "call_stack_front_f64", call_stack_front_f64);
	mod.link_optional("*", "call_stack_front_str", call_stack_front_str);
	mod.link_optional("*", "call_stack_front_bool", call_stack_front_bool);
	mod.link_optional("*", "call_stack_front_object", call_stack_front_object);
	mod.link_optional("*", "call_stack_front_vec2", call_stack_front_vec2);
	mod.link_optional("*", "call_stack_front_size", call_stack_front_size);

	mod.link_optional("*", "dora_print", dora_print);

	mod.link_optional("*", "array_set", array_set);
	mod.link_optional("*", "array_get", array_get);
	mod.link_optional("*", "array_first", array_first);
	mod.link_optional("*", "array_last", array_last);
	mod.link_optional("*", "array_random_object", array_random_object);
	mod.link_optional("*", "array_add", array_add);
	mod.link_optional("*", "array_insert", array_insert);
	mod.link_optional("*", "array_contains", array_contains);
	mod.link_optional("*", "array_index", array_index);
	mod.link_optional("*", "array_remove_last", array_remove_last);
	mod.link_optional("*", "array_fast_remove", array_fast_remove);

	mod.link_optional("*", "dictionary_set", dictionary_set);
	mod.link_optional("*", "dictionary_get", dictionary_get);

	mod.link_optional("*", "entity_set", entity_set);
	mod.link_optional("*", "entity_get", entity_get);
	mod.link_optional("*", "entity_get_old", entity_get_old);

	mod.link_optional("*", "group_watch", group_watch);
	mod.link_optional("*", "group_find", group_find);

	mod.link_optional("*", "observer_watch", observer_watch);

	mod.link_optional("*", "node_emit", node_emit);

	mod.link_optional("*", "blackboard_set", blackboard_set);
	mod.link_optional("*", "blackboard_get", blackboard_get);
}

WasmRuntime::WasmRuntime() {
	_env = New<wasm3::environment>();
	_runtime = New<wasm3::runtime>(_env->new_runtime(DORA_WASM_STACK_SIZE));
}

WasmRuntime::~WasmRuntime() { }

bool WasmRuntime::executeMainFile(String filename) {
	if (_wasm.first) {
		Warn("only one wasm module can be executed.");
		return false;
	}
	try {
		PROFILE("Loader"_slice, filename);
		{
			PROFILE("Loader"_slice, filename.toString() + " [Load]"s);
			_wasm = SharedContent.load(filename);
			auto mod = _env->parse_module(_wasm.first.get(), _wasm.second);
			_runtime->load(mod);
			mod.link_default();
			linkDoraModule(mod);
			_callFunc = New<wasm3::function>(_runtime->find_function("call_function"));
			_derefFunc = New<wasm3::function>(_runtime->find_function("deref_function"));
		}
		wasm3::function mainFn = _runtime->find_function("_start");
		mainFn.call_argv();
		return true;
	} catch (std::runtime_error& e) {
		Error("failed to load wasm module: {}, due to: {}{}", filename.toString(), e.what(), _runtime->get_error_message() == Slice::Empty ? ""s : ": "s + _runtime->get_error_message());
		return false;
	}
}

void WasmRuntime::executeMainFileAsync(String filename, const std::function<void(bool)>& handler) {
	if (_wasm.first) {
		Warn("only one wasm module can be executed, clear the current module before executing another");
		return;
	}
	auto file = filename.toString();
	SharedContent.loadAsyncData(filename, [file, handler, this](OwnArray<uint8_t>&& data, size_t size) {
		if (!data) {
			Error("failed to load wasm file \"{}\".", file);
			handler(false);
			return;
		}
		_wasm = {std::move(data), size};
		SharedAsyncThread.run(
			[file, this] {
				try {
					auto mod = New<wasm3::module3>(_env->parse_module(_wasm.first.get(), _wasm.second));
					_runtime->load(*mod);
					mod->link_default();
					linkDoraModule(*mod);
					_callFunc = New<wasm3::function>(_runtime->find_function("call_function"));
					_derefFunc = New<wasm3::function>(_runtime->find_function("deref_function"));
					auto mainFn = New<wasm3::function>(_runtime->find_function("_start"));
					return Values::alloc(std::move(mod), std::move(mainFn));
				} catch (std::runtime_error& e) {
					Error("failed to load wasm module: {}, due to: {}{}", file, e.what(), _runtime->get_error_message() == Slice::Empty ? Slice::Empty : ": "s + _runtime->get_error_message());
					return Values::alloc(Own<wasm3::module3>(), Own<wasm3::function>());
				}
			},
			[file, handler, this](Own<Values> values) {
				try {
					PROFILE("Loader"_slice, file);
					Own<wasm3::module3> mod;
					Own<wasm3::function> mainFn;
					values->get(mod, mainFn);
					if (mod) {
						mainFn->call_argv();
						handler(true);
					} else
						handler(false);
				} catch (std::runtime_error& e) {
					Error("failed to execute wasm module: {}, due to: {}{}", file, e.what(), _runtime->get_error_message() == Slice::Empty ? Slice::Empty : ": "s + _runtime->get_error_message());
					handler(false);
				}
			});
	});
}

void WasmRuntime::invoke(int32_t funcId) {
	AssertUnless(_callFunc, "wasm module is not ready");
	try {
		_callFunc->call(funcId);
	} catch (std::runtime_error& e) {
		Error("failed to execute wasm module due to: {}{}", e.what(), _runtime->get_error_message() == Slice::Empty ? Slice::Empty : ": "s + _runtime->get_error_message());
	}
}

void WasmRuntime::deref(int32_t funcId) {
	AssertUnless(_derefFunc, "wasm module is not ready");
	_derefFunc->call(funcId);
}

uint32_t WasmRuntime::getMemorySize() const {
	if (_wasm.first) {
		return _runtime->get_memory_size() + _wasm.second + DORA_WASM_STACK_SIZE;
	}
	return DORA_WASM_STACK_SIZE;
}

void WasmRuntime::clear() {
	_callFunc = nullptr;
	_derefFunc = nullptr;
	_runtime = nullptr;

	_env = New<wasm3::environment>();
	_runtime = New<wasm3::runtime>(_env->new_runtime(DORA_WASM_STACK_SIZE));
	_wasm = {nullptr, 0};
}

NS_DORA_END
