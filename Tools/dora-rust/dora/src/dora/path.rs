/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn path_get_ext(path: i64) -> i64;
	fn path_get_path(path: i64) -> i64;
	fn path_get_name(path: i64) -> i64;
	fn path_get_filename(path: i64) -> i64;
	fn path_get_relative(path: i64, target: i64) -> i64;
	fn path_replace_ext(path: i64, new_ext: i64) -> i64;
	fn path_replace_filename(path: i64, new_file: i64) -> i64;
	fn path_concat(paths: i64) -> i64;
}
/// Helper struct for file path operations.
pub struct Path { }
impl Path {
	/// Extracts the file extension from a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT" Output: "txt"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	///
	/// # Returns
	///
	/// * `String` - The extension of the input file.
	pub fn get_ext(path: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_ext(crate::dora::from_string(path))); }
	}
	/// Extracts the parent path from a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT" Output: "/a/b"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	///
	/// # Returns
	///
	/// * `String` - The parent path of the input file.
	pub fn get_path(path: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_path(crate::dora::from_string(path))); }
	}
	/// Extracts the file name without extension from a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT" Output: "c"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	///
	/// # Returns
	///
	/// * `String` - The name of the input file without extension.
	pub fn get_name(path: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_name(crate::dora::from_string(path))); }
	}
	/// Extracts the file name from a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT" Output: "c.TXT"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	///
	/// # Returns
	///
	/// * `String` - The name of the input file.
	pub fn get_filename(path: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_filename(crate::dora::from_string(path))); }
	}
	/// Computes the relative path from the target file to the input file.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT", base: "/a" Output: "b/c.TXT"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	/// * `base` - The target file path.
	///
	/// # Returns
	///
	/// * `String` - The relative path from the input file to the target file.
	pub fn get_relative(path: &str, target: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_relative(crate::dora::from_string(path), crate::dora::from_string(target))); }
	}
	/// Changes the file extension in a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT", "lua" Output: "/a/b/c.lua"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	/// * `new_ext` - The new file extension to replace the old one.
	///
	/// # Returns
	///
	/// * `String` - The new file path.
	pub fn replace_ext(path: &str, new_ext: &str) -> String {
		unsafe { return crate::dora::to_string(path_replace_ext(crate::dora::from_string(path), crate::dora::from_string(new_ext))); }
	}
	/// Changes the filename in a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT", "d" Output: "/a/b/d.TXT"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	/// * `new_file` - The new filename to replace the old one.
	///
	/// # Returns
	///
	/// * `String` - The new file path.
	pub fn replace_filename(path: &str, new_file: &str) -> String {
		unsafe { return crate::dora::to_string(path_replace_filename(crate::dora::from_string(path), crate::dora::from_string(new_file))); }
	}
	/// Joins the given segments into a new file path.
	///
	/// # Example
	///
	/// Input: "a", "b", "c.TXT" Output: "a/b/c.TXT"
	///
	/// # Arguments
	///
	/// * `segments` - The segments to be joined as a new file path.
	///
	/// # Returns
	///
	/// * `String` - The new file path.
	pub fn concat(paths: &Vec<&str>) -> String {
		unsafe { return crate::dora::to_string(path_concat(crate::dora::Vector::from_str(paths))); }
	}
}