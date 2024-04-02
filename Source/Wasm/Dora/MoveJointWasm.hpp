/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t movejoint_type() {
	return DoraType<MoveJoint>();
}
static void movejoint_set_position(int64_t self, int64_t var) {
	r_cast<MoveJoint*>(self)->setPosition(vec2_from(var));
}
static int64_t movejoint_get_position(int64_t self) {
	return vec2_retain(r_cast<MoveJoint*>(self)->getPosition());
}
static void linkMoveJoint(wasm3::module3& mod) {
	mod.link_optional("*", "movejoint_type", movejoint_type);
	mod.link_optional("*", "movejoint_set_position", movejoint_set_position);
	mod.link_optional("*", "movejoint_get_position", movejoint_get_position);
}