/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

/** @brief Helper macros to define setters and getters */
#define PROPERTY(varType, varName, funName)\
protected: varType varName;\
public: varType get##funName() const;\
public: void set##funName(varType var)

#define PROPERTY_NAME(varType, funName)\
public: varType get##funName() const;\
public: void set##funName(varType var)

#define PROPERTY_REF(varType, varName, funName)\
protected: varType varName;\
public: const varType& get##funName() const;\
public: void set##funName(const varType& var)

#define PROPERTY_NAME_REF(varType, funName)\
public: const varType& get##funName() const;\
public: void set##funName(const varType& var)

#define PROPERTY_VIRTUAL(varType, varName, funName)\
protected: varType varName;\
public: varType get##funName() const;\
public: virtual void set##funName(varType var)

#define PROPERTY_READONLY(varType, funName)\
public: varType get##funName() const

#define PROPERTY_READONLY_REF(varType, funName)\
public: const varType& get##funName() const

#define PROPERTY_READONLY_CLASS(varType, funName)\
public: static varType get##funName()

#define PROPERTY_READONLY_CALL(varType, funName)\
public: varType get##funName()

#define PROPERTY_BOOL(varName, funName)\
protected: bool varName;\
public: bool is##funName() const;\
public: void set##funName(bool var)

#define PROPERTY_BOOL_NAME(funName)\
public: bool is##funName() const;\
public: void set##funName(bool var)

#define PROPERTY_READONLY_BOOL(funName)\
public: bool is##funName() const

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
#define BREAK_IF(cond) if (cond) break;
#define BREAK_UNLESS(cond) if (!cond) break;
#define BLOCK_END } while (false);

/** @brief A better Enum.
	@example Use it as below.

	ENUM_START(MyFlag)
	{
		FlagOne = 1,
		FlagTwo,
		FlagThree
	}
	ENUM_END(MyFlag)

	MyFlag flag = MyFlag::FlagTwo;
*/
#define ENUM_START(x) struct x \
{ \
public: \
	enum xEnum

#define ENUM_END(x) ;\
	inline x() { } \
	inline x(const xEnum value):_value(value) { } \
	explicit inline x(int value):_value((xEnum)value) { } \
	inline void operator=(const xEnum inValue) \
	{ \
		_value = inValue; \
	} \
	inline operator xEnum() const \
	{ \
		return _value; \
	} \
private: \
	xEnum _value; \
};

/** @brief Compiler compact macros */
#ifdef __GNUC__
	#define DORA_UNUSED __attribute__ ((unused))
#else
	#define DORA_UNUSED
#endif

#define DORA_UNUSED_PARAM(unusedparam) (void)unusedparam
#define DORA_DUMMY do {} while (0)

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
namespace Tuple {
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
	inline void foreach(const TupleT& item, Func&& func)
	{
		TupleHelper<TupleT, std::tuple_size<TupleT>::value>::foreach(item, func);
	}
} // namespace Tuple

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
	template<class> struct Hasher;
	template<>
	struct Hasher<string>
	{
		size_t constexpr operator()(char const* input) const
		{
			return *input ?
			static_cast<size_t>(*input) + 33ull * (*this)(input + 1ull) : 5381ull;
		}
		std::size_t operator()(const string& str) const
		{
			return (*this)(str.c_str());
		}
	};
	template<typename T>
	std::size_t constexpr hash(T&& t)
	{
		return Hasher<typename std::decay<T>::type>()(std::forward<T>(t));
	}
	namespace Literals
	{
		std::size_t constexpr operator "" _hash(const char* s, size_t)
		{
			return Hasher<string>()(s);
		}
	}
} // namespace SwitchStr

/* Short names for C++ casts */
#define s_cast static_cast
#define r_cast reinterpret_cast
#define c_cast const_cast
#define d_cast dynamic_cast

#ifndef FLT_EPSILON
	#define FLT_EPSILON 1.192092896e-07F
#endif // FLT_EPSILON

NS_DOROTHY_END
