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
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 640
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
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1034
			items[#items + 1] = { -- 1035
				sessionId = sessionId, -- 1036
				rootSessionId = infoRootSessionId, -- 1037
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1038
				title = sanitizeUTF8(toStr(info.title)), -- 1039
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1040
				goal = sanitizeUTF8(toStr(info.goal)), -- 1041
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1042
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1043
					__TS__ArrayFilter( -- 1044
						info.filesHint, -- 1044
						function(____, item) return type(item) == "string" end -- 1044
					), -- 1044
					function(____, item) return sanitizeUTF8(item) end -- 1044
				) or ({}), -- 1044
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1046
				success = info.success == true, -- 1047
				cleared = info.cleared == true, -- 1048
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1049
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1050
					"subagents", -- 1050
					Path:getFilename(path) -- 1050
				)), -- 1050
				sourceTaskId = sourceTaskId or 0, -- 1051
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1052
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1053
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1054
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1055
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1056
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1057
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1058
			} -- 1058
		end -- 1058
		::__continue172:: -- 1058
	end -- 1058
	__TS__ArraySort( -- 1061
		items, -- 1061
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1061
	) -- 1061
	return items -- 1062
end -- 1062
function getPendingHandoffDir(projectRoot, memoryScope) -- 1065
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1066
end -- 1066
function writePendingHandoff(projectRoot, memoryScope, value) -- 1069
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1070
	if not Content:exist(dir) then -- 1070
		ensureDirRecursive(dir) -- 1072
	end -- 1072
	local path = Path(dir, value.id .. ".json") -- 1074
	local text = safeJsonEncode(value) -- 1075
	if not text then -- 1075
		return false -- 1076
	end -- 1076
	return Content:save(path, text .. "\n") -- 1077
end -- 1077
function listPendingHandoffs(projectRoot, memoryScope) -- 1080
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1081
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1081
		return {} -- 1082
	end -- 1082
	local items = {} -- 1083
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1084
		do -- 1084
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1085
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1085
				goto __continue187 -- 1086
			end -- 1086
			local text = Content:load(path) -- 1087
			if not text or __TS__StringTrim(text) == "" then -- 1087
				goto __continue187 -- 1088
			end -- 1088
			local obj = safeJsonDecode(text) -- 1089
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1089
				goto __continue187 -- 1090
			end -- 1090
			local value = obj -- 1091
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1092
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1093
			local id = sanitizeUTF8(toStr(value.id)) -- 1094
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1095
			local message = sanitizeUTF8(toStr(value.message)) -- 1096
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1097
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1098
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1099
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1099
				goto __continue187 -- 1101
			end -- 1101
			items[#items + 1] = { -- 1103
				id = id, -- 1104
				sourceSessionId = sourceSessionId, -- 1105
				sourceTitle = sourceTitle, -- 1106
				sourceTaskId = sourceTaskId, -- 1107
				message = message, -- 1108
				prompt = prompt, -- 1109
				goal = goal, -- 1110
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1111
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1112
					__TS__ArrayFilter( -- 1113
						value.filesHint, -- 1113
						function(____, item) return type(item) == "string" end -- 1113
					), -- 1113
					function(____, item) return sanitizeUTF8(item) end -- 1113
				) or ({}), -- 1113
				success = value.success == true, -- 1115
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1116
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1117
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1118
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1119
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1120
				createdAt = createdAt -- 1121
			} -- 1121
		end -- 1121
		::__continue187:: -- 1121
	end -- 1121
	__TS__ArraySort( -- 1124
		items, -- 1124
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1124
	) -- 1124
	return items -- 1125
end -- 1125
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1128
	local path = Path( -- 1129
		getPendingHandoffDir(projectRoot, memoryScope), -- 1129
		id .. ".json" -- 1129
	) -- 1129
	if Content:exist(path) then -- 1129
		Content:remove(path) -- 1131
	end -- 1131
end -- 1131
function normalizePromptText(prompt) -- 1135
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1136
end -- 1136
function normalizePromptTextSafe(prompt) -- 1139
	if type(prompt) == "string" then -- 1139
		local normalized = normalizePromptText(prompt) -- 1141
		if normalized ~= "" then -- 1141
			return normalized -- 1142
		end -- 1142
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1143
		if sanitized ~= "" then -- 1143
			return truncateAgentUserPrompt(sanitized) -- 1145
		end -- 1145
		return "" -- 1147
	end -- 1147
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1149
	if text == "" then -- 1149
		return "" -- 1150
	end -- 1150
	return truncateAgentUserPrompt(text) -- 1151
end -- 1151
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1154
	local sections = {} -- 1155
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1156
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1157
	local normalizedFiles = __TS__ArrayFilter( -- 1158
		__TS__ArrayMap( -- 1158
			__TS__ArrayFilter( -- 1158
				filesHint or ({}), -- 1158
				function(____, item) return type(item) == "string" end -- 1159
			), -- 1159
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1160
		), -- 1160
		function(____, item) return item ~= "" end -- 1161
	) -- 1161
	if normalizedTitle ~= "" then -- 1161
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1163
	end -- 1163
	if normalizedExpected ~= "" then -- 1163
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1166
	end -- 1166
	if #normalizedFiles > 0 then -- 1166
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1169
	end -- 1169
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1171
end -- 1171
function normalizeSessionRuntimeState(session) -- 1174
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1174
		return session -- 1176
	end -- 1176
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1176
		return session -- 1179
	end -- 1179
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1181
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1182
	return __TS__ObjectAssign( -- 1183
		{}, -- 1183
		session, -- 1184
		{ -- 1183
			status = "STOPPED", -- 1185
			currentTaskStatus = "STOPPED", -- 1186
			updatedAt = now() -- 1187
		} -- 1187
	) -- 1187
end -- 1187
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1191
	DB:exec( -- 1192
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1192
		{ -- 1196
			status, -- 1197
			currentTaskId or 0, -- 1198
			currentTaskStatus or status, -- 1199
			now(), -- 1200
			sessionId -- 1201
		} -- 1201
	) -- 1201
end -- 1201
function mergeAgentMetrics(current, next) -- 1206
	return __TS__ObjectAssign({}, current or ({}), next) -- 1207
end -- 1207
function updateSessionMetrics(sessionId, metrics) -- 1213
	local session = getSessionItem(sessionId) -- 1214
	if not session then -- 1214
		return nil -- 1215
	end -- 1215
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1216
	DB:exec( -- 1217
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1217
		{ -- 1221
			encodeJson(merged), -- 1222
			now(), -- 1223
			sessionId -- 1224
		} -- 1224
	) -- 1224
	return merged -- 1227
end -- 1227
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1230
	if taskId == nil or taskId <= 0 then -- 1230
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1232
		return -- 1233
	end -- 1233
	local row = getSessionRow(sessionId) -- 1235
	if not row then -- 1235
		return -- 1236
	end -- 1236
	local session = rowToSession(row) -- 1237
	if session.currentTaskId ~= taskId then -- 1237
		Log( -- 1239
			"Info", -- 1239
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1239
		) -- 1239
		return -- 1240
	end -- 1240
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1242
end -- 1242
function insertMessage(sessionId, role, content, taskId) -- 1245
	local t = now() -- 1246
	DB:exec( -- 1247
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1247
		{ -- 1250
			sessionId, -- 1251
			taskId or 0, -- 1252
			role, -- 1253
			sanitizeUTF8(content), -- 1254
			t, -- 1255
			t -- 1256
		} -- 1256
	) -- 1256
	return getLastInsertRowId() -- 1259
end -- 1259
function updateMessage(messageId, content) -- 1262
	DB:exec( -- 1263
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1263
		{ -- 1265
			sanitizeUTF8(content), -- 1265
			now(), -- 1265
			messageId -- 1265
		} -- 1265
	) -- 1265
end -- 1265
function updateUserMessageForTask(messageId, content, taskId) -- 1269
	DB:exec( -- 1270
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1270
		{ -- 1274
			sanitizeUTF8(content), -- 1274
			taskId, -- 1274
			now(), -- 1274
			messageId -- 1274
		} -- 1274
	) -- 1274
end -- 1274
function upsertAssistantMessage(sessionId, taskId, content) -- 1310
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1311
	if row and type(row[1]) == "number" then -- 1311
		updateMessage(row[1], content) -- 1318
		return row[1] -- 1319
	end -- 1319
	return insertMessage(sessionId, "assistant", content, taskId) -- 1321
end -- 1321
function upsertStep(sessionId, taskId, step, tool, patch) -- 1324
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1334
	local reason = sanitizeUTF8(patch.reason or "") -- 1338
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1339
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1340
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1341
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1342
	local statusPatch = patch.status or "" -- 1343
	local status = patch.status or "PENDING" -- 1344
	if not row then -- 1344
		local t = now() -- 1346
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1347
			sessionId, -- 1351
			taskId, -- 1352
			step, -- 1353
			tool, -- 1354
			status, -- 1355
			reason, -- 1356
			reasoningContent, -- 1357
			paramsJson, -- 1358
			resultJson, -- 1359
			patch.checkpointId or 0, -- 1360
			patch.checkpointSeq or 0, -- 1361
			filesJson, -- 1362
			t, -- 1363
			t -- 1364
		}) -- 1364
		return -- 1367
	end -- 1367
	DB:exec( -- 1369
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1369
		{ -- 1381
			tool, -- 1382
			statusPatch, -- 1383
			status, -- 1384
			reason, -- 1385
			reason, -- 1386
			reasoningContent, -- 1387
			reasoningContent, -- 1388
			paramsJson, -- 1389
			paramsJson, -- 1390
			resultJson, -- 1391
			resultJson, -- 1392
			patch.checkpointId or 0, -- 1393
			patch.checkpointId or 0, -- 1394
			patch.checkpointSeq or 0, -- 1395
			patch.checkpointSeq or 0, -- 1396
			filesJson, -- 1397
			filesJson, -- 1398
			now(), -- 1399
			row[1] -- 1400
		} -- 1400
	) -- 1400
end -- 1400
function getNextStepNumber(sessionId, taskId) -- 1405
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1406
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1410
	return math.max(0, current) + 1 -- 1411
end -- 1411
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1414
	if status == nil then -- 1414
		status = "DONE" -- 1422
	end -- 1422
	local step = getNextStepNumber(sessionId, taskId) -- 1424
	upsertStep( -- 1425
		sessionId, -- 1425
		taskId, -- 1425
		step, -- 1425
		tool, -- 1425
		{status = status, reason = reason, params = params, result = result} -- 1425
	) -- 1425
	return getStepItem(sessionId, taskId, step) -- 1431
end -- 1431
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1434
	if taskId <= 0 then -- 1434
		return -- 1435
	end -- 1435
	if finalSteps ~= nil and finalSteps >= 0 then -- 1435
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1437
	end -- 1437
	if not finalStatus then -- 1437
		return -- 1443
	end -- 1443
	if finalSteps ~= nil and finalSteps >= 0 then -- 1443
		DB:exec( -- 1445
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1445
			{ -- 1449
				finalStatus, -- 1449
				now(), -- 1449
				sessionId, -- 1449
				taskId, -- 1449
				finalSteps -- 1449
			} -- 1449
		) -- 1449
		return -- 1451
	end -- 1451
	DB:exec( -- 1453
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1453
		{ -- 1457
			finalStatus, -- 1457
			now(), -- 1457
			sessionId, -- 1457
			taskId -- 1457
		} -- 1457
	) -- 1457
end -- 1457
function emitAgentSessionPatch(sessionId, patch) -- 1484
	if HttpServer.wsConnectionCount == 0 then -- 1484
		return -- 1486
	end -- 1486
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1488
	if not text then -- 1488
		return -- 1493
	end -- 1493
	emit("AppWS", "Send", text) -- 1494
end -- 1494
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1497
	emitAgentSessionPatch( -- 1498
		sessionId, -- 1498
		{ -- 1498
			sessionDeleted = true, -- 1499
			relatedSessions = listRelatedSessions(rootSessionId) -- 1500
		} -- 1500
	) -- 1500
	local rootSession = getSessionItem(rootSessionId) -- 1502
	if rootSession then -- 1502
		emitAgentSessionPatch( -- 1504
			rootSessionId, -- 1504
			{ -- 1504
				session = rootSession, -- 1505
				relatedSessions = listRelatedSessions(rootSessionId) -- 1506
			} -- 1506
		) -- 1506
	end -- 1506
end -- 1506
function flushPendingSubAgentHandoffs(rootSession) -- 1511
	if rootSession.kind ~= "main" then -- 1511
		return -- 1512
	end -- 1512
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1512
		return -- 1514
	end -- 1514
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1516
	if #items == 0 then -- 1516
		return -- 1517
	end -- 1517
	local handoffTaskId = 0 -- 1518
	local ____rootSession_currentTaskId_30 -- 1519
	if rootSession.currentTaskId then -- 1519
		____rootSession_currentTaskId_30 = getTaskPrompt(rootSession.currentTaskId) -- 1519
	else -- 1519
		____rootSession_currentTaskId_30 = nil -- 1519
	end -- 1519
	local currentTaskPrompt = ____rootSession_currentTaskId_30 -- 1519
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1519
		handoffTaskId = rootSession.currentTaskId -- 1527
	else -- 1527
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1529
		if not taskRes.success then -- 1529
			Log( -- 1531
				"Warn", -- 1531
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1531
			) -- 1531
			return -- 1532
		end -- 1532
		handoffTaskId = taskRes.taskId -- 1534
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1535
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1536
		emitAgentSessionPatch( -- 1537
			rootSession.id, -- 1537
			{session = getSessionItem(rootSession.id)} -- 1537
		) -- 1537
	end -- 1537
	do -- 1537
		local i = 0 -- 1541
		while i < #items do -- 1541
			local item = items[i + 1] -- 1542
			local step = appendSystemStep( -- 1543
				rootSession.id, -- 1544
				handoffTaskId, -- 1545
				"sub_agent_handoff", -- 1546
				"sub_agent_handoff", -- 1547
				item.message, -- 1548
				{ -- 1549
					sourceSessionId = item.sourceSessionId, -- 1550
					sourceTitle = item.sourceTitle, -- 1551
					sourceTaskId = item.sourceTaskId, -- 1552
					success = item.success == true, -- 1553
					summary = item.message, -- 1554
					resultFilePath = item.resultFilePath or "", -- 1555
					artifactDir = item.artifactDir or "", -- 1556
					finishedAt = item.finishedAt or "", -- 1557
					changeSet = item.changeSet, -- 1558
					memoryEntry = item.memoryEntry -- 1559
				}, -- 1559
				{ -- 1561
					sourceSessionId = item.sourceSessionId, -- 1562
					sourceTitle = item.sourceTitle, -- 1563
					sourceTaskId = item.sourceTaskId, -- 1564
					prompt = item.prompt, -- 1565
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1566
					expectedOutput = item.expectedOutput or "", -- 1567
					filesHint = item.filesHint or ({}), -- 1568
					resultFilePath = item.resultFilePath or "", -- 1569
					artifactDir = item.artifactDir or "", -- 1570
					changeSet = item.changeSet, -- 1571
					memoryEntry = item.memoryEntry -- 1572
				}, -- 1572
				"DONE" -- 1574
			) -- 1574
			if step then -- 1574
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1577
			end -- 1577
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1579
			i = i + 1 -- 1541
		end -- 1541
	end -- 1541
end -- 1541
function applyEvent(sessionId, event) -- 1591
	repeat -- 1591
		local ____switch257 = event.type -- 1591
		local ____cond257 = ____switch257 == "task_started" -- 1591
		if ____cond257 then -- 1591
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1594
			emitAgentSessionPatch( -- 1595
				sessionId, -- 1595
				{session = getSessionItem(sessionId)} -- 1595
			) -- 1595
			break -- 1598
		end -- 1598
		____cond257 = ____cond257 or ____switch257 == "decision_made" -- 1598
		if ____cond257 then -- 1598
			upsertStep( -- 1600
				sessionId, -- 1600
				event.taskId, -- 1600
				event.step, -- 1600
				event.tool, -- 1600
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1600
			) -- 1600
			emitAgentSessionPatch( -- 1606
				sessionId, -- 1606
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1606
			) -- 1606
			break -- 1609
		end -- 1609
		____cond257 = ____cond257 or ____switch257 == "tool_started" -- 1609
		if ____cond257 then -- 1609
			upsertStep( -- 1611
				sessionId, -- 1611
				event.taskId, -- 1611
				event.step, -- 1611
				event.tool, -- 1611
				{status = "RUNNING"} -- 1611
			) -- 1611
			emitAgentSessionPatch( -- 1614
				sessionId, -- 1614
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1614
			) -- 1614
			break -- 1617
		end -- 1617
		____cond257 = ____cond257 or ____switch257 == "tool_finished" -- 1617
		if ____cond257 then -- 1617
			upsertStep( -- 1619
				sessionId, -- 1619
				event.taskId, -- 1619
				event.step, -- 1619
				event.tool, -- 1619
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1619
			) -- 1619
			emitAgentSessionPatch( -- 1624
				sessionId, -- 1624
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1624
			) -- 1624
			break -- 1627
		end -- 1627
		____cond257 = ____cond257 or ____switch257 == "checkpoint_created" -- 1627
		if ____cond257 then -- 1627
			upsertStep( -- 1629
				sessionId, -- 1629
				event.taskId, -- 1629
				event.step, -- 1629
				event.tool, -- 1629
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1629
			) -- 1629
			emitAgentSessionPatch( -- 1634
				sessionId, -- 1634
				{ -- 1634
					step = getStepItem(sessionId, event.taskId, event.step), -- 1635
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1636
				} -- 1636
			) -- 1636
			break -- 1638
		end -- 1638
		____cond257 = ____cond257 or ____switch257 == "memory_compression_started" -- 1638
		if ____cond257 then -- 1638
			upsertStep( -- 1640
				sessionId, -- 1640
				event.taskId, -- 1640
				event.step, -- 1640
				event.tool, -- 1640
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1640
			) -- 1640
			emitAgentSessionPatch( -- 1645
				sessionId, -- 1645
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1645
			) -- 1645
			break -- 1648
		end -- 1648
		____cond257 = ____cond257 or ____switch257 == "memory_compression_finished" -- 1648
		if ____cond257 then -- 1648
			upsertStep( -- 1650
				sessionId, -- 1650
				event.taskId, -- 1650
				event.step, -- 1650
				event.tool, -- 1650
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1650
			) -- 1650
			emitAgentSessionPatch( -- 1655
				sessionId, -- 1655
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1655
			) -- 1655
			break -- 1658
		end -- 1658
		____cond257 = ____cond257 or ____switch257 == "metrics_updated" -- 1658
		if ____cond257 then -- 1658
			do -- 1658
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1660
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1661
				break -- 1664
			end -- 1664
		end -- 1664
		____cond257 = ____cond257 or ____switch257 == "assistant_message_updated" -- 1664
		if ____cond257 then -- 1664
			do -- 1664
				upsertStep( -- 1667
					sessionId, -- 1667
					event.taskId, -- 1667
					event.step, -- 1667
					"message", -- 1667
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1667
				) -- 1667
				emitAgentSessionPatch( -- 1672
					sessionId, -- 1672
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1672
				) -- 1672
				break -- 1675
			end -- 1675
		end -- 1675
		____cond257 = ____cond257 or ____switch257 == "task_finished" -- 1675
		if ____cond257 then -- 1675
			do -- 1675
				local ____opt_31 = activeStopTokens[event.taskId or -1] -- 1675
				local stopped = (____opt_31 and ____opt_31.stopped) == true -- 1678
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1679
				local session = getSessionItem(sessionId) -- 1682
				local isSubSession = (session and session.kind) == "sub" -- 1683
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1684
				if isSubSession and event.taskId ~= nil then -- 1684
					finalizingSubSessionTaskIds[event.taskId] = true -- 1686
				end -- 1686
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1688
				if event.taskId ~= nil then -- 1688
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1690
					local ____finalizeTaskSteps_37 = finalizeTaskSteps -- 1691
					local ____array_36 = __TS__SparseArrayNew( -- 1691
						sessionId, -- 1692
						event.taskId, -- 1693
						type(event.steps) == "number" and math.max( -- 1694
							0, -- 1694
							math.floor(event.steps) -- 1694
						) or nil -- 1694
					) -- 1694
					local ____event_success_35 -- 1695
					if event.success then -- 1695
						____event_success_35 = nil -- 1695
					else -- 1695
						____event_success_35 = stopped and "STOPPED" or "FAILED" -- 1695
					end -- 1695
					__TS__SparseArrayPush(____array_36, ____event_success_35) -- 1695
					____finalizeTaskSteps_37(__TS__SparseArraySpread(____array_36)) -- 1691
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1697
					if not isSubSession then -- 1697
						__TS__Delete(activeStopTokens, event.taskId) -- 1699
					end -- 1699
					emitAgentSessionPatch( -- 1701
						sessionId, -- 1701
						{ -- 1701
							session = getSessionItem(sessionId), -- 1702
							message = getMessageItem(messageId), -- 1703
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1704
							removedStepIds = removedStepIds -- 1705
						} -- 1705
					) -- 1705
				end -- 1705
				if session and session.kind == "main" then -- 1705
					flushPendingSubAgentHandoffs(session) -- 1709
				end -- 1709
				break -- 1711
			end -- 1711
		end -- 1711
	until true -- 1711
end -- 1711
function ____exports.createSession(projectRoot, title) -- 1848
	if title == nil then -- 1848
		title = "" -- 1848
	end -- 1848
	if not isValidProjectRoot(projectRoot) then -- 1848
		return {success = false, message = "invalid projectRoot"} -- 1850
	end -- 1850
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1852
	if row then -- 1852
		return { -- 1861
			success = true, -- 1861
			session = rowToSession(row) -- 1861
		} -- 1861
	end -- 1861
	local t = now() -- 1863
	DB:exec( -- 1864
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1864
		{ -- 1867
			projectRoot, -- 1867
			title ~= "" and title or Path:getFilename(projectRoot), -- 1867
			t, -- 1867
			t -- 1867
		} -- 1867
	) -- 1867
	local sessionId = getLastInsertRowId() -- 1869
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1870
	local session = getSessionItem(sessionId) -- 1871
	if not session then -- 1871
		return {success = false, message = "failed to create session"} -- 1873
	end -- 1873
	return {success = true, session = session} -- 1875
end -- 1848
function ____exports.createSubSession(parentSessionId, title) -- 1878
	if title == nil then -- 1878
		title = "" -- 1878
	end -- 1878
	local parent = getSessionItem(parentSessionId) -- 1879
	if not parent then -- 1879
		return {success = false, message = "parent session not found"} -- 1881
	end -- 1881
	local rootId = getSessionRootId(parent) -- 1883
	local t = now() -- 1884
	DB:exec( -- 1885
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1885
		{ -- 1888
			parent.projectRoot, -- 1888
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1888
			rootId, -- 1888
			parent.id, -- 1888
			t, -- 1888
			t -- 1888
		} -- 1888
	) -- 1888
	local sessionId = getLastInsertRowId() -- 1890
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1891
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1892
	local session = getSessionItem(sessionId) -- 1893
	if not session then -- 1893
		return {success = false, message = "failed to create sub session"} -- 1895
	end -- 1895
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1897
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1898
	subStorage:writeMemory(parentStorage:readMemory()) -- 1899
	return {success = true, session = session} -- 1900
end -- 1878
function spawnSubAgentSession(request) -- 1903
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1903
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1914
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1915
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1916
		if normalizedPrompt == "" then -- 1916
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1918
		end -- 1918
		if normalizedPrompt == "" then -- 1918
			local ____Log_43 = Log -- 1925
			local ____temp_40 = #normalizedTitle -- 1925
			local ____temp_41 = #rawPrompt -- 1925
			local ____temp_42 = #toStr(request.expectedOutput) -- 1925
			local ____opt_38 = request.filesHint -- 1925
			____Log_43( -- 1925
				"Warn", -- 1925
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_40)) .. " raw_prompt_len=") .. tostring(____temp_41)) .. " expected_len=") .. tostring(____temp_42)) .. " files_hint_count=") .. tostring(____opt_38 and #____opt_38 or 0) -- 1925
			) -- 1925
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1925
		end -- 1925
		Log( -- 1928
			"Info", -- 1928
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1928
		) -- 1928
		local parentSessionId = request.parentSessionId -- 1929
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1929
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1931
			if not fallbackParent then -- 1931
				local createdMain = ____exports.createSession(request.projectRoot) -- 1933
				if createdMain.success then -- 1933
					fallbackParent = createdMain.session -- 1935
				end -- 1935
			end -- 1935
			if fallbackParent then -- 1935
				Log( -- 1939
					"Warn", -- 1939
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1939
				) -- 1939
				parentSessionId = fallbackParent.id -- 1940
			end -- 1940
		end -- 1940
		local parentSession = getSessionItem(parentSessionId) -- 1943
		if not parentSession then -- 1943
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1943
		end -- 1943
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1947
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1947
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1947
		end -- 1947
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1951
		if not created.success then -- 1951
			return ____awaiter_resolve(nil, created) -- 1951
		end -- 1951
		writeSpawnInfo( -- 1955
			created.session.projectRoot, -- 1955
			created.session.memoryScope, -- 1955
			{ -- 1955
				sessionId = created.session.id, -- 1956
				rootSessionId = created.session.rootSessionId, -- 1957
				parentSessionId = created.session.parentSessionId, -- 1958
				title = created.session.title, -- 1959
				prompt = normalizedPrompt, -- 1960
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1961
				expectedOutput = request.expectedOutput or "", -- 1962
				filesHint = request.filesHint or ({}), -- 1963
				status = "RUNNING", -- 1964
				success = false, -- 1965
				resultFilePath = "", -- 1966
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1967
				sourceTaskId = 0, -- 1968
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1969
				createdAtTs = created.session.createdAt, -- 1970
				finishedAt = "", -- 1971
				finishedAtTs = 0 -- 1972
			} -- 1972
		) -- 1972
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1974
		if not sent.success then -- 1974
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1974
		end -- 1974
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1974
	end) -- 1974
end -- 1974
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2055
	local rootSession = getRootSessionItem(session.id) -- 2056
	if not rootSession then -- 2056
		return -- 2057
	end -- 2057
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2058
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2059
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2060
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2061
	local queueResult = writePendingHandoff( -- 2062
		rootSession.projectRoot, -- 2062
		rootSession.memoryScope, -- 2062
		{ -- 2062
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2063
			sourceSessionId = session.id, -- 2064
			sourceTitle = session.title, -- 2065
			sourceTaskId = taskId, -- 2066
			message = summary, -- 2067
			prompt = result.prompt, -- 2068
			goal = result.goal, -- 2069
			expectedOutput = result.expectedOutput or "", -- 2070
			filesHint = result.filesHint or ({}), -- 2071
			success = result.success, -- 2072
			resultFilePath = result.resultFilePath, -- 2073
			artifactDir = result.artifactDir, -- 2074
			finishedAt = result.finishedAt, -- 2075
			changeSet = changeSet, -- 2076
			memoryEntry = result.memoryEntry, -- 2077
			createdAt = createdAt -- 2078
		} -- 2078
	) -- 2078
	if not queueResult then -- 2078
		Log( -- 2081
			"Warn", -- 2081
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2081
		) -- 2081
		return -- 2082
	end -- 2082
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2082
		flushPendingSubAgentHandoffs(rootSession) -- 2085
	end -- 2085
end -- 2085
function finalizeSubSession(session, taskId, success, message) -- 2089
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2089
		local rootSessionId = getSessionRootId(session) -- 2090
		local rootSession = getRootSessionItem(session.id) -- 2091
		if not rootSession then -- 2091
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2091
		end -- 2091
		local spawnInfo = getSessionSpawnInfo(session) -- 2095
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2096
		local finishedAtTs = now() -- 2097
		local resultText = sanitizeUTF8(message) -- 2098
		local changeSet = getTaskChangeSetSummary(taskId) -- 2099
		local record = { -- 2100
			sessionId = session.id, -- 2101
			rootSessionId = rootSessionId, -- 2102
			parentSessionId = session.parentSessionId, -- 2103
			title = session.title, -- 2104
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2105
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2106
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2107
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2108
			status = success and "DONE" or "FAILED", -- 2109
			success = success, -- 2110
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2111
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2112
			sourceTaskId = taskId, -- 2113
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2114
			finishedAt = finishedAt, -- 2115
			createdAtTs = session.createdAt, -- 2116
			finishedAtTs = finishedAtTs, -- 2117
			changeSet = changeSet -- 2118
		} -- 2118
		if record.success then -- 2118
			local memoryEntryResult = __TS__Await(generateSubAgentMemoryEntry(session, record, resultText)) -- 2121
			record.memoryEntry = memoryEntryResult.entry -- 2122
			if memoryEntryResult.error and memoryEntryResult.error ~= "" then -- 2122
				record.memoryEntryError = memoryEntryResult.error -- 2124
				Log( -- 2125
					"Warn", -- 2125
					(("[AgentSession] sub session memory entry failed session=" .. tostring(session.id)) .. " error=") .. memoryEntryResult.error -- 2125
				) -- 2125
			end -- 2125
		end -- 2125
		if not writeSubAgentResultFile(session, record, resultText) then -- 2125
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2125
		end -- 2125
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2125
			sessionId = record.sessionId, -- 2132
			rootSessionId = record.rootSessionId, -- 2133
			parentSessionId = record.parentSessionId, -- 2134
			title = record.title, -- 2135
			prompt = record.prompt, -- 2136
			goal = record.goal, -- 2137
			expectedOutput = record.expectedOutput or "", -- 2138
			filesHint = record.filesHint or ({}), -- 2139
			status = record.status, -- 2140
			success = record.success, -- 2141
			resultFilePath = record.resultFilePath, -- 2142
			artifactDir = record.artifactDir, -- 2143
			sourceTaskId = record.sourceTaskId, -- 2144
			createdAt = record.createdAt, -- 2145
			finishedAt = record.finishedAt, -- 2146
			createdAtTs = record.createdAtTs, -- 2147
			finishedAtTs = record.finishedAtTs, -- 2148
			changeSet = record.changeSet, -- 2149
			memoryEntry = record.memoryEntry, -- 2150
			memoryEntryError = record.memoryEntryError -- 2151
		}) then -- 2151
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2151
		end -- 2151
		if success then -- 2151
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2156
			deleteSessionRecords(session.id, true) -- 2157
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2158
		end -- 2158
		return ____awaiter_resolve(nil, {success = true}) -- 2158
	end) -- 2158
end -- 2158
function stopClearedSubSession(session, taskId) -- 2163
	local spawnInfo = getSessionSpawnInfo(session) -- 2164
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2165
	local rootSessionId = getSessionRootId(session) -- 2166
	Tools.setTaskStatus(taskId, "STOPPED") -- 2167
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2168
	if not writeSpawnInfo( -- 2168
		session.projectRoot, -- 2169
		session.memoryScope, -- 2169
		{ -- 2169
			sessionId = session.id, -- 2170
			rootSessionId = rootSessionId, -- 2171
			parentSessionId = session.parentSessionId, -- 2172
			title = session.title, -- 2173
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2174
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2175
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2176
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2177
			status = "STOPPED", -- 2178
			success = false, -- 2179
			cleared = true, -- 2180
			resultFilePath = "", -- 2181
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2182
			sourceTaskId = taskId, -- 2183
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2184
			finishedAt = finishedAt, -- 2185
			createdAtTs = session.createdAt, -- 2186
			finishedAtTs = now() -- 2187
		} -- 2187
	) then -- 2187
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2189
	end -- 2189
	deleteSessionRecords(session.id, true) -- 2191
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2192
	return {success = true} -- 2193
end -- 2193
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 2196
	if allowSubSessionStart == nil then -- 2196
		allowSubSessionStart = false -- 2196
	end -- 2196
	local session = getSessionItem(sessionId) -- 2197
	if not session then -- 2197
		return {success = false, message = "session not found"} -- 2199
	end -- 2199
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2199
		return {success = false, message = "session task is finalizing"} -- 2202
	end -- 2202
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2202
		return {success = false, message = "session task is still running"} -- 2205
	end -- 2205
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2207
	if normalizedPrompt == "" and session.kind == "sub" then -- 2207
		local spawnInfo = getSessionSpawnInfo(session) -- 2209
		if spawnInfo then -- 2209
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2211
			if normalizedPrompt == "" then -- 2211
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2213
			end -- 2213
		end -- 2213
	end -- 2213
	if normalizedPrompt == "" then -- 2213
		return {success = false, message = "prompt is empty"} -- 2222
	end -- 2222
	return startPromptTask(session, normalizedPrompt) -- 2224
end -- 2196
function startPromptTask(session, normalizedPrompt, existingUserMessageId) -- 2227
	local taskRes = Tools.createTask(normalizedPrompt) -- 2228
	if not taskRes.success then -- 2228
		return {success = false, message = taskRes.message} -- 2230
	end -- 2230
	local taskId = taskRes.taskId -- 2232
	local useChineseResponse = getDefaultUseChineseResponse() -- 2233
	if existingUserMessageId ~= nil then -- 2233
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2235
	else -- 2235
		insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2237
	end -- 2237
	local stopToken = {stopped = false} -- 2239
	activeStopTokens[taskId] = stopToken -- 2240
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2241
	runCodingAgent( -- 2242
		{ -- 2242
			prompt = normalizedPrompt, -- 2243
			workDir = session.projectRoot, -- 2244
			useChineseResponse = useChineseResponse, -- 2245
			taskId = taskId, -- 2246
			sessionId = session.id, -- 2247
			memoryScope = session.memoryScope, -- 2248
			role = session.kind, -- 2249
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2250
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2253
			stopToken = stopToken, -- 2256
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2257
		}, -- 2257
		function(result) -- 2258
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2258
				local nextSession = getSessionItem(session.id) -- 2259
				if nextSession and nextSession.kind == "sub" then -- 2259
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2259
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2262
						if not stopped.success then -- 2262
							Log( -- 2264
								"Warn", -- 2264
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2264
							) -- 2264
							emitAgentSessionPatch( -- 2265
								session.id, -- 2265
								{session = getSessionItem(session.id)} -- 2265
							) -- 2265
						end -- 2265
						__TS__Delete(activeStopTokens, taskId) -- 2269
						return ____awaiter_resolve(nil) -- 2269
					end -- 2269
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2272
					emitAgentSessionPatch( -- 2273
						session.id, -- 2273
						{session = getSessionItem(session.id)} -- 2273
					) -- 2273
					local finalized = __TS__Await(finalizeSubSession(nextSession, taskId, result.success, result.message)) -- 2276
					if not finalized.success then -- 2276
						Log( -- 2278
							"Warn", -- 2278
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2278
						) -- 2278
					end -- 2278
					local finalizedSession = getSessionItem(session.id) -- 2280
					if finalizedSession then -- 2280
						local stopped = stopToken.stopped == true -- 2282
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2283
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2286
						emitAgentSessionPatch( -- 2287
							session.id, -- 2287
							{session = getSessionItem(session.id)} -- 2287
						) -- 2287
					end -- 2287
					__TS__Delete(activeStopTokens, taskId) -- 2291
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2292
				end -- 2292
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2292
					applyEvent(session.id, { -- 2295
						type = "task_finished", -- 2296
						sessionId = session.id, -- 2297
						taskId = result.taskId, -- 2298
						success = false, -- 2299
						message = result.message, -- 2300
						steps = result.steps -- 2301
					}) -- 2301
				end -- 2301
			end) -- 2301
		end -- 2258
	) -- 2258
	return {success = true, sessionId = session.id, taskId = taskId} -- 2305
end -- 2305
function ____exports.listRunningSubAgents(request) -- 2392
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2392
		local session = getSessionItem(request.sessionId) -- 2400
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2400
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2402
		end -- 2402
		if not session then -- 2402
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2402
		end -- 2402
		local rootSession = getRootSessionItem(session.id) -- 2407
		if not rootSession then -- 2407
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2407
		end -- 2407
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2411
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2412
		local limit = math.max( -- 2413
			1, -- 2413
			math.floor(tonumber(request.limit) or 5) -- 2413
		) -- 2413
		local offset = math.max( -- 2414
			0, -- 2414
			math.floor(tonumber(request.offset) or 0) -- 2414
		) -- 2414
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2415
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2416
		local runningSessions = {} -- 2423
		do -- 2423
			local i = 0 -- 2424
			while i < #rows do -- 2424
				do -- 2424
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2425
					if current.currentTaskStatus ~= "RUNNING" then -- 2425
						goto __continue365 -- 2427
					end -- 2427
					local spawnInfo = getSessionSpawnInfo(current) -- 2429
					runningSessions[#runningSessions + 1] = { -- 2430
						sessionId = current.id, -- 2431
						title = current.title, -- 2432
						parentSessionId = current.parentSessionId, -- 2433
						rootSessionId = current.rootSessionId, -- 2434
						status = "RUNNING", -- 2435
						currentTaskId = current.currentTaskId, -- 2436
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2437
						goal = spawnInfo and spawnInfo.goal, -- 2438
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2439
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2440
						createdAt = current.createdAt, -- 2441
						updatedAt = current.updatedAt -- 2442
					} -- 2442
				end -- 2442
				::__continue365:: -- 2442
				i = i + 1 -- 2424
			end -- 2424
		end -- 2424
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2445
		local completedSessions = __TS__ArrayMap( -- 2446
			completedRecords, -- 2446
			function(____, record) return { -- 2446
				sessionId = record.sessionId, -- 2447
				title = record.title, -- 2448
				parentSessionId = record.parentSessionId, -- 2449
				rootSessionId = record.rootSessionId, -- 2450
				status = record.status, -- 2451
				goal = record.goal, -- 2452
				expectedOutput = record.expectedOutput, -- 2453
				filesHint = record.filesHint, -- 2454
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2455
				success = record.success, -- 2456
				cleared = record.cleared, -- 2457
				resultFilePath = record.resultFilePath, -- 2458
				artifactDir = record.artifactDir, -- 2459
				finishedAt = record.finishedAt, -- 2460
				createdAt = record.createdAtTs, -- 2461
				updatedAt = record.finishedAtTs -- 2462
			} end -- 2462
		) -- 2462
		local merged = {} -- 2464
		if status == "running" then -- 2464
			merged = runningSessions -- 2466
		elseif status == "done" then -- 2466
			merged = __TS__ArrayFilter( -- 2468
				completedSessions, -- 2468
				function(____, item) return item.status == "DONE" end -- 2468
			) -- 2468
		elseif status == "failed" then -- 2468
			merged = __TS__ArrayFilter( -- 2470
				completedSessions, -- 2470
				function(____, item) return item.status == "FAILED" end -- 2470
			) -- 2470
		elseif status == "stopped" then -- 2470
			merged = __TS__ArrayFilter( -- 2472
				completedSessions, -- 2472
				function(____, item) return item.status == "STOPPED" end -- 2472
			) -- 2472
		elseif status == "all" then -- 2472
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2474
		else -- 2474
			local runningKeys = {} -- 2476
			do -- 2476
				local i = 0 -- 2477
				while i < #runningSessions do -- 2477
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2478
					i = i + 1 -- 2477
				end -- 2477
			end -- 2477
			local latestCompletedByKey = {} -- 2480
			do -- 2480
				local i = 0 -- 2481
				while i < #completedSessions do -- 2481
					do -- 2481
						local item = completedSessions[i + 1] -- 2482
						local key = getSubAgentDisplayKey(item) -- 2483
						if runningKeys[key] then -- 2483
							goto __continue380 -- 2485
						end -- 2485
						local current = latestCompletedByKey[key] -- 2487
						if not current or item.updatedAt > current.updatedAt then -- 2487
							latestCompletedByKey[key] = item -- 2489
						end -- 2489
					end -- 2489
					::__continue380:: -- 2489
					i = i + 1 -- 2481
				end -- 2481
			end -- 2481
			local latestCompleted = {} -- 2492
			for ____, item in pairs(latestCompletedByKey) do -- 2493
				latestCompleted[#latestCompleted + 1] = item -- 2494
			end -- 2494
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2496
		end -- 2496
		if query ~= "" then -- 2496
			merged = __TS__ArrayFilter( -- 2499
				merged, -- 2499
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2499
			) -- 2499
		end -- 2499
		__TS__ArraySort( -- 2505
			merged, -- 2505
			function(____, a, b) -- 2505
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2505
					return -1 -- 2506
				end -- 2506
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2506
					return 1 -- 2507
				end -- 2507
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2507
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2509
				end -- 2509
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2511
			end -- 2505
		) -- 2505
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2513
		return ____awaiter_resolve(nil, { -- 2513
			success = true, -- 2515
			rootSessionId = rootSession.id, -- 2516
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2517
			status = status, -- 2518
			limit = limit, -- 2519
			offset = offset, -- 2520
			hasMore = offset + limit < #merged, -- 2521
			sessions = paged -- 2522
		}) -- 2522
	end) -- 2522
end -- 2392
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
local function clearSessionAfterMessage(sessionId, message) -- 1278
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1279
	local removedStepIds = {} -- 1287
	do -- 1287
		local i = 0 -- 1288
		while i < #removedStepRows do -- 1288
			local row = removedStepRows[i + 1] -- 1289
			if type(row[1]) == "number" then -- 1289
				removedStepIds[#removedStepIds + 1] = row[1] -- 1291
			end -- 1291
			i = i + 1 -- 1288
		end -- 1288
	end -- 1288
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1294
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1302
	return removedStepIds -- 1307
end -- 1278
local function sanitizeStoredSteps(sessionId) -- 1461
	DB:exec( -- 1462
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1462
		{ -- 1480
			now(), -- 1480
			sessionId -- 1480
		} -- 1480
	) -- 1480
end -- 1461
local function getSchemaVersion() -- 1716
	local row = queryOne("PRAGMA user_version") -- 1717
	return row and type(row[1]) == "number" and row[1] or 0 -- 1718
end -- 1716
local function setSchemaVersion(version) -- 1721
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1722
		0, -- 1722
		math.floor(version) -- 1722
	))) -- 1722
end -- 1721
local function hasTableColumn(tableName, columnName) -- 1725
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1726
	do -- 1726
		local i = 0 -- 1727
		while i < #rows do -- 1727
			local row = rows[i + 1] -- 1728
			if toStr(row[2]) == columnName then -- 1728
				return true -- 1730
			end -- 1730
			i = i + 1 -- 1727
		end -- 1727
	end -- 1727
	return false -- 1733
end -- 1725
local function ensureSessionMetricsColumn() -- 1736
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1736
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1738
	end -- 1738
end -- 1736
local function recreateSchema() -- 1742
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1743
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1744
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1745
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1746
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1761
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1762
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1771
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1772
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1789
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1790
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1791
end -- 1742
do -- 1742
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1742
		recreateSchema() -- 1797
	else -- 1797
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1799
		ensureSessionMetricsColumn() -- 1814
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1815
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1816
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1825
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1826
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1843
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1844
	end -- 1844
end -- 1844
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1986
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1986
		return {success = false, message = "invalid projectRoot"} -- 1988
	end -- 1988
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1990
	for ____, row in ipairs(rows) do -- 1991
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1992
		if sessionId > 0 then -- 1992
			deleteSessionRecords(sessionId) -- 1994
		end -- 1994
	end -- 1994
	return {success = true, deleted = #rows} -- 1997
end -- 1986
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2000
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2000
		return {success = false, message = "invalid projectRoot"} -- 2002
	end -- 2002
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2004
	local renamed = 0 -- 2005
	for ____, row in ipairs(rows) do -- 2006
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2007
		local projectRoot = toStr(row[2]) -- 2008
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2009
		if sessionId > 0 and nextProjectRoot then -- 2009
			DB:exec( -- 2011
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2011
				{ -- 2013
					nextProjectRoot, -- 2013
					Path:getFilename(nextProjectRoot), -- 2013
					now(), -- 2013
					sessionId -- 2013
				} -- 2013
			) -- 2013
			renamed = renamed + 1 -- 2015
		end -- 2015
	end -- 2015
	return {success = true, renamed = renamed} -- 2018
end -- 2000
function ____exports.getSession(sessionId) -- 2021
	local session = getSessionItem(sessionId) -- 2022
	if not session then -- 2022
		return {success = false, message = "session not found"} -- 2024
	end -- 2024
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2026
	local relatedSessions = listRelatedSessions(sessionId) -- 2027
	sanitizeStoredSteps(sessionId) -- 2028
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2029
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2036
	local ____relatedSessions_45 = relatedSessions -- 2047
	local ____temp_44 -- 2048
	if normalizedSession.kind == "sub" then -- 2048
		____temp_44 = getSessionSpawnInfo(normalizedSession) -- 2048
	else -- 2048
		____temp_44 = nil -- 2048
	end -- 2048
	return { -- 2044
		success = true, -- 2045
		session = normalizedSession, -- 2046
		relatedSessions = ____relatedSessions_45, -- 2047
		spawnInfo = ____temp_44, -- 2048
		messages = __TS__ArrayMap( -- 2049
			messages, -- 2049
			function(____, row) return rowToMessage(row) end -- 2049
		), -- 2049
		steps = __TS__ArrayMap( -- 2050
			steps, -- 2050
			function(____, row) return rowToStep(row) end -- 2050
		), -- 2050
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 2051
	} -- 2051
end -- 2021
function ____exports.resendPrompt(sessionId, messageId, prompt) -- 2308
	local session = getSessionItem(sessionId) -- 2309
	if not session then -- 2309
		return {success = false, message = "session not found"} -- 2311
	end -- 2311
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2311
		return {success = false, message = "session task is finalizing"} -- 2314
	end -- 2314
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2314
		return {success = false, message = "session task is still running"} -- 2317
	end -- 2317
	local message = getMessageItem(messageId) -- 2319
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2319
		return {success = false, message = "message not found"} -- 2321
	end -- 2321
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2323
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2329
	if latestUserMessageId ~= messageId then -- 2329
		return {success = false, message = "only the latest user prompt can be edited"} -- 2331
	end -- 2331
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2333
	if normalizedPrompt == "" then -- 2333
		return {success = false, message = "prompt is empty"} -- 2335
	end -- 2335
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2337
	local result = startPromptTask(session, normalizedPrompt, messageId) -- 2338
	if result.success and #removedStepIds > 0 then -- 2338
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2340
	end -- 2340
	return result -- 2342
end -- 2308
function ____exports.stopSessionTask(sessionId) -- 2345
	local session = getSessionItem(sessionId) -- 2346
	if not session or session.currentTaskId == nil then -- 2346
		return {success = false, message = "session task not found"} -- 2348
	end -- 2348
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2348
		return {success = false, message = "session task is finalizing"} -- 2351
	end -- 2351
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2353
	local stopToken = activeStopTokens[session.currentTaskId] -- 2354
	if not stopToken then -- 2354
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2354
			return {success = true, recovered = true} -- 2357
		end -- 2357
		return {success = false, message = "task is not running"} -- 2359
	end -- 2359
	stopToken.stopped = true -- 2361
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2362
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2363
	return {success = true} -- 2364
end -- 2345
function ____exports.getCurrentTaskId(sessionId) -- 2367
	local ____opt_66 = getSessionItem(sessionId) -- 2367
	return ____opt_66 and ____opt_66.currentTaskId -- 2368
end -- 2367
function ____exports.listRunningSessions() -- 2371
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2372
	local sessions = {} -- 2379
	do -- 2379
		local i = 0 -- 2380
		while i < #rows do -- 2380
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2381
			if session.currentTaskStatus == "RUNNING" then -- 2381
				sessions[#sessions + 1] = session -- 2383
			end -- 2383
			i = i + 1 -- 2380
		end -- 2380
	end -- 2380
	return {success = true, sessions = sessions} -- 2386
end -- 2371
return ____exports -- 2371