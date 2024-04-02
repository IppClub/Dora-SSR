/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t keyboard__is_key_down(int64_t name) {
	return SharedKeyboard.isKeyDown(*str_from(name)) ? 1 : 0;
}
static int32_t keyboard__is_key_up(int64_t name) {
	return SharedKeyboard.isKeyUp(*str_from(name)) ? 1 : 0;
}
static int32_t keyboard__is_key_pressed(int64_t name) {
	return SharedKeyboard.isKeyPressed(*str_from(name)) ? 1 : 0;
}
static void keyboard_update_ime_pos_hint(int64_t win_pos) {
	SharedKeyboard.updateIMEPosHint(vec2_from(win_pos));
}
static void linkKeyboard(wasm3::module3& mod) {
	mod.link_optional("*", "keyboard__is_key_down", keyboard__is_key_down);
	mod.link_optional("*", "keyboard__is_key_up", keyboard__is_key_up);
	mod.link_optional("*", "keyboard__is_key_pressed", keyboard__is_key_pressed);
	mod.link_optional("*", "keyboard_update_ime_pos_hint", keyboard_update_ime_pos_hint);
}