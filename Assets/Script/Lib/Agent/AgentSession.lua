-- [ts]: AgentSession.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____CodingAgent = require("Agent.CodingAgent") -- 3
local runCodingAgent = ____CodingAgent.runCodingAgent -- 3
local normalizeAgentCompletionReport = ____CodingAgent.normalizeAgentCompletionReport -- 3
local truncateAgentUserPrompt = ____CodingAgent.truncateAgentUserPrompt -- 3
local AgentToolRegistry = require("Agent.AgentToolRegistry") -- 5
local Tools = require("Agent.Tools") -- 6
local ____Memory = require("Agent.Memory") -- 7
local DualLayerStorage = ____Memory.DualLayerStorage -- 7
local ____Utils = require("Agent.Utils") -- 8
local Log = ____Utils.Log -- 8
local safeJsonDecode = ____Utils.safeJsonDecode -- 8
local safeJsonEncode = ____Utils.safeJsonEncode -- 8
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 8
function getDefaultUseChineseResponse() -- 277
	local zh = string.match(App.locale, "^zh") -- 278
	return zh ~= nil -- 279
end -- 279
function toStr(v) -- 282
	if v == false or v == nil then -- 282
		return "" -- 283
	end -- 283
	return tostring(v) -- 284
end -- 284
function encodeJson(value) -- 287
	local text = safeJsonEncode(value) -- 288
	return text or "" -- 289
end -- 289
function decodeJsonObject(text) -- 292
	if not text or text == "" then -- 292
		return nil -- 293
	end -- 293
	local value = safeJsonDecode(text) -- 294
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 294
		return value -- 296
	end -- 296
	return nil -- 298
end -- 298
function decodeJsonFiles(text) -- 301
	if not text or text == "" then -- 301
		return nil -- 302
	end -- 302
	local value = safeJsonDecode(text) -- 303
	if not value or not __TS__ArrayIsArray(value) then -- 303
		return nil -- 304
	end -- 304
	local files = {} -- 305
	do -- 305
		local i = 0 -- 306
		while i < #value do -- 306
			do -- 306
				local item = value[i + 1] -- 307
				if type(item) ~= "table" then -- 307
					goto __continue14 -- 308
				end -- 308
				files[#files + 1] = { -- 309
					path = sanitizeUTF8(toStr(item.path)), -- 310
					op = sanitizeUTF8(toStr(item.op)) -- 311
				} -- 311
			end -- 311
			::__continue14:: -- 311
			i = i + 1 -- 306
		end -- 306
	end -- 306
	return files -- 314
end -- 314
function decodeChangeSetSummary(value) -- 317
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 317
		return nil -- 318
	end -- 318
	local row = value -- 319
	if row.success ~= true then -- 319
		return nil -- 320
	end -- 320
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 321
	if taskId <= 0 then -- 321
		return nil -- 322
	end -- 322
	local files = {} -- 323
	if __TS__ArrayIsArray(row.files) then -- 323
		do -- 323
			local i = 0 -- 325
			while i < #row.files do -- 325
				do -- 325
					local file = row.files[i + 1] -- 326
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 326
						goto __continue22 -- 327
					end -- 327
					local fileRow = file -- 328
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 329
					if path == "" then -- 329
						goto __continue22 -- 330
					end -- 330
					local checkpointIds = {} -- 331
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 331
						do -- 331
							local j = 0 -- 333
							while j < #fileRow.checkpointIds do -- 333
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 334
								if checkpointId > 0 then -- 334
									checkpointIds[#checkpointIds + 1] = checkpointId -- 335
								end -- 335
								j = j + 1 -- 333
							end -- 333
						end -- 333
					end -- 333
					local op = toStr(fileRow.op) -- 338
					files[#files + 1] = { -- 339
						path = path, -- 340
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 341
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 342
						checkpointIds = checkpointIds -- 343
					} -- 343
				end -- 343
				::__continue22:: -- 343
				i = i + 1 -- 325
			end -- 325
		end -- 325
	end -- 325
	return { -- 347
		success = true, -- 348
		taskId = taskId, -- 349
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 350
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 351
		files = files, -- 352
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 353
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 354
	} -- 354
end -- 354
function takeUtf8Head(text, maxChars) -- 358
	if maxChars <= 0 or text == "" then -- 358
		return "" -- 359
	end -- 359
	local nextPos = utf8.offset(text, maxChars + 1) -- 360
	if nextPos == nil then -- 360
		return text -- 361
	end -- 361
	return string.sub(text, 1, nextPos - 1) -- 362
end -- 362
function normalizeMemoryEntryEvidence(value) -- 365
	local evidence = {} -- 366
	if not __TS__ArrayIsArray(value) then -- 366
		return evidence -- 367
	end -- 367
	do -- 367
		local i = 0 -- 368
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 368
			do -- 368
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 369
				if item == "" then -- 369
					goto __continue35 -- 370
				end -- 370
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 370
					evidence[#evidence + 1] = item -- 372
				end -- 372
			end -- 372
			::__continue35:: -- 372
			i = i + 1 -- 368
		end -- 368
	end -- 368
	return evidence -- 375
end -- 375
function decodeSubAgentMemoryEntry(value) -- 378
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 378
		return nil -- 379
	end -- 379
	local row = value -- 380
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 381
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 382
	local content = takeUtf8Head( -- 383
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 383
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 383
	) -- 383
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 383
		return nil -- 384
	end -- 384
	return { -- 385
		sourceSessionId = sourceSessionId, -- 386
		sourceTaskId = sourceTaskId, -- 387
		content = content, -- 388
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 389
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 390
	} -- 390
end -- 390
function getTaskChangeSetSummary(taskId) -- 394
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 395
	return summary.success and summary or nil -- 396
end -- 396
function queryRows(sql, args) -- 399
	local ____args_0 -- 400
	if args then -- 400
		____args_0 = DB:query(sql, args) -- 400
	else -- 400
		____args_0 = DB:query(sql) -- 400
	end -- 400
	return ____args_0 -- 400
end -- 400
function queryOne(sql, args) -- 403
	local rows = queryRows(sql, args) -- 404
	if not rows or #rows == 0 then -- 404
		return nil -- 405
	end -- 405
	return rows[1] -- 406
end -- 406
function getLastInsertRowId() -- 409
	local row = queryOne("SELECT last_insert_rowid()") -- 410
	return row and (row[1] or 0) or 0 -- 411
end -- 411
function isValidProjectRoot(path) -- 414
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 415
end -- 415
function rowToSession(row) -- 418
	return { -- 419
		id = row[1], -- 420
		projectRoot = toStr(row[2]), -- 421
		title = toStr(row[3]), -- 422
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 423
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 424
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 425
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 426
		status = toStr(row[8]), -- 427
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 428
		currentTaskStatus = toStr(row[10]), -- 429
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 430
		createdAt = row[11], -- 431
		updatedAt = row[12], -- 432
		metrics = decodeJsonObject(toStr(row[13])) -- 433
	} -- 433
end -- 433
function rowToMessage(row) -- 437
	return { -- 438
		id = row[1], -- 439
		sessionId = row[2], -- 440
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 441
		role = toStr(row[4]), -- 442
		content = toStr(row[5]), -- 443
		createdAt = row[6], -- 444
		updatedAt = row[7] -- 445
	} -- 445
end -- 445
function rowToStep(row) -- 449
	return { -- 450
		id = row[1], -- 451
		sessionId = row[2], -- 452
		taskId = row[3], -- 453
		step = row[4], -- 454
		tool = toStr(row[5]), -- 455
		status = toStr(row[6]), -- 456
		reason = toStr(row[7]), -- 457
		reasoningContent = toStr(row[8]), -- 458
		params = decodeJsonObject(toStr(row[9])), -- 459
		result = decodeJsonObject(toStr(row[10])), -- 460
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 461
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 462
		files = decodeJsonFiles(toStr(row[13])), -- 463
		createdAt = row[14], -- 464
		updatedAt = row[15] -- 465
	} -- 465
end -- 465
function getMessageItem(messageId) -- 469
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 470
	return row and rowToMessage(row) or nil -- 476
end -- 476
function getStepItem(sessionId, taskId, step) -- 479
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 480
	return row and rowToStep(row) or nil -- 486
end -- 486
function deleteMessageSteps(sessionId, taskId) -- 489
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 490
	local ids = {} -- 495
	do -- 495
		local i = 0 -- 496
		while i < #rows do -- 496
			local row = rows[i + 1] -- 497
			if type(row[1]) == "number" then -- 497
				ids[#ids + 1] = row[1] -- 499
			end -- 499
			i = i + 1 -- 496
		end -- 496
	end -- 496
	if #ids > 0 then -- 496
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 503
	end -- 503
	return ids -- 509
end -- 509
function normalizeDisabledAgentTools(value) -- 512
	if not __TS__ArrayIsArray(value) then -- 512
		return {} -- 513
	end -- 513
	local tools = {} -- 514
	do -- 514
		local i = 0 -- 515
		while i < #value do -- 515
			do -- 515
				local name = value[i + 1] -- 516
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 516
					goto __continue60 -- 517
				end -- 517
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 517
					tools[#tools + 1] = name -- 518
				end -- 518
			end -- 518
			::__continue60:: -- 518
			i = i + 1 -- 515
		end -- 515
	end -- 515
	return tools -- 520
end -- 520
function getSessionRow(sessionId) -- 523
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 524
end -- 524
function getSessionItem(sessionId) -- 532
	local row = getSessionRow(sessionId) -- 533
	return row and rowToSession(row) or nil -- 534
end -- 534
function getTaskPrompt(taskId) -- 537
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 538
	if not row or type(row[1]) ~= "string" then -- 538
		return nil -- 539
	end -- 539
	return toStr(row[1]) -- 540
end -- 540
function getLatestMainSessionByProjectRoot(projectRoot) -- 543
	if not isValidProjectRoot(projectRoot) then -- 543
		return nil -- 544
	end -- 544
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 545
	return row and rowToSession(row) or nil -- 553
end -- 553
function countRunningSubSessions(rootSessionId) -- 556
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 557
	local count = 0 -- 564
	do -- 564
		local i = 0 -- 565
		while i < #rows do -- 565
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 566
			if session.currentTaskStatus == "RUNNING" then -- 566
				count = count + 1 -- 568
			end -- 568
			i = i + 1 -- 565
		end -- 565
	end -- 565
	return count -- 571
end -- 571
function deleteSessionRecords(sessionId, preserveArtifacts) -- 574
	if preserveArtifacts == nil then -- 574
		preserveArtifacts = false -- 574
	end -- 574
	local session = getSessionItem(sessionId) -- 575
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 576
	do -- 576
		local i = 0 -- 577
		while i < #children do -- 577
			local row = children[i + 1] -- 578
			if type(row[1]) == "number" and row[1] > 0 then -- 578
				deleteSessionRecords(row[1], preserveArtifacts) -- 580
			end -- 580
			i = i + 1 -- 577
		end -- 577
	end -- 577
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 583
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 584
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 585
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 586
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 586
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 588
	end -- 588
end -- 588
function getSessionRootId(session) -- 592
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 593
end -- 593
function getRootSessionItem(sessionId) -- 596
	local session = getSessionItem(sessionId) -- 597
	if not session then -- 597
		return nil -- 598
	end -- 598
	return getSessionItem(getSessionRootId(session)) or session -- 599
end -- 599
function listRelatedSessions(sessionId) -- 602
	local root = getRootSessionItem(sessionId) -- 603
	if not root then -- 603
		return {} -- 604
	end -- 604
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 605
	return __TS__ArrayMap( -- 614
		rows, -- 614
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 614
	) -- 614
end -- 614
function getSessionSpawnInfo(session) -- 617
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 618
	if not info then -- 618
		return nil -- 619
	end -- 619
	local ____temp_4 = type(info.sessionId) == "number" and info.sessionId or nil -- 621
	local ____temp_5 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 622
	local ____temp_6 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 623
	local ____temp_7 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 624
	local ____temp_8 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 625
	local ____temp_9 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 626
	local ____temp_10 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 627
	local ____temp_11 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 628
		__TS__ArrayFilter( -- 629
			info.filesHint, -- 629
			function(____, item) return type(item) == "string" end -- 629
		), -- 629
		function(____, item) return sanitizeUTF8(item) end -- 629
	) or nil -- 629
	local ____temp_12 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 631
	local ____temp_2 -- 634
	if info.success == true then -- 634
		____temp_2 = true -- 634
	else -- 634
		local ____temp_1 -- 634
		if info.success == false then -- 634
			____temp_1 = false -- 634
		else -- 634
			____temp_1 = nil -- 634
		end -- 634
		____temp_2 = ____temp_1 -- 634
	end -- 634
	local ____temp_3 -- 635
	if info.cleared == true then -- 635
		____temp_3 = true -- 635
	else -- 635
		____temp_3 = nil -- 635
	end -- 635
	return { -- 620
		sessionId = ____temp_4, -- 621
		rootSessionId = ____temp_5, -- 622
		parentSessionId = ____temp_6, -- 623
		title = ____temp_7, -- 624
		prompt = ____temp_8, -- 625
		goal = ____temp_9, -- 626
		expectedOutput = ____temp_10, -- 627
		filesHint = ____temp_11, -- 628
		status = ____temp_12, -- 631
		success = ____temp_2, -- 634
		cleared = ____temp_3, -- 635
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 636
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 637
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 638
		changeSet = decodeChangeSetSummary(info.changeSet), -- 639
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 640
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 641
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 642
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 645
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 646
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 647
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 648
	} -- 648
end -- 648
function ensureDirRecursive(dir) -- 665
	if not dir or dir == "" then -- 665
		return false -- 666
	end -- 666
	if Content:exist(dir) then -- 666
		return Content:isdir(dir) -- 667
	end -- 667
	local parent = Path:getPath(dir) -- 668
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 668
		if not ensureDirRecursive(parent) then -- 668
			return false -- 671
		end -- 671
	end -- 671
	return Content:mkdir(dir) -- 674
end -- 674
function writeSpawnInfo(projectRoot, memoryScope, value) -- 677
	local dir = Path(projectRoot, ".agent", memoryScope) -- 678
	if not Content:exist(dir) then -- 678
		ensureDirRecursive(dir) -- 680
	end -- 680
	local path = Path(dir, SPAWN_INFO_FILE) -- 682
	local text = safeJsonEncode(value) -- 683
	if not text then -- 683
		return false -- 684
	end -- 684
	local content = text .. "\n" -- 685
	if not Content:save(path, content) then -- 685
		return false -- 687
	end -- 687
	Tools.sendWebIDEFileUpdate(path, true, content) -- 689
	return true -- 690
end -- 690
function readSpawnInfo(projectRoot, memoryScope) -- 693
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 694
	if not Content:exist(path) then -- 694
		return nil -- 695
	end -- 695
	local text = Content:load(path) -- 696
	if not text or __TS__StringTrim(text) == "" then -- 696
		return nil -- 697
	end -- 697
	local value = safeJsonDecode(text) -- 698
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 698
		return value -- 700
	end -- 700
	return nil -- 702
end -- 702
function getArtifactRelativeDir(memoryScope) -- 705
	return Path(".agent", memoryScope) -- 706
end -- 706
function getArtifactDir(projectRoot, memoryScope) -- 709
	return Path( -- 710
		projectRoot, -- 710
		getArtifactRelativeDir(memoryScope) -- 710
	) -- 710
end -- 710
function getResultRelativePath(memoryScope) -- 713
	return Path( -- 714
		getArtifactRelativeDir(memoryScope), -- 714
		RESULT_FILE -- 714
	) -- 714
end -- 714
function getResultPath(projectRoot, memoryScope) -- 717
	return Path( -- 718
		projectRoot, -- 718
		getResultRelativePath(memoryScope) -- 718
	) -- 718
end -- 718
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 721
	if not resultFilePath or resultFilePath == "" then -- 721
		return "" -- 722
	end -- 722
	local path = Path(projectRoot, resultFilePath) -- 723
	if not Content:exist(path) then -- 723
		return "" -- 724
	end -- 724
	local text = sanitizeUTF8(Content:load(path)) -- 725
	if not text or __TS__StringTrim(text) == "" then -- 725
		return "" -- 726
	end -- 726
	local marker = "\n## Summary\n" -- 727
	local start = string.find(text, marker, 1, true) -- 728
	if start ~= nil then -- 728
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 730
	end -- 730
	return __TS__StringTrim(text) -- 732
end -- 732
function buildStructuredSubAgentMemoryEntry(record) -- 735
	local hasPassedValidation = false -- 736
	do -- 736
		local i = 0 -- 737
		while i < #record.completion.validation do -- 737
			local result = record.completion.validation[i + 1].result -- 738
			if result == "failed" then -- 738
				return nil -- 743
			end -- 743
			if result == "passed" then -- 743
				hasPassedValidation = true -- 745
			end -- 745
			i = i + 1 -- 737
		end -- 737
	end -- 737
	if not hasPassedValidation then -- 737
		return nil -- 748
	end -- 748
	local candidates = record.completion.learningCandidates -- 749
	local claims = {} -- 750
	local evidence = {} -- 751
	do -- 751
		local i = 0 -- 752
		while i < #candidates do -- 752
			do -- 752
				local candidate = candidates[i + 1] -- 753
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 753
					goto __continue122 -- 754
				end -- 754
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 755
				do -- 755
					local j = 0 -- 756
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 756
						local item = candidate.evidence[j + 1] -- 757
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 757
							evidence[#evidence + 1] = item -- 758
						end -- 758
						j = j + 1 -- 756
					end -- 756
				end -- 756
			end -- 756
			::__continue122:: -- 756
			i = i + 1 -- 752
		end -- 752
	end -- 752
	local content = takeUtf8Head( -- 761
		table.concat(claims, "\n"), -- 761
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 761
	) -- 761
	if content == "" then -- 761
		return nil -- 762
	end -- 762
	return { -- 763
		sourceSessionId = record.sessionId, -- 764
		sourceTaskId = record.sourceTaskId, -- 765
		content = content, -- 766
		evidence = evidence, -- 767
		createdAt = record.finishedAt -- 768
	} -- 768
end -- 768
function containsNormalizedText(text, query) -- 772
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 773
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 774
	if normalizedQuery == "" then -- 774
		return true -- 775
	end -- 775
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 776
end -- 776
function getSubAgentDisplayKey(item) -- 779
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 785
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 786
	local label = goal ~= "" and goal or title -- 787
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 788
end -- 788
function writeSubAgentResultFile(session, record, resultText) -- 791
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 792
	if not Content:exist(dir) then -- 792
		ensureDirRecursive(dir) -- 794
	end -- 794
	local ____array_13 = __TS__SparseArrayNew( -- 794
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 797
		"- Status: " .. record.status, -- 798
		"- Success: " .. (record.success and "true" or "false"), -- 799
		"- Outcome: " .. record.completion.outcome, -- 800
		"- Session ID: " .. tostring(record.sessionId), -- 801
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 802
		"- Goal: " .. record.goal, -- 803
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 804
	) -- 804
	__TS__SparseArrayPush( -- 804
		____array_13, -- 804
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 805
	) -- 805
	__TS__SparseArrayPush( -- 805
		____array_13, -- 805
		"- Finished At: " .. record.finishedAt, -- 806
		"", -- 807
		"## Validation", -- 808
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 809
			record.completion.validation, -- 810
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 810
		) or ({"- Not reported"})) -- 810
	) -- 810
	__TS__SparseArrayPush( -- 810
		____array_13, -- 810
		"", -- 812
		"## Known Issues", -- 813
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 814
			record.completion.knownIssues, -- 814
			function(____, item) return "- " .. item end -- 814
		) or ({"- None reported"})) -- 814
	) -- 814
	__TS__SparseArrayPush( -- 814
		____array_13, -- 814
		"", -- 815
		"## Assumptions", -- 816
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 817
			record.completion.assumptions, -- 817
			function(____, item) return "- " .. item end -- 817
		) or ({"- None reported"})) -- 817
	) -- 817
	__TS__SparseArrayPush(____array_13, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 817
	local lines = {__TS__SparseArraySpread(____array_13)} -- 796
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 822
	local content = table.concat(lines, "\n") .. "\n" -- 823
	if not Content:save(path, content) then -- 823
		return false -- 825
	end -- 825
	Tools.sendWebIDEFileUpdate(path, true, content) -- 827
	return true -- 828
end -- 828
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 831
	local dir = Path(projectRoot, ".agent", "subagents") -- 832
	if not Content:exist(dir) or not Content:isdir(dir) then -- 832
		return {} -- 833
	end -- 833
	local items = {} -- 834
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 835
		do -- 835
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 836
			if not Content:exist(path) or not Content:isdir(path) then -- 836
				goto __continue139 -- 837
			end -- 837
			local info = readSpawnInfo( -- 838
				projectRoot, -- 838
				Path( -- 838
					"subagents", -- 838
					Path:getFilename(path) -- 838
				) -- 838
			) -- 838
			if not info then -- 838
				goto __continue139 -- 839
			end -- 839
			local sessionId = tonumber(info.sessionId) -- 840
			local infoRootSessionId = tonumber(info.rootSessionId) -- 841
			local sourceTaskId = tonumber(info.sourceTaskId) -- 842
			local status = sanitizeUTF8(toStr(info.status)) -- 843
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 843
				goto __continue139 -- 844
			end -- 844
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 844
				goto __continue139 -- 845
			end -- 845
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 846
			items[#items + 1] = { -- 847
				sessionId = sessionId, -- 848
				rootSessionId = infoRootSessionId, -- 849
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 850
				title = sanitizeUTF8(toStr(info.title)), -- 851
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 852
				goal = sanitizeUTF8(toStr(info.goal)), -- 853
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 854
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 855
					__TS__ArrayFilter( -- 856
						info.filesHint, -- 856
						function(____, item) return type(item) == "string" end -- 856
					), -- 856
					function(____, item) return sanitizeUTF8(item) end -- 856
				) or ({}), -- 856
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 858
				success = info.success == true, -- 859
				cleared = info.cleared == true, -- 860
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 861
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 862
					"subagents", -- 862
					Path:getFilename(path) -- 862
				)), -- 862
				sourceTaskId = sourceTaskId or 0, -- 863
				changeSet = decodeChangeSetSummary(info.changeSet), -- 864
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 865
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 866
				completion = normalizeAgentCompletionReport(info.completion), -- 867
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 868
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 869
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 870
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 871
			} -- 871
		end -- 871
		::__continue139:: -- 871
	end -- 871
	__TS__ArraySort( -- 874
		items, -- 874
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 874
	) -- 874
	return items -- 875
end -- 875
function getPendingHandoffDir(projectRoot, memoryScope) -- 878
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 879
end -- 879
function writePendingHandoff(projectRoot, memoryScope, value) -- 882
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 883
	if not Content:exist(dir) then -- 883
		ensureDirRecursive(dir) -- 885
	end -- 885
	local path = Path(dir, value.id .. ".json") -- 887
	local text = safeJsonEncode(value) -- 888
	if not text then -- 888
		return false -- 889
	end -- 889
	return Content:save(path, text .. "\n") -- 890
end -- 890
function listPendingHandoffs(projectRoot, memoryScope) -- 893
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 894
	if not Content:exist(dir) or not Content:isdir(dir) then -- 894
		return {} -- 895
	end -- 895
	local items = {} -- 896
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 897
		do -- 897
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 898
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 898
				goto __continue154 -- 899
			end -- 899
			local text = Content:load(path) -- 900
			if not text or __TS__StringTrim(text) == "" then -- 900
				goto __continue154 -- 901
			end -- 901
			local obj = safeJsonDecode(text) -- 902
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 902
				goto __continue154 -- 903
			end -- 903
			local value = obj -- 904
			local sourceTaskId = tonumber(value.sourceTaskId) -- 905
			local sourceSessionId = tonumber(value.sourceSessionId) -- 906
			local id = sanitizeUTF8(toStr(value.id)) -- 907
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 908
			local message = sanitizeUTF8(toStr(value.message)) -- 909
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 910
			local goal = sanitizeUTF8(toStr(value.goal)) -- 911
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 912
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 912
				goto __continue154 -- 914
			end -- 914
			items[#items + 1] = { -- 916
				id = id, -- 917
				sourceSessionId = sourceSessionId, -- 918
				sourceTitle = sourceTitle, -- 919
				sourceTaskId = sourceTaskId, -- 920
				message = message, -- 921
				prompt = prompt, -- 922
				goal = goal, -- 923
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 924
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 925
					__TS__ArrayFilter( -- 926
						value.filesHint, -- 926
						function(____, item) return type(item) == "string" end -- 926
					), -- 926
					function(____, item) return sanitizeUTF8(item) end -- 926
				) or ({}), -- 926
				success = value.success == true, -- 928
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 929
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 930
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 931
				changeSet = decodeChangeSetSummary(value.changeSet), -- 932
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 933
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 934
				createdAt = createdAt -- 937
			} -- 937
		end -- 937
		::__continue154:: -- 937
	end -- 937
	__TS__ArraySort( -- 940
		items, -- 940
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 940
	) -- 940
	return items -- 941
end -- 941
function deletePendingHandoff(projectRoot, memoryScope, id) -- 944
	local path = Path( -- 945
		getPendingHandoffDir(projectRoot, memoryScope), -- 945
		id .. ".json" -- 945
	) -- 945
	if Content:exist(path) then -- 945
		Content:remove(path) -- 947
	end -- 947
end -- 947
function normalizePromptText(prompt) -- 951
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 952
end -- 952
function normalizePromptTextSafe(prompt) -- 955
	if type(prompt) == "string" then -- 955
		local normalized = normalizePromptText(prompt) -- 957
		if normalized ~= "" then -- 957
			return normalized -- 958
		end -- 958
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 959
		if sanitized ~= "" then -- 959
			return truncateAgentUserPrompt(sanitized) -- 961
		end -- 961
		return "" -- 963
	end -- 963
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 965
	if text == "" then -- 965
		return "" -- 966
	end -- 966
	return truncateAgentUserPrompt(text) -- 967
end -- 967
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 970
	local sections = {} -- 971
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 972
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 973
	local normalizedFiles = __TS__ArrayFilter( -- 974
		__TS__ArrayMap( -- 974
			__TS__ArrayFilter( -- 974
				filesHint or ({}), -- 974
				function(____, item) return type(item) == "string" end -- 975
			), -- 975
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 976
		), -- 976
		function(____, item) return item ~= "" end -- 977
	) -- 977
	if normalizedTitle ~= "" then -- 977
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 979
	end -- 979
	if normalizedExpected ~= "" then -- 979
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 982
	end -- 982
	if #normalizedFiles > 0 then -- 982
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 985
	end -- 985
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 987
end -- 987
function normalizeSessionRuntimeState(session) -- 990
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 990
		return session -- 992
	end -- 992
	if activeStopTokens[session.currentTaskId] ~= nil then -- 992
		return session -- 995
	end -- 995
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 997
	if #pendingToolRows > 0 then -- 997
		local t = now() -- 1003
		do -- 1003
			local i = 0 -- 1004
			while i < #pendingToolRows do -- 1004
				local row = pendingToolRows[i + 1] -- 1005
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1006
				result.success = false -- 1007
				result.state = "failed" -- 1008
				result.interrupted = true -- 1009
				result.message = "tool call was interrupted because the program exited before it completed." -- 1010
				DB:exec( -- 1011
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1011
					{ -- 1013
						encodeJson(result), -- 1013
						t, -- 1013
						row[1] -- 1013
					} -- 1013
				) -- 1013
				i = i + 1 -- 1004
			end -- 1004
		end -- 1004
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1016
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1017
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1018
	end -- 1018
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1025
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1026
	return __TS__ObjectAssign( -- 1027
		{}, -- 1027
		session, -- 1028
		{ -- 1027
			status = "STOPPED", -- 1029
			currentTaskStatus = "STOPPED", -- 1030
			updatedAt = now() -- 1031
		} -- 1031
	) -- 1031
end -- 1031
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1035
	DB:exec( -- 1036
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1036
		{ -- 1040
			status, -- 1041
			currentTaskId or 0, -- 1042
			currentTaskStatus or status, -- 1043
			now(), -- 1044
			sessionId -- 1045
		} -- 1045
	) -- 1045
end -- 1045
function mergeAgentMetrics(current, next) -- 1050
	return __TS__ObjectAssign({}, current or ({}), next) -- 1051
end -- 1051
function updateSessionMetrics(sessionId, metrics) -- 1057
	local session = getSessionItem(sessionId) -- 1058
	if not session then -- 1058
		return nil -- 1059
	end -- 1059
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1060
	DB:exec( -- 1061
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1061
		{ -- 1065
			encodeJson(merged), -- 1066
			now(), -- 1067
			sessionId -- 1068
		} -- 1068
	) -- 1068
	return merged -- 1071
end -- 1071
function clearSessionTokenUsage(sessionId) -- 1074
	local session = getSessionItem(sessionId) -- 1075
	if not session then -- 1075
		return nil -- 1076
	end -- 1076
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1077
	__TS__Delete(metrics, "usage") -- 1078
	DB:exec( -- 1079
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1079
		{ -- 1083
			encodeJson(metrics), -- 1084
			now(), -- 1085
			sessionId -- 1086
		} -- 1086
	) -- 1086
	return metrics -- 1089
end -- 1089
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1092
	if taskId == nil or taskId <= 0 then -- 1092
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1094
		return -- 1095
	end -- 1095
	local row = getSessionRow(sessionId) -- 1097
	if not row then -- 1097
		return -- 1098
	end -- 1098
	local session = rowToSession(row) -- 1099
	if session.currentTaskId ~= taskId then -- 1099
		Log( -- 1101
			"Info", -- 1101
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1101
		) -- 1101
		return -- 1102
	end -- 1102
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1104
end -- 1104
function insertMessage(sessionId, role, content, taskId) -- 1107
	local t = now() -- 1108
	DB:exec( -- 1109
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1109
		{ -- 1112
			sessionId, -- 1113
			taskId or 0, -- 1114
			role, -- 1115
			sanitizeUTF8(content), -- 1116
			t, -- 1117
			t -- 1118
		} -- 1118
	) -- 1118
	return getLastInsertRowId() -- 1121
end -- 1121
function updateMessage(messageId, content) -- 1124
	DB:exec( -- 1125
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1125
		{ -- 1127
			sanitizeUTF8(content), -- 1127
			now(), -- 1127
			messageId -- 1127
		} -- 1127
	) -- 1127
end -- 1127
function updateUserMessageForTask(messageId, content, taskId) -- 1131
	DB:exec( -- 1132
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1132
		{ -- 1136
			sanitizeUTF8(content), -- 1136
			taskId, -- 1136
			now(), -- 1136
			messageId -- 1136
		} -- 1136
	) -- 1136
end -- 1136
function upsertAssistantMessage(sessionId, taskId, content) -- 1193
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1194
	if row and type(row[1]) == "number" then -- 1194
		updateMessage(row[1], content) -- 1201
		return row[1] -- 1202
	end -- 1202
	return insertMessage(sessionId, "assistant", content, taskId) -- 1204
end -- 1204
function upsertStep(sessionId, taskId, step, tool, patch) -- 1207
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1217
	local reason = sanitizeUTF8(patch.reason or "") -- 1221
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1222
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1223
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1224
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1225
	local statusPatch = patch.status or "" -- 1226
	local status = patch.status or "PENDING" -- 1227
	if not row then -- 1227
		local t = now() -- 1229
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1230
			sessionId, -- 1234
			taskId, -- 1235
			step, -- 1236
			tool, -- 1237
			status, -- 1238
			reason, -- 1239
			reasoningContent, -- 1240
			paramsJson, -- 1241
			resultJson, -- 1242
			patch.checkpointId or 0, -- 1243
			patch.checkpointSeq or 0, -- 1244
			filesJson, -- 1245
			t, -- 1246
			t -- 1247
		}) -- 1247
		return -- 1250
	end -- 1250
	DB:exec( -- 1252
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1252
		{ -- 1264
			tool, -- 1265
			statusPatch, -- 1266
			status, -- 1267
			reason, -- 1268
			reason, -- 1269
			reasoningContent, -- 1270
			reasoningContent, -- 1271
			paramsJson, -- 1272
			paramsJson, -- 1273
			resultJson, -- 1274
			resultJson, -- 1275
			patch.checkpointId or 0, -- 1276
			patch.checkpointId or 0, -- 1277
			patch.checkpointSeq or 0, -- 1278
			patch.checkpointSeq or 0, -- 1279
			filesJson, -- 1280
			filesJson, -- 1281
			now(), -- 1282
			row[1] -- 1283
		} -- 1283
	) -- 1283
end -- 1283
function getNextStepNumber(sessionId, taskId) -- 1288
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1289
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1293
	return math.max(0, current) + 1 -- 1294
end -- 1294
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1297
	if status == nil then -- 1297
		status = "DONE" -- 1305
	end -- 1305
	local step = getNextStepNumber(sessionId, taskId) -- 1307
	upsertStep( -- 1308
		sessionId, -- 1308
		taskId, -- 1308
		step, -- 1308
		tool, -- 1308
		{status = status, reason = reason, params = params, result = result} -- 1308
	) -- 1308
	return getStepItem(sessionId, taskId, step) -- 1314
end -- 1314
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1317
	if taskId <= 0 then -- 1317
		return -- 1318
	end -- 1318
	if finalSteps ~= nil and finalSteps >= 0 then -- 1318
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1320
	end -- 1320
	if not finalStatus then -- 1320
		return -- 1326
	end -- 1326
	if finalSteps ~= nil and finalSteps >= 0 then -- 1326
		DB:exec( -- 1328
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1328
			{ -- 1332
				finalStatus, -- 1332
				now(), -- 1332
				sessionId, -- 1332
				taskId, -- 1332
				finalSteps -- 1332
			} -- 1332
		) -- 1332
		return -- 1334
	end -- 1334
	DB:exec( -- 1336
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1336
		{ -- 1340
			finalStatus, -- 1340
			now(), -- 1340
			sessionId, -- 1340
			taskId -- 1340
		} -- 1340
	) -- 1340
end -- 1340
function emitAgentSessionPatch(sessionId, patch) -- 1367
	if HttpServer.wsConnectionCount == 0 then -- 1367
		return -- 1369
	end -- 1369
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1371
	if not text then -- 1371
		return -- 1376
	end -- 1376
	emit("AppWS", "Send", text) -- 1377
end -- 1377
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1380
	emitAgentSessionPatch( -- 1381
		sessionId, -- 1381
		{ -- 1381
			sessionDeleted = true, -- 1382
			relatedSessions = listRelatedSessions(rootSessionId) -- 1383
		} -- 1383
	) -- 1383
	local rootSession = getSessionItem(rootSessionId) -- 1385
	if rootSession then -- 1385
		emitAgentSessionPatch( -- 1387
			rootSessionId, -- 1387
			{ -- 1387
				session = rootSession, -- 1388
				relatedSessions = listRelatedSessions(rootSessionId) -- 1389
			} -- 1389
		) -- 1389
	end -- 1389
end -- 1389
function flushPendingSubAgentHandoffs(rootSession) -- 1394
	if rootSession.kind ~= "main" then -- 1394
		return -- 1395
	end -- 1395
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1395
		return -- 1397
	end -- 1397
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1399
	if #items == 0 then -- 1399
		return -- 1400
	end -- 1400
	local handoffTaskId = 0 -- 1401
	local ____rootSession_currentTaskId_14 -- 1402
	if rootSession.currentTaskId then -- 1402
		____rootSession_currentTaskId_14 = getTaskPrompt(rootSession.currentTaskId) -- 1402
	else -- 1402
		____rootSession_currentTaskId_14 = nil -- 1402
	end -- 1402
	local currentTaskPrompt = ____rootSession_currentTaskId_14 -- 1402
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1402
		handoffTaskId = rootSession.currentTaskId -- 1410
	else -- 1410
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1412
		if not taskRes.success then -- 1412
			Log( -- 1414
				"Warn", -- 1414
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1414
			) -- 1414
			return -- 1415
		end -- 1415
		handoffTaskId = taskRes.taskId -- 1417
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1418
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1419
		emitAgentSessionPatch( -- 1420
			rootSession.id, -- 1420
			{session = getSessionItem(rootSession.id)} -- 1420
		) -- 1420
	end -- 1420
	do -- 1420
		local i = 0 -- 1424
		while i < #items do -- 1424
			local item = items[i + 1] -- 1425
			local step = appendSystemStep( -- 1426
				rootSession.id, -- 1427
				handoffTaskId, -- 1428
				"sub_agent_handoff", -- 1429
				"sub_agent_handoff", -- 1430
				item.message, -- 1431
				{ -- 1432
					sourceSessionId = item.sourceSessionId, -- 1433
					sourceTitle = item.sourceTitle, -- 1434
					sourceTaskId = item.sourceTaskId, -- 1435
					success = item.success == true, -- 1436
					summary = item.message, -- 1437
					resultFilePath = item.resultFilePath or "", -- 1438
					artifactDir = item.artifactDir or "", -- 1439
					finishedAt = item.finishedAt or "", -- 1440
					changeSet = item.changeSet, -- 1441
					memoryEntry = item.memoryEntry, -- 1442
					completion = item.completion -- 1443
				}, -- 1443
				{ -- 1445
					sourceSessionId = item.sourceSessionId, -- 1446
					sourceTitle = item.sourceTitle, -- 1447
					sourceTaskId = item.sourceTaskId, -- 1448
					prompt = item.prompt, -- 1449
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1450
					expectedOutput = item.expectedOutput or "", -- 1451
					filesHint = item.filesHint or ({}), -- 1452
					resultFilePath = item.resultFilePath or "", -- 1453
					artifactDir = item.artifactDir or "", -- 1454
					changeSet = item.changeSet, -- 1455
					memoryEntry = item.memoryEntry, -- 1456
					completion = item.completion -- 1457
				}, -- 1457
				"DONE" -- 1459
			) -- 1459
			if step then -- 1459
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1462
			end -- 1462
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1464
			i = i + 1 -- 1424
		end -- 1424
	end -- 1424
end -- 1424
function applyEvent(sessionId, event) -- 1476
	repeat -- 1476
		local ____switch234 = event.type -- 1476
		local metrics -- 1476
		local ____cond234 = ____switch234 == "task_started" -- 1476
		if ____cond234 then -- 1476
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1479
			metrics = clearSessionTokenUsage(sessionId) -- 1480
			emitAgentSessionPatch( -- 1481
				sessionId, -- 1481
				{ -- 1481
					session = getSessionItem(sessionId), -- 1482
					metrics = metrics -- 1483
				} -- 1483
			) -- 1483
			break -- 1485
		end -- 1485
		____cond234 = ____cond234 or ____switch234 == "decision_made" -- 1485
		if ____cond234 then -- 1485
			upsertStep( -- 1487
				sessionId, -- 1487
				event.taskId, -- 1487
				event.step, -- 1487
				event.tool, -- 1487
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1487
			) -- 1487
			emitAgentSessionPatch( -- 1493
				sessionId, -- 1493
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1493
			) -- 1493
			break -- 1496
		end -- 1496
		____cond234 = ____cond234 or ____switch234 == "tool_started" -- 1496
		if ____cond234 then -- 1496
			upsertStep( -- 1498
				sessionId, -- 1498
				event.taskId, -- 1498
				event.step, -- 1498
				event.tool, -- 1498
				{status = "RUNNING"} -- 1498
			) -- 1498
			emitAgentSessionPatch( -- 1501
				sessionId, -- 1501
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1501
			) -- 1501
			break -- 1504
		end -- 1504
		____cond234 = ____cond234 or ____switch234 == "tool_finished" -- 1504
		if ____cond234 then -- 1504
			upsertStep( -- 1506
				sessionId, -- 1506
				event.taskId, -- 1506
				event.step, -- 1506
				event.tool, -- 1506
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1506
			) -- 1506
			emitAgentSessionPatch( -- 1511
				sessionId, -- 1511
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1511
			) -- 1511
			break -- 1514
		end -- 1514
		____cond234 = ____cond234 or ____switch234 == "tool_progress" -- 1514
		if ____cond234 then -- 1514
			do -- 1514
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1517
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1517
					break -- 1519
				end -- 1519
			end -- 1519
			upsertStep( -- 1522
				sessionId, -- 1522
				event.taskId, -- 1522
				event.step, -- 1522
				event.tool, -- 1522
				{status = "RUNNING", result = event.result} -- 1522
			) -- 1522
			emitAgentSessionPatch( -- 1526
				sessionId, -- 1526
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1526
			) -- 1526
			break -- 1529
		end -- 1529
		____cond234 = ____cond234 or ____switch234 == "checkpoint_created" -- 1529
		if ____cond234 then -- 1529
			upsertStep( -- 1531
				sessionId, -- 1531
				event.taskId, -- 1531
				event.step, -- 1531
				event.tool, -- 1531
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1531
			) -- 1531
			emitAgentSessionPatch( -- 1536
				sessionId, -- 1536
				{ -- 1536
					step = getStepItem(sessionId, event.taskId, event.step), -- 1537
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1538
				} -- 1538
			) -- 1538
			break -- 1540
		end -- 1540
		____cond234 = ____cond234 or ____switch234 == "memory_compression_started" -- 1540
		if ____cond234 then -- 1540
			upsertStep( -- 1542
				sessionId, -- 1542
				event.taskId, -- 1542
				event.step, -- 1542
				event.tool, -- 1542
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1542
			) -- 1542
			emitAgentSessionPatch( -- 1547
				sessionId, -- 1547
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1547
			) -- 1547
			break -- 1550
		end -- 1550
		____cond234 = ____cond234 or ____switch234 == "memory_compression_finished" -- 1550
		if ____cond234 then -- 1550
			upsertStep( -- 1552
				sessionId, -- 1552
				event.taskId, -- 1552
				event.step, -- 1552
				event.tool, -- 1552
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1552
			) -- 1552
			emitAgentSessionPatch( -- 1557
				sessionId, -- 1557
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1557
			) -- 1557
			break -- 1560
		end -- 1560
		____cond234 = ____cond234 or ____switch234 == "metrics_updated" -- 1560
		if ____cond234 then -- 1560
			do -- 1560
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1562
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1563
				break -- 1566
			end -- 1566
		end -- 1566
		____cond234 = ____cond234 or ____switch234 == "assistant_message_updated" -- 1566
		if ____cond234 then -- 1566
			do -- 1566
				upsertStep( -- 1569
					sessionId, -- 1569
					event.taskId, -- 1569
					event.step, -- 1569
					"message", -- 1569
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1569
				) -- 1569
				emitAgentSessionPatch( -- 1574
					sessionId, -- 1574
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1574
				) -- 1574
				break -- 1577
			end -- 1577
		end -- 1577
		____cond234 = ____cond234 or ____switch234 == "task_finished" -- 1577
		if ____cond234 then -- 1577
			do -- 1577
				local ____opt_15 = activeStopTokens[event.taskId or -1] -- 1577
				local stopped = (____opt_15 and ____opt_15.stopped) == true -- 1580
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1581
				local session = getSessionItem(sessionId) -- 1584
				local isSubSession = (session and session.kind) == "sub" -- 1585
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1586
				if isSubSession and event.taskId ~= nil then -- 1586
					finalizingSubSessionTaskIds[event.taskId] = true -- 1588
				end -- 1588
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1590
				if event.taskId ~= nil then -- 1590
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1592
					local ____finalizeTaskSteps_21 = finalizeTaskSteps -- 1593
					local ____array_20 = __TS__SparseArrayNew( -- 1593
						sessionId, -- 1594
						event.taskId, -- 1595
						type(event.steps) == "number" and math.max( -- 1596
							0, -- 1596
							math.floor(event.steps) -- 1596
						) or nil -- 1596
					) -- 1596
					local ____event_success_19 -- 1597
					if event.success then -- 1597
						____event_success_19 = nil -- 1597
					else -- 1597
						____event_success_19 = stopped and "STOPPED" or "FAILED" -- 1597
					end -- 1597
					__TS__SparseArrayPush(____array_20, ____event_success_19) -- 1597
					____finalizeTaskSteps_21(__TS__SparseArraySpread(____array_20)) -- 1593
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1599
					if not isSubSession then -- 1599
						__TS__Delete(activeStopTokens, event.taskId) -- 1601
					end -- 1601
					emitAgentSessionPatch( -- 1603
						sessionId, -- 1603
						{ -- 1603
							session = getSessionItem(sessionId), -- 1604
							message = getMessageItem(messageId), -- 1605
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1606
							removedStepIds = removedStepIds -- 1607
						} -- 1607
					) -- 1607
				end -- 1607
				if session and session.kind == "main" then -- 1607
					flushPendingSubAgentHandoffs(session) -- 1611
				end -- 1611
				break -- 1613
			end -- 1613
		end -- 1613
	until true -- 1613
end -- 1613
function ____exports.createSession(projectRoot, title) -- 1750
	if title == nil then -- 1750
		title = "" -- 1750
	end -- 1750
	if not isValidProjectRoot(projectRoot) then -- 1750
		return {success = false, message = "invalid projectRoot"} -- 1752
	end -- 1752
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1754
	if row then -- 1754
		return { -- 1763
			success = true, -- 1763
			session = rowToSession(row) -- 1763
		} -- 1763
	end -- 1763
	local t = now() -- 1765
	DB:exec( -- 1766
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1766
		{ -- 1769
			projectRoot, -- 1769
			title ~= "" and title or Path:getFilename(projectRoot), -- 1769
			t, -- 1769
			t -- 1769
		} -- 1769
	) -- 1769
	local sessionId = getLastInsertRowId() -- 1771
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1772
	local session = getSessionItem(sessionId) -- 1773
	if not session then -- 1773
		return {success = false, message = "failed to create session"} -- 1775
	end -- 1775
	return {success = true, session = session} -- 1777
end -- 1750
function ____exports.createSubSession(parentSessionId, title) -- 1780
	if title == nil then -- 1780
		title = "" -- 1780
	end -- 1780
	local parent = getSessionItem(parentSessionId) -- 1781
	if not parent then -- 1781
		return {success = false, message = "parent session not found"} -- 1783
	end -- 1783
	local rootId = getSessionRootId(parent) -- 1785
	local t = now() -- 1786
	DB:exec( -- 1787
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1787
		{ -- 1790
			parent.projectRoot, -- 1790
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1790
			rootId, -- 1790
			parent.id, -- 1790
			t, -- 1790
			t -- 1790
		} -- 1790
	) -- 1790
	local sessionId = getLastInsertRowId() -- 1792
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1793
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1794
	local session = getSessionItem(sessionId) -- 1795
	if not session then -- 1795
		return {success = false, message = "failed to create sub session"} -- 1797
	end -- 1797
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1799
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1800
	subStorage:writeMemory(parentStorage:readMemory()) -- 1801
	return {success = true, session = session} -- 1802
end -- 1780
function spawnSubAgentSession(request) -- 1805
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1805
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1817
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1818
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1819
		if normalizedPrompt == "" then -- 1819
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1821
		end -- 1821
		if normalizedPrompt == "" then -- 1821
			local ____Log_27 = Log -- 1828
			local ____temp_24 = #normalizedTitle -- 1828
			local ____temp_25 = #rawPrompt -- 1828
			local ____temp_26 = #toStr(request.expectedOutput) -- 1828
			local ____opt_22 = request.filesHint -- 1828
			____Log_27( -- 1828
				"Warn", -- 1828
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_24)) .. " raw_prompt_len=") .. tostring(____temp_25)) .. " expected_len=") .. tostring(____temp_26)) .. " files_hint_count=") .. tostring(____opt_22 and #____opt_22 or 0) -- 1828
			) -- 1828
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1828
		end -- 1828
		Log( -- 1831
			"Info", -- 1831
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1831
		) -- 1831
		local parentSessionId = request.parentSessionId -- 1832
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1832
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1834
			if not fallbackParent then -- 1834
				local createdMain = ____exports.createSession(request.projectRoot) -- 1836
				if createdMain.success then -- 1836
					fallbackParent = createdMain.session -- 1838
				end -- 1838
			end -- 1838
			if fallbackParent then -- 1838
				Log( -- 1842
					"Warn", -- 1842
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1842
				) -- 1842
				parentSessionId = fallbackParent.id -- 1843
			end -- 1843
		end -- 1843
		local parentSession = getSessionItem(parentSessionId) -- 1846
		if not parentSession then -- 1846
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1846
		end -- 1846
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1850
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1850
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1850
		end -- 1850
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1854
		if not created.success then -- 1854
			return ____awaiter_resolve(nil, created) -- 1854
		end -- 1854
		writeSpawnInfo( -- 1858
			created.session.projectRoot, -- 1858
			created.session.memoryScope, -- 1858
			{ -- 1858
				sessionId = created.session.id, -- 1859
				rootSessionId = created.session.rootSessionId, -- 1860
				parentSessionId = created.session.parentSessionId, -- 1861
				title = created.session.title, -- 1862
				prompt = normalizedPrompt, -- 1863
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1864
				expectedOutput = request.expectedOutput or "", -- 1865
				filesHint = request.filesHint or ({}), -- 1866
				status = "RUNNING", -- 1867
				success = false, -- 1868
				resultFilePath = "", -- 1869
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1870
				sourceTaskId = 0, -- 1871
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1872
				createdAtTs = created.session.createdAt, -- 1873
				finishedAt = "", -- 1874
				finishedAtTs = 0 -- 1875
			} -- 1875
		) -- 1875
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true, request.disabledAgentTools) -- 1877
		if not sent.success then -- 1877
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1877
		end -- 1877
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1877
	end) -- 1877
end -- 1877
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 1958
	local rootSession = getRootSessionItem(session.id) -- 1959
	if not rootSession then -- 1959
		return -- 1960
	end -- 1960
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 1961
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1962
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1963
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1964
	local queueResult = writePendingHandoff( -- 1965
		rootSession.projectRoot, -- 1965
		rootSession.memoryScope, -- 1965
		{ -- 1965
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1966
			sourceSessionId = session.id, -- 1967
			sourceTitle = session.title, -- 1968
			sourceTaskId = taskId, -- 1969
			message = summary, -- 1970
			prompt = result.prompt, -- 1971
			goal = result.goal, -- 1972
			expectedOutput = result.expectedOutput or "", -- 1973
			filesHint = result.filesHint or ({}), -- 1974
			success = result.success, -- 1975
			resultFilePath = result.resultFilePath, -- 1976
			artifactDir = result.artifactDir, -- 1977
			finishedAt = result.finishedAt, -- 1978
			changeSet = changeSet, -- 1979
			memoryEntry = result.memoryEntry, -- 1980
			completion = result.completion, -- 1981
			createdAt = createdAt -- 1982
		} -- 1982
	) -- 1982
	if not queueResult then -- 1982
		Log( -- 1985
			"Warn", -- 1985
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1985
		) -- 1985
		return -- 1986
	end -- 1986
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1986
		flushPendingSubAgentHandoffs(rootSession) -- 1989
	end -- 1989
end -- 1989
function finalizeSubSession(session, taskId, success, message, completion) -- 1993
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1993
		local rootSessionId = getSessionRootId(session) -- 1994
		local rootSession = getRootSessionItem(session.id) -- 1995
		if not rootSession then -- 1995
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 1995
		end -- 1995
		local spawnInfo = getSessionSpawnInfo(session) -- 1999
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2000
		local finishedAtTs = now() -- 2001
		local resultText = sanitizeUTF8(message) -- 2002
		local changeSet = getTaskChangeSetSummary(taskId) -- 2003
		local record = { -- 2004
			sessionId = session.id, -- 2005
			rootSessionId = rootSessionId, -- 2006
			parentSessionId = session.parentSessionId, -- 2007
			title = session.title, -- 2008
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2009
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2010
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2011
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2012
			status = success and "DONE" or "FAILED", -- 2013
			success = success, -- 2014
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2015
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2016
			sourceTaskId = taskId, -- 2017
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2018
			finishedAt = finishedAt, -- 2019
			createdAtTs = session.createdAt, -- 2020
			finishedAtTs = finishedAtTs, -- 2021
			changeSet = changeSet, -- 2022
			completion = completion or normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({resultText})}) -- 2023
		} -- 2023
		local ____record_success_40 -- 2028
		if record.success then -- 2028
			____record_success_40 = buildStructuredSubAgentMemoryEntry(record) -- 2028
		else -- 2028
			____record_success_40 = nil -- 2028
		end -- 2028
		record.memoryEntry = ____record_success_40 -- 2028
		if not writeSubAgentResultFile(session, record, resultText) then -- 2028
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2028
		end -- 2028
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2028
			sessionId = record.sessionId, -- 2033
			rootSessionId = record.rootSessionId, -- 2034
			parentSessionId = record.parentSessionId, -- 2035
			title = record.title, -- 2036
			prompt = record.prompt, -- 2037
			goal = record.goal, -- 2038
			expectedOutput = record.expectedOutput or "", -- 2039
			filesHint = record.filesHint or ({}), -- 2040
			status = record.status, -- 2041
			success = record.success, -- 2042
			resultFilePath = record.resultFilePath, -- 2043
			artifactDir = record.artifactDir, -- 2044
			sourceTaskId = record.sourceTaskId, -- 2045
			createdAt = record.createdAt, -- 2046
			finishedAt = record.finishedAt, -- 2047
			createdAtTs = record.createdAtTs, -- 2048
			finishedAtTs = record.finishedAtTs, -- 2049
			changeSet = record.changeSet, -- 2050
			memoryEntry = record.memoryEntry, -- 2051
			memoryEntryError = record.memoryEntryError, -- 2052
			completion = record.completion -- 2053
		}) then -- 2053
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2053
		end -- 2053
		if success then -- 2053
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2058
			deleteSessionRecords(session.id, true) -- 2059
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2060
		end -- 2060
		return ____awaiter_resolve(nil, {success = true}) -- 2060
	end) -- 2060
end -- 2060
function stopClearedSubSession(session, taskId) -- 2065
	local spawnInfo = getSessionSpawnInfo(session) -- 2066
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2067
	local rootSessionId = getSessionRootId(session) -- 2068
	Tools.setTaskStatus(taskId, "STOPPED") -- 2069
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2070
	if not writeSpawnInfo( -- 2070
		session.projectRoot, -- 2071
		session.memoryScope, -- 2071
		{ -- 2071
			sessionId = session.id, -- 2072
			rootSessionId = rootSessionId, -- 2073
			parentSessionId = session.parentSessionId, -- 2074
			title = session.title, -- 2075
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2076
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2077
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2078
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2079
			status = "STOPPED", -- 2080
			success = false, -- 2081
			cleared = true, -- 2082
			resultFilePath = "", -- 2083
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2084
			sourceTaskId = taskId, -- 2085
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2086
			finishedAt = finishedAt, -- 2087
			createdAtTs = session.createdAt, -- 2088
			finishedAtTs = now() -- 2089
		} -- 2089
	) then -- 2089
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2091
	end -- 2091
	deleteSessionRecords(session.id, true) -- 2093
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2094
	return {success = true} -- 2095
end -- 2095
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools) -- 2098
	if allowSubSessionStart == nil then -- 2098
		allowSubSessionStart = false -- 2098
	end -- 2098
	local session = getSessionItem(sessionId) -- 2099
	if not session then -- 2099
		return {success = false, message = "session not found"} -- 2101
	end -- 2101
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2101
		return {success = false, message = "session task is finalizing"} -- 2104
	end -- 2104
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2104
		return {success = false, message = "session task is still running"} -- 2107
	end -- 2107
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2109
	if normalizedPrompt == "" and session.kind == "sub" then -- 2109
		local spawnInfo = getSessionSpawnInfo(session) -- 2111
		if spawnInfo then -- 2111
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2113
			if normalizedPrompt == "" then -- 2113
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2115
			end -- 2115
		end -- 2115
	end -- 2115
	if normalizedPrompt == "" then -- 2115
		return {success = false, message = "prompt is empty"} -- 2124
	end -- 2124
	return startPromptTask( -- 2126
		session, -- 2126
		normalizedPrompt, -- 2126
		nil, -- 2126
		normalizeDisabledAgentTools(disabledAgentTools) -- 2126
	) -- 2126
end -- 2098
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools) -- 2129
	if disabledAgentTools == nil then -- 2129
		disabledAgentTools = {} -- 2129
	end -- 2129
	local taskRes = Tools.createTask(normalizedPrompt) -- 2130
	if not taskRes.success then -- 2130
		return {success = false, message = taskRes.message} -- 2132
	end -- 2132
	local taskId = taskRes.taskId -- 2134
	local useChineseResponse = getDefaultUseChineseResponse() -- 2135
	if existingUserMessageId ~= nil then -- 2135
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2137
	else -- 2137
		insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2139
	end -- 2139
	local stopToken = {stopped = false} -- 2141
	activeStopTokens[taskId] = stopToken -- 2142
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2143
	runCodingAgent( -- 2144
		{ -- 2144
			prompt = normalizedPrompt, -- 2145
			workDir = session.projectRoot, -- 2146
			useChineseResponse = useChineseResponse, -- 2147
			taskId = taskId, -- 2148
			sessionId = session.id, -- 2149
			memoryScope = session.memoryScope, -- 2150
			role = session.kind, -- 2151
			disabledAgentTools = disabledAgentTools, -- 2152
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2153
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2156
			stopToken = stopToken, -- 2159
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2160
		}, -- 2160
		function(result) -- 2161
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2161
				local nextSession = getSessionItem(session.id) -- 2162
				if nextSession and nextSession.kind == "sub" then -- 2162
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2162
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2165
						if not stopped.success then -- 2165
							Log( -- 2167
								"Warn", -- 2167
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2167
							) -- 2167
							emitAgentSessionPatch( -- 2168
								session.id, -- 2168
								{session = getSessionItem(session.id)} -- 2168
							) -- 2168
						end -- 2168
						__TS__Delete(activeStopTokens, taskId) -- 2172
						return ____awaiter_resolve(nil) -- 2172
					end -- 2172
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2175
					emitAgentSessionPatch( -- 2176
						session.id, -- 2176
						{session = getSessionItem(session.id)} -- 2176
					) -- 2176
					local finalized = __TS__Await(finalizeSubSession( -- 2179
						nextSession, -- 2179
						taskId, -- 2179
						result.success, -- 2179
						result.message, -- 2179
						result.completion -- 2179
					)) -- 2179
					if not finalized.success then -- 2179
						Log( -- 2181
							"Warn", -- 2181
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2181
						) -- 2181
					end -- 2181
					local finalizedSession = getSessionItem(session.id) -- 2183
					if finalizedSession then -- 2183
						local stopped = stopToken.stopped == true -- 2185
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2186
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2189
						emitAgentSessionPatch( -- 2190
							session.id, -- 2190
							{session = getSessionItem(session.id)} -- 2190
						) -- 2190
					end -- 2190
					__TS__Delete(activeStopTokens, taskId) -- 2194
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2195
				end -- 2195
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2195
					applyEvent(session.id, { -- 2198
						type = "task_finished", -- 2199
						sessionId = session.id, -- 2200
						taskId = result.taskId, -- 2201
						success = false, -- 2202
						message = result.message, -- 2203
						steps = result.steps -- 2204
					}) -- 2204
				end -- 2204
			end) -- 2204
		end -- 2161
	) -- 2161
	return {success = true, sessionId = session.id, taskId = taskId} -- 2208
end -- 2208
function ____exports.listRunningSubAgents(request) -- 2296
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2296
		local session = getSessionItem(request.sessionId) -- 2304
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2304
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2306
		end -- 2306
		if not session then -- 2306
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2306
		end -- 2306
		local rootSession = getRootSessionItem(session.id) -- 2311
		if not rootSession then -- 2311
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2311
		end -- 2311
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2315
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2316
		local limit = math.max( -- 2317
			1, -- 2317
			math.floor(tonumber(request.limit) or 5) -- 2317
		) -- 2317
		local offset = math.max( -- 2318
			0, -- 2318
			math.floor(tonumber(request.offset) or 0) -- 2318
		) -- 2318
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2319
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2320
		local runningSessions = {} -- 2327
		do -- 2327
			local i = 0 -- 2328
			while i < #rows do -- 2328
				do -- 2328
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2329
					if current.currentTaskStatus ~= "RUNNING" then -- 2329
						goto __continue342 -- 2331
					end -- 2331
					local spawnInfo = getSessionSpawnInfo(current) -- 2333
					runningSessions[#runningSessions + 1] = { -- 2334
						sessionId = current.id, -- 2335
						title = current.title, -- 2336
						parentSessionId = current.parentSessionId, -- 2337
						rootSessionId = current.rootSessionId, -- 2338
						status = "RUNNING", -- 2339
						currentTaskId = current.currentTaskId, -- 2340
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2341
						goal = spawnInfo and spawnInfo.goal, -- 2342
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2343
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2344
						createdAt = current.createdAt, -- 2345
						updatedAt = current.updatedAt -- 2346
					} -- 2346
				end -- 2346
				::__continue342:: -- 2346
				i = i + 1 -- 2328
			end -- 2328
		end -- 2328
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2349
		local completedSessions = __TS__ArrayMap( -- 2350
			completedRecords, -- 2350
			function(____, record) return { -- 2350
				sessionId = record.sessionId, -- 2351
				title = record.title, -- 2352
				parentSessionId = record.parentSessionId, -- 2353
				rootSessionId = record.rootSessionId, -- 2354
				status = record.status, -- 2355
				goal = record.goal, -- 2356
				expectedOutput = record.expectedOutput, -- 2357
				filesHint = record.filesHint, -- 2358
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2359
				success = record.success, -- 2360
				cleared = record.cleared, -- 2361
				resultFilePath = record.resultFilePath, -- 2362
				artifactDir = record.artifactDir, -- 2363
				finishedAt = record.finishedAt, -- 2364
				createdAt = record.createdAtTs, -- 2365
				updatedAt = record.finishedAtTs -- 2366
			} end -- 2366
		) -- 2366
		local merged = {} -- 2368
		if status == "running" then -- 2368
			merged = runningSessions -- 2370
		elseif status == "done" then -- 2370
			merged = __TS__ArrayFilter( -- 2372
				completedSessions, -- 2372
				function(____, item) return item.status == "DONE" end -- 2372
			) -- 2372
		elseif status == "failed" then -- 2372
			merged = __TS__ArrayFilter( -- 2374
				completedSessions, -- 2374
				function(____, item) return item.status == "FAILED" end -- 2374
			) -- 2374
		elseif status == "stopped" then -- 2374
			merged = __TS__ArrayFilter( -- 2376
				completedSessions, -- 2376
				function(____, item) return item.status == "STOPPED" end -- 2376
			) -- 2376
		elseif status == "all" then -- 2376
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2378
		else -- 2378
			local runningKeys = {} -- 2380
			do -- 2380
				local i = 0 -- 2381
				while i < #runningSessions do -- 2381
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2382
					i = i + 1 -- 2381
				end -- 2381
			end -- 2381
			local latestCompletedByKey = {} -- 2384
			do -- 2384
				local i = 0 -- 2385
				while i < #completedSessions do -- 2385
					do -- 2385
						local item = completedSessions[i + 1] -- 2386
						local key = getSubAgentDisplayKey(item) -- 2387
						if runningKeys[key] then -- 2387
							goto __continue357 -- 2389
						end -- 2389
						local current = latestCompletedByKey[key] -- 2391
						if not current or item.updatedAt > current.updatedAt then -- 2391
							latestCompletedByKey[key] = item -- 2393
						end -- 2393
					end -- 2393
					::__continue357:: -- 2393
					i = i + 1 -- 2385
				end -- 2385
			end -- 2385
			local latestCompleted = {} -- 2396
			for ____, item in pairs(latestCompletedByKey) do -- 2397
				latestCompleted[#latestCompleted + 1] = item -- 2398
			end -- 2398
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2400
		end -- 2400
		if query ~= "" then -- 2400
			merged = __TS__ArrayFilter( -- 2403
				merged, -- 2403
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2403
			) -- 2403
		end -- 2403
		__TS__ArraySort( -- 2409
			merged, -- 2409
			function(____, a, b) -- 2409
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2409
					return -1 -- 2410
				end -- 2410
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2410
					return 1 -- 2411
				end -- 2411
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2411
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2413
				end -- 2413
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2415
			end -- 2409
		) -- 2409
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2417
		return ____awaiter_resolve(nil, { -- 2417
			success = true, -- 2419
			rootSessionId = rootSession.id, -- 2420
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2421
			status = status, -- 2422
			limit = limit, -- 2423
			offset = offset, -- 2424
			hasMore = offset + limit < #merged, -- 2425
			sessions = paged -- 2426
		}) -- 2426
	end) -- 2426
end -- 2296
TABLE_SESSION = "AgentSession" -- 215
TABLE_MESSAGE = "AgentSessionMessage" -- 216
TABLE_STEP = "AgentSessionStep" -- 217
TABLE_TASK = "AgentTask" -- 218
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 219
SPAWN_INFO_FILE = "SPAWN.json" -- 220
RESULT_FILE = "RESULT.md" -- 221
PENDING_HANDOFF_DIR = "pending-handoffs" -- 222
MAX_CONCURRENT_SUB_AGENTS = 4 -- 223
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 224
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 225
activeStopTokens = {} -- 273
finalizingSubSessionTaskIds = {} -- 274
now = function() return os.time() end -- 275
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 652
	if projectRoot == oldRoot then -- 652
		return newRoot -- 654
	end -- 654
	for ____, separator in ipairs({"/", "\\"}) do -- 656
		local prefix = oldRoot .. separator -- 657
		if __TS__StringStartsWith(projectRoot, prefix) then -- 657
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 659
		end -- 659
	end -- 659
	return nil -- 662
end -- 652
local function clearSessionAfterMessage(sessionId, message) -- 1140
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1141
	local removedStepIds = {} -- 1149
	do -- 1149
		local i = 0 -- 1150
		while i < #removedStepRows do -- 1150
			local row = removedStepRows[i + 1] -- 1151
			if type(row[1]) == "number" then -- 1151
				removedStepIds[#removedStepIds + 1] = row[1] -- 1153
			end -- 1153
			i = i + 1 -- 1150
		end -- 1150
	end -- 1150
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1156
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1164
	return removedStepIds -- 1169
end -- 1140
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1172
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1173
	local persisted = storage:readSessionState() -- 1174
	local userIndex = -1 -- 1175
	do -- 1175
		local i = #persisted.messages - 1 -- 1176
		while i >= 0 do -- 1176
			if persisted.messages[i + 1].role == "user" then -- 1176
				userIndex = i -- 1178
				break -- 1179
			end -- 1179
			i = i - 1 -- 1176
		end -- 1176
	end -- 1176
	if userIndex < 0 then -- 1176
		return -- 1182
	end -- 1182
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1183
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1184
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1185
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1190
end -- 1172
local function sanitizeStoredSteps(sessionId) -- 1344
	DB:exec( -- 1345
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1345
		{ -- 1363
			now(), -- 1363
			sessionId -- 1363
		} -- 1363
	) -- 1363
end -- 1344
local function getSchemaVersion() -- 1618
	local row = queryOne("PRAGMA user_version") -- 1619
	return row and type(row[1]) == "number" and row[1] or 0 -- 1620
end -- 1618
local function setSchemaVersion(version) -- 1623
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1624
		0, -- 1624
		math.floor(version) -- 1624
	))) -- 1624
end -- 1623
local function hasTableColumn(tableName, columnName) -- 1627
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1628
	do -- 1628
		local i = 0 -- 1629
		while i < #rows do -- 1629
			local row = rows[i + 1] -- 1630
			if toStr(row[2]) == columnName then -- 1630
				return true -- 1632
			end -- 1632
			i = i + 1 -- 1629
		end -- 1629
	end -- 1629
	return false -- 1635
end -- 1627
local function ensureSessionMetricsColumn() -- 1638
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1638
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1640
	end -- 1640
end -- 1638
local function recreateSchema() -- 1644
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1645
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1646
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1647
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1648
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1663
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1664
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1673
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1674
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1691
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1692
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1693
end -- 1644
do -- 1644
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1644
		recreateSchema() -- 1699
	else -- 1699
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1701
		ensureSessionMetricsColumn() -- 1716
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1717
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1718
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1727
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1728
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1745
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1746
	end -- 1746
end -- 1746
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1889
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1889
		return {success = false, message = "invalid projectRoot"} -- 1891
	end -- 1891
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1893
	for ____, row in ipairs(rows) do -- 1894
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1895
		if sessionId > 0 then -- 1895
			deleteSessionRecords(sessionId) -- 1897
		end -- 1897
	end -- 1897
	return {success = true, deleted = #rows} -- 1900
end -- 1889
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1903
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1903
		return {success = false, message = "invalid projectRoot"} -- 1905
	end -- 1905
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1907
	local renamed = 0 -- 1908
	for ____, row in ipairs(rows) do -- 1909
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1910
		local projectRoot = toStr(row[2]) -- 1911
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1912
		if sessionId > 0 and nextProjectRoot then -- 1912
			DB:exec( -- 1914
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1914
				{ -- 1916
					nextProjectRoot, -- 1916
					Path:getFilename(nextProjectRoot), -- 1916
					now(), -- 1916
					sessionId -- 1916
				} -- 1916
			) -- 1916
			renamed = renamed + 1 -- 1918
		end -- 1918
	end -- 1918
	return {success = true, renamed = renamed} -- 1921
end -- 1903
function ____exports.getSession(sessionId) -- 1924
	local session = getSessionItem(sessionId) -- 1925
	if not session then -- 1925
		return {success = false, message = "session not found"} -- 1927
	end -- 1927
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1929
	local relatedSessions = listRelatedSessions(sessionId) -- 1930
	sanitizeStoredSteps(sessionId) -- 1931
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1932
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1939
	local ____relatedSessions_29 = relatedSessions -- 1950
	local ____temp_28 -- 1951
	if normalizedSession.kind == "sub" then -- 1951
		____temp_28 = getSessionSpawnInfo(normalizedSession) -- 1951
	else -- 1951
		____temp_28 = nil -- 1951
	end -- 1951
	return { -- 1947
		success = true, -- 1948
		session = normalizedSession, -- 1949
		relatedSessions = ____relatedSessions_29, -- 1950
		spawnInfo = ____temp_28, -- 1951
		messages = __TS__ArrayMap( -- 1952
			messages, -- 1952
			function(____, row) return rowToMessage(row) end -- 1952
		), -- 1952
		steps = __TS__ArrayMap( -- 1953
			steps, -- 1953
			function(____, row) return rowToStep(row) end -- 1953
		), -- 1953
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 1954
	} -- 1954
end -- 1924
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools) -- 2211
	local session = getSessionItem(sessionId) -- 2212
	if not session then -- 2212
		return {success = false, message = "session not found"} -- 2214
	end -- 2214
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2214
		return {success = false, message = "session task is finalizing"} -- 2217
	end -- 2217
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2217
		return {success = false, message = "session task is still running"} -- 2220
	end -- 2220
	local message = getMessageItem(messageId) -- 2222
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2222
		return {success = false, message = "message not found"} -- 2224
	end -- 2224
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2226
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2232
	if latestUserMessageId ~= messageId then -- 2232
		return {success = false, message = "only the latest user prompt can be edited"} -- 2234
	end -- 2234
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2236
	if normalizedPrompt == "" then -- 2236
		return {success = false, message = "prompt is empty"} -- 2238
	end -- 2238
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2240
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2241
	local result = startPromptTask( -- 2242
		session, -- 2242
		normalizedPrompt, -- 2242
		messageId, -- 2242
		normalizeDisabledAgentTools(disabledAgentTools) -- 2242
	) -- 2242
	if result.success and #removedStepIds > 0 then -- 2242
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2244
	end -- 2244
	return result -- 2246
end -- 2211
function ____exports.stopSessionTask(sessionId) -- 2249
	local session = getSessionItem(sessionId) -- 2250
	if not session or session.currentTaskId == nil then -- 2250
		return {success = false, message = "session task not found"} -- 2252
	end -- 2252
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2252
		return {success = false, message = "session task is finalizing"} -- 2255
	end -- 2255
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2257
	local stopToken = activeStopTokens[session.currentTaskId] -- 2258
	if not stopToken then -- 2258
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2258
			return {success = true, recovered = true} -- 2261
		end -- 2261
		return {success = false, message = "task is not running"} -- 2263
	end -- 2263
	stopToken.stopped = true -- 2265
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2266
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2267
	return {success = true} -- 2268
end -- 2249
function ____exports.getCurrentTaskId(sessionId) -- 2271
	local ____opt_51 = getSessionItem(sessionId) -- 2271
	return ____opt_51 and ____opt_51.currentTaskId -- 2272
end -- 2271
function ____exports.listRunningSessions() -- 2275
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2276
	local sessions = {} -- 2283
	do -- 2283
		local i = 0 -- 2284
		while i < #rows do -- 2284
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2285
			if session.currentTaskStatus == "RUNNING" then -- 2285
				sessions[#sessions + 1] = session -- 2287
			end -- 2287
			i = i + 1 -- 2284
		end -- 2284
	end -- 2284
	return {success = true, sessions = sessions} -- 2290
end -- 2275
return ____exports -- 2275