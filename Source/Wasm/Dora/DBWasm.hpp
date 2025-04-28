/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t db_exist_db(int64_t db_name) {
	return SharedDB.existDB(*Str_From(db_name)) ? 1 : 0;
}
int32_t db_exist(int64_t table_name) {
	return SharedDB.exist(*Str_From(table_name)) ? 1 : 0;
}
int32_t db_exist_schema(int64_t table_name, int64_t schema) {
	return SharedDB.exist(*Str_From(table_name), *Str_From(schema)) ? 1 : 0;
}
int32_t db_exec(int64_t sql) {
	return s_cast<int32_t>(SharedDB.exec(*Str_From(sql)));
}
int32_t db_transaction(int64_t query) {
	return DB_Transaction(*r_cast<DBQuery*>(query)) ? 1 : 0;
}
void db_transaction_async(int64_t query, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	DB_TransactionAsync(*r_cast<DBQuery*>(query), [func0, args0, deref0](bool result) {
		args0->clear();
		args0->push(result);
		SharedWasmRuntime.invoke(func0);
	});
}
int64_t db_query(int64_t sql, int32_t with_columns) {
	return r_cast<int64_t>(new DBRecord{DB_Query(*Str_From(sql), with_columns != 0)});
}
int64_t db_query_with_params(int64_t sql, int64_t params, int32_t with_columns) {
	return r_cast<int64_t>(new DBRecord{DB_QueryWithParams(*Str_From(sql), r_cast<Array*>(params), with_columns != 0)});
}
void db_insert(int64_t table_name, int64_t values) {
	DB_Insert(*Str_From(table_name), *r_cast<DBParams*>(values));
}
int32_t db_exec_with_records(int64_t sql, int64_t values) {
	return DB_ExecWithRecords(*Str_From(sql), *r_cast<DBParams*>(values));
}
void db_query_with_params_async(int64_t sql, int64_t params, int32_t with_columns, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	DB_QueryWithParamsAsync(*Str_From(sql), r_cast<Array*>(params), with_columns != 0, [func0, args0, deref0](DBRecord& result) {
		args0->clear();
		args0->push(r_cast<int64_t>(new DBRecord{std::move(result)}));
		SharedWasmRuntime.invoke(func0);
	});
}
void db_insert_async(int64_t table_name, int64_t values, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	DB_InsertAsync(*Str_From(table_name), *r_cast<DBParams*>(values), [func0, args0, deref0](bool result) {
		args0->clear();
		args0->push(result);
		SharedWasmRuntime.invoke(func0);
	});
}
void db_exec_async(int64_t sql, int64_t values, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	DB_ExecAsync(*Str_From(sql), *r_cast<DBParams*>(values), [func0, args0, deref0](int64_t rowChanges) {
		args0->clear();
		args0->push(rowChanges);
		SharedWasmRuntime.invoke(func0);
	});
}
} // extern "C"

static void linkDB(wasm3::module3& mod) {
	mod.link_optional("*", "db_exist_db", db_exist_db);
	mod.link_optional("*", "db_exist", db_exist);
	mod.link_optional("*", "db_exist_schema", db_exist_schema);
	mod.link_optional("*", "db_exec", db_exec);
	mod.link_optional("*", "db_transaction", db_transaction);
	mod.link_optional("*", "db_transaction_async", db_transaction_async);
	mod.link_optional("*", "db_query", db_query);
	mod.link_optional("*", "db_query_with_params", db_query_with_params);
	mod.link_optional("*", "db_insert", db_insert);
	mod.link_optional("*", "db_exec_with_records", db_exec_with_records);
	mod.link_optional("*", "db_query_with_params_async", db_query_with_params_async);
	mod.link_optional("*", "db_insert_async", db_insert_async);
	mod.link_optional("*", "db_exec_async", db_exec_async);
}