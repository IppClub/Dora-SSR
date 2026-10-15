-- [yue]: Assets/Script/Dev/Bootstrap.yue
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
local DB <const> = DB -- 22
local type <const> = type -- 22

local currentVersion = 1 -- 24
_module_0["currentVersion"] = currentVersion -- 24

local check -- 26
check = function() -- 26
	if not DB:isReady() then -- 27
		return { -- 29
			ok = false, -- 29
			kind = "open", -- 30
			error = DB:getOpenError() -- 31
		} -- 28
	end -- 27
	local rows = DB:query("SELECT version FROM DoraSchemaMeta WHERE component = 'main' LIMIT 1") -- 33
	local version = rows and rows[1] and rows[1][1] -- 34
	if not (type(version) == "number") then -- 35
		return { -- 37
			ok = false, -- 37
			kind = "metadata" -- 38
		} -- 36
	end -- 35
	if version > currentVersion then -- 40
		return { -- 42
			ok = false, -- 42
			kind = "newer", -- 43
			version = version -- 44
		} -- 41
	end -- 40
	if not (version == currentVersion) then -- 46
		return { -- 48
			ok = false, -- 48
			kind = "migration", -- 49
			version = version -- 50
		} -- 47
	end -- 46
	return { -- 53
		ok = true, -- 53
		version = version -- 54
	} -- 52
end -- 26
_module_0["check"] = check -- 26
return _module_0 -- 1
