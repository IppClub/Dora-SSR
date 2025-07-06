/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <deque>

namespace SQLite {
class Database;
} // namespace SQLite

NS_DORA_BEGIN

class Value;
class Async;

class DB : public NonCopyable {
public:
	typedef std::variant<int64_t, double, std::string, bool> Col;
	typedef std::deque<std::vector<Col>> Rows;
	PROPERTY_READONLY(Async*, Thread);
	PROPERTY_READONLY(SQLite::Database*, Database);
	virtual ~DB();
	bool existDB(String name) const;
	bool exist(String tableName, String schema = Slice::Empty) const;
	int exec(String sql);
	int exec(String sql, const std::vector<Own<Value>>& args);
	int exec(String sql, const std::deque<std::vector<Own<Value>>>& rows);
	bool insert(String tableName, const std::deque<std::vector<Own<Value>>>& rows);
	std::optional<Rows> query(String sql, const std::vector<Own<Value>>& args, bool withColumns = false);
	void queryAsync(String sql, std::vector<Own<Value>>&& args, bool withColumns, const std::function<void(std::optional<Rows>& result)>& callback);
	void insertAsync(String tableName, std::deque<std::vector<Own<Value>>>&& rows, const std::function<void(bool)>& callback);
	void execAsync(String sql, std::vector<Own<Value>>&& args, const std::function<void(int)>& callback);
	void execAsync(String sql, std::deque<std::vector<Own<Value>>>&& rows, const std::function<void(int)>& callback);

	static Own<Value> col(const Col& c);

public:
	bool transaction(const std::function<void(SQLite::Database*)>& func);
	void transactionAsync(const std::function<void(SQLite::Database*)>& func, const std::function<void(bool)>& callback);
	static Rows queryUnsafe(SQLite::Database* db, String sql, const std::vector<Own<Value>>& args, bool withColumns = false);
	static bool transactionUnsafe(SQLite::Database* db, const std::function<void(SQLite::Database*)>& func);
	static void insertUnsafe(SQLite::Database* db, String tableName, const std::deque<std::vector<Own<Value>>>& values);
	static int execUnsafe(SQLite::Database* db, String sql);
	static int execUnsafe(SQLite::Database* db, String sql, const std::vector<Own<Value>>& args);
	static int execUnsafe(SQLite::Database* db, String sql, const std::deque<std::vector<Own<Value>>>& rows);
	static bool existDBUnsafe(SQLite::Database* db, String name);
	void stop();

protected:
	DB();

private:
	Own<SQLite::Database> _database;
	Async* _thread;
	SINGLETON_REF(DB, Application);
};

#define SharedDB \
	Dora::Singleton<Dora::DB>::shared()

NS_DORA_END
