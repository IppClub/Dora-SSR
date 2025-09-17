/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t controller__is_button_down(int32_t controller_id, int64_t name) {
	return SharedController.isButtonDown(s_cast<int>(controller_id), *Str_From(name)) ? 1 : 0;
}
DORA_EXPORT int32_t controller__is_button_up(int32_t controller_id, int64_t name) {
	return SharedController.isButtonUp(s_cast<int>(controller_id), *Str_From(name)) ? 1 : 0;
}
DORA_EXPORT int32_t controller__is_button_pressed(int32_t controller_id, int64_t name) {
	return SharedController.isButtonPressed(s_cast<int>(controller_id), *Str_From(name)) ? 1 : 0;
}
DORA_EXPORT float controller__get_axis(int32_t controller_id, int64_t name) {
	return SharedController.getAxis(s_cast<int>(controller_id), *Str_From(name));
}
} // extern "C"

static void linkController(wasm3::module3& mod) {
	mod.link_optional("*", "controller__is_button_down", controller__is_button_down);
	mod.link_optional("*", "controller__is_button_up", controller__is_button_up);
	mod.link_optional("*", "controller__is_button_pressed", controller__is_button_pressed);
	mod.link_optional("*", "controller__get_axis", controller__get_axis);
}