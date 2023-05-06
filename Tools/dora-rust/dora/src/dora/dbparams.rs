extern "C" {
	fn dbparams_release(raw: i64);
	fn dbparams_add(slf: i64, params: i64);
}
use crate::dora::IObject;
pub struct DBParams { raw: i64 }
impl Drop for DBParams {
	fn drop(&mut self) { unsafe { dbparams_release(self.raw); } }
}
impl DBParams {
	pub fn raw(&self) -> i64 {
		self.raw
	}
	pub fn from(raw: i64) -> DBParams {
		DBParams { raw: raw }
	}
	pub fn add(&mut self, params: &crate::dora::Array) {
		unsafe { dbparams_add(self.raw(), params.raw()); }
	}
}