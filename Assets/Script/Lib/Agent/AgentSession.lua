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
function getDefaultUseChineseResponse() -- 261
	local zh = string.match(App.locale, "^zh") -- 262
	return zh ~= nil -- 263
end -- 263
function toStr(v) -- 266
	if v == false or v == nil or v == nil then -- 266
		return "" -- 267
	end -- 267
	return tostring(v) -- 268
end -- 268
function encodeJson(value) -- 271
	local text = safeJsonEncode(value) -- 272
	return text or "" -- 273
end -- 273
function decodeJsonObject(text) -- 276
	if not text or text == "" then -- 276
		return nil -- 277
	end -- 277
	local value = safeJsonDecode(text) -- 278
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 278
		return value -- 280
	end -- 280
	return nil -- 282
end -- 282
function decodeJsonFiles(text) -- 285
	if not text or text == "" then -- 285
		return nil -- 286
	end -- 286
	local value = safeJsonDecode(text) -- 287
	if not value or not __TS__ArrayIsArray(value) then -- 287
		return nil -- 288
	end -- 288
	local files = {} -- 289
	do -- 289
		local i = 0 -- 290
		while i < #value do -- 290
			do -- 290
				local item = value[i + 1] -- 291
				if type(item) ~= "table" then -- 291
					goto __continue14 -- 292
				end -- 292
				files[#files + 1] = { -- 293
					path = sanitizeUTF8(toStr(item.path)), -- 294
					op = sanitizeUTF8(toStr(item.op)) -- 295
				} -- 295
			end -- 295
			::__continue14:: -- 295
			i = i + 1 -- 290
		end -- 290
	end -- 290
	return files -- 298
end -- 298
function decodeChangeSetSummary(value) -- 301
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 301
		return nil -- 302
	end -- 302
	local row = value -- 303
	if row.success ~= true then -- 303
		return nil -- 304
	end -- 304
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 305
	if taskId <= 0 then -- 305
		return nil -- 306
	end -- 306
	local files = {} -- 307
	if __TS__ArrayIsArray(row.files) then -- 307
		do -- 307
			local i = 0 -- 309
			while i < #row.files do -- 309
				do -- 309
					local file = row.files[i + 1] -- 310
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 310
						goto __continue22 -- 311
					end -- 311
					local fileRow = file -- 312
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 313
					if path == "" then -- 313
						goto __continue22 -- 314
					end -- 314
					local checkpointIds = {} -- 315
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 315
						do -- 315
							local j = 0 -- 317
							while j < #fileRow.checkpointIds do -- 317
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 318
								if checkpointId > 0 then -- 318
									checkpointIds[#checkpointIds + 1] = checkpointId -- 319
								end -- 319
								j = j + 1 -- 317
							end -- 317
						end -- 317
					end -- 317
					local op = toStr(fileRow.op) -- 322
					files[#files + 1] = { -- 323
						path = path, -- 324
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 325
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 326
						checkpointIds = checkpointIds -- 327
					} -- 327
				end -- 327
				::__continue22:: -- 327
				i = i + 1 -- 309
			end -- 309
		end -- 309
	end -- 309
	return { -- 331
		success = true, -- 332
		taskId = taskId, -- 333
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 334
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 335
		files = files, -- 336
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 337
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 338
	} -- 338
end -- 338
function takeUtf8Head(text, maxChars) -- 342
	if maxChars <= 0 or text == "" then -- 342
		return "" -- 343
	end -- 343
	local nextPos = utf8.offset(text, maxChars + 1) -- 344
	if nextPos == nil then -- 344
		return text -- 345
	end -- 345
	return string.sub(text, 1, nextPos - 1) -- 346
end -- 346
function normalizeMemoryEntryEvidence(value) -- 349
	local evidence = {} -- 350
	if not __TS__ArrayIsArray(value) then -- 350
		return evidence -- 351
	end -- 351
	do -- 351
		local i = 0 -- 352
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 352
			do -- 352
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 353
				if item == "" then -- 353
					goto __continue35 -- 354
				end -- 354
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 354
					evidence[#evidence + 1] = item -- 356
				end -- 356
			end -- 356
			::__continue35:: -- 356
			i = i + 1 -- 352
		end -- 352
	end -- 352
	return evidence -- 359
end -- 359
function decodeSubAgentMemoryEntry(value) -- 362
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 362
		return nil -- 363
	end -- 363
	local row = value -- 364
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 365
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 366
	local content = takeUtf8Head( -- 367
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 367
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 367
	) -- 367
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 367
		return nil -- 368
	end -- 368
	return { -- 369
		sourceSessionId = sourceSessionId, -- 370
		sourceTaskId = sourceTaskId, -- 371
		content = content, -- 372
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 373
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 374
	} -- 374
end -- 374
function getTaskChangeSetSummary(taskId) -- 378
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 379
	return summary.success and summary or nil -- 380
end -- 380
function queryRows(sql, args) -- 383
	local ____args_0 -- 384
	if args then -- 384
		____args_0 = DB:query(sql, args) -- 384
	else -- 384
		____args_0 = DB:query(sql) -- 384
	end -- 384
	return ____args_0 -- 384
end -- 384
function queryOne(sql, args) -- 387
	local rows = queryRows(sql, args) -- 388
	if not rows or #rows == 0 then -- 388
		return nil -- 389
	end -- 389
	return rows[1] -- 390
end -- 390
function getLastInsertRowId() -- 393
	local row = queryOne("SELECT last_insert_rowid()") -- 394
	return row and (row[1] or 0) or 0 -- 395
end -- 395
function isValidProjectRoot(path) -- 398
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 399
end -- 399
function rowToSession(row) -- 402
	return { -- 403
		id = row[1], -- 404
		projectRoot = toStr(row[2]), -- 405
		title = toStr(row[3]), -- 406
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 407
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 408
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 409
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 410
		status = toStr(row[8]), -- 411
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 412
		currentTaskStatus = toStr(row[10]), -- 413
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 414
		createdAt = row[11], -- 415
		updatedAt = row[12], -- 416
		metrics = decodeJsonObject(toStr(row[13])) -- 417
	} -- 417
end -- 417
function rowToMessage(row) -- 421
	return { -- 422
		id = row[1], -- 423
		sessionId = row[2], -- 424
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 425
		role = toStr(row[4]), -- 426
		content = toStr(row[5]), -- 427
		createdAt = row[6], -- 428
		updatedAt = row[7] -- 429
	} -- 429
end -- 429
function rowToStep(row) -- 433
	return { -- 434
		id = row[1], -- 435
		sessionId = row[2], -- 436
		taskId = row[3], -- 437
		step = row[4], -- 438
		tool = toStr(row[5]), -- 439
		status = toStr(row[6]), -- 440
		reason = toStr(row[7]), -- 441
		reasoningContent = toStr(row[8]), -- 442
		params = decodeJsonObject(toStr(row[9])), -- 443
		result = decodeJsonObject(toStr(row[10])), -- 444
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 445
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 446
		files = decodeJsonFiles(toStr(row[13])), -- 447
		createdAt = row[14], -- 448
		updatedAt = row[15] -- 449
	} -- 449
end -- 449
function getMessageItem(messageId) -- 453
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 454
	return row and rowToMessage(row) or nil -- 460
end -- 460
function getStepItem(sessionId, taskId, step) -- 463
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 464
	return row and rowToStep(row) or nil -- 470
end -- 470
function deleteMessageSteps(sessionId, taskId) -- 473
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 474
	local ids = {} -- 479
	do -- 479
		local i = 0 -- 480
		while i < #rows do -- 480
			local row = rows[i + 1] -- 481
			if type(row[1]) == "number" then -- 481
				ids[#ids + 1] = row[1] -- 483
			end -- 483
			i = i + 1 -- 480
		end -- 480
	end -- 480
	if #ids > 0 then -- 480
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 487
	end -- 487
	return ids -- 493
end -- 493
function getSessionRow(sessionId) -- 496
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 497
end -- 497
function getSessionItem(sessionId) -- 505
	local row = getSessionRow(sessionId) -- 506
	return row and rowToSession(row) or nil -- 507
end -- 507
function getTaskPrompt(taskId) -- 510
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 511
	if not row or type(row[1]) ~= "string" then -- 511
		return nil -- 512
	end -- 512
	return toStr(row[1]) -- 513
end -- 513
function getLatestMainSessionByProjectRoot(projectRoot) -- 516
	if not isValidProjectRoot(projectRoot) then -- 516
		return nil -- 517
	end -- 517
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 518
	return row and rowToSession(row) or nil -- 526
end -- 526
function countRunningSubSessions(rootSessionId) -- 529
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 530
	local count = 0 -- 537
	do -- 537
		local i = 0 -- 538
		while i < #rows do -- 538
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 539
			if session.currentTaskStatus == "RUNNING" then -- 539
				count = count + 1 -- 541
			end -- 541
			i = i + 1 -- 538
		end -- 538
	end -- 538
	return count -- 544
end -- 544
function deleteSessionRecords(sessionId, preserveArtifacts) -- 547
	if preserveArtifacts == nil then -- 547
		preserveArtifacts = false -- 547
	end -- 547
	local session = getSessionItem(sessionId) -- 548
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 549
	do -- 549
		local i = 0 -- 550
		while i < #children do -- 550
			local row = children[i + 1] -- 551
			if type(row[1]) == "number" and row[1] > 0 then -- 551
				deleteSessionRecords(row[1], preserveArtifacts) -- 553
			end -- 553
			i = i + 1 -- 550
		end -- 550
	end -- 550
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 556
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 557
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 558
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 559
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 559
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 561
	end -- 561
end -- 561
function getSessionRootId(session) -- 565
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 566
end -- 566
function getRootSessionItem(sessionId) -- 569
	local session = getSessionItem(sessionId) -- 570
	if not session then -- 570
		return nil -- 571
	end -- 571
	return getSessionItem(getSessionRootId(session)) or session -- 572
end -- 572
function listRelatedSessions(sessionId) -- 575
	local root = getRootSessionItem(sessionId) -- 576
	if not root then -- 576
		return {} -- 577
	end -- 577
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 578
	return __TS__ArrayMap( -- 587
		rows, -- 587
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 587
	) -- 587
end -- 587
function getSessionSpawnInfo(session) -- 590
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 591
	if not info then -- 591
		return nil -- 592
	end -- 592
	local ____temp_4 = type(info.sessionId) == "number" and info.sessionId or nil -- 594
	local ____temp_5 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 595
	local ____temp_6 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 596
	local ____temp_7 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 597
	local ____temp_8 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 598
	local ____temp_9 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 599
	local ____temp_10 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 600
	local ____temp_11 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 601
		__TS__ArrayFilter( -- 602
			info.filesHint, -- 602
			function(____, item) return type(item) == "string" end -- 602
		), -- 602
		function(____, item) return sanitizeUTF8(item) end -- 602
	) or nil -- 602
	local ____temp_12 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 604
	local ____temp_2 -- 607
	if info.success == true then -- 607
		____temp_2 = true -- 607
	else -- 607
		local ____temp_1 -- 607
		if info.success == false then -- 607
			____temp_1 = false -- 607
		else -- 607
			____temp_1 = nil -- 607
		end -- 607
		____temp_2 = ____temp_1 -- 607
	end -- 607
	local ____temp_3 -- 608
	if info.cleared == true then -- 608
		____temp_3 = true -- 608
	else -- 608
		____temp_3 = nil -- 608
	end -- 608
	return { -- 593
		sessionId = ____temp_4, -- 594
		rootSessionId = ____temp_5, -- 595
		parentSessionId = ____temp_6, -- 596
		title = ____temp_7, -- 597
		prompt = ____temp_8, -- 598
		goal = ____temp_9, -- 599
		expectedOutput = ____temp_10, -- 600
		filesHint = ____temp_11, -- 601
		status = ____temp_12, -- 604
		success = ____temp_2, -- 607
		cleared = ____temp_3, -- 608
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 609
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 610
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 611
		changeSet = decodeChangeSetSummary(info.changeSet), -- 612
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 613
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 614
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 615
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 616
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 617
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 618
	} -- 618
end -- 618
function ensureDirRecursive(dir) -- 635
	if not dir or dir == "" then -- 635
		return false -- 636
	end -- 636
	if Content:exist(dir) then -- 636
		return Content:isdir(dir) -- 637
	end -- 637
	local parent = Path:getPath(dir) -- 638
	if parent and parent ~= dir and not Content:exist(parent) then -- 638
		if not ensureDirRecursive(parent) then -- 638
			return false -- 641
		end -- 641
	end -- 641
	return Content:mkdir(dir) -- 644
end -- 644
function writeSpawnInfo(projectRoot, memoryScope, value) -- 647
	local dir = Path(projectRoot, ".agent", memoryScope) -- 648
	if not Content:exist(dir) then -- 648
		ensureDirRecursive(dir) -- 650
	end -- 650
	local path = Path(dir, SPAWN_INFO_FILE) -- 652
	local text = safeJsonEncode(value) -- 653
	if not text then -- 653
		return false -- 654
	end -- 654
	local content = text .. "\n" -- 655
	if not Content:save(path, content) then -- 655
		return false -- 657
	end -- 657
	Tools.sendWebIDEFileUpdate(path, true, content) -- 659
	return true -- 660
end -- 660
function readSpawnInfo(projectRoot, memoryScope) -- 663
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 664
	if not Content:exist(path) then -- 664
		return nil -- 665
	end -- 665
	local text = Content:load(path) -- 666
	if not text or __TS__StringTrim(text) == "" then -- 666
		return nil -- 667
	end -- 667
	local value = safeJsonDecode(text) -- 668
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 668
		return value -- 670
	end -- 670
	return nil -- 672
end -- 672
function getArtifactRelativeDir(memoryScope) -- 675
	return Path(".agent", memoryScope) -- 676
end -- 676
function getArtifactDir(projectRoot, memoryScope) -- 679
	return Path( -- 680
		projectRoot, -- 680
		getArtifactRelativeDir(memoryScope) -- 680
	) -- 680
end -- 680
function getResultRelativePath(memoryScope) -- 683
	return Path( -- 684
		getArtifactRelativeDir(memoryScope), -- 684
		RESULT_FILE -- 684
	) -- 684
end -- 684
function getResultPath(projectRoot, memoryScope) -- 687
	return Path( -- 688
		projectRoot, -- 688
		getResultRelativePath(memoryScope) -- 688
	) -- 688
end -- 688
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 691
	if not resultFilePath or resultFilePath == "" then -- 691
		return "" -- 692
	end -- 692
	local path = Path(projectRoot, resultFilePath) -- 693
	if not Content:exist(path) then -- 693
		return "" -- 694
	end -- 694
	local text = sanitizeUTF8(Content:load(path)) -- 695
	if not text or __TS__StringTrim(text) == "" then -- 695
		return "" -- 696
	end -- 696
	local marker = "\n## Summary\n" -- 697
	local start = string.find(text, marker, 1, true) -- 698
	if start ~= nil then -- 698
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 700
	end -- 700
	return __TS__StringTrim(text) -- 702
end -- 702
function buildSubAgentMemoryEntryLLMOptions(llmConfig) -- 705
	local options = { -- 706
		temperature = llmConfig.temperature or SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, -- 707
		max_tokens = math.min(llmConfig.maxTokens or SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS) -- 708
	} -- 708
	if llmConfig.reasoningEffort then -- 708
		options.reasoning_effort = __TS__StringTrim(llmConfig.reasoningEffort) -- 711
	end -- 711
	if type(options.reasoning_effort) ~= "string" or __TS__StringTrim(options.reasoning_effort) == "" then -- 711
		__TS__Delete(options, "reasoning_effort") -- 714
	end -- 714
	return options -- 716
end -- 716
function buildSubAgentMemoryEntryToolSchema() -- 719
	return {{type = "function", ["function"] = {name = "save_sub_agent_memory_entry", description = "Save one durable memory paragraph extracted from a completed sub-agent session.", parameters = {type = "object", properties = {content = {type = "string", description = "A concise paragraph of key information worth carrying into future main-agent context. Use an empty string when nothing durable should be saved."}, evidence = {type = "array", items = {type = "string"}, description = "Optional short file paths, artifact paths, or concrete anchors that support the memory paragraph."}}, required = {"content"}}}}} -- 720
end -- 720
function buildSubAgentMemoryEntrySystemPrompt() -- 744
	return "You generate a durable memory entry for the parent Dora agent.\nPrefer calling save_sub_agent_memory_entry when tool calling is available.\nIf you cannot call tools, output exactly one JSON object with this shape: {\"content\":\"...\",\"evidence\":[\"...\"]}.\n\nUse the completed sub-agent conversation and final result to decide whether anything should be remembered.\nReturn a single compact paragraph in content, similar to a history entry.\nFocus on durable facts: implemented behavior, important design decisions, constraints, discovered project conventions, or follow-up risks.\nDo not include generic progress narration, praise, or temporary execution details.\nIf there is no information likely to help future work, set content to an empty string.\nKeep evidence short and concrete, such as touched file paths or result artifact paths." -- 745
end -- 745
function formatSubAgentMemoryTailMessage(message) -- 757
	local lines = {"role: " .. sanitizeUTF8(toStr(message.role))} -- 758
	if type(message.name) == "string" and message.name ~= "" then -- 758
		lines[#lines + 1] = "name: " .. sanitizeUTF8(message.name) -- 760
	end -- 760
	if type(message.tool_call_id) == "string" and message.tool_call_id ~= "" then -- 760
		lines[#lines + 1] = "tool_call_id: " .. sanitizeUTF8(message.tool_call_id) -- 763
	end -- 763
	local content = type(message.content) == "string" and clipTextToTokenBudget( -- 765
		sanitizeUTF8(message.content), -- 766
		SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS -- 766
	) or "" -- 766
	if content ~= "" then -- 766
		lines[#lines + 1] = "content:\n" .. content -- 769
	end -- 769
	if __TS__ArrayIsArray(message.tool_calls) and #message.tool_calls > 0 then -- 769
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 772
		if toolCallsText ~= nil and toolCallsText ~= "" then -- 772
			lines[#lines + 1] = "tool_calls:\n" .. clipTextToTokenBudget(toolCallsText, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS) -- 774
		end -- 774
	end -- 774
	return table.concat(lines, "\n") -- 777
end -- 777
function buildSubAgentRecentMessageTail(messages) -- 780
	local parts = {} -- 781
	local totalTokens = 0 -- 782
	local count = 0 -- 783
	do -- 783
		local i = #messages - 1 -- 784
		while i >= 0 and count < SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES do -- 784
			do -- 784
				local text = formatSubAgentMemoryTailMessage(messages[i + 1]) -- 785
				if text == "" then -- 785
					goto __continue122 -- 786
				end -- 786
				local tokens = estimateTextTokens(text) -- 787
				if #parts > 0 and totalTokens + tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS then -- 787
					break -- 788
				end -- 788
				if tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS and #parts == 0 then -- 788
					__TS__ArrayUnshift( -- 790
						parts, -- 790
						clipTextToTokenBudget(text, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS) -- 790
					) -- 790
					break -- 791
				end -- 791
				__TS__ArrayUnshift(parts, text) -- 793
				totalTokens = totalTokens + tokens -- 794
				count = count + 1 -- 795
			end -- 795
			::__continue122:: -- 795
			i = i - 1 -- 784
		end -- 784
	end -- 784
	return #parts > 0 and table.concat(parts, "\n\n---\n\n") or "(empty)"
end -- 797
function buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 800
	local ____opt_13 = record.changeSet -- 800
	local files = ____opt_13 and ____opt_13.files or ({}) -- 801
	local changedFiles = table.concat( -- 802
		__TS__ArrayMap( -- 802
			files, -- 802
			function(____, file) return ((("- " .. file.path) .. " (") .. file.op) .. ")" end -- 802
		), -- 802
		"\n" -- 802
	) -- 802
	local boundedMemoryContext = clipTextToTokenBudget(memoryContext ~= "" and memoryContext or "(empty)", SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS) -- 803
	local boundedResultText = clipTextToTokenBudget(resultText ~= "" and resultText or "(empty)", SUB_AGENT_MEMORY_RESULT_MAX_TOKENS) -- 804
	return ((((((((((((((((((((((("Sub-agent memory context:\n" .. boundedMemoryContext) .. "\n\nSub-agent task metadata:\n- sessionId: ") .. tostring(record.sessionId)) .. "\n- taskId: ") .. tostring(record.sourceTaskId)) .. "\n- title: ") .. record.title) .. "\n- goal: ") .. record.goal) .. "\n- prompt: ") .. record.prompt) .. "\n- expectedOutput: ") .. (record.expectedOutput or "")) .. "\n- resultFilePath: ") .. record.resultFilePath) .. "\n- finishedAt: ") .. record.finishedAt) .. "\n\nChanged files:\n") .. (changedFiles ~= "" and changedFiles or "- none")) .. "\n\nFinal sub-agent result:\n") .. boundedResultText) .. "\n\nRecent conversation tail:\n") .. recentMessageTail) .. "\n\nGenerate the memory entry now." -- 805
end -- 805
function buildSubAgentMemoryEntryRetryPrompt(lastError) -- 830
	return ("Previous memory entry response was invalid: " .. lastError) .. "\n\nRetry with exactly one JSON object and no Markdown fences, no prose, no tool call.\nSchema:\n{\"content\":\"one concise durable memory paragraph, or empty string if nothing should be saved\",\"evidence\":[\"optional short file path or artifact path\"]}\n\nRules:\n- content must be a string.\n- evidence must be an array of strings.\n- Use {\"content\":\"\",\"evidence\":[]} when there is no durable memory to save." -- 831
end -- 831
function normalizeGeneratedSubAgentMemoryEntry(value, record) -- 843
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 843
		return nil -- 844
	end -- 844
	local row = value -- 845
	local content = takeUtf8Head( -- 846
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 846
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 846
	) -- 846
	if content == "" then -- 846
		return nil -- 847
	end -- 847
	return { -- 848
		sourceSessionId = record.sessionId, -- 849
		sourceTaskId = record.sourceTaskId, -- 850
		content = content, -- 851
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 852
		createdAt = record.finishedAt -- 853
	} -- 853
end -- 853
function getMemoryEntryToolFunction(response) -- 857
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 857
		return nil -- 858
	end -- 858
	local row = response -- 859
	local choices = row.choices -- 860
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 860
		return nil -- 861
	end -- 861
	local ____opt_15 = choices[1] -- 861
	if ____opt_15 ~= nil then -- 861
		____opt_15 = ____opt_15.message -- 861
	end -- 861
	local message = ____opt_15 -- 862
	local ____opt_result_19 -- 862
	if message ~= nil then -- 862
		____opt_result_19 = message.tool_calls -- 862
	end -- 862
	local toolCalls = ____opt_result_19 -- 863
	if not __TS__ArrayIsArray(toolCalls) then -- 863
		return nil -- 864
	end -- 864
	do -- 864
		local i = 0 -- 865
		while i < #toolCalls do -- 865
			local ____opt_20 = toolCalls[i + 1] -- 865
			if ____opt_20 ~= nil then -- 865
				____opt_20 = ____opt_20["function"] -- 865
			end -- 865
			local fn = ____opt_20 -- 866
			if (fn and fn.name) == "save_sub_agent_memory_entry" then -- 866
				return fn -- 867
			end -- 867
			i = i + 1 -- 865
		end -- 865
	end -- 865
	return nil -- 869
end -- 869
function getMemoryEntryPlainContent(response) -- 872
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 872
		return "" -- 873
	end -- 873
	local row = response -- 874
	local choices = row.choices -- 875
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 875
		return "" -- 876
	end -- 876
	local ____opt_24 = choices[1] -- 876
	if ____opt_24 ~= nil then -- 876
		____opt_24 = ____opt_24.message -- 876
	end -- 876
	local message = ____opt_24 -- 877
	local ____opt_result_28 -- 877
	if message ~= nil then -- 877
		____opt_result_28 = message.content -- 877
	end -- 877
	return type(____opt_result_28) == "string" and __TS__StringTrim(sanitizeUTF8(message.content)) or "" -- 878
end -- 878
function decodeMemoryEntryFromPlainContent(content) -- 881
	if content == "" then -- 881
		return nil -- 882
	end -- 882
	local direct = safeJsonDecode(content) -- 883
	if direct ~= nil then -- 883
		return direct -- 884
	end -- 884
	local start = string.find(content, "{", 1, true) -- 885
	if start == nil then -- 885
		return nil -- 886
	end -- 886
	local ____end = #content -- 887
	while ____end >= start do -- 887
		local candidate = string.sub(content, start, ____end) -- 889
		local value = safeJsonDecode(candidate) -- 890
		if value ~= nil then -- 890
			return value -- 891
		end -- 891
		____end = ____end - 1 -- 892
	end -- 892
	return nil -- 894
end -- 894
function hasEmptyMemoryEntryContent(value) -- 897
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 897
		return false -- 898
	end -- 898
	local row = value -- 899
	return type(row.content) == "string" and __TS__StringTrim(sanitizeUTF8(row.content)) == "" -- 900
end -- 900
function generateSubAgentMemoryEntry(session, record, resultText) -- 903
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 903
		if not record.success then -- 903
			return ____awaiter_resolve(nil, {}) -- 903
		end -- 903
		local configRes = getActiveLLMConfig() -- 905
		if not configRes.success then -- 905
			return ____awaiter_resolve(nil, {error = configRes.message}) -- 905
		end -- 905
		local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 909
		local persisted = storage:readSessionState() -- 910
		local memoryContext = storage:readMemory() -- 911
		local recentMessageTail = buildSubAgentRecentMessageTail(persisted.messages) -- 912
		local prompt = buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 913
		local tools = configRes.config.supportsFunctionCalling and buildSubAgentMemoryEntryToolSchema() or nil -- 914
		local lastError = "missing memory entry" -- 915
		do -- 915
			local attempt = 0 -- 916
			while attempt < SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY do -- 916
				do -- 916
					local useTools = attempt == 0 and tools ~= nil -- 917
					local messages = { -- 918
						{ -- 919
							role = "system", -- 919
							content = buildSubAgentMemoryEntrySystemPrompt() -- 919
						}, -- 919
						{ -- 920
							role = "user", -- 921
							content = attempt == 0 and prompt or (prompt .. "\n\n") .. buildSubAgentMemoryEntryRetryPrompt(lastError) -- 922
						} -- 922
					} -- 922
					local response = __TS__Await(callLLM( -- 927
						messages, -- 928
						__TS__ObjectAssign( -- 929
							{}, -- 929
							buildSubAgentMemoryEntryLLMOptions(configRes.config), -- 930
							useTools and ({tools = tools}) or ({}) -- 931
						), -- 931
						configRes.config -- 933
					)) -- 933
					if not response.success then -- 933
						lastError = response.message -- 936
						if useTools then -- 936
							Log("Warn", "[AgentSession] sub session memory entry tool request failed, retrying without tools: " .. response.message) -- 938
						end -- 938
						goto __continue154 -- 940
					end -- 940
					local fn = getMemoryEntryToolFunction(response.response) -- 942
					local argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 943
					if fn ~= nil and argsText ~= "" then -- 943
						local args, err = safeJsonDecode(argsText) -- 945
						if err ~= nil or args == nil then -- 945
							lastError = "invalid memory entry tool arguments: " .. tostring(err) -- 947
							goto __continue154 -- 948
						end -- 948
						if hasEmptyMemoryEntryContent(args) then -- 948
							return ____awaiter_resolve(nil, {}) -- 948
						end -- 948
						local entry = normalizeGeneratedSubAgentMemoryEntry(args, record) -- 951
						if entry ~= nil then -- 951
							return ____awaiter_resolve(nil, {entry = entry}) -- 951
						end -- 951
						lastError = "invalid memory entry tool arguments shape" -- 953
						goto __continue154 -- 954
					end -- 954
					local plainContent = getMemoryEntryPlainContent(response.response) -- 956
					local plainArgs = decodeMemoryEntryFromPlainContent(plainContent) -- 957
					if plainArgs ~= nil then -- 957
						if hasEmptyMemoryEntryContent(plainArgs) then -- 957
							return ____awaiter_resolve(nil, {}) -- 957
						end -- 957
						local entry = normalizeGeneratedSubAgentMemoryEntry(plainArgs, record) -- 960
						if entry ~= nil then -- 960
							return ____awaiter_resolve(nil, {entry = entry}) -- 960
						end -- 960
						lastError = "invalid memory entry JSON shape" -- 962
						goto __continue154 -- 963
					end -- 963
					lastError = "LLM did not return memory entry tool call or JSON content" -- 965
				end -- 965
				::__continue154:: -- 965
				attempt = attempt + 1 -- 916
			end -- 916
		end -- 916
		return ____awaiter_resolve(nil, {error = lastError}) -- 916
	end) -- 916
end -- 916
function containsNormalizedText(text, query) -- 970
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 971
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 972
	if normalizedQuery == "" then -- 972
		return true -- 973
	end -- 973
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 974
end -- 974
function getSubAgentDisplayKey(item) -- 977
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 983
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 984
	local label = goal ~= "" and goal or title -- 985
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 986
end -- 986
function writeSubAgentResultFile(session, record, resultText) -- 989
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 990
	if not Content:exist(dir) then -- 990
		ensureDirRecursive(dir) -- 992
	end -- 992
	local ____array_29 = __TS__SparseArrayNew( -- 992
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 995
		"- Status: " .. record.status, -- 996
		"- Success: " .. (record.success and "true" or "false"), -- 997
		"- Session ID: " .. tostring(record.sessionId), -- 998
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 999
		"- Goal: " .. record.goal, -- 1000
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1001
	) -- 1001
	__TS__SparseArrayPush( -- 1001
		____array_29, -- 1001
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1002
	) -- 1002
	__TS__SparseArrayPush( -- 1002
		____array_29, -- 1002
		"- Finished At: " .. record.finishedAt, -- 1003
		"", -- 1004
		"## Summary", -- 1005
		resultText ~= "" and resultText or "(empty)" -- 1006
	) -- 1006
	local lines = {__TS__SparseArraySpread(____array_29)} -- 994
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1008
	local content = table.concat(lines, "\n") .. "\n" -- 1009
	if not Content:save(path, content) then -- 1009
		return false -- 1011
	end -- 1011
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1013
	return true -- 1014
end -- 1014
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1017
	local dir = Path(projectRoot, ".agent", "subagents") -- 1018
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1018
		return {} -- 1019
	end -- 1019
	local items = {} -- 1020
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1021
		do -- 1021
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1022
			if not Content:exist(path) or not Content:isdir(path) then -- 1022
				goto __continue172 -- 1023
			end -- 1023
			local info = readSpawnInfo( -- 1024
				projectRoot, -- 1024
				Path( -- 1024
					"subagents", -- 1024
					Path:getFilename(path) -- 1024
				) -- 1024
			) -- 1024
			if not info then -- 1024
				goto __continue172 -- 1025
			end -- 1025
			local sessionId = tonumber(info.sessionId) -- 1026
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1027
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1028
			local status = sanitizeUTF8(toStr(info.status)) -- 1029
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1029
				goto __continue172 -- 1030
			end -- 1030
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1030
				goto __continue172 -- 1031
			end -- 1031
			items[#items + 1] = { -- 1032
				sessionId = sessionId, -- 1033
				rootSessionId = infoRootSessionId, -- 1034
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1035
				title = sanitizeUTF8(toStr(info.title)), -- 1036
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1037
				goal = sanitizeUTF8(toStr(info.goal)), -- 1038
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1039
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1040
					__TS__ArrayFilter( -- 1041
						info.filesHint, -- 1041
						function(____, item) return type(item) == "string" end -- 1041
					), -- 1041
					function(____, item) return sanitizeUTF8(item) end -- 1041
				) or ({}), -- 1041
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1043
				success = info.success == true, -- 1044
				cleared = info.cleared == true, -- 1045
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1046
				artifactDir = sanitizeUTF8(toStr(info.artifactDir)) or getArtifactRelativeDir(Path( -- 1047
					"subagents", -- 1047
					Path:getFilename(path) -- 1047
				)), -- 1047
				sourceTaskId = sourceTaskId or 0, -- 1048
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1049
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1050
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1051
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1052
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1053
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1054
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1055
			} -- 1055
		end -- 1055
		::__continue172:: -- 1055
	end -- 1055
	__TS__ArraySort( -- 1058
		items, -- 1058
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1058
	) -- 1058
	return items -- 1059
end -- 1059
function getPendingHandoffDir(projectRoot, memoryScope) -- 1062
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1063
end -- 1063
function writePendingHandoff(projectRoot, memoryScope, value) -- 1066
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1067
	if not Content:exist(dir) then -- 1067
		ensureDirRecursive(dir) -- 1069
	end -- 1069
	local path = Path(dir, value.id .. ".json") -- 1071
	local text = safeJsonEncode(value) -- 1072
	if not text then -- 1072
		return false -- 1073
	end -- 1073
	return Content:save(path, text .. "\n") -- 1074
end -- 1074
function listPendingHandoffs(projectRoot, memoryScope) -- 1077
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1078
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1078
		return {} -- 1079
	end -- 1079
	local items = {} -- 1080
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1081
		do -- 1081
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1082
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1082
				goto __continue187 -- 1083
			end -- 1083
			local text = Content:load(path) -- 1084
			if not text or __TS__StringTrim(text) == "" then -- 1084
				goto __continue187 -- 1085
			end -- 1085
			local value = safeJsonDecode(text) -- 1086
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 1086
				goto __continue187 -- 1087
			end -- 1087
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1088
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1089
			local id = sanitizeUTF8(toStr(value.id)) -- 1090
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1091
			local message = sanitizeUTF8(toStr(value.message)) -- 1092
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1093
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1094
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1095
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1095
				goto __continue187 -- 1097
			end -- 1097
			items[#items + 1] = { -- 1099
				id = id, -- 1100
				sourceSessionId = sourceSessionId, -- 1101
				sourceTitle = sourceTitle, -- 1102
				sourceTaskId = sourceTaskId, -- 1103
				message = message, -- 1104
				prompt = prompt, -- 1105
				goal = goal, -- 1106
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1107
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1108
					__TS__ArrayFilter( -- 1109
						value.filesHint, -- 1109
						function(____, item) return type(item) == "string" end -- 1109
					), -- 1109
					function(____, item) return sanitizeUTF8(item) end -- 1109
				) or ({}), -- 1109
				success = value.success == true, -- 1111
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1112
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1113
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1114
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1115
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1116
				createdAt = createdAt -- 1117
			} -- 1117
		end -- 1117
		::__continue187:: -- 1117
	end -- 1117
	__TS__ArraySort( -- 1120
		items, -- 1120
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1120
	) -- 1120
	return items -- 1121
end -- 1121
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1124
	local path = Path( -- 1125
		getPendingHandoffDir(projectRoot, memoryScope), -- 1125
		id .. ".json" -- 1125
	) -- 1125
	if Content:exist(path) then -- 1125
		Content:remove(path) -- 1127
	end -- 1127
end -- 1127
function normalizePromptText(prompt) -- 1131
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1132
end -- 1132
function normalizePromptTextSafe(prompt) -- 1135
	if type(prompt) == "string" then -- 1135
		local normalized = normalizePromptText(prompt) -- 1137
		if normalized ~= "" then -- 1137
			return normalized -- 1138
		end -- 1138
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1139
		if sanitized ~= "" then -- 1139
			return truncateAgentUserPrompt(sanitized) -- 1141
		end -- 1141
		return "" -- 1143
	end -- 1143
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1145
	if text == "" then -- 1145
		return "" -- 1146
	end -- 1146
	return truncateAgentUserPrompt(text) -- 1147
end -- 1147
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1150
	local sections = {} -- 1151
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1152
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1153
	local normalizedFiles = __TS__ArrayFilter( -- 1154
		__TS__ArrayMap( -- 1154
			__TS__ArrayFilter( -- 1154
				filesHint or ({}), -- 1154
				function(____, item) return type(item) == "string" end -- 1155
			), -- 1155
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1156
		), -- 1156
		function(____, item) return item ~= "" end -- 1157
	) -- 1157
	if normalizedTitle ~= "" then -- 1157
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1159
	end -- 1159
	if normalizedExpected ~= "" then -- 1159
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1162
	end -- 1162
	if #normalizedFiles > 0 then -- 1162
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1165
	end -- 1165
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1167
end -- 1167
function normalizeSessionRuntimeState(session) -- 1170
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1170
		return session -- 1172
	end -- 1172
	if activeStopTokens[session.currentTaskId] then -- 1172
		return session -- 1175
	end -- 1175
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1177
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1178
	return __TS__ObjectAssign( -- 1179
		{}, -- 1179
		session, -- 1180
		{ -- 1179
			status = "STOPPED", -- 1181
			currentTaskStatus = "STOPPED", -- 1182
			updatedAt = now() -- 1183
		} -- 1183
	) -- 1183
end -- 1183
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1187
	DB:exec( -- 1188
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1188
		{ -- 1192
			status, -- 1193
			currentTaskId or 0, -- 1194
			currentTaskStatus or status, -- 1195
			now(), -- 1196
			sessionId -- 1197
		} -- 1197
	) -- 1197
end -- 1197
function mergeAgentMetrics(current, next) -- 1202
	return __TS__ObjectAssign({}, current or ({}), next) -- 1203
end -- 1203
function updateSessionMetrics(sessionId, metrics) -- 1209
	local session = getSessionItem(sessionId) -- 1210
	if not session then -- 1210
		return nil -- 1211
	end -- 1211
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1212
	DB:exec( -- 1213
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1213
		{ -- 1217
			encodeJson(merged), -- 1218
			now(), -- 1219
			sessionId -- 1220
		} -- 1220
	) -- 1220
	return merged -- 1223
end -- 1223
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1226
	if taskId == nil or taskId <= 0 then -- 1226
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1228
		return -- 1229
	end -- 1229
	local row = getSessionRow(sessionId) -- 1231
	if not row then -- 1231
		return -- 1232
	end -- 1232
	local session = rowToSession(row) -- 1233
	if session.currentTaskId ~= taskId then -- 1233
		Log( -- 1235
			"Info", -- 1235
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1235
		) -- 1235
		return -- 1236
	end -- 1236
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1238
end -- 1238
function insertMessage(sessionId, role, content, taskId) -- 1241
	local t = now() -- 1242
	DB:exec( -- 1243
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1243
		{ -- 1246
			sessionId, -- 1247
			taskId or 0, -- 1248
			role, -- 1249
			sanitizeUTF8(content), -- 1250
			t, -- 1251
			t -- 1252
		} -- 1252
	) -- 1252
	return getLastInsertRowId() -- 1255
end -- 1255
function updateMessage(messageId, content) -- 1258
	DB:exec( -- 1259
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1259
		{ -- 1261
			sanitizeUTF8(content), -- 1261
			now(), -- 1261
			messageId -- 1261
		} -- 1261
	) -- 1261
end -- 1261
function upsertAssistantMessage(sessionId, taskId, content) -- 1265
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1266
	if row and type(row[1]) == "number" then -- 1266
		updateMessage(row[1], content) -- 1273
		return row[1] -- 1274
	end -- 1274
	return insertMessage(sessionId, "assistant", content, taskId) -- 1276
end -- 1276
function upsertStep(sessionId, taskId, step, tool, patch) -- 1279
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1289
	local reason = sanitizeUTF8(patch.reason or "") -- 1293
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1294
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1295
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1296
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1297
	local statusPatch = patch.status or "" -- 1298
	local status = patch.status or "PENDING" -- 1299
	if not row then -- 1299
		local t = now() -- 1301
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1302
			sessionId, -- 1306
			taskId, -- 1307
			step, -- 1308
			tool, -- 1309
			status, -- 1310
			reason, -- 1311
			reasoningContent, -- 1312
			paramsJson, -- 1313
			resultJson, -- 1314
			patch.checkpointId or 0, -- 1315
			patch.checkpointSeq or 0, -- 1316
			filesJson, -- 1317
			t, -- 1318
			t -- 1319
		}) -- 1319
		return -- 1322
	end -- 1322
	DB:exec( -- 1324
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1324
		{ -- 1336
			tool, -- 1337
			statusPatch, -- 1338
			status, -- 1339
			reason, -- 1340
			reason, -- 1341
			reasoningContent, -- 1342
			reasoningContent, -- 1343
			paramsJson, -- 1344
			paramsJson, -- 1345
			resultJson, -- 1346
			resultJson, -- 1347
			patch.checkpointId or 0, -- 1348
			patch.checkpointId or 0, -- 1349
			patch.checkpointSeq or 0, -- 1350
			patch.checkpointSeq or 0, -- 1351
			filesJson, -- 1352
			filesJson, -- 1353
			now(), -- 1354
			row[1] -- 1355
		} -- 1355
	) -- 1355
end -- 1355
function getNextStepNumber(sessionId, taskId) -- 1360
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1361
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1365
	return math.max(0, current) + 1 -- 1366
end -- 1366
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1369
	if status == nil then -- 1369
		status = "DONE" -- 1377
	end -- 1377
	local step = getNextStepNumber(sessionId, taskId) -- 1379
	upsertStep( -- 1380
		sessionId, -- 1380
		taskId, -- 1380
		step, -- 1380
		tool, -- 1380
		{status = status, reason = reason, params = params, result = result} -- 1380
	) -- 1380
	return getStepItem(sessionId, taskId, step) -- 1386
end -- 1386
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1389
	if taskId <= 0 then -- 1389
		return -- 1390
	end -- 1390
	if finalSteps ~= nil and finalSteps >= 0 then -- 1390
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1392
	end -- 1392
	if not finalStatus then -- 1392
		return -- 1398
	end -- 1398
	if finalSteps ~= nil and finalSteps >= 0 then -- 1398
		DB:exec( -- 1400
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1400
			{ -- 1404
				finalStatus, -- 1404
				now(), -- 1404
				sessionId, -- 1404
				taskId, -- 1404
				finalSteps -- 1404
			} -- 1404
		) -- 1404
		return -- 1406
	end -- 1406
	DB:exec( -- 1408
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1408
		{ -- 1412
			finalStatus, -- 1412
			now(), -- 1412
			sessionId, -- 1412
			taskId -- 1412
		} -- 1412
	) -- 1412
end -- 1412
function emitAgentSessionPatch(sessionId, patch) -- 1439
	if HttpServer.wsConnectionCount == 0 then -- 1439
		return -- 1441
	end -- 1441
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1443
	if not text then -- 1443
		return -- 1448
	end -- 1448
	emit("AppWS", "Send", text) -- 1449
end -- 1449
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1452
	emitAgentSessionPatch( -- 1453
		sessionId, -- 1453
		{ -- 1453
			sessionDeleted = true, -- 1454
			relatedSessions = listRelatedSessions(rootSessionId) -- 1455
		} -- 1455
	) -- 1455
	local rootSession = getSessionItem(rootSessionId) -- 1457
	if rootSession then -- 1457
		emitAgentSessionPatch( -- 1459
			rootSessionId, -- 1459
			{ -- 1459
				session = rootSession, -- 1460
				relatedSessions = listRelatedSessions(rootSessionId) -- 1461
			} -- 1461
		) -- 1461
	end -- 1461
end -- 1461
function flushPendingSubAgentHandoffs(rootSession) -- 1466
	if rootSession.kind ~= "main" then -- 1466
		return -- 1467
	end -- 1467
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1467
		return -- 1469
	end -- 1469
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1471
	if #items == 0 then -- 1471
		return -- 1472
	end -- 1472
	local handoffTaskId = 0 -- 1473
	local ____rootSession_currentTaskId_30 -- 1474
	if rootSession.currentTaskId then -- 1474
		____rootSession_currentTaskId_30 = getTaskPrompt(rootSession.currentTaskId) -- 1474
	else -- 1474
		____rootSession_currentTaskId_30 = nil -- 1474
	end -- 1474
	local currentTaskPrompt = ____rootSession_currentTaskId_30 -- 1474
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1474
		handoffTaskId = rootSession.currentTaskId -- 1482
	else -- 1482
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1484
		if not taskRes.success then -- 1484
			Log( -- 1486
				"Warn", -- 1486
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1486
			) -- 1486
			return -- 1487
		end -- 1487
		handoffTaskId = taskRes.taskId -- 1489
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1490
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1491
		emitAgentSessionPatch( -- 1492
			rootSession.id, -- 1492
			{session = getSessionItem(rootSession.id)} -- 1492
		) -- 1492
	end -- 1492
	do -- 1492
		local i = 0 -- 1496
		while i < #items do -- 1496
			local item = items[i + 1] -- 1497
			local step = appendSystemStep( -- 1498
				rootSession.id, -- 1499
				handoffTaskId, -- 1500
				"sub_agent_handoff", -- 1501
				"sub_agent_handoff", -- 1502
				item.message, -- 1503
				{ -- 1504
					sourceSessionId = item.sourceSessionId, -- 1505
					sourceTitle = item.sourceTitle, -- 1506
					sourceTaskId = item.sourceTaskId, -- 1507
					success = item.success == true, -- 1508
					summary = item.message, -- 1509
					resultFilePath = item.resultFilePath or "", -- 1510
					artifactDir = item.artifactDir or "", -- 1511
					finishedAt = item.finishedAt or "", -- 1512
					changeSet = item.changeSet, -- 1513
					memoryEntry = item.memoryEntry -- 1514
				}, -- 1514
				{ -- 1516
					sourceSessionId = item.sourceSessionId, -- 1517
					sourceTitle = item.sourceTitle, -- 1518
					sourceTaskId = item.sourceTaskId, -- 1519
					prompt = item.prompt, -- 1520
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1521
					expectedOutput = item.expectedOutput or "", -- 1522
					filesHint = item.filesHint or ({}), -- 1523
					resultFilePath = item.resultFilePath or "", -- 1524
					artifactDir = item.artifactDir or "", -- 1525
					changeSet = item.changeSet, -- 1526
					memoryEntry = item.memoryEntry -- 1527
				}, -- 1527
				"DONE" -- 1529
			) -- 1529
			if step then -- 1529
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1532
			end -- 1532
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1534
			i = i + 1 -- 1496
		end -- 1496
	end -- 1496
end -- 1496
function applyEvent(sessionId, event) -- 1546
	repeat -- 1546
		local ____switch252 = event.type -- 1546
		local ____cond252 = ____switch252 == "task_started" -- 1546
		if ____cond252 then -- 1546
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1549
			emitAgentSessionPatch( -- 1550
				sessionId, -- 1550
				{session = getSessionItem(sessionId)} -- 1550
			) -- 1550
			break -- 1553
		end -- 1553
		____cond252 = ____cond252 or ____switch252 == "decision_made" -- 1553
		if ____cond252 then -- 1553
			upsertStep( -- 1555
				sessionId, -- 1555
				event.taskId, -- 1555
				event.step, -- 1555
				event.tool, -- 1555
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1555
			) -- 1555
			emitAgentSessionPatch( -- 1561
				sessionId, -- 1561
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1561
			) -- 1561
			break -- 1564
		end -- 1564
		____cond252 = ____cond252 or ____switch252 == "tool_started" -- 1564
		if ____cond252 then -- 1564
			upsertStep( -- 1566
				sessionId, -- 1566
				event.taskId, -- 1566
				event.step, -- 1566
				event.tool, -- 1566
				{status = "RUNNING"} -- 1566
			) -- 1566
			emitAgentSessionPatch( -- 1569
				sessionId, -- 1569
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1569
			) -- 1569
			break -- 1572
		end -- 1572
		____cond252 = ____cond252 or ____switch252 == "tool_finished" -- 1572
		if ____cond252 then -- 1572
			upsertStep( -- 1574
				sessionId, -- 1574
				event.taskId, -- 1574
				event.step, -- 1574
				event.tool, -- 1574
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1574
			) -- 1574
			emitAgentSessionPatch( -- 1579
				sessionId, -- 1579
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1579
			) -- 1579
			break -- 1582
		end -- 1582
		____cond252 = ____cond252 or ____switch252 == "checkpoint_created" -- 1582
		if ____cond252 then -- 1582
			upsertStep( -- 1584
				sessionId, -- 1584
				event.taskId, -- 1584
				event.step, -- 1584
				event.tool, -- 1584
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1584
			) -- 1584
			emitAgentSessionPatch( -- 1589
				sessionId, -- 1589
				{ -- 1589
					step = getStepItem(sessionId, event.taskId, event.step), -- 1590
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1591
				} -- 1591
			) -- 1591
			break -- 1593
		end -- 1593
		____cond252 = ____cond252 or ____switch252 == "memory_compression_started" -- 1593
		if ____cond252 then -- 1593
			upsertStep( -- 1595
				sessionId, -- 1595
				event.taskId, -- 1595
				event.step, -- 1595
				event.tool, -- 1595
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1595
			) -- 1595
			emitAgentSessionPatch( -- 1600
				sessionId, -- 1600
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1600
			) -- 1600
			break -- 1603
		end -- 1603
		____cond252 = ____cond252 or ____switch252 == "memory_compression_finished" -- 1603
		if ____cond252 then -- 1603
			upsertStep( -- 1605
				sessionId, -- 1605
				event.taskId, -- 1605
				event.step, -- 1605
				event.tool, -- 1605
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1605
			) -- 1605
			emitAgentSessionPatch( -- 1610
				sessionId, -- 1610
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1610
			) -- 1610
			break -- 1613
		end -- 1613
		____cond252 = ____cond252 or ____switch252 == "metrics_updated" -- 1613
		if ____cond252 then -- 1613
			do -- 1613
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1615
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1616
				break -- 1619
			end -- 1619
		end -- 1619
		____cond252 = ____cond252 or ____switch252 == "assistant_message_updated" -- 1619
		if ____cond252 then -- 1619
			do -- 1619
				upsertStep( -- 1622
					sessionId, -- 1622
					event.taskId, -- 1622
					event.step, -- 1622
					"message", -- 1622
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1622
				) -- 1622
				emitAgentSessionPatch( -- 1627
					sessionId, -- 1627
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1627
				) -- 1627
				break -- 1630
			end -- 1630
		end -- 1630
		____cond252 = ____cond252 or ____switch252 == "task_finished" -- 1630
		if ____cond252 then -- 1630
			do -- 1630
				local ____opt_31 = activeStopTokens[event.taskId or -1] -- 1630
				local stopped = (____opt_31 and ____opt_31.stopped) == true -- 1633
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1634
				local session = getSessionItem(sessionId) -- 1637
				local isSubSession = (session and session.kind) == "sub" -- 1638
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1639
				if isSubSession and event.taskId ~= nil then -- 1639
					finalizingSubSessionTaskIds[event.taskId] = true -- 1641
				end -- 1641
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1643
				if event.taskId ~= nil then -- 1643
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1645
					local ____finalizeTaskSteps_37 = finalizeTaskSteps -- 1646
					local ____array_36 = __TS__SparseArrayNew( -- 1646
						sessionId, -- 1647
						event.taskId, -- 1648
						type(event.steps) == "number" and math.max( -- 1649
							0, -- 1649
							math.floor(event.steps) -- 1649
						) or nil -- 1649
					) -- 1649
					local ____event_success_35 -- 1650
					if event.success then -- 1650
						____event_success_35 = nil -- 1650
					else -- 1650
						____event_success_35 = stopped and "STOPPED" or "FAILED" -- 1650
					end -- 1650
					__TS__SparseArrayPush(____array_36, ____event_success_35) -- 1650
					____finalizeTaskSteps_37(__TS__SparseArraySpread(____array_36)) -- 1646
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1652
					if not isSubSession then -- 1652
						activeStopTokens[event.taskId] = nil -- 1654
					end -- 1654
					emitAgentSessionPatch( -- 1656
						sessionId, -- 1656
						{ -- 1656
							session = getSessionItem(sessionId), -- 1657
							message = getMessageItem(messageId), -- 1658
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1659
							removedStepIds = removedStepIds -- 1660
						} -- 1660
					) -- 1660
				end -- 1660
				if session and session.kind == "main" then -- 1660
					flushPendingSubAgentHandoffs(session) -- 1664
				end -- 1664
				break -- 1666
			end -- 1666
		end -- 1666
	until true -- 1666
end -- 1666
function ____exports.createSession(projectRoot, title) -- 1803
	if title == nil then -- 1803
		title = "" -- 1803
	end -- 1803
	if not isValidProjectRoot(projectRoot) then -- 1803
		return {success = false, message = "invalid projectRoot"} -- 1805
	end -- 1805
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1807
	if row then -- 1807
		return { -- 1816
			success = true, -- 1816
			session = rowToSession(row) -- 1816
		} -- 1816
	end -- 1816
	local t = now() -- 1818
	DB:exec( -- 1819
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1819
		{ -- 1822
			projectRoot, -- 1822
			title ~= "" and title or Path:getFilename(projectRoot), -- 1822
			t, -- 1822
			t -- 1822
		} -- 1822
	) -- 1822
	local sessionId = getLastInsertRowId() -- 1824
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1825
	local session = getSessionItem(sessionId) -- 1826
	if not session then -- 1826
		return {success = false, message = "failed to create session"} -- 1828
	end -- 1828
	return {success = true, session = session} -- 1830
end -- 1803
function ____exports.createSubSession(parentSessionId, title) -- 1833
	if title == nil then -- 1833
		title = "" -- 1833
	end -- 1833
	local parent = getSessionItem(parentSessionId) -- 1834
	if not parent then -- 1834
		return {success = false, message = "parent session not found"} -- 1836
	end -- 1836
	local rootId = getSessionRootId(parent) -- 1838
	local t = now() -- 1839
	DB:exec( -- 1840
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1840
		{ -- 1843
			parent.projectRoot, -- 1843
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1843
			rootId, -- 1843
			parent.id, -- 1843
			t, -- 1843
			t -- 1843
		} -- 1843
	) -- 1843
	local sessionId = getLastInsertRowId() -- 1845
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1846
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1847
	local session = getSessionItem(sessionId) -- 1848
	if not session then -- 1848
		return {success = false, message = "failed to create sub session"} -- 1850
	end -- 1850
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1852
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1853
	subStorage:writeMemory(parentStorage:readMemory()) -- 1854
	return {success = true, session = session} -- 1855
end -- 1833
function spawnSubAgentSession(request) -- 1858
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1858
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1869
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1870
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1871
		if normalizedPrompt == "" then -- 1871
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1873
		end -- 1873
		if normalizedPrompt == "" then -- 1873
			local ____Log_43 = Log -- 1880
			local ____temp_40 = #normalizedTitle -- 1880
			local ____temp_41 = #rawPrompt -- 1880
			local ____temp_42 = #toStr(request.expectedOutput) -- 1880
			local ____opt_38 = request.filesHint -- 1880
			____Log_43( -- 1880
				"Warn", -- 1880
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_40)) .. " raw_prompt_len=") .. tostring(____temp_41)) .. " expected_len=") .. tostring(____temp_42)) .. " files_hint_count=") .. tostring(____opt_38 and #____opt_38 or 0) -- 1880
			) -- 1880
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1880
		end -- 1880
		Log( -- 1883
			"Info", -- 1883
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1883
		) -- 1883
		local parentSessionId = request.parentSessionId -- 1884
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1884
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1886
			if not fallbackParent then -- 1886
				local createdMain = ____exports.createSession(request.projectRoot) -- 1888
				if createdMain.success then -- 1888
					fallbackParent = createdMain.session -- 1890
				end -- 1890
			end -- 1890
			if fallbackParent then -- 1890
				Log( -- 1894
					"Warn", -- 1894
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1894
				) -- 1894
				parentSessionId = fallbackParent.id -- 1895
			end -- 1895
		end -- 1895
		local parentSession = getSessionItem(parentSessionId) -- 1898
		if not parentSession then -- 1898
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1898
		end -- 1898
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1902
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1902
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1902
		end -- 1902
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1906
		if not created.success then -- 1906
			return ____awaiter_resolve(nil, created) -- 1906
		end -- 1906
		writeSpawnInfo( -- 1910
			created.session.projectRoot, -- 1910
			created.session.memoryScope, -- 1910
			{ -- 1910
				sessionId = created.session.id, -- 1911
				rootSessionId = created.session.rootSessionId, -- 1912
				parentSessionId = created.session.parentSessionId, -- 1913
				title = created.session.title, -- 1914
				prompt = normalizedPrompt, -- 1915
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1916
				expectedOutput = request.expectedOutput or "", -- 1917
				filesHint = request.filesHint or ({}), -- 1918
				status = "RUNNING", -- 1919
				success = false, -- 1920
				resultFilePath = "", -- 1921
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1922
				sourceTaskId = 0, -- 1923
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1924
				createdAtTs = created.session.createdAt, -- 1925
				finishedAt = "", -- 1926
				finishedAtTs = 0 -- 1927
			} -- 1927
		) -- 1927
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1929
		if not sent.success then -- 1929
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1929
		end -- 1929
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1929
	end) -- 1929
end -- 1929
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2010
	local rootSession = getRootSessionItem(session.id) -- 2011
	if not rootSession then -- 2011
		return -- 2012
	end -- 2012
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2013
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2014
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2015
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2016
	local queueResult = writePendingHandoff( -- 2017
		rootSession.projectRoot, -- 2017
		rootSession.memoryScope, -- 2017
		{ -- 2017
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2018
			sourceSessionId = session.id, -- 2019
			sourceTitle = session.title, -- 2020
			sourceTaskId = taskId, -- 2021
			message = summary, -- 2022
			prompt = result.prompt, -- 2023
			goal = result.goal, -- 2024
			expectedOutput = result.expectedOutput or "", -- 2025
			filesHint = result.filesHint or ({}), -- 2026
			success = result.success, -- 2027
			resultFilePath = result.resultFilePath, -- 2028
			artifactDir = result.artifactDir, -- 2029
			finishedAt = result.finishedAt, -- 2030
			changeSet = changeSet, -- 2031
			memoryEntry = result.memoryEntry, -- 2032
			createdAt = createdAt -- 2033
		} -- 2033
	) -- 2033
	if not queueResult then -- 2033
		Log( -- 2036
			"Warn", -- 2036
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2036
		) -- 2036
		return -- 2037
	end -- 2037
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2037
		flushPendingSubAgentHandoffs(rootSession) -- 2040
	end -- 2040
end -- 2040
function finalizeSubSession(session, taskId, success, message) -- 2044
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2044
		local rootSessionId = getSessionRootId(session) -- 2045
		local rootSession = getRootSessionItem(session.id) -- 2046
		if not rootSession then -- 2046
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2046
		end -- 2046
		local spawnInfo = getSessionSpawnInfo(session) -- 2050
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2051
		local finishedAtTs = now() -- 2052
		local resultText = sanitizeUTF8(message) -- 2053
		local changeSet = getTaskChangeSetSummary(taskId) -- 2054
		local record = { -- 2055
			sessionId = session.id, -- 2056
			rootSessionId = rootSessionId, -- 2057
			parentSessionId = session.parentSessionId, -- 2058
			title = session.title, -- 2059
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2060
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2061
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2062
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2063
			status = success and "DONE" or "FAILED", -- 2064
			success = success, -- 2065
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2066
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2067
			sourceTaskId = taskId, -- 2068
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2069
			finishedAt = finishedAt, -- 2070
			createdAtTs = session.createdAt, -- 2071
			finishedAtTs = finishedAtTs, -- 2072
			changeSet = changeSet -- 2073
		} -- 2073
		if record.success then -- 2073
			local memoryEntryResult = __TS__Await(generateSubAgentMemoryEntry(session, record, resultText)) -- 2076
			record.memoryEntry = memoryEntryResult.entry -- 2077
			if memoryEntryResult.error and memoryEntryResult.error ~= "" then -- 2077
				record.memoryEntryError = memoryEntryResult.error -- 2079
				Log( -- 2080
					"Warn", -- 2080
					(("[AgentSession] sub session memory entry failed session=" .. tostring(session.id)) .. " error=") .. memoryEntryResult.error -- 2080
				) -- 2080
			end -- 2080
		end -- 2080
		if not writeSubAgentResultFile(session, record, resultText) then -- 2080
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2080
		end -- 2080
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2080
			sessionId = record.sessionId, -- 2087
			rootSessionId = record.rootSessionId, -- 2088
			parentSessionId = record.parentSessionId, -- 2089
			title = record.title, -- 2090
			prompt = record.prompt, -- 2091
			goal = record.goal, -- 2092
			expectedOutput = record.expectedOutput or "", -- 2093
			filesHint = record.filesHint or ({}), -- 2094
			status = record.status, -- 2095
			success = record.success, -- 2096
			resultFilePath = record.resultFilePath, -- 2097
			artifactDir = record.artifactDir, -- 2098
			sourceTaskId = record.sourceTaskId, -- 2099
			createdAt = record.createdAt, -- 2100
			finishedAt = record.finishedAt, -- 2101
			createdAtTs = record.createdAtTs, -- 2102
			finishedAtTs = record.finishedAtTs, -- 2103
			changeSet = record.changeSet, -- 2104
			memoryEntry = record.memoryEntry, -- 2105
			memoryEntryError = record.memoryEntryError -- 2106
		}) then -- 2106
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2106
		end -- 2106
		if success then -- 2106
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2111
			deleteSessionRecords(session.id, true) -- 2112
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2113
		end -- 2113
		return ____awaiter_resolve(nil, {success = true}) -- 2113
	end) -- 2113
end -- 2113
function stopClearedSubSession(session, taskId) -- 2118
	local spawnInfo = getSessionSpawnInfo(session) -- 2119
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2120
	local rootSessionId = getSessionRootId(session) -- 2121
	Tools.setTaskStatus(taskId, "STOPPED") -- 2122
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2123
	if not writeSpawnInfo( -- 2123
		session.projectRoot, -- 2124
		session.memoryScope, -- 2124
		{ -- 2124
			sessionId = session.id, -- 2125
			rootSessionId = rootSessionId, -- 2126
			parentSessionId = session.parentSessionId, -- 2127
			title = session.title, -- 2128
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2129
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2130
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2131
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2132
			status = "STOPPED", -- 2133
			success = false, -- 2134
			cleared = true, -- 2135
			resultFilePath = "", -- 2136
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2137
			sourceTaskId = taskId, -- 2138
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2139
			finishedAt = finishedAt, -- 2140
			createdAtTs = session.createdAt, -- 2141
			finishedAtTs = now() -- 2142
		} -- 2142
	) then -- 2142
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2144
	end -- 2144
	deleteSessionRecords(session.id, true) -- 2146
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2147
	return {success = true} -- 2148
end -- 2148
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 2151
	if allowSubSessionStart == nil then -- 2151
		allowSubSessionStart = false -- 2151
	end -- 2151
	local session = getSessionItem(sessionId) -- 2152
	if not session then -- 2152
		return {success = false, message = "session not found"} -- 2154
	end -- 2154
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2154
		return {success = false, message = "session task is finalizing"} -- 2157
	end -- 2157
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2157
		return {success = false, message = "session task is still running"} -- 2160
	end -- 2160
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2162
	if normalizedPrompt == "" and session.kind == "sub" then -- 2162
		local spawnInfo = getSessionSpawnInfo(session) -- 2164
		if spawnInfo then -- 2164
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2166
			if normalizedPrompt == "" then -- 2166
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2168
			end -- 2168
		end -- 2168
	end -- 2168
	if normalizedPrompt == "" then -- 2168
		return {success = false, message = "prompt is empty"} -- 2177
	end -- 2177
	local taskRes = Tools.createTask(normalizedPrompt) -- 2179
	if not taskRes.success then -- 2179
		return {success = false, message = taskRes.message} -- 2181
	end -- 2181
	local taskId = taskRes.taskId -- 2183
	local useChineseResponse = getDefaultUseChineseResponse() -- 2184
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 2185
	local stopToken = {stopped = false} -- 2186
	activeStopTokens[taskId] = stopToken -- 2187
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 2188
	runCodingAgent( -- 2189
		{ -- 2189
			prompt = normalizedPrompt, -- 2190
			workDir = session.projectRoot, -- 2191
			useChineseResponse = useChineseResponse, -- 2192
			taskId = taskId, -- 2193
			sessionId = sessionId, -- 2194
			memoryScope = session.memoryScope, -- 2195
			role = session.kind, -- 2196
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2197
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2200
			stopToken = stopToken, -- 2203
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 2204
		}, -- 2204
		function(result) -- 2205
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2205
				local nextSession = getSessionItem(sessionId) -- 2206
				if nextSession and nextSession.kind == "sub" then -- 2206
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2206
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2209
						if not stopped.success then -- 2209
							Log( -- 2211
								"Warn", -- 2211
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2211
							) -- 2211
							emitAgentSessionPatch( -- 2212
								sessionId, -- 2212
								{session = getSessionItem(sessionId)} -- 2212
							) -- 2212
						end -- 2212
						activeStopTokens[taskId] = nil -- 2216
						return ____awaiter_resolve(nil) -- 2216
					end -- 2216
					setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 2219
					emitAgentSessionPatch( -- 2220
						sessionId, -- 2220
						{session = getSessionItem(sessionId)} -- 2220
					) -- 2220
					local finalized = __TS__Await(finalizeSubSession(nextSession, taskId, result.success, result.message)) -- 2223
					if not finalized.success then -- 2223
						Log( -- 2225
							"Warn", -- 2225
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2225
						) -- 2225
					end -- 2225
					local finalizedSession = getSessionItem(sessionId) -- 2227
					if finalizedSession then -- 2227
						local stopped = stopToken.stopped == true -- 2229
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2230
						setSessionState(sessionId, finalStatus, taskId, finalStatus) -- 2233
						emitAgentSessionPatch( -- 2234
							sessionId, -- 2234
							{session = getSessionItem(sessionId)} -- 2234
						) -- 2234
					end -- 2234
					activeStopTokens[taskId] = nil -- 2238
					finalizingSubSessionTaskIds[taskId] = nil -- 2239
				end -- 2239
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2239
					applyEvent(sessionId, { -- 2242
						type = "task_finished", -- 2243
						sessionId = sessionId, -- 2244
						taskId = result.taskId, -- 2245
						success = false, -- 2246
						message = result.message, -- 2247
						steps = result.steps -- 2248
					}) -- 2248
				end -- 2248
			end) -- 2248
		end -- 2205
	) -- 2205
	return {success = true, sessionId = sessionId, taskId = taskId} -- 2252
end -- 2151
function ____exports.listRunningSubAgents(request) -- 2302
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2302
		local session = getSessionItem(request.sessionId) -- 2310
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2310
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2312
		end -- 2312
		if not session then -- 2312
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2312
		end -- 2312
		local rootSession = getRootSessionItem(session.id) -- 2317
		if not rootSession then -- 2317
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2317
		end -- 2317
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2321
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2322
		local limit = math.max( -- 2323
			1, -- 2323
			math.floor(tonumber(request.limit) or 5) -- 2323
		) -- 2323
		local offset = math.max( -- 2324
			0, -- 2324
			math.floor(tonumber(request.offset) or 0) -- 2324
		) -- 2324
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2325
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2326
		local runningSessions = {} -- 2333
		do -- 2333
			local i = 0 -- 2334
			while i < #rows do -- 2334
				do -- 2334
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2335
					if current.currentTaskStatus ~= "RUNNING" then -- 2335
						goto __continue349 -- 2337
					end -- 2337
					local spawnInfo = getSessionSpawnInfo(current) -- 2339
					runningSessions[#runningSessions + 1] = { -- 2340
						sessionId = current.id, -- 2341
						title = current.title, -- 2342
						parentSessionId = current.parentSessionId, -- 2343
						rootSessionId = current.rootSessionId, -- 2344
						status = "RUNNING", -- 2345
						currentTaskId = current.currentTaskId, -- 2346
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2347
						goal = spawnInfo and spawnInfo.goal, -- 2348
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2349
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2350
						createdAt = current.createdAt, -- 2351
						updatedAt = current.updatedAt -- 2352
					} -- 2352
				end -- 2352
				::__continue349:: -- 2352
				i = i + 1 -- 2334
			end -- 2334
		end -- 2334
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2355
		local completedSessions = __TS__ArrayMap( -- 2356
			completedRecords, -- 2356
			function(____, record) return { -- 2356
				sessionId = record.sessionId, -- 2357
				title = record.title, -- 2358
				parentSessionId = record.parentSessionId, -- 2359
				rootSessionId = record.rootSessionId, -- 2360
				status = record.status, -- 2361
				goal = record.goal, -- 2362
				expectedOutput = record.expectedOutput, -- 2363
				filesHint = record.filesHint, -- 2364
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2365
				success = record.success, -- 2366
				cleared = record.cleared, -- 2367
				resultFilePath = record.resultFilePath, -- 2368
				artifactDir = record.artifactDir, -- 2369
				finishedAt = record.finishedAt, -- 2370
				createdAt = record.createdAtTs, -- 2371
				updatedAt = record.finishedAtTs -- 2372
			} end -- 2372
		) -- 2372
		local merged = {} -- 2374
		if status == "running" then -- 2374
			merged = runningSessions -- 2376
		elseif status == "done" then -- 2376
			merged = __TS__ArrayFilter( -- 2378
				completedSessions, -- 2378
				function(____, item) return item.status == "DONE" end -- 2378
			) -- 2378
		elseif status == "failed" then -- 2378
			merged = __TS__ArrayFilter( -- 2380
				completedSessions, -- 2380
				function(____, item) return item.status == "FAILED" end -- 2380
			) -- 2380
		elseif status == "stopped" then -- 2380
			merged = __TS__ArrayFilter( -- 2382
				completedSessions, -- 2382
				function(____, item) return item.status == "STOPPED" end -- 2382
			) -- 2382
		elseif status == "all" then -- 2382
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2384
		else -- 2384
			local runningKeys = {} -- 2386
			do -- 2386
				local i = 0 -- 2387
				while i < #runningSessions do -- 2387
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2388
					i = i + 1 -- 2387
				end -- 2387
			end -- 2387
			local latestCompletedByKey = {} -- 2390
			do -- 2390
				local i = 0 -- 2391
				while i < #completedSessions do -- 2391
					do -- 2391
						local item = completedSessions[i + 1] -- 2392
						local key = getSubAgentDisplayKey(item) -- 2393
						if runningKeys[key] then -- 2393
							goto __continue364 -- 2395
						end -- 2395
						local current = latestCompletedByKey[key] -- 2397
						if not current or item.updatedAt > current.updatedAt then -- 2397
							latestCompletedByKey[key] = item -- 2399
						end -- 2399
					end -- 2399
					::__continue364:: -- 2399
					i = i + 1 -- 2391
				end -- 2391
			end -- 2391
			local latestCompleted = {} -- 2402
			for ____, item in pairs(latestCompletedByKey) do -- 2403
				latestCompleted[#latestCompleted + 1] = item -- 2404
			end -- 2404
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2406
		end -- 2406
		if query ~= "" then -- 2406
			merged = __TS__ArrayFilter( -- 2409
				merged, -- 2409
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2409
			) -- 2409
		end -- 2409
		__TS__ArraySort( -- 2415
			merged, -- 2415
			function(____, a, b) -- 2415
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2415
					return -1 -- 2416
				end -- 2416
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2416
					return 1 -- 2417
				end -- 2417
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2417
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2419
				end -- 2419
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2421
			end -- 2415
		) -- 2415
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2423
		return ____awaiter_resolve(nil, { -- 2423
			success = true, -- 2425
			rootSessionId = rootSession.id, -- 2426
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2427
			status = status, -- 2428
			limit = limit, -- 2429
			offset = offset, -- 2430
			hasMore = offset + limit < #merged, -- 2431
			sessions = paged -- 2432
		}) -- 2432
	end) -- 2432
end -- 2302
TABLE_SESSION = "AgentSession" -- 193
TABLE_MESSAGE = "AgentSessionMessage" -- 194
TABLE_STEP = "AgentSessionStep" -- 195
TABLE_TASK = "AgentTask" -- 196
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 197
SPAWN_INFO_FILE = "SPAWN.json" -- 198
RESULT_FILE = "RESULT.md" -- 199
PENDING_HANDOFF_DIR = "pending-handoffs" -- 200
MAX_CONCURRENT_SUB_AGENTS = 4 -- 201
SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE = 0.1 -- 202
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS = 1024 -- 203
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY = 3 -- 204
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 205
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 206
SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS = 3000 -- 207
SUB_AGENT_MEMORY_RESULT_MAX_TOKENS = 2000 -- 208
SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES = 20 -- 209
SUB_AGENT_MEMORY_TAIL_MAX_TOKENS = 4000 -- 210
SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS = 600 -- 211
activeStopTokens = {} -- 257
finalizingSubSessionTaskIds = {} -- 258
now = function() return os.time() end -- 259
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 622
	if projectRoot == oldRoot then -- 622
		return newRoot -- 624
	end -- 624
	for ____, separator in ipairs({"/", "\\"}) do -- 626
		local prefix = oldRoot .. separator -- 627
		if __TS__StringStartsWith(projectRoot, prefix) then -- 627
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 629
		end -- 629
	end -- 629
	return nil -- 632
end -- 622
local function sanitizeStoredSteps(sessionId) -- 1416
	DB:exec( -- 1417
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1417
		{ -- 1435
			now(), -- 1435
			sessionId -- 1435
		} -- 1435
	) -- 1435
end -- 1416
local function getSchemaVersion() -- 1671
	local row = queryOne("PRAGMA user_version") -- 1672
	return row and type(row[1]) == "number" and row[1] or 0 -- 1673
end -- 1671
local function setSchemaVersion(version) -- 1676
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1677
		0, -- 1677
		math.floor(version) -- 1677
	))) -- 1677
end -- 1676
local function hasTableColumn(tableName, columnName) -- 1680
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1681
	do -- 1681
		local i = 0 -- 1682
		while i < #rows do -- 1682
			local row = rows[i + 1] -- 1683
			if toStr(row[2]) == columnName then -- 1683
				return true -- 1685
			end -- 1685
			i = i + 1 -- 1682
		end -- 1682
	end -- 1682
	return false -- 1688
end -- 1680
local function ensureSessionMetricsColumn() -- 1691
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1691
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1693
	end -- 1693
end -- 1691
local function recreateSchema() -- 1697
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1698
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1699
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1700
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1701
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1716
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1717
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1726
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1727
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1744
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1745
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1746
end -- 1697
do -- 1697
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1697
		recreateSchema() -- 1752
	else -- 1752
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t\t);") -- 1754
		ensureSessionMetricsColumn() -- 1769
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1770
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1771
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1780
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1781
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1798
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1799
	end -- 1799
end -- 1799
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1941
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1941
		return {success = false, message = "invalid projectRoot"} -- 1943
	end -- 1943
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1945
	for ____, row in ipairs(rows) do -- 1946
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1947
		if sessionId > 0 then -- 1947
			deleteSessionRecords(sessionId) -- 1949
		end -- 1949
	end -- 1949
	return {success = true, deleted = #rows} -- 1952
end -- 1941
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1955
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1955
		return {success = false, message = "invalid projectRoot"} -- 1957
	end -- 1957
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1959
	local renamed = 0 -- 1960
	for ____, row in ipairs(rows) do -- 1961
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1962
		local projectRoot = toStr(row[2]) -- 1963
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1964
		if sessionId > 0 and nextProjectRoot then -- 1964
			DB:exec( -- 1966
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1966
				{ -- 1968
					nextProjectRoot, -- 1968
					Path:getFilename(nextProjectRoot), -- 1968
					now(), -- 1968
					sessionId -- 1968
				} -- 1968
			) -- 1968
			renamed = renamed + 1 -- 1970
		end -- 1970
	end -- 1970
	return {success = true, renamed = renamed} -- 1973
end -- 1955
function ____exports.getSession(sessionId) -- 1976
	local session = getSessionItem(sessionId) -- 1977
	if not session then -- 1977
		return {success = false, message = "session not found"} -- 1979
	end -- 1979
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1981
	local relatedSessions = listRelatedSessions(sessionId) -- 1982
	sanitizeStoredSteps(sessionId) -- 1983
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1984
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1991
	local ____relatedSessions_45 = relatedSessions -- 2002
	local ____temp_44 -- 2003
	if normalizedSession.kind == "sub" then -- 2003
		____temp_44 = getSessionSpawnInfo(normalizedSession) -- 2003
	else -- 2003
		____temp_44 = nil -- 2003
	end -- 2003
	return { -- 1999
		success = true, -- 2000
		session = normalizedSession, -- 2001
		relatedSessions = ____relatedSessions_45, -- 2002
		spawnInfo = ____temp_44, -- 2003
		messages = __TS__ArrayMap( -- 2004
			messages, -- 2004
			function(____, row) return rowToMessage(row) end -- 2004
		), -- 2004
		steps = __TS__ArrayMap( -- 2005
			steps, -- 2005
			function(____, row) return rowToStep(row) end -- 2005
		), -- 2005
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 2006
	} -- 2006
end -- 1976
function ____exports.stopSessionTask(sessionId) -- 2255
	local session = getSessionItem(sessionId) -- 2256
	if not session or session.currentTaskId == nil then -- 2256
		return {success = false, message = "session task not found"} -- 2258
	end -- 2258
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2258
		return {success = false, message = "session task is finalizing"} -- 2261
	end -- 2261
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2263
	local stopToken = activeStopTokens[session.currentTaskId] -- 2264
	if not stopToken then -- 2264
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2264
			return {success = true, recovered = true} -- 2267
		end -- 2267
		return {success = false, message = "task is not running"} -- 2269
	end -- 2269
	stopToken.stopped = true -- 2271
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2272
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2273
	return {success = true} -- 2274
end -- 2255
function ____exports.getCurrentTaskId(sessionId) -- 2277
	local ____opt_66 = getSessionItem(sessionId) -- 2277
	return ____opt_66 and ____opt_66.currentTaskId -- 2278
end -- 2277
function ____exports.listRunningSessions() -- 2281
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2282
	local sessions = {} -- 2289
	do -- 2289
		local i = 0 -- 2290
		while i < #rows do -- 2290
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2291
			if session.currentTaskStatus == "RUNNING" then -- 2291
				sessions[#sessions + 1] = session -- 2293
			end -- 2293
			i = i + 1 -- 2290
		end -- 2290
	end -- 2290
	return {success = true, sessions = sessions} -- 2296
end -- 2281
return ____exports -- 2281