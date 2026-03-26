-- [ts]: WebIDEAgentSession.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayReverse = ____lualib.__TS__ArrayReverse -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local setSessionState, TABLE_SESSION, now -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local json = ____Dora.json -- 2
local ____CodingAgent = require("Agent.CodingAgent") -- 3
local runCodingAgent = ____CodingAgent.runCodingAgent -- 3
local Tools = require("Agent.Tools") -- 4
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 274
	DB:exec( -- 275
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 275
		{ -- 279
			status, -- 280
			currentTaskId or 0, -- 281
			currentTaskStatus or status, -- 282
			now(), -- 283
			sessionId -- 284
		} -- 284
	) -- 284
end -- 284
TABLE_SESSION = "AgentSession" -- 80
local TABLE_MESSAGE = "AgentSessionMessage" -- 81
local TABLE_STEP = "AgentSessionStep" -- 82
local TABLE_TASK = "AgentTask" -- 83
local SESSION_CONTEXT_MAX_MESSAGES = 12 -- 84
local SESSION_CONTEXT_MAX_CHARS = 12000 -- 85
local activeStopTokens = {} -- 87
local activeAssistantMessageIds = {} -- 88
now = function() return os.time() end -- 90
local function getDefaultUseChineseResponse() -- 92
	local zh = string.match(App.locale, "^zh") -- 93
	return zh ~= nil -- 94
end -- 92
local function toBool(v) -- 97
	return v ~= 0 and v ~= false and v ~= nil and v ~= nil -- 98
end -- 97
local function toStr(v) -- 101
	if v == false or v == nil or v == nil then -- 101
		return "" -- 102
	end -- 102
	return tostring(v) -- 103
end -- 101
local function encodeJson(value) -- 106
	local text = json.encode(value) -- 107
	return text or "" -- 108
end -- 106
local function decodeJsonObject(text) -- 111
	if not text or text == "" then -- 111
		return nil -- 112
	end -- 112
	local value = json.decode(text) -- 113
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 113
		return value -- 115
	end -- 115
	return nil -- 117
end -- 111
local function decodeJsonFiles(text) -- 120
	if not text or text == "" then -- 120
		return nil -- 121
	end -- 121
	local value = json.decode(text) -- 122
	if not value or not __TS__ArrayIsArray(value) then -- 122
		return nil -- 123
	end -- 123
	local files = {} -- 124
	do -- 124
		local i = 0 -- 125
		while i < #value do -- 125
			do -- 125
				local item = value[i + 1] -- 126
				if type(item) ~= "table" then -- 126
					goto __continue15 -- 127
				end -- 127
				files[#files + 1] = { -- 128
					path = toStr(item.path), -- 129
					op = toStr(item.op) -- 130
				} -- 130
			end -- 130
			::__continue15:: -- 130
			i = i + 1 -- 125
		end -- 125
	end -- 125
	return files -- 133
end -- 120
local function queryRows(sql, args) -- 136
	local ____args_0 -- 137
	if args then -- 137
		____args_0 = DB:query(sql, args) -- 137
	else -- 137
		____args_0 = DB:query(sql) -- 137
	end -- 137
	return ____args_0 -- 137
end -- 136
local function queryOne(sql, args) -- 140
	local rows = queryRows(sql, args) -- 141
	if not rows or #rows == 0 then -- 141
		return nil -- 142
	end -- 142
	return rows[1] -- 143
end -- 140
local function getLastInsertRowId() -- 146
	local row = queryOne("SELECT last_insert_rowid()") -- 147
	return row and (row[1] or 0) or 0 -- 148
end -- 146
local function isValidProjectRoot(path) -- 151
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 152
end -- 151
local function rowToSession(row) -- 155
	return { -- 156
		id = row[1], -- 157
		projectRoot = toStr(row[2]), -- 158
		title = toStr(row[3]), -- 159
		status = toStr(row[4]), -- 160
		currentTaskId = type(row[5]) == "number" and row[5] > 0 and row[5] or nil, -- 161
		currentTaskStatus = toStr(row[6]), -- 162
		createdAt = row[7], -- 163
		updatedAt = row[8] -- 164
	} -- 164
end -- 155
local function rowToMessage(row) -- 168
	return { -- 169
		id = row[1], -- 170
		sessionId = row[2], -- 171
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 172
		role = toStr(row[4]), -- 173
		kind = toStr(row[5]), -- 174
		content = toStr(row[6]), -- 175
		streaming = toBool(row[7]), -- 176
		createdAt = row[8], -- 177
		updatedAt = row[9] -- 178
	} -- 178
end -- 168
local function rowToStep(row) -- 182
	return { -- 183
		id = row[1], -- 184
		sessionId = row[2], -- 185
		taskId = row[3], -- 186
		step = row[4], -- 187
		tool = toStr(row[5]), -- 188
		status = toStr(row[6]), -- 189
		reason = toStr(row[7]), -- 190
		params = decodeJsonObject(toStr(row[8])), -- 191
		result = decodeJsonObject(toStr(row[9])), -- 192
		checkpointId = type(row[10]) == "number" and row[10] > 0 and row[10] or nil, -- 193
		checkpointSeq = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 194
		files = decodeJsonFiles(toStr(row[12])), -- 195
		createdAt = row[13], -- 196
		updatedAt = row[14] -- 197
	} -- 197
end -- 182
local function getSessionRow(sessionId) -- 201
	return queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 202
end -- 201
local function getSessionItem(sessionId) -- 210
	local row = getSessionRow(sessionId) -- 211
	return row and rowToSession(row) or nil -- 212
end -- 210
local function normalizeSessionRuntimeState(session) -- 215
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 215
		return session -- 217
	end -- 217
	if activeStopTokens[session.currentTaskId] then -- 217
		return session -- 220
	end -- 220
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 222
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 223
	return __TS__ObjectAssign( -- 224
		{}, -- 224
		session, -- 225
		{ -- 224
			status = "STOPPED", -- 226
			currentTaskStatus = "STOPPED", -- 227
			updatedAt = now() -- 228
		} -- 228
	) -- 228
end -- 215
local function trimSessionContext(text, maxChars) -- 232
	if #text <= maxChars then -- 232
		return text -- 233
	end -- 233
	local clipped = __TS__StringSlice(text, #text - maxChars) -- 234
	local newlinePos = (string.find(clipped, "\n", nil, true) or 0) - 1 -- 235
	return newlinePos >= 0 and __TS__StringSlice(clipped, newlinePos + 1) or clipped -- 236
end -- 232
local function buildSessionPromptContext(sessionId, useChineseResponse) -- 239
	local rows = queryRows(("SELECT role, kind, content\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND content <> ''\n\t\tORDER BY id DESC\n\t\tLIMIT ?", {sessionId, SESSION_CONTEXT_MAX_MESSAGES}) or ({}) -- 240
	if #rows == 0 then -- 240
		return "" -- 248
	end -- 248
	local messages = __TS__ArrayFilter( -- 249
		__TS__ArrayMap( -- 249
			__TS__ArrayReverse(__TS__ArraySlice(rows)), -- 249
			function(____, row) return { -- 252
				role = toStr(row[1]), -- 253
				kind = toStr(row[2]), -- 254
				content = __TS__StringTrim(toStr(row[3])) -- 255
			} end -- 255
		), -- 255
		function(____, message) return message.content ~= "" end -- 257
	) -- 257
	if #messages == 0 then -- 257
		return "" -- 258
	end -- 258
	local lines = {} -- 259
	lines[#lines + 1] = useChineseResponse and "以下是同一会话中之前的对话内容，请把它们作为当前请求的上下文参考。若与当前请求冲突，以当前请求为准。" or "Here is the prior conversation from the same session. Use it as context for the current request. If there is any conflict, prefer the current request." -- 260
	lines[#lines + 1] = "" -- 263
	do -- 263
		local i = 0 -- 264
		while i < #messages do -- 264
			local message = messages[i + 1] -- 265
			local speaker = message.role == "user" and (useChineseResponse and "用户" or "User") or (useChineseResponse and "助手" or "Assistant") -- 266
			lines[#lines + 1] = (speaker .. ": ") .. message.content -- 269
			i = i + 1 -- 264
		end -- 264
	end -- 264
	return trimSessionContext( -- 271
		table.concat(lines, "\n"), -- 271
		SESSION_CONTEXT_MAX_CHARS -- 271
	) -- 271
end -- 239
local function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 289
	if taskId == nil or taskId <= 0 then -- 289
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 291
		return -- 292
	end -- 292
	local row = getSessionRow(sessionId) -- 294
	if not row then -- 294
		return -- 295
	end -- 295
	local session = rowToSession(row) -- 296
	if session.currentTaskId ~= taskId then -- 296
		Log( -- 298
			"Info", -- 298
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 298
		) -- 298
		return -- 299
	end -- 299
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 301
end -- 289
local function insertMessage(sessionId, role, kind, content, taskId, streaming) -- 304
	if streaming == nil then -- 304
		streaming = false -- 304
	end -- 304
	local t = now() -- 305
	DB:exec(("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, kind, content, streaming, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?)", { -- 306
		sessionId, -- 310
		taskId or 0, -- 311
		role, -- 312
		kind, -- 313
		content, -- 314
		streaming and 1 or 0, -- 315
		t, -- 316
		t -- 317
	}) -- 317
	return getLastInsertRowId() -- 320
end -- 304
local function updateMessage(messageId, content, streaming) -- 323
	DB:exec( -- 324
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, streaming = ?, updated_at = ? WHERE id = ?", -- 324
		{ -- 326
			content, -- 326
			streaming and 1 or 0, -- 326
			now(), -- 326
			messageId -- 326
		} -- 326
	) -- 326
end -- 323
local function getAssistantSummaryMessageId(taskId, sessionId) -- 330
	local cached = activeAssistantMessageIds[taskId] -- 331
	if cached ~= nil then -- 331
		return cached -- 332
	end -- 332
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ? AND kind = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant", "summary"}) -- 333
	if row and type(row[1]) == "number" then -- 333
		activeAssistantMessageIds[taskId] = row[1] -- 340
		return row[1] -- 341
	end -- 341
	local messageId = insertMessage( -- 343
		sessionId, -- 343
		"assistant", -- 343
		"summary", -- 343
		"", -- 343
		taskId, -- 343
		true -- 343
	) -- 343
	activeAssistantMessageIds[taskId] = messageId -- 344
	return messageId -- 345
end -- 330
local function upsertStep(sessionId, taskId, step, tool, patch) -- 348
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 357
	local reason = patch.reason or "" -- 361
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 362
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 363
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 364
	local status = patch.status or "PENDING" -- 365
	if not row then -- 365
		local t = now() -- 367
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 368
			sessionId, -- 372
			taskId, -- 373
			step, -- 374
			tool, -- 375
			status, -- 376
			reason, -- 377
			paramsJson, -- 378
			resultJson, -- 379
			patch.checkpointId or 0, -- 380
			patch.checkpointSeq or 0, -- 381
			filesJson, -- 382
			t, -- 383
			t -- 384
		}) -- 384
		return -- 387
	end -- 387
	DB:exec( -- 389
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 389
		{ -- 400
			tool, -- 401
			patch.status or "", -- 402
			status, -- 403
			reason, -- 404
			reason, -- 405
			paramsJson, -- 406
			paramsJson, -- 407
			resultJson, -- 408
			resultJson, -- 409
			patch.checkpointId or 0, -- 410
			patch.checkpointId or 0, -- 411
			patch.checkpointSeq or 0, -- 412
			patch.checkpointSeq or 0, -- 413
			filesJson, -- 414
			filesJson, -- 415
			now(), -- 416
			row[1] -- 417
		} -- 417
	) -- 417
end -- 348
local function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 422
	if taskId <= 0 then -- 422
		return -- 423
	end -- 423
	if finalSteps ~= nil and finalSteps >= 0 then -- 423
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 425
	end -- 425
	if not finalStatus then -- 425
		return -- 431
	end -- 431
	if finalSteps ~= nil and finalSteps >= 0 then -- 431
		DB:exec( -- 433
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 433
			{ -- 437
				finalStatus, -- 437
				now(), -- 437
				sessionId, -- 437
				taskId, -- 437
				finalSteps -- 437
			} -- 437
		) -- 437
		return -- 439
	end -- 439
	DB:exec( -- 441
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 441
		{ -- 445
			finalStatus, -- 445
			now(), -- 445
			sessionId, -- 445
			taskId -- 445
		} -- 445
	) -- 445
end -- 422
local function sanitizeStoredSteps(sessionId) -- 449
	DB:exec( -- 450
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 450
		{ -- 468
			now(), -- 468
			sessionId -- 468
		} -- 468
	) -- 468
end -- 449
local function applyEvent(sessionId, event) -- 472
	repeat -- 472
		local ____switch58 = event.type -- 472
		local ____cond58 = ____switch58 == "task_started" -- 472
		if ____cond58 then -- 472
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 475
			break -- 476
		end -- 476
		____cond58 = ____cond58 or ____switch58 == "decision_made" -- 476
		if ____cond58 then -- 476
			upsertStep( -- 478
				sessionId, -- 478
				event.taskId, -- 478
				event.step, -- 478
				event.tool, -- 478
				{status = "PENDING", reason = event.reason, params = event.params} -- 478
			) -- 478
			break -- 483
		end -- 483
		____cond58 = ____cond58 or ____switch58 == "tool_started" -- 483
		if ____cond58 then -- 483
			upsertStep( -- 485
				sessionId, -- 485
				event.taskId, -- 485
				event.step, -- 485
				event.tool, -- 485
				{status = "RUNNING"} -- 485
			) -- 485
			break -- 488
		end -- 488
		____cond58 = ____cond58 or ____switch58 == "tool_finished" -- 488
		if ____cond58 then -- 488
			upsertStep( -- 490
				sessionId, -- 490
				event.taskId, -- 490
				event.step, -- 490
				event.tool, -- 490
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 490
			) -- 490
			break -- 495
		end -- 495
		____cond58 = ____cond58 or ____switch58 == "checkpoint_created" -- 495
		if ____cond58 then -- 495
			upsertStep( -- 497
				sessionId, -- 497
				event.taskId, -- 497
				event.step, -- 497
				event.tool, -- 497
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 497
			) -- 497
			break -- 502
		end -- 502
		____cond58 = ____cond58 or ____switch58 == "summary_stream" -- 502
		if ____cond58 then -- 502
			do -- 502
				local messageId = getAssistantSummaryMessageId(event.taskId, sessionId) -- 504
				local row = queryOne(("SELECT content FROM " .. TABLE_MESSAGE) .. " WHERE id = ?", {messageId}) -- 505
				local oldContent = row and toStr(row[1]) or "" -- 506
				local nextContent = oldContent .. event.textDelta -- 507
				updateMessage(messageId, nextContent, true) -- 508
				break -- 509
			end -- 509
		end -- 509
		____cond58 = ____cond58 or ____switch58 == "task_finished" -- 509
		if ____cond58 then -- 509
			do -- 509
				local ____opt_1 = activeStopTokens[event.taskId or -1] -- 509
				local stopped = (____opt_1 and ____opt_1.stopped) == true -- 512
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 513
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 516
				if event.taskId ~= nil then -- 516
					local ____finalizeTaskSteps_5 = finalizeTaskSteps -- 518
					local ____array_4 = __TS__SparseArrayNew( -- 518
						sessionId, -- 519
						event.taskId, -- 520
						type(event.steps) == "number" and math.max( -- 521
							0, -- 521
							math.floor(event.steps) -- 521
						) or nil -- 521
					) -- 521
					local ____event_success_3 -- 522
					if event.success then -- 522
						____event_success_3 = nil -- 522
					else -- 522
						____event_success_3 = stopped and "STOPPED" or "FAILED" -- 522
					end -- 522
					__TS__SparseArrayPush(____array_4, ____event_success_3) -- 522
					____finalizeTaskSteps_5(__TS__SparseArraySpread(____array_4)) -- 518
					local messageId = getAssistantSummaryMessageId(event.taskId, sessionId) -- 524
					local row = queryOne(("SELECT content FROM " .. TABLE_MESSAGE) .. " WHERE id = ?", {messageId}) -- 525
					local content = row and toStr(row[1]) or "" -- 526
					updateMessage(messageId, content ~= "" and content or event.message, false) -- 527
					activeStopTokens[event.taskId] = nil -- 528
					activeAssistantMessageIds[event.taskId] = nil -- 529
				end -- 529
				break -- 531
			end -- 531
		end -- 531
	until true -- 531
end -- 472
do -- 472
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 538
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 548
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tkind TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tstreaming INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 549
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 560
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 561
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 577
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 578
end -- 578
function ____exports.createSession(projectRoot, title) -- 581
	if title == nil then -- 581
		title = "" -- 581
	end -- 581
	if not isValidProjectRoot(projectRoot) then -- 581
		return {success = false, message = "invalid projectRoot"} -- 583
	end -- 583
	local row = queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ?\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 585
	if row then -- 585
		return { -- 594
			success = true, -- 594
			session = rowToSession(row) -- 594
		} -- 594
	end -- 594
	local t = now() -- 596
	DB:exec( -- 597
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'IDLE', 'IDLE', ?, ?)", -- 597
		{ -- 600
			projectRoot, -- 600
			title ~= "" and title or Path:getFilename(projectRoot), -- 600
			t, -- 600
			t -- 600
		} -- 600
	) -- 600
	local session = getSessionItem(getLastInsertRowId()) -- 602
	if not session then -- 602
		return {success = false, message = "failed to create session"} -- 604
	end -- 604
	return {success = true, session = session} -- 606
end -- 581
function ____exports.getSession(sessionId) -- 609
	local session = getSessionItem(sessionId) -- 610
	if not session then -- 610
		return {success = false, message = "session not found"} -- 612
	end -- 612
	local normalizedSession = normalizeSessionRuntimeState(session) -- 614
	sanitizeStoredSteps(sessionId) -- 615
	local messages = queryRows(("SELECT id, session_id, task_id, role, kind, content, streaming, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 616
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 623
	return { -- 631
		success = true, -- 632
		session = normalizedSession, -- 633
		messages = __TS__ArrayMap( -- 634
			messages, -- 634
			function(____, row) return rowToMessage(row) end -- 634
		), -- 634
		steps = __TS__ArrayMap( -- 635
			steps, -- 635
			function(____, row) return rowToStep(row) end -- 635
		) -- 635
	} -- 635
end -- 609
function ____exports.sendPrompt(sessionId, prompt) -- 639
	local session = getSessionItem(sessionId) -- 640
	if not session then -- 640
		return {success = false, message = "session not found"} -- 642
	end -- 642
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 642
		return {success = false, message = "session task is still running"} -- 645
	end -- 645
	local taskRes = Tools.createTask(prompt) -- 647
	if not taskRes.success then -- 647
		return {success = false, message = taskRes.message} -- 649
	end -- 649
	local taskId = taskRes.taskId -- 651
	local useChineseResponse = getDefaultUseChineseResponse() -- 652
	local sessionContext = buildSessionPromptContext(sessionId, useChineseResponse) -- 653
	local agentPrompt = sessionContext ~= "" and (((sessionContext .. "\n\n") .. (useChineseResponse and "当前用户请求：" or "Current user request:")) .. "\n") .. prompt or prompt -- 654
	insertMessage( -- 657
		sessionId, -- 657
		"user", -- 657
		"message", -- 657
		prompt, -- 657
		taskId, -- 657
		false -- 657
	) -- 657
	local assistantMessageId = insertMessage( -- 658
		sessionId, -- 658
		"assistant", -- 658
		"summary", -- 658
		"", -- 658
		taskId, -- 658
		true -- 658
	) -- 658
	activeAssistantMessageIds[taskId] = assistantMessageId -- 659
	local stopToken = {stopped = false} -- 660
	activeStopTokens[taskId] = stopToken -- 661
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 662
	runCodingAgent( -- 663
		{ -- 663
			prompt = agentPrompt, -- 664
			workDir = session.projectRoot, -- 665
			useChineseResponse = useChineseResponse, -- 666
			taskId = taskId, -- 667
			sessionId = sessionId, -- 668
			stopToken = stopToken, -- 669
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 670
		}, -- 670
		function(result) -- 671
			if not result.success then -- 671
				applyEvent(sessionId, { -- 673
					type = "task_finished", -- 674
					sessionId = sessionId, -- 675
					taskId = result.taskId, -- 676
					success = false, -- 677
					message = result.message, -- 678
					steps = result.steps -- 679
				}) -- 679
			end -- 679
		end -- 671
	) -- 671
	return {success = true, sessionId = sessionId, taskId = taskId} -- 683
end -- 639
function ____exports.stopSessionTask(sessionId) -- 686
	local session = getSessionItem(sessionId) -- 687
	if not session or session.currentTaskId == nil then -- 687
		return {success = false, message = "session task not found"} -- 689
	end -- 689
	local normalizedSession = normalizeSessionRuntimeState(session) -- 691
	local stopToken = activeStopTokens[session.currentTaskId] -- 692
	if not stopToken then -- 692
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 692
			return {success = true, recovered = true} -- 695
		end -- 695
		return {success = false, message = "task is not running"} -- 697
	end -- 697
	stopToken.stopped = true -- 699
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 700
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 701
	return {success = true} -- 702
end -- 686
function ____exports.getCurrentTaskId(sessionId) -- 705
	local ____opt_6 = getSessionItem(sessionId) -- 705
	return ____opt_6 and ____opt_6.currentTaskId -- 706
end -- 705
function ____exports.listRunningSessions() -- 709
	local rows = queryRows(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 710
	local sessions = {} -- 717
	do -- 717
		local i = 0 -- 718
		while i < #rows do -- 718
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 719
			if session.currentTaskStatus == "RUNNING" then -- 719
				sessions[#sessions + 1] = session -- 721
			end -- 721
			i = i + 1 -- 718
		end -- 718
	end -- 718
	return {success = true, sessions = sessions} -- 724
end -- 709
return ____exports -- 709