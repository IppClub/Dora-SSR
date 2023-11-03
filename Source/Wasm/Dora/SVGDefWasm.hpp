static int32_t svg_type() {
	return DoraType<SVGDef>();
}
static float svgdef_get_width(int64_t self) {
	return r_cast<SVGDef*>(self)->getWidth();
}
static float svgdef_get_height(int64_t self) {
	return r_cast<SVGDef*>(self)->getHeight();
}
static void svgdef_render(int64_t self) {
	r_cast<SVGDef*>(self)->render();
}
static int64_t svgdef_new(int64_t filename) {
	return from_object(SVGDef::from(*str_from(filename)));
}
static void linkSVGDef(wasm3::module3& mod) {
	mod.link_optional("*", "svg_type", svg_type);
	mod.link_optional("*", "svgdef_get_width", svgdef_get_width);
	mod.link_optional("*", "svgdef_get_height", svgdef_get_height);
	mod.link_optional("*", "svgdef_render", svgdef_render);
	mod.link_optional("*", "svgdef_new", svgdef_new);
}