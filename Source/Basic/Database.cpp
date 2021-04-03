/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Database.h"
#include "Basic/Content.h"
#include "Common/Utils.h"
#include "Support/Value.h"
#include "Common/Async.h"

#include "SQLiteCpp/SQLiteCpp.h"

#ifdef SQLITECPP_ENABLE_ASSERT_HANDLER
namespace SQLite {

void assertion_failed(const char* apFile, const long apLine, const char* apFunc, const char* apExpr, const char* apMsg)
{
	auto msg = fmt::format("[Dorothy Error]\n[File] {},\n[Func] {}, [Line] {},\n[Condition] {},\n[Message] {}", apFile, apFunc, apLine, apExpr, apMsg);
	throw std::runtime_error(msg);
}

} // namespace SQLite
#endif // SQLITECPP_ENABLE_ASSERT_HANDLER

NS_DOROTHY_BEGIN

DB::DB()
{
	auto dbFile = Path::concat({SharedContent.getWritablePath(), "dora.db"_slice});
	try
	{
		_database = New<SQLite::Database>(dbFile,
			SQLite::OPEN_READWRITE|SQLite::OPEN_CREATE);
	}
	catch (std::exception&)
	{
		if (SharedContent.exist(dbFile))
		{
			SharedContent.remove(dbFile);
		}
		try
		{
			_database = New<SQLite::Database>(dbFile,
				SQLite::OPEN_READWRITE|SQLite::OPEN_CREATE);
		}
		catch (std::exception& e)
		{
			Dorothy::LogError(
				fmt::format("[Dorothy Error] fail to open database: {}", e.what()));
			std::abort();
		}
	}
}

DB::~DB()
{ }

bool DB::exist(String tableName) const
{
	int result = 0;
	SQLite::Statement query(*_database,
			"SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?");
	query.bind(1, tableName);
	if (query.executeStep())
	{
		result = query.getColumn(0);
	}
	return result == 0 ? false : true;
}

bool DB::transaction(const function<void()>& sqls)
{
	try
	{
		SQLite::Transaction transaction(*_database);
		sqls();
		transaction.commit();
		return true;
	}
	catch (std::exception& e)
	{
		Error("fail to execute SQL transaction: {}", e.what());
		return false;
	}
}

static void bindValues(SQLite::Statement& query, const vector<Own<Value>>& args)
{
	int argCount = 0;
	for (auto& arg : args)
	{
		if (auto v = arg->as<int>())
		{
			query.bind(++argCount, *v);
		}
		else if (auto v = arg->as<double>())
		{
			query.bind(++argCount, *v);
		}
		else if (auto v = arg->as<string>())
		{
			query.bind(++argCount, *v);
		}
		else if (auto v = arg->as<unsigned>())
		{
			query.bind(++argCount, *v);
		}
		else if (auto v = arg->as<long long>())
		{
			query.bind(++argCount, *v);
		}
		else if (arg->as<bool>() && *arg->as<bool>() == false)
		{
			query.bind(++argCount);
		}
		else throw std::runtime_error("unsupported argument type");
	}
}

deque<vector<Own<Value>>> DB::query(String sql, const vector<Own<Value>>& args, bool withColumns)
{
	deque<vector<Own<Value>>> result;
	SQLite::Statement query(*_database, sql);
	bindValues(query, args);
	bool columnCollected = false;
	while (query.executeStep())
	{
		int colCount = query.getColumnCount();
		if (!columnCollected && withColumns)
		{
			columnCollected = true;
			auto& values = result.emplace_back(colCount);
			for (int i = 0; i < colCount; i++)
			{
				values[i] = Value::alloc(string(query.getColumn(i).getName()));
			}
		}
		auto& values = result.emplace_back(colCount);
		for (int i = 0; i < colCount; i++)
		{
			auto col = query.getColumn(i);
			if (col.isInteger())
			{
				values[i] = Value::alloc(col.getInt());
			}
			else if (col.isFloat())
			{
				values[i] = Value::alloc(col.getDouble());
			}
			else if (col.isText() || col.isBlob())
			{
				values[i] = Value::alloc(col.getString());
			}
			else if (col.isNull())
			{
				values[i] = Value::alloc(false);
			}
		}
	}
	return result;
}

void DB::insert(String tableName, const vector<vector<Own<Value>>>& values)
{
	if (values.empty() || values.front().empty()) return;
	string valueHolder;
	for (size_t i = 0; i < values.front().size(); i++)
	{
		valueHolder += '?';
		if (i != values.front().size() - 1) valueHolder += ',';
	}
	SQLite::Statement query(*_database, fmt::format("INSERT INTO {} VALUES ({})", tableName.toString(), valueHolder));
	for (const auto& row : values)
	{
		bindValues(query, row);
		query.exec();
		query.reset();
	}
}

int DB::exec(String sql)
{
	SQLite::Statement query(*_database, sql);
	return query.exec();
}

int DB::exec(String sql, const vector<Own<Value>>& values)
{
	SQLite::Statement query(*_database, sql);
	bindValues(query, values);
	return query.exec();
}

void DB::queryAsync(String sql, vector<Own<Value>>&& args, bool withColumns, const function<void(const deque<vector<Own<Value>>>&)>& callback)
{
	string sqlStr(sql);
	auto argsPtr = std::make_shared<vector<Own<Value>>>(std::move(args));
	SharedAsyncThread.run([sqlStr, argsPtr, withColumns]()
	{
		try
		{
			auto result = SharedDB.query(sqlStr, *argsPtr, withColumns);
			return Values::alloc(std::move(result));
		}
		catch (std::exception& e)
		{
			Error("fail to execute SQL transaction: {}", e.what());
			return Values::alloc(deque<vector<Own<Value>>>());
		}
	}, [callback](Own<Values> values)
	{
		deque<vector<Own<Value>>> result;
		values->get(result);
		callback(result);
	});
}

void DB::insertAsync(String tableName, vector<vector<Own<Value>>>&& values, const function<void(bool)>& callback)
{
	string tableStr(tableName);
	auto valuesPtr = std::make_shared<vector<vector<Own<Value>>>>(std::move(values));
	SharedAsyncThread.run([tableStr, valuesPtr]()
	{
		bool result = SharedDB.transaction([&]()
		{
			SharedDB.insert(tableStr, *valuesPtr);
		});
		return Values::alloc(result);
	}, [callback](Own<Values> values)
	{
		bool result = false;
		values->get(result);
		callback(result);
	});
}

void DB::execAsync(String sql, vector<Own<Value>>&& values, const function<void(int)>& callback)
{
	string sqlStr(sql);
	auto valuesPtr = std::make_shared<vector<Own<Value>>>(std::move(values));
	SharedAsyncThread.run([sqlStr, valuesPtr]()
	{
		int result = 0;
		try
		{
			result = SharedDB.exec(sqlStr, *valuesPtr);
		}
		catch (std::exception& e)
		{
			Error("fail to execute SQL transaction: {}", e.what());
		}
		return Values::alloc(result);
	}, [callback](Own<Values> values)
	{
		int result = 0;
		values->get(result);
		callback(result);
	});
}

NS_DOROTHY_END
