/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Common/Singleton.h"
#include <mutex>

NS_DOROTHY_BEGIN

struct LifeCycler
{
	~LifeCycler()
	{
		for (auto name : names)
		{
			Life::destroy(name);
		}
	}
	unordered_set<string> names;
	unordered_map<string, Own<Life>> lives;
	unordered_map<string, Own<list<string>>> references;
};

Own<LifeCycler> g_cycler;

std::once_flag g_initCycler;

LifeCycler* getCycler()
{
	std::call_once(g_initCycler, []()
	{
		g_cycler = New<LifeCycler>();
	});
	static LifeCycler* cycler = g_cycler;
	return cycler;
}

#if DORA_DEBUG
void Life::assertIf(bool disposed, String name)
{
	AssertIf(disposed, "accessing disposed singleton instance named \"%s\".", name);
}
#endif

void Life::addName(String name)
{
	LifeCycler* cycler = getCycler();
	cycler->names.insert(name);
}

void Life::addDependency(String target, String dependency)
{
	LifeCycler* cycler = getCycler();
	auto it = cycler->references.find(dependency);
	if (it == cycler->references.end())
	{
		auto refs = new list<string>();
		refs->push_back(target);
		cycler->references[dependency] = MakeOwn(refs);
	}
	else
	{
		it->second->push_back(target);
	}
}

void Life::addItem(String name, Life* life)
{
	LifeCycler* cycler = getCycler();
	cycler->lives[name] = MakeOwn(life);
}

void Life::destroy(String name)
{
	LifeCycler* cycler = getCycler();
	auto it = cycler->references.find(name);
	if (it != cycler->references.end())
	{
		auto items = std::move(it->second);
		cycler->references.erase(it);
		for (const auto& item : *items)
		{
			destroy(item);
		}
	}
	AssertUnless(cycler->names.find(name) != cycler->names.end(), "no singleton class named \"%s\".", name);
	auto itemIt = cycler->lives.find(name);
	if (itemIt != cycler->lives.end())
	{
		Log("destroy singleton \"%s\".", name);
		cycler->lives.erase(itemIt);
	}
}

NS_DOROTHY_END
