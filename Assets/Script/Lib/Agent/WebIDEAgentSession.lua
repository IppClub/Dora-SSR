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
	DB:exec(("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", { -- 254
		sessionId, -- 258
		taskId or 0, -- 259
		role, -- 260
		content, -- 261
		t, -- 262
		t -- 263
	}) -- 263
	return getLastInsertRowId() -- 266
end -- 252
local function updateMessage(messageId, content) -- 269
	DB:exec( -- 270
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 270
		{ -- 272
			content, -- 272
			now(), -- 272
			messageId -- 272
		} -- 272
	) -- 272
end -- 269
local function upsertStep(sessionId, taskId, step, tool, patch) -- 276
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 286
	local reason = patch.reason or "" -- 290
	local reasoningContent = patch.reasoningContent or "" -- 291
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 292
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 293
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 294
	local status = patch.status or "PENDING" -- 295
	if not row then -- 295
		local t = now() -- 297
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 298
			sessionId, -- 302
			taskId, -- 303
			step, -- 304
			tool, -- 305
			status, -- 306
			reason, -- 307
			reasoningContent, -- 308
			paramsJson, -- 309
			resultJson, -- 310
			patch.checkpointId or 0, -- 311
			patch.checkpointSeq or 0, -- 312
			filesJson, -- 313
			t, -- 314
			t -- 315
		}) -- 315
		return -- 318
	end -- 318
	DB:exec( -- 320
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 320
		{ -- 332
			tool, -- 333
			patch.status or "", -- 334
			status, -- 335
			reason, -- 336
			reason, -- 337
			reasoningContent, -- 338
			reasoningContent, -- 339
			paramsJson, -- 340
			paramsJson, -- 341
			resultJson, -- 342
			resultJson, -- 343
			patch.checkpointId or 0, -- 344
			patch.checkpointId or 0, -- 345
			patch.checkpointSeq or 0, -- 346
			patch.checkpointSeq or 0, -- 347
			filesJson, -- 348
			filesJson, -- 349
			now(), -- 350
			row[1] -- 351
		} -- 351
	) -- 351
end -- 276
local function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 356
	if taskId <= 0 then -- 356
		return -- 357
	end -- 357
	if finalSteps ~= nil and finalSteps >= 0 then -- 357
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 359
	end -- 359
	if not finalStatus then -- 359
		return -- 365
	end -- 365
	if finalSteps ~= nil and finalSteps >= 0 then -- 365
		DB:exec( -- 367
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 367
			{ -- 371
				finalStatus, -- 371
				now(), -- 371
				sessionId, -- 371
				taskId, -- 371
				finalSteps -- 371
			} -- 371
		) -- 371
		return -- 373
	end -- 373
	DB:exec( -- 375
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 375
		{ -- 379
			finalStatus, -- 379
			now(), -- 379
			sessionId, -- 379
			taskId -- 379
		} -- 379
	) -- 379
end -- 356
local function sanitizeStoredSteps(sessionId) -- 383
	DB:exec( -- 384
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 384
		{ -- 402
			now(), -- 402
			sessionId -- 402
		} -- 402
	) -- 402
end -- 383
local function applyEvent(sessionId, event) -- 406
	repeat -- 406
		local ____switch45 = event.type -- 406
		local ____cond45 = ____switch45 == "task_started" -- 406
		if ____cond45 then -- 406
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 409
			break -- 410
		end -- 410
		____cond45 = ____cond45 or ____switch45 == "decision_made" -- 410
		if ____cond45 then -- 410
			upsertStep( -- 412
				sessionId, -- 412
				event.taskId, -- 412
				event.step, -- 412
				event.tool, -- 412
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 412
			) -- 412
			break -- 418
		end -- 418
		____cond45 = ____cond45 or ____switch45 == "tool_started" -- 418
		if ____cond45 then -- 418
			upsertStep( -- 420
				sessionId, -- 420
				event.taskId, -- 420
				event.step, -- 420
				event.tool, -- 420
				{status = "RUNNING"} -- 420
			) -- 420
			break -- 423
		end -- 423
		____cond45 = ____cond45 or ____switch45 == "tool_finished" -- 423
		if ____cond45 then -- 423
			upsertStep( -- 425
				sessionId, -- 425
				event.taskId, -- 425
				event.step, -- 425
				event.tool, -- 425
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 425
			) -- 425
			break -- 430
		end -- 430
		____cond45 = ____cond45 or ____switch45 == "checkpoint_created" -- 430
		if ____cond45 then -- 430
			upsertStep( -- 432
				sessionId, -- 432
				event.taskId, -- 432
				event.step, -- 432
				event.tool, -- 432
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 432
			) -- 432
			break -- 437
		end -- 437
		____cond45 = ____cond45 or ____switch45 == "task_finished" -- 437
		if ____cond45 then -- 437
			do -- 437
				local ____opt_1 = activeStopTokens[event.taskId or -1] -- 437
				local stopped = (____opt_1 and ____opt_1.stopped) == true -- 439
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 440
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 443
				if event.taskId ~= nil then -- 443
					local ____finalizeTaskSteps_5 = finalizeTaskSteps -- 445
					local ____array_4 = __TS__SparseArrayNew( -- 445
						sessionId, -- 446
						event.taskId, -- 447
						type(event.steps) == "number" and math.max( -- 448
							0, -- 448
							math.floor(event.steps) -- 448
						) or nil -- 448
					) -- 448
					local ____event_success_3 -- 449
					if event.success then -- 449
						____event_success_3 = nil -- 449
					else -- 449
						____event_success_3 = stopped and "STOPPED" or "FAILED" -- 449
					end -- 449
					__TS__SparseArrayPush(____array_4, ____event_success_3) -- 449
					____finalizeTaskSteps_5(__TS__SparseArraySpread(____array_4)) -- 445
					local summaryRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\t\t\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\t\t\t\tORDER BY id DESC LIMIT 1", {sessionId, event.taskId, "assistant"}) -- 451
					if summaryRow and type(summaryRow[1]) == "number" then -- 451
						updateMessage(summaryRow[1], event.message) -- 458
					else -- 458
						insertMessage(sessionId, "assistant", event.message, event.taskId) -- 460
					end -- 460
					activeStopTokens[event.taskId] = nil -- 462
				end -- 462
				break -- 464
			end -- 464
		end -- 464
	until true -- 464
end -- 406
local function getSchemaVersion() -- 469
	local row = queryOne("PRAGMA user_version") -- 470
	return row and type(row[1]) == "number" and row[1] or 0 -- 471
end -- 469
local function setSchemaVersion(version) -- 474
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 475
		0, -- 475
		math.floor(version) -- 475
	))) -- 475
end -- 474
local function recreateSchema() -- 478
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 479
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 480
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 481
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 482
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 492
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 493
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 502
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 503
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 520
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 521
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 522
end -- 478
do -- 478
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 478
		recreateSchema() -- 528
	else -- 528
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 530
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 540
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 541
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 550
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 551
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 568
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 569
	end -- 569
end -- 569
function ____exports.createSession(projectRoot, title) -- 573
	if title == nil then -- 573
		title = "" -- 573
	end -- 573
	if not isValidProjectRoot(projectRoot) then -- 573
		return {success = false, message = "invalid projectRoot"} -- 575
	end -- 575
	local row = queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ?\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 577
	if row then -- 577
		return { -- 586
			success = true, -- 586
			session = rowToSession(row) -- 586
		} -- 586
	end -- 586
	local t = now() -- 588
	DB:exec( -- 589
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'IDLE', 'IDLE', ?, ?)", -- 589
		{ -- 592
			projectRoot, -- 592
			title ~= "" and title or Path:getFilename(projectRoot), -- 592
			t, -- 592
			t -- 592
		} -- 592
	) -- 592
	local session = getSessionItem(getLastInsertRowId()) -- 594
	if not session then -- 594
		return {success = false, message = "failed to create session"} -- 596
	end -- 596
	return {success = true, session = session} -- 598
end -- 573
function ____exports.getSession(sessionId) -- 601
	local session = getSessionItem(sessionId) -- 602
	if not session then -- 602
		return {success = false, message = "session not found"} -- 604
	end -- 604
	local normalizedSession = normalizeSessionRuntimeState(session) -- 606
	sanitizeStoredSteps(sessionId) -- 607
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 608
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 615
	return { -- 623
		success = true, -- 624
		session = normalizedSession, -- 625
		messages = __TS__ArrayMap( -- 626
			messages, -- 626
			function(____, row) return rowToMessage(row) end -- 626
		), -- 626
		steps = __TS__ArrayMap( -- 627
			steps, -- 627
			function(____, row) return rowToStep(row) end -- 627
		) -- 627
	} -- 627
end -- 601
function ____exports.sendPrompt(sessionId, prompt) -- 631
	local session = getSessionItem(sessionId) -- 632
	if not session then -- 632
		return {success = false, message = "session not found"} -- 634
	end -- 634
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 634
		return {success = false, message = "session task is still running"} -- 637
	end -- 637
	local taskRes = Tools.createTask(prompt) -- 639
	if not taskRes.success then -- 639
		return {success = false, message = taskRes.message} -- 641
	end -- 641
	local taskId = taskRes.taskId -- 643
	local useChineseResponse = getDefaultUseChineseResponse() -- 644
	insertMessage(sessionId, "user", prompt, taskId) -- 645
	local stopToken = {stopped = false} -- 646
	activeStopTokens[taskId] = stopToken -- 647
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 648
	runCodingAgent( -- 649
		{ -- 649
			prompt = prompt, -- 650
			workDir = session.projectRoot, -- 651
			useChineseResponse = useChineseResponse, -- 652
			taskId = taskId, -- 653
			sessionId = sessionId, -- 654
			stopToken = stopToken, -- 655
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 656
		}, -- 656
		function(result) -- 657
			if not result.success then -- 657
				applyEvent(sessionId, { -- 659
					type = "task_finished", -- 660
					sessionId = sessionId, -- 661
					taskId = result.taskId, -- 662
					success = false, -- 663
					message = result.message, -- 664
					steps = result.steps -- 665
				}) -- 665
			end -- 665
		end -- 657
	) -- 657
	return {success = true, sessionId = sessionId, taskId = taskId} -- 669
end -- 631
function ____exports.stopSessionTask(sessionId) -- 672
	local session = getSessionItem(sessionId) -- 673
	if not session or session.currentTaskId == nil then -- 673
		return {success = false, message = "session task not found"} -- 675
	end -- 675
	local normalizedSession = normalizeSessionRuntimeState(session) -- 677
	local stopToken = activeStopTokens[session.currentTaskId] -- 678
	if not stopToken then -- 678
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 678
			return {success = true, recovered = true} -- 681
		end -- 681
		return {success = false, message = "task is not running"} -- 683
	end -- 683
	stopToken.stopped = true -- 685
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 686
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 687
	return {success = true} -- 688
end -- 672
function ____exports.getCurrentTaskId(sessionId) -- 691
	local ____opt_6 = getSessionItem(sessionId) -- 691
	return ____opt_6 and ____opt_6.currentTaskId -- 692
end -- 691
function ____exports.listRunningSessions() -- 695
	local rows = queryRows(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 696
	local sessions = {} -- 703
	do -- 703
		local i = 0 -- 704
		while i < #rows do -- 704
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 705
			if session.currentTaskStatus == "RUNNING" then -- 705
				sessions[#sessions + 1] = session -- 707
			end -- 707
			i = i + 1 -- 704
		end -- 704
	end -- 704
	return {success = true, sessions = sessions} -- 710
end -- 695
return ____exports -- 695