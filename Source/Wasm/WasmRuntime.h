/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"
#include "wasm3_cpp.h"

NS_DORA_BEGIN

class Scheduler;
class Async;

using dora_val_t = std::variant<
	int64_t,
	double,
	bool,
	std::string,
	Object*,
	Vec2,
	Size>;

using OptString = std::optional<Slice>;

class CallStack {
public:
	void push(uint64_t value);
	void push(int64_t value);
	void push(double value);
	void push(bool value);
	void push(String value);
	void push(Object* value);
	void push(const Vec2& value);
	void push(const Size& value);
	void push_v(dora_val_t value);
	template <typename T>
	typename std::enable_if_t<
		!std::is_same_v<T, Slice>
		&& std::is_same_v<T, OptString>>
	push(const T& value) {
		if (value) {
			push(*value);
		}
	}
	bool empty() const;
	dora_val_t pop();
	dora_val_t& front();
	bool pop_bool_or(bool def);
	void clear();

private:
	std::deque<dora_val_t> _stack;
};

class WasmRuntime : public NonCopyable {
public:
	PROPERTY_READONLY_CALL(Scheduler*, PostScheduler);
	PROPERTY_READONLY_CALL(Scheduler*, Scheduler);
	PROPERTY_READONLY(uint32_t, MemorySize);
	virtual ~WasmRuntime();
	bool executeMainFile(String filename);
	void executeMainFileAsync(String filename, const std::function<void(bool)>& handler);
	void invoke(int32_t funcId);
	void deref(int32_t funcId);
	void scheduleUpdate();
	void unscheduleUpdate();
	void clear();
	uint8_t* getMemoryAddress(int32_t wasmAddr);
	static bool isInWasm();

	void buildWaAsync(String fullPath, const std::function<void(String)>& callback);
	void formatWaAsync(String fullPath, const std::function<void(String)>& callback);

protected:
	WasmRuntime();

private:
	int32_t loadFuncs();
	bool _loading;
	Own<wasm3::environment> _env;
	Own<wasm3::runtime> _runtime;
	Own<wasm3::function> _callFunc;
	Own<wasm3::function> _derefFunc;
	Ref<Scheduler> _scheduler;
	Ref<Scheduler> _postScheduler;
	std::shared_ptr<bool> _scheduling;
	std::pair<OwnArray<uint8_t>, size_t> _wasm;
	Async* _thread = nullptr;
	static int _callFromWasm;
	SINGLETON_REF(WasmRuntime, LuaEngine);
};

#define SharedWasmRuntime \
	Dora::Singleton<Dora::WasmRuntime>::shared()

NS_DORA_END
