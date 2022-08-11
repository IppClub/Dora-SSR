extern "C" {
	fn cache_load(filename: i64) -> i32;
	fn cache_load_async(filename: i64, func: i32);
	fn cache_update_item(filename: i64, content: i64);
	fn cache_update_texture(filename: i64, texture: i64);
	fn cache_unload();
	fn cache_unload_item_or_type(name: i64) -> i32;
	fn cache_remove_unused();
	fn cache_remove_unused_by_type(type_name: i64);
}
use crate::dora::IObject;
pub struct Cache { }
impl Cache {
	pub fn load(filename: &str) -> bool {
		unsafe { return cache_load(crate::dora::from_string(filename)) != 0; }
	}
	pub fn load_async(filename: &str, mut callback: Box<dyn FnMut()>) {
		let func_id = crate::dora::push_function(Box::new(move || {
			callback()
		}));
		unsafe { cache_load_async(crate::dora::from_string(filename), func_id); }
	}
	pub fn update_item(filename: &str, content: &str) {
		unsafe { cache_update_item(crate::dora::from_string(filename), crate::dora::from_string(content)); }
	}
	pub fn update_texture(filename: &str, texture: &crate::dora::Texture2D) {
		unsafe { cache_update_texture(crate::dora::from_string(filename), texture.raw()); }
	}
	pub fn unload() {
		unsafe { cache_unload(); }
	}
	pub fn unload_item_or_type(name: &str) -> bool {
		unsafe { return cache_unload_item_or_type(crate::dora::from_string(name)) != 0; }
	}
	pub fn remove_unused() {
		unsafe { cache_remove_unused(); }
	}
	pub fn remove_unused_by_type(type_name: &str) {
		unsafe { cache_remove_unused_by_type(crate::dora::from_string(type_name)); }
	}
}