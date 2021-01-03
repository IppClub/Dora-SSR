/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Menu.h"
#include "Input/TouchDispather.h"

NS_DOROTHY_BEGIN

Menu::Menu():
_enabled(true),
_selectedItem(nullptr)
{
	setTouchEnabled(true);
	_flags.setOff(Node::TraverseEnabled);
}

Menu::Menu(float width, float height):Menu()
{
	setSize(Size{width,height});
}

void Menu::setEnabled(bool var)
{
	_enabled = var;
}

bool Menu::isEnabled() const
{
	return _enabled;
}

bool Menu::init()
{
	if (!Node::init()) return false;
	slot("TapFilter"_slice, [&](Event* e)
	{
		Touch* touch; e->get(touch);
		if (_selectedItem || !_enabled)
		{
			touch->setEnabled(false);
		}
	});
	slot("TapBegan"_slice, [&](Event* e)
	{
		Touch* touch; e->get(touch);
		_selectedItem = itemForTouch(touch);
		if (_selectedItem)
		{
			_selectedItem->emit("TapBegan"_slice, touch);
		}
		else touch->setEnabled(false);
	});
	slot("TapMoved"_slice, [&](Event* e)
	{
		Touch* touch; e->get(touch);
		Node* currentItem = itemForTouch(touch);
		if (!_enabled)
		{
			if (currentItem && currentItem == _selectedItem)
			{
				_selectedItem->emit("TapEnded"_slice, touch);
				_selectedItem = nullptr;
			}
			return;
		}
		if (currentItem != _selectedItem)
		{
			if (_selectedItem)
			{
				_selectedItem->emit("TapEnded"_slice, touch);
			}
			_selectedItem = currentItem;
			if (currentItem)
			{
				currentItem->emit("TapBegan"_slice, touch);
			}
		}
	});
	slot("TapEnded"_slice, [&](Event* e)
	{
		Touch* touch; e->get(touch);
		if (_selectedItem)
		{
			_selectedItem->emit("TapEnded"_slice, touch);
			if (_enabled)
			{
				_selectedItem->emit("Tapped"_slice, touch);
			}
			_selectedItem = nullptr;
		}
	});
	return true;
}

static Node* getTouchedItem(Node* parentItem, const Vec2& worldLocation)
{
	Array* children = parentItem->getChildren();
	if (children && !children->isEmpty())
	{
		for (int i = s_cast<int>(children->getCount()) - 1; i >= 0; i--)
		{
			Node* childItem = &children->get(i)->to<Node>();
			if (childItem && childItem->isVisible() && childItem->isTouchEnabled())
			{
				Vec2 local = childItem->convertToNodeSpace(worldLocation);
				if (Rect(Vec2::zero, childItem->getSize()).containsPoint(local))
				{
					Node* targetItem = getTouchedItem(childItem, worldLocation);
					return targetItem ? targetItem : childItem;
				}
			}
		}
	}
	return parentItem;
}

Node* Menu::itemForTouch(Touch* touch)
{
	Vec2 worldLocation = touch->getWorldLocation();
	if (_children && !_children->isEmpty())
	{
		for (int i = s_cast<int>(_children->getCount()) - 1; i >= 0; i--)
		{
			Node* childItem = &_children->get(i)->to<Node>();
			if (childItem && childItem->isVisible() && childItem->isTouchEnabled())
			{
				Vec2 local = childItem->convertToNodeSpace(worldLocation);
				if (Rect(Vec2::zero, childItem->getSize()).containsPoint(local))
				{
					return getTouchedItem(childItem, worldLocation);
				}
			}
		}
	}
	return nullptr;
}

NS_DOROTHY_END
