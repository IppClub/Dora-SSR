/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

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

/* SelNode */

bool SelNode::doAction(Unit* self)
{
	if (self->isReceivingDecisionTrace())
	{
		auto& decisionNodes = SharedAI.getDecisionNodes();
		size_t oldSize = decisionNodes.size();
		bool result = false;
		for (AILeaf* node : _children)
		{
			if (node->doAction(self))
			{
				result = true;
				break;
			}
		}
		if (!result)
		{
			if (oldSize == 0) decisionNodes.clear();
			else
			{
				size_t newSize = decisionNodes.size();
				while (newSize > oldSize)
				{
					decisionNodes.pop_back();
					newSize--;
				}
			}
		}
		return result;
	}
	else
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
}

/* SeqNode */

bool SeqNode::doAction(Unit* self)
{
	if (self->isReceivingDecisionTrace())
	{
		auto& decisionNodes = SharedAI.getDecisionNodes();
		size_t oldSize = decisionNodes.size();
		bool result = true;
		for (AILeaf* node : _children)
		{
			if (!node->doAction(self))
			{
				result = false;
				break;
			}
		}
		if (!result)
		{
			if (oldSize == 0) decisionNodes.clear();
			else
			{
				size_t newSize = decisionNodes.size();
				while (newSize > oldSize)
				{
					decisionNodes.pop_back();
					newSize--;
				}
			}
		}
		return result;
	}
	else
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
}

/* ParSelNode */

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

/* ConNode */

bool ConNode::doAction(Unit* self)
{
	if (_handler && _handler(self))
	{
		if (self->isReceivingDecisionTrace() && !_name.empty())
		{
			SharedAI.getDecisionNodes().push_back(_name);
		}
		return true;
	}
	return false;
}

ConNode::ConNode(String name, const function<bool(Unit*)>& handler):
_name(name),
_handler(handler)
{ }

/* ActNode */

bool ActNode::doAction(Unit* self)
{
	if (self->start(_actionName))
	{
		if (self->isReceivingDecisionTrace() && !_actionName.empty())
		{
			SharedAI.getDecisionNodes().push_back(_actionName);
		}
		return true;
	}
	return false;
}

ActNode::ActNode(String actionName):
_actionName(actionName)
{ }

/* DynamicActNode */

bool DynamicActNode::doAction(Unit* self)
{
	auto actionName = _handler(self);
	if (self->start(actionName))
	{
		if (self->isReceivingDecisionTrace() && !actionName.empty())
		{
			SharedAI.getDecisionNodes().push_back("[dynamic] "_slice + actionName);
		}
		return true;
	}
	return false;
}

DynamicActNode::DynamicActNode(const function<string(Unit*)>& handler):
_handler(handler)
{ }

/* PassNode */

bool PassNode::doAction(Unit* self)
{
	DORA_UNUSED_PARAM(self);
	return true;
}

/* RejectNode */

bool RejectNode::doAction(Unit* self)
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

AILeaf* Con(String name, const function<bool(Unit*)>& handler)
{
	return ConNode::create(name, handler);
}

AILeaf* Act(String actionName)
{
	return ActNode::create(actionName);
}

AILeaf* Act(const function<string(Unit*)>& handler)
{
	return DynamicActNode::create(handler);
}

AILeaf* Pass()
{
	return PassNode::create();
}

AILeaf* Reject()
{
	return RejectNode::create();
}

NS_DOROTHY_PLATFORMER_END
