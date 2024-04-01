static int32_t db_exist(int64_t table_name) {
	return SharedDB.exist(*str_from(table_name)) ? 1 : 0;
}
static int32_t db_exist_schema(int64_t table_name, int64_t schema) {
	return SharedDB.exist(*str_from(table_name), *str_from(schema)) ? 1 : 0;
}
static int32_t db_exec(int64_t sql) {
	return s_cast<int32_t>(SharedDB.exec(*str_from(sql)));
}
static int32_t db_transaction(int64_t query) {
	return db_do_transaction(*r_cast<DBQuery*>(query)) ? 1 : 0;
}
static void db_transaction_async(int64_t query, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	db_do_transaction_async(*r_cast<DBQuery*>(query), [func, args, deref](bool result) {
		args->clear();
		args->push(result);
		SharedWasmRuntime.invoke(func);
	});
}
static int64_t db_query(int64_t sql, int32_t with_columns) {
	return r_cast<int64_t>(new DBRecord{db_do_query(*str_from(sql), with_columns != 0)});
}
static int64_t db_query_with_params(int64_t sql, int64_t params, int32_t with_columns) {
	return r_cast<int64_t>(new DBRecord{db_do_query_with_params(*str_from(sql), r_cast<Array*>(params), with_columns != 0)});
}
static void db_insert(int64_t table_name, int64_t values) {
	db_do_insert(*str_from(table_name), *r_cast<DBParams*>(values));
}
static int32_t db_exec_with_records(int64_t sql, int64_t values) {
	return db_do_exec_with_records(*str_from(sql), *r_cast<DBParams*>(values));
}
static void db_query_with_params_async(int64_t sql, int64_t params, int32_t with_columns, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	db_do_query_with_params_async(*str_from(sql), r_cast<Array*>(params), with_columns != 0, [func, args, deref](DBRecord& result) {
		args->clear();
		args->push(r_cast<int64_t>(new DBRecord{std::move(result)}));
		SharedWasmRuntime.invoke(func);
	});
}
static void db_insert_async(int64_t table_name, int64_t values, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	db_do_insert_async(*str_from(table_name), *r_cast<DBParams*>(values), [func, args, deref](bool result) {
		args->clear();
		args->push(result);
		SharedWasmRuntime.invoke(func);
	});
}
static void db_exec_async(int64_t sql, int64_t values, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	db_do_exec_async(*str_from(sql), *r_cast<DBParams*>(values), [func, args, deref](int64_t rowChanges) {
		args->clear();
		args->push(rowChanges);
		SharedWasmRuntime.invoke(func);
	});
}
static void linkDB(wasm3::module3& mod) {
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