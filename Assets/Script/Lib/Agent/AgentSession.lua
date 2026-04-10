-- [ts]: AgentSession.ts
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
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____CodingAgent = require("Agent.CodingAgent") -- 3
local runCodingAgent = ____CodingAgent.runCodingAgent -- 3
local truncateAgentUserPrompt = ____CodingAgent.truncateAgentUserPrompt -- 3
local Tools = require("Agent.Tools") -- 4
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
local safeJsonDecode = ____Utils.safeJsonDecode -- 5
local safeJsonEncode = ____Utils.safeJsonEncode -- 5
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 5
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 284
	DB:exec( -- 285
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 285
		{ -- 289
			status, -- 290
			currentTaskId or 0, -- 291
			currentTaskStatus or status, -- 292
			now(), -- 293
			sessionId -- 294
		} -- 294
	) -- 294
end -- 294
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
local function getMessageItem(messageId) -- 191
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 192
	return row and rowToMessage(row) or nil -- 198
end -- 191
local function getStepItem(sessionId, taskId, step) -- 201
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 202
	return row and rowToStep(row) or nil -- 208
end -- 201
local function deleteMessageSteps(sessionId, taskId) -- 211
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 212
	local ids = {} -- 217
	do -- 217
		local i = 0 -- 218
		while i < #rows do -- 218
			local row = rows[i + 1] -- 219
			if type(row[1]) == "number" then -- 219
				ids[#ids + 1] = row[1] -- 221
			end -- 221
			i = i + 1 -- 218
		end -- 218
	end -- 218
	if #ids > 0 then -- 218
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 225
	end -- 225
	return ids -- 231
end -- 211
local function getSessionRow(sessionId) -- 234
	return queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 235
end -- 234
local function getSessionItem(sessionId) -- 243
	local row = getSessionRow(sessionId) -- 244
	return row and rowToSession(row) or nil -- 245
end -- 243
local function deleteSessionRecords(sessionId) -- 248
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 249
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 250
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 251
end -- 248
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 254
	if projectRoot == oldRoot then -- 254
		return newRoot -- 256
	end -- 256
	for ____, separator in ipairs({"/", "\\"}) do -- 258
		local prefix = oldRoot .. separator -- 259
		if __TS__StringStartsWith(projectRoot, prefix) then -- 259
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 261
		end -- 261
	end -- 261
	return nil -- 264
end -- 254
local function normalizeSessionRuntimeState(session) -- 267
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 267
		return session -- 269
	end -- 269
	if activeStopTokens[session.currentTaskId] then -- 269
		return session -- 272
	end -- 272
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 274
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 275
	return __TS__ObjectAssign( -- 276
		{}, -- 276
		session, -- 277
		{ -- 276
			status = "STOPPED", -- 278
			currentTaskStatus = "STOPPED", -- 279
			updatedAt = now() -- 280
		} -- 280
	) -- 280
end -- 267
local function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 299
	if taskId == nil or taskId <= 0 then -- 299
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 301
		return -- 302
	end -- 302
	local row = getSessionRow(sessionId) -- 304
	if not row then -- 304
		return -- 305
	end -- 305
	local session = rowToSession(row) -- 306
	if session.currentTaskId ~= taskId then -- 306
		Log( -- 308
			"Info", -- 308
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 308
		) -- 308
		return -- 309
	end -- 309
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 311
end -- 299
local function insertMessage(sessionId, role, content, taskId) -- 314
	local t = now() -- 315
	DB:exec( -- 316
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 316
		{ -- 319
			sessionId, -- 320
			taskId or 0, -- 321
			role, -- 322
			sanitizeUTF8(content), -- 323
			t, -- 324
			t -- 325
		} -- 325
	) -- 325
	return getLastInsertRowId() -- 328
end -- 314
local function updateMessage(messageId, content) -- 331
	DB:exec( -- 332
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 332
		{ -- 334
			sanitizeUTF8(content), -- 334
			now(), -- 334
			messageId -- 334
		} -- 334
	) -- 334
end -- 331
local function upsertAssistantMessage(sessionId, taskId, content) -- 338
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 339
	if row and type(row[1]) == "number" then -- 339
		updateMessage(row[1], content) -- 346
		return row[1] -- 347
	end -- 347
	return insertMessage(sessionId, "assistant", content, taskId) -- 349
end -- 338
local function upsertStep(sessionId, taskId, step, tool, patch) -- 352
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 362
	local reason = sanitizeUTF8(patch.reason or "") -- 366
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 367
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 368
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 369
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 370
	local statusPatch = patch.status or "" -- 371
	local status = patch.status or "PENDING" -- 372
	if not row then -- 372
		local t = now() -- 374
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 375
			sessionId, -- 379
			taskId, -- 380
			step, -- 381
			tool, -- 382
			status, -- 383
			reason, -- 384
			reasoningContent, -- 385
			paramsJson, -- 386
			resultJson, -- 387
			patch.checkpointId or 0, -- 388
			patch.checkpointSeq or 0, -- 389
			filesJson, -- 390
			t, -- 391
			t -- 392
		}) -- 392
		return -- 395
	end -- 395
	DB:exec( -- 397
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 397
		{ -- 409
			tool, -- 410
			statusPatch, -- 411
			status, -- 412
			reason, -- 413
			reason, -- 414
			reasoningContent, -- 415
			reasoningContent, -- 416
			paramsJson, -- 417
			paramsJson, -- 418
			resultJson, -- 419
			resultJson, -- 420
			patch.checkpointId or 0, -- 421
			patch.checkpointId or 0, -- 422
			patch.checkpointSeq or 0, -- 423
			patch.checkpointSeq or 0, -- 424
			filesJson, -- 425
			filesJson, -- 426
			now(), -- 427
			row[1] -- 428
		} -- 428
	) -- 428
end -- 352
local function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 433
	if taskId <= 0 then -- 433
		return -- 434
	end -- 434
	if finalSteps ~= nil and finalSteps >= 0 then -- 434
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 436
	end -- 436
	if not finalStatus then -- 436
		return -- 442
	end -- 442
	if finalSteps ~= nil and finalSteps >= 0 then -- 442
		DB:exec( -- 444
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 444
			{ -- 448
				finalStatus, -- 448
				now(), -- 448
				sessionId, -- 448
				taskId, -- 448
				finalSteps -- 448
			} -- 448
		) -- 448
		return -- 450
	end -- 450
	DB:exec( -- 452
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 452
		{ -- 456
			finalStatus, -- 456
			now(), -- 456
			sessionId, -- 456
			taskId -- 456
		} -- 456
	) -- 456
end -- 433
local function sanitizeStoredSteps(sessionId) -- 460
	DB:exec( -- 461
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 461
		{ -- 479
			now(), -- 479
			sessionId -- 479
		} -- 479
	) -- 479
end -- 460
local function emitAgentSessionPatch(sessionId, patch) -- 483
	if HttpServer.wsConnectionCount == 0 then -- 483
		return -- 485
	end -- 485
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 487
	if not text then -- 487
		return -- 492
	end -- 492
	emit("AppWS", "Send", text) -- 493
end -- 483
local function applyEvent(sessionId, event) -- 496
	repeat -- 496
		local ____switch63 = event.type -- 496
		local ____cond63 = ____switch63 == "task_started" -- 496
		if ____cond63 then -- 496
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 499
			emitAgentSessionPatch( -- 500
				sessionId, -- 500
				{session = getSessionItem(sessionId)} -- 500
			) -- 500
			break -- 503
		end -- 503
		____cond63 = ____cond63 or ____switch63 == "decision_made" -- 503
		if ____cond63 then -- 503
			upsertStep( -- 505
				sessionId, -- 505
				event.taskId, -- 505
				event.step, -- 505
				event.tool, -- 505
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 505
			) -- 505
			emitAgentSessionPatch( -- 511
				sessionId, -- 511
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 511
			) -- 511
			break -- 514
		end -- 514
		____cond63 = ____cond63 or ____switch63 == "tool_started" -- 514
		if ____cond63 then -- 514
			upsertStep( -- 516
				sessionId, -- 516
				event.taskId, -- 516
				event.step, -- 516
				event.tool, -- 516
				{status = "RUNNING"} -- 516
			) -- 516
			emitAgentSessionPatch( -- 519
				sessionId, -- 519
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 519
			) -- 519
			break -- 522
		end -- 522
		____cond63 = ____cond63 or ____switch63 == "tool_finished" -- 522
		if ____cond63 then -- 522
			upsertStep( -- 524
				sessionId, -- 524
				event.taskId, -- 524
				event.step, -- 524
				event.tool, -- 524
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 524
			) -- 524
			emitAgentSessionPatch( -- 529
				sessionId, -- 529
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 529
			) -- 529
			break -- 532
		end -- 532
		____cond63 = ____cond63 or ____switch63 == "checkpoint_created" -- 532
		if ____cond63 then -- 532
			upsertStep( -- 534
				sessionId, -- 534
				event.taskId, -- 534
				event.step, -- 534
				event.tool, -- 534
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 534
			) -- 534
			emitAgentSessionPatch( -- 539
				sessionId, -- 539
				{ -- 539
					step = getStepItem(sessionId, event.taskId, event.step), -- 540
					checkpoints = Tools.listCheckpoints(event.taskId) -- 541
				} -- 541
			) -- 541
			break -- 543
		end -- 543
		____cond63 = ____cond63 or ____switch63 == "memory_compression_started" -- 543
		if ____cond63 then -- 543
			upsertStep( -- 545
				sessionId, -- 545
				event.taskId, -- 545
				event.step, -- 545
				event.tool, -- 545
				{status = "RUNNING", reason = event.reason, params = event.params} -- 545
			) -- 545
			emitAgentSessionPatch( -- 550
				sessionId, -- 550
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 550
			) -- 550
			break -- 553
		end -- 553
		____cond63 = ____cond63 or ____switch63 == "memory_compression_finished" -- 553
		if ____cond63 then -- 553
			upsertStep( -- 555
				sessionId, -- 555
				event.taskId, -- 555
				event.step, -- 555
				event.tool, -- 555
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 555
			) -- 555
			emitAgentSessionPatch( -- 560
				sessionId, -- 560
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 560
			) -- 560
			break -- 563
		end -- 563
		____cond63 = ____cond63 or ____switch63 == "assistant_message_updated" -- 563
		if ____cond63 then -- 563
			do -- 563
				upsertStep( -- 565
					sessionId, -- 565
					event.taskId, -- 565
					event.step, -- 565
					"message", -- 565
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 565
				) -- 565
				emitAgentSessionPatch( -- 570
					sessionId, -- 570
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 570
				) -- 570
				break -- 573
			end -- 573
		end -- 573
		____cond63 = ____cond63 or ____switch63 == "task_finished" -- 573
		if ____cond63 then -- 573
			do -- 573
				local ____opt_1 = activeStopTokens[event.taskId or -1] -- 573
				local stopped = (____opt_1 and ____opt_1.stopped) == true -- 576
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 577
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 580
				if event.taskId ~= nil then -- 580
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 582
					local ____finalizeTaskSteps_5 = finalizeTaskSteps -- 583
					local ____array_4 = __TS__SparseArrayNew( -- 583
						sessionId, -- 584
						event.taskId, -- 585
						type(event.steps) == "number" and math.max( -- 586
							0, -- 586
							math.floor(event.steps) -- 586
						) or nil -- 586
					) -- 586
					local ____event_success_3 -- 587
					if event.success then -- 587
						____event_success_3 = nil -- 587
					else -- 587
						____event_success_3 = stopped and "STOPPED" or "FAILED" -- 587
					end -- 587
					__TS__SparseArrayPush(____array_4, ____event_success_3) -- 587
					____finalizeTaskSteps_5(__TS__SparseArraySpread(____array_4)) -- 583
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 589
					activeStopTokens[event.taskId] = nil -- 590
					emitAgentSessionPatch( -- 591
						sessionId, -- 591
						{ -- 591
							session = getSessionItem(sessionId), -- 592
							message = getMessageItem(messageId), -- 593
							checkpoints = Tools.listCheckpoints(event.taskId), -- 594
							removedStepIds = removedStepIds -- 595
						} -- 595
					) -- 595
				end -- 595
				break -- 598
			end -- 598
		end -- 598
	until true -- 598
end -- 496
local function getSchemaVersion() -- 603
	local row = queryOne("PRAGMA user_version") -- 604
	return row and type(row[1]) == "number" and row[1] or 0 -- 605
end -- 603
local function setSchemaVersion(version) -- 608
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 609
		0, -- 609
		math.floor(version) -- 609
	))) -- 609
end -- 608
local function recreateSchema() -- 612
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 613
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 614
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 615
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 616
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 626
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 627
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 636
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 637
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 654
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 655
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 656
end -- 612
do -- 612
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 612
		recreateSchema() -- 662
	else -- 662
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 664
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 674
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 675
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 684
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 685
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 702
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 703
	end -- 703
end -- 703
function ____exports.createSession(projectRoot, title) -- 707
	if title == nil then -- 707
		title = "" -- 707
	end -- 707
	if not isValidProjectRoot(projectRoot) then -- 707
		return {success = false, message = "invalid projectRoot"} -- 709
	end -- 709
	local row = queryOne(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ?\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 711
	if row then -- 711
		return { -- 720
			success = true, -- 720
			session = rowToSession(row) -- 720
		} -- 720
	end -- 720
	local t = now() -- 722
	DB:exec( -- 723
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'IDLE', 'IDLE', ?, ?)", -- 723
		{ -- 726
			projectRoot, -- 726
			title ~= "" and title or Path:getFilename(projectRoot), -- 726
			t, -- 726
			t -- 726
		} -- 726
	) -- 726
	local session = getSessionItem(getLastInsertRowId()) -- 728
	if not session then -- 728
		return {success = false, message = "failed to create session"} -- 730
	end -- 730
	return {success = true, session = session} -- 732
end -- 707
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 735
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 735
		return {success = false, message = "invalid projectRoot"} -- 737
	end -- 737
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 739
	for ____, row in ipairs(rows) do -- 740
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 741
		if sessionId > 0 then -- 741
			deleteSessionRecords(sessionId) -- 743
		end -- 743
	end -- 743
	return {success = true, deleted = #rows} -- 746
end -- 735
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 749
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 749
		return {success = false, message = "invalid projectRoot"} -- 751
	end -- 751
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 753
	local renamed = 0 -- 754
	for ____, row in ipairs(rows) do -- 755
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 756
		local projectRoot = toStr(row[2]) -- 757
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 758
		if sessionId > 0 and nextProjectRoot then -- 758
			DB:exec( -- 760
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 760
				{ -- 762
					nextProjectRoot, -- 762
					Path:getFilename(nextProjectRoot), -- 762
					now(), -- 762
					sessionId -- 762
				} -- 762
			) -- 762
			renamed = renamed + 1 -- 764
		end -- 764
	end -- 764
	return {success = true, renamed = renamed} -- 767
end -- 749
function ____exports.getSession(sessionId) -- 770
	local session = getSessionItem(sessionId) -- 771
	if not session then -- 771
		return {success = false, message = "session not found"} -- 773
	end -- 773
	local normalizedSession = normalizeSessionRuntimeState(session) -- 775
	sanitizeStoredSteps(sessionId) -- 776
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 777
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 784
	return { -- 792
		success = true, -- 793
		session = normalizedSession, -- 794
		messages = __TS__ArrayMap( -- 795
			messages, -- 795
			function(____, row) return rowToMessage(row) end -- 795
		), -- 795
		steps = __TS__ArrayMap( -- 796
			steps, -- 796
			function(____, row) return rowToStep(row) end -- 796
		) -- 796
	} -- 796
end -- 770
function ____exports.sendPrompt(sessionId, prompt) -- 800
	local session = getSessionItem(sessionId) -- 801
	if not session then -- 801
		return {success = false, message = "session not found"} -- 803
	end -- 803
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 803
		return {success = false, message = "session task is still running"} -- 806
	end -- 806
	local normalizedPrompt = truncateAgentUserPrompt(prompt) -- 808
	local taskRes = Tools.createTask(normalizedPrompt) -- 809
	if not taskRes.success then -- 809
		return {success = false, message = taskRes.message} -- 811
	end -- 811
	local taskId = taskRes.taskId -- 813
	local useChineseResponse = getDefaultUseChineseResponse() -- 814
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 815
	local stopToken = {stopped = false} -- 816
	activeStopTokens[taskId] = stopToken -- 817
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 818
	runCodingAgent( -- 819
		{ -- 819
			prompt = normalizedPrompt, -- 820
			workDir = session.projectRoot, -- 821
			useChineseResponse = useChineseResponse, -- 822
			taskId = taskId, -- 823
			sessionId = sessionId, -- 824
			stopToken = stopToken, -- 825
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 826
		}, -- 826
		function(result) -- 827
			if not result.success then -- 827
				applyEvent(sessionId, { -- 829
					type = "task_finished", -- 830
					sessionId = sessionId, -- 831
					taskId = result.taskId, -- 832
					success = false, -- 833
					message = result.message, -- 834
					steps = result.steps -- 835
				}) -- 835
			end -- 835
		end -- 827
	) -- 827
	return {success = true, sessionId = sessionId, taskId = taskId} -- 839
end -- 800
function ____exports.stopSessionTask(sessionId) -- 842
	local session = getSessionItem(sessionId) -- 843
	if not session or session.currentTaskId == nil then -- 843
		return {success = false, message = "session task not found"} -- 845
	end -- 845
	local normalizedSession = normalizeSessionRuntimeState(session) -- 847
	local stopToken = activeStopTokens[session.currentTaskId] -- 848
	if not stopToken then -- 848
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 848
			return {success = true, recovered = true} -- 851
		end -- 851
		return {success = false, message = "task is not running"} -- 853
	end -- 853
	stopToken.stopped = true -- 855
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 856
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 857
	return {success = true} -- 858
end -- 842
function ____exports.getCurrentTaskId(sessionId) -- 861
	local ____opt_6 = getSessionItem(sessionId) -- 861
	return ____opt_6 and ____opt_6.currentTaskId -- 862
end -- 861
function ____exports.listRunningSessions() -- 865
	local rows = queryRows(("SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 866
	local sessions = {} -- 873
	do -- 873
		local i = 0 -- 874
		while i < #rows do -- 874
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 875
			if session.currentTaskStatus == "RUNNING" then -- 875
				sessions[#sessions + 1] = session -- 877
			end -- 877
			i = i + 1 -- 874
		end -- 874
	end -- 874
	return {success = true, sessions = sessions} -- 880
end -- 865
return ____exports -- 865