static int32_t platformer_visual_type()
{
	return DoraType<Platformer::Visual>();
}
static int32_t platformer_visual_is_playing(int64_t self)
{
	return r_cast<Platformer::Visual*>(self)->isPlaying() ? 1 : 0;
}
static void platformer_visual_start(int64_t self)
{
	r_cast<Platformer::Visual*>(self)->start();
}
static void platformer_visual_stop(int64_t self)
{
	r_cast<Platformer::Visual*>(self)->stop();
}
static int64_t platformer_visual_auto_remove(int64_t self)
{
	return from_object(r_cast<Platformer::Visual*>(self)->autoRemove());
}
static int64_t platformer_visual_new(int64_t name)
{
	return from_object(Platformer::Visual::create(*str_from(name)));
}
static void linkPlatformerVisual(wasm3::module& mod)
{
	mod.link_optional("*", "platformer_visual_type", platformer_visual_type);
	mod.link_optional("*", "platformer_visual_is_playing", platformer_visual_is_playing);
	mod.link_optional("*", "platformer_visual_start", platformer_visual_start);
	mod.link_optional("*", "platformer_visual_stop", platformer_visual_stop);
	mod.link_optional("*", "platformer_visual_auto_remove", platformer_visual_auto_remove);
	mod.link_optional("*", "platformer_visual_new", platformer_visual_new);
}