/* Copyright (c) 2013 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_OLISTENER_H__
#define __DOROTHY_OLISTENER_H__

NS_DOROTHY_BEGIN

class oEvent;
class oEventType;

typedef Delegate<void (oEvent* event)> oEventHandler;

/** @brief Use event listener to handle event. */
class oListener: public oObject
{
public:
	~oListener();
	virtual bool init() override;
	const string& getName() const;
	/** True to receive event and handle it, false to not receive event. */
	void setEnabled(bool enable);
	/** Get is registered. */
	bool isEnabled() const;
	/** Change the callback delegate. */
	void setHandler(const oEventHandler& handler);
	/** Get callback delegate. */
	const oEventHandler& getHandler() const;
	void clearHandler();
	/** Invoked when event is received. */
	void handle(oEvent* e);
	/** Use it to create a new listener. You may want to get the listener retained for future use. */
	CREATE_FUNC(oListener);
protected:
	oListener(const string& name, const oEventHandler& handler);
	oListener(const string& name, int handler);
	static const int InvalidOrder;
	string _name;
	int _order;
	oEventHandler _handler;
	friend class oEventType;
	LUA_TYPE_OVERRIDE(oListener)
};

NS_DOROTHY_END

#endif //__DOROTHY_OLISTENER_H__
