/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "ML/ML.h"
#include "ml/DecisionTree.h"
#include "Common/Async.h"

NS_DOROTHY_BEGIN

void BuildDecisionTreeAsync(String data, int maxDepth,
	const std::function<void(double, String,String,String)>& handleTree)
{
	auto dataStr = std::make_shared<std::string>(data.rawData(), data.size());
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

/* QLearner */

QLearner::QState QLearner::pack(const std::vector<Uint32>& hints, const std::vector<Uint32>& values)
{
	AssertUnless(hints.size() == values.size(), "Q state must be packed with same number of categorical hints with values");
	int currentBit = 0;
	QLearner::QState state = 0;
	for (size_t i = 0; i < hints.size(); i++)
	{
		Uint32 kind = hints[i];
		Uint32 value = values[i];
		AssertIf(value >= kind, "categorical value {} of index {} is greater or equal than {}", value, i, kind);
		state += (s_cast<QLearner::QState>(value) << currentBit);
		int bit = 1;
		while ((1 << bit) < kind) bit++;
		currentBit += bit;
	}
	AssertIf(currentBit > sizeof(QLearner::QState) * 8, "can only pack values into {} bits instead of {} bits", sizeof(QLearner::QState) * 8, currentBit);
	return state;
}

QLearner::QLearner(double gamma, double alpha, double maxQ):
_gamma(gamma),
_alpha(alpha),
_maxQ(maxQ),
_currentState(0)
{ }

QLearner::QState QLearner::getCurrentState() const
{
	return _currentState;
}

QLearner::QAction QLearner::getBestAction(QState state) const
{
	QAction action = 0;
	double q = _maxQ;
	auto sit = _values.find(state);
	if (sit != _values.end())
	{
		for (const auto& ait : sit->second)
		{
			if (ait.second > q)
			{
				q = ait.second;
				action = ait.first;
			}
		}
	}
	return action;
}

void QLearner::setQ(QState s, QAction a, double q)
{
	auto result = _values.emplace(s, std::map<QAction, double>());
	result.first->second[a] = q;
}

const QLearner::QMatrix& QLearner::getMatrix() const
{
	return _values;
}

double QLearner::getQ(QState s, QAction a) const
{
	auto sit = _values.find(s);
	if (sit != _values.end())
	{
		auto ait = sit->second.find(a);
		if (ait != sit->second.end())
		{
			return ait->second;
		}
	}
	return _maxQ;
}

void QLearner::iterate(QState newState)
{
	_currentState = newState;
}

void QLearner::iterate(QAction testAction, QState newState, double reward)
{
	QState oldState = _currentState;
	double maxQ = getMaxQ(oldState);
	double oldQ = getQ(oldState, testAction);
	double newQ = (1.0 - _alpha) * oldQ + _alpha * reward + _gamma * maxQ;
	setQ(oldState, testAction, newQ);
}

double QLearner::getMaxQ(QState state) const
{
	double q = _maxQ;
	auto sit = _values.find(state);
	if (sit != _values.end())
	{
		for (const auto& ait : sit->second)
		{
			if (ait.second > q)
			{
				q = ait.second;
			}
		}
	}
	return q;
}

NS_DOROTHY_END
