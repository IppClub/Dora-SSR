/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <map>

NS_DOROTHY_BEGIN

void BuildDecisionTreeAsync(String data, int maxDepth,
	const std::function<void(double,String,String,String)>& handleTree);

class QLearner : public Object
{
public:
	using QState = uint64_t;
	using QAction = uint32_t; // action must start with 1, 0 means invalid action
	using QMatrix = std::map<QState, std::map<QAction, double>>;
public:
	PROPERTY_READONLY(QState, CurrentState);
	void iterate(QState newState);
	void iterate(QAction action, QState newState, double reward);
	QAction getBestAction(QState state) const;
	const QMatrix& getMatrix() const;
	static QState pack(const std::vector<Uint32>& hints, const std::vector<Uint32>& values);
	CREATE_FUNC(QLearner);
public:
	void setQ(QState s, QAction a, double q);
protected:
	QLearner(double gamma = 0.5, double alpha = 0.5, double maxQ = 100.0);
	double getMaxQ(QState state) const;
	double getQ(QState s, QAction a) const;
private:
	double _maxQ;
	double _gamma;
	double _alpha;
	QState _currentState;
	QMatrix _values;
	DORA_TYPE_OVERRIDE(QLearner);
};

NS_DOROTHY_END
