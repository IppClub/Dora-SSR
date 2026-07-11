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
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildSubAgentMemoryEntryLLMOptions, formatSubAgentMemoryTailMessage, buildSubAgentRecentMessageTail, getMemoryEntryPlainContent, buildSubAgentMemoryEntriesBatchSystemPrompt, buildSubAgentMemoryEntryBatchItem, buildSubAgentMemoryEntriesBatchPrompt, buildSubAgentMemoryEntriesBatchRetryPrompt, findBatchMemoryElement, normalizeGeneratedBatchMemoryEntry, generateSubAgentMemoryEntries, backfillPendingHandoffMemoryEntry, backfillSpawnInfoMemoryEntry, finalizeMainAgentPendingHandoffs, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_BATCH_MAX_ITEMS, SUB_AGENT_MEMORY_ENTRY_BATCH_PER_ITEM_CONTEXT_TOKENS, SUB_AGENT_MEMORY_ENTRY_BATCH_PER_ITEM_RESULT_TOKENS, SUB_AGENT_MEMORY_ENTRY_BATCH_PER_ITEM_TAIL_TOKENS, SUB_AGENT_MEMORY_ENTRY_BATCH_MAX_TOKENS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
function getDefaultUseChineseResponse() -- 270
	local zh = string.match(App.locale, "^zh") -- 271
	return zh ~= nil -- 272
end -- 272
function toStr(v) -- 275
	if v == false or v == nil then -- 275
		return "" -- 276
	end -- 276
	return tostring(v) -- 277
end -- 277
function encodeJson(value) -- 280
	local text = safeJsonEncode(value) -- 281
	return text or "" -- 282
end -- 282
function decodeJsonObject(text) -- 285
	if not text or text == "" then -- 285
		return nil -- 286
	end -- 286
	local value = safeJsonDecode(text) -- 287
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 287
		return value -- 289
	end -- 289
	return nil -- 291
end -- 291
function decodeJsonFiles(text) -- 294
	if not text or text == "" then -- 294
		return nil -- 295
	end -- 295
	local value = safeJsonDecode(text) -- 296
	if not value or not __TS__ArrayIsArray(value) then -- 296
		return nil -- 297
	end -- 297
	local files = {} -- 298
	do -- 298
		local i = 0 -- 299
		while i < #value do -- 299
			do -- 299
				local item = value[i + 1] -- 300
				if type(item) ~= "table" then -- 300
					goto __continue14 -- 301
				end -- 301
				files[#files + 1] = { -- 302
					path = sanitizeUTF8(toStr(item.path)), -- 303
					op = sanitizeUTF8(toStr(item.op)) -- 304
				} -- 304
			end -- 304
			::__continue14:: -- 304
			i = i + 1 -- 299
		end -- 299
	end -- 299
	return files -- 307
end -- 307
function decodeChangeSetSummary(value) -- 310
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 310
		return nil -- 311
	end -- 311
	local row = value -- 312
	if row.success ~= true then -- 312
		return nil -- 313
	end -- 313
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 314
	if taskId <= 0 then -- 314
		return nil -- 315
	end -- 315
	local files = {} -- 316
	if __TS__ArrayIsArray(row.files) then -- 316
		do -- 316
			local i = 0 -- 318
			while i < #row.files do -- 318
				do -- 318
					local file = row.files[i + 1] -- 319
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 319
						goto __continue22 -- 320
					end -- 320
					local fileRow = file -- 321
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 322
					if path == "" then -- 322
						goto __continue22 -- 323
					end -- 323
					local checkpointIds = {} -- 324
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 324
						do -- 324
							local j = 0 -- 326
							while j < #fileRow.checkpointIds do -- 326
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 327
								if checkpointId > 0 then -- 327
									checkpointIds[#checkpointIds + 1] = checkpointId -- 328
								end -- 328
								j = j + 1 -- 326
							end -- 326
						end -- 326
					end -- 326
					local op = toStr(fileRow.op) -- 331
					files[#files + 1] = { -- 332
						path = path, -- 333
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 334
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 335
						checkpointIds = checkpointIds -- 336
					} -- 336
				end -- 336
				::__continue22:: -- 336
				i = i + 1 -- 318
			end -- 318
		end -- 318
	end -- 318
	return { -- 340
		success = true, -- 341
		taskId = taskId, -- 342
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 343
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 344
		files = files, -- 345
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 346
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 347
	} -- 347
end -- 347
function takeUtf8Head(text, maxChars) -- 351
	if maxChars <= 0 or text == "" then -- 351
		return "" -- 352
	end -- 352
	local nextPos = utf8.offset(text, maxChars + 1) -- 353
	if nextPos == nil then -- 353
		return text -- 354
	end -- 354
	return string.sub(text, 1, nextPos - 1) -- 355
end -- 355
function normalizeMemoryEntryEvidence(value) -- 358
	local evidence = {} -- 359
	if not __TS__ArrayIsArray(value) then -- 359
		return evidence -- 360
	end -- 360
	do -- 360
		local i = 0 -- 361
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 361
			do -- 361
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 362
				if item == "" then -- 362
					goto __continue35 -- 363
				end -- 363
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 363
					evidence[#evidence + 1] = item -- 365
				end -- 365
			end -- 365
			::__continue35:: -- 365
			i = i + 1 -- 361
		end -- 361
	end -- 361
	return evidence -- 368
end -- 368
function decodeSubAgentMemoryEntry(value) -- 371
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 371
		return nil -- 372
	end -- 372
	local row = value -- 373
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 374
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 375
	local content = takeUtf8Head( -- 376
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 376
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 376
	) -- 376
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 376
		return nil -- 377
	end -- 377
	return { -- 378
		sourceSessionId = sourceSessionId, -- 379
		sourceTaskId = sourceTaskId, -- 380
		content = content, -- 381
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 382
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 383
	} -- 383
end -- 383
function getTaskChangeSetSummary(taskId) -- 387
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 388
	return summary.success and summary or nil -- 389
end -- 389
function queryRows(sql, args) -- 392
	local ____args_0 -- 393
	if args then -- 393
		____args_0 = DB:query(sql, args) -- 393
	else -- 393
		____args_0 = DB:query(sql) -- 393
	end -- 393
	return ____args_0 -- 393
end -- 393
function queryOne(sql, args) -- 396
	local rows = queryRows(sql, args) -- 397
	if not rows or #rows == 0 then -- 397
		return nil -- 398
	end -- 398
	return rows[1] -- 399
end -- 399
function getLastInsertRowId() -- 402
	local row = queryOne("SELECT last_insert_rowid()") -- 403
	return row and (row[1] or 0) or 0 -- 404
end -- 404
function isValidProjectRoot(path) -- 407
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 408
end -- 408
function rowToSession(row) -- 411
	return { -- 412
		id = row[1], -- 413
		projectRoot = toStr(row[2]), -- 414
		title = toStr(row[3]), -- 415
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 416
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 417
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 418
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 419
		status = toStr(row[8]), -- 420
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 421
		currentTaskStatus = toStr(row[10]), -- 422
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 423
		createdAt = row[11], -- 424
		updatedAt = row[12], -- 425
		metrics = decodeJsonObject(toStr(row[13])) -- 426
	} -- 426
end -- 426
function rowToMessage(row) -- 430
	return { -- 431
		id = row[1], -- 432
		sessionId = row[2], -- 433
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 434
		role = toStr(row[4]), -- 435
		content = toStr(row[5]), -- 436
		createdAt = row[6], -- 437
		updatedAt = row[7] -- 438
	} -- 438
end -- 438
function rowToStep(row) -- 442
	return { -- 443
		id = row[1], -- 444
		sessionId = row[2], -- 445
		taskId = row[3], -- 446
		step = row[4], -- 447
		tool = toStr(row[5]), -- 448
		status = toStr(row[6]), -- 449
		reason = toStr(row[7]), -- 450
		reasoningContent = toStr(row[8]), -- 451
		params = decodeJsonObject(toStr(row[9])), -- 452
		result = decodeJsonObject(toStr(row[10])), -- 453
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 454
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 455
		files = decodeJsonFiles(toStr(row[13])), -- 456
		createdAt = row[14], -- 457
		updatedAt = row[15] -- 458
	} -- 458
end -- 458
function getMessageItem(messageId) -- 462
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 463
	return row and rowToMessage(row) or nil -- 469
end -- 469
function getStepItem(sessionId, taskId, step) -- 472
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 473
	return row and rowToStep(row) or nil -- 479
end -- 479
function deleteMessageSteps(sessionId, taskId) -- 482
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 483
	local ids = {} -- 488
	do -- 488
		local i = 0 -- 489
		while i < #rows do -- 489
			local row = rows[i + 1] -- 490
			if type(row[1]) == "number" then -- 490
				ids[#ids + 1] = row[1] -- 492
			end -- 492
			i = i + 1 -- 489
		end -- 489
	end -- 489
	if #ids > 0 then -- 489
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 496
	end -- 496
	return ids -- 502
end -- 502
function normalizeDisabledAgentTools(value) -- 505
	if not __TS__ArrayIsArray(value) then -- 505
		return {} -- 506
	end -- 506
	local tools = {} -- 507
	do -- 507
		local i = 0 -- 508
		while i < #value do -- 508
			do -- 508
				local name = value[i + 1] -- 509
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 509
					goto __continue60 -- 510
				end -- 510
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 510
					tools[#tools + 1] = name -- 511
				end -- 511
			end -- 511
			::__continue60:: -- 511
			i = i + 1 -- 508
		end -- 508
	end -- 508
	return tools -- 513
end -- 513
function getSessionRow(sessionId) -- 516
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 517
end -- 517
function getSessionItem(sessionId) -- 525
	local row = getSessionRow(sessionId) -- 526
	return row and rowToSession(row) or nil -- 527
end -- 527
function getTaskPrompt(taskId) -- 530
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 531
	if not row or type(row[1]) ~= "string" then -- 531
		return nil -- 532
	end -- 532
	return toStr(row[1]) -- 533
end -- 533
function getLatestMainSessionByProjectRoot(projectRoot) -- 536
	if not isValidProjectRoot(projectRoot) then -- 536
		return nil -- 537
	end -- 537
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 538
	return row and rowToSession(row) or nil -- 546
end -- 546
function countRunningSubSessions(rootSessionId) -- 549
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 550
	local count = 0 -- 557
	do -- 557
		local i = 0 -- 558
		while i < #rows do -- 558
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 559
			if session.currentTaskStatus == "RUNNING" then -- 559
				count = count + 1 -- 561
			end -- 561
			i = i + 1 -- 558
		end -- 558
	end -- 558
	return count -- 564
end -- 564
function deleteSessionRecords(sessionId, preserveArtifacts) -- 567
	if preserveArtifacts == nil then -- 567
		preserveArtifacts = false -- 567
	end -- 567
	local session = getSessionItem(sessionId) -- 568
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 569
	do -- 569
		local i = 0 -- 570
		while i < #children do -- 570
			local row = children[i + 1] -- 571
			if type(row[1]) == "number" and row[1] > 0 then -- 571
				deleteSessionRecords(row[1], preserveArtifacts) -- 573
			end -- 573
			i = i + 1 -- 570
		end -- 570
	end -- 570
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 576
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 577
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 578
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 579
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 579
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 581
	end -- 581
end -- 581
function getSessionRootId(session) -- 585
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 586
end -- 586
function getRootSessionItem(sessionId) -- 589
	local session = getSessionItem(sessionId) -- 590
	if not session then -- 590
		return nil -- 591
	end -- 591
	return getSessionItem(getSessionRootId(session)) or session -- 592
end -- 592
function listRelatedSessions(sessionId) -- 595
	local root = getRootSessionItem(sessionId) -- 596
	if not root then -- 596
		return {} -- 597
	end -- 597
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 598
	return __TS__ArrayMap( -- 607
		rows, -- 607
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 607
	) -- 607
end -- 607
function getSessionSpawnInfo(session) -- 610
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 611
	if not info then -- 611
		return nil -- 612
	end -- 612
	local ____temp_4 = type(info.sessionId) == "number" and info.sessionId or nil -- 614
	local ____temp_5 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 615
	local ____temp_6 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 616
	local ____temp_7 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 617
	local ____temp_8 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 618
	local ____temp_9 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 619
	local ____temp_10 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 620
	local ____temp_11 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 621
		__TS__ArrayFilter( -- 622
			info.filesHint, -- 622
			function(____, item) return type(item) == "string" end -- 622
		), -- 622
		function(____, item) return sanitizeUTF8(item) end -- 622
	) or nil -- 622
	local ____temp_12 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 624
	local ____temp_2 -- 627
	if info.success == true then -- 627
		____temp_2 = true -- 627
	else -- 627
		local ____temp_1 -- 627
		if info.success == false then -- 627
			____temp_1 = false -- 627
		else -- 627
			____temp_1 = nil -- 627
		end -- 627
		____temp_2 = ____temp_1 -- 627
	end -- 627
	local ____temp_3 -- 628
	if info.cleared == true then -- 628
		____temp_3 = true -- 628
	else -- 628
		____temp_3 = nil -- 628
	end -- 628
	return { -- 613
		sessionId = ____temp_4, -- 614
		rootSessionId = ____temp_5, -- 615
		parentSessionId = ____temp_6, -- 616
		title = ____temp_7, -- 617
		prompt = ____temp_8, -- 618
		goal = ____temp_9, -- 619
		expectedOutput = ____temp_10, -- 620
		filesHint = ____temp_11, -- 621
		status = ____temp_12, -- 624
		success = ____temp_2, -- 627
		cleared = ____temp_3, -- 628
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 629
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 630
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 631
		changeSet = decodeChangeSetSummary(info.changeSet), -- 632
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 633
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 634
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 635
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 636
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 637
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 638
	} -- 638
end -- 638
function ensureDirRecursive(dir) -- 655
	if not dir or dir == "" then -- 655
		return false -- 656
	end -- 656
	if Content:exist(dir) then -- 656
		return Content:isdir(dir) -- 657
	end -- 657
	local parent = Path:getPath(dir) -- 658
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 658
		if not ensureDirRecursive(parent) then -- 658
			return false -- 661
		end -- 661
	end -- 661
	return Content:mkdir(dir) -- 664
end -- 664
function writeSpawnInfo(projectRoot, memoryScope, value) -- 667
	local dir = Path(projectRoot, ".agent", memoryScope) -- 668
	if not Content:exist(dir) then -- 668
		ensureDirRecursive(dir) -- 670
	end -- 670
	local path = Path(dir, SPAWN_INFO_FILE) -- 672
	local text = safeJsonEncode(value) -- 673
	if not text then -- 673
		return false -- 674
	end -- 674
	local content = text .. "\n" -- 675
	if not Content:save(path, content) then -- 675
		return false -- 677
	end -- 677
	Tools.sendWebIDEFileUpdate(path, true, content) -- 679
	return true -- 680
end -- 680
function readSpawnInfo(projectRoot, memoryScope) -- 683
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 684
	if not Content:exist(path) then -- 684
		return nil -- 685
	end -- 685
	local text = Content:load(path) -- 686
	if not text or __TS__StringTrim(text) == "" then -- 686
		return nil -- 687
	end -- 687
	local value = safeJsonDecode(text) -- 688
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 688
		return value -- 690
	end -- 690
	return nil -- 692
end -- 692
function getArtifactRelativeDir(memoryScope) -- 695
	return Path(".agent", memoryScope) -- 696
end -- 696
function getArtifactDir(projectRoot, memoryScope) -- 699
	return Path( -- 700
		projectRoot, -- 700
		getArtifactRelativeDir(memoryScope) -- 700
	) -- 700
end -- 700
function getResultRelativePath(memoryScope) -- 703
	return Path( -- 704
		getArtifactRelativeDir(memoryScope), -- 704
		RESULT_FILE -- 704
	) -- 704
end -- 704
function getResultPath(projectRoot, memoryScope) -- 707
	return Path( -- 708
		projectRoot, -- 708
		getResultRelativePath(memoryScope) -- 708
	) -- 708
end -- 708
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 711
	if not resultFilePath or resultFilePath == "" then -- 711
		return "" -- 712
	end -- 712
	local path = Path(projectRoot, resultFilePath) -- 713
	if not Content:exist(path) then -- 713
		return "" -- 714
	end -- 714
	local text = sanitizeUTF8(Content:load(path)) -- 715
	if not text or __TS__StringTrim(text) == "" then -- 715
		return "" -- 716
	end -- 716
	local marker = "\n## Summary\n" -- 717
	local start = string.find(text, marker, 1, true) -- 718
	if start ~= nil then -- 718
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 720
	end -- 720
	return __TS__StringTrim(text) -- 722
end -- 722
function buildSubAgentMemoryEntryLLMOptions(llmConfig) -- 725
	local options = { -- 726
		temperature = llmConfig.temperature or SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, -- 727
		max_tokens = math.min(llmConfig.maxTokens or SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS) -- 728
	} -- 728
	if llmConfig.reasoningEffort then -- 728
		options.reasoning_effort = __TS__StringTrim(llmConfig.reasoningEffort) -- 731
	end -- 731
	if type(options.reasoning_effort) ~= "string" or __TS__StringTrim(options.reasoning_effort) == "" then -- 731
		__TS__Delete(options, "reasoning_effort") -- 734
	end -- 734
	return options -- 736
end -- 736
function formatSubAgentMemoryTailMessage(message) -- 739
	local lines = {"role: " .. sanitizeUTF8(toStr(message.role))} -- 740
	if type(message.name) == "string" and message.name ~= "" then -- 740
		lines[#lines + 1] = "name: " .. sanitizeUTF8(message.name) -- 742
	end -- 742
	if type(message.tool_call_id) == "string" and message.tool_call_id ~= "" then -- 742
		lines[#lines + 1] = "tool_call_id: " .. sanitizeUTF8(message.tool_call_id) -- 745
	end -- 745
	local content = type(message.content) == "string" and clipTextToTokenBudget( -- 747
		sanitizeUTF8(message.content), -- 748
		SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS -- 748
	) or "" -- 748
	if content ~= "" then -- 748
		lines[#lines + 1] = "content:\n" .. content -- 751
	end -- 751
	if __TS__ArrayIsArray(message.tool_calls) and #message.tool_calls > 0 then -- 751
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 754
		if toolCallsText ~= nil and toolCallsText ~= "" then -- 754
			lines[#lines + 1] = "tool_calls:\n" .. clipTextToTokenBudget(toolCallsText, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS) -- 756
		end -- 756
	end -- 756
	return table.concat(lines, "\n") -- 759
end -- 759
function buildSubAgentRecentMessageTail(messages) -- 762
	local parts = {} -- 763
	local totalTokens = 0 -- 764
	local count = 0 -- 765
	do -- 765
		local i = #messages - 1 -- 766
		while i >= 0 and count < SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES do -- 766
			do -- 766
				local text = formatSubAgentMemoryTailMessage(messages[i + 1]) -- 767
				if text == "" then -- 767
					goto __continue126 -- 768
				end -- 768
				local tokens = estimateTextTokens(text) -- 769
				if #parts > 0 and totalTokens + tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS then -- 769
					break -- 770
				end -- 770
				if tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS and #parts == 0 then -- 770
					__TS__ArrayUnshift( -- 772
						parts, -- 772
						clipTextToTokenBudget(text, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS) -- 772
					) -- 772
					break -- 773
				end -- 773
				__TS__ArrayUnshift(parts, text) -- 775
				totalTokens = totalTokens + tokens -- 776
				count = count + 1 -- 777
			end -- 777
			::__continue126:: -- 777
			i = i - 1 -- 766
		end -- 766
	end -- 766
	return #parts > 0 and table.concat(parts, "\n\n---\n\n") or "(empty)"
end -- 779
function getMemoryEntryPlainContent(response) -- 782
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 782
		return "" -- 783
	end -- 783
	local row = response -- 784
	local choices = row.choices -- 785
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 785
		return "" -- 786
	end -- 786
	local ____opt_13 = choices[1] -- 786
	if ____opt_13 ~= nil then -- 786
		____opt_13 = ____opt_13.message -- 786
	end -- 786
	local message = ____opt_13 -- 787
	local ____opt_result_17 -- 787
	if message ~= nil then -- 787
		____opt_result_17 = message.content -- 787
	end -- 787
	return type(____opt_result_17) == "string" and __TS__StringTrim(sanitizeUTF8(message.content)) or "" -- 788
end -- 788
function buildSubAgentMemoryEntriesBatchSystemPrompt() -- 828
	return "You generate durable memory entries for the parent Dora agent, one per completed sub-agent listed below.\nReturn exactly one JSON array (no Markdown fences, no prose). Each element must be:\n{\"sourceSessionId\": <number>, \"content\": \"<one compact paragraph or empty string>\", \"evidence\": [\"<short file/artifact path>\", ...]}\n\nRules:\n- Output one object per sub-agent, matching its sourceSessionId exactly.\n- content is a concise paragraph of durable facts worth carrying into future main-agent context: implemented behavior, design decisions, constraints, discovered project conventions, follow-up risks.\n- Use an empty string content when a sub-agent produced nothing worth remembering.\n- No generic progress narration, praise, or temporary execution details.\n- Keep evidence short and concrete (touched file paths, result artifact paths)." -- 829
end -- 829
function buildSubAgentMemoryEntryBatchItem(rootSession, item) -- 841
	local subScope = Path( -- 842
		"subagents", -- 842
		tostring(item.sourceSessionId) -- 842
	) -- 842
	local storage = __TS__New(DualLayerStorage, rootSession.projectRoot, subScope) -- 843
	local memoryContext = storage:readMemory() -- 844
	local persisted = storage:readSessionState() -- 845
	local tailRaw = buildSubAgentRecentMessageTail(persisted.messages) -- 846
	local resultText = readSubAgentResultSummary(rootSession.projectRoot, item.resultFilePath or "") -- 847
	return { -- 848
		item = item, -- 849
		memoryContext = clipTextToTokenBudget(memoryContext ~= "" and memoryContext or "(empty)", SUB_AGENT_MEMORY_ENTRY_BATCH_PER_ITEM_CONTEXT_TOKENS), -- 850
		recentMessageTail = clipTextToTokenBudget(tailRaw ~= "" and tailRaw or "(empty)", SUB_AGENT_MEMORY_ENTRY_BATCH_PER_ITEM_TAIL_TOKENS), -- 851
		resultText = clipTextToTokenBudget(resultText ~= "" and resultText or "(empty)", SUB_AGENT_MEMORY_ENTRY_BATCH_PER_ITEM_RESULT_TOKENS) -- 852
	} -- 852
end -- 852
function buildSubAgentMemoryEntriesBatchPrompt(batchItems) -- 856
	local rootContext = #batchItems > 0 and batchItems[1].memoryContext or "(empty)" -- 857
	local blocks = {} -- 858
	do -- 858
		local i = 0 -- 859
		while i < #batchItems do -- 859
			local bi = batchItems[i + 1] -- 860
			local item = bi.item -- 861
			local ____opt_18 = item.changeSet -- 861
			local files = ____opt_18 and ____opt_18.files or ({}) -- 862
			local changedFiles = table.concat( -- 863
				__TS__ArrayMap( -- 863
					files, -- 863
					function(____, f) return ((("- " .. f.path) .. " (") .. f.op) .. ")" end -- 863
				), -- 863
				"\n" -- 863
			) -- 863
			blocks[#blocks + 1] = (((((((((((((((("=== sourceSessionId: " .. tostring(item.sourceSessionId)) .. " (taskId ") .. tostring(item.sourceTaskId)) .. ") ===\ntitle: ") .. item.sourceTitle) .. "\ngoal: ") .. item.goal) .. "\nprompt: ") .. item.prompt) .. "\nexpectedOutput: ") .. (item.expectedOutput or "")) .. "\nchanged files:\n") .. (changedFiles ~= "" and changedFiles or "- none")) .. "\nresult summary:\n") .. bi.resultText) .. "\nrecent tail:\n") .. bi.recentMessageTail -- 864
			i = i + 1 -- 859
		end -- 859
	end -- 859
	return ((("Shared existing memory (truncated):\n" .. rootContext) .. "\n\nSub-agents to summarize:\n") .. table.concat(blocks, "\n\n")) .. "\n\nReturn the JSON array now." -- 876
end -- 876
function buildSubAgentMemoryEntriesBatchRetryPrompt(lastError) -- 885
	return ("Previous batch response was invalid: " .. lastError) .. "\n\nRetry with exactly one JSON array of objects, no Markdown fences, no prose.\nEach object: {\"sourceSessionId\": <number>, \"content\": \"<paragraph or empty string>\", \"evidence\": [\"...\"]}" -- 886
end -- 886
function findBatchMemoryElement(parsed, sourceSessionId) -- 892
	do -- 892
		local i = 0 -- 893
		while i < #parsed do -- 893
			do -- 893
				local el = parsed[i + 1] -- 894
				if not el or __TS__ArrayIsArray(el) or type(el) ~= "table" then -- 894
					goto __continue150 -- 895
				end -- 895
				local row = el -- 896
				local rawId = row.sourceSessionId -- 897
				local ____temp_21 -- 898
				if type(rawId) == "number" then -- 898
					____temp_21 = rawId -- 898
				else -- 898
					local ____temp_20 -- 898
					if type(rawId) == "string" then -- 898
						____temp_20 = tonumber(rawId) -- 898
					else -- 898
						____temp_20 = nil -- 898
					end -- 898
					____temp_21 = ____temp_20 -- 898
				end -- 898
				local sid = ____temp_21 -- 898
				if sid == sourceSessionId then -- 898
					return el -- 899
				end -- 899
			end -- 899
			::__continue150:: -- 899
			i = i + 1 -- 893
		end -- 893
	end -- 893
	return nil -- 901
end -- 901
function normalizeGeneratedBatchMemoryEntry(element, item) -- 905
	if not element or __TS__ArrayIsArray(element) or type(element) ~= "table" then -- 905
		return {} -- 906
	end -- 906
	local row = element -- 907
	local rawId = row.sourceSessionId -- 908
	local ____temp_23 -- 909
	if type(rawId) == "number" then -- 909
		____temp_23 = rawId -- 909
	else -- 909
		local ____temp_22 -- 909
		if type(rawId) == "string" then -- 909
			____temp_22 = tonumber(rawId) -- 909
		else -- 909
			____temp_22 = nil -- 909
		end -- 909
		____temp_23 = ____temp_22 -- 909
	end -- 909
	local sid = ____temp_23 -- 909
	if sid ~= item.sourceSessionId then -- 909
		return {} -- 910
	end -- 910
	if type(row.content) ~= "string" then -- 910
		return {} -- 911
	end -- 911
	local content = takeUtf8Head( -- 912
		__TS__StringTrim(sanitizeUTF8(row.content)), -- 912
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 912
	) -- 912
	if content == "" then -- 912
		return {skipped = true} -- 913
	end -- 913
	return {entry = { -- 914
		sourceSessionId = item.sourceSessionId, -- 916
		sourceTaskId = item.sourceTaskId, -- 917
		content = content, -- 918
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 919
		createdAt = item.finishedAt or "" -- 920
	}} -- 920
end -- 920
function generateSubAgentMemoryEntries(rootSession, items) -- 925
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 925
		local entries = {} -- 929
		local errors = {} -- 930
		if #items == 0 then -- 930
			return ____awaiter_resolve(nil, {entries = entries, errors = errors}) -- 930
		end -- 930
		local configRes = getActiveLLMConfig() -- 932
		if not configRes.success then -- 932
			return ____awaiter_resolve(nil, {entries = entries, errors = errors, fatal = configRes.message}) -- 932
		end -- 932
		local config = configRes.config -- 936
		do -- 936
			local start = 0 -- 937
			while start < #items do -- 937
				local slice = {} -- 938
				do -- 938
					local i = start -- 939
					while i < #items and #slice < SUB_AGENT_MEMORY_ENTRY_BATCH_MAX_ITEMS do -- 939
						slice[#slice + 1] = items[i + 1] -- 940
						i = i + 1 -- 939
					end -- 939
				end -- 939
				local batchItems = __TS__ArrayMap( -- 942
					slice, -- 942
					function(____, it) return buildSubAgentMemoryEntryBatchItem(rootSession, it) end -- 942
				) -- 942
				local prompt = buildSubAgentMemoryEntriesBatchPrompt(batchItems) -- 943
				local lastError = "missing batch memory entries" -- 944
				local settled = false -- 945
				do -- 945
					local attempt = 0 -- 946
					while attempt < SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY and not settled do -- 946
						do -- 946
							local messages = { -- 947
								{ -- 948
									role = "system", -- 948
									content = buildSubAgentMemoryEntriesBatchSystemPrompt() -- 948
								}, -- 948
								{ -- 949
									role = "user", -- 950
									content = attempt == 0 and prompt or (prompt .. "\n\n") .. buildSubAgentMemoryEntriesBatchRetryPrompt(lastError) -- 951
								} -- 951
							} -- 951
							local options = buildSubAgentMemoryEntryLLMOptions(config) -- 956
							options.max_tokens = SUB_AGENT_MEMORY_ENTRY_BATCH_MAX_TOKENS -- 957
							local response = __TS__Await(callLLM(messages, options, config)) -- 958
							if not response.success then -- 958
								lastError = response.message -- 960
								goto __continue167 -- 961
							end -- 961
							local plainContent = getMemoryEntryPlainContent(response.response) -- 963
							if plainContent == "" then -- 963
								lastError = "LLM returned no content" -- 965
								goto __continue167 -- 966
							end -- 966
							local parsed, parseErr = safeJsonDecode(plainContent) -- 968
							if parseErr ~= nil or not __TS__ArrayIsArray(parsed) then -- 968
								lastError = "invalid batch JSON: " .. tostring(parseErr or "not an array") -- 970
								goto __continue167 -- 971
							end -- 971
							do -- 971
								local i = 0 -- 973
								while i < #slice do -- 973
									do -- 973
										local it = slice[i + 1] -- 974
										if entries[it.sourceSessionId] ~= nil then -- 974
											goto __continue172 -- 975
										end -- 975
										local matched = findBatchMemoryElement(parsed, it.sourceSessionId) -- 976
										local norm = normalizeGeneratedBatchMemoryEntry(matched, it) -- 977
										if norm.entry ~= nil then -- 977
											entries[it.sourceSessionId] = norm.entry -- 979
										elseif norm.skipped == true then -- 979
										elseif matched == nil then -- 979
											if errors[it.sourceSessionId] == nil then -- 979
												errors[it.sourceSessionId] = "no entry for sourceSessionId in batch response" -- 983
											end -- 983
										elseif errors[it.sourceSessionId] == nil then -- 983
											errors[it.sourceSessionId] = "invalid entry shape" -- 985
										end -- 985
									end -- 985
									::__continue172:: -- 985
									i = i + 1 -- 973
								end -- 973
							end -- 973
							settled = true -- 988
						end -- 988
						::__continue167:: -- 988
						attempt = attempt + 1 -- 946
					end -- 946
				end -- 946
				if not settled then -- 946
					do -- 946
						local i = 0 -- 991
						while i < #slice do -- 991
							local sid = slice[i + 1].sourceSessionId -- 992
							if entries[sid] == nil and errors[sid] == nil then -- 992
								errors[sid] = lastError -- 994
							end -- 994
							i = i + 1 -- 991
						end -- 991
					end -- 991
					Log( -- 997
						"Warn", -- 997
						(((("[AgentSession] batch memory entry failed root=" .. tostring(rootSession.id)) .. " start=") .. tostring(start)) .. " error=") .. lastError -- 997
					) -- 997
				end -- 997
				start = start + SUB_AGENT_MEMORY_ENTRY_BATCH_MAX_ITEMS -- 937
			end -- 937
		end -- 937
		return ____awaiter_resolve(nil, {entries = entries, errors = errors}) -- 937
	end) -- 937
end -- 937
function backfillPendingHandoffMemoryEntry(rootSession, item, entry) -- 1003
	local dir = getPendingHandoffDir(rootSession.projectRoot, rootSession.memoryScope) -- 1004
	local path = Path(dir, item.id .. ".json") -- 1005
	local text = Content:load(path) -- 1006
	if not text then -- 1006
		return false -- 1007
	end -- 1007
	local obj = safeJsonDecode(text) -- 1008
	if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1008
		return false -- 1009
	end -- 1009
	local value = obj -- 1010
	if entry ~= nil then -- 1010
		value.memoryEntry = entry -- 1012
	else -- 1012
		__TS__Delete(value, "memoryEntry") -- 1014
	end -- 1014
	return writePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, value) -- 1016
end -- 1016
function backfillSpawnInfoMemoryEntry(rootSession, item, entry, errorMessage) -- 1019
	local subScope = Path( -- 1020
		"subagents", -- 1020
		tostring(item.sourceSessionId) -- 1020
	) -- 1020
	local info = readSpawnInfo(rootSession.projectRoot, subScope) -- 1021
	if not info then -- 1021
		return false -- 1022
	end -- 1022
	if entry ~= nil then -- 1022
		info.memoryEntry = entry -- 1024
	else -- 1024
		__TS__Delete(info, "memoryEntry") -- 1026
	end -- 1026
	if errorMessage ~= nil and errorMessage ~= "" then -- 1026
		info.memoryEntryError = errorMessage -- 1029
	end -- 1029
	return writeSpawnInfo(rootSession.projectRoot, subScope, info) -- 1031
end -- 1031
function finalizeMainAgentPendingHandoffs(rootSession) -- 1034
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1034
		if rootSession.kind ~= "main" then -- 1034
			return ____awaiter_resolve(nil) -- 1034
		end -- 1034
		local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1036
		if #items == 0 then -- 1036
			return ____awaiter_resolve(nil) -- 1036
		end -- 1036
		local successItems = __TS__ArrayFilter( -- 1038
			items, -- 1038
			function(____, it) return it.success ~= false end -- 1038
		) -- 1038
		if #successItems > 0 then -- 1038
			local result = __TS__Await(generateSubAgentMemoryEntries(rootSession, successItems)) -- 1040
			if result.fatal then -- 1040
				Log( -- 1042
					"Warn", -- 1042
					(("[AgentSession] batch memory entry fatal root=" .. tostring(rootSession.id)) .. " error=") .. result.fatal -- 1042
				) -- 1042
			end -- 1042
			do -- 1042
				local i = 0 -- 1044
				while i < #successItems do -- 1044
					local it = successItems[i + 1] -- 1045
					local entry = result.entries[it.sourceSessionId] -- 1046
					local err = result.errors[it.sourceSessionId] or result.fatal -- 1047
					backfillPendingHandoffMemoryEntry(rootSession, it, entry) -- 1048
					backfillSpawnInfoMemoryEntry(rootSession, it, entry, err) -- 1049
					i = i + 1 -- 1044
				end -- 1044
			end -- 1044
		end -- 1044
		flushPendingSubAgentHandoffs(rootSession) -- 1052
	end) -- 1052
end -- 1052
function containsNormalizedText(text, query) -- 1055
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1056
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1057
	if normalizedQuery == "" then -- 1057
		return true -- 1058
	end -- 1058
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1059
end -- 1059
function getSubAgentDisplayKey(item) -- 1062
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1068
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1069
	local label = goal ~= "" and goal or title -- 1070
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1071
end -- 1071
function writeSubAgentResultFile(session, record, resultText) -- 1074
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1075
	if not Content:exist(dir) then -- 1075
		ensureDirRecursive(dir) -- 1077
	end -- 1077
	local ____array_24 = __TS__SparseArrayNew( -- 1077
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1080
		"- Status: " .. record.status, -- 1081
		"- Success: " .. (record.success and "true" or "false"), -- 1082
		"- Session ID: " .. tostring(record.sessionId), -- 1083
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1084
		"- Goal: " .. record.goal, -- 1085
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1086
	) -- 1086
	__TS__SparseArrayPush( -- 1086
		____array_24, -- 1086
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1087
	) -- 1087
	__TS__SparseArrayPush( -- 1087
		____array_24, -- 1087
		"- Finished At: " .. record.finishedAt, -- 1088
		"", -- 1089
		"## Summary", -- 1090
		resultText ~= "" and resultText or "(empty)" -- 1091
	) -- 1091
	local lines = {__TS__SparseArraySpread(____array_24)} -- 1079
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1093
	local content = table.concat(lines, "\n") .. "\n" -- 1094
	if not Content:save(path, content) then -- 1094
		return false -- 1096
	end -- 1096
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1098
	return true -- 1099
end -- 1099
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1102
	local dir = Path(projectRoot, ".agent", "subagents") -- 1103
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1103
		return {} -- 1104
	end -- 1104
	local items = {} -- 1105
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1106
		do -- 1106
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1107
			if not Content:exist(path) or not Content:isdir(path) then -- 1107
				goto __continue209 -- 1108
			end -- 1108
			local info = readSpawnInfo( -- 1109
				projectRoot, -- 1109
				Path( -- 1109
					"subagents", -- 1109
					Path:getFilename(path) -- 1109
				) -- 1109
			) -- 1109
			if not info then -- 1109
				goto __continue209 -- 1110
			end -- 1110
			local sessionId = tonumber(info.sessionId) -- 1111
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1112
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1113
			local status = sanitizeUTF8(toStr(info.status)) -- 1114
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1114
				goto __continue209 -- 1115
			end -- 1115
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1115
				goto __continue209 -- 1116
			end -- 1116
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1117
			items[#items + 1] = { -- 1118
				sessionId = sessionId, -- 1119
				rootSessionId = infoRootSessionId, -- 1120
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1121
				title = sanitizeUTF8(toStr(info.title)), -- 1122
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1123
				goal = sanitizeUTF8(toStr(info.goal)), -- 1124
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1125
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1126
					__TS__ArrayFilter( -- 1127
						info.filesHint, -- 1127
						function(____, item) return type(item) == "string" end -- 1127
					), -- 1127
					function(____, item) return sanitizeUTF8(item) end -- 1127
				) or ({}), -- 1127
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1129
				success = info.success == true, -- 1130
				cleared = info.cleared == true, -- 1131
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1132
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1133
					"subagents", -- 1133
					Path:getFilename(path) -- 1133
				)), -- 1133
				sourceTaskId = sourceTaskId or 0, -- 1134
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1135
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1136
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1137
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1138
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1139
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1140
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1141
			} -- 1141
		end -- 1141
		::__continue209:: -- 1141
	end -- 1141
	__TS__ArraySort( -- 1144
		items, -- 1144
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1144
	) -- 1144
	return items -- 1145
end -- 1145
function getPendingHandoffDir(projectRoot, memoryScope) -- 1148
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1149
end -- 1149
function writePendingHandoff(projectRoot, memoryScope, value) -- 1152
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1153
	if not Content:exist(dir) then -- 1153
		ensureDirRecursive(dir) -- 1155
	end -- 1155
	local path = Path(dir, value.id .. ".json") -- 1157
	local text = safeJsonEncode(value) -- 1158
	if not text then -- 1158
		return false -- 1159
	end -- 1159
	return Content:save(path, text .. "\n") -- 1160
end -- 1160
function listPendingHandoffs(projectRoot, memoryScope) -- 1163
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1164
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1164
		return {} -- 1165
	end -- 1165
	local items = {} -- 1166
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1167
		do -- 1167
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1168
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1168
				goto __continue224 -- 1169
			end -- 1169
			local text = Content:load(path) -- 1170
			if not text or __TS__StringTrim(text) == "" then -- 1170
				goto __continue224 -- 1171
			end -- 1171
			local obj = safeJsonDecode(text) -- 1172
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1172
				goto __continue224 -- 1173
			end -- 1173
			local value = obj -- 1174
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1175
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1176
			local id = sanitizeUTF8(toStr(value.id)) -- 1177
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1178
			local message = sanitizeUTF8(toStr(value.message)) -- 1179
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1180
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1181
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1182
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1182
				goto __continue224 -- 1184
			end -- 1184
			items[#items + 1] = { -- 1186
				id = id, -- 1187
				sourceSessionId = sourceSessionId, -- 1188
				sourceTitle = sourceTitle, -- 1189
				sourceTaskId = sourceTaskId, -- 1190
				message = message, -- 1191
				prompt = prompt, -- 1192
				goal = goal, -- 1193
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1194
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1195
					__TS__ArrayFilter( -- 1196
						value.filesHint, -- 1196
						function(____, item) return type(item) == "string" end -- 1196
					), -- 1196
					function(____, item) return sanitizeUTF8(item) end -- 1196
				) or ({}), -- 1196
				success = value.success == true, -- 1198
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1199
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1200
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1201
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1202
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1203
				createdAt = createdAt -- 1204
			} -- 1204
		end -- 1204
		::__continue224:: -- 1204
	end -- 1204
	__TS__ArraySort( -- 1207
		items, -- 1207
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1207
	) -- 1207
	return items -- 1208
end -- 1208
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1211
	local path = Path( -- 1212
		getPendingHandoffDir(projectRoot, memoryScope), -- 1212
		id .. ".json" -- 1212
	) -- 1212
	if Content:exist(path) then -- 1212
		Content:remove(path) -- 1214
	end -- 1214
end -- 1214
function normalizePromptText(prompt) -- 1218
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1219
end -- 1219
function normalizePromptTextSafe(prompt) -- 1222
	if type(prompt) == "string" then -- 1222
		local normalized = normalizePromptText(prompt) -- 1224
		if normalized ~= "" then -- 1224
			return normalized -- 1225
		end -- 1225
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1226
		if sanitized ~= "" then -- 1226
			return truncateAgentUserPrompt(sanitized) -- 1228
		end -- 1228
		return "" -- 1230
	end -- 1230
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1232
	if text == "" then -- 1232
		return "" -- 1233
	end -- 1233
	return truncateAgentUserPrompt(text) -- 1234
end -- 1234
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1237
	local sections = {} -- 1238
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1239
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1240
	local normalizedFiles = __TS__ArrayFilter( -- 1241
		__TS__ArrayMap( -- 1241
			__TS__ArrayFilter( -- 1241
				filesHint or ({}), -- 1241
				function(____, item) return type(item) == "string" end -- 1242
			), -- 1242
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1243
		), -- 1243
		function(____, item) return item ~= "" end -- 1244
	) -- 1244
	if normalizedTitle ~= "" then -- 1244
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1246
	end -- 1246
	if normalizedExpected ~= "" then -- 1246
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1249
	end -- 1249
	if #normalizedFiles > 0 then -- 1249
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1252
	end -- 1252
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1254
end -- 1254
function normalizeSessionRuntimeState(session) -- 1257
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1257
		return session -- 1259
	end -- 1259
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1259
		return session -- 1262
	end -- 1262
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1264
	if #pendingToolRows > 0 then -- 1264
		local t = now() -- 1270
		do -- 1270
			local i = 0 -- 1271
			while i < #pendingToolRows do -- 1271
				local row = pendingToolRows[i + 1] -- 1272
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1273
				result.success = false -- 1274
				result.state = "failed" -- 1275
				result.interrupted = true -- 1276
				result.message = "tool call was interrupted because the program exited before it completed." -- 1277
				DB:exec( -- 1278
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1278
					{ -- 1280
						encodeJson(result), -- 1280
						t, -- 1280
						row[1] -- 1280
					} -- 1280
				) -- 1280
				i = i + 1 -- 1271
			end -- 1271
		end -- 1271
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1283
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1284
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1285
	end -- 1285
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1292
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1293
	return __TS__ObjectAssign( -- 1294
		{}, -- 1294
		session, -- 1295
		{ -- 1294
			status = "STOPPED", -- 1296
			currentTaskStatus = "STOPPED", -- 1297
			updatedAt = now() -- 1298
		} -- 1298
	) -- 1298
end -- 1298
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1302
	DB:exec( -- 1303
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1303
		{ -- 1307
			status, -- 1308
			currentTaskId or 0, -- 1309
			currentTaskStatus or status, -- 1310
			now(), -- 1311
			sessionId -- 1312
		} -- 1312
	) -- 1312
end -- 1312
function mergeAgentMetrics(current, next) -- 1317
	return __TS__ObjectAssign({}, current or ({}), next) -- 1318
end -- 1318
function updateSessionMetrics(sessionId, metrics) -- 1324
	local session = getSessionItem(sessionId) -- 1325
	if not session then -- 1325
		return nil -- 1326
	end -- 1326
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1327
	DB:exec( -- 1328
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1328
		{ -- 1332
			encodeJson(merged), -- 1333
			now(), -- 1334
			sessionId -- 1335
		} -- 1335
	) -- 1335
	return merged -- 1338
end -- 1338
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1341
	if taskId == nil or taskId <= 0 then -- 1341
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1343
		return -- 1344
	end -- 1344
	local row = getSessionRow(sessionId) -- 1346
	if not row then -- 1346
		return -- 1347
	end -- 1347
	local session = rowToSession(row) -- 1348
	if session.currentTaskId ~= taskId then -- 1348
		Log( -- 1350
			"Info", -- 1350
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1350
		) -- 1350
		return -- 1351
	end -- 1351
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1353
end -- 1353
function insertMessage(sessionId, role, content, taskId) -- 1356
	local t = now() -- 1357
	DB:exec( -- 1358
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1358
		{ -- 1361
			sessionId, -- 1362
			taskId or 0, -- 1363
			role, -- 1364
			sanitizeUTF8(content), -- 1365
			t, -- 1366
			t -- 1367
		} -- 1367
	) -- 1367
	return getLastInsertRowId() -- 1370
end -- 1370
function updateMessage(messageId, content) -- 1373
	DB:exec( -- 1374
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1374
		{ -- 1376
			sanitizeUTF8(content), -- 1376
			now(), -- 1376
			messageId -- 1376
		} -- 1376
	) -- 1376
end -- 1376
function updateUserMessageForTask(messageId, content, taskId) -- 1380
	DB:exec( -- 1381
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1381
		{ -- 1385
			sanitizeUTF8(content), -- 1385
			taskId, -- 1385
			now(), -- 1385
			messageId -- 1385
		} -- 1385
	) -- 1385
end -- 1385
function upsertAssistantMessage(sessionId, taskId, content) -- 1442
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1443
	if row and type(row[1]) == "number" then -- 1443
		updateMessage(row[1], content) -- 1450
		return row[1] -- 1451
	end -- 1451
	return insertMessage(sessionId, "assistant", content, taskId) -- 1453
end -- 1453
function upsertStep(sessionId, taskId, step, tool, patch) -- 1456
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1466
	local reason = sanitizeUTF8(patch.reason or "") -- 1470
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1471
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1472
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1473
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1474
	local statusPatch = patch.status or "" -- 1475
	local status = patch.status or "PENDING" -- 1476
	if not row then -- 1476
		local t = now() -- 1478
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1479
			sessionId, -- 1483
			taskId, -- 1484
			step, -- 1485
			tool, -- 1486
			status, -- 1487
			reason, -- 1488
			reasoningContent, -- 1489
			paramsJson, -- 1490
			resultJson, -- 1491
			patch.checkpointId or 0, -- 1492
			patch.checkpointSeq or 0, -- 1493
			filesJson, -- 1494
			t, -- 1495
			t -- 1496
		}) -- 1496
		return -- 1499
	end -- 1499
	DB:exec( -- 1501
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1501
		{ -- 1513
			tool, -- 1514
			statusPatch, -- 1515
			status, -- 1516
			reason, -- 1517
			reason, -- 1518
			reasoningContent, -- 1519
			reasoningContent, -- 1520
			paramsJson, -- 1521
			paramsJson, -- 1522
			resultJson, -- 1523
			resultJson, -- 1524
			patch.checkpointId or 0, -- 1525
			patch.checkpointId or 0, -- 1526
			patch.checkpointSeq or 0, -- 1527
			patch.checkpointSeq or 0, -- 1528
			filesJson, -- 1529
			filesJson, -- 1530
			now(), -- 1531
			row[1] -- 1532
		} -- 1532
	) -- 1532
end -- 1532
function getNextStepNumber(sessionId, taskId) -- 1537
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1538
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1542
	return math.max(0, current) + 1 -- 1543
end -- 1543
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1546
	if status == nil then -- 1546
		status = "DONE" -- 1554
	end -- 1554
	local step = getNextStepNumber(sessionId, taskId) -- 1556
	upsertStep( -- 1557
		sessionId, -- 1557
		taskId, -- 1557
		step, -- 1557
		tool, -- 1557
		{status = status, reason = reason, params = params, result = result} -- 1557
	) -- 1557
	return getStepItem(sessionId, taskId, step) -- 1563
end -- 1563
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1566
	if taskId <= 0 then -- 1566
		return -- 1567
	end -- 1567
	if finalSteps ~= nil and finalSteps >= 0 then -- 1567
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1569
	end -- 1569
	if not finalStatus then -- 1569
		return -- 1575
	end -- 1575
	if finalSteps ~= nil and finalSteps >= 0 then -- 1575
		DB:exec( -- 1577
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1577
			{ -- 1581
				finalStatus, -- 1581
				now(), -- 1581
				sessionId, -- 1581
				taskId, -- 1581
				finalSteps -- 1581
			} -- 1581
		) -- 1581
		return -- 1583
	end -- 1583
	DB:exec( -- 1585
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1585
		{ -- 1589
			finalStatus, -- 1589
			now(), -- 1589
			sessionId, -- 1589
			taskId -- 1589
		} -- 1589
	) -- 1589
end -- 1589
function emitAgentSessionPatch(sessionId, patch) -- 1616
	if HttpServer.wsConnectionCount == 0 then -- 1616
		return -- 1618
	end -- 1618
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1620
	if not text then -- 1620
		return -- 1625
	end -- 1625
	emit("AppWS", "Send", text) -- 1626
end -- 1626
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1629
	emitAgentSessionPatch( -- 1630
		sessionId, -- 1630
		{ -- 1630
			sessionDeleted = true, -- 1631
			relatedSessions = listRelatedSessions(rootSessionId) -- 1632
		} -- 1632
	) -- 1632
	local rootSession = getSessionItem(rootSessionId) -- 1634
	if rootSession then -- 1634
		emitAgentSessionPatch( -- 1636
			rootSessionId, -- 1636
			{ -- 1636
				session = rootSession, -- 1637
				relatedSessions = listRelatedSessions(rootSessionId) -- 1638
			} -- 1638
		) -- 1638
	end -- 1638
end -- 1638
function flushPendingSubAgentHandoffs(rootSession) -- 1643
	if rootSession.kind ~= "main" then -- 1643
		return -- 1644
	end -- 1644
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1644
		return -- 1646
	end -- 1646
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1648
	if #items == 0 then -- 1648
		return -- 1649
	end -- 1649
	local handoffTaskId = 0 -- 1650
	local ____rootSession_currentTaskId_25 -- 1651
	if rootSession.currentTaskId then -- 1651
		____rootSession_currentTaskId_25 = getTaskPrompt(rootSession.currentTaskId) -- 1651
	else -- 1651
		____rootSession_currentTaskId_25 = nil -- 1651
	end -- 1651
	local currentTaskPrompt = ____rootSession_currentTaskId_25 -- 1651
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1651
		handoffTaskId = rootSession.currentTaskId -- 1659
	else -- 1659
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1661
		if not taskRes.success then -- 1661
			Log( -- 1663
				"Warn", -- 1663
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1663
			) -- 1663
			return -- 1664
		end -- 1664
		handoffTaskId = taskRes.taskId -- 1666
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1667
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1668
		emitAgentSessionPatch( -- 1669
			rootSession.id, -- 1669
			{session = getSessionItem(rootSession.id)} -- 1669
		) -- 1669
	end -- 1669
	do -- 1669
		local i = 0 -- 1673
		while i < #items do -- 1673
			local item = items[i + 1] -- 1674
			local step = appendSystemStep( -- 1675
				rootSession.id, -- 1676
				handoffTaskId, -- 1677
				"sub_agent_handoff", -- 1678
				"sub_agent_handoff", -- 1679
				item.message, -- 1680
				{ -- 1681
					sourceSessionId = item.sourceSessionId, -- 1682
					sourceTitle = item.sourceTitle, -- 1683
					sourceTaskId = item.sourceTaskId, -- 1684
					success = item.success == true, -- 1685
					summary = item.message, -- 1686
					resultFilePath = item.resultFilePath or "", -- 1687
					artifactDir = item.artifactDir or "", -- 1688
					finishedAt = item.finishedAt or "", -- 1689
					changeSet = item.changeSet, -- 1690
					memoryEntry = item.memoryEntry -- 1691
				}, -- 1691
				{ -- 1693
					sourceSessionId = item.sourceSessionId, -- 1694
					sourceTitle = item.sourceTitle, -- 1695
					sourceTaskId = item.sourceTaskId, -- 1696
					prompt = item.prompt, -- 1697
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1698
					expectedOutput = item.expectedOutput or "", -- 1699
					filesHint = item.filesHint or ({}), -- 1700
					resultFilePath = item.resultFilePath or "", -- 1701
					artifactDir = item.artifactDir or "", -- 1702
					changeSet = item.changeSet, -- 1703
					memoryEntry = item.memoryEntry -- 1704
				}, -- 1704
				"DONE" -- 1706
			) -- 1706
			if step then -- 1706
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1709
			end -- 1709
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1711
			i = i + 1 -- 1673
		end -- 1673
	end -- 1673
end -- 1673
function applyEvent(sessionId, event) -- 1723
	repeat -- 1723
		local ____switch302 = event.type -- 1723
		local ____cond302 = ____switch302 == "task_started" -- 1723
		if ____cond302 then -- 1723
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1726
			emitAgentSessionPatch( -- 1727
				sessionId, -- 1727
				{session = getSessionItem(sessionId)} -- 1727
			) -- 1727
			break -- 1730
		end -- 1730
		____cond302 = ____cond302 or ____switch302 == "decision_made" -- 1730
		if ____cond302 then -- 1730
			upsertStep( -- 1732
				sessionId, -- 1732
				event.taskId, -- 1732
				event.step, -- 1732
				event.tool, -- 1732
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1732
			) -- 1732
			emitAgentSessionPatch( -- 1738
				sessionId, -- 1738
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1738
			) -- 1738
			break -- 1741
		end -- 1741
		____cond302 = ____cond302 or ____switch302 == "tool_started" -- 1741
		if ____cond302 then -- 1741
			upsertStep( -- 1743
				sessionId, -- 1743
				event.taskId, -- 1743
				event.step, -- 1743
				event.tool, -- 1743
				{status = "RUNNING"} -- 1743
			) -- 1743
			emitAgentSessionPatch( -- 1746
				sessionId, -- 1746
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1746
			) -- 1746
			break -- 1749
		end -- 1749
		____cond302 = ____cond302 or ____switch302 == "tool_finished" -- 1749
		if ____cond302 then -- 1749
			upsertStep( -- 1751
				sessionId, -- 1751
				event.taskId, -- 1751
				event.step, -- 1751
				event.tool, -- 1751
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1751
			) -- 1751
			emitAgentSessionPatch( -- 1756
				sessionId, -- 1756
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1756
			) -- 1756
			break -- 1759
		end -- 1759
		____cond302 = ____cond302 or ____switch302 == "tool_progress" -- 1759
		if ____cond302 then -- 1759
			do -- 1759
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1762
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1762
					break -- 1764
				end -- 1764
			end -- 1764
			upsertStep( -- 1767
				sessionId, -- 1767
				event.taskId, -- 1767
				event.step, -- 1767
				event.tool, -- 1767
				{status = "RUNNING", result = event.result} -- 1767
			) -- 1767
			emitAgentSessionPatch( -- 1771
				sessionId, -- 1771
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1771
			) -- 1771
			break -- 1774
		end -- 1774
		____cond302 = ____cond302 or ____switch302 == "checkpoint_created" -- 1774
		if ____cond302 then -- 1774
			upsertStep( -- 1776
				sessionId, -- 1776
				event.taskId, -- 1776
				event.step, -- 1776
				event.tool, -- 1776
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1776
			) -- 1776
			emitAgentSessionPatch( -- 1781
				sessionId, -- 1781
				{ -- 1781
					step = getStepItem(sessionId, event.taskId, event.step), -- 1782
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1783
				} -- 1783
			) -- 1783
			break -- 1785
		end -- 1785
		____cond302 = ____cond302 or ____switch302 == "memory_compression_started" -- 1785
		if ____cond302 then -- 1785
			upsertStep( -- 1787
				sessionId, -- 1787
				event.taskId, -- 1787
				event.step, -- 1787
				event.tool, -- 1787
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1787
			) -- 1787
			emitAgentSessionPatch( -- 1792
				sessionId, -- 1792
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1792
			) -- 1792
			break -- 1795
		end -- 1795
		____cond302 = ____cond302 or ____switch302 == "memory_compression_finished" -- 1795
		if ____cond302 then -- 1795
			upsertStep( -- 1797
				sessionId, -- 1797
				event.taskId, -- 1797
				event.step, -- 1797
				event.tool, -- 1797
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1797
			) -- 1797
			emitAgentSessionPatch( -- 1802
				sessionId, -- 1802
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1802
			) -- 1802
			break -- 1805
		end -- 1805
		____cond302 = ____cond302 or ____switch302 == "metrics_updated" -- 1805
		if ____cond302 then -- 1805
			do -- 1805
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1807
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1808
				break -- 1811
			end -- 1811
		end -- 1811
		____cond302 = ____cond302 or ____switch302 == "assistant_message_updated" -- 1811
		if ____cond302 then -- 1811
			do -- 1811
				upsertStep( -- 1814
					sessionId, -- 1814
					event.taskId, -- 1814
					event.step, -- 1814
					"message", -- 1814
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1814
				) -- 1814
				emitAgentSessionPatch( -- 1819
					sessionId, -- 1819
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1819
				) -- 1819
				break -- 1822
			end -- 1822
		end -- 1822
		____cond302 = ____cond302 or ____switch302 == "task_finished" -- 1822
		if ____cond302 then -- 1822
			do -- 1822
				local ____opt_26 = activeStopTokens[event.taskId or -1] -- 1822
				local stopped = (____opt_26 and ____opt_26.stopped) == true -- 1825
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1826
				local session = getSessionItem(sessionId) -- 1829
				local isSubSession = (session and session.kind) == "sub" -- 1830
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1831
				if isSubSession and event.taskId ~= nil then -- 1831
					finalizingSubSessionTaskIds[event.taskId] = true -- 1833
				end -- 1833
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1835
				if event.taskId ~= nil then -- 1835
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1837
					local ____finalizeTaskSteps_32 = finalizeTaskSteps -- 1838
					local ____array_31 = __TS__SparseArrayNew( -- 1838
						sessionId, -- 1839
						event.taskId, -- 1840
						type(event.steps) == "number" and math.max( -- 1841
							0, -- 1841
							math.floor(event.steps) -- 1841
						) or nil -- 1841
					) -- 1841
					local ____event_success_30 -- 1842
					if event.success then -- 1842
						____event_success_30 = nil -- 1842
					else -- 1842
						____event_success_30 = stopped and "STOPPED" or "FAILED" -- 1842
					end -- 1842
					__TS__SparseArrayPush(____array_31, ____event_success_30) -- 1842
					____finalizeTaskSteps_32(__TS__SparseArraySpread(____array_31)) -- 1838
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1844
					if not isSubSession then -- 1844
						__TS__Delete(activeStopTokens, event.taskId) -- 1846
					end -- 1846
					emitAgentSessionPatch( -- 1848
						sessionId, -- 1848
						{ -- 1848
							session = getSessionItem(sessionId), -- 1849
							message = getMessageItem(messageId), -- 1850
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1851
							removedStepIds = removedStepIds -- 1852
						} -- 1852
					) -- 1852
				end -- 1852
				break -- 1855
			end -- 1855
		end -- 1855
	until true -- 1855
end -- 1855
function ____exports.createSession(projectRoot, title) -- 1992
	if title == nil then -- 1992
		title = "" -- 1992
	end -- 1992
	if not isValidProjectRoot(projectRoot) then -- 1992
		return {success = false, message = "invalid projectRoot"} -- 1994
	end -- 1994
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1996
	if row then -- 1996
		return { -- 2005
			success = true, -- 2005
			session = rowToSession(row) -- 2005
		} -- 2005
	end -- 2005
	local t = now() -- 2007
	DB:exec( -- 2008
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 2008
		{ -- 2011
			projectRoot, -- 2011
			title ~= "" and title or Path:getFilename(projectRoot), -- 2011
			t, -- 2011
			t -- 2011
		} -- 2011
	) -- 2011
	local sessionId = getLastInsertRowId() -- 2013
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2014
	local session = getSessionItem(sessionId) -- 2015
	if not session then -- 2015
		return {success = false, message = "failed to create session"} -- 2017
	end -- 2017
	return {success = true, session = session} -- 2019
end -- 1992
function ____exports.createSubSession(parentSessionId, title) -- 2022
	if title == nil then -- 2022
		title = "" -- 2022
	end -- 2022
	local parent = getSessionItem(parentSessionId) -- 2023
	if not parent then -- 2023
		return {success = false, message = "parent session not found"} -- 2025
	end -- 2025
	local rootId = getSessionRootId(parent) -- 2027
	local t = now() -- 2028
	DB:exec( -- 2029
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2029
		{ -- 2032
			parent.projectRoot, -- 2032
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2032
			rootId, -- 2032
			parent.id, -- 2032
			t, -- 2032
			t -- 2032
		} -- 2032
	) -- 2032
	local sessionId = getLastInsertRowId() -- 2034
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2035
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2036
	local session = getSessionItem(sessionId) -- 2037
	if not session then -- 2037
		return {success = false, message = "failed to create sub session"} -- 2039
	end -- 2039
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2041
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2042
	subStorage:writeMemory(parentStorage:readMemory()) -- 2043
	return {success = true, session = session} -- 2044
end -- 2022
function spawnSubAgentSession(request) -- 2047
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2047
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2059
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2060
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2061
		if normalizedPrompt == "" then -- 2061
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2063
		end -- 2063
		if normalizedPrompt == "" then -- 2063
			local ____Log_38 = Log -- 2070
			local ____temp_35 = #normalizedTitle -- 2070
			local ____temp_36 = #rawPrompt -- 2070
			local ____temp_37 = #toStr(request.expectedOutput) -- 2070
			local ____opt_33 = request.filesHint -- 2070
			____Log_38( -- 2070
				"Warn", -- 2070
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_35)) .. " raw_prompt_len=") .. tostring(____temp_36)) .. " expected_len=") .. tostring(____temp_37)) .. " files_hint_count=") .. tostring(____opt_33 and #____opt_33 or 0) -- 2070
			) -- 2070
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2070
		end -- 2070
		Log( -- 2073
			"Info", -- 2073
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2073
		) -- 2073
		local parentSessionId = request.parentSessionId -- 2074
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2074
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2076
			if not fallbackParent then -- 2076
				local createdMain = ____exports.createSession(request.projectRoot) -- 2078
				if createdMain.success then -- 2078
					fallbackParent = createdMain.session -- 2080
				end -- 2080
			end -- 2080
			if fallbackParent then -- 2080
				Log( -- 2084
					"Warn", -- 2084
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2084
				) -- 2084
				parentSessionId = fallbackParent.id -- 2085
			end -- 2085
		end -- 2085
		local parentSession = getSessionItem(parentSessionId) -- 2088
		if not parentSession then -- 2088
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2088
		end -- 2088
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2092
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2092
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2092
		end -- 2092
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2096
		if not created.success then -- 2096
			return ____awaiter_resolve(nil, created) -- 2096
		end -- 2096
		writeSpawnInfo( -- 2100
			created.session.projectRoot, -- 2100
			created.session.memoryScope, -- 2100
			{ -- 2100
				sessionId = created.session.id, -- 2101
				rootSessionId = created.session.rootSessionId, -- 2102
				parentSessionId = created.session.parentSessionId, -- 2103
				title = created.session.title, -- 2104
				prompt = normalizedPrompt, -- 2105
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2106
				expectedOutput = request.expectedOutput or "", -- 2107
				filesHint = request.filesHint or ({}), -- 2108
				status = "RUNNING", -- 2109
				success = false, -- 2110
				resultFilePath = "", -- 2111
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2112
				sourceTaskId = 0, -- 2113
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2114
				createdAtTs = created.session.createdAt, -- 2115
				finishedAt = "", -- 2116
				finishedAtTs = 0 -- 2117
			} -- 2117
		) -- 2117
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true, request.disabledAgentTools) -- 2119
		if not sent.success then -- 2119
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2119
		end -- 2119
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2119
	end) -- 2119
end -- 2119
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2200
	local rootSession = getRootSessionItem(session.id) -- 2201
	if not rootSession then -- 2201
		return -- 2202
	end -- 2202
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2203
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2204
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2205
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2206
	local queueResult = writePendingHandoff( -- 2207
		rootSession.projectRoot, -- 2207
		rootSession.memoryScope, -- 2207
		{ -- 2207
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2208
			sourceSessionId = session.id, -- 2209
			sourceTitle = session.title, -- 2210
			sourceTaskId = taskId, -- 2211
			message = summary, -- 2212
			prompt = result.prompt, -- 2213
			goal = result.goal, -- 2214
			expectedOutput = result.expectedOutput or "", -- 2215
			filesHint = result.filesHint or ({}), -- 2216
			success = result.success, -- 2217
			resultFilePath = result.resultFilePath, -- 2218
			artifactDir = result.artifactDir, -- 2219
			finishedAt = result.finishedAt, -- 2220
			changeSet = changeSet, -- 2221
			memoryEntry = result.memoryEntry, -- 2222
			createdAt = createdAt -- 2223
		} -- 2223
	) -- 2223
	if not queueResult then -- 2223
		Log( -- 2226
			"Warn", -- 2226
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2226
		) -- 2226
		return -- 2227
	end -- 2227
end -- 2227
function finalizeSubSession(session, taskId, success, message) -- 2231
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2231
		local rootSessionId = getSessionRootId(session) -- 2232
		local rootSession = getRootSessionItem(session.id) -- 2233
		if not rootSession then -- 2233
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2233
		end -- 2233
		local spawnInfo = getSessionSpawnInfo(session) -- 2237
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2238
		local finishedAtTs = now() -- 2239
		local resultText = sanitizeUTF8(message) -- 2240
		local changeSet = getTaskChangeSetSummary(taskId) -- 2241
		local record = { -- 2242
			sessionId = session.id, -- 2243
			rootSessionId = rootSessionId, -- 2244
			parentSessionId = session.parentSessionId, -- 2245
			title = session.title, -- 2246
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2247
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2248
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2249
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2250
			status = success and "DONE" or "FAILED", -- 2251
			success = success, -- 2252
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2253
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2254
			sourceTaskId = taskId, -- 2255
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2256
			finishedAt = finishedAt, -- 2257
			createdAtTs = session.createdAt, -- 2258
			finishedAtTs = finishedAtTs, -- 2259
			changeSet = changeSet -- 2260
		} -- 2260
		if not writeSubAgentResultFile(session, record, resultText) then -- 2260
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2260
		end -- 2260
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2260
			sessionId = record.sessionId, -- 2267
			rootSessionId = record.rootSessionId, -- 2268
			parentSessionId = record.parentSessionId, -- 2269
			title = record.title, -- 2270
			prompt = record.prompt, -- 2271
			goal = record.goal, -- 2272
			expectedOutput = record.expectedOutput or "", -- 2273
			filesHint = record.filesHint or ({}), -- 2274
			status = record.status, -- 2275
			success = record.success, -- 2276
			resultFilePath = record.resultFilePath, -- 2277
			artifactDir = record.artifactDir, -- 2278
			sourceTaskId = record.sourceTaskId, -- 2279
			createdAt = record.createdAt, -- 2280
			finishedAt = record.finishedAt, -- 2281
			createdAtTs = record.createdAtTs, -- 2282
			finishedAtTs = record.finishedAtTs, -- 2283
			changeSet = record.changeSet, -- 2284
			memoryEntry = record.memoryEntry, -- 2285
			memoryEntryError = record.memoryEntryError -- 2286
		}) then -- 2286
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2286
		end -- 2286
		if success then -- 2286
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2291
			deleteSessionRecords(session.id, true) -- 2292
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2293
		end -- 2293
		return ____awaiter_resolve(nil, {success = true}) -- 2293
	end) -- 2293
end -- 2293
function stopClearedSubSession(session, taskId) -- 2298
	local spawnInfo = getSessionSpawnInfo(session) -- 2299
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2300
	local rootSessionId = getSessionRootId(session) -- 2301
	Tools.setTaskStatus(taskId, "STOPPED") -- 2302
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2303
	if not writeSpawnInfo( -- 2303
		session.projectRoot, -- 2304
		session.memoryScope, -- 2304
		{ -- 2304
			sessionId = session.id, -- 2305
			rootSessionId = rootSessionId, -- 2306
			parentSessionId = session.parentSessionId, -- 2307
			title = session.title, -- 2308
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2309
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2310
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2311
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2312
			status = "STOPPED", -- 2313
			success = false, -- 2314
			cleared = true, -- 2315
			resultFilePath = "", -- 2316
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2317
			sourceTaskId = taskId, -- 2318
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2319
			finishedAt = finishedAt, -- 2320
			createdAtTs = session.createdAt, -- 2321
			finishedAtTs = now() -- 2322
		} -- 2322
	) then -- 2322
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2324
	end -- 2324
	deleteSessionRecords(session.id, true) -- 2326
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2327
	return {success = true} -- 2328
end -- 2328
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools) -- 2331
	if allowSubSessionStart == nil then -- 2331
		allowSubSessionStart = false -- 2331
	end -- 2331
	local session = getSessionItem(sessionId) -- 2332
	if not session then -- 2332
		return {success = false, message = "session not found"} -- 2334
	end -- 2334
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2334
		return {success = false, message = "session task is finalizing"} -- 2337
	end -- 2337
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2337
		return {success = false, message = "session task is still running"} -- 2340
	end -- 2340
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2342
	if normalizedPrompt == "" and session.kind == "sub" then -- 2342
		local spawnInfo = getSessionSpawnInfo(session) -- 2344
		if spawnInfo then -- 2344
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2346
			if normalizedPrompt == "" then -- 2346
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2348
			end -- 2348
		end -- 2348
	end -- 2348
	if normalizedPrompt == "" then -- 2348
		return {success = false, message = "prompt is empty"} -- 2357
	end -- 2357
	return startPromptTask( -- 2359
		session, -- 2359
		normalizedPrompt, -- 2359
		nil, -- 2359
		normalizeDisabledAgentTools(disabledAgentTools) -- 2359
	) -- 2359
end -- 2331
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools) -- 2362
	if disabledAgentTools == nil then -- 2362
		disabledAgentTools = {} -- 2362
	end -- 2362
	local taskRes = Tools.createTask(normalizedPrompt) -- 2363
	if not taskRes.success then -- 2363
		return {success = false, message = taskRes.message} -- 2365
	end -- 2365
	local taskId = taskRes.taskId -- 2367
	local useChineseResponse = getDefaultUseChineseResponse() -- 2368
	if existingUserMessageId ~= nil then -- 2368
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2370
	else -- 2370
		insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2372
	end -- 2372
	local stopToken = {stopped = false} -- 2374
	activeStopTokens[taskId] = stopToken -- 2375
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2376
	runCodingAgent( -- 2377
		{ -- 2377
			prompt = normalizedPrompt, -- 2378
			workDir = session.projectRoot, -- 2379
			useChineseResponse = useChineseResponse, -- 2380
			taskId = taskId, -- 2381
			sessionId = session.id, -- 2382
			memoryScope = session.memoryScope, -- 2383
			role = session.kind, -- 2384
			disabledAgentTools = disabledAgentTools, -- 2385
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2386
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2389
			stopToken = stopToken, -- 2392
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2393
		}, -- 2393
		function(result) -- 2394
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2394
				local nextSession = getSessionItem(session.id) -- 2395
				if nextSession and nextSession.kind == "sub" then -- 2395
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2395
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2398
						if not stopped.success then -- 2398
							Log( -- 2400
								"Warn", -- 2400
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2400
							) -- 2400
							emitAgentSessionPatch( -- 2401
								session.id, -- 2401
								{session = getSessionItem(session.id)} -- 2401
							) -- 2401
						end -- 2401
						__TS__Delete(activeStopTokens, taskId) -- 2405
						return ____awaiter_resolve(nil) -- 2405
					end -- 2405
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2408
					emitAgentSessionPatch( -- 2409
						session.id, -- 2409
						{session = getSessionItem(session.id)} -- 2409
					) -- 2409
					local finalized = __TS__Await(finalizeSubSession(nextSession, taskId, result.success, result.message)) -- 2412
					if not finalized.success then -- 2412
						Log( -- 2414
							"Warn", -- 2414
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2414
						) -- 2414
					end -- 2414
					local finalizedSession = getSessionItem(session.id) -- 2416
					if finalizedSession then -- 2416
						local stopped = stopToken.stopped == true -- 2418
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2419
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2422
						emitAgentSessionPatch( -- 2423
							session.id, -- 2423
							{session = getSessionItem(session.id)} -- 2423
						) -- 2423
					end -- 2423
					__TS__Delete(activeStopTokens, taskId) -- 2427
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2428
				end -- 2428
				if not nextSession or nextSession.kind ~= "sub" then -- 2428
					local rootSession = getRootSessionItem(session.id) -- 2431
					if rootSession and rootSession.kind == "main" then -- 2431
						__TS__Await(finalizeMainAgentPendingHandoffs(rootSession)) -- 2433
					end -- 2433
					if not result.success then -- 2433
						applyEvent(session.id, { -- 2436
							type = "task_finished", -- 2437
							sessionId = session.id, -- 2438
							taskId = result.taskId, -- 2439
							success = false, -- 2440
							message = result.message, -- 2441
							steps = result.steps -- 2442
						}) -- 2442
					end -- 2442
				end -- 2442
			end) -- 2442
		end -- 2394
	) -- 2394
	return {success = true, sessionId = session.id, taskId = taskId} -- 2447
end -- 2447
function ____exports.listRunningSubAgents(request) -- 2535
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2535
		local session = getSessionItem(request.sessionId) -- 2543
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2543
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2545
		end -- 2545
		if not session then -- 2545
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2545
		end -- 2545
		local rootSession = getRootSessionItem(session.id) -- 2550
		if not rootSession then -- 2550
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2550
		end -- 2550
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2554
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2555
		local limit = math.max( -- 2556
			1, -- 2556
			math.floor(tonumber(request.limit) or 5) -- 2556
		) -- 2556
		local offset = math.max( -- 2557
			0, -- 2557
			math.floor(tonumber(request.offset) or 0) -- 2557
		) -- 2557
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2558
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2559
		local runningSessions = {} -- 2566
		do -- 2566
			local i = 0 -- 2567
			while i < #rows do -- 2567
				do -- 2567
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2568
					if current.currentTaskStatus ~= "RUNNING" then -- 2568
						goto __continue410 -- 2570
					end -- 2570
					local spawnInfo = getSessionSpawnInfo(current) -- 2572
					runningSessions[#runningSessions + 1] = { -- 2573
						sessionId = current.id, -- 2574
						title = current.title, -- 2575
						parentSessionId = current.parentSessionId, -- 2576
						rootSessionId = current.rootSessionId, -- 2577
						status = "RUNNING", -- 2578
						currentTaskId = current.currentTaskId, -- 2579
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2580
						goal = spawnInfo and spawnInfo.goal, -- 2581
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2582
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2583
						createdAt = current.createdAt, -- 2584
						updatedAt = current.updatedAt -- 2585
					} -- 2585
				end -- 2585
				::__continue410:: -- 2585
				i = i + 1 -- 2567
			end -- 2567
		end -- 2567
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2588
		local completedSessions = __TS__ArrayMap( -- 2589
			completedRecords, -- 2589
			function(____, record) return { -- 2589
				sessionId = record.sessionId, -- 2590
				title = record.title, -- 2591
				parentSessionId = record.parentSessionId, -- 2592
				rootSessionId = record.rootSessionId, -- 2593
				status = record.status, -- 2594
				goal = record.goal, -- 2595
				expectedOutput = record.expectedOutput, -- 2596
				filesHint = record.filesHint, -- 2597
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2598
				success = record.success, -- 2599
				cleared = record.cleared, -- 2600
				resultFilePath = record.resultFilePath, -- 2601
				artifactDir = record.artifactDir, -- 2602
				finishedAt = record.finishedAt, -- 2603
				createdAt = record.createdAtTs, -- 2604
				updatedAt = record.finishedAtTs -- 2605
			} end -- 2605
		) -- 2605
		local merged = {} -- 2607
		if status == "running" then -- 2607
			merged = runningSessions -- 2609
		elseif status == "done" then -- 2609
			merged = __TS__ArrayFilter( -- 2611
				completedSessions, -- 2611
				function(____, item) return item.status == "DONE" end -- 2611
			) -- 2611
		elseif status == "failed" then -- 2611
			merged = __TS__ArrayFilter( -- 2613
				completedSessions, -- 2613
				function(____, item) return item.status == "FAILED" end -- 2613
			) -- 2613
		elseif status == "stopped" then -- 2613
			merged = __TS__ArrayFilter( -- 2615
				completedSessions, -- 2615
				function(____, item) return item.status == "STOPPED" end -- 2615
			) -- 2615
		elseif status == "all" then -- 2615
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2617
		else -- 2617
			local runningKeys = {} -- 2619
			do -- 2619
				local i = 0 -- 2620
				while i < #runningSessions do -- 2620
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2621
					i = i + 1 -- 2620
				end -- 2620
			end -- 2620
			local latestCompletedByKey = {} -- 2623
			do -- 2623
				local i = 0 -- 2624
				while i < #completedSessions do -- 2624
					do -- 2624
						local item = completedSessions[i + 1] -- 2625
						local key = getSubAgentDisplayKey(item) -- 2626
						if runningKeys[key] then -- 2626
							goto __continue425 -- 2628
						end -- 2628
						local current = latestCompletedByKey[key] -- 2630
						if not current or item.updatedAt > current.updatedAt then -- 2630
							latestCompletedByKey[key] = item -- 2632
						end -- 2632
					end -- 2632
					::__continue425:: -- 2632
					i = i + 1 -- 2624
				end -- 2624
			end -- 2624
			local latestCompleted = {} -- 2635
			for ____, item in pairs(latestCompletedByKey) do -- 2636
				latestCompleted[#latestCompleted + 1] = item -- 2637
			end -- 2637
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2639
		end -- 2639
		if query ~= "" then -- 2639
			merged = __TS__ArrayFilter( -- 2642
				merged, -- 2642
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2642
			) -- 2642
		end -- 2642
		__TS__ArraySort( -- 2648
			merged, -- 2648
			function(____, a, b) -- 2648
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2648
					return -1 -- 2649
				end -- 2649
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2649
					return 1 -- 2650
				end -- 2650
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2650
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2652
				end -- 2652
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2654
			end -- 2648
		) -- 2648
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2656
		return ____awaiter_resolve(nil, { -- 2656
			success = true, -- 2658
			rootSessionId = rootSession.id, -- 2659
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2660
			status = status, -- 2661
			limit = limit, -- 2662
			offset = offset, -- 2663
			hasMore = offset + limit < #merged, -- 2664
			sessions = paged -- 2665
		}) -- 2665
	end) -- 2665
end -- 2535
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
local SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS = 3000 -- 211
local SUB_AGENT_MEMORY_RESULT_MAX_TOKENS = 2000 -- 212
SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES = 20 -- 213
SUB_AGENT_MEMORY_TAIL_MAX_TOKENS = 4000 -- 214
SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS = 600 -- 215
SUB_AGENT_MEMORY_ENTRY_BATCH_MAX_ITEMS = 8 -- 216
SUB_AGENT_MEMORY_ENTRY_BATCH_PER_ITEM_CONTEXT_TOKENS = 800 -- 217
SUB_AGENT_MEMORY_ENTRY_BATCH_PER_ITEM_RESULT_TOKENS = 600 -- 218
SUB_AGENT_MEMORY_ENTRY_BATCH_PER_ITEM_TAIL_TOKENS = 400 -- 219
SUB_AGENT_MEMORY_ENTRY_BATCH_MAX_TOKENS = 4096 -- 220
activeStopTokens = {} -- 266
finalizingSubSessionTaskIds = {} -- 267
now = function() return os.time() end -- 268
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 642
	if projectRoot == oldRoot then -- 642
		return newRoot -- 644
	end -- 644
	for ____, separator in ipairs({"/", "\\"}) do -- 646
		local prefix = oldRoot .. separator -- 647
		if __TS__StringStartsWith(projectRoot, prefix) then -- 647
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 649
		end -- 649
	end -- 649
	return nil -- 652
end -- 642
local function decodeMemoryEntryFromPlainContent(content) -- 791
	if content == "" then -- 791
		return nil -- 792
	end -- 792
	local direct = safeJsonDecode(content) -- 793
	if direct ~= nil then -- 793
		return direct -- 794
	end -- 794
	local start = string.find(content, "{", 1, true) -- 795
	if start == nil then -- 795
		return nil -- 796
	end -- 796
	local ____end = #content -- 797
	while ____end >= start do -- 797
		local candidate = string.sub(content, start, ____end) -- 799
		local value = safeJsonDecode(candidate) -- 800
		if value ~= nil then -- 800
			return value -- 801
		end -- 801
		____end = ____end - 1 -- 802
	end -- 802
	return nil -- 804
end -- 791
local function hasEmptyMemoryEntryContent(value) -- 807
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 807
		return false -- 808
	end -- 808
	local row = value -- 809
	return type(row.content) == "string" and __TS__StringTrim(sanitizeUTF8(row.content)) == "" -- 810
end -- 807
local function clearSessionAfterMessage(sessionId, message) -- 1389
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1390
	local removedStepIds = {} -- 1398
	do -- 1398
		local i = 0 -- 1399
		while i < #removedStepRows do -- 1399
			local row = removedStepRows[i + 1] -- 1400
			if type(row[1]) == "number" then -- 1400
				removedStepIds[#removedStepIds + 1] = row[1] -- 1402
			end -- 1402
			i = i + 1 -- 1399
		end -- 1399
	end -- 1399
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1405
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1413
	return removedStepIds -- 1418
end -- 1389
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1421
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1422
	local persisted = storage:readSessionState() -- 1423
	local userIndex = -1 -- 1424
	do -- 1424
		local i = #persisted.messages - 1 -- 1425
		while i >= 0 do -- 1425
			if persisted.messages[i + 1].role == "user" then -- 1425
				userIndex = i -- 1427
				break -- 1428
			end -- 1428
			i = i - 1 -- 1425
		end -- 1425
	end -- 1425
	if userIndex < 0 then -- 1425
		return -- 1431
	end -- 1431
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1432
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1433
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1434
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1439
end -- 1421
local function sanitizeStoredSteps(sessionId) -- 1593
	DB:exec( -- 1594
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1594
		{ -- 1612
			now(), -- 1612
			sessionId -- 1612
		} -- 1612
	) -- 1612
end -- 1593
local function getSchemaVersion() -- 1860
	local row = queryOne("PRAGMA user_version") -- 1861
	return row and type(row[1]) == "number" and row[1] or 0 -- 1862
end -- 1860
local function setSchemaVersion(version) -- 1865
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1866
		0, -- 1866
		math.floor(version) -- 1866
	))) -- 1866
end -- 1865
local function hasTableColumn(tableName, columnName) -- 1869
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1870
	do -- 1870
		local i = 0 -- 1871
		while i < #rows do -- 1871
			local row = rows[i + 1] -- 1872
			if toStr(row[2]) == columnName then -- 1872
				return true -- 1874
			end -- 1874
			i = i + 1 -- 1871
		end -- 1871
	end -- 1871
	return false -- 1877
end -- 1869
local function ensureSessionMetricsColumn() -- 1880
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1880
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1882
	end -- 1882
end -- 1880
local function recreateSchema() -- 1886
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1887
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1888
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1889
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1890
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1905
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1906
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1915
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1916
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1933
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1934
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1935
end -- 1886
do -- 1886
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1886
		recreateSchema() -- 1941
	else -- 1941
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1943
		ensureSessionMetricsColumn() -- 1958
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1959
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1960
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1969
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1970
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1987
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1988
	end -- 1988
end -- 1988
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2131
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2131
		return {success = false, message = "invalid projectRoot"} -- 2133
	end -- 2133
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2135
	for ____, row in ipairs(rows) do -- 2136
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2137
		if sessionId > 0 then -- 2137
			deleteSessionRecords(sessionId) -- 2139
		end -- 2139
	end -- 2139
	return {success = true, deleted = #rows} -- 2142
end -- 2131
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2145
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2145
		return {success = false, message = "invalid projectRoot"} -- 2147
	end -- 2147
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2149
	local renamed = 0 -- 2150
	for ____, row in ipairs(rows) do -- 2151
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2152
		local projectRoot = toStr(row[2]) -- 2153
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2154
		if sessionId > 0 and nextProjectRoot then -- 2154
			DB:exec( -- 2156
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2156
				{ -- 2158
					nextProjectRoot, -- 2158
					Path:getFilename(nextProjectRoot), -- 2158
					now(), -- 2158
					sessionId -- 2158
				} -- 2158
			) -- 2158
			renamed = renamed + 1 -- 2160
		end -- 2160
	end -- 2160
	return {success = true, renamed = renamed} -- 2163
end -- 2145
function ____exports.getSession(sessionId) -- 2166
	local session = getSessionItem(sessionId) -- 2167
	if not session then -- 2167
		return {success = false, message = "session not found"} -- 2169
	end -- 2169
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2171
	local relatedSessions = listRelatedSessions(sessionId) -- 2172
	sanitizeStoredSteps(sessionId) -- 2173
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2174
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2181
	local ____relatedSessions_40 = relatedSessions -- 2192
	local ____temp_39 -- 2193
	if normalizedSession.kind == "sub" then -- 2193
		____temp_39 = getSessionSpawnInfo(normalizedSession) -- 2193
	else -- 2193
		____temp_39 = nil -- 2193
	end -- 2193
	return { -- 2189
		success = true, -- 2190
		session = normalizedSession, -- 2191
		relatedSessions = ____relatedSessions_40, -- 2192
		spawnInfo = ____temp_39, -- 2193
		messages = __TS__ArrayMap( -- 2194
			messages, -- 2194
			function(____, row) return rowToMessage(row) end -- 2194
		), -- 2194
		steps = __TS__ArrayMap( -- 2195
			steps, -- 2195
			function(____, row) return rowToStep(row) end -- 2195
		), -- 2195
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 2196
	} -- 2196
end -- 2166
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools) -- 2450
	local session = getSessionItem(sessionId) -- 2451
	if not session then -- 2451
		return {success = false, message = "session not found"} -- 2453
	end -- 2453
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2453
		return {success = false, message = "session task is finalizing"} -- 2456
	end -- 2456
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2456
		return {success = false, message = "session task is still running"} -- 2459
	end -- 2459
	local message = getMessageItem(messageId) -- 2461
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2461
		return {success = false, message = "message not found"} -- 2463
	end -- 2463
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2465
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2471
	if latestUserMessageId ~= messageId then -- 2471
		return {success = false, message = "only the latest user prompt can be edited"} -- 2473
	end -- 2473
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2475
	if normalizedPrompt == "" then -- 2475
		return {success = false, message = "prompt is empty"} -- 2477
	end -- 2477
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2479
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2480
	local result = startPromptTask( -- 2481
		session, -- 2481
		normalizedPrompt, -- 2481
		messageId, -- 2481
		normalizeDisabledAgentTools(disabledAgentTools) -- 2481
	) -- 2481
	if result.success and #removedStepIds > 0 then -- 2481
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2483
	end -- 2483
	return result -- 2485
end -- 2450
function ____exports.stopSessionTask(sessionId) -- 2488
	local session = getSessionItem(sessionId) -- 2489
	if not session or session.currentTaskId == nil then -- 2489
		return {success = false, message = "session task not found"} -- 2491
	end -- 2491
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2491
		return {success = false, message = "session task is finalizing"} -- 2494
	end -- 2494
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2496
	local stopToken = activeStopTokens[session.currentTaskId] -- 2497
	if not stopToken then -- 2497
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2497
			return {success = true, recovered = true} -- 2500
		end -- 2500
		return {success = false, message = "task is not running"} -- 2502
	end -- 2502
	stopToken.stopped = true -- 2504
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2505
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2506
	return {success = true} -- 2507
end -- 2488
function ____exports.getCurrentTaskId(sessionId) -- 2510
	local ____opt_61 = getSessionItem(sessionId) -- 2510
	return ____opt_61 and ____opt_61.currentTaskId -- 2511
end -- 2510
function ____exports.listRunningSessions() -- 2514
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2515
	local sessions = {} -- 2522
	do -- 2522
		local i = 0 -- 2523
		while i < #rows do -- 2523
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2524
			if session.currentTaskStatus == "RUNNING" then -- 2524
				sessions[#sessions + 1] = session -- 2526
			end -- 2526
			i = i + 1 -- 2523
		end -- 2523
	end -- 2523
	return {success = true, sessions = sessions} -- 2529
end -- 2514
return ____exports -- 2514