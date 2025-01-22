/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
void rect_release(int64_t raw) {
	delete r_cast<Rect*>(raw);
}
void rect_set_origin(int64_t self, int64_t val) {
	r_cast<Rect*>(self)->origin = Vec2_From(val);
}
int64_t rect_get_origin(int64_t self) {
	return Vec2_Retain(r_cast<Rect*>(self)->origin);
}
void rect_set_size(int64_t self, int64_t val) {
	r_cast<Rect*>(self)->size = Size_From(val);
}
int64_t rect_get_size(int64_t self) {
	return Size_Retain(r_cast<Rect*>(self)->size);
}
void rect_set_x(int64_t self, float val) {
	r_cast<Rect*>(self)->setX(val);
}
float rect_get_x(int64_t self) {
	return r_cast<Rect*>(self)->getX();
}
void rect_set_y(int64_t self, float val) {
	r_cast<Rect*>(self)->setY(val);
}
float rect_get_y(int64_t self) {
	return r_cast<Rect*>(self)->getY();
}
void rect_set_width(int64_t self, float val) {
	r_cast<Rect*>(self)->setWidth(val);
}
float rect_get_width(int64_t self) {
	return r_cast<Rect*>(self)->getWidth();
}
void rect_set_height(int64_t self, float val) {
	r_cast<Rect*>(self)->setHeight(val);
}
float rect_get_height(int64_t self) {
	return r_cast<Rect*>(self)->getHeight();
}
void rect_set_left(int64_t self, float val) {
	r_cast<Rect*>(self)->setLeft(val);
}
float rect_get_left(int64_t self) {
	return r_cast<Rect*>(self)->getLeft();
}
void rect_set_right(int64_t self, float val) {
	r_cast<Rect*>(self)->setRight(val);
}
float rect_get_right(int64_t self) {
	return r_cast<Rect*>(self)->getRight();
}
void rect_set_center_x(int64_t self, float val) {
	r_cast<Rect*>(self)->setCenterX(val);
}
float rect_get_center_x(int64_t self) {
	return r_cast<Rect*>(self)->getCenterX();
}
void rect_set_center_y(int64_t self, float val) {
	r_cast<Rect*>(self)->setCenterY(val);
}
float rect_get_center_y(int64_t self) {
	return r_cast<Rect*>(self)->getCenterY();
}
void rect_set_bottom(int64_t self, float val) {
	r_cast<Rect*>(self)->setBottom(val);
}
float rect_get_bottom(int64_t self) {
	return r_cast<Rect*>(self)->getBottom();
}
void rect_set_top(int64_t self, float val) {
	r_cast<Rect*>(self)->setTop(val);
}
float rect_get_top(int64_t self) {
	return r_cast<Rect*>(self)->getTop();
}
void rect_set_lower_bound(int64_t self, int64_t val) {
	r_cast<Rect*>(self)->setLowerBound(Vec2_From(val));
}
int64_t rect_get_lower_bound(int64_t self) {
	return Vec2_Retain(r_cast<Rect*>(self)->getLowerBound());
}
void rect_set_upper_bound(int64_t self, int64_t val) {
	r_cast<Rect*>(self)->setUpperBound(Vec2_From(val));
}
int64_t rect_get_upper_bound(int64_t self) {
	return Vec2_Retain(r_cast<Rect*>(self)->getUpperBound());
}
void rect_set(int64_t self, float x, float y, float width, float height) {
	r_cast<Rect*>(self)->set(x, y, width, height);
}
int32_t rect_contains_point(int64_t self, int64_t point) {
	return r_cast<Rect*>(self)->containsPoint(Vec2_From(point)) ? 1 : 0;
}
int32_t rect_intersects_rect(int64_t self, int64_t rect) {
	return r_cast<Rect*>(self)->intersectsRect(*r_cast<Rect*>(rect)) ? 1 : 0;
}
int32_t rect_equals(int64_t self, int64_t other) {
	return r_cast<Rect*>(self)->operator==(*r_cast<Rect*>(other)) ? 1 : 0;
}
int64_t rect_new(int64_t origin, int64_t size) {
	return r_cast<int64_t>(new Rect{Vec2_From(origin), Size_From(size)});
}
int64_t rect_zero() {
	return r_cast<int64_t>(new Rect{Rect_GetZero()});
}
} // extern "C"

static void linkRect(wasm3::module3& mod) {
	mod.link_optional("*", "rect_release", rect_release);
	mod.link_optional("*", "rect_set_origin", rect_set_origin);
	mod.link_optional("*", "rect_get_origin", rect_get_origin);
	mod.link_optional("*", "rect_set_size", rect_set_size);
	mod.link_optional("*", "rect_get_size", rect_get_size);
	mod.link_optional("*", "rect_set_x", rect_set_x);
	mod.link_optional("*", "rect_get_x", rect_get_x);
	mod.link_optional("*", "rect_set_y", rect_set_y);
	mod.link_optional("*", "rect_get_y", rect_get_y);
	mod.link_optional("*", "rect_set_width", rect_set_width);
	mod.link_optional("*", "rect_get_width", rect_get_width);
	mod.link_optional("*", "rect_set_height", rect_set_height);
	mod.link_optional("*", "rect_get_height", rect_get_height);
	mod.link_optional("*", "rect_set_left", rect_set_left);
	mod.link_optional("*", "rect_get_left", rect_get_left);
	mod.link_optional("*", "rect_set_right", rect_set_right);
	mod.link_optional("*", "rect_get_right", rect_get_right);
	mod.link_optional("*", "rect_set_center_x", rect_set_center_x);
	mod.link_optional("*", "rect_get_center_x", rect_get_center_x);
	mod.link_optional("*", "rect_set_center_y", rect_set_center_y);
	mod.link_optional("*", "rect_get_center_y", rect_get_center_y);
	mod.link_optional("*", "rect_set_bottom", rect_set_bottom);
	mod.link_optional("*", "rect_get_bottom", rect_get_bottom);
	mod.link_optional("*", "rect_set_top", rect_set_top);
	mod.link_optional("*", "rect_get_top", rect_get_top);
	mod.link_optional("*", "rect_set_lower_bound", rect_set_lower_bound);
	mod.link_optional("*", "rect_get_lower_bound", rect_get_lower_bound);
	mod.link_optional("*", "rect_set_upper_bound", rect_set_upper_bound);
	mod.link_optional("*", "rect_get_upper_bound", rect_get_upper_bound);
	mod.link_optional("*", "rect_set", rect_set);
	mod.link_optional("*", "rect_contains_point", rect_contains_point);
	mod.link_optional("*", "rect_intersects_rect", rect_intersects_rect);
	mod.link_optional("*", "rect_equals", rect_equals);
	mod.link_optional("*", "rect_new", rect_new);
	mod.link_optional("*", "rect_zero", rect_zero);
}