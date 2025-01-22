/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

#if DORA_TEST
class TestEntry {
public:
	TestEntry(String name);
	virtual bool run() = 0;
};
#endif // DORA_TEST

class Test {
public:
	static std::list<std::string> getNames();
	static bool run(String name);
#if DORA_TEST
private:
	static StringMap<TestEntry*>& getTests();
	friend class TestEntry;
#endif // DORA_TEST
};

#if DORA_TEST
#define DORA_TEST_ENTRY(name) \
	class name : public TestEntry { \
	public: \
		name() \
			: TestEntry(#name) { } \
		virtual bool run() override; \
	}; \
	static inline name _##name; \
	bool name::run()
#else
#define DORA_TEST_ENTRY(name) inline bool _##name()
#endif // DORA_TEST

NS_DORA_END
