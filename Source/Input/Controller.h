/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

union SDL_Event;

NS_DORA_BEGIN

class Event;

typedef Acf::Delegate<void(Event*)> ControllerHandler;

class Controller : public NonCopyable {
public:
	virtual ~Controller();
	bool initInRender();
	bool isButtonDown(int controllerId, String name) const;
	bool isButtonUp(int controllerId, String name) const;
	bool isButtonPressed(int controllerId, String name) const;
	float getAxis(int controllerId, String name) const;
	ControllerHandler handler;
	void clearChanges();
	void handleEventInRender(const SDL_Event& event);

protected:
	Controller();
	void addControllerInRender(int deviceIndex);

private:
	using DeviceID = int32_t;
	struct Device {
		Device(int id, void* controller)
			: id(id)
			, controller(controller) { }
		int id;
		void* controller;
		StringMap<float> axisMap;
		struct ButtonState {
			bool oldState;
			bool newState;
		};
		StringMap<ButtonState> buttonMap;
	};
	std::unordered_map<DeviceID, Own<Device>> _deviceMap;
	std::stack<int> _availableDeviceIds;
	SINGLETON_REF(Controller, Director);
};

#define SharedController \
	Dora::Singleton<Dora::Controller>::shared()

NS_DORA_END
