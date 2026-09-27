local scriptPath = string.gsub(arg[0] or "", "\\", "/")
local repoRoot = string.match(scriptPath, "^(.*)/Tools/build%-scripts/[^/]+$") or "."
local lualib = dofile(repoRoot .. "/Assets/Script/Lib/lualib_bundle.lua")

local trim = lualib.__TS__StringTrim
local trimStart = lualib.__TS__StringTrimStart
local trimEnd = lualib.__TS__StringTrimEnd
local nbsp = utf8.char(0x00A0)
local bom = utf8.char(0xFEFF)

local function expect(actual, expected, label)
	assert(actual == expected, label .. ": expected " .. string.format("%q", expected) .. ", got " .. string.format("%q", actual))
	assert(utf8.len(actual) ~= nil, label .. ": result is not valid UTF-8")
end

for _, name in ipairs({"你", "移", "丿", "残影 位移", "项目移"}) do
	expect(trim(name), name, "trim preserves " .. name)
	expect(trim(" \t" .. name .. "\r\n"), name, "trim ASCII whitespace around " .. name)
	expect(trimStart(" \t" .. name), name, "trimStart preserves " .. name)
	expect(trimEnd(name .. "\r\n"), name, "trimEnd preserves " .. name)
end

local leadingC2 = utf8.char(0x00A1) .. "name"
local leadingEF = utf8.char(0xF000) .. "name"
expect(trimStart(leadingC2), leadingC2, "trimStart preserves a non-whitespace C2 sequence")
expect(trimStart(leadingEF), leadingEF, "trimStart preserves a non-whitespace EF sequence")
expect(trim(" \t" .. nbsp .. bom .. "项目移" .. bom .. nbsp .. "\r\n"), "项目移", "trim mixed Unicode whitespace")
expect(trimStart(nbsp .. bom .. "项目移" .. nbsp), "项目移" .. nbsp, "trimStart only removes the prefix")
expect(trimEnd(nbsp .. "项目移" .. bom .. nbsp), nbsp .. "项目移", "trimEnd only removes the suffix")
expect(trim(" \t" .. nbsp .. bom .. "\r\n"), "", "trim all whitespace")
expect(trim(""), "", "trim empty string")

print("UTF-8 lualib trim regression tests passed.")
