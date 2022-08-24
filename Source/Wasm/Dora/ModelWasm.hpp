static int32_t model_type() {
	return DoraType<Model>();
}
static float model_get_duration(int64_t self) {
	return r_cast<Model*>(self)->getDuration();
}
static void model_set_reversed(int64_t self, int32_t var) {
	r_cast<Model*>(self)->setReversed(var != 0);
}
static int32_t model_is_reversed(int64_t self) {
	return r_cast<Model*>(self)->isReversed() ? 1 : 0;
}
static int32_t model_is_playing(int64_t self) {
	return r_cast<Model*>(self)->isPlaying() ? 1 : 0;
}
static int32_t model_is_paused(int64_t self) {
	return r_cast<Model*>(self)->isPaused() ? 1 : 0;
}
static int32_t model_has_animation(int64_t self, int64_t name) {
	return r_cast<Model*>(self)->hasAnimation(*str_from(name)) ? 1 : 0;
}
static void model_pause(int64_t self) {
	r_cast<Model*>(self)->pause();
}
static void model_resume(int64_t self) {
	r_cast<Model*>(self)->resume();
}
static void model_resume_animation(int64_t self, int64_t name, int32_t looping) {
	r_cast<Model*>(self)->resume(*str_from(name), looping != 0);
}
static void model_reset(int64_t self) {
	r_cast<Model*>(self)->reset();
}
static void model_update_to(int64_t self, float eclapsed, int32_t reversed) {
	r_cast<Model*>(self)->updateTo(eclapsed, reversed != 0);
}
static int64_t model_get_node_by_name(int64_t self, int64_t name) {
	return from_object(r_cast<Model*>(self)->getNodeByName(*str_from(name)));
}
static int32_t model_each_node(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return r_cast<Model*>(self)->eachNode([func, args, deref](Node* node) {
		args->clear();
		args->push(node);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}) ? 1 : 0;
}
static int64_t model_new(int64_t filename) {
	return from_object(Model::create(*str_from(filename)));
}
static int64_t model_get_clip_file(int64_t filename) {
	return str_retain(model_get_clip_filename(*str_from(filename)));
}
static int64_t model_get_looks(int64_t filename) {
	return to_vec(model_get_look_names(*str_from(filename)));
}
static int64_t model_get_animations(int64_t filename) {
	return to_vec(model_get_animation_names(*str_from(filename)));
}
static void linkModel(wasm3::module& mod) {
	mod.link_optional("*", "model_type", model_type);
	mod.link_optional("*", "model_get_duration", model_get_duration);
	mod.link_optional("*", "model_set_reversed", model_set_reversed);
	mod.link_optional("*", "model_is_reversed", model_is_reversed);
	mod.link_optional("*", "model_is_playing", model_is_playing);
	mod.link_optional("*", "model_is_paused", model_is_paused);
	mod.link_optional("*", "model_has_animation", model_has_animation);
	mod.link_optional("*", "model_pause", model_pause);
	mod.link_optional("*", "model_resume", model_resume);
	mod.link_optional("*", "model_resume_animation", model_resume_animation);
	mod.link_optional("*", "model_reset", model_reset);
	mod.link_optional("*", "model_update_to", model_update_to);
	mod.link_optional("*", "model_get_node_by_name", model_get_node_by_name);
	mod.link_optional("*", "model_each_node", model_each_node);
	mod.link_optional("*", "model_new", model_new);
	mod.link_optional("*", "model_get_clip_file", model_get_clip_file);
	mod.link_optional("*", "model_get_looks", model_get_looks);
	mod.link_optional("*", "model_get_animations", model_get_animations);
}