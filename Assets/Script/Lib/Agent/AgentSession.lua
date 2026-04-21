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
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, setSessionStateForTaskEvent, insertMessage, updateMessage, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, activeStopTokens, now -- 1
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
function getSubAgentDisplayKey(item) -- 554
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 560
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 561
	local label = goal ~= "" and goal or title -- 562
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 563
end -- 563
function writeSubAgentResultFile(session, record, resultText) -- 566
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 567
	if not Content:exist(dir) then -- 567
		ensureDirRecursive(dir) -- 569
	end -- 569
	local ____array_12 = __TS__SparseArrayNew( -- 569
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 572
		"- Status: " .. record.status, -- 573
		"- Success: " .. (record.success and "true" or "false"), -- 574
		"- Session ID: " .. tostring(record.sessionId), -- 575
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 576
		"- Goal: " .. record.goal, -- 577
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 578
	) -- 578
	__TS__SparseArrayPush( -- 578
		____array_12, -- 578
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 579
	) -- 579
	__TS__SparseArrayPush( -- 579
		____array_12, -- 579
		"- Finished At: " .. record.finishedAt, -- 580
		"", -- 581
		"## Summary", -- 582
		resultText ~= "" and resultText or "(empty)" -- 583
	) -- 583
	local lines = {__TS__SparseArraySpread(____array_12)} -- 571
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 585
	local content = table.concat(lines, "\n") .. "\n" -- 586
	if not Content:save(path, content) then -- 586
		return false -- 588
	end -- 588
	Tools.sendWebIDEFileUpdate(path, true, content) -- 590
	return true -- 591
end -- 591
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 594
	local dir = Path(projectRoot, ".agent", "subagents") -- 595
	if not Content:exist(dir) or not Content:isdir(dir) then -- 595
		return {} -- 596
	end -- 596
	local items = {} -- 597
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 598
		do -- 598
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 599
			if not Content:exist(path) or not Content:isdir(path) then -- 599
				goto __continue91 -- 600
			end -- 600
			local info = readSpawnInfo( -- 601
				projectRoot, -- 601
				Path( -- 601
					"subagents", -- 601
					Path:getFilename(path) -- 601
				) -- 601
			) -- 601
			if not info then -- 601
				goto __continue91 -- 602
			end -- 602
			local sessionId = tonumber(info.sessionId) -- 603
			local infoRootSessionId = tonumber(info.rootSessionId) -- 604
			local sourceTaskId = tonumber(info.sourceTaskId) -- 605
			local status = sanitizeUTF8(toStr(info.status)) -- 606
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 606
				goto __continue91 -- 607
			end -- 607
			if status ~= "DONE" and status ~= "FAILED" then -- 607
				goto __continue91 -- 608
			end -- 608
			items[#items + 1] = { -- 609
				sessionId = sessionId, -- 610
				rootSessionId = infoRootSessionId, -- 611
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 612
				title = sanitizeUTF8(toStr(info.title)), -- 613
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 614
				goal = sanitizeUTF8(toStr(info.goal)), -- 615
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 616
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 617
					__TS__ArrayFilter( -- 618
						info.filesHint, -- 618
						function(____, item) return type(item) == "string" end -- 618
					), -- 618
					function(____, item) return sanitizeUTF8(item) end -- 618
				) or ({}), -- 618
				status = status == "FAILED" and "FAILED" or "DONE", -- 620
				success = info.success == true, -- 621
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 622
				artifactDir = sanitizeUTF8(toStr(info.artifactDir)) or getArtifactRelativeDir(Path( -- 623
					"subagents", -- 623
					Path:getFilename(path) -- 623
				)), -- 623
				sourceTaskId = sourceTaskId or 0, -- 624
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 625
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 626
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 627
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 628
			} -- 628
		end -- 628
		::__continue91:: -- 628
	end -- 628
	__TS__ArraySort( -- 631
		items, -- 631
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 631
	) -- 631
	return items -- 632
end -- 632
function getPendingHandoffDir(projectRoot, memoryScope) -- 635
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 636
end -- 636
function writePendingHandoff(projectRoot, memoryScope, value) -- 639
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 640
	if not Content:exist(dir) then -- 640
		ensureDirRecursive(dir) -- 642
	end -- 642
	local path = Path(dir, value.id .. ".json") -- 644
	local text = safeJsonEncode(value) -- 645
	if not text then -- 645
		return false -- 646
	end -- 646
	return Content:save(path, text .. "\n") -- 647
end -- 647
function listPendingHandoffs(projectRoot, memoryScope) -- 650
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 651
	if not Content:exist(dir) or not Content:isdir(dir) then -- 651
		return {} -- 652
	end -- 652
	local items = {} -- 653
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 654
		do -- 654
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 655
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 655
				goto __continue106 -- 656
			end -- 656
			local text = Content:load(path) -- 657
			if not text or __TS__StringTrim(text) == "" then -- 657
				goto __continue106 -- 658
			end -- 658
			local value = safeJsonDecode(text) -- 659
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 659
				goto __continue106 -- 660
			end -- 660
			local sourceTaskId = tonumber(value.sourceTaskId) -- 661
			local sourceSessionId = tonumber(value.sourceSessionId) -- 662
			local id = sanitizeUTF8(toStr(value.id)) -- 663
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 664
			local message = sanitizeUTF8(toStr(value.message)) -- 665
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 666
			local goal = sanitizeUTF8(toStr(value.goal)) -- 667
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 668
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 668
				goto __continue106 -- 670
			end -- 670
			items[#items + 1] = { -- 672
				id = id, -- 673
				sourceSessionId = sourceSessionId, -- 674
				sourceTitle = sourceTitle, -- 675
				sourceTaskId = sourceTaskId, -- 676
				message = message, -- 677
				prompt = prompt, -- 678
				goal = goal, -- 679
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 680
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 681
					__TS__ArrayFilter( -- 682
						value.filesHint, -- 682
						function(____, item) return type(item) == "string" end -- 682
					), -- 682
					function(____, item) return sanitizeUTF8(item) end -- 682
				) or ({}), -- 682
				success = value.success == true, -- 684
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 685
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 686
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 687
				createdAt = createdAt -- 688
			} -- 688
		end -- 688
		::__continue106:: -- 688
	end -- 688
	__TS__ArraySort( -- 691
		items, -- 691
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 691
	) -- 691
	return items -- 692
end -- 692
function deletePendingHandoff(projectRoot, memoryScope, id) -- 695
	local path = Path( -- 696
		getPendingHandoffDir(projectRoot, memoryScope), -- 696
		id .. ".json" -- 696
	) -- 696
	if Content:exist(path) then -- 696
		Content:remove(path) -- 698
	end -- 698
end -- 698
function normalizePromptText(prompt) -- 702
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 703
end -- 703
function normalizePromptTextSafe(prompt) -- 706
	if type(prompt) == "string" then -- 706
		local normalized = normalizePromptText(prompt) -- 708
		if normalized ~= "" then -- 708
			return normalized -- 709
		end -- 709
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 710
		if sanitized ~= "" then -- 710
			return truncateAgentUserPrompt(sanitized) -- 712
		end -- 712
		return "" -- 714
	end -- 714
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 716
	if text == "" then -- 716
		return "" -- 717
	end -- 717
	return truncateAgentUserPrompt(text) -- 718
end -- 718
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 721
	local sections = {} -- 722
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 723
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 724
	local normalizedFiles = __TS__ArrayFilter( -- 725
		__TS__ArrayMap( -- 725
			__TS__ArrayFilter( -- 725
				filesHint or ({}), -- 725
				function(____, item) return type(item) == "string" end -- 726
			), -- 726
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 727
		), -- 727
		function(____, item) return item ~= "" end -- 728
	) -- 728
	if normalizedTitle ~= "" then -- 728
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 730
	end -- 730
	if normalizedExpected ~= "" then -- 730
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 733
	end -- 733
	if #normalizedFiles > 0 then -- 733
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 736
	end -- 736
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 738
end -- 738
function normalizeSessionRuntimeState(session) -- 741
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 741
		return session -- 743
	end -- 743
	if activeStopTokens[session.currentTaskId] then -- 743
		return session -- 746
	end -- 746
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 748
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 749
	return __TS__ObjectAssign( -- 750
		{}, -- 750
		session, -- 751
		{ -- 750
			status = "STOPPED", -- 752
			currentTaskStatus = "STOPPED", -- 753
			updatedAt = now() -- 754
		} -- 754
	) -- 754
end -- 754
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 758
	DB:exec( -- 759
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 759
		{ -- 763
			status, -- 764
			currentTaskId or 0, -- 765
			currentTaskStatus or status, -- 766
			now(), -- 767
			sessionId -- 768
		} -- 768
	) -- 768
end -- 768
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 773
	if taskId == nil or taskId <= 0 then -- 773
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 775
		return -- 776
	end -- 776
	local row = getSessionRow(sessionId) -- 778
	if not row then -- 778
		return -- 779
	end -- 779
	local session = rowToSession(row) -- 780
	if session.currentTaskId ~= taskId then -- 780
		Log( -- 782
			"Info", -- 782
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 782
		) -- 782
		return -- 783
	end -- 783
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 785
end -- 785
function insertMessage(sessionId, role, content, taskId) -- 788
	local t = now() -- 789
	DB:exec( -- 790
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 790
		{ -- 793
			sessionId, -- 794
			taskId or 0, -- 795
			role, -- 796
			sanitizeUTF8(content), -- 797
			t, -- 798
			t -- 799
		} -- 799
	) -- 799
	return getLastInsertRowId() -- 802
end -- 802
function updateMessage(messageId, content) -- 805
	DB:exec( -- 806
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 806
		{ -- 808
			sanitizeUTF8(content), -- 808
			now(), -- 808
			messageId -- 808
		} -- 808
	) -- 808
end -- 808
function upsertAssistantMessage(sessionId, taskId, content) -- 812
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 813
	if row and type(row[1]) == "number" then -- 813
		updateMessage(row[1], content) -- 820
		return row[1] -- 821
	end -- 821
	return insertMessage(sessionId, "assistant", content, taskId) -- 823
end -- 823
function upsertStep(sessionId, taskId, step, tool, patch) -- 826
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 836
	local reason = sanitizeUTF8(patch.reason or "") -- 840
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 841
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 842
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 843
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 844
	local statusPatch = patch.status or "" -- 845
	local status = patch.status or "PENDING" -- 846
	if not row then -- 846
		local t = now() -- 848
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 849
			sessionId, -- 853
			taskId, -- 854
			step, -- 855
			tool, -- 856
			status, -- 857
			reason, -- 858
			reasoningContent, -- 859
			paramsJson, -- 860
			resultJson, -- 861
			patch.checkpointId or 0, -- 862
			patch.checkpointSeq or 0, -- 863
			filesJson, -- 864
			t, -- 865
			t -- 866
		}) -- 866
		return -- 869
	end -- 869
	DB:exec( -- 871
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 871
		{ -- 883
			tool, -- 884
			statusPatch, -- 885
			status, -- 886
			reason, -- 887
			reason, -- 888
			reasoningContent, -- 889
			reasoningContent, -- 890
			paramsJson, -- 891
			paramsJson, -- 892
			resultJson, -- 893
			resultJson, -- 894
			patch.checkpointId or 0, -- 895
			patch.checkpointId or 0, -- 896
			patch.checkpointSeq or 0, -- 897
			patch.checkpointSeq or 0, -- 898
			filesJson, -- 899
			filesJson, -- 900
			now(), -- 901
			row[1] -- 902
		} -- 902
	) -- 902
end -- 902
function getNextStepNumber(sessionId, taskId) -- 907
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 908
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 912
	return math.max(0, current) + 1 -- 913
end -- 913
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 916
	if status == nil then -- 916
		status = "DONE" -- 924
	end -- 924
	local step = getNextStepNumber(sessionId, taskId) -- 926
	upsertStep( -- 927
		sessionId, -- 927
		taskId, -- 927
		step, -- 927
		tool, -- 927
		{status = status, reason = reason, params = params, result = result} -- 927
	) -- 927
	return getStepItem(sessionId, taskId, step) -- 933
end -- 933
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 936
	if taskId <= 0 then -- 936
		return -- 937
	end -- 937
	if finalSteps ~= nil and finalSteps >= 0 then -- 937
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 939
	end -- 939
	if not finalStatus then -- 939
		return -- 945
	end -- 945
	if finalSteps ~= nil and finalSteps >= 0 then -- 945
		DB:exec( -- 947
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 947
			{ -- 951
				finalStatus, -- 951
				now(), -- 951
				sessionId, -- 951
				taskId, -- 951
				finalSteps -- 951
			} -- 951
		) -- 951
		return -- 953
	end -- 953
	DB:exec( -- 955
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 955
		{ -- 959
			finalStatus, -- 959
			now(), -- 959
			sessionId, -- 959
			taskId -- 959
		} -- 959
	) -- 959
end -- 959
function emitAgentSessionPatch(sessionId, patch) -- 986
	if HttpServer.wsConnectionCount == 0 then -- 986
		return -- 988
	end -- 988
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 990
	if not text then -- 990
		return -- 995
	end -- 995
	emit("AppWS", "Send", text) -- 996
end -- 996
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 999
	emitAgentSessionPatch( -- 1000
		sessionId, -- 1000
		{ -- 1000
			sessionDeleted = true, -- 1001
			relatedSessions = listRelatedSessions(rootSessionId) -- 1002
		} -- 1002
	) -- 1002
	local rootSession = getSessionItem(rootSessionId) -- 1004
	if rootSession then -- 1004
		emitAgentSessionPatch( -- 1006
			rootSessionId, -- 1006
			{ -- 1006
				session = rootSession, -- 1007
				relatedSessions = listRelatedSessions(rootSessionId) -- 1008
			} -- 1008
		) -- 1008
	end -- 1008
end -- 1008
function flushPendingSubAgentHandoffs(rootSession) -- 1013
	if rootSession.kind ~= "main" then -- 1013
		return -- 1014
	end -- 1014
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1014
		return -- 1016
	end -- 1016
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1018
	if #items == 0 then -- 1018
		return -- 1019
	end -- 1019
	local handoffTaskId = 0 -- 1020
	local ____rootSession_currentTaskId_13 -- 1021
	if rootSession.currentTaskId then -- 1021
		____rootSession_currentTaskId_13 = getTaskPrompt(rootSession.currentTaskId) -- 1021
	else -- 1021
		____rootSession_currentTaskId_13 = nil -- 1021
	end -- 1021
	local currentTaskPrompt = ____rootSession_currentTaskId_13 -- 1021
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1021
		handoffTaskId = rootSession.currentTaskId -- 1029
	else -- 1029
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1031
		if not taskRes.success then -- 1031
			Log( -- 1033
				"Warn", -- 1033
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1033
			) -- 1033
			return -- 1034
		end -- 1034
		handoffTaskId = taskRes.taskId -- 1036
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1037
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1038
		emitAgentSessionPatch( -- 1039
			rootSession.id, -- 1039
			{session = getSessionItem(rootSession.id)} -- 1039
		) -- 1039
	end -- 1039
	do -- 1039
		local i = 0 -- 1043
		while i < #items do -- 1043
			local item = items[i + 1] -- 1044
			local step = appendSystemStep( -- 1045
				rootSession.id, -- 1046
				handoffTaskId, -- 1047
				"sub_agent_handoff", -- 1048
				"sub_agent_handoff", -- 1049
				item.message, -- 1050
				{ -- 1051
					sourceSessionId = item.sourceSessionId, -- 1052
					sourceTitle = item.sourceTitle, -- 1053
					sourceTaskId = item.sourceTaskId, -- 1054
					success = item.success == true, -- 1055
					summary = item.message, -- 1056
					resultFilePath = item.resultFilePath or "", -- 1057
					artifactDir = item.artifactDir or "", -- 1058
					finishedAt = item.finishedAt or "" -- 1059
				}, -- 1059
				{ -- 1061
					sourceSessionId = item.sourceSessionId, -- 1062
					sourceTitle = item.sourceTitle, -- 1063
					prompt = item.prompt, -- 1064
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1065
					expectedOutput = item.expectedOutput or "", -- 1066
					filesHint = item.filesHint or ({}), -- 1067
					resultFilePath = item.resultFilePath or "", -- 1068
					artifactDir = item.artifactDir or "" -- 1069
				}, -- 1069
				"DONE" -- 1071
			) -- 1071
			if step then -- 1071
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1074
			end -- 1074
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1076
			i = i + 1 -- 1043
		end -- 1043
	end -- 1043
end -- 1043
function applyEvent(sessionId, event) -- 1080
	repeat -- 1080
		local ____switch168 = event.type -- 1080
		local ____cond168 = ____switch168 == "task_started" -- 1080
		if ____cond168 then -- 1080
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1083
			emitAgentSessionPatch( -- 1084
				sessionId, -- 1084
				{session = getSessionItem(sessionId)} -- 1084
			) -- 1084
			break -- 1087
		end -- 1087
		____cond168 = ____cond168 or ____switch168 == "decision_made" -- 1087
		if ____cond168 then -- 1087
			upsertStep( -- 1089
				sessionId, -- 1089
				event.taskId, -- 1089
				event.step, -- 1089
				event.tool, -- 1089
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1089
			) -- 1089
			emitAgentSessionPatch( -- 1095
				sessionId, -- 1095
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1095
			) -- 1095
			break -- 1098
		end -- 1098
		____cond168 = ____cond168 or ____switch168 == "tool_started" -- 1098
		if ____cond168 then -- 1098
			upsertStep( -- 1100
				sessionId, -- 1100
				event.taskId, -- 1100
				event.step, -- 1100
				event.tool, -- 1100
				{status = "RUNNING"} -- 1100
			) -- 1100
			emitAgentSessionPatch( -- 1103
				sessionId, -- 1103
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1103
			) -- 1103
			break -- 1106
		end -- 1106
		____cond168 = ____cond168 or ____switch168 == "tool_finished" -- 1106
		if ____cond168 then -- 1106
			upsertStep( -- 1108
				sessionId, -- 1108
				event.taskId, -- 1108
				event.step, -- 1108
				event.tool, -- 1108
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1108
			) -- 1108
			emitAgentSessionPatch( -- 1113
				sessionId, -- 1113
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1113
			) -- 1113
			break -- 1116
		end -- 1116
		____cond168 = ____cond168 or ____switch168 == "checkpoint_created" -- 1116
		if ____cond168 then -- 1116
			upsertStep( -- 1118
				sessionId, -- 1118
				event.taskId, -- 1118
				event.step, -- 1118
				event.tool, -- 1118
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1118
			) -- 1118
			emitAgentSessionPatch( -- 1123
				sessionId, -- 1123
				{ -- 1123
					step = getStepItem(sessionId, event.taskId, event.step), -- 1124
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1125
				} -- 1125
			) -- 1125
			break -- 1127
		end -- 1127
		____cond168 = ____cond168 or ____switch168 == "memory_compression_started" -- 1127
		if ____cond168 then -- 1127
			upsertStep( -- 1129
				sessionId, -- 1129
				event.taskId, -- 1129
				event.step, -- 1129
				event.tool, -- 1129
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1129
			) -- 1129
			emitAgentSessionPatch( -- 1134
				sessionId, -- 1134
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1134
			) -- 1134
			break -- 1137
		end -- 1137
		____cond168 = ____cond168 or ____switch168 == "memory_compression_finished" -- 1137
		if ____cond168 then -- 1137
			upsertStep( -- 1139
				sessionId, -- 1139
				event.taskId, -- 1139
				event.step, -- 1139
				event.tool, -- 1139
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1139
			) -- 1139
			emitAgentSessionPatch( -- 1144
				sessionId, -- 1144
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1144
			) -- 1144
			break -- 1147
		end -- 1147
		____cond168 = ____cond168 or ____switch168 == "assistant_message_updated" -- 1147
		if ____cond168 then -- 1147
			do -- 1147
				upsertStep( -- 1149
					sessionId, -- 1149
					event.taskId, -- 1149
					event.step, -- 1149
					"message", -- 1149
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1149
				) -- 1149
				emitAgentSessionPatch( -- 1154
					sessionId, -- 1154
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1154
				) -- 1154
				break -- 1157
			end -- 1157
		end -- 1157
		____cond168 = ____cond168 or ____switch168 == "task_finished" -- 1157
		if ____cond168 then -- 1157
			do -- 1157
				local ____opt_14 = activeStopTokens[event.taskId or -1] -- 1157
				local stopped = (____opt_14 and ____opt_14.stopped) == true -- 1160
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1161
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 1164
				if event.taskId ~= nil then -- 1164
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1166
					local ____finalizeTaskSteps_18 = finalizeTaskSteps -- 1167
					local ____array_17 = __TS__SparseArrayNew( -- 1167
						sessionId, -- 1168
						event.taskId, -- 1169
						type(event.steps) == "number" and math.max( -- 1170
							0, -- 1170
							math.floor(event.steps) -- 1170
						) or nil -- 1170
					) -- 1170
					local ____event_success_16 -- 1171
					if event.success then -- 1171
						____event_success_16 = nil -- 1171
					else -- 1171
						____event_success_16 = stopped and "STOPPED" or "FAILED" -- 1171
					end -- 1171
					__TS__SparseArrayPush(____array_17, ____event_success_16) -- 1171
					____finalizeTaskSteps_18(__TS__SparseArraySpread(____array_17)) -- 1167
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1173
					activeStopTokens[event.taskId] = nil -- 1174
					emitAgentSessionPatch( -- 1175
						sessionId, -- 1175
						{ -- 1175
							session = getSessionItem(sessionId), -- 1176
							message = getMessageItem(messageId), -- 1177
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1178
							removedStepIds = removedStepIds -- 1179
						} -- 1179
					) -- 1179
				end -- 1179
				local session = getSessionItem(sessionId) -- 1182
				if session and session.kind == "main" then -- 1182
					flushPendingSubAgentHandoffs(session) -- 1184
				end -- 1184
				break -- 1186
			end -- 1186
		end -- 1186
	until true -- 1186
end -- 1186
function ____exports.createSession(projectRoot, title) -- 1303
	if title == nil then -- 1303
		title = "" -- 1303
	end -- 1303
	if not isValidProjectRoot(projectRoot) then -- 1303
		return {success = false, message = "invalid projectRoot"} -- 1305
	end -- 1305
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1307
	if row then -- 1307
		return { -- 1316
			success = true, -- 1316
			session = rowToSession(row) -- 1316
		} -- 1316
	end -- 1316
	local t = now() -- 1318
	DB:exec( -- 1319
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1319
		{ -- 1322
			projectRoot, -- 1322
			title ~= "" and title or Path:getFilename(projectRoot), -- 1322
			t, -- 1322
			t -- 1322
		} -- 1322
	) -- 1322
	local sessionId = getLastInsertRowId() -- 1324
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1325
	local session = getSessionItem(sessionId) -- 1326
	if not session then -- 1326
		return {success = false, message = "failed to create session"} -- 1328
	end -- 1328
	return {success = true, session = session} -- 1330
end -- 1303
function ____exports.createSubSession(parentSessionId, title) -- 1333
	if title == nil then -- 1333
		title = "" -- 1333
	end -- 1333
	local parent = getSessionItem(parentSessionId) -- 1334
	if not parent then -- 1334
		return {success = false, message = "parent session not found"} -- 1336
	end -- 1336
	local rootId = getSessionRootId(parent) -- 1338
	local t = now() -- 1339
	DB:exec( -- 1340
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1340
		{ -- 1343
			parent.projectRoot, -- 1343
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1343
			rootId, -- 1343
			parent.id, -- 1343
			t, -- 1343
			t -- 1343
		} -- 1343
	) -- 1343
	local sessionId = getLastInsertRowId() -- 1345
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1346
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1347
	local session = getSessionItem(sessionId) -- 1348
	if not session then -- 1348
		return {success = false, message = "failed to create sub session"} -- 1350
	end -- 1350
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1352
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1353
	subStorage:writeMemory(parentStorage:readMemory()) -- 1354
	return {success = true, session = session} -- 1355
end -- 1333
function spawnSubAgentSession(request) -- 1358
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1358
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1369
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1370
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1371
		if normalizedPrompt == "" then -- 1371
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1373
		end -- 1373
		if normalizedPrompt == "" then -- 1373
			local ____Log_24 = Log -- 1380
			local ____temp_21 = #normalizedTitle -- 1380
			local ____temp_22 = #rawPrompt -- 1380
			local ____temp_23 = #toStr(request.expectedOutput) -- 1380
			local ____opt_19 = request.filesHint -- 1380
			____Log_24( -- 1380
				"Warn", -- 1380
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_21)) .. " raw_prompt_len=") .. tostring(____temp_22)) .. " expected_len=") .. tostring(____temp_23)) .. " files_hint_count=") .. tostring(____opt_19 and #____opt_19 or 0) -- 1380
			) -- 1380
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1380
		end -- 1380
		Log( -- 1383
			"Info", -- 1383
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1383
		) -- 1383
		local parentSessionId = request.parentSessionId -- 1384
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1384
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1386
			if not fallbackParent then -- 1386
				local createdMain = ____exports.createSession(request.projectRoot) -- 1388
				if createdMain.success then -- 1388
					fallbackParent = createdMain.session -- 1390
				end -- 1390
			end -- 1390
			if fallbackParent then -- 1390
				Log( -- 1394
					"Warn", -- 1394
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1394
				) -- 1394
				parentSessionId = fallbackParent.id -- 1395
			end -- 1395
		end -- 1395
		local parentSession = getSessionItem(parentSessionId) -- 1398
		if not parentSession then -- 1398
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1398
		end -- 1398
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1402
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1402
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1402
		end -- 1402
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1406
		if not created.success then -- 1406
			return ____awaiter_resolve(nil, created) -- 1406
		end -- 1406
		writeSpawnInfo( -- 1410
			created.session.projectRoot, -- 1410
			created.session.memoryScope, -- 1410
			{ -- 1410
				sessionId = created.session.id, -- 1411
				rootSessionId = created.session.rootSessionId, -- 1412
				parentSessionId = created.session.parentSessionId, -- 1413
				title = created.session.title, -- 1414
				prompt = normalizedPrompt, -- 1415
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1416
				expectedOutput = request.expectedOutput or "", -- 1417
				filesHint = request.filesHint or ({}), -- 1418
				status = "RUNNING", -- 1419
				success = false, -- 1420
				resultFilePath = "", -- 1421
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1422
				sourceTaskId = 0, -- 1423
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1424
				createdAtTs = created.session.createdAt, -- 1425
				finishedAt = "", -- 1426
				finishedAtTs = 0 -- 1427
			} -- 1427
		) -- 1427
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1429
		if not sent.success then -- 1429
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1429
		end -- 1429
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1429
	end) -- 1429
end -- 1429
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 1509
	local rootSession = getRootSessionItem(session.id) -- 1510
	if not rootSession then -- 1510
		return -- 1511
	end -- 1511
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1512
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1513
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1514
	local queueResult = writePendingHandoff( -- 1515
		rootSession.projectRoot, -- 1515
		rootSession.memoryScope, -- 1515
		{ -- 1515
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1516
			sourceSessionId = session.id, -- 1517
			sourceTitle = session.title, -- 1518
			sourceTaskId = taskId, -- 1519
			message = summary, -- 1520
			prompt = result.prompt, -- 1521
			goal = result.goal, -- 1522
			expectedOutput = result.expectedOutput or "", -- 1523
			filesHint = result.filesHint or ({}), -- 1524
			success = result.success, -- 1525
			resultFilePath = result.resultFilePath, -- 1526
			artifactDir = result.artifactDir, -- 1527
			finishedAt = result.finishedAt, -- 1528
			createdAt = createdAt -- 1529
		} -- 1529
	) -- 1529
	if not queueResult then -- 1529
		Log( -- 1532
			"Warn", -- 1532
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1532
		) -- 1532
		return -- 1533
	end -- 1533
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1533
		flushPendingSubAgentHandoffs(rootSession) -- 1536
	end -- 1536
end -- 1536
function finalizeSubSession(session, taskId, success, message) -- 1540
	local rootSessionId = getSessionRootId(session) -- 1541
	local rootSession = getRootSessionItem(session.id) -- 1542
	if not rootSession then -- 1542
		return {success = false, message = "root session not found"} -- 1544
	end -- 1544
	local spawnInfo = getSessionSpawnInfo(session) -- 1546
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1547
	local finishedAtTs = now() -- 1548
	local resultText = sanitizeUTF8(message) -- 1549
	local record = { -- 1550
		sessionId = session.id, -- 1551
		rootSessionId = rootSessionId, -- 1552
		parentSessionId = session.parentSessionId, -- 1553
		title = session.title, -- 1554
		prompt = spawnInfo and spawnInfo.prompt or "", -- 1555
		goal = spawnInfo and spawnInfo.goal or session.title, -- 1556
		expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 1557
		filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 1558
		status = success and "DONE" or "FAILED", -- 1559
		success = success, -- 1560
		resultFilePath = getResultRelativePath(session.memoryScope), -- 1561
		artifactDir = getArtifactRelativeDir(session.memoryScope), -- 1562
		sourceTaskId = taskId, -- 1563
		createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 1564
		finishedAt = finishedAt, -- 1565
		createdAtTs = session.createdAt, -- 1566
		finishedAtTs = finishedAtTs -- 1567
	} -- 1567
	if not writeSubAgentResultFile(session, record, resultText) then -- 1567
		return {success = false, message = "failed to persist sub session result file"} -- 1570
	end -- 1570
	if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 1570
		sessionId = record.sessionId, -- 1573
		rootSessionId = record.rootSessionId, -- 1574
		parentSessionId = record.parentSessionId, -- 1575
		title = record.title, -- 1576
		prompt = record.prompt, -- 1577
		goal = record.goal, -- 1578
		expectedOutput = record.expectedOutput or "", -- 1579
		filesHint = record.filesHint or ({}), -- 1580
		status = record.status, -- 1581
		success = record.success, -- 1582
		resultFilePath = record.resultFilePath, -- 1583
		artifactDir = record.artifactDir, -- 1584
		sourceTaskId = record.sourceTaskId, -- 1585
		createdAt = record.createdAt, -- 1586
		finishedAt = record.finishedAt, -- 1587
		createdAtTs = record.createdAtTs, -- 1588
		finishedAtTs = record.finishedAtTs -- 1589
	}) then -- 1589
		return {success = false, message = "failed to persist sub session spawn info"} -- 1591
	end -- 1591
	if success then -- 1591
		appendSubAgentHandoffStep(session, taskId, record, resultText) -- 1594
		deleteSessionRecords(session.id, true) -- 1595
		emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 1596
	end -- 1596
	return {success = true} -- 1598
end -- 1598
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 1601
	if allowSubSessionStart == nil then -- 1601
		allowSubSessionStart = false -- 1601
	end -- 1601
	local session = getSessionItem(sessionId) -- 1602
	if not session then -- 1602
		return {success = false, message = "session not found"} -- 1604
	end -- 1604
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 1604
		return {success = false, message = "session task is still running"} -- 1607
	end -- 1607
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 1609
	if normalizedPrompt == "" and session.kind == "sub" then -- 1609
		local spawnInfo = getSessionSpawnInfo(session) -- 1611
		if spawnInfo then -- 1611
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 1613
			if normalizedPrompt == "" then -- 1613
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 1615
			end -- 1615
		end -- 1615
	end -- 1615
	if normalizedPrompt == "" then -- 1615
		return {success = false, message = "prompt is empty"} -- 1624
	end -- 1624
	local taskRes = Tools.createTask(normalizedPrompt) -- 1626
	if not taskRes.success then -- 1626
		return {success = false, message = taskRes.message} -- 1628
	end -- 1628
	local taskId = taskRes.taskId -- 1630
	local useChineseResponse = getDefaultUseChineseResponse() -- 1631
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 1632
	local stopToken = {stopped = false} -- 1633
	activeStopTokens[taskId] = stopToken -- 1634
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 1635
	runCodingAgent( -- 1636
		{ -- 1636
			prompt = normalizedPrompt, -- 1637
			workDir = session.projectRoot, -- 1638
			useChineseResponse = useChineseResponse, -- 1639
			taskId = taskId, -- 1640
			sessionId = sessionId, -- 1641
			memoryScope = session.memoryScope, -- 1642
			role = session.kind, -- 1643
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 1644
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 1647
			stopToken = stopToken, -- 1650
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 1651
		}, -- 1651
		function(result) -- 1652
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1652
				local nextSession = getSessionItem(sessionId) -- 1653
				if nextSession and nextSession.kind == "sub" then -- 1653
					local finalized = finalizeSubSession(nextSession, taskId, result.success, result.message) -- 1655
					if not finalized.success then -- 1655
						Log( -- 1657
							"Warn", -- 1657
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 1657
						) -- 1657
					end -- 1657
				end -- 1657
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 1657
					applyEvent(sessionId, { -- 1661
						type = "task_finished", -- 1662
						sessionId = sessionId, -- 1663
						taskId = result.taskId, -- 1664
						success = false, -- 1665
						message = result.message, -- 1666
						steps = result.steps -- 1667
					}) -- 1667
				end -- 1667
			end) -- 1667
		end -- 1652
	) -- 1652
	return {success = true, sessionId = sessionId, taskId = taskId} -- 1671
end -- 1601
function ____exports.listRunningSubAgents(request) -- 1718
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1718
		local session = getSessionItem(request.sessionId) -- 1726
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 1726
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1728
		end -- 1728
		if not session then -- 1728
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 1728
		end -- 1728
		local rootSession = getRootSessionItem(session.id) -- 1733
		if not rootSession then -- 1733
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 1733
		end -- 1733
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 1737
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 1738
		local limit = math.max( -- 1739
			1, -- 1739
			math.floor(tonumber(request.limit) or 5) -- 1739
		) -- 1739
		local offset = math.max( -- 1740
			0, -- 1740
			math.floor(tonumber(request.offset) or 0) -- 1740
		) -- 1740
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 1741
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 1742
		local runningSessions = {} -- 1749
		do -- 1749
			local i = 0 -- 1750
			while i < #rows do -- 1750
				do -- 1750
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1751
					if current.currentTaskStatus ~= "RUNNING" then -- 1751
						goto __continue247 -- 1753
					end -- 1753
					local spawnInfo = getSessionSpawnInfo(current) -- 1755
					runningSessions[#runningSessions + 1] = { -- 1756
						sessionId = current.id, -- 1757
						title = current.title, -- 1758
						parentSessionId = current.parentSessionId, -- 1759
						rootSessionId = current.rootSessionId, -- 1760
						status = "RUNNING", -- 1761
						currentTaskId = current.currentTaskId, -- 1762
						currentTaskStatus = current.currentTaskStatus or current.status, -- 1763
						goal = spawnInfo and spawnInfo.goal, -- 1764
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 1765
						filesHint = spawnInfo and spawnInfo.filesHint, -- 1766
						createdAt = current.createdAt, -- 1767
						updatedAt = current.updatedAt -- 1768
					} -- 1768
				end -- 1768
				::__continue247:: -- 1768
				i = i + 1 -- 1750
			end -- 1750
		end -- 1750
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 1771
		local completedSessions = __TS__ArrayMap( -- 1772
			completedRecords, -- 1772
			function(____, record) return { -- 1772
				sessionId = record.sessionId, -- 1773
				title = record.title, -- 1774
				parentSessionId = record.parentSessionId, -- 1775
				rootSessionId = record.rootSessionId, -- 1776
				status = record.status, -- 1777
				goal = record.goal, -- 1778
				expectedOutput = record.expectedOutput, -- 1779
				filesHint = record.filesHint, -- 1780
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 1781
				success = record.success, -- 1782
				resultFilePath = record.resultFilePath, -- 1783
				artifactDir = record.artifactDir, -- 1784
				finishedAt = record.finishedAt, -- 1785
				createdAt = record.createdAtTs, -- 1786
				updatedAt = record.finishedAtTs -- 1787
			} end -- 1787
		) -- 1787
		local merged = {} -- 1789
		if status == "running" then -- 1789
			merged = runningSessions -- 1791
		elseif status == "done" then -- 1791
			merged = __TS__ArrayFilter( -- 1793
				completedSessions, -- 1793
				function(____, item) return item.status == "DONE" end -- 1793
			) -- 1793
		elseif status == "failed" then -- 1793
			merged = __TS__ArrayFilter( -- 1795
				completedSessions, -- 1795
				function(____, item) return item.status == "FAILED" end -- 1795
			) -- 1795
		elseif status == "all" then -- 1795
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 1797
		else -- 1797
			local runningKeys = {} -- 1799
			do -- 1799
				local i = 0 -- 1800
				while i < #runningSessions do -- 1800
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 1801
					i = i + 1 -- 1800
				end -- 1800
			end -- 1800
			local latestCompletedByKey = {} -- 1803
			do -- 1803
				local i = 0 -- 1804
				while i < #completedSessions do -- 1804
					do -- 1804
						local item = completedSessions[i + 1] -- 1805
						local key = getSubAgentDisplayKey(item) -- 1806
						if runningKeys[key] then -- 1806
							goto __continue260 -- 1808
						end -- 1808
						local current = latestCompletedByKey[key] -- 1810
						if not current or item.updatedAt > current.updatedAt then -- 1810
							latestCompletedByKey[key] = item -- 1812
						end -- 1812
					end -- 1812
					::__continue260:: -- 1812
					i = i + 1 -- 1804
				end -- 1804
			end -- 1804
			local latestCompleted = {} -- 1815
			for ____, item in pairs(latestCompletedByKey) do -- 1816
				latestCompleted[#latestCompleted + 1] = item -- 1817
			end -- 1817
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 1819
		end -- 1819
		if query ~= "" then -- 1819
			merged = __TS__ArrayFilter( -- 1822
				merged, -- 1822
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 1822
			) -- 1822
		end -- 1822
		__TS__ArraySort( -- 1828
			merged, -- 1828
			function(____, a, b) -- 1828
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 1828
					return -1 -- 1829
				end -- 1829
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 1829
					return 1 -- 1830
				end -- 1830
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 1830
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 1832
				end -- 1832
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 1834
			end -- 1828
		) -- 1828
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 1836
		return ____awaiter_resolve(nil, { -- 1836
			success = true, -- 1838
			rootSessionId = rootSession.id, -- 1839
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 1840
			status = status, -- 1841
			limit = limit, -- 1842
			offset = offset, -- 1843
			hasMore = offset + limit < #merged, -- 1844
			sessions = paged -- 1845
		}) -- 1845
	end) -- 1845
end -- 1718
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
local function sanitizeStoredSteps(sessionId) -- 963
	DB:exec( -- 964
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 964
		{ -- 982
			now(), -- 982
			sessionId -- 982
		} -- 982
	) -- 982
end -- 963
local function getSchemaVersion() -- 1191
	local row = queryOne("PRAGMA user_version") -- 1192
	return row and type(row[1]) == "number" and row[1] or 0 -- 1193
end -- 1191
local function setSchemaVersion(version) -- 1196
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1197
		0, -- 1197
		math.floor(version) -- 1197
	))) -- 1197
end -- 1196
local function recreateSchema() -- 1200
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1201
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1202
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1203
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1204
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1218
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1219
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1228
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1229
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1246
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1247
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1248
end -- 1200
do -- 1200
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1200
		recreateSchema() -- 1254
	else -- 1254
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1256
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1270
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1271
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1280
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1281
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1298
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1299
	end -- 1299
end -- 1299
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1441
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1441
		return {success = false, message = "invalid projectRoot"} -- 1443
	end -- 1443
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1445
	for ____, row in ipairs(rows) do -- 1446
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1447
		if sessionId > 0 then -- 1447
			deleteSessionRecords(sessionId) -- 1449
		end -- 1449
	end -- 1449
	return {success = true, deleted = #rows} -- 1452
end -- 1441
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1455
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1455
		return {success = false, message = "invalid projectRoot"} -- 1457
	end -- 1457
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1459
	local renamed = 0 -- 1460
	for ____, row in ipairs(rows) do -- 1461
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1462
		local projectRoot = toStr(row[2]) -- 1463
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1464
		if sessionId > 0 and nextProjectRoot then -- 1464
			DB:exec( -- 1466
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1466
				{ -- 1468
					nextProjectRoot, -- 1468
					Path:getFilename(nextProjectRoot), -- 1468
					now(), -- 1468
					sessionId -- 1468
				} -- 1468
			) -- 1468
			renamed = renamed + 1 -- 1470
		end -- 1470
	end -- 1470
	return {success = true, renamed = renamed} -- 1473
end -- 1455
function ____exports.getSession(sessionId) -- 1476
	local session = getSessionItem(sessionId) -- 1477
	if not session then -- 1477
		return {success = false, message = "session not found"} -- 1479
	end -- 1479
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1481
	local relatedSessions = listRelatedSessions(sessionId) -- 1482
	sanitizeStoredSteps(sessionId) -- 1483
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1484
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1491
	local ____relatedSessions_26 = relatedSessions -- 1502
	local ____temp_25 -- 1503
	if normalizedSession.kind == "sub" then -- 1503
		____temp_25 = getSessionSpawnInfo(normalizedSession) -- 1503
	else -- 1503
		____temp_25 = nil -- 1503
	end -- 1503
	return { -- 1499
		success = true, -- 1500
		session = normalizedSession, -- 1501
		relatedSessions = ____relatedSessions_26, -- 1502
		spawnInfo = ____temp_25, -- 1503
		messages = __TS__ArrayMap( -- 1504
			messages, -- 1504
			function(____, row) return rowToMessage(row) end -- 1504
		), -- 1504
		steps = __TS__ArrayMap( -- 1505
			steps, -- 1505
			function(____, row) return rowToStep(row) end -- 1505
		) -- 1505
	} -- 1505
end -- 1476
function ____exports.stopSessionTask(sessionId) -- 1674
	local session = getSessionItem(sessionId) -- 1675
	if not session or session.currentTaskId == nil then -- 1675
		return {success = false, message = "session task not found"} -- 1677
	end -- 1677
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1679
	local stopToken = activeStopTokens[session.currentTaskId] -- 1680
	if not stopToken then -- 1680
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 1680
			return {success = true, recovered = true} -- 1683
		end -- 1683
		return {success = false, message = "task is not running"} -- 1685
	end -- 1685
	stopToken.stopped = true -- 1687
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 1688
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1689
	return {success = true} -- 1690
end -- 1674
function ____exports.getCurrentTaskId(sessionId) -- 1693
	local ____opt_37 = getSessionItem(sessionId) -- 1693
	return ____opt_37 and ____opt_37.currentTaskId -- 1694
end -- 1693
function ____exports.listRunningSessions() -- 1697
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 1698
	local sessions = {} -- 1705
	do -- 1705
		local i = 0 -- 1706
		while i < #rows do -- 1706
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1707
			if session.currentTaskStatus == "RUNNING" then -- 1707
				sessions[#sessions + 1] = session -- 1709
			end -- 1709
			i = i + 1 -- 1706
		end -- 1706
	end -- 1706
	return {success = true, sessions = sessions} -- 1712
end -- 1697
return ____exports -- 1697