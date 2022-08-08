static int32_t label_type()
{
	return DoraType<Label>();
}
static void label_set_alignment(int64_t self, int32_t var)
{
	r_cast<Label*>(self)->setAlignment(s_cast<TextAlign>(var));
}
static int32_t label_get_alignment(int64_t self)
{
	return s_cast<int32_t>(r_cast<Label*>(self)->getAlignment());
}
static void label_set_alpha_ref(int64_t self, float var)
{
	r_cast<Label*>(self)->setAlphaRef(var);
}
static float label_get_alpha_ref(int64_t self)
{
	return r_cast<Label*>(self)->getAlphaRef();
}
static void label_set_text_width(int64_t self, float var)
{
	r_cast<Label*>(self)->setTextWidth(var);
}
static float label_get_text_width(int64_t self)
{
	return r_cast<Label*>(self)->getTextWidth();
}
static void label_set_spacing(int64_t self, float var)
{
	r_cast<Label*>(self)->setSpacing(var);
}
static float label_get_spacing(int64_t self)
{
	return r_cast<Label*>(self)->getSpacing();
}
static void label_set_line_gap(int64_t self, float var)
{
	r_cast<Label*>(self)->setLineGap(var);
}
static float label_get_line_gap(int64_t self)
{
	return r_cast<Label*>(self)->getLineGap();
}
static void label_set_text(int64_t self, int64_t var)
{
	r_cast<Label*>(self)->setText(*str_from(var));
}
static int64_t label_get_text(int64_t self)
{
	return str_retain(r_cast<Label*>(self)->getText());
}
static void label_set_blend_func(int64_t self, int64_t var)
{
	r_cast<Label*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(var)));
}
static int64_t label_get_blend_func(int64_t self)
{
	return s_cast<int64_t>(r_cast<Label*>(self)->getBlendFunc().toValue());
}
static void label_set_depth_write(int64_t self, int32_t var)
{
	r_cast<Label*>(self)->setDepthWrite(var != 0);
}
static int32_t label_is_depth_write(int64_t self)
{
	return r_cast<Label*>(self)->isDepthWrite() ? 1 : 0;
}
static void label_set_batched(int64_t self, int32_t var)
{
	r_cast<Label*>(self)->setBatched(var != 0);
}
static int32_t label_is_batched(int64_t self)
{
	return r_cast<Label*>(self)->isBatched() ? 1 : 0;
}
static void label_set_effect(int64_t self, int64_t var)
{
	r_cast<Label*>(self)->setEffect(r_cast<SpriteEffect*>(var));
}
static int64_t label_get_effect(int64_t self)
{
	return from_object(r_cast<Label*>(self)->getEffect());
}
static int32_t label_get_character_count(int64_t self)
{
	return s_cast<int32_t>(r_cast<Label*>(self)->getCharacterCount());
}
static int64_t label_get_character(int64_t self, int32_t index)
{
	return from_object(r_cast<Label*>(self)->getCharacter(s_cast<int>(index)));
}
static float label_get_automatic_width(int64_t self)
{
	return Label::AutomaticWidth;
}
static int64_t label_new(int64_t font_name, int32_t font_size)
{
	return from_object(Label::create(*str_from(font_name), s_cast<uint32_t>(font_size)));
}
static void linkLabel(wasm3::module& mod)
{
	mod.link_optional("*", "label_type", label_type);
	mod.link_optional("*", "label_set_alignment", label_set_alignment);
	mod.link_optional("*", "label_get_alignment", label_get_alignment);
	mod.link_optional("*", "label_set_alpha_ref", label_set_alpha_ref);
	mod.link_optional("*", "label_get_alpha_ref", label_get_alpha_ref);
	mod.link_optional("*", "label_set_text_width", label_set_text_width);
	mod.link_optional("*", "label_get_text_width", label_get_text_width);
	mod.link_optional("*", "label_set_spacing", label_set_spacing);
	mod.link_optional("*", "label_get_spacing", label_get_spacing);
	mod.link_optional("*", "label_set_line_gap", label_set_line_gap);
	mod.link_optional("*", "label_get_line_gap", label_get_line_gap);
	mod.link_optional("*", "label_set_text", label_set_text);
	mod.link_optional("*", "label_get_text", label_get_text);
	mod.link_optional("*", "label_set_blend_func", label_set_blend_func);
	mod.link_optional("*", "label_get_blend_func", label_get_blend_func);
	mod.link_optional("*", "label_set_depth_write", label_set_depth_write);
	mod.link_optional("*", "label_is_depth_write", label_is_depth_write);
	mod.link_optional("*", "label_set_batched", label_set_batched);
	mod.link_optional("*", "label_is_batched", label_is_batched);
	mod.link_optional("*", "label_set_effect", label_set_effect);
	mod.link_optional("*", "label_get_effect", label_get_effect);
	mod.link_optional("*", "label_get_character_count", label_get_character_count);
	mod.link_optional("*", "label_get_character", label_get_character);
	mod.link_optional("*", "label_get_automatic_width", label_get_automatic_width);
	mod.link_optional("*", "label_new", label_new);
}