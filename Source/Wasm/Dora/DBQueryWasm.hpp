static void dbquery_release(int64_t raw) {
	delete r_cast<DBQuery*>(raw);
}
static void dbquery_add_with_params(int64_t self, int64_t sql, int64_t record) {
	r_cast<DBQuery*>(self)->addWithParams(*str_from(sql), *r_cast<DBRecord*>(record));
}
static void dbquery_add(int64_t self, int64_t sql) {
	r_cast<DBQuery*>(self)->add(*str_from(sql));
}
static void linkDBQuery(wasm3::module& mod) {
	mod.link_optional("*", "dbquery_release", dbquery_release);
	mod.link_optional("*", "dbquery_add_with_params", dbquery_add_with_params);
	mod.link_optional("*", "dbquery_add", dbquery_add);
}