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
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildSubAgentMemoryEntryLLMOptions, buildSubAgentMemoryEntryToolSchema, buildSubAgentMemoryEntrySystemPrompt, formatSubAgentMemoryTailMessage, buildSubAgentRecentMessageTail, buildSubAgentMemoryEntryPrompt, buildSubAgentMemoryEntryRetryPrompt, normalizeGeneratedSubAgentMemoryEntry, getMemoryEntryToolFunction, getMemoryEntryPlainContent, decodeMemoryEntryFromPlainContent, hasEmptyMemoryEntryContent, generateSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS, SUB_AGENT_MEMORY_RESULT_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
local AgentToolRegistry = require("Agent.AgentToolRegistry") -- 4
local Tools = require("Agent.Tools") -- 5
local ____Memory = require("Agent.Memory") -- 6
local DualLayerStorage = ____Memory.DualLayerStorage -- 6
local ____Utils = require("Agent.Utils") -- 7
local Log = ____Utils.Log -- 7
local callLLM = ____Utils.callLLM -- 7
local clipTextToTokenBudget = ____Utils.clipTextToTokenBudget -- 7
local estimateTextTokens = ____Utils.estimateTextTokens -- 7
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 7
local safeJsonDecode = ____Utils.safeJsonDecode -- 7
local safeJsonEncode = ____Utils.safeJsonEncode -- 7
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 7
function getDefaultUseChineseResponse() -- 265
	local zh = string.match(App.locale, "^zh") -- 266
	return zh ~= nil -- 267
end -- 267
function toStr(v) -- 270
	if v == false or v == nil then -- 270
		return "" -- 271
	end -- 271
	return tostring(v) -- 272
end -- 272
function encodeJson(value) -- 275
	local text = safeJsonEncode(value) -- 276
	return text or "" -- 277
end -- 277
function decodeJsonObject(text) -- 280
	if not text or text == "" then -- 280
		return nil -- 281
	end -- 281
	local value = safeJsonDecode(text) -- 282
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 282
		return value -- 284
	end -- 284
	return nil -- 286
end -- 286
function decodeJsonFiles(text) -- 289
	if not text or text == "" then -- 289
		return nil -- 290
	end -- 290
	local value = safeJsonDecode(text) -- 291
	if not value or not __TS__ArrayIsArray(value) then -- 291
		return nil -- 292
	end -- 292
	local files = {} -- 293
	do -- 293
		local i = 0 -- 294
		while i < #value do -- 294
			do -- 294
				local item = value[i + 1] -- 295
				if type(item) ~= "table" then -- 295
					goto __continue14 -- 296
				end -- 296
				files[#files + 1] = { -- 297
					path = sanitizeUTF8(toStr(item.path)), -- 298
					op = sanitizeUTF8(toStr(item.op)) -- 299
				} -- 299
			end -- 299
			::__continue14:: -- 299
			i = i + 1 -- 294
		end -- 294
	end -- 294
	return files -- 302
end -- 302
function decodeChangeSetSummary(value) -- 305
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 305
		return nil -- 306
	end -- 306
	local row = value -- 307
	if row.success ~= true then -- 307
		return nil -- 308
	end -- 308
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 309
	if taskId <= 0 then -- 309
		return nil -- 310
	end -- 310
	local files = {} -- 311
	if __TS__ArrayIsArray(row.files) then -- 311
		do -- 311
			local i = 0 -- 313
			while i < #row.files do -- 313
				do -- 313
					local file = row.files[i + 1] -- 314
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 314
						goto __continue22 -- 315
					end -- 315
					local fileRow = file -- 316
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 317
					if path == "" then -- 317
						goto __continue22 -- 318
					end -- 318
					local checkpointIds = {} -- 319
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 319
						do -- 319
							local j = 0 -- 321
							while j < #fileRow.checkpointIds do -- 321
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 322
								if checkpointId > 0 then -- 322
									checkpointIds[#checkpointIds + 1] = checkpointId -- 323
								end -- 323
								j = j + 1 -- 321
							end -- 321
						end -- 321
					end -- 321
					local op = toStr(fileRow.op) -- 326
					files[#files + 1] = { -- 327
						path = path, -- 328
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 329
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 330
						checkpointIds = checkpointIds -- 331
					} -- 331
				end -- 331
				::__continue22:: -- 331
				i = i + 1 -- 313
			end -- 313
		end -- 313
	end -- 313
	return { -- 335
		success = true, -- 336
		taskId = taskId, -- 337
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 338
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 339
		files = files, -- 340
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 341
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 342
	} -- 342
end -- 342
function takeUtf8Head(text, maxChars) -- 346
	if maxChars <= 0 or text == "" then -- 346
		return "" -- 347
	end -- 347
	local nextPos = utf8.offset(text, maxChars + 1) -- 348
	if nextPos == nil then -- 348
		return text -- 349
	end -- 349
	return string.sub(text, 1, nextPos - 1) -- 350
end -- 350
function normalizeMemoryEntryEvidence(value) -- 353
	local evidence = {} -- 354
	if not __TS__ArrayIsArray(value) then -- 354
		return evidence -- 355
	end -- 355
	do -- 355
		local i = 0 -- 356
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 356
			do -- 356
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 357
				if item == "" then -- 357
					goto __continue35 -- 358
				end -- 358
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 358
					evidence[#evidence + 1] = item -- 360
				end -- 360
			end -- 360
			::__continue35:: -- 360
			i = i + 1 -- 356
		end -- 356
	end -- 356
	return evidence -- 363
end -- 363
function decodeSubAgentMemoryEntry(value) -- 366
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 366
		return nil -- 367
	end -- 367
	local row = value -- 368
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 369
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 370
	local content = takeUtf8Head( -- 371
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 371
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 371
	) -- 371
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 371
		return nil -- 372
	end -- 372
	return { -- 373
		sourceSessionId = sourceSessionId, -- 374
		sourceTaskId = sourceTaskId, -- 375
		content = content, -- 376
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 377
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 378
	} -- 378
end -- 378
function getTaskChangeSetSummary(taskId) -- 382
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 383
	return summary.success and summary or nil -- 384
end -- 384
function queryRows(sql, args) -- 387
	local ____args_0 -- 388
	if args then -- 388
		____args_0 = DB:query(sql, args) -- 388
	else -- 388
		____args_0 = DB:query(sql) -- 388
	end -- 388
	return ____args_0 -- 388
end -- 388
function queryOne(sql, args) -- 391
	local rows = queryRows(sql, args) -- 392
	if not rows or #rows == 0 then -- 392
		return nil -- 393
	end -- 393
	return rows[1] -- 394
end -- 394
function getLastInsertRowId() -- 397
	local row = queryOne("SELECT last_insert_rowid()") -- 398
	return row and (row[1] or 0) or 0 -- 399
end -- 399
function isValidProjectRoot(path) -- 402
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 403
end -- 403
function rowToSession(row) -- 406
	return { -- 407
		id = row[1], -- 408
		projectRoot = toStr(row[2]), -- 409
		title = toStr(row[3]), -- 410
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 411
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 412
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 413
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 414
		status = toStr(row[8]), -- 415
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 416
		currentTaskStatus = toStr(row[10]), -- 417
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 418
		createdAt = row[11], -- 419
		updatedAt = row[12], -- 420
		metrics = decodeJsonObject(toStr(row[13])) -- 421
	} -- 421
end -- 421
function rowToMessage(row) -- 425
	return { -- 426
		id = row[1], -- 427
		sessionId = row[2], -- 428
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 429
		role = toStr(row[4]), -- 430
		content = toStr(row[5]), -- 431
		createdAt = row[6], -- 432
		updatedAt = row[7] -- 433
	} -- 433
end -- 433
function rowToStep(row) -- 437
	return { -- 438
		id = row[1], -- 439
		sessionId = row[2], -- 440
		taskId = row[3], -- 441
		step = row[4], -- 442
		tool = toStr(row[5]), -- 443
		status = toStr(row[6]), -- 444
		reason = toStr(row[7]), -- 445
		reasoningContent = toStr(row[8]), -- 446
		params = decodeJsonObject(toStr(row[9])), -- 447
		result = decodeJsonObject(toStr(row[10])), -- 448
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 449
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 450
		files = decodeJsonFiles(toStr(row[13])), -- 451
		createdAt = row[14], -- 452
		updatedAt = row[15] -- 453
	} -- 453
end -- 453
function getMessageItem(messageId) -- 457
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 458
	return row and rowToMessage(row) or nil -- 464
end -- 464
function getStepItem(sessionId, taskId, step) -- 467
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 468
	return row and rowToStep(row) or nil -- 474
end -- 474
function deleteMessageSteps(sessionId, taskId) -- 477
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 478
	local ids = {} -- 483
	do -- 483
		local i = 0 -- 484
		while i < #rows do -- 484
			local row = rows[i + 1] -- 485
			if type(row[1]) == "number" then -- 485
				ids[#ids + 1] = row[1] -- 487
			end -- 487
			i = i + 1 -- 484
		end -- 484
	end -- 484
	if #ids > 0 then -- 484
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 491
	end -- 491
	return ids -- 497
end -- 497
function normalizeDisabledAgentTools(value) -- 500
	if not __TS__ArrayIsArray(value) then -- 500
		return {} -- 501
	end -- 501
	local tools = {} -- 502
	do -- 502
		local i = 0 -- 503
		while i < #value do -- 503
			do -- 503
				local name = value[i + 1] -- 504
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 504
					goto __continue60 -- 505
				end -- 505
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 505
					tools[#tools + 1] = name -- 506
				end -- 506
			end -- 506
			::__continue60:: -- 506
			i = i + 1 -- 503
		end -- 503
	end -- 503
	return tools -- 508
end -- 508
function getSessionRow(sessionId) -- 511
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 512
end -- 512
function getSessionItem(sessionId) -- 520
	local row = getSessionRow(sessionId) -- 521
	return row and rowToSession(row) or nil -- 522
end -- 522
function getTaskPrompt(taskId) -- 525
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 526
	if not row or type(row[1]) ~= "string" then -- 526
		return nil -- 527
	end -- 527
	return toStr(row[1]) -- 528
end -- 528
function getLatestMainSessionByProjectRoot(projectRoot) -- 531
	if not isValidProjectRoot(projectRoot) then -- 531
		return nil -- 532
	end -- 532
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 533
	return row and rowToSession(row) or nil -- 541
end -- 541
function countRunningSubSessions(rootSessionId) -- 544
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 545
	local count = 0 -- 552
	do -- 552
		local i = 0 -- 553
		while i < #rows do -- 553
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 554
			if session.currentTaskStatus == "RUNNING" then -- 554
				count = count + 1 -- 556
			end -- 556
			i = i + 1 -- 553
		end -- 553
	end -- 553
	return count -- 559
end -- 559
function deleteSessionRecords(sessionId, preserveArtifacts) -- 562
	if preserveArtifacts == nil then -- 562
		preserveArtifacts = false -- 562
	end -- 562
	local session = getSessionItem(sessionId) -- 563
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 564
	do -- 564
		local i = 0 -- 565
		while i < #children do -- 565
			local row = children[i + 1] -- 566
			if type(row[1]) == "number" and row[1] > 0 then -- 566
				deleteSessionRecords(row[1], preserveArtifacts) -- 568
			end -- 568
			i = i + 1 -- 565
		end -- 565
	end -- 565
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 571
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 572
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 573
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 574
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 574
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 576
	end -- 576
end -- 576
function getSessionRootId(session) -- 580
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 581
end -- 581
function getRootSessionItem(sessionId) -- 584
	local session = getSessionItem(sessionId) -- 585
	if not session then -- 585
		return nil -- 586
	end -- 586
	return getSessionItem(getSessionRootId(session)) or session -- 587
end -- 587
function listRelatedSessions(sessionId) -- 590
	local root = getRootSessionItem(sessionId) -- 591
	if not root then -- 591
		return {} -- 592
	end -- 592
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 593
	return __TS__ArrayMap( -- 602
		rows, -- 602
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 602
	) -- 602
end -- 602
function getSessionSpawnInfo(session) -- 605
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 606
	if not info then -- 606
		return nil -- 607
	end -- 607
	local ____temp_4 = type(info.sessionId) == "number" and info.sessionId or nil -- 609
	local ____temp_5 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 610
	local ____temp_6 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 611
	local ____temp_7 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 612
	local ____temp_8 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 613
	local ____temp_9 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 614
	local ____temp_10 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 615
	local ____temp_11 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 616
		__TS__ArrayFilter( -- 617
			info.filesHint, -- 617
			function(____, item) return type(item) == "string" end -- 617
		), -- 617
		function(____, item) return sanitizeUTF8(item) end -- 617
	) or nil -- 617
	local ____temp_12 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 619
	local ____temp_2 -- 622
	if info.success == true then -- 622
		____temp_2 = true -- 622
	else -- 622
		local ____temp_1 -- 622
		if info.success == false then -- 622
			____temp_1 = false -- 622
		else -- 622
			____temp_1 = nil -- 622
		end -- 622
		____temp_2 = ____temp_1 -- 622
	end -- 622
	local ____temp_3 -- 623
	if info.cleared == true then -- 623
		____temp_3 = true -- 623
	else -- 623
		____temp_3 = nil -- 623
	end -- 623
	return { -- 608
		sessionId = ____temp_4, -- 609
		rootSessionId = ____temp_5, -- 610
		parentSessionId = ____temp_6, -- 611
		title = ____temp_7, -- 612
		prompt = ____temp_8, -- 613
		goal = ____temp_9, -- 614
		expectedOutput = ____temp_10, -- 615
		filesHint = ____temp_11, -- 616
		status = ____temp_12, -- 619
		success = ____temp_2, -- 622
		cleared = ____temp_3, -- 623
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 624
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 625
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 626
		changeSet = decodeChangeSetSummary(info.changeSet), -- 627
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 628
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 629
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 630
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 631
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 632
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 633
	} -- 633
end -- 633
function ensureDirRecursive(dir) -- 650
	if not dir or dir == "" then -- 650
		return false -- 651
	end -- 651
	if Content:exist(dir) then -- 651
		return Content:isdir(dir) -- 652
	end -- 652
	local parent = Path:getPath(dir) -- 653
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 653
		if not ensureDirRecursive(parent) then -- 653
			return false -- 656
		end -- 656
	end -- 656
	return Content:mkdir(dir) -- 659
end -- 659
function writeSpawnInfo(projectRoot, memoryScope, value) -- 662
	local dir = Path(projectRoot, ".agent", memoryScope) -- 663
	if not Content:exist(dir) then -- 663
		ensureDirRecursive(dir) -- 665
	end -- 665
	local path = Path(dir, SPAWN_INFO_FILE) -- 667
	local text = safeJsonEncode(value) -- 668
	if not text then -- 668
		return false -- 669
	end -- 669
	local content = text .. "\n" -- 670
	if not Content:save(path, content) then -- 670
		return false -- 672
	end -- 672
	Tools.sendWebIDEFileUpdate(path, true, content) -- 674
	return true -- 675
end -- 675
function readSpawnInfo(projectRoot, memoryScope) -- 678
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 679
	if not Content:exist(path) then -- 679
		return nil -- 680
	end -- 680
	local text = Content:load(path) -- 681
	if not text or __TS__StringTrim(text) == "" then -- 681
		return nil -- 682
	end -- 682
	local value = safeJsonDecode(text) -- 683
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 683
		return value -- 685
	end -- 685
	return nil -- 687
end -- 687
function getArtifactRelativeDir(memoryScope) -- 690
	return Path(".agent", memoryScope) -- 691
end -- 691
function getArtifactDir(projectRoot, memoryScope) -- 694
	return Path( -- 695
		projectRoot, -- 695
		getArtifactRelativeDir(memoryScope) -- 695
	) -- 695
end -- 695
function getResultRelativePath(memoryScope) -- 698
	return Path( -- 699
		getArtifactRelativeDir(memoryScope), -- 699
		RESULT_FILE -- 699
	) -- 699
end -- 699
function getResultPath(projectRoot, memoryScope) -- 702
	return Path( -- 703
		projectRoot, -- 703
		getResultRelativePath(memoryScope) -- 703
	) -- 703
end -- 703
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 706
	if not resultFilePath or resultFilePath == "" then -- 706
		return "" -- 707
	end -- 707
	local path = Path(projectRoot, resultFilePath) -- 708
	if not Content:exist(path) then -- 708
		return "" -- 709
	end -- 709
	local text = sanitizeUTF8(Content:load(path)) -- 710
	if not text or __TS__StringTrim(text) == "" then -- 710
		return "" -- 711
	end -- 711
	local marker = "\n## Summary\n" -- 712
	local start = string.find(text, marker, 1, true) -- 713
	if start ~= nil then -- 713
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 715
	end -- 715
	return __TS__StringTrim(text) -- 717
end -- 717
function buildSubAgentMemoryEntryLLMOptions(llmConfig) -- 720
	local options = { -- 721
		temperature = llmConfig.temperature or SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, -- 722
		max_tokens = math.min(llmConfig.maxTokens or SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS) -- 723
	} -- 723
	if llmConfig.reasoningEffort then -- 723
		options.reasoning_effort = __TS__StringTrim(llmConfig.reasoningEffort) -- 726
	end -- 726
	if type(options.reasoning_effort) ~= "string" or __TS__StringTrim(options.reasoning_effort) == "" then -- 726
		__TS__Delete(options, "reasoning_effort") -- 729
	end -- 729
	return options -- 731
end -- 731
function buildSubAgentMemoryEntryToolSchema() -- 734
	return {{type = "function", ["function"] = {name = "save_sub_agent_memory_entry", description = "Save one durable memory paragraph extracted from a completed sub-agent session.", parameters = {type = "object", properties = {content = {type = "string", description = "A concise paragraph of key information worth carrying into future main-agent context. Use an empty string when nothing durable should be saved."}, evidence = {type = "array", items = {type = "string"}, description = "Optional short file paths, artifact paths, or concrete anchors that support the memory paragraph."}}, required = {"content"}}}}} -- 735
end -- 735
function buildSubAgentMemoryEntrySystemPrompt() -- 759
	return "You generate a durable memory entry for the parent Dora agent.\nPrefer calling save_sub_agent_memory_entry when tool calling is available.\nIf you cannot call tools, output exactly one JSON object with this shape: {\"content\":\"...\",\"evidence\":[\"...\"]}.\n\nUse the completed sub-agent conversation and final result to decide whether anything should be remembered.\nReturn a single compact paragraph in content, similar to a history entry.\nFocus on durable facts: implemented behavior, important design decisions, constraints, discovered project conventions, or follow-up risks.\nDo not include generic progress narration, praise, or temporary execution details.\nIf there is no information likely to help future work, set content to an empty string.\nKeep evidence short and concrete, such as touched file paths or result artifact paths." -- 760
end -- 760
function formatSubAgentMemoryTailMessage(message) -- 772
	local lines = {"role: " .. sanitizeUTF8(toStr(message.role))} -- 773
	if type(message.name) == "string" and message.name ~= "" then -- 773
		lines[#lines + 1] = "name: " .. sanitizeUTF8(message.name) -- 775
	end -- 775
	if type(message.tool_call_id) == "string" and message.tool_call_id ~= "" then -- 775
		lines[#lines + 1] = "tool_call_id: " .. sanitizeUTF8(message.tool_call_id) -- 778
	end -- 778
	local content = type(message.content) == "string" and clipTextToTokenBudget( -- 780
		sanitizeUTF8(message.content), -- 781
		SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS -- 781
	) or "" -- 781
	if content ~= "" then -- 781
		lines[#lines + 1] = "content:\n" .. content -- 784
	end -- 784
	if __TS__ArrayIsArray(message.tool_calls) and #message.tool_calls > 0 then -- 784
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 787
		if toolCallsText ~= nil and toolCallsText ~= "" then -- 787
			lines[#lines + 1] = "tool_calls:\n" .. clipTextToTokenBudget(toolCallsText, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS) -- 789
		end -- 789
	end -- 789
	return table.concat(lines, "\n") -- 792
end -- 792
function buildSubAgentRecentMessageTail(messages) -- 795
	local parts = {} -- 796
	local totalTokens = 0 -- 797
	local count = 0 -- 798
	do -- 798
		local i = #messages - 1 -- 799
		while i >= 0 and count < SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES do -- 799
			do -- 799
				local text = formatSubAgentMemoryTailMessage(messages[i + 1]) -- 800
				if text == "" then -- 800
					goto __continue128 -- 801
				end -- 801
				local tokens = estimateTextTokens(text) -- 802
				if #parts > 0 and totalTokens + tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS then -- 802
					break -- 803
				end -- 803
				if tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS and #parts == 0 then -- 803
					__TS__ArrayUnshift( -- 805
						parts, -- 805
						clipTextToTokenBudget(text, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS) -- 805
					) -- 805
					break -- 806
				end -- 806
				__TS__ArrayUnshift(parts, text) -- 808
				totalTokens = totalTokens + tokens -- 809
				count = count + 1 -- 810
			end -- 810
			::__continue128:: -- 810
			i = i - 1 -- 799
		end -- 799
	end -- 799
	return #parts > 0 and table.concat(parts, "\n\n---\n\n") or "(empty)"
end -- 812
function buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 815
	local ____opt_13 = record.changeSet -- 815
	local files = ____opt_13 and ____opt_13.files or ({}) -- 816
	local changedFiles = table.concat( -- 817
		__TS__ArrayMap( -- 817
			files, -- 817
			function(____, file) return ((("- " .. file.path) .. " (") .. file.op) .. ")" end -- 817
		), -- 817
		"\n" -- 817
	) -- 817
	local boundedMemoryContext = clipTextToTokenBudget(memoryContext ~= "" and memoryContext or "(empty)", SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS) -- 818
	local boundedResultText = clipTextToTokenBudget(resultText ~= "" and resultText or "(empty)", SUB_AGENT_MEMORY_RESULT_MAX_TOKENS) -- 819
	return ((((((((((((((((((((((("Sub-agent memory context:\n" .. boundedMemoryContext) .. "\n\nSub-agent task metadata:\n- sessionId: ") .. tostring(record.sessionId)) .. "\n- taskId: ") .. tostring(record.sourceTaskId)) .. "\n- title: ") .. record.title) .. "\n- goal: ") .. record.goal) .. "\n- prompt: ") .. record.prompt) .. "\n- expectedOutput: ") .. (record.expectedOutput or "")) .. "\n- resultFilePath: ") .. record.resultFilePath) .. "\n- finishedAt: ") .. record.finishedAt) .. "\n\nChanged files:\n") .. (changedFiles ~= "" and changedFiles or "- none")) .. "\n\nFinal sub-agent result:\n") .. boundedResultText) .. "\n\nRecent conversation tail:\n") .. recentMessageTail) .. "\n\nGenerate the memory entry now." -- 820
end -- 820
function buildSubAgentMemoryEntryRetryPrompt(lastError) -- 845
	return ("Previous memory entry response was invalid: " .. lastError) .. "\n\nRetry with exactly one JSON object and no Markdown fences, no prose, no tool call.\nSchema:\n{\"content\":\"one concise durable memory paragraph, or empty string if nothing should be saved\",\"evidence\":[\"optional short file path or artifact path\"]}\n\nRules:\n- content must be a string.\n- evidence must be an array of strings.\n- Use {\"content\":\"\",\"evidence\":[]} when there is no durable memory to save." -- 846
end -- 846
function normalizeGeneratedSubAgentMemoryEntry(value, record) -- 858
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 858
		return nil -- 859
	end -- 859
	local row = value -- 860
	local content = takeUtf8Head( -- 861
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 861
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 861
	) -- 861
	if content == "" then -- 861
		return nil -- 862
	end -- 862
	return { -- 863
		sourceSessionId = record.sessionId, -- 864
		sourceTaskId = record.sourceTaskId, -- 865
		content = content, -- 866
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 867
		createdAt = record.finishedAt -- 868
	} -- 868
end -- 868
function getMemoryEntryToolFunction(response) -- 872
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 872
		return nil -- 873
	end -- 873
	local row = response -- 874
	local choices = row.choices -- 875
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 875
		return nil -- 876
	end -- 876
	local ____opt_15 = choices[1] -- 876
	if ____opt_15 ~= nil then -- 876
		____opt_15 = ____opt_15.message -- 876
	end -- 876
	local message = ____opt_15 -- 877
	local ____opt_result_19 -- 877
	if message ~= nil then -- 877
		____opt_result_19 = message.tool_calls -- 877
	end -- 877
	local toolCalls = ____opt_result_19 -- 878
	if not __TS__ArrayIsArray(toolCalls) then -- 878
		return nil -- 879
	end -- 879
	do -- 879
		local i = 0 -- 880
		while i < #toolCalls do -- 880
			local ____opt_20 = toolCalls[i + 1] -- 880
			if ____opt_20 ~= nil then -- 880
				____opt_20 = ____opt_20["function"] -- 880
			end -- 880
			local fn = ____opt_20 -- 881
			if (fn and fn.name) == "save_sub_agent_memory_entry" then -- 881
				return fn -- 882
			end -- 882
			i = i + 1 -- 880
		end -- 880
	end -- 880
	return nil -- 884
end -- 884
function getMemoryEntryPlainContent(response) -- 887
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 887
		return "" -- 888
	end -- 888
	local row = response -- 889
	local choices = row.choices -- 890
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 890
		return "" -- 891
	end -- 891
	local ____opt_24 = choices[1] -- 891
	if ____opt_24 ~= nil then -- 891
		____opt_24 = ____opt_24.message -- 891
	end -- 891
	local message = ____opt_24 -- 892
	local ____opt_result_28 -- 892
	if message ~= nil then -- 892
		____opt_result_28 = message.content -- 892
	end -- 892
	return type(____opt_result_28) == "string" and __TS__StringTrim(sanitizeUTF8(message.content)) or "" -- 893
end -- 893
function decodeMemoryEntryFromPlainContent(content) -- 896
	if content == "" then -- 896
		return nil -- 897
	end -- 897
	local direct = safeJsonDecode(content) -- 898
	if direct ~= nil then -- 898
		return direct -- 899
	end -- 899
	local start = string.find(content, "{", 1, true) -- 900
	if start == nil then -- 900
		return nil -- 901
	end -- 901
	local ____end = #content -- 902
	while ____end >= start do -- 902
		local candidate = string.sub(content, start, ____end) -- 904
		local value = safeJsonDecode(candidate) -- 905
		if value ~= nil then -- 905
			return value -- 906
		end -- 906
		____end = ____end - 1 -- 907
	end -- 907
	return nil -- 909
end -- 909
function hasEmptyMemoryEntryContent(value) -- 912
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 912
		return false -- 913
	end -- 913
	local row = value -- 914
	return type(row.content) == "string" and __TS__StringTrim(sanitizeUTF8(row.content)) == "" -- 915
end -- 915
function generateSubAgentMemoryEntry(session, record, resultText) -- 918
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 918
		if not record.success then -- 918
			return ____awaiter_resolve(nil, {}) -- 918
		end -- 918
		local configRes = getActiveLLMConfig() -- 920
		if not configRes.success then -- 920
			return ____awaiter_resolve(nil, {error = configRes.message}) -- 920
		end -- 920
		local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 924
		local persisted = storage:readSessionState() -- 925
		local memoryContext = storage:readMemory() -- 926
		local recentMessageTail = buildSubAgentRecentMessageTail(persisted.messages) -- 927
		local prompt = buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 928
		local tools = configRes.config.supportsFunctionCalling and buildSubAgentMemoryEntryToolSchema() or nil -- 929
		local lastError = "missing memory entry" -- 930
		do -- 930
			local attempt = 0 -- 931
			while attempt < SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY do -- 931
				do -- 931
					local useTools = attempt == 0 and tools ~= nil -- 932
					local messages = { -- 933
						{ -- 934
							role = "system", -- 934
							content = buildSubAgentMemoryEntrySystemPrompt() -- 934
						}, -- 934
						{ -- 935
							role = "user", -- 936
							content = attempt == 0 and prompt or (prompt .. "\n\n") .. buildSubAgentMemoryEntryRetryPrompt(lastError) -- 937
						} -- 937
					} -- 937
					local response = __TS__Await(callLLM( -- 942
						messages, -- 943
						__TS__ObjectAssign( -- 944
							{}, -- 944
							buildSubAgentMemoryEntryLLMOptions(configRes.config), -- 945
							useTools and ({tools = tools}) or ({}) -- 946
						), -- 946
						configRes.config -- 948
					)) -- 948
					if not response.success then -- 948
						lastError = response.message -- 951
						if useTools then -- 951
							Log("Warn", "[AgentSession] sub session memory entry tool request failed, retrying without tools: " .. response.message) -- 953
						end -- 953
						goto __continue160 -- 955
					end -- 955
					local fn = getMemoryEntryToolFunction(response.response) -- 957
					local argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 958
					if fn ~= nil and argsText ~= "" then -- 958
						local args, err = safeJsonDecode(argsText) -- 960
						if err ~= nil or args == nil then -- 960
							lastError = "invalid memory entry tool arguments: " .. tostring(err) -- 962
							goto __continue160 -- 963
						end -- 963
						if hasEmptyMemoryEntryContent(args) then -- 963
							return ____awaiter_resolve(nil, {}) -- 963
						end -- 963
						local entry = normalizeGeneratedSubAgentMemoryEntry(args, record) -- 966
						if entry ~= nil then -- 966
							return ____awaiter_resolve(nil, {entry = entry}) -- 966
						end -- 966
						lastError = "invalid memory entry tool arguments shape" -- 968
						goto __continue160 -- 969
					end -- 969
					local plainContent = getMemoryEntryPlainContent(response.response) -- 971
					local plainArgs = decodeMemoryEntryFromPlainContent(plainContent) -- 972
					if plainArgs ~= nil then -- 972
						if hasEmptyMemoryEntryContent(plainArgs) then -- 972
							return ____awaiter_resolve(nil, {}) -- 972
						end -- 972
						local entry = normalizeGeneratedSubAgentMemoryEntry(plainArgs, record) -- 975
						if entry ~= nil then -- 975
							return ____awaiter_resolve(nil, {entry = entry}) -- 975
						end -- 975
						lastError = "invalid memory entry JSON shape" -- 977
						goto __continue160 -- 978
					end -- 978
					lastError = "LLM did not return memory entry tool call or JSON content" -- 980
				end -- 980
				::__continue160:: -- 980
				attempt = attempt + 1 -- 931
			end -- 931
		end -- 931
		return ____awaiter_resolve(nil, {error = lastError}) -- 931
	end) -- 931
end -- 931
function containsNormalizedText(text, query) -- 985
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 986
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 987
	if normalizedQuery == "" then -- 987
		return true -- 988
	end -- 988
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 989
end -- 989
function getSubAgentDisplayKey(item) -- 992
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 998
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 999
	local label = goal ~= "" and goal or title -- 1000
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1001
end -- 1001
function writeSubAgentResultFile(session, record, resultText) -- 1004
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1005
	if not Content:exist(dir) then -- 1005
		ensureDirRecursive(dir) -- 1007
	end -- 1007
	local ____array_29 = __TS__SparseArrayNew( -- 1007
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1010
		"- Status: " .. record.status, -- 1011
		"- Success: " .. (record.success and "true" or "false"), -- 1012
		"- Session ID: " .. tostring(record.sessionId), -- 1013
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1014
		"- Goal: " .. record.goal, -- 1015
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1016
	) -- 1016
	__TS__SparseArrayPush( -- 1016
		____array_29, -- 1016
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1017
	) -- 1017
	__TS__SparseArrayPush( -- 1017
		____array_29, -- 1017
		"- Finished At: " .. record.finishedAt, -- 1018
		"", -- 1019
		"## Summary", -- 1020
		resultText ~= "" and resultText or "(empty)" -- 1021
	) -- 1021
	local lines = {__TS__SparseArraySpread(____array_29)} -- 1009
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1023
	local content = table.concat(lines, "\n") .. "\n" -- 1024
	if not Content:save(path, content) then -- 1024
		return false -- 1026
	end -- 1026
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1028
	return true -- 1029
end -- 1029
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1032
	local dir = Path(projectRoot, ".agent", "subagents") -- 1033
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1033
		return {} -- 1034
	end -- 1034
	local items = {} -- 1035
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1036
		do -- 1036
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1037
			if not Content:exist(path) or not Content:isdir(path) then -- 1037
				goto __continue178 -- 1038
			end -- 1038
			local info = readSpawnInfo( -- 1039
				projectRoot, -- 1039
				Path( -- 1039
					"subagents", -- 1039
					Path:getFilename(path) -- 1039
				) -- 1039
			) -- 1039
			if not info then -- 1039
				goto __continue178 -- 1040
			end -- 1040
			local sessionId = tonumber(info.sessionId) -- 1041
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1042
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1043
			local status = sanitizeUTF8(toStr(info.status)) -- 1044
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1044
				goto __continue178 -- 1045
			end -- 1045
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1045
				goto __continue178 -- 1046
			end -- 1046
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1047
			items[#items + 1] = { -- 1048
				sessionId = sessionId, -- 1049
				rootSessionId = infoRootSessionId, -- 1050
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1051
				title = sanitizeUTF8(toStr(info.title)), -- 1052
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1053
				goal = sanitizeUTF8(toStr(info.goal)), -- 1054
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1055
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1056
					__TS__ArrayFilter( -- 1057
						info.filesHint, -- 1057
						function(____, item) return type(item) == "string" end -- 1057
					), -- 1057
					function(____, item) return sanitizeUTF8(item) end -- 1057
				) or ({}), -- 1057
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1059
				success = info.success == true, -- 1060
				cleared = info.cleared == true, -- 1061
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1062
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1063
					"subagents", -- 1063
					Path:getFilename(path) -- 1063
				)), -- 1063
				sourceTaskId = sourceTaskId or 0, -- 1064
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1065
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1066
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1067
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1068
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1069
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1070
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1071
			} -- 1071
		end -- 1071
		::__continue178:: -- 1071
	end -- 1071
	__TS__ArraySort( -- 1074
		items, -- 1074
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1074
	) -- 1074
	return items -- 1075
end -- 1075
function getPendingHandoffDir(projectRoot, memoryScope) -- 1078
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1079
end -- 1079
function writePendingHandoff(projectRoot, memoryScope, value) -- 1082
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1083
	if not Content:exist(dir) then -- 1083
		ensureDirRecursive(dir) -- 1085
	end -- 1085
	local path = Path(dir, value.id .. ".json") -- 1087
	local text = safeJsonEncode(value) -- 1088
	if not text then -- 1088
		return false -- 1089
	end -- 1089
	return Content:save(path, text .. "\n") -- 1090
end -- 1090
function listPendingHandoffs(projectRoot, memoryScope) -- 1093
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1094
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1094
		return {} -- 1095
	end -- 1095
	local items = {} -- 1096
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1097
		do -- 1097
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1098
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1098
				goto __continue193 -- 1099
			end -- 1099
			local text = Content:load(path) -- 1100
			if not text or __TS__StringTrim(text) == "" then -- 1100
				goto __continue193 -- 1101
			end -- 1101
			local obj = safeJsonDecode(text) -- 1102
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1102
				goto __continue193 -- 1103
			end -- 1103
			local value = obj -- 1104
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1105
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1106
			local id = sanitizeUTF8(toStr(value.id)) -- 1107
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1108
			local message = sanitizeUTF8(toStr(value.message)) -- 1109
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1110
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1111
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1112
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1112
				goto __continue193 -- 1114
			end -- 1114
			items[#items + 1] = { -- 1116
				id = id, -- 1117
				sourceSessionId = sourceSessionId, -- 1118
				sourceTitle = sourceTitle, -- 1119
				sourceTaskId = sourceTaskId, -- 1120
				message = message, -- 1121
				prompt = prompt, -- 1122
				goal = goal, -- 1123
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1124
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1125
					__TS__ArrayFilter( -- 1126
						value.filesHint, -- 1126
						function(____, item) return type(item) == "string" end -- 1126
					), -- 1126
					function(____, item) return sanitizeUTF8(item) end -- 1126
				) or ({}), -- 1126
				success = value.success == true, -- 1128
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1129
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1130
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1131
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1132
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1133
				createdAt = createdAt -- 1134
			} -- 1134
		end -- 1134
		::__continue193:: -- 1134
	end -- 1134
	__TS__ArraySort( -- 1137
		items, -- 1137
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1137
	) -- 1137
	return items -- 1138
end -- 1138
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1141
	local path = Path( -- 1142
		getPendingHandoffDir(projectRoot, memoryScope), -- 1142
		id .. ".json" -- 1142
	) -- 1142
	if Content:exist(path) then -- 1142
		Content:remove(path) -- 1144
	end -- 1144
end -- 1144
function normalizePromptText(prompt) -- 1148
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1149
end -- 1149
function normalizePromptTextSafe(prompt) -- 1152
	if type(prompt) == "string" then -- 1152
		local normalized = normalizePromptText(prompt) -- 1154
		if normalized ~= "" then -- 1154
			return normalized -- 1155
		end -- 1155
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1156
		if sanitized ~= "" then -- 1156
			return truncateAgentUserPrompt(sanitized) -- 1158
		end -- 1158
		return "" -- 1160
	end -- 1160
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1162
	if text == "" then -- 1162
		return "" -- 1163
	end -- 1163
	return truncateAgentUserPrompt(text) -- 1164
end -- 1164
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1167
	local sections = {} -- 1168
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1169
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1170
	local normalizedFiles = __TS__ArrayFilter( -- 1171
		__TS__ArrayMap( -- 1171
			__TS__ArrayFilter( -- 1171
				filesHint or ({}), -- 1171
				function(____, item) return type(item) == "string" end -- 1172
			), -- 1172
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1173
		), -- 1173
		function(____, item) return item ~= "" end -- 1174
	) -- 1174
	if normalizedTitle ~= "" then -- 1174
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1176
	end -- 1176
	if normalizedExpected ~= "" then -- 1176
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1179
	end -- 1179
	if #normalizedFiles > 0 then -- 1179
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1182
	end -- 1182
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1184
end -- 1184
function normalizeSessionRuntimeState(session) -- 1187
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1187
		return session -- 1189
	end -- 1189
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1189
		return session -- 1192
	end -- 1192
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1194
	if #pendingToolRows > 0 then -- 1194
		local t = now() -- 1200
		do -- 1200
			local i = 0 -- 1201
			while i < #pendingToolRows do -- 1201
				local row = pendingToolRows[i + 1] -- 1202
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1203
				result.success = false -- 1204
				result.state = "failed" -- 1205
				result.interrupted = true -- 1206
				result.message = "tool call was interrupted because the program exited before it completed." -- 1207
				DB:exec( -- 1208
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1208
					{ -- 1210
						encodeJson(result), -- 1210
						t, -- 1210
						row[1] -- 1210
					} -- 1210
				) -- 1210
				i = i + 1 -- 1201
			end -- 1201
		end -- 1201
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1213
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1214
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1215
	end -- 1215
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1222
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1223
	return __TS__ObjectAssign( -- 1224
		{}, -- 1224
		session, -- 1225
		{ -- 1224
			status = "STOPPED", -- 1226
			currentTaskStatus = "STOPPED", -- 1227
			updatedAt = now() -- 1228
		} -- 1228
	) -- 1228
end -- 1228
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1232
	DB:exec( -- 1233
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1233
		{ -- 1237
			status, -- 1238
			currentTaskId or 0, -- 1239
			currentTaskStatus or status, -- 1240
			now(), -- 1241
			sessionId -- 1242
		} -- 1242
	) -- 1242
end -- 1242
function mergeAgentMetrics(current, next) -- 1247
	return __TS__ObjectAssign({}, current or ({}), next) -- 1248
end -- 1248
function updateSessionMetrics(sessionId, metrics) -- 1254
	local session = getSessionItem(sessionId) -- 1255
	if not session then -- 1255
		return nil -- 1256
	end -- 1256
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1257
	DB:exec( -- 1258
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1258
		{ -- 1262
			encodeJson(merged), -- 1263
			now(), -- 1264
			sessionId -- 1265
		} -- 1265
	) -- 1265
	return merged -- 1268
end -- 1268
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1271
	if taskId == nil or taskId <= 0 then -- 1271
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1273
		return -- 1274
	end -- 1274
	local row = getSessionRow(sessionId) -- 1276
	if not row then -- 1276
		return -- 1277
	end -- 1277
	local session = rowToSession(row) -- 1278
	if session.currentTaskId ~= taskId then -- 1278
		Log( -- 1280
			"Info", -- 1280
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1280
		) -- 1280
		return -- 1281
	end -- 1281
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1283
end -- 1283
function insertMessage(sessionId, role, content, taskId) -- 1286
	local t = now() -- 1287
	DB:exec( -- 1288
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1288
		{ -- 1291
			sessionId, -- 1292
			taskId or 0, -- 1293
			role, -- 1294
			sanitizeUTF8(content), -- 1295
			t, -- 1296
			t -- 1297
		} -- 1297
	) -- 1297
	return getLastInsertRowId() -- 1300
end -- 1300
function updateMessage(messageId, content) -- 1303
	DB:exec( -- 1304
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1304
		{ -- 1306
			sanitizeUTF8(content), -- 1306
			now(), -- 1306
			messageId -- 1306
		} -- 1306
	) -- 1306
end -- 1306
function updateUserMessageForTask(messageId, content, taskId) -- 1310
	DB:exec( -- 1311
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1311
		{ -- 1315
			sanitizeUTF8(content), -- 1315
			taskId, -- 1315
			now(), -- 1315
			messageId -- 1315
		} -- 1315
	) -- 1315
end -- 1315
function upsertAssistantMessage(sessionId, taskId, content) -- 1372
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1373
	if row and type(row[1]) == "number" then -- 1373
		updateMessage(row[1], content) -- 1380
		return row[1] -- 1381
	end -- 1381
	return insertMessage(sessionId, "assistant", content, taskId) -- 1383
end -- 1383
function upsertStep(sessionId, taskId, step, tool, patch) -- 1386
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1396
	local reason = sanitizeUTF8(patch.reason or "") -- 1400
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1401
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1402
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1403
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1404
	local statusPatch = patch.status or "" -- 1405
	local status = patch.status or "PENDING" -- 1406
	if not row then -- 1406
		local t = now() -- 1408
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1409
			sessionId, -- 1413
			taskId, -- 1414
			step, -- 1415
			tool, -- 1416
			status, -- 1417
			reason, -- 1418
			reasoningContent, -- 1419
			paramsJson, -- 1420
			resultJson, -- 1421
			patch.checkpointId or 0, -- 1422
			patch.checkpointSeq or 0, -- 1423
			filesJson, -- 1424
			t, -- 1425
			t -- 1426
		}) -- 1426
		return -- 1429
	end -- 1429
	DB:exec( -- 1431
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1431
		{ -- 1443
			tool, -- 1444
			statusPatch, -- 1445
			status, -- 1446
			reason, -- 1447
			reason, -- 1448
			reasoningContent, -- 1449
			reasoningContent, -- 1450
			paramsJson, -- 1451
			paramsJson, -- 1452
			resultJson, -- 1453
			resultJson, -- 1454
			patch.checkpointId or 0, -- 1455
			patch.checkpointId or 0, -- 1456
			patch.checkpointSeq or 0, -- 1457
			patch.checkpointSeq or 0, -- 1458
			filesJson, -- 1459
			filesJson, -- 1460
			now(), -- 1461
			row[1] -- 1462
		} -- 1462
	) -- 1462
end -- 1462
function getNextStepNumber(sessionId, taskId) -- 1467
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1468
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1472
	return math.max(0, current) + 1 -- 1473
end -- 1473
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1476
	if status == nil then -- 1476
		status = "DONE" -- 1484
	end -- 1484
	local step = getNextStepNumber(sessionId, taskId) -- 1486
	upsertStep( -- 1487
		sessionId, -- 1487
		taskId, -- 1487
		step, -- 1487
		tool, -- 1487
		{status = status, reason = reason, params = params, result = result} -- 1487
	) -- 1487
	return getStepItem(sessionId, taskId, step) -- 1493
end -- 1493
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1496
	if taskId <= 0 then -- 1496
		return -- 1497
	end -- 1497
	if finalSteps ~= nil and finalSteps >= 0 then -- 1497
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1499
	end -- 1499
	if not finalStatus then -- 1499
		return -- 1505
	end -- 1505
	if finalSteps ~= nil and finalSteps >= 0 then -- 1505
		DB:exec( -- 1507
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1507
			{ -- 1511
				finalStatus, -- 1511
				now(), -- 1511
				sessionId, -- 1511
				taskId, -- 1511
				finalSteps -- 1511
			} -- 1511
		) -- 1511
		return -- 1513
	end -- 1513
	DB:exec( -- 1515
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1515
		{ -- 1519
			finalStatus, -- 1519
			now(), -- 1519
			sessionId, -- 1519
			taskId -- 1519
		} -- 1519
	) -- 1519
end -- 1519
function emitAgentSessionPatch(sessionId, patch) -- 1546
	if HttpServer.wsConnectionCount == 0 then -- 1546
		return -- 1548
	end -- 1548
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1550
	if not text then -- 1550
		return -- 1555
	end -- 1555
	emit("AppWS", "Send", text) -- 1556
end -- 1556
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1559
	emitAgentSessionPatch( -- 1560
		sessionId, -- 1560
		{ -- 1560
			sessionDeleted = true, -- 1561
			relatedSessions = listRelatedSessions(rootSessionId) -- 1562
		} -- 1562
	) -- 1562
	local rootSession = getSessionItem(rootSessionId) -- 1564
	if rootSession then -- 1564
		emitAgentSessionPatch( -- 1566
			rootSessionId, -- 1566
			{ -- 1566
				session = rootSession, -- 1567
				relatedSessions = listRelatedSessions(rootSessionId) -- 1568
			} -- 1568
		) -- 1568
	end -- 1568
end -- 1568
function flushPendingSubAgentHandoffs(rootSession) -- 1573
	if rootSession.kind ~= "main" then -- 1573
		return -- 1574
	end -- 1574
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1574
		return -- 1576
	end -- 1576
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1578
	if #items == 0 then -- 1578
		return -- 1579
	end -- 1579
	local handoffTaskId = 0 -- 1580
	local ____rootSession_currentTaskId_30 -- 1581
	if rootSession.currentTaskId then -- 1581
		____rootSession_currentTaskId_30 = getTaskPrompt(rootSession.currentTaskId) -- 1581
	else -- 1581
		____rootSession_currentTaskId_30 = nil -- 1581
	end -- 1581
	local currentTaskPrompt = ____rootSession_currentTaskId_30 -- 1581
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1581
		handoffTaskId = rootSession.currentTaskId -- 1589
	else -- 1589
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1591
		if not taskRes.success then -- 1591
			Log( -- 1593
				"Warn", -- 1593
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1593
			) -- 1593
			return -- 1594
		end -- 1594
		handoffTaskId = taskRes.taskId -- 1596
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1597
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1598
		emitAgentSessionPatch( -- 1599
			rootSession.id, -- 1599
			{session = getSessionItem(rootSession.id)} -- 1599
		) -- 1599
	end -- 1599
	do -- 1599
		local i = 0 -- 1603
		while i < #items do -- 1603
			local item = items[i + 1] -- 1604
			local step = appendSystemStep( -- 1605
				rootSession.id, -- 1606
				handoffTaskId, -- 1607
				"sub_agent_handoff", -- 1608
				"sub_agent_handoff", -- 1609
				item.message, -- 1610
				{ -- 1611
					sourceSessionId = item.sourceSessionId, -- 1612
					sourceTitle = item.sourceTitle, -- 1613
					sourceTaskId = item.sourceTaskId, -- 1614
					success = item.success == true, -- 1615
					summary = item.message, -- 1616
					resultFilePath = item.resultFilePath or "", -- 1617
					artifactDir = item.artifactDir or "", -- 1618
					finishedAt = item.finishedAt or "", -- 1619
					changeSet = item.changeSet, -- 1620
					memoryEntry = item.memoryEntry -- 1621
				}, -- 1621
				{ -- 1623
					sourceSessionId = item.sourceSessionId, -- 1624
					sourceTitle = item.sourceTitle, -- 1625
					sourceTaskId = item.sourceTaskId, -- 1626
					prompt = item.prompt, -- 1627
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1628
					expectedOutput = item.expectedOutput or "", -- 1629
					filesHint = item.filesHint or ({}), -- 1630
					resultFilePath = item.resultFilePath or "", -- 1631
					artifactDir = item.artifactDir or "", -- 1632
					changeSet = item.changeSet, -- 1633
					memoryEntry = item.memoryEntry -- 1634
				}, -- 1634
				"DONE" -- 1636
			) -- 1636
			if step then -- 1636
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1639
			end -- 1639
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1641
			i = i + 1 -- 1603
		end -- 1603
	end -- 1603
end -- 1603
function applyEvent(sessionId, event) -- 1653
	repeat -- 1653
		local ____switch271 = event.type -- 1653
		local ____cond271 = ____switch271 == "task_started" -- 1653
		if ____cond271 then -- 1653
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1656
			emitAgentSessionPatch( -- 1657
				sessionId, -- 1657
				{session = getSessionItem(sessionId)} -- 1657
			) -- 1657
			break -- 1660
		end -- 1660
		____cond271 = ____cond271 or ____switch271 == "decision_made" -- 1660
		if ____cond271 then -- 1660
			upsertStep( -- 1662
				sessionId, -- 1662
				event.taskId, -- 1662
				event.step, -- 1662
				event.tool, -- 1662
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1662
			) -- 1662
			emitAgentSessionPatch( -- 1668
				sessionId, -- 1668
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1668
			) -- 1668
			break -- 1671
		end -- 1671
		____cond271 = ____cond271 or ____switch271 == "tool_started" -- 1671
		if ____cond271 then -- 1671
			upsertStep( -- 1673
				sessionId, -- 1673
				event.taskId, -- 1673
				event.step, -- 1673
				event.tool, -- 1673
				{status = "RUNNING"} -- 1673
			) -- 1673
			emitAgentSessionPatch( -- 1676
				sessionId, -- 1676
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1676
			) -- 1676
			break -- 1679
		end -- 1679
		____cond271 = ____cond271 or ____switch271 == "tool_finished" -- 1679
		if ____cond271 then -- 1679
			upsertStep( -- 1681
				sessionId, -- 1681
				event.taskId, -- 1681
				event.step, -- 1681
				event.tool, -- 1681
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1681
			) -- 1681
			emitAgentSessionPatch( -- 1686
				sessionId, -- 1686
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1686
			) -- 1686
			break -- 1689
		end -- 1689
		____cond271 = ____cond271 or ____switch271 == "tool_progress" -- 1689
		if ____cond271 then -- 1689
			do -- 1689
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1692
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1692
					break -- 1694
				end -- 1694
			end -- 1694
			upsertStep( -- 1697
				sessionId, -- 1697
				event.taskId, -- 1697
				event.step, -- 1697
				event.tool, -- 1697
				{status = "RUNNING", result = event.result} -- 1697
			) -- 1697
			emitAgentSessionPatch( -- 1701
				sessionId, -- 1701
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1701
			) -- 1701
			break -- 1704
		end -- 1704
		____cond271 = ____cond271 or ____switch271 == "checkpoint_created" -- 1704
		if ____cond271 then -- 1704
			upsertStep( -- 1706
				sessionId, -- 1706
				event.taskId, -- 1706
				event.step, -- 1706
				event.tool, -- 1706
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1706
			) -- 1706
			emitAgentSessionPatch( -- 1711
				sessionId, -- 1711
				{ -- 1711
					step = getStepItem(sessionId, event.taskId, event.step), -- 1712
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1713
				} -- 1713
			) -- 1713
			break -- 1715
		end -- 1715
		____cond271 = ____cond271 or ____switch271 == "memory_compression_started" -- 1715
		if ____cond271 then -- 1715
			upsertStep( -- 1717
				sessionId, -- 1717
				event.taskId, -- 1717
				event.step, -- 1717
				event.tool, -- 1717
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1717
			) -- 1717
			emitAgentSessionPatch( -- 1722
				sessionId, -- 1722
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1722
			) -- 1722
			break -- 1725
		end -- 1725
		____cond271 = ____cond271 or ____switch271 == "memory_compression_finished" -- 1725
		if ____cond271 then -- 1725
			upsertStep( -- 1727
				sessionId, -- 1727
				event.taskId, -- 1727
				event.step, -- 1727
				event.tool, -- 1727
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1727
			) -- 1727
			emitAgentSessionPatch( -- 1732
				sessionId, -- 1732
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1732
			) -- 1732
			break -- 1735
		end -- 1735
		____cond271 = ____cond271 or ____switch271 == "metrics_updated" -- 1735
		if ____cond271 then -- 1735
			do -- 1735
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1737
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1738
				break -- 1741
			end -- 1741
		end -- 1741
		____cond271 = ____cond271 or ____switch271 == "assistant_message_updated" -- 1741
		if ____cond271 then -- 1741
			do -- 1741
				upsertStep( -- 1744
					sessionId, -- 1744
					event.taskId, -- 1744
					event.step, -- 1744
					"message", -- 1744
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1744
				) -- 1744
				emitAgentSessionPatch( -- 1749
					sessionId, -- 1749
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1749
				) -- 1749
				break -- 1752
			end -- 1752
		end -- 1752
		____cond271 = ____cond271 or ____switch271 == "task_finished" -- 1752
		if ____cond271 then -- 1752
			do -- 1752
				local ____opt_31 = activeStopTokens[event.taskId or -1] -- 1752
				local stopped = (____opt_31 and ____opt_31.stopped) == true -- 1755
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1756
				local session = getSessionItem(sessionId) -- 1759
				local isSubSession = (session and session.kind) == "sub" -- 1760
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1761
				if isSubSession and event.taskId ~= nil then -- 1761
					finalizingSubSessionTaskIds[event.taskId] = true -- 1763
				end -- 1763
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1765
				if event.taskId ~= nil then -- 1765
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1767
					local ____finalizeTaskSteps_37 = finalizeTaskSteps -- 1768
					local ____array_36 = __TS__SparseArrayNew( -- 1768
						sessionId, -- 1769
						event.taskId, -- 1770
						type(event.steps) == "number" and math.max( -- 1771
							0, -- 1771
							math.floor(event.steps) -- 1771
						) or nil -- 1771
					) -- 1771
					local ____event_success_35 -- 1772
					if event.success then -- 1772
						____event_success_35 = nil -- 1772
					else -- 1772
						____event_success_35 = stopped and "STOPPED" or "FAILED" -- 1772
					end -- 1772
					__TS__SparseArrayPush(____array_36, ____event_success_35) -- 1772
					____finalizeTaskSteps_37(__TS__SparseArraySpread(____array_36)) -- 1768
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1774
					if not isSubSession then -- 1774
						__TS__Delete(activeStopTokens, event.taskId) -- 1776
					end -- 1776
					emitAgentSessionPatch( -- 1778
						sessionId, -- 1778
						{ -- 1778
							session = getSessionItem(sessionId), -- 1779
							message = getMessageItem(messageId), -- 1780
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1781
							removedStepIds = removedStepIds -- 1782
						} -- 1782
					) -- 1782
				end -- 1782
				if session and session.kind == "main" then -- 1782
					flushPendingSubAgentHandoffs(session) -- 1786
				end -- 1786
				break -- 1788
			end -- 1788
		end -- 1788
	until true -- 1788
end -- 1788
function ____exports.createSession(projectRoot, title) -- 1925
	if title == nil then -- 1925
		title = "" -- 1925
	end -- 1925
	if not isValidProjectRoot(projectRoot) then -- 1925
		return {success = false, message = "invalid projectRoot"} -- 1927
	end -- 1927
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1929
	if row then -- 1929
		return { -- 1938
			success = true, -- 1938
			session = rowToSession(row) -- 1938
		} -- 1938
	end -- 1938
	local t = now() -- 1940
	DB:exec( -- 1941
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1941
		{ -- 1944
			projectRoot, -- 1944
			title ~= "" and title or Path:getFilename(projectRoot), -- 1944
			t, -- 1944
			t -- 1944
		} -- 1944
	) -- 1944
	local sessionId = getLastInsertRowId() -- 1946
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1947
	local session = getSessionItem(sessionId) -- 1948
	if not session then -- 1948
		return {success = false, message = "failed to create session"} -- 1950
	end -- 1950
	return {success = true, session = session} -- 1952
end -- 1925
function ____exports.createSubSession(parentSessionId, title) -- 1955
	if title == nil then -- 1955
		title = "" -- 1955
	end -- 1955
	local parent = getSessionItem(parentSessionId) -- 1956
	if not parent then -- 1956
		return {success = false, message = "parent session not found"} -- 1958
	end -- 1958
	local rootId = getSessionRootId(parent) -- 1960
	local t = now() -- 1961
	DB:exec( -- 1962
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1962
		{ -- 1965
			parent.projectRoot, -- 1965
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1965
			rootId, -- 1965
			parent.id, -- 1965
			t, -- 1965
			t -- 1965
		} -- 1965
	) -- 1965
	local sessionId = getLastInsertRowId() -- 1967
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1968
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1969
	local session = getSessionItem(sessionId) -- 1970
	if not session then -- 1970
		return {success = false, message = "failed to create sub session"} -- 1972
	end -- 1972
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1974
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1975
	subStorage:writeMemory(parentStorage:readMemory()) -- 1976
	return {success = true, session = session} -- 1977
end -- 1955
function spawnSubAgentSession(request) -- 1980
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1980
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1992
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1993
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1994
		if normalizedPrompt == "" then -- 1994
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1996
		end -- 1996
		if normalizedPrompt == "" then -- 1996
			local ____Log_43 = Log -- 2003
			local ____temp_40 = #normalizedTitle -- 2003
			local ____temp_41 = #rawPrompt -- 2003
			local ____temp_42 = #toStr(request.expectedOutput) -- 2003
			local ____opt_38 = request.filesHint -- 2003
			____Log_43( -- 2003
				"Warn", -- 2003
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_40)) .. " raw_prompt_len=") .. tostring(____temp_41)) .. " expected_len=") .. tostring(____temp_42)) .. " files_hint_count=") .. tostring(____opt_38 and #____opt_38 or 0) -- 2003
			) -- 2003
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2003
		end -- 2003
		Log( -- 2006
			"Info", -- 2006
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2006
		) -- 2006
		local parentSessionId = request.parentSessionId -- 2007
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2007
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2009
			if not fallbackParent then -- 2009
				local createdMain = ____exports.createSession(request.projectRoot) -- 2011
				if createdMain.success then -- 2011
					fallbackParent = createdMain.session -- 2013
				end -- 2013
			end -- 2013
			if fallbackParent then -- 2013
				Log( -- 2017
					"Warn", -- 2017
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2017
				) -- 2017
				parentSessionId = fallbackParent.id -- 2018
			end -- 2018
		end -- 2018
		local parentSession = getSessionItem(parentSessionId) -- 2021
		if not parentSession then -- 2021
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2021
		end -- 2021
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2025
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2025
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2025
		end -- 2025
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2029
		if not created.success then -- 2029
			return ____awaiter_resolve(nil, created) -- 2029
		end -- 2029
		writeSpawnInfo( -- 2033
			created.session.projectRoot, -- 2033
			created.session.memoryScope, -- 2033
			{ -- 2033
				sessionId = created.session.id, -- 2034
				rootSessionId = created.session.rootSessionId, -- 2035
				parentSessionId = created.session.parentSessionId, -- 2036
				title = created.session.title, -- 2037
				prompt = normalizedPrompt, -- 2038
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2039
				expectedOutput = request.expectedOutput or "", -- 2040
				filesHint = request.filesHint or ({}), -- 2041
				status = "RUNNING", -- 2042
				success = false, -- 2043
				resultFilePath = "", -- 2044
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2045
				sourceTaskId = 0, -- 2046
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2047
				createdAtTs = created.session.createdAt, -- 2048
				finishedAt = "", -- 2049
				finishedAtTs = 0 -- 2050
			} -- 2050
		) -- 2050
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true, request.disabledAgentTools) -- 2052
		if not sent.success then -- 2052
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2052
		end -- 2052
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2052
	end) -- 2052
end -- 2052
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2133
	local rootSession = getRootSessionItem(session.id) -- 2134
	if not rootSession then -- 2134
		return -- 2135
	end -- 2135
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2136
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2137
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2138
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2139
	local queueResult = writePendingHandoff( -- 2140
		rootSession.projectRoot, -- 2140
		rootSession.memoryScope, -- 2140
		{ -- 2140
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2141
			sourceSessionId = session.id, -- 2142
			sourceTitle = session.title, -- 2143
			sourceTaskId = taskId, -- 2144
			message = summary, -- 2145
			prompt = result.prompt, -- 2146
			goal = result.goal, -- 2147
			expectedOutput = result.expectedOutput or "", -- 2148
			filesHint = result.filesHint or ({}), -- 2149
			success = result.success, -- 2150
			resultFilePath = result.resultFilePath, -- 2151
			artifactDir = result.artifactDir, -- 2152
			finishedAt = result.finishedAt, -- 2153
			changeSet = changeSet, -- 2154
			memoryEntry = result.memoryEntry, -- 2155
			createdAt = createdAt -- 2156
		} -- 2156
	) -- 2156
	if not queueResult then -- 2156
		Log( -- 2159
			"Warn", -- 2159
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2159
		) -- 2159
		return -- 2160
	end -- 2160
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2160
		flushPendingSubAgentHandoffs(rootSession) -- 2163
	end -- 2163
end -- 2163
function finalizeSubSession(session, taskId, success, message) -- 2167
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2167
		local rootSessionId = getSessionRootId(session) -- 2168
		local rootSession = getRootSessionItem(session.id) -- 2169
		if not rootSession then -- 2169
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2169
		end -- 2169
		local spawnInfo = getSessionSpawnInfo(session) -- 2173
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2174
		local finishedAtTs = now() -- 2175
		local resultText = sanitizeUTF8(message) -- 2176
		local changeSet = getTaskChangeSetSummary(taskId) -- 2177
		local record = { -- 2178
			sessionId = session.id, -- 2179
			rootSessionId = rootSessionId, -- 2180
			parentSessionId = session.parentSessionId, -- 2181
			title = session.title, -- 2182
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2183
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2184
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2185
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2186
			status = success and "DONE" or "FAILED", -- 2187
			success = success, -- 2188
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2189
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2190
			sourceTaskId = taskId, -- 2191
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2192
			finishedAt = finishedAt, -- 2193
			createdAtTs = session.createdAt, -- 2194
			finishedAtTs = finishedAtTs, -- 2195
			changeSet = changeSet -- 2196
		} -- 2196
		if record.success then -- 2196
			local memoryEntryResult = __TS__Await(generateSubAgentMemoryEntry(session, record, resultText)) -- 2199
			record.memoryEntry = memoryEntryResult.entry -- 2200
			if memoryEntryResult.error and memoryEntryResult.error ~= "" then -- 2200
				record.memoryEntryError = memoryEntryResult.error -- 2202
				Log( -- 2203
					"Warn", -- 2203
					(("[AgentSession] sub session memory entry failed session=" .. tostring(session.id)) .. " error=") .. memoryEntryResult.error -- 2203
				) -- 2203
			end -- 2203
		end -- 2203
		if not writeSubAgentResultFile(session, record, resultText) then -- 2203
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2203
		end -- 2203
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2203
			sessionId = record.sessionId, -- 2210
			rootSessionId = record.rootSessionId, -- 2211
			parentSessionId = record.parentSessionId, -- 2212
			title = record.title, -- 2213
			prompt = record.prompt, -- 2214
			goal = record.goal, -- 2215
			expectedOutput = record.expectedOutput or "", -- 2216
			filesHint = record.filesHint or ({}), -- 2217
			status = record.status, -- 2218
			success = record.success, -- 2219
			resultFilePath = record.resultFilePath, -- 2220
			artifactDir = record.artifactDir, -- 2221
			sourceTaskId = record.sourceTaskId, -- 2222
			createdAt = record.createdAt, -- 2223
			finishedAt = record.finishedAt, -- 2224
			createdAtTs = record.createdAtTs, -- 2225
			finishedAtTs = record.finishedAtTs, -- 2226
			changeSet = record.changeSet, -- 2227
			memoryEntry = record.memoryEntry, -- 2228
			memoryEntryError = record.memoryEntryError -- 2229
		}) then -- 2229
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2229
		end -- 2229
		if success then -- 2229
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2234
			deleteSessionRecords(session.id, true) -- 2235
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2236
		end -- 2236
		return ____awaiter_resolve(nil, {success = true}) -- 2236
	end) -- 2236
end -- 2236
function stopClearedSubSession(session, taskId) -- 2241
	local spawnInfo = getSessionSpawnInfo(session) -- 2242
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2243
	local rootSessionId = getSessionRootId(session) -- 2244
	Tools.setTaskStatus(taskId, "STOPPED") -- 2245
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2246
	if not writeSpawnInfo( -- 2246
		session.projectRoot, -- 2247
		session.memoryScope, -- 2247
		{ -- 2247
			sessionId = session.id, -- 2248
			rootSessionId = rootSessionId, -- 2249
			parentSessionId = session.parentSessionId, -- 2250
			title = session.title, -- 2251
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2252
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2253
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2254
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2255
			status = "STOPPED", -- 2256
			success = false, -- 2257
			cleared = true, -- 2258
			resultFilePath = "", -- 2259
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2260
			sourceTaskId = taskId, -- 2261
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2262
			finishedAt = finishedAt, -- 2263
			createdAtTs = session.createdAt, -- 2264
			finishedAtTs = now() -- 2265
		} -- 2265
	) then -- 2265
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2267
	end -- 2267
	deleteSessionRecords(session.id, true) -- 2269
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2270
	return {success = true} -- 2271
end -- 2271
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools) -- 2274
	if allowSubSessionStart == nil then -- 2274
		allowSubSessionStart = false -- 2274
	end -- 2274
	local session = getSessionItem(sessionId) -- 2275
	if not session then -- 2275
		return {success = false, message = "session not found"} -- 2277
	end -- 2277
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2277
		return {success = false, message = "session task is finalizing"} -- 2280
	end -- 2280
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2280
		return {success = false, message = "session task is still running"} -- 2283
	end -- 2283
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2285
	if normalizedPrompt == "" and session.kind == "sub" then -- 2285
		local spawnInfo = getSessionSpawnInfo(session) -- 2287
		if spawnInfo then -- 2287
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2289
			if normalizedPrompt == "" then -- 2289
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2291
			end -- 2291
		end -- 2291
	end -- 2291
	if normalizedPrompt == "" then -- 2291
		return {success = false, message = "prompt is empty"} -- 2300
	end -- 2300
	return startPromptTask( -- 2302
		session, -- 2302
		normalizedPrompt, -- 2302
		nil, -- 2302
		normalizeDisabledAgentTools(disabledAgentTools) -- 2302
	) -- 2302
end -- 2274
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools) -- 2305
	if disabledAgentTools == nil then -- 2305
		disabledAgentTools = {} -- 2305
	end -- 2305
	local taskRes = Tools.createTask(normalizedPrompt) -- 2306
	if not taskRes.success then -- 2306
		return {success = false, message = taskRes.message} -- 2308
	end -- 2308
	local taskId = taskRes.taskId -- 2310
	local useChineseResponse = getDefaultUseChineseResponse() -- 2311
	if existingUserMessageId ~= nil then -- 2311
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2313
	else -- 2313
		insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2315
	end -- 2315
	local stopToken = {stopped = false} -- 2317
	activeStopTokens[taskId] = stopToken -- 2318
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2319
	runCodingAgent( -- 2320
		{ -- 2320
			prompt = normalizedPrompt, -- 2321
			workDir = session.projectRoot, -- 2322
			useChineseResponse = useChineseResponse, -- 2323
			taskId = taskId, -- 2324
			sessionId = session.id, -- 2325
			memoryScope = session.memoryScope, -- 2326
			role = session.kind, -- 2327
			disabledAgentTools = disabledAgentTools, -- 2328
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2329
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2332
			stopToken = stopToken, -- 2335
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2336
		}, -- 2336
		function(result) -- 2337
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2337
				local nextSession = getSessionItem(session.id) -- 2338
				if nextSession and nextSession.kind == "sub" then -- 2338
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2338
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2341
						if not stopped.success then -- 2341
							Log( -- 2343
								"Warn", -- 2343
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2343
							) -- 2343
							emitAgentSessionPatch( -- 2344
								session.id, -- 2344
								{session = getSessionItem(session.id)} -- 2344
							) -- 2344
						end -- 2344
						__TS__Delete(activeStopTokens, taskId) -- 2348
						return ____awaiter_resolve(nil) -- 2348
					end -- 2348
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2351
					emitAgentSessionPatch( -- 2352
						session.id, -- 2352
						{session = getSessionItem(session.id)} -- 2352
					) -- 2352
					local finalized = __TS__Await(finalizeSubSession(nextSession, taskId, result.success, result.message)) -- 2355
					if not finalized.success then -- 2355
						Log( -- 2357
							"Warn", -- 2357
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2357
						) -- 2357
					end -- 2357
					local finalizedSession = getSessionItem(session.id) -- 2359
					if finalizedSession then -- 2359
						local stopped = stopToken.stopped == true -- 2361
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2362
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2365
						emitAgentSessionPatch( -- 2366
							session.id, -- 2366
							{session = getSessionItem(session.id)} -- 2366
						) -- 2366
					end -- 2366
					__TS__Delete(activeStopTokens, taskId) -- 2370
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2371
				end -- 2371
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2371
					applyEvent(session.id, { -- 2374
						type = "task_finished", -- 2375
						sessionId = session.id, -- 2376
						taskId = result.taskId, -- 2377
						success = false, -- 2378
						message = result.message, -- 2379
						steps = result.steps -- 2380
					}) -- 2380
				end -- 2380
			end) -- 2380
		end -- 2337
	) -- 2337
	return {success = true, sessionId = session.id, taskId = taskId} -- 2384
end -- 2384
function ____exports.listRunningSubAgents(request) -- 2472
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2472
		local session = getSessionItem(request.sessionId) -- 2480
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2480
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2482
		end -- 2482
		if not session then -- 2482
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2482
		end -- 2482
		local rootSession = getRootSessionItem(session.id) -- 2487
		if not rootSession then -- 2487
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2487
		end -- 2487
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2491
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2492
		local limit = math.max( -- 2493
			1, -- 2493
			math.floor(tonumber(request.limit) or 5) -- 2493
		) -- 2493
		local offset = math.max( -- 2494
			0, -- 2494
			math.floor(tonumber(request.offset) or 0) -- 2494
		) -- 2494
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2495
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2496
		local runningSessions = {} -- 2503
		do -- 2503
			local i = 0 -- 2504
			while i < #rows do -- 2504
				do -- 2504
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2505
					if current.currentTaskStatus ~= "RUNNING" then -- 2505
						goto __continue381 -- 2507
					end -- 2507
					local spawnInfo = getSessionSpawnInfo(current) -- 2509
					runningSessions[#runningSessions + 1] = { -- 2510
						sessionId = current.id, -- 2511
						title = current.title, -- 2512
						parentSessionId = current.parentSessionId, -- 2513
						rootSessionId = current.rootSessionId, -- 2514
						status = "RUNNING", -- 2515
						currentTaskId = current.currentTaskId, -- 2516
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2517
						goal = spawnInfo and spawnInfo.goal, -- 2518
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2519
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2520
						createdAt = current.createdAt, -- 2521
						updatedAt = current.updatedAt -- 2522
					} -- 2522
				end -- 2522
				::__continue381:: -- 2522
				i = i + 1 -- 2504
			end -- 2504
		end -- 2504
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2525
		local completedSessions = __TS__ArrayMap( -- 2526
			completedRecords, -- 2526
			function(____, record) return { -- 2526
				sessionId = record.sessionId, -- 2527
				title = record.title, -- 2528
				parentSessionId = record.parentSessionId, -- 2529
				rootSessionId = record.rootSessionId, -- 2530
				status = record.status, -- 2531
				goal = record.goal, -- 2532
				expectedOutput = record.expectedOutput, -- 2533
				filesHint = record.filesHint, -- 2534
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2535
				success = record.success, -- 2536
				cleared = record.cleared, -- 2537
				resultFilePath = record.resultFilePath, -- 2538
				artifactDir = record.artifactDir, -- 2539
				finishedAt = record.finishedAt, -- 2540
				createdAt = record.createdAtTs, -- 2541
				updatedAt = record.finishedAtTs -- 2542
			} end -- 2542
		) -- 2542
		local merged = {} -- 2544
		if status == "running" then -- 2544
			merged = runningSessions -- 2546
		elseif status == "done" then -- 2546
			merged = __TS__ArrayFilter( -- 2548
				completedSessions, -- 2548
				function(____, item) return item.status == "DONE" end -- 2548
			) -- 2548
		elseif status == "failed" then -- 2548
			merged = __TS__ArrayFilter( -- 2550
				completedSessions, -- 2550
				function(____, item) return item.status == "FAILED" end -- 2550
			) -- 2550
		elseif status == "stopped" then -- 2550
			merged = __TS__ArrayFilter( -- 2552
				completedSessions, -- 2552
				function(____, item) return item.status == "STOPPED" end -- 2552
			) -- 2552
		elseif status == "all" then -- 2552
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2554
		else -- 2554
			local runningKeys = {} -- 2556
			do -- 2556
				local i = 0 -- 2557
				while i < #runningSessions do -- 2557
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2558
					i = i + 1 -- 2557
				end -- 2557
			end -- 2557
			local latestCompletedByKey = {} -- 2560
			do -- 2560
				local i = 0 -- 2561
				while i < #completedSessions do -- 2561
					do -- 2561
						local item = completedSessions[i + 1] -- 2562
						local key = getSubAgentDisplayKey(item) -- 2563
						if runningKeys[key] then -- 2563
							goto __continue396 -- 2565
						end -- 2565
						local current = latestCompletedByKey[key] -- 2567
						if not current or item.updatedAt > current.updatedAt then -- 2567
							latestCompletedByKey[key] = item -- 2569
						end -- 2569
					end -- 2569
					::__continue396:: -- 2569
					i = i + 1 -- 2561
				end -- 2561
			end -- 2561
			local latestCompleted = {} -- 2572
			for ____, item in pairs(latestCompletedByKey) do -- 2573
				latestCompleted[#latestCompleted + 1] = item -- 2574
			end -- 2574
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2576
		end -- 2576
		if query ~= "" then -- 2576
			merged = __TS__ArrayFilter( -- 2579
				merged, -- 2579
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2579
			) -- 2579
		end -- 2579
		__TS__ArraySort( -- 2585
			merged, -- 2585
			function(____, a, b) -- 2585
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2585
					return -1 -- 2586
				end -- 2586
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2586
					return 1 -- 2587
				end -- 2587
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2587
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2589
				end -- 2589
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2591
			end -- 2585
		) -- 2585
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2593
		return ____awaiter_resolve(nil, { -- 2593
			success = true, -- 2595
			rootSessionId = rootSession.id, -- 2596
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2597
			status = status, -- 2598
			limit = limit, -- 2599
			offset = offset, -- 2600
			hasMore = offset + limit < #merged, -- 2601
			sessions = paged -- 2602
		}) -- 2602
	end) -- 2602
end -- 2472
TABLE_SESSION = "AgentSession" -- 197
TABLE_MESSAGE = "AgentSessionMessage" -- 198
TABLE_STEP = "AgentSessionStep" -- 199
TABLE_TASK = "AgentTask" -- 200
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 201
SPAWN_INFO_FILE = "SPAWN.json" -- 202
RESULT_FILE = "RESULT.md" -- 203
PENDING_HANDOFF_DIR = "pending-handoffs" -- 204
MAX_CONCURRENT_SUB_AGENTS = 4 -- 205
SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE = 0.1 -- 206
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS = 1024 -- 207
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY = 3 -- 208
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 209
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 210
SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS = 3000 -- 211
SUB_AGENT_MEMORY_RESULT_MAX_TOKENS = 2000 -- 212
SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES = 20 -- 213
SUB_AGENT_MEMORY_TAIL_MAX_TOKENS = 4000 -- 214
SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS = 600 -- 215
activeStopTokens = {} -- 261
finalizingSubSessionTaskIds = {} -- 262
now = function() return os.time() end -- 263
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 637
	if projectRoot == oldRoot then -- 637
		return newRoot -- 639
	end -- 639
	for ____, separator in ipairs({"/", "\\"}) do -- 641
		local prefix = oldRoot .. separator -- 642
		if __TS__StringStartsWith(projectRoot, prefix) then -- 642
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 644
		end -- 644
	end -- 644
	return nil -- 647
end -- 637
local function clearSessionAfterMessage(sessionId, message) -- 1319
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1320
	local removedStepIds = {} -- 1328
	do -- 1328
		local i = 0 -- 1329
		while i < #removedStepRows do -- 1329
			local row = removedStepRows[i + 1] -- 1330
			if type(row[1]) == "number" then -- 1330
				removedStepIds[#removedStepIds + 1] = row[1] -- 1332
			end -- 1332
			i = i + 1 -- 1329
		end -- 1329
	end -- 1329
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1335
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1343
	return removedStepIds -- 1348
end -- 1319
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1351
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1352
	local persisted = storage:readSessionState() -- 1353
	local userIndex = -1 -- 1354
	do -- 1354
		local i = #persisted.messages - 1 -- 1355
		while i >= 0 do -- 1355
			if persisted.messages[i + 1].role == "user" then -- 1355
				userIndex = i -- 1357
				break -- 1358
			end -- 1358
			i = i - 1 -- 1355
		end -- 1355
	end -- 1355
	if userIndex < 0 then -- 1355
		return -- 1361
	end -- 1361
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1362
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1363
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1364
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1369
end -- 1351
local function sanitizeStoredSteps(sessionId) -- 1523
	DB:exec( -- 1524
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1524
		{ -- 1542
			now(), -- 1542
			sessionId -- 1542
		} -- 1542
	) -- 1542
end -- 1523
local function getSchemaVersion() -- 1793
	local row = queryOne("PRAGMA user_version") -- 1794
	return row and type(row[1]) == "number" and row[1] or 0 -- 1795
end -- 1793
local function setSchemaVersion(version) -- 1798
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1799
		0, -- 1799
		math.floor(version) -- 1799
	))) -- 1799
end -- 1798
local function hasTableColumn(tableName, columnName) -- 1802
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1803
	do -- 1803
		local i = 0 -- 1804
		while i < #rows do -- 1804
			local row = rows[i + 1] -- 1805
			if toStr(row[2]) == columnName then -- 1805
				return true -- 1807
			end -- 1807
			i = i + 1 -- 1804
		end -- 1804
	end -- 1804
	return false -- 1810
end -- 1802
local function ensureSessionMetricsColumn() -- 1813
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1813
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1815
	end -- 1815
end -- 1813
local function recreateSchema() -- 1819
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1820
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1821
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1822
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1823
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1838
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1839
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1848
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1849
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1866
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1867
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1868
end -- 1819
do -- 1819
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1819
		recreateSchema() -- 1874
	else -- 1874
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1876
		ensureSessionMetricsColumn() -- 1891
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1892
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1893
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1902
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1903
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1920
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1921
	end -- 1921
end -- 1921
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2064
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2064
		return {success = false, message = "invalid projectRoot"} -- 2066
	end -- 2066
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2068
	for ____, row in ipairs(rows) do -- 2069
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2070
		if sessionId > 0 then -- 2070
			deleteSessionRecords(sessionId) -- 2072
		end -- 2072
	end -- 2072
	return {success = true, deleted = #rows} -- 2075
end -- 2064
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2078
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2078
		return {success = false, message = "invalid projectRoot"} -- 2080
	end -- 2080
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2082
	local renamed = 0 -- 2083
	for ____, row in ipairs(rows) do -- 2084
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2085
		local projectRoot = toStr(row[2]) -- 2086
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2087
		if sessionId > 0 and nextProjectRoot then -- 2087
			DB:exec( -- 2089
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2089
				{ -- 2091
					nextProjectRoot, -- 2091
					Path:getFilename(nextProjectRoot), -- 2091
					now(), -- 2091
					sessionId -- 2091
				} -- 2091
			) -- 2091
			renamed = renamed + 1 -- 2093
		end -- 2093
	end -- 2093
	return {success = true, renamed = renamed} -- 2096
end -- 2078
function ____exports.getSession(sessionId) -- 2099
	local session = getSessionItem(sessionId) -- 2100
	if not session then -- 2100
		return {success = false, message = "session not found"} -- 2102
	end -- 2102
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2104
	local relatedSessions = listRelatedSessions(sessionId) -- 2105
	sanitizeStoredSteps(sessionId) -- 2106
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2107
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2114
	local ____relatedSessions_45 = relatedSessions -- 2125
	local ____temp_44 -- 2126
	if normalizedSession.kind == "sub" then -- 2126
		____temp_44 = getSessionSpawnInfo(normalizedSession) -- 2126
	else -- 2126
		____temp_44 = nil -- 2126
	end -- 2126
	return { -- 2122
		success = true, -- 2123
		session = normalizedSession, -- 2124
		relatedSessions = ____relatedSessions_45, -- 2125
		spawnInfo = ____temp_44, -- 2126
		messages = __TS__ArrayMap( -- 2127
			messages, -- 2127
			function(____, row) return rowToMessage(row) end -- 2127
		), -- 2127
		steps = __TS__ArrayMap( -- 2128
			steps, -- 2128
			function(____, row) return rowToStep(row) end -- 2128
		), -- 2128
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 2129
	} -- 2129
end -- 2099
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools) -- 2387
	local session = getSessionItem(sessionId) -- 2388
	if not session then -- 2388
		return {success = false, message = "session not found"} -- 2390
	end -- 2390
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2390
		return {success = false, message = "session task is finalizing"} -- 2393
	end -- 2393
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2393
		return {success = false, message = "session task is still running"} -- 2396
	end -- 2396
	local message = getMessageItem(messageId) -- 2398
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2398
		return {success = false, message = "message not found"} -- 2400
	end -- 2400
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2402
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2408
	if latestUserMessageId ~= messageId then -- 2408
		return {success = false, message = "only the latest user prompt can be edited"} -- 2410
	end -- 2410
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2412
	if normalizedPrompt == "" then -- 2412
		return {success = false, message = "prompt is empty"} -- 2414
	end -- 2414
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2416
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2417
	local result = startPromptTask( -- 2418
		session, -- 2418
		normalizedPrompt, -- 2418
		messageId, -- 2418
		normalizeDisabledAgentTools(disabledAgentTools) -- 2418
	) -- 2418
	if result.success and #removedStepIds > 0 then -- 2418
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2420
	end -- 2420
	return result -- 2422
end -- 2387
function ____exports.stopSessionTask(sessionId) -- 2425
	local session = getSessionItem(sessionId) -- 2426
	if not session or session.currentTaskId == nil then -- 2426
		return {success = false, message = "session task not found"} -- 2428
	end -- 2428
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2428
		return {success = false, message = "session task is finalizing"} -- 2431
	end -- 2431
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2433
	local stopToken = activeStopTokens[session.currentTaskId] -- 2434
	if not stopToken then -- 2434
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2434
			return {success = true, recovered = true} -- 2437
		end -- 2437
		return {success = false, message = "task is not running"} -- 2439
	end -- 2439
	stopToken.stopped = true -- 2441
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2442
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2443
	return {success = true} -- 2444
end -- 2425
function ____exports.getCurrentTaskId(sessionId) -- 2447
	local ____opt_66 = getSessionItem(sessionId) -- 2447
	return ____opt_66 and ____opt_66.currentTaskId -- 2448
end -- 2447
function ____exports.listRunningSessions() -- 2451
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2452
	local sessions = {} -- 2459
	do -- 2459
		local i = 0 -- 2460
		while i < #rows do -- 2460
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2461
			if session.currentTaskStatus == "RUNNING" then -- 2461
				sessions[#sessions + 1] = session -- 2463
			end -- 2463
			i = i + 1 -- 2460
		end -- 2460
	end -- 2460
	return {success = true, sessions = sessions} -- 2466
end -- 2451
return ____exports -- 2451