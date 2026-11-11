-- [ts]: InputInbox.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local DB = ____Dora.DB -- 1
local ____Utils = require("Agent.Utils") -- 2
local safeJsonDecode = ____Utils.safeJsonDecode -- 2
local safeJsonEncode = ____Utils.safeJsonEncode -- 2
local ____Support = require("Agent.Storage.Support") -- 3
local queryRows = ____Support.queryRows -- 3
local toStr = ____Support.toStr -- 3
local getLastInsertRowId = ____Support.getLastInsertRowId -- 3
local ____table = "agent.AgentSessionInput" -- 21
local function checkedExec(sql, values) -- 22
	local changed = DB:exec(sql, values) -- 23
	if changed < 0 then -- 23
		error( -- 24
			__TS__New(Error, "failed to persist Agent input queue"), -- 24
			0 -- 24
		) -- 24
	end -- 24
	return changed -- 25
end -- 22
local function decode(row) -- 27
	local options = safeJsonDecode(toStr(row[7])) -- 28
	return { -- 29
		id = row[1], -- 29
		content = toStr(row[2]), -- 29
		delivery = row[3] == "steer" and "steer" or "queue", -- 29
		status = toStr(row[4]), -- 30
		held = row[5] == 1, -- 30
		taskId = type(row[6]) == "number" and row[6] or nil, -- 30
		options = options and type(options) == "table" and options or ({}) -- 31
	} -- 31
end -- 27
function ____exports.listInputs(sessionId, includeDelivered) -- 33
	if includeDelivered == nil then -- 33
		includeDelivered = false -- 33
	end -- 33
	return __TS__ArrayMap( -- 34
		queryRows(((("SELECT id, content, delivery, status, held, task_id, options_json FROM " .. ____table) .. "\n\t\tWHERE session_id = ? AND status IN (") .. (includeDelivered and "'pending','delivering','editing','delivered'" or "'pending','delivering','editing'")) .. ") ORDER BY position, id", {sessionId}) or ({}), -- 34
		function(____, row) return decode(row) end -- 35
	) -- 35
end -- 33
function ____exports.getInput(sessionId, id) -- 37
	local rows = queryRows(("SELECT id, content, delivery, status, held, task_id, options_json FROM " .. ____table) .. " WHERE session_id=? AND id=?", {sessionId, id}) -- 38
	return rows and #rows > 0 and decode(rows[1]) or nil -- 39
end -- 37
function ____exports.admitInput(sessionId, content, delivery, requestId, options, taskId) -- 41
	local existing = queryRows(("SELECT id, content, delivery, status, held, task_id, options_json FROM " .. ____table) .. " WHERE session_id=? AND request_id=?", {sessionId, requestId}) -- 42
	if existing and #existing > 0 then -- 42
		local item = decode(existing[1]) -- 44
		local ____item_options_submittedContent_0 = item.options.submittedContent -- 45
		if ____item_options_submittedContent_0 == nil then -- 45
			____item_options_submittedContent_0 = item.content -- 45
		end -- 45
		if ____item_options_submittedContent_0 ~= content then -- 45
			error( -- 45
				__TS__New(Error, "input request ID was reused with different content"), -- 45
				0 -- 45
			) -- 45
		end -- 45
		return item -- 46
	end -- 46
	if #____exports.listInputs(sessionId) >= 50 then -- 46
		error( -- 48
			__TS__New(Error, "message queue is full (50); remove an entry first"), -- 48
			0 -- 48
		) -- 48
	end -- 48
	local encoded = safeJsonEncode(__TS__ObjectAssign({}, options, {submittedContent = content})) -- 49
	if not encoded or checkedExec(((("INSERT INTO " .. ____table) .. "(session_id,request_id,content,delivery,status,held,task_id,options_json,position)\n\t\tVALUES(?,?,?,?, 'pending',0,?,?,COALESCE((SELECT MAX(position)+1 FROM ") .. ____table) .. " WHERE session_id=?),1))", { -- 49
		sessionId, -- 52
		requestId, -- 52
		content, -- 52
		delivery, -- 52
		taskId or false, -- 52
		encoded, -- 52
		sessionId -- 52
	}) < 0 then -- 52
		error( -- 52
			__TS__New(Error, "failed to save pending input"), -- 52
			0 -- 52
		) -- 52
	end -- 52
	local item = ____exports.getInput( -- 53
		sessionId, -- 53
		getLastInsertRowId() -- 53
	) -- 53
	if not item then -- 53
		error( -- 54
			__TS__New(Error, "failed to read saved input"), -- 54
			0 -- 54
		) -- 54
	end -- 54
	return item -- 55
end -- 41
function ____exports.markDelivering(id, taskId) -- 57
	if checkedExec(("UPDATE " .. ____table) .. " SET status='delivering', task_id=? WHERE id=? AND status IN ('pending','delivering')", {taskId, id}) < 0 then -- 57
		error( -- 58
			__TS__New(Error, "failed to reserve input"), -- 58
			0 -- 58
		) -- 58
	end -- 58
end -- 57
function ____exports.markDelivered(id, messageId, step) -- 60
	if step == nil then -- 60
		step = 0 -- 60
	end -- 60
	if checkedExec(("UPDATE " .. ____table) .. " SET status='delivered',message_id=COALESCE(?,message_id),delivered_step=? WHERE id=?", {messageId or false, step, id}) < 0 then -- 60
		error( -- 61
			__TS__New(Error, "failed to commit input delivery"), -- 61
			0 -- 61
		) -- 61
	end -- 61
end -- 60
function ____exports.holdInputs(sessionId) -- 63
	checkedExec(("UPDATE " .. ____table) .. " SET held=1, delivery='queue' WHERE session_id=? AND status IN ('pending','delivering','editing')", {sessionId}) -- 64
end -- 63
function ____exports.recoverInputs(sessionId) -- 66
	checkedExec(("UPDATE " .. ____table) .. " SET status='pending',held=1,delivery='queue' WHERE session_id=? AND status IN ('delivering','editing')", {sessionId}) -- 67
	____exports.holdInputs(sessionId) -- 68
end -- 66
function ____exports.mutateInput(sessionId, command, content) -- 70
	if command.action == "resume" then -- 70
		checkedExec(("UPDATE " .. ____table) .. " SET held=0 WHERE session_id=? AND status='pending'", {sessionId}) -- 72
		return -- 73
	end -- 73
	local item = ____exports.getInput(sessionId, command.inputId or 0) -- 75
	if not item or item.status ~= "pending" and item.status ~= "editing" then -- 75
		error( -- 76
			__TS__New(Error, "input was already delivered or removed; refresh the queue"), -- 76
			0 -- 76
		) -- 76
	end -- 76
	if command.action == "hold" or command.action == "release" then -- 76
		checkedExec(("UPDATE " .. ____table) .. " SET status=? WHERE id=?", {command.action == "hold" and "editing" or "pending", item.id}) -- 77
	elseif command.action == "cancel" then -- 77
		checkedExec(("UPDATE " .. ____table) .. " SET status='cancelled' WHERE id=?", {item.id}) -- 78
	elseif command.action == "edit" then -- 78
		if __TS__StringTrim(content) == "" then -- 78
			error( -- 80
				__TS__New(Error, "prompt is empty"), -- 80
				0 -- 80
			) -- 80
		end -- 80
		checkedExec(("UPDATE " .. ____table) .. " SET content=? WHERE id=?", {content, item.id}) -- 81
	elseif item.status == "editing" then -- 81
		error( -- 82
			__TS__New(Error, "message is being edited; finish or release the edit first"), -- 82
			0 -- 82
		) -- 82
	elseif command.action == "steer" then -- 82
		checkedExec(("UPDATE " .. ____table) .. " SET delivery='steer',held=0 WHERE id=?", {item.id}) -- 83
	else -- 83
		error( -- 84
			__TS__New(Error, "invalid input action"), -- 84
			0 -- 84
		) -- 84
	end -- 84
end -- 70
return ____exports -- 70