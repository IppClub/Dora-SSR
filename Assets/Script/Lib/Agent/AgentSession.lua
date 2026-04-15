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
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getPendingMergeCount, listPendingMergeJobs, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, writeFinalizeInfo, readFinalizeInfo, deleteFinalizeInfo, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, setSessionStateForTaskEvent, insertMessage, updateMessage, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, buildSubAgentMemoryMergeJob, appendSubAgentHandoffStep, startSubSessionFinalize, completeSubSessionFinalizeAfterCompact, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, FINALIZE_INFO_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, activeStopTokens, now -- 1
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
function getDefaultUseChineseResponse() -- 137
	local zh = string.match(App.locale, "^zh") -- 138
	return zh ~= nil -- 139
end -- 139
function toStr(v) -- 142
	if v == false or v == nil or v == nil then -- 142
		return "" -- 143
	end -- 143
	return tostring(v) -- 144
end -- 144
function encodeJson(value) -- 147
	local text = safeJsonEncode(value) -- 148
	return text or "" -- 149
end -- 149
function decodeJsonObject(text) -- 152
	if not text or text == "" then -- 152
		return nil -- 153
	end -- 153
	local value = safeJsonDecode(text) -- 154
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 154
		return value -- 156
	end -- 156
	return nil -- 158
end -- 158
function decodeJsonFiles(text) -- 161
	if not text or text == "" then -- 161
		return nil -- 162
	end -- 162
	local value = safeJsonDecode(text) -- 163
	if not value or not __TS__ArrayIsArray(value) then -- 163
		return nil -- 164
	end -- 164
	local files = {} -- 165
	do -- 165
		local i = 0 -- 166
		while i < #value do -- 166
			do -- 166
				local item = value[i + 1] -- 167
				if type(item) ~= "table" then -- 167
					goto __continue14 -- 168
				end -- 168
				files[#files + 1] = { -- 169
					path = sanitizeUTF8(toStr(item.path)), -- 170
					op = sanitizeUTF8(toStr(item.op)) -- 171
				} -- 171
			end -- 171
			::__continue14:: -- 171
			i = i + 1 -- 166
		end -- 166
	end -- 166
	return files -- 174
end -- 174
function queryRows(sql, args) -- 177
	local ____args_0 -- 178
	if args then -- 178
		____args_0 = DB:query(sql, args) -- 178
	else -- 178
		____args_0 = DB:query(sql) -- 178
	end -- 178
	return ____args_0 -- 178
end -- 178
function queryOne(sql, args) -- 181
	local rows = queryRows(sql, args) -- 182
	if not rows or #rows == 0 then -- 182
		return nil -- 183
	end -- 183
	return rows[1] -- 184
end -- 184
function getLastInsertRowId() -- 187
	local row = queryOne("SELECT last_insert_rowid()") -- 188
	return row and (row[1] or 0) or 0 -- 189
end -- 189
function isValidProjectRoot(path) -- 192
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 193
end -- 193
function rowToSession(row) -- 196
	return { -- 197
		id = row[1], -- 198
		projectRoot = toStr(row[2]), -- 199
		title = toStr(row[3]), -- 200
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 201
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 202
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 203
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 204
		status = toStr(row[8]), -- 205
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 206
		currentTaskStatus = toStr(row[10]), -- 207
		createdAt = row[11], -- 208
		updatedAt = row[12] -- 209
	} -- 209
end -- 209
function rowToMessage(row) -- 213
	return { -- 214
		id = row[1], -- 215
		sessionId = row[2], -- 216
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 217
		role = toStr(row[4]), -- 218
		content = toStr(row[5]), -- 219
		createdAt = row[6], -- 220
		updatedAt = row[7] -- 221
	} -- 221
end -- 221
function rowToStep(row) -- 225
	return { -- 226
		id = row[1], -- 227
		sessionId = row[2], -- 228
		taskId = row[3], -- 229
		step = row[4], -- 230
		tool = toStr(row[5]), -- 231
		status = toStr(row[6]), -- 232
		reason = toStr(row[7]), -- 233
		reasoningContent = toStr(row[8]), -- 234
		params = decodeJsonObject(toStr(row[9])), -- 235
		result = decodeJsonObject(toStr(row[10])), -- 236
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 237
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 238
		files = decodeJsonFiles(toStr(row[13])), -- 239
		createdAt = row[14], -- 240
		updatedAt = row[15] -- 241
	} -- 241
end -- 241
function getMessageItem(messageId) -- 245
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 246
	return row and rowToMessage(row) or nil -- 252
end -- 252
function getStepItem(sessionId, taskId, step) -- 255
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 256
	return row and rowToStep(row) or nil -- 262
end -- 262
function deleteMessageSteps(sessionId, taskId) -- 265
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 266
	local ids = {} -- 271
	do -- 271
		local i = 0 -- 272
		while i < #rows do -- 272
			local row = rows[i + 1] -- 273
			if type(row[1]) == "number" then -- 273
				ids[#ids + 1] = row[1] -- 275
			end -- 275
			i = i + 1 -- 272
		end -- 272
	end -- 272
	if #ids > 0 then -- 272
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 279
	end -- 279
	return ids -- 285
end -- 285
function getSessionRow(sessionId) -- 288
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 289
end -- 289
function getSessionItem(sessionId) -- 297
	local row = getSessionRow(sessionId) -- 298
	return row and rowToSession(row) or nil -- 299
end -- 299
function getTaskPrompt(taskId) -- 302
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 303
	if not row or type(row[1]) ~= "string" then -- 303
		return nil -- 304
	end -- 304
	return toStr(row[1]) -- 305
end -- 305
function getLatestMainSessionByProjectRoot(projectRoot) -- 308
	if not isValidProjectRoot(projectRoot) then -- 308
		return nil -- 309
	end -- 309
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 310
	return row and rowToSession(row) or nil -- 318
end -- 318
function countRunningSubSessions(rootSessionId) -- 321
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 322
	local count = 0 -- 329
	do -- 329
		local i = 0 -- 330
		while i < #rows do -- 330
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 331
			if session.currentTaskStatus == "RUNNING" then -- 331
				count = count + 1 -- 333
			end -- 333
			i = i + 1 -- 330
		end -- 330
	end -- 330
	return count -- 336
end -- 336
function deleteSessionRecords(sessionId) -- 339
	local session = getSessionItem(sessionId) -- 340
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 341
	do -- 341
		local i = 0 -- 342
		while i < #children do -- 342
			local row = children[i + 1] -- 343
			if type(row[1]) == "number" and row[1] > 0 then -- 343
				deleteSessionRecords(row[1]) -- 345
			end -- 345
			i = i + 1 -- 342
		end -- 342
	end -- 342
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 348
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 349
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 350
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 351
	if session and session.kind == "sub" and session.memoryScope ~= "" then -- 351
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 353
	end -- 353
end -- 353
function getSessionRootId(session) -- 357
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 358
end -- 358
function getRootSessionItem(sessionId) -- 361
	local session = getSessionItem(sessionId) -- 362
	if not session then -- 362
		return nil -- 363
	end -- 363
	return getSessionItem(getSessionRootId(session)) or session -- 364
end -- 364
function listRelatedSessions(sessionId) -- 367
	local root = getRootSessionItem(sessionId) -- 368
	if not root then -- 368
		return {} -- 369
	end -- 369
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 370
	return __TS__ArrayMap( -- 379
		rows, -- 379
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 379
	) -- 379
end -- 379
function getPendingMergeCount(projectRoot) -- 382
	return #__TS__New(MemoryMergeQueue, projectRoot):listJobs() -- 383
end -- 383
function listPendingMergeJobs(projectRoot) -- 386
	return __TS__ArrayMap( -- 387
		__TS__New(MemoryMergeQueue, projectRoot):listJobs(), -- 387
		function(____, job) return { -- 387
			jobId = job.jobId, -- 388
			sourceAgentId = job.sourceAgentId, -- 389
			sourceTitle = job.sourceTitle, -- 390
			createdAt = job.createdAt, -- 391
			attempts = job.attempts, -- 392
			lastError = job.lastError -- 393
		} end -- 393
	) -- 393
end -- 393
function getSessionSpawnInfo(session) -- 397
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 398
	if not info then -- 398
		return nil -- 399
	end -- 399
	return { -- 400
		prompt = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "", -- 401
		goal = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "", -- 402
		expectedOutput = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil, -- 403
		filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 404
			__TS__ArrayFilter( -- 405
				info.filesHint, -- 405
				function(____, item) return type(item) == "string" end -- 405
			), -- 405
			function(____, item) return sanitizeUTF8(item) end -- 405
		) or nil, -- 405
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil -- 407
	} -- 407
end -- 407
function ensureDirRecursive(dir) -- 424
	if not dir or dir == "" then -- 424
		return false -- 425
	end -- 425
	if Content:exist(dir) then -- 425
		return Content:isdir(dir) -- 426
	end -- 426
	local parent = Path:getPath(dir) -- 427
	if parent and parent ~= dir and not Content:exist(parent) then -- 427
		if not ensureDirRecursive(parent) then -- 427
			return false -- 430
		end -- 430
	end -- 430
	return Content:mkdir(dir) -- 433
end -- 433
function writeSpawnInfo(projectRoot, memoryScope, value) -- 436
	local dir = Path(projectRoot, ".agent", memoryScope) -- 437
	if not Content:exist(dir) then -- 437
		ensureDirRecursive(dir) -- 439
	end -- 439
	local path = Path(dir, SPAWN_INFO_FILE) -- 441
	local text = safeJsonEncode(value) -- 442
	if not text then -- 442
		return false -- 443
	end -- 443
	return Content:save(path, text .. "\n") -- 444
end -- 444
function readSpawnInfo(projectRoot, memoryScope) -- 447
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 448
	if not Content:exist(path) then -- 448
		return nil -- 449
	end -- 449
	local text = Content:load(path) -- 450
	if not text or __TS__StringTrim(text) == "" then -- 450
		return nil -- 451
	end -- 451
	local value = safeJsonDecode(text) -- 452
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 452
		return value -- 454
	end -- 454
	return nil -- 456
end -- 456
function writeFinalizeInfo(projectRoot, memoryScope, value) -- 459
	local dir = Path(projectRoot, ".agent", memoryScope) -- 460
	if not Content:exist(dir) then -- 460
		ensureDirRecursive(dir) -- 462
	end -- 462
	local path = Path(dir, FINALIZE_INFO_FILE) -- 464
	local text = safeJsonEncode(value) -- 465
	if not text then -- 465
		return false -- 466
	end -- 466
	return Content:save(path, text .. "\n") -- 467
end -- 467
function readFinalizeInfo(projectRoot, memoryScope) -- 470
	local path = Path(projectRoot, ".agent", memoryScope, FINALIZE_INFO_FILE) -- 471
	if not Content:exist(path) then -- 471
		return nil -- 472
	end -- 472
	local text = Content:load(path) -- 473
	if not text or __TS__StringTrim(text) == "" then -- 473
		return nil -- 474
	end -- 474
	local value = safeJsonDecode(text) -- 475
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 475
		local sourceTaskId = tonumber(value.sourceTaskId) -- 477
		if not (sourceTaskId and sourceTaskId > 0) then -- 477
			return nil -- 478
		end -- 478
		return { -- 479
			sourceTaskId = sourceTaskId, -- 480
			message = sanitizeUTF8(toStr(value.message)), -- 481
			createdAt = type(value.createdAt) == "string" and sanitizeUTF8(value.createdAt) or nil -- 482
		} -- 482
	end -- 482
	return nil -- 487
end -- 487
function deleteFinalizeInfo(projectRoot, memoryScope) -- 490
	local path = Path(projectRoot, ".agent", memoryScope, FINALIZE_INFO_FILE) -- 491
	if Content:exist(path) then -- 491
		Content:remove(path) -- 493
	end -- 493
end -- 493
function getPendingHandoffDir(projectRoot, memoryScope) -- 497
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 498
end -- 498
function writePendingHandoff(projectRoot, memoryScope, value) -- 501
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 502
	if not Content:exist(dir) then -- 502
		ensureDirRecursive(dir) -- 504
	end -- 504
	local path = Path(dir, value.id .. ".json") -- 506
	local text = safeJsonEncode(value) -- 507
	if not text then -- 507
		return false -- 508
	end -- 508
	return Content:save(path, text .. "\n") -- 509
end -- 509
function listPendingHandoffs(projectRoot, memoryScope) -- 512
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 513
	if not Content:exist(dir) or not Content:isdir(dir) then -- 513
		return {} -- 514
	end -- 514
	local items = {} -- 515
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 516
		do -- 516
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 517
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 517
				goto __continue92 -- 518
			end -- 518
			local text = Content:load(path) -- 519
			if not text or __TS__StringTrim(text) == "" then -- 519
				goto __continue92 -- 520
			end -- 520
			local value = safeJsonDecode(text) -- 521
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 521
				goto __continue92 -- 522
			end -- 522
			local sourceTaskId = tonumber(value.sourceTaskId) -- 523
			local sourceSessionId = tonumber(value.sourceSessionId) -- 524
			local id = sanitizeUTF8(toStr(value.id)) -- 525
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 526
			local message = sanitizeUTF8(toStr(value.message)) -- 527
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 528
			local goal = sanitizeUTF8(toStr(value.goal)) -- 529
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 530
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 530
				goto __continue92 -- 532
			end -- 532
			items[#items + 1] = { -- 534
				id = id, -- 535
				sourceSessionId = sourceSessionId, -- 536
				sourceTitle = sourceTitle, -- 537
				sourceTaskId = sourceTaskId, -- 538
				message = message, -- 539
				prompt = prompt, -- 540
				goal = goal, -- 541
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 542
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 543
					__TS__ArrayFilter( -- 544
						value.filesHint, -- 544
						function(____, item) return type(item) == "string" end -- 544
					), -- 544
					function(____, item) return sanitizeUTF8(item) end -- 544
				) or ({}), -- 544
				createdAt = createdAt -- 546
			} -- 546
		end -- 546
		::__continue92:: -- 546
	end -- 546
	__TS__ArraySort( -- 549
		items, -- 549
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 549
	) -- 549
	return items -- 550
end -- 550
function deletePendingHandoff(projectRoot, memoryScope, id) -- 553
	local path = Path( -- 554
		getPendingHandoffDir(projectRoot, memoryScope), -- 554
		id .. ".json" -- 554
	) -- 554
	if Content:exist(path) then -- 554
		Content:remove(path) -- 556
	end -- 556
end -- 556
function normalizePromptText(prompt) -- 560
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 561
end -- 561
function normalizePromptTextSafe(prompt) -- 564
	if type(prompt) == "string" then -- 564
		local normalized = normalizePromptText(prompt) -- 566
		if normalized ~= "" then -- 566
			return normalized -- 567
		end -- 567
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 568
		if sanitized ~= "" then -- 568
			return truncateAgentUserPrompt(sanitized) -- 570
		end -- 570
		return "" -- 572
	end -- 572
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 574
	if text == "" then -- 574
		return "" -- 575
	end -- 575
	return truncateAgentUserPrompt(text) -- 576
end -- 576
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 579
	local sections = {} -- 580
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 581
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 582
	local normalizedFiles = __TS__ArrayFilter( -- 583
		__TS__ArrayMap( -- 583
			__TS__ArrayFilter( -- 583
				filesHint or ({}), -- 583
				function(____, item) return type(item) == "string" end -- 584
			), -- 584
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 585
		), -- 585
		function(____, item) return item ~= "" end -- 586
	) -- 586
	if normalizedTitle ~= "" then -- 586
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 588
	end -- 588
	if normalizedExpected ~= "" then -- 588
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 591
	end -- 591
	if #normalizedFiles > 0 then -- 591
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 594
	end -- 594
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 596
end -- 596
function normalizeSessionRuntimeState(session) -- 599
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 599
		return session -- 601
	end -- 601
	if activeStopTokens[session.currentTaskId] then -- 601
		return session -- 604
	end -- 604
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 606
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 607
	return __TS__ObjectAssign( -- 608
		{}, -- 608
		session, -- 609
		{ -- 608
			status = "STOPPED", -- 610
			currentTaskStatus = "STOPPED", -- 611
			updatedAt = now() -- 612
		} -- 612
	) -- 612
end -- 612
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 616
	DB:exec( -- 617
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 617
		{ -- 621
			status, -- 622
			currentTaskId or 0, -- 623
			currentTaskStatus or status, -- 624
			now(), -- 625
			sessionId -- 626
		} -- 626
	) -- 626
end -- 626
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 631
	if taskId == nil or taskId <= 0 then -- 631
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 633
		return -- 634
	end -- 634
	local row = getSessionRow(sessionId) -- 636
	if not row then -- 636
		return -- 637
	end -- 637
	local session = rowToSession(row) -- 638
	if session.currentTaskId ~= taskId then -- 638
		Log( -- 640
			"Info", -- 640
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 640
		) -- 640
		return -- 641
	end -- 641
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 643
end -- 643
function insertMessage(sessionId, role, content, taskId) -- 646
	local t = now() -- 647
	DB:exec( -- 648
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 648
		{ -- 651
			sessionId, -- 652
			taskId or 0, -- 653
			role, -- 654
			sanitizeUTF8(content), -- 655
			t, -- 656
			t -- 657
		} -- 657
	) -- 657
	return getLastInsertRowId() -- 660
end -- 660
function updateMessage(messageId, content) -- 663
	DB:exec( -- 664
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 664
		{ -- 666
			sanitizeUTF8(content), -- 666
			now(), -- 666
			messageId -- 666
		} -- 666
	) -- 666
end -- 666
function upsertAssistantMessage(sessionId, taskId, content) -- 670
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 671
	if row and type(row[1]) == "number" then -- 671
		updateMessage(row[1], content) -- 678
		return row[1] -- 679
	end -- 679
	return insertMessage(sessionId, "assistant", content, taskId) -- 681
end -- 681
function upsertStep(sessionId, taskId, step, tool, patch) -- 684
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 694
	local reason = sanitizeUTF8(patch.reason or "") -- 698
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 699
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 700
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 701
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 702
	local statusPatch = patch.status or "" -- 703
	local status = patch.status or "PENDING" -- 704
	if not row then -- 704
		local t = now() -- 706
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 707
			sessionId, -- 711
			taskId, -- 712
			step, -- 713
			tool, -- 714
			status, -- 715
			reason, -- 716
			reasoningContent, -- 717
			paramsJson, -- 718
			resultJson, -- 719
			patch.checkpointId or 0, -- 720
			patch.checkpointSeq or 0, -- 721
			filesJson, -- 722
			t, -- 723
			t -- 724
		}) -- 724
		return -- 727
	end -- 727
	DB:exec( -- 729
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 729
		{ -- 741
			tool, -- 742
			statusPatch, -- 743
			status, -- 744
			reason, -- 745
			reason, -- 746
			reasoningContent, -- 747
			reasoningContent, -- 748
			paramsJson, -- 749
			paramsJson, -- 750
			resultJson, -- 751
			resultJson, -- 752
			patch.checkpointId or 0, -- 753
			patch.checkpointId or 0, -- 754
			patch.checkpointSeq or 0, -- 755
			patch.checkpointSeq or 0, -- 756
			filesJson, -- 757
			filesJson, -- 758
			now(), -- 759
			row[1] -- 760
		} -- 760
	) -- 760
end -- 760
function getNextStepNumber(sessionId, taskId) -- 765
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 766
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 770
	return math.max(0, current) + 1 -- 771
end -- 771
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 774
	if status == nil then -- 774
		status = "DONE" -- 782
	end -- 782
	local step = getNextStepNumber(sessionId, taskId) -- 784
	upsertStep( -- 785
		sessionId, -- 785
		taskId, -- 785
		step, -- 785
		tool, -- 785
		{status = status, reason = reason, params = params, result = result} -- 785
	) -- 785
	return getStepItem(sessionId, taskId, step) -- 791
end -- 791
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 794
	if taskId <= 0 then -- 794
		return -- 795
	end -- 795
	if finalSteps ~= nil and finalSteps >= 0 then -- 795
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 797
	end -- 797
	if not finalStatus then -- 797
		return -- 803
	end -- 803
	if finalSteps ~= nil and finalSteps >= 0 then -- 803
		DB:exec( -- 805
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 805
			{ -- 809
				finalStatus, -- 809
				now(), -- 809
				sessionId, -- 809
				taskId, -- 809
				finalSteps -- 809
			} -- 809
		) -- 809
		return -- 811
	end -- 811
	DB:exec( -- 813
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 813
		{ -- 817
			finalStatus, -- 817
			now(), -- 817
			sessionId, -- 817
			taskId -- 817
		} -- 817
	) -- 817
end -- 817
function emitAgentSessionPatch(sessionId, patch) -- 844
	if HttpServer.wsConnectionCount == 0 then -- 844
		return -- 846
	end -- 846
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 848
	if not text then -- 848
		return -- 853
	end -- 853
	emit("AppWS", "Send", text) -- 854
end -- 854
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 869
	emitAgentSessionPatch( -- 870
		sessionId, -- 870
		{ -- 870
			sessionDeleted = true, -- 871
			relatedSessions = listRelatedSessions(rootSessionId), -- 872
			pendingMergeCount = getPendingMergeCount(projectRoot), -- 873
			pendingMergeJobs = listPendingMergeJobs(projectRoot) -- 874
		} -- 874
	) -- 874
	local rootSession = getSessionItem(rootSessionId) -- 876
	if rootSession then -- 876
		emitAgentSessionPatch( -- 878
			rootSessionId, -- 878
			{ -- 878
				session = rootSession, -- 879
				relatedSessions = listRelatedSessions(rootSessionId), -- 880
				pendingMergeCount = getPendingMergeCount(projectRoot), -- 881
				pendingMergeJobs = listPendingMergeJobs(projectRoot) -- 882
			} -- 882
		) -- 882
	end -- 882
end -- 882
function flushPendingSubAgentHandoffs(rootSession) -- 887
	if rootSession.kind ~= "main" then -- 887
		return -- 888
	end -- 888
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 888
		return -- 890
	end -- 890
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 892
	if #items == 0 then -- 892
		return -- 893
	end -- 893
	local handoffTaskId = 0 -- 894
	local ____rootSession_currentTaskId_8 -- 895
	if rootSession.currentTaskId then -- 895
		____rootSession_currentTaskId_8 = getTaskPrompt(rootSession.currentTaskId) -- 895
	else -- 895
		____rootSession_currentTaskId_8 = nil -- 895
	end -- 895
	local currentTaskPrompt = ____rootSession_currentTaskId_8 -- 895
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 895
		handoffTaskId = rootSession.currentTaskId -- 903
	else -- 903
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 905
		if not taskRes.success then -- 905
			Log( -- 907
				"Warn", -- 907
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 907
			) -- 907
			return -- 908
		end -- 908
		handoffTaskId = taskRes.taskId -- 910
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 911
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 912
		emitAgentSessionPatch( -- 913
			rootSession.id, -- 913
			{session = getSessionItem(rootSession.id)} -- 913
		) -- 913
	end -- 913
	do -- 913
		local i = 0 -- 917
		while i < #items do -- 917
			local item = items[i + 1] -- 918
			local step = appendSystemStep( -- 919
				rootSession.id, -- 920
				handoffTaskId, -- 921
				"sub_agent_handoff", -- 922
				"sub_agent_handoff", -- 923
				item.message, -- 924
				{sourceSessionId = item.sourceSessionId, sourceTitle = item.sourceTitle, sourceTaskId = item.sourceTaskId}, -- 925
				{ -- 930
					sourceSessionId = item.sourceSessionId, -- 931
					sourceTitle = item.sourceTitle, -- 932
					prompt = item.prompt, -- 933
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 934
					expectedOutput = item.expectedOutput or "", -- 935
					filesHint = item.filesHint or ({}) -- 936
				}, -- 936
				"DONE" -- 938
			) -- 938
			if step then -- 938
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 941
			end -- 941
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 943
			i = i + 1 -- 917
		end -- 917
	end -- 917
end -- 917
function applyEvent(sessionId, event) -- 947
	repeat -- 947
		local ____switch156 = event.type -- 947
		local ____cond156 = ____switch156 == "task_started" -- 947
		if ____cond156 then -- 947
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 950
			emitAgentSessionPatch( -- 951
				sessionId, -- 951
				{session = getSessionItem(sessionId)} -- 951
			) -- 951
			break -- 954
		end -- 954
		____cond156 = ____cond156 or ____switch156 == "decision_made" -- 954
		if ____cond156 then -- 954
			upsertStep( -- 956
				sessionId, -- 956
				event.taskId, -- 956
				event.step, -- 956
				event.tool, -- 956
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 956
			) -- 956
			emitAgentSessionPatch( -- 962
				sessionId, -- 962
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 962
			) -- 962
			break -- 965
		end -- 965
		____cond156 = ____cond156 or ____switch156 == "tool_started" -- 965
		if ____cond156 then -- 965
			upsertStep( -- 967
				sessionId, -- 967
				event.taskId, -- 967
				event.step, -- 967
				event.tool, -- 967
				{status = "RUNNING"} -- 967
			) -- 967
			emitAgentSessionPatch( -- 970
				sessionId, -- 970
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 970
			) -- 970
			break -- 973
		end -- 973
		____cond156 = ____cond156 or ____switch156 == "tool_finished" -- 973
		if ____cond156 then -- 973
			upsertStep( -- 975
				sessionId, -- 975
				event.taskId, -- 975
				event.step, -- 975
				event.tool, -- 975
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 975
			) -- 975
			emitAgentSessionPatch( -- 980
				sessionId, -- 980
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 980
			) -- 980
			break -- 983
		end -- 983
		____cond156 = ____cond156 or ____switch156 == "checkpoint_created" -- 983
		if ____cond156 then -- 983
			upsertStep( -- 985
				sessionId, -- 985
				event.taskId, -- 985
				event.step, -- 985
				event.tool, -- 985
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 985
			) -- 985
			emitAgentSessionPatch( -- 990
				sessionId, -- 990
				{ -- 990
					step = getStepItem(sessionId, event.taskId, event.step), -- 991
					checkpoints = Tools.listCheckpoints(event.taskId) -- 992
				} -- 992
			) -- 992
			break -- 994
		end -- 994
		____cond156 = ____cond156 or ____switch156 == "memory_compression_started" -- 994
		if ____cond156 then -- 994
			upsertStep( -- 996
				sessionId, -- 996
				event.taskId, -- 996
				event.step, -- 996
				event.tool, -- 996
				{status = "RUNNING", reason = event.reason, params = event.params} -- 996
			) -- 996
			emitAgentSessionPatch( -- 1001
				sessionId, -- 1001
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1001
			) -- 1001
			break -- 1004
		end -- 1004
		____cond156 = ____cond156 or ____switch156 == "memory_compression_finished" -- 1004
		if ____cond156 then -- 1004
			upsertStep( -- 1006
				sessionId, -- 1006
				event.taskId, -- 1006
				event.step, -- 1006
				event.tool, -- 1006
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1006
			) -- 1006
			emitAgentSessionPatch( -- 1011
				sessionId, -- 1011
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1011
			) -- 1011
			break -- 1014
		end -- 1014
		____cond156 = ____cond156 or ____switch156 == "memory_merge_started" -- 1014
		if ____cond156 then -- 1014
			do -- 1014
				upsertStep( -- 1016
					sessionId, -- 1016
					event.taskId, -- 1016
					event.step, -- 1016
					"merge_memory", -- 1016
					{ -- 1016
						status = "RUNNING", -- 1017
						reason = getDefaultUseChineseResponse() and ("正在合并来自 " .. event.sourceTitle) .. " 的记忆。" or ("Pending memory merge from " .. event.sourceTitle) .. ".", -- 1018
						params = {jobId = event.jobId, sourceAgentId = event.sourceAgentId, sourceTitle = event.sourceTitle} -- 1021
					} -- 1021
				) -- 1021
				emitAgentSessionPatch( -- 1027
					sessionId, -- 1027
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1027
				) -- 1027
				break -- 1030
			end -- 1030
		end -- 1030
		____cond156 = ____cond156 or ____switch156 == "memory_merge_finished" -- 1030
		if ____cond156 then -- 1030
			do -- 1030
				upsertStep( -- 1033
					sessionId, -- 1033
					event.taskId, -- 1033
					event.step, -- 1033
					"merge_memory", -- 1033
					{ -- 1033
						status = event.success and "DONE" or "FAILED", -- 1034
						reason = sanitizeUTF8(event.message), -- 1035
						params = {jobId = event.jobId, sourceAgentId = event.sourceAgentId, sourceTitle = event.sourceTitle}, -- 1036
						result = { -- 1041
							success = event.success, -- 1042
							attempts = event.attempts, -- 1043
							jobId = event.jobId, -- 1044
							sourceAgentId = event.sourceAgentId, -- 1045
							sourceTitle = event.sourceTitle -- 1046
						} -- 1046
					} -- 1046
				) -- 1046
				emitAgentSessionPatch( -- 1049
					sessionId, -- 1049
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1049
				) -- 1049
				break -- 1052
			end -- 1052
		end -- 1052
		____cond156 = ____cond156 or ____switch156 == "assistant_message_updated" -- 1052
		if ____cond156 then -- 1052
			do -- 1052
				upsertStep( -- 1055
					sessionId, -- 1055
					event.taskId, -- 1055
					event.step, -- 1055
					"message", -- 1055
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1055
				) -- 1055
				emitAgentSessionPatch( -- 1060
					sessionId, -- 1060
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1060
				) -- 1060
				break -- 1063
			end -- 1063
		end -- 1063
		____cond156 = ____cond156 or ____switch156 == "task_finished" -- 1063
		if ____cond156 then -- 1063
			do -- 1063
				local ____opt_9 = activeStopTokens[event.taskId or -1] -- 1063
				local stopped = (____opt_9 and ____opt_9.stopped) == true -- 1066
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1067
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 1070
				if event.taskId ~= nil then -- 1070
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1072
					local ____finalizeTaskSteps_13 = finalizeTaskSteps -- 1073
					local ____array_12 = __TS__SparseArrayNew( -- 1073
						sessionId, -- 1074
						event.taskId, -- 1075
						type(event.steps) == "number" and math.max( -- 1076
							0, -- 1076
							math.floor(event.steps) -- 1076
						) or nil -- 1076
					) -- 1076
					local ____event_success_11 -- 1077
					if event.success then -- 1077
						____event_success_11 = nil -- 1077
					else -- 1077
						____event_success_11 = stopped and "STOPPED" or "FAILED" -- 1077
					end -- 1077
					__TS__SparseArrayPush(____array_12, ____event_success_11) -- 1077
					____finalizeTaskSteps_13(__TS__SparseArraySpread(____array_12)) -- 1073
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1079
					activeStopTokens[event.taskId] = nil -- 1080
					emitAgentSessionPatch( -- 1081
						sessionId, -- 1081
						{ -- 1081
							session = getSessionItem(sessionId), -- 1082
							message = getMessageItem(messageId), -- 1083
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1084
							removedStepIds = removedStepIds -- 1085
						} -- 1085
					) -- 1085
				end -- 1085
				local session = getSessionItem(sessionId) -- 1088
				if session and session.kind == "main" then -- 1088
					flushPendingSubAgentHandoffs(session) -- 1090
				end -- 1090
				break -- 1092
			end -- 1092
		end -- 1092
	until true -- 1092
end -- 1092
function ____exports.createSession(projectRoot, title) -- 1209
	if title == nil then -- 1209
		title = "" -- 1209
	end -- 1209
	if not isValidProjectRoot(projectRoot) then -- 1209
		return {success = false, message = "invalid projectRoot"} -- 1211
	end -- 1211
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1213
	if row then -- 1213
		return { -- 1222
			success = true, -- 1222
			session = rowToSession(row) -- 1222
		} -- 1222
	end -- 1222
	local t = now() -- 1224
	DB:exec( -- 1225
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1225
		{ -- 1228
			projectRoot, -- 1228
			title ~= "" and title or Path:getFilename(projectRoot), -- 1228
			t, -- 1228
			t -- 1228
		} -- 1228
	) -- 1228
	local sessionId = getLastInsertRowId() -- 1230
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1231
	local session = getSessionItem(sessionId) -- 1232
	if not session then -- 1232
		return {success = false, message = "failed to create session"} -- 1234
	end -- 1234
	return {success = true, session = session} -- 1236
end -- 1209
function ____exports.createSubSession(parentSessionId, title) -- 1239
	if title == nil then -- 1239
		title = "" -- 1239
	end -- 1239
	local parent = getSessionItem(parentSessionId) -- 1240
	if not parent then -- 1240
		return {success = false, message = "parent session not found"} -- 1242
	end -- 1242
	local rootId = getSessionRootId(parent) -- 1244
	local t = now() -- 1245
	DB:exec( -- 1246
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1246
		{ -- 1249
			parent.projectRoot, -- 1249
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1249
			rootId, -- 1249
			parent.id, -- 1249
			t, -- 1249
			t -- 1249
		} -- 1249
	) -- 1249
	local sessionId = getLastInsertRowId() -- 1251
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1252
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1253
	local session = getSessionItem(sessionId) -- 1254
	if not session then -- 1254
		return {success = false, message = "failed to create sub session"} -- 1256
	end -- 1256
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1258
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1259
	subStorage:writeMemory(parentStorage:readMemory()) -- 1260
	return {success = true, session = session} -- 1261
end -- 1239
function spawnSubAgentSession(request) -- 1264
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1264
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1275
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1276
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1277
		if normalizedPrompt == "" then -- 1277
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1279
		end -- 1279
		if normalizedPrompt == "" then -- 1279
			local ____Log_19 = Log -- 1286
			local ____temp_16 = #normalizedTitle -- 1286
			local ____temp_17 = #rawPrompt -- 1286
			local ____temp_18 = #toStr(request.expectedOutput) -- 1286
			local ____opt_14 = request.filesHint -- 1286
			____Log_19( -- 1286
				"Warn", -- 1286
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_16)) .. " raw_prompt_len=") .. tostring(____temp_17)) .. " expected_len=") .. tostring(____temp_18)) .. " files_hint_count=") .. tostring(____opt_14 and #____opt_14 or 0) -- 1286
			) -- 1286
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1286
		end -- 1286
		Log( -- 1289
			"Info", -- 1289
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1289
		) -- 1289
		local parentSessionId = request.parentSessionId -- 1290
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1290
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1292
			if not fallbackParent then -- 1292
				local createdMain = ____exports.createSession(request.projectRoot) -- 1294
				if createdMain.success then -- 1294
					fallbackParent = createdMain.session -- 1296
				end -- 1296
			end -- 1296
			if fallbackParent then -- 1296
				Log( -- 1300
					"Warn", -- 1300
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1300
				) -- 1300
				parentSessionId = fallbackParent.id -- 1301
			end -- 1301
		end -- 1301
		local parentSession = getSessionItem(parentSessionId) -- 1304
		if not parentSession then -- 1304
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1304
		end -- 1304
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1308
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1308
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1308
		end -- 1308
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1312
		if not created.success then -- 1312
			return ____awaiter_resolve(nil, created) -- 1312
		end -- 1312
		writeSpawnInfo( -- 1316
			created.session.projectRoot, -- 1316
			created.session.memoryScope, -- 1316
			{ -- 1316
				prompt = normalizedPrompt, -- 1317
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1318
				expectedOutput = request.expectedOutput or "", -- 1319
				filesHint = request.filesHint or ({}), -- 1320
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1321
			} -- 1321
		) -- 1321
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1323
		if not sent.success then -- 1323
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1323
		end -- 1323
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1323
	end) -- 1323
end -- 1323
function buildSubAgentMemoryMergeJob(session) -- 1405
	if session.kind ~= "sub" then -- 1405
		return {success = true} -- 1407
	end -- 1407
	local rootSession = getRootSessionItem(session.id) -- 1409
	if not rootSession then -- 1409
		return {success = false, message = "root session not found"} -- 1411
	end -- 1411
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1413
	local finalMemory = storage:readMemory() -- 1414
	if __TS__StringTrim(finalMemory) == "" then -- 1414
		return {success = false, message = "sub session memory is empty"} -- 1416
	end -- 1416
	local queue = __TS__New(MemoryMergeQueue, session.projectRoot) -- 1418
	local spawnInfo = readSpawnInfo(session.projectRoot, session.memoryScope) -- 1419
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1420
	local sanitizedTitle = string.gsub(session.title, "[^%w_-]", "_") -- 1421
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1422
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1423
	local jobId = (((cleanedTime2 .. "_") .. sanitizeUTF8(sanitizedTitle)) .. "_") .. tostring(session.id) -- 1424
	local result = queue:writeJob({ -- 1425
		jobId = jobId, -- 1426
		rootAgentId = tostring(rootSession.id), -- 1427
		sourceAgentId = tostring(session.id), -- 1428
		sourceTitle = session.title, -- 1429
		createdAt = createdAt, -- 1430
		spawn = { -- 1431
			prompt = type(spawnInfo and spawnInfo.prompt) == "string" and spawnInfo.prompt or session.title, -- 1432
			goal = type(spawnInfo and spawnInfo.goal) == "string" and spawnInfo.goal or session.title, -- 1435
			expectedOutput = type(spawnInfo and spawnInfo.expectedOutput) == "string" and spawnInfo.expectedOutput or "", -- 1438
			filesHint = __TS__ArrayIsArray(spawnInfo and spawnInfo.filesHint) and spawnInfo.filesHint or ({}) -- 1441
		}, -- 1441
		memory = {finalMemory = finalMemory} -- 1445
	}) -- 1445
	if not result.success then -- 1445
		return result -- 1450
	end -- 1450
	return {success = true} -- 1452
end -- 1452
function appendSubAgentHandoffStep(session, taskId, message) -- 1455
	local rootSession = getRootSessionItem(session.id) -- 1456
	if not rootSession then -- 1456
		return -- 1457
	end -- 1457
	local spawnInfo = getSessionSpawnInfo(session) -- 1458
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1459
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1460
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1461
	local queueResult = writePendingHandoff( -- 1462
		rootSession.projectRoot, -- 1462
		rootSession.memoryScope, -- 1462
		{ -- 1462
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1463
			sourceSessionId = session.id, -- 1464
			sourceTitle = session.title, -- 1465
			sourceTaskId = taskId, -- 1466
			message = sanitizeUTF8(message), -- 1467
			prompt = spawnInfo and spawnInfo.prompt or "", -- 1468
			goal = spawnInfo and spawnInfo.goal or session.title, -- 1469
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 1470
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 1471
			createdAt = createdAt -- 1472
		} -- 1472
	) -- 1472
	if not queueResult then -- 1472
		Log( -- 1475
			"Warn", -- 1475
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1475
		) -- 1475
		return -- 1476
	end -- 1476
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1476
		flushPendingSubAgentHandoffs(rootSession) -- 1479
	end -- 1479
end -- 1479
function startSubSessionFinalize(session, taskId, message) -- 1483
	if not writeFinalizeInfo( -- 1483
		session.projectRoot, -- 1484
		session.memoryScope, -- 1484
		{ -- 1484
			sourceTaskId = taskId, -- 1485
			message = sanitizeUTF8(message), -- 1486
			createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1487
		} -- 1487
	) then -- 1487
		return {success = false, message = "failed to persist sub session finalize info"} -- 1489
	end -- 1489
	local compactPrompt = "/compact" -- 1491
	local sent = ____exports.sendPrompt(session.id, compactPrompt, true) -- 1492
	if not sent.success then -- 1492
		deleteFinalizeInfo(session.projectRoot, session.memoryScope) -- 1494
		return sent -- 1495
	end -- 1495
	return {success = true} -- 1497
end -- 1497
function completeSubSessionFinalizeAfterCompact(session) -- 1500
	local rootSessionId = getSessionRootId(session) -- 1501
	local projectRoot = session.projectRoot -- 1502
	local finalizeInfo = readFinalizeInfo(projectRoot, session.memoryScope) -- 1503
	if not finalizeInfo then -- 1503
		return {success = false, message = "sub session finalize info not found"} -- 1505
	end -- 1505
	appendSubAgentHandoffStep(session, finalizeInfo.sourceTaskId, finalizeInfo.message) -- 1507
	local mergeResult = buildSubAgentMemoryMergeJob(session) -- 1508
	if not mergeResult.success then -- 1508
		Log( -- 1510
			"Warn", -- 1510
			(("[AgentSession] sub session merge handoff failed session=" .. tostring(session.id)) .. " error=") .. mergeResult.message -- 1510
		) -- 1510
		return mergeResult -- 1511
	end -- 1511
	deleteFinalizeInfo(projectRoot, session.memoryScope) -- 1513
	deleteSessionRecords(session.id) -- 1514
	emitSessionDeletedPatch(session.id, rootSessionId, projectRoot) -- 1515
	return {success = true} -- 1516
end -- 1516
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 1519
	if allowSubSessionStart == nil then -- 1519
		allowSubSessionStart = false -- 1519
	end -- 1519
	local session = getSessionItem(sessionId) -- 1520
	if not session then -- 1520
		return {success = false, message = "session not found"} -- 1522
	end -- 1522
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 1522
		return {success = false, message = "session task is still running"} -- 1525
	end -- 1525
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 1527
	if normalizedPrompt == "" and session.kind == "sub" then -- 1527
		local spawnInfo = getSessionSpawnInfo(session) -- 1529
		if spawnInfo then -- 1529
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 1531
			if normalizedPrompt == "" then -- 1531
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 1533
			end -- 1533
		end -- 1533
	end -- 1533
	if normalizedPrompt == "" then -- 1533
		return {success = false, message = "prompt is empty"} -- 1542
	end -- 1542
	local taskRes = Tools.createTask(normalizedPrompt) -- 1544
	if not taskRes.success then -- 1544
		return {success = false, message = taskRes.message} -- 1546
	end -- 1546
	local taskId = taskRes.taskId -- 1548
	local useChineseResponse = getDefaultUseChineseResponse() -- 1549
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 1550
	local stopToken = {stopped = false} -- 1551
	activeStopTokens[taskId] = stopToken -- 1552
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 1553
	runCodingAgent( -- 1554
		{ -- 1554
			prompt = normalizedPrompt, -- 1555
			workDir = session.projectRoot, -- 1556
			useChineseResponse = useChineseResponse, -- 1557
			taskId = taskId, -- 1558
			sessionId = sessionId, -- 1559
			memoryScope = session.memoryScope, -- 1560
			role = session.kind, -- 1561
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 1562
			stopToken = stopToken, -- 1565
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 1566
		}, -- 1566
		function(result) -- 1567
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1567
				local nextSession = getSessionItem(sessionId) -- 1568
				if result.success then -- 1568
					if nextSession and nextSession.kind == "sub" then -- 1568
						if __TS__StringTrim(normalizedPrompt) == "/compact" then -- 1568
							if readFinalizeInfo(nextSession.projectRoot, nextSession.memoryScope) then -- 1568
								local finalized = completeSubSessionFinalizeAfterCompact(nextSession) -- 1573
								if not finalized.success then -- 1573
									Log( -- 1575
										"Warn", -- 1575
										(("[AgentSession] sub session compact finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 1575
									) -- 1575
								end -- 1575
							end -- 1575
						else -- 1575
							local started = startSubSessionFinalize(nextSession, taskId, result.message) -- 1579
							if not started.success then -- 1579
								Log( -- 1581
									"Warn", -- 1581
									(("[AgentSession] sub session finalize start failed session=" .. tostring(nextSession.id)) .. " error=") .. started.message -- 1581
								) -- 1581
							end -- 1581
						end -- 1581
					end -- 1581
				end -- 1581
				if not result.success then -- 1581
					applyEvent(sessionId, { -- 1587
						type = "task_finished", -- 1588
						sessionId = sessionId, -- 1589
						taskId = result.taskId, -- 1590
						success = false, -- 1591
						message = result.message, -- 1592
						steps = result.steps -- 1593
					}) -- 1593
				end -- 1593
			end) -- 1593
		end -- 1567
	) -- 1567
	return {success = true, sessionId = sessionId, taskId = taskId} -- 1597
end -- 1519
TABLE_SESSION = "AgentSession" -- 105
TABLE_MESSAGE = "AgentSessionMessage" -- 106
TABLE_STEP = "AgentSessionStep" -- 107
TABLE_TASK = "AgentTask" -- 108
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 109
SPAWN_INFO_FILE = "SPAWN.json" -- 110
FINALIZE_INFO_FILE = "FINALIZE.json" -- 111
PENDING_HANDOFF_DIR = "pending-handoffs" -- 112
MAX_CONCURRENT_SUB_AGENTS = 4 -- 113
activeStopTokens = {} -- 134
now = function() return os.time() end -- 135
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 411
	if projectRoot == oldRoot then -- 411
		return newRoot -- 413
	end -- 413
	for ____, separator in ipairs({"/", "\\"}) do -- 415
		local prefix = oldRoot .. separator -- 416
		if __TS__StringStartsWith(projectRoot, prefix) then -- 416
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 418
		end -- 418
	end -- 418
	return nil -- 421
end -- 411
local function sanitizeStoredSteps(sessionId) -- 821
	DB:exec( -- 822
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 822
		{ -- 840
			now(), -- 840
			sessionId -- 840
		} -- 840
	) -- 840
end -- 821
local function emitSessionTreePatch(sessionId) -- 857
	local session = getSessionItem(sessionId) -- 858
	if not session then -- 858
		return -- 859
	end -- 859
	local ____emitAgentSessionPatch_7 = emitAgentSessionPatch -- 860
	local ____session_id_6 = session.id -- 860
	local ____session_2 = session -- 861
	local ____listRelatedSessions_result_3 = listRelatedSessions(session.id) -- 862
	local ____getPendingMergeCount_result_4 = getPendingMergeCount(session.projectRoot) -- 863
	local ____listPendingMergeJobs_result_5 = listPendingMergeJobs(session.projectRoot) -- 864
	local ____temp_1 -- 865
	if session.kind == "sub" then -- 865
		____temp_1 = getSessionSpawnInfo(session) -- 865
	else -- 865
		____temp_1 = nil -- 865
	end -- 865
	____emitAgentSessionPatch_7(____session_id_6, { -- 860
		session = ____session_2, -- 861
		relatedSessions = ____listRelatedSessions_result_3, -- 862
		pendingMergeCount = ____getPendingMergeCount_result_4, -- 863
		pendingMergeJobs = ____listPendingMergeJobs_result_5, -- 864
		spawnInfo = ____temp_1 -- 865
	}) -- 865
end -- 857
local function getSchemaVersion() -- 1097
	local row = queryOne("PRAGMA user_version") -- 1098
	return row and type(row[1]) == "number" and row[1] or 0 -- 1099
end -- 1097
local function setSchemaVersion(version) -- 1102
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1103
		0, -- 1103
		math.floor(version) -- 1103
	))) -- 1103
end -- 1102
local function recreateSchema() -- 1106
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1107
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1108
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1109
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1110
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1124
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1125
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1134
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1135
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1152
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1153
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1154
end -- 1106
do -- 1106
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1106
		recreateSchema() -- 1160
	else -- 1160
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1162
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1176
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1177
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1186
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1187
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1204
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1205
	end -- 1205
end -- 1205
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1335
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1335
		return {success = false, message = "invalid projectRoot"} -- 1337
	end -- 1337
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1339
	for ____, row in ipairs(rows) do -- 1340
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1341
		if sessionId > 0 then -- 1341
			deleteSessionRecords(sessionId) -- 1343
		end -- 1343
	end -- 1343
	return {success = true, deleted = #rows} -- 1346
end -- 1335
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1349
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1349
		return {success = false, message = "invalid projectRoot"} -- 1351
	end -- 1351
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1353
	local renamed = 0 -- 1354
	for ____, row in ipairs(rows) do -- 1355
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1356
		local projectRoot = toStr(row[2]) -- 1357
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1358
		if sessionId > 0 and nextProjectRoot then -- 1358
			DB:exec( -- 1360
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1360
				{ -- 1362
					nextProjectRoot, -- 1362
					Path:getFilename(nextProjectRoot), -- 1362
					now(), -- 1362
					sessionId -- 1362
				} -- 1362
			) -- 1362
			renamed = renamed + 1 -- 1364
		end -- 1364
	end -- 1364
	return {success = true, renamed = renamed} -- 1367
end -- 1349
function ____exports.getSession(sessionId) -- 1370
	local session = getSessionItem(sessionId) -- 1371
	if not session then -- 1371
		return {success = false, message = "session not found"} -- 1373
	end -- 1373
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1375
	local relatedSessions = listRelatedSessions(sessionId) -- 1376
	sanitizeStoredSteps(sessionId) -- 1377
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1378
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1385
	local ____relatedSessions_21 = relatedSessions -- 1396
	local ____getPendingMergeCount_result_22 = getPendingMergeCount(normalizedSession.projectRoot) -- 1397
	local ____listPendingMergeJobs_result_23 = listPendingMergeJobs(normalizedSession.projectRoot) -- 1398
	local ____temp_20 -- 1399
	if normalizedSession.kind == "sub" then -- 1399
		____temp_20 = getSessionSpawnInfo(normalizedSession) -- 1399
	else -- 1399
		____temp_20 = nil -- 1399
	end -- 1399
	return { -- 1393
		success = true, -- 1394
		session = normalizedSession, -- 1395
		relatedSessions = ____relatedSessions_21, -- 1396
		pendingMergeCount = ____getPendingMergeCount_result_22, -- 1397
		pendingMergeJobs = ____listPendingMergeJobs_result_23, -- 1398
		spawnInfo = ____temp_20, -- 1399
		messages = __TS__ArrayMap( -- 1400
			messages, -- 1400
			function(____, row) return rowToMessage(row) end -- 1400
		), -- 1400
		steps = __TS__ArrayMap( -- 1401
			steps, -- 1401
			function(____, row) return rowToStep(row) end -- 1401
		) -- 1401
	} -- 1401
end -- 1370
function ____exports.stopSessionTask(sessionId) -- 1600
	local session = getSessionItem(sessionId) -- 1601
	if not session or session.currentTaskId == nil then -- 1601
		return {success = false, message = "session task not found"} -- 1603
	end -- 1603
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1605
	local stopToken = activeStopTokens[session.currentTaskId] -- 1606
	if not stopToken then -- 1606
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 1606
			return {success = true, recovered = true} -- 1609
		end -- 1609
		return {success = false, message = "task is not running"} -- 1611
	end -- 1611
	stopToken.stopped = true -- 1613
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 1614
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1615
	return {success = true} -- 1616
end -- 1600
function ____exports.getCurrentTaskId(sessionId) -- 1619
	local ____opt_40 = getSessionItem(sessionId) -- 1619
	return ____opt_40 and ____opt_40.currentTaskId -- 1620
end -- 1619
function ____exports.listRunningSessions() -- 1623
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 1624
	local sessions = {} -- 1631
	do -- 1631
		local i = 0 -- 1632
		while i < #rows do -- 1632
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1633
			if session.currentTaskStatus == "RUNNING" then -- 1633
				sessions[#sessions + 1] = session -- 1635
			end -- 1635
			i = i + 1 -- 1632
		end -- 1632
	end -- 1632
	return {success = true, sessions = sessions} -- 1638
end -- 1623
return ____exports -- 1623