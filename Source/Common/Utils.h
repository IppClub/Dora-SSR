/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <coroutine>

NS_DORA_BEGIN

/** @brief Helper macros to define setters and getters */
#define PROPERTY(varType, funName) \
public: \
	varType get##funName() const noexcept; \
\
public: \
	void set##funName(varType var)

#define PROPERTY_EXCEPT(varType, funName) \
public: \
	varType get##funName() const; \
\
public: \
	void set##funName(varType var)

#define PROPERTY_CREF(varType, funName) \
public: \
	const varType& get##funName() const noexcept; \
\
public: \
	void set##funName(const varType& var)

#define PROPERTY_CLASS(varType, funName) \
public: \
	static varType get##funName(); \
\
public: \
	static void set##funName(varType var)

#define PROPERTY_VIRTUAL(varType, funName) \
public: \
	varType get##funName() const noexcept; \
\
public: \
	virtual void set##funName(varType var)

#define PROPERTY_VIRTUAL_CREF(varType, funName) \
public: \
	const varType& get##funName() const noexcept; \
\
public: \
	virtual void set##funName(const varType& var)

#define PROPERTY_READONLY_VIRTUAL(varType, funName) \
public: \
	virtual varType get##funName() const noexcept

#define PROPERTY_READONLY(varType, funName) \
public: \
	varType get##funName() const noexcept

#define PROPERTY_READONLY_EXCEPT(varType, funName) \
public: \
	varType get##funName() const

#define PROPERTY_READONLY_CREF(varType, funName) \
public: \
	const varType& get##funName() const noexcept

#define PROPERTY_READONLY_CREF_EXCEPT(varType, funName) \
public: \
	const varType& get##funName() const

#define PROPERTY_READONLY_REF(varType, funName) \
public: \
	varType& get##funName()

#define PROPERTY_READONLY_BOOL(funName) \
public: \
	bool is##funName() const noexcept

#define PROPERTY_READONLY_HAS(funName) \
public: \
	bool has##funName() const noexcept

#define PROPERTY_READONLY_CLASS(varType, funName) \
public: \
	static varType get##funName()

#define PROPERTY_READONLY_CALL(varType, funName) \
public: \
	varType get##funName()

#define PROPERTY_BOOL(funName) \
public: \
	bool is##funName() const noexcept; \
\
public: \
	void set##funName(bool var)

#define PROPERTY_VIRTUAL_BOOL(funName) \
public: \
	bool is##funName() const noexcept; \
\
public: \
	void virtual set##funName(bool var)

#define PROPERTY_OVERRIDE_BOOL(funName) \
public: \
	bool is##funName() const noexcept; \
\
public: \
	void virtual set##funName(bool var) override

#define PROPERTY_STRING(funName) \
public: \
	const std::string& get##funName() const noexcept; \
\
public: \
	void set##funName(String var)

#define PROPERTY_VIRTUAL_STRING(funName) \
public: \
	const std::string& get##funName() const noexcept; \
\
public: \
	virtual void set##funName(String var)

/** @brief Code block for condition check.
	@example Use it as below.

	BLOCK_START
	...
	BREAK_IF(flag)
	...
	BREAK_UNLESS(flag2)
	...
	BLOCK_END
*/
#define BLOCK_START do {
#define BREAK_IF(cond) \
	if (cond) break
#define BREAK_UNLESS(cond) \
	if (!(cond)) break
#define BLOCK_END \
	} \
	while (false);

/** @brief Compiler compact macros */
#define DORA_UNUSED [[maybe_unused]]
#define DORA_UNUSED_PARAM(unusedparam) (void)unusedparam
#define DORA_DUMMY \
	do { \
	} while (0)

/* Short names for C++ casts */
#define s_cast static_cast
#define r_cast reinterpret_cast
#define c_cast const_cast
#define d_cast dynamic_cast

/** @brief Short name for Slice used for argument type */
typedef Slice String;

/** @brief Helper function to add create style codes for oObject derivations.
 The added create(...) functions accept the same argument with the class constructors.
 @example Use it as below.

 // Add the macro in subclass of Object
 class MyItem : public Object
 {
	public:
		MyItem();
		MyItem(int value);
		virtual bool init() override;
		CREATE_FUNC_NULLABLE(MyItem);
 };

 // Use the create functions
 auto itemA = MyItem::create();
 auto itemB = MyItem::create(998);
 */
#define CREATE_FUNC_NULLABLE(type) \
	template <class... Args> \
	static inline type* create(Args&&... args) { \
		return Object::create<type>(std::forward<Args>(args)...); \
	} \
	friend class Object

#define CREATE_FUNC_NOT_NULL(type) \
	template <class... Args> \
	static inline type* create(Args&&... args) { \
		return Object::createNotNull<type>(std::forward<Args>(args)...); \
	} \
	friend class Object

/**
 @brief Helper class to do null check for pointer.
 @example Use it as below.

 void func(NotNull<MyClass, 1> arg1, NotNull<MyClass, 2> arg2) { ... }
 */
template <typename T, int pos>
class NotNull {
public:
	NotNull(T* ptr)
		: _ptr(ptr) {
		if (!_ptr) {
			if constexpr (pos == 0) {
				throw std::runtime_error("unexpected null pointer.");
			} else {
				throw std::runtime_error("argument "s + std::to_string(pos) + " is unexpected null pointer."s);
			}
		}
	}

	NotNull(std::nullptr_t) = delete;

	inline T* operator->() const {
		return _ptr;
	}

	inline operator T*() const {
		return _ptr;
	}

	inline T* get() const {
		return _ptr;
	}

private:
	T* _ptr;
};

/**
 @brief Helper class to declare a non-copyable class.
 @example Use it as below.

 class MyClass : public NonCopyable { ... };
 */
class NonCopyable {
protected:
	NonCopyable() = default;
	~NonCopyable() = default;
	NonCopyable(const NonCopyable&) = delete;
	void operator=(const NonCopyable&) = delete;
};

/** @brief Helper function to iterate a std::tuple.
 @example Use it as below.

 // I have a tuple
 auto item = std::make_tuple(998, 233, "a pen");

 // I have a handler
 struct Handler
 {
	template<typename T>
	void operator()(const T& element)
	{
		cout << element << "\n";
	}
 };

 // Em, start iteration
 Tuple::foreach(item, Handler());
 */
namespace Tuple {
template <typename TupleT, size_t Size>
struct TupleHelper {
	template <typename Func>
	static void foreach (const TupleT& item, Func && func) {
		TupleHelper<TupleT, Size - 1>::foreach (item, func);
		func(std::get<Size - 1>(item));
	}
};
template <typename TupleT>
struct TupleHelper<TupleT, 0> {
	template <typename Func>
	static void foreach (const TupleT&, Func&&) { }
};
template <typename TupleT, typename Func>
inline int foreach (const TupleT& item, Func && func) {
	TupleHelper<TupleT, std::tuple_size<TupleT>::value>::foreach (item, func);
	return s_cast<int>(std::tuple_size<TupleT>::value);
}
} // namespace Tuple

#ifndef FLT_EPSILON
#define FLT_EPSILON std::numeric_limits<float>::epsilon()
#endif // FLT_EPSILON

/** @brief Helper functions to hash string in compile time for use of
 string switch case.
 @example Use it as below.

 string extension = "png";
 switch (Switch::hash(extension))
 {
	case "xml"_hash:
		// ...
		break;
	case "cpp"_hash:
		// ...
		break;
	default:
		// ...
		break;
 }
 */
namespace Switch {
inline constexpr std::size_t hash(char const* input) {
	return *input ? *input + 33ull * hash(input + 1) : 5381;
}
inline std::size_t hash(const char* input, int size, int index) {
	return index < size ? input[index] + 33ull * hash(input, size, index + 1) : 5381;
}
inline std::size_t hash(String str) {
	return hash(str.rawData(), s_cast<int>(str.size()), 0);
}
namespace Literals {
inline std::size_t constexpr operator"" _hash(const char* s, size_t) {
	return hash(s);
}
} // namespace Literals
} // namespace Switch

/** @brief Helpers for number comparision */
namespace Math {
template <class T>
inline T clamp(T value, T boundA, T boundB) {
	auto [minVal, maxVal] = std::minmax(boundA, boundB);
	return std::max(std::min(value, maxVal), minVal);
}

float rand0to1();
float rand1to1();
} // namespace Math

/** @brief Dora`s type system for lua and
 it`s an alternative for dynamic_cast.
 */
extern int doraType;

template <class T>
int DoraType() {
	static int type = doraType++;
	return type;
}

#define DORA_TYPE(type) \
public: \
	int getDoraType() const { \
		return DoraType<type>(); \
	}

#define DORA_TYPE_BASE(type) \
public: \
	virtual int getDoraType() const { \
		return DoraType<type>(); \
	}

#define DORA_TYPE_OVERRIDE(type) \
public: \
	virtual int getDoraType() const override { \
		return DoraType<type>(); \
	}

template <class OutT, class InT>
OutT* DoraAs(InT* obj) {
	return (obj && obj->getDoraType() == DoraType<OutT>()) ? s_cast<OutT*>(obj) : nullptr;
}

template <class TargetT, class SelfT>
bool DoraIs(SelfT* obj) {
	return obj->getDoraType() == DoraType<TargetT>();
}

template <class OutT, class InT>
OutT* DoraTo(InT* obj) {
	AssertIf(obj && d_cast<OutT*>(obj) == nullptr, "failed to do Dora type convertion.");
	return s_cast<OutT*>(obj);
}

class Flag {
public:
	using ValueType = uint32_t;
	Flag(ValueType value);
	void set(ValueType type, bool value);
	void toggle(ValueType type);
	inline void setOn(ValueType type) { _flags |= type; }
	inline void setOff(ValueType type) { _flags &= ~type; }
	inline bool isOn(ValueType type) const { return (_flags & type) != 0; }
	inline bool isOff(ValueType type) const { return (_flags & type) == 0; }

private:
	ValueType _flags;
};

#define LuaType DoraType

template <typename T>
class RRefCapture {
public:
	RRefCapture(T&& x)
		: _ptr(&x) { }
	operator T&&() const {
		return std::move(*_ptr);
	}

private:
	T* _ptr;
};

class Profiler {
public:
	Profiler(String name, String msg = Slice::Empty);
	~Profiler();
	static const std::string EventName;
	static int level;

private:
	double _lastTime;
	std::string _name;
	std::string _msg;
};

#if DORA_DISABLE_PROFILER
#define PROFILE(name, ...)
#else
#define PROFILE(...) Profiler _(__VA_ARGS__)
#endif

class Path {
public:
	static std::string concatVector(const std::vector<std::string>& paths);
	static std::string concat(const std::list<Slice>& paths);
	static std::string getExt(String path);
	static std::string getPath(String path);
	static std::string getName(String path);
	static std::string getFilename(String path);
	static std::string getRelative(String path, String target);
	static std::string replaceExt(String path, String newExt);
	static std::string replaceFilename(String path, String newFile);
};

#define _DEFER(code, line) std::shared_ptr<void> _defer_##line(nullptr, [&](auto) { \
	code; \
})
#define DEFER(code) _DEFER(code, __LINE__)

struct StringHash {
	using is_transparent = void;
	[[nodiscard]] inline size_t operator()(const char* txt) const {
		return std::hash<std::string_view>{}(txt);
	}
	[[nodiscard]] inline size_t operator()(std::string_view txt) const {
		return std::hash<std::string_view>{}(txt);
	}
	[[nodiscard]] inline size_t operator()(String txt) const {
		return std::hash<std::string_view>{}({txt.rawData(), txt.size()});
	}
	[[nodiscard]] inline size_t operator()(const std::string& txt) const {
		return std::hash<std::string>{}(txt);
	}
};

template <class T>
using StringMap = std::unordered_map<std::string, T, StringHash, std::equal_to<>>;

/** @brief C++ 20 coroutine helper */
template <typename T>
struct Promise;

template <typename T>
struct Coroutine : std::coroutine_handle<Promise<T>> {
	using promise_type = Promise<T>;
};

template <typename T>
struct Promise {
	T value;
	std::exception_ptr exception;
	Coroutine<T> get_return_object() { return {Coroutine<T>::from_promise(*this)}; }
	std::suspend_always initial_suspend() noexcept { return {}; }
	std::suspend_always final_suspend() noexcept { return {}; }
	template <std::convertible_to<T> From>
	std::suspend_always yield_value(From&& from) {
		value = std::forward<From>(from);
		return {};
	}
	void return_void() { }
	void unhandled_exception() { exception = std::current_exception(); }
};

using Job = Coroutine<bool>;

#define co_sleep(duration) \
	{ \
		double __time = 0.0; \
		double __duration = s_cast<double>(duration); \
		do { \
			co_yield false; \
			__time += SharedApplication.getDeltaTime(); \
		} while (__time < __duration); \
	}

#define co_wait(condition) \
	while (!(condition)) { \
		co_yield false; \
	}

#define co_cycle(duration, work) \
	{ \
		double __time = 0.0; \
		double __duration = s_cast<double>(duration); \
		auto __work = work; \
		do { \
			__work(s_cast<float>(std::min(1.0, __time / __duration))); \
			if (__time >= __duration) break; \
			co_yield false; \
			__time += SharedApplication.getDeltaTime(); \
		} while (true); \
	}

std::function<bool(double)> once(const std::function<Job()>& work);
std::function<bool(double)> loop(const std::function<Job()>& work);
void thread(const std::function<Job()>& work);
void threadLoop(const std::function<Job()>& work);

std::string sprintf(const char* fmt, ...);

NS_DORA_END
