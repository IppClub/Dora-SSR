/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "ML/ML.h"
#include "ml/DecisionTree.h"
#include "Common/Async.h"

NS_DOROTHY_BEGIN

void ML::buildDecisionTreeAsync(String data, int maxDepth,
	const std::function<void(double, String,String,String)>& handleTree)
{
	auto dataStr = std::make_shared<string>(data.rawData(), data.size());
	SharedAsyncThread.run([dataStr, maxDepth]()
	{
		auto result = GaGa::DecisionTree::BuildTest(std::move(*dataStr), maxDepth);
		return Values::alloc(std::move(result));
	}, [handleTree](Own<Values> values)
	{
		std::pair<std::list<GaGa::DecisionTree::Node>, double> result;
		values->get(result);
		handleTree(result.second, Slice::Empty, Slice::Empty, Slice::Empty);
		for (const auto& node : result.first)
		{
			handleTree(node.depth, node.name, node.op, node.value);
		}
	});
}

NS_DOROTHY_END
