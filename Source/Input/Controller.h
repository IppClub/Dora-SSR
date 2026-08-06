/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <set>

union SDL_Event;

NS_DORA_BEGIN

class Event;

typedef Acf::Delegate<void(Event*)> ControllerHandler;

class Controller : public NonCopyable {
public:
	struct DeviceInfo {
		std::string guid;
		int instanceId = -1;
		int vendorId = 0;
		int productId = 0;
		int productVersion = 0;
		int axisCount = 0;
		int buttonCount = 0;
		int hatCount = 0;
		bool vibrationSupported = false;
	};
	struct GamepadMapping {
		std::string inputType;
		int index = -1;
		std::string hat;
	};
	virtual ~Controller();
	bool initInRender();
	bool isButtonDown(int controllerId, String name) const;
	bool isButtonUp(int controllerId, String name) const;
	bool isButtonPressed(int controllerId, String name) const;
	float getAxis(int controllerId, String name) const;
	std::vector<int> getControllerIds() const;
	String getControllerName(int controllerId) const;
	DeviceInfo getControllerInfo(int controllerId) const;
	float getControllerAxis(int controllerId, int axis) const;
	int getControllerHat(int controllerId, int hat) const;
	bool isControllerButtonPressed(int controllerId, int button) const;
	bool setControllerVibration(int controllerId, float left, float right, double duration);
	bool setGamepadMapping(std::string_view guid, std::string_view gamepadInput,
		std::string_view inputType, int index, std::string_view hat, std::string& error);
	bool loadGamepadMappings(std::string_view mappings, std::string& error);
	std::string saveGamepadMappings() const;
	std::string getGamepadMappingString(std::string_view guid) const;
	std::optional<GamepadMapping> getControllerGamepadMapping(int controllerId,
		std::string_view gamepadInput) const;
	std::string getControllerGamepadMappingString(int controllerId) const;
	ControllerHandler handler;
	void clearChanges();
	void handleEventInRender(const SDL_Event& event, bool emitEvents = true);
	void handleDevVirtualControllerEventInRender(const SDL_Event& event);

protected:
	Controller();
	void addControllerInRender(int deviceIndex);

private:
	using DeviceID = int32_t;
	struct Device {
		Device(int id, void* controller, std::string name)
			: id(id)
			, controller(controller)
			, name(std::move(name)) { }
		int id;
		void* controller;
		std::string name;
		StringMap<float> axisMap;
		struct ButtonState {
			bool oldState;
			bool newState;
		};
		StringMap<ButtonState> buttonMap;
	};
	std::unordered_map<DeviceID, Own<Device>> _deviceMap;
	std::set<std::string> _recentGamepadGuids;
	std::stack<int> _availableDeviceIds;
	void* _devVirtualController = nullptr;
	void* _devVirtualJoystick = nullptr;
	int _devVirtualDeviceIndex = -1;
	SINGLETON_REF(Controller, Director);
};

#define SharedController \
	Dora::Singleton<Dora::Controller>::shared()

NS_DORA_END
