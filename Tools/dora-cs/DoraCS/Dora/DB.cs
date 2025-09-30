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
		public static extern int32_t db_exist_db(int64_t dbName);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exist(int64_t tableName);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exist_schema(int64_t tableName, int64_t schema);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exec(int64_t sql);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_transaction(int64_t query);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_transaction_async(int64_t query, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t db_query(int64_t sql, int32_t withColumns);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t db_query_with_params(int64_t sql, int64_t params_, int32_t withColumns);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_insert(int64_t tableName, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t db_exec_with_records(int64_t sql, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_query_with_params_async(int64_t sql, int64_t params_, int32_t withColumns, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_insert_async(int64_t tableName, int64_t values, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void db_exec_async(int64_t sql, int64_t values, int32_t func0, int64_t stack0);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct that represents a database.
	/// </summary>
	public static partial class DB
	{
		/// <summary>
		/// Checks whether a database exists.
		/// </summary>
		/// <param name="dbName">The name of the database to check.</param>
		/// <returns>`true` if the database exists, `false` otherwise.</returns>
		public static bool ExistDb(string dbName)
		{
			return Native.db_exist_db(Bridge.FromString(dbName)) != 0;
		}
		/// <summary>
		/// Checks whether a table exists in the database.
		/// </summary>
		/// <param name="tableName">The name of the table to check.</param>
		/// <returns>`true` if the table exists, `false` otherwise.</returns>
		public static bool Exist(string tableName)
		{
			return Native.db_exist(Bridge.FromString(tableName)) != 0;
		}
		/// <summary>
		/// Checks whether a table exists in the database.
		/// </summary>
		/// <param name="tableName">The name of the table to check.</param>
		/// <param name="schema">Optional. The name of the schema to check in.</param>
		/// <returns>`true` if the table exists, `false` otherwise.</returns>
		public static bool ExistSchema(string tableName, string schema)
		{
			return Native.db_exist_schema(Bridge.FromString(tableName), Bridge.FromString(schema)) != 0;
		}
		/// <summary>
		/// Executes an SQL statement and returns the number of rows affected.
		/// </summary>
		/// <param name="sql">The SQL statement to execute.</param>
		/// <returns>The number of rows affected by the statement.</returns>
		public static int Exec(string sql)
		{
			return Native.db_exec(Bridge.FromString(sql));
		}
		/// <summary>
		/// Executes a list of SQL statements as a single transaction.
		/// </summary>
		/// <param name="query">A list of SQL statements to execute.</param>
		/// <returns>`true` if the transaction was successful, `false` otherwise.</returns>
		public static bool Transaction(DBQuery query)
		{
			return Native.db_transaction(query.Raw) != 0;
		}
		/// <summary>
		/// Executes a list of SQL statements as a single transaction asynchronously.
		/// </summary>
		/// <param name="query">A list of SQL statements to execute.</param>
		/// <param name="callback">A callback function that is invoked when the transaction is executed, receiving the result of the transaction.</param>
		/// <returns>`true` if the transaction was successful, `false` otherwise.</returns>
		public static void TransactionAsync(DBQuery query, System.Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopBool());
			});
			Native.db_transaction_async(query.Raw, func_id0, stack_raw0);
		}
		/// <summary>
		/// Executes an SQL query and returns the results as a list of rows.
		/// </summary>
		/// <param name="sql">The SQL statement to execute.</param>
		/// <param name="withColumns">Whether to include column names in the result.</param>
		/// <returns>A list of rows returned by the query.</returns>
		public static DBRecord Query(string sql, bool withColumns)
		{
			return DBRecord.From(Native.db_query(Bridge.FromString(sql), withColumns ? 1 : 0));
		}
		/// <summary>
		/// Executes an SQL query and returns the results as a list of rows.
		/// </summary>
		/// <param name="sql">The SQL statement to execute.</param>
		/// <param name="params_">A list of values to substitute into the SQL statement.</param>
		/// <param name="withColumns">Whether to include column names in the result.</param>
		/// <returns>A list of rows returned by the query.</returns>
		public static DBRecord Query(string sql, Array params_, bool withColumns)
		{
			return DBRecord.From(Native.db_query_with_params(Bridge.FromString(sql), params_.Raw, withColumns ? 1 : 0));
		}
		/// <summary>
		/// Inserts a row of data into a table within a transaction.
		/// </summary>
		/// <param name="tableName">The name of the table to insert into.</param>
		/// <param name="values">The values to insert into the table.</param>
		/// <returns>`true` if the insertion was successful, `false` otherwise.</returns>
		public static void Insert(string tableName, DBParams values)
		{
			Native.db_insert(Bridge.FromString(tableName), values.Raw);
		}
		/// <summary>
		/// Executes an SQL statement and returns the number of rows affected.
		/// </summary>
		/// <param name="sql">The SQL statement to execute.</param>
		/// <param name="values">Lists of values to substitute into the SQL statement.</param>
		/// <returns>The number of rows affected by the statement.</returns>
		public static int Exec(string sql, DBParams values)
		{
			return Native.db_exec_with_records(Bridge.FromString(sql), values.Raw);
		}
		/// <summary>
		/// Executes an SQL query asynchronously and returns the results as a list of rows.
		/// </summary>
		/// <param name="sql">The SQL statement to execute.</param>
		/// <param name="params_">Optional. A list of values to substitute into the SQL statement.</param>
		/// <param name="withColumns">Optional. Whether to include column names in the result. Default is `false`.</param>
		/// <param name="callback">A callback function that is invoked when the query is executed, receiving the results as a list of rows.</param>
		public static void QueryAsync(string sql, Array params_, bool withColumns, System.Action<DBRecord> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(DBRecord.From(stack0.PopI64()));
			});
			Native.db_query_with_params_async(Bridge.FromString(sql), params_.Raw, withColumns ? 1 : 0, func_id0, stack_raw0);
		}
		/// <summary>
		/// Inserts a row of data into a table within a transaction asynchronously.
		/// </summary>
		/// <param name="tableName">The name of the table to insert into.</param>
		/// <param name="values">The values to insert into the table.</param>
		/// <param name="callback">A callback function that is invoked when the insertion is executed, receiving the result of the insertion.</param>
		public static void InsertAsync(string tableName, DBParams values, System.Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopBool());
			});
			Native.db_insert_async(Bridge.FromString(tableName), values.Raw, func_id0, stack_raw0);
		}
		/// <summary>
		/// Executes an SQL statement with a list of values within a transaction asynchronously and returns the number of rows affected.
		/// </summary>
		/// <param name="sql">The SQL statement to execute.</param>
		/// <param name="values">A list of values to substitute into the SQL statement.</param>
		/// <param name="callback">A callback function that is invoked when the statement is executed, recieving the number of rows affected.</param>
		public static void ExecAsync(string sql, DBParams values, System.Action<long> callback)
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
