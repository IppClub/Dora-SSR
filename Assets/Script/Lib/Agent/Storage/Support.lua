-- [ts]: Support.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local DB = ____Dora.DB -- 2
function ____exports.toStr(value) -- 6
	if value == false or value == nil then -- 6
		return "" -- 7
	end -- 7
	return tostring(value) -- 8
end -- 6
function ____exports.queryRows(sql, args) -- 11
	local ____args_0 -- 12
	if args then -- 12
		____args_0 = DB:query(sql, args) -- 12
	else -- 12
		____args_0 = DB:query(sql) -- 12
	end -- 12
	return ____args_0 -- 12
end -- 11
function ____exports.queryOne(sql, args) -- 15
	local rows = ____exports.queryRows(sql, args) -- 16
	if not rows or #rows == 0 then -- 16
		return nil -- 17
	end -- 17
	return rows[1] -- 18
end -- 15
function ____exports.getLastInsertRowId() -- 21
	local row = ____exports.queryOne("SELECT last_insert_rowid()") -- 22
	return row and (row[1] or 0) or 0 -- 23
end -- 21
return ____exports -- 21