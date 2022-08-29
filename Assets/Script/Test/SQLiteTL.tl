local DB = require("DB")
local p = require("p")
local thread = require("thread")

local sqls: {DB.SQL} = {
	"DROP TABLE IF EXISTS test",
	"CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)",
	{
		"INSERT INTO test VALUES(?, ?)",
		{
			{false, "hello"},
			{false, "world"},
			{false, "ok"}
		}
	}
}

local result = DB:transaction(sqls)
print(result and "Success" or "Failure")
print(DB:exist("test"))

p(DB:query("SELECT * FROM test", true))

print("row changed:", DB:exec("DELETE FROM test WHERE id > 1"))
print("row changed:", DB:exec("UPDATE test SET value = ? WHERE id = 1", { "hello world!" }))

thread(function(): boolean
	print("insert async")
	local data = {}
	local _len_0 = 1
	for k in pairs(_G as {string: any}) do
		data[_len_0] = {false, k}
		_len_0 = _len_0 + 1
	end
	p(DB:insertAsync("test", data))
	print("query async...")
	local items = DB:queryAsync("SELECT value FROM test WHERE value NOT LIKE 'hello%' ORDER BY value ASC")
	local rows = {}
	local count = 1
	for i = 1, #items do
		local item = items[i]
		rows[count] = item[1]
		count = count + 1
	end
	p(rows)
end)

print("OK")
