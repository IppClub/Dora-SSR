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
local ____exports = {} -- 1
local setSessionState, TABLE_SESSION, now -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local json = ____Dora.json -- 2
local ____CodingAgent = require("Agent.CodingAgent") -- 3
local runCodingAgent = ____CodingAgent.runCodingAgent -- 3
local Tools = require("Agent.Tools") -- 4
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 267
	DB:exec( -- 268
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 268
		{ -- 272
			status, -- 273
			currentTaskId or 0, -- 274
			currentTaskStatus or status, -- 275
			now(), -- 276
			sessionId -- 277
		} -- 277
	) -- 277
end -- 277
TABLE_SESSION = "AgentSession" -- 79
local TABLE_MESSAGE = "AgentSessionMessage" -- 80
local TABLE_STEP = "AgentSessionStep" -- 81
local SESSION_CONTEXT_MAX_MESSAGES = 12 -- 82
local SESSION_CONTEXT_MAX_CHARS = 12000 -- 83
local activeStopTokens = {} -- 85
local activeAssistantMessageIds = {} -- 86
now = function() return os.time() end -- 88
local function toBool(v) -- 90
	return v ~= 0 and v ~= false and v ~= nil and v ~= nil -- 91
end -- 90
local function toStr(v) -- 94
	if v == false or v == nil or v == nil then -- 94
		return "" -- 95
	end -- 95
	return tostring(v) -- 96
end -- 94
local function encodeJson(value) -- 99
	local text = json.encode(value) -- 100
	return text or "" -- 101
end -- 99
local function decodeJsonObject(text) -- 104
	if not text or text == "" then -- 104
		return nil -- 105
	end -- 105
	local value = json.decode(text) -- 106
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 106
		return value -- 108
	end -- 108
	return nil -- 110
end -- 104
local function decodeJsonFiles(text) -- 113
	if not text or text == "" then -- 113
		return nil -- 114
	end -- 114
	local value = json.decode(text) -- 115
	if not value or not __TS__ArrayIsArray(value) then -- 115
		return nil -- 116
	end -- 116
	local files = {} -- 117
	do -- 117
		local i = 0 -- 118
		while i < #value do -- 118
			do -- 118
				local item = value[i + 1] -- 119
				if type(item) ~= "table" then -- 119
					goto __continue14 -- 120
				end -- 120
				files[#files + 1] = { -- 121
					path = toStr(item.path), -- 122
					op = toStr(item.op) -- 123
				} -- 123
			end -- 123
			::__continue14:: -- 123
			i = i + 1 -- 118
		end -- 118
	end -- 118
	return files -- 126
end -- 113
local function queryRows(sql, args) -- 129
	local ____args_0 -- 130
	if args then -- 130
		____args_0 = DB:query(sql, args) -- 130
	else -- 130
		____args_0 = DB:query(sql) -- 130
	end -- 130
	return ____args_0 -- 130
end -- 129
local function queryOne(sql, args) -- 133
	local rows = queryRows(sql, args) -- 134
	if not rows or #rows == 0 then -- 134
		return nil -- 135
	end -- 135
	return rows[1] -- 136
end -- 133
local function getLastInsertRowId() -- 139
	local row = queryOne("SELECT last_insert_rowid()") -- 140
	return row and (row[1] or 0) or 0 -- 141
end -- 139
local function isValidProjectRoot(path) -- 144
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 145
end -- 144
local function rowToSession(row) -- 148
	return { -- 149
		id = row[1], -- 150
		projectRoot = toStr(row[2]), -- 151
		title = toStr(row[3]), -- 152
		status = toStr(row[4]), -- 153
		currentTaskId = type(row[5]) == "number" and row[5] > 0 and row[5] or nil, -- 154
		currentTaskStatus = toStr(row[6]), -- 155
		createdAt = row[7], -- 156
		updatedAt = row[8] -- 157
	} -- 157
end -- 148
local function rowToMessage(row) -- 161
	return { -- 162
		id = row[1], -- 163
		sessionId = row[2], -- 164
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 165
		role = toStr(row[4]), -- 166
		kind = toStr(row[5]), -- 167
		content = toStr(row[6]), -- 168
		streaming = toBool(row[7]), -- 169
		createdAt = row[8], -- 170
		updatedAt = row[9] -- 171
	} -- 171
end -- 161
local function rowToStep(row) -- 175
	return { -- 176
		id = row[1], -- 177
		sessionId = row[2], -- 178
		taskId = row[3], -- 179
		step = row[4], -- 180
		tool = toStr(row[5]), -- 181
		status = toStr(row[6]), -- 182
		reason = toStr(row[7]), -- 183
		params = decodeJsonObject(toStr(row[8])), -- 184
		result = decodeJsonObject(toStr(row[9])), -- 185
		checkpointId = type(row[10]) == "number" and row[10] > 0 and row[10] or nil, -- 186
		checkpointSeq = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 187
		files = decodeJsonFiles(toStr(row[12])), -- 188
		createdAt = row[13], -- 189
		updatedAt = row[14] -- 190
	} -- 190
end -- 175
local function getSessionRow(sessionId) -- 194
	return queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 195
end -- 194
local function getSessionItem(sessionId) -- 203
	local row = getSessionRow(sessionId) -- 204
	return row and rowToSession(row) or nil -- 205
end -- 203
local function normalizeSessionRuntimeState(session) -- 208
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 208
		return session -- 210
	end -- 210
	if activeStopTokens[session.currentTaskId] then -- 210
		return session -- 213
	end -- 213
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 215
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 216
	return __TS__ObjectAssign( -- 217
		{}, -- 217
		session, -- 218
		{ -- 217
			status = "STOPPED", -- 219
			currentTaskStatus = "STOPPED", -- 220
			updatedAt = now() -- 221
		} -- 221
	) -- 221
end -- 208
local function trimSessionContext(text, maxChars) -- 225
	if #text <= maxChars then -- 225
		return text -- 226
	end -- 226
	local clipped = __TS__StringSlice(text, #text - maxChars) -- 227
	local newlinePos = (string.find(clipped, "\n", nil, true) or 0) - 1 -- 228
	return newlinePos >= 0 and __TS__StringSlice(clipped, newlinePos + 1) or clipped -- 229
end -- 225
local function buildSessionPromptContext(sessionId, useChineseResponse) -- 232
	local rows = queryRows(("SELECT role, kind, content\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND content <> ''\n\t\tORDER BY id DESC\n\t\tLIMIT ?", {sessionId, SESSION_CONTEXT_MAX_MESSAGES}) or ({}) -- 233
	if #rows == 0 then -- 233
		return "" -- 241
	end -- 241
	local messages = __TS__ArrayFilter( -- 242
		__TS__ArrayMap( -- 242
			__TS__ArrayReverse(__TS__ArraySlice(rows)), -- 242
			function(____, row) return { -- 245
				role = toStr(row[1]), -- 246
				kind = toStr(row[2]), -- 247
				content = __TS__StringTrim(toStr(row[3])) -- 248
			} end -- 248
		), -- 248
		function(____, message) return message.content ~= "" end -- 250
	) -- 250
	if #messages == 0 then -- 250
		return "" -- 251
	end -- 251
	local lines = {} -- 252
	lines[#lines + 1] = useChineseResponse and "以下是同一会话中之前的对话内容，请把它们作为当前请求的上下文参考。若与当前请求冲突，以当前请求为准。" or "Here is the prior conversation from the same session. Use it as context for the current request. If there is any conflict, prefer the current request." -- 253
	lines[#lines + 1] = "" -- 256
	do -- 256
		local i = 0 -- 257
		while i < #messages do -- 257
			local message = messages[i + 1] -- 258
			local speaker = message.role == "user" and (useChineseResponse and "用户" or "User") or (useChineseResponse and "助手" or "Assistant") -- 259
			lines[#lines + 1] = (speaker .. ": ") .. message.content -- 262
			i = i + 1 -- 257
		end -- 257
	end -- 257
	return trimSessionContext( -- 264
		table.concat(lines, "\n"), -- 264
		SESSION_CONTEXT_MAX_CHARS -- 264
	) -- 264
end -- 232
local function insertMessage(sessionId, role, kind, content, taskId, streaming) -- 282
	if streaming == nil then -- 282
		streaming = false -- 282
	end -- 282
	local t = now() -- 283
	DB:exec(("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, kind, content, streaming, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?)", { -- 284
		sessionId, -- 288
		taskId or 0, -- 289
		role, -- 290
		kind, -- 291
		content, -- 292
		streaming and 1 or 0, -- 293
		t, -- 294
		t -- 295
	}) -- 295
	return getLastInsertRowId() -- 298
end -- 282
local function updateMessage(messageId, content, streaming) -- 301
	DB:exec( -- 302
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, streaming = ?, updated_at = ? WHERE id = ?", -- 302
		{ -- 304
			content, -- 304
			streaming and 1 or 0, -- 304
			now(), -- 304
			messageId -- 304
		} -- 304
	) -- 304
end -- 301
local function getAssistantSummaryMessageId(taskId, sessionId) -- 308
	local cached = activeAssistantMessageIds[taskId] -- 309
	if cached ~= nil then -- 309
		return cached -- 310
	end -- 310
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ? AND kind = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant", "summary"}) -- 311
	if row and type(row[1]) == "number" then -- 311
		activeAssistantMessageIds[taskId] = row[1] -- 318
		return row[1] -- 319
	end -- 319
	local messageId = insertMessage( -- 321
		sessionId, -- 321
		"assistant", -- 321
		"summary", -- 321
		"", -- 321
		taskId, -- 321
		true -- 321
	) -- 321
	activeAssistantMessageIds[taskId] = messageId -- 322
	return messageId -- 323
end -- 308
local function upsertStep(sessionId, taskId, step, tool, patch) -- 326
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 335
	local reason = patch.reason or "" -- 339
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 340
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 341
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 342
	local status = patch.status or "PENDING" -- 343
	if not row then -- 343
		local t = now() -- 345
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 346
			sessionId, -- 350
			taskId, -- 351
			step, -- 352
			tool, -- 353
			status, -- 354
			reason, -- 355
			paramsJson, -- 356
			resultJson, -- 357
			patch.checkpointId or 0, -- 358
			patch.checkpointSeq or 0, -- 359
			filesJson, -- 360
			t, -- 361
			t -- 362
		}) -- 362
		return -- 365
	end -- 365
	DB:exec( -- 367
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 367
		{ -- 378
			tool, -- 379
			patch.status or "", -- 380
			status, -- 381
			reason, -- 382
			reason, -- 383
			paramsJson, -- 384
			paramsJson, -- 385
			resultJson, -- 386
			resultJson, -- 387
			patch.checkpointId or 0, -- 388
			patch.checkpointId or 0, -- 389
			patch.checkpointSeq or 0, -- 390
			patch.checkpointSeq or 0, -- 391
			filesJson, -- 392
			filesJson, -- 393
			now(), -- 394
			row[1] -- 395
		} -- 395
	) -- 395
end -- 326
local function applyEvent(sessionId, event) -- 400
	repeat -- 400
		local ____switch47 = event.type -- 400
		local ____cond47 = ____switch47 == "task_started" -- 400
		if ____cond47 then -- 400
			setSessionState(sessionId, "RUNNING", event.taskId, "RUNNING") -- 403
			break -- 404
		end -- 404
		____cond47 = ____cond47 or ____switch47 == "decision_made" -- 404
		if ____cond47 then -- 404
			upsertStep( -- 406
				sessionId, -- 406
				event.taskId, -- 406
				event.step, -- 406
				event.tool, -- 406
				{status = "PENDING", reason = event.reason, params = event.params} -- 406
			) -- 406
			break -- 411
		end -- 411
		____cond47 = ____cond47 or ____switch47 == "tool_started" -- 411
		if ____cond47 then -- 411
			upsertStep( -- 413
				sessionId, -- 413
				event.taskId, -- 413
				event.step, -- 413
				event.tool, -- 413
				{status = "RUNNING"} -- 413
			) -- 413
			break -- 416
		end -- 416
		____cond47 = ____cond47 or ____switch47 == "tool_finished" -- 416
		if ____cond47 then -- 416
			upsertStep( -- 418
				sessionId, -- 418
				event.taskId, -- 418
				event.step, -- 418
				event.tool, -- 418
				{status = "DONE", reason = event.reason, result = event.result} -- 418
			) -- 418
			break -- 423
		end -- 423
		____cond47 = ____cond47 or ____switch47 == "checkpoint_created" -- 423
		if ____cond47 then -- 423
			upsertStep( -- 425
				sessionId, -- 425
				event.taskId, -- 425
				event.step, -- 425
				event.tool, -- 425
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 425
			) -- 425
			break -- 430
		end -- 430
		____cond47 = ____cond47 or ____switch47 == "summary_stream" -- 430
		if ____cond47 then -- 430
			do -- 430
				local messageId = getAssistantSummaryMessageId(event.taskId, sessionId) -- 432
				local row = queryOne(("SELECT content FROM " .. TABLE_MESSAGE) .. " WHERE id = ?", {messageId}) -- 433
				local oldContent = row and toStr(row[1]) or "" -- 434
				local nextContent = oldContent .. event.textDelta -- 435
				updateMessage(messageId, nextContent, true) -- 436
				break -- 437
			end -- 437
		end -- 437
		____cond47 = ____cond47 or ____switch47 == "task_finished" -- 437
		if ____cond47 then -- 437
			do -- 437
				local ____event_success_3 -- 440
				if event.success then -- 440
					____event_success_3 = "DONE" -- 441
				else -- 441
					local ____opt_1 = activeStopTokens[event.taskId or -1] -- 441
					____event_success_3 = ____opt_1 and ____opt_1.stopped and "STOPPED" or "FAILED" -- 442
				end -- 442
				local finalStatus = ____event_success_3 -- 440
				setSessionState(sessionId, finalStatus, event.taskId, finalStatus) -- 443
				if event.taskId ~= nil then -- 443
					local messageId = getAssistantSummaryMessageId(event.taskId, sessionId) -- 445
					local row = queryOne(("SELECT content FROM " .. TABLE_MESSAGE) .. " WHERE id = ?", {messageId}) -- 446
					local content = row and toStr(row[1]) or "" -- 447
					updateMessage(messageId, content ~= "" and content or event.message, false) -- 448
					activeStopTokens[event.taskId] = nil -- 449
					activeAssistantMessageIds[event.taskId] = nil -- 450
				end -- 450
				break -- 452
			end -- 452
		end -- 452
	until true -- 452
end -- 400
do -- 400
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 459
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 469
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tkind TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tstreaming INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 470
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 481
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 482
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 498
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 499
end -- 499
function ____exports.createSession(projectRoot, title) -- 502
	if title == nil then -- 502
		title = "" -- 502
	end -- 502
	if not isValidProjectRoot(projectRoot) then -- 502
		return {success = false, message = "invalid projectRoot"} -- 504
	end -- 504
	local row = queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ?\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 506
	if row then -- 506
		return { -- 515
			success = true, -- 515
			session = rowToSession(row) -- 515
		} -- 515
	end -- 515
	local t = now() -- 517
	DB:exec( -- 518
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'IDLE', 'IDLE', ?, ?)", -- 518
		{ -- 521
			projectRoot, -- 521
			title ~= "" and title or Path:getFilename(projectRoot), -- 521
			t, -- 521
			t -- 521
		} -- 521
	) -- 521
	local session = getSessionItem(getLastInsertRowId()) -- 523
	if not session then -- 523
		return {success = false, message = "failed to create session"} -- 525
	end -- 525
	return {success = true, session = session} -- 527
end -- 502
function ____exports.getSession(sessionId) -- 530
	local session = getSessionItem(sessionId) -- 531
	if not session then -- 531
		return {success = false, message = "session not found"} -- 533
	end -- 533
	local normalizedSession = normalizeSessionRuntimeState(session) -- 535
	local messages = queryRows(("SELECT id, session_id, task_id, role, kind, content, streaming, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 536
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 543
	return { -- 550
		success = true, -- 551
		session = normalizedSession, -- 552
		messages = __TS__ArrayMap( -- 553
			messages, -- 553
			function(____, row) return rowToMessage(row) end -- 553
		), -- 553
		steps = __TS__ArrayMap( -- 554
			steps, -- 554
			function(____, row) return rowToStep(row) end -- 554
		) -- 554
	} -- 554
end -- 530
function ____exports.sendPrompt(sessionId, prompt, useChineseResponse) -- 558
	if useChineseResponse == nil then -- 558
		useChineseResponse = true -- 558
	end -- 558
	local session = getSessionItem(sessionId) -- 559
	if not session then -- 559
		return {success = false, message = "session not found"} -- 561
	end -- 561
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 561
		return {success = false, message = "session task is still running"} -- 564
	end -- 564
	local taskRes = Tools.createTask(prompt) -- 566
	if not taskRes.success then -- 566
		return {success = false, message = taskRes.message} -- 568
	end -- 568
	local taskId = taskRes.taskId -- 570
	local sessionContext = buildSessionPromptContext(sessionId, useChineseResponse) -- 571
	local agentPrompt = sessionContext ~= "" and (((sessionContext .. "\n\n") .. (useChineseResponse and "当前用户请求：" or "Current user request:")) .. "\n") .. prompt or prompt -- 572
	insertMessage( -- 575
		sessionId, -- 575
		"user", -- 575
		"message", -- 575
		prompt, -- 575
		taskId, -- 575
		false -- 575
	) -- 575
	local assistantMessageId = insertMessage( -- 576
		sessionId, -- 576
		"assistant", -- 576
		"summary", -- 576
		"", -- 576
		taskId, -- 576
		true -- 576
	) -- 576
	activeAssistantMessageIds[taskId] = assistantMessageId -- 577
	local stopToken = {stopped = false} -- 578
	activeStopTokens[taskId] = stopToken -- 579
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 580
	runCodingAgent( -- 581
		{ -- 581
			prompt = agentPrompt, -- 582
			workDir = session.projectRoot, -- 583
			useChineseResponse = useChineseResponse, -- 584
			taskId = taskId, -- 585
			sessionId = sessionId, -- 586
			stopToken = stopToken, -- 587
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 588
		}, -- 588
		function(result) -- 589
			if not result.success then -- 589
				applyEvent(sessionId, { -- 591
					type = "task_finished", -- 592
					sessionId = sessionId, -- 593
					taskId = result.taskId, -- 594
					success = false, -- 595
					message = result.message, -- 596
					steps = result.steps -- 597
				}) -- 597
			end -- 597
		end -- 589
	) -- 589
	return {success = true, sessionId = sessionId, taskId = taskId} -- 601
end -- 558
function ____exports.stopSessionTask(sessionId) -- 604
	local session = getSessionItem(sessionId) -- 605
	if not session or session.currentTaskId == nil then -- 605
		return {success = false, message = "session task not found"} -- 607
	end -- 607
	local normalizedSession = normalizeSessionRuntimeState(session) -- 609
	local stopToken = activeStopTokens[session.currentTaskId] -- 610
	if not stopToken then -- 610
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 610
			return {success = true, recovered = true} -- 613
		end -- 613
		return {success = false, message = "task is not running"} -- 615
	end -- 615
	stopToken.stopped = true -- 617
	stopToken.reason = "stopped by user" -- 618
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 619
	return {success = true} -- 620
end -- 604
function ____exports.getCurrentTaskId(sessionId) -- 623
	local ____opt_4 = getSessionItem(sessionId) -- 623
	return ____opt_4 and ____opt_4.currentTaskId -- 624
end -- 623
function ____exports.listRunningSessions() -- 627
	local rows = queryRows(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 628
	local sessions = {} -- 635
	do -- 635
		local i = 0 -- 636
		while i < #rows do -- 636
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 637
			if session.currentTaskStatus == "RUNNING" then -- 637
				sessions[#sessions + 1] = session -- 639
			end -- 639
			i = i + 1 -- 636
		end -- 636
	end -- 636
	return {success = true, sessions = sessions} -- 642
end -- 627
return ____exports -- 627