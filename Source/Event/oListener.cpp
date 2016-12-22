/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/oHeader.h"
#include "Event/oEvent.h"
#include "Event/oListener.h"

NS_DOROTHY_BEGIN

const int oListener::InvalidOrder = -1;

bool oListener::init()
{
	oListener::setEnabled(true);
	return true;
}

void oListener::setEnabled( bool enable )
{
	if (enable)
	{
		oEvent::reg(this);
	}
	else
	{
		oEvent::unreg(this);
	}
}

bool oListener::isEnabled() const
{
	return _order != oListener::InvalidOrder;
}

void oListener::setHandler( const oEventHandler& handler )
{
	_handler = handler;
}

const oEventHandler& oListener::getHandler() const
{
	return _handler;
}

void oListener::clearHandler()
{
	_handler.Clear();
}

void oListener::handle( oEvent* e )
{
	if (_handler)
	{
		_handler(e);
	}
}

oListener::oListener( const string& name, const oEventHandler& handler ):
_name(name),
_handler(handler),
_order(oListener::InvalidOrder)
{ }

const string& oListener::getName() const
{
	return _name;
}

oListener::~oListener()
{
	oListener::setEnabled(false);
}

NS_DOROTHY_END
