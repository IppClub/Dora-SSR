static void content_set_search_paths(int64_t var)
{
	SharedContent.setSearchPaths(from_str_vec(var));
}
static int64_t content_get_search_paths()
{
	return to_vec(SharedContent.getSearchPaths());
}
static void linkContent(wasm3::module& mod)
{
	mod.link_optional("*", "content_set_search_paths", content_set_search_paths);
	mod.link_optional("*", "content_get_search_paths", content_get_search_paths);
}
