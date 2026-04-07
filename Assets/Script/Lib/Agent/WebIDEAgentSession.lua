-- [ts]: WebIDEAgentSession.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local setSessionState, TABLE_SESSION, now -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local ____CodingAgent = require("Agent.CodingAgent") -- 3
local runCodingAgent = ____CodingAgent.runCodingAgent -- 3
local truncateAgentUserPrompt = ____CodingAgent.truncateAgentUserPrompt -- 3
local Tools = require("Agent.Tools") -- 4
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
local safeJsonDecode = ____Utils.safeJsonDecode -- 5
local safeJsonEncode = ____Utils.safeJsonEncode -- 5
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 5
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 241
	DB:exec( -- 242
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 242
		{ -- 246
			status, -- 247
			currentTaskId or 0, -- 248
			currentTaskStatus or status, -- 249
			now(), -- 250
			sessionId -- 251
		} -- 251
	) -- 251
end -- 251
TABLE_SESSION = "AgentSession" -- 78
local TABLE_MESSAGE = "AgentSessionMessage" -- 79
local TABLE_STEP = "AgentSessionStep" -- 80
local TABLE_TASK = "AgentTask" -- 81
local AGENT_SESSION_SCHEMA_VERSION = 1 -- 82
local activeStopTokens = {} -- 84
now = function() return os.time() end -- 85
local function getDefaultUseChineseResponse() -- 87
	local zh = string.match(App.locale, "^zh") -- 88
	return zh ~= nil -- 89
end -- 87
local function toStr(v) -- 92
	if v == false or v == nil or v == nil then -- 92
		return "" -- 93
	end -- 93
	return tostring(v) -- 94
end -- 92
local function encodeJson(value) -- 97
	local text = safeJsonEncode(value) -- 98
	return text or "" -- 99
end -- 97
local function decodeJsonObject(text) -- 102
	if not text or text == "" then -- 102
		return nil -- 103
	end -- 103
	local value = safeJsonDecode(text) -- 104
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 104
		return value -- 106
	end -- 106
	return nil -- 108
end -- 102
local function decodeJsonFiles(text) -- 111
	if not text or text == "" then -- 111
		return nil -- 112
	end -- 112
	local value = safeJsonDecode(text) -- 113
	if not value or not __TS__ArrayIsArray(value) then -- 113
		return nil -- 114
	end -- 114
	local files = {} -- 115
	do -- 115
		local i = 0 -- 116
		while i < #value do -- 116
			do -- 116
				local item = value[i + 1] -- 117
				if type(item) ~= "table" then -- 117
					goto __continue14 -- 118
				end -- 118
				files[#files + 1] = { -- 119
					path = sanitizeUTF8(toStr(item.path)), -- 120
					op = sanitizeUTF8(toStr(item.op)) -- 121
				} -- 121
			end -- 121
			::__continue14:: -- 121
			i = i + 1 -- 116
		end -- 116
	end -- 116
	return files -- 124
end -- 111
local function queryRows(sql, args) -- 127
	local ____args_0 -- 128
	if args then -- 128
		____args_0 = DB:query(sql, args) -- 128
	else -- 128
		____args_0 = DB:query(sql) -- 128
	end -- 128
	return ____args_0 -- 128
end -- 127
local function queryOne(sql, args) -- 131
	local rows = queryRows(sql, args) -- 132
	if not rows or #rows == 0 then -- 132
		return nil -- 133
	end -- 133
	return rows[1] -- 134
end -- 131
local function getLastInsertRowId() -- 137
	local row = queryOne("SELECT last_insert_rowid()") -- 138
	return row and (row[1] or 0) or 0 -- 139
end -- 137
local function isValidProjectRoot(path) -- 142
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 143
end -- 142
local function rowToSession(row) -- 146
	return { -- 147
		id = row[1], -- 148
		projectRoot = toStr(row[2]), -- 149
		title = toStr(row[3]), -- 150
		status = toStr(row[4]), -- 151
		currentTaskId = type(row[5]) == "number" and row[5] > 0 and row[5] or nil, -- 152
		currentTaskStatus = toStr(row[6]), -- 153
		createdAt = row[7], -- 154
		updatedAt = row[8] -- 155
	} -- 155
end -- 146
local function rowToMessage(row) -- 159
	return { -- 160
		id = row[1], -- 161
		sessionId = row[2], -- 162
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 163
		role = toStr(row[4]), -- 164
		content = toStr(row[5]), -- 165
		createdAt = row[6], -- 166
		updatedAt = row[7] -- 167
	} -- 167
end -- 159
local function rowToStep(row) -- 171
	return { -- 172
		id = row[1], -- 173
		sessionId = row[2], -- 174
		taskId = row[3], -- 175
		step = row[4], -- 176
		tool = toStr(row[5]), -- 177
		status = toStr(row[6]), -- 178
		reason = toStr(row[7]), -- 179
		reasoningContent = toStr(row[8]), -- 180
		params = decodeJsonObject(toStr(row[9])), -- 181
		result = decodeJsonObject(toStr(row[10])), -- 182
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 183
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 184
		files = decodeJsonFiles(toStr(row[13])), -- 185
		createdAt = row[14], -- 186
		updatedAt = row[15] -- 187
	} -- 187
end -- 171
local function getSessionRow(sessionId) -- 191
	return queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 192
end -- 191
local function getSessionItem(sessionId) -- 200
	local row = getSessionRow(sessionId) -- 201
	return row and rowToSession(row) or nil -- 202
end -- 200
local function deleteSessionRecords(sessionId) -- 205
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 206
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 207
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 208
end -- 205
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 211
	if projectRoot == oldRoot then -- 211
		return newRoot -- 213
	end -- 213
	for ____, separator in ipairs({"/", "\\"}) do -- 215
		local prefix = oldRoot .. separator -- 216
		if __TS__StringStartsWith(projectRoot, prefix) then -- 216
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 218
		end -- 218
	end -- 218
	return nil -- 221
end -- 211
local function normalizeSessionRuntimeState(session) -- 224
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 224
		return session -- 226
	end -- 226
	if activeStopTokens[session.currentTaskId] then -- 226
		return session -- 229
	end -- 229
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 231
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 232
	return __TS__ObjectAssign( -- 233
		{}, -- 233
		session, -- 234
		{ -- 233
			status = "STOPPED", -- 235
			currentTaskStatus = "STOPPED", -- 236
			updatedAt = now() -- 237
		} -- 237
	) -- 237
end -- 224
local function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 256
	if taskId == nil or taskId <= 0 then -- 256
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 258
		return -- 259
	end -- 259
	local row = getSessionRow(sessionId) -- 261
	if not row then -- 261
		return -- 262
	end -- 262
	local session = rowToSession(row) -- 263
	if session.currentTaskId ~= taskId then -- 263
		Log( -- 265
			"Info", -- 265
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 265
		) -- 265
		return -- 266
	end -- 266
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 268
end -- 256
local function insertMessage(sessionId, role, content, taskId) -- 271
	local t = now() -- 272
	DB:exec( -- 273
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 273
		{ -- 276
			sessionId, -- 277
			taskId or 0, -- 278
			role, -- 279
			sanitizeUTF8(content), -- 280
			t, -- 281
			t -- 282
		} -- 282
	) -- 282
	return getLastInsertRowId() -- 285
end -- 271
local function updateMessage(messageId, content) -- 288
	DB:exec( -- 289
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 289
		{ -- 291
			sanitizeUTF8(content), -- 291
			now(), -- 291
			messageId -- 291
		} -- 291
	) -- 291
end -- 288
local function upsertStep(sessionId, taskId, step, tool, patch) -- 295
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 305
	local reason = sanitizeUTF8(patch.reason or "") -- 309
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 310
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 311
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 312
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 313
	local statusPatch = patch.status or "" -- 314
	local status = patch.status or "PENDING" -- 315
	if not row then -- 315
		local t = now() -- 317
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 318
			sessionId, -- 322
			taskId, -- 323
			step, -- 324
			tool, -- 325
			status, -- 326
			reason, -- 327
			reasoningContent, -- 328
			paramsJson, -- 329
			resultJson, -- 330
			patch.checkpointId or 0, -- 331
			patch.checkpointSeq or 0, -- 332
			filesJson, -- 333
			t, -- 334
			t -- 335
		}) -- 335
		return -- 338
	end -- 338
	DB:exec( -- 340
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 340
		{ -- 352
			tool, -- 353
			statusPatch, -- 354
			status, -- 355
			reason, -- 356
			reason, -- 357
			reasoningContent, -- 358
			reasoningContent, -- 359
			paramsJson, -- 360
			paramsJson, -- 361
			resultJson, -- 362
			resultJson, -- 363
			patch.checkpointId or 0, -- 364
			patch.checkpointId or 0, -- 365
			patch.checkpointSeq or 0, -- 366
			patch.checkpointSeq or 0, -- 367
			filesJson, -- 368
			filesJson, -- 369
			now(), -- 370
			row[1] -- 371
		} -- 371
	) -- 371
end -- 295
local function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 376
	if taskId <= 0 then -- 376
		return -- 377
	end -- 377
	if finalSteps ~= nil and finalSteps >= 0 then -- 377
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 379
	end -- 379
	if not finalStatus then -- 379
		return -- 385
	end -- 385
	if finalSteps ~= nil and finalSteps >= 0 then -- 385
		DB:exec( -- 387
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 387
			{ -- 391
				finalStatus, -- 391
				now(), -- 391
				sessionId, -- 391
				taskId, -- 391
				finalSteps -- 391
			} -- 391
		) -- 391
		return -- 393
	end -- 393
	DB:exec( -- 395
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 395
		{ -- 399
			finalStatus, -- 399
			now(), -- 399
			sessionId, -- 399
			taskId -- 399
		} -- 399
	) -- 399
end -- 376
local function sanitizeStoredSteps(sessionId) -- 403
	DB:exec( -- 404
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 404
		{ -- 422
			now(), -- 422
			sessionId -- 422
		} -- 422
	) -- 422
end -- 403
local function applyEvent(sessionId, event) -- 426
	repeat -- 426
		local ____switch51 = event.type -- 426
		local ____cond51 = ____switch51 == "task_started" -- 426
		if ____cond51 then -- 426
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 429
			break -- 430
		end -- 430
		____cond51 = ____cond51 or ____switch51 == "decision_made" -- 430
		if ____cond51 then -- 430
			upsertStep( -- 432
				sessionId, -- 432
				event.taskId, -- 432
				event.step, -- 432
				event.tool, -- 432
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 432
			) -- 432
			break -- 438
		end -- 438
		____cond51 = ____cond51 or ____switch51 == "tool_started" -- 438
		if ____cond51 then -- 438
			upsertStep( -- 440
				sessionId, -- 440
				event.taskId, -- 440
				event.step, -- 440
				event.tool, -- 440
				{status = "RUNNING"} -- 440
			) -- 440
			break -- 443
		end -- 443
		____cond51 = ____cond51 or ____switch51 == "tool_finished" -- 443
		if ____cond51 then -- 443
			upsertStep( -- 445
				sessionId, -- 445
				event.taskId, -- 445
				event.step, -- 445
				event.tool, -- 445
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 445
			) -- 445
			break -- 450
		end -- 450
		____cond51 = ____cond51 or ____switch51 == "checkpoint_created" -- 450
		if ____cond51 then -- 450
			upsertStep( -- 452
				sessionId, -- 452
				event.taskId, -- 452
				event.step, -- 452
				event.tool, -- 452
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 452
			) -- 452
			break -- 457
		end -- 457
		____cond51 = ____cond51 or ____switch51 == "memory_compression_started" -- 457
		if ____cond51 then -- 457
			upsertStep( -- 459
				sessionId, -- 459
				event.taskId, -- 459
				event.step, -- 459
				event.tool, -- 459
				{status = "RUNNING", reason = event.reason, params = event.params} -- 459
			) -- 459
			break -- 464
		end -- 464
		____cond51 = ____cond51 or ____switch51 == "memory_compression_finished" -- 464
		if ____cond51 then -- 464
			upsertStep( -- 466
				sessionId, -- 466
				event.taskId, -- 466
				event.step, -- 466
				event.tool, -- 466
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 466
			) -- 466
			break -- 471
		end -- 471
		____cond51 = ____cond51 or ____switch51 == "task_finished" -- 471
		if ____cond51 then -- 471
			do -- 471
				local ____opt_1 = activeStopTokens[event.taskId or -1] -- 471
				local stopped = (____opt_1 and ____opt_1.stopped) == true -- 473
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 474
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 477
				if event.taskId ~= nil then -- 477
					local ____finalizeTaskSteps_5 = finalizeTaskSteps -- 479
					local ____array_4 = __TS__SparseArrayNew( -- 479
						sessionId, -- 480
						event.taskId, -- 481
						type(event.steps) == "number" and math.max( -- 482
							0, -- 482
							math.floor(event.steps) -- 482
						) or nil -- 482
					) -- 482
					local ____event_success_3 -- 483
					if event.success then -- 483
						____event_success_3 = nil -- 483
					else -- 483
						____event_success_3 = stopped and "STOPPED" or "FAILED" -- 483
					end -- 483
					__TS__SparseArrayPush(____array_4, ____event_success_3) -- 483
					____finalizeTaskSteps_5(__TS__SparseArraySpread(____array_4)) -- 479
					local summaryRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\t\t\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\t\t\t\tORDER BY id DESC LIMIT 1", {sessionId, event.taskId, "assistant"}) -- 485
					if summaryRow and type(summaryRow[1]) == "number" then -- 485
						updateMessage(summaryRow[1], event.message) -- 492
					else -- 492
						insertMessage(sessionId, "assistant", event.message, event.taskId) -- 494
					end -- 494
					activeStopTokens[event.taskId] = nil -- 496
				end -- 496
				break -- 498
			end -- 498
		end -- 498
	until true -- 498
end -- 426
local function getSchemaVersion() -- 503
	local row = queryOne("PRAGMA user_version") -- 504
	return row and type(row[1]) == "number" and row[1] or 0 -- 505
end -- 503
local function setSchemaVersion(version) -- 508
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 509
		0, -- 509
		math.floor(version) -- 509
	))) -- 509
end -- 508
local function recreateSchema() -- 512
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 513
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 514
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 515
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 516
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 526
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 527
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 536
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 537
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 554
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 555
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 556
end -- 512
do -- 512
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 512
		recreateSchema() -- 562
	else -- 562
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 564
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 574
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 575
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 584
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 585
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 602
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 603
	end -- 603
end -- 603
function ____exports.createSession(projectRoot, title) -- 607
	if title == nil then -- 607
		title = "" -- 607
	end -- 607
	if not isValidProjectRoot(projectRoot) then -- 607
		return {success = false, message = "invalid projectRoot"} -- 609
	end -- 609
	local row = queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ?\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 611
	if row then -- 611
		return { -- 620
			success = true, -- 620
			session = rowToSession(row) -- 620
		} -- 620
	end -- 620
	local t = now() -- 622
	DB:exec( -- 623
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'IDLE', 'IDLE', ?, ?)", -- 623
		{ -- 626
			projectRoot, -- 626
			title ~= "" and title or Path:getFilename(projectRoot), -- 626
			t, -- 626
			t -- 626
		} -- 626
	) -- 626
	local session = getSessionItem(getLastInsertRowId()) -- 628
	if not session then -- 628
		return {success = false, message = "failed to create session"} -- 630
	end -- 630
	return {success = true, session = session} -- 632
end -- 607
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 635
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 635
		return {success = false, message = "invalid projectRoot"} -- 637
	end -- 637
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 639
	for ____, row in ipairs(rows) do -- 640
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 641
		if sessionId > 0 then -- 641
			deleteSessionRecords(sessionId) -- 643
		end -- 643
	end -- 643
	return {success = true, deleted = #rows} -- 646
end -- 635
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 649
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 649
		return {success = false, message = "invalid projectRoot"} -- 651
	end -- 651
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 653
	local renamed = 0 -- 654
	for ____, row in ipairs(rows) do -- 655
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 656
		local projectRoot = toStr(row[2]) -- 657
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 658
		if sessionId > 0 and nextProjectRoot then -- 658
			DB:exec( -- 660
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 660
				{ -- 662
					nextProjectRoot, -- 662
					Path:getFilename(nextProjectRoot), -- 662
					now(), -- 662
					sessionId -- 662
				} -- 662
			) -- 662
			renamed = renamed + 1 -- 664
		end -- 664
	end -- 664
	return {success = true, renamed = renamed} -- 667
end -- 649
function ____exports.getSession(sessionId) -- 670
	local session = getSessionItem(sessionId) -- 671
	if not session then -- 671
		return {success = false, message = "session not found"} -- 673
	end -- 673
	local normalizedSession = normalizeSessionRuntimeState(session) -- 675
	sanitizeStoredSteps(sessionId) -- 676
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 677
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 684
	return { -- 692
		success = true, -- 693
		session = normalizedSession, -- 694
		messages = __TS__ArrayMap( -- 695
			messages, -- 695
			function(____, row) return rowToMessage(row) end -- 695
		), -- 695
		steps = __TS__ArrayMap( -- 696
			steps, -- 696
			function(____, row) return rowToStep(row) end -- 696
		) -- 696
	} -- 696
end -- 670
function ____exports.sendPrompt(sessionId, prompt) -- 700
	local session = getSessionItem(sessionId) -- 701
	if not session then -- 701
		return {success = false, message = "session not found"} -- 703
	end -- 703
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 703
		return {success = false, message = "session task is still running"} -- 706
	end -- 706
	local normalizedPrompt = truncateAgentUserPrompt(prompt) -- 708
	local taskRes = Tools.createTask(normalizedPrompt) -- 709
	if not taskRes.success then -- 709
		return {success = false, message = taskRes.message} -- 711
	end -- 711
	local taskId = taskRes.taskId -- 713
	local useChineseResponse = getDefaultUseChineseResponse() -- 714
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 715
	local stopToken = {stopped = false} -- 716
	activeStopTokens[taskId] = stopToken -- 717
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 718
	runCodingAgent( -- 719
		{ -- 719
			prompt = normalizedPrompt, -- 720
			workDir = session.projectRoot, -- 721
			useChineseResponse = useChineseResponse, -- 722
			taskId = taskId, -- 723
			sessionId = sessionId, -- 724
			stopToken = stopToken, -- 725
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 726
		}, -- 726
		function(result) -- 727
			if not result.success then -- 727
				applyEvent(sessionId, { -- 729
					type = "task_finished", -- 730
					sessionId = sessionId, -- 731
					taskId = result.taskId, -- 732
					success = false, -- 733
					message = result.message, -- 734
					steps = result.steps -- 735
				}) -- 735
			end -- 735
		end -- 727
	) -- 727
	return {success = true, sessionId = sessionId, taskId = taskId} -- 739
end -- 700
function ____exports.stopSessionTask(sessionId) -- 742
	local session = getSessionItem(sessionId) -- 743
	if not session or session.currentTaskId == nil then -- 743
		return {success = false, message = "session task not found"} -- 745
	end -- 745
	local normalizedSession = normalizeSessionRuntimeState(session) -- 747
	local stopToken = activeStopTokens[session.currentTaskId] -- 748
	if not stopToken then -- 748
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 748
			return {success = true, recovered = true} -- 751
		end -- 751
		return {success = false, message = "task is not running"} -- 753
	end -- 753
	stopToken.stopped = true -- 755
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 756
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 757
	return {success = true} -- 758
end -- 742
function ____exports.getCurrentTaskId(sessionId) -- 761
	local ____opt_6 = getSessionItem(sessionId) -- 761
	return ____opt_6 and ____opt_6.currentTaskId -- 762
end -- 761
function ____exports.listRunningSessions() -- 765
	local rows = queryRows(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 766
	local sessions = {} -- 773
	do -- 773
		local i = 0 -- 774
		while i < #rows do -- 774
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 775
			if session.currentTaskStatus == "RUNNING" then -- 775
				sessions[#sessions + 1] = session -- 777
			end -- 777
			i = i + 1 -- 774
		end -- 774
	end -- 774
	return {success = true, sessions = sessions} -- 780
end -- 765
return ____exports -- 765