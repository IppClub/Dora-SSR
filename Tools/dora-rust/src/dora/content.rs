extern "C" {
	fn content_set_search_paths(var: i64);
	fn content_get_search_paths() -> i64;
}
pub struct Content {  }
impl Content {
	pub fn set_search_paths(var: &Vec<&str>) {
		unsafe { content_set_search_paths(crate::dora::Vector::from_str(var)) };
	}
	pub fn get_search_paths() -> Vec<String> {
		return crate::dora::Vector::to_str(unsafe { content_get_search_paths() });
	}
}