/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Life
{
public:
	virtual ~Life() { }
	virtual const string& getName() const = 0;
	static void addDependency(String target, String dependency);
	static void addItem(String name, Life* life);
	static void addName(String name);
	static void destroy(String name);
#if DORA_DEBUG
	static void assertIf(bool disposed, String name);
#endif
};

template <class T>
class Singleton : public T, public Life
{
public:
	Singleton()
	{
		_disposed = false;
		Life::addItem(_name, getLife());
	}

	static Singleton& shared()
	{
		static auto* _instance = new Singleton();
#if DORA_DEBUG
		Life::assertIf(_disposed, _name);
#endif
		return *_instance;
	}

	virtual ~Singleton()
	{
		_disposed = true;
	}

	virtual const string& getName() const override
	{
		return _name;
	}

	T* getTarget() const
	{
		return d_cast<T*>(c_cast<Singleton*>(this));
	}

	Life* getLife() const
	{
		return d_cast<Life*>(c_cast<Singleton*>(this));
	}

	static bool isDisposed()
	{
		return _disposed;
	}

	static void setDependencyInfo(String name, const vector<const char*>& dependencies)
	{
		_name = name;
		Life::addName(name);
		for (const auto& dependency : dependencies)
		{
			Life::addDependency(name, dependency);
		}
	}

private:
	static string _name;
	static bool _disposed;
};

template <class T>
string Singleton<T>::_name;

template <class T>
bool Singleton<T>::_disposed = true;

#define SINGLETON(type, ...) \
private: \
	struct type##_initializer \
	{ \
		type##_initializer() \
		{ \
			Singleton<type>::setDependencyInfo(#type, {__VA_ARGS__}); \
		} \
	} __##type##_initializer__

NS_DOROTHY_END
