/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn dbquery_release(raw: i64);
	fn dbquery_add_with_params(slf: i64, sql: i64, params: i64);
	fn dbquery_add(slf: i64, sql: i64);
	fn dbquery_new() -> i64;
}
pub struct DBQuery { raw: i64 }
impl Drop for DBQuery {
	fn drop(&mut self) { unsafe { dbquery_release(self.raw); } }
}
impl DBQuery {
	pub(crate) fn raw(&self) -> i64 {
		self.raw
	}
	pub(crate) fn from(raw: i64) -> DBQuery {
		DBQuery { raw: raw }
	}
	pub fn add_with_params(&mut self, sql: &str, params: crate::dora::DBParams) {
		unsafe { dbquery_add_with_params(self.raw(), crate::dora::from_string(sql), params.raw()); }
	}
	pub fn add(&mut self, sql: &str) {
		unsafe { dbquery_add(self.raw(), crate::dora::from_string(sql)); }
	}
	pub fn new() -> crate::dora::DBQuery {
		unsafe { return crate::dora::DBQuery::from(dbquery_new()); }
	}
}