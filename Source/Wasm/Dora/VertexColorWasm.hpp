static void vertexcolor_release(int64_t raw) {
	delete r_cast<VertexColor*>(raw);
}
static void vertexcolor_set_vertex(int64_t self, int64_t var) {
	r_cast<VertexColor*>(self)->vertex = vec2_from(var);
}
static int64_t vertexcolor_get_vertex(int64_t self) {
	return vec2_retain(r_cast<VertexColor*>(self)->vertex);
}
static void vertexcolor_set_color(int64_t self, int32_t var) {
	r_cast<VertexColor*>(self)->color = Color(s_cast<uint32_t>(var));
}
static int32_t vertexcolor_get_color(int64_t self) {
	return r_cast<VertexColor*>(self)->color.toARGB();
}
static int64_t vertexcolor_new(int64_t vec, int32_t color) {
	return r_cast<int64_t>(new VertexColor{vec2_from(vec), Color(s_cast<uint32_t>(color))});
}
static void linkVertexColor(wasm3::module3& mod) {
	mod.link_optional("*", "vertexcolor_release", vertexcolor_release);
	mod.link_optional("*", "vertexcolor_set_vertex", vertexcolor_set_vertex);
	mod.link_optional("*", "vertexcolor_get_vertex", vertexcolor_get_vertex);
	mod.link_optional("*", "vertexcolor_set_color", vertexcolor_set_color);
	mod.link_optional("*", "vertexcolor_get_color", vertexcolor_get_color);
	mod.link_optional("*", "vertexcolor_new", vertexcolor_new);
}