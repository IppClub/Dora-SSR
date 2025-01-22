/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Test/Test.h"

NS_DORA_BEGIN

#if DORA_TEST

TestEntry::TestEntry(String name) {
	Test::getTests()[name.toString()] = this;
}

std::list<std::string> Test::getNames() {
	std::list<std::string> names;
	for (const auto& test : Test::getTests()) {
		names.push_back(test.first);
	}
	return names;
}

StringMap<TestEntry*>& Test::getTests() {
	static StringMap<TestEntry*> tests;
	return tests;
}

bool Test::run(String name) {
	try {
		if (auto it = getTests().find(name); it != getTests().end()) {
			return it->second->run();
		} else {
			return false;
		}
	} catch (const std::runtime_error& e) {
		LogError(e.what());
		return false;
	}
}

#else // DORA_TEST

std::list<std::string> Test::getNames() {
	return {};
}

bool Test::run(String) {
	return true;
}

#endif // DORA_TEST

NS_DORA_END
