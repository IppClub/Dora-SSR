/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

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
#include "miniz.h"
#include "sqlite3.h"

#include <array>

#ifdef SQLITECPP_ENABLE_ASSERT_HANDLER
namespace SQLite {

void assertion_failed(const char* apFile, const int apLine, const char* apFunc, const char* apExpr, const char* apMsg) {
	auto msg = fmt::format("[Dora Error]\n[File] {},\n[Func] {}, [Line] {},\n[Condition] {},\n[Message] {}", apFile, apFunc, apLine, apExpr, apMsg);
	throw std::runtime_error(msg);
}

} // namespace SQLite
#endif // SQLITECPP_ENABLE_ASSERT_HANDLER

NS_DORA_BEGIN

namespace {

constexpr size_t TextCompressThreshold = 512;
constexpr size_t TextInflateChunkSize = 64 * 1024;
constexpr uint64_t TextMaxRawSize = 256ull * 1024ull * 1024ull;

void compressText(sqlite3_context* context, int argc, sqlite3_value** argv) {
	if (argc != 1 || sqlite3_value_type(argv[0]) == SQLITE_NULL) {
		sqlite3_result_null(context);
		return;
	}
	if (sqlite3_value_type(argv[0]) != SQLITE_TEXT) {
		sqlite3_result_error(context, "dora_compress_text expects TEXT", -1);
		return;
	}
	const auto* source = static_cast<const uint8_t*>(sqlite3_value_text(argv[0]));
	const int sourceSizeValue = sqlite3_value_bytes(argv[0]);
	if (sourceSizeValue < 0) {
		sqlite3_result_error(context, "invalid text length", -1);
		return;
	}
	const size_t sourceSize = static_cast<size_t>(sourceSizeValue);
	if (sourceSize > TextMaxRawSize) {
		sqlite3_result_error(context, "text exceeds compression limit", -1);
		return;
	}

	if (sourceSize < TextCompressThreshold) {
		sqlite3_result_text64(
			context,
			reinterpret_cast<const char*>(source),
			sourceSize,
			SQLITE_TRANSIENT,
			SQLITE_UTF8);
		return;
	}

	mz_ulong compressedSize = mz_compressBound(static_cast<mz_ulong>(sourceSize));
	std::vector<uint8_t> compressed(static_cast<size_t>(compressedSize));
	const int result = mz_compress2(
		compressed.data(),
		&compressedSize,
		source,
		static_cast<mz_ulong>(sourceSize),
		MZ_BEST_SPEED);
	if (result != MZ_OK) {
		sqlite3_result_error(context, "failed to compress text", -1);
		return;
	}
	compressed.resize(static_cast<size_t>(compressedSize));
	if (compressed.size() >= sourceSize) {
		sqlite3_result_text64(
			context,
			reinterpret_cast<const char*>(source),
			sourceSize,
			SQLITE_TRANSIENT,
			SQLITE_UTF8);
		return;
	}
	sqlite3_result_blob64(context, compressed.data(), compressed.size(), SQLITE_TRANSIENT);
}

void decompressText(sqlite3_context* context, int argc, sqlite3_value** argv) {
	if (argc != 1 || sqlite3_value_type(argv[0]) == SQLITE_NULL) {
		sqlite3_result_null(context);
		return;
	}
	const int valueType = sqlite3_value_type(argv[0]);
	if (valueType == SQLITE_TEXT) {
		sqlite3_result_value(context, argv[0]);
		return;
	}
	if (valueType != SQLITE_BLOB) {
		sqlite3_result_error(context, "dora_decompress_text expects TEXT or BLOB", -1);
		return;
	}

	const auto* source = static_cast<const uint8_t*>(sqlite3_value_blob(argv[0]));
	const int sourceSizeValue = sqlite3_value_bytes(argv[0]);
	if (!source || sourceSizeValue <= 0) {
		sqlite3_result_error(context, "invalid compressed text", -1);
		return;
	}
	const size_t sourceSize = static_cast<size_t>(sourceSizeValue);

	mz_stream stream{};
	stream.next_in = source;
	stream.avail_in = static_cast<unsigned int>(sourceSize);
	if (mz_inflateInit(&stream) != MZ_OK) {
		sqlite3_result_error(context, "failed to initialize text decompression", -1);
		return;
	}

	std::vector<uint8_t> output;
	std::array<uint8_t, TextInflateChunkSize> chunk;
	for (;;) {
		stream.next_out = chunk.data();
		stream.avail_out = static_cast<unsigned int>(chunk.size());
		const int result = mz_inflate(&stream, stream.avail_in == 0 ? MZ_FINISH : MZ_NO_FLUSH);
		const size_t produced = chunk.size() - stream.avail_out;
		if (produced > TextMaxRawSize - output.size()) {
			mz_inflateEnd(&stream);
			sqlite3_result_error(context, "text exceeds decompression limit", -1);
			return;
		}
		output.insert(output.end(), chunk.begin(), chunk.begin() + produced);
		if (result == MZ_STREAM_END) {
			const bool fullyConsumed = stream.avail_in == 0;
			mz_inflateEnd(&stream);
			if (!fullyConsumed) {
				sqlite3_result_error(context, "compressed text contains trailing data", -1);
				return;
			}
			break;
		}
		if (result != MZ_OK || (produced == 0 && stream.avail_in == 0)) {
			mz_inflateEnd(&stream);
			sqlite3_result_error(context, "corrupt compressed text", -1);
			return;
		}
	}

	sqlite3_result_text64(
		context,
		output.empty() ? "" : reinterpret_cast<const char*>(output.data()),
		output.size(),
		SQLITE_TRANSIENT,
		SQLITE_UTF8);
}

void registerTextCodecs(SQLite::Database& database) {
	database.createFunction("dora_compress_text", 1, true, nullptr, compressText);
	database.createFunction("dora_decompress_text", 1, true, nullptr, decompressText);
}

} // namespace

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
	registerTextCodecs(*_database);
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
				values[i] = col.getString();
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
