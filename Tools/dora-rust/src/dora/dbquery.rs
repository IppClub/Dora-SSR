extern "C" {
	fn dbquery_release(raw: i64);
	fn dbquery_add_with_params(slf: i64, sql: i64, params: i64);
	fn dbquery_add(slf: i64, sql: i64);
}
pub struct DBQuery { raw: i64 }
impl Drop for DBQuery {
	fn drop(&mut self) { unsafe { dbquery_release(self.raw); } }
}
impl DBQuery {
	pub fn raw(&self) -> i64 {
		self.raw
	}
	pub fn from(raw: i64) -> DBQuery {
		DBQuery { raw: raw }
	}
	pub fn add_with_params(&mut self, sql: &str, params: crate::dora::DBParams) {
		unsafe { dbquery_add_with_params(self.raw(), crate::dora::from_string(sql), params.raw()); }
	}
	pub fn add(&mut self, sql: &str) {
		unsafe { dbquery_add(self.raw(), crate::dora::from_string(sql)); }
	}
}