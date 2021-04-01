/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

namespace SQLite {
class Database;
} // namespace SQLite

NS_DOROTHY_BEGIN

class Value;

class DB
{
public:
	virtual ~DB();
	bool exist(String tableName) const;
	bool transaction(const function<void()>& func);
	list<vector<Own<Value>>> query(String sql, const vector<Own<Value>>& args, bool withColumns = false);
	void insert(String tableName, const list<vector<Own<Value>>>& values);
	int exec(String sql);
	int exec(String sql, const vector<Own<Value>>& values);
	void queryAsync(String sql, vector<Own<Value>>&& args, bool withColumns, const function<void(const list<vector<Own<Value>>>& result)>& callback);
	void insertAsync(String tableName, list<vector<Own<Value>>>&& values, const function<void(bool)>& callback);
	void execAsync(String sql, vector<Own<Value>>&& values, const function<void(int)>& callback);
protected:
	DB();
private:
	Own<SQLite::Database> _database;
	SINGLETON_REF(DB, Application);
};

#define SharedDB \
	Dorothy::Singleton<Dorothy::DB>::shared()

NS_DOROTHY_END
