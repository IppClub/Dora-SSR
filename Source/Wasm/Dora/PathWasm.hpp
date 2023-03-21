static int64_t path_get_ext(int64_t path) {
	return str_retain(Path::getExt(*str_from(path)));
}
static int64_t path_get_path(int64_t path) {
	return str_retain(Path::getPath(*str_from(path)));
}
static int64_t path_get_name(int64_t path) {
	return str_retain(Path::getName(*str_from(path)));
}
static int64_t path_get_filename(int64_t path) {
	return str_retain(Path::getFilename(*str_from(path)));
}
static int64_t path_get_relative(int64_t path, int64_t target) {
	return str_retain(Path::getRelative(*str_from(path), *str_from(target)));
}
static int64_t path_replace_ext(int64_t path, int64_t new_ext) {
	return str_retain(Path::replaceExt(*str_from(path), *str_from(new_ext)));
}
static int64_t path_replace_filename(int64_t path, int64_t new_file) {
	return str_retain(Path::replaceFilename(*str_from(path), *str_from(new_file)));
}
static void linkPath(wasm3::module& mod) {
	mod.link_optional("*", "path_get_ext", path_get_ext);
	mod.link_optional("*", "path_get_path", path_get_path);
	mod.link_optional("*", "path_get_name", path_get_name);
	mod.link_optional("*", "path_get_filename", path_get_filename);
	mod.link_optional("*", "path_get_relative", path_get_relative);
	mod.link_optional("*", "path_replace_ext", path_replace_ext);
	mod.link_optional("*", "path_replace_filename", path_replace_filename);
}