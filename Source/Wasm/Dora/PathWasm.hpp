/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int64_t path_get_ext(int64_t path) {
	return Str_Retain(Path::getExt(*Str_From(path)));
}
DORA_EXPORT int64_t path_get_path(int64_t path) {
	return Str_Retain(Path::getPath(*Str_From(path)));
}
DORA_EXPORT int64_t path_get_name(int64_t path) {
	return Str_Retain(Path::getName(*Str_From(path)));
}
DORA_EXPORT int64_t path_get_filename(int64_t path) {
	return Str_Retain(Path::getFilename(*Str_From(path)));
}
DORA_EXPORT int64_t path_get_relative(int64_t path, int64_t target) {
	return Str_Retain(Path::getRelative(*Str_From(path), *Str_From(target)));
}
DORA_EXPORT int64_t path_replace_ext(int64_t path, int64_t new_ext) {
	return Str_Retain(Path::replaceExt(*Str_From(path), *Str_From(new_ext)));
}
DORA_EXPORT int64_t path_replace_filename(int64_t path, int64_t new_file) {
	return Str_Retain(Path::replaceFilename(*Str_From(path), *Str_From(new_file)));
}
DORA_EXPORT int64_t path_concat(int64_t paths) {
	return Str_Retain(Path::concatVector(Vec_FromStr(paths)));
}
} // extern "C"

static void linkPath(wasm3::module3& mod) {
	mod.link_optional("*", "path_get_ext", path_get_ext);
	mod.link_optional("*", "path_get_path", path_get_path);
	mod.link_optional("*", "path_get_name", path_get_name);
	mod.link_optional("*", "path_get_filename", path_get_filename);
	mod.link_optional("*", "path_get_relative", path_get_relative);
	mod.link_optional("*", "path_replace_ext", path_replace_ext);
	mod.link_optional("*", "path_replace_filename", path_replace_filename);
	mod.link_optional("*", "path_concat", path_concat);
}