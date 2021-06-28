/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Common/Singleton.h"
#include <numeric>
#include <mutex>

NS_DOROTHY_BEGIN

struct LifeCycler
{
	std::string getRefTree()
	{
		fmt::memory_buffer out;
		std::unordered_set<std::string> entries;
		for (const auto& life : lives)
		{
			entries.insert(life.first);
		}
		for (const auto& itemRef : itemRefs)
		{
			entries.insert(itemRef.first);
		}
		for (auto& ref : refs)
		{
			ref.visited = false;
			auto entry = entries.find(ref.target);
			if (entry != entries.end())
			{
				entries.erase(entry);
			}
		}
		for (const auto& entry : entries)
		{
			std::queue<std::pair<std::string,int>> refList;
			refList.push(std::make_pair(entry,-1));
			while (!refList.empty())
			{
				auto name = refList.front();
				std::string msg;
				for (int i = 0; i < name.second; i++)
				{
					msg += " ";
				}
				if (name.second > 0)
				{
					msg += "|-";
				}
				fmt::format_to(std::back_inserter(out), "{}{}\n"sv, msg, name.first);
				refList.pop();
				auto it = itemRefs.find(name.first);
				if (it != itemRefs.end())
				{
					for (Reference* ref : *it->second)
					{
						if (!ref->visited)
						{
							ref->visited = true;
							refList.push(std::make_pair(ref->target, name.second+2));
						}
					}
				}
			}
			fmt::format_to(std::back_inserter(out), "\n"sv);
		}
		return fmt::to_string(out);
	}

	void destroy(String itemName = Slice::Empty)
	{
		std::unordered_set<std::string> entries;
		if (itemName.empty())
		{
			for (const auto& life : lives)
			{
				entries.insert(life.first);
			}
			for (const auto& itemRef : itemRefs)
			{
				entries.insert(itemRef.first);
			}
			for (auto& ref : refs)
			{
				ref.visited = false;
				auto entry = entries.find(ref.target);
				if (entry != entries.end())
				{
					entries.erase(entry);
				}
			}
		}
		else
		{
			for (auto& ref : refs)
			{
				ref.visited = false;
			}
			entries.insert(itemName);
		}
		for (const auto& entry : entries)
		{
			std::vector<std::string> items;
			std::queue<std::string> refList;
			refList.push(entry);
			while (!refList.empty())
			{
				std::string name = refList.front();
				refList.pop();
				items.push_back(name);
				auto it = itemRefs.find(name);
				if (it != itemRefs.end())
				{
					for (Reference* ref : *it->second)
					{
						if (!ref->visited)
						{
							ref->visited = true;
							refList.push(ref->target);
						}
					}
				}
			}
#if DORA_DEBUG
			std::unordered_set<std::string> names;
			std::vector<std::string> nameList;
			for (auto it = items.rbegin(); it != items.rend(); ++it)
			{
				if (names.find(*it) == names.end() && lives.find(*it) != lives.end())
				{
					names.insert(*it);
					nameList.push_back(*it);
				}
			}
			if (!nameList.empty())
			{
				Info("singleton destroyed: {}.", std::accumulate(nameList.begin()+1, nameList.end(), nameList.front(),
				[](const std::string& a, const std::string& b) { return a + ", " + b; }));
			}
#endif // DORA_DEBUG
			for (auto it = items.rbegin(); it != items.rend(); ++it)
			{
				lives.erase(*it);
				itemRefs.erase(*it);
			}
		}
	}
	~LifeCycler()
	{
		destroy();
	}
	struct Reference
	{
		bool visited;
		std::string target;
	};
	std::list<Reference> refs;
	std::unordered_set<std::string> names;
	std::unordered_map<std::string, Own<Life>> lives;
	std::unordered_map<std::string, Own<std::vector<Reference*>>> itemRefs;
};

Own<LifeCycler> globalCycler;

std::once_flag initCyclerOnce;

LifeCycler* getCycler()
{
	std::call_once(initCyclerOnce, []()
	{
		globalCycler = New<LifeCycler>();
	});
	return globalCycler.get();
}

void Life::addName(String name)
{
	LifeCycler* cycler = getCycler();
	cycler->names.insert(name);
}

void Life::addDependency(String target, String dependency)
{
	LifeCycler* cycler = getCycler();
	cycler->refs.push_back(LifeCycler::Reference{false, target});
	auto it = cycler->itemRefs.find(dependency);
	if (it == cycler->itemRefs.end())
	{
		auto refList = new std::vector<LifeCycler::Reference*>();
		refList->push_back(&cycler->refs.back());
		cycler->itemRefs[dependency] = MakeOwn(refList);
	}
	else
	{
		it->second->push_back(&cycler->refs.back());
	}
}

void Life::addItem(String name, Life* life)
{
	LifeCycler* cycler = getCycler();
	AssertIf(cycler->lives.find(name) != cycler->lives.end(), "Singleton name duplicated: \"{}\".", name);
	cycler->lives[name] = MakeOwn(life);
}

void Life::destroy(String name)
{
	LifeCycler* cycler = getCycler();
	cycler->destroy(name);
}

std::string Life::getRefTree()
{
	LifeCycler* cycler = getCycler();
	return cycler->getRefTree();
}

NS_DOROTHY_END
