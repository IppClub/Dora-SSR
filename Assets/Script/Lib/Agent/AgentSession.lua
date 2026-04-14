-- [ts]: AgentSession.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, getSessionRow, getSessionItem, getLatestMainSessionByProjectRoot, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getPendingMergeCount, listPendingMergeJobs, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, writeFinalizeInfo, readFinalizeInfo, deleteFinalizeInfo, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, setSessionStateForTaskEvent, insertMessage, updateMessage, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, buildSubAgentMemoryMergeJob, appendSubAgentHandoffStep, startSubSessionFinalize, completeSubSessionFinalizeAfterCompact, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, SPAWN_INFO_FILE, FINALIZE_INFO_FILE, PENDING_HANDOFF_DIR, activeStopTokens, now -- 1
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
local ____Memory = require("Agent.Memory") -- 5
local DualLayerStorage = ____Memory.DualLayerStorage -- 5
local MemoryMergeQueue = ____Memory.MemoryMergeQueue -- 5
local ____Utils = require("Agent.Utils") -- 6
local Log = ____Utils.Log -- 6
local safeJsonDecode = ____Utils.safeJsonDecode -- 6
local safeJsonEncode = ____Utils.safeJsonEncode -- 6
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 6
function getDefaultUseChineseResponse() -- 136
	local zh = string.match(App.locale, "^zh") -- 137
	return zh ~= nil -- 138
end -- 138
function toStr(v) -- 141
	if v == false or v == nil or v == nil then -- 141
		return "" -- 142
	end -- 142
	return tostring(v) -- 143
end -- 143
function encodeJson(value) -- 146
	local text = safeJsonEncode(value) -- 147
	return text or "" -- 148
end -- 148
function decodeJsonObject(text) -- 151
	if not text or text == "" then -- 151
		return nil -- 152
	end -- 152
	local value = safeJsonDecode(text) -- 153
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 153
		return value -- 155
	end -- 155
	return nil -- 157
end -- 157
function decodeJsonFiles(text) -- 160
	if not text or text == "" then -- 160
		return nil -- 161
	end -- 161
	local value = safeJsonDecode(text) -- 162
	if not value or not __TS__ArrayIsArray(value) then -- 162
		return nil -- 163
	end -- 163
	local files = {} -- 164
	do -- 164
		local i = 0 -- 165
		while i < #value do -- 165
			do -- 165
				local item = value[i + 1] -- 166
				if type(item) ~= "table" then -- 166
					goto __continue14 -- 167
				end -- 167
				files[#files + 1] = { -- 168
					path = sanitizeUTF8(toStr(item.path)), -- 169
					op = sanitizeUTF8(toStr(item.op)) -- 170
				} -- 170
			end -- 170
			::__continue14:: -- 170
			i = i + 1 -- 165
		end -- 165
	end -- 165
	return files -- 173
end -- 173
function queryRows(sql, args) -- 176
	local ____args_0 -- 177
	if args then -- 177
		____args_0 = DB:query(sql, args) -- 177
	else -- 177
		____args_0 = DB:query(sql) -- 177
	end -- 177
	return ____args_0 -- 177
end -- 177
function queryOne(sql, args) -- 180
	local rows = queryRows(sql, args) -- 181
	if not rows or #rows == 0 then -- 181
		return nil -- 182
	end -- 182
	return rows[1] -- 183
end -- 183
function getLastInsertRowId() -- 186
	local row = queryOne("SELECT last_insert_rowid()") -- 187
	return row and (row[1] or 0) or 0 -- 188
end -- 188
function isValidProjectRoot(path) -- 191
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 192
end -- 192
function rowToSession(row) -- 195
	return { -- 196
		id = row[1], -- 197
		projectRoot = toStr(row[2]), -- 198
		title = toStr(row[3]), -- 199
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 200
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 201
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 202
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 203
		status = toStr(row[8]), -- 204
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 205
		currentTaskStatus = toStr(row[10]), -- 206
		createdAt = row[11], -- 207
		updatedAt = row[12] -- 208
	} -- 208
end -- 208
function rowToMessage(row) -- 212
	return { -- 213
		id = row[1], -- 214
		sessionId = row[2], -- 215
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 216
		role = toStr(row[4]), -- 217
		content = toStr(row[5]), -- 218
		createdAt = row[6], -- 219
		updatedAt = row[7] -- 220
	} -- 220
end -- 220
function rowToStep(row) -- 224
	return { -- 225
		id = row[1], -- 226
		sessionId = row[2], -- 227
		taskId = row[3], -- 228
		step = row[4], -- 229
		tool = toStr(row[5]), -- 230
		status = toStr(row[6]), -- 231
		reason = toStr(row[7]), -- 232
		reasoningContent = toStr(row[8]), -- 233
		params = decodeJsonObject(toStr(row[9])), -- 234
		result = decodeJsonObject(toStr(row[10])), -- 235
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 236
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 237
		files = decodeJsonFiles(toStr(row[13])), -- 238
		createdAt = row[14], -- 239
		updatedAt = row[15] -- 240
	} -- 240
end -- 240
function getMessageItem(messageId) -- 244
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 245
	return row and rowToMessage(row) or nil -- 251
end -- 251
function getStepItem(sessionId, taskId, step) -- 254
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 255
	return row and rowToStep(row) or nil -- 261
end -- 261
function deleteMessageSteps(sessionId, taskId) -- 264
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 265
	local ids = {} -- 270
	do -- 270
		local i = 0 -- 271
		while i < #rows do -- 271
			local row = rows[i + 1] -- 272
			if type(row[1]) == "number" then -- 272
				ids[#ids + 1] = row[1] -- 274
			end -- 274
			i = i + 1 -- 271
		end -- 271
	end -- 271
	if #ids > 0 then -- 271
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 278
	end -- 278
	return ids -- 284
end -- 284
function getSessionRow(sessionId) -- 287
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 288
end -- 288
function getSessionItem(sessionId) -- 296
	local row = getSessionRow(sessionId) -- 297
	return row and rowToSession(row) or nil -- 298
end -- 298
function getLatestMainSessionByProjectRoot(projectRoot) -- 301
	if not isValidProjectRoot(projectRoot) then -- 301
		return nil -- 302
	end -- 302
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 303
	return row and rowToSession(row) or nil -- 311
end -- 311
function deleteSessionRecords(sessionId) -- 314
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 315
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 316
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 317
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 318
end -- 318
function getSessionRootId(session) -- 321
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 322
end -- 322
function getRootSessionItem(sessionId) -- 325
	local session = getSessionItem(sessionId) -- 326
	if not session then -- 326
		return nil -- 327
	end -- 327
	return getSessionItem(getSessionRootId(session)) or session -- 328
end -- 328
function listRelatedSessions(sessionId) -- 331
	local root = getRootSessionItem(sessionId) -- 332
	if not root then -- 332
		return {} -- 333
	end -- 333
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 334
	return __TS__ArrayMap( -- 343
		rows, -- 343
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 343
	) -- 343
end -- 343
function getPendingMergeCount(projectRoot) -- 346
	return #__TS__New(MemoryMergeQueue, projectRoot):listJobs() -- 347
end -- 347
function listPendingMergeJobs(projectRoot) -- 350
	return __TS__ArrayMap( -- 351
		__TS__New(MemoryMergeQueue, projectRoot):listJobs(), -- 351
		function(____, job) return { -- 351
			jobId = job.jobId, -- 352
			sourceAgentId = job.sourceAgentId, -- 353
			sourceTitle = job.sourceTitle, -- 354
			createdAt = job.createdAt, -- 355
			attempts = job.attempts, -- 356
			lastError = job.lastError -- 357
		} end -- 357
	) -- 357
end -- 357
function getSessionSpawnInfo(session) -- 361
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 362
	if not info then -- 362
		return nil -- 363
	end -- 363
	return { -- 364
		prompt = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "", -- 365
		goal = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "", -- 366
		expectedOutput = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil, -- 367
		filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 368
			__TS__ArrayFilter( -- 369
				info.filesHint, -- 369
				function(____, item) return type(item) == "string" end -- 369
			), -- 369
			function(____, item) return sanitizeUTF8(item) end -- 369
		) or nil, -- 369
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil -- 371
	} -- 371
end -- 371
function ensureDirRecursive(dir) -- 388
	if not dir or dir == "" then -- 388
		return false -- 389
	end -- 389
	if Content:exist(dir) then -- 389
		return Content:isdir(dir) -- 390
	end -- 390
	local parent = Path:getPath(dir) -- 391
	if parent and parent ~= dir and not Content:exist(parent) then -- 391
		if not ensureDirRecursive(parent) then -- 391
			return false -- 394
		end -- 394
	end -- 394
	return Content:mkdir(dir) -- 397
end -- 397
function writeSpawnInfo(projectRoot, memoryScope, value) -- 400
	local dir = Path(projectRoot, ".agent", memoryScope) -- 401
	if not Content:exist(dir) then -- 401
		ensureDirRecursive(dir) -- 403
	end -- 403
	local path = Path(dir, SPAWN_INFO_FILE) -- 405
	local text = safeJsonEncode(value) -- 406
	if not text then -- 406
		return false -- 407
	end -- 407
	return Content:save(path, text .. "\n") -- 408
end -- 408
function readSpawnInfo(projectRoot, memoryScope) -- 411
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 412
	if not Content:exist(path) then -- 412
		return nil -- 413
	end -- 413
	local text = Content:load(path) -- 414
	if not text or __TS__StringTrim(text) == "" then -- 414
		return nil -- 415
	end -- 415
	local value = safeJsonDecode(text) -- 416
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 416
		return value -- 418
	end -- 418
	return nil -- 420
end -- 420
function writeFinalizeInfo(projectRoot, memoryScope, value) -- 423
	local dir = Path(projectRoot, ".agent", memoryScope) -- 424
	if not Content:exist(dir) then -- 424
		ensureDirRecursive(dir) -- 426
	end -- 426
	local path = Path(dir, FINALIZE_INFO_FILE) -- 428
	local text = safeJsonEncode(value) -- 429
	if not text then -- 429
		return false -- 430
	end -- 430
	return Content:save(path, text .. "\n") -- 431
end -- 431
function readFinalizeInfo(projectRoot, memoryScope) -- 434
	local path = Path(projectRoot, ".agent", memoryScope, FINALIZE_INFO_FILE) -- 435
	if not Content:exist(path) then -- 435
		return nil -- 436
	end -- 436
	local text = Content:load(path) -- 437
	if not text or __TS__StringTrim(text) == "" then -- 437
		return nil -- 438
	end -- 438
	local value = safeJsonDecode(text) -- 439
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 439
		local sourceTaskId = tonumber(value.sourceTaskId) -- 441
		if not (sourceTaskId and sourceTaskId > 0) then -- 441
			return nil -- 442
		end -- 442
		return { -- 443
			sourceTaskId = sourceTaskId, -- 444
			message = sanitizeUTF8(toStr(value.message)), -- 445
			createdAt = type(value.createdAt) == "string" and sanitizeUTF8(value.createdAt) or nil -- 446
		} -- 446
	end -- 446
	return nil -- 451
end -- 451
function deleteFinalizeInfo(projectRoot, memoryScope) -- 454
	local path = Path(projectRoot, ".agent", memoryScope, FINALIZE_INFO_FILE) -- 455
	if Content:exist(path) then -- 455
		Content:remove(path) -- 457
	end -- 457
end -- 457
function getPendingHandoffDir(projectRoot, memoryScope) -- 461
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 462
end -- 462
function writePendingHandoff(projectRoot, memoryScope, value) -- 465
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 466
	if not Content:exist(dir) then -- 466
		ensureDirRecursive(dir) -- 468
	end -- 468
	local path = Path(dir, value.id .. ".json") -- 470
	local text = safeJsonEncode(value) -- 471
	if not text then -- 471
		return false -- 472
	end -- 472
	return Content:save(path, text .. "\n") -- 473
end -- 473
function listPendingHandoffs(projectRoot, memoryScope) -- 476
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 477
	if not Content:exist(dir) or not Content:isdir(dir) then -- 477
		return {} -- 478
	end -- 478
	local items = {} -- 479
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 480
		do -- 480
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 481
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 481
				goto __continue82 -- 482
			end -- 482
			local text = Content:load(path) -- 483
			if not text or __TS__StringTrim(text) == "" then -- 483
				goto __continue82 -- 484
			end -- 484
			local value = safeJsonDecode(text) -- 485
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 485
				goto __continue82 -- 486
			end -- 486
			local sourceTaskId = tonumber(value.sourceTaskId) -- 487
			local sourceSessionId = tonumber(value.sourceSessionId) -- 488
			local id = sanitizeUTF8(toStr(value.id)) -- 489
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 490
			local message = sanitizeUTF8(toStr(value.message)) -- 491
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 492
			local goal = sanitizeUTF8(toStr(value.goal)) -- 493
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 494
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 494
				goto __continue82 -- 496
			end -- 496
			items[#items + 1] = { -- 498
				id = id, -- 499
				sourceSessionId = sourceSessionId, -- 500
				sourceTitle = sourceTitle, -- 501
				sourceTaskId = sourceTaskId, -- 502
				message = message, -- 503
				prompt = prompt, -- 504
				goal = goal, -- 505
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 506
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 507
					__TS__ArrayFilter( -- 508
						value.filesHint, -- 508
						function(____, item) return type(item) == "string" end -- 508
					), -- 508
					function(____, item) return sanitizeUTF8(item) end -- 508
				) or ({}), -- 508
				createdAt = createdAt -- 510
			} -- 510
		end -- 510
		::__continue82:: -- 510
	end -- 510
	__TS__ArraySort( -- 513
		items, -- 513
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 513
	) -- 513
	return items -- 514
end -- 514
function deletePendingHandoff(projectRoot, memoryScope, id) -- 517
	local path = Path( -- 518
		getPendingHandoffDir(projectRoot, memoryScope), -- 518
		id .. ".json" -- 518
	) -- 518
	if Content:exist(path) then -- 518
		Content:remove(path) -- 520
	end -- 520
end -- 520
function normalizePromptText(prompt) -- 524
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 525
end -- 525
function normalizePromptTextSafe(prompt) -- 528
	if type(prompt) == "string" then -- 528
		local normalized = normalizePromptText(prompt) -- 530
		if normalized ~= "" then -- 530
			return normalized -- 531
		end -- 531
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 532
		if sanitized ~= "" then -- 532
			return truncateAgentUserPrompt(sanitized) -- 534
		end -- 534
		return "" -- 536
	end -- 536
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 538
	if text == "" then -- 538
		return "" -- 539
	end -- 539
	return truncateAgentUserPrompt(text) -- 540
end -- 540
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 543
	local sections = {} -- 544
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 545
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 546
	local normalizedFiles = __TS__ArrayFilter( -- 547
		__TS__ArrayMap( -- 547
			__TS__ArrayFilter( -- 547
				filesHint or ({}), -- 547
				function(____, item) return type(item) == "string" end -- 548
			), -- 548
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 549
		), -- 549
		function(____, item) return item ~= "" end -- 550
	) -- 550
	if normalizedTitle ~= "" then -- 550
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 552
	end -- 552
	if normalizedExpected ~= "" then -- 552
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 555
	end -- 555
	if #normalizedFiles > 0 then -- 555
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 558
	end -- 558
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 560
end -- 560
function normalizeSessionRuntimeState(session) -- 563
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 563
		return session -- 565
	end -- 565
	if activeStopTokens[session.currentTaskId] then -- 565
		return session -- 568
	end -- 568
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 570
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 571
	return __TS__ObjectAssign( -- 572
		{}, -- 572
		session, -- 573
		{ -- 572
			status = "STOPPED", -- 574
			currentTaskStatus = "STOPPED", -- 575
			updatedAt = now() -- 576
		} -- 576
	) -- 576
end -- 576
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 580
	DB:exec( -- 581
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 581
		{ -- 585
			status, -- 586
			currentTaskId or 0, -- 587
			currentTaskStatus or status, -- 588
			now(), -- 589
			sessionId -- 590
		} -- 590
	) -- 590
end -- 590
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 595
	if taskId == nil or taskId <= 0 then -- 595
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 597
		return -- 598
	end -- 598
	local row = getSessionRow(sessionId) -- 600
	if not row then -- 600
		return -- 601
	end -- 601
	local session = rowToSession(row) -- 602
	if session.currentTaskId ~= taskId then -- 602
		Log( -- 604
			"Info", -- 604
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 604
		) -- 604
		return -- 605
	end -- 605
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 607
end -- 607
function insertMessage(sessionId, role, content, taskId) -- 610
	local t = now() -- 611
	DB:exec( -- 612
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 612
		{ -- 615
			sessionId, -- 616
			taskId or 0, -- 617
			role, -- 618
			sanitizeUTF8(content), -- 619
			t, -- 620
			t -- 621
		} -- 621
	) -- 621
	return getLastInsertRowId() -- 624
end -- 624
function updateMessage(messageId, content) -- 627
	DB:exec( -- 628
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 628
		{ -- 630
			sanitizeUTF8(content), -- 630
			now(), -- 630
			messageId -- 630
		} -- 630
	) -- 630
end -- 630
function upsertAssistantMessage(sessionId, taskId, content) -- 634
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 635
	if row and type(row[1]) == "number" then -- 635
		updateMessage(row[1], content) -- 642
		return row[1] -- 643
	end -- 643
	return insertMessage(sessionId, "assistant", content, taskId) -- 645
end -- 645
function upsertStep(sessionId, taskId, step, tool, patch) -- 648
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 658
	local reason = sanitizeUTF8(patch.reason or "") -- 662
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 663
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 664
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 665
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 666
	local statusPatch = patch.status or "" -- 667
	local status = patch.status or "PENDING" -- 668
	if not row then -- 668
		local t = now() -- 670
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 671
			sessionId, -- 675
			taskId, -- 676
			step, -- 677
			tool, -- 678
			status, -- 679
			reason, -- 680
			reasoningContent, -- 681
			paramsJson, -- 682
			resultJson, -- 683
			patch.checkpointId or 0, -- 684
			patch.checkpointSeq or 0, -- 685
			filesJson, -- 686
			t, -- 687
			t -- 688
		}) -- 688
		return -- 691
	end -- 691
	DB:exec( -- 693
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 693
		{ -- 705
			tool, -- 706
			statusPatch, -- 707
			status, -- 708
			reason, -- 709
			reason, -- 710
			reasoningContent, -- 711
			reasoningContent, -- 712
			paramsJson, -- 713
			paramsJson, -- 714
			resultJson, -- 715
			resultJson, -- 716
			patch.checkpointId or 0, -- 717
			patch.checkpointId or 0, -- 718
			patch.checkpointSeq or 0, -- 719
			patch.checkpointSeq or 0, -- 720
			filesJson, -- 721
			filesJson, -- 722
			now(), -- 723
			row[1] -- 724
		} -- 724
	) -- 724
end -- 724
function getNextStepNumber(sessionId, taskId) -- 729
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 730
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 734
	return math.max(0, current) + 1 -- 735
end -- 735
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 738
	if status == nil then -- 738
		status = "DONE" -- 746
	end -- 746
	local step = getNextStepNumber(sessionId, taskId) -- 748
	upsertStep( -- 749
		sessionId, -- 749
		taskId, -- 749
		step, -- 749
		tool, -- 749
		{status = status, reason = reason, params = params, result = result} -- 749
	) -- 749
	return getStepItem(sessionId, taskId, step) -- 755
end -- 755
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 758
	if taskId <= 0 then -- 758
		return -- 759
	end -- 759
	if finalSteps ~= nil and finalSteps >= 0 then -- 759
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 761
	end -- 761
	if not finalStatus then -- 761
		return -- 767
	end -- 767
	if finalSteps ~= nil and finalSteps >= 0 then -- 767
		DB:exec( -- 769
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 769
			{ -- 773
				finalStatus, -- 773
				now(), -- 773
				sessionId, -- 773
				taskId, -- 773
				finalSteps -- 773
			} -- 773
		) -- 773
		return -- 775
	end -- 775
	DB:exec( -- 777
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 777
		{ -- 781
			finalStatus, -- 781
			now(), -- 781
			sessionId, -- 781
			taskId -- 781
		} -- 781
	) -- 781
end -- 781
function emitAgentSessionPatch(sessionId, patch) -- 808
	if HttpServer.wsConnectionCount == 0 then -- 808
		return -- 810
	end -- 810
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 812
	if not text then -- 812
		return -- 817
	end -- 817
	emit("AppWS", "Send", text) -- 818
end -- 818
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 833
	emitAgentSessionPatch( -- 834
		sessionId, -- 834
		{ -- 834
			sessionDeleted = true, -- 835
			relatedSessions = listRelatedSessions(rootSessionId), -- 836
			pendingMergeCount = getPendingMergeCount(projectRoot), -- 837
			pendingMergeJobs = listPendingMergeJobs(projectRoot) -- 838
		} -- 838
	) -- 838
	local rootSession = getSessionItem(rootSessionId) -- 840
	if rootSession then -- 840
		emitAgentSessionPatch( -- 842
			rootSessionId, -- 842
			{ -- 842
				session = rootSession, -- 843
				relatedSessions = listRelatedSessions(rootSessionId), -- 844
				pendingMergeCount = getPendingMergeCount(projectRoot), -- 845
				pendingMergeJobs = listPendingMergeJobs(projectRoot) -- 846
			} -- 846
		) -- 846
	end -- 846
end -- 846
function flushPendingSubAgentHandoffs(rootSession) -- 851
	if rootSession.kind ~= "main" then -- 851
		return -- 852
	end -- 852
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 852
		return -- 854
	end -- 854
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 856
	if #items == 0 then -- 856
		return -- 857
	end -- 857
	local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 858
	if not taskRes.success then -- 858
		Log( -- 860
			"Warn", -- 860
			(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 860
		) -- 860
		return -- 861
	end -- 861
	local handoffTaskId = taskRes.taskId -- 863
	Tools.setTaskStatus(handoffTaskId, "DONE") -- 864
	setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 865
	emitAgentSessionPatch( -- 866
		rootSession.id, -- 866
		{session = getSessionItem(rootSession.id)} -- 866
	) -- 866
	do -- 866
		local i = 0 -- 869
		while i < #items do -- 869
			local item = items[i + 1] -- 870
			local step = appendSystemStep( -- 871
				rootSession.id, -- 872
				handoffTaskId, -- 873
				"sub_agent_handoff", -- 874
				"sub_agent_handoff", -- 875
				item.message, -- 876
				{sourceSessionId = item.sourceSessionId, sourceTitle = item.sourceTitle, sourceTaskId = item.sourceTaskId}, -- 877
				{ -- 882
					sourceSessionId = item.sourceSessionId, -- 883
					sourceTitle = item.sourceTitle, -- 884
					prompt = item.prompt, -- 885
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 886
					expectedOutput = item.expectedOutput or "", -- 887
					filesHint = item.filesHint or ({}) -- 888
				}, -- 888
				"DONE" -- 890
			) -- 890
			if step then -- 890
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 893
			end -- 893
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 895
			i = i + 1 -- 869
		end -- 869
	end -- 869
end -- 869
function applyEvent(sessionId, event) -- 899
	repeat -- 899
		local ____switch144 = event.type -- 899
		local ____cond144 = ____switch144 == "task_started" -- 899
		if ____cond144 then -- 899
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 902
			emitAgentSessionPatch( -- 903
				sessionId, -- 903
				{session = getSessionItem(sessionId)} -- 903
			) -- 903
			break -- 906
		end -- 906
		____cond144 = ____cond144 or ____switch144 == "decision_made" -- 906
		if ____cond144 then -- 906
			upsertStep( -- 908
				sessionId, -- 908
				event.taskId, -- 908
				event.step, -- 908
				event.tool, -- 908
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 908
			) -- 908
			emitAgentSessionPatch( -- 914
				sessionId, -- 914
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 914
			) -- 914
			break -- 917
		end -- 917
		____cond144 = ____cond144 or ____switch144 == "tool_started" -- 917
		if ____cond144 then -- 917
			upsertStep( -- 919
				sessionId, -- 919
				event.taskId, -- 919
				event.step, -- 919
				event.tool, -- 919
				{status = "RUNNING"} -- 919
			) -- 919
			emitAgentSessionPatch( -- 922
				sessionId, -- 922
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 922
			) -- 922
			break -- 925
		end -- 925
		____cond144 = ____cond144 or ____switch144 == "tool_finished" -- 925
		if ____cond144 then -- 925
			upsertStep( -- 927
				sessionId, -- 927
				event.taskId, -- 927
				event.step, -- 927
				event.tool, -- 927
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 927
			) -- 927
			emitAgentSessionPatch( -- 932
				sessionId, -- 932
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 932
			) -- 932
			break -- 935
		end -- 935
		____cond144 = ____cond144 or ____switch144 == "checkpoint_created" -- 935
		if ____cond144 then -- 935
			upsertStep( -- 937
				sessionId, -- 937
				event.taskId, -- 937
				event.step, -- 937
				event.tool, -- 937
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 937
			) -- 937
			emitAgentSessionPatch( -- 942
				sessionId, -- 942
				{ -- 942
					step = getStepItem(sessionId, event.taskId, event.step), -- 943
					checkpoints = Tools.listCheckpoints(event.taskId) -- 944
				} -- 944
			) -- 944
			break -- 946
		end -- 946
		____cond144 = ____cond144 or ____switch144 == "memory_compression_started" -- 946
		if ____cond144 then -- 946
			upsertStep( -- 948
				sessionId, -- 948
				event.taskId, -- 948
				event.step, -- 948
				event.tool, -- 948
				{status = "RUNNING", reason = event.reason, params = event.params} -- 948
			) -- 948
			emitAgentSessionPatch( -- 953
				sessionId, -- 953
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 953
			) -- 953
			break -- 956
		end -- 956
		____cond144 = ____cond144 or ____switch144 == "memory_compression_finished" -- 956
		if ____cond144 then -- 956
			upsertStep( -- 958
				sessionId, -- 958
				event.taskId, -- 958
				event.step, -- 958
				event.tool, -- 958
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 958
			) -- 958
			emitAgentSessionPatch( -- 963
				sessionId, -- 963
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 963
			) -- 963
			break -- 966
		end -- 966
		____cond144 = ____cond144 or ____switch144 == "memory_merge_started" -- 966
		if ____cond144 then -- 966
			do -- 966
				upsertStep( -- 968
					sessionId, -- 968
					event.taskId, -- 968
					event.step, -- 968
					"merge_memory", -- 968
					{ -- 968
						status = "RUNNING", -- 969
						reason = getDefaultUseChineseResponse() and ("正在合并来自 " .. event.sourceTitle) .. " 的记忆。" or ("Pending memory merge from " .. event.sourceTitle) .. ".", -- 970
						params = {jobId = event.jobId, sourceAgentId = event.sourceAgentId, sourceTitle = event.sourceTitle} -- 973
					} -- 973
				) -- 973
				emitAgentSessionPatch( -- 979
					sessionId, -- 979
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 979
				) -- 979
				break -- 982
			end -- 982
		end -- 982
		____cond144 = ____cond144 or ____switch144 == "memory_merge_finished" -- 982
		if ____cond144 then -- 982
			do -- 982
				upsertStep( -- 985
					sessionId, -- 985
					event.taskId, -- 985
					event.step, -- 985
					"merge_memory", -- 985
					{ -- 985
						status = event.success and "DONE" or "FAILED", -- 986
						reason = sanitizeUTF8(event.message), -- 987
						params = {jobId = event.jobId, sourceAgentId = event.sourceAgentId, sourceTitle = event.sourceTitle}, -- 988
						result = { -- 993
							success = event.success, -- 994
							attempts = event.attempts, -- 995
							jobId = event.jobId, -- 996
							sourceAgentId = event.sourceAgentId, -- 997
							sourceTitle = event.sourceTitle -- 998
						} -- 998
					} -- 998
				) -- 998
				emitAgentSessionPatch( -- 1001
					sessionId, -- 1001
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1001
				) -- 1001
				break -- 1004
			end -- 1004
		end -- 1004
		____cond144 = ____cond144 or ____switch144 == "assistant_message_updated" -- 1004
		if ____cond144 then -- 1004
			do -- 1004
				upsertStep( -- 1007
					sessionId, -- 1007
					event.taskId, -- 1007
					event.step, -- 1007
					"message", -- 1007
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1007
				) -- 1007
				emitAgentSessionPatch( -- 1012
					sessionId, -- 1012
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1012
				) -- 1012
				break -- 1015
			end -- 1015
		end -- 1015
		____cond144 = ____cond144 or ____switch144 == "task_finished" -- 1015
		if ____cond144 then -- 1015
			do -- 1015
				local ____opt_8 = activeStopTokens[event.taskId or -1] -- 1015
				local stopped = (____opt_8 and ____opt_8.stopped) == true -- 1018
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1019
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 1022
				if event.taskId ~= nil then -- 1022
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1024
					local ____finalizeTaskSteps_12 = finalizeTaskSteps -- 1025
					local ____array_11 = __TS__SparseArrayNew( -- 1025
						sessionId, -- 1026
						event.taskId, -- 1027
						type(event.steps) == "number" and math.max( -- 1028
							0, -- 1028
							math.floor(event.steps) -- 1028
						) or nil -- 1028
					) -- 1028
					local ____event_success_10 -- 1029
					if event.success then -- 1029
						____event_success_10 = nil -- 1029
					else -- 1029
						____event_success_10 = stopped and "STOPPED" or "FAILED" -- 1029
					end -- 1029
					__TS__SparseArrayPush(____array_11, ____event_success_10) -- 1029
					____finalizeTaskSteps_12(__TS__SparseArraySpread(____array_11)) -- 1025
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1031
					activeStopTokens[event.taskId] = nil -- 1032
					emitAgentSessionPatch( -- 1033
						sessionId, -- 1033
						{ -- 1033
							session = getSessionItem(sessionId), -- 1034
							message = getMessageItem(messageId), -- 1035
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1036
							removedStepIds = removedStepIds -- 1037
						} -- 1037
					) -- 1037
				end -- 1037
				local session = getSessionItem(sessionId) -- 1040
				if session and session.kind == "main" then -- 1040
					flushPendingSubAgentHandoffs(session) -- 1042
				end -- 1042
				break -- 1044
			end -- 1044
		end -- 1044
	until true -- 1044
end -- 1044
function ____exports.createSession(projectRoot, title) -- 1161
	if title == nil then -- 1161
		title = "" -- 1161
	end -- 1161
	if not isValidProjectRoot(projectRoot) then -- 1161
		return {success = false, message = "invalid projectRoot"} -- 1163
	end -- 1163
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1165
	if row then -- 1165
		return { -- 1174
			success = true, -- 1174
			session = rowToSession(row) -- 1174
		} -- 1174
	end -- 1174
	local t = now() -- 1176
	DB:exec( -- 1177
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1177
		{ -- 1180
			projectRoot, -- 1180
			title ~= "" and title or Path:getFilename(projectRoot), -- 1180
			t, -- 1180
			t -- 1180
		} -- 1180
	) -- 1180
	local sessionId = getLastInsertRowId() -- 1182
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1183
	local session = getSessionItem(sessionId) -- 1184
	if not session then -- 1184
		return {success = false, message = "failed to create session"} -- 1186
	end -- 1186
	return {success = true, session = session} -- 1188
end -- 1161
function ____exports.createSubSession(parentSessionId, title) -- 1191
	if title == nil then -- 1191
		title = "" -- 1191
	end -- 1191
	local parent = getSessionItem(parentSessionId) -- 1192
	if not parent then -- 1192
		return {success = false, message = "parent session not found"} -- 1194
	end -- 1194
	local rootId = getSessionRootId(parent) -- 1196
	local t = now() -- 1197
	DB:exec( -- 1198
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1198
		{ -- 1201
			parent.projectRoot, -- 1201
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1201
			rootId, -- 1201
			parent.id, -- 1201
			t, -- 1201
			t -- 1201
		} -- 1201
	) -- 1201
	local sessionId = getLastInsertRowId() -- 1203
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1204
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1205
	local session = getSessionItem(sessionId) -- 1206
	if not session then -- 1206
		return {success = false, message = "failed to create sub session"} -- 1208
	end -- 1208
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1210
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1211
	subStorage:writeMemory(parentStorage:readMemory()) -- 1212
	return {success = true, session = session} -- 1213
end -- 1191
function spawnSubAgentSession(request) -- 1216
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1216
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1227
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1228
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1229
		if normalizedPrompt == "" then -- 1229
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1231
		end -- 1231
		if normalizedPrompt == "" then -- 1231
			local ____Log_18 = Log -- 1238
			local ____temp_15 = #normalizedTitle -- 1238
			local ____temp_16 = #rawPrompt -- 1238
			local ____temp_17 = #toStr(request.expectedOutput) -- 1238
			local ____opt_13 = request.filesHint -- 1238
			____Log_18( -- 1238
				"Warn", -- 1238
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_15)) .. " raw_prompt_len=") .. tostring(____temp_16)) .. " expected_len=") .. tostring(____temp_17)) .. " files_hint_count=") .. tostring(____opt_13 and #____opt_13 or 0) -- 1238
			) -- 1238
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1238
		end -- 1238
		Log( -- 1241
			"Info", -- 1241
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1241
		) -- 1241
		local parentSessionId = request.parentSessionId -- 1242
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1242
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1244
			if not fallbackParent then -- 1244
				local createdMain = ____exports.createSession(request.projectRoot) -- 1246
				if createdMain.success then -- 1246
					fallbackParent = createdMain.session -- 1248
				end -- 1248
			end -- 1248
			if fallbackParent then -- 1248
				Log( -- 1252
					"Warn", -- 1252
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1252
				) -- 1252
				parentSessionId = fallbackParent.id -- 1253
			end -- 1253
		end -- 1253
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1256
		if not created.success then -- 1256
			return ____awaiter_resolve(nil, created) -- 1256
		end -- 1256
		writeSpawnInfo( -- 1260
			created.session.projectRoot, -- 1260
			created.session.memoryScope, -- 1260
			{ -- 1260
				prompt = normalizedPrompt, -- 1261
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1262
				expectedOutput = request.expectedOutput or "", -- 1263
				filesHint = request.filesHint or ({}), -- 1264
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1265
			} -- 1265
		) -- 1265
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1267
		if not sent.success then -- 1267
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1267
		end -- 1267
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1267
	end) -- 1267
end -- 1267
function buildSubAgentMemoryMergeJob(session) -- 1349
	if session.kind ~= "sub" then -- 1349
		return {success = true} -- 1351
	end -- 1351
	local rootSession = getRootSessionItem(session.id) -- 1353
	if not rootSession then -- 1353
		return {success = false, message = "root session not found"} -- 1355
	end -- 1355
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1357
	local finalMemory = storage:readMemory() -- 1358
	if __TS__StringTrim(finalMemory) == "" then -- 1358
		return {success = false, message = "sub session memory is empty"} -- 1360
	end -- 1360
	local queue = __TS__New(MemoryMergeQueue, session.projectRoot) -- 1362
	local spawnInfo = readSpawnInfo(session.projectRoot, session.memoryScope) -- 1363
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1364
	local sanitizedTitle = string.gsub(session.title, "[^%w_-]", "_") -- 1365
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1366
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1367
	local jobId = (((cleanedTime2 .. "_") .. sanitizeUTF8(sanitizedTitle)) .. "_") .. tostring(session.id) -- 1368
	local result = queue:writeJob({ -- 1369
		jobId = jobId, -- 1370
		rootAgentId = tostring(rootSession.id), -- 1371
		sourceAgentId = tostring(session.id), -- 1372
		sourceTitle = session.title, -- 1373
		createdAt = createdAt, -- 1374
		spawn = { -- 1375
			prompt = type(spawnInfo and spawnInfo.prompt) == "string" and spawnInfo.prompt or session.title, -- 1376
			goal = type(spawnInfo and spawnInfo.goal) == "string" and spawnInfo.goal or session.title, -- 1379
			expectedOutput = type(spawnInfo and spawnInfo.expectedOutput) == "string" and spawnInfo.expectedOutput or "", -- 1382
			filesHint = __TS__ArrayIsArray(spawnInfo and spawnInfo.filesHint) and spawnInfo.filesHint or ({}) -- 1385
		}, -- 1385
		memory = {finalMemory = finalMemory} -- 1389
	}) -- 1389
	if not result.success then -- 1389
		return result -- 1394
	end -- 1394
	return {success = true} -- 1396
end -- 1396
function appendSubAgentHandoffStep(session, taskId, message) -- 1399
	local rootSession = getRootSessionItem(session.id) -- 1400
	if not rootSession then -- 1400
		return -- 1401
	end -- 1401
	local spawnInfo = getSessionSpawnInfo(session) -- 1402
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1403
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1404
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1405
	local queueResult = writePendingHandoff( -- 1406
		rootSession.projectRoot, -- 1406
		rootSession.memoryScope, -- 1406
		{ -- 1406
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1407
			sourceSessionId = session.id, -- 1408
			sourceTitle = session.title, -- 1409
			sourceTaskId = taskId, -- 1410
			message = sanitizeUTF8(message), -- 1411
			prompt = spawnInfo and spawnInfo.prompt or "", -- 1412
			goal = spawnInfo and spawnInfo.goal or session.title, -- 1413
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 1414
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 1415
			createdAt = createdAt -- 1416
		} -- 1416
	) -- 1416
	if not queueResult then -- 1416
		Log( -- 1419
			"Warn", -- 1419
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1419
		) -- 1419
		return -- 1420
	end -- 1420
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1420
		flushPendingSubAgentHandoffs(rootSession) -- 1423
	end -- 1423
end -- 1423
function startSubSessionFinalize(session, taskId, message) -- 1427
	if not writeFinalizeInfo( -- 1427
		session.projectRoot, -- 1428
		session.memoryScope, -- 1428
		{ -- 1428
			sourceTaskId = taskId, -- 1429
			message = sanitizeUTF8(message), -- 1430
			createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1431
		} -- 1431
	) then -- 1431
		return {success = false, message = "failed to persist sub session finalize info"} -- 1433
	end -- 1433
	local compactPrompt = "/compact" -- 1435
	local sent = ____exports.sendPrompt(session.id, compactPrompt, true) -- 1436
	if not sent.success then -- 1436
		deleteFinalizeInfo(session.projectRoot, session.memoryScope) -- 1438
		return sent -- 1439
	end -- 1439
	return {success = true} -- 1441
end -- 1441
function completeSubSessionFinalizeAfterCompact(session) -- 1444
	local rootSessionId = getSessionRootId(session) -- 1445
	local projectRoot = session.projectRoot -- 1446
	local finalizeInfo = readFinalizeInfo(projectRoot, session.memoryScope) -- 1447
	if not finalizeInfo then -- 1447
		return {success = false, message = "sub session finalize info not found"} -- 1449
	end -- 1449
	appendSubAgentHandoffStep(session, finalizeInfo.sourceTaskId, finalizeInfo.message) -- 1451
	local mergeResult = buildSubAgentMemoryMergeJob(session) -- 1452
	if not mergeResult.success then -- 1452
		Log( -- 1454
			"Warn", -- 1454
			(("[AgentSession] sub session merge handoff failed session=" .. tostring(session.id)) .. " error=") .. mergeResult.message -- 1454
		) -- 1454
		return mergeResult -- 1455
	end -- 1455
	deleteFinalizeInfo(projectRoot, session.memoryScope) -- 1457
	deleteSessionRecords(session.id) -- 1458
	emitSessionDeletedPatch(session.id, rootSessionId, projectRoot) -- 1459
	return {success = true} -- 1460
end -- 1460
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 1463
	if allowSubSessionStart == nil then -- 1463
		allowSubSessionStart = false -- 1463
	end -- 1463
	local session = getSessionItem(sessionId) -- 1464
	if not session then -- 1464
		return {success = false, message = "session not found"} -- 1466
	end -- 1466
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 1466
		return {success = false, message = "session task is still running"} -- 1469
	end -- 1469
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 1471
	if normalizedPrompt == "" and session.kind == "sub" then -- 1471
		local spawnInfo = getSessionSpawnInfo(session) -- 1473
		if spawnInfo then -- 1473
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 1475
			if normalizedPrompt == "" then -- 1475
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 1477
			end -- 1477
		end -- 1477
	end -- 1477
	if normalizedPrompt == "" then -- 1477
		return {success = false, message = "prompt is empty"} -- 1486
	end -- 1486
	local taskRes = Tools.createTask(normalizedPrompt) -- 1488
	if not taskRes.success then -- 1488
		return {success = false, message = taskRes.message} -- 1490
	end -- 1490
	local taskId = taskRes.taskId -- 1492
	local useChineseResponse = getDefaultUseChineseResponse() -- 1493
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 1494
	local stopToken = {stopped = false} -- 1495
	activeStopTokens[taskId] = stopToken -- 1496
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 1497
	runCodingAgent( -- 1498
		{ -- 1498
			prompt = normalizedPrompt, -- 1499
			workDir = session.projectRoot, -- 1500
			useChineseResponse = useChineseResponse, -- 1501
			taskId = taskId, -- 1502
			sessionId = sessionId, -- 1503
			memoryScope = session.memoryScope, -- 1504
			role = session.kind, -- 1505
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 1506
			stopToken = stopToken, -- 1509
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 1510
		}, -- 1510
		function(result) -- 1511
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1511
				local nextSession = getSessionItem(sessionId) -- 1512
				if result.success then -- 1512
					if nextSession and nextSession.kind == "sub" then -- 1512
						if __TS__StringTrim(normalizedPrompt) == "/compact" then -- 1512
							if readFinalizeInfo(nextSession.projectRoot, nextSession.memoryScope) then -- 1512
								local finalized = completeSubSessionFinalizeAfterCompact(nextSession) -- 1517
								if not finalized.success then -- 1517
									Log( -- 1519
										"Warn", -- 1519
										(("[AgentSession] sub session compact finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 1519
									) -- 1519
								end -- 1519
							end -- 1519
						else -- 1519
							local started = startSubSessionFinalize(nextSession, taskId, result.message) -- 1523
							if not started.success then -- 1523
								Log( -- 1525
									"Warn", -- 1525
									(("[AgentSession] sub session finalize start failed session=" .. tostring(nextSession.id)) .. " error=") .. started.message -- 1525
								) -- 1525
							end -- 1525
						end -- 1525
					end -- 1525
				end -- 1525
				if not result.success then -- 1525
					applyEvent(sessionId, { -- 1531
						type = "task_finished", -- 1532
						sessionId = sessionId, -- 1533
						taskId = result.taskId, -- 1534
						success = false, -- 1535
						message = result.message, -- 1536
						steps = result.steps -- 1537
					}) -- 1537
				end -- 1537
			end) -- 1537
		end -- 1511
	) -- 1511
	return {success = true, sessionId = sessionId, taskId = taskId} -- 1541
end -- 1463
TABLE_SESSION = "AgentSession" -- 105
TABLE_MESSAGE = "AgentSessionMessage" -- 106
TABLE_STEP = "AgentSessionStep" -- 107
local TABLE_TASK = "AgentTask" -- 108
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 109
SPAWN_INFO_FILE = "SPAWN.json" -- 110
FINALIZE_INFO_FILE = "FINALIZE.json" -- 111
PENDING_HANDOFF_DIR = "pending-handoffs" -- 112
activeStopTokens = {} -- 133
now = function() return os.time() end -- 134
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 375
	if projectRoot == oldRoot then -- 375
		return newRoot -- 377
	end -- 377
	for ____, separator in ipairs({"/", "\\"}) do -- 379
		local prefix = oldRoot .. separator -- 380
		if __TS__StringStartsWith(projectRoot, prefix) then -- 380
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 382
		end -- 382
	end -- 382
	return nil -- 385
end -- 375
local function sanitizeStoredSteps(sessionId) -- 785
	DB:exec( -- 786
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 786
		{ -- 804
			now(), -- 804
			sessionId -- 804
		} -- 804
	) -- 804
end -- 785
local function emitSessionTreePatch(sessionId) -- 821
	local session = getSessionItem(sessionId) -- 822
	if not session then -- 822
		return -- 823
	end -- 823
	local ____emitAgentSessionPatch_7 = emitAgentSessionPatch -- 824
	local ____session_id_6 = session.id -- 824
	local ____session_2 = session -- 825
	local ____listRelatedSessions_result_3 = listRelatedSessions(session.id) -- 826
	local ____getPendingMergeCount_result_4 = getPendingMergeCount(session.projectRoot) -- 827
	local ____listPendingMergeJobs_result_5 = listPendingMergeJobs(session.projectRoot) -- 828
	local ____temp_1 -- 829
	if session.kind == "sub" then -- 829
		____temp_1 = getSessionSpawnInfo(session) -- 829
	else -- 829
		____temp_1 = nil -- 829
	end -- 829
	____emitAgentSessionPatch_7(____session_id_6, { -- 824
		session = ____session_2, -- 825
		relatedSessions = ____listRelatedSessions_result_3, -- 826
		pendingMergeCount = ____getPendingMergeCount_result_4, -- 827
		pendingMergeJobs = ____listPendingMergeJobs_result_5, -- 828
		spawnInfo = ____temp_1 -- 829
	}) -- 829
end -- 821
local function getSchemaVersion() -- 1049
	local row = queryOne("PRAGMA user_version") -- 1050
	return row and type(row[1]) == "number" and row[1] or 0 -- 1051
end -- 1049
local function setSchemaVersion(version) -- 1054
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1055
		0, -- 1055
		math.floor(version) -- 1055
	))) -- 1055
end -- 1054
local function recreateSchema() -- 1058
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1059
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1060
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1061
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1062
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1076
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1077
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1086
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1087
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1104
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1105
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1106
end -- 1058
do -- 1058
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1058
		recreateSchema() -- 1112
	else -- 1112
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1114
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1128
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1129
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1138
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1139
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1156
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1157
	end -- 1157
end -- 1157
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1279
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1279
		return {success = false, message = "invalid projectRoot"} -- 1281
	end -- 1281
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1283
	for ____, row in ipairs(rows) do -- 1284
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1285
		if sessionId > 0 then -- 1285
			deleteSessionRecords(sessionId) -- 1287
		end -- 1287
	end -- 1287
	return {success = true, deleted = #rows} -- 1290
end -- 1279
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1293
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1293
		return {success = false, message = "invalid projectRoot"} -- 1295
	end -- 1295
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1297
	local renamed = 0 -- 1298
	for ____, row in ipairs(rows) do -- 1299
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1300
		local projectRoot = toStr(row[2]) -- 1301
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1302
		if sessionId > 0 and nextProjectRoot then -- 1302
			DB:exec( -- 1304
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1304
				{ -- 1306
					nextProjectRoot, -- 1306
					Path:getFilename(nextProjectRoot), -- 1306
					now(), -- 1306
					sessionId -- 1306
				} -- 1306
			) -- 1306
			renamed = renamed + 1 -- 1308
		end -- 1308
	end -- 1308
	return {success = true, renamed = renamed} -- 1311
end -- 1293
function ____exports.getSession(sessionId) -- 1314
	local session = getSessionItem(sessionId) -- 1315
	if not session then -- 1315
		return {success = false, message = "session not found"} -- 1317
	end -- 1317
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1319
	local relatedSessions = listRelatedSessions(sessionId) -- 1320
	sanitizeStoredSteps(sessionId) -- 1321
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1322
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1329
	local ____relatedSessions_20 = relatedSessions -- 1340
	local ____getPendingMergeCount_result_21 = getPendingMergeCount(normalizedSession.projectRoot) -- 1341
	local ____listPendingMergeJobs_result_22 = listPendingMergeJobs(normalizedSession.projectRoot) -- 1342
	local ____temp_19 -- 1343
	if normalizedSession.kind == "sub" then -- 1343
		____temp_19 = getSessionSpawnInfo(normalizedSession) -- 1343
	else -- 1343
		____temp_19 = nil -- 1343
	end -- 1343
	return { -- 1337
		success = true, -- 1338
		session = normalizedSession, -- 1339
		relatedSessions = ____relatedSessions_20, -- 1340
		pendingMergeCount = ____getPendingMergeCount_result_21, -- 1341
		pendingMergeJobs = ____listPendingMergeJobs_result_22, -- 1342
		spawnInfo = ____temp_19, -- 1343
		messages = __TS__ArrayMap( -- 1344
			messages, -- 1344
			function(____, row) return rowToMessage(row) end -- 1344
		), -- 1344
		steps = __TS__ArrayMap( -- 1345
			steps, -- 1345
			function(____, row) return rowToStep(row) end -- 1345
		) -- 1345
	} -- 1345
end -- 1314
function ____exports.stopSessionTask(sessionId) -- 1544
	local session = getSessionItem(sessionId) -- 1545
	if not session or session.currentTaskId == nil then -- 1545
		return {success = false, message = "session task not found"} -- 1547
	end -- 1547
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1549
	local stopToken = activeStopTokens[session.currentTaskId] -- 1550
	if not stopToken then -- 1550
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 1550
			return {success = true, recovered = true} -- 1553
		end -- 1553
		return {success = false, message = "task is not running"} -- 1555
	end -- 1555
	stopToken.stopped = true -- 1557
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 1558
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1559
	return {success = true} -- 1560
end -- 1544
function ____exports.getCurrentTaskId(sessionId) -- 1563
	local ____opt_39 = getSessionItem(sessionId) -- 1563
	return ____opt_39 and ____opt_39.currentTaskId -- 1564
end -- 1563
function ____exports.listRunningSessions() -- 1567
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 1568
	local sessions = {} -- 1575
	do -- 1575
		local i = 0 -- 1576
		while i < #rows do -- 1576
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1577
			if session.currentTaskStatus == "RUNNING" then -- 1577
				sessions[#sessions + 1] = session -- 1579
			end -- 1579
			i = i + 1 -- 1576
		end -- 1576
	end -- 1576
	return {success = true, sessions = sessions} -- 1582
end -- 1567
return ____exports -- 1567