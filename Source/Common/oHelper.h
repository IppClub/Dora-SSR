/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_COMMON_OHELPER_H__
#define __DOROTHY_COMMON_OHELPER_H__

#define NS_DOROTHY_BEGIN namespace Dorothy {
#define NS_DOROTHY_END }

NS_DOROTHY_BEGIN

//
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

/** @brief Code block for condition check
	@example as below

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

/** @brief A more efficient switch case for strings
	@example Use it as below

	string str = "abc";
	SWITCH_STR_START(str)
	{
		CASE_STR(Pig)
		{
			break;
		}
		CASE_STR(Dog)
		{
			break;
		}
	}
	SWITCH_STR_END
*/
inline size_t oHash(const string& str) { return std::hash<std::string>{}(str); }
#define SWITCH_STR_START(x) { size_t __strHashCodeForSwitch = oHash(x);string __targetStrForSwitch(x); do
#define __CASE_STR0(x, name, flag) static size_t name##flag = oHash(x);if (__strHashCodeForSwitch == name##flag && __targetStrForSwitch == x)
#define __CASE_STR1(x, flag) __CASE_STR0(x, __strCase, flag)
#define CASE_STR(x) __CASE_STR1(#x, x)
#define DEFAULT_STR()
#define SWITCH_STR_END while (false); }

/** @brief A better Enum
	@example Use it as below

	ENUM_START(MyFlag)
	{
		FlagOne = 1,
		FlagTwo,
		FlagThree
	}
	ENUM_END(MyFlag)

	MyFlag flag = MyFlag::FlagTwo;
*/
#define ENUM_START(x) struct x\
{\
public:\
	enum xEnum

#define ENUM_END(x) ;\
	inline x(){}\
	inline x(const xEnum value):_value(value){}\
	explicit inline x(int value):_value((xEnum)value){}\
	inline void operator=( const xEnum inValue )\
{\
	_value = inValue;\
}\
	inline operator xEnum() const\
{\
	return _value;\
}\
private:\
	xEnum _value;\
};

#ifdef __GNUC__
	#define DORA_UNUSED __attribute__ ((unused))
#else
	#define DORA_UNUSED
#endif

#define DORA_UNUSED_PARAM(unusedparam) (void)unusedparam
#define DORA_DUMMY do {} while (0)

typedef const Slice& oSlice;

NS_DOROTHY_END

#endif // __DOROTHY_COMMON_OHELPER_H__
