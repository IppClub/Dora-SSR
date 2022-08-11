extern "C" {
	fn dbrecord_release(raw: i64);
	fn dbrecord_add(slf: i64, params: i64);
	fn dbrecord_read(slf: i64, record: i64) -> i32;
}
use crate::dora::IObject;
pub struct DBRecord { raw: i64 }
impl Drop for DBRecord {
	fn drop(&mut self) { unsafe { dbrecord_release(self.raw); } }
}
impl DBRecord {
	pub fn raw(&self) -> i64 {
		self.raw
	}
	pub fn from(raw: i64) -> DBRecord {
		DBRecord { raw: raw }
	}
	pub fn add(&mut self, params: &crate::dora::Array) {
		unsafe { dbrecord_add(self.raw(), params.raw()); }
	}
	pub fn read(&mut self, record: &crate::dora::Array) -> bool {
		unsafe { return dbrecord_read(self.raw(), record.raw()) != 0; }
	}
}