/* Copyright (c) 2022 Jin Li, dragon-fly@qq.com

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

void assertion_failed(const char* apFile, const long apLine, const char* apFunc, const char* apExpr, const char* apMsg) {
	auto msg = fmt::format("[Dorothy Error]\n[File] {},\n[Func] {}, [Line] {},\n[Condition] {},\n[Message] {}", apFile, apFunc, apLine, apExpr, apMsg);
	throw std::runtime_error(msg);
}

} // namespace SQLite
#endif // SQLITECPP_ENABLE_ASSERT_HANDLER

NS_DOROTHY_BEGIN

DB::DB() {
	auto dbFile = Path::concat({SharedContent.getWritablePath(), "dora.db"_slice});
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
			Dorothy::LogError(
				fmt::format("[Dorothy Error] failed to open database: {}\n", e.what()));
			std::abort();
		}
	}
}

DB::~DB() { }

bool DB::exist(String tableName) const {
	try {
		int result = 0;
		SQLite::Statement query(*_database,
			"SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?");
		query.bind(1, tableName);
		if (query.executeStep()) {
			result = query.getColumn(0);
		}
		return result == 0 ? false : true;
	} catch (std::exception& e) {
		Warn("failed to execute DB query: {}", e.what());
		return false;
	}
}

int DB::exec(String sql) {
	try {
		return execUnsafe(_database.get(), sql);
	} catch (std::exception& e) {
		Warn("failed to execute DB SQL: {}", e.what());
		return false;
	}
}

int DB::exec(String sql, const std::vector<Own<Value>>& args) {
	try {
		return execUnsafe(_database.get(), sql, args);
	} catch (std::exception& e) {
		Warn("failed to execute DB SQL: {}", e.what());
		return false;
	}
}

int DB::exec(String sql, const std::deque<std::vector<Own<Value>>>& rows) {
	int result = 0;
	transaction([&](SQLite::Database* db) {
		result = execUnsafe(db, sql, rows);
	});
	return result;
}

bool DB::insert(String tableName, const std::deque<std::vector<Own<Value>>>& rows) {
	return transaction([&](SQLite::Database* db) {
		insertUnsafe(db, tableName, rows);
	});
}

bool DB::transaction(const std::function<void(SQLite::Database*)>& sqls) {
	try {
		SQLite::Transaction transaction(*_database);
		sqls(_database.get());
		transaction.commit();
		return true;
	} catch (std::exception& e) {
		Warn("failed to execute DB transaction: {}", e.what());
		return false;
	}
}

static void bindValues(SQLite::Statement& query, const std::vector<Own<Value>>& args) {
	int argCount = 0;
	for (auto& arg : args) {
		if (auto v = arg->asVal<int>()) {
			query.bind(++argCount, *v);
		} else if (auto v = arg->asVal<double>()) {
			query.bind(++argCount, *v);
		} else if (auto v = arg->asVal<std::string>()) {
			query.bind(++argCount, *v);
		} else if (auto v = arg->asVal<uint32_t>()) {
			query.bind(++argCount, *v);
		} else if (auto v = arg->asVal<int64_t>()) {
			query.bind(++argCount, *v);
		} else if (arg->asVal<bool>() && *arg->asVal<bool>() == false) {
			query.bind(++argCount);
		} else
			throw std::runtime_error("unsupported argument type");
	}
}

std::deque<std::vector<Own<Value>>> DB::query(String sql, const std::vector<Own<Value>>& args, bool withColumns) {
	std::deque<std::vector<Own<Value>>> result;
	SQLite::Statement query(*_database, sql);
	bindValues(query, args);
	bool columnCollected = false;
	while (query.executeStep()) {
		int colCount = query.getColumnCount();
		if (!columnCollected && withColumns) {
			columnCollected = true;
			auto& values = result.emplace_back(colCount);
			for (int i = 0; i < colCount; i++) {
				values[i] = Value::alloc(std::string(query.getColumn(i).getName()));
			}
		}
		auto& values = result.emplace_back(colCount);
		for (int i = 0; i < colCount; i++) {
			auto col = query.getColumn(i);
			if (col.isInteger()) {
				values[i] = Value::alloc(s_cast<int64_t>(col.getInt64()));
			} else if (col.isFloat()) {
				values[i] = Value::alloc(s_cast<double>(col.getDouble()));
			} else if (col.isText() || col.isBlob()) {
				values[i] = Value::alloc(col.getString());
			} else if (col.isNull()) {
				values[i] = Value::alloc(false);
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
	SQLite::Statement query(*db, fmt::format("INSERT INTO {} VALUES ({})", tableName.toString(), valueHolder));
	for (const auto& row : rows) {
		bindValues(query, row);
		query.exec();
		query.reset();
	}
}

int DB::execUnsafe(SQLite::Database* db, String sql) {
	SQLite::Statement query(*db, sql);
	return query.exec();
}

int DB::execUnsafe(SQLite::Database* db, String sql, const std::vector<Own<Value>>& args) {
	SQLite::Statement query(*db, sql);
	bindValues(query, args);
	return query.exec();
}

int DB::execUnsafe(SQLite::Database* db, String sql, const std::deque<std::vector<Own<Value>>>& rows) {
	SQLite::Statement query(*db, sql);
	if (rows.empty()) {
		return query.exec();
	}
	int rowChanged = 0;
	for (const auto& row : rows) {
		bindValues(query, row);
		rowChanged += query.exec();
		query.reset();
	}
	return rowChanged;
}

void DB::queryAsync(String sql, std::vector<Own<Value>>&& args, bool withColumns, const std::function<void(std::deque<std::vector<Own<Value>>>&)>& callback) {
	std::string sqlStr(sql);
	auto argsPtr = std::make_shared<std::vector<Own<Value>>>(std::move(args));
	SharedAsyncThread.run(
		[sqlStr, argsPtr, withColumns]() {
			try {
				auto result = SharedDB.query(sqlStr, *argsPtr, withColumns);
				return Values::alloc(std::move(result));
			} catch (std::exception& e) {
				Warn("failed to execute DB query: {}", e.what());
				return Values::alloc(std::deque<std::vector<Own<Value>>>());
			}
		},
		[callback](Own<Values> values) {
			std::deque<std::vector<Own<Value>>> result;
			values->get(result);
			callback(result);
		});
}

void DB::insertAsync(String tableName, std::deque<std::vector<Own<Value>>>&& rows, const std::function<void(bool)>& callback) {
	std::string tableStr(tableName);
	auto rowsPtr = std::make_shared<std::deque<std::vector<Own<Value>>>>(std::move(rows));
	SharedAsyncThread.run(
		[tableStr, rowsPtr]() {
			bool result = SharedDB.transaction([&](SQLite::Database* db) {
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
	std::string sqlStr(sql);
	auto rowsPtr = std::make_shared<std::deque<std::vector<Own<Value>>>>(std::move(rows));
	SharedAsyncThread.run(
		[sqlStr, rowsPtr]() {
			int result = 0;
			SharedDB.transaction([&](SQLite::Database* db) {
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

NS_DOROTHY_END
