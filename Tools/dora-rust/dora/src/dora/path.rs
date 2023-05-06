extern "C" {
	fn path_get_ext(path: i64) -> i64;
	fn path_get_path(path: i64) -> i64;
	fn path_get_name(path: i64) -> i64;
	fn path_get_filename(path: i64) -> i64;
	fn path_get_relative(path: i64, target: i64) -> i64;
	fn path_replace_ext(path: i64, new_ext: i64) -> i64;
	fn path_replace_filename(path: i64, new_file: i64) -> i64;
}
pub struct Path { raw: i64 }
impl Path {
	pub fn from(raw: i64) -> Option<Path> {
		match raw {
			0 => None,
			_ => Some(Path { raw: raw })
		}
	}
	pub fn raw(&self) -> i64 { self.raw }
	pub fn get_ext(path: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_ext(crate::dora::from_string(path))); }
	}
	pub fn get_path(path: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_path(crate::dora::from_string(path))); }
	}
	pub fn get_name(path: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_name(crate::dora::from_string(path))); }
	}
	pub fn get_filename(path: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_filename(crate::dora::from_string(path))); }
	}
	pub fn get_relative(path: &str, target: &str) -> String {
		unsafe { return crate::dora::to_string(path_get_relative(crate::dora::from_string(path), crate::dora::from_string(target))); }
	}
	pub fn replace_ext(path: &str, new_ext: &str) -> String {
		unsafe { return crate::dora::to_string(path_replace_ext(crate::dora::from_string(path), crate::dora::from_string(new_ext))); }
	}
	pub fn replace_filename(path: &str, new_file: &str) -> String {
		unsafe { return crate::dora::to_string(path_replace_filename(crate::dora::from_string(path), crate::dora::from_string(new_file))); }
	}
}