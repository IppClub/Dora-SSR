/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class LuaHandler : public Object
{
public:
	virtual ~LuaHandler();
	virtual bool update(double deltaTime) override;
	bool equals(LuaHandler* other) const;
	int get() const;
	CREATE_FUNC(LuaHandler);
protected:
	LuaHandler(int handler);
private:
	int _handler;
	DORA_TYPE_OVERRIDE(LuaHandler);
};

struct LuaArgsPusher
{
	template<typename T>
	void operator()(T&& element)
	{
		SharedLueEngine.push(element);
	}
};

class Event;
class LuaFunction
{
public:
	LuaFunction(int handler):_handler(LuaHandler::create(handler)) { }
	inline bool operator==(const LuaFunction& other) const
	{
		return _handler->equals(other._handler);
	}
	template<typename ...Args>
	void operator()(Args ...args) const
	{
		SharedLueEngine.executeFunction(_handler->get(), Tuple::foreach(std::make_tuple(args...), LuaArgsPusher()));
	}
	void operator()(Event* event) const;
private:
	Ref<LuaHandler> _handler;
};

class LuaFunctionBool
{
public:
	LuaFunctionBool(int handler):_handler(LuaHandler::create(handler)) { }
	inline bool operator==(const LuaFunctionBool& other) const
	{
		return _handler->equals(other._handler);
	}
	template<typename ...Args>
	bool operator()(Args ...args) const
	{
		return SharedLueEngine.executeFunction(_handler->get(), Tuple::foreach(std::make_tuple(args...), LuaArgsPusher())) != 0;
	}
private:
	Ref<LuaHandler> _handler;
};

NS_DOROTHY_END
