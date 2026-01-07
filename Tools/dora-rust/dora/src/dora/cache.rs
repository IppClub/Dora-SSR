/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn cache_load(filename: i64) -> i32;
	fn cache_load_async(filename: i64, func0: i32, stack0: i64);
	fn cache_update_item(filename: i64, content: i64);
	fn cache_update_texture(filename: i64, texture: i64);
	fn cache_unload_item_or_type(name: i64) -> i32;
	fn cache_unload();
	fn cache_remove_unused();
	fn cache_remove_unused_by_type(type_name: i64);
}
use crate::dora::IObject;
/// A interface for managing various game resources.
pub struct Cache { }
impl Cache {
	/// Loads a file into the cache with a blocking operation.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to load.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file was loaded successfully, `false` otherwise.
	pub fn load(filename: &str) -> bool {
		unsafe { return cache_load(crate::dora::from_string(filename)) != 0; }
	}
	/// Loads a file into the cache asynchronously.
	///
	/// # Arguments
	///
	/// * `filenames` - The name of the file(s) to load. This can be a single string or a vector of strings.
	/// * `handler` - A callback function that is invoked when the file is loaded.
	pub fn load_async(filename: &str, mut handler: Box<dyn FnMut(bool)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(stack0.pop_bool().unwrap())
		}));
		unsafe { cache_load_async(crate::dora::from_string(filename), func_id0, stack_raw0); }
	}
	/// Updates the content of a file loaded in the cache.
	/// If the item of filename does not exist in the cache, a new file content will be added into the cache.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to update.
	/// * `content` - The new content for the file.
	pub fn update_item(filename: &str, content: &str) {
		unsafe { cache_update_item(crate::dora::from_string(filename), crate::dora::from_string(content)); }
	}
	/// Updates the texture object of the specific filename loaded in the cache.
	/// If the texture object of filename does not exist in the cache, it will be added into the cache.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the texture to update.
	/// * `texture` - The new texture object for the file.
	pub fn update_texture(filename: &str, texture: &crate::dora::Texture2D) {
		unsafe { cache_update_texture(crate::dora::from_string(filename), texture.raw()); }
	}
	/// Unloads a resource from the cache.
	///
	/// # Arguments
	///
	/// * `name` - The type name of resource to unload, could be one of "Texture", "SVG", "Clip", "Frame", "Model", "Particle", "Shader", "Font", "Sound", "Spine". Or the name of the resource file to unload.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the resource was unloaded successfully, `false` otherwise.
	pub fn unload_item_or_type(name: &str) -> bool {
		unsafe { return cache_unload_item_or_type(crate::dora::from_string(name)) != 0; }
	}
	/// Unloads all resources from the cache.
	pub fn unload() {
		unsafe { cache_unload(); }
	}
	/// Removes all unused resources (not being referenced) from the cache.
	pub fn remove_unused() {
		unsafe { cache_remove_unused(); }
	}
	/// Removes all unused resources of the given type from the cache.
	///
	/// # Arguments
	///
	/// * `resource_type` - The type of resource to remove. This could be one of "Texture", "SVG", "Clip", "Frame", "Model", "Particle", "Shader", "Font", "Sound", "Spine".
	pub fn remove_unused_by_type(type_name: &str) {
		unsafe { cache_remove_unused_by_type(crate::dora::from_string(type_name)); }
	}
}