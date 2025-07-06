/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Database.h"

#include "Basic/Content.h"
#include "Common/Async.h"
#include "Common/Utils.h"
#include "Support/Value.h"

#include "SQLiteCpp/SQLiteCpp.h"

#ifdef SQLITECPP_ENABLE_ASSERT_HANDLER
namespace SQLite {

void assertion_failed(const char* apFile, const int apLine, const char* apFunc, const char* apExpr, const char* apMsg) {
	auto msg = fmt::format("[Dora Error]\n[File] {},\n[Func] {}, [Line] {},\n[Condition] {},\n[Message] {}", apFile, apFunc, apLine, apExpr, apMsg);
	throw std::runtime_error(msg);
}

} // namespace SQLite
#endif // SQLITECPP_ENABLE_ASSERT_HANDLER

NS_DORA_BEGIN

DB::DB()
	: _thread(SharedAsyncThread.newThread()) {
	auto dbFile = Path::concat({SharedContent.getAppPath(), "dora.db"_slice});
	try {
		_database = New<SQLite::Database>(dbFile,
			SQLite::OPEN_READWRITE | SQLite::OPEN_CREATE | SQLite::OPEN_NOMUTEX);
	} catch (std::exception&) {
		if (SharedContent.exist(dbFile)) {
			SharedContent.remove(dbFile);
		}
		try {
			_database = New<SQLite::Database>(dbFile,
				SQLite::OPEN_READWRITE | SQLite::OPEN_CREATE | SQLite::OPEN_NOMUTEX);
		} catch (std::exception& e) {
			Dora::LogError(
				fmt::format("[Dora Error] failed to open database: {}\n", e.what()));
			std::abort();
		}
	}
}

DB::~DB() { }

Async* DB::getThread() const noexcept {
	return _thread;
}

SQLite::Database* DB::getDatabase() const noexcept {
	return _database.get();
}

bool DB::existDBUnsafe(SQLite::Database* db, String name) {
	bool existed = false;
	if (!name.empty()) {
		try {
			SQLite::Statement statement(*db, fmt::format("SELECT EXISTS(SELECT 1 FROM pragma_database_list WHERE name = ?)", name.toString()));
			statement.bind(1, name.toString());
			int result = 0;
			if (statement.executeStep()) {
				result = statement.getColumn(0);
			}
			existed = result == 0 ? false : true;
		} catch (std::exception& e) {
			Warn("failed to execute DB query: {}", e.what());
		}
	}
	return existed;
}

bool DB::existDB(String name) const {
	bool existed = false;
	_thread->runInMainSync([&]() {
		existed = DB::existDBUnsafe(_database.get(), name);
	});
	return existed;
}

bool DB::exist(String tableName, String schema) const {
	bool existed = false;
	_thread->runInMainSync([&]() {
		if (!schema.empty() && !existDBUnsafe(_database.get(), schema)) {
			return;
		}
		try {
			SQLite::Statement statement(*_database, schema.empty() ? "SELECT EXISTS(SELECT 1 FROM sqlite_master WHERE type='table' AND name = ?)"s : fmt::format("SELECT EXISTS(SELECT 1 FROM {}.sqlite_master WHERE type='table' AND name = ?)", schema.toString()));
			statement.bind(1, tableName.toString());
			int result = 0;
			if (statement.executeStep()) {
				result = statement.getColumn(0);
			}
			existed = result == 0 ? false : true;
		} catch (std::exception& e) {
			Warn("failed to execute DB query: {}", e.what());
		}
	});
	return existed;
}

int DB::exec(String sql) {
	int rowChanged = -1;
	_thread->runInMainSync([&]() {
		try {
			rowChanged = execUnsafe(_database.get(), sql);
		} catch (std::exception& e) {
			Warn("failed to execute DB SQL: {}", e.what());
		}
	});
	return rowChanged;
}

int DB::exec(String sql, const std::vector<Own<Value>>& args) {
	int rowChanged = -1;
	_thread->runInMainSync([&]() {
		try {
			rowChanged = execUnsafe(_database.get(), sql, args);
		} catch (std::exception& e) {
			Warn("failed to execute DB SQL: {}", e.what());
		}
	});
	return rowChanged;
}

int DB::exec(String sql, const std::deque<std::vector<Own<Value>>>& rows) {
	int rowChanged = -1;
	_thread->runInMainSync([&]() {
		transactionUnsafe(_database.get(), [&](SQLite::Database* db) {
			rowChanged = execUnsafe(db, sql, rows);
		});
	});
	return rowChanged;
}

bool DB::insert(String tableName, const std::deque<std::vector<Own<Value>>>& rows) {
	bool success = false;
	_thread->runInMainSync([&]() {
		success = transactionUnsafe(_database.get(), [&](SQLite::Database* db) {
			insertUnsafe(db, tableName, rows);
		});
	});
	return success;
}

bool DB::transaction(const std::function<void(SQLite::Database*)>& sqls) {
	bool success = false;
	_thread->runInMainSync([&]() {
		success = transactionUnsafe(_database.get(), sqls);
	});
	return success;
}

bool DB::transactionUnsafe(SQLite::Database* db, const std::function<void(SQLite::Database*)>& sqls) {
	try {
		SQLite::Transaction transaction(*db);
		sqls(db);
		transaction.commit();
		return true;
	} catch (std::exception& e) {
		Warn("failed to execute DB transaction: {}", e.what());
	}
	return false;
}

void DB::transactionAsync(const std::function<void(SQLite::Database*)>& sqls, const std::function<void(bool)>& callback) {
	_thread->run(
		[sqls, this]() {
			try {
				SQLite::Transaction transaction(*_database);
				sqls(_database.get());
				transaction.commit();
				return Values::alloc(true);
			} catch (std::exception& e) {
				Warn("failed to execute DB transaction: {}", e.what());
				return Values::alloc(false);
			}
		},
		[callback](Own<Values> values) {
			bool result = false;
			values->get(result);
			callback(result);
		});
}

static void bindValues(SQLite::Statement& query, const std::vector<Own<Value>>& args) {
	int argCount = 0;
	for (auto& arg : args) {
		if (auto v = arg->asVal<int64_t>()) {
			query.bind(++argCount, *v);
		} else if (auto v = arg->asVal<double>()) {
			query.bind(++argCount, *v);
		} else if (auto v = arg->asVal<std::string>()) {
			query.bind(++argCount, *v);
		} else if (arg->asVal<bool>() && *arg->asVal<bool>() == false) {
			query.bind(++argCount);
		} else
			throw std::runtime_error("unsupported argument type");
	}
}

std::optional<DB::Rows> DB::query(String sql, const std::vector<Own<Value>>& args, bool withColumns) {
	std::optional<DB::Rows> result;
	_thread->runInMainSync([&]() {
		try {
			result = DB::queryUnsafe(_database.get(), sql, args, withColumns);
		} catch (std::exception& e) {
			Warn("failed to execute DB query: {}", e.what());
		}
	});
	return result;
}

DB::Rows DB::queryUnsafe(SQLite::Database* db, String sql, const std::vector<Own<Value>>& args, bool withColumns) {
	Rows result;
	SQLite::Statement statement(*db, sql.toString());
	bindValues(statement, args);
	bool columnCollected = false;
	while (statement.executeStep()) {
		int colCount = statement.getColumnCount();
		if (!columnCollected && withColumns) {
			columnCollected = true;
			auto& values = result.emplace_back(colCount);
			for (int i = 0; i < colCount; i++) {
				values[i] = std::string(statement.getColumn(i).getName());
			}
		}
		auto& values = result.emplace_back(colCount);
		for (int i = 0; i < colCount; i++) {
			auto col = statement.getColumn(i);
			if (col.isInteger()) {
				values[i] = col.getInt64();
			} else if (col.isFloat()) {
				values[i] = col.getDouble();
			} else if (col.isText() || col.isBlob()) {
				values[i] = std::string(col.getText());
			} else if (col.isNull()) {
				values[i] = false;
			}
		}
	}
	return result;
}

void DB::insertUnsafe(SQLite::Database* db, String tableName, const std::deque<std::vector<Own<Value>>>& rows) {
	if (rows.empty() || rows.front().empty()) return;
	std::string valueHolder;
	for (size_t i = 0; i < rows.front().size(); i++) {
		valueHolder += '?';
		if (i != rows.front().size() - 1) valueHolder += ',';
	}
	SQLite::Statement statement(*db, fmt::format("INSERT INTO {} VALUES ({})", tableName.toString(), valueHolder));
	for (const auto& row : rows) {
		statement.clearBindings();
		bindValues(statement, row);
		statement.exec();
		statement.reset();
	}
}

int DB::execUnsafe(SQLite::Database* db, String sql) {
	SQLite::Statement statement(*db, sql.toString());
	return statement.exec();
}

int DB::execUnsafe(SQLite::Database* db, String sql, const std::vector<Own<Value>>& args) {
	SQLite::Statement statement(*db, sql.toString());
	bindValues(statement, args);
	return statement.exec();
}

int DB::execUnsafe(SQLite::Database* db, String sql, const std::deque<std::vector<Own<Value>>>& rows) {
	SQLite::Statement statement(*db, sql.toString());
	if (rows.empty()) {
		return statement.exec();
	}
	int rowChanged = 0;
	for (const auto& row : rows) {
		statement.clearBindings();
		bindValues(statement, row);
		rowChanged += statement.exec();
		statement.reset();
	}
	return rowChanged;
}

void DB::queryAsync(String sql, std::vector<Own<Value>>&& args, bool withColumns, const std::function<void(std::optional<Rows>&)>& callback) {
	std::string sqlStr(sql.toString());
	auto argsPtr = std::make_shared<std::vector<Own<Value>>>(std::move(args));
	_thread->run(
		[sqlStr, argsPtr = std::move(argsPtr), withColumns, db = _database.get()]() {
			try {
				auto result = SharedDB.queryUnsafe(db, sqlStr, *argsPtr, withColumns);
				return Values::alloc(std::move(result));
			} catch (std::exception& e) {
				Warn("failed to execute DB query: {}", e.what());
				return Own<Values>{};
			}
		},
		[callback](Own<Values> values) {
			std::optional<Rows> opt;
			if (values) {
				Rows result;
				values->get(result);
				opt = std::move(result);
			}
			callback(opt);
		});
}

void DB::insertAsync(String tableName, std::deque<std::vector<Own<Value>>>&& rows, const std::function<void(bool)>& callback) {
	std::string tableStr(tableName.toString());
	auto rowsPtr = std::make_shared<std::deque<std::vector<Own<Value>>>>(std::move(rows));
	_thread->run(
		[tableStr, rowsPtr = std::move(rowsPtr), db = _database.get()]() {
			bool result = SharedDB.transactionUnsafe(db, [&](SQLite::Database* db) {
				DB::insertUnsafe(db, tableStr, *rowsPtr);
			});
			return Values::alloc(result);
		},
		[callback](Own<Values> values) {
			bool result = false;
			values->get(result);
			callback(result);
		});
}

void DB::execAsync(String sql, std::vector<Own<Value>>&& args, const std::function<void(int)>& callback) {
	std::deque<std::vector<Own<Value>>> rows;
	auto& row = rows.emplace_back();
	row = std::move(args);
	execAsync(sql, std::move(rows), callback);
}

void DB::execAsync(String sql, std::deque<std::vector<Own<Value>>>&& rows, const std::function<void(int)>& callback) {
	std::string sqlStr(sql.toString());
	auto rowsPtr = std::make_shared<std::deque<std::vector<Own<Value>>>>(std::move(rows));
	_thread->run(
		[sqlStr, rowsPtr = std::move(rowsPtr), database = _database.get()]() {
			int result = 0;
			SharedDB.transactionUnsafe(database, [&](SQLite::Database* db) {
				result += DB::execUnsafe(db, sqlStr, *rowsPtr);
			});
			return Values::alloc(result);
		},
		[callback](Own<Values> values) {
			int result = 0;
			values->get(result);
			callback(result);
		});
}

Own<Value> DB::col(const Col& c) {
	if (std::holds_alternative<int64_t>(c)) {
		return Value::alloc(std::get<int64_t>(c));
	} else if (std::holds_alternative<double>(c)) {
		return Value::alloc(std::get<double>(c));
	} else if (std::holds_alternative<std::string>(c)) {
		return Value::alloc(std::get<std::string>(c));
	} else {
		return Value::alloc(std::get<bool>(c));
	}
}

void DB::stop() {
	_thread->stop();
}

NS_DORA_END
