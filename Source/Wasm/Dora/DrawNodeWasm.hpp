static int32_t drawnode_type()
{
	return DoraType<DrawNode>();
}
static void drawnode_set_depth_write(int64_t self, int32_t var)
{
	r_cast<DrawNode*>(self)->setDepthWrite(var != 0);
}
static int32_t drawnode_is_depth_write(int64_t self)
{
	return r_cast<DrawNode*>(self)->isDepthWrite() ? 1 : 0;
}
static void drawnode_set_blend_func(int64_t self, int64_t var)
{
	r_cast<DrawNode*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(var)));
}
static int64_t drawnode_get_blend_func(int64_t self)
{
	return s_cast<int64_t>(r_cast<DrawNode*>(self)->getBlendFunc().toValue());
}
static void drawnode_draw_dot(int64_t self, int64_t pos, float radius, int32_t color)
{
	r_cast<DrawNode*>(self)->drawDot(vec2_from(pos), radius, Color(s_cast<uint32_t>(color)));
}
static void drawnode_draw_segment(int64_t self, int64_t from, int64_t to, float radius, int32_t color)
{
	r_cast<DrawNode*>(self)->drawSegment(vec2_from(from), vec2_from(to), radius, Color(s_cast<uint32_t>(color)));
}
static void drawnode_draw_polygon(int64_t self, int64_t verts, int32_t fill_color, float border_width, int32_t border_color)
{
	r_cast<DrawNode*>(self)->drawPolygon(from_vec2_vec(verts), Color(s_cast<uint32_t>(fill_color)), border_width, Color(s_cast<uint32_t>(border_color)));
}
static void drawnode_draw_vertices(int64_t self, int64_t verts)
{
	r_cast<DrawNode*>(self)->drawVertices(from_vertex_color_vec(verts));
}
static void drawnode_clear(int64_t self)
{
	r_cast<DrawNode*>(self)->clear();
}
static int64_t drawnode_new()
{
	return from_object(DrawNode::create());
}
static void linkDrawNode(wasm3::module& mod)
{
	mod.link_optional("*", "drawnode_type", drawnode_type);
	mod.link_optional("*", "drawnode_set_depth_write", drawnode_set_depth_write);
	mod.link_optional("*", "drawnode_is_depth_write", drawnode_is_depth_write);
	mod.link_optional("*", "drawnode_set_blend_func", drawnode_set_blend_func);
	mod.link_optional("*", "drawnode_get_blend_func", drawnode_get_blend_func);
	mod.link_optional("*", "drawnode_draw_dot", drawnode_draw_dot);
	mod.link_optional("*", "drawnode_draw_segment", drawnode_draw_segment);
	mod.link_optional("*", "drawnode_draw_polygon", drawnode_draw_polygon);
	mod.link_optional("*", "drawnode_draw_vertices", drawnode_draw_vertices);
	mod.link_optional("*", "drawnode_clear", drawnode_clear);
	mod.link_optional("*", "drawnode_new", drawnode_new);
}