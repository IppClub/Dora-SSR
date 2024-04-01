extern "C" {
	fn db_exist(table_name: i64) -> i32;
	fn db_exist_schema(table_name: i64, schema: i64) -> i32;
	fn db_exec(sql: i64) -> i32;
	fn db_transaction(query: i64) -> i32;
	fn db_transaction_async(query: i64, func: i32, stack: i64);
	fn db_query(sql: i64, with_columns: i32) -> i64;
	fn db_query_with_params(sql: i64, args: i64, with_columns: i32) -> i64;
	fn db_insert(table_name: i64, values: i64);
	fn db_exec_with_records(sql: i64, values: i64) -> i32;
	fn db_query_with_params_async(sql: i64, args: i64, with_columns: i32, func: i32, stack: i64);
	fn db_insert_async(table_name: i64, values: i64, func: i32, stack: i64);
	fn db_exec_async(sql: i64, values: i64, func: i32, stack: i64);
}
use crate::dora::IObject;
/// A struct that represents a database.
pub struct DB { }
impl DB {
	/// Checks whether a table exists in the database.
	///
	/// # Arguments
	///
	/// * `table_name` - The name of the table to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the table exists, `false` otherwise.
	pub fn exist(table_name: &str) -> bool {
		unsafe { return db_exist(crate::dora::from_string(table_name)) != 0; }
	}
	/// Checks whether a table exists in the database.
	///
	/// # Arguments
	///
	/// * `table_name` - The name of the table to check.
	/// * `schema` - Optional. The name of the schema to check in.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the table exists, `false` otherwise.
	pub fn exist_schema(table_name: &str, schema: &str) -> bool {
		unsafe { return db_exist_schema(crate::dora::from_string(table_name), crate::dora::from_string(schema)) != 0; }
	}
	/// Executes an SQL statement and returns the number of rows affected.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	///
	/// # Returns
	///
	/// * `i32` - The number of rows affected by the statement.
	pub fn exec(sql: &str) -> i32 {
		unsafe { return db_exec(crate::dora::from_string(sql)); }
	}
	/// Executes a list of SQL statements as a single transaction.
	///
	/// # Arguments
	///
	/// * `query` - A list of SQL statements to execute.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the transaction was successful, `false` otherwise.
	pub fn transaction(query: crate::dora::DBQuery) -> bool {
		unsafe { return db_transaction(query.raw()) != 0; }
	}
	/// Executes a list of SQL statements as a single transaction asynchronously.
	///
	/// # Arguments
	///
	/// * `sqls` - A list of SQL statements to execute.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the transaction was successful, `false` otherwise.
	pub fn transaction_async(query: crate::dora::DBQuery, mut callback: Box<dyn FnMut(bool)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(stack.pop_bool().unwrap())
		}));
		unsafe { db_transaction_async(query.raw(), func_id, stack_raw); }
	}
	/// Executes an SQL query and returns the results as a list of rows.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `with_column` - Whether to include column names in the result.
	///
	/// # Returns
	///
	/// * `DBRecord` - A list of rows returned by the query.
	pub fn query(sql: &str, with_columns: bool) -> crate::dora::DBRecord {
		unsafe { return crate::dora::DBRecord::from(db_query(crate::dora::from_string(sql), if with_columns { 1 } else { 0 })); }
	}
	/// Executes an SQL query and returns the results as a list of rows.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `args` - A list of values to substitute into the SQL statement.
	/// * `with_column` - Whether to include column names in the result.
	///
	/// # Returns
	///
	/// * `DBRecord` - A list of rows returned by the query.
	pub fn query_with_params(sql: &str, args: &crate::dora::Array, with_columns: bool) -> crate::dora::DBRecord {
		unsafe { return crate::dora::DBRecord::from(db_query_with_params(crate::dora::from_string(sql), args.raw(), if with_columns { 1 } else { 0 })); }
	}
	/// Inserts a row of data into a table within a transaction.
	///
	/// # Arguments
	///
	/// * `table_name` - The name of the table to insert into.
	/// * `values` - The values to insert into the table.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the insertion was successful, `false` otherwise.
	pub fn insert(table_name: &str, values: crate::dora::DBParams) {
		unsafe { db_insert(crate::dora::from_string(table_name), values.raw()); }
	}
	/// Executes an SQL statement and returns the number of rows affected.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `values` - Lists of values to substitute into the SQL statement.
	///
	/// # Returns
	///
	/// * `i32` - The number of rows affected by the statement.
	pub fn exec_with_records(sql: &str, values: crate::dora::DBParams) -> i32 {
		unsafe { return db_exec_with_records(crate::dora::from_string(sql), values.raw()); }
	}
	/// Executes an SQL query asynchronously and returns the results as a list of rows.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `args` - Optional. A list of values to substitute into the SQL statement.
	/// * `with_column` - Optional. Whether to include column names in the result. Default is `false`.
	/// * `callback` - A callback function that is invoked when the query is executed, receiving the results as a list of rows.
	pub fn query_with_params_async(sql: &str, args: &crate::dora::Array, with_columns: bool, mut callback: Box<dyn FnMut(crate::dora::DBRecord)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(crate::dora::DBRecord::from(stack.pop_i64().unwrap()))
		}));
		unsafe { db_query_with_params_async(crate::dora::from_string(sql), args.raw(), if with_columns { 1 } else { 0 }, func_id, stack_raw); }
	}
	/// Inserts a row of data into a table within a transaction asynchronously.
	///
	/// # Arguments
	///
	/// * `table_name` - The name of the table to insert into.
	/// * `values` - The values to insert into the table.
	/// * `callback` - A callback function that is invoked when the insertion is executed, receiving the result of the insertion.
	pub fn insert_async(table_name: &str, values: crate::dora::DBParams, mut callback: Box<dyn FnMut(bool)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(stack.pop_bool().unwrap())
		}));
		unsafe { db_insert_async(crate::dora::from_string(table_name), values.raw(), func_id, stack_raw); }
	}
	/// Executes an SQL statement with a list of values within a transaction asynchronously and returns the number of rows affected.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `values` - A list of values to substitute into the SQL statement.
	/// * `callback` - A callback function that is invoked when the statement is executed, recieving the number of rows affected.
	pub fn exec_async(sql: &str, values: crate::dora::DBParams, mut callback: Box<dyn FnMut(i64)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(stack.pop_i64().unwrap())
		}));
		unsafe { db_exec_async(crate::dora::from_string(sql), values.raw(), func_id, stack_raw); }
	}
}