/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t motorjoint_type() {
	return DoraType<MotorJoint>();
}
void motorjoint_set_enabled(int64_t self, int32_t val) {
	r_cast<MotorJoint*>(self)->setEnabled(val != 0);
}
int32_t motorjoint_is_enabled(int64_t self) {
	return r_cast<MotorJoint*>(self)->isEnabled() ? 1 : 0;
}
void motorjoint_set_force(int64_t self, float val) {
	r_cast<MotorJoint*>(self)->setForce(val);
}
float motorjoint_get_force(int64_t self) {
	return r_cast<MotorJoint*>(self)->getForce();
}
void motorjoint_set_speed(int64_t self, float val) {
	r_cast<MotorJoint*>(self)->setSpeed(val);
}
float motorjoint_get_speed(int64_t self) {
	return r_cast<MotorJoint*>(self)->getSpeed();
}
} // extern "C"

static void linkMotorJoint(wasm3::module3& mod) {
	mod.link_optional("*", "motorjoint_type", motorjoint_type);
	mod.link_optional("*", "motorjoint_set_enabled", motorjoint_set_enabled);
	mod.link_optional("*", "motorjoint_is_enabled", motorjoint_is_enabled);
	mod.link_optional("*", "motorjoint_set_force", motorjoint_set_force);
	mod.link_optional("*", "motorjoint_get_force", motorjoint_get_force);
	mod.link_optional("*", "motorjoint_set_speed", motorjoint_set_speed);
	mod.link_optional("*", "motorjoint_get_speed", motorjoint_get_speed);
}