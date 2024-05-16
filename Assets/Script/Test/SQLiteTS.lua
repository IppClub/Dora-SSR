-- [ts]: SQLiteTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local DB = ____Dora.DB -- 4
local Vec2 = ____Dora.Vec2 -- 4
local thread = ____Dora.thread -- 4
local threadLoop = ____Dora.threadLoop -- 4
local sqls = {"DROP TABLE IF EXISTS test", "CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)", {"INSERT INTO test VALUES(?, ?)", {{false, "hello"}, {false, "world"}, {false, "ok"}}}} -- 6
local result = DB:transaction(sqls) -- 19
print(result and "Success" or "Failure") -- 20
print(DB:exist("test")) -- 21
p(DB:query("SELECT * FROM test", true)) -- 23
print( -- 25
    "row changed:", -- 25
    DB:exec("DELETE FROM test WHERE id > 1") -- 25
) -- 25
print( -- 26
    "row changed:", -- 26
    DB:exec("UPDATE test SET value = ? WHERE id = 1", {"hello world!"}) -- 26
) -- 26
thread(function() -- 28
    print("insert async") -- 29
    local data = {} -- 30
    for k in pairs(_G) do -- 31
        data[#data + 1] = {false, k} -- 32
    end -- 32
    p(DB:insertAsync("test", data)) -- 34
    print("query async...") -- 35
    local items = DB:queryAsync("SELECT value FROM test WHERE value NOT LIKE 'hello%' ORDER BY value ASC") -- 36
    local rows = {} -- 37
    do -- 37
        local i = 0 -- 38
        while i < #items do -- 38
            local item = items[i + 1] -- 39
            rows[#rows + 1] = item[1] -- 40
            i = i + 1 -- 38
        end -- 38
    end -- 38
    p(rows) -- 42
    return false -- 43
end) -- 28
print("OK") -- 46
local windowFlags = { -- 48
    "NoDecoration", -- 49
    "AlwaysAutoResize", -- 50
    "NoSavedSettings", -- 51
    "NoFocusOnAppearing", -- 52
    "NoNav", -- 53
    "NoMove" -- 54
} -- 54
threadLoop(function() -- 56
    local size = App.visualSize -- 57
    ImGui.SetNextWindowBgAlpha(0.35) -- 58
    ImGui.SetNextWindowPos( -- 59
        Vec2(size.width - 10, 10), -- 59
        "Always", -- 59
        Vec2(1, 0) -- 59
    ) -- 59
    ImGui.SetNextWindowSize( -- 60
        Vec2(240, 0), -- 60
        "FirstUseEver" -- 60
    ) -- 60
    ImGui.Begin( -- 61
        "SQLite", -- 61
        windowFlags, -- 61
        function() -- 61
            ImGui.Text("SQLite (Typescript)") -- 62
            ImGui.Separator() -- 63
            ImGui.TextWrapped("Doing database operations in synchronous and asynchronous ways") -- 64
        end -- 61
    ) -- 61
    return false -- 66
end) -- 56
return ____exports -- 56