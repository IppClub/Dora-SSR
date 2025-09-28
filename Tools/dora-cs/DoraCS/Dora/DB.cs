/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


using System.Runtime.InteropServices;
using int64_t = long;
using int32_t = int;

namespace Dora
{
	internal static partial class Native
	{
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exist_db(int64_t db_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exist(int64_t table_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exist_schema(int64_t table_name, int64_t schema);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exec(int64_t sql);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_transaction(int64_t query);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_transaction_async(int64_t query, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t db_query(int64_t sql, int32_t with_columns);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t db_query_with_params(int64_t sql, int64_t params_, int32_t with_columns);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_insert(int64_t table_name, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exec_with_records(int64_t sql, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_query_with_params_async(int64_t sql, int64_t params_, int32_t with_columns, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_insert_async(int64_t table_name, int64_t values, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_exec_async(int64_t sql, int64_t values, int32_t func0, int64_t stack0);
	}
} // namespace Dora

namespace Dora
{
	/// A struct that represents a database.
	public static partial class DB
	{
		/// Checks whether a database exists.
		///
		/// # Arguments
		///
		/// * `db_name` - The name of the database to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the database exists, `false` otherwise.
		public static bool ExistDb(string db_name)
		{
			return Native.db_exist_db(Bridge.FromString(db_name)) != 0;
		}
		/// Checks whether a table exists in the database.
		///
		/// # Arguments
		///
		/// * `table_name` - The name of the table to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the table exists, `false` otherwise.
		public static bool Exist(string table_name)
		{
			return Native.db_exist(Bridge.FromString(table_name)) != 0;
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
		public static bool ExistSchema(string table_name, string schema)
		{
			return Native.db_exist_schema(Bridge.FromString(table_name), Bridge.FromString(schema)) != 0;
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
		public static int Exec(string sql)
		{
			return Native.db_exec(Bridge.FromString(sql));
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
		public static bool Transaction(DBQuery query)
		{
			return Native.db_transaction(query.Raw) != 0;
		}
		/// Executes a list of SQL statements as a single transaction asynchronously.
		///
		/// # Arguments
		///
		/// * `sqls` - A list of SQL statements to execute.
		/// * `callback` - A callback function that is invoked when the transaction is executed, receiving the result of the transaction.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the transaction was successful, `false` otherwise.
		public static void TransactionAsync(DBQuery query, Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopBool());
			});
			Native.db_transaction_async(query.Raw, func_id0, stack_raw0);
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
		public static DBRecord Query(string sql, bool with_columns)
		{
			return DBRecord.From(Native.db_query(Bridge.FromString(sql), with_columns ? 1 : 0));
		}
		/// Executes an SQL query and returns the results as a list of rows.
		///
		/// # Arguments
		///
		/// * `sql` - The SQL statement to execute.
		/// * `params_` - A list of values to substitute into the SQL statement.
		/// * `with_column` - Whether to include column names in the result.
		///
		/// # Returns
		///
		/// * `DBRecord` - A list of rows returned by the query.
		public static DBRecord QueryWithParams(string sql, Array params_, bool with_columns)
		{
			return DBRecord.From(Native.db_query_with_params(Bridge.FromString(sql), params_.Raw, with_columns ? 1 : 0));
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
		public static void Insert(string table_name, DBParams values)
		{
			Native.db_insert(Bridge.FromString(table_name), values.Raw);
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
		public static int ExecWithRecords(string sql, DBParams values)
		{
			return Native.db_exec_with_records(Bridge.FromString(sql), values.Raw);
		}
		/// Executes an SQL query asynchronously and returns the results as a list of rows.
		///
		/// # Arguments
		///
		/// * `sql` - The SQL statement to execute.
		/// * `params_` - Optional. A list of values to substitute into the SQL statement.
		/// * `with_column` - Optional. Whether to include column names in the result. Default is `false`.
		/// * `callback` - A callback function that is invoked when the query is executed, receiving the results as a list of rows.
		public static void QueryWithParamsAsync(string sql, Array params_, bool with_columns, Action<DBRecord> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(DBRecord.From(stack0.PopI64()));
			});
			Native.db_query_with_params_async(Bridge.FromString(sql), params_.Raw, with_columns ? 1 : 0, func_id0, stack_raw0);
		}
		/// Inserts a row of data into a table within a transaction asynchronously.
		///
		/// # Arguments
		///
		/// * `table_name` - The name of the table to insert into.
		/// * `values` - The values to insert into the table.
		/// * `callback` - A callback function that is invoked when the insertion is executed, receiving the result of the insertion.
		public static void InsertAsync(string table_name, DBParams values, Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopBool());
			});
			Native.db_insert_async(Bridge.FromString(table_name), values.Raw, func_id0, stack_raw0);
		}
		/// Executes an SQL statement with a list of values within a transaction asynchronously and returns the number of rows affected.
		///
		/// # Arguments
		///
		/// * `sql` - The SQL statement to execute.
		/// * `values` - A list of values to substitute into the SQL statement.
		/// * `callback` - A callback function that is invoked when the statement is executed, recieving the number of rows affected.
		public static void ExecAsync(string sql, DBParams values, Action<long> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopI64());
			});
			Native.db_exec_async(Bridge.FromString(sql), values.Raw, func_id0, stack_raw0);
		}
	}
} // namespace Dora
