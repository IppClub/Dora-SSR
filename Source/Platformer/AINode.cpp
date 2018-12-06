/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Platformer/AINode.h"
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

bool SelNode::doAction(Unit* self)
{
	for (AILeaf* node : _children)
	{
		if (node->doAction(self))
		{
			return true;
		}
	}
	return false;
}

bool SeqNode::doAction(Unit* self)
{
	for (AILeaf* node : _children)
	{
		if (!node->doAction(self))
		{
			return false;
		}
	}
	return true;
}

bool ParSelNode::doAction(Unit* self)
{
	bool result = true;
	for (AILeaf* node : _children)
	{
		if (!node->doAction(self))
		{
			result = false;
		}
	}
	return result;
}

bool ParSeqNode::doAction(Unit* self)
{
	bool result = false;
	for (AILeaf* node : _children)
	{
		if (node->doAction(self))
		{
			result = true;
		}
	}
	return result;
}

bool ConNode::doAction(Unit* self)
{
	if (_handler) return _handler(self);
	return false;
}

ConNode::ConNode(const function<bool(Unit*)>& handler):
_handler(handler)
{ }

bool ActNode::doAction(Unit* self)
{
	return self->start(_actionName);
}

ActNode::ActNode(String actionName):
_actionName(actionName)
{ }

bool TrueNode::doAction(Unit* self)
{
	DORA_UNUSED_PARAM(self);
	return true;
}

bool FalseNode::doAction(Unit* self)
{
	DORA_UNUSED_PARAM(self);
	return false;
}

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

AILeaf* Con(const function<bool(Unit*)>& handler)
{
	return ConNode::create(handler);
}

AILeaf* Act(String actionName)
{
	return ActNode::create(actionName);
}

AILeaf* True()
{
	return TrueNode::create();
}

AILeaf* False()
{
	return FalseNode::create();
}

NS_DOROTHY_PLATFORMER_END
