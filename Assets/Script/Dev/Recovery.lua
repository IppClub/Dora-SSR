-- [yue]: Assets/Script/Dev/Recovery.yue
local _module_0 = { } -- 1
-- Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local _ENV = Dora -- 21
local require <const> = require -- 22
local DB <const> = DB -- 22
local tostring <const> = tostring -- 22
local Log <const> = Log -- 22
local Warn <const> = Warn -- 22

local Bootstrap = require("Script.Dev.Bootstrap") -- 24

local installMetadata -- 26
installMetadata = function() -- 26
	return DB:transaction({ -- 28
		[[CREATE TABLE IF NOT EXISTS DoraSchemaMeta(
			component TEXT PRIMARY KEY,
			version INTEGER NOT NULL
		)]], -- 28
		"INSERT OR REPLACE INTO DoraSchemaMeta(component, version) VALUES('main', " .. tostring(Bootstrap.currentVersion) .. ")" -- 32
	}) -- 27
end -- 26

local checkIntegrity -- 35
checkIntegrity = function() -- 35
	local result = DB:query("PRAGMA quick_check") -- 36
	return result and result[1] and result[1][1] == "ok" -- 37
end -- 35

local checkLegacySchema -- 39
checkLegacySchema = function() -- 39
	local tables = DB:query("SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'Config' LIMIT 1") -- 40
	if not tables then -- 41
		return false -- 41
	end -- 41
	if not tables[1] then -- 42
		return true -- 42
	end -- 42
	return DB:query("SELECT name, value_num, value_str, value_bool FROM Config LIMIT 0") -- 43
end -- 39

local migrate -- 45
migrate = function(status) -- 45
	if not checkIntegrity() then -- 46
		return false, "database integrity check failed" -- 46
	end -- 46
	local version = status.version or 0 -- 47
	while version < Bootstrap.currentVersion do -- 48
		if 0 == version then -- 50
			if not checkLegacySchema() then -- 51
				return false, "legacy Config schema is incompatible" -- 51
			end -- 51
			if not installMetadata() then -- 52
				return false, "failed to install database schema metadata" -- 52
			end -- 52
			version = 1 -- 53
		else -- 55
			return false, "no migration is available from database schema version " .. tostring(version) -- 55
		end -- 49
	end -- 48
	return true -- 56
end -- 45

local rebuild -- 58
rebuild = function() -- 58
	local ok, detail = DB:recover() -- 59
	if not ok then -- 60
		return false, detail -- 60
	end -- 60
	if not installMetadata() then -- 61
		return false, "database was rebuilt but schema metadata could not be initialized" -- 62
	end -- 61
	if not (detail == "") then -- 63
		Log("Dora database was rebuilt. Backup: " .. tostring(detail)) -- 63
	end -- 63
	return true -- 64
end -- 58

local recover -- 66
recover = function(status) -- 66
	if status.kind == "newer" then -- 67
		return false, "database schema version " .. tostring(status.version) .. " is newer than supported version " .. tostring(Bootstrap.currentVersion) -- 68
	end -- 67
	if status.kind == "metadata" or status.kind == "migration" then -- 69
		local ok, reason = migrate(status) -- 70
		if ok then -- 71
			return true -- 71
		end -- 71
		Warn("database migration failed: " .. tostring(reason) .. "; rebuilding the database") -- 72
	end -- 69
	return rebuild() -- 73
end -- 66
_module_0["recover"] = recover -- 66
return _module_0 -- 1
