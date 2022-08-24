static int32_t grid_type() {
	return DoraType<Grid>();
}
static void grid_set_depth_write(int64_t self, int32_t var) {
	r_cast<Grid*>(self)->setDepthWrite(var != 0);
}
static int32_t grid_is_depth_write(int64_t self) {
	return r_cast<Grid*>(self)->isDepthWrite() ? 1 : 0;
}
static void grid_set_blend_func(int64_t self, int64_t var) {
	r_cast<Grid*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(var)));
}
static int64_t grid_get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<Grid*>(self)->getBlendFunc().toValue());
}
static void grid_set_effect(int64_t self, int64_t var) {
	r_cast<Grid*>(self)->setEffect(r_cast<SpriteEffect*>(var));
}
static int64_t grid_get_effect(int64_t self) {
	return from_object(r_cast<Grid*>(self)->getEffect());
}
static void grid_set_texture_rect(int64_t self, int64_t var) {
	r_cast<Grid*>(self)->setTextureRect(*r_cast<Rect*>(var));
}
static int64_t grid_get_texture_rect(int64_t self) {
	return r_cast<int64_t>(new Rect{r_cast<Grid*>(self)->getTextureRect()});
}
static void grid_set_texture(int64_t self, int64_t var) {
	r_cast<Grid*>(self)->setTexture(r_cast<Texture2D*>(var));
}
static int64_t grid_get_texture(int64_t self) {
	return from_object(r_cast<Grid*>(self)->getTexture());
}
static void grid_set_pos(int64_t self, int32_t x, int32_t y, int64_t pos, float z) {
	r_cast<Grid*>(self)->setPos(s_cast<int>(x), s_cast<int>(y), vec2_from(pos), z);
}
static int64_t grid_get_pos(int64_t self, int32_t x, int32_t y) {
	return vec2_retain(r_cast<Grid*>(self)->getPos(s_cast<int>(x), s_cast<int>(y)));
}
static void grid_set_color(int64_t self, int32_t x, int32_t y, int32_t color) {
	r_cast<Grid*>(self)->setColor(s_cast<int>(x), s_cast<int>(y), Color(s_cast<uint32_t>(color)));
}
static int32_t grid_get_color(int64_t self, int32_t x, int32_t y) {
	return r_cast<Grid*>(self)->getColor(s_cast<int>(x), s_cast<int>(y)).toARGB();
}
static void grid_move_uv(int64_t self, int32_t x, int32_t y, int64_t offset) {
	r_cast<Grid*>(self)->moveUV(s_cast<int>(x), s_cast<int>(y), vec2_from(offset));
}
static int64_t grid_new(float width, float height, int32_t grid_x, int32_t grid_y) {
	return from_object(Grid::create(width, height, s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
static int64_t grid_with_texture_rect(int64_t texture, int64_t texture_rect, int32_t grid_x, int32_t grid_y) {
	return from_object(Grid::create(r_cast<Texture2D*>(texture), *r_cast<Rect*>(texture_rect), s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
static int64_t grid_with_texture(int64_t texture, int32_t grid_x, int32_t grid_y) {
	return from_object(Grid::create(r_cast<Texture2D*>(texture), s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
static int64_t grid_with_file(int64_t clip_str, int32_t grid_x, int32_t grid_y) {
	return from_object(Grid::from(*str_from(clip_str), s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
static void linkGrid(wasm3::module& mod) {
	mod.link_optional("*", "grid_type", grid_type);
	mod.link_optional("*", "grid_set_depth_write", grid_set_depth_write);
	mod.link_optional("*", "grid_is_depth_write", grid_is_depth_write);
	mod.link_optional("*", "grid_set_blend_func", grid_set_blend_func);
	mod.link_optional("*", "grid_get_blend_func", grid_get_blend_func);
	mod.link_optional("*", "grid_set_effect", grid_set_effect);
	mod.link_optional("*", "grid_get_effect", grid_get_effect);
	mod.link_optional("*", "grid_set_texture_rect", grid_set_texture_rect);
	mod.link_optional("*", "grid_get_texture_rect", grid_get_texture_rect);
	mod.link_optional("*", "grid_set_texture", grid_set_texture);
	mod.link_optional("*", "grid_get_texture", grid_get_texture);
	mod.link_optional("*", "grid_set_pos", grid_set_pos);
	mod.link_optional("*", "grid_get_pos", grid_get_pos);
	mod.link_optional("*", "grid_set_color", grid_set_color);
	mod.link_optional("*", "grid_get_color", grid_get_color);
	mod.link_optional("*", "grid_move_uv", grid_move_uv);
	mod.link_optional("*", "grid_new", grid_new);
	mod.link_optional("*", "grid_with_texture_rect", grid_with_texture_rect);
	mod.link_optional("*", "grid_with_texture", grid_with_texture);
	mod.link_optional("*", "grid_with_file", grid_with_file);
}