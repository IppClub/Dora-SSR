static void rect_release(int64_t raw) {
	delete r_cast<Rect*>(raw);
}
static void rect_set_origin(int64_t self, int64_t var) {
	r_cast<Rect*>(self)->origin = vec2_from(var);
}
static int64_t rect_get_origin(int64_t self) {
	return vec2_retain(r_cast<Rect*>(self)->origin);
}
static void rect_set_size(int64_t self, int64_t var) {
	r_cast<Rect*>(self)->size = size_from(var);
}
static int64_t rect_get_size(int64_t self) {
	return size_retain(r_cast<Rect*>(self)->size);
}
static void rect_set_x(int64_t self, float var) {
	r_cast<Rect*>(self)->setX(var);
}
static float rect_get_x(int64_t self) {
	return r_cast<Rect*>(self)->getX();
}
static void rect_set_y(int64_t self, float var) {
	r_cast<Rect*>(self)->setY(var);
}
static float rect_get_y(int64_t self) {
	return r_cast<Rect*>(self)->getY();
}
static void rect_set_width(int64_t self, float var) {
	r_cast<Rect*>(self)->setWidth(var);
}
static float rect_get_width(int64_t self) {
	return r_cast<Rect*>(self)->getWidth();
}
static void rect_set_height(int64_t self, float var) {
	r_cast<Rect*>(self)->setHeight(var);
}
static float rect_get_height(int64_t self) {
	return r_cast<Rect*>(self)->getHeight();
}
static void rect_set_left(int64_t self, float var) {
	r_cast<Rect*>(self)->setLeft(var);
}
static float rect_get_left(int64_t self) {
	return r_cast<Rect*>(self)->getLeft();
}
static void rect_set_right(int64_t self, float var) {
	r_cast<Rect*>(self)->setRight(var);
}
static float rect_get_right(int64_t self) {
	return r_cast<Rect*>(self)->getRight();
}
static void rect_set_center_x(int64_t self, float var) {
	r_cast<Rect*>(self)->setCenterX(var);
}
static float rect_get_center_x(int64_t self) {
	return r_cast<Rect*>(self)->getCenterX();
}
static void rect_set_center_y(int64_t self, float var) {
	r_cast<Rect*>(self)->setCenterY(var);
}
static float rect_get_center_y(int64_t self) {
	return r_cast<Rect*>(self)->getCenterY();
}
static void rect_set_bottom(int64_t self, float var) {
	r_cast<Rect*>(self)->setBottom(var);
}
static float rect_get_bottom(int64_t self) {
	return r_cast<Rect*>(self)->getBottom();
}
static void rect_set_top(int64_t self, float var) {
	r_cast<Rect*>(self)->setTop(var);
}
static float rect_get_top(int64_t self) {
	return r_cast<Rect*>(self)->getTop();
}
static void rect_set_lower_bound(int64_t self, int64_t var) {
	r_cast<Rect*>(self)->setLowerBound(vec2_from(var));
}
static int64_t rect_get_lower_bound(int64_t self) {
	return vec2_retain(r_cast<Rect*>(self)->getLowerBound());
}
static void rect_set_upper_bound(int64_t self, int64_t var) {
	r_cast<Rect*>(self)->setUpperBound(vec2_from(var));
}
static int64_t rect_get_upper_bound(int64_t self) {
	return vec2_retain(r_cast<Rect*>(self)->getUpperBound());
}
static void rect_set(int64_t self, float x, float y, float width, float height) {
	r_cast<Rect*>(self)->set(x, y, width, height);
}
static int32_t rect_contains_point(int64_t self, int64_t point) {
	return r_cast<Rect*>(self)->containsPoint(vec2_from(point)) ? 1 : 0;
}
static int32_t rect_intersects_rect(int64_t self, int64_t rect) {
	return r_cast<Rect*>(self)->intersectsRect(*r_cast<Rect*>(rect)) ? 1 : 0;
}
static int32_t rect_equals(int64_t self, int64_t other) {
	return r_cast<Rect*>(self)->operator==(*r_cast<Rect*>(other)) ? 1 : 0;
}
static int64_t rect_new(int64_t origin, int64_t size) {
	return r_cast<int64_t>(new Rect{vec2_from(origin), size_from(size)});
}
static int64_t rect_zero() {
	return r_cast<int64_t>(new Rect{rect_get_zero()});
}
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