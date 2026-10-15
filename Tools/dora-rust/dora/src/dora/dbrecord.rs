/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn dbrecord_release(raw: i64);
	fn dbrecord_is_valid(slf: i64) -> i32;
	fn dbrecord_read(slf: i64, record: i64) -> i32;
}
use crate::dora::IObject;
pub struct DBRecord { raw: i64 }
impl Drop for DBRecord {
	fn drop(&mut self) { unsafe { dbrecord_release(self.raw); } }
}
impl DBRecord {
	pub(crate) fn raw(&self) -> i64 {
		self.raw
	}
	pub(crate) fn from(raw: i64) -> DBRecord {
		DBRecord { raw: raw }
	}
	pub fn is_valid(&self) -> bool {
		return unsafe { dbrecord_is_valid(self.raw()) != 0 };
	}
	pub fn read(&mut self, record: &crate::dora::Array) -> bool {
		unsafe { return dbrecord_read(self.raw(), record.raw()) != 0; }
	}
}