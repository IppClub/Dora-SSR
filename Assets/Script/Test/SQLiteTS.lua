-- [ts]: SQLiteTS.ts
local ____exports = {} -- 1
local ____dora = require("dora") -- 1
local DB = ____dora.DB -- 1
local thread = ____dora.thread -- 1
local sqls = {"DROP TABLE IF EXISTS test", "CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)", {"INSERT INTO test VALUES(?, ?)", {{false, "hello"}, {false, "world"}, {false, "ok"}}}} -- 3
local result = DB:transaction(sqls) -- 16
print(result and "Success" or "Failure") -- 17
print(DB:exist("test")) -- 18
p(DB:query("SELECT * FROM test", true)) -- 20
print( -- 22
    "row changed:", -- 22
    DB:exec("DELETE FROM test WHERE id > 1") -- 22
) -- 22
print( -- 23
    "row changed:", -- 23
    DB:exec("UPDATE test SET value = ? WHERE id = 1", {"hello world!"}) -- 23
) -- 23
thread(function() -- 25
    print("insert async") -- 26
    local data = {} -- 27
    for k in pairs(_G) do -- 28
        data[#data + 1] = {false, k} -- 29
    end -- 29
    p(DB:insertAsync("test", data)) -- 31
    print("query async...") -- 32
    local items = DB:queryAsync("SELECT value FROM test WHERE value NOT LIKE 'hello%' ORDER BY value ASC") -- 33
    local rows = {} -- 34
    do -- 34
        local i = 0 -- 35
        while i < #items do -- 35
            local item = items[i + 1] -- 36
            rows[#rows + 1] = item[1] -- 37
            i = i + 1 -- 35
        end -- 35
    end -- 35
    p(rows) -- 39
    return false -- 40
end) -- 25
print("OK") -- 43
return ____exports -- 43