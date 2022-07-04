/* Copyright (c) 2022 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "wasm3_cpp.h"

NS_DOROTHY_BEGIN

using dora_val_t = std::variant<
	int32_t, int64_t,
	float, double,
	bool, std::string,
	Object*,
	Vec2,
	Size
>;

class CallStack
{
public:
	void push(int32_t value);
	void push(int64_t value);
	void push(float value);
	void push(double value);
	void push(bool value);
	void push(String value);
	void push(Object* value);
	void push(const Vec2& value);
	void push(const Size& value);
	void push_v(dora_val_t value);
	bool empty() const;
	dora_val_t pop();
	dora_val_t& front();
private:
	std::deque<dora_val_t> _stack;
};

class WasmRuntime
{
public:
	~WasmRuntime();
	bool executeMainFile(String filename);
	void executeMainFileAsync(String filename, const std::function<void(bool)>& handler);
	void invoke(int32_t funcId);
	void deref(int32_t funcId);
protected:
	WasmRuntime();
private:
	wasm3::environment _env;
	wasm3::runtime _runtime;
	Own<wasm3::function> _callFunc;
	Own<wasm3::function> _derefFunc;
	std::pair<OwnArray<uint8_t>, size_t> _wasm;
	SINGLETON_REF(WasmRuntime, LuaEngine);
};

#define SharedWasmRuntime \
	Dorothy::Singleton<Dorothy::WasmRuntime>::shared()

NS_DOROTHY_END
