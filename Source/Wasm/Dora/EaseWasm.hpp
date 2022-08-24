static float ease_func(int32_t easing, float time) {
	return Ease::func(s_cast<Ease::Enum>(easing), time);
}
static void linkEase(wasm3::module& mod) {
	mod.link_optional("*", "ease_func", ease_func);
}