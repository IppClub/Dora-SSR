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
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildSubAgentMemoryEntryLLMOptions, buildSubAgentMemoryEntryToolSchema, buildSubAgentMemoryEntrySystemPrompt, formatSubAgentMemoryTailMessage, buildSubAgentRecentMessageTail, buildSubAgentMemoryEntryPrompt, buildSubAgentMemoryEntryRetryPrompt, normalizeGeneratedSubAgentMemoryEntry, getMemoryEntryToolFunction, getMemoryEntryPlainContent, decodeMemoryEntryFromPlainContent, hasEmptyMemoryEntryContent, generateSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS, SUB_AGENT_MEMORY_RESULT_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
function getDefaultUseChineseResponse() -- 263
	local zh = string.match(App.locale, "^zh") -- 264
	return zh ~= nil -- 265
end -- 265
function toStr(v) -- 268
	if v == false or v == nil then -- 268
		return "" -- 269
	end -- 269
	return tostring(v) -- 270
end -- 270
function encodeJson(value) -- 273
	local text = safeJsonEncode(value) -- 274
	return text or "" -- 275
end -- 275
function decodeJsonObject(text) -- 278
	if not text or text == "" then -- 278
		return nil -- 279
	end -- 279
	local value = safeJsonDecode(text) -- 280
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 280
		return value -- 282
	end -- 282
	return nil -- 284
end -- 284
function decodeJsonFiles(text) -- 287
	if not text or text == "" then -- 287
		return nil -- 288
	end -- 288
	local value = safeJsonDecode(text) -- 289
	if not value or not __TS__ArrayIsArray(value) then -- 289
		return nil -- 290
	end -- 290
	local files = {} -- 291
	do -- 291
		local i = 0 -- 292
		while i < #value do -- 292
			do -- 292
				local item = value[i + 1] -- 293
				if type(item) ~= "table" then -- 293
					goto __continue14 -- 294
				end -- 294
				files[#files + 1] = { -- 295
					path = sanitizeUTF8(toStr(item.path)), -- 296
					op = sanitizeUTF8(toStr(item.op)) -- 297
				} -- 297
			end -- 297
			::__continue14:: -- 297
			i = i + 1 -- 292
		end -- 292
	end -- 292
	return files -- 300
end -- 300
function decodeChangeSetSummary(value) -- 303
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 303
		return nil -- 304
	end -- 304
	local row = value -- 305
	if row.success ~= true then -- 305
		return nil -- 306
	end -- 306
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 307
	if taskId <= 0 then -- 307
		return nil -- 308
	end -- 308
	local files = {} -- 309
	if __TS__ArrayIsArray(row.files) then -- 309
		do -- 309
			local i = 0 -- 311
			while i < #row.files do -- 311
				do -- 311
					local file = row.files[i + 1] -- 312
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 312
						goto __continue22 -- 313
					end -- 313
					local fileRow = file -- 314
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 315
					if path == "" then -- 315
						goto __continue22 -- 316
					end -- 316
					local checkpointIds = {} -- 317
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 317
						do -- 317
							local j = 0 -- 319
							while j < #fileRow.checkpointIds do -- 319
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 320
								if checkpointId > 0 then -- 320
									checkpointIds[#checkpointIds + 1] = checkpointId -- 321
								end -- 321
								j = j + 1 -- 319
							end -- 319
						end -- 319
					end -- 319
					local op = toStr(fileRow.op) -- 324
					files[#files + 1] = { -- 325
						path = path, -- 326
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 327
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 328
						checkpointIds = checkpointIds -- 329
					} -- 329
				end -- 329
				::__continue22:: -- 329
				i = i + 1 -- 311
			end -- 311
		end -- 311
	end -- 311
	return { -- 333
		success = true, -- 334
		taskId = taskId, -- 335
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 336
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 337
		files = files, -- 338
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 339
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 340
	} -- 340
end -- 340
function takeUtf8Head(text, maxChars) -- 344
	if maxChars <= 0 or text == "" then -- 344
		return "" -- 345
	end -- 345
	local nextPos = utf8.offset(text, maxChars + 1) -- 346
	if nextPos == nil then -- 346
		return text -- 347
	end -- 347
	return string.sub(text, 1, nextPos - 1) -- 348
end -- 348
function normalizeMemoryEntryEvidence(value) -- 351
	local evidence = {} -- 352
	if not __TS__ArrayIsArray(value) then -- 352
		return evidence -- 353
	end -- 353
	do -- 353
		local i = 0 -- 354
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 354
			do -- 354
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 355
				if item == "" then -- 355
					goto __continue35 -- 356
				end -- 356
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 356
					evidence[#evidence + 1] = item -- 358
				end -- 358
			end -- 358
			::__continue35:: -- 358
			i = i + 1 -- 354
		end -- 354
	end -- 354
	return evidence -- 361
end -- 361
function decodeSubAgentMemoryEntry(value) -- 364
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 364
		return nil -- 365
	end -- 365
	local row = value -- 366
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 367
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 368
	local content = takeUtf8Head( -- 369
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 369
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 369
	) -- 369
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 369
		return nil -- 370
	end -- 370
	return { -- 371
		sourceSessionId = sourceSessionId, -- 372
		sourceTaskId = sourceTaskId, -- 373
		content = content, -- 374
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 375
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 376
	} -- 376
end -- 376
function getTaskChangeSetSummary(taskId) -- 380
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 381
	return summary.success and summary or nil -- 382
end -- 382
function queryRows(sql, args) -- 385
	local ____args_0 -- 386
	if args then -- 386
		____args_0 = DB:query(sql, args) -- 386
	else -- 386
		____args_0 = DB:query(sql) -- 386
	end -- 386
	return ____args_0 -- 386
end -- 386
function queryOne(sql, args) -- 389
	local rows = queryRows(sql, args) -- 390
	if not rows or #rows == 0 then -- 390
		return nil -- 391
	end -- 391
	return rows[1] -- 392
end -- 392
function getLastInsertRowId() -- 395
	local row = queryOne("SELECT last_insert_rowid()") -- 396
	return row and (row[1] or 0) or 0 -- 397
end -- 397
function isValidProjectRoot(path) -- 400
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 401
end -- 401
function rowToSession(row) -- 404
	return { -- 405
		id = row[1], -- 406
		projectRoot = toStr(row[2]), -- 407
		title = toStr(row[3]), -- 408
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 409
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 410
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 411
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 412
		status = toStr(row[8]), -- 413
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 414
		currentTaskStatus = toStr(row[10]), -- 415
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 416
		createdAt = row[11], -- 417
		updatedAt = row[12], -- 418
		metrics = decodeJsonObject(toStr(row[13])) -- 419
	} -- 419
end -- 419
function rowToMessage(row) -- 423
	return { -- 424
		id = row[1], -- 425
		sessionId = row[2], -- 426
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 427
		role = toStr(row[4]), -- 428
		content = toStr(row[5]), -- 429
		createdAt = row[6], -- 430
		updatedAt = row[7] -- 431
	} -- 431
end -- 431
function rowToStep(row) -- 435
	return { -- 436
		id = row[1], -- 437
		sessionId = row[2], -- 438
		taskId = row[3], -- 439
		step = row[4], -- 440
		tool = toStr(row[5]), -- 441
		status = toStr(row[6]), -- 442
		reason = toStr(row[7]), -- 443
		reasoningContent = toStr(row[8]), -- 444
		params = decodeJsonObject(toStr(row[9])), -- 445
		result = decodeJsonObject(toStr(row[10])), -- 446
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 447
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 448
		files = decodeJsonFiles(toStr(row[13])), -- 449
		createdAt = row[14], -- 450
		updatedAt = row[15] -- 451
	} -- 451
end -- 451
function getMessageItem(messageId) -- 455
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 456
	return row and rowToMessage(row) or nil -- 462
end -- 462
function getStepItem(sessionId, taskId, step) -- 465
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 466
	return row and rowToStep(row) or nil -- 472
end -- 472
function deleteMessageSteps(sessionId, taskId) -- 475
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 476
	local ids = {} -- 481
	do -- 481
		local i = 0 -- 482
		while i < #rows do -- 482
			local row = rows[i + 1] -- 483
			if type(row[1]) == "number" then -- 483
				ids[#ids + 1] = row[1] -- 485
			end -- 485
			i = i + 1 -- 482
		end -- 482
	end -- 482
	if #ids > 0 then -- 482
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 489
	end -- 489
	return ids -- 495
end -- 495
function getSessionRow(sessionId) -- 498
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 499
end -- 499
function getSessionItem(sessionId) -- 507
	local row = getSessionRow(sessionId) -- 508
	return row and rowToSession(row) or nil -- 509
end -- 509
function getTaskPrompt(taskId) -- 512
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 513
	if not row or type(row[1]) ~= "string" then -- 513
		return nil -- 514
	end -- 514
	return toStr(row[1]) -- 515
end -- 515
function getLatestMainSessionByProjectRoot(projectRoot) -- 518
	if not isValidProjectRoot(projectRoot) then -- 518
		return nil -- 519
	end -- 519
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 520
	return row and rowToSession(row) or nil -- 528
end -- 528
function countRunningSubSessions(rootSessionId) -- 531
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 532
	local count = 0 -- 539
	do -- 539
		local i = 0 -- 540
		while i < #rows do -- 540
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 541
			if session.currentTaskStatus == "RUNNING" then -- 541
				count = count + 1 -- 543
			end -- 543
			i = i + 1 -- 540
		end -- 540
	end -- 540
	return count -- 546
end -- 546
function deleteSessionRecords(sessionId, preserveArtifacts) -- 549
	if preserveArtifacts == nil then -- 549
		preserveArtifacts = false -- 549
	end -- 549
	local session = getSessionItem(sessionId) -- 550
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 551
	do -- 551
		local i = 0 -- 552
		while i < #children do -- 552
			local row = children[i + 1] -- 553
			if type(row[1]) == "number" and row[1] > 0 then -- 553
				deleteSessionRecords(row[1], preserveArtifacts) -- 555
			end -- 555
			i = i + 1 -- 552
		end -- 552
	end -- 552
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 558
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 559
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 560
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 561
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 561
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 563
	end -- 563
end -- 563
function getSessionRootId(session) -- 567
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 568
end -- 568
function getRootSessionItem(sessionId) -- 571
	local session = getSessionItem(sessionId) -- 572
	if not session then -- 572
		return nil -- 573
	end -- 573
	return getSessionItem(getSessionRootId(session)) or session -- 574
end -- 574
function listRelatedSessions(sessionId) -- 577
	local root = getRootSessionItem(sessionId) -- 578
	if not root then -- 578
		return {} -- 579
	end -- 579
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 580
	return __TS__ArrayMap( -- 589
		rows, -- 589
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 589
	) -- 589
end -- 589
function getSessionSpawnInfo(session) -- 592
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 593
	if not info then -- 593
		return nil -- 594
	end -- 594
	local ____temp_4 = type(info.sessionId) == "number" and info.sessionId or nil -- 596
	local ____temp_5 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 597
	local ____temp_6 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 598
	local ____temp_7 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 599
	local ____temp_8 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 600
	local ____temp_9 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 601
	local ____temp_10 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 602
	local ____temp_11 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 603
		__TS__ArrayFilter( -- 604
			info.filesHint, -- 604
			function(____, item) return type(item) == "string" end -- 604
		), -- 604
		function(____, item) return sanitizeUTF8(item) end -- 604
	) or nil -- 604
	local ____temp_12 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 606
	local ____temp_2 -- 609
	if info.success == true then -- 609
		____temp_2 = true -- 609
	else -- 609
		local ____temp_1 -- 609
		if info.success == false then -- 609
			____temp_1 = false -- 609
		else -- 609
			____temp_1 = nil -- 609
		end -- 609
		____temp_2 = ____temp_1 -- 609
	end -- 609
	local ____temp_3 -- 610
	if info.cleared == true then -- 610
		____temp_3 = true -- 610
	else -- 610
		____temp_3 = nil -- 610
	end -- 610
	return { -- 595
		sessionId = ____temp_4, -- 596
		rootSessionId = ____temp_5, -- 597
		parentSessionId = ____temp_6, -- 598
		title = ____temp_7, -- 599
		prompt = ____temp_8, -- 600
		goal = ____temp_9, -- 601
		expectedOutput = ____temp_10, -- 602
		filesHint = ____temp_11, -- 603
		status = ____temp_12, -- 606
		success = ____temp_2, -- 609
		cleared = ____temp_3, -- 610
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 611
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 612
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 613
		changeSet = decodeChangeSetSummary(info.changeSet), -- 614
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 615
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 616
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 617
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 618
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 619
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 620
	} -- 620
end -- 620
function ensureDirRecursive(dir) -- 637
	if not dir or dir == "" then -- 637
		return false -- 638
	end -- 638
	if Content:exist(dir) then -- 638
		return Content:isdir(dir) -- 639
	end -- 639
	local parent = Path:getPath(dir) -- 640
	if parent and parent ~= dir and not Content:exist(parent) then -- 640
		if not ensureDirRecursive(parent) then -- 640
			return false -- 643
		end -- 643
	end -- 643
	return Content:mkdir(dir) -- 646
end -- 646
function writeSpawnInfo(projectRoot, memoryScope, value) -- 649
	local dir = Path(projectRoot, ".agent", memoryScope) -- 650
	if not Content:exist(dir) then -- 650
		ensureDirRecursive(dir) -- 652
	end -- 652
	local path = Path(dir, SPAWN_INFO_FILE) -- 654
	local text = safeJsonEncode(value) -- 655
	if not text then -- 655
		return false -- 656
	end -- 656
	local content = text .. "\n" -- 657
	if not Content:save(path, content) then -- 657
		return false -- 659
	end -- 659
	Tools.sendWebIDEFileUpdate(path, true, content) -- 661
	return true -- 662
end -- 662
function readSpawnInfo(projectRoot, memoryScope) -- 665
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 666
	if not Content:exist(path) then -- 666
		return nil -- 667
	end -- 667
	local text = Content:load(path) -- 668
	if not text or __TS__StringTrim(text) == "" then -- 668
		return nil -- 669
	end -- 669
	local value = safeJsonDecode(text) -- 670
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 670
		return value -- 672
	end -- 672
	return nil -- 674
end -- 674
function getArtifactRelativeDir(memoryScope) -- 677
	return Path(".agent", memoryScope) -- 678
end -- 678
function getArtifactDir(projectRoot, memoryScope) -- 681
	return Path( -- 682
		projectRoot, -- 682
		getArtifactRelativeDir(memoryScope) -- 682
	) -- 682
end -- 682
function getResultRelativePath(memoryScope) -- 685
	return Path( -- 686
		getArtifactRelativeDir(memoryScope), -- 686
		RESULT_FILE -- 686
	) -- 686
end -- 686
function getResultPath(projectRoot, memoryScope) -- 689
	return Path( -- 690
		projectRoot, -- 690
		getResultRelativePath(memoryScope) -- 690
	) -- 690
end -- 690
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 693
	if not resultFilePath or resultFilePath == "" then -- 693
		return "" -- 694
	end -- 694
	local path = Path(projectRoot, resultFilePath) -- 695
	if not Content:exist(path) then -- 695
		return "" -- 696
	end -- 696
	local text = sanitizeUTF8(Content:load(path)) -- 697
	if not text or __TS__StringTrim(text) == "" then -- 697
		return "" -- 698
	end -- 698
	local marker = "\n## Summary\n" -- 699
	local start = string.find(text, marker, 1, true) -- 700
	if start ~= nil then -- 700
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 702
	end -- 702
	return __TS__StringTrim(text) -- 704
end -- 704
function buildSubAgentMemoryEntryLLMOptions(llmConfig) -- 707
	local options = { -- 708
		temperature = llmConfig.temperature or SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, -- 709
		max_tokens = math.min(llmConfig.maxTokens or SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS) -- 710
	} -- 710
	if llmConfig.reasoningEffort then -- 710
		options.reasoning_effort = __TS__StringTrim(llmConfig.reasoningEffort) -- 713
	end -- 713
	if type(options.reasoning_effort) ~= "string" or __TS__StringTrim(options.reasoning_effort) == "" then -- 713
		__TS__Delete(options, "reasoning_effort") -- 716
	end -- 716
	return options -- 718
end -- 718
function buildSubAgentMemoryEntryToolSchema() -- 721
	return {{type = "function", ["function"] = {name = "save_sub_agent_memory_entry", description = "Save one durable memory paragraph extracted from a completed sub-agent session.", parameters = {type = "object", properties = {content = {type = "string", description = "A concise paragraph of key information worth carrying into future main-agent context. Use an empty string when nothing durable should be saved."}, evidence = {type = "array", items = {type = "string"}, description = "Optional short file paths, artifact paths, or concrete anchors that support the memory paragraph."}}, required = {"content"}}}}} -- 722
end -- 722
function buildSubAgentMemoryEntrySystemPrompt() -- 746
	return "You generate a durable memory entry for the parent Dora agent.\nPrefer calling save_sub_agent_memory_entry when tool calling is available.\nIf you cannot call tools, output exactly one JSON object with this shape: {\"content\":\"...\",\"evidence\":[\"...\"]}.\n\nUse the completed sub-agent conversation and final result to decide whether anything should be remembered.\nReturn a single compact paragraph in content, similar to a history entry.\nFocus on durable facts: implemented behavior, important design decisions, constraints, discovered project conventions, or follow-up risks.\nDo not include generic progress narration, praise, or temporary execution details.\nIf there is no information likely to help future work, set content to an empty string.\nKeep evidence short and concrete, such as touched file paths or result artifact paths." -- 747
end -- 747
function formatSubAgentMemoryTailMessage(message) -- 759
	local lines = {"role: " .. sanitizeUTF8(toStr(message.role))} -- 760
	if type(message.name) == "string" and message.name ~= "" then -- 760
		lines[#lines + 1] = "name: " .. sanitizeUTF8(message.name) -- 762
	end -- 762
	if type(message.tool_call_id) == "string" and message.tool_call_id ~= "" then -- 762
		lines[#lines + 1] = "tool_call_id: " .. sanitizeUTF8(message.tool_call_id) -- 765
	end -- 765
	local content = type(message.content) == "string" and clipTextToTokenBudget( -- 767
		sanitizeUTF8(message.content), -- 768
		SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS -- 768
	) or "" -- 768
	if content ~= "" then -- 768
		lines[#lines + 1] = "content:\n" .. content -- 771
	end -- 771
	if __TS__ArrayIsArray(message.tool_calls) and #message.tool_calls > 0 then -- 771
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 774
		if toolCallsText ~= nil and toolCallsText ~= "" then -- 774
			lines[#lines + 1] = "tool_calls:\n" .. clipTextToTokenBudget(toolCallsText, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS) -- 776
		end -- 776
	end -- 776
	return table.concat(lines, "\n") -- 779
end -- 779
function buildSubAgentRecentMessageTail(messages) -- 782
	local parts = {} -- 783
	local totalTokens = 0 -- 784
	local count = 0 -- 785
	do -- 785
		local i = #messages - 1 -- 786
		while i >= 0 and count < SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES do -- 786
			do -- 786
				local text = formatSubAgentMemoryTailMessage(messages[i + 1]) -- 787
				if text == "" then -- 787
					goto __continue122 -- 788
				end -- 788
				local tokens = estimateTextTokens(text) -- 789
				if #parts > 0 and totalTokens + tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS then -- 789
					break -- 790
				end -- 790
				if tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS and #parts == 0 then -- 790
					__TS__ArrayUnshift( -- 792
						parts, -- 792
						clipTextToTokenBudget(text, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS) -- 792
					) -- 792
					break -- 793
				end -- 793
				__TS__ArrayUnshift(parts, text) -- 795
				totalTokens = totalTokens + tokens -- 796
				count = count + 1 -- 797
			end -- 797
			::__continue122:: -- 797
			i = i - 1 -- 786
		end -- 786
	end -- 786
	return #parts > 0 and table.concat(parts, "\n\n---\n\n") or "(empty)"
end -- 799
function buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 802
	local ____opt_13 = record.changeSet -- 802
	local files = ____opt_13 and ____opt_13.files or ({}) -- 803
	local changedFiles = table.concat( -- 804
		__TS__ArrayMap( -- 804
			files, -- 804
			function(____, file) return ((("- " .. file.path) .. " (") .. file.op) .. ")" end -- 804
		), -- 804
		"\n" -- 804
	) -- 804
	local boundedMemoryContext = clipTextToTokenBudget(memoryContext ~= "" and memoryContext or "(empty)", SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS) -- 805
	local boundedResultText = clipTextToTokenBudget(resultText ~= "" and resultText or "(empty)", SUB_AGENT_MEMORY_RESULT_MAX_TOKENS) -- 806
	return ((((((((((((((((((((((("Sub-agent memory context:\n" .. boundedMemoryContext) .. "\n\nSub-agent task metadata:\n- sessionId: ") .. tostring(record.sessionId)) .. "\n- taskId: ") .. tostring(record.sourceTaskId)) .. "\n- title: ") .. record.title) .. "\n- goal: ") .. record.goal) .. "\n- prompt: ") .. record.prompt) .. "\n- expectedOutput: ") .. (record.expectedOutput or "")) .. "\n- resultFilePath: ") .. record.resultFilePath) .. "\n- finishedAt: ") .. record.finishedAt) .. "\n\nChanged files:\n") .. (changedFiles ~= "" and changedFiles or "- none")) .. "\n\nFinal sub-agent result:\n") .. boundedResultText) .. "\n\nRecent conversation tail:\n") .. recentMessageTail) .. "\n\nGenerate the memory entry now." -- 807
end -- 807
function buildSubAgentMemoryEntryRetryPrompt(lastError) -- 832
	return ("Previous memory entry response was invalid: " .. lastError) .. "\n\nRetry with exactly one JSON object and no Markdown fences, no prose, no tool call.\nSchema:\n{\"content\":\"one concise durable memory paragraph, or empty string if nothing should be saved\",\"evidence\":[\"optional short file path or artifact path\"]}\n\nRules:\n- content must be a string.\n- evidence must be an array of strings.\n- Use {\"content\":\"\",\"evidence\":[]} when there is no durable memory to save." -- 833
end -- 833
function normalizeGeneratedSubAgentMemoryEntry(value, record) -- 845
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 845
		return nil -- 846
	end -- 846
	local row = value -- 847
	local content = takeUtf8Head( -- 848
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 848
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 848
	) -- 848
	if content == "" then -- 848
		return nil -- 849
	end -- 849
	return { -- 850
		sourceSessionId = record.sessionId, -- 851
		sourceTaskId = record.sourceTaskId, -- 852
		content = content, -- 853
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 854
		createdAt = record.finishedAt -- 855
	} -- 855
end -- 855
function getMemoryEntryToolFunction(response) -- 859
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 859
		return nil -- 860
	end -- 860
	local row = response -- 861
	local choices = row.choices -- 862
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 862
		return nil -- 863
	end -- 863
	local ____opt_15 = choices[1] -- 863
	if ____opt_15 ~= nil then -- 863
		____opt_15 = ____opt_15.message -- 863
	end -- 863
	local message = ____opt_15 -- 864
	local ____opt_result_19 -- 864
	if message ~= nil then -- 864
		____opt_result_19 = message.tool_calls -- 864
	end -- 864
	local toolCalls = ____opt_result_19 -- 865
	if not __TS__ArrayIsArray(toolCalls) then -- 865
		return nil -- 866
	end -- 866
	do -- 866
		local i = 0 -- 867
		while i < #toolCalls do -- 867
			local ____opt_20 = toolCalls[i + 1] -- 867
			if ____opt_20 ~= nil then -- 867
				____opt_20 = ____opt_20["function"] -- 867
			end -- 867
			local fn = ____opt_20 -- 868
			if (fn and fn.name) == "save_sub_agent_memory_entry" then -- 868
				return fn -- 869
			end -- 869
			i = i + 1 -- 867
		end -- 867
	end -- 867
	return nil -- 871
end -- 871
function getMemoryEntryPlainContent(response) -- 874
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 874
		return "" -- 875
	end -- 875
	local row = response -- 876
	local choices = row.choices -- 877
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 877
		return "" -- 878
	end -- 878
	local ____opt_24 = choices[1] -- 878
	if ____opt_24 ~= nil then -- 878
		____opt_24 = ____opt_24.message -- 878
	end -- 878
	local message = ____opt_24 -- 879
	local ____opt_result_28 -- 879
	if message ~= nil then -- 879
		____opt_result_28 = message.content -- 879
	end -- 879
	return type(____opt_result_28) == "string" and __TS__StringTrim(sanitizeUTF8(message.content)) or "" -- 880
end -- 880
function decodeMemoryEntryFromPlainContent(content) -- 883
	if content == "" then -- 883
		return nil -- 884
	end -- 884
	local direct = safeJsonDecode(content) -- 885
	if direct ~= nil then -- 885
		return direct -- 886
	end -- 886
	local start = string.find(content, "{", 1, true) -- 887
	if start == nil then -- 887
		return nil -- 888
	end -- 888
	local ____end = #content -- 889
	while ____end >= start do -- 889
		local candidate = string.sub(content, start, ____end) -- 891
		local value = safeJsonDecode(candidate) -- 892
		if value ~= nil then -- 892
			return value -- 893
		end -- 893
		____end = ____end - 1 -- 894
	end -- 894
	return nil -- 896
end -- 896
function hasEmptyMemoryEntryContent(value) -- 899
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 899
		return false -- 900
	end -- 900
	local row = value -- 901
	return type(row.content) == "string" and __TS__StringTrim(sanitizeUTF8(row.content)) == "" -- 902
end -- 902
function generateSubAgentMemoryEntry(session, record, resultText) -- 905
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 905
		if not record.success then -- 905
			return ____awaiter_resolve(nil, {}) -- 905
		end -- 905
		local configRes = getActiveLLMConfig() -- 907
		if not configRes.success then -- 907
			return ____awaiter_resolve(nil, {error = configRes.message}) -- 907
		end -- 907
		local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 911
		local persisted = storage:readSessionState() -- 912
		local memoryContext = storage:readMemory() -- 913
		local recentMessageTail = buildSubAgentRecentMessageTail(persisted.messages) -- 914
		local prompt = buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 915
		local tools = configRes.config.supportsFunctionCalling and buildSubAgentMemoryEntryToolSchema() or nil -- 916
		local lastError = "missing memory entry" -- 917
		do -- 917
			local attempt = 0 -- 918
			while attempt < SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY do -- 918
				do -- 918
					local useTools = attempt == 0 and tools ~= nil -- 919
					local messages = { -- 920
						{ -- 921
							role = "system", -- 921
							content = buildSubAgentMemoryEntrySystemPrompt() -- 921
						}, -- 921
						{ -- 922
							role = "user", -- 923
							content = attempt == 0 and prompt or (prompt .. "\n\n") .. buildSubAgentMemoryEntryRetryPrompt(lastError) -- 924
						} -- 924
					} -- 924
					local response = __TS__Await(callLLM( -- 929
						messages, -- 930
						__TS__ObjectAssign( -- 931
							{}, -- 931
							buildSubAgentMemoryEntryLLMOptions(configRes.config), -- 932
							useTools and ({tools = tools}) or ({}) -- 933
						), -- 933
						configRes.config -- 935
					)) -- 935
					if not response.success then -- 935
						lastError = response.message -- 938
						if useTools then -- 938
							Log("Warn", "[AgentSession] sub session memory entry tool request failed, retrying without tools: " .. response.message) -- 940
						end -- 940
						goto __continue154 -- 942
					end -- 942
					local fn = getMemoryEntryToolFunction(response.response) -- 944
					local argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 945
					if fn ~= nil and argsText ~= "" then -- 945
						local args, err = safeJsonDecode(argsText) -- 947
						if err ~= nil or args == nil then -- 947
							lastError = "invalid memory entry tool arguments: " .. tostring(err) -- 949
							goto __continue154 -- 950
						end -- 950
						if hasEmptyMemoryEntryContent(args) then -- 950
							return ____awaiter_resolve(nil, {}) -- 950
						end -- 950
						local entry = normalizeGeneratedSubAgentMemoryEntry(args, record) -- 953
						if entry ~= nil then -- 953
							return ____awaiter_resolve(nil, {entry = entry}) -- 953
						end -- 953
						lastError = "invalid memory entry tool arguments shape" -- 955
						goto __continue154 -- 956
					end -- 956
					local plainContent = getMemoryEntryPlainContent(response.response) -- 958
					local plainArgs = decodeMemoryEntryFromPlainContent(plainContent) -- 959
					if plainArgs ~= nil then -- 959
						if hasEmptyMemoryEntryContent(plainArgs) then -- 959
							return ____awaiter_resolve(nil, {}) -- 959
						end -- 959
						local entry = normalizeGeneratedSubAgentMemoryEntry(plainArgs, record) -- 962
						if entry ~= nil then -- 962
							return ____awaiter_resolve(nil, {entry = entry}) -- 962
						end -- 962
						lastError = "invalid memory entry JSON shape" -- 964
						goto __continue154 -- 965
					end -- 965
					lastError = "LLM did not return memory entry tool call or JSON content" -- 967
				end -- 967
				::__continue154:: -- 967
				attempt = attempt + 1 -- 918
			end -- 918
		end -- 918
		return ____awaiter_resolve(nil, {error = lastError}) -- 918
	end) -- 918
end -- 918
function containsNormalizedText(text, query) -- 972
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 973
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 974
	if normalizedQuery == "" then -- 974
		return true -- 975
	end -- 975
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 976
end -- 976
function getSubAgentDisplayKey(item) -- 979
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 985
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 986
	local label = goal ~= "" and goal or title -- 987
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 988
end -- 988
function writeSubAgentResultFile(session, record, resultText) -- 991
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 992
	if not Content:exist(dir) then -- 992
		ensureDirRecursive(dir) -- 994
	end -- 994
	local ____array_29 = __TS__SparseArrayNew( -- 994
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 997
		"- Status: " .. record.status, -- 998
		"- Success: " .. (record.success and "true" or "false"), -- 999
		"- Session ID: " .. tostring(record.sessionId), -- 1000
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1001
		"- Goal: " .. record.goal, -- 1002
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1003
	) -- 1003
	__TS__SparseArrayPush( -- 1003
		____array_29, -- 1003
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1004
	) -- 1004
	__TS__SparseArrayPush( -- 1004
		____array_29, -- 1004
		"- Finished At: " .. record.finishedAt, -- 1005
		"", -- 1006
		"## Summary", -- 1007
		resultText ~= "" and resultText or "(empty)" -- 1008
	) -- 1008
	local lines = {__TS__SparseArraySpread(____array_29)} -- 996
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1010
	local content = table.concat(lines, "\n") .. "\n" -- 1011
	if not Content:save(path, content) then -- 1011
		return false -- 1013
	end -- 1013
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1015
	return true -- 1016
end -- 1016
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1019
	local dir = Path(projectRoot, ".agent", "subagents") -- 1020
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1020
		return {} -- 1021
	end -- 1021
	local items = {} -- 1022
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1023
		do -- 1023
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1024
			if not Content:exist(path) or not Content:isdir(path) then -- 1024
				goto __continue172 -- 1025
			end -- 1025
			local info = readSpawnInfo( -- 1026
				projectRoot, -- 1026
				Path( -- 1026
					"subagents", -- 1026
					Path:getFilename(path) -- 1026
				) -- 1026
			) -- 1026
			if not info then -- 1026
				goto __continue172 -- 1027
			end -- 1027
			local sessionId = tonumber(info.sessionId) -- 1028
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1029
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1030
			local status = sanitizeUTF8(toStr(info.status)) -- 1031
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1031
				goto __continue172 -- 1032
			end -- 1032
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1032
				goto __continue172 -- 1033
			end -- 1033
			items[#items + 1] = { -- 1034
				sessionId = sessionId, -- 1035
				rootSessionId = infoRootSessionId, -- 1036
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1037
				title = sanitizeUTF8(toStr(info.title)), -- 1038
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1039
				goal = sanitizeUTF8(toStr(info.goal)), -- 1040
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1041
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1042
					__TS__ArrayFilter( -- 1043
						info.filesHint, -- 1043
						function(____, item) return type(item) == "string" end -- 1043
					), -- 1043
					function(____, item) return sanitizeUTF8(item) end -- 1043
				) or ({}), -- 1043
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1045
				success = info.success == true, -- 1046
				cleared = info.cleared == true, -- 1047
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1048
				artifactDir = sanitizeUTF8(toStr(info.artifactDir)) or getArtifactRelativeDir(Path( -- 1049
					"subagents", -- 1049
					Path:getFilename(path) -- 1049
				)), -- 1049
				sourceTaskId = sourceTaskId or 0, -- 1050
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1051
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1052
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1053
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1054
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1055
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1056
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1057
			} -- 1057
		end -- 1057
		::__continue172:: -- 1057
	end -- 1057
	__TS__ArraySort( -- 1060
		items, -- 1060
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1060
	) -- 1060
	return items -- 1061
end -- 1061
function getPendingHandoffDir(projectRoot, memoryScope) -- 1064
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1065
end -- 1065
function writePendingHandoff(projectRoot, memoryScope, value) -- 1068
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1069
	if not Content:exist(dir) then -- 1069
		ensureDirRecursive(dir) -- 1071
	end -- 1071
	local path = Path(dir, value.id .. ".json") -- 1073
	local text = safeJsonEncode(value) -- 1074
	if not text then -- 1074
		return false -- 1075
	end -- 1075
	return Content:save(path, text .. "\n") -- 1076
end -- 1076
function listPendingHandoffs(projectRoot, memoryScope) -- 1079
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1080
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1080
		return {} -- 1081
	end -- 1081
	local items = {} -- 1082
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1083
		do -- 1083
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1084
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1084
				goto __continue187 -- 1085
			end -- 1085
			local text = Content:load(path) -- 1086
			if not text or __TS__StringTrim(text) == "" then -- 1086
				goto __continue187 -- 1087
			end -- 1087
			local value = safeJsonDecode(text) -- 1088
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 1088
				goto __continue187 -- 1089
			end -- 1089
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1090
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1091
			local id = sanitizeUTF8(toStr(value.id)) -- 1092
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1093
			local message = sanitizeUTF8(toStr(value.message)) -- 1094
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1095
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1096
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1097
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1097
				goto __continue187 -- 1099
			end -- 1099
			items[#items + 1] = { -- 1101
				id = id, -- 1102
				sourceSessionId = sourceSessionId, -- 1103
				sourceTitle = sourceTitle, -- 1104
				sourceTaskId = sourceTaskId, -- 1105
				message = message, -- 1106
				prompt = prompt, -- 1107
				goal = goal, -- 1108
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1109
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1110
					__TS__ArrayFilter( -- 1111
						value.filesHint, -- 1111
						function(____, item) return type(item) == "string" end -- 1111
					), -- 1111
					function(____, item) return sanitizeUTF8(item) end -- 1111
				) or ({}), -- 1111
				success = value.success == true, -- 1113
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1114
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1115
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1116
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1117
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1118
				createdAt = createdAt -- 1119
			} -- 1119
		end -- 1119
		::__continue187:: -- 1119
	end -- 1119
	__TS__ArraySort( -- 1122
		items, -- 1122
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1122
	) -- 1122
	return items -- 1123
end -- 1123
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1126
	local path = Path( -- 1127
		getPendingHandoffDir(projectRoot, memoryScope), -- 1127
		id .. ".json" -- 1127
	) -- 1127
	if Content:exist(path) then -- 1127
		Content:remove(path) -- 1129
	end -- 1129
end -- 1129
function normalizePromptText(prompt) -- 1133
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1134
end -- 1134
function normalizePromptTextSafe(prompt) -- 1137
	if type(prompt) == "string" then -- 1137
		local normalized = normalizePromptText(prompt) -- 1139
		if normalized ~= "" then -- 1139
			return normalized -- 1140
		end -- 1140
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1141
		if sanitized ~= "" then -- 1141
			return truncateAgentUserPrompt(sanitized) -- 1143
		end -- 1143
		return "" -- 1145
	end -- 1145
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1147
	if text == "" then -- 1147
		return "" -- 1148
	end -- 1148
	return truncateAgentUserPrompt(text) -- 1149
end -- 1149
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1152
	local sections = {} -- 1153
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1154
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1155
	local normalizedFiles = __TS__ArrayFilter( -- 1156
		__TS__ArrayMap( -- 1156
			__TS__ArrayFilter( -- 1156
				filesHint or ({}), -- 1156
				function(____, item) return type(item) == "string" end -- 1157
			), -- 1157
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1158
		), -- 1158
		function(____, item) return item ~= "" end -- 1159
	) -- 1159
	if normalizedTitle ~= "" then -- 1159
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1161
	end -- 1161
	if normalizedExpected ~= "" then -- 1161
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1164
	end -- 1164
	if #normalizedFiles > 0 then -- 1164
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1167
	end -- 1167
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1169
end -- 1169
function normalizeSessionRuntimeState(session) -- 1172
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1172
		return session -- 1174
	end -- 1174
	if activeStopTokens[session.currentTaskId] then -- 1174
		return session -- 1177
	end -- 1177
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1179
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1180
	return __TS__ObjectAssign( -- 1181
		{}, -- 1181
		session, -- 1182
		{ -- 1181
			status = "STOPPED", -- 1183
			currentTaskStatus = "STOPPED", -- 1184
			updatedAt = now() -- 1185
		} -- 1185
	) -- 1185
end -- 1185
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1189
	DB:exec( -- 1190
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1190
		{ -- 1194
			status, -- 1195
			currentTaskId or 0, -- 1196
			currentTaskStatus or status, -- 1197
			now(), -- 1198
			sessionId -- 1199
		} -- 1199
	) -- 1199
end -- 1199
function mergeAgentMetrics(current, next) -- 1204
	return __TS__ObjectAssign({}, current or ({}), next) -- 1205
end -- 1205
function updateSessionMetrics(sessionId, metrics) -- 1211
	local session = getSessionItem(sessionId) -- 1212
	if not session then -- 1212
		return nil -- 1213
	end -- 1213
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1214
	DB:exec( -- 1215
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1215
		{ -- 1219
			encodeJson(merged), -- 1220
			now(), -- 1221
			sessionId -- 1222
		} -- 1222
	) -- 1222
	return merged -- 1225
end -- 1225
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1228
	if taskId == nil or taskId <= 0 then -- 1228
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1230
		return -- 1231
	end -- 1231
	local row = getSessionRow(sessionId) -- 1233
	if not row then -- 1233
		return -- 1234
	end -- 1234
	local session = rowToSession(row) -- 1235
	if session.currentTaskId ~= taskId then -- 1235
		Log( -- 1237
			"Info", -- 1237
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1237
		) -- 1237
		return -- 1238
	end -- 1238
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1240
end -- 1240
function insertMessage(sessionId, role, content, taskId) -- 1243
	local t = now() -- 1244
	DB:exec( -- 1245
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1245
		{ -- 1248
			sessionId, -- 1249
			taskId or 0, -- 1250
			role, -- 1251
			sanitizeUTF8(content), -- 1252
			t, -- 1253
			t -- 1254
		} -- 1254
	) -- 1254
	return getLastInsertRowId() -- 1257
end -- 1257
function updateMessage(messageId, content) -- 1260
	DB:exec( -- 1261
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1261
		{ -- 1263
			sanitizeUTF8(content), -- 1263
			now(), -- 1263
			messageId -- 1263
		} -- 1263
	) -- 1263
end -- 1263
function updateUserMessageForTask(messageId, content, taskId) -- 1267
	DB:exec( -- 1268
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1268
		{ -- 1272
			sanitizeUTF8(content), -- 1272
			taskId, -- 1272
			now(), -- 1272
			messageId -- 1272
		} -- 1272
	) -- 1272
end -- 1272
function upsertAssistantMessage(sessionId, taskId, content) -- 1308
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1309
	if row and type(row[1]) == "number" then -- 1309
		updateMessage(row[1], content) -- 1316
		return row[1] -- 1317
	end -- 1317
	return insertMessage(sessionId, "assistant", content, taskId) -- 1319
end -- 1319
function upsertStep(sessionId, taskId, step, tool, patch) -- 1322
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1332
	local reason = sanitizeUTF8(patch.reason or "") -- 1336
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1337
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1338
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1339
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1340
	local statusPatch = patch.status or "" -- 1341
	local status = patch.status or "PENDING" -- 1342
	if not row then -- 1342
		local t = now() -- 1344
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1345
			sessionId, -- 1349
			taskId, -- 1350
			step, -- 1351
			tool, -- 1352
			status, -- 1353
			reason, -- 1354
			reasoningContent, -- 1355
			paramsJson, -- 1356
			resultJson, -- 1357
			patch.checkpointId or 0, -- 1358
			patch.checkpointSeq or 0, -- 1359
			filesJson, -- 1360
			t, -- 1361
			t -- 1362
		}) -- 1362
		return -- 1365
	end -- 1365
	DB:exec( -- 1367
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1367
		{ -- 1379
			tool, -- 1380
			statusPatch, -- 1381
			status, -- 1382
			reason, -- 1383
			reason, -- 1384
			reasoningContent, -- 1385
			reasoningContent, -- 1386
			paramsJson, -- 1387
			paramsJson, -- 1388
			resultJson, -- 1389
			resultJson, -- 1390
			patch.checkpointId or 0, -- 1391
			patch.checkpointId or 0, -- 1392
			patch.checkpointSeq or 0, -- 1393
			patch.checkpointSeq or 0, -- 1394
			filesJson, -- 1395
			filesJson, -- 1396
			now(), -- 1397
			row[1] -- 1398
		} -- 1398
	) -- 1398
end -- 1398
function getNextStepNumber(sessionId, taskId) -- 1403
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1404
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1408
	return math.max(0, current) + 1 -- 1409
end -- 1409
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1412
	if status == nil then -- 1412
		status = "DONE" -- 1420
	end -- 1420
	local step = getNextStepNumber(sessionId, taskId) -- 1422
	upsertStep( -- 1423
		sessionId, -- 1423
		taskId, -- 1423
		step, -- 1423
		tool, -- 1423
		{status = status, reason = reason, params = params, result = result} -- 1423
	) -- 1423
	return getStepItem(sessionId, taskId, step) -- 1429
end -- 1429
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1432
	if taskId <= 0 then -- 1432
		return -- 1433
	end -- 1433
	if finalSteps ~= nil and finalSteps >= 0 then -- 1433
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1435
	end -- 1435
	if not finalStatus then -- 1435
		return -- 1441
	end -- 1441
	if finalSteps ~= nil and finalSteps >= 0 then -- 1441
		DB:exec( -- 1443
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1443
			{ -- 1447
				finalStatus, -- 1447
				now(), -- 1447
				sessionId, -- 1447
				taskId, -- 1447
				finalSteps -- 1447
			} -- 1447
		) -- 1447
		return -- 1449
	end -- 1449
	DB:exec( -- 1451
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1451
		{ -- 1455
			finalStatus, -- 1455
			now(), -- 1455
			sessionId, -- 1455
			taskId -- 1455
		} -- 1455
	) -- 1455
end -- 1455
function emitAgentSessionPatch(sessionId, patch) -- 1482
	if HttpServer.wsConnectionCount == 0 then -- 1482
		return -- 1484
	end -- 1484
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1486
	if not text then -- 1486
		return -- 1491
	end -- 1491
	emit("AppWS", "Send", text) -- 1492
end -- 1492
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1495
	emitAgentSessionPatch( -- 1496
		sessionId, -- 1496
		{ -- 1496
			sessionDeleted = true, -- 1497
			relatedSessions = listRelatedSessions(rootSessionId) -- 1498
		} -- 1498
	) -- 1498
	local rootSession = getSessionItem(rootSessionId) -- 1500
	if rootSession then -- 1500
		emitAgentSessionPatch( -- 1502
			rootSessionId, -- 1502
			{ -- 1502
				session = rootSession, -- 1503
				relatedSessions = listRelatedSessions(rootSessionId) -- 1504
			} -- 1504
		) -- 1504
	end -- 1504
end -- 1504
function flushPendingSubAgentHandoffs(rootSession) -- 1509
	if rootSession.kind ~= "main" then -- 1509
		return -- 1510
	end -- 1510
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1510
		return -- 1512
	end -- 1512
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1514
	if #items == 0 then -- 1514
		return -- 1515
	end -- 1515
	local handoffTaskId = 0 -- 1516
	local ____rootSession_currentTaskId_30 -- 1517
	if rootSession.currentTaskId then -- 1517
		____rootSession_currentTaskId_30 = getTaskPrompt(rootSession.currentTaskId) -- 1517
	else -- 1517
		____rootSession_currentTaskId_30 = nil -- 1517
	end -- 1517
	local currentTaskPrompt = ____rootSession_currentTaskId_30 -- 1517
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1517
		handoffTaskId = rootSession.currentTaskId -- 1525
	else -- 1525
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1527
		if not taskRes.success then -- 1527
			Log( -- 1529
				"Warn", -- 1529
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1529
			) -- 1529
			return -- 1530
		end -- 1530
		handoffTaskId = taskRes.taskId -- 1532
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1533
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1534
		emitAgentSessionPatch( -- 1535
			rootSession.id, -- 1535
			{session = getSessionItem(rootSession.id)} -- 1535
		) -- 1535
	end -- 1535
	do -- 1535
		local i = 0 -- 1539
		while i < #items do -- 1539
			local item = items[i + 1] -- 1540
			local step = appendSystemStep( -- 1541
				rootSession.id, -- 1542
				handoffTaskId, -- 1543
				"sub_agent_handoff", -- 1544
				"sub_agent_handoff", -- 1545
				item.message, -- 1546
				{ -- 1547
					sourceSessionId = item.sourceSessionId, -- 1548
					sourceTitle = item.sourceTitle, -- 1549
					sourceTaskId = item.sourceTaskId, -- 1550
					success = item.success == true, -- 1551
					summary = item.message, -- 1552
					resultFilePath = item.resultFilePath or "", -- 1553
					artifactDir = item.artifactDir or "", -- 1554
					finishedAt = item.finishedAt or "", -- 1555
					changeSet = item.changeSet, -- 1556
					memoryEntry = item.memoryEntry -- 1557
				}, -- 1557
				{ -- 1559
					sourceSessionId = item.sourceSessionId, -- 1560
					sourceTitle = item.sourceTitle, -- 1561
					sourceTaskId = item.sourceTaskId, -- 1562
					prompt = item.prompt, -- 1563
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1564
					expectedOutput = item.expectedOutput or "", -- 1565
					filesHint = item.filesHint or ({}), -- 1566
					resultFilePath = item.resultFilePath or "", -- 1567
					artifactDir = item.artifactDir or "", -- 1568
					changeSet = item.changeSet, -- 1569
					memoryEntry = item.memoryEntry -- 1570
				}, -- 1570
				"DONE" -- 1572
			) -- 1572
			if step then -- 1572
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1575
			end -- 1575
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1577
			i = i + 1 -- 1539
		end -- 1539
	end -- 1539
end -- 1539
function applyEvent(sessionId, event) -- 1589
	repeat -- 1589
		local ____switch257 = event.type -- 1589
		local ____cond257 = ____switch257 == "task_started" -- 1589
		if ____cond257 then -- 1589
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1592
			emitAgentSessionPatch( -- 1593
				sessionId, -- 1593
				{session = getSessionItem(sessionId)} -- 1593
			) -- 1593
			break -- 1596
		end -- 1596
		____cond257 = ____cond257 or ____switch257 == "decision_made" -- 1596
		if ____cond257 then -- 1596
			upsertStep( -- 1598
				sessionId, -- 1598
				event.taskId, -- 1598
				event.step, -- 1598
				event.tool, -- 1598
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1598
			) -- 1598
			emitAgentSessionPatch( -- 1604
				sessionId, -- 1604
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1604
			) -- 1604
			break -- 1607
		end -- 1607
		____cond257 = ____cond257 or ____switch257 == "tool_started" -- 1607
		if ____cond257 then -- 1607
			upsertStep( -- 1609
				sessionId, -- 1609
				event.taskId, -- 1609
				event.step, -- 1609
				event.tool, -- 1609
				{status = "RUNNING"} -- 1609
			) -- 1609
			emitAgentSessionPatch( -- 1612
				sessionId, -- 1612
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1612
			) -- 1612
			break -- 1615
		end -- 1615
		____cond257 = ____cond257 or ____switch257 == "tool_finished" -- 1615
		if ____cond257 then -- 1615
			upsertStep( -- 1617
				sessionId, -- 1617
				event.taskId, -- 1617
				event.step, -- 1617
				event.tool, -- 1617
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1617
			) -- 1617
			emitAgentSessionPatch( -- 1622
				sessionId, -- 1622
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1622
			) -- 1622
			break -- 1625
		end -- 1625
		____cond257 = ____cond257 or ____switch257 == "checkpoint_created" -- 1625
		if ____cond257 then -- 1625
			upsertStep( -- 1627
				sessionId, -- 1627
				event.taskId, -- 1627
				event.step, -- 1627
				event.tool, -- 1627
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1627
			) -- 1627
			emitAgentSessionPatch( -- 1632
				sessionId, -- 1632
				{ -- 1632
					step = getStepItem(sessionId, event.taskId, event.step), -- 1633
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1634
				} -- 1634
			) -- 1634
			break -- 1636
		end -- 1636
		____cond257 = ____cond257 or ____switch257 == "memory_compression_started" -- 1636
		if ____cond257 then -- 1636
			upsertStep( -- 1638
				sessionId, -- 1638
				event.taskId, -- 1638
				event.step, -- 1638
				event.tool, -- 1638
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1638
			) -- 1638
			emitAgentSessionPatch( -- 1643
				sessionId, -- 1643
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1643
			) -- 1643
			break -- 1646
		end -- 1646
		____cond257 = ____cond257 or ____switch257 == "memory_compression_finished" -- 1646
		if ____cond257 then -- 1646
			upsertStep( -- 1648
				sessionId, -- 1648
				event.taskId, -- 1648
				event.step, -- 1648
				event.tool, -- 1648
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1648
			) -- 1648
			emitAgentSessionPatch( -- 1653
				sessionId, -- 1653
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1653
			) -- 1653
			break -- 1656
		end -- 1656
		____cond257 = ____cond257 or ____switch257 == "metrics_updated" -- 1656
		if ____cond257 then -- 1656
			do -- 1656
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1658
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1659
				break -- 1662
			end -- 1662
		end -- 1662
		____cond257 = ____cond257 or ____switch257 == "assistant_message_updated" -- 1662
		if ____cond257 then -- 1662
			do -- 1662
				upsertStep( -- 1665
					sessionId, -- 1665
					event.taskId, -- 1665
					event.step, -- 1665
					"message", -- 1665
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1665
				) -- 1665
				emitAgentSessionPatch( -- 1670
					sessionId, -- 1670
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1670
				) -- 1670
				break -- 1673
			end -- 1673
		end -- 1673
		____cond257 = ____cond257 or ____switch257 == "task_finished" -- 1673
		if ____cond257 then -- 1673
			do -- 1673
				local ____opt_31 = activeStopTokens[event.taskId or -1] -- 1673
				local stopped = (____opt_31 and ____opt_31.stopped) == true -- 1676
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1677
				local session = getSessionItem(sessionId) -- 1680
				local isSubSession = (session and session.kind) == "sub" -- 1681
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1682
				if isSubSession and event.taskId ~= nil then -- 1682
					finalizingSubSessionTaskIds[event.taskId] = true -- 1684
				end -- 1684
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1686
				if event.taskId ~= nil then -- 1686
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1688
					local ____finalizeTaskSteps_37 = finalizeTaskSteps -- 1689
					local ____array_36 = __TS__SparseArrayNew( -- 1689
						sessionId, -- 1690
						event.taskId, -- 1691
						type(event.steps) == "number" and math.max( -- 1692
							0, -- 1692
							math.floor(event.steps) -- 1692
						) or nil -- 1692
					) -- 1692
					local ____event_success_35 -- 1693
					if event.success then -- 1693
						____event_success_35 = nil -- 1693
					else -- 1693
						____event_success_35 = stopped and "STOPPED" or "FAILED" -- 1693
					end -- 1693
					__TS__SparseArrayPush(____array_36, ____event_success_35) -- 1693
					____finalizeTaskSteps_37(__TS__SparseArraySpread(____array_36)) -- 1689
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1695
					if not isSubSession then -- 1695
						activeStopTokens[event.taskId] = nil -- 1697
					end -- 1697
					emitAgentSessionPatch( -- 1699
						sessionId, -- 1699
						{ -- 1699
							session = getSessionItem(sessionId), -- 1700
							message = getMessageItem(messageId), -- 1701
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1702
							removedStepIds = removedStepIds -- 1703
						} -- 1703
					) -- 1703
				end -- 1703
				if session and session.kind == "main" then -- 1703
					flushPendingSubAgentHandoffs(session) -- 1707
				end -- 1707
				break -- 1709
			end -- 1709
		end -- 1709
	until true -- 1709
end -- 1709
function ____exports.createSession(projectRoot, title) -- 1846
	if title == nil then -- 1846
		title = "" -- 1846
	end -- 1846
	if not isValidProjectRoot(projectRoot) then -- 1846
		return {success = false, message = "invalid projectRoot"} -- 1848
	end -- 1848
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1850
	if row then -- 1850
		return { -- 1859
			success = true, -- 1859
			session = rowToSession(row) -- 1859
		} -- 1859
	end -- 1859
	local t = now() -- 1861
	DB:exec( -- 1862
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1862
		{ -- 1865
			projectRoot, -- 1865
			title ~= "" and title or Path:getFilename(projectRoot), -- 1865
			t, -- 1865
			t -- 1865
		} -- 1865
	) -- 1865
	local sessionId = getLastInsertRowId() -- 1867
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1868
	local session = getSessionItem(sessionId) -- 1869
	if not session then -- 1869
		return {success = false, message = "failed to create session"} -- 1871
	end -- 1871
	return {success = true, session = session} -- 1873
end -- 1846
function ____exports.createSubSession(parentSessionId, title) -- 1876
	if title == nil then -- 1876
		title = "" -- 1876
	end -- 1876
	local parent = getSessionItem(parentSessionId) -- 1877
	if not parent then -- 1877
		return {success = false, message = "parent session not found"} -- 1879
	end -- 1879
	local rootId = getSessionRootId(parent) -- 1881
	local t = now() -- 1882
	DB:exec( -- 1883
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1883
		{ -- 1886
			parent.projectRoot, -- 1886
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1886
			rootId, -- 1886
			parent.id, -- 1886
			t, -- 1886
			t -- 1886
		} -- 1886
	) -- 1886
	local sessionId = getLastInsertRowId() -- 1888
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1889
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1890
	local session = getSessionItem(sessionId) -- 1891
	if not session then -- 1891
		return {success = false, message = "failed to create sub session"} -- 1893
	end -- 1893
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1895
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1896
	subStorage:writeMemory(parentStorage:readMemory()) -- 1897
	return {success = true, session = session} -- 1898
end -- 1876
function spawnSubAgentSession(request) -- 1901
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1901
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1912
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1913
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1914
		if normalizedPrompt == "" then -- 1914
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1916
		end -- 1916
		if normalizedPrompt == "" then -- 1916
			local ____Log_43 = Log -- 1923
			local ____temp_40 = #normalizedTitle -- 1923
			local ____temp_41 = #rawPrompt -- 1923
			local ____temp_42 = #toStr(request.expectedOutput) -- 1923
			local ____opt_38 = request.filesHint -- 1923
			____Log_43( -- 1923
				"Warn", -- 1923
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_40)) .. " raw_prompt_len=") .. tostring(____temp_41)) .. " expected_len=") .. tostring(____temp_42)) .. " files_hint_count=") .. tostring(____opt_38 and #____opt_38 or 0) -- 1923
			) -- 1923
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1923
		end -- 1923
		Log( -- 1926
			"Info", -- 1926
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1926
		) -- 1926
		local parentSessionId = request.parentSessionId -- 1927
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1927
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1929
			if not fallbackParent then -- 1929
				local createdMain = ____exports.createSession(request.projectRoot) -- 1931
				if createdMain.success then -- 1931
					fallbackParent = createdMain.session -- 1933
				end -- 1933
			end -- 1933
			if fallbackParent then -- 1933
				Log( -- 1937
					"Warn", -- 1937
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1937
				) -- 1937
				parentSessionId = fallbackParent.id -- 1938
			end -- 1938
		end -- 1938
		local parentSession = getSessionItem(parentSessionId) -- 1941
		if not parentSession then -- 1941
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1941
		end -- 1941
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1945
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1945
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1945
		end -- 1945
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1949
		if not created.success then -- 1949
			return ____awaiter_resolve(nil, created) -- 1949
		end -- 1949
		writeSpawnInfo( -- 1953
			created.session.projectRoot, -- 1953
			created.session.memoryScope, -- 1953
			{ -- 1953
				sessionId = created.session.id, -- 1954
				rootSessionId = created.session.rootSessionId, -- 1955
				parentSessionId = created.session.parentSessionId, -- 1956
				title = created.session.title, -- 1957
				prompt = normalizedPrompt, -- 1958
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1959
				expectedOutput = request.expectedOutput or "", -- 1960
				filesHint = request.filesHint or ({}), -- 1961
				status = "RUNNING", -- 1962
				success = false, -- 1963
				resultFilePath = "", -- 1964
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1965
				sourceTaskId = 0, -- 1966
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1967
				createdAtTs = created.session.createdAt, -- 1968
				finishedAt = "", -- 1969
				finishedAtTs = 0 -- 1970
			} -- 1970
		) -- 1970
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1972
		if not sent.success then -- 1972
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1972
		end -- 1972
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1972
	end) -- 1972
end -- 1972
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2053
	local rootSession = getRootSessionItem(session.id) -- 2054
	if not rootSession then -- 2054
		return -- 2055
	end -- 2055
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2056
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2057
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2058
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2059
	local queueResult = writePendingHandoff( -- 2060
		rootSession.projectRoot, -- 2060
		rootSession.memoryScope, -- 2060
		{ -- 2060
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2061
			sourceSessionId = session.id, -- 2062
			sourceTitle = session.title, -- 2063
			sourceTaskId = taskId, -- 2064
			message = summary, -- 2065
			prompt = result.prompt, -- 2066
			goal = result.goal, -- 2067
			expectedOutput = result.expectedOutput or "", -- 2068
			filesHint = result.filesHint or ({}), -- 2069
			success = result.success, -- 2070
			resultFilePath = result.resultFilePath, -- 2071
			artifactDir = result.artifactDir, -- 2072
			finishedAt = result.finishedAt, -- 2073
			changeSet = changeSet, -- 2074
			memoryEntry = result.memoryEntry, -- 2075
			createdAt = createdAt -- 2076
		} -- 2076
	) -- 2076
	if not queueResult then -- 2076
		Log( -- 2079
			"Warn", -- 2079
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2079
		) -- 2079
		return -- 2080
	end -- 2080
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2080
		flushPendingSubAgentHandoffs(rootSession) -- 2083
	end -- 2083
end -- 2083
function finalizeSubSession(session, taskId, success, message) -- 2087
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2087
		local rootSessionId = getSessionRootId(session) -- 2088
		local rootSession = getRootSessionItem(session.id) -- 2089
		if not rootSession then -- 2089
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2089
		end -- 2089
		local spawnInfo = getSessionSpawnInfo(session) -- 2093
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2094
		local finishedAtTs = now() -- 2095
		local resultText = sanitizeUTF8(message) -- 2096
		local changeSet = getTaskChangeSetSummary(taskId) -- 2097
		local record = { -- 2098
			sessionId = session.id, -- 2099
			rootSessionId = rootSessionId, -- 2100
			parentSessionId = session.parentSessionId, -- 2101
			title = session.title, -- 2102
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2103
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2104
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2105
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2106
			status = success and "DONE" or "FAILED", -- 2107
			success = success, -- 2108
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2109
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2110
			sourceTaskId = taskId, -- 2111
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2112
			finishedAt = finishedAt, -- 2113
			createdAtTs = session.createdAt, -- 2114
			finishedAtTs = finishedAtTs, -- 2115
			changeSet = changeSet -- 2116
		} -- 2116
		if record.success then -- 2116
			local memoryEntryResult = __TS__Await(generateSubAgentMemoryEntry(session, record, resultText)) -- 2119
			record.memoryEntry = memoryEntryResult.entry -- 2120
			if memoryEntryResult.error and memoryEntryResult.error ~= "" then -- 2120
				record.memoryEntryError = memoryEntryResult.error -- 2122
				Log( -- 2123
					"Warn", -- 2123
					(("[AgentSession] sub session memory entry failed session=" .. tostring(session.id)) .. " error=") .. memoryEntryResult.error -- 2123
				) -- 2123
			end -- 2123
		end -- 2123
		if not writeSubAgentResultFile(session, record, resultText) then -- 2123
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2123
		end -- 2123
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2123
			sessionId = record.sessionId, -- 2130
			rootSessionId = record.rootSessionId, -- 2131
			parentSessionId = record.parentSessionId, -- 2132
			title = record.title, -- 2133
			prompt = record.prompt, -- 2134
			goal = record.goal, -- 2135
			expectedOutput = record.expectedOutput or "", -- 2136
			filesHint = record.filesHint or ({}), -- 2137
			status = record.status, -- 2138
			success = record.success, -- 2139
			resultFilePath = record.resultFilePath, -- 2140
			artifactDir = record.artifactDir, -- 2141
			sourceTaskId = record.sourceTaskId, -- 2142
			createdAt = record.createdAt, -- 2143
			finishedAt = record.finishedAt, -- 2144
			createdAtTs = record.createdAtTs, -- 2145
			finishedAtTs = record.finishedAtTs, -- 2146
			changeSet = record.changeSet, -- 2147
			memoryEntry = record.memoryEntry, -- 2148
			memoryEntryError = record.memoryEntryError -- 2149
		}) then -- 2149
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2149
		end -- 2149
		if success then -- 2149
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2154
			deleteSessionRecords(session.id, true) -- 2155
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2156
		end -- 2156
		return ____awaiter_resolve(nil, {success = true}) -- 2156
	end) -- 2156
end -- 2156
function stopClearedSubSession(session, taskId) -- 2161
	local spawnInfo = getSessionSpawnInfo(session) -- 2162
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2163
	local rootSessionId = getSessionRootId(session) -- 2164
	Tools.setTaskStatus(taskId, "STOPPED") -- 2165
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2166
	if not writeSpawnInfo( -- 2166
		session.projectRoot, -- 2167
		session.memoryScope, -- 2167
		{ -- 2167
			sessionId = session.id, -- 2168
			rootSessionId = rootSessionId, -- 2169
			parentSessionId = session.parentSessionId, -- 2170
			title = session.title, -- 2171
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2172
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2173
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2174
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2175
			status = "STOPPED", -- 2176
			success = false, -- 2177
			cleared = true, -- 2178
			resultFilePath = "", -- 2179
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2180
			sourceTaskId = taskId, -- 2181
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2182
			finishedAt = finishedAt, -- 2183
			createdAtTs = session.createdAt, -- 2184
			finishedAtTs = now() -- 2185
		} -- 2185
	) then -- 2185
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2187
	end -- 2187
	deleteSessionRecords(session.id, true) -- 2189
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2190
	return {success = true} -- 2191
end -- 2191
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 2194
	if allowSubSessionStart == nil then -- 2194
		allowSubSessionStart = false -- 2194
	end -- 2194
	local session = getSessionItem(sessionId) -- 2195
	if not session then -- 2195
		return {success = false, message = "session not found"} -- 2197
	end -- 2197
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2197
		return {success = false, message = "session task is finalizing"} -- 2200
	end -- 2200
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2200
		return {success = false, message = "session task is still running"} -- 2203
	end -- 2203
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2205
	if normalizedPrompt == "" and session.kind == "sub" then -- 2205
		local spawnInfo = getSessionSpawnInfo(session) -- 2207
		if spawnInfo then -- 2207
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2209
			if normalizedPrompt == "" then -- 2209
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2211
			end -- 2211
		end -- 2211
	end -- 2211
	if normalizedPrompt == "" then -- 2211
		return {success = false, message = "prompt is empty"} -- 2220
	end -- 2220
	return startPromptTask(session, normalizedPrompt) -- 2222
end -- 2194
function startPromptTask(session, normalizedPrompt, existingUserMessageId) -- 2225
	local taskRes = Tools.createTask(normalizedPrompt) -- 2226
	if not taskRes.success then -- 2226
		return {success = false, message = taskRes.message} -- 2228
	end -- 2228
	local taskId = taskRes.taskId -- 2230
	local useChineseResponse = getDefaultUseChineseResponse() -- 2231
	if existingUserMessageId ~= nil then -- 2231
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2233
	else -- 2233
		insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2235
	end -- 2235
	local stopToken = {stopped = false} -- 2237
	activeStopTokens[taskId] = stopToken -- 2238
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2239
	runCodingAgent( -- 2240
		{ -- 2240
			prompt = normalizedPrompt, -- 2241
			workDir = session.projectRoot, -- 2242
			useChineseResponse = useChineseResponse, -- 2243
			taskId = taskId, -- 2244
			sessionId = session.id, -- 2245
			memoryScope = session.memoryScope, -- 2246
			role = session.kind, -- 2247
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2248
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2251
			stopToken = stopToken, -- 2254
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2255
		}, -- 2255
		function(result) -- 2256
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2256
				local nextSession = getSessionItem(session.id) -- 2257
				if nextSession and nextSession.kind == "sub" then -- 2257
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2257
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2260
						if not stopped.success then -- 2260
							Log( -- 2262
								"Warn", -- 2262
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2262
							) -- 2262
							emitAgentSessionPatch( -- 2263
								session.id, -- 2263
								{session = getSessionItem(session.id)} -- 2263
							) -- 2263
						end -- 2263
						activeStopTokens[taskId] = nil -- 2267
						return ____awaiter_resolve(nil) -- 2267
					end -- 2267
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2270
					emitAgentSessionPatch( -- 2271
						session.id, -- 2271
						{session = getSessionItem(session.id)} -- 2271
					) -- 2271
					local finalized = __TS__Await(finalizeSubSession(nextSession, taskId, result.success, result.message)) -- 2274
					if not finalized.success then -- 2274
						Log( -- 2276
							"Warn", -- 2276
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2276
						) -- 2276
					end -- 2276
					local finalizedSession = getSessionItem(session.id) -- 2278
					if finalizedSession then -- 2278
						local stopped = stopToken.stopped == true -- 2280
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2281
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2284
						emitAgentSessionPatch( -- 2285
							session.id, -- 2285
							{session = getSessionItem(session.id)} -- 2285
						) -- 2285
					end -- 2285
					activeStopTokens[taskId] = nil -- 2289
					finalizingSubSessionTaskIds[taskId] = nil -- 2290
				end -- 2290
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2290
					applyEvent(session.id, { -- 2293
						type = "task_finished", -- 2294
						sessionId = session.id, -- 2295
						taskId = result.taskId, -- 2296
						success = false, -- 2297
						message = result.message, -- 2298
						steps = result.steps -- 2299
					}) -- 2299
				end -- 2299
			end) -- 2299
		end -- 2256
	) -- 2256
	return {success = true, sessionId = session.id, taskId = taskId} -- 2303
end -- 2303
function ____exports.listRunningSubAgents(request) -- 2390
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2390
		local session = getSessionItem(request.sessionId) -- 2398
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2398
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2400
		end -- 2400
		if not session then -- 2400
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2400
		end -- 2400
		local rootSession = getRootSessionItem(session.id) -- 2405
		if not rootSession then -- 2405
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2405
		end -- 2405
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2409
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2410
		local limit = math.max( -- 2411
			1, -- 2411
			math.floor(tonumber(request.limit) or 5) -- 2411
		) -- 2411
		local offset = math.max( -- 2412
			0, -- 2412
			math.floor(tonumber(request.offset) or 0) -- 2412
		) -- 2412
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2413
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2414
		local runningSessions = {} -- 2421
		do -- 2421
			local i = 0 -- 2422
			while i < #rows do -- 2422
				do -- 2422
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2423
					if current.currentTaskStatus ~= "RUNNING" then -- 2423
						goto __continue365 -- 2425
					end -- 2425
					local spawnInfo = getSessionSpawnInfo(current) -- 2427
					runningSessions[#runningSessions + 1] = { -- 2428
						sessionId = current.id, -- 2429
						title = current.title, -- 2430
						parentSessionId = current.parentSessionId, -- 2431
						rootSessionId = current.rootSessionId, -- 2432
						status = "RUNNING", -- 2433
						currentTaskId = current.currentTaskId, -- 2434
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2435
						goal = spawnInfo and spawnInfo.goal, -- 2436
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2437
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2438
						createdAt = current.createdAt, -- 2439
						updatedAt = current.updatedAt -- 2440
					} -- 2440
				end -- 2440
				::__continue365:: -- 2440
				i = i + 1 -- 2422
			end -- 2422
		end -- 2422
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2443
		local completedSessions = __TS__ArrayMap( -- 2444
			completedRecords, -- 2444
			function(____, record) return { -- 2444
				sessionId = record.sessionId, -- 2445
				title = record.title, -- 2446
				parentSessionId = record.parentSessionId, -- 2447
				rootSessionId = record.rootSessionId, -- 2448
				status = record.status, -- 2449
				goal = record.goal, -- 2450
				expectedOutput = record.expectedOutput, -- 2451
				filesHint = record.filesHint, -- 2452
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2453
				success = record.success, -- 2454
				cleared = record.cleared, -- 2455
				resultFilePath = record.resultFilePath, -- 2456
				artifactDir = record.artifactDir, -- 2457
				finishedAt = record.finishedAt, -- 2458
				createdAt = record.createdAtTs, -- 2459
				updatedAt = record.finishedAtTs -- 2460
			} end -- 2460
		) -- 2460
		local merged = {} -- 2462
		if status == "running" then -- 2462
			merged = runningSessions -- 2464
		elseif status == "done" then -- 2464
			merged = __TS__ArrayFilter( -- 2466
				completedSessions, -- 2466
				function(____, item) return item.status == "DONE" end -- 2466
			) -- 2466
		elseif status == "failed" then -- 2466
			merged = __TS__ArrayFilter( -- 2468
				completedSessions, -- 2468
				function(____, item) return item.status == "FAILED" end -- 2468
			) -- 2468
		elseif status == "stopped" then -- 2468
			merged = __TS__ArrayFilter( -- 2470
				completedSessions, -- 2470
				function(____, item) return item.status == "STOPPED" end -- 2470
			) -- 2470
		elseif status == "all" then -- 2470
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2472
		else -- 2472
			local runningKeys = {} -- 2474
			do -- 2474
				local i = 0 -- 2475
				while i < #runningSessions do -- 2475
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2476
					i = i + 1 -- 2475
				end -- 2475
			end -- 2475
			local latestCompletedByKey = {} -- 2478
			do -- 2478
				local i = 0 -- 2479
				while i < #completedSessions do -- 2479
					do -- 2479
						local item = completedSessions[i + 1] -- 2480
						local key = getSubAgentDisplayKey(item) -- 2481
						if runningKeys[key] then -- 2481
							goto __continue380 -- 2483
						end -- 2483
						local current = latestCompletedByKey[key] -- 2485
						if not current or item.updatedAt > current.updatedAt then -- 2485
							latestCompletedByKey[key] = item -- 2487
						end -- 2487
					end -- 2487
					::__continue380:: -- 2487
					i = i + 1 -- 2479
				end -- 2479
			end -- 2479
			local latestCompleted = {} -- 2490
			for ____, item in pairs(latestCompletedByKey) do -- 2491
				latestCompleted[#latestCompleted + 1] = item -- 2492
			end -- 2492
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2494
		end -- 2494
		if query ~= "" then -- 2494
			merged = __TS__ArrayFilter( -- 2497
				merged, -- 2497
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2497
			) -- 2497
		end -- 2497
		__TS__ArraySort( -- 2503
			merged, -- 2503
			function(____, a, b) -- 2503
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2503
					return -1 -- 2504
				end -- 2504
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2504
					return 1 -- 2505
				end -- 2505
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2505
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2507
				end -- 2507
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2509
			end -- 2503
		) -- 2503
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2511
		return ____awaiter_resolve(nil, { -- 2511
			success = true, -- 2513
			rootSessionId = rootSession.id, -- 2514
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2515
			status = status, -- 2516
			limit = limit, -- 2517
			offset = offset, -- 2518
			hasMore = offset + limit < #merged, -- 2519
			sessions = paged -- 2520
		}) -- 2520
	end) -- 2520
end -- 2390
TABLE_SESSION = "AgentSession" -- 195
TABLE_MESSAGE = "AgentSessionMessage" -- 196
TABLE_STEP = "AgentSessionStep" -- 197
TABLE_TASK = "AgentTask" -- 198
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 199
SPAWN_INFO_FILE = "SPAWN.json" -- 200
RESULT_FILE = "RESULT.md" -- 201
PENDING_HANDOFF_DIR = "pending-handoffs" -- 202
MAX_CONCURRENT_SUB_AGENTS = 4 -- 203
SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE = 0.1 -- 204
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS = 1024 -- 205
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY = 3 -- 206
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 207
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 208
SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS = 3000 -- 209
SUB_AGENT_MEMORY_RESULT_MAX_TOKENS = 2000 -- 210
SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES = 20 -- 211
SUB_AGENT_MEMORY_TAIL_MAX_TOKENS = 4000 -- 212
SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS = 600 -- 213
activeStopTokens = {} -- 259
finalizingSubSessionTaskIds = {} -- 260
now = function() return os.time() end -- 261
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 624
	if projectRoot == oldRoot then -- 624
		return newRoot -- 626
	end -- 626
	for ____, separator in ipairs({"/", "\\"}) do -- 628
		local prefix = oldRoot .. separator -- 629
		if __TS__StringStartsWith(projectRoot, prefix) then -- 629
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 631
		end -- 631
	end -- 631
	return nil -- 634
end -- 624
local function clearSessionAfterMessage(sessionId, message) -- 1276
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1277
	local removedStepIds = {} -- 1285
	do -- 1285
		local i = 0 -- 1286
		while i < #removedStepRows do -- 1286
			local row = removedStepRows[i + 1] -- 1287
			if type(row[1]) == "number" then -- 1287
				removedStepIds[#removedStepIds + 1] = row[1] -- 1289
			end -- 1289
			i = i + 1 -- 1286
		end -- 1286
	end -- 1286
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1292
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1300
	return removedStepIds -- 1305
end -- 1276
local function sanitizeStoredSteps(sessionId) -- 1459
	DB:exec( -- 1460
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1460
		{ -- 1478
			now(), -- 1478
			sessionId -- 1478
		} -- 1478
	) -- 1478
end -- 1459
local function getSchemaVersion() -- 1714
	local row = queryOne("PRAGMA user_version") -- 1715
	return row and type(row[1]) == "number" and row[1] or 0 -- 1716
end -- 1714
local function setSchemaVersion(version) -- 1719
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1720
		0, -- 1720
		math.floor(version) -- 1720
	))) -- 1720
end -- 1719
local function hasTableColumn(tableName, columnName) -- 1723
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1724
	do -- 1724
		local i = 0 -- 1725
		while i < #rows do -- 1725
			local row = rows[i + 1] -- 1726
			if toStr(row[2]) == columnName then -- 1726
				return true -- 1728
			end -- 1728
			i = i + 1 -- 1725
		end -- 1725
	end -- 1725
	return false -- 1731
end -- 1723
local function ensureSessionMetricsColumn() -- 1734
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1734
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1736
	end -- 1736
end -- 1734
local function recreateSchema() -- 1740
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1741
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1742
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1743
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1744
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1759
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1760
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1769
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1770
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1787
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1788
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1789
end -- 1740
do -- 1740
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1740
		recreateSchema() -- 1795
	else -- 1795
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1797
		ensureSessionMetricsColumn() -- 1812
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1813
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1814
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1823
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1824
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1841
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1842
	end -- 1842
end -- 1842
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1984
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1984
		return {success = false, message = "invalid projectRoot"} -- 1986
	end -- 1986
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1988
	for ____, row in ipairs(rows) do -- 1989
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1990
		if sessionId > 0 then -- 1990
			deleteSessionRecords(sessionId) -- 1992
		end -- 1992
	end -- 1992
	return {success = true, deleted = #rows} -- 1995
end -- 1984
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1998
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1998
		return {success = false, message = "invalid projectRoot"} -- 2000
	end -- 2000
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2002
	local renamed = 0 -- 2003
	for ____, row in ipairs(rows) do -- 2004
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2005
		local projectRoot = toStr(row[2]) -- 2006
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2007
		if sessionId > 0 and nextProjectRoot then -- 2007
			DB:exec( -- 2009
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2009
				{ -- 2011
					nextProjectRoot, -- 2011
					Path:getFilename(nextProjectRoot), -- 2011
					now(), -- 2011
					sessionId -- 2011
				} -- 2011
			) -- 2011
			renamed = renamed + 1 -- 2013
		end -- 2013
	end -- 2013
	return {success = true, renamed = renamed} -- 2016
end -- 1998
function ____exports.getSession(sessionId) -- 2019
	local session = getSessionItem(sessionId) -- 2020
	if not session then -- 2020
		return {success = false, message = "session not found"} -- 2022
	end -- 2022
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2024
	local relatedSessions = listRelatedSessions(sessionId) -- 2025
	sanitizeStoredSteps(sessionId) -- 2026
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2027
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2034
	local ____relatedSessions_45 = relatedSessions -- 2045
	local ____temp_44 -- 2046
	if normalizedSession.kind == "sub" then -- 2046
		____temp_44 = getSessionSpawnInfo(normalizedSession) -- 2046
	else -- 2046
		____temp_44 = nil -- 2046
	end -- 2046
	return { -- 2042
		success = true, -- 2043
		session = normalizedSession, -- 2044
		relatedSessions = ____relatedSessions_45, -- 2045
		spawnInfo = ____temp_44, -- 2046
		messages = __TS__ArrayMap( -- 2047
			messages, -- 2047
			function(____, row) return rowToMessage(row) end -- 2047
		), -- 2047
		steps = __TS__ArrayMap( -- 2048
			steps, -- 2048
			function(____, row) return rowToStep(row) end -- 2048
		), -- 2048
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 2049
	} -- 2049
end -- 2019
function ____exports.resendPrompt(sessionId, messageId, prompt) -- 2306
	local session = getSessionItem(sessionId) -- 2307
	if not session then -- 2307
		return {success = false, message = "session not found"} -- 2309
	end -- 2309
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2309
		return {success = false, message = "session task is finalizing"} -- 2312
	end -- 2312
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2312
		return {success = false, message = "session task is still running"} -- 2315
	end -- 2315
	local message = getMessageItem(messageId) -- 2317
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2317
		return {success = false, message = "message not found"} -- 2319
	end -- 2319
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2321
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2327
	if latestUserMessageId ~= messageId then -- 2327
		return {success = false, message = "only the latest user prompt can be edited"} -- 2329
	end -- 2329
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2331
	if normalizedPrompt == "" then -- 2331
		return {success = false, message = "prompt is empty"} -- 2333
	end -- 2333
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2335
	local result = startPromptTask(session, normalizedPrompt, messageId) -- 2336
	if result.success and #removedStepIds > 0 then -- 2336
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2338
	end -- 2338
	return result -- 2340
end -- 2306
function ____exports.stopSessionTask(sessionId) -- 2343
	local session = getSessionItem(sessionId) -- 2344
	if not session or session.currentTaskId == nil then -- 2344
		return {success = false, message = "session task not found"} -- 2346
	end -- 2346
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2346
		return {success = false, message = "session task is finalizing"} -- 2349
	end -- 2349
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2351
	local stopToken = activeStopTokens[session.currentTaskId] -- 2352
	if not stopToken then -- 2352
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2352
			return {success = true, recovered = true} -- 2355
		end -- 2355
		return {success = false, message = "task is not running"} -- 2357
	end -- 2357
	stopToken.stopped = true -- 2359
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2360
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2361
	return {success = true} -- 2362
end -- 2343
function ____exports.getCurrentTaskId(sessionId) -- 2365
	local ____opt_66 = getSessionItem(sessionId) -- 2365
	return ____opt_66 and ____opt_66.currentTaskId -- 2366
end -- 2365
function ____exports.listRunningSessions() -- 2369
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2370
	local sessions = {} -- 2377
	do -- 2377
		local i = 0 -- 2378
		while i < #rows do -- 2378
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2379
			if session.currentTaskStatus == "RUNNING" then -- 2379
				sessions[#sessions + 1] = session -- 2381
			end -- 2381
			i = i + 1 -- 2378
		end -- 2378
	end -- 2378
	return {success = true, sessions = sessions} -- 2384
end -- 2369
return ____exports -- 2369