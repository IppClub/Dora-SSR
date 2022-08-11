static int32_t cache_load(int64_t filename)
{
	return Cache::load(*str_from(filename)) ? 1 : 0;
}
static void cache_load_async(int64_t filename, int32_t func)
{
	std::shared_ptr<void> deref(nullptr, [func](auto)
	{
		SharedWasmRuntime.deref(func);
	});
	Cache::loadAsync(*str_from(filename), [func, deref]()
	{
		SharedWasmRuntime.invoke(func);
	});
}
static void cache_update_item(int64_t filename, int64_t content)
{
	Cache::update(*str_from(filename), *str_from(content));
}
static void cache_update_texture(int64_t filename, int64_t texture)
{
	Cache::update(*str_from(filename), r_cast<Texture2D*>(texture));
}
static void cache_unload()
{
	Cache::unload();
}
static int32_t cache_unload_item_or_type(int64_t name)
{
	return Cache::unload(*str_from(name)) ? 1 : 0;
}
static void cache_remove_unused()
{
	Cache::removeUnused();
}
static void cache_remove_unused_by_type(int64_t type_name)
{
	Cache::removeUnused(*str_from(type_name));
}
static void linkCache(wasm3::module& mod)
{
	mod.link_optional("*", "cache_load", cache_load);
	mod.link_optional("*", "cache_load_async", cache_load_async);
	mod.link_optional("*", "cache_update_item", cache_update_item);
	mod.link_optional("*", "cache_update_texture", cache_update_texture);
	mod.link_optional("*", "cache_unload", cache_unload);
	mod.link_optional("*", "cache_unload_item_or_type", cache_unload_item_or_type);
	mod.link_optional("*", "cache_remove_unused", cache_remove_unused);
	mod.link_optional("*", "cache_remove_unused_by_type", cache_remove_unused_by_type);
}