/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

/** Dora singleton helper.
 @example

 class Application
 {
public:
	// virtual destructor is required
	virtual ~Application();
	// Application has no dependency
	SINGLETON_REF(Application);
 };
 #define SharedApplication \
	Dora::Singleton<Dora::Application>::shared()

 class Log
 {
public:
	virtual ~Log();
	// Log has a dependency of Application
	SINGLETON_REF(Log, Application);
 };
 #define SharedLog \
	Dora::Singleton<Dora::Log>::shared()

 class Console
 {
public:
	virtual ~Console();
	// Console has a dependency of Application
	SINGLETON_REF(Console, Application);
	// Add Console as additional dependency for Log
	SINGLETON_REF(Log, Console);
 };
 #define SharedConsole \
	Dora::Singleton<Dora::Console>::shared()

 Singleton instances will be destroyed in orders of:
	Log
	Console
	Application
*/

class Life {
public:
	virtual ~Life() { }
	static void addDependency(String target, String dependency);
	static void addItem(String name, Life* life);
	static void addName(String name);
	static void destroy(String name);
	static std::string getRefTree();

protected:
	Life() = default;
	Life(const Life&) = delete;
	void operator=(const Life&) = delete;
};

template <class T>
class Singleton : public T, public Life {
public:
	enum class Status {
		Uninitialized,
		Available,
		Disposed,
	};
	Singleton() {
		_status = Status::Available;
		Life::addItem(_name, getLife());
	}

	static Singleton& shared() {
		static auto* _instance = new Singleton();
		AssertIf(_status != Status::Available, "accessing disposed singleton instance named \"{}\".", _name);
		return *_instance;
	}

	virtual ~Singleton() {
		_status = Status::Disposed;
	}

	const std::string& getName() const {
		return _name;
	}

	T* getTarget() const {
		return s_cast<T*>(c_cast<Singleton*>(this));
	}

	Life* getLife() const {
		return s_cast<Life*>(c_cast<Singleton*>(this));
	}

	static bool isDisposed() {
		return _status == Status::Disposed;
	}

	static bool isInitialized() {
		return _status == Status::Available;
	}

	static void setDependencyInfo(String name, String dependencyStr) {
		_name = name.toString();
		Life::addName(name);
		auto dependencies = dependencyStr.split(",");
		for (auto& dependency : dependencies) {
			dependency.trimSpace();
			Life::addDependency(name, dependency);
		}
	}

protected:
	Singleton(const Singleton&) = delete;
	void operator=(const Singleton&) = delete;

private:
	static std::string _name;
	static Status _status;
};

template <class T>
std::string Singleton<T>::_name;

template <class T>
typename Singleton<T>::Status Singleton<T>::_status = Singleton<T>::Status::Uninitialized;

#define SINGLETON_REF(type, ...) \
private: \
	struct type##_ref_initializer { \
		type##_ref_initializer() { \
			const char* info[] = {nullptr, #__VA_ARGS__}; \
			Singleton<type>::setDependencyInfo(#type, (sizeof(info) / sizeof(*info) == 1 ? "" : info[1])); \
		} \
	} __##type##_initializer__

NS_DORA_END
