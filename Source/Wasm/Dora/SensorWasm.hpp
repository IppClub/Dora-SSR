/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t sensor_type() {
	return DoraType<Sensor>();
}
void sensor_set_enabled(int64_t self, int32_t val) {
	r_cast<Sensor*>(self)->setEnabled(val != 0);
}
int32_t sensor_is_enabled(int64_t self) {
	return r_cast<Sensor*>(self)->isEnabled() ? 1 : 0;
}
int32_t sensor_get_tag(int64_t self) {
	return s_cast<int32_t>(r_cast<Sensor*>(self)->getTag());
}
int64_t sensor_get_owner(int64_t self) {
	return Object_From(r_cast<Sensor*>(self)->getOwner());
}
int32_t sensor_is_sensed(int64_t self) {
	return r_cast<Sensor*>(self)->isSensed() ? 1 : 0;
}
int64_t sensor_get_sensed_bodies(int64_t self) {
	return Object_From(r_cast<Sensor*>(self)->getSensedBodies());
}
int32_t sensor_contains(int64_t self, int64_t body) {
	return r_cast<Sensor*>(self)->contains(r_cast<Body*>(body)) ? 1 : 0;
}
} // extern "C"

static void linkSensor(wasm3::module3& mod) {
	mod.link_optional("*", "sensor_type", sensor_type);
	mod.link_optional("*", "sensor_set_enabled", sensor_set_enabled);
	mod.link_optional("*", "sensor_is_enabled", sensor_is_enabled);
	mod.link_optional("*", "sensor_get_tag", sensor_get_tag);
	mod.link_optional("*", "sensor_get_owner", sensor_get_owner);
	mod.link_optional("*", "sensor_is_sensed", sensor_is_sensed);
	mod.link_optional("*", "sensor_get_sensed_bodies", sensor_get_sensed_bodies);
	mod.link_optional("*", "sensor_contains", sensor_contains);
}