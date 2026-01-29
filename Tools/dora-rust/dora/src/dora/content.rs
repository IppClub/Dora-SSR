/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn content_set_search_paths(val: i64);
	fn content_get_search_paths() -> i64;
	fn content_set_asset_path(val: i64);
	fn content_get_asset_path() -> i64;
	fn content_set_writable_path(val: i64);
	fn content_get_writable_path() -> i64;
	fn content_get_app_path() -> i64;
	fn content_save(filename: i64, content: i64) -> i32;
	fn content_exist(filename: i64) -> i32;
	fn content_mkdir(path: i64) -> i32;
	fn content_isdir(path: i64) -> i32;
	fn content_is_absolute_path(path: i64) -> i32;
	fn content_copy(src: i64, dst: i64) -> i32;
	fn content_move_to(src: i64, dst: i64) -> i32;
	fn content_remove(path: i64) -> i32;
	fn content_get_full_path(filename: i64) -> i64;
	fn content_add_search_path(path: i64);
	fn content_insert_search_path(index: i32, path: i64);
	fn content_remove_search_path(path: i64);
	fn content_clear_path_cache();
	fn content_get_dirs(path: i64) -> i64;
	fn content_get_files(path: i64) -> i64;
	fn content_get_all_files(path: i64) -> i64;
	fn content_search_files_async(path: i64, exts: i64, extension_levels: i64, excludes: i64, pattern: i64, use_regex: i32, case_sensitive: i32, include_content: i32, content_window: i32, func0: i32, stack0: i64);
	fn content_load_async(filename: i64, func0: i32, stack0: i64);
	fn content_copy_async(src_file: i64, target_file: i64, func0: i32, stack0: i64);
	fn content_save_async(filename: i64, content: i64, func0: i32, stack0: i64);
	fn content_zip_async(folder_path: i64, zip_file: i64, func0: i32, stack0: i64, func1: i32, stack1: i64);
	fn content_unzip_async(zip_file: i64, folder_path: i64, func0: i32, stack0: i64, func1: i32, stack1: i64);
	fn content_load_excel(filename: i64) -> i64;
}
use crate::dora::IObject;
/// The `Content` is a static struct that manages file searching,
/// loading and other operations related to resources.
pub struct Content { }
impl Content {
	/// Sets an array of directories to search for resource files.
	pub fn set_search_paths(val: &Vec<&str>) {
		unsafe { content_set_search_paths(crate::dora::Vector::from_str(val)) };
	}
	/// Gets an array of directories to search for resource files.
	pub fn get_search_paths() -> Vec<String> {
		return unsafe { crate::dora::Vector::to_str(content_get_search_paths()) };
	}
	/// Sets the path to the directory containing read-only resources. Can only be altered by the user on platform Windows, MacOS and Linux.
	pub fn set_asset_path(val: &str) {
		unsafe { content_set_asset_path(crate::dora::from_string(val)) };
	}
	/// Gets the path to the directory containing read-only resources. Can only be altered by the user on platform Windows, MacOS and Linux.
	pub fn get_asset_path() -> String {
		return unsafe { crate::dora::to_string(content_get_asset_path()) };
	}
	/// Sets the path to the directory where files can be written. Can only be altered by the user on platform Windows, MacOS and Linux. Default is the same as `appPath`.
	pub fn set_writable_path(val: &str) {
		unsafe { content_set_writable_path(crate::dora::from_string(val)) };
	}
	/// Gets the path to the directory where files can be written. Can only be altered by the user on platform Windows, MacOS and Linux. Default is the same as `appPath`.
	pub fn get_writable_path() -> String {
		return unsafe { crate::dora::to_string(content_get_writable_path()) };
	}
	/// Gets the path to the directory for the application storage.
	pub fn get_app_path() -> String {
		return unsafe { crate::dora::to_string(content_get_app_path()) };
	}
	/// Saves the specified content to a file with the specified filename.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to save.
	/// * `content` - The content to save to the file.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the content saves to file successfully, `false` otherwise.
	pub fn save(filename: &str, content: &str) -> bool {
		unsafe { return content_save(crate::dora::from_string(filename), crate::dora::from_string(content)) != 0; }
	}
	/// Checks if a file with the specified filename exists.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file exists, `false` otherwise.
	pub fn exist(filename: &str) -> bool {
		unsafe { return content_exist(crate::dora::from_string(filename)) != 0; }
	}
	/// Creates a new directory with the specified path.
	///
	/// # Arguments
	///
	/// * `path` - The path of the directory to create.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the directory was created, `false` otherwise.
	pub fn mkdir(path: &str) -> bool {
		unsafe { return content_mkdir(crate::dora::from_string(path)) != 0; }
	}
	/// Checks if the specified path is a directory.
	///
	/// # Arguments
	///
	/// * `path` - The path to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the path is a directory, `false` otherwise.
	pub fn isdir(path: &str) -> bool {
		unsafe { return content_isdir(crate::dora::from_string(path)) != 0; }
	}
	/// Checks if the specified path is an absolute path.
	///
	/// # Arguments
	///
	/// * `path` - The path to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the path is an absolute path, `false` otherwise.
	pub fn is_absolute_path(path: &str) -> bool {
		unsafe { return content_is_absolute_path(crate::dora::from_string(path)) != 0; }
	}
	/// Copies the file or directory at the specified source path to the target path.
	///
	/// # Arguments
	///
	/// * `src_path` - The path of the file or directory to copy.
	/// * `dst_path` - The path to copy the file or directory to.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file or directory was successfully copied to the target path, `false` otherwise.
	pub fn copy(src: &str, dst: &str) -> bool {
		unsafe { return content_copy(crate::dora::from_string(src), crate::dora::from_string(dst)) != 0; }
	}
	/// Moves the file or directory at the specified source path to the target path.
	///
	/// # Arguments
	///
	/// * `src_path` - The path of the file or directory to move.
	/// * `dst_path` - The path to move the file or directory to.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file or directory was successfully moved to the target path, `false` otherwise.
	pub fn move_to(src: &str, dst: &str) -> bool {
		unsafe { return content_move_to(crate::dora::from_string(src), crate::dora::from_string(dst)) != 0; }
	}
	/// Removes the file or directory at the specified path.
	///
	/// # Arguments
	///
	/// * `path` - The path of the file or directory to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file or directory was successfully removed, `false` otherwise.
	pub fn remove(path: &str) -> bool {
		unsafe { return content_remove(crate::dora::from_string(path)) != 0; }
	}
	/// Gets the full path of a file with the specified filename.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to get the full path of.
	///
	/// # Returns
	///
	/// * `String` - The full path of the file.
	pub fn get_full_path(filename: &str) -> String {
		unsafe { return crate::dora::to_string(content_get_full_path(crate::dora::from_string(filename))); }
	}
	/// Adds a new search path to the end of the list.
	///
	/// # Arguments
	///
	/// * `path` - The search path to add.
	pub fn add_search_path(path: &str) {
		unsafe { content_add_search_path(crate::dora::from_string(path)); }
	}
	/// Inserts a search path at the specified index.
	///
	/// # Arguments
	///
	/// * `index` - The index at which to insert the search path.
	/// * `path` - The search path to insert.
	pub fn insert_search_path(index: i32, path: &str) {
		unsafe { content_insert_search_path(index, crate::dora::from_string(path)); }
	}
	/// Removes the specified search path from the list.
	///
	/// # Arguments
	///
	/// * `path` - The search path to remove.
	pub fn remove_search_path(path: &str) {
		unsafe { content_remove_search_path(crate::dora::from_string(path)); }
	}
	/// Clears the search path cache of the map of relative paths to full paths.
	pub fn clear_path_cache() {
		unsafe { content_clear_path_cache(); }
	}
	/// Gets the names of all subdirectories in the specified directory.
	///
	/// # Arguments
	///
	/// * `path` - The path of the directory to search.
	///
	/// # Returns
	///
	/// * `Vec<String>` - An array of the names of all subdirectories in the specified directory.
	pub fn get_dirs(path: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(content_get_dirs(crate::dora::from_string(path))); }
	}
	/// Gets the names of all files in the specified directory.
	///
	/// # Arguments
	///
	/// * `path` - The path of the directory to search.
	///
	/// # Returns
	///
	/// * `Vec<String>` - An array of the names of all files in the specified directory.
	pub fn get_files(path: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(content_get_files(crate::dora::from_string(path))); }
	}
	/// Gets the names of all files in the specified directory and its subdirectories.
	///
	/// # Arguments
	///
	/// * `path` - The path of the directory to search.
	///
	/// # Returns
	///
	/// * `Vec<String>` - An array of the names of all files in the specified directory and its subdirectories.
	pub fn get_all_files(path: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(content_get_all_files(crate::dora::from_string(path))); }
	}
	/// Asynchronously searches files and returns the match results. Should be run in a thread.
	///
	/// # Arguments
	///
	/// * `path` - The root path to search from, empty string means asset root.
	/// * `exts` - An array of filename extensions to include, empty array means all.
	/// * `extensionLevels` - A map from extension to priority level for picking the preferred file when the same basename appears with different extensions.
	/// * `excludes` - An array of directory names to skip during searching.
	/// * `pattern` - The search pattern.
	/// * `useRegex` - Whether to treat pattern as regex (default false).
	/// * `caseSensitive` - Whether to use case-sensitive matching (default false).
	/// * `includeContent` - Whether to include the matched content snippet (default false).
	/// * `contentWindow` - Number of characters around the match to include when includeContent is true.
	/// * `callback` - Called per result, return true to stop searching. The callback receives empty dictionary when done.
	pub fn search_files_async(path: &str, exts: &Vec<&str>, extension_levels: &crate::dora::Dictionary, excludes: &Vec<&str>, pattern: &str, use_regex: bool, case_sensitive: bool, include_content: bool, content_window: i32, mut callback: Box<dyn FnMut(&crate::dora::Dictionary) -> bool>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = callback(&stack0.pop_cast::<crate::dora::Dictionary>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { content_search_files_async(crate::dora::from_string(path), crate::dora::Vector::from_str(exts), extension_levels.raw(), crate::dora::Vector::from_str(excludes), crate::dora::from_string(pattern), if use_regex { 1 } else { 0 }, if case_sensitive { 1 } else { 0 }, if include_content { 1 } else { 0 }, content_window, func_id0, stack_raw0); }
	}
	/// Asynchronously loads the content of the file with the specified filename.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to load.
	/// * `callback` - The function to call with the content of the file once it is loaded.
	///
	/// # Returns
	///
	/// * `String` - The content of the loaded file.
	pub fn load_async(filename: &str, mut callback: Box<dyn FnMut(&str)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			callback(stack0.pop_str().unwrap().as_str())
		}));
		unsafe { content_load_async(crate::dora::from_string(filename), func_id0, stack_raw0); }
	}
	/// Asynchronously copies a file or a folder from the source path to the destination path.
	///
	/// # Arguments
	///
	/// * `srcFile` - The path of the file or folder to copy.
	/// * `targetFile` - The destination path of the copied files.
	/// * `callback` - The function to call with a boolean indicating whether the file or folder was copied successfully.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file or folder was copied successfully, `false` otherwise.
	pub fn copy_async(src_file: &str, target_file: &str, mut callback: Box<dyn FnMut(bool)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			callback(stack0.pop_bool().unwrap())
		}));
		unsafe { content_copy_async(crate::dora::from_string(src_file), crate::dora::from_string(target_file), func_id0, stack_raw0); }
	}
	/// Asynchronously saves the specified content to a file with the specified filename.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to save.
	/// * `content` - The content to save to the file.
	/// * `callback` - The function to call with a boolean indicating whether the content was saved successfully.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the content was saved successfully, `false` otherwise.
	pub fn save_async(filename: &str, content: &str, mut callback: Box<dyn FnMut(bool)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			callback(stack0.pop_bool().unwrap())
		}));
		unsafe { content_save_async(crate::dora::from_string(filename), crate::dora::from_string(content), func_id0, stack_raw0); }
	}
	/// Asynchronously compresses the specified folder to a ZIP archive with the specified filename.
	///
	/// # Arguments
	///
	/// * `folder_path` - The path of the folder to compress, should be under the asset writable path.
	/// * `zip_file` - The name of the ZIP archive to create.
	/// * `filter` - An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
	/// * `callback` - The function to call with a boolean indicating whether the folder was compressed successfully.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the folder was compressed successfully, `false` otherwise.
	pub fn zip_async(folder_path: &str, zip_file: &str, mut filter: Box<dyn FnMut(&str) -> bool>, mut callback: Box<dyn FnMut(bool)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = filter(stack0.pop_str().unwrap().as_str());
			stack0.push_bool(result);
		}));
		let mut stack1 = crate::dora::CallStack::new();
		let stack_raw1 = stack1.raw();
		let func_id1 = crate::dora::push_function(Box::new(move || {
			callback(stack1.pop_bool().unwrap())
		}));
		unsafe { content_zip_async(crate::dora::from_string(folder_path), crate::dora::from_string(zip_file), func_id0, stack_raw0, func_id1, stack_raw1); }
	}
	/// Asynchronously decompresses a ZIP archive to the specified folder.
	///
	/// # Arguments
	///
	/// * `zip_file` - The name of the ZIP archive to decompress, should be a file under the asset writable path.
	/// * `folder_path` - The path of the folder to decompress to, should be under the asset writable path.
	/// * `filter` - An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
	/// * `callback` - The function to call with a boolean indicating whether the archive was decompressed successfully.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the folder was decompressed successfully, `false` otherwise.
	pub fn unzip_async(zip_file: &str, folder_path: &str, mut filter: Box<dyn FnMut(&str) -> bool>, mut callback: Box<dyn FnMut(bool)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = filter(stack0.pop_str().unwrap().as_str());
			stack0.push_bool(result);
		}));
		let mut stack1 = crate::dora::CallStack::new();
		let stack_raw1 = stack1.raw();
		let func_id1 = crate::dora::push_function(Box::new(move || {
			callback(stack1.pop_bool().unwrap())
		}));
		unsafe { content_unzip_async(crate::dora::from_string(zip_file), crate::dora::from_string(folder_path), func_id0, stack_raw0, func_id1, stack_raw1); }
	}
	pub fn load_excel(filename: &str) -> crate::dora::WorkBook {
		unsafe { return crate::dora::WorkBook::from(content_load_excel(crate::dora::from_string(filename))); }
	}
}