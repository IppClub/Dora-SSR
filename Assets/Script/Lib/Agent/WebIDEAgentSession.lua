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
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local json = ____Dora.json -- 2
local ____CodingAgent = require("Agent.CodingAgent") -- 3
local runCodingAgent = ____CodingAgent.runCodingAgent -- 3
local Tools = require("Agent.Tools") -- 4
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 272
	DB:exec( -- 273
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 273
		{ -- 277
			status, -- 278
			currentTaskId or 0, -- 279
			currentTaskStatus or status, -- 280
			now(), -- 281
			sessionId -- 282
		} -- 282
	) -- 282
end -- 282
TABLE_SESSION = "AgentSession" -- 79
local TABLE_MESSAGE = "AgentSessionMessage" -- 80
local TABLE_STEP = "AgentSessionStep" -- 81
local SESSION_CONTEXT_MAX_MESSAGES = 12 -- 82
local SESSION_CONTEXT_MAX_CHARS = 12000 -- 83
local activeStopTokens = {} -- 85
local activeAssistantMessageIds = {} -- 86
now = function() return os.time() end -- 88
local function getDefaultUseChineseResponse() -- 90
	local zh = string.match(App.locale, "^zh") -- 91
	return zh ~= nil -- 92
end -- 90
local function toBool(v) -- 95
	return v ~= 0 and v ~= false and v ~= nil and v ~= nil -- 96
end -- 95
local function toStr(v) -- 99
	if v == false or v == nil or v == nil then -- 99
		return "" -- 100
	end -- 100
	return tostring(v) -- 101
end -- 99
local function encodeJson(value) -- 104
	local text = json.encode(value) -- 105
	return text or "" -- 106
end -- 104
local function decodeJsonObject(text) -- 109
	if not text or text == "" then -- 109
		return nil -- 110
	end -- 110
	local value = json.decode(text) -- 111
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 111
		return value -- 113
	end -- 113
	return nil -- 115
end -- 109
local function decodeJsonFiles(text) -- 118
	if not text or text == "" then -- 118
		return nil -- 119
	end -- 119
	local value = json.decode(text) -- 120
	if not value or not __TS__ArrayIsArray(value) then -- 120
		return nil -- 121
	end -- 121
	local files = {} -- 122
	do -- 122
		local i = 0 -- 123
		while i < #value do -- 123
			do -- 123
				local item = value[i + 1] -- 124
				if type(item) ~= "table" then -- 124
					goto __continue15 -- 125
				end -- 125
				files[#files + 1] = { -- 126
					path = toStr(item.path), -- 127
					op = toStr(item.op) -- 128
				} -- 128
			end -- 128
			::__continue15:: -- 128
			i = i + 1 -- 123
		end -- 123
	end -- 123
	return files -- 131
end -- 118
local function queryRows(sql, args) -- 134
	local ____args_0 -- 135
	if args then -- 135
		____args_0 = DB:query(sql, args) -- 135
	else -- 135
		____args_0 = DB:query(sql) -- 135
	end -- 135
	return ____args_0 -- 135
end -- 134
local function queryOne(sql, args) -- 138
	local rows = queryRows(sql, args) -- 139
	if not rows or #rows == 0 then -- 139
		return nil -- 140
	end -- 140
	return rows[1] -- 141
end -- 138
local function getLastInsertRowId() -- 144
	local row = queryOne("SELECT last_insert_rowid()") -- 145
	return row and (row[1] or 0) or 0 -- 146
end -- 144
local function isValidProjectRoot(path) -- 149
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 150
end -- 149
local function rowToSession(row) -- 153
	return { -- 154
		id = row[1], -- 155
		projectRoot = toStr(row[2]), -- 156
		title = toStr(row[3]), -- 157
		status = toStr(row[4]), -- 158
		currentTaskId = type(row[5]) == "number" and row[5] > 0 and row[5] or nil, -- 159
		currentTaskStatus = toStr(row[6]), -- 160
		createdAt = row[7], -- 161
		updatedAt = row[8] -- 162
	} -- 162
end -- 153
local function rowToMessage(row) -- 166
	return { -- 167
		id = row[1], -- 168
		sessionId = row[2], -- 169
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 170
		role = toStr(row[4]), -- 171
		kind = toStr(row[5]), -- 172
		content = toStr(row[6]), -- 173
		streaming = toBool(row[7]), -- 174
		createdAt = row[8], -- 175
		updatedAt = row[9] -- 176
	} -- 176
end -- 166
local function rowToStep(row) -- 180
	return { -- 181
		id = row[1], -- 182
		sessionId = row[2], -- 183
		taskId = row[3], -- 184
		step = row[4], -- 185
		tool = toStr(row[5]), -- 186
		status = toStr(row[6]), -- 187
		reason = toStr(row[7]), -- 188
		params = decodeJsonObject(toStr(row[8])), -- 189
		result = decodeJsonObject(toStr(row[9])), -- 190
		checkpointId = type(row[10]) == "number" and row[10] > 0 and row[10] or nil, -- 191
		checkpointSeq = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 192
		files = decodeJsonFiles(toStr(row[12])), -- 193
		createdAt = row[13], -- 194
		updatedAt = row[14] -- 195
	} -- 195
end -- 180
local function getSessionRow(sessionId) -- 199
	return queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 200
end -- 199
local function getSessionItem(sessionId) -- 208
	local row = getSessionRow(sessionId) -- 209
	return row and rowToSession(row) or nil -- 210
end -- 208
local function normalizeSessionRuntimeState(session) -- 213
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 213
		return session -- 215
	end -- 215
	if activeStopTokens[session.currentTaskId] then -- 215
		return session -- 218
	end -- 218
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 220
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 221
	return __TS__ObjectAssign( -- 222
		{}, -- 222
		session, -- 223
		{ -- 222
			status = "STOPPED", -- 224
			currentTaskStatus = "STOPPED", -- 225
			updatedAt = now() -- 226
		} -- 226
	) -- 226
end -- 213
local function trimSessionContext(text, maxChars) -- 230
	if #text <= maxChars then -- 230
		return text -- 231
	end -- 231
	local clipped = __TS__StringSlice(text, #text - maxChars) -- 232
	local newlinePos = (string.find(clipped, "\n", nil, true) or 0) - 1 -- 233
	return newlinePos >= 0 and __TS__StringSlice(clipped, newlinePos + 1) or clipped -- 234
end -- 230
local function buildSessionPromptContext(sessionId, useChineseResponse) -- 237
	local rows = queryRows(("SELECT role, kind, content\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND content <> ''\n\t\tORDER BY id DESC\n\t\tLIMIT ?", {sessionId, SESSION_CONTEXT_MAX_MESSAGES}) or ({}) -- 238
	if #rows == 0 then -- 238
		return "" -- 246
	end -- 246
	local messages = __TS__ArrayFilter( -- 247
		__TS__ArrayMap( -- 247
			__TS__ArrayReverse(__TS__ArraySlice(rows)), -- 247
			function(____, row) return { -- 250
				role = toStr(row[1]), -- 251
				kind = toStr(row[2]), -- 252
				content = __TS__StringTrim(toStr(row[3])) -- 253
			} end -- 253
		), -- 253
		function(____, message) return message.content ~= "" end -- 255
	) -- 255
	if #messages == 0 then -- 255
		return "" -- 256
	end -- 256
	local lines = {} -- 257
	lines[#lines + 1] = useChineseResponse and "以下是同一会话中之前的对话内容，请把它们作为当前请求的上下文参考。若与当前请求冲突，以当前请求为准。" or "Here is the prior conversation from the same session. Use it as context for the current request. If there is any conflict, prefer the current request." -- 258
	lines[#lines + 1] = "" -- 261
	do -- 261
		local i = 0 -- 262
		while i < #messages do -- 262
			local message = messages[i + 1] -- 263
			local speaker = message.role == "user" and (useChineseResponse and "用户" or "User") or (useChineseResponse and "助手" or "Assistant") -- 264
			lines[#lines + 1] = (speaker .. ": ") .. message.content -- 267
			i = i + 1 -- 262
		end -- 262
	end -- 262
	return trimSessionContext( -- 269
		table.concat(lines, "\n"), -- 269
		SESSION_CONTEXT_MAX_CHARS -- 269
	) -- 269
end -- 237
local function insertMessage(sessionId, role, kind, content, taskId, streaming) -- 287
	if streaming == nil then -- 287
		streaming = false -- 287
	end -- 287
	local t = now() -- 288
	DB:exec(("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, kind, content, streaming, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?)", { -- 289
		sessionId, -- 293
		taskId or 0, -- 294
		role, -- 295
		kind, -- 296
		content, -- 297
		streaming and 1 or 0, -- 298
		t, -- 299
		t -- 300
	}) -- 300
	return getLastInsertRowId() -- 303
end -- 287
local function updateMessage(messageId, content, streaming) -- 306
	DB:exec( -- 307
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, streaming = ?, updated_at = ? WHERE id = ?", -- 307
		{ -- 309
			content, -- 309
			streaming and 1 or 0, -- 309
			now(), -- 309
			messageId -- 309
		} -- 309
	) -- 309
end -- 306
local function getAssistantSummaryMessageId(taskId, sessionId) -- 313
	local cached = activeAssistantMessageIds[taskId] -- 314
	if cached ~= nil then -- 314
		return cached -- 315
	end -- 315
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ? AND kind = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant", "summary"}) -- 316
	if row and type(row[1]) == "number" then -- 316
		activeAssistantMessageIds[taskId] = row[1] -- 323
		return row[1] -- 324
	end -- 324
	local messageId = insertMessage( -- 326
		sessionId, -- 326
		"assistant", -- 326
		"summary", -- 326
		"", -- 326
		taskId, -- 326
		true -- 326
	) -- 326
	activeAssistantMessageIds[taskId] = messageId -- 327
	return messageId -- 328
end -- 313
local function upsertStep(sessionId, taskId, step, tool, patch) -- 331
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 340
	local reason = patch.reason or "" -- 344
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 345
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 346
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 347
	local status = patch.status or "PENDING" -- 348
	if not row then -- 348
		local t = now() -- 350
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 351
			sessionId, -- 355
			taskId, -- 356
			step, -- 357
			tool, -- 358
			status, -- 359
			reason, -- 360
			paramsJson, -- 361
			resultJson, -- 362
			patch.checkpointId or 0, -- 363
			patch.checkpointSeq or 0, -- 364
			filesJson, -- 365
			t, -- 366
			t -- 367
		}) -- 367
		return -- 370
	end -- 370
	DB:exec( -- 372
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 372
		{ -- 383
			tool, -- 384
			patch.status or "", -- 385
			status, -- 386
			reason, -- 387
			reason, -- 388
			paramsJson, -- 389
			paramsJson, -- 390
			resultJson, -- 391
			resultJson, -- 392
			patch.checkpointId or 0, -- 393
			patch.checkpointId or 0, -- 394
			patch.checkpointSeq or 0, -- 395
			patch.checkpointSeq or 0, -- 396
			filesJson, -- 397
			filesJson, -- 398
			now(), -- 399
			row[1] -- 400
		} -- 400
	) -- 400
end -- 331
local function applyEvent(sessionId, event) -- 405
	repeat -- 405
		local ____switch48 = event.type -- 405
		local ____cond48 = ____switch48 == "task_started" -- 405
		if ____cond48 then -- 405
			setSessionState(sessionId, "RUNNING", event.taskId, "RUNNING") -- 408
			break -- 409
		end -- 409
		____cond48 = ____cond48 or ____switch48 == "decision_made" -- 409
		if ____cond48 then -- 409
			upsertStep( -- 411
				sessionId, -- 411
				event.taskId, -- 411
				event.step, -- 411
				event.tool, -- 411
				{status = "PENDING", reason = event.reason, params = event.params} -- 411
			) -- 411
			break -- 416
		end -- 416
		____cond48 = ____cond48 or ____switch48 == "tool_started" -- 416
		if ____cond48 then -- 416
			upsertStep( -- 418
				sessionId, -- 418
				event.taskId, -- 418
				event.step, -- 418
				event.tool, -- 418
				{status = "RUNNING"} -- 418
			) -- 418
			break -- 421
		end -- 421
		____cond48 = ____cond48 or ____switch48 == "tool_finished" -- 421
		if ____cond48 then -- 421
			upsertStep( -- 423
				sessionId, -- 423
				event.taskId, -- 423
				event.step, -- 423
				event.tool, -- 423
				{status = "DONE", reason = event.reason, result = event.result} -- 423
			) -- 423
			break -- 428
		end -- 428
		____cond48 = ____cond48 or ____switch48 == "checkpoint_created" -- 428
		if ____cond48 then -- 428
			upsertStep( -- 430
				sessionId, -- 430
				event.taskId, -- 430
				event.step, -- 430
				event.tool, -- 430
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 430
			) -- 430
			break -- 435
		end -- 435
		____cond48 = ____cond48 or ____switch48 == "summary_stream" -- 435
		if ____cond48 then -- 435
			do -- 435
				local messageId = getAssistantSummaryMessageId(event.taskId, sessionId) -- 437
				local row = queryOne(("SELECT content FROM " .. TABLE_MESSAGE) .. " WHERE id = ?", {messageId}) -- 438
				local oldContent = row and toStr(row[1]) or "" -- 439
				local nextContent = oldContent .. event.textDelta -- 440
				updateMessage(messageId, nextContent, true) -- 441
				break -- 442
			end -- 442
		end -- 442
		____cond48 = ____cond48 or ____switch48 == "task_finished" -- 442
		if ____cond48 then -- 442
			do -- 442
				local ____event_success_3 -- 445
				if event.success then -- 445
					____event_success_3 = "DONE" -- 446
				else -- 446
					local ____opt_1 = activeStopTokens[event.taskId or -1] -- 446
					____event_success_3 = ____opt_1 and ____opt_1.stopped and "STOPPED" or "FAILED" -- 447
				end -- 447
				local finalStatus = ____event_success_3 -- 445
				setSessionState(sessionId, finalStatus, event.taskId, finalStatus) -- 448
				if event.taskId ~= nil then -- 448
					local messageId = getAssistantSummaryMessageId(event.taskId, sessionId) -- 450
					local row = queryOne(("SELECT content FROM " .. TABLE_MESSAGE) .. " WHERE id = ?", {messageId}) -- 451
					local content = row and toStr(row[1]) or "" -- 452
					updateMessage(messageId, content ~= "" and content or event.message, false) -- 453
					activeStopTokens[event.taskId] = nil -- 454
					activeAssistantMessageIds[event.taskId] = nil -- 455
				end -- 455
				break -- 457
			end -- 457
		end -- 457
	until true -- 457
end -- 405
do -- 405
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 464
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 474
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tkind TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tstreaming INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 475
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 486
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 487
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 503
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 504
end -- 504
function ____exports.createSession(projectRoot, title) -- 507
	if title == nil then -- 507
		title = "" -- 507
	end -- 507
	if not isValidProjectRoot(projectRoot) then -- 507
		return {success = false, message = "invalid projectRoot"} -- 509
	end -- 509
	local row = queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ?\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 511
	if row then -- 511
		return { -- 520
			success = true, -- 520
			session = rowToSession(row) -- 520
		} -- 520
	end -- 520
	local t = now() -- 522
	DB:exec( -- 523
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'IDLE', 'IDLE', ?, ?)", -- 523
		{ -- 526
			projectRoot, -- 526
			title ~= "" and title or Path:getFilename(projectRoot), -- 526
			t, -- 526
			t -- 526
		} -- 526
	) -- 526
	local session = getSessionItem(getLastInsertRowId()) -- 528
	if not session then -- 528
		return {success = false, message = "failed to create session"} -- 530
	end -- 530
	return {success = true, session = session} -- 532
end -- 507
function ____exports.getSession(sessionId) -- 535
	local session = getSessionItem(sessionId) -- 536
	if not session then -- 536
		return {success = false, message = "session not found"} -- 538
	end -- 538
	local normalizedSession = normalizeSessionRuntimeState(session) -- 540
	local messages = queryRows(("SELECT id, session_id, task_id, role, kind, content, streaming, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 541
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 548
	return { -- 555
		success = true, -- 556
		session = normalizedSession, -- 557
		messages = __TS__ArrayMap( -- 558
			messages, -- 558
			function(____, row) return rowToMessage(row) end -- 558
		), -- 558
		steps = __TS__ArrayMap( -- 559
			steps, -- 559
			function(____, row) return rowToStep(row) end -- 559
		) -- 559
	} -- 559
end -- 535
function ____exports.sendPrompt(sessionId, prompt, useChineseResponse) -- 563
	if useChineseResponse == nil then -- 563
		useChineseResponse = getDefaultUseChineseResponse() -- 563
	end -- 563
	local session = getSessionItem(sessionId) -- 564
	if not session then -- 564
		return {success = false, message = "session not found"} -- 566
	end -- 566
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 566
		return {success = false, message = "session task is still running"} -- 569
	end -- 569
	local taskRes = Tools.createTask(prompt) -- 571
	if not taskRes.success then -- 571
		return {success = false, message = taskRes.message} -- 573
	end -- 573
	local taskId = taskRes.taskId -- 575
	local sessionContext = buildSessionPromptContext(sessionId, useChineseResponse) -- 576
	local agentPrompt = sessionContext ~= "" and (((sessionContext .. "\n\n") .. (useChineseResponse and "当前用户请求：" or "Current user request:")) .. "\n") .. prompt or prompt -- 577
	insertMessage( -- 580
		sessionId, -- 580
		"user", -- 580
		"message", -- 580
		prompt, -- 580
		taskId, -- 580
		false -- 580
	) -- 580
	local assistantMessageId = insertMessage( -- 581
		sessionId, -- 581
		"assistant", -- 581
		"summary", -- 581
		"", -- 581
		taskId, -- 581
		true -- 581
	) -- 581
	activeAssistantMessageIds[taskId] = assistantMessageId -- 582
	local stopToken = {stopped = false} -- 583
	activeStopTokens[taskId] = stopToken -- 584
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 585
	runCodingAgent( -- 586
		{ -- 586
			prompt = agentPrompt, -- 587
			workDir = session.projectRoot, -- 588
			useChineseResponse = useChineseResponse, -- 589
			taskId = taskId, -- 590
			sessionId = sessionId, -- 591
			stopToken = stopToken, -- 592
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 593
		}, -- 593
		function(result) -- 594
			if not result.success then -- 594
				applyEvent(sessionId, { -- 596
					type = "task_finished", -- 597
					sessionId = sessionId, -- 598
					taskId = result.taskId, -- 599
					success = false, -- 600
					message = result.message, -- 601
					steps = result.steps -- 602
				}) -- 602
			end -- 602
		end -- 594
	) -- 594
	return {success = true, sessionId = sessionId, taskId = taskId} -- 606
end -- 563
function ____exports.stopSessionTask(sessionId) -- 609
	local session = getSessionItem(sessionId) -- 610
	if not session or session.currentTaskId == nil then -- 610
		return {success = false, message = "session task not found"} -- 612
	end -- 612
	local normalizedSession = normalizeSessionRuntimeState(session) -- 614
	local stopToken = activeStopTokens[session.currentTaskId] -- 615
	if not stopToken then -- 615
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 615
			return {success = true, recovered = true} -- 618
		end -- 618
		return {success = false, message = "task is not running"} -- 620
	end -- 620
	stopToken.stopped = true -- 622
	stopToken.reason = "stopped by user" -- 623
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 624
	return {success = true} -- 625
end -- 609
function ____exports.getCurrentTaskId(sessionId) -- 628
	local ____opt_4 = getSessionItem(sessionId) -- 628
	return ____opt_4 and ____opt_4.currentTaskId -- 629
end -- 628
function ____exports.listRunningSessions() -- 632
	local rows = queryRows(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 633
	local sessions = {} -- 640
	do -- 640
		local i = 0 -- 641
		while i < #rows do -- 641
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 642
			if session.currentTaskStatus == "RUNNING" then -- 642
				sessions[#sessions + 1] = session -- 644
			end -- 644
			i = i + 1 -- 641
		end -- 641
	end -- 641
	return {success = true, sessions = sessions} -- 647
end -- 632
return ____exports -- 632