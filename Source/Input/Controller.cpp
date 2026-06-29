/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

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

#define DORA_DEV_VIRTUAL_CONTROLLER (DORA_DEBUG && (BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX))

#if DORA_DEV_VIRTUAL_CONTROLLER
static bool isDevVirtualControllerEnabled() {
	auto value = SDL_getenv("DORA_VIRTUAL_CONTROLLER");
	return value && SDL_strcasecmp(value, "0") != 0 && SDL_strcasecmp(value, "false") != 0;
}

static Uint32 makeControllerButtonMask() {
	Uint32 mask = 0;
	for (int i = 0; i < SDL_CONTROLLER_BUTTON_MAX; ++i) {
		mask |= 1u << i;
	}
	return mask;
}

static Uint32 makeControllerAxisMask() {
	Uint32 mask = 0;
	for (int i = 0; i < SDL_CONTROLLER_AXIS_MAX; ++i) {
		mask |= 1u << i;
	}
	return mask;
}
#endif // DORA_DEV_VIRTUAL_CONTROLLER

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
#if DORA_DEV_VIRTUAL_CONTROLLER
	if (isDevVirtualControllerEnabled()) {
#if SDL_VERSION_ATLEAST(2, 24, 0)
		SDL_VirtualJoystickDesc desc;
		SDL_zero(desc);
		desc.version = SDL_VIRTUAL_JOYSTICK_DESC_VERSION;
		desc.type = SDL_JOYSTICK_TYPE_GAMECONTROLLER;
		desc.naxes = SDL_CONTROLLER_AXIS_MAX;
		desc.nbuttons = SDL_CONTROLLER_BUTTON_MAX;
		desc.button_mask = makeControllerButtonMask();
		desc.axis_mask = makeControllerAxisMask();
		desc.name = "Dora Dev Virtual Controller";
		_devVirtualDeviceIndex = SDL_JoystickAttachVirtualEx(&desc);
#else
		_devVirtualDeviceIndex = SDL_JoystickAttachVirtual(SDL_JOYSTICK_TYPE_GAMECONTROLLER, SDL_CONTROLLER_AXIS_MAX, SDL_CONTROLLER_BUTTON_MAX, 0);
#endif
		if (_devVirtualDeviceIndex >= 0) {
			addControllerInRender(_devVirtualDeviceIndex);
			Info("enabled Dora dev virtual controller. Keyboard mapping: Arrow keys/WASD=D-pad, J=A, K=B, U=X, I=Y/context, Tab=Back, Q=L1, E=R1, Enter=Start.");
		} else {
			Warn("failed to attach Dora dev virtual controller! {}", SDL_GetError());
		}
	}
#endif // DORA_DEV_VIRTUAL_CONTROLLER
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
#if DORA_DEV_VIRTUAL_CONTROLLER
	if (deviceIndex == _devVirtualDeviceIndex && _devVirtualController) return;
#endif // DORA_DEV_VIRTUAL_CONTROLLER
	auto joystickId = s_cast<DeviceID>(SDL_JoystickGetDeviceInstanceID(deviceIndex));
	if (joystickId < 0) return;
	auto controller = SDL_GameControllerOpen(deviceIndex);
	if (controller) {
#if DORA_DEV_VIRTUAL_CONTROLLER
		if (deviceIndex == _devVirtualDeviceIndex) {
			_devVirtualController = controller;
			_devVirtualJoystick = SDL_GameControllerGetJoystick(controller);
		}
#endif // DORA_DEV_VIRTUAL_CONTROLLER
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

void Controller::handleDevVirtualControllerEventInRender(const SDL_Event& event) {
#if DORA_DEV_VIRTUAL_CONTROLLER
	if (!_devVirtualJoystick) return;
	if (event.type != SDL_KEYDOWN && event.type != SDL_KEYUP) return;
	if (event.type == SDL_KEYDOWN && event.key.repeat) return;
	auto pressed = event.key.state == SDL_PRESSED ? 1 : 0;
	switch (event.key.keysym.scancode) {
		case SDL_SCANCODE_LEFT:
		case SDL_SCANCODE_A:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_DPAD_LEFT, pressed);
			break;
		case SDL_SCANCODE_RIGHT:
		case SDL_SCANCODE_D:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_DPAD_RIGHT, pressed);
			break;
		case SDL_SCANCODE_UP:
		case SDL_SCANCODE_W:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_DPAD_UP, pressed);
			break;
		case SDL_SCANCODE_DOWN:
		case SDL_SCANCODE_S:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_DPAD_DOWN, pressed);
			break;
		case SDL_SCANCODE_J:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_A, pressed);
			break;
		case SDL_SCANCODE_K:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_B, pressed);
			break;
		case SDL_SCANCODE_U:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_X, pressed);
			break;
		case SDL_SCANCODE_I:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_Y, pressed);
			break;
		case SDL_SCANCODE_TAB:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_BACK, pressed);
			break;
		case SDL_SCANCODE_Q:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_LEFTSHOULDER, pressed);
			break;
		case SDL_SCANCODE_E:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_RIGHTSHOULDER, pressed);
			break;
		case SDL_SCANCODE_RETURN:
		case SDL_SCANCODE_RETURN2:
			SDL_JoystickSetVirtualButton(s_cast<SDL_Joystick*>(_devVirtualJoystick), SDL_CONTROLLER_BUTTON_START, pressed);
			break;
		default:
			break;
	}
#else
	DORA_UNUSED_PARAM(event);
#endif // DORA_DEV_VIRTUAL_CONTROLLER
}

void Controller::handleEventInRender(const SDL_Event& event, bool emitEvents) {
	switch (event.type) {
		case SDL_CONTROLLERDEVICEADDED:
			addControllerInRender(event.cdevice.which);
			break;
		case SDL_CONTROLLERDEVICEREMOVED: {
			auto joystickId = s_cast<DeviceID>(event.cdevice.which);
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
			SharedApplication.invokeInLogic([axisName, joystickId, value, emitEvents, this]() {
				if (auto it = _deviceMap.find(joystickId); it != _deviceMap.end()) {
					if (!emitEvents) {
						it->second->axisMap[axisName] = 0.0f;
						return;
					}
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
			SharedApplication.invokeInLogic([buttonName, joystickId, isDown, emitEvents, this]() {
				if (auto it = _deviceMap.find(joystickId); it != _deviceMap.end()) {
					if (!emitEvents) {
						it->second->buttonMap[buttonName] = Device::ButtonState{.oldState = false, .newState = false};
						return;
					}
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
