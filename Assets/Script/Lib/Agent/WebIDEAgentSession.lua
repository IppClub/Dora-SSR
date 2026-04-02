-- [ts]: WebIDEAgentSession.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
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
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 222
	DB:exec( -- 223
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 223
		{ -- 227
			status, -- 228
			currentTaskId or 0, -- 229
			currentTaskStatus or status, -- 230
			now(), -- 231
			sessionId -- 232
		} -- 232
	) -- 232
end -- 232
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
local function normalizeSessionRuntimeState(session) -- 205
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 205
		return session -- 207
	end -- 207
	if activeStopTokens[session.currentTaskId] then -- 207
		return session -- 210
	end -- 210
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 212
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 213
	return __TS__ObjectAssign( -- 214
		{}, -- 214
		session, -- 215
		{ -- 214
			status = "STOPPED", -- 216
			currentTaskStatus = "STOPPED", -- 217
			updatedAt = now() -- 218
		} -- 218
	) -- 218
end -- 205
local function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 237
	if taskId == nil or taskId <= 0 then -- 237
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 239
		return -- 240
	end -- 240
	local row = getSessionRow(sessionId) -- 242
	if not row then -- 242
		return -- 243
	end -- 243
	local session = rowToSession(row) -- 244
	if session.currentTaskId ~= taskId then -- 244
		Log( -- 246
			"Info", -- 246
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 246
		) -- 246
		return -- 247
	end -- 247
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 249
end -- 237
local function insertMessage(sessionId, role, content, taskId) -- 252
	local t = now() -- 253
	DB:exec( -- 254
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 254
		{ -- 257
			sessionId, -- 258
			taskId or 0, -- 259
			role, -- 260
			sanitizeUTF8(content), -- 261
			t, -- 262
			t -- 263
		} -- 263
	) -- 263
	return getLastInsertRowId() -- 266
end -- 252
local function updateMessage(messageId, content) -- 269
	DB:exec( -- 270
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 270
		{ -- 272
			sanitizeUTF8(content), -- 272
			now(), -- 272
			messageId -- 272
		} -- 272
	) -- 272
end -- 269
local function upsertStep(sessionId, taskId, step, tool, patch) -- 276
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 286
	local reason = sanitizeUTF8(patch.reason or "") -- 290
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 291
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 292
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 293
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 294
	local statusPatch = patch.status or "" -- 295
	local status = patch.status or "PENDING" -- 296
	if not row then -- 296
		local t = now() -- 298
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 299
			sessionId, -- 303
			taskId, -- 304
			step, -- 305
			tool, -- 306
			status, -- 307
			reason, -- 308
			reasoningContent, -- 309
			paramsJson, -- 310
			resultJson, -- 311
			patch.checkpointId or 0, -- 312
			patch.checkpointSeq or 0, -- 313
			filesJson, -- 314
			t, -- 315
			t -- 316
		}) -- 316
		return -- 319
	end -- 319
	DB:exec( -- 321
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 321
		{ -- 333
			tool, -- 334
			statusPatch, -- 335
			status, -- 336
			reason, -- 337
			reason, -- 338
			reasoningContent, -- 339
			reasoningContent, -- 340
			paramsJson, -- 341
			paramsJson, -- 342
			resultJson, -- 343
			resultJson, -- 344
			patch.checkpointId or 0, -- 345
			patch.checkpointId or 0, -- 346
			patch.checkpointSeq or 0, -- 347
			patch.checkpointSeq or 0, -- 348
			filesJson, -- 349
			filesJson, -- 350
			now(), -- 351
			row[1] -- 352
		} -- 352
	) -- 352
end -- 276
local function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 357
	if taskId <= 0 then -- 357
		return -- 358
	end -- 358
	if finalSteps ~= nil and finalSteps >= 0 then -- 358
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 360
	end -- 360
	if not finalStatus then -- 360
		return -- 366
	end -- 366
	if finalSteps ~= nil and finalSteps >= 0 then -- 366
		DB:exec( -- 368
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 368
			{ -- 372
				finalStatus, -- 372
				now(), -- 372
				sessionId, -- 372
				taskId, -- 372
				finalSteps -- 372
			} -- 372
		) -- 372
		return -- 374
	end -- 374
	DB:exec( -- 376
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 376
		{ -- 380
			finalStatus, -- 380
			now(), -- 380
			sessionId, -- 380
			taskId -- 380
		} -- 380
	) -- 380
end -- 357
local function sanitizeStoredSteps(sessionId) -- 384
	DB:exec( -- 385
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 385
		{ -- 403
			now(), -- 403
			sessionId -- 403
		} -- 403
	) -- 403
end -- 384
local function applyEvent(sessionId, event) -- 407
	repeat -- 407
		local ____switch45 = event.type -- 407
		local ____cond45 = ____switch45 == "task_started" -- 407
		if ____cond45 then -- 407
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 410
			break -- 411
		end -- 411
		____cond45 = ____cond45 or ____switch45 == "decision_made" -- 411
		if ____cond45 then -- 411
			upsertStep( -- 413
				sessionId, -- 413
				event.taskId, -- 413
				event.step, -- 413
				event.tool, -- 413
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 413
			) -- 413
			break -- 419
		end -- 419
		____cond45 = ____cond45 or ____switch45 == "tool_started" -- 419
		if ____cond45 then -- 419
			upsertStep( -- 421
				sessionId, -- 421
				event.taskId, -- 421
				event.step, -- 421
				event.tool, -- 421
				{status = "RUNNING"} -- 421
			) -- 421
			break -- 424
		end -- 424
		____cond45 = ____cond45 or ____switch45 == "tool_finished" -- 424
		if ____cond45 then -- 424
			upsertStep( -- 426
				sessionId, -- 426
				event.taskId, -- 426
				event.step, -- 426
				event.tool, -- 426
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 426
			) -- 426
			break -- 431
		end -- 431
		____cond45 = ____cond45 or ____switch45 == "checkpoint_created" -- 431
		if ____cond45 then -- 431
			upsertStep( -- 433
				sessionId, -- 433
				event.taskId, -- 433
				event.step, -- 433
				event.tool, -- 433
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 433
			) -- 433
			break -- 438
		end -- 438
		____cond45 = ____cond45 or ____switch45 == "memory_compression_started" -- 438
		if ____cond45 then -- 438
			upsertStep( -- 440
				sessionId, -- 440
				event.taskId, -- 440
				event.step, -- 440
				event.tool, -- 440
				{status = "RUNNING", reason = event.reason, params = event.params} -- 440
			) -- 440
			break -- 445
		end -- 445
		____cond45 = ____cond45 or ____switch45 == "memory_compression_finished" -- 445
		if ____cond45 then -- 445
			upsertStep( -- 447
				sessionId, -- 447
				event.taskId, -- 447
				event.step, -- 447
				event.tool, -- 447
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 447
			) -- 447
			break -- 452
		end -- 452
		____cond45 = ____cond45 or ____switch45 == "task_finished" -- 452
		if ____cond45 then -- 452
			do -- 452
				local ____opt_1 = activeStopTokens[event.taskId or -1] -- 452
				local stopped = (____opt_1 and ____opt_1.stopped) == true -- 454
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 455
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 458
				if event.taskId ~= nil then -- 458
					local ____finalizeTaskSteps_5 = finalizeTaskSteps -- 460
					local ____array_4 = __TS__SparseArrayNew( -- 460
						sessionId, -- 461
						event.taskId, -- 462
						type(event.steps) == "number" and math.max( -- 463
							0, -- 463
							math.floor(event.steps) -- 463
						) or nil -- 463
					) -- 463
					local ____event_success_3 -- 464
					if event.success then -- 464
						____event_success_3 = nil -- 464
					else -- 464
						____event_success_3 = stopped and "STOPPED" or "FAILED" -- 464
					end -- 464
					__TS__SparseArrayPush(____array_4, ____event_success_3) -- 464
					____finalizeTaskSteps_5(__TS__SparseArraySpread(____array_4)) -- 460
					local summaryRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\t\t\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\t\t\t\tORDER BY id DESC LIMIT 1", {sessionId, event.taskId, "assistant"}) -- 466
					if summaryRow and type(summaryRow[1]) == "number" then -- 466
						updateMessage(summaryRow[1], event.message) -- 473
					else -- 473
						insertMessage(sessionId, "assistant", event.message, event.taskId) -- 475
					end -- 475
					activeStopTokens[event.taskId] = nil -- 477
				end -- 477
				break -- 479
			end -- 479
		end -- 479
	until true -- 479
end -- 407
local function getSchemaVersion() -- 484
	local row = queryOne("PRAGMA user_version") -- 485
	return row and type(row[1]) == "number" and row[1] or 0 -- 486
end -- 484
local function setSchemaVersion(version) -- 489
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 490
		0, -- 490
		math.floor(version) -- 490
	))) -- 490
end -- 489
local function recreateSchema() -- 493
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 494
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 495
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 496
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 497
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 507
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 508
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 517
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 518
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 535
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 536
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 537
end -- 493
do -- 493
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 493
		recreateSchema() -- 543
	else -- 543
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 545
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 555
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 556
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 565
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 566
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 583
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 584
	end -- 584
end -- 584
function ____exports.createSession(projectRoot, title) -- 588
	if title == nil then -- 588
		title = "" -- 588
	end -- 588
	if not isValidProjectRoot(projectRoot) then -- 588
		return {success = false, message = "invalid projectRoot"} -- 590
	end -- 590
	local row = queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ?\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 592
	if row then -- 592
		return { -- 601
			success = true, -- 601
			session = rowToSession(row) -- 601
		} -- 601
	end -- 601
	local t = now() -- 603
	DB:exec( -- 604
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'IDLE', 'IDLE', ?, ?)", -- 604
		{ -- 607
			projectRoot, -- 607
			title ~= "" and title or Path:getFilename(projectRoot), -- 607
			t, -- 607
			t -- 607
		} -- 607
	) -- 607
	local session = getSessionItem(getLastInsertRowId()) -- 609
	if not session then -- 609
		return {success = false, message = "failed to create session"} -- 611
	end -- 611
	return {success = true, session = session} -- 613
end -- 588
function ____exports.getSession(sessionId) -- 616
	local session = getSessionItem(sessionId) -- 617
	if not session then -- 617
		return {success = false, message = "session not found"} -- 619
	end -- 619
	local normalizedSession = normalizeSessionRuntimeState(session) -- 621
	sanitizeStoredSteps(sessionId) -- 622
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 623
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 630
	return { -- 638
		success = true, -- 639
		session = normalizedSession, -- 640
		messages = __TS__ArrayMap( -- 641
			messages, -- 641
			function(____, row) return rowToMessage(row) end -- 641
		), -- 641
		steps = __TS__ArrayMap( -- 642
			steps, -- 642
			function(____, row) return rowToStep(row) end -- 642
		) -- 642
	} -- 642
end -- 616
function ____exports.sendPrompt(sessionId, prompt) -- 646
	local session = getSessionItem(sessionId) -- 647
	if not session then -- 647
		return {success = false, message = "session not found"} -- 649
	end -- 649
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 649
		return {success = false, message = "session task is still running"} -- 652
	end -- 652
	local normalizedPrompt = truncateAgentUserPrompt(prompt) -- 654
	local taskRes = Tools.createTask(normalizedPrompt) -- 655
	if not taskRes.success then -- 655
		return {success = false, message = taskRes.message} -- 657
	end -- 657
	local taskId = taskRes.taskId -- 659
	local useChineseResponse = getDefaultUseChineseResponse() -- 660
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 661
	local stopToken = {stopped = false} -- 662
	activeStopTokens[taskId] = stopToken -- 663
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 664
	runCodingAgent( -- 665
		{ -- 665
			prompt = normalizedPrompt, -- 666
			workDir = session.projectRoot, -- 667
			useChineseResponse = useChineseResponse, -- 668
			taskId = taskId, -- 669
			sessionId = sessionId, -- 670
			stopToken = stopToken, -- 671
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 672
		}, -- 672
		function(result) -- 673
			if not result.success then -- 673
				applyEvent(sessionId, { -- 675
					type = "task_finished", -- 676
					sessionId = sessionId, -- 677
					taskId = result.taskId, -- 678
					success = false, -- 679
					message = result.message, -- 680
					steps = result.steps -- 681
				}) -- 681
			end -- 681
		end -- 673
	) -- 673
	return {success = true, sessionId = sessionId, taskId = taskId} -- 685
end -- 646
function ____exports.stopSessionTask(sessionId) -- 688
	local session = getSessionItem(sessionId) -- 689
	if not session or session.currentTaskId == nil then -- 689
		return {success = false, message = "session task not found"} -- 691
	end -- 691
	local normalizedSession = normalizeSessionRuntimeState(session) -- 693
	local stopToken = activeStopTokens[session.currentTaskId] -- 694
	if not stopToken then -- 694
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 694
			return {success = true, recovered = true} -- 697
		end -- 697
		return {success = false, message = "task is not running"} -- 699
	end -- 699
	stopToken.stopped = true -- 701
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 702
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 703
	return {success = true} -- 704
end -- 688
function ____exports.getCurrentTaskId(sessionId) -- 707
	local ____opt_6 = getSessionItem(sessionId) -- 707
	return ____opt_6 and ____opt_6.currentTaskId -- 708
end -- 707
function ____exports.listRunningSessions() -- 711
	local rows = queryRows(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 712
	local sessions = {} -- 719
	do -- 719
		local i = 0 -- 720
		while i < #rows do -- 720
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 721
			if session.currentTaskStatus == "RUNNING" then -- 721
				sessions[#sessions + 1] = session -- 723
			end -- 723
			i = i + 1 -- 720
		end -- 720
	end -- 720
	return {success = true, sessions = sessions} -- 726
end -- 711
return ____exports -- 711