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
	local session = getSessionItem(sessionId) -- 315
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 316
	do -- 316
		local i = 0 -- 317
		while i < #children do -- 317
			local row = children[i + 1] -- 318
			if type(row[1]) == "number" and row[1] > 0 then -- 318
				deleteSessionRecords(row[1]) -- 320
			end -- 320
			i = i + 1 -- 317
		end -- 317
	end -- 317
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 323
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 324
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 325
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 326
	if session and session.kind == "sub" and session.memoryScope ~= "" then -- 326
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 328
	end -- 328
end -- 328
function getSessionRootId(session) -- 332
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 333
end -- 333
function getRootSessionItem(sessionId) -- 336
	local session = getSessionItem(sessionId) -- 337
	if not session then -- 337
		return nil -- 338
	end -- 338
	return getSessionItem(getSessionRootId(session)) or session -- 339
end -- 339
function listRelatedSessions(sessionId) -- 342
	local root = getRootSessionItem(sessionId) -- 343
	if not root then -- 343
		return {} -- 344
	end -- 344
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 345
	return __TS__ArrayMap( -- 354
		rows, -- 354
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 354
	) -- 354
end -- 354
function getPendingMergeCount(projectRoot) -- 357
	return #__TS__New(MemoryMergeQueue, projectRoot):listJobs() -- 358
end -- 358
function listPendingMergeJobs(projectRoot) -- 361
	return __TS__ArrayMap( -- 362
		__TS__New(MemoryMergeQueue, projectRoot):listJobs(), -- 362
		function(____, job) return { -- 362
			jobId = job.jobId, -- 363
			sourceAgentId = job.sourceAgentId, -- 364
			sourceTitle = job.sourceTitle, -- 365
			createdAt = job.createdAt, -- 366
			attempts = job.attempts, -- 367
			lastError = job.lastError -- 368
		} end -- 368
	) -- 368
end -- 368
function getSessionSpawnInfo(session) -- 372
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 373
	if not info then -- 373
		return nil -- 374
	end -- 374
	return { -- 375
		prompt = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "", -- 376
		goal = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "", -- 377
		expectedOutput = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil, -- 378
		filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 379
			__TS__ArrayFilter( -- 380
				info.filesHint, -- 380
				function(____, item) return type(item) == "string" end -- 380
			), -- 380
			function(____, item) return sanitizeUTF8(item) end -- 380
		) or nil, -- 380
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil -- 382
	} -- 382
end -- 382
function ensureDirRecursive(dir) -- 399
	if not dir or dir == "" then -- 399
		return false -- 400
	end -- 400
	if Content:exist(dir) then -- 400
		return Content:isdir(dir) -- 401
	end -- 401
	local parent = Path:getPath(dir) -- 402
	if parent and parent ~= dir and not Content:exist(parent) then -- 402
		if not ensureDirRecursive(parent) then -- 402
			return false -- 405
		end -- 405
	end -- 405
	return Content:mkdir(dir) -- 408
end -- 408
function writeSpawnInfo(projectRoot, memoryScope, value) -- 411
	local dir = Path(projectRoot, ".agent", memoryScope) -- 412
	if not Content:exist(dir) then -- 412
		ensureDirRecursive(dir) -- 414
	end -- 414
	local path = Path(dir, SPAWN_INFO_FILE) -- 416
	local text = safeJsonEncode(value) -- 417
	if not text then -- 417
		return false -- 418
	end -- 418
	return Content:save(path, text .. "\n") -- 419
end -- 419
function readSpawnInfo(projectRoot, memoryScope) -- 422
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 423
	if not Content:exist(path) then -- 423
		return nil -- 424
	end -- 424
	local text = Content:load(path) -- 425
	if not text or __TS__StringTrim(text) == "" then -- 425
		return nil -- 426
	end -- 426
	local value = safeJsonDecode(text) -- 427
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 427
		return value -- 429
	end -- 429
	return nil -- 431
end -- 431
function writeFinalizeInfo(projectRoot, memoryScope, value) -- 434
	local dir = Path(projectRoot, ".agent", memoryScope) -- 435
	if not Content:exist(dir) then -- 435
		ensureDirRecursive(dir) -- 437
	end -- 437
	local path = Path(dir, FINALIZE_INFO_FILE) -- 439
	local text = safeJsonEncode(value) -- 440
	if not text then -- 440
		return false -- 441
	end -- 441
	return Content:save(path, text .. "\n") -- 442
end -- 442
function readFinalizeInfo(projectRoot, memoryScope) -- 445
	local path = Path(projectRoot, ".agent", memoryScope, FINALIZE_INFO_FILE) -- 446
	if not Content:exist(path) then -- 446
		return nil -- 447
	end -- 447
	local text = Content:load(path) -- 448
	if not text or __TS__StringTrim(text) == "" then -- 448
		return nil -- 449
	end -- 449
	local value = safeJsonDecode(text) -- 450
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 450
		local sourceTaskId = tonumber(value.sourceTaskId) -- 452
		if not (sourceTaskId and sourceTaskId > 0) then -- 452
			return nil -- 453
		end -- 453
		return { -- 454
			sourceTaskId = sourceTaskId, -- 455
			message = sanitizeUTF8(toStr(value.message)), -- 456
			createdAt = type(value.createdAt) == "string" and sanitizeUTF8(value.createdAt) or nil -- 457
		} -- 457
	end -- 457
	return nil -- 462
end -- 462
function deleteFinalizeInfo(projectRoot, memoryScope) -- 465
	local path = Path(projectRoot, ".agent", memoryScope, FINALIZE_INFO_FILE) -- 466
	if Content:exist(path) then -- 466
		Content:remove(path) -- 468
	end -- 468
end -- 468
function getPendingHandoffDir(projectRoot, memoryScope) -- 472
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 473
end -- 473
function writePendingHandoff(projectRoot, memoryScope, value) -- 476
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 477
	if not Content:exist(dir) then -- 477
		ensureDirRecursive(dir) -- 479
	end -- 479
	local path = Path(dir, value.id .. ".json") -- 481
	local text = safeJsonEncode(value) -- 482
	if not text then -- 482
		return false -- 483
	end -- 483
	return Content:save(path, text .. "\n") -- 484
end -- 484
function listPendingHandoffs(projectRoot, memoryScope) -- 487
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 488
	if not Content:exist(dir) or not Content:isdir(dir) then -- 488
		return {} -- 489
	end -- 489
	local items = {} -- 490
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 491
		do -- 491
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 492
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 492
				goto __continue86 -- 493
			end -- 493
			local text = Content:load(path) -- 494
			if not text or __TS__StringTrim(text) == "" then -- 494
				goto __continue86 -- 495
			end -- 495
			local value = safeJsonDecode(text) -- 496
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 496
				goto __continue86 -- 497
			end -- 497
			local sourceTaskId = tonumber(value.sourceTaskId) -- 498
			local sourceSessionId = tonumber(value.sourceSessionId) -- 499
			local id = sanitizeUTF8(toStr(value.id)) -- 500
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 501
			local message = sanitizeUTF8(toStr(value.message)) -- 502
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 503
			local goal = sanitizeUTF8(toStr(value.goal)) -- 504
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 505
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 505
				goto __continue86 -- 507
			end -- 507
			items[#items + 1] = { -- 509
				id = id, -- 510
				sourceSessionId = sourceSessionId, -- 511
				sourceTitle = sourceTitle, -- 512
				sourceTaskId = sourceTaskId, -- 513
				message = message, -- 514
				prompt = prompt, -- 515
				goal = goal, -- 516
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 517
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 518
					__TS__ArrayFilter( -- 519
						value.filesHint, -- 519
						function(____, item) return type(item) == "string" end -- 519
					), -- 519
					function(____, item) return sanitizeUTF8(item) end -- 519
				) or ({}), -- 519
				createdAt = createdAt -- 521
			} -- 521
		end -- 521
		::__continue86:: -- 521
	end -- 521
	__TS__ArraySort( -- 524
		items, -- 524
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 524
	) -- 524
	return items -- 525
end -- 525
function deletePendingHandoff(projectRoot, memoryScope, id) -- 528
	local path = Path( -- 529
		getPendingHandoffDir(projectRoot, memoryScope), -- 529
		id .. ".json" -- 529
	) -- 529
	if Content:exist(path) then -- 529
		Content:remove(path) -- 531
	end -- 531
end -- 531
function normalizePromptText(prompt) -- 535
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 536
end -- 536
function normalizePromptTextSafe(prompt) -- 539
	if type(prompt) == "string" then -- 539
		local normalized = normalizePromptText(prompt) -- 541
		if normalized ~= "" then -- 541
			return normalized -- 542
		end -- 542
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 543
		if sanitized ~= "" then -- 543
			return truncateAgentUserPrompt(sanitized) -- 545
		end -- 545
		return "" -- 547
	end -- 547
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 549
	if text == "" then -- 549
		return "" -- 550
	end -- 550
	return truncateAgentUserPrompt(text) -- 551
end -- 551
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 554
	local sections = {} -- 555
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 556
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 557
	local normalizedFiles = __TS__ArrayFilter( -- 558
		__TS__ArrayMap( -- 558
			__TS__ArrayFilter( -- 558
				filesHint or ({}), -- 558
				function(____, item) return type(item) == "string" end -- 559
			), -- 559
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 560
		), -- 560
		function(____, item) return item ~= "" end -- 561
	) -- 561
	if normalizedTitle ~= "" then -- 561
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 563
	end -- 563
	if normalizedExpected ~= "" then -- 563
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 566
	end -- 566
	if #normalizedFiles > 0 then -- 566
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 569
	end -- 569
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 571
end -- 571
function normalizeSessionRuntimeState(session) -- 574
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 574
		return session -- 576
	end -- 576
	if activeStopTokens[session.currentTaskId] then -- 576
		return session -- 579
	end -- 579
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 581
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 582
	return __TS__ObjectAssign( -- 583
		{}, -- 583
		session, -- 584
		{ -- 583
			status = "STOPPED", -- 585
			currentTaskStatus = "STOPPED", -- 586
			updatedAt = now() -- 587
		} -- 587
	) -- 587
end -- 587
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 591
	DB:exec( -- 592
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 592
		{ -- 596
			status, -- 597
			currentTaskId or 0, -- 598
			currentTaskStatus or status, -- 599
			now(), -- 600
			sessionId -- 601
		} -- 601
	) -- 601
end -- 601
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 606
	if taskId == nil or taskId <= 0 then -- 606
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 608
		return -- 609
	end -- 609
	local row = getSessionRow(sessionId) -- 611
	if not row then -- 611
		return -- 612
	end -- 612
	local session = rowToSession(row) -- 613
	if session.currentTaskId ~= taskId then -- 613
		Log( -- 615
			"Info", -- 615
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 615
		) -- 615
		return -- 616
	end -- 616
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 618
end -- 618
function insertMessage(sessionId, role, content, taskId) -- 621
	local t = now() -- 622
	DB:exec( -- 623
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 623
		{ -- 626
			sessionId, -- 627
			taskId or 0, -- 628
			role, -- 629
			sanitizeUTF8(content), -- 630
			t, -- 631
			t -- 632
		} -- 632
	) -- 632
	return getLastInsertRowId() -- 635
end -- 635
function updateMessage(messageId, content) -- 638
	DB:exec( -- 639
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 639
		{ -- 641
			sanitizeUTF8(content), -- 641
			now(), -- 641
			messageId -- 641
		} -- 641
	) -- 641
end -- 641
function upsertAssistantMessage(sessionId, taskId, content) -- 645
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 646
	if row and type(row[1]) == "number" then -- 646
		updateMessage(row[1], content) -- 653
		return row[1] -- 654
	end -- 654
	return insertMessage(sessionId, "assistant", content, taskId) -- 656
end -- 656
function upsertStep(sessionId, taskId, step, tool, patch) -- 659
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 669
	local reason = sanitizeUTF8(patch.reason or "") -- 673
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 674
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 675
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 676
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 677
	local statusPatch = patch.status or "" -- 678
	local status = patch.status or "PENDING" -- 679
	if not row then -- 679
		local t = now() -- 681
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 682
			sessionId, -- 686
			taskId, -- 687
			step, -- 688
			tool, -- 689
			status, -- 690
			reason, -- 691
			reasoningContent, -- 692
			paramsJson, -- 693
			resultJson, -- 694
			patch.checkpointId or 0, -- 695
			patch.checkpointSeq or 0, -- 696
			filesJson, -- 697
			t, -- 698
			t -- 699
		}) -- 699
		return -- 702
	end -- 702
	DB:exec( -- 704
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 704
		{ -- 716
			tool, -- 717
			statusPatch, -- 718
			status, -- 719
			reason, -- 720
			reason, -- 721
			reasoningContent, -- 722
			reasoningContent, -- 723
			paramsJson, -- 724
			paramsJson, -- 725
			resultJson, -- 726
			resultJson, -- 727
			patch.checkpointId or 0, -- 728
			patch.checkpointId or 0, -- 729
			patch.checkpointSeq or 0, -- 730
			patch.checkpointSeq or 0, -- 731
			filesJson, -- 732
			filesJson, -- 733
			now(), -- 734
			row[1] -- 735
		} -- 735
	) -- 735
end -- 735
function getNextStepNumber(sessionId, taskId) -- 740
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 741
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 745
	return math.max(0, current) + 1 -- 746
end -- 746
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 749
	if status == nil then -- 749
		status = "DONE" -- 757
	end -- 757
	local step = getNextStepNumber(sessionId, taskId) -- 759
	upsertStep( -- 760
		sessionId, -- 760
		taskId, -- 760
		step, -- 760
		tool, -- 760
		{status = status, reason = reason, params = params, result = result} -- 760
	) -- 760
	return getStepItem(sessionId, taskId, step) -- 766
end -- 766
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 769
	if taskId <= 0 then -- 769
		return -- 770
	end -- 770
	if finalSteps ~= nil and finalSteps >= 0 then -- 770
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 772
	end -- 772
	if not finalStatus then -- 772
		return -- 778
	end -- 778
	if finalSteps ~= nil and finalSteps >= 0 then -- 778
		DB:exec( -- 780
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 780
			{ -- 784
				finalStatus, -- 784
				now(), -- 784
				sessionId, -- 784
				taskId, -- 784
				finalSteps -- 784
			} -- 784
		) -- 784
		return -- 786
	end -- 786
	DB:exec( -- 788
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 788
		{ -- 792
			finalStatus, -- 792
			now(), -- 792
			sessionId, -- 792
			taskId -- 792
		} -- 792
	) -- 792
end -- 792
function emitAgentSessionPatch(sessionId, patch) -- 819
	if HttpServer.wsConnectionCount == 0 then -- 819
		return -- 821
	end -- 821
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 823
	if not text then -- 823
		return -- 828
	end -- 828
	emit("AppWS", "Send", text) -- 829
end -- 829
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 844
	emitAgentSessionPatch( -- 845
		sessionId, -- 845
		{ -- 845
			sessionDeleted = true, -- 846
			relatedSessions = listRelatedSessions(rootSessionId), -- 847
			pendingMergeCount = getPendingMergeCount(projectRoot), -- 848
			pendingMergeJobs = listPendingMergeJobs(projectRoot) -- 849
		} -- 849
	) -- 849
	local rootSession = getSessionItem(rootSessionId) -- 851
	if rootSession then -- 851
		emitAgentSessionPatch( -- 853
			rootSessionId, -- 853
			{ -- 853
				session = rootSession, -- 854
				relatedSessions = listRelatedSessions(rootSessionId), -- 855
				pendingMergeCount = getPendingMergeCount(projectRoot), -- 856
				pendingMergeJobs = listPendingMergeJobs(projectRoot) -- 857
			} -- 857
		) -- 857
	end -- 857
end -- 857
function flushPendingSubAgentHandoffs(rootSession) -- 862
	if rootSession.kind ~= "main" then -- 862
		return -- 863
	end -- 863
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 863
		return -- 865
	end -- 865
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 867
	if #items == 0 then -- 867
		return -- 868
	end -- 868
	local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 869
	if not taskRes.success then -- 869
		Log( -- 871
			"Warn", -- 871
			(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 871
		) -- 871
		return -- 872
	end -- 872
	local handoffTaskId = taskRes.taskId -- 874
	Tools.setTaskStatus(handoffTaskId, "DONE") -- 875
	setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 876
	emitAgentSessionPatch( -- 877
		rootSession.id, -- 877
		{session = getSessionItem(rootSession.id)} -- 877
	) -- 877
	do -- 877
		local i = 0 -- 880
		while i < #items do -- 880
			local item = items[i + 1] -- 881
			local step = appendSystemStep( -- 882
				rootSession.id, -- 883
				handoffTaskId, -- 884
				"sub_agent_handoff", -- 885
				"sub_agent_handoff", -- 886
				item.message, -- 887
				{sourceSessionId = item.sourceSessionId, sourceTitle = item.sourceTitle, sourceTaskId = item.sourceTaskId}, -- 888
				{ -- 893
					sourceSessionId = item.sourceSessionId, -- 894
					sourceTitle = item.sourceTitle, -- 895
					prompt = item.prompt, -- 896
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 897
					expectedOutput = item.expectedOutput or "", -- 898
					filesHint = item.filesHint or ({}) -- 899
				}, -- 899
				"DONE" -- 901
			) -- 901
			if step then -- 901
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 904
			end -- 904
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 906
			i = i + 1 -- 880
		end -- 880
	end -- 880
end -- 880
function applyEvent(sessionId, event) -- 910
	repeat -- 910
		local ____switch148 = event.type -- 910
		local ____cond148 = ____switch148 == "task_started" -- 910
		if ____cond148 then -- 910
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 913
			emitAgentSessionPatch( -- 914
				sessionId, -- 914
				{session = getSessionItem(sessionId)} -- 914
			) -- 914
			break -- 917
		end -- 917
		____cond148 = ____cond148 or ____switch148 == "decision_made" -- 917
		if ____cond148 then -- 917
			upsertStep( -- 919
				sessionId, -- 919
				event.taskId, -- 919
				event.step, -- 919
				event.tool, -- 919
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 919
			) -- 919
			emitAgentSessionPatch( -- 925
				sessionId, -- 925
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 925
			) -- 925
			break -- 928
		end -- 928
		____cond148 = ____cond148 or ____switch148 == "tool_started" -- 928
		if ____cond148 then -- 928
			upsertStep( -- 930
				sessionId, -- 930
				event.taskId, -- 930
				event.step, -- 930
				event.tool, -- 930
				{status = "RUNNING"} -- 930
			) -- 930
			emitAgentSessionPatch( -- 933
				sessionId, -- 933
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 933
			) -- 933
			break -- 936
		end -- 936
		____cond148 = ____cond148 or ____switch148 == "tool_finished" -- 936
		if ____cond148 then -- 936
			upsertStep( -- 938
				sessionId, -- 938
				event.taskId, -- 938
				event.step, -- 938
				event.tool, -- 938
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 938
			) -- 938
			emitAgentSessionPatch( -- 943
				sessionId, -- 943
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 943
			) -- 943
			break -- 946
		end -- 946
		____cond148 = ____cond148 or ____switch148 == "checkpoint_created" -- 946
		if ____cond148 then -- 946
			upsertStep( -- 948
				sessionId, -- 948
				event.taskId, -- 948
				event.step, -- 948
				event.tool, -- 948
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 948
			) -- 948
			emitAgentSessionPatch( -- 953
				sessionId, -- 953
				{ -- 953
					step = getStepItem(sessionId, event.taskId, event.step), -- 954
					checkpoints = Tools.listCheckpoints(event.taskId) -- 955
				} -- 955
			) -- 955
			break -- 957
		end -- 957
		____cond148 = ____cond148 or ____switch148 == "memory_compression_started" -- 957
		if ____cond148 then -- 957
			upsertStep( -- 959
				sessionId, -- 959
				event.taskId, -- 959
				event.step, -- 959
				event.tool, -- 959
				{status = "RUNNING", reason = event.reason, params = event.params} -- 959
			) -- 959
			emitAgentSessionPatch( -- 964
				sessionId, -- 964
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 964
			) -- 964
			break -- 967
		end -- 967
		____cond148 = ____cond148 or ____switch148 == "memory_compression_finished" -- 967
		if ____cond148 then -- 967
			upsertStep( -- 969
				sessionId, -- 969
				event.taskId, -- 969
				event.step, -- 969
				event.tool, -- 969
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 969
			) -- 969
			emitAgentSessionPatch( -- 974
				sessionId, -- 974
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 974
			) -- 974
			break -- 977
		end -- 977
		____cond148 = ____cond148 or ____switch148 == "memory_merge_started" -- 977
		if ____cond148 then -- 977
			do -- 977
				upsertStep( -- 979
					sessionId, -- 979
					event.taskId, -- 979
					event.step, -- 979
					"merge_memory", -- 979
					{ -- 979
						status = "RUNNING", -- 980
						reason = getDefaultUseChineseResponse() and ("正在合并来自 " .. event.sourceTitle) .. " 的记忆。" or ("Pending memory merge from " .. event.sourceTitle) .. ".", -- 981
						params = {jobId = event.jobId, sourceAgentId = event.sourceAgentId, sourceTitle = event.sourceTitle} -- 984
					} -- 984
				) -- 984
				emitAgentSessionPatch( -- 990
					sessionId, -- 990
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 990
				) -- 990
				break -- 993
			end -- 993
		end -- 993
		____cond148 = ____cond148 or ____switch148 == "memory_merge_finished" -- 993
		if ____cond148 then -- 993
			do -- 993
				upsertStep( -- 996
					sessionId, -- 996
					event.taskId, -- 996
					event.step, -- 996
					"merge_memory", -- 996
					{ -- 996
						status = event.success and "DONE" or "FAILED", -- 997
						reason = sanitizeUTF8(event.message), -- 998
						params = {jobId = event.jobId, sourceAgentId = event.sourceAgentId, sourceTitle = event.sourceTitle}, -- 999
						result = { -- 1004
							success = event.success, -- 1005
							attempts = event.attempts, -- 1006
							jobId = event.jobId, -- 1007
							sourceAgentId = event.sourceAgentId, -- 1008
							sourceTitle = event.sourceTitle -- 1009
						} -- 1009
					} -- 1009
				) -- 1009
				emitAgentSessionPatch( -- 1012
					sessionId, -- 1012
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1012
				) -- 1012
				break -- 1015
			end -- 1015
		end -- 1015
		____cond148 = ____cond148 or ____switch148 == "assistant_message_updated" -- 1015
		if ____cond148 then -- 1015
			do -- 1015
				upsertStep( -- 1018
					sessionId, -- 1018
					event.taskId, -- 1018
					event.step, -- 1018
					"message", -- 1018
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1018
				) -- 1018
				emitAgentSessionPatch( -- 1023
					sessionId, -- 1023
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1023
				) -- 1023
				break -- 1026
			end -- 1026
		end -- 1026
		____cond148 = ____cond148 or ____switch148 == "task_finished" -- 1026
		if ____cond148 then -- 1026
			do -- 1026
				local ____opt_8 = activeStopTokens[event.taskId or -1] -- 1026
				local stopped = (____opt_8 and ____opt_8.stopped) == true -- 1029
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1030
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 1033
				if event.taskId ~= nil then -- 1033
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1035
					local ____finalizeTaskSteps_12 = finalizeTaskSteps -- 1036
					local ____array_11 = __TS__SparseArrayNew( -- 1036
						sessionId, -- 1037
						event.taskId, -- 1038
						type(event.steps) == "number" and math.max( -- 1039
							0, -- 1039
							math.floor(event.steps) -- 1039
						) or nil -- 1039
					) -- 1039
					local ____event_success_10 -- 1040
					if event.success then -- 1040
						____event_success_10 = nil -- 1040
					else -- 1040
						____event_success_10 = stopped and "STOPPED" or "FAILED" -- 1040
					end -- 1040
					__TS__SparseArrayPush(____array_11, ____event_success_10) -- 1040
					____finalizeTaskSteps_12(__TS__SparseArraySpread(____array_11)) -- 1036
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1042
					activeStopTokens[event.taskId] = nil -- 1043
					emitAgentSessionPatch( -- 1044
						sessionId, -- 1044
						{ -- 1044
							session = getSessionItem(sessionId), -- 1045
							message = getMessageItem(messageId), -- 1046
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1047
							removedStepIds = removedStepIds -- 1048
						} -- 1048
					) -- 1048
				end -- 1048
				local session = getSessionItem(sessionId) -- 1051
				if session and session.kind == "main" then -- 1051
					flushPendingSubAgentHandoffs(session) -- 1053
				end -- 1053
				break -- 1055
			end -- 1055
		end -- 1055
	until true -- 1055
end -- 1055
function ____exports.createSession(projectRoot, title) -- 1172
	if title == nil then -- 1172
		title = "" -- 1172
	end -- 1172
	if not isValidProjectRoot(projectRoot) then -- 1172
		return {success = false, message = "invalid projectRoot"} -- 1174
	end -- 1174
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1176
	if row then -- 1176
		return { -- 1185
			success = true, -- 1185
			session = rowToSession(row) -- 1185
		} -- 1185
	end -- 1185
	local t = now() -- 1187
	DB:exec( -- 1188
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1188
		{ -- 1191
			projectRoot, -- 1191
			title ~= "" and title or Path:getFilename(projectRoot), -- 1191
			t, -- 1191
			t -- 1191
		} -- 1191
	) -- 1191
	local sessionId = getLastInsertRowId() -- 1193
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1194
	local session = getSessionItem(sessionId) -- 1195
	if not session then -- 1195
		return {success = false, message = "failed to create session"} -- 1197
	end -- 1197
	return {success = true, session = session} -- 1199
end -- 1172
function ____exports.createSubSession(parentSessionId, title) -- 1202
	if title == nil then -- 1202
		title = "" -- 1202
	end -- 1202
	local parent = getSessionItem(parentSessionId) -- 1203
	if not parent then -- 1203
		return {success = false, message = "parent session not found"} -- 1205
	end -- 1205
	local rootId = getSessionRootId(parent) -- 1207
	local t = now() -- 1208
	DB:exec( -- 1209
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1209
		{ -- 1212
			parent.projectRoot, -- 1212
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1212
			rootId, -- 1212
			parent.id, -- 1212
			t, -- 1212
			t -- 1212
		} -- 1212
	) -- 1212
	local sessionId = getLastInsertRowId() -- 1214
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1215
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1216
	local session = getSessionItem(sessionId) -- 1217
	if not session then -- 1217
		return {success = false, message = "failed to create sub session"} -- 1219
	end -- 1219
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1221
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1222
	subStorage:writeMemory(parentStorage:readMemory()) -- 1223
	return {success = true, session = session} -- 1224
end -- 1202
function spawnSubAgentSession(request) -- 1227
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1227
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1238
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1239
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1240
		if normalizedPrompt == "" then -- 1240
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1242
		end -- 1242
		if normalizedPrompt == "" then -- 1242
			local ____Log_18 = Log -- 1249
			local ____temp_15 = #normalizedTitle -- 1249
			local ____temp_16 = #rawPrompt -- 1249
			local ____temp_17 = #toStr(request.expectedOutput) -- 1249
			local ____opt_13 = request.filesHint -- 1249
			____Log_18( -- 1249
				"Warn", -- 1249
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_15)) .. " raw_prompt_len=") .. tostring(____temp_16)) .. " expected_len=") .. tostring(____temp_17)) .. " files_hint_count=") .. tostring(____opt_13 and #____opt_13 or 0) -- 1249
			) -- 1249
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1249
		end -- 1249
		Log( -- 1252
			"Info", -- 1252
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1252
		) -- 1252
		local parentSessionId = request.parentSessionId -- 1253
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1253
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1255
			if not fallbackParent then -- 1255
				local createdMain = ____exports.createSession(request.projectRoot) -- 1257
				if createdMain.success then -- 1257
					fallbackParent = createdMain.session -- 1259
				end -- 1259
			end -- 1259
			if fallbackParent then -- 1259
				Log( -- 1263
					"Warn", -- 1263
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1263
				) -- 1263
				parentSessionId = fallbackParent.id -- 1264
			end -- 1264
		end -- 1264
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1267
		if not created.success then -- 1267
			return ____awaiter_resolve(nil, created) -- 1267
		end -- 1267
		writeSpawnInfo( -- 1271
			created.session.projectRoot, -- 1271
			created.session.memoryScope, -- 1271
			{ -- 1271
				prompt = normalizedPrompt, -- 1272
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1273
				expectedOutput = request.expectedOutput or "", -- 1274
				filesHint = request.filesHint or ({}), -- 1275
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1276
			} -- 1276
		) -- 1276
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1278
		if not sent.success then -- 1278
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1278
		end -- 1278
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1278
	end) -- 1278
end -- 1278
function buildSubAgentMemoryMergeJob(session) -- 1360
	if session.kind ~= "sub" then -- 1360
		return {success = true} -- 1362
	end -- 1362
	local rootSession = getRootSessionItem(session.id) -- 1364
	if not rootSession then -- 1364
		return {success = false, message = "root session not found"} -- 1366
	end -- 1366
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1368
	local finalMemory = storage:readMemory() -- 1369
	if __TS__StringTrim(finalMemory) == "" then -- 1369
		return {success = false, message = "sub session memory is empty"} -- 1371
	end -- 1371
	local queue = __TS__New(MemoryMergeQueue, session.projectRoot) -- 1373
	local spawnInfo = readSpawnInfo(session.projectRoot, session.memoryScope) -- 1374
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1375
	local sanitizedTitle = string.gsub(session.title, "[^%w_-]", "_") -- 1376
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1377
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1378
	local jobId = (((cleanedTime2 .. "_") .. sanitizeUTF8(sanitizedTitle)) .. "_") .. tostring(session.id) -- 1379
	local result = queue:writeJob({ -- 1380
		jobId = jobId, -- 1381
		rootAgentId = tostring(rootSession.id), -- 1382
		sourceAgentId = tostring(session.id), -- 1383
		sourceTitle = session.title, -- 1384
		createdAt = createdAt, -- 1385
		spawn = { -- 1386
			prompt = type(spawnInfo and spawnInfo.prompt) == "string" and spawnInfo.prompt or session.title, -- 1387
			goal = type(spawnInfo and spawnInfo.goal) == "string" and spawnInfo.goal or session.title, -- 1390
			expectedOutput = type(spawnInfo and spawnInfo.expectedOutput) == "string" and spawnInfo.expectedOutput or "", -- 1393
			filesHint = __TS__ArrayIsArray(spawnInfo and spawnInfo.filesHint) and spawnInfo.filesHint or ({}) -- 1396
		}, -- 1396
		memory = {finalMemory = finalMemory} -- 1400
	}) -- 1400
	if not result.success then -- 1400
		return result -- 1405
	end -- 1405
	return {success = true} -- 1407
end -- 1407
function appendSubAgentHandoffStep(session, taskId, message) -- 1410
	local rootSession = getRootSessionItem(session.id) -- 1411
	if not rootSession then -- 1411
		return -- 1412
	end -- 1412
	local spawnInfo = getSessionSpawnInfo(session) -- 1413
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1414
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1415
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1416
	local queueResult = writePendingHandoff( -- 1417
		rootSession.projectRoot, -- 1417
		rootSession.memoryScope, -- 1417
		{ -- 1417
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1418
			sourceSessionId = session.id, -- 1419
			sourceTitle = session.title, -- 1420
			sourceTaskId = taskId, -- 1421
			message = sanitizeUTF8(message), -- 1422
			prompt = spawnInfo and spawnInfo.prompt or "", -- 1423
			goal = spawnInfo and spawnInfo.goal or session.title, -- 1424
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 1425
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 1426
			createdAt = createdAt -- 1427
		} -- 1427
	) -- 1427
	if not queueResult then -- 1427
		Log( -- 1430
			"Warn", -- 1430
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1430
		) -- 1430
		return -- 1431
	end -- 1431
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1431
		flushPendingSubAgentHandoffs(rootSession) -- 1434
	end -- 1434
end -- 1434
function startSubSessionFinalize(session, taskId, message) -- 1438
	if not writeFinalizeInfo( -- 1438
		session.projectRoot, -- 1439
		session.memoryScope, -- 1439
		{ -- 1439
			sourceTaskId = taskId, -- 1440
			message = sanitizeUTF8(message), -- 1441
			createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1442
		} -- 1442
	) then -- 1442
		return {success = false, message = "failed to persist sub session finalize info"} -- 1444
	end -- 1444
	local compactPrompt = "/compact" -- 1446
	local sent = ____exports.sendPrompt(session.id, compactPrompt, true) -- 1447
	if not sent.success then -- 1447
		deleteFinalizeInfo(session.projectRoot, session.memoryScope) -- 1449
		return sent -- 1450
	end -- 1450
	return {success = true} -- 1452
end -- 1452
function completeSubSessionFinalizeAfterCompact(session) -- 1455
	local rootSessionId = getSessionRootId(session) -- 1456
	local projectRoot = session.projectRoot -- 1457
	local finalizeInfo = readFinalizeInfo(projectRoot, session.memoryScope) -- 1458
	if not finalizeInfo then -- 1458
		return {success = false, message = "sub session finalize info not found"} -- 1460
	end -- 1460
	appendSubAgentHandoffStep(session, finalizeInfo.sourceTaskId, finalizeInfo.message) -- 1462
	local mergeResult = buildSubAgentMemoryMergeJob(session) -- 1463
	if not mergeResult.success then -- 1463
		Log( -- 1465
			"Warn", -- 1465
			(("[AgentSession] sub session merge handoff failed session=" .. tostring(session.id)) .. " error=") .. mergeResult.message -- 1465
		) -- 1465
		return mergeResult -- 1466
	end -- 1466
	deleteFinalizeInfo(projectRoot, session.memoryScope) -- 1468
	deleteSessionRecords(session.id) -- 1469
	emitSessionDeletedPatch(session.id, rootSessionId, projectRoot) -- 1470
	return {success = true} -- 1471
end -- 1471
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 1474
	if allowSubSessionStart == nil then -- 1474
		allowSubSessionStart = false -- 1474
	end -- 1474
	local session = getSessionItem(sessionId) -- 1475
	if not session then -- 1475
		return {success = false, message = "session not found"} -- 1477
	end -- 1477
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 1477
		return {success = false, message = "session task is still running"} -- 1480
	end -- 1480
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 1482
	if normalizedPrompt == "" and session.kind == "sub" then -- 1482
		local spawnInfo = getSessionSpawnInfo(session) -- 1484
		if spawnInfo then -- 1484
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 1486
			if normalizedPrompt == "" then -- 1486
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 1488
			end -- 1488
		end -- 1488
	end -- 1488
	if normalizedPrompt == "" then -- 1488
		return {success = false, message = "prompt is empty"} -- 1497
	end -- 1497
	local taskRes = Tools.createTask(normalizedPrompt) -- 1499
	if not taskRes.success then -- 1499
		return {success = false, message = taskRes.message} -- 1501
	end -- 1501
	local taskId = taskRes.taskId -- 1503
	local useChineseResponse = getDefaultUseChineseResponse() -- 1504
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 1505
	local stopToken = {stopped = false} -- 1506
	activeStopTokens[taskId] = stopToken -- 1507
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 1508
	runCodingAgent( -- 1509
		{ -- 1509
			prompt = normalizedPrompt, -- 1510
			workDir = session.projectRoot, -- 1511
			useChineseResponse = useChineseResponse, -- 1512
			taskId = taskId, -- 1513
			sessionId = sessionId, -- 1514
			memoryScope = session.memoryScope, -- 1515
			role = session.kind, -- 1516
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 1517
			stopToken = stopToken, -- 1520
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 1521
		}, -- 1521
		function(result) -- 1522
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1522
				local nextSession = getSessionItem(sessionId) -- 1523
				if result.success then -- 1523
					if nextSession and nextSession.kind == "sub" then -- 1523
						if __TS__StringTrim(normalizedPrompt) == "/compact" then -- 1523
							if readFinalizeInfo(nextSession.projectRoot, nextSession.memoryScope) then -- 1523
								local finalized = completeSubSessionFinalizeAfterCompact(nextSession) -- 1528
								if not finalized.success then -- 1528
									Log( -- 1530
										"Warn", -- 1530
										(("[AgentSession] sub session compact finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 1530
									) -- 1530
								end -- 1530
							end -- 1530
						else -- 1530
							local started = startSubSessionFinalize(nextSession, taskId, result.message) -- 1534
							if not started.success then -- 1534
								Log( -- 1536
									"Warn", -- 1536
									(("[AgentSession] sub session finalize start failed session=" .. tostring(nextSession.id)) .. " error=") .. started.message -- 1536
								) -- 1536
							end -- 1536
						end -- 1536
					end -- 1536
				end -- 1536
				if not result.success then -- 1536
					applyEvent(sessionId, { -- 1542
						type = "task_finished", -- 1543
						sessionId = sessionId, -- 1544
						taskId = result.taskId, -- 1545
						success = false, -- 1546
						message = result.message, -- 1547
						steps = result.steps -- 1548
					}) -- 1548
				end -- 1548
			end) -- 1548
		end -- 1522
	) -- 1522
	return {success = true, sessionId = sessionId, taskId = taskId} -- 1552
end -- 1474
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
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 386
	if projectRoot == oldRoot then -- 386
		return newRoot -- 388
	end -- 388
	for ____, separator in ipairs({"/", "\\"}) do -- 390
		local prefix = oldRoot .. separator -- 391
		if __TS__StringStartsWith(projectRoot, prefix) then -- 391
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 393
		end -- 393
	end -- 393
	return nil -- 396
end -- 386
local function sanitizeStoredSteps(sessionId) -- 796
	DB:exec( -- 797
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 797
		{ -- 815
			now(), -- 815
			sessionId -- 815
		} -- 815
	) -- 815
end -- 796
local function emitSessionTreePatch(sessionId) -- 832
	local session = getSessionItem(sessionId) -- 833
	if not session then -- 833
		return -- 834
	end -- 834
	local ____emitAgentSessionPatch_7 = emitAgentSessionPatch -- 835
	local ____session_id_6 = session.id -- 835
	local ____session_2 = session -- 836
	local ____listRelatedSessions_result_3 = listRelatedSessions(session.id) -- 837
	local ____getPendingMergeCount_result_4 = getPendingMergeCount(session.projectRoot) -- 838
	local ____listPendingMergeJobs_result_5 = listPendingMergeJobs(session.projectRoot) -- 839
	local ____temp_1 -- 840
	if session.kind == "sub" then -- 840
		____temp_1 = getSessionSpawnInfo(session) -- 840
	else -- 840
		____temp_1 = nil -- 840
	end -- 840
	____emitAgentSessionPatch_7(____session_id_6, { -- 835
		session = ____session_2, -- 836
		relatedSessions = ____listRelatedSessions_result_3, -- 837
		pendingMergeCount = ____getPendingMergeCount_result_4, -- 838
		pendingMergeJobs = ____listPendingMergeJobs_result_5, -- 839
		spawnInfo = ____temp_1 -- 840
	}) -- 840
end -- 832
local function getSchemaVersion() -- 1060
	local row = queryOne("PRAGMA user_version") -- 1061
	return row and type(row[1]) == "number" and row[1] or 0 -- 1062
end -- 1060
local function setSchemaVersion(version) -- 1065
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1066
		0, -- 1066
		math.floor(version) -- 1066
	))) -- 1066
end -- 1065
local function recreateSchema() -- 1069
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1070
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1071
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1072
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1073
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1087
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1088
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1097
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1098
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1115
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1116
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1117
end -- 1069
do -- 1069
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1069
		recreateSchema() -- 1123
	else -- 1123
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1125
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1139
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1140
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1149
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1150
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1167
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1168
	end -- 1168
end -- 1168
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1290
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1290
		return {success = false, message = "invalid projectRoot"} -- 1292
	end -- 1292
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1294
	for ____, row in ipairs(rows) do -- 1295
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1296
		if sessionId > 0 then -- 1296
			deleteSessionRecords(sessionId) -- 1298
		end -- 1298
	end -- 1298
	return {success = true, deleted = #rows} -- 1301
end -- 1290
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1304
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1304
		return {success = false, message = "invalid projectRoot"} -- 1306
	end -- 1306
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1308
	local renamed = 0 -- 1309
	for ____, row in ipairs(rows) do -- 1310
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1311
		local projectRoot = toStr(row[2]) -- 1312
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1313
		if sessionId > 0 and nextProjectRoot then -- 1313
			DB:exec( -- 1315
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1315
				{ -- 1317
					nextProjectRoot, -- 1317
					Path:getFilename(nextProjectRoot), -- 1317
					now(), -- 1317
					sessionId -- 1317
				} -- 1317
			) -- 1317
			renamed = renamed + 1 -- 1319
		end -- 1319
	end -- 1319
	return {success = true, renamed = renamed} -- 1322
end -- 1304
function ____exports.getSession(sessionId) -- 1325
	local session = getSessionItem(sessionId) -- 1326
	if not session then -- 1326
		return {success = false, message = "session not found"} -- 1328
	end -- 1328
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1330
	local relatedSessions = listRelatedSessions(sessionId) -- 1331
	sanitizeStoredSteps(sessionId) -- 1332
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1333
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1340
	local ____relatedSessions_20 = relatedSessions -- 1351
	local ____getPendingMergeCount_result_21 = getPendingMergeCount(normalizedSession.projectRoot) -- 1352
	local ____listPendingMergeJobs_result_22 = listPendingMergeJobs(normalizedSession.projectRoot) -- 1353
	local ____temp_19 -- 1354
	if normalizedSession.kind == "sub" then -- 1354
		____temp_19 = getSessionSpawnInfo(normalizedSession) -- 1354
	else -- 1354
		____temp_19 = nil -- 1354
	end -- 1354
	return { -- 1348
		success = true, -- 1349
		session = normalizedSession, -- 1350
		relatedSessions = ____relatedSessions_20, -- 1351
		pendingMergeCount = ____getPendingMergeCount_result_21, -- 1352
		pendingMergeJobs = ____listPendingMergeJobs_result_22, -- 1353
		spawnInfo = ____temp_19, -- 1354
		messages = __TS__ArrayMap( -- 1355
			messages, -- 1355
			function(____, row) return rowToMessage(row) end -- 1355
		), -- 1355
		steps = __TS__ArrayMap( -- 1356
			steps, -- 1356
			function(____, row) return rowToStep(row) end -- 1356
		) -- 1356
	} -- 1356
end -- 1325
function ____exports.stopSessionTask(sessionId) -- 1555
	local session = getSessionItem(sessionId) -- 1556
	if not session or session.currentTaskId == nil then -- 1556
		return {success = false, message = "session task not found"} -- 1558
	end -- 1558
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1560
	local stopToken = activeStopTokens[session.currentTaskId] -- 1561
	if not stopToken then -- 1561
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 1561
			return {success = true, recovered = true} -- 1564
		end -- 1564
		return {success = false, message = "task is not running"} -- 1566
	end -- 1566
	stopToken.stopped = true -- 1568
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 1569
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1570
	return {success = true} -- 1571
end -- 1555
function ____exports.getCurrentTaskId(sessionId) -- 1574
	local ____opt_39 = getSessionItem(sessionId) -- 1574
	return ____opt_39 and ____opt_39.currentTaskId -- 1575
end -- 1574
function ____exports.listRunningSessions() -- 1578
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 1579
	local sessions = {} -- 1586
	do -- 1586
		local i = 0 -- 1587
		while i < #rows do -- 1587
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1588
			if session.currentTaskStatus == "RUNNING" then -- 1588
				sessions[#sessions + 1] = session -- 1590
			end -- 1590
			i = i + 1 -- 1587
		end -- 1587
	end -- 1587
	return {success = true, sessions = sessions} -- 1593
end -- 1578
return ____exports -- 1578