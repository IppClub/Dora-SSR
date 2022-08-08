static int32_t sprite_type()
{
	return DoraType<Sprite>();
}
static void sprite_set_depth_write(int64_t self, int32_t var)
{
	r_cast<Sprite*>(self)->setDepthWrite(var != 0);
}
static int32_t sprite_is_depth_write(int64_t self)
{
	return r_cast<Sprite*>(self)->isDepthWrite() ? 1 : 0;
}
static void sprite_set_alpha_ref(int64_t self, float var)
{
	r_cast<Sprite*>(self)->setAlphaRef(var);
}
static float sprite_get_alpha_ref(int64_t self)
{
	return r_cast<Sprite*>(self)->getAlphaRef();
}
static void sprite_set_texture_rect(int64_t self, int64_t var)
{
	r_cast<Sprite*>(self)->setTextureRect(*r_cast<Rect*>(var));
}
static int64_t sprite_get_texture_rect(int64_t self)
{
	return r_cast<int64_t>(new Rect{r_cast<Sprite*>(self)->getTextureRect()});
}
static int64_t sprite_get_texture(int64_t self)
{
	return from_object(r_cast<Sprite*>(self)->getTexture());
}
static void sprite_set_blend_func(int64_t self, int64_t var)
{
	r_cast<Sprite*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(var)));
}
static int64_t sprite_get_blend_func(int64_t self)
{
	return s_cast<int64_t>(r_cast<Sprite*>(self)->getBlendFunc().toValue());
}
static void sprite_set_effect(int64_t self, int64_t var)
{
	r_cast<Sprite*>(self)->setEffect(r_cast<SpriteEffect*>(var));
}
static int64_t sprite_get_effect(int64_t self)
{
	return from_object(r_cast<Sprite*>(self)->getEffect());
}
static void sprite_set_uwrap(int64_t self, int32_t var)
{
	r_cast<Sprite*>(self)->setUWrap(s_cast<TextureWrap>(var));
}
static int32_t sprite_get_uwrap(int64_t self)
{
	return s_cast<int32_t>(r_cast<Sprite*>(self)->getUWrap());
}
static void sprite_set_vwrap(int64_t self, int32_t var)
{
	r_cast<Sprite*>(self)->setVWrap(s_cast<TextureWrap>(var));
}
static int32_t sprite_get_vwrap(int64_t self)
{
	return s_cast<int32_t>(r_cast<Sprite*>(self)->getVWrap());
}
static void sprite_set_filter(int64_t self, int32_t var)
{
	r_cast<Sprite*>(self)->setFilter(s_cast<TextureFilter>(var));
}
static int32_t sprite_get_filter(int64_t self)
{
	return s_cast<int32_t>(r_cast<Sprite*>(self)->getFilter());
}
static int64_t sprite_new()
{
	return from_object(Sprite::create());
}
static int64_t sprite_with_texture_rect(int64_t texture, int64_t texture_rect)
{
	return from_object(Sprite::create(r_cast<Texture2D*>(texture), *r_cast<Rect*>(texture_rect)));
}
static int64_t sprite_with_texture(int64_t texture)
{
	return from_object(Sprite::create(r_cast<Texture2D*>(texture)));
}
static int64_t sprite_with_file(int64_t clip_str)
{
	return from_object(sprite_create(*str_from(clip_str)));
}
static void linkSprite(wasm3::module& mod)
{
	mod.link_optional("*", "sprite_type", sprite_type);
	mod.link_optional("*", "sprite_set_depth_write", sprite_set_depth_write);
	mod.link_optional("*", "sprite_is_depth_write", sprite_is_depth_write);
	mod.link_optional("*", "sprite_set_alpha_ref", sprite_set_alpha_ref);
	mod.link_optional("*", "sprite_get_alpha_ref", sprite_get_alpha_ref);
	mod.link_optional("*", "sprite_set_texture_rect", sprite_set_texture_rect);
	mod.link_optional("*", "sprite_get_texture_rect", sprite_get_texture_rect);
	mod.link_optional("*", "sprite_get_texture", sprite_get_texture);
	mod.link_optional("*", "sprite_set_blend_func", sprite_set_blend_func);
	mod.link_optional("*", "sprite_get_blend_func", sprite_get_blend_func);
	mod.link_optional("*", "sprite_set_effect", sprite_set_effect);
	mod.link_optional("*", "sprite_get_effect", sprite_get_effect);
	mod.link_optional("*", "sprite_set_uwrap", sprite_set_uwrap);
	mod.link_optional("*", "sprite_get_uwrap", sprite_get_uwrap);
	mod.link_optional("*", "sprite_set_vwrap", sprite_set_vwrap);
	mod.link_optional("*", "sprite_get_vwrap", sprite_get_vwrap);
	mod.link_optional("*", "sprite_set_filter", sprite_set_filter);
	mod.link_optional("*", "sprite_get_filter", sprite_get_filter);
	mod.link_optional("*", "sprite_new", sprite_new);
	mod.link_optional("*", "sprite_with_texture_rect", sprite_with_texture_rect);
	mod.link_optional("*", "sprite_with_texture", sprite_with_texture);
	mod.link_optional("*", "sprite_with_file", sprite_with_file);
}