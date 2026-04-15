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
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 857
	emitAgentSessionPatch( -- 858
		sessionId, -- 858
		{ -- 858
			sessionDeleted = true, -- 859
			relatedSessions = listRelatedSessions(rootSessionId), -- 860
			pendingMergeCount = getPendingMergeCount(projectRoot), -- 861
			pendingMergeJobs = listPendingMergeJobs(projectRoot) -- 862
		} -- 862
	) -- 862
	local rootSession = getSessionItem(rootSessionId) -- 864
	if rootSession then -- 864
		emitAgentSessionPatch( -- 866
			rootSessionId, -- 866
			{ -- 866
				session = rootSession, -- 867
				relatedSessions = listRelatedSessions(rootSessionId), -- 868
				pendingMergeCount = getPendingMergeCount(projectRoot), -- 869
				pendingMergeJobs = listPendingMergeJobs(projectRoot) -- 870
			} -- 870
		) -- 870
	end -- 870
end -- 870
function flushPendingSubAgentHandoffs(rootSession) -- 875
	if rootSession.kind ~= "main" then -- 875
		return -- 876
	end -- 876
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 876
		return -- 878
	end -- 878
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 880
	if #items == 0 then -- 880
		return -- 881
	end -- 881
	local handoffTaskId = 0 -- 882
	local ____rootSession_currentTaskId_1 -- 883
	if rootSession.currentTaskId then -- 883
		____rootSession_currentTaskId_1 = getTaskPrompt(rootSession.currentTaskId) -- 883
	else -- 883
		____rootSession_currentTaskId_1 = nil -- 883
	end -- 883
	local currentTaskPrompt = ____rootSession_currentTaskId_1 -- 883
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 883
		handoffTaskId = rootSession.currentTaskId -- 891
	else -- 891
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 893
		if not taskRes.success then -- 893
			Log( -- 895
				"Warn", -- 895
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 895
			) -- 895
			return -- 896
		end -- 896
		handoffTaskId = taskRes.taskId -- 898
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 899
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 900
		emitAgentSessionPatch( -- 901
			rootSession.id, -- 901
			{session = getSessionItem(rootSession.id)} -- 901
		) -- 901
	end -- 901
	do -- 901
		local i = 0 -- 905
		while i < #items do -- 905
			local item = items[i + 1] -- 906
			local step = appendSystemStep( -- 907
				rootSession.id, -- 908
				handoffTaskId, -- 909
				"sub_agent_handoff", -- 910
				"sub_agent_handoff", -- 911
				item.message, -- 912
				{sourceSessionId = item.sourceSessionId, sourceTitle = item.sourceTitle, sourceTaskId = item.sourceTaskId}, -- 913
				{ -- 918
					sourceSessionId = item.sourceSessionId, -- 919
					sourceTitle = item.sourceTitle, -- 920
					prompt = item.prompt, -- 921
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 922
					expectedOutput = item.expectedOutput or "", -- 923
					filesHint = item.filesHint or ({}) -- 924
				}, -- 924
				"DONE" -- 926
			) -- 926
			if step then -- 926
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 929
			end -- 929
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 931
			i = i + 1 -- 905
		end -- 905
	end -- 905
end -- 905
function applyEvent(sessionId, event) -- 935
	repeat -- 935
		local ____switch154 = event.type -- 935
		local ____cond154 = ____switch154 == "task_started" -- 935
		if ____cond154 then -- 935
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 938
			emitAgentSessionPatch( -- 939
				sessionId, -- 939
				{session = getSessionItem(sessionId)} -- 939
			) -- 939
			break -- 942
		end -- 942
		____cond154 = ____cond154 or ____switch154 == "decision_made" -- 942
		if ____cond154 then -- 942
			upsertStep( -- 944
				sessionId, -- 944
				event.taskId, -- 944
				event.step, -- 944
				event.tool, -- 944
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 944
			) -- 944
			emitAgentSessionPatch( -- 950
				sessionId, -- 950
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 950
			) -- 950
			break -- 953
		end -- 953
		____cond154 = ____cond154 or ____switch154 == "tool_started" -- 953
		if ____cond154 then -- 953
			upsertStep( -- 955
				sessionId, -- 955
				event.taskId, -- 955
				event.step, -- 955
				event.tool, -- 955
				{status = "RUNNING"} -- 955
			) -- 955
			emitAgentSessionPatch( -- 958
				sessionId, -- 958
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 958
			) -- 958
			break -- 961
		end -- 961
		____cond154 = ____cond154 or ____switch154 == "tool_finished" -- 961
		if ____cond154 then -- 961
			upsertStep( -- 963
				sessionId, -- 963
				event.taskId, -- 963
				event.step, -- 963
				event.tool, -- 963
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 963
			) -- 963
			emitAgentSessionPatch( -- 968
				sessionId, -- 968
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 968
			) -- 968
			break -- 971
		end -- 971
		____cond154 = ____cond154 or ____switch154 == "checkpoint_created" -- 971
		if ____cond154 then -- 971
			upsertStep( -- 973
				sessionId, -- 973
				event.taskId, -- 973
				event.step, -- 973
				event.tool, -- 973
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 973
			) -- 973
			emitAgentSessionPatch( -- 978
				sessionId, -- 978
				{ -- 978
					step = getStepItem(sessionId, event.taskId, event.step), -- 979
					checkpoints = Tools.listCheckpoints(event.taskId) -- 980
				} -- 980
			) -- 980
			break -- 982
		end -- 982
		____cond154 = ____cond154 or ____switch154 == "memory_compression_started" -- 982
		if ____cond154 then -- 982
			upsertStep( -- 984
				sessionId, -- 984
				event.taskId, -- 984
				event.step, -- 984
				event.tool, -- 984
				{status = "RUNNING", reason = event.reason, params = event.params} -- 984
			) -- 984
			emitAgentSessionPatch( -- 989
				sessionId, -- 989
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 989
			) -- 989
			break -- 992
		end -- 992
		____cond154 = ____cond154 or ____switch154 == "memory_compression_finished" -- 992
		if ____cond154 then -- 992
			upsertStep( -- 994
				sessionId, -- 994
				event.taskId, -- 994
				event.step, -- 994
				event.tool, -- 994
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 994
			) -- 994
			emitAgentSessionPatch( -- 999
				sessionId, -- 999
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 999
			) -- 999
			break -- 1002
		end -- 1002
		____cond154 = ____cond154 or ____switch154 == "memory_merge_started" -- 1002
		if ____cond154 then -- 1002
			do -- 1002
				upsertStep( -- 1004
					sessionId, -- 1004
					event.taskId, -- 1004
					event.step, -- 1004
					"merge_memory", -- 1004
					{ -- 1004
						status = "RUNNING", -- 1005
						reason = getDefaultUseChineseResponse() and ("正在合并来自 `" .. event.sourceTitle) .. "` 的记忆。" or ("Pending memory merge from `" .. event.sourceTitle) .. "`.", -- 1006
						params = {jobId = event.jobId, sourceAgentId = event.sourceAgentId, sourceTitle = event.sourceTitle} -- 1009
					} -- 1009
				) -- 1009
				emitAgentSessionPatch( -- 1015
					sessionId, -- 1015
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1015
				) -- 1015
				break -- 1018
			end -- 1018
		end -- 1018
		____cond154 = ____cond154 or ____switch154 == "memory_merge_finished" -- 1018
		if ____cond154 then -- 1018
			do -- 1018
				upsertStep( -- 1021
					sessionId, -- 1021
					event.taskId, -- 1021
					event.step, -- 1021
					"merge_memory", -- 1021
					{ -- 1021
						status = event.success and "DONE" or "FAILED", -- 1022
						reason = sanitizeUTF8(event.message), -- 1023
						params = {jobId = event.jobId, sourceAgentId = event.sourceAgentId, sourceTitle = event.sourceTitle}, -- 1024
						result = { -- 1029
							success = event.success, -- 1030
							attempts = event.attempts, -- 1031
							jobId = event.jobId, -- 1032
							sourceAgentId = event.sourceAgentId, -- 1033
							sourceTitle = event.sourceTitle -- 1034
						} -- 1034
					} -- 1034
				) -- 1034
				emitAgentSessionPatch( -- 1037
					sessionId, -- 1037
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1037
				) -- 1037
				break -- 1040
			end -- 1040
		end -- 1040
		____cond154 = ____cond154 or ____switch154 == "assistant_message_updated" -- 1040
		if ____cond154 then -- 1040
			do -- 1040
				upsertStep( -- 1043
					sessionId, -- 1043
					event.taskId, -- 1043
					event.step, -- 1043
					"message", -- 1043
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1043
				) -- 1043
				emitAgentSessionPatch( -- 1048
					sessionId, -- 1048
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1048
				) -- 1048
				break -- 1051
			end -- 1051
		end -- 1051
		____cond154 = ____cond154 or ____switch154 == "task_finished" -- 1051
		if ____cond154 then -- 1051
			do -- 1051
				local ____opt_2 = activeStopTokens[event.taskId or -1] -- 1051
				local stopped = (____opt_2 and ____opt_2.stopped) == true -- 1054
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1055
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 1058
				if event.taskId ~= nil then -- 1058
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1060
					local ____finalizeTaskSteps_6 = finalizeTaskSteps -- 1061
					local ____array_5 = __TS__SparseArrayNew( -- 1061
						sessionId, -- 1062
						event.taskId, -- 1063
						type(event.steps) == "number" and math.max( -- 1064
							0, -- 1064
							math.floor(event.steps) -- 1064
						) or nil -- 1064
					) -- 1064
					local ____event_success_4 -- 1065
					if event.success then -- 1065
						____event_success_4 = nil -- 1065
					else -- 1065
						____event_success_4 = stopped and "STOPPED" or "FAILED" -- 1065
					end -- 1065
					__TS__SparseArrayPush(____array_5, ____event_success_4) -- 1065
					____finalizeTaskSteps_6(__TS__SparseArraySpread(____array_5)) -- 1061
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1067
					activeStopTokens[event.taskId] = nil -- 1068
					emitAgentSessionPatch( -- 1069
						sessionId, -- 1069
						{ -- 1069
							session = getSessionItem(sessionId), -- 1070
							message = getMessageItem(messageId), -- 1071
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1072
							removedStepIds = removedStepIds -- 1073
						} -- 1073
					) -- 1073
				end -- 1073
				local session = getSessionItem(sessionId) -- 1076
				if session and session.kind == "main" then -- 1076
					flushPendingSubAgentHandoffs(session) -- 1078
				end -- 1078
				break -- 1080
			end -- 1080
		end -- 1080
	until true -- 1080
end -- 1080
function ____exports.createSession(projectRoot, title) -- 1197
	if title == nil then -- 1197
		title = "" -- 1197
	end -- 1197
	if not isValidProjectRoot(projectRoot) then -- 1197
		return {success = false, message = "invalid projectRoot"} -- 1199
	end -- 1199
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1201
	if row then -- 1201
		return { -- 1210
			success = true, -- 1210
			session = rowToSession(row) -- 1210
		} -- 1210
	end -- 1210
	local t = now() -- 1212
	DB:exec( -- 1213
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1213
		{ -- 1216
			projectRoot, -- 1216
			title ~= "" and title or Path:getFilename(projectRoot), -- 1216
			t, -- 1216
			t -- 1216
		} -- 1216
	) -- 1216
	local sessionId = getLastInsertRowId() -- 1218
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1219
	local session = getSessionItem(sessionId) -- 1220
	if not session then -- 1220
		return {success = false, message = "failed to create session"} -- 1222
	end -- 1222
	return {success = true, session = session} -- 1224
end -- 1197
function ____exports.createSubSession(parentSessionId, title) -- 1227
	if title == nil then -- 1227
		title = "" -- 1227
	end -- 1227
	local parent = getSessionItem(parentSessionId) -- 1228
	if not parent then -- 1228
		return {success = false, message = "parent session not found"} -- 1230
	end -- 1230
	local rootId = getSessionRootId(parent) -- 1232
	local t = now() -- 1233
	DB:exec( -- 1234
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1234
		{ -- 1237
			parent.projectRoot, -- 1237
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1237
			rootId, -- 1237
			parent.id, -- 1237
			t, -- 1237
			t -- 1237
		} -- 1237
	) -- 1237
	local sessionId = getLastInsertRowId() -- 1239
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1240
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1241
	local session = getSessionItem(sessionId) -- 1242
	if not session then -- 1242
		return {success = false, message = "failed to create sub session"} -- 1244
	end -- 1244
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1246
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1247
	subStorage:writeMemory(parentStorage:readMemory()) -- 1248
	return {success = true, session = session} -- 1249
end -- 1227
function spawnSubAgentSession(request) -- 1252
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1252
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1263
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1264
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1265
		if normalizedPrompt == "" then -- 1265
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1267
		end -- 1267
		if normalizedPrompt == "" then -- 1267
			local ____Log_12 = Log -- 1274
			local ____temp_9 = #normalizedTitle -- 1274
			local ____temp_10 = #rawPrompt -- 1274
			local ____temp_11 = #toStr(request.expectedOutput) -- 1274
			local ____opt_7 = request.filesHint -- 1274
			____Log_12( -- 1274
				"Warn", -- 1274
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_9)) .. " raw_prompt_len=") .. tostring(____temp_10)) .. " expected_len=") .. tostring(____temp_11)) .. " files_hint_count=") .. tostring(____opt_7 and #____opt_7 or 0) -- 1274
			) -- 1274
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1274
		end -- 1274
		Log( -- 1277
			"Info", -- 1277
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1277
		) -- 1277
		local parentSessionId = request.parentSessionId -- 1278
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1278
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1280
			if not fallbackParent then -- 1280
				local createdMain = ____exports.createSession(request.projectRoot) -- 1282
				if createdMain.success then -- 1282
					fallbackParent = createdMain.session -- 1284
				end -- 1284
			end -- 1284
			if fallbackParent then -- 1284
				Log( -- 1288
					"Warn", -- 1288
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1288
				) -- 1288
				parentSessionId = fallbackParent.id -- 1289
			end -- 1289
		end -- 1289
		local parentSession = getSessionItem(parentSessionId) -- 1292
		if not parentSession then -- 1292
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1292
		end -- 1292
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1296
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1296
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1296
		end -- 1296
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1300
		if not created.success then -- 1300
			return ____awaiter_resolve(nil, created) -- 1300
		end -- 1300
		writeSpawnInfo( -- 1304
			created.session.projectRoot, -- 1304
			created.session.memoryScope, -- 1304
			{ -- 1304
				prompt = normalizedPrompt, -- 1305
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1306
				expectedOutput = request.expectedOutput or "", -- 1307
				filesHint = request.filesHint or ({}), -- 1308
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1309
			} -- 1309
		) -- 1309
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1311
		if not sent.success then -- 1311
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1311
		end -- 1311
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1311
	end) -- 1311
end -- 1311
function buildSubAgentMemoryMergeJob(session) -- 1393
	if session.kind ~= "sub" then -- 1393
		return {success = true} -- 1395
	end -- 1395
	local rootSession = getRootSessionItem(session.id) -- 1397
	if not rootSession then -- 1397
		return {success = false, message = "root session not found"} -- 1399
	end -- 1399
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1401
	local finalMemory = storage:readMemory() -- 1402
	if __TS__StringTrim(finalMemory) == "" then -- 1402
		return {success = false, message = "sub session memory is empty"} -- 1404
	end -- 1404
	local queue = __TS__New(MemoryMergeQueue, session.projectRoot) -- 1406
	local spawnInfo = readSpawnInfo(session.projectRoot, session.memoryScope) -- 1407
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1408
	local sanitizedTitle = string.gsub(session.title, "[^%w_-]", "_") -- 1409
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1410
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1411
	local jobId = (((cleanedTime2 .. "_") .. sanitizeUTF8(sanitizedTitle)) .. "_") .. tostring(session.id) -- 1412
	local result = queue:writeJob({ -- 1413
		jobId = jobId, -- 1414
		rootAgentId = tostring(rootSession.id), -- 1415
		sourceAgentId = tostring(session.id), -- 1416
		sourceTitle = session.title, -- 1417
		createdAt = createdAt, -- 1418
		spawn = { -- 1419
			prompt = type(spawnInfo and spawnInfo.prompt) == "string" and spawnInfo.prompt or session.title, -- 1420
			goal = type(spawnInfo and spawnInfo.goal) == "string" and spawnInfo.goal or session.title, -- 1423
			expectedOutput = type(spawnInfo and spawnInfo.expectedOutput) == "string" and spawnInfo.expectedOutput or "", -- 1426
			filesHint = __TS__ArrayIsArray(spawnInfo and spawnInfo.filesHint) and spawnInfo.filesHint or ({}) -- 1429
		}, -- 1429
		memory = {finalMemory = finalMemory} -- 1433
	}) -- 1433
	if not result.success then -- 1433
		return result -- 1438
	end -- 1438
	return {success = true} -- 1440
end -- 1440
function appendSubAgentHandoffStep(session, taskId, message) -- 1443
	local rootSession = getRootSessionItem(session.id) -- 1444
	if not rootSession then -- 1444
		return -- 1445
	end -- 1445
	local spawnInfo = getSessionSpawnInfo(session) -- 1446
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1447
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1448
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1449
	local queueResult = writePendingHandoff( -- 1450
		rootSession.projectRoot, -- 1450
		rootSession.memoryScope, -- 1450
		{ -- 1450
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1451
			sourceSessionId = session.id, -- 1452
			sourceTitle = session.title, -- 1453
			sourceTaskId = taskId, -- 1454
			message = sanitizeUTF8(message), -- 1455
			prompt = spawnInfo and spawnInfo.prompt or "", -- 1456
			goal = spawnInfo and spawnInfo.goal or session.title, -- 1457
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 1458
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 1459
			createdAt = createdAt -- 1460
		} -- 1460
	) -- 1460
	if not queueResult then -- 1460
		Log( -- 1463
			"Warn", -- 1463
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1463
		) -- 1463
		return -- 1464
	end -- 1464
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1464
		flushPendingSubAgentHandoffs(rootSession) -- 1467
	end -- 1467
end -- 1467
function startSubSessionFinalize(session, taskId, message) -- 1471
	if not writeFinalizeInfo( -- 1471
		session.projectRoot, -- 1472
		session.memoryScope, -- 1472
		{ -- 1472
			sourceTaskId = taskId, -- 1473
			message = sanitizeUTF8(message), -- 1474
			createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1475
		} -- 1475
	) then -- 1475
		return {success = false, message = "failed to persist sub session finalize info"} -- 1477
	end -- 1477
	local compactPrompt = "/compact" -- 1479
	local sent = ____exports.sendPrompt(session.id, compactPrompt, true) -- 1480
	if not sent.success then -- 1480
		deleteFinalizeInfo(session.projectRoot, session.memoryScope) -- 1482
		return sent -- 1483
	end -- 1483
	return {success = true} -- 1485
end -- 1485
function completeSubSessionFinalizeAfterCompact(session) -- 1488
	local rootSessionId = getSessionRootId(session) -- 1489
	local projectRoot = session.projectRoot -- 1490
	local finalizeInfo = readFinalizeInfo(projectRoot, session.memoryScope) -- 1491
	if not finalizeInfo then -- 1491
		return {success = false, message = "sub session finalize info not found"} -- 1493
	end -- 1493
	appendSubAgentHandoffStep(session, finalizeInfo.sourceTaskId, finalizeInfo.message) -- 1495
	local mergeResult = buildSubAgentMemoryMergeJob(session) -- 1496
	if not mergeResult.success then -- 1496
		Log( -- 1498
			"Warn", -- 1498
			(("[AgentSession] sub session merge handoff failed session=" .. tostring(session.id)) .. " error=") .. mergeResult.message -- 1498
		) -- 1498
		return mergeResult -- 1499
	end -- 1499
	deleteFinalizeInfo(projectRoot, session.memoryScope) -- 1501
	deleteSessionRecords(session.id) -- 1502
	emitSessionDeletedPatch(session.id, rootSessionId, projectRoot) -- 1503
	return {success = true} -- 1504
end -- 1504
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 1507
	if allowSubSessionStart == nil then -- 1507
		allowSubSessionStart = false -- 1507
	end -- 1507
	local session = getSessionItem(sessionId) -- 1508
	if not session then -- 1508
		return {success = false, message = "session not found"} -- 1510
	end -- 1510
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 1510
		return {success = false, message = "session task is still running"} -- 1513
	end -- 1513
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 1515
	if normalizedPrompt == "" and session.kind == "sub" then -- 1515
		local spawnInfo = getSessionSpawnInfo(session) -- 1517
		if spawnInfo then -- 1517
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 1519
			if normalizedPrompt == "" then -- 1519
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 1521
			end -- 1521
		end -- 1521
	end -- 1521
	if normalizedPrompt == "" then -- 1521
		return {success = false, message = "prompt is empty"} -- 1530
	end -- 1530
	local taskRes = Tools.createTask(normalizedPrompt) -- 1532
	if not taskRes.success then -- 1532
		return {success = false, message = taskRes.message} -- 1534
	end -- 1534
	local taskId = taskRes.taskId -- 1536
	local useChineseResponse = getDefaultUseChineseResponse() -- 1537
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 1538
	local stopToken = {stopped = false} -- 1539
	activeStopTokens[taskId] = stopToken -- 1540
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 1541
	runCodingAgent( -- 1542
		{ -- 1542
			prompt = normalizedPrompt, -- 1543
			workDir = session.projectRoot, -- 1544
			useChineseResponse = useChineseResponse, -- 1545
			taskId = taskId, -- 1546
			sessionId = sessionId, -- 1547
			memoryScope = session.memoryScope, -- 1548
			role = session.kind, -- 1549
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 1550
			stopToken = stopToken, -- 1553
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 1554
		}, -- 1554
		function(result) -- 1555
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1555
				local nextSession = getSessionItem(sessionId) -- 1556
				if result.success then -- 1556
					if nextSession and nextSession.kind == "sub" then -- 1556
						if __TS__StringTrim(normalizedPrompt) == "/compact" then -- 1556
							if readFinalizeInfo(nextSession.projectRoot, nextSession.memoryScope) then -- 1556
								local finalized = completeSubSessionFinalizeAfterCompact(nextSession) -- 1561
								if not finalized.success then -- 1561
									Log( -- 1563
										"Warn", -- 1563
										(("[AgentSession] sub session compact finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 1563
									) -- 1563
								end -- 1563
							end -- 1563
						else -- 1563
							local started = startSubSessionFinalize(nextSession, taskId, result.message) -- 1567
							if not started.success then -- 1567
								Log( -- 1569
									"Warn", -- 1569
									(("[AgentSession] sub session finalize start failed session=" .. tostring(nextSession.id)) .. " error=") .. started.message -- 1569
								) -- 1569
							end -- 1569
						end -- 1569
					end -- 1569
				end -- 1569
				if not result.success then -- 1569
					applyEvent(sessionId, { -- 1575
						type = "task_finished", -- 1576
						sessionId = sessionId, -- 1577
						taskId = result.taskId, -- 1578
						success = false, -- 1579
						message = result.message, -- 1580
						steps = result.steps -- 1581
					}) -- 1581
				end -- 1581
			end) -- 1581
		end -- 1555
	) -- 1555
	return {success = true, sessionId = sessionId, taskId = taskId} -- 1585
end -- 1507
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
local function getSchemaVersion() -- 1085
	local row = queryOne("PRAGMA user_version") -- 1086
	return row and type(row[1]) == "number" and row[1] or 0 -- 1087
end -- 1085
local function setSchemaVersion(version) -- 1090
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1091
		0, -- 1091
		math.floor(version) -- 1091
	))) -- 1091
end -- 1090
local function recreateSchema() -- 1094
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1095
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1096
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1097
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1098
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1112
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1113
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1122
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1123
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1140
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1141
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1142
end -- 1094
do -- 1094
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1094
		recreateSchema() -- 1148
	else -- 1148
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1150
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1164
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1165
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1174
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1175
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1192
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1193
	end -- 1193
end -- 1193
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1323
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1323
		return {success = false, message = "invalid projectRoot"} -- 1325
	end -- 1325
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1327
	for ____, row in ipairs(rows) do -- 1328
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1329
		if sessionId > 0 then -- 1329
			deleteSessionRecords(sessionId) -- 1331
		end -- 1331
	end -- 1331
	return {success = true, deleted = #rows} -- 1334
end -- 1323
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1337
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1337
		return {success = false, message = "invalid projectRoot"} -- 1339
	end -- 1339
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1341
	local renamed = 0 -- 1342
	for ____, row in ipairs(rows) do -- 1343
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1344
		local projectRoot = toStr(row[2]) -- 1345
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1346
		if sessionId > 0 and nextProjectRoot then -- 1346
			DB:exec( -- 1348
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1348
				{ -- 1350
					nextProjectRoot, -- 1350
					Path:getFilename(nextProjectRoot), -- 1350
					now(), -- 1350
					sessionId -- 1350
				} -- 1350
			) -- 1350
			renamed = renamed + 1 -- 1352
		end -- 1352
	end -- 1352
	return {success = true, renamed = renamed} -- 1355
end -- 1337
function ____exports.getSession(sessionId) -- 1358
	local session = getSessionItem(sessionId) -- 1359
	if not session then -- 1359
		return {success = false, message = "session not found"} -- 1361
	end -- 1361
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1363
	local relatedSessions = listRelatedSessions(sessionId) -- 1364
	sanitizeStoredSteps(sessionId) -- 1365
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1366
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1373
	local ____relatedSessions_14 = relatedSessions -- 1384
	local ____getPendingMergeCount_result_15 = getPendingMergeCount(normalizedSession.projectRoot) -- 1385
	local ____listPendingMergeJobs_result_16 = listPendingMergeJobs(normalizedSession.projectRoot) -- 1386
	local ____temp_13 -- 1387
	if normalizedSession.kind == "sub" then -- 1387
		____temp_13 = getSessionSpawnInfo(normalizedSession) -- 1387
	else -- 1387
		____temp_13 = nil -- 1387
	end -- 1387
	return { -- 1381
		success = true, -- 1382
		session = normalizedSession, -- 1383
		relatedSessions = ____relatedSessions_14, -- 1384
		pendingMergeCount = ____getPendingMergeCount_result_15, -- 1385
		pendingMergeJobs = ____listPendingMergeJobs_result_16, -- 1386
		spawnInfo = ____temp_13, -- 1387
		messages = __TS__ArrayMap( -- 1388
			messages, -- 1388
			function(____, row) return rowToMessage(row) end -- 1388
		), -- 1388
		steps = __TS__ArrayMap( -- 1389
			steps, -- 1389
			function(____, row) return rowToStep(row) end -- 1389
		) -- 1389
	} -- 1389
end -- 1358
function ____exports.stopSessionTask(sessionId) -- 1588
	local session = getSessionItem(sessionId) -- 1589
	if not session or session.currentTaskId == nil then -- 1589
		return {success = false, message = "session task not found"} -- 1591
	end -- 1591
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1593
	local stopToken = activeStopTokens[session.currentTaskId] -- 1594
	if not stopToken then -- 1594
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 1594
			return {success = true, recovered = true} -- 1597
		end -- 1597
		return {success = false, message = "task is not running"} -- 1599
	end -- 1599
	stopToken.stopped = true -- 1601
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 1602
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1603
	return {success = true} -- 1604
end -- 1588
function ____exports.getCurrentTaskId(sessionId) -- 1607
	local ____opt_33 = getSessionItem(sessionId) -- 1607
	return ____opt_33 and ____opt_33.currentTaskId -- 1608
end -- 1607
function ____exports.listRunningSessions() -- 1611
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 1612
	local sessions = {} -- 1619
	do -- 1619
		local i = 0 -- 1620
		while i < #rows do -- 1620
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1621
			if session.currentTaskStatus == "RUNNING" then -- 1621
				sessions[#sessions + 1] = session -- 1623
			end -- 1623
			i = i + 1 -- 1620
		end -- 1620
	end -- 1620
	return {success = true, sessions = sessions} -- 1626
end -- 1611
return ____exports -- 1611