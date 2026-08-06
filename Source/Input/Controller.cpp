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

#include <sstream>

NS_DORA_BEGIN

#define DORA_DEV_VIRTUAL_CONTROLLER (DORA_DEBUG && (BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX))

static SDL_GameControllerAxis gamepadAxisFromLove(std::string_view name) {
	if (name == "leftx") return SDL_CONTROLLER_AXIS_LEFTX;
	if (name == "lefty") return SDL_CONTROLLER_AXIS_LEFTY;
	if (name == "rightx") return SDL_CONTROLLER_AXIS_RIGHTX;
	if (name == "righty") return SDL_CONTROLLER_AXIS_RIGHTY;
	if (name == "triggerleft") return SDL_CONTROLLER_AXIS_TRIGGERLEFT;
	if (name == "triggerright") return SDL_CONTROLLER_AXIS_TRIGGERRIGHT;
	return SDL_CONTROLLER_AXIS_INVALID;
}

static SDL_GameControllerButton gamepadButtonFromLove(std::string_view name) {
	if (name == "a") return SDL_CONTROLLER_BUTTON_A;
	if (name == "b") return SDL_CONTROLLER_BUTTON_B;
	if (name == "x") return SDL_CONTROLLER_BUTTON_X;
	if (name == "y") return SDL_CONTROLLER_BUTTON_Y;
	if (name == "back") return SDL_CONTROLLER_BUTTON_BACK;
	if (name == "guide") return SDL_CONTROLLER_BUTTON_GUIDE;
	if (name == "start") return SDL_CONTROLLER_BUTTON_START;
	if (name == "leftstick") return SDL_CONTROLLER_BUTTON_LEFTSTICK;
	if (name == "rightstick") return SDL_CONTROLLER_BUTTON_RIGHTSTICK;
	if (name == "leftshoulder") return SDL_CONTROLLER_BUTTON_LEFTSHOULDER;
	if (name == "rightshoulder") return SDL_CONTROLLER_BUTTON_RIGHTSHOULDER;
	if (name == "dpup") return SDL_CONTROLLER_BUTTON_DPAD_UP;
	if (name == "dpdown") return SDL_CONTROLLER_BUTTON_DPAD_DOWN;
	if (name == "dpleft") return SDL_CONTROLLER_BUTTON_DPAD_LEFT;
	if (name == "dpright") return SDL_CONTROLLER_BUTTON_DPAD_RIGHT;
	return SDL_CONTROLLER_BUTTON_INVALID;
}

static std::string sdlGamepadInputName(std::string_view name) {
	if (const auto axis = gamepadAxisFromLove(name); axis != SDL_CONTROLLER_AXIS_INVALID)
		return SDL_GameControllerGetStringForAxis(axis);
	if (const auto button = gamepadButtonFromLove(name); button != SDL_CONTROLLER_BUTTON_INVALID)
		return SDL_GameControllerGetStringForButton(button);
	return {};
}

static int hatMaskFromLove(std::string_view name) {
	if (name == "c") return SDL_HAT_CENTERED;
	if (name == "u") return SDL_HAT_UP;
	if (name == "r") return SDL_HAT_RIGHT;
	if (name == "d") return SDL_HAT_DOWN;
	if (name == "l") return SDL_HAT_LEFT;
	if (name == "ru") return SDL_HAT_RIGHTUP;
	if (name == "rd") return SDL_HAT_RIGHTDOWN;
	if (name == "lu") return SDL_HAT_LEFTUP;
	if (name == "ld") return SDL_HAT_LEFTDOWN;
	return -1;
}

static std::string loveHatFromMask(int value) {
	switch (value) {
		case SDL_HAT_UP: return "u";
		case SDL_HAT_RIGHT: return "r";
		case SDL_HAT_DOWN: return "d";
		case SDL_HAT_LEFT: return "l";
		case SDL_HAT_RIGHTUP: return "ru";
		case SDL_HAT_RIGHTDOWN: return "rd";
		case SDL_HAT_LEFTUP: return "lu";
		case SDL_HAT_LEFTDOWN: return "ld";
		default: return "c";
	}
}

static void removeControllerBind(std::string& mapping, const std::string& bind) {
	auto position = mapping.find(bind + ',');
	if (position == std::string::npos) {
		position = mapping.rfind(bind);
		if (position == std::string::npos || position != mapping.size() - bind.size()) return;
	}
	auto start = mapping.rfind(',', position);
	if (start == std::string::npos || start >= mapping.size() - 1) return;
	++start;
	auto end = mapping.find(',', start + 1);
	if (end == std::string::npos) end = mapping.size() - 1;
	mapping.replace(start, end - start + 1, "");
}

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

std::vector<int> Controller::getControllerIds() const {
	std::vector<int> ids;
	ids.reserve(_deviceMap.size());
	for (const auto& device : _deviceMap) {
		ids.push_back(device.second->id);
	}
	std::sort(ids.begin(), ids.end());
	return ids;
}

String Controller::getControllerName(int controllerId) const {
	for (const auto& device : _deviceMap) {
		if (device.second->id == controllerId) return device.second->name;
	}
	return Slice::Empty;
}

Controller::DeviceInfo Controller::getControllerInfo(int controllerId) const {
	DeviceInfo info;
	for (const auto& device : _deviceMap) {
		if (device.second->id != controllerId) continue;
		auto controller = s_cast<SDL_GameController*>(device.second->controller);
		auto joystick = SDL_GameControllerGetJoystick(controller);
		char guid[33] = {};
		SDL_JoystickGetGUIDString(SDL_JoystickGetGUID(joystick), guid, sizeof(guid));
		info.guid = guid;
		info.instanceId = SDL_JoystickInstanceID(joystick);
		info.vendorId = SDL_GameControllerGetVendor(controller);
		info.productId = SDL_GameControllerGetProduct(controller);
		info.productVersion = SDL_GameControllerGetProductVersion(controller);
		info.axisCount = SDL_JoystickNumAxes(joystick);
		info.buttonCount = SDL_JoystickNumButtons(joystick);
		info.hatCount = SDL_JoystickNumHats(joystick);
		info.vibrationSupported = SDL_GameControllerHasRumble(controller) == SDL_TRUE;
		return info;
	}
	return info;
}

float Controller::getControllerAxis(int controllerId, int axis) const {
	for (const auto& device : _deviceMap) {
		if (device.second->id != controllerId) continue;
		auto joystick = SDL_GameControllerGetJoystick(s_cast<SDL_GameController*>(device.second->controller));
		if (axis < 0 || axis >= SDL_JoystickNumAxes(joystick)) return 0.0f;
		const Sint16 value = SDL_JoystickGetAxis(joystick, axis);
		return value < 0 ? s_cast<float>(value) / 32768.0f : s_cast<float>(value) / 32767.0f;
	}
	return 0.0f;
}

int Controller::getControllerHat(int controllerId, int hat) const {
	for (const auto& device : _deviceMap) {
		if (device.second->id != controllerId) continue;
		auto joystick = SDL_GameControllerGetJoystick(s_cast<SDL_GameController*>(device.second->controller));
		if (hat < 0 || hat >= SDL_JoystickNumHats(joystick)) return SDL_HAT_CENTERED;
		return SDL_JoystickGetHat(joystick, hat);
	}
	return SDL_HAT_CENTERED;
}

bool Controller::isControllerButtonPressed(int controllerId, int button) const {
	for (const auto& device : _deviceMap) {
		if (device.second->id != controllerId) continue;
		auto joystick = SDL_GameControllerGetJoystick(s_cast<SDL_GameController*>(device.second->controller));
		return button >= 0 && button < SDL_JoystickNumButtons(joystick)
			&& SDL_JoystickGetButton(joystick, button) != 0;
	}
	return false;
}

bool Controller::setControllerVibration(int controllerId, float left, float right, double duration) {
	for (const auto& device : _deviceMap) {
		if (device.second->id != controllerId) continue;
		auto controller = s_cast<SDL_GameController*>(device.second->controller);
		if (SDL_GameControllerHasRumble(controller) != SDL_TRUE) return false;
		const Uint16 low = s_cast<Uint16>(Math::clamp(left, 0.0f, 1.0f) * 65535.0f);
		const Uint16 high = s_cast<Uint16>(Math::clamp(right, 0.0f, 1.0f) * 65535.0f);
		const Uint32 milliseconds = duration < 0.0
			? std::numeric_limits<Uint32>::max()
			: s_cast<Uint32>(Math::clamp(duration * 1000.0, 0.0,
				s_cast<double>(std::numeric_limits<Uint32>::max())));
		return SDL_GameControllerRumble(controller, low, high, milliseconds) == 0;
	}
	return false;
}

bool Controller::setGamepadMapping(std::string_view guid, std::string_view gamepadInput,
	std::string_view inputType, int index, std::string_view hat, std::string& error) {
	if (guid.size() != 32) {
		error = "Invalid joystick GUID: " + std::string(guid);
		return false;
	}
	const std::string inputName = sdlGamepadInputName(gamepadInput);
	if (inputName.empty()) {
		error = "Invalid gamepad axis/button: " + std::string(gamepadInput);
		return false;
	}
	if (index < 0) {
		error = "Invalid joystick input value";
		return false;
	}
	std::string bind;
	if (inputType == "axis") bind = "a" + std::to_string(index);
	else if (inputType == "button") bind = "b" + std::to_string(index);
	else if (inputType == "hat") {
		const int mask = hatMaskFromLove(hat);
		if (mask <= SDL_HAT_CENTERED) {
			error = "Invalid joystick hat: " + std::string(hat);
			return false;
		}
		bind = "h" + std::to_string(index) + "." + std::to_string(mask);
	} else {
		error = "Invalid joystick input type: " + std::string(inputType);
		return false;
	}

	const SDL_JoystickGUID sdlGuid = SDL_JoystickGetGUIDFromString(std::string(guid).c_str());
	std::string mapping;
	if (char* existing = SDL_GameControllerMappingForGUID(sdlGuid)) {
		mapping = existing;
		SDL_free(existing);
	} else {
		std::string name = "Controller";
		for (const auto& [deviceId, device] : _deviceMap) {
			(void)deviceId;
			auto joystick = SDL_GameControllerGetJoystick(s_cast<SDL_GameController*>(device->controller));
			char currentGuid[33] = {};
			SDL_JoystickGetGUIDString(SDL_JoystickGetGUID(joystick), currentGuid, sizeof(currentGuid));
			if (guid == currentGuid) {
				name = device->name;
				break;
			}
		}
		mapping = std::string(guid) + "," + name + ",";
	}
	if (!mapping.empty() && mapping.back() != ',') mapping += ',';
	removeControllerBind(mapping, bind);
	const std::string replacement = inputName + ':' + bind + ',';
	if (const auto position = mapping.find(',' + inputName + ':'); position != std::string::npos) {
		auto end = mapping.find(',', position + 1);
		if (end == std::string::npos) end = mapping.size() - 1;
		mapping.replace(position + 1, end - position, replacement);
	} else if (const auto platform = mapping.find("platform:"); platform != std::string::npos) {
		mapping.insert(platform, replacement);
	} else {
		mapping += replacement;
	}
	if (SDL_GameControllerAddMapping(mapping.c_str()) < 0) {
		error = SDL_GetError();
		return false;
	}
	_recentGamepadGuids.insert(std::string(guid));
	error.clear();
	return true;
}

bool Controller::loadGamepadMappings(std::string_view mappings, std::string& error) {
	std::istringstream stream{std::string(mappings)};
	std::string mapping;
	bool success = false;
	while (std::getline(stream, mapping)) {
		if (mapping.empty() || mapping.front() == '#') continue;
		if (const auto start = mapping.find("platform:"); start != std::string::npos) {
			const auto valueStart = start + sizeof("platform:") - 1;
			const auto end = mapping.find(',', valueStart);
			const std::string_view platform(mapping.data() + valueStart,
				(end == std::string::npos ? mapping.size() : end) - valueStart);
			if (platform != SDL_GetPlatform()) {
				success = true;
				continue;
			}
			mapping.erase(start, (end == std::string::npos ? mapping.size() : end + 1) - start);
		}
		if (SDL_GameControllerAddMapping(mapping.c_str()) >= 0) {
			success = true;
			const auto comma = mapping.find(',');
			if (comma == 32) _recentGamepadGuids.insert(mapping.substr(0, comma));
		}
	}
	if (!success && !mappings.empty()) {
		error = "Invalid gamepad mappings";
		return false;
	}
	error.clear();
	return true;
}

std::string Controller::saveGamepadMappings() const {
	std::string output;
	for (const auto& guid : _recentGamepadGuids) {
		const SDL_JoystickGUID sdlGuid = SDL_JoystickGetGUIDFromString(guid.c_str());
		char* raw = SDL_GameControllerMappingForGUID(sdlGuid);
		if (!raw) continue;
		std::string mapping(raw);
		SDL_free(raw);
		if (mapping.empty() || mapping.back() != ',') mapping += ',';
		if (mapping.find("platform:") == std::string::npos)
			mapping += "platform:" + std::string(SDL_GetPlatform()) + ',';
		output += mapping + '\n';
	}
	return output;
}

std::string Controller::getGamepadMappingString(std::string_view guid) const {
	if (guid.size() != 32) return {};
	const SDL_JoystickGUID sdlGuid = SDL_JoystickGetGUIDFromString(std::string(guid).c_str());
	char* raw = SDL_GameControllerMappingForGUID(sdlGuid);
	if (!raw) return {};
	std::string mapping(raw);
	SDL_free(raw);
	if (mapping.empty() || mapping.back() != ',') mapping += ',';
	if (mapping.find("platform:") == std::string::npos)
		mapping += "platform:" + std::string(SDL_GetPlatform());
	return mapping;
}

std::optional<Controller::GamepadMapping> Controller::getControllerGamepadMapping(
	int controllerId, std::string_view gamepadInput) const {
	for (const auto& [deviceId, device] : _deviceMap) {
		(void)deviceId;
		if (device->id != controllerId) continue;
		auto controller = s_cast<SDL_GameController*>(device->controller);
		SDL_GameControllerButtonBind bind{};
		if (const auto axis = gamepadAxisFromLove(gamepadInput); axis != SDL_CONTROLLER_AXIS_INVALID)
			bind = SDL_GameControllerGetBindForAxis(controller, axis);
		else if (const auto button = gamepadButtonFromLove(gamepadInput); button != SDL_CONTROLLER_BUTTON_INVALID)
			bind = SDL_GameControllerGetBindForButton(controller, button);
		else
			return std::nullopt;
		GamepadMapping result;
		switch (bind.bindType) {
			case SDL_CONTROLLER_BINDTYPE_AXIS:
				result.inputType = "axis";
				result.index = bind.value.axis;
				break;
			case SDL_CONTROLLER_BINDTYPE_BUTTON:
				result.inputType = "button";
				result.index = bind.value.button;
				break;
			case SDL_CONTROLLER_BINDTYPE_HAT:
				result.inputType = "hat";
				result.index = bind.value.hat.hat;
				result.hat = loveHatFromMask(bind.value.hat.hat_mask);
				break;
			default: return std::nullopt;
		}
		return result;
	}
	return std::nullopt;
}

std::string Controller::getControllerGamepadMappingString(int controllerId) const {
	for (const auto& [deviceId, device] : _deviceMap) {
		(void)deviceId;
		if (device->id != controllerId) continue;
		char* raw = SDL_GameControllerMapping(s_cast<SDL_GameController*>(device->controller));
		if (!raw) return {};
		std::string mapping(raw);
		SDL_free(raw);
		if (mapping.empty() || mapping.back() != ',') mapping += ',';
		if (mapping.find("platform:") == std::string::npos)
			mapping += "platform:" + std::string(SDL_GetPlatform());
		return mapping;
	}
	return {};
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
		const std::string controllerName = SDL_GameControllerName(controller) ? SDL_GameControllerName(controller) : "Dora Controller";
		char controllerGuidBuffer[33] = {};
		SDL_JoystickGetGUIDString(SDL_JoystickGetGUID(SDL_GameControllerGetJoystick(controller)),
			controllerGuidBuffer, sizeof(controllerGuidBuffer));
		const std::string controllerGuid = controllerGuidBuffer;
#if DORA_DEV_VIRTUAL_CONTROLLER
		if (deviceIndex == _devVirtualDeviceIndex) {
			_devVirtualController = controller;
			_devVirtualJoystick = SDL_GameControllerGetJoystick(controller);
		}
#endif // DORA_DEV_VIRTUAL_CONTROLLER
		SharedApplication.invokeInLogic([controller, joystickId, controllerName, controllerGuid, this]() {
			if (_deviceMap.contains(joystickId)) return;
			int deviceId = -1;
			if (!_availableDeviceIds.empty()) {
				deviceId = _availableDeviceIds.top();
				_availableDeviceIds.pop();
			} else {
				deviceId = s_cast<int>(_deviceMap.size());
			}
			_deviceMap[joystickId] = New<Device>(deviceId, controller, controllerName);
			_recentGamepadGuids.insert(controllerGuid);
			EventArgs<int, Slice> added("ControllerAdded"_slice, deviceId, controllerName);
			handler(&added);
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
						EventArgs<int> removed("ControllerRemoved"_slice, it->second->id);
						handler(&removed);
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
		case SDL_JOYAXISMOTION: {
			auto joystickId = s_cast<DeviceID>(event.jaxis.which);
			const int axisIndex = event.jaxis.axis;
			const float value = event.jaxis.value < 0
				? s_cast<float>(event.jaxis.value) / 32768.0f
				: s_cast<float>(event.jaxis.value) / 32767.0f;
			if (!emitEvents) break;
			SharedApplication.invokeInLogic([joystickId, axisIndex, value, this]() {
				if (auto it = _deviceMap.find(joystickId); it != _deviceMap.end()) {
					EventArgs<int, int, float> axis(
						"JoystickAxis"_slice, it->second->id, axisIndex, value);
					handler(&axis);
				}
			});
			break;
		}
		case SDL_JOYBUTTONDOWN:
		case SDL_JOYBUTTONUP: {
			auto joystickId = s_cast<DeviceID>(event.jbutton.which);
			const int buttonIndex = event.jbutton.button;
			const bool isDown = event.jbutton.state == SDL_PRESSED;
			if (!emitEvents) break;
			SharedApplication.invokeInLogic([joystickId, buttonIndex, isDown, this]() {
				if (auto it = _deviceMap.find(joystickId); it != _deviceMap.end()) {
					EventArgs<int, int> button(isDown
						? "JoystickButtonDown"_slice : "JoystickButtonUp"_slice,
						it->second->id, buttonIndex);
					handler(&button);
				}
			});
			break;
		}
		case SDL_JOYHATMOTION: {
			auto joystickId = s_cast<DeviceID>(event.jhat.which);
			const int hatIndex = event.jhat.hat;
			const int value = event.jhat.value;
			if (!emitEvents) break;
			SharedApplication.invokeInLogic([joystickId, hatIndex, value, this]() {
				if (auto it = _deviceMap.find(joystickId); it != _deviceMap.end()) {
					EventArgs<int, int, int> hat(
						"JoystickHat"_slice, it->second->id, hatIndex, value);
					handler(&hat);
				}
			});
			break;
		}
		default:
			break;
	}
}

NS_DORA_END
