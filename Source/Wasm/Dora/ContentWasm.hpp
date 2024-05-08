/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static void content_set_search_paths(int64_t var) {
	SharedContent.setSearchPaths(from_str_vec(var));
}
static int64_t content_get_search_paths() {
	return to_vec(SharedContent.getSearchPaths());
}
static int64_t content_get_asset_path() {
	return str_retain(SharedContent.getAssetPath());
}
static int64_t content_get_writable_path() {
	return str_retain(SharedContent.getWritablePath());
}
static int32_t content_save(int64_t filename, int64_t content) {
	return SharedContent.save(*str_from(filename), *str_from(content)) ? 1 : 0;
}
static int32_t content_exist(int64_t filename) {
	return SharedContent.exist(*str_from(filename)) ? 1 : 0;
}
static int32_t content_mkdir(int64_t path) {
	return SharedContent.createFolder(*str_from(path)) ? 1 : 0;
}
static int32_t content_isdir(int64_t path) {
	return SharedContent.isFolder(*str_from(path)) ? 1 : 0;
}
static int32_t content_is_absolute_path(int64_t path) {
	return SharedContent.isAbsolutePath(*str_from(path)) ? 1 : 0;
}
static int32_t content_copy(int64_t src, int64_t dst) {
	return SharedContent.copy(*str_from(src), *str_from(dst)) ? 1 : 0;
}
static int32_t content_move_to(int64_t src, int64_t dst) {
	return SharedContent.move(*str_from(src), *str_from(dst)) ? 1 : 0;
}
static int32_t content_remove(int64_t path) {
	return SharedContent.remove(*str_from(path)) ? 1 : 0;
}
static int64_t content_get_full_path(int64_t filename) {
	return str_retain(SharedContent.getFullPath(*str_from(filename)));
}
static void content_add_search_path(int64_t path) {
	SharedContent.addSearchPath(*str_from(path));
}
static void content_insert_search_path(int32_t index, int64_t path) {
	SharedContent.insertSearchPath(s_cast<int>(index), *str_from(path));
}
static void content_remove_search_path(int64_t path) {
	SharedContent.removeSearchPath(*str_from(path));
}
static void content_clear_path_cache() {
	SharedContent.clearPathCache();
}
static int64_t content_get_dirs(int64_t path) {
	return to_vec(SharedContent.getDirs(*str_from(path)));
}
static int64_t content_get_files(int64_t path) {
	return to_vec(SharedContent.getFiles(*str_from(path)));
}
static int64_t content_get_all_files(int64_t path) {
	return to_vec(SharedContent.getAllFiles(*str_from(path)));
}
static void content_load_async(int64_t filename, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	SharedContent.loadAsync(*str_from(filename), [func, args, deref](String content) {
		args->clear();
		args->push(content);
		SharedWasmRuntime.invoke(func);
	});
}
static void content_copy_async(int64_t src_file, int64_t target_file, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	SharedContent.copyAsync(*str_from(src_file), *str_from(target_file), [func, args, deref](bool success) {
		args->clear();
		args->push(success);
		SharedWasmRuntime.invoke(func);
	});
}
static void content_save_async(int64_t filename, int64_t content, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	SharedContent.saveAsync(*str_from(filename), *str_from(content), [func, args, deref](bool success) {
		args->clear();
		args->push(success);
		SharedWasmRuntime.invoke(func);
	});
}
static void content_zip_async(int64_t folder_path, int64_t zip_file, int32_t func, int64_t stack, int32_t func1, int64_t stack1) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	std::shared_ptr<void> deref1(nullptr, [func1](auto) {
		SharedWasmRuntime.deref(func1);
	});
	auto args1 = r_cast<CallStack*>(stack1);
	SharedContent.zipAsync(*str_from(folder_path), *str_from(zip_file), [func, args, deref](String file) {
		args->clear();
		args->push(file);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}, [func1, args1, deref1](bool success) {
		args1->clear();
		args1->push(success);
		SharedWasmRuntime.invoke(func1);
	});
}
static void content_unzip_async(int64_t zip_file, int64_t folder_path, int32_t func, int64_t stack, int32_t func1, int64_t stack1) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	std::shared_ptr<void> deref1(nullptr, [func1](auto) {
		SharedWasmRuntime.deref(func1);
	});
	auto args1 = r_cast<CallStack*>(stack1);
	SharedContent.unzipAsync(*str_from(zip_file), *str_from(folder_path), [func, args, deref](String file) {
		args->clear();
		args->push(file);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}, [func1, args1, deref1](bool success) {
		args1->clear();
		args1->push(success);
		SharedWasmRuntime.invoke(func1);
	});
}
static int64_t content_load_excel(int64_t filename) {
	return r_cast<int64_t>(new WorkBook{content_wasm_load_excel(*str_from(filename))});
}
static void linkContent(wasm3::module3& mod) {
	mod.link_optional("*", "content_set_search_paths", content_set_search_paths);
	mod.link_optional("*", "content_get_search_paths", content_get_search_paths);
	mod.link_optional("*", "content_get_asset_path", content_get_asset_path);
	mod.link_optional("*", "content_get_writable_path", content_get_writable_path);
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