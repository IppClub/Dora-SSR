-- [ts]: AgentSession.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildSubAgentMemoryEntryLLMOptions, buildSubAgentMemoryEntryToolSchema, buildSubAgentMemoryEntrySystemPrompt, formatSubAgentMemoryTailMessage, buildSubAgentRecentMessageTail, buildSubAgentMemoryEntryPrompt, buildSubAgentMemoryEntryRetryPrompt, normalizeGeneratedSubAgentMemoryEntry, getMemoryEntryToolFunction, getMemoryEntryPlainContent, decodeMemoryEntryFromPlainContent, hasEmptyMemoryEntryContent, generateSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, setSessionStateForTaskEvent, insertMessage, updateMessage, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS, SUB_AGENT_MEMORY_RESULT_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
local callLLM = ____Utils.callLLM -- 6
local clipTextToTokenBudget = ____Utils.clipTextToTokenBudget -- 6
local estimateTextTokens = ____Utils.estimateTextTokens -- 6
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 6
local safeJsonDecode = ____Utils.safeJsonDecode -- 6
local safeJsonEncode = ____Utils.safeJsonEncode -- 6
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 6
function getDefaultUseChineseResponse() -- 260
	local zh = string.match(App.locale, "^zh") -- 261
	return zh ~= nil -- 262
end -- 262
function toStr(v) -- 265
	if v == false or v == nil or v == nil then -- 265
		return "" -- 266
	end -- 266
	return tostring(v) -- 267
end -- 267
function encodeJson(value) -- 270
	local text = safeJsonEncode(value) -- 271
	return text or "" -- 272
end -- 272
function decodeJsonObject(text) -- 275
	if not text or text == "" then -- 275
		return nil -- 276
	end -- 276
	local value = safeJsonDecode(text) -- 277
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 277
		return value -- 279
	end -- 279
	return nil -- 281
end -- 281
function decodeJsonFiles(text) -- 284
	if not text or text == "" then -- 284
		return nil -- 285
	end -- 285
	local value = safeJsonDecode(text) -- 286
	if not value or not __TS__ArrayIsArray(value) then -- 286
		return nil -- 287
	end -- 287
	local files = {} -- 288
	do -- 288
		local i = 0 -- 289
		while i < #value do -- 289
			do -- 289
				local item = value[i + 1] -- 290
				if type(item) ~= "table" then -- 290
					goto __continue14 -- 291
				end -- 291
				files[#files + 1] = { -- 292
					path = sanitizeUTF8(toStr(item.path)), -- 293
					op = sanitizeUTF8(toStr(item.op)) -- 294
				} -- 294
			end -- 294
			::__continue14:: -- 294
			i = i + 1 -- 289
		end -- 289
	end -- 289
	return files -- 297
end -- 297
function decodeChangeSetSummary(value) -- 300
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 300
		return nil -- 301
	end -- 301
	local row = value -- 302
	if row.success ~= true then -- 302
		return nil -- 303
	end -- 303
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 304
	if taskId <= 0 then -- 304
		return nil -- 305
	end -- 305
	local files = {} -- 306
	if __TS__ArrayIsArray(row.files) then -- 306
		do -- 306
			local i = 0 -- 308
			while i < #row.files do -- 308
				do -- 308
					local file = row.files[i + 1] -- 309
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 309
						goto __continue22 -- 310
					end -- 310
					local fileRow = file -- 311
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 312
					if path == "" then -- 312
						goto __continue22 -- 313
					end -- 313
					local checkpointIds = {} -- 314
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 314
						do -- 314
							local j = 0 -- 316
							while j < #fileRow.checkpointIds do -- 316
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 317
								if checkpointId > 0 then -- 317
									checkpointIds[#checkpointIds + 1] = checkpointId -- 318
								end -- 318
								j = j + 1 -- 316
							end -- 316
						end -- 316
					end -- 316
					local op = toStr(fileRow.op) -- 321
					files[#files + 1] = { -- 322
						path = path, -- 323
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 324
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 325
						checkpointIds = checkpointIds -- 326
					} -- 326
				end -- 326
				::__continue22:: -- 326
				i = i + 1 -- 308
			end -- 308
		end -- 308
	end -- 308
	return { -- 330
		success = true, -- 331
		taskId = taskId, -- 332
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 333
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 334
		files = files, -- 335
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 336
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 337
	} -- 337
end -- 337
function takeUtf8Head(text, maxChars) -- 341
	if maxChars <= 0 or text == "" then -- 341
		return "" -- 342
	end -- 342
	local nextPos = utf8.offset(text, maxChars + 1) -- 343
	if nextPos == nil then -- 343
		return text -- 344
	end -- 344
	return string.sub(text, 1, nextPos - 1) -- 345
end -- 345
function normalizeMemoryEntryEvidence(value) -- 348
	local evidence = {} -- 349
	if not __TS__ArrayIsArray(value) then -- 349
		return evidence -- 350
	end -- 350
	do -- 350
		local i = 0 -- 351
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 351
			do -- 351
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 352
				if item == "" then -- 352
					goto __continue35 -- 353
				end -- 353
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 353
					evidence[#evidence + 1] = item -- 355
				end -- 355
			end -- 355
			::__continue35:: -- 355
			i = i + 1 -- 351
		end -- 351
	end -- 351
	return evidence -- 358
end -- 358
function decodeSubAgentMemoryEntry(value) -- 361
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 361
		return nil -- 362
	end -- 362
	local row = value -- 363
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 364
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 365
	local content = takeUtf8Head( -- 366
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 366
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 366
	) -- 366
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 366
		return nil -- 367
	end -- 367
	return { -- 368
		sourceSessionId = sourceSessionId, -- 369
		sourceTaskId = sourceTaskId, -- 370
		content = content, -- 371
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 372
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 373
	} -- 373
end -- 373
function getTaskChangeSetSummary(taskId) -- 377
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 378
	return summary.success and summary or nil -- 379
end -- 379
function queryRows(sql, args) -- 382
	local ____args_0 -- 383
	if args then -- 383
		____args_0 = DB:query(sql, args) -- 383
	else -- 383
		____args_0 = DB:query(sql) -- 383
	end -- 383
	return ____args_0 -- 383
end -- 383
function queryOne(sql, args) -- 386
	local rows = queryRows(sql, args) -- 387
	if not rows or #rows == 0 then -- 387
		return nil -- 388
	end -- 388
	return rows[1] -- 389
end -- 389
function getLastInsertRowId() -- 392
	local row = queryOne("SELECT last_insert_rowid()") -- 393
	return row and (row[1] or 0) or 0 -- 394
end -- 394
function isValidProjectRoot(path) -- 397
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 398
end -- 398
function rowToSession(row) -- 401
	return { -- 402
		id = row[1], -- 403
		projectRoot = toStr(row[2]), -- 404
		title = toStr(row[3]), -- 405
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 406
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 407
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 408
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 409
		status = toStr(row[8]), -- 410
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 411
		currentTaskStatus = toStr(row[10]), -- 412
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 413
		createdAt = row[11], -- 414
		updatedAt = row[12], -- 415
		metrics = decodeJsonObject(toStr(row[13])) -- 416
	} -- 416
end -- 416
function rowToMessage(row) -- 420
	return { -- 421
		id = row[1], -- 422
		sessionId = row[2], -- 423
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 424
		role = toStr(row[4]), -- 425
		content = toStr(row[5]), -- 426
		createdAt = row[6], -- 427
		updatedAt = row[7] -- 428
	} -- 428
end -- 428
function rowToStep(row) -- 432
	return { -- 433
		id = row[1], -- 434
		sessionId = row[2], -- 435
		taskId = row[3], -- 436
		step = row[4], -- 437
		tool = toStr(row[5]), -- 438
		status = toStr(row[6]), -- 439
		reason = toStr(row[7]), -- 440
		reasoningContent = toStr(row[8]), -- 441
		params = decodeJsonObject(toStr(row[9])), -- 442
		result = decodeJsonObject(toStr(row[10])), -- 443
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 444
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 445
		files = decodeJsonFiles(toStr(row[13])), -- 446
		createdAt = row[14], -- 447
		updatedAt = row[15] -- 448
	} -- 448
end -- 448
function getMessageItem(messageId) -- 452
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 453
	return row and rowToMessage(row) or nil -- 459
end -- 459
function getStepItem(sessionId, taskId, step) -- 462
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 463
	return row and rowToStep(row) or nil -- 469
end -- 469
function deleteMessageSteps(sessionId, taskId) -- 472
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 473
	local ids = {} -- 478
	do -- 478
		local i = 0 -- 479
		while i < #rows do -- 479
			local row = rows[i + 1] -- 480
			if type(row[1]) == "number" then -- 480
				ids[#ids + 1] = row[1] -- 482
			end -- 482
			i = i + 1 -- 479
		end -- 479
	end -- 479
	if #ids > 0 then -- 479
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 486
	end -- 486
	return ids -- 492
end -- 492
function getSessionRow(sessionId) -- 495
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 496
end -- 496
function getSessionItem(sessionId) -- 504
	local row = getSessionRow(sessionId) -- 505
	return row and rowToSession(row) or nil -- 506
end -- 506
function getTaskPrompt(taskId) -- 509
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 510
	if not row or type(row[1]) ~= "string" then -- 510
		return nil -- 511
	end -- 511
	return toStr(row[1]) -- 512
end -- 512
function getLatestMainSessionByProjectRoot(projectRoot) -- 515
	if not isValidProjectRoot(projectRoot) then -- 515
		return nil -- 516
	end -- 516
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 517
	return row and rowToSession(row) or nil -- 525
end -- 525
function countRunningSubSessions(rootSessionId) -- 528
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 529
	local count = 0 -- 536
	do -- 536
		local i = 0 -- 537
		while i < #rows do -- 537
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 538
			if session.currentTaskStatus == "RUNNING" then -- 538
				count = count + 1 -- 540
			end -- 540
			i = i + 1 -- 537
		end -- 537
	end -- 537
	return count -- 543
end -- 543
function deleteSessionRecords(sessionId, preserveArtifacts) -- 546
	if preserveArtifacts == nil then -- 546
		preserveArtifacts = false -- 546
	end -- 546
	local session = getSessionItem(sessionId) -- 547
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 548
	do -- 548
		local i = 0 -- 549
		while i < #children do -- 549
			local row = children[i + 1] -- 550
			if type(row[1]) == "number" and row[1] > 0 then -- 550
				deleteSessionRecords(row[1], preserveArtifacts) -- 552
			end -- 552
			i = i + 1 -- 549
		end -- 549
	end -- 549
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 555
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 556
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 557
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 558
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 558
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 560
	end -- 560
end -- 560
function getSessionRootId(session) -- 564
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 565
end -- 565
function getRootSessionItem(sessionId) -- 568
	local session = getSessionItem(sessionId) -- 569
	if not session then -- 569
		return nil -- 570
	end -- 570
	return getSessionItem(getSessionRootId(session)) or session -- 571
end -- 571
function listRelatedSessions(sessionId) -- 574
	local root = getRootSessionItem(sessionId) -- 575
	if not root then -- 575
		return {} -- 576
	end -- 576
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 577
	return __TS__ArrayMap( -- 586
		rows, -- 586
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 586
	) -- 586
end -- 586
function getSessionSpawnInfo(session) -- 589
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 590
	if not info then -- 590
		return nil -- 591
	end -- 591
	local ____temp_4 = type(info.sessionId) == "number" and info.sessionId or nil -- 593
	local ____temp_5 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 594
	local ____temp_6 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 595
	local ____temp_7 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 596
	local ____temp_8 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 597
	local ____temp_9 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 598
	local ____temp_10 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 599
	local ____temp_11 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 600
		__TS__ArrayFilter( -- 601
			info.filesHint, -- 601
			function(____, item) return type(item) == "string" end -- 601
		), -- 601
		function(____, item) return sanitizeUTF8(item) end -- 601
	) or nil -- 601
	local ____temp_12 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 603
	local ____temp_2 -- 606
	if info.success == true then -- 606
		____temp_2 = true -- 606
	else -- 606
		local ____temp_1 -- 606
		if info.success == false then -- 606
			____temp_1 = false -- 606
		else -- 606
			____temp_1 = nil -- 606
		end -- 606
		____temp_2 = ____temp_1 -- 606
	end -- 606
	local ____temp_3 -- 607
	if info.cleared == true then -- 607
		____temp_3 = true -- 607
	else -- 607
		____temp_3 = nil -- 607
	end -- 607
	return { -- 592
		sessionId = ____temp_4, -- 593
		rootSessionId = ____temp_5, -- 594
		parentSessionId = ____temp_6, -- 595
		title = ____temp_7, -- 596
		prompt = ____temp_8, -- 597
		goal = ____temp_9, -- 598
		expectedOutput = ____temp_10, -- 599
		filesHint = ____temp_11, -- 600
		status = ____temp_12, -- 603
		success = ____temp_2, -- 606
		cleared = ____temp_3, -- 607
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 608
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 609
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 610
		changeSet = decodeChangeSetSummary(info.changeSet), -- 611
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 612
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 613
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 614
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 615
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 616
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 617
	} -- 617
end -- 617
function ensureDirRecursive(dir) -- 634
	if not dir or dir == "" then -- 634
		return false -- 635
	end -- 635
	if Content:exist(dir) then -- 635
		return Content:isdir(dir) -- 636
	end -- 636
	local parent = Path:getPath(dir) -- 637
	if parent and parent ~= dir and not Content:exist(parent) then -- 637
		if not ensureDirRecursive(parent) then -- 637
			return false -- 640
		end -- 640
	end -- 640
	return Content:mkdir(dir) -- 643
end -- 643
function writeSpawnInfo(projectRoot, memoryScope, value) -- 646
	local dir = Path(projectRoot, ".agent", memoryScope) -- 647
	if not Content:exist(dir) then -- 647
		ensureDirRecursive(dir) -- 649
	end -- 649
	local path = Path(dir, SPAWN_INFO_FILE) -- 651
	local text = safeJsonEncode(value) -- 652
	if not text then -- 652
		return false -- 653
	end -- 653
	local content = text .. "\n" -- 654
	if not Content:save(path, content) then -- 654
		return false -- 656
	end -- 656
	Tools.sendWebIDEFileUpdate(path, true, content) -- 658
	return true -- 659
end -- 659
function readSpawnInfo(projectRoot, memoryScope) -- 662
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 663
	if not Content:exist(path) then -- 663
		return nil -- 664
	end -- 664
	local text = Content:load(path) -- 665
	if not text or __TS__StringTrim(text) == "" then -- 665
		return nil -- 666
	end -- 666
	local value = safeJsonDecode(text) -- 667
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 667
		return value -- 669
	end -- 669
	return nil -- 671
end -- 671
function getArtifactRelativeDir(memoryScope) -- 674
	return Path(".agent", memoryScope) -- 675
end -- 675
function getArtifactDir(projectRoot, memoryScope) -- 678
	return Path( -- 679
		projectRoot, -- 679
		getArtifactRelativeDir(memoryScope) -- 679
	) -- 679
end -- 679
function getResultRelativePath(memoryScope) -- 682
	return Path( -- 683
		getArtifactRelativeDir(memoryScope), -- 683
		RESULT_FILE -- 683
	) -- 683
end -- 683
function getResultPath(projectRoot, memoryScope) -- 686
	return Path( -- 687
		projectRoot, -- 687
		getResultRelativePath(memoryScope) -- 687
	) -- 687
end -- 687
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 690
	if not resultFilePath or resultFilePath == "" then -- 690
		return "" -- 691
	end -- 691
	local path = Path(projectRoot, resultFilePath) -- 692
	if not Content:exist(path) then -- 692
		return "" -- 693
	end -- 693
	local text = sanitizeUTF8(Content:load(path)) -- 694
	if not text or __TS__StringTrim(text) == "" then -- 694
		return "" -- 695
	end -- 695
	local marker = "\n## Summary\n" -- 696
	local start = string.find(text, marker, 1, true) -- 697
	if start ~= nil then -- 697
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 699
	end -- 699
	return __TS__StringTrim(text) -- 701
end -- 701
function buildSubAgentMemoryEntryLLMOptions(llmConfig) -- 704
	local options = { -- 705
		temperature = llmConfig.temperature or SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, -- 706
		max_tokens = math.min(llmConfig.maxTokens or SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS) -- 707
	} -- 707
	if llmConfig.reasoningEffort then -- 707
		options.reasoning_effort = __TS__StringTrim(llmConfig.reasoningEffort) -- 710
	end -- 710
	if type(options.reasoning_effort) ~= "string" or __TS__StringTrim(options.reasoning_effort) == "" then -- 710
		__TS__Delete(options, "reasoning_effort") -- 713
	end -- 713
	return options -- 715
end -- 715
function buildSubAgentMemoryEntryToolSchema() -- 718
	return {{type = "function", ["function"] = {name = "save_sub_agent_memory_entry", description = "Save one durable memory paragraph extracted from a completed sub-agent session.", parameters = {type = "object", properties = {content = {type = "string", description = "A concise paragraph of key information worth carrying into future main-agent context. Use an empty string when nothing durable should be saved."}, evidence = {type = "array", items = {type = "string"}, description = "Optional short file paths, artifact paths, or concrete anchors that support the memory paragraph."}}, required = {"content"}}}}} -- 719
end -- 719
function buildSubAgentMemoryEntrySystemPrompt() -- 743
	return "You generate a durable memory entry for the parent Dora agent.\nPrefer calling save_sub_agent_memory_entry when tool calling is available.\nIf you cannot call tools, output exactly one JSON object with this shape: {\"content\":\"...\",\"evidence\":[\"...\"]}.\n\nUse the completed sub-agent conversation and final result to decide whether anything should be remembered.\nReturn a single compact paragraph in content, similar to a history entry.\nFocus on durable facts: implemented behavior, important design decisions, constraints, discovered project conventions, or follow-up risks.\nDo not include generic progress narration, praise, or temporary execution details.\nIf there is no information likely to help future work, set content to an empty string.\nKeep evidence short and concrete, such as touched file paths or result artifact paths." -- 744
end -- 744
function formatSubAgentMemoryTailMessage(message) -- 756
	local lines = {"role: " .. sanitizeUTF8(toStr(message.role))} -- 757
	if type(message.name) == "string" and message.name ~= "" then -- 757
		lines[#lines + 1] = "name: " .. sanitizeUTF8(message.name) -- 759
	end -- 759
	if type(message.tool_call_id) == "string" and message.tool_call_id ~= "" then -- 759
		lines[#lines + 1] = "tool_call_id: " .. sanitizeUTF8(message.tool_call_id) -- 762
	end -- 762
	local content = type(message.content) == "string" and clipTextToTokenBudget( -- 764
		sanitizeUTF8(message.content), -- 765
		SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS -- 765
	) or "" -- 765
	if content ~= "" then -- 765
		lines[#lines + 1] = "content:\n" .. content -- 768
	end -- 768
	if __TS__ArrayIsArray(message.tool_calls) and #message.tool_calls > 0 then -- 768
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 771
		if toolCallsText ~= nil and toolCallsText ~= "" then -- 771
			lines[#lines + 1] = "tool_calls:\n" .. clipTextToTokenBudget(toolCallsText, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS) -- 773
		end -- 773
	end -- 773
	return table.concat(lines, "\n") -- 776
end -- 776
function buildSubAgentRecentMessageTail(messages) -- 779
	local parts = {} -- 780
	local totalTokens = 0 -- 781
	local count = 0 -- 782
	do -- 782
		local i = #messages - 1 -- 783
		while i >= 0 and count < SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES do -- 783
			do -- 783
				local text = formatSubAgentMemoryTailMessage(messages[i + 1]) -- 784
				if text == "" then -- 784
					goto __continue122 -- 785
				end -- 785
				local tokens = estimateTextTokens(text) -- 786
				if #parts > 0 and totalTokens + tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS then -- 786
					break -- 787
				end -- 787
				if tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS and #parts == 0 then -- 787
					__TS__ArrayUnshift( -- 789
						parts, -- 789
						clipTextToTokenBudget(text, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS) -- 789
					) -- 789
					break -- 790
				end -- 790
				__TS__ArrayUnshift(parts, text) -- 792
				totalTokens = totalTokens + tokens -- 793
				count = count + 1 -- 794
			end -- 794
			::__continue122:: -- 794
			i = i - 1 -- 783
		end -- 783
	end -- 783
	return #parts > 0 and table.concat(parts, "\n\n---\n\n") or "(empty)"
end -- 796
function buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 799
	local ____opt_13 = record.changeSet -- 799
	local files = ____opt_13 and ____opt_13.files or ({}) -- 800
	local changedFiles = table.concat( -- 801
		__TS__ArrayMap( -- 801
			files, -- 801
			function(____, file) return ((("- " .. file.path) .. " (") .. file.op) .. ")" end -- 801
		), -- 801
		"\n" -- 801
	) -- 801
	local boundedMemoryContext = clipTextToTokenBudget(memoryContext ~= "" and memoryContext or "(empty)", SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS) -- 802
	local boundedResultText = clipTextToTokenBudget(resultText ~= "" and resultText or "(empty)", SUB_AGENT_MEMORY_RESULT_MAX_TOKENS) -- 803
	return ((((((((((((((((((((((("Sub-agent memory context:\n" .. boundedMemoryContext) .. "\n\nSub-agent task metadata:\n- sessionId: ") .. tostring(record.sessionId)) .. "\n- taskId: ") .. tostring(record.sourceTaskId)) .. "\n- title: ") .. record.title) .. "\n- goal: ") .. record.goal) .. "\n- prompt: ") .. record.prompt) .. "\n- expectedOutput: ") .. (record.expectedOutput or "")) .. "\n- resultFilePath: ") .. record.resultFilePath) .. "\n- finishedAt: ") .. record.finishedAt) .. "\n\nChanged files:\n") .. (changedFiles ~= "" and changedFiles or "- none")) .. "\n\nFinal sub-agent result:\n") .. boundedResultText) .. "\n\nRecent conversation tail:\n") .. recentMessageTail) .. "\n\nGenerate the memory entry now." -- 804
end -- 804
function buildSubAgentMemoryEntryRetryPrompt(lastError) -- 829
	return ("Previous memory entry response was invalid: " .. lastError) .. "\n\nRetry with exactly one JSON object and no Markdown fences, no prose, no tool call.\nSchema:\n{\"content\":\"one concise durable memory paragraph, or empty string if nothing should be saved\",\"evidence\":[\"optional short file path or artifact path\"]}\n\nRules:\n- content must be a string.\n- evidence must be an array of strings.\n- Use {\"content\":\"\",\"evidence\":[]} when there is no durable memory to save." -- 830
end -- 830
function normalizeGeneratedSubAgentMemoryEntry(value, record) -- 842
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 842
		return nil -- 843
	end -- 843
	local row = value -- 844
	local content = takeUtf8Head( -- 845
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 845
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 845
	) -- 845
	if content == "" then -- 845
		return nil -- 846
	end -- 846
	return { -- 847
		sourceSessionId = record.sessionId, -- 848
		sourceTaskId = record.sourceTaskId, -- 849
		content = content, -- 850
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 851
		createdAt = record.finishedAt -- 852
	} -- 852
end -- 852
function getMemoryEntryToolFunction(response) -- 856
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 856
		return nil -- 857
	end -- 857
	local row = response -- 858
	local choices = row.choices -- 859
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 859
		return nil -- 860
	end -- 860
	local ____opt_15 = choices[1] -- 860
	if ____opt_15 ~= nil then -- 860
		____opt_15 = ____opt_15.message -- 860
	end -- 860
	local message = ____opt_15 -- 861
	local ____opt_result_19 -- 861
	if message ~= nil then -- 861
		____opt_result_19 = message.tool_calls -- 861
	end -- 861
	local toolCalls = ____opt_result_19 -- 862
	if not __TS__ArrayIsArray(toolCalls) then -- 862
		return nil -- 863
	end -- 863
	do -- 863
		local i = 0 -- 864
		while i < #toolCalls do -- 864
			local ____opt_20 = toolCalls[i + 1] -- 864
			if ____opt_20 ~= nil then -- 864
				____opt_20 = ____opt_20["function"] -- 864
			end -- 864
			local fn = ____opt_20 -- 865
			if (fn and fn.name) == "save_sub_agent_memory_entry" then -- 865
				return fn -- 866
			end -- 866
			i = i + 1 -- 864
		end -- 864
	end -- 864
	return nil -- 868
end -- 868
function getMemoryEntryPlainContent(response) -- 871
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 871
		return "" -- 872
	end -- 872
	local row = response -- 873
	local choices = row.choices -- 874
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 874
		return "" -- 875
	end -- 875
	local ____opt_24 = choices[1] -- 875
	if ____opt_24 ~= nil then -- 875
		____opt_24 = ____opt_24.message -- 875
	end -- 875
	local message = ____opt_24 -- 876
	local ____opt_result_28 -- 876
	if message ~= nil then -- 876
		____opt_result_28 = message.content -- 876
	end -- 876
	return type(____opt_result_28) == "string" and __TS__StringTrim(sanitizeUTF8(message.content)) or "" -- 877
end -- 877
function decodeMemoryEntryFromPlainContent(content) -- 880
	if content == "" then -- 880
		return nil -- 881
	end -- 881
	local direct = safeJsonDecode(content) -- 882
	if direct ~= nil then -- 882
		return direct -- 883
	end -- 883
	local start = string.find(content, "{", 1, true) -- 884
	if start == nil then -- 884
		return nil -- 885
	end -- 885
	local ____end = #content -- 886
	while ____end >= start do -- 886
		local candidate = string.sub(content, start, ____end) -- 888
		local value = safeJsonDecode(candidate) -- 889
		if value ~= nil then -- 889
			return value -- 890
		end -- 890
		____end = ____end - 1 -- 891
	end -- 891
	return nil -- 893
end -- 893
function hasEmptyMemoryEntryContent(value) -- 896
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 896
		return false -- 897
	end -- 897
	local row = value -- 898
	return type(row.content) == "string" and __TS__StringTrim(sanitizeUTF8(row.content)) == "" -- 899
end -- 899
function generateSubAgentMemoryEntry(session, record, resultText) -- 902
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 902
		if not record.success then -- 902
			return ____awaiter_resolve(nil, {}) -- 902
		end -- 902
		local configRes = getActiveLLMConfig() -- 904
		if not configRes.success then -- 904
			return ____awaiter_resolve(nil, {error = configRes.message}) -- 904
		end -- 904
		local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 908
		local persisted = storage:readSessionState() -- 909
		local memoryContext = storage:readMemory() -- 910
		local recentMessageTail = buildSubAgentRecentMessageTail(persisted.messages) -- 911
		local prompt = buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 912
		local tools = configRes.config.supportsFunctionCalling and buildSubAgentMemoryEntryToolSchema() or nil -- 913
		local lastError = "missing memory entry" -- 914
		do -- 914
			local attempt = 0 -- 915
			while attempt < SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY do -- 915
				do -- 915
					local useTools = attempt == 0 and tools ~= nil -- 916
					local messages = { -- 917
						{ -- 918
							role = "system", -- 918
							content = buildSubAgentMemoryEntrySystemPrompt() -- 918
						}, -- 918
						{ -- 919
							role = "user", -- 920
							content = attempt == 0 and prompt or (prompt .. "\n\n") .. buildSubAgentMemoryEntryRetryPrompt(lastError) -- 921
						} -- 921
					} -- 921
					local response = __TS__Await(callLLM( -- 926
						messages, -- 927
						__TS__ObjectAssign( -- 928
							{}, -- 928
							buildSubAgentMemoryEntryLLMOptions(configRes.config), -- 929
							useTools and ({tools = tools}) or ({}) -- 930
						), -- 930
						configRes.config -- 932
					)) -- 932
					if not response.success then -- 932
						lastError = response.message -- 935
						if useTools then -- 935
							Log("Warn", "[AgentSession] sub session memory entry tool request failed, retrying without tools: " .. response.message) -- 937
						end -- 937
						goto __continue154 -- 939
					end -- 939
					local fn = getMemoryEntryToolFunction(response.response) -- 941
					local argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 942
					if fn ~= nil and argsText ~= "" then -- 942
						local args, err = safeJsonDecode(argsText) -- 944
						if err ~= nil or args == nil then -- 944
							lastError = "invalid memory entry tool arguments: " .. tostring(err) -- 946
							goto __continue154 -- 947
						end -- 947
						if hasEmptyMemoryEntryContent(args) then -- 947
							return ____awaiter_resolve(nil, {}) -- 947
						end -- 947
						local entry = normalizeGeneratedSubAgentMemoryEntry(args, record) -- 950
						if entry ~= nil then -- 950
							return ____awaiter_resolve(nil, {entry = entry}) -- 950
						end -- 950
						lastError = "invalid memory entry tool arguments shape" -- 952
						goto __continue154 -- 953
					end -- 953
					local plainContent = getMemoryEntryPlainContent(response.response) -- 955
					local plainArgs = decodeMemoryEntryFromPlainContent(plainContent) -- 956
					if plainArgs ~= nil then -- 956
						if hasEmptyMemoryEntryContent(plainArgs) then -- 956
							return ____awaiter_resolve(nil, {}) -- 956
						end -- 956
						local entry = normalizeGeneratedSubAgentMemoryEntry(plainArgs, record) -- 959
						if entry ~= nil then -- 959
							return ____awaiter_resolve(nil, {entry = entry}) -- 959
						end -- 959
						lastError = "invalid memory entry JSON shape" -- 961
						goto __continue154 -- 962
					end -- 962
					lastError = "LLM did not return memory entry tool call or JSON content" -- 964
				end -- 964
				::__continue154:: -- 964
				attempt = attempt + 1 -- 915
			end -- 915
		end -- 915
		return ____awaiter_resolve(nil, {error = lastError}) -- 915
	end) -- 915
end -- 915
function containsNormalizedText(text, query) -- 969
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 970
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 971
	if normalizedQuery == "" then -- 971
		return true -- 972
	end -- 972
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 973
end -- 973
function getSubAgentDisplayKey(item) -- 976
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 982
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 983
	local label = goal ~= "" and goal or title -- 984
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 985
end -- 985
function writeSubAgentResultFile(session, record, resultText) -- 988
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 989
	if not Content:exist(dir) then -- 989
		ensureDirRecursive(dir) -- 991
	end -- 991
	local ____array_29 = __TS__SparseArrayNew( -- 991
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 994
		"- Status: " .. record.status, -- 995
		"- Success: " .. (record.success and "true" or "false"), -- 996
		"- Session ID: " .. tostring(record.sessionId), -- 997
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 998
		"- Goal: " .. record.goal, -- 999
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1000
	) -- 1000
	__TS__SparseArrayPush( -- 1000
		____array_29, -- 1000
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1001
	) -- 1001
	__TS__SparseArrayPush( -- 1001
		____array_29, -- 1001
		"- Finished At: " .. record.finishedAt, -- 1002
		"", -- 1003
		"## Summary", -- 1004
		resultText ~= "" and resultText or "(empty)" -- 1005
	) -- 1005
	local lines = {__TS__SparseArraySpread(____array_29)} -- 993
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1007
	local content = table.concat(lines, "\n") .. "\n" -- 1008
	if not Content:save(path, content) then -- 1008
		return false -- 1010
	end -- 1010
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1012
	return true -- 1013
end -- 1013
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1016
	local dir = Path(projectRoot, ".agent", "subagents") -- 1017
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1017
		return {} -- 1018
	end -- 1018
	local items = {} -- 1019
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1020
		do -- 1020
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1021
			if not Content:exist(path) or not Content:isdir(path) then -- 1021
				goto __continue172 -- 1022
			end -- 1022
			local info = readSpawnInfo( -- 1023
				projectRoot, -- 1023
				Path( -- 1023
					"subagents", -- 1023
					Path:getFilename(path) -- 1023
				) -- 1023
			) -- 1023
			if not info then -- 1023
				goto __continue172 -- 1024
			end -- 1024
			local sessionId = tonumber(info.sessionId) -- 1025
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1026
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1027
			local status = sanitizeUTF8(toStr(info.status)) -- 1028
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1028
				goto __continue172 -- 1029
			end -- 1029
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1029
				goto __continue172 -- 1030
			end -- 1030
			items[#items + 1] = { -- 1031
				sessionId = sessionId, -- 1032
				rootSessionId = infoRootSessionId, -- 1033
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1034
				title = sanitizeUTF8(toStr(info.title)), -- 1035
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1036
				goal = sanitizeUTF8(toStr(info.goal)), -- 1037
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1038
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1039
					__TS__ArrayFilter( -- 1040
						info.filesHint, -- 1040
						function(____, item) return type(item) == "string" end -- 1040
					), -- 1040
					function(____, item) return sanitizeUTF8(item) end -- 1040
				) or ({}), -- 1040
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1042
				success = info.success == true, -- 1043
				cleared = info.cleared == true, -- 1044
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1045
				artifactDir = sanitizeUTF8(toStr(info.artifactDir)) or getArtifactRelativeDir(Path( -- 1046
					"subagents", -- 1046
					Path:getFilename(path) -- 1046
				)), -- 1046
				sourceTaskId = sourceTaskId or 0, -- 1047
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1048
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1049
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1050
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1051
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1052
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1053
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1054
			} -- 1054
		end -- 1054
		::__continue172:: -- 1054
	end -- 1054
	__TS__ArraySort( -- 1057
		items, -- 1057
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1057
	) -- 1057
	return items -- 1058
end -- 1058
function getPendingHandoffDir(projectRoot, memoryScope) -- 1061
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1062
end -- 1062
function writePendingHandoff(projectRoot, memoryScope, value) -- 1065
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1066
	if not Content:exist(dir) then -- 1066
		ensureDirRecursive(dir) -- 1068
	end -- 1068
	local path = Path(dir, value.id .. ".json") -- 1070
	local text = safeJsonEncode(value) -- 1071
	if not text then -- 1071
		return false -- 1072
	end -- 1072
	return Content:save(path, text .. "\n") -- 1073
end -- 1073
function listPendingHandoffs(projectRoot, memoryScope) -- 1076
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1077
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1077
		return {} -- 1078
	end -- 1078
	local items = {} -- 1079
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1080
		do -- 1080
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1081
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1081
				goto __continue187 -- 1082
			end -- 1082
			local text = Content:load(path) -- 1083
			if not text or __TS__StringTrim(text) == "" then -- 1083
				goto __continue187 -- 1084
			end -- 1084
			local value = safeJsonDecode(text) -- 1085
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 1085
				goto __continue187 -- 1086
			end -- 1086
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1087
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1088
			local id = sanitizeUTF8(toStr(value.id)) -- 1089
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1090
			local message = sanitizeUTF8(toStr(value.message)) -- 1091
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1092
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1093
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1094
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1094
				goto __continue187 -- 1096
			end -- 1096
			items[#items + 1] = { -- 1098
				id = id, -- 1099
				sourceSessionId = sourceSessionId, -- 1100
				sourceTitle = sourceTitle, -- 1101
				sourceTaskId = sourceTaskId, -- 1102
				message = message, -- 1103
				prompt = prompt, -- 1104
				goal = goal, -- 1105
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1106
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1107
					__TS__ArrayFilter( -- 1108
						value.filesHint, -- 1108
						function(____, item) return type(item) == "string" end -- 1108
					), -- 1108
					function(____, item) return sanitizeUTF8(item) end -- 1108
				) or ({}), -- 1108
				success = value.success == true, -- 1110
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1111
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1112
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1113
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1114
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1115
				createdAt = createdAt -- 1116
			} -- 1116
		end -- 1116
		::__continue187:: -- 1116
	end -- 1116
	__TS__ArraySort( -- 1119
		items, -- 1119
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1119
	) -- 1119
	return items -- 1120
end -- 1120
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1123
	local path = Path( -- 1124
		getPendingHandoffDir(projectRoot, memoryScope), -- 1124
		id .. ".json" -- 1124
	) -- 1124
	if Content:exist(path) then -- 1124
		Content:remove(path) -- 1126
	end -- 1126
end -- 1126
function normalizePromptText(prompt) -- 1130
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1131
end -- 1131
function normalizePromptTextSafe(prompt) -- 1134
	if type(prompt) == "string" then -- 1134
		local normalized = normalizePromptText(prompt) -- 1136
		if normalized ~= "" then -- 1136
			return normalized -- 1137
		end -- 1137
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1138
		if sanitized ~= "" then -- 1138
			return truncateAgentUserPrompt(sanitized) -- 1140
		end -- 1140
		return "" -- 1142
	end -- 1142
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1144
	if text == "" then -- 1144
		return "" -- 1145
	end -- 1145
	return truncateAgentUserPrompt(text) -- 1146
end -- 1146
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1149
	local sections = {} -- 1150
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1151
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1152
	local normalizedFiles = __TS__ArrayFilter( -- 1153
		__TS__ArrayMap( -- 1153
			__TS__ArrayFilter( -- 1153
				filesHint or ({}), -- 1153
				function(____, item) return type(item) == "string" end -- 1154
			), -- 1154
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1155
		), -- 1155
		function(____, item) return item ~= "" end -- 1156
	) -- 1156
	if normalizedTitle ~= "" then -- 1156
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1158
	end -- 1158
	if normalizedExpected ~= "" then -- 1158
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1161
	end -- 1161
	if #normalizedFiles > 0 then -- 1161
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1164
	end -- 1164
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1166
end -- 1166
function normalizeSessionRuntimeState(session) -- 1169
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1169
		return session -- 1171
	end -- 1171
	if activeStopTokens[session.currentTaskId] then -- 1171
		return session -- 1174
	end -- 1174
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1176
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1177
	return __TS__ObjectAssign( -- 1178
		{}, -- 1178
		session, -- 1179
		{ -- 1178
			status = "STOPPED", -- 1180
			currentTaskStatus = "STOPPED", -- 1181
			updatedAt = now() -- 1182
		} -- 1182
	) -- 1182
end -- 1182
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1186
	DB:exec( -- 1187
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1187
		{ -- 1191
			status, -- 1192
			currentTaskId or 0, -- 1193
			currentTaskStatus or status, -- 1194
			now(), -- 1195
			sessionId -- 1196
		} -- 1196
	) -- 1196
end -- 1196
function mergeAgentMetrics(current, next) -- 1201
	return __TS__ObjectAssign({}, current or ({}), next) -- 1202
end -- 1202
function updateSessionMetrics(sessionId, metrics) -- 1208
	local session = getSessionItem(sessionId) -- 1209
	if not session then -- 1209
		return nil -- 1210
	end -- 1210
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1211
	DB:exec( -- 1212
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1212
		{ -- 1216
			encodeJson(merged), -- 1217
			now(), -- 1218
			sessionId -- 1219
		} -- 1219
	) -- 1219
	return merged -- 1222
end -- 1222
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1225
	if taskId == nil or taskId <= 0 then -- 1225
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1227
		return -- 1228
	end -- 1228
	local row = getSessionRow(sessionId) -- 1230
	if not row then -- 1230
		return -- 1231
	end -- 1231
	local session = rowToSession(row) -- 1232
	if session.currentTaskId ~= taskId then -- 1232
		Log( -- 1234
			"Info", -- 1234
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1234
		) -- 1234
		return -- 1235
	end -- 1235
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1237
end -- 1237
function insertMessage(sessionId, role, content, taskId) -- 1240
	local t = now() -- 1241
	DB:exec( -- 1242
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1242
		{ -- 1245
			sessionId, -- 1246
			taskId or 0, -- 1247
			role, -- 1248
			sanitizeUTF8(content), -- 1249
			t, -- 1250
			t -- 1251
		} -- 1251
	) -- 1251
	return getLastInsertRowId() -- 1254
end -- 1254
function updateMessage(messageId, content) -- 1257
	DB:exec( -- 1258
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1258
		{ -- 1260
			sanitizeUTF8(content), -- 1260
			now(), -- 1260
			messageId -- 1260
		} -- 1260
	) -- 1260
end -- 1260
function upsertAssistantMessage(sessionId, taskId, content) -- 1264
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1265
	if row and type(row[1]) == "number" then -- 1265
		updateMessage(row[1], content) -- 1272
		return row[1] -- 1273
	end -- 1273
	return insertMessage(sessionId, "assistant", content, taskId) -- 1275
end -- 1275
function upsertStep(sessionId, taskId, step, tool, patch) -- 1278
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1288
	local reason = sanitizeUTF8(patch.reason or "") -- 1292
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1293
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1294
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1295
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1296
	local statusPatch = patch.status or "" -- 1297
	local status = patch.status or "PENDING" -- 1298
	if not row then -- 1298
		local t = now() -- 1300
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1301
			sessionId, -- 1305
			taskId, -- 1306
			step, -- 1307
			tool, -- 1308
			status, -- 1309
			reason, -- 1310
			reasoningContent, -- 1311
			paramsJson, -- 1312
			resultJson, -- 1313
			patch.checkpointId or 0, -- 1314
			patch.checkpointSeq or 0, -- 1315
			filesJson, -- 1316
			t, -- 1317
			t -- 1318
		}) -- 1318
		return -- 1321
	end -- 1321
	DB:exec( -- 1323
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1323
		{ -- 1335
			tool, -- 1336
			statusPatch, -- 1337
			status, -- 1338
			reason, -- 1339
			reason, -- 1340
			reasoningContent, -- 1341
			reasoningContent, -- 1342
			paramsJson, -- 1343
			paramsJson, -- 1344
			resultJson, -- 1345
			resultJson, -- 1346
			patch.checkpointId or 0, -- 1347
			patch.checkpointId or 0, -- 1348
			patch.checkpointSeq or 0, -- 1349
			patch.checkpointSeq or 0, -- 1350
			filesJson, -- 1351
			filesJson, -- 1352
			now(), -- 1353
			row[1] -- 1354
		} -- 1354
	) -- 1354
end -- 1354
function getNextStepNumber(sessionId, taskId) -- 1359
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1360
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1364
	return math.max(0, current) + 1 -- 1365
end -- 1365
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1368
	if status == nil then -- 1368
		status = "DONE" -- 1376
	end -- 1376
	local step = getNextStepNumber(sessionId, taskId) -- 1378
	upsertStep( -- 1379
		sessionId, -- 1379
		taskId, -- 1379
		step, -- 1379
		tool, -- 1379
		{status = status, reason = reason, params = params, result = result} -- 1379
	) -- 1379
	return getStepItem(sessionId, taskId, step) -- 1385
end -- 1385
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1388
	if taskId <= 0 then -- 1388
		return -- 1389
	end -- 1389
	if finalSteps ~= nil and finalSteps >= 0 then -- 1389
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1391
	end -- 1391
	if not finalStatus then -- 1391
		return -- 1397
	end -- 1397
	if finalSteps ~= nil and finalSteps >= 0 then -- 1397
		DB:exec( -- 1399
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1399
			{ -- 1403
				finalStatus, -- 1403
				now(), -- 1403
				sessionId, -- 1403
				taskId, -- 1403
				finalSteps -- 1403
			} -- 1403
		) -- 1403
		return -- 1405
	end -- 1405
	DB:exec( -- 1407
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1407
		{ -- 1411
			finalStatus, -- 1411
			now(), -- 1411
			sessionId, -- 1411
			taskId -- 1411
		} -- 1411
	) -- 1411
end -- 1411
function emitAgentSessionPatch(sessionId, patch) -- 1438
	if HttpServer.wsConnectionCount == 0 then -- 1438
		return -- 1440
	end -- 1440
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1442
	if not text then -- 1442
		return -- 1447
	end -- 1447
	emit("AppWS", "Send", text) -- 1448
end -- 1448
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1451
	emitAgentSessionPatch( -- 1452
		sessionId, -- 1452
		{ -- 1452
			sessionDeleted = true, -- 1453
			relatedSessions = listRelatedSessions(rootSessionId) -- 1454
		} -- 1454
	) -- 1454
	local rootSession = getSessionItem(rootSessionId) -- 1456
	if rootSession then -- 1456
		emitAgentSessionPatch( -- 1458
			rootSessionId, -- 1458
			{ -- 1458
				session = rootSession, -- 1459
				relatedSessions = listRelatedSessions(rootSessionId) -- 1460
			} -- 1460
		) -- 1460
	end -- 1460
end -- 1460
function flushPendingSubAgentHandoffs(rootSession) -- 1465
	if rootSession.kind ~= "main" then -- 1465
		return -- 1466
	end -- 1466
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1466
		return -- 1468
	end -- 1468
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1470
	if #items == 0 then -- 1470
		return -- 1471
	end -- 1471
	local handoffTaskId = 0 -- 1472
	local ____rootSession_currentTaskId_30 -- 1473
	if rootSession.currentTaskId then -- 1473
		____rootSession_currentTaskId_30 = getTaskPrompt(rootSession.currentTaskId) -- 1473
	else -- 1473
		____rootSession_currentTaskId_30 = nil -- 1473
	end -- 1473
	local currentTaskPrompt = ____rootSession_currentTaskId_30 -- 1473
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1473
		handoffTaskId = rootSession.currentTaskId -- 1481
	else -- 1481
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1483
		if not taskRes.success then -- 1483
			Log( -- 1485
				"Warn", -- 1485
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1485
			) -- 1485
			return -- 1486
		end -- 1486
		handoffTaskId = taskRes.taskId -- 1488
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1489
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1490
		emitAgentSessionPatch( -- 1491
			rootSession.id, -- 1491
			{session = getSessionItem(rootSession.id)} -- 1491
		) -- 1491
	end -- 1491
	do -- 1491
		local i = 0 -- 1495
		while i < #items do -- 1495
			local item = items[i + 1] -- 1496
			local step = appendSystemStep( -- 1497
				rootSession.id, -- 1498
				handoffTaskId, -- 1499
				"sub_agent_handoff", -- 1500
				"sub_agent_handoff", -- 1501
				item.message, -- 1502
				{ -- 1503
					sourceSessionId = item.sourceSessionId, -- 1504
					sourceTitle = item.sourceTitle, -- 1505
					sourceTaskId = item.sourceTaskId, -- 1506
					success = item.success == true, -- 1507
					summary = item.message, -- 1508
					resultFilePath = item.resultFilePath or "", -- 1509
					artifactDir = item.artifactDir or "", -- 1510
					finishedAt = item.finishedAt or "", -- 1511
					changeSet = item.changeSet, -- 1512
					memoryEntry = item.memoryEntry -- 1513
				}, -- 1513
				{ -- 1515
					sourceSessionId = item.sourceSessionId, -- 1516
					sourceTitle = item.sourceTitle, -- 1517
					sourceTaskId = item.sourceTaskId, -- 1518
					prompt = item.prompt, -- 1519
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1520
					expectedOutput = item.expectedOutput or "", -- 1521
					filesHint = item.filesHint or ({}), -- 1522
					resultFilePath = item.resultFilePath or "", -- 1523
					artifactDir = item.artifactDir or "", -- 1524
					changeSet = item.changeSet, -- 1525
					memoryEntry = item.memoryEntry -- 1526
				}, -- 1526
				"DONE" -- 1528
			) -- 1528
			if step then -- 1528
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1531
			end -- 1531
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1533
			i = i + 1 -- 1495
		end -- 1495
	end -- 1495
end -- 1495
function applyEvent(sessionId, event) -- 1545
	repeat -- 1545
		local ____switch252 = event.type -- 1545
		local ____cond252 = ____switch252 == "task_started" -- 1545
		if ____cond252 then -- 1545
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1548
			emitAgentSessionPatch( -- 1549
				sessionId, -- 1549
				{session = getSessionItem(sessionId)} -- 1549
			) -- 1549
			break -- 1552
		end -- 1552
		____cond252 = ____cond252 or ____switch252 == "decision_made" -- 1552
		if ____cond252 then -- 1552
			upsertStep( -- 1554
				sessionId, -- 1554
				event.taskId, -- 1554
				event.step, -- 1554
				event.tool, -- 1554
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1554
			) -- 1554
			emitAgentSessionPatch( -- 1560
				sessionId, -- 1560
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1560
			) -- 1560
			break -- 1563
		end -- 1563
		____cond252 = ____cond252 or ____switch252 == "tool_started" -- 1563
		if ____cond252 then -- 1563
			upsertStep( -- 1565
				sessionId, -- 1565
				event.taskId, -- 1565
				event.step, -- 1565
				event.tool, -- 1565
				{status = "RUNNING"} -- 1565
			) -- 1565
			emitAgentSessionPatch( -- 1568
				sessionId, -- 1568
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1568
			) -- 1568
			break -- 1571
		end -- 1571
		____cond252 = ____cond252 or ____switch252 == "tool_finished" -- 1571
		if ____cond252 then -- 1571
			upsertStep( -- 1573
				sessionId, -- 1573
				event.taskId, -- 1573
				event.step, -- 1573
				event.tool, -- 1573
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1573
			) -- 1573
			emitAgentSessionPatch( -- 1578
				sessionId, -- 1578
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1578
			) -- 1578
			break -- 1581
		end -- 1581
		____cond252 = ____cond252 or ____switch252 == "checkpoint_created" -- 1581
		if ____cond252 then -- 1581
			upsertStep( -- 1583
				sessionId, -- 1583
				event.taskId, -- 1583
				event.step, -- 1583
				event.tool, -- 1583
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1583
			) -- 1583
			emitAgentSessionPatch( -- 1588
				sessionId, -- 1588
				{ -- 1588
					step = getStepItem(sessionId, event.taskId, event.step), -- 1589
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1590
				} -- 1590
			) -- 1590
			break -- 1592
		end -- 1592
		____cond252 = ____cond252 or ____switch252 == "memory_compression_started" -- 1592
		if ____cond252 then -- 1592
			upsertStep( -- 1594
				sessionId, -- 1594
				event.taskId, -- 1594
				event.step, -- 1594
				event.tool, -- 1594
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1594
			) -- 1594
			emitAgentSessionPatch( -- 1599
				sessionId, -- 1599
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1599
			) -- 1599
			break -- 1602
		end -- 1602
		____cond252 = ____cond252 or ____switch252 == "memory_compression_finished" -- 1602
		if ____cond252 then -- 1602
			upsertStep( -- 1604
				sessionId, -- 1604
				event.taskId, -- 1604
				event.step, -- 1604
				event.tool, -- 1604
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1604
			) -- 1604
			emitAgentSessionPatch( -- 1609
				sessionId, -- 1609
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1609
			) -- 1609
			break -- 1612
		end -- 1612
		____cond252 = ____cond252 or ____switch252 == "metrics_updated" -- 1612
		if ____cond252 then -- 1612
			do -- 1612
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1614
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1615
				break -- 1618
			end -- 1618
		end -- 1618
		____cond252 = ____cond252 or ____switch252 == "assistant_message_updated" -- 1618
		if ____cond252 then -- 1618
			do -- 1618
				upsertStep( -- 1621
					sessionId, -- 1621
					event.taskId, -- 1621
					event.step, -- 1621
					"message", -- 1621
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1621
				) -- 1621
				emitAgentSessionPatch( -- 1626
					sessionId, -- 1626
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1626
				) -- 1626
				break -- 1629
			end -- 1629
		end -- 1629
		____cond252 = ____cond252 or ____switch252 == "task_finished" -- 1629
		if ____cond252 then -- 1629
			do -- 1629
				local ____opt_31 = activeStopTokens[event.taskId or -1] -- 1629
				local stopped = (____opt_31 and ____opt_31.stopped) == true -- 1632
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1633
				local session = getSessionItem(sessionId) -- 1636
				local isSubSession = (session and session.kind) == "sub" -- 1637
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1638
				if isSubSession and event.taskId ~= nil then -- 1638
					finalizingSubSessionTaskIds[event.taskId] = true -- 1640
				end -- 1640
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1642
				if event.taskId ~= nil then -- 1642
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1644
					local ____finalizeTaskSteps_37 = finalizeTaskSteps -- 1645
					local ____array_36 = __TS__SparseArrayNew( -- 1645
						sessionId, -- 1646
						event.taskId, -- 1647
						type(event.steps) == "number" and math.max( -- 1648
							0, -- 1648
							math.floor(event.steps) -- 1648
						) or nil -- 1648
					) -- 1648
					local ____event_success_35 -- 1649
					if event.success then -- 1649
						____event_success_35 = nil -- 1649
					else -- 1649
						____event_success_35 = stopped and "STOPPED" or "FAILED" -- 1649
					end -- 1649
					__TS__SparseArrayPush(____array_36, ____event_success_35) -- 1649
					____finalizeTaskSteps_37(__TS__SparseArraySpread(____array_36)) -- 1645
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1651
					if not isSubSession then -- 1651
						activeStopTokens[event.taskId] = nil -- 1653
					end -- 1653
					emitAgentSessionPatch( -- 1655
						sessionId, -- 1655
						{ -- 1655
							session = getSessionItem(sessionId), -- 1656
							message = getMessageItem(messageId), -- 1657
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1658
							removedStepIds = removedStepIds -- 1659
						} -- 1659
					) -- 1659
				end -- 1659
				if session and session.kind == "main" then -- 1659
					flushPendingSubAgentHandoffs(session) -- 1663
				end -- 1663
				break -- 1665
			end -- 1665
		end -- 1665
	until true -- 1665
end -- 1665
function ____exports.createSession(projectRoot, title) -- 1802
	if title == nil then -- 1802
		title = "" -- 1802
	end -- 1802
	if not isValidProjectRoot(projectRoot) then -- 1802
		return {success = false, message = "invalid projectRoot"} -- 1804
	end -- 1804
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1806
	if row then -- 1806
		return { -- 1815
			success = true, -- 1815
			session = rowToSession(row) -- 1815
		} -- 1815
	end -- 1815
	local t = now() -- 1817
	DB:exec( -- 1818
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1818
		{ -- 1821
			projectRoot, -- 1821
			title ~= "" and title or Path:getFilename(projectRoot), -- 1821
			t, -- 1821
			t -- 1821
		} -- 1821
	) -- 1821
	local sessionId = getLastInsertRowId() -- 1823
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1824
	local session = getSessionItem(sessionId) -- 1825
	if not session then -- 1825
		return {success = false, message = "failed to create session"} -- 1827
	end -- 1827
	return {success = true, session = session} -- 1829
end -- 1802
function ____exports.createSubSession(parentSessionId, title) -- 1832
	if title == nil then -- 1832
		title = "" -- 1832
	end -- 1832
	local parent = getSessionItem(parentSessionId) -- 1833
	if not parent then -- 1833
		return {success = false, message = "parent session not found"} -- 1835
	end -- 1835
	local rootId = getSessionRootId(parent) -- 1837
	local t = now() -- 1838
	DB:exec( -- 1839
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1839
		{ -- 1842
			parent.projectRoot, -- 1842
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1842
			rootId, -- 1842
			parent.id, -- 1842
			t, -- 1842
			t -- 1842
		} -- 1842
	) -- 1842
	local sessionId = getLastInsertRowId() -- 1844
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1845
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1846
	local session = getSessionItem(sessionId) -- 1847
	if not session then -- 1847
		return {success = false, message = "failed to create sub session"} -- 1849
	end -- 1849
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1851
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1852
	subStorage:writeMemory(parentStorage:readMemory()) -- 1853
	return {success = true, session = session} -- 1854
end -- 1832
function spawnSubAgentSession(request) -- 1857
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1857
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1868
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1869
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1870
		if normalizedPrompt == "" then -- 1870
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1872
		end -- 1872
		if normalizedPrompt == "" then -- 1872
			local ____Log_43 = Log -- 1879
			local ____temp_40 = #normalizedTitle -- 1879
			local ____temp_41 = #rawPrompt -- 1879
			local ____temp_42 = #toStr(request.expectedOutput) -- 1879
			local ____opt_38 = request.filesHint -- 1879
			____Log_43( -- 1879
				"Warn", -- 1879
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_40)) .. " raw_prompt_len=") .. tostring(____temp_41)) .. " expected_len=") .. tostring(____temp_42)) .. " files_hint_count=") .. tostring(____opt_38 and #____opt_38 or 0) -- 1879
			) -- 1879
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1879
		end -- 1879
		Log( -- 1882
			"Info", -- 1882
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1882
		) -- 1882
		local parentSessionId = request.parentSessionId -- 1883
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1883
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1885
			if not fallbackParent then -- 1885
				local createdMain = ____exports.createSession(request.projectRoot) -- 1887
				if createdMain.success then -- 1887
					fallbackParent = createdMain.session -- 1889
				end -- 1889
			end -- 1889
			if fallbackParent then -- 1889
				Log( -- 1893
					"Warn", -- 1893
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1893
				) -- 1893
				parentSessionId = fallbackParent.id -- 1894
			end -- 1894
		end -- 1894
		local parentSession = getSessionItem(parentSessionId) -- 1897
		if not parentSession then -- 1897
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1897
		end -- 1897
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1901
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1901
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1901
		end -- 1901
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1905
		if not created.success then -- 1905
			return ____awaiter_resolve(nil, created) -- 1905
		end -- 1905
		writeSpawnInfo( -- 1909
			created.session.projectRoot, -- 1909
			created.session.memoryScope, -- 1909
			{ -- 1909
				sessionId = created.session.id, -- 1910
				rootSessionId = created.session.rootSessionId, -- 1911
				parentSessionId = created.session.parentSessionId, -- 1912
				title = created.session.title, -- 1913
				prompt = normalizedPrompt, -- 1914
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1915
				expectedOutput = request.expectedOutput or "", -- 1916
				filesHint = request.filesHint or ({}), -- 1917
				status = "RUNNING", -- 1918
				success = false, -- 1919
				resultFilePath = "", -- 1920
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1921
				sourceTaskId = 0, -- 1922
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1923
				createdAtTs = created.session.createdAt, -- 1924
				finishedAt = "", -- 1925
				finishedAtTs = 0 -- 1926
			} -- 1926
		) -- 1926
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1928
		if not sent.success then -- 1928
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1928
		end -- 1928
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1928
	end) -- 1928
end -- 1928
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2009
	local rootSession = getRootSessionItem(session.id) -- 2010
	if not rootSession then -- 2010
		return -- 2011
	end -- 2011
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2012
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2013
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2014
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2015
	local queueResult = writePendingHandoff( -- 2016
		rootSession.projectRoot, -- 2016
		rootSession.memoryScope, -- 2016
		{ -- 2016
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2017
			sourceSessionId = session.id, -- 2018
			sourceTitle = session.title, -- 2019
			sourceTaskId = taskId, -- 2020
			message = summary, -- 2021
			prompt = result.prompt, -- 2022
			goal = result.goal, -- 2023
			expectedOutput = result.expectedOutput or "", -- 2024
			filesHint = result.filesHint or ({}), -- 2025
			success = result.success, -- 2026
			resultFilePath = result.resultFilePath, -- 2027
			artifactDir = result.artifactDir, -- 2028
			finishedAt = result.finishedAt, -- 2029
			changeSet = changeSet, -- 2030
			memoryEntry = result.memoryEntry, -- 2031
			createdAt = createdAt -- 2032
		} -- 2032
	) -- 2032
	if not queueResult then -- 2032
		Log( -- 2035
			"Warn", -- 2035
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2035
		) -- 2035
		return -- 2036
	end -- 2036
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2036
		flushPendingSubAgentHandoffs(rootSession) -- 2039
	end -- 2039
end -- 2039
function finalizeSubSession(session, taskId, success, message) -- 2043
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2043
		local rootSessionId = getSessionRootId(session) -- 2044
		local rootSession = getRootSessionItem(session.id) -- 2045
		if not rootSession then -- 2045
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2045
		end -- 2045
		local spawnInfo = getSessionSpawnInfo(session) -- 2049
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2050
		local finishedAtTs = now() -- 2051
		local resultText = sanitizeUTF8(message) -- 2052
		local changeSet = getTaskChangeSetSummary(taskId) -- 2053
		local record = { -- 2054
			sessionId = session.id, -- 2055
			rootSessionId = rootSessionId, -- 2056
			parentSessionId = session.parentSessionId, -- 2057
			title = session.title, -- 2058
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2059
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2060
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2061
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2062
			status = success and "DONE" or "FAILED", -- 2063
			success = success, -- 2064
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2065
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2066
			sourceTaskId = taskId, -- 2067
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2068
			finishedAt = finishedAt, -- 2069
			createdAtTs = session.createdAt, -- 2070
			finishedAtTs = finishedAtTs, -- 2071
			changeSet = changeSet -- 2072
		} -- 2072
		if record.success then -- 2072
			local memoryEntryResult = __TS__Await(generateSubAgentMemoryEntry(session, record, resultText)) -- 2075
			record.memoryEntry = memoryEntryResult.entry -- 2076
			if memoryEntryResult.error and memoryEntryResult.error ~= "" then -- 2076
				record.memoryEntryError = memoryEntryResult.error -- 2078
				Log( -- 2079
					"Warn", -- 2079
					(("[AgentSession] sub session memory entry failed session=" .. tostring(session.id)) .. " error=") .. memoryEntryResult.error -- 2079
				) -- 2079
			end -- 2079
		end -- 2079
		if not writeSubAgentResultFile(session, record, resultText) then -- 2079
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2079
		end -- 2079
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2079
			sessionId = record.sessionId, -- 2086
			rootSessionId = record.rootSessionId, -- 2087
			parentSessionId = record.parentSessionId, -- 2088
			title = record.title, -- 2089
			prompt = record.prompt, -- 2090
			goal = record.goal, -- 2091
			expectedOutput = record.expectedOutput or "", -- 2092
			filesHint = record.filesHint or ({}), -- 2093
			status = record.status, -- 2094
			success = record.success, -- 2095
			resultFilePath = record.resultFilePath, -- 2096
			artifactDir = record.artifactDir, -- 2097
			sourceTaskId = record.sourceTaskId, -- 2098
			createdAt = record.createdAt, -- 2099
			finishedAt = record.finishedAt, -- 2100
			createdAtTs = record.createdAtTs, -- 2101
			finishedAtTs = record.finishedAtTs, -- 2102
			changeSet = record.changeSet, -- 2103
			memoryEntry = record.memoryEntry, -- 2104
			memoryEntryError = record.memoryEntryError -- 2105
		}) then -- 2105
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2105
		end -- 2105
		if success then -- 2105
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2110
			deleteSessionRecords(session.id, true) -- 2111
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2112
		end -- 2112
		return ____awaiter_resolve(nil, {success = true}) -- 2112
	end) -- 2112
end -- 2112
function stopClearedSubSession(session, taskId) -- 2117
	local spawnInfo = getSessionSpawnInfo(session) -- 2118
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2119
	local rootSessionId = getSessionRootId(session) -- 2120
	Tools.setTaskStatus(taskId, "STOPPED") -- 2121
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2122
	if not writeSpawnInfo( -- 2122
		session.projectRoot, -- 2123
		session.memoryScope, -- 2123
		{ -- 2123
			sessionId = session.id, -- 2124
			rootSessionId = rootSessionId, -- 2125
			parentSessionId = session.parentSessionId, -- 2126
			title = session.title, -- 2127
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2128
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2129
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2130
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2131
			status = "STOPPED", -- 2132
			success = false, -- 2133
			cleared = true, -- 2134
			resultFilePath = "", -- 2135
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2136
			sourceTaskId = taskId, -- 2137
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2138
			finishedAt = finishedAt, -- 2139
			createdAtTs = session.createdAt, -- 2140
			finishedAtTs = now() -- 2141
		} -- 2141
	) then -- 2141
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2143
	end -- 2143
	deleteSessionRecords(session.id, true) -- 2145
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2146
	return {success = true} -- 2147
end -- 2147
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 2150
	if allowSubSessionStart == nil then -- 2150
		allowSubSessionStart = false -- 2150
	end -- 2150
	local session = getSessionItem(sessionId) -- 2151
	if not session then -- 2151
		return {success = false, message = "session not found"} -- 2153
	end -- 2153
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2153
		return {success = false, message = "session task is finalizing"} -- 2156
	end -- 2156
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2156
		return {success = false, message = "session task is still running"} -- 2159
	end -- 2159
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2161
	if normalizedPrompt == "" and session.kind == "sub" then -- 2161
		local spawnInfo = getSessionSpawnInfo(session) -- 2163
		if spawnInfo then -- 2163
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2165
			if normalizedPrompt == "" then -- 2165
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2167
			end -- 2167
		end -- 2167
	end -- 2167
	if normalizedPrompt == "" then -- 2167
		return {success = false, message = "prompt is empty"} -- 2176
	end -- 2176
	local taskRes = Tools.createTask(normalizedPrompt) -- 2178
	if not taskRes.success then -- 2178
		return {success = false, message = taskRes.message} -- 2180
	end -- 2180
	local taskId = taskRes.taskId -- 2182
	local useChineseResponse = getDefaultUseChineseResponse() -- 2183
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 2184
	local stopToken = {stopped = false} -- 2185
	activeStopTokens[taskId] = stopToken -- 2186
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 2187
	runCodingAgent( -- 2188
		{ -- 2188
			prompt = normalizedPrompt, -- 2189
			workDir = session.projectRoot, -- 2190
			useChineseResponse = useChineseResponse, -- 2191
			taskId = taskId, -- 2192
			sessionId = sessionId, -- 2193
			memoryScope = session.memoryScope, -- 2194
			role = session.kind, -- 2195
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2196
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2199
			stopToken = stopToken, -- 2202
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 2203
		}, -- 2203
		function(result) -- 2204
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2204
				local nextSession = getSessionItem(sessionId) -- 2205
				if nextSession and nextSession.kind == "sub" then -- 2205
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2205
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2208
						if not stopped.success then -- 2208
							Log( -- 2210
								"Warn", -- 2210
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2210
							) -- 2210
							emitAgentSessionPatch( -- 2211
								sessionId, -- 2211
								{session = getSessionItem(sessionId)} -- 2211
							) -- 2211
						end -- 2211
						activeStopTokens[taskId] = nil -- 2215
						return ____awaiter_resolve(nil) -- 2215
					end -- 2215
					setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 2218
					emitAgentSessionPatch( -- 2219
						sessionId, -- 2219
						{session = getSessionItem(sessionId)} -- 2219
					) -- 2219
					local finalized = __TS__Await(finalizeSubSession(nextSession, taskId, result.success, result.message)) -- 2222
					if not finalized.success then -- 2222
						Log( -- 2224
							"Warn", -- 2224
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2224
						) -- 2224
					end -- 2224
					local finalizedSession = getSessionItem(sessionId) -- 2226
					if finalizedSession then -- 2226
						local stopped = stopToken.stopped == true -- 2228
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2229
						setSessionState(sessionId, finalStatus, taskId, finalStatus) -- 2232
						emitAgentSessionPatch( -- 2233
							sessionId, -- 2233
							{session = getSessionItem(sessionId)} -- 2233
						) -- 2233
					end -- 2233
					activeStopTokens[taskId] = nil -- 2237
					finalizingSubSessionTaskIds[taskId] = nil -- 2238
				end -- 2238
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2238
					applyEvent(sessionId, { -- 2241
						type = "task_finished", -- 2242
						sessionId = sessionId, -- 2243
						taskId = result.taskId, -- 2244
						success = false, -- 2245
						message = result.message, -- 2246
						steps = result.steps -- 2247
					}) -- 2247
				end -- 2247
			end) -- 2247
		end -- 2204
	) -- 2204
	return {success = true, sessionId = sessionId, taskId = taskId} -- 2251
end -- 2150
function ____exports.listRunningSubAgents(request) -- 2301
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2301
		local session = getSessionItem(request.sessionId) -- 2309
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2309
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2311
		end -- 2311
		if not session then -- 2311
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2311
		end -- 2311
		local rootSession = getRootSessionItem(session.id) -- 2316
		if not rootSession then -- 2316
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2316
		end -- 2316
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2320
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2321
		local limit = math.max( -- 2322
			1, -- 2322
			math.floor(tonumber(request.limit) or 5) -- 2322
		) -- 2322
		local offset = math.max( -- 2323
			0, -- 2323
			math.floor(tonumber(request.offset) or 0) -- 2323
		) -- 2323
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2324
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2325
		local runningSessions = {} -- 2332
		do -- 2332
			local i = 0 -- 2333
			while i < #rows do -- 2333
				do -- 2333
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2334
					if current.currentTaskStatus ~= "RUNNING" then -- 2334
						goto __continue349 -- 2336
					end -- 2336
					local spawnInfo = getSessionSpawnInfo(current) -- 2338
					runningSessions[#runningSessions + 1] = { -- 2339
						sessionId = current.id, -- 2340
						title = current.title, -- 2341
						parentSessionId = current.parentSessionId, -- 2342
						rootSessionId = current.rootSessionId, -- 2343
						status = "RUNNING", -- 2344
						currentTaskId = current.currentTaskId, -- 2345
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2346
						goal = spawnInfo and spawnInfo.goal, -- 2347
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2348
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2349
						createdAt = current.createdAt, -- 2350
						updatedAt = current.updatedAt -- 2351
					} -- 2351
				end -- 2351
				::__continue349:: -- 2351
				i = i + 1 -- 2333
			end -- 2333
		end -- 2333
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2354
		local completedSessions = __TS__ArrayMap( -- 2355
			completedRecords, -- 2355
			function(____, record) return { -- 2355
				sessionId = record.sessionId, -- 2356
				title = record.title, -- 2357
				parentSessionId = record.parentSessionId, -- 2358
				rootSessionId = record.rootSessionId, -- 2359
				status = record.status, -- 2360
				goal = record.goal, -- 2361
				expectedOutput = record.expectedOutput, -- 2362
				filesHint = record.filesHint, -- 2363
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2364
				success = record.success, -- 2365
				cleared = record.cleared, -- 2366
				resultFilePath = record.resultFilePath, -- 2367
				artifactDir = record.artifactDir, -- 2368
				finishedAt = record.finishedAt, -- 2369
				createdAt = record.createdAtTs, -- 2370
				updatedAt = record.finishedAtTs -- 2371
			} end -- 2371
		) -- 2371
		local merged = {} -- 2373
		if status == "running" then -- 2373
			merged = runningSessions -- 2375
		elseif status == "done" then -- 2375
			merged = __TS__ArrayFilter( -- 2377
				completedSessions, -- 2377
				function(____, item) return item.status == "DONE" end -- 2377
			) -- 2377
		elseif status == "failed" then -- 2377
			merged = __TS__ArrayFilter( -- 2379
				completedSessions, -- 2379
				function(____, item) return item.status == "FAILED" end -- 2379
			) -- 2379
		elseif status == "stopped" then -- 2379
			merged = __TS__ArrayFilter( -- 2381
				completedSessions, -- 2381
				function(____, item) return item.status == "STOPPED" end -- 2381
			) -- 2381
		elseif status == "all" then -- 2381
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2383
		else -- 2383
			local runningKeys = {} -- 2385
			do -- 2385
				local i = 0 -- 2386
				while i < #runningSessions do -- 2386
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2387
					i = i + 1 -- 2386
				end -- 2386
			end -- 2386
			local latestCompletedByKey = {} -- 2389
			do -- 2389
				local i = 0 -- 2390
				while i < #completedSessions do -- 2390
					do -- 2390
						local item = completedSessions[i + 1] -- 2391
						local key = getSubAgentDisplayKey(item) -- 2392
						if runningKeys[key] then -- 2392
							goto __continue364 -- 2394
						end -- 2394
						local current = latestCompletedByKey[key] -- 2396
						if not current or item.updatedAt > current.updatedAt then -- 2396
							latestCompletedByKey[key] = item -- 2398
						end -- 2398
					end -- 2398
					::__continue364:: -- 2398
					i = i + 1 -- 2390
				end -- 2390
			end -- 2390
			local latestCompleted = {} -- 2401
			for ____, item in pairs(latestCompletedByKey) do -- 2402
				latestCompleted[#latestCompleted + 1] = item -- 2403
			end -- 2403
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2405
		end -- 2405
		if query ~= "" then -- 2405
			merged = __TS__ArrayFilter( -- 2408
				merged, -- 2408
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2408
			) -- 2408
		end -- 2408
		__TS__ArraySort( -- 2414
			merged, -- 2414
			function(____, a, b) -- 2414
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2414
					return -1 -- 2415
				end -- 2415
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2415
					return 1 -- 2416
				end -- 2416
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2416
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2418
				end -- 2418
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2420
			end -- 2414
		) -- 2414
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2422
		return ____awaiter_resolve(nil, { -- 2422
			success = true, -- 2424
			rootSessionId = rootSession.id, -- 2425
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2426
			status = status, -- 2427
			limit = limit, -- 2428
			offset = offset, -- 2429
			hasMore = offset + limit < #merged, -- 2430
			sessions = paged -- 2431
		}) -- 2431
	end) -- 2431
end -- 2301
TABLE_SESSION = "AgentSession" -- 192
TABLE_MESSAGE = "AgentSessionMessage" -- 193
TABLE_STEP = "AgentSessionStep" -- 194
TABLE_TASK = "AgentTask" -- 195
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 196
SPAWN_INFO_FILE = "SPAWN.json" -- 197
RESULT_FILE = "RESULT.md" -- 198
PENDING_HANDOFF_DIR = "pending-handoffs" -- 199
MAX_CONCURRENT_SUB_AGENTS = 4 -- 200
SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE = 0.1 -- 201
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS = 1024 -- 202
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY = 3 -- 203
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 204
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 205
SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS = 3000 -- 206
SUB_AGENT_MEMORY_RESULT_MAX_TOKENS = 2000 -- 207
SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES = 20 -- 208
SUB_AGENT_MEMORY_TAIL_MAX_TOKENS = 4000 -- 209
SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS = 600 -- 210
activeStopTokens = {} -- 256
finalizingSubSessionTaskIds = {} -- 257
now = function() return os.time() end -- 258
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 621
	if projectRoot == oldRoot then -- 621
		return newRoot -- 623
	end -- 623
	for ____, separator in ipairs({"/", "\\"}) do -- 625
		local prefix = oldRoot .. separator -- 626
		if __TS__StringStartsWith(projectRoot, prefix) then -- 626
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 628
		end -- 628
	end -- 628
	return nil -- 631
end -- 621
local function sanitizeStoredSteps(sessionId) -- 1415
	DB:exec( -- 1416
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1416
		{ -- 1434
			now(), -- 1434
			sessionId -- 1434
		} -- 1434
	) -- 1434
end -- 1415
local function getSchemaVersion() -- 1670
	local row = queryOne("PRAGMA user_version") -- 1671
	return row and type(row[1]) == "number" and row[1] or 0 -- 1672
end -- 1670
local function setSchemaVersion(version) -- 1675
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1676
		0, -- 1676
		math.floor(version) -- 1676
	))) -- 1676
end -- 1675
local function hasTableColumn(tableName, columnName) -- 1679
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1680
	do -- 1680
		local i = 0 -- 1681
		while i < #rows do -- 1681
			local row = rows[i + 1] -- 1682
			if toStr(row[2]) == columnName then -- 1682
				return true -- 1684
			end -- 1684
			i = i + 1 -- 1681
		end -- 1681
	end -- 1681
	return false -- 1687
end -- 1679
local function ensureSessionMetricsColumn() -- 1690
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1690
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1692
	end -- 1692
end -- 1690
local function recreateSchema() -- 1696
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1697
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1698
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1699
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1700
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1715
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1716
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1725
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1726
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1743
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1744
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1745
end -- 1696
do -- 1696
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1696
		recreateSchema() -- 1751
	else -- 1751
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t\t);") -- 1753
		ensureSessionMetricsColumn() -- 1768
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1769
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1770
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1779
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1780
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1797
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1798
	end -- 1798
end -- 1798
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1940
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1940
		return {success = false, message = "invalid projectRoot"} -- 1942
	end -- 1942
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1944
	for ____, row in ipairs(rows) do -- 1945
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1946
		if sessionId > 0 then -- 1946
			deleteSessionRecords(sessionId) -- 1948
		end -- 1948
	end -- 1948
	return {success = true, deleted = #rows} -- 1951
end -- 1940
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1954
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1954
		return {success = false, message = "invalid projectRoot"} -- 1956
	end -- 1956
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1958
	local renamed = 0 -- 1959
	for ____, row in ipairs(rows) do -- 1960
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1961
		local projectRoot = toStr(row[2]) -- 1962
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1963
		if sessionId > 0 and nextProjectRoot then -- 1963
			DB:exec( -- 1965
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1965
				{ -- 1967
					nextProjectRoot, -- 1967
					Path:getFilename(nextProjectRoot), -- 1967
					now(), -- 1967
					sessionId -- 1967
				} -- 1967
			) -- 1967
			renamed = renamed + 1 -- 1969
		end -- 1969
	end -- 1969
	return {success = true, renamed = renamed} -- 1972
end -- 1954
function ____exports.getSession(sessionId) -- 1975
	local session = getSessionItem(sessionId) -- 1976
	if not session then -- 1976
		return {success = false, message = "session not found"} -- 1978
	end -- 1978
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1980
	local relatedSessions = listRelatedSessions(sessionId) -- 1981
	sanitizeStoredSteps(sessionId) -- 1982
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1983
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1990
	local ____relatedSessions_45 = relatedSessions -- 2001
	local ____temp_44 -- 2002
	if normalizedSession.kind == "sub" then -- 2002
		____temp_44 = getSessionSpawnInfo(normalizedSession) -- 2002
	else -- 2002
		____temp_44 = nil -- 2002
	end -- 2002
	return { -- 1998
		success = true, -- 1999
		session = normalizedSession, -- 2000
		relatedSessions = ____relatedSessions_45, -- 2001
		spawnInfo = ____temp_44, -- 2002
		messages = __TS__ArrayMap( -- 2003
			messages, -- 2003
			function(____, row) return rowToMessage(row) end -- 2003
		), -- 2003
		steps = __TS__ArrayMap( -- 2004
			steps, -- 2004
			function(____, row) return rowToStep(row) end -- 2004
		), -- 2004
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 2005
	} -- 2005
end -- 1975
function ____exports.stopSessionTask(sessionId) -- 2254
	local session = getSessionItem(sessionId) -- 2255
	if not session or session.currentTaskId == nil then -- 2255
		return {success = false, message = "session task not found"} -- 2257
	end -- 2257
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2257
		return {success = false, message = "session task is finalizing"} -- 2260
	end -- 2260
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2262
	local stopToken = activeStopTokens[session.currentTaskId] -- 2263
	if not stopToken then -- 2263
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2263
			return {success = true, recovered = true} -- 2266
		end -- 2266
		return {success = false, message = "task is not running"} -- 2268
	end -- 2268
	stopToken.stopped = true -- 2270
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2271
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2272
	return {success = true} -- 2273
end -- 2254
function ____exports.getCurrentTaskId(sessionId) -- 2276
	local ____opt_66 = getSessionItem(sessionId) -- 2276
	return ____opt_66 and ____opt_66.currentTaskId -- 2277
end -- 2276
function ____exports.listRunningSessions() -- 2280
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2281
	local sessions = {} -- 2288
	do -- 2288
		local i = 0 -- 2289
		while i < #rows do -- 2289
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2290
			if session.currentTaskStatus == "RUNNING" then -- 2290
				sessions[#sessions + 1] = session -- 2292
			end -- 2292
			i = i + 1 -- 2289
		end -- 2289
	end -- 2289
	return {success = true, sessions = sessions} -- 2295
end -- 2280
return ____exports -- 2280