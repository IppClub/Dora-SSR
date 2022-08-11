extern "C" {
	fn content_set_search_paths(var: i64);
	fn content_get_search_paths() -> i64;
	fn content_get_asset_path() -> i64;
	fn content_get_writable_path() -> i64;
	fn content_save(filename: i64, content: i64);
	fn content_exist(filename: i64) -> i32;
	fn content_mkdir(path: i64) -> i32;
	fn content_isdir(path: i64) -> i32;
	fn content_remove(path: i64) -> i32;
	fn content_get_full_path(filename: i64) -> i64;
	fn content_add_search_path(path: i64);
	fn content_insert_search_path(index: i32, path: i64);
	fn content_remove_search_path(path: i64);
	fn content_clear_path_cache();
	fn content_get_dirs(path: i64) -> i64;
	fn content_get_files(path: i64) -> i64;
	fn content_get_all_files(path: i64) -> i64;
	fn content_load_async(filename: i64, func: i32, stack: i64);
	fn content_copy_async(src_file: i64, target_file: i64, func: i32);
	fn content_save_async(filename: i64, content: i64, func: i32);
}
pub struct Content { }
impl Content {
	pub fn set_search_paths(var: &Vec<&str>) {
		unsafe { content_set_search_paths(crate::dora::Vector::from_str(var)) };
	}
	pub fn get_search_paths() -> Vec<String> {
		return unsafe { crate::dora::Vector::to_str(content_get_search_paths()) };
	}
	pub fn get_asset_path() -> String {
		return unsafe { crate::dora::to_string(content_get_asset_path()) };
	}
	pub fn get_writable_path() -> String {
		return unsafe { crate::dora::to_string(content_get_writable_path()) };
	}
	pub fn save(filename: &str, content: &str) {
		unsafe { content_save(crate::dora::from_string(filename), crate::dora::from_string(content)); }
	}
	pub fn exist(filename: &str) -> bool {
		unsafe { return content_exist(crate::dora::from_string(filename)) != 0; }
	}
	pub fn mkdir(path: &str) -> bool {
		unsafe { return content_mkdir(crate::dora::from_string(path)) != 0; }
	}
	pub fn isdir(path: &str) -> bool {
		unsafe { return content_isdir(crate::dora::from_string(path)) != 0; }
	}
	pub fn remove(path: &str) -> bool {
		unsafe { return content_remove(crate::dora::from_string(path)) != 0; }
	}
	pub fn get_full_path(filename: &str) -> String {
		unsafe { return crate::dora::to_string(content_get_full_path(crate::dora::from_string(filename))); }
	}
	pub fn add_search_path(path: &str) {
		unsafe { content_add_search_path(crate::dora::from_string(path)); }
	}
	pub fn insert_search_path(index: i32, path: &str) {
		unsafe { content_insert_search_path(index, crate::dora::from_string(path)); }
	}
	pub fn remove_search_path(path: &str) {
		unsafe { content_remove_search_path(crate::dora::from_string(path)); }
	}
	pub fn clear_path_cache() {
		unsafe { content_clear_path_cache(); }
	}
	pub fn get_dirs(path: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(content_get_dirs(crate::dora::from_string(path))); }
	}
	pub fn get_files(path: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(content_get_files(crate::dora::from_string(path))); }
	}
	pub fn get_all_files(path: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(content_get_all_files(crate::dora::from_string(path))); }
	}
	pub fn load_async(filename: &str, mut callback: Box<dyn FnMut(&str)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(stack.pop_str().unwrap().as_str())
		}));
		unsafe { content_load_async(crate::dora::from_string(filename), func_id, stack_raw); }
	}
	pub fn copy_async(src_file: &str, target_file: &str, mut callback: Box<dyn FnMut()>) {
		let func_id = crate::dora::push_function(Box::new(move || {
			callback()
		}));
		unsafe { content_copy_async(crate::dora::from_string(src_file), crate::dora::from_string(target_file), func_id); }
	}
	pub fn save_async(filename: &str, content: &str, mut callback: Box<dyn FnMut()>) {
		let func_id = crate::dora::push_function(Box::new(move || {
			callback()
		}));
		unsafe { content_save_async(crate::dora::from_string(filename), crate::dora::from_string(content), func_id); }
	}
}