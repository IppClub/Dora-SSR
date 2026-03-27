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
local clipTextToTokenBudget = ____Utils.clipTextToTokenBudget -- 5
local estimateTextTokens = ____Utils.estimateTextTokens -- 5
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 5
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 285
	DB:exec( -- 286
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 286
		{ -- 290
			status, -- 291
			currentTaskId or 0, -- 292
			currentTaskStatus or status, -- 293
			now(), -- 294
			sessionId -- 295
		} -- 295
	) -- 295
end -- 295
TABLE_SESSION = "AgentSession" -- 82
local TABLE_MESSAGE = "AgentSessionMessage" -- 83
local TABLE_STEP = "AgentSessionStep" -- 84
local TABLE_TASK = "AgentTask" -- 85
local SESSION_CONTEXT_MAX_MESSAGES = 12 -- 86
local SESSION_CONTEXT_MAX_CHARS = 12000 -- 87
local activeStopTokens = {} -- 89
local activeAssistantMessageIds = {} -- 90
now = function() return os.time() end -- 91
local function getDefaultUseChineseResponse() -- 93
	local zh = string.match(App.locale, "^zh") -- 94
	return zh ~= nil -- 95
end -- 93
local function toBool(v) -- 98
	return v ~= 0 and v ~= false and v ~= nil and v ~= nil -- 99
end -- 98
local function toStr(v) -- 102
	if v == false or v == nil or v == nil then -- 102
		return "" -- 103
	end -- 103
	return tostring(v) -- 104
end -- 102
local function encodeJson(value) -- 107
	local text = json.encode(value) -- 108
	return text or "" -- 109
end -- 107
local function decodeJsonObject(text) -- 112
	if not text or text == "" then -- 112
		return nil -- 113
	end -- 113
	local value = json.decode(text) -- 114
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 114
		return value -- 116
	end -- 116
	return nil -- 118
end -- 112
local function decodeJsonFiles(text) -- 121
	if not text or text == "" then -- 121
		return nil -- 122
	end -- 122
	local value = json.decode(text) -- 123
	if not value or not __TS__ArrayIsArray(value) then -- 123
		return nil -- 124
	end -- 124
	local files = {} -- 125
	do -- 125
		local i = 0 -- 126
		while i < #value do -- 126
			do -- 126
				local item = value[i + 1] -- 127
				if type(item) ~= "table" then -- 127
					goto __continue15 -- 128
				end -- 128
				files[#files + 1] = { -- 129
					path = toStr(item.path), -- 130
					op = toStr(item.op) -- 131
				} -- 131
			end -- 131
			::__continue15:: -- 131
			i = i + 1 -- 126
		end -- 126
	end -- 126
	return files -- 134
end -- 121
local function queryRows(sql, args) -- 137
	local ____args_0 -- 138
	if args then -- 138
		____args_0 = DB:query(sql, args) -- 138
	else -- 138
		____args_0 = DB:query(sql) -- 138
	end -- 138
	return ____args_0 -- 138
end -- 137
local function queryOne(sql, args) -- 141
	local rows = queryRows(sql, args) -- 142
	if not rows or #rows == 0 then -- 142
		return nil -- 143
	end -- 143
	return rows[1] -- 144
end -- 141
local function getLastInsertRowId() -- 147
	local row = queryOne("SELECT last_insert_rowid()") -- 148
	return row and (row[1] or 0) or 0 -- 149
end -- 147
local function isValidProjectRoot(path) -- 152
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 153
end -- 152
local function rowToSession(row) -- 156
	return { -- 157
		id = row[1], -- 158
		projectRoot = toStr(row[2]), -- 159
		title = toStr(row[3]), -- 160
		status = toStr(row[4]), -- 161
		currentTaskId = type(row[5]) == "number" and row[5] > 0 and row[5] or nil, -- 162
		currentTaskStatus = toStr(row[6]), -- 163
		createdAt = row[7], -- 164
		updatedAt = row[8] -- 165
	} -- 165
end -- 156
local function rowToMessage(row) -- 169
	return { -- 170
		id = row[1], -- 171
		sessionId = row[2], -- 172
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 173
		role = toStr(row[4]), -- 174
		kind = toStr(row[5]), -- 175
		content = toStr(row[6]), -- 176
		streaming = toBool(row[7]), -- 177
		createdAt = row[8], -- 178
		updatedAt = row[9] -- 179
	} -- 179
end -- 169
local function rowToStep(row) -- 183
	return { -- 184
		id = row[1], -- 185
		sessionId = row[2], -- 186
		taskId = row[3], -- 187
		step = row[4], -- 188
		tool = toStr(row[5]), -- 189
		status = toStr(row[6]), -- 190
		reason = toStr(row[7]), -- 191
		reasoningContent = toStr(row[8]), -- 192
		params = decodeJsonObject(toStr(row[9])), -- 193
		result = decodeJsonObject(toStr(row[10])), -- 194
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 195
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 196
		files = decodeJsonFiles(toStr(row[13])), -- 197
		createdAt = row[14], -- 198
		updatedAt = row[15] -- 199
	} -- 199
end -- 183
local function getSessionRow(sessionId) -- 203
	return queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 204
end -- 203
local function getSessionItem(sessionId) -- 212
	local row = getSessionRow(sessionId) -- 213
	return row and rowToSession(row) or nil -- 214
end -- 212
local function normalizeSessionRuntimeState(session) -- 217
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 217
		return session -- 219
	end -- 219
	if activeStopTokens[session.currentTaskId] then -- 219
		return session -- 222
	end -- 222
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 224
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 225
	return __TS__ObjectAssign( -- 226
		{}, -- 226
		session, -- 227
		{ -- 226
			status = "STOPPED", -- 228
			currentTaskStatus = "STOPPED", -- 229
			updatedAt = now() -- 230
		} -- 230
	) -- 230
end -- 217
local function trimSessionContext(text, maxChars) -- 234
	if #text <= maxChars then -- 234
		return text -- 235
	end -- 235
	local clipped = __TS__StringSlice(text, #text - maxChars) -- 236
	local newlinePos = (string.find(clipped, "\n", nil, true) or 0) - 1 -- 237
	return newlinePos >= 0 and __TS__StringSlice(clipped, newlinePos + 1) or clipped -- 238
end -- 234
local function buildSessionPromptContext(sessionId, useChineseResponse, llmConfig) -- 241
	local rows = queryRows(("SELECT role, kind, content\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND content <> ''\n\t\tORDER BY id DESC\n\t\tLIMIT ?", {sessionId, SESSION_CONTEXT_MAX_MESSAGES}) or ({}) -- 242
	if #rows == 0 then -- 242
		return "" -- 250
	end -- 250
	local messages = __TS__ArrayFilter( -- 251
		__TS__ArrayMap( -- 251
			__TS__ArrayReverse(__TS__ArraySlice(rows)), -- 251
			function(____, row) return { -- 254
				role = toStr(row[1]), -- 255
				kind = toStr(row[2]), -- 256
				content = __TS__StringTrim(toStr(row[3])) -- 257
			} end -- 257
		), -- 257
		function(____, message) return message.content ~= "" end -- 259
	) -- 259
	if #messages == 0 then -- 259
		return "" -- 260
	end -- 260
	local lines = {} -- 261
	lines[#lines + 1] = useChineseResponse and "以下是同一会话中之前的对话内容，请把它们作为当前请求的上下文参考。若与当前请求冲突，以当前请求为准。" or "Here is the prior conversation from the same session. Use it as context for the current request. If there is any conflict, prefer the current request." -- 262
	lines[#lines + 1] = "" -- 265
	do -- 265
		local i = 0 -- 266
		while i < #messages do -- 266
			local message = messages[i + 1] -- 267
			local speaker = message.role == "user" and (useChineseResponse and "用户" or "User") or (useChineseResponse and "助手" or "Assistant") -- 268
			lines[#lines + 1] = (speaker .. ": ") .. message.content -- 271
			i = i + 1 -- 266
		end -- 266
	end -- 266
	local text = trimSessionContext( -- 273
		table.concat(lines, "\n"), -- 273
		SESSION_CONTEXT_MAX_CHARS -- 273
	) -- 273
	if llmConfig then -- 273
		local contextBudget = math.max( -- 275
			600, -- 275
			math.min( -- 275
				2400, -- 275
				math.floor(math.max(4000, llmConfig.contextWindow) * 0.15) -- 275
			) -- 275
		) -- 275
		local estimated = estimateTextTokens(text) -- 276
		if estimated > contextBudget then -- 276
			text = clipTextToTokenBudget(text, contextBudget) -- 278
			Log( -- 279
				"Info", -- 279
				(("[AgentSession] trimmed session context tokens=" .. tostring(estimated)) .. " budget=") .. tostring(contextBudget) -- 279
			) -- 279
		end -- 279
	end -- 279
	return text -- 282
end -- 241
local function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 300
	if taskId == nil or taskId <= 0 then -- 300
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 302
		return -- 303
	end -- 303
	local row = getSessionRow(sessionId) -- 305
	if not row then -- 305
		return -- 306
	end -- 306
	local session = rowToSession(row) -- 307
	if session.currentTaskId ~= taskId then -- 307
		Log( -- 309
			"Info", -- 309
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 309
		) -- 309
		return -- 310
	end -- 310
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 312
end -- 300
local function insertMessage(sessionId, role, kind, content, taskId, streaming) -- 315
	if streaming == nil then -- 315
		streaming = false -- 315
	end -- 315
	local t = now() -- 316
	DB:exec(("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, kind, content, streaming, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?)", { -- 317
		sessionId, -- 321
		taskId or 0, -- 322
		role, -- 323
		kind, -- 324
		content, -- 325
		streaming and 1 or 0, -- 326
		t, -- 327
		t -- 328
	}) -- 328
	return getLastInsertRowId() -- 331
end -- 315
local function updateMessage(messageId, content, streaming) -- 334
	DB:exec( -- 335
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, streaming = ?, updated_at = ? WHERE id = ?", -- 335
		{ -- 337
			content, -- 337
			streaming and 1 or 0, -- 337
			now(), -- 337
			messageId -- 337
		} -- 337
	) -- 337
end -- 334
local function getAssistantSummaryMessageId(taskId, sessionId) -- 341
	local cached = activeAssistantMessageIds[taskId] -- 342
	if cached ~= nil then -- 342
		return cached -- 343
	end -- 343
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ? AND kind = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant", "summary"}) -- 344
	if row and type(row[1]) == "number" then -- 344
		activeAssistantMessageIds[taskId] = row[1] -- 351
		return row[1] -- 352
	end -- 352
	local messageId = insertMessage( -- 354
		sessionId, -- 354
		"assistant", -- 354
		"summary", -- 354
		"", -- 354
		taskId, -- 354
		true -- 354
	) -- 354
	activeAssistantMessageIds[taskId] = messageId -- 355
	return messageId -- 356
end -- 341
local function upsertStep(sessionId, taskId, step, tool, patch) -- 359
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 369
	local reason = patch.reason or "" -- 373
	local reasoningContent = patch.reasoningContent or "" -- 374
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 375
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 376
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 377
	local status = patch.status or "PENDING" -- 378
	if not row then -- 378
		local t = now() -- 380
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 381
			sessionId, -- 385
			taskId, -- 386
			step, -- 387
			tool, -- 388
			status, -- 389
			reason, -- 390
			reasoningContent, -- 391
			paramsJson, -- 392
			resultJson, -- 393
			patch.checkpointId or 0, -- 394
			patch.checkpointSeq or 0, -- 395
			filesJson, -- 396
			t, -- 397
			t -- 398
		}) -- 398
		return -- 401
	end -- 401
	DB:exec( -- 403
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 403
		{ -- 415
			tool, -- 416
			patch.status or "", -- 417
			status, -- 418
			reason, -- 419
			reason, -- 420
			reasoningContent, -- 421
			reasoningContent, -- 422
			paramsJson, -- 423
			paramsJson, -- 424
			resultJson, -- 425
			resultJson, -- 426
			patch.checkpointId or 0, -- 427
			patch.checkpointId or 0, -- 428
			patch.checkpointSeq or 0, -- 429
			patch.checkpointSeq or 0, -- 430
			filesJson, -- 431
			filesJson, -- 432
			now(), -- 433
			row[1] -- 434
		} -- 434
	) -- 434
end -- 359
local function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 439
	if taskId <= 0 then -- 439
		return -- 440
	end -- 440
	if finalSteps ~= nil and finalSteps >= 0 then -- 440
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 442
	end -- 442
	if not finalStatus then -- 442
		return -- 448
	end -- 448
	if finalSteps ~= nil and finalSteps >= 0 then -- 448
		DB:exec( -- 450
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 450
			{ -- 454
				finalStatus, -- 454
				now(), -- 454
				sessionId, -- 454
				taskId, -- 454
				finalSteps -- 454
			} -- 454
		) -- 454
		return -- 456
	end -- 456
	DB:exec( -- 458
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 458
		{ -- 462
			finalStatus, -- 462
			now(), -- 462
			sessionId, -- 462
			taskId -- 462
		} -- 462
	) -- 462
end -- 439
local function sanitizeStoredSteps(sessionId) -- 466
	DB:exec( -- 467
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 467
		{ -- 485
			now(), -- 485
			sessionId -- 485
		} -- 485
	) -- 485
end -- 466
local function applyEvent(sessionId, event) -- 489
	repeat -- 489
		local ____switch60 = event.type -- 489
		local ____cond60 = ____switch60 == "task_started" -- 489
		if ____cond60 then -- 489
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 492
			break -- 493
		end -- 493
		____cond60 = ____cond60 or ____switch60 == "decision_made" -- 493
		if ____cond60 then -- 493
			upsertStep( -- 495
				sessionId, -- 495
				event.taskId, -- 495
				event.step, -- 495
				event.tool, -- 495
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 495
			) -- 495
			break -- 501
		end -- 501
		____cond60 = ____cond60 or ____switch60 == "tool_started" -- 501
		if ____cond60 then -- 501
			upsertStep( -- 503
				sessionId, -- 503
				event.taskId, -- 503
				event.step, -- 503
				event.tool, -- 503
				{status = "RUNNING"} -- 503
			) -- 503
			break -- 506
		end -- 506
		____cond60 = ____cond60 or ____switch60 == "tool_finished" -- 506
		if ____cond60 then -- 506
			upsertStep( -- 508
				sessionId, -- 508
				event.taskId, -- 508
				event.step, -- 508
				event.tool, -- 508
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 508
			) -- 508
			break -- 513
		end -- 513
		____cond60 = ____cond60 or ____switch60 == "checkpoint_created" -- 513
		if ____cond60 then -- 513
			upsertStep( -- 515
				sessionId, -- 515
				event.taskId, -- 515
				event.step, -- 515
				event.tool, -- 515
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 515
			) -- 515
			break -- 520
		end -- 520
		____cond60 = ____cond60 or ____switch60 == "summary_stream" -- 520
		if ____cond60 then -- 520
			do -- 520
				local messageId = getAssistantSummaryMessageId(event.taskId, sessionId) -- 522
				local row = queryOne(("SELECT content FROM " .. TABLE_MESSAGE) .. " WHERE id = ?", {messageId}) -- 523
				local oldContent = row and toStr(row[1]) or "" -- 524
				local nextContent = oldContent .. event.textDelta -- 525
				updateMessage(messageId, nextContent, true) -- 526
				break -- 527
			end -- 527
		end -- 527
		____cond60 = ____cond60 or ____switch60 == "task_finished" -- 527
		if ____cond60 then -- 527
			do -- 527
				local ____opt_1 = activeStopTokens[event.taskId or -1] -- 527
				local stopped = (____opt_1 and ____opt_1.stopped) == true -- 530
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 531
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 534
				if event.taskId ~= nil then -- 534
					local ____finalizeTaskSteps_5 = finalizeTaskSteps -- 536
					local ____array_4 = __TS__SparseArrayNew( -- 536
						sessionId, -- 537
						event.taskId, -- 538
						type(event.steps) == "number" and math.max( -- 539
							0, -- 539
							math.floor(event.steps) -- 539
						) or nil -- 539
					) -- 539
					local ____event_success_3 -- 540
					if event.success then -- 540
						____event_success_3 = nil -- 540
					else -- 540
						____event_success_3 = stopped and "STOPPED" or "FAILED" -- 540
					end -- 540
					__TS__SparseArrayPush(____array_4, ____event_success_3) -- 540
					____finalizeTaskSteps_5(__TS__SparseArraySpread(____array_4)) -- 536
					local messageId = getAssistantSummaryMessageId(event.taskId, sessionId) -- 542
					local row = queryOne(("SELECT content FROM " .. TABLE_MESSAGE) .. " WHERE id = ?", {messageId}) -- 543
					local content = row and toStr(row[1]) or "" -- 544
					updateMessage(messageId, content ~= "" and content or event.message, false) -- 545
					activeStopTokens[event.taskId] = nil -- 546
					activeAssistantMessageIds[event.taskId] = nil -- 547
				end -- 547
				break -- 549
			end -- 549
		end -- 549
	until true -- 549
end -- 489
do -- 489
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 556
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 566
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tkind TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tstreaming INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 567
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 578
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 579
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 596
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 597
	local stepColumns = queryRows(("PRAGMA table_info(" .. TABLE_STEP) .. ")") or ({}) -- 598
	local hasReasoningContent = false -- 599
	do -- 599
		local i = 0 -- 600
		while i < #stepColumns do -- 600
			local row = stepColumns[i + 1] -- 601
			if toStr(row[2]) == "reasoning_content" then -- 601
				hasReasoningContent = true -- 603
				break -- 604
			end -- 604
			i = i + 1 -- 600
		end -- 600
	end -- 600
	if not hasReasoningContent then -- 600
		DB:exec(("ALTER TABLE " .. TABLE_STEP) .. " ADD COLUMN reasoning_content TEXT NOT NULL DEFAULT ''") -- 608
	end -- 608
end -- 608
function ____exports.createSession(projectRoot, title) -- 612
	if title == nil then -- 612
		title = "" -- 612
	end -- 612
	if not isValidProjectRoot(projectRoot) then -- 612
		return {success = false, message = "invalid projectRoot"} -- 614
	end -- 614
	local row = queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ?\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 616
	if row then -- 616
		return { -- 625
			success = true, -- 625
			session = rowToSession(row) -- 625
		} -- 625
	end -- 625
	local t = now() -- 627
	DB:exec( -- 628
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'IDLE', 'IDLE', ?, ?)", -- 628
		{ -- 631
			projectRoot, -- 631
			title ~= "" and title or Path:getFilename(projectRoot), -- 631
			t, -- 631
			t -- 631
		} -- 631
	) -- 631
	local session = getSessionItem(getLastInsertRowId()) -- 633
	if not session then -- 633
		return {success = false, message = "failed to create session"} -- 635
	end -- 635
	return {success = true, session = session} -- 637
end -- 612
function ____exports.getSession(sessionId) -- 640
	local session = getSessionItem(sessionId) -- 641
	if not session then -- 641
		return {success = false, message = "session not found"} -- 643
	end -- 643
	local normalizedSession = normalizeSessionRuntimeState(session) -- 645
	sanitizeStoredSteps(sessionId) -- 646
	local messages = queryRows(("SELECT id, session_id, task_id, role, kind, content, streaming, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 647
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 654
	return { -- 662
		success = true, -- 663
		session = normalizedSession, -- 664
		messages = __TS__ArrayMap( -- 665
			messages, -- 665
			function(____, row) return rowToMessage(row) end -- 665
		), -- 665
		steps = __TS__ArrayMap( -- 666
			steps, -- 666
			function(____, row) return rowToStep(row) end -- 666
		) -- 666
	} -- 666
end -- 640
function ____exports.sendPrompt(sessionId, prompt) -- 670
	local session = getSessionItem(sessionId) -- 671
	if not session then -- 671
		return {success = false, message = "session not found"} -- 673
	end -- 673
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 673
		return {success = false, message = "session task is still running"} -- 676
	end -- 676
	local taskRes = Tools.createTask(prompt) -- 678
	if not taskRes.success then -- 678
		return {success = false, message = taskRes.message} -- 680
	end -- 680
	local taskId = taskRes.taskId -- 682
	local useChineseResponse = getDefaultUseChineseResponse() -- 683
	local llmConfigRes = getActiveLLMConfig() -- 684
	local sessionContext = buildSessionPromptContext(sessionId, useChineseResponse, llmConfigRes.success and llmConfigRes.config or nil) -- 685
	local agentPrompt = sessionContext ~= "" and (((sessionContext .. "\n\n") .. (useChineseResponse and "当前用户请求：" or "Current user request:")) .. "\n") .. prompt or prompt -- 690
	insertMessage( -- 693
		sessionId, -- 693
		"user", -- 693
		"message", -- 693
		prompt, -- 693
		taskId, -- 693
		false -- 693
	) -- 693
	local assistantMessageId = insertMessage( -- 694
		sessionId, -- 694
		"assistant", -- 694
		"summary", -- 694
		"", -- 694
		taskId, -- 694
		true -- 694
	) -- 694
	activeAssistantMessageIds[taskId] = assistantMessageId -- 695
	local stopToken = {stopped = false} -- 696
	activeStopTokens[taskId] = stopToken -- 697
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 698
	runCodingAgent( -- 699
		{ -- 699
			prompt = agentPrompt, -- 700
			workDir = session.projectRoot, -- 701
			useChineseResponse = useChineseResponse, -- 702
			taskId = taskId, -- 703
			sessionId = sessionId, -- 704
			stopToken = stopToken, -- 705
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 706
		}, -- 706
		function(result) -- 707
			if not result.success then -- 707
				applyEvent(sessionId, { -- 709
					type = "task_finished", -- 710
					sessionId = sessionId, -- 711
					taskId = result.taskId, -- 712
					success = false, -- 713
					message = result.message, -- 714
					steps = result.steps -- 715
				}) -- 715
			end -- 715
		end -- 707
	) -- 707
	return {success = true, sessionId = sessionId, taskId = taskId} -- 719
end -- 670
function ____exports.stopSessionTask(sessionId) -- 722
	local session = getSessionItem(sessionId) -- 723
	if not session or session.currentTaskId == nil then -- 723
		return {success = false, message = "session task not found"} -- 725
	end -- 725
	local normalizedSession = normalizeSessionRuntimeState(session) -- 727
	local stopToken = activeStopTokens[session.currentTaskId] -- 728
	if not stopToken then -- 728
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 728
			return {success = true, recovered = true} -- 731
		end -- 731
		return {success = false, message = "task is not running"} -- 733
	end -- 733
	stopToken.stopped = true -- 735
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 736
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 737
	return {success = true} -- 738
end -- 722
function ____exports.getCurrentTaskId(sessionId) -- 741
	local ____opt_6 = getSessionItem(sessionId) -- 741
	return ____opt_6 and ____opt_6.currentTaskId -- 742
end -- 741
function ____exports.listRunningSessions() -- 745
	local rows = queryRows(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 746
	local sessions = {} -- 753
	do -- 753
		local i = 0 -- 754
		while i < #rows do -- 754
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 755
			if session.currentTaskStatus == "RUNNING" then -- 755
				sessions[#sessions + 1] = session -- 757
			end -- 757
			i = i + 1 -- 754
		end -- 754
	end -- 754
	return {success = true, sessions = sessions} -- 760
end -- 745
return ____exports -- 745