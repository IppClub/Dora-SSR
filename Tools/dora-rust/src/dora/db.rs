extern "C" {
	fn db_exist(table_name: i64) -> i32;
	fn db_exec(sql: i64) -> i32;
	fn db_transaction(query: i64) -> i32;
	fn db_query(sql: i64, with_columns: i32) -> i64;
	fn db_query_with_params(sql: i64, param: i64, with_columns: i32) -> i64;
	fn db_insert(table_name: i64, record: i64);
	fn db_exec_with_params(sql: i64, param: i64) -> i32;
	fn db_query_with_params_async(sql: i64, param: i64, with_columns: i32, func: i32, stack: i64);
	fn db_insert_async(table_name: i64, record: i64, func: i32, stack: i64);
	fn db_exec_async(sql: i64, param: i64, func: i32, stack: i64);
}
use crate::dora::IObject;
pub struct DB { }
impl DB {
	pub fn exist(table_name: &str) -> bool {
		unsafe { return db_exist(crate::dora::from_string(table_name)) != 0; }
	}
	pub fn exec(sql: &str) -> i32 {
		unsafe { return db_exec(crate::dora::from_string(sql)); }
	}
	pub fn transaction(query: crate::dora::DBQuery) -> bool {
		unsafe { return db_transaction(query.raw()) != 0; }
	}
	pub fn query(sql: &str, with_columns: bool) -> crate::dora::DBRecord {
		unsafe { return crate::dora::DBRecord::from(db_query(crate::dora::from_string(sql), if with_columns { 1 } else { 0 })); }
	}
	pub fn query_with_params(sql: &str, param: &crate::dora::Array, with_columns: bool) -> crate::dora::DBRecord {
		unsafe { return crate::dora::DBRecord::from(db_query_with_params(crate::dora::from_string(sql), param.raw(), if with_columns { 1 } else { 0 })); }
	}
	pub fn insert(table_name: &str, record: crate::dora::DBRecord) {
		unsafe { db_insert(crate::dora::from_string(table_name), record.raw()); }
	}
	pub fn exec_with_params(sql: &str, param: &crate::dora::Array) -> i32 {
		unsafe { return db_exec_with_params(crate::dora::from_string(sql), param.raw()); }
	}
	pub fn query_with_params_async(sql: &str, param: &crate::dora::Array, with_columns: bool, mut callback: Box<dyn FnMut(crate::dora::DBRecord)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(crate::dora::DBRecord::from(stack.pop_i64().unwrap()))
		}));
		unsafe { db_query_with_params_async(crate::dora::from_string(sql), param.raw(), if with_columns { 1 } else { 0 }, func_id, stack_raw); }
	}
	pub fn insert_async(table_name: &str, record: crate::dora::DBRecord, mut callback: Box<dyn FnMut(bool)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(stack.pop_bool().unwrap())
		}));
		unsafe { db_insert_async(crate::dora::from_string(table_name), record.raw(), func_id, stack_raw); }
	}
	pub fn exec_async(sql: &str, param: &crate::dora::Array, mut callback: Box<dyn FnMut(i64)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(stack.pop_i64().unwrap())
		}));
		unsafe { db_exec_async(crate::dora::from_string(sql), param.raw(), func_id, stack_raw); }
	}
}