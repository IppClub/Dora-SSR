/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
void content_set_search_paths(int64_t val) {
	SharedContent.setSearchPaths(Vec_FromStr(val));
}
int64_t content_get_search_paths() {
	return Vec_To(SharedContent.getSearchPaths());
}
void content_set_asset_path(int64_t val) {
	SharedContent.setAssetPath(*Str_From(val));
}
int64_t content_get_asset_path() {
	return Str_Retain(SharedContent.getAssetPath());
}
void content_set_writable_path(int64_t val) {
	SharedContent.setWritablePath(*Str_From(val));
}
int64_t content_get_writable_path() {
	return Str_Retain(SharedContent.getWritablePath());
}
int64_t content_get_app_path() {
	return Str_Retain(SharedContent.getAppPath());
}
int32_t content_save(int64_t filename, int64_t content) {
	return SharedContent.save(*Str_From(filename), *Str_From(content)) ? 1 : 0;
}
int32_t content_exist(int64_t filename) {
	return SharedContent.exist(*Str_From(filename)) ? 1 : 0;
}
int32_t content_mkdir(int64_t path) {
	return SharedContent.createFolder(*Str_From(path)) ? 1 : 0;
}
int32_t content_isdir(int64_t path) {
	return SharedContent.isFolder(*Str_From(path)) ? 1 : 0;
}
int32_t content_is_absolute_path(int64_t path) {
	return SharedContent.isAbsolutePath(*Str_From(path)) ? 1 : 0;
}
int32_t content_copy(int64_t src, int64_t dst) {
	return SharedContent.copy(*Str_From(src), *Str_From(dst)) ? 1 : 0;
}
int32_t content_move_to(int64_t src, int64_t dst) {
	return SharedContent.move(*Str_From(src), *Str_From(dst)) ? 1 : 0;
}
int32_t content_remove(int64_t path) {
	return SharedContent.remove(*Str_From(path)) ? 1 : 0;
}
int64_t content_get_full_path(int64_t filename) {
	return Str_Retain(SharedContent.getFullPath(*Str_From(filename)));
}
void content_add_search_path(int64_t path) {
	SharedContent.addSearchPath(*Str_From(path));
}
void content_insert_search_path(int32_t index, int64_t path) {
	SharedContent.insertSearchPath(s_cast<int>(index), *Str_From(path));
}
void content_remove_search_path(int64_t path) {
	SharedContent.removeSearchPath(*Str_From(path));
}
void content_clear_path_cache() {
	SharedContent.clearPathCache();
}
int64_t content_get_dirs(int64_t path) {
	return Vec_To(SharedContent.getDirs(*Str_From(path)));
}
int64_t content_get_files(int64_t path) {
	return Vec_To(SharedContent.getFiles(*Str_From(path)));
}
int64_t content_get_all_files(int64_t path) {
	return Vec_To(SharedContent.getAllFiles(*Str_From(path)));
}
void content_load_async(int64_t filename, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	SharedContent.loadAsync(*Str_From(filename), [func0, args0, deref0](String content) {
		args0->clear();
		args0->push(content);
		SharedWasmRuntime.invoke(func0);
	});
}
void content_copy_async(int64_t src_file, int64_t target_file, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	SharedContent.copyAsync(*Str_From(src_file), *Str_From(target_file), [func0, args0, deref0](bool success) {
		args0->clear();
		args0->push(success);
		SharedWasmRuntime.invoke(func0);
	});
}
void content_save_async(int64_t filename, int64_t content, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	SharedContent.saveAsync(*Str_From(filename), *Str_From(content), [func0, args0, deref0](bool success) {
		args0->clear();
		args0->push(success);
		SharedWasmRuntime.invoke(func0);
	});
}
void content_zip_async(int64_t folder_path, int64_t zip_file, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	std::shared_ptr<void> deref1(nullptr, [func1](auto) {
		SharedWasmRuntime.deref(func1);
	});
	auto args1 = r_cast<CallStack*>(stack1);
	SharedContent.zipAsync(*Str_From(folder_path), *Str_From(zip_file), [func0, args0, deref0](String file) {
		args0->clear();
		args0->push(file);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}, [func1, args1, deref1](bool success) {
		args1->clear();
		args1->push(success);
		SharedWasmRuntime.invoke(func1);
	});
}
void content_unzip_async(int64_t zip_file, int64_t folder_path, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	std::shared_ptr<void> deref1(nullptr, [func1](auto) {
		SharedWasmRuntime.deref(func1);
	});
	auto args1 = r_cast<CallStack*>(stack1);
	SharedContent.unzipAsync(*Str_From(zip_file), *Str_From(folder_path), [func0, args0, deref0](String file) {
		args0->clear();
		args0->push(file);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}, [func1, args1, deref1](bool success) {
		args1->clear();
		args1->push(success);
		SharedWasmRuntime.invoke(func1);
	});
}
int64_t content_load_excel(int64_t filename) {
	return r_cast<int64_t>(new WorkBook{content_wasm_load_excel(*Str_From(filename))});
}
} // extern "C"

static void linkContent(wasm3::module3& mod) {
	mod.link_optional("*", "content_set_search_paths", content_set_search_paths);
	mod.link_optional("*", "content_get_search_paths", content_get_search_paths);
	mod.link_optional("*", "content_set_asset_path", content_set_asset_path);
	mod.link_optional("*", "content_get_asset_path", content_get_asset_path);
	mod.link_optional("*", "content_set_writable_path", content_set_writable_path);
	mod.link_optional("*", "content_get_writable_path", content_get_writable_path);
	mod.link_optional("*", "content_get_app_path", content_get_app_path);
	mod.link_optional("*", "content_save", content_save);
	mod.link_optional("*", "content_exist", content_exist);
	mod.link_optional("*", "content_mkdir", content_mkdir);
	mod.link_optional("*", "content_isdir", content_isdir);
	mod.link_optional("*", "content_is_absolute_path", content_is_absolute_path);
	mod.link_optional("*", "content_copy", content_copy);
	mod.link_optional("*", "content_move_to", content_move_to);
	mod.link_optional("*", "content_remove", content_remove);
	mod.link_optional("*", "content_get_full_path", content_get_full_path);
	mod.link_optional("*", "content_add_search_path", content_add_search_path);
	mod.link_optional("*", "content_insert_search_path", content_insert_search_path);
	mod.link_optional("*", "content_remove_search_path", content_remove_search_path);
	mod.link_optional("*", "content_clear_path_cache", content_clear_path_cache);
	mod.link_optional("*", "content_get_dirs", content_get_dirs);
	mod.link_optional("*", "content_get_files", content_get_files);
	mod.link_optional("*", "content_get_all_files", content_get_all_files);
	mod.link_optional("*", "content_load_async", content_load_async);
	mod.link_optional("*", "content_copy_async", content_copy_async);
	mod.link_optional("*", "content_save_async", content_save_async);
	mod.link_optional("*", "content_zip_async", content_zip_async);
	mod.link_optional("*", "content_unzip_async", content_unzip_async);
	mod.link_optional("*", "content_load_excel", content_load_excel);
}