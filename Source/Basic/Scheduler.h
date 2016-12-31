/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Scheduler : public Object
{
	typedef Delegate<void (double deltaTime, Scheduler* scheduler)> UpdateHandler;
public:
	PROPERTY(float, _timeScale, TimeScale);
	void schedule(Object* object);
	void schedule(const function<bool (double)>& handler);
	void unschedule(Object* object);
	void unschedule(const function<bool (double)>& handler);
	virtual bool update(double deltaTime) override;
	CREATE_FUNC(Scheduler)
protected:	
	Scheduler();
private:
	UpdateHandler _updateHandler;
	LUA_TYPE_OVERRIDE(Scheduler);
};

NS_DOROTHY_END
