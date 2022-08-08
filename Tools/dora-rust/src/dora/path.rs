extern "C" {
	fn path_get_ext(path: i64) -> i64;
	fn path_get_path(path: i64) -> i64;
	fn path_get_name(path: i64) -> i64;
	fn path_get_filename(path: i64) -> i64;
	fn path_replace_ext(path: i64, new_ext: i64) -> i64;
	fn path_replace_filename(path: i64, new_file: i64) -> i64;
}
pub struct Path { raw: i64 }
impl Path {
	pub fn get_ext(path: &str) -> String {
		return crate::dora::to_string(unsafe { path_get_ext(crate::dora::from_string(path)) });
	}
	pub fn get_path(path: &str) -> String {
		return crate::dora::to_string(unsafe { path_get_path(crate::dora::from_string(path)) });
	}
	pub fn get_name(path: &str) -> String {
		return crate::dora::to_string(unsafe { path_get_name(crate::dora::from_string(path)) });
	}
	pub fn get_filename(path: &str) -> String {
		return crate::dora::to_string(unsafe { path_get_filename(crate::dora::from_string(path)) });
	}
	pub fn replace_ext(path: &str, new_ext: &str) -> String {
		return crate::dora::to_string(unsafe { path_replace_ext(crate::dora::from_string(path), crate::dora::from_string(new_ext)) });
	}
	pub fn replace_filename(path: &str, new_file: &str) -> String {
		return crate::dora::to_string(unsafe { path_replace_filename(crate::dora::from_string(path), crate::dora::from_string(new_file)) });
	}
}