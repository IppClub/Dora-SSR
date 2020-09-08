/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

/** @brief Helper macros to define setters and getters */
#define PROPERTY(varType, funName) \
public: varType get##funName() const; \
public: void set##funName(varType var)

#define PROPERTY_CREF(varType, funName) \
public: const varType& get##funName() const; \
public: void set##funName(const varType& var)

#define PROPERTY_CLASS(varType, funName) \
public: static varType get##funName(); \
public: static void set##funName(varType var)

#define PROPERTY(varType, funName) \
public: varType get##funName() const; \
public: void set##funName(varType var)

#define PROPERTY_VIRTUAL(varType, funName) \
public: varType get##funName() const; \
public: virtual void set##funName(varType var)

#define PROPERTY_VIRTUAL_CREF(varType, funName) \
public: const varType& get##funName() const; \
public: virtual void set##funName(const varType& var)

#define PROPERTY_READONLY_VIRTUAL(varType, funName) \
public: virtual varType get##funName() const

#define PROPERTY_READONLY(varType, funName) \
public: varType get##funName() const

#define PROPERTY_READONLY_CREF(varType, funName) \
public: const varType& get##funName() const

#define PROPERTY_READONLY_REF(varType, funName) \
public: varType& get##funName()

#define PROPERTY_READONLY_BOOL(funName) \
public: bool is##funName() const

#define PROPERTY_READONLY_HAS(funName) \
public: bool has##funName() const

#define PROPERTY_READONLY_CLASS(varType, funName) \
public: static varType get##funName()

#define PROPERTY_READONLY_CALL(varType, funName) \
public: varType get##funName()

#define PROPERTY_BOOL(funName) \
public: bool is##funName() const; \
public: void set##funName(bool var)

#define PROPERTY_VIRTUAL_BOOL(funName) \
public: bool is##funName() const; \
public: void virtual set##funName(bool var)

#define PROPERTY_STRING(funName) \
public: const string& get##funName() const; \
public: void set##funName(String var)

#define PROPERTY_VIRTUAL_STRING(funName) \
public: const string& get##funName() const; \
public: virtual void set##funName(String var)

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
#define BREAK_IF(cond) if (cond) break
#define BREAK_UNLESS(cond) if (!(cond)) break
#define BLOCK_END } while (false);

/** @brief Compiler compact macros */
#ifdef __GNUC__
	#define DORA_UNUSED __attribute__ ((unused))
#else
	#define DORA_UNUSED
#endif

#define DORA_UNUSED_PARAM(unusedparam) (void)unusedparam
#define DORA_DUMMY do {} while (0)

/* Short names for C++ casts */
#define s_cast static_cast
#define r_cast reinterpret_cast
#define c_cast const_cast
#define d_cast dynamic_cast

/** @brief Short name for Slice used for argument type */
typedef const Slice& String;

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
		CREATE_FUNC(MyItem)
 };
 
 // Use the create functions
 auto itemA = MyItem::create();
 auto itemB = MyItem::create(998);
 */
#define CREATE_FUNC(type) \
template<class... Args> \
static type* create(Args&&... args) \
{ \
    type* item = new type(std::forward<Args>(args)...); \
    if (item && item->init()) \
    { \
        item->autorelease(); \
    } \
    else \
    { \
        delete item; \
        item = nullptr; \
    } \
	return item; \
}

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
namespace Tuple
{
	template<typename TupleT, size_t Size>
	struct TupleHelper
	{
		template<typename Func>
		static void foreach(const TupleT& item, Func&& func)
		{
			TupleHelper<TupleT, Size - 1>::foreach(item, func);
			func(std::get<Size - 1>(item));
		}
	};
	template<typename TupleT>
	struct TupleHelper<TupleT, 0>
	{
		template<typename Func>
		static void foreach(const TupleT&, Func&&)
		{ }
	};
	template<typename TupleT, typename Func>
	inline int foreach(const TupleT& item, Func&& func)
	{
		TupleHelper<TupleT, std::tuple_size<TupleT>::value>::foreach(item, func);
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
namespace Switch
{
	inline constexpr std::size_t hash(char const* input)
	{
		return *input ? *input + 33ull * hash(input + 1) : 5381;
	}
	inline std::size_t hash(const char* input, int size, int index)
	{
		return index < size ? input[index] + 33ull * hash(input, size, index + 1) : 5381;
	}
	inline std::size_t hash(String str)
	{
		return hash(str.rawData(), s_cast<int>(str.size()), 0);
	}
	namespace Literals
	{
		inline std::size_t constexpr operator"" _hash(const char* s, size_t)
		{
			return hash(s);
		}
	}
} // namespace Switch

/** @brief Helpers for number comparision */
namespace Math
{
	template <class T>
	inline T clamp(T value, T minVal, T maxVal)
	{
		auto pair = std::minmax(minVal, maxVal);
		return std::max(std::min(value, pair.second), pair.first);
	}

	float rand0to1();
	float rand1to1();
}

/** @brief Dorothy`s type system for lua and
 it`s an alternative for dynamic_cast.
 */
extern int doraType;

template <class T>
int DoraType()
{
	static int type = doraType++;
	return type;
}

#define DORA_TYPE(type) \
public: int getDoraType() const \
{ \
	return DoraType<type>(); \
}

#define DORA_TYPE_BASE(type) \
public: virtual int getDoraType() const \
{ \
	return DoraType<type>(); \
}

#define DORA_TYPE_OVERRIDE(type) \
public: virtual int getDoraType() const override \
{ \
	return DoraType<type>(); \
}

template <class OutT, class InT>
OutT* DoraCast(InT* obj)
{
	return (obj && obj->getDoraType() == DoraType<OutT>()) ? s_cast<OutT*>(obj) : nullptr;
}

template <class TargetT, class SelfT>
bool DoraIs(SelfT* obj)
{
	return obj->getDoraType() == DoraType<TargetT>();
}

template <class OutT, class InT>
OutT* DoraTo(InT* obj)
{
	AssertIf(obj && d_cast<OutT*>(obj) == nullptr, "failed to do Dora type convertion.");
	return s_cast<OutT*>(obj);
}

class Flag
{
public:
	Flag(Uint32 value);
	void set(Uint32 type, bool value);
	void toggle(Uint32 type);
	inline void setOn(Uint32 type) { _flags |= type; }
	inline void setOff(Uint32 type) { _flags &= ~type; }
	inline bool isOn(Uint32 type) const { return (_flags & type) != 0; }
	inline bool isOff(Uint32 type) const { return (_flags & type) == 0; }
private:
	Uint32 _flags;
};

#define LuaType DoraType

template<typename T>
class RRefCapture
{
public:
	RRefCapture(T&& x):_ptr(&x) { }
	operator T&& () const
	{
		return std::move(*_ptr);
	}
private:
	T* _ptr;
};

class Profiler
{
public:
	Profiler();
	void start();
	double stop(String logName = Slice::Empty);

	template <typename Func>
	static double run(const Func& func)
	{
		Profiler profiler;
		func();
		return profiler.stop();
	}

	template <typename Func>
	static double run(String logName, const Func& func)
	{
		Profiler profiler;
		func();
		return profiler.stop(logName);
	}
private:
	double _lastTime;
};

class Path
{
public:
	static string concat(const list<string>& paths);
	static string getExt(const string& path);
	static string getPath(const string& path);
	static string getName(const string& path);
	static string getFilename(const string& path);
	static string replaceExt(const string& path, const string& newExt);
	static string replaceFilename(const string& path, const string& newFile);
};

NS_DOROTHY_END
