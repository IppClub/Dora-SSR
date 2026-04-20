-- [ts]: AgentSession.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, containsNormalizedText, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, setSessionStateForTaskEvent, insertMessage, updateMessage, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, activeStopTokens, now -- 1
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
local ____Utils = require("Agent.Utils") -- 6
local Log = ____Utils.Log -- 6
local safeJsonDecode = ____Utils.safeJsonDecode -- 6
local safeJsonEncode = ____Utils.safeJsonEncode -- 6
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 6
function getDefaultUseChineseResponse() -- 191
	local zh = string.match(App.locale, "^zh") -- 192
	return zh ~= nil -- 193
end -- 193
function toStr(v) -- 196
	if v == false or v == nil or v == nil then -- 196
		return "" -- 197
	end -- 197
	return tostring(v) -- 198
end -- 198
function encodeJson(value) -- 201
	local text = safeJsonEncode(value) -- 202
	return text or "" -- 203
end -- 203
function decodeJsonObject(text) -- 206
	if not text or text == "" then -- 206
		return nil -- 207
	end -- 207
	local value = safeJsonDecode(text) -- 208
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 208
		return value -- 210
	end -- 210
	return nil -- 212
end -- 212
function decodeJsonFiles(text) -- 215
	if not text or text == "" then -- 215
		return nil -- 216
	end -- 216
	local value = safeJsonDecode(text) -- 217
	if not value or not __TS__ArrayIsArray(value) then -- 217
		return nil -- 218
	end -- 218
	local files = {} -- 219
	do -- 219
		local i = 0 -- 220
		while i < #value do -- 220
			do -- 220
				local item = value[i + 1] -- 221
				if type(item) ~= "table" then -- 221
					goto __continue14 -- 222
				end -- 222
				files[#files + 1] = { -- 223
					path = sanitizeUTF8(toStr(item.path)), -- 224
					op = sanitizeUTF8(toStr(item.op)) -- 225
				} -- 225
			end -- 225
			::__continue14:: -- 225
			i = i + 1 -- 220
		end -- 220
	end -- 220
	return files -- 228
end -- 228
function queryRows(sql, args) -- 231
	local ____args_0 -- 232
	if args then -- 232
		____args_0 = DB:query(sql, args) -- 232
	else -- 232
		____args_0 = DB:query(sql) -- 232
	end -- 232
	return ____args_0 -- 232
end -- 232
function queryOne(sql, args) -- 235
	local rows = queryRows(sql, args) -- 236
	if not rows or #rows == 0 then -- 236
		return nil -- 237
	end -- 237
	return rows[1] -- 238
end -- 238
function getLastInsertRowId() -- 241
	local row = queryOne("SELECT last_insert_rowid()") -- 242
	return row and (row[1] or 0) or 0 -- 243
end -- 243
function isValidProjectRoot(path) -- 246
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 247
end -- 247
function rowToSession(row) -- 250
	return { -- 251
		id = row[1], -- 252
		projectRoot = toStr(row[2]), -- 253
		title = toStr(row[3]), -- 254
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 255
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 256
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 257
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 258
		status = toStr(row[8]), -- 259
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 260
		currentTaskStatus = toStr(row[10]), -- 261
		createdAt = row[11], -- 262
		updatedAt = row[12] -- 263
	} -- 263
end -- 263
function rowToMessage(row) -- 267
	return { -- 268
		id = row[1], -- 269
		sessionId = row[2], -- 270
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 271
		role = toStr(row[4]), -- 272
		content = toStr(row[5]), -- 273
		createdAt = row[6], -- 274
		updatedAt = row[7] -- 275
	} -- 275
end -- 275
function rowToStep(row) -- 279
	return { -- 280
		id = row[1], -- 281
		sessionId = row[2], -- 282
		taskId = row[3], -- 283
		step = row[4], -- 284
		tool = toStr(row[5]), -- 285
		status = toStr(row[6]), -- 286
		reason = toStr(row[7]), -- 287
		reasoningContent = toStr(row[8]), -- 288
		params = decodeJsonObject(toStr(row[9])), -- 289
		result = decodeJsonObject(toStr(row[10])), -- 290
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 291
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 292
		files = decodeJsonFiles(toStr(row[13])), -- 293
		createdAt = row[14], -- 294
		updatedAt = row[15] -- 295
	} -- 295
end -- 295
function getMessageItem(messageId) -- 299
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 300
	return row and rowToMessage(row) or nil -- 306
end -- 306
function getStepItem(sessionId, taskId, step) -- 309
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 310
	return row and rowToStep(row) or nil -- 316
end -- 316
function deleteMessageSteps(sessionId, taskId) -- 319
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 320
	local ids = {} -- 325
	do -- 325
		local i = 0 -- 326
		while i < #rows do -- 326
			local row = rows[i + 1] -- 327
			if type(row[1]) == "number" then -- 327
				ids[#ids + 1] = row[1] -- 329
			end -- 329
			i = i + 1 -- 326
		end -- 326
	end -- 326
	if #ids > 0 then -- 326
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 333
	end -- 333
	return ids -- 339
end -- 339
function getSessionRow(sessionId) -- 342
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 343
end -- 343
function getSessionItem(sessionId) -- 351
	local row = getSessionRow(sessionId) -- 352
	return row and rowToSession(row) or nil -- 353
end -- 353
function getTaskPrompt(taskId) -- 356
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 357
	if not row or type(row[1]) ~= "string" then -- 357
		return nil -- 358
	end -- 358
	return toStr(row[1]) -- 359
end -- 359
function getLatestMainSessionByProjectRoot(projectRoot) -- 362
	if not isValidProjectRoot(projectRoot) then -- 362
		return nil -- 363
	end -- 363
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 364
	return row and rowToSession(row) or nil -- 372
end -- 372
function countRunningSubSessions(rootSessionId) -- 375
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 376
	local count = 0 -- 383
	do -- 383
		local i = 0 -- 384
		while i < #rows do -- 384
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 385
			if session.currentTaskStatus == "RUNNING" then -- 385
				count = count + 1 -- 387
			end -- 387
			i = i + 1 -- 384
		end -- 384
	end -- 384
	return count -- 390
end -- 390
function deleteSessionRecords(sessionId, preserveArtifacts) -- 393
	if preserveArtifacts == nil then -- 393
		preserveArtifacts = false -- 393
	end -- 393
	local session = getSessionItem(sessionId) -- 394
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 395
	do -- 395
		local i = 0 -- 396
		while i < #children do -- 396
			local row = children[i + 1] -- 397
			if type(row[1]) == "number" and row[1] > 0 then -- 397
				deleteSessionRecords(row[1], preserveArtifacts) -- 399
			end -- 399
			i = i + 1 -- 396
		end -- 396
	end -- 396
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 402
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 403
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 404
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 405
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 405
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 407
	end -- 407
end -- 407
function getSessionRootId(session) -- 411
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 412
end -- 412
function getRootSessionItem(sessionId) -- 415
	local session = getSessionItem(sessionId) -- 416
	if not session then -- 416
		return nil -- 417
	end -- 417
	return getSessionItem(getSessionRootId(session)) or session -- 418
end -- 418
function listRelatedSessions(sessionId) -- 421
	local root = getRootSessionItem(sessionId) -- 422
	if not root then -- 422
		return {} -- 423
	end -- 423
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 424
	return __TS__ArrayMap( -- 433
		rows, -- 433
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 433
	) -- 433
end -- 433
function getSessionSpawnInfo(session) -- 436
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 437
	if not info then -- 437
		return nil -- 438
	end -- 438
	local ____temp_3 = type(info.sessionId) == "number" and info.sessionId or nil -- 440
	local ____temp_4 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 441
	local ____temp_5 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 442
	local ____temp_6 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 443
	local ____temp_7 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 444
	local ____temp_8 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 445
	local ____temp_9 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 446
	local ____temp_10 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 447
		__TS__ArrayFilter( -- 448
			info.filesHint, -- 448
			function(____, item) return type(item) == "string" end -- 448
		), -- 448
		function(____, item) return sanitizeUTF8(item) end -- 448
	) or nil -- 448
	local ____temp_11 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil)) -- 450
	local ____temp_2 -- 453
	if info.success == true then -- 453
		____temp_2 = true -- 453
	else -- 453
		local ____temp_1 -- 453
		if info.success == false then -- 453
			____temp_1 = false -- 453
		else -- 453
			____temp_1 = nil -- 453
		end -- 453
		____temp_2 = ____temp_1 -- 453
	end -- 453
	return { -- 439
		sessionId = ____temp_3, -- 440
		rootSessionId = ____temp_4, -- 441
		parentSessionId = ____temp_5, -- 442
		title = ____temp_6, -- 443
		prompt = ____temp_7, -- 444
		goal = ____temp_8, -- 445
		expectedOutput = ____temp_9, -- 446
		filesHint = ____temp_10, -- 447
		status = ____temp_11, -- 450
		success = ____temp_2, -- 453
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 454
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 455
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 456
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 457
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 458
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 459
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 460
	} -- 460
end -- 460
function ensureDirRecursive(dir) -- 477
	if not dir or dir == "" then -- 477
		return false -- 478
	end -- 478
	if Content:exist(dir) then -- 478
		return Content:isdir(dir) -- 479
	end -- 479
	local parent = Path:getPath(dir) -- 480
	if parent and parent ~= dir and not Content:exist(parent) then -- 480
		if not ensureDirRecursive(parent) then -- 480
			return false -- 483
		end -- 483
	end -- 483
	return Content:mkdir(dir) -- 486
end -- 486
function writeSpawnInfo(projectRoot, memoryScope, value) -- 489
	local dir = Path(projectRoot, ".agent", memoryScope) -- 490
	if not Content:exist(dir) then -- 490
		ensureDirRecursive(dir) -- 492
	end -- 492
	local path = Path(dir, SPAWN_INFO_FILE) -- 494
	local text = safeJsonEncode(value) -- 495
	if not text then -- 495
		return false -- 496
	end -- 496
	local content = text .. "\n" -- 497
	if not Content:save(path, content) then -- 497
		return false -- 499
	end -- 499
	Tools.sendWebIDEFileUpdate(path, true, content) -- 501
	return true -- 502
end -- 502
function readSpawnInfo(projectRoot, memoryScope) -- 505
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 506
	if not Content:exist(path) then -- 506
		return nil -- 507
	end -- 507
	local text = Content:load(path) -- 508
	if not text or __TS__StringTrim(text) == "" then -- 508
		return nil -- 509
	end -- 509
	local value = safeJsonDecode(text) -- 510
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 510
		return value -- 512
	end -- 512
	return nil -- 514
end -- 514
function getArtifactRelativeDir(memoryScope) -- 517
	return Path(".agent", memoryScope) -- 518
end -- 518
function getArtifactDir(projectRoot, memoryScope) -- 521
	return Path( -- 522
		projectRoot, -- 522
		getArtifactRelativeDir(memoryScope) -- 522
	) -- 522
end -- 522
function getResultRelativePath(memoryScope) -- 525
	return Path( -- 526
		getArtifactRelativeDir(memoryScope), -- 526
		RESULT_FILE -- 526
	) -- 526
end -- 526
function getResultPath(projectRoot, memoryScope) -- 529
	return Path( -- 530
		projectRoot, -- 530
		getResultRelativePath(memoryScope) -- 530
	) -- 530
end -- 530
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 533
	if not resultFilePath or resultFilePath == "" then -- 533
		return "" -- 534
	end -- 534
	local path = Path(projectRoot, resultFilePath) -- 535
	if not Content:exist(path) then -- 535
		return "" -- 536
	end -- 536
	local text = sanitizeUTF8(Content:load(path)) -- 537
	if not text or __TS__StringTrim(text) == "" then -- 537
		return "" -- 538
	end -- 538
	local marker = "\n## Summary\n" -- 539
	local start = string.find(text, marker, 1, true) -- 540
	if start ~= nil then -- 540
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 542
	end -- 542
	return __TS__StringTrim(text) -- 544
end -- 544
function containsNormalizedText(text, query) -- 547
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 548
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 549
	if normalizedQuery == "" then -- 549
		return true -- 550
	end -- 550
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 551
end -- 551
function writeSubAgentResultFile(session, record, resultText) -- 554
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 555
	if not Content:exist(dir) then -- 555
		ensureDirRecursive(dir) -- 557
	end -- 557
	local ____array_12 = __TS__SparseArrayNew( -- 557
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 560
		"- Status: " .. record.status, -- 561
		"- Success: " .. (record.success and "true" or "false"), -- 562
		"- Session ID: " .. tostring(record.sessionId), -- 563
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 564
		"- Goal: " .. record.goal, -- 565
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 566
	) -- 566
	__TS__SparseArrayPush( -- 566
		____array_12, -- 566
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 567
	) -- 567
	__TS__SparseArrayPush( -- 567
		____array_12, -- 567
		"- Finished At: " .. record.finishedAt, -- 568
		"", -- 569
		"## Summary", -- 570
		resultText ~= "" and resultText or "(empty)" -- 571
	) -- 571
	local lines = {__TS__SparseArraySpread(____array_12)} -- 559
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 573
	local content = table.concat(lines, "\n") .. "\n" -- 574
	if not Content:save(path, content) then -- 574
		return false -- 576
	end -- 576
	Tools.sendWebIDEFileUpdate(path, true, content) -- 578
	return true -- 579
end -- 579
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 582
	local dir = Path(projectRoot, ".agent", "subagents") -- 583
	if not Content:exist(dir) or not Content:isdir(dir) then -- 583
		return {} -- 584
	end -- 584
	local items = {} -- 585
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 586
		do -- 586
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 587
			if not Content:exist(path) or not Content:isdir(path) then -- 587
				goto __continue90 -- 588
			end -- 588
			local info = readSpawnInfo( -- 589
				projectRoot, -- 589
				Path( -- 589
					"subagents", -- 589
					Path:getFilename(path) -- 589
				) -- 589
			) -- 589
			if not info then -- 589
				goto __continue90 -- 590
			end -- 590
			local sessionId = tonumber(info.sessionId) -- 591
			local infoRootSessionId = tonumber(info.rootSessionId) -- 592
			local sourceTaskId = tonumber(info.sourceTaskId) -- 593
			local status = sanitizeUTF8(toStr(info.status)) -- 594
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 594
				goto __continue90 -- 595
			end -- 595
			if status ~= "DONE" and status ~= "FAILED" then -- 595
				goto __continue90 -- 596
			end -- 596
			items[#items + 1] = { -- 597
				sessionId = sessionId, -- 598
				rootSessionId = infoRootSessionId, -- 599
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 600
				title = sanitizeUTF8(toStr(info.title)), -- 601
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 602
				goal = sanitizeUTF8(toStr(info.goal)), -- 603
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 604
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 605
					__TS__ArrayFilter( -- 606
						info.filesHint, -- 606
						function(____, item) return type(item) == "string" end -- 606
					), -- 606
					function(____, item) return sanitizeUTF8(item) end -- 606
				) or ({}), -- 606
				status = status == "FAILED" and "FAILED" or "DONE", -- 608
				success = info.success == true, -- 609
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 610
				artifactDir = sanitizeUTF8(toStr(info.artifactDir)) or getArtifactRelativeDir(Path( -- 611
					"subagents", -- 611
					Path:getFilename(path) -- 611
				)), -- 611
				sourceTaskId = sourceTaskId or 0, -- 612
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 613
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 614
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 615
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 616
			} -- 616
		end -- 616
		::__continue90:: -- 616
	end -- 616
	__TS__ArraySort( -- 619
		items, -- 619
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 619
	) -- 619
	return items -- 620
end -- 620
function getPendingHandoffDir(projectRoot, memoryScope) -- 623
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 624
end -- 624
function writePendingHandoff(projectRoot, memoryScope, value) -- 627
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 628
	if not Content:exist(dir) then -- 628
		ensureDirRecursive(dir) -- 630
	end -- 630
	local path = Path(dir, value.id .. ".json") -- 632
	local text = safeJsonEncode(value) -- 633
	if not text then -- 633
		return false -- 634
	end -- 634
	return Content:save(path, text .. "\n") -- 635
end -- 635
function listPendingHandoffs(projectRoot, memoryScope) -- 638
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 639
	if not Content:exist(dir) or not Content:isdir(dir) then -- 639
		return {} -- 640
	end -- 640
	local items = {} -- 641
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 642
		do -- 642
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 643
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 643
				goto __continue105 -- 644
			end -- 644
			local text = Content:load(path) -- 645
			if not text or __TS__StringTrim(text) == "" then -- 645
				goto __continue105 -- 646
			end -- 646
			local value = safeJsonDecode(text) -- 647
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 647
				goto __continue105 -- 648
			end -- 648
			local sourceTaskId = tonumber(value.sourceTaskId) -- 649
			local sourceSessionId = tonumber(value.sourceSessionId) -- 650
			local id = sanitizeUTF8(toStr(value.id)) -- 651
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 652
			local message = sanitizeUTF8(toStr(value.message)) -- 653
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 654
			local goal = sanitizeUTF8(toStr(value.goal)) -- 655
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 656
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 656
				goto __continue105 -- 658
			end -- 658
			items[#items + 1] = { -- 660
				id = id, -- 661
				sourceSessionId = sourceSessionId, -- 662
				sourceTitle = sourceTitle, -- 663
				sourceTaskId = sourceTaskId, -- 664
				message = message, -- 665
				prompt = prompt, -- 666
				goal = goal, -- 667
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 668
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 669
					__TS__ArrayFilter( -- 670
						value.filesHint, -- 670
						function(____, item) return type(item) == "string" end -- 670
					), -- 670
					function(____, item) return sanitizeUTF8(item) end -- 670
				) or ({}), -- 670
				success = value.success == true, -- 672
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 673
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 674
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 675
				createdAt = createdAt -- 676
			} -- 676
		end -- 676
		::__continue105:: -- 676
	end -- 676
	__TS__ArraySort( -- 679
		items, -- 679
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 679
	) -- 679
	return items -- 680
end -- 680
function deletePendingHandoff(projectRoot, memoryScope, id) -- 683
	local path = Path( -- 684
		getPendingHandoffDir(projectRoot, memoryScope), -- 684
		id .. ".json" -- 684
	) -- 684
	if Content:exist(path) then -- 684
		Content:remove(path) -- 686
	end -- 686
end -- 686
function normalizePromptText(prompt) -- 690
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 691
end -- 691
function normalizePromptTextSafe(prompt) -- 694
	if type(prompt) == "string" then -- 694
		local normalized = normalizePromptText(prompt) -- 696
		if normalized ~= "" then -- 696
			return normalized -- 697
		end -- 697
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 698
		if sanitized ~= "" then -- 698
			return truncateAgentUserPrompt(sanitized) -- 700
		end -- 700
		return "" -- 702
	end -- 702
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 704
	if text == "" then -- 704
		return "" -- 705
	end -- 705
	return truncateAgentUserPrompt(text) -- 706
end -- 706
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 709
	local sections = {} -- 710
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 711
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 712
	local normalizedFiles = __TS__ArrayFilter( -- 713
		__TS__ArrayMap( -- 713
			__TS__ArrayFilter( -- 713
				filesHint or ({}), -- 713
				function(____, item) return type(item) == "string" end -- 714
			), -- 714
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 715
		), -- 715
		function(____, item) return item ~= "" end -- 716
	) -- 716
	if normalizedTitle ~= "" then -- 716
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 718
	end -- 718
	if normalizedExpected ~= "" then -- 718
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 721
	end -- 721
	if #normalizedFiles > 0 then -- 721
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 724
	end -- 724
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 726
end -- 726
function normalizeSessionRuntimeState(session) -- 729
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 729
		return session -- 731
	end -- 731
	if activeStopTokens[session.currentTaskId] then -- 731
		return session -- 734
	end -- 734
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 736
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 737
	return __TS__ObjectAssign( -- 738
		{}, -- 738
		session, -- 739
		{ -- 738
			status = "STOPPED", -- 740
			currentTaskStatus = "STOPPED", -- 741
			updatedAt = now() -- 742
		} -- 742
	) -- 742
end -- 742
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 746
	DB:exec( -- 747
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 747
		{ -- 751
			status, -- 752
			currentTaskId or 0, -- 753
			currentTaskStatus or status, -- 754
			now(), -- 755
			sessionId -- 756
		} -- 756
	) -- 756
end -- 756
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 761
	if taskId == nil or taskId <= 0 then -- 761
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 763
		return -- 764
	end -- 764
	local row = getSessionRow(sessionId) -- 766
	if not row then -- 766
		return -- 767
	end -- 767
	local session = rowToSession(row) -- 768
	if session.currentTaskId ~= taskId then -- 768
		Log( -- 770
			"Info", -- 770
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 770
		) -- 770
		return -- 771
	end -- 771
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 773
end -- 773
function insertMessage(sessionId, role, content, taskId) -- 776
	local t = now() -- 777
	DB:exec( -- 778
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 778
		{ -- 781
			sessionId, -- 782
			taskId or 0, -- 783
			role, -- 784
			sanitizeUTF8(content), -- 785
			t, -- 786
			t -- 787
		} -- 787
	) -- 787
	return getLastInsertRowId() -- 790
end -- 790
function updateMessage(messageId, content) -- 793
	DB:exec( -- 794
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 794
		{ -- 796
			sanitizeUTF8(content), -- 796
			now(), -- 796
			messageId -- 796
		} -- 796
	) -- 796
end -- 796
function upsertAssistantMessage(sessionId, taskId, content) -- 800
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 801
	if row and type(row[1]) == "number" then -- 801
		updateMessage(row[1], content) -- 808
		return row[1] -- 809
	end -- 809
	return insertMessage(sessionId, "assistant", content, taskId) -- 811
end -- 811
function upsertStep(sessionId, taskId, step, tool, patch) -- 814
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 824
	local reason = sanitizeUTF8(patch.reason or "") -- 828
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 829
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 830
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 831
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 832
	local statusPatch = patch.status or "" -- 833
	local status = patch.status or "PENDING" -- 834
	if not row then -- 834
		local t = now() -- 836
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 837
			sessionId, -- 841
			taskId, -- 842
			step, -- 843
			tool, -- 844
			status, -- 845
			reason, -- 846
			reasoningContent, -- 847
			paramsJson, -- 848
			resultJson, -- 849
			patch.checkpointId or 0, -- 850
			patch.checkpointSeq or 0, -- 851
			filesJson, -- 852
			t, -- 853
			t -- 854
		}) -- 854
		return -- 857
	end -- 857
	DB:exec( -- 859
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 859
		{ -- 871
			tool, -- 872
			statusPatch, -- 873
			status, -- 874
			reason, -- 875
			reason, -- 876
			reasoningContent, -- 877
			reasoningContent, -- 878
			paramsJson, -- 879
			paramsJson, -- 880
			resultJson, -- 881
			resultJson, -- 882
			patch.checkpointId or 0, -- 883
			patch.checkpointId or 0, -- 884
			patch.checkpointSeq or 0, -- 885
			patch.checkpointSeq or 0, -- 886
			filesJson, -- 887
			filesJson, -- 888
			now(), -- 889
			row[1] -- 890
		} -- 890
	) -- 890
end -- 890
function getNextStepNumber(sessionId, taskId) -- 895
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 896
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 900
	return math.max(0, current) + 1 -- 901
end -- 901
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 904
	if status == nil then -- 904
		status = "DONE" -- 912
	end -- 912
	local step = getNextStepNumber(sessionId, taskId) -- 914
	upsertStep( -- 915
		sessionId, -- 915
		taskId, -- 915
		step, -- 915
		tool, -- 915
		{status = status, reason = reason, params = params, result = result} -- 915
	) -- 915
	return getStepItem(sessionId, taskId, step) -- 921
end -- 921
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 924
	if taskId <= 0 then -- 924
		return -- 925
	end -- 925
	if finalSteps ~= nil and finalSteps >= 0 then -- 925
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 927
	end -- 927
	if not finalStatus then -- 927
		return -- 933
	end -- 933
	if finalSteps ~= nil and finalSteps >= 0 then -- 933
		DB:exec( -- 935
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 935
			{ -- 939
				finalStatus, -- 939
				now(), -- 939
				sessionId, -- 939
				taskId, -- 939
				finalSteps -- 939
			} -- 939
		) -- 939
		return -- 941
	end -- 941
	DB:exec( -- 943
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 943
		{ -- 947
			finalStatus, -- 947
			now(), -- 947
			sessionId, -- 947
			taskId -- 947
		} -- 947
	) -- 947
end -- 947
function emitAgentSessionPatch(sessionId, patch) -- 974
	if HttpServer.wsConnectionCount == 0 then -- 974
		return -- 976
	end -- 976
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 978
	if not text then -- 978
		return -- 983
	end -- 983
	emit("AppWS", "Send", text) -- 984
end -- 984
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 987
	emitAgentSessionPatch( -- 988
		sessionId, -- 988
		{ -- 988
			sessionDeleted = true, -- 989
			relatedSessions = listRelatedSessions(rootSessionId) -- 990
		} -- 990
	) -- 990
	local rootSession = getSessionItem(rootSessionId) -- 992
	if rootSession then -- 992
		emitAgentSessionPatch( -- 994
			rootSessionId, -- 994
			{ -- 994
				session = rootSession, -- 995
				relatedSessions = listRelatedSessions(rootSessionId) -- 996
			} -- 996
		) -- 996
	end -- 996
end -- 996
function flushPendingSubAgentHandoffs(rootSession) -- 1001
	if rootSession.kind ~= "main" then -- 1001
		return -- 1002
	end -- 1002
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1002
		return -- 1004
	end -- 1004
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1006
	if #items == 0 then -- 1006
		return -- 1007
	end -- 1007
	local handoffTaskId = 0 -- 1008
	local ____rootSession_currentTaskId_13 -- 1009
	if rootSession.currentTaskId then -- 1009
		____rootSession_currentTaskId_13 = getTaskPrompt(rootSession.currentTaskId) -- 1009
	else -- 1009
		____rootSession_currentTaskId_13 = nil -- 1009
	end -- 1009
	local currentTaskPrompt = ____rootSession_currentTaskId_13 -- 1009
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1009
		handoffTaskId = rootSession.currentTaskId -- 1017
	else -- 1017
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1019
		if not taskRes.success then -- 1019
			Log( -- 1021
				"Warn", -- 1021
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1021
			) -- 1021
			return -- 1022
		end -- 1022
		handoffTaskId = taskRes.taskId -- 1024
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1025
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1026
		emitAgentSessionPatch( -- 1027
			rootSession.id, -- 1027
			{session = getSessionItem(rootSession.id)} -- 1027
		) -- 1027
	end -- 1027
	do -- 1027
		local i = 0 -- 1031
		while i < #items do -- 1031
			local item = items[i + 1] -- 1032
			local step = appendSystemStep( -- 1033
				rootSession.id, -- 1034
				handoffTaskId, -- 1035
				"sub_agent_handoff", -- 1036
				"sub_agent_handoff", -- 1037
				item.message, -- 1038
				{ -- 1039
					sourceSessionId = item.sourceSessionId, -- 1040
					sourceTitle = item.sourceTitle, -- 1041
					sourceTaskId = item.sourceTaskId, -- 1042
					success = item.success == true, -- 1043
					summary = item.message, -- 1044
					resultFilePath = item.resultFilePath or "", -- 1045
					artifactDir = item.artifactDir or "", -- 1046
					finishedAt = item.finishedAt or "" -- 1047
				}, -- 1047
				{ -- 1049
					sourceSessionId = item.sourceSessionId, -- 1050
					sourceTitle = item.sourceTitle, -- 1051
					prompt = item.prompt, -- 1052
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1053
					expectedOutput = item.expectedOutput or "", -- 1054
					filesHint = item.filesHint or ({}), -- 1055
					resultFilePath = item.resultFilePath or "", -- 1056
					artifactDir = item.artifactDir or "" -- 1057
				}, -- 1057
				"DONE" -- 1059
			) -- 1059
			if step then -- 1059
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1062
			end -- 1062
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1064
			i = i + 1 -- 1031
		end -- 1031
	end -- 1031
end -- 1031
function applyEvent(sessionId, event) -- 1068
	repeat -- 1068
		local ____switch167 = event.type -- 1068
		local ____cond167 = ____switch167 == "task_started" -- 1068
		if ____cond167 then -- 1068
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1071
			emitAgentSessionPatch( -- 1072
				sessionId, -- 1072
				{session = getSessionItem(sessionId)} -- 1072
			) -- 1072
			break -- 1075
		end -- 1075
		____cond167 = ____cond167 or ____switch167 == "decision_made" -- 1075
		if ____cond167 then -- 1075
			upsertStep( -- 1077
				sessionId, -- 1077
				event.taskId, -- 1077
				event.step, -- 1077
				event.tool, -- 1077
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1077
			) -- 1077
			emitAgentSessionPatch( -- 1083
				sessionId, -- 1083
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1083
			) -- 1083
			break -- 1086
		end -- 1086
		____cond167 = ____cond167 or ____switch167 == "tool_started" -- 1086
		if ____cond167 then -- 1086
			upsertStep( -- 1088
				sessionId, -- 1088
				event.taskId, -- 1088
				event.step, -- 1088
				event.tool, -- 1088
				{status = "RUNNING"} -- 1088
			) -- 1088
			emitAgentSessionPatch( -- 1091
				sessionId, -- 1091
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1091
			) -- 1091
			break -- 1094
		end -- 1094
		____cond167 = ____cond167 or ____switch167 == "tool_finished" -- 1094
		if ____cond167 then -- 1094
			upsertStep( -- 1096
				sessionId, -- 1096
				event.taskId, -- 1096
				event.step, -- 1096
				event.tool, -- 1096
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1096
			) -- 1096
			emitAgentSessionPatch( -- 1101
				sessionId, -- 1101
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1101
			) -- 1101
			break -- 1104
		end -- 1104
		____cond167 = ____cond167 or ____switch167 == "checkpoint_created" -- 1104
		if ____cond167 then -- 1104
			upsertStep( -- 1106
				sessionId, -- 1106
				event.taskId, -- 1106
				event.step, -- 1106
				event.tool, -- 1106
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1106
			) -- 1106
			emitAgentSessionPatch( -- 1111
				sessionId, -- 1111
				{ -- 1111
					step = getStepItem(sessionId, event.taskId, event.step), -- 1112
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1113
				} -- 1113
			) -- 1113
			break -- 1115
		end -- 1115
		____cond167 = ____cond167 or ____switch167 == "memory_compression_started" -- 1115
		if ____cond167 then -- 1115
			upsertStep( -- 1117
				sessionId, -- 1117
				event.taskId, -- 1117
				event.step, -- 1117
				event.tool, -- 1117
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1117
			) -- 1117
			emitAgentSessionPatch( -- 1122
				sessionId, -- 1122
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1122
			) -- 1122
			break -- 1125
		end -- 1125
		____cond167 = ____cond167 or ____switch167 == "memory_compression_finished" -- 1125
		if ____cond167 then -- 1125
			upsertStep( -- 1127
				sessionId, -- 1127
				event.taskId, -- 1127
				event.step, -- 1127
				event.tool, -- 1127
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1127
			) -- 1127
			emitAgentSessionPatch( -- 1132
				sessionId, -- 1132
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1132
			) -- 1132
			break -- 1135
		end -- 1135
		____cond167 = ____cond167 or ____switch167 == "assistant_message_updated" -- 1135
		if ____cond167 then -- 1135
			do -- 1135
				upsertStep( -- 1137
					sessionId, -- 1137
					event.taskId, -- 1137
					event.step, -- 1137
					"message", -- 1137
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1137
				) -- 1137
				emitAgentSessionPatch( -- 1142
					sessionId, -- 1142
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1142
				) -- 1142
				break -- 1145
			end -- 1145
		end -- 1145
		____cond167 = ____cond167 or ____switch167 == "task_finished" -- 1145
		if ____cond167 then -- 1145
			do -- 1145
				local ____opt_14 = activeStopTokens[event.taskId or -1] -- 1145
				local stopped = (____opt_14 and ____opt_14.stopped) == true -- 1148
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1149
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 1152
				if event.taskId ~= nil then -- 1152
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1154
					local ____finalizeTaskSteps_18 = finalizeTaskSteps -- 1155
					local ____array_17 = __TS__SparseArrayNew( -- 1155
						sessionId, -- 1156
						event.taskId, -- 1157
						type(event.steps) == "number" and math.max( -- 1158
							0, -- 1158
							math.floor(event.steps) -- 1158
						) or nil -- 1158
					) -- 1158
					local ____event_success_16 -- 1159
					if event.success then -- 1159
						____event_success_16 = nil -- 1159
					else -- 1159
						____event_success_16 = stopped and "STOPPED" or "FAILED" -- 1159
					end -- 1159
					__TS__SparseArrayPush(____array_17, ____event_success_16) -- 1159
					____finalizeTaskSteps_18(__TS__SparseArraySpread(____array_17)) -- 1155
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1161
					activeStopTokens[event.taskId] = nil -- 1162
					emitAgentSessionPatch( -- 1163
						sessionId, -- 1163
						{ -- 1163
							session = getSessionItem(sessionId), -- 1164
							message = getMessageItem(messageId), -- 1165
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1166
							removedStepIds = removedStepIds -- 1167
						} -- 1167
					) -- 1167
				end -- 1167
				local session = getSessionItem(sessionId) -- 1170
				if session and session.kind == "main" then -- 1170
					flushPendingSubAgentHandoffs(session) -- 1172
				end -- 1172
				break -- 1174
			end -- 1174
		end -- 1174
	until true -- 1174
end -- 1174
function ____exports.createSession(projectRoot, title) -- 1291
	if title == nil then -- 1291
		title = "" -- 1291
	end -- 1291
	if not isValidProjectRoot(projectRoot) then -- 1291
		return {success = false, message = "invalid projectRoot"} -- 1293
	end -- 1293
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1295
	if row then -- 1295
		return { -- 1304
			success = true, -- 1304
			session = rowToSession(row) -- 1304
		} -- 1304
	end -- 1304
	local t = now() -- 1306
	DB:exec( -- 1307
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1307
		{ -- 1310
			projectRoot, -- 1310
			title ~= "" and title or Path:getFilename(projectRoot), -- 1310
			t, -- 1310
			t -- 1310
		} -- 1310
	) -- 1310
	local sessionId = getLastInsertRowId() -- 1312
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1313
	local session = getSessionItem(sessionId) -- 1314
	if not session then -- 1314
		return {success = false, message = "failed to create session"} -- 1316
	end -- 1316
	return {success = true, session = session} -- 1318
end -- 1291
function ____exports.createSubSession(parentSessionId, title) -- 1321
	if title == nil then -- 1321
		title = "" -- 1321
	end -- 1321
	local parent = getSessionItem(parentSessionId) -- 1322
	if not parent then -- 1322
		return {success = false, message = "parent session not found"} -- 1324
	end -- 1324
	local rootId = getSessionRootId(parent) -- 1326
	local t = now() -- 1327
	DB:exec( -- 1328
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1328
		{ -- 1331
			parent.projectRoot, -- 1331
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1331
			rootId, -- 1331
			parent.id, -- 1331
			t, -- 1331
			t -- 1331
		} -- 1331
	) -- 1331
	local sessionId = getLastInsertRowId() -- 1333
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1334
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1335
	local session = getSessionItem(sessionId) -- 1336
	if not session then -- 1336
		return {success = false, message = "failed to create sub session"} -- 1338
	end -- 1338
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1340
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1341
	subStorage:writeMemory(parentStorage:readMemory()) -- 1342
	return {success = true, session = session} -- 1343
end -- 1321
function spawnSubAgentSession(request) -- 1346
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1346
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1357
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1358
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1359
		if normalizedPrompt == "" then -- 1359
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1361
		end -- 1361
		if normalizedPrompt == "" then -- 1361
			local ____Log_24 = Log -- 1368
			local ____temp_21 = #normalizedTitle -- 1368
			local ____temp_22 = #rawPrompt -- 1368
			local ____temp_23 = #toStr(request.expectedOutput) -- 1368
			local ____opt_19 = request.filesHint -- 1368
			____Log_24( -- 1368
				"Warn", -- 1368
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_21)) .. " raw_prompt_len=") .. tostring(____temp_22)) .. " expected_len=") .. tostring(____temp_23)) .. " files_hint_count=") .. tostring(____opt_19 and #____opt_19 or 0) -- 1368
			) -- 1368
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1368
		end -- 1368
		Log( -- 1371
			"Info", -- 1371
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1371
		) -- 1371
		local parentSessionId = request.parentSessionId -- 1372
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1372
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1374
			if not fallbackParent then -- 1374
				local createdMain = ____exports.createSession(request.projectRoot) -- 1376
				if createdMain.success then -- 1376
					fallbackParent = createdMain.session -- 1378
				end -- 1378
			end -- 1378
			if fallbackParent then -- 1378
				Log( -- 1382
					"Warn", -- 1382
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1382
				) -- 1382
				parentSessionId = fallbackParent.id -- 1383
			end -- 1383
		end -- 1383
		local parentSession = getSessionItem(parentSessionId) -- 1386
		if not parentSession then -- 1386
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1386
		end -- 1386
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1390
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1390
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1390
		end -- 1390
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1394
		if not created.success then -- 1394
			return ____awaiter_resolve(nil, created) -- 1394
		end -- 1394
		writeSpawnInfo( -- 1398
			created.session.projectRoot, -- 1398
			created.session.memoryScope, -- 1398
			{ -- 1398
				sessionId = created.session.id, -- 1399
				rootSessionId = created.session.rootSessionId, -- 1400
				parentSessionId = created.session.parentSessionId, -- 1401
				title = created.session.title, -- 1402
				prompt = normalizedPrompt, -- 1403
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1404
				expectedOutput = request.expectedOutput or "", -- 1405
				filesHint = request.filesHint or ({}), -- 1406
				status = "RUNNING", -- 1407
				success = false, -- 1408
				resultFilePath = "", -- 1409
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1410
				sourceTaskId = 0, -- 1411
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1412
				createdAtTs = created.session.createdAt, -- 1413
				finishedAt = "", -- 1414
				finishedAtTs = 0 -- 1415
			} -- 1415
		) -- 1415
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1417
		if not sent.success then -- 1417
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1417
		end -- 1417
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1417
	end) -- 1417
end -- 1417
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 1497
	local rootSession = getRootSessionItem(session.id) -- 1498
	if not rootSession then -- 1498
		return -- 1499
	end -- 1499
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1500
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1501
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1502
	local queueResult = writePendingHandoff( -- 1503
		rootSession.projectRoot, -- 1503
		rootSession.memoryScope, -- 1503
		{ -- 1503
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1504
			sourceSessionId = session.id, -- 1505
			sourceTitle = session.title, -- 1506
			sourceTaskId = taskId, -- 1507
			message = summary, -- 1508
			prompt = result.prompt, -- 1509
			goal = result.goal, -- 1510
			expectedOutput = result.expectedOutput or "", -- 1511
			filesHint = result.filesHint or ({}), -- 1512
			success = result.success, -- 1513
			resultFilePath = result.resultFilePath, -- 1514
			artifactDir = result.artifactDir, -- 1515
			finishedAt = result.finishedAt, -- 1516
			createdAt = createdAt -- 1517
		} -- 1517
	) -- 1517
	if not queueResult then -- 1517
		Log( -- 1520
			"Warn", -- 1520
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1520
		) -- 1520
		return -- 1521
	end -- 1521
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1521
		flushPendingSubAgentHandoffs(rootSession) -- 1524
	end -- 1524
end -- 1524
function finalizeSubSession(session, taskId, success, message) -- 1528
	local rootSessionId = getSessionRootId(session) -- 1529
	local rootSession = getRootSessionItem(session.id) -- 1530
	if not rootSession then -- 1530
		return {success = false, message = "root session not found"} -- 1532
	end -- 1532
	local spawnInfo = getSessionSpawnInfo(session) -- 1534
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1535
	local finishedAtTs = now() -- 1536
	local resultText = sanitizeUTF8(message) -- 1537
	local record = { -- 1538
		sessionId = session.id, -- 1539
		rootSessionId = rootSessionId, -- 1540
		parentSessionId = session.parentSessionId, -- 1541
		title = session.title, -- 1542
		prompt = spawnInfo and spawnInfo.prompt or "", -- 1543
		goal = spawnInfo and spawnInfo.goal or session.title, -- 1544
		expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 1545
		filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 1546
		status = success and "DONE" or "FAILED", -- 1547
		success = success, -- 1548
		resultFilePath = getResultRelativePath(session.memoryScope), -- 1549
		artifactDir = getArtifactRelativeDir(session.memoryScope), -- 1550
		sourceTaskId = taskId, -- 1551
		createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 1552
		finishedAt = finishedAt, -- 1553
		createdAtTs = session.createdAt, -- 1554
		finishedAtTs = finishedAtTs -- 1555
	} -- 1555
	if not writeSubAgentResultFile(session, record, resultText) then -- 1555
		return {success = false, message = "failed to persist sub session result file"} -- 1558
	end -- 1558
	if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 1558
		sessionId = record.sessionId, -- 1561
		rootSessionId = record.rootSessionId, -- 1562
		parentSessionId = record.parentSessionId, -- 1563
		title = record.title, -- 1564
		prompt = record.prompt, -- 1565
		goal = record.goal, -- 1566
		expectedOutput = record.expectedOutput or "", -- 1567
		filesHint = record.filesHint or ({}), -- 1568
		status = record.status, -- 1569
		success = record.success, -- 1570
		resultFilePath = record.resultFilePath, -- 1571
		artifactDir = record.artifactDir, -- 1572
		sourceTaskId = record.sourceTaskId, -- 1573
		createdAt = record.createdAt, -- 1574
		finishedAt = record.finishedAt, -- 1575
		createdAtTs = record.createdAtTs, -- 1576
		finishedAtTs = record.finishedAtTs -- 1577
	}) then -- 1577
		return {success = false, message = "failed to persist sub session spawn info"} -- 1579
	end -- 1579
	if success then -- 1579
		appendSubAgentHandoffStep(session, taskId, record, resultText) -- 1582
	end -- 1582
	deleteSessionRecords(session.id, true) -- 1584
	emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 1585
	return {success = true} -- 1586
end -- 1586
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 1589
	if allowSubSessionStart == nil then -- 1589
		allowSubSessionStart = false -- 1589
	end -- 1589
	local session = getSessionItem(sessionId) -- 1590
	if not session then -- 1590
		return {success = false, message = "session not found"} -- 1592
	end -- 1592
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 1592
		return {success = false, message = "session task is still running"} -- 1595
	end -- 1595
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 1597
	if normalizedPrompt == "" and session.kind == "sub" then -- 1597
		local spawnInfo = getSessionSpawnInfo(session) -- 1599
		if spawnInfo then -- 1599
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 1601
			if normalizedPrompt == "" then -- 1601
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 1603
			end -- 1603
		end -- 1603
	end -- 1603
	if normalizedPrompt == "" then -- 1603
		return {success = false, message = "prompt is empty"} -- 1612
	end -- 1612
	local taskRes = Tools.createTask(normalizedPrompt) -- 1614
	if not taskRes.success then -- 1614
		return {success = false, message = taskRes.message} -- 1616
	end -- 1616
	local taskId = taskRes.taskId -- 1618
	local useChineseResponse = getDefaultUseChineseResponse() -- 1619
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 1620
	local stopToken = {stopped = false} -- 1621
	activeStopTokens[taskId] = stopToken -- 1622
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 1623
	runCodingAgent( -- 1624
		{ -- 1624
			prompt = normalizedPrompt, -- 1625
			workDir = session.projectRoot, -- 1626
			useChineseResponse = useChineseResponse, -- 1627
			taskId = taskId, -- 1628
			sessionId = sessionId, -- 1629
			memoryScope = session.memoryScope, -- 1630
			role = session.kind, -- 1631
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 1632
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 1635
			stopToken = stopToken, -- 1638
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 1639
		}, -- 1639
		function(result) -- 1640
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1640
				local nextSession = getSessionItem(sessionId) -- 1641
				if nextSession and nextSession.kind == "sub" then -- 1641
					local finalized = finalizeSubSession(nextSession, taskId, result.success, result.message) -- 1643
					if not finalized.success then -- 1643
						Log( -- 1645
							"Warn", -- 1645
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 1645
						) -- 1645
					end -- 1645
				end -- 1645
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 1645
					applyEvent(sessionId, { -- 1649
						type = "task_finished", -- 1650
						sessionId = sessionId, -- 1651
						taskId = result.taskId, -- 1652
						success = false, -- 1653
						message = result.message, -- 1654
						steps = result.steps -- 1655
					}) -- 1655
				end -- 1655
			end) -- 1655
		end -- 1640
	) -- 1640
	return {success = true, sessionId = sessionId, taskId = taskId} -- 1659
end -- 1589
function ____exports.listRunningSubAgents(request) -- 1706
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1706
		local session = getSessionItem(request.sessionId) -- 1714
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 1714
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1716
		end -- 1716
		if not session then -- 1716
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 1716
		end -- 1716
		local rootSession = getRootSessionItem(session.id) -- 1721
		if not rootSession then -- 1721
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 1721
		end -- 1721
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 1725
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 1726
		local limit = math.max( -- 1727
			1, -- 1727
			math.floor(tonumber(request.limit) or 5) -- 1727
		) -- 1727
		local offset = math.max( -- 1728
			0, -- 1728
			math.floor(tonumber(request.offset) or 0) -- 1728
		) -- 1728
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 1729
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 1730
		local runningSessions = {} -- 1737
		do -- 1737
			local i = 0 -- 1738
			while i < #rows do -- 1738
				do -- 1738
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1739
					if current.currentTaskStatus ~= "RUNNING" then -- 1739
						goto __continue246 -- 1741
					end -- 1741
					local spawnInfo = getSessionSpawnInfo(current) -- 1743
					runningSessions[#runningSessions + 1] = { -- 1744
						sessionId = current.id, -- 1745
						title = current.title, -- 1746
						parentSessionId = current.parentSessionId, -- 1747
						rootSessionId = current.rootSessionId, -- 1748
						status = "RUNNING", -- 1749
						currentTaskId = current.currentTaskId, -- 1750
						currentTaskStatus = current.currentTaskStatus or current.status, -- 1751
						goal = spawnInfo and spawnInfo.goal, -- 1752
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 1753
						filesHint = spawnInfo and spawnInfo.filesHint, -- 1754
						createdAt = current.createdAt, -- 1755
						updatedAt = current.updatedAt -- 1756
					} -- 1756
				end -- 1756
				::__continue246:: -- 1756
				i = i + 1 -- 1738
			end -- 1738
		end -- 1738
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 1759
		local completedSessions = __TS__ArrayMap( -- 1760
			completedRecords, -- 1760
			function(____, record) return { -- 1760
				sessionId = record.sessionId, -- 1761
				title = record.title, -- 1762
				parentSessionId = record.parentSessionId, -- 1763
				rootSessionId = record.rootSessionId, -- 1764
				status = record.status, -- 1765
				goal = record.goal, -- 1766
				expectedOutput = record.expectedOutput, -- 1767
				filesHint = record.filesHint, -- 1768
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 1769
				success = record.success, -- 1770
				resultFilePath = record.resultFilePath, -- 1771
				artifactDir = record.artifactDir, -- 1772
				finishedAt = record.finishedAt, -- 1773
				createdAt = record.createdAtTs, -- 1774
				updatedAt = record.finishedAtTs -- 1775
			} end -- 1775
		) -- 1775
		local merged = {} -- 1777
		if status == "running" then -- 1777
			merged = runningSessions -- 1779
		elseif status == "done" then -- 1779
			merged = __TS__ArrayFilter( -- 1781
				completedSessions, -- 1781
				function(____, item) return item.status == "DONE" end -- 1781
			) -- 1781
		elseif status == "failed" then -- 1781
			merged = __TS__ArrayFilter( -- 1783
				completedSessions, -- 1783
				function(____, item) return item.status == "FAILED" end -- 1783
			) -- 1783
		elseif status == "all" then -- 1783
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 1785
		else -- 1785
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 1787
		end -- 1787
		if query ~= "" then -- 1787
			merged = __TS__ArrayFilter( -- 1790
				merged, -- 1790
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 1790
			) -- 1790
		end -- 1790
		__TS__ArraySort( -- 1796
			merged, -- 1796
			function(____, a, b) -- 1796
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 1796
					return -1 -- 1797
				end -- 1797
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 1797
					return 1 -- 1798
				end -- 1798
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 1798
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 1800
				end -- 1800
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 1802
			end -- 1796
		) -- 1796
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 1804
		return ____awaiter_resolve(nil, { -- 1804
			success = true, -- 1806
			rootSessionId = rootSession.id, -- 1807
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 1808
			status = status, -- 1809
			limit = limit, -- 1810
			offset = offset, -- 1811
			hasMore = offset + limit < #merged, -- 1812
			sessions = paged -- 1813
		}) -- 1813
	end) -- 1813
end -- 1706
TABLE_SESSION = "AgentSession" -- 140
TABLE_MESSAGE = "AgentSessionMessage" -- 141
TABLE_STEP = "AgentSessionStep" -- 142
TABLE_TASK = "AgentTask" -- 143
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 144
SPAWN_INFO_FILE = "SPAWN.json" -- 145
RESULT_FILE = "RESULT.md" -- 146
PENDING_HANDOFF_DIR = "pending-handoffs" -- 147
MAX_CONCURRENT_SUB_AGENTS = 4 -- 148
activeStopTokens = {} -- 188
now = function() return os.time() end -- 189
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 464
	if projectRoot == oldRoot then -- 464
		return newRoot -- 466
	end -- 466
	for ____, separator in ipairs({"/", "\\"}) do -- 468
		local prefix = oldRoot .. separator -- 469
		if __TS__StringStartsWith(projectRoot, prefix) then -- 469
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 471
		end -- 471
	end -- 471
	return nil -- 474
end -- 464
local function sanitizeStoredSteps(sessionId) -- 951
	DB:exec( -- 952
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 952
		{ -- 970
			now(), -- 970
			sessionId -- 970
		} -- 970
	) -- 970
end -- 951
local function getSchemaVersion() -- 1179
	local row = queryOne("PRAGMA user_version") -- 1180
	return row and type(row[1]) == "number" and row[1] or 0 -- 1181
end -- 1179
local function setSchemaVersion(version) -- 1184
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1185
		0, -- 1185
		math.floor(version) -- 1185
	))) -- 1185
end -- 1184
local function recreateSchema() -- 1188
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1189
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1190
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1191
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1192
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1206
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1207
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1216
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1217
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1234
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1235
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1236
end -- 1188
do -- 1188
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1188
		recreateSchema() -- 1242
	else -- 1242
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1244
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1258
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1259
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1268
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1269
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1286
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1287
	end -- 1287
end -- 1287
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1429
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1429
		return {success = false, message = "invalid projectRoot"} -- 1431
	end -- 1431
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1433
	for ____, row in ipairs(rows) do -- 1434
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1435
		if sessionId > 0 then -- 1435
			deleteSessionRecords(sessionId) -- 1437
		end -- 1437
	end -- 1437
	return {success = true, deleted = #rows} -- 1440
end -- 1429
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1443
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1443
		return {success = false, message = "invalid projectRoot"} -- 1445
	end -- 1445
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1447
	local renamed = 0 -- 1448
	for ____, row in ipairs(rows) do -- 1449
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1450
		local projectRoot = toStr(row[2]) -- 1451
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1452
		if sessionId > 0 and nextProjectRoot then -- 1452
			DB:exec( -- 1454
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1454
				{ -- 1456
					nextProjectRoot, -- 1456
					Path:getFilename(nextProjectRoot), -- 1456
					now(), -- 1456
					sessionId -- 1456
				} -- 1456
			) -- 1456
			renamed = renamed + 1 -- 1458
		end -- 1458
	end -- 1458
	return {success = true, renamed = renamed} -- 1461
end -- 1443
function ____exports.getSession(sessionId) -- 1464
	local session = getSessionItem(sessionId) -- 1465
	if not session then -- 1465
		return {success = false, message = "session not found"} -- 1467
	end -- 1467
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1469
	local relatedSessions = listRelatedSessions(sessionId) -- 1470
	sanitizeStoredSteps(sessionId) -- 1471
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1472
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1479
	local ____relatedSessions_26 = relatedSessions -- 1490
	local ____temp_25 -- 1491
	if normalizedSession.kind == "sub" then -- 1491
		____temp_25 = getSessionSpawnInfo(normalizedSession) -- 1491
	else -- 1491
		____temp_25 = nil -- 1491
	end -- 1491
	return { -- 1487
		success = true, -- 1488
		session = normalizedSession, -- 1489
		relatedSessions = ____relatedSessions_26, -- 1490
		spawnInfo = ____temp_25, -- 1491
		messages = __TS__ArrayMap( -- 1492
			messages, -- 1492
			function(____, row) return rowToMessage(row) end -- 1492
		), -- 1492
		steps = __TS__ArrayMap( -- 1493
			steps, -- 1493
			function(____, row) return rowToStep(row) end -- 1493
		) -- 1493
	} -- 1493
end -- 1464
function ____exports.stopSessionTask(sessionId) -- 1662
	local session = getSessionItem(sessionId) -- 1663
	if not session or session.currentTaskId == nil then -- 1663
		return {success = false, message = "session task not found"} -- 1665
	end -- 1665
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1667
	local stopToken = activeStopTokens[session.currentTaskId] -- 1668
	if not stopToken then -- 1668
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 1668
			return {success = true, recovered = true} -- 1671
		end -- 1671
		return {success = false, message = "task is not running"} -- 1673
	end -- 1673
	stopToken.stopped = true -- 1675
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 1676
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1677
	return {success = true} -- 1678
end -- 1662
function ____exports.getCurrentTaskId(sessionId) -- 1681
	local ____opt_37 = getSessionItem(sessionId) -- 1681
	return ____opt_37 and ____opt_37.currentTaskId -- 1682
end -- 1681
function ____exports.listRunningSessions() -- 1685
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 1686
	local sessions = {} -- 1693
	do -- 1693
		local i = 0 -- 1694
		while i < #rows do -- 1694
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1695
			if session.currentTaskStatus == "RUNNING" then -- 1695
				sessions[#sessions + 1] = session -- 1697
			end -- 1697
			i = i + 1 -- 1694
		end -- 1694
	end -- 1694
	return {success = true, sessions = sessions} -- 1700
end -- 1685
return ____exports -- 1685