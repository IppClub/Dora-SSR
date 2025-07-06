/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Input/Controller.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Event/Event.h"

#include "SDL.h"

NS_DORA_BEGIN

Controller::Controller() {
	static_assert(sizeof(SDL_JoystickID) <= sizeof(DeviceID), "can not hold SDL_JoystickID in DeviceID");
}

Controller::~Controller() { }

bool Controller::initInRender() {
	SDL_SetHint(SDL_HINT_ACCELEROMETER_AS_JOYSTICK, "0");
	auto time = SharedApplication.getCurrentTime();
	if (SharedContent.exist("gamecontrollerdb.txt"_slice)) {
		int64_t size = 0;
		uint8_t* buffer = SharedContent.loadUnsafe("gamecontrollerdb.txt"_slice, size);
		OwnArray<uint8_t> data(buffer);
		if (size > 0) {
			const char* platform = SDL_GetPlatform();
			auto str = std::string{r_cast<const char*>(data.get()), s_cast<size_t>(size)};
			char *line, *line_end, *tmp, *comma, line_platform[64];
			size_t db_size = str.size(), platform_len;
			char* buf = &str[0];
			line = buf;
			auto platformStr = "platform:"sv;
			while (line < buf + db_size) {
				line_end = SDL_strchr(line, '\n');
				if (line_end != nullptr) {
					*line_end = '\0';
				} else {
					line_end = buf + db_size;
				}
				tmp = SDL_strstr(line, platformStr.data());
				if (tmp != nullptr) {
					tmp += platformStr.size();
					comma = SDL_strchr(tmp, ',');
					if (comma != nullptr) {
						platform_len = comma - tmp + 1;
						if (platform_len + 1 < SDL_arraysize(line_platform)) {
							SDL_strlcpy(line_platform, tmp, platform_len);
							if (SDL_strncasecmp(line_platform, platform, platform_len) == 0) {
								if (SDL_GameControllerAddMapping(line) < 0) {
									Error("failed to load controller mapping: {}", line);
								}
							}
						}
					}
				}
				line = line_end + 1;
			}
			auto deltaTime = SharedApplication.getCurrentTime() - time;
			SharedApplication.invokeInLogic([deltaTime]() {
				Event::send(Profiler::EventName, "Loader"s, "gamecontrollerdb.txt"s, 0, deltaTime);
			});
		}
	}
	for (int i = 0; i < SDL_NumJoysticks(); ++i) {
		addControllerInRender(i);
	}
	return true;
}

bool Controller::isButtonDown(int controllerId, String name) const {
	for (const auto& device : _deviceMap) {
		if (device.second->id == controllerId) {
			const auto& buttonMap = device.second->buttonMap;
			if (auto it = buttonMap.find(name); it != buttonMap.end()) {
				return !it->second.oldState && it->second.newState;
			}
		}
	}
	return false;
}

bool Controller::isButtonUp(int controllerId, String name) const {
	for (const auto& device : _deviceMap) {
		if (device.second->id == controllerId) {
			const auto& buttonMap = device.second->buttonMap;
			if (auto it = buttonMap.find(name); it != buttonMap.end()) {
				return it->second.oldState && !it->second.newState;
			}
		}
	}
	return false;
}

bool Controller::isButtonPressed(int controllerId, String name) const {
	for (const auto& device : _deviceMap) {
		if (device.second->id == controllerId) {
			const auto& buttonMap = device.second->buttonMap;
			if (auto it = buttonMap.find(name); it != buttonMap.end()) {
				return it->second.newState;
			}
		}
	}
	return false;
}

float Controller::getAxis(int controllerId, String name) const {
	for (const auto& device : _deviceMap) {
		if (device.second->id == controllerId) {
			const auto& axisMap = device.second->axisMap;
			if (auto it = axisMap.find(name); it != axisMap.end()) {
				return it->second;
			}
		}
	}
	return 0.0f;
}

void Controller::clearChanges() {
	for (const auto& device : _deviceMap) {
		for (auto& button : device.second->buttonMap) {
			button.second.oldState = button.second.newState;
			if (button.second.newState) {
				EventArgs<int, Slice> buttonPressed("ButtonPressed"_slice, device.first, button.first);
				handler(&buttonPressed);
			}
		}
	}
}

void Controller::addControllerInRender(int deviceIndex) {
	auto joystickId = s_cast<DeviceID>(SDL_JoystickGetDeviceInstanceID(deviceIndex));
	if (joystickId < 0) return;
	auto controller = SDL_GameControllerOpen(deviceIndex);
	if (controller) {
		SharedApplication.invokeInLogic([controller, joystickId, this]() {
			if (_deviceMap.contains(joystickId)) return;
			int deviceId = -1;
			if (!_availableDeviceIds.empty()) {
				deviceId = _availableDeviceIds.top();
				_availableDeviceIds.pop();
			} else {
				deviceId = s_cast<int>(_deviceMap.size());
			}
			_deviceMap[joystickId] = New<Device>(deviceId, controller);
		});
	} else {
		Warn("failed to open a new controller! {}", SDL_GetError());
	}
}

void Controller::handleEventInRender(const SDL_Event& event) {
	switch (event.type) {
		case SDL_CONTROLLERDEVICEADDED:
			addControllerInRender(event.cdevice.which);
			break;
		case SDL_CONTROLLERDEVICEREMOVED: {
			auto joystickId = s_cast<DeviceID>(SDL_JoystickGetDeviceInstanceID(event.cdevice.which));
			if (joystickId < 0) break;
			if (auto it = _deviceMap.find(joystickId); it != _deviceMap.end()) {
				SDL_GameControllerClose(s_cast<SDL_GameController*>(it->second->controller));
				SharedApplication.invokeInLogic([joystickId, this]() {
					if (auto it = _deviceMap.find(joystickId); it != _deviceMap.end()) {
						_availableDeviceIds.push(it->second->id);
						_deviceMap.erase(it);
					}
				});
			}
			break;
		}
		case SDL_CONTROLLERAXISMOTION: {
			auto joystickId = s_cast<DeviceID>(event.caxis.which);
			std::string axisName = SDL_GameControllerGetStringForAxis(s_cast<SDL_GameControllerAxis>(event.caxis.axis));
			float value = s_cast<float>(event.caxis.value) / SDL_JOYSTICK_AXIS_MAX;
			SharedApplication.invokeInLogic([axisName, joystickId, value, this]() {
				if (auto it = _deviceMap.find(joystickId); it != _deviceMap.end()) {
					it->second->axisMap[axisName] = value;
					EventArgs<int, Slice, float> axis("Axis"_slice, it->second->id, axisName, value);
					handler(&axis);
				}
			});
			break;
		}
		case SDL_CONTROLLERBUTTONDOWN:
		case SDL_CONTROLLERBUTTONUP: {
			auto joystickId = s_cast<DeviceID>(event.cbutton.which);
			std::string buttonName = SDL_GameControllerGetStringForButton(s_cast<SDL_GameControllerButton>(event.cbutton.button));
			bool isDown = event.cbutton.state > 0;
			SharedApplication.invokeInLogic([buttonName, joystickId, isDown, this]() {
				if (auto it = _deviceMap.find(joystickId); it != _deviceMap.end()) {
					Device::ButtonState state{.oldState = false, .newState = false};
					if (auto bit = it->second->buttonMap.find(buttonName); bit != it->second->buttonMap.end()) {
						bit->second.newState = isDown;
						state = bit->second;
					} else {
						state.newState = isDown;
						it->second->buttonMap[buttonName] = state;
					}
					if (!state.oldState && state.newState) {
						EventArgs<int, Slice> button("ButtonDown"_slice, it->second->id, buttonName);
						handler(&button);
					} else if (state.oldState && !state.newState) {
						EventArgs<int, Slice> button("ButtonUp"_slice, it->second->id, buttonName);
						handler(&button);
					}
				}
			});
			break;
		}
		default:
			break;
	}
}

NS_DORA_END
