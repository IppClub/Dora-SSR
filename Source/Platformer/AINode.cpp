/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Platformer/AINode.h"
#include "Platformer/AI.h"
#include "Platformer/Unit.h"

NS_DOROTHY_PLATFORMER_BEGIN

AINode* AINode::add(AILeaf* node)
{
	_children.push_back(node);
	return this;
}

void AINode::remove(AILeaf* node)
{
	_children.remove(node);
}

void AINode::clear()
{
	_children.clear();
}

const RefVector<AILeaf>& AINode::getChildren() const
{
	return _children;
}

bool SelNode::doAction()
{
	for (AILeaf* node : _children)
	{
		if (node->doAction())
		{
			return true;
		}
	}
	return false;
}

bool SeqNode::doAction()
{
	for (AILeaf* node : _children)
	{
		if (!node->doAction())
		{
			return false;
		}
	}
	return true;
}

bool ParSelNode::doAction()
{
	bool result = true;
	for (AILeaf* node : _children)
	{
		if (!node->doAction())
		{
			result = false;
		}
	}
	return result;
}

bool ParSeqNode::doAction()
{
	bool result = false;
	for (AILeaf* node : _children)
	{
		if (node->doAction())
		{
			result = true;
		}
	}
	return result;
}

bool ConNode::doAction()
{
	if (_handler) return _handler();
	return false;
}

ConNode::ConNode(const function<bool()>& handler):
_handler(handler)
{ }

bool ActNode::doAction()
{
	return SharedAI.getSelf()->start(_actionName);
}

ActNode::ActNode(String actionName):
_actionName(actionName)
{ }

AILeaf* Sel(AILeaf* nodes[], int count)
{
	SelNode* sel = SelNode::create();
	for (int i = 0; i < count; i++)
	{
		sel->add(nodes[i]);
	}
	return sel;
}

AILeaf* Seq(AILeaf* nodes[], int count)
{
	SeqNode* seq = SeqNode::create();
	for (int i = 0; i < count; i++)
	{
		seq->add(nodes[i]);
	}
	return seq;
}

AILeaf* ParSel(AILeaf* nodes[], int count)
{
	ParSelNode* parSel = ParSelNode::create();
	for (int i = 0; i < count; i++)
	{
		parSel->add(nodes[i]);
	}
	return parSel;
}

AILeaf* ParSeq(AILeaf* nodes[], int count)
{
	ParSeqNode* parSeq = ParSeqNode::create();
	for (int i = 0; i < count; i++)
	{
		parSeq->add(nodes[i]);
	}
	return parSeq;
}

AILeaf* Con(const function<bool()>& handler)
{
	return ConNode::create(handler);
}

AILeaf* Act(String actionName)
{
	return ActNode::create(actionName);
}

NS_DOROTHY_PLATFORMER_END
