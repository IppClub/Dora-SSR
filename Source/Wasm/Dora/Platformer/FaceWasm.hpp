static int32_t platformer_face_type() {
	return DoraType<Platformer::Face>();
}
static void platformer_face_add_child(int64_t self, int64_t face) {
	r_cast<Platformer::Face*>(self)->addChild(r_cast<Platformer::Face*>(face));
}
static int64_t platformer_face_to_node(int64_t self) {
	return from_object(r_cast<Platformer::Face*>(self)->toNode());
}
static int64_t platformer_face_new(int64_t face_str, int64_t point, float scale, float angle) {
	return from_object(Platformer::Face::create(*str_from(face_str), vec2_from(point), scale, angle));
}
static int64_t platformer_face_with_func(int32_t func, int64_t stack, int64_t point, float scale, float angle) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return from_object(Platformer::Face::create([func, args, deref]() {
		args->clear();
		SharedWasmRuntime.invoke(func);
		return s_cast<Node*>(std::get<Object*>(args->pop()));
	}, vec2_from(point), scale, angle));
}
static void linkPlatformerFace(wasm3::module& mod) {
	mod.link_optional("*", "platformer_face_type", platformer_face_type);
	mod.link_optional("*", "platformer_face_add_child", platformer_face_add_child);
	mod.link_optional("*", "platformer_face_to_node", platformer_face_to_node);
	mod.link_optional("*", "platformer_face_new", platformer_face_new);
	mod.link_optional("*", "platformer_face_with_func", platformer_face_with_func);
}