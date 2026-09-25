-- [yue]: Assets/Script/init.yue
--[[ Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. ]]

local _ENV = Dora -- 9
local Content <const> = Content -- 10
local Path <const> = Path -- 10
local App <const> = App -- 10
local require <const> = require -- 10
local error <const> = error -- 10
local tostring <const> = tostring -- 10

Content.searchPaths = { -- 14
	Path(Content.assetPath, "Script"), -- 14
	Path(Content.assetPath, "Script", "Lib"), -- 15
	Path(Content.assetPath, "Script", "Lib", "Dora", App.locale:match("^zh") and "zh-Hans" or "en") -- 16
} -- 13

local bootstrap = require("Script.Dev.Bootstrap") -- 18
local status = bootstrap.check() -- 19
if not status.ok then -- 20
	local recovery = require("Script.Dev.Recovery") -- 21
	local ok, reason = recovery.recover(status) -- 22
	if not ok then -- 23
		error("failed to initialize Dora database: " .. tostring(reason)) -- 23
	end -- 23
	status = bootstrap.check() -- 24
	if not status.ok then -- 25
		error("failed to initialize Dora database after recovery") -- 25
	end -- 25
end -- 20

return require("Script.Dev.Entry") -- 27
