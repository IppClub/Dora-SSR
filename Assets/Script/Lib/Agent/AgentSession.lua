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
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildSubAgentMemoryEntryLLMOptions, buildSubAgentMemoryEntryToolSchema, buildSubAgentMemoryEntrySystemPrompt, formatSubAgentMemoryTailMessage, buildSubAgentRecentMessageTail, buildSubAgentMemoryEntryPrompt, buildSubAgentMemoryEntryRetryPrompt, normalizeGeneratedSubAgentMemoryEntry, getMemoryEntryToolFunction, getMemoryEntryPlainContent, decodeMemoryEntryFromPlainContent, hasEmptyMemoryEntryContent, generateSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, setSessionStateForTaskEvent, insertMessage, updateMessage, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS, SUB_AGENT_MEMORY_RESULT_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
function getDefaultUseChineseResponse() -- 240
	local zh = string.match(App.locale, "^zh") -- 241
	return zh ~= nil -- 242
end -- 242
function toStr(v) -- 245
	if v == false or v == nil or v == nil then -- 245
		return "" -- 246
	end -- 246
	return tostring(v) -- 247
end -- 247
function encodeJson(value) -- 250
	local text = safeJsonEncode(value) -- 251
	return text or "" -- 252
end -- 252
function decodeJsonObject(text) -- 255
	if not text or text == "" then -- 255
		return nil -- 256
	end -- 256
	local value = safeJsonDecode(text) -- 257
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 257
		return value -- 259
	end -- 259
	return nil -- 261
end -- 261
function decodeJsonFiles(text) -- 264
	if not text or text == "" then -- 264
		return nil -- 265
	end -- 265
	local value = safeJsonDecode(text) -- 266
	if not value or not __TS__ArrayIsArray(value) then -- 266
		return nil -- 267
	end -- 267
	local files = {} -- 268
	do -- 268
		local i = 0 -- 269
		while i < #value do -- 269
			do -- 269
				local item = value[i + 1] -- 270
				if type(item) ~= "table" then -- 270
					goto __continue14 -- 271
				end -- 271
				files[#files + 1] = { -- 272
					path = sanitizeUTF8(toStr(item.path)), -- 273
					op = sanitizeUTF8(toStr(item.op)) -- 274
				} -- 274
			end -- 274
			::__continue14:: -- 274
			i = i + 1 -- 269
		end -- 269
	end -- 269
	return files -- 277
end -- 277
function decodeChangeSetSummary(value) -- 280
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 280
		return nil -- 281
	end -- 281
	local row = value -- 282
	if row.success ~= true then -- 282
		return nil -- 283
	end -- 283
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 284
	if taskId <= 0 then -- 284
		return nil -- 285
	end -- 285
	local files = {} -- 286
	if __TS__ArrayIsArray(row.files) then -- 286
		do -- 286
			local i = 0 -- 288
			while i < #row.files do -- 288
				do -- 288
					local file = row.files[i + 1] -- 289
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 289
						goto __continue22 -- 290
					end -- 290
					local fileRow = file -- 291
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 292
					if path == "" then -- 292
						goto __continue22 -- 293
					end -- 293
					local checkpointIds = {} -- 294
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 294
						do -- 294
							local j = 0 -- 296
							while j < #fileRow.checkpointIds do -- 296
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 297
								if checkpointId > 0 then -- 297
									checkpointIds[#checkpointIds + 1] = checkpointId -- 298
								end -- 298
								j = j + 1 -- 296
							end -- 296
						end -- 296
					end -- 296
					local op = toStr(fileRow.op) -- 301
					files[#files + 1] = { -- 302
						path = path, -- 303
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 304
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 305
						checkpointIds = checkpointIds -- 306
					} -- 306
				end -- 306
				::__continue22:: -- 306
				i = i + 1 -- 288
			end -- 288
		end -- 288
	end -- 288
	return { -- 310
		success = true, -- 311
		taskId = taskId, -- 312
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 313
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 314
		files = files, -- 315
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 316
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 317
	} -- 317
end -- 317
function takeUtf8Head(text, maxChars) -- 321
	if maxChars <= 0 or text == "" then -- 321
		return "" -- 322
	end -- 322
	local nextPos = utf8.offset(text, maxChars + 1) -- 323
	if nextPos == nil then -- 323
		return text -- 324
	end -- 324
	return string.sub(text, 1, nextPos - 1) -- 325
end -- 325
function normalizeMemoryEntryEvidence(value) -- 328
	local evidence = {} -- 329
	if not __TS__ArrayIsArray(value) then -- 329
		return evidence -- 330
	end -- 330
	do -- 330
		local i = 0 -- 331
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 331
			do -- 331
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 332
				if item == "" then -- 332
					goto __continue35 -- 333
				end -- 333
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 333
					evidence[#evidence + 1] = item -- 335
				end -- 335
			end -- 335
			::__continue35:: -- 335
			i = i + 1 -- 331
		end -- 331
	end -- 331
	return evidence -- 338
end -- 338
function decodeSubAgentMemoryEntry(value) -- 341
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 341
		return nil -- 342
	end -- 342
	local row = value -- 343
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 344
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 345
	local content = takeUtf8Head( -- 346
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 346
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 346
	) -- 346
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 346
		return nil -- 347
	end -- 347
	return { -- 348
		sourceSessionId = sourceSessionId, -- 349
		sourceTaskId = sourceTaskId, -- 350
		content = content, -- 351
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 352
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 353
	} -- 353
end -- 353
function getTaskChangeSetSummary(taskId) -- 357
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 358
	return summary.success and summary or nil -- 359
end -- 359
function queryRows(sql, args) -- 362
	local ____args_0 -- 363
	if args then -- 363
		____args_0 = DB:query(sql, args) -- 363
	else -- 363
		____args_0 = DB:query(sql) -- 363
	end -- 363
	return ____args_0 -- 363
end -- 363
function queryOne(sql, args) -- 366
	local rows = queryRows(sql, args) -- 367
	if not rows or #rows == 0 then -- 367
		return nil -- 368
	end -- 368
	return rows[1] -- 369
end -- 369
function getLastInsertRowId() -- 372
	local row = queryOne("SELECT last_insert_rowid()") -- 373
	return row and (row[1] or 0) or 0 -- 374
end -- 374
function isValidProjectRoot(path) -- 377
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 378
end -- 378
function rowToSession(row) -- 381
	return { -- 382
		id = row[1], -- 383
		projectRoot = toStr(row[2]), -- 384
		title = toStr(row[3]), -- 385
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 386
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 387
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 388
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 389
		status = toStr(row[8]), -- 390
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 391
		currentTaskStatus = toStr(row[10]), -- 392
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 393
		createdAt = row[11], -- 394
		updatedAt = row[12] -- 395
	} -- 395
end -- 395
function rowToMessage(row) -- 399
	return { -- 400
		id = row[1], -- 401
		sessionId = row[2], -- 402
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 403
		role = toStr(row[4]), -- 404
		content = toStr(row[5]), -- 405
		createdAt = row[6], -- 406
		updatedAt = row[7] -- 407
	} -- 407
end -- 407
function rowToStep(row) -- 411
	return { -- 412
		id = row[1], -- 413
		sessionId = row[2], -- 414
		taskId = row[3], -- 415
		step = row[4], -- 416
		tool = toStr(row[5]), -- 417
		status = toStr(row[6]), -- 418
		reason = toStr(row[7]), -- 419
		reasoningContent = toStr(row[8]), -- 420
		params = decodeJsonObject(toStr(row[9])), -- 421
		result = decodeJsonObject(toStr(row[10])), -- 422
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 423
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 424
		files = decodeJsonFiles(toStr(row[13])), -- 425
		createdAt = row[14], -- 426
		updatedAt = row[15] -- 427
	} -- 427
end -- 427
function getMessageItem(messageId) -- 431
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 432
	return row and rowToMessage(row) or nil -- 438
end -- 438
function getStepItem(sessionId, taskId, step) -- 441
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 442
	return row and rowToStep(row) or nil -- 448
end -- 448
function deleteMessageSteps(sessionId, taskId) -- 451
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 452
	local ids = {} -- 457
	do -- 457
		local i = 0 -- 458
		while i < #rows do -- 458
			local row = rows[i + 1] -- 459
			if type(row[1]) == "number" then -- 459
				ids[#ids + 1] = row[1] -- 461
			end -- 461
			i = i + 1 -- 458
		end -- 458
	end -- 458
	if #ids > 0 then -- 458
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 465
	end -- 465
	return ids -- 471
end -- 471
function getSessionRow(sessionId) -- 474
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 475
end -- 475
function getSessionItem(sessionId) -- 483
	local row = getSessionRow(sessionId) -- 484
	return row and rowToSession(row) or nil -- 485
end -- 485
function getTaskPrompt(taskId) -- 488
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 489
	if not row or type(row[1]) ~= "string" then -- 489
		return nil -- 490
	end -- 490
	return toStr(row[1]) -- 491
end -- 491
function getLatestMainSessionByProjectRoot(projectRoot) -- 494
	if not isValidProjectRoot(projectRoot) then -- 494
		return nil -- 495
	end -- 495
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 496
	return row and rowToSession(row) or nil -- 504
end -- 504
function countRunningSubSessions(rootSessionId) -- 507
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 508
	local count = 0 -- 515
	do -- 515
		local i = 0 -- 516
		while i < #rows do -- 516
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 517
			if session.currentTaskStatus == "RUNNING" then -- 517
				count = count + 1 -- 519
			end -- 519
			i = i + 1 -- 516
		end -- 516
	end -- 516
	return count -- 522
end -- 522
function deleteSessionRecords(sessionId, preserveArtifacts) -- 525
	if preserveArtifacts == nil then -- 525
		preserveArtifacts = false -- 525
	end -- 525
	local session = getSessionItem(sessionId) -- 526
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 527
	do -- 527
		local i = 0 -- 528
		while i < #children do -- 528
			local row = children[i + 1] -- 529
			if type(row[1]) == "number" and row[1] > 0 then -- 529
				deleteSessionRecords(row[1], preserveArtifacts) -- 531
			end -- 531
			i = i + 1 -- 528
		end -- 528
	end -- 528
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 534
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 535
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 536
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 537
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 537
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 539
	end -- 539
end -- 539
function getSessionRootId(session) -- 543
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 544
end -- 544
function getRootSessionItem(sessionId) -- 547
	local session = getSessionItem(sessionId) -- 548
	if not session then -- 548
		return nil -- 549
	end -- 549
	return getSessionItem(getSessionRootId(session)) or session -- 550
end -- 550
function listRelatedSessions(sessionId) -- 553
	local root = getRootSessionItem(sessionId) -- 554
	if not root then -- 554
		return {} -- 555
	end -- 555
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 556
	return __TS__ArrayMap( -- 565
		rows, -- 565
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 565
	) -- 565
end -- 565
function getSessionSpawnInfo(session) -- 568
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 569
	if not info then -- 569
		return nil -- 570
	end -- 570
	local ____temp_4 = type(info.sessionId) == "number" and info.sessionId or nil -- 572
	local ____temp_5 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 573
	local ____temp_6 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 574
	local ____temp_7 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 575
	local ____temp_8 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 576
	local ____temp_9 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 577
	local ____temp_10 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 578
	local ____temp_11 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 579
		__TS__ArrayFilter( -- 580
			info.filesHint, -- 580
			function(____, item) return type(item) == "string" end -- 580
		), -- 580
		function(____, item) return sanitizeUTF8(item) end -- 580
	) or nil -- 580
	local ____temp_12 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 582
	local ____temp_2 -- 585
	if info.success == true then -- 585
		____temp_2 = true -- 585
	else -- 585
		local ____temp_1 -- 585
		if info.success == false then -- 585
			____temp_1 = false -- 585
		else -- 585
			____temp_1 = nil -- 585
		end -- 585
		____temp_2 = ____temp_1 -- 585
	end -- 585
	local ____temp_3 -- 586
	if info.cleared == true then -- 586
		____temp_3 = true -- 586
	else -- 586
		____temp_3 = nil -- 586
	end -- 586
	return { -- 571
		sessionId = ____temp_4, -- 572
		rootSessionId = ____temp_5, -- 573
		parentSessionId = ____temp_6, -- 574
		title = ____temp_7, -- 575
		prompt = ____temp_8, -- 576
		goal = ____temp_9, -- 577
		expectedOutput = ____temp_10, -- 578
		filesHint = ____temp_11, -- 579
		status = ____temp_12, -- 582
		success = ____temp_2, -- 585
		cleared = ____temp_3, -- 586
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 587
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 588
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 589
		changeSet = decodeChangeSetSummary(info.changeSet), -- 590
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 591
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 592
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 593
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 594
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 595
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 596
	} -- 596
end -- 596
function ensureDirRecursive(dir) -- 613
	if not dir or dir == "" then -- 613
		return false -- 614
	end -- 614
	if Content:exist(dir) then -- 614
		return Content:isdir(dir) -- 615
	end -- 615
	local parent = Path:getPath(dir) -- 616
	if parent and parent ~= dir and not Content:exist(parent) then -- 616
		if not ensureDirRecursive(parent) then -- 616
			return false -- 619
		end -- 619
	end -- 619
	return Content:mkdir(dir) -- 622
end -- 622
function writeSpawnInfo(projectRoot, memoryScope, value) -- 625
	local dir = Path(projectRoot, ".agent", memoryScope) -- 626
	if not Content:exist(dir) then -- 626
		ensureDirRecursive(dir) -- 628
	end -- 628
	local path = Path(dir, SPAWN_INFO_FILE) -- 630
	local text = safeJsonEncode(value) -- 631
	if not text then -- 631
		return false -- 632
	end -- 632
	local content = text .. "\n" -- 633
	if not Content:save(path, content) then -- 633
		return false -- 635
	end -- 635
	Tools.sendWebIDEFileUpdate(path, true, content) -- 637
	return true -- 638
end -- 638
function readSpawnInfo(projectRoot, memoryScope) -- 641
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 642
	if not Content:exist(path) then -- 642
		return nil -- 643
	end -- 643
	local text = Content:load(path) -- 644
	if not text or __TS__StringTrim(text) == "" then -- 644
		return nil -- 645
	end -- 645
	local value = safeJsonDecode(text) -- 646
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 646
		return value -- 648
	end -- 648
	return nil -- 650
end -- 650
function getArtifactRelativeDir(memoryScope) -- 653
	return Path(".agent", memoryScope) -- 654
end -- 654
function getArtifactDir(projectRoot, memoryScope) -- 657
	return Path( -- 658
		projectRoot, -- 658
		getArtifactRelativeDir(memoryScope) -- 658
	) -- 658
end -- 658
function getResultRelativePath(memoryScope) -- 661
	return Path( -- 662
		getArtifactRelativeDir(memoryScope), -- 662
		RESULT_FILE -- 662
	) -- 662
end -- 662
function getResultPath(projectRoot, memoryScope) -- 665
	return Path( -- 666
		projectRoot, -- 666
		getResultRelativePath(memoryScope) -- 666
	) -- 666
end -- 666
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 669
	if not resultFilePath or resultFilePath == "" then -- 669
		return "" -- 670
	end -- 670
	local path = Path(projectRoot, resultFilePath) -- 671
	if not Content:exist(path) then -- 671
		return "" -- 672
	end -- 672
	local text = sanitizeUTF8(Content:load(path)) -- 673
	if not text or __TS__StringTrim(text) == "" then -- 673
		return "" -- 674
	end -- 674
	local marker = "\n## Summary\n" -- 675
	local start = string.find(text, marker, 1, true) -- 676
	if start ~= nil then -- 676
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 678
	end -- 678
	return __TS__StringTrim(text) -- 680
end -- 680
function buildSubAgentMemoryEntryLLMOptions(llmConfig) -- 683
	local options = { -- 684
		temperature = llmConfig.temperature or SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, -- 685
		max_tokens = math.min(llmConfig.maxTokens or SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS) -- 686
	} -- 686
	if llmConfig.reasoningEffort then -- 686
		options.reasoning_effort = __TS__StringTrim(llmConfig.reasoningEffort) -- 689
	end -- 689
	if type(options.reasoning_effort) ~= "string" or __TS__StringTrim(options.reasoning_effort) == "" then -- 689
		__TS__Delete(options, "reasoning_effort") -- 692
	end -- 692
	return options -- 694
end -- 694
function buildSubAgentMemoryEntryToolSchema() -- 697
	return {{type = "function", ["function"] = {name = "save_sub_agent_memory_entry", description = "Save one durable memory paragraph extracted from a completed sub-agent session.", parameters = {type = "object", properties = {content = {type = "string", description = "A concise paragraph of key information worth carrying into future main-agent context. Use an empty string when nothing durable should be saved."}, evidence = {type = "array", items = {type = "string"}, description = "Optional short file paths, artifact paths, or concrete anchors that support the memory paragraph."}}, required = {"content"}}}}} -- 698
end -- 698
function buildSubAgentMemoryEntrySystemPrompt() -- 722
	return "You generate a durable memory entry for the parent Dora agent.\nPrefer calling save_sub_agent_memory_entry when tool calling is available.\nIf you cannot call tools, output exactly one JSON object with this shape: {\"content\":\"...\",\"evidence\":[\"...\"]}.\n\nUse the completed sub-agent conversation and final result to decide whether anything should be remembered.\nReturn a single compact paragraph in content, similar to a history entry.\nFocus on durable facts: implemented behavior, important design decisions, constraints, discovered project conventions, or follow-up risks.\nDo not include generic progress narration, praise, or temporary execution details.\nIf there is no information likely to help future work, set content to an empty string.\nKeep evidence short and concrete, such as touched file paths or result artifact paths." -- 723
end -- 723
function formatSubAgentMemoryTailMessage(message) -- 735
	local lines = {"role: " .. sanitizeUTF8(toStr(message.role))} -- 736
	if type(message.name) == "string" and message.name ~= "" then -- 736
		lines[#lines + 1] = "name: " .. sanitizeUTF8(message.name) -- 738
	end -- 738
	if type(message.tool_call_id) == "string" and message.tool_call_id ~= "" then -- 738
		lines[#lines + 1] = "tool_call_id: " .. sanitizeUTF8(message.tool_call_id) -- 741
	end -- 741
	local content = type(message.content) == "string" and clipTextToTokenBudget( -- 743
		sanitizeUTF8(message.content), -- 744
		SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS -- 744
	) or "" -- 744
	if content ~= "" then -- 744
		lines[#lines + 1] = "content:\n" .. content -- 747
	end -- 747
	if __TS__ArrayIsArray(message.tool_calls) and #message.tool_calls > 0 then -- 747
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 750
		if toolCallsText ~= nil and toolCallsText ~= "" then -- 750
			lines[#lines + 1] = "tool_calls:\n" .. clipTextToTokenBudget(toolCallsText, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS) -- 752
		end -- 752
	end -- 752
	return table.concat(lines, "\n") -- 755
end -- 755
function buildSubAgentRecentMessageTail(messages) -- 758
	local parts = {} -- 759
	local totalTokens = 0 -- 760
	local count = 0 -- 761
	do -- 761
		local i = #messages - 1 -- 762
		while i >= 0 and count < SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES do -- 762
			do -- 762
				local text = formatSubAgentMemoryTailMessage(messages[i + 1]) -- 763
				if text == "" then -- 763
					goto __continue122 -- 764
				end -- 764
				local tokens = estimateTextTokens(text) -- 765
				if #parts > 0 and totalTokens + tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS then -- 765
					break -- 766
				end -- 766
				if tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS and #parts == 0 then -- 766
					__TS__ArrayUnshift( -- 768
						parts, -- 768
						clipTextToTokenBudget(text, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS) -- 768
					) -- 768
					break -- 769
				end -- 769
				__TS__ArrayUnshift(parts, text) -- 771
				totalTokens = totalTokens + tokens -- 772
				count = count + 1 -- 773
			end -- 773
			::__continue122:: -- 773
			i = i - 1 -- 762
		end -- 762
	end -- 762
	return #parts > 0 and table.concat(parts, "\n\n---\n\n") or "(empty)"
end -- 775
function buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 778
	local ____opt_13 = record.changeSet -- 778
	local files = ____opt_13 and ____opt_13.files or ({}) -- 779
	local changedFiles = table.concat( -- 780
		__TS__ArrayMap( -- 780
			files, -- 780
			function(____, file) return ((("- " .. file.path) .. " (") .. file.op) .. ")" end -- 780
		), -- 780
		"\n" -- 780
	) -- 780
	local boundedMemoryContext = clipTextToTokenBudget(memoryContext ~= "" and memoryContext or "(empty)", SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS) -- 781
	local boundedResultText = clipTextToTokenBudget(resultText ~= "" and resultText or "(empty)", SUB_AGENT_MEMORY_RESULT_MAX_TOKENS) -- 782
	return ((((((((((((((((((((((("Sub-agent memory context:\n" .. boundedMemoryContext) .. "\n\nSub-agent task metadata:\n- sessionId: ") .. tostring(record.sessionId)) .. "\n- taskId: ") .. tostring(record.sourceTaskId)) .. "\n- title: ") .. record.title) .. "\n- goal: ") .. record.goal) .. "\n- prompt: ") .. record.prompt) .. "\n- expectedOutput: ") .. (record.expectedOutput or "")) .. "\n- resultFilePath: ") .. record.resultFilePath) .. "\n- finishedAt: ") .. record.finishedAt) .. "\n\nChanged files:\n") .. (changedFiles ~= "" and changedFiles or "- none")) .. "\n\nFinal sub-agent result:\n") .. boundedResultText) .. "\n\nRecent conversation tail:\n") .. recentMessageTail) .. "\n\nGenerate the memory entry now." -- 783
end -- 783
function buildSubAgentMemoryEntryRetryPrompt(lastError) -- 808
	return ("Previous memory entry response was invalid: " .. lastError) .. "\n\nRetry with exactly one JSON object and no Markdown fences, no prose, no tool call.\nSchema:\n{\"content\":\"one concise durable memory paragraph, or empty string if nothing should be saved\",\"evidence\":[\"optional short file path or artifact path\"]}\n\nRules:\n- content must be a string.\n- evidence must be an array of strings.\n- Use {\"content\":\"\",\"evidence\":[]} when there is no durable memory to save." -- 809
end -- 809
function normalizeGeneratedSubAgentMemoryEntry(value, record) -- 821
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 821
		return nil -- 822
	end -- 822
	local row = value -- 823
	local content = takeUtf8Head( -- 824
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 824
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 824
	) -- 824
	if content == "" then -- 824
		return nil -- 825
	end -- 825
	return { -- 826
		sourceSessionId = record.sessionId, -- 827
		sourceTaskId = record.sourceTaskId, -- 828
		content = content, -- 829
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 830
		createdAt = record.finishedAt -- 831
	} -- 831
end -- 831
function getMemoryEntryToolFunction(response) -- 835
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 835
		return nil -- 836
	end -- 836
	local row = response -- 837
	local choices = row.choices -- 838
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 838
		return nil -- 839
	end -- 839
	local ____opt_15 = choices[1] -- 839
	if ____opt_15 ~= nil then -- 839
		____opt_15 = ____opt_15.message -- 839
	end -- 839
	local message = ____opt_15 -- 840
	local ____opt_result_19 -- 840
	if message ~= nil then -- 840
		____opt_result_19 = message.tool_calls -- 840
	end -- 840
	local toolCalls = ____opt_result_19 -- 841
	if not __TS__ArrayIsArray(toolCalls) then -- 841
		return nil -- 842
	end -- 842
	do -- 842
		local i = 0 -- 843
		while i < #toolCalls do -- 843
			local ____opt_20 = toolCalls[i + 1] -- 843
			if ____opt_20 ~= nil then -- 843
				____opt_20 = ____opt_20["function"] -- 843
			end -- 843
			local fn = ____opt_20 -- 844
			if (fn and fn.name) == "save_sub_agent_memory_entry" then -- 844
				return fn -- 845
			end -- 845
			i = i + 1 -- 843
		end -- 843
	end -- 843
	return nil -- 847
end -- 847
function getMemoryEntryPlainContent(response) -- 850
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 850
		return "" -- 851
	end -- 851
	local row = response -- 852
	local choices = row.choices -- 853
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 853
		return "" -- 854
	end -- 854
	local ____opt_24 = choices[1] -- 854
	if ____opt_24 ~= nil then -- 854
		____opt_24 = ____opt_24.message -- 854
	end -- 854
	local message = ____opt_24 -- 855
	local ____opt_result_28 -- 855
	if message ~= nil then -- 855
		____opt_result_28 = message.content -- 855
	end -- 855
	return type(____opt_result_28) == "string" and __TS__StringTrim(sanitizeUTF8(message.content)) or "" -- 856
end -- 856
function decodeMemoryEntryFromPlainContent(content) -- 859
	if content == "" then -- 859
		return nil -- 860
	end -- 860
	local direct = safeJsonDecode(content) -- 861
	if direct ~= nil then -- 861
		return direct -- 862
	end -- 862
	local start = string.find(content, "{", 1, true) -- 863
	if start == nil then -- 863
		return nil -- 864
	end -- 864
	local ____end = #content -- 865
	while ____end >= start do -- 865
		local candidate = string.sub(content, start, ____end) -- 867
		local value = safeJsonDecode(candidate) -- 868
		if value ~= nil then -- 868
			return value -- 869
		end -- 869
		____end = ____end - 1 -- 870
	end -- 870
	return nil -- 872
end -- 872
function hasEmptyMemoryEntryContent(value) -- 875
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 875
		return false -- 876
	end -- 876
	local row = value -- 877
	return type(row.content) == "string" and __TS__StringTrim(sanitizeUTF8(row.content)) == "" -- 878
end -- 878
function generateSubAgentMemoryEntry(session, record, resultText) -- 881
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 881
		if not record.success then -- 881
			return ____awaiter_resolve(nil, {}) -- 881
		end -- 881
		local configRes = getActiveLLMConfig() -- 883
		if not configRes.success then -- 883
			return ____awaiter_resolve(nil, {error = configRes.message}) -- 883
		end -- 883
		local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 887
		local persisted = storage:readSessionState() -- 888
		local memoryContext = storage:readMemory() -- 889
		local recentMessageTail = buildSubAgentRecentMessageTail(persisted.messages) -- 890
		local prompt = buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 891
		local tools = configRes.config.supportsFunctionCalling and buildSubAgentMemoryEntryToolSchema() or nil -- 892
		local lastError = "missing memory entry" -- 893
		do -- 893
			local attempt = 0 -- 894
			while attempt < SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY do -- 894
				do -- 894
					local useTools = attempt == 0 and tools ~= nil -- 895
					local messages = { -- 896
						{ -- 897
							role = "system", -- 897
							content = buildSubAgentMemoryEntrySystemPrompt() -- 897
						}, -- 897
						{ -- 898
							role = "user", -- 899
							content = attempt == 0 and prompt or (prompt .. "\n\n") .. buildSubAgentMemoryEntryRetryPrompt(lastError) -- 900
						} -- 900
					} -- 900
					local response = __TS__Await(callLLM( -- 905
						messages, -- 906
						__TS__ObjectAssign( -- 907
							{}, -- 907
							buildSubAgentMemoryEntryLLMOptions(configRes.config), -- 908
							useTools and ({tools = tools}) or ({}) -- 909
						), -- 909
						configRes.config -- 911
					)) -- 911
					if not response.success then -- 911
						lastError = response.message -- 914
						if useTools then -- 914
							Log("Warn", "[AgentSession] sub session memory entry tool request failed, retrying without tools: " .. response.message) -- 916
						end -- 916
						goto __continue154 -- 918
					end -- 918
					local fn = getMemoryEntryToolFunction(response.response) -- 920
					local argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 921
					if fn ~= nil and argsText ~= "" then -- 921
						local args, err = safeJsonDecode(argsText) -- 923
						if err ~= nil or args == nil then -- 923
							lastError = "invalid memory entry tool arguments: " .. tostring(err) -- 925
							goto __continue154 -- 926
						end -- 926
						if hasEmptyMemoryEntryContent(args) then -- 926
							return ____awaiter_resolve(nil, {}) -- 926
						end -- 926
						local entry = normalizeGeneratedSubAgentMemoryEntry(args, record) -- 929
						if entry ~= nil then -- 929
							return ____awaiter_resolve(nil, {entry = entry}) -- 929
						end -- 929
						lastError = "invalid memory entry tool arguments shape" -- 931
						goto __continue154 -- 932
					end -- 932
					local plainContent = getMemoryEntryPlainContent(response.response) -- 934
					local plainArgs = decodeMemoryEntryFromPlainContent(plainContent) -- 935
					if plainArgs ~= nil then -- 935
						if hasEmptyMemoryEntryContent(plainArgs) then -- 935
							return ____awaiter_resolve(nil, {}) -- 935
						end -- 935
						local entry = normalizeGeneratedSubAgentMemoryEntry(plainArgs, record) -- 938
						if entry ~= nil then -- 938
							return ____awaiter_resolve(nil, {entry = entry}) -- 938
						end -- 938
						lastError = "invalid memory entry JSON shape" -- 940
						goto __continue154 -- 941
					end -- 941
					lastError = "LLM did not return memory entry tool call or JSON content" -- 943
				end -- 943
				::__continue154:: -- 943
				attempt = attempt + 1 -- 894
			end -- 894
		end -- 894
		return ____awaiter_resolve(nil, {error = lastError}) -- 894
	end) -- 894
end -- 894
function containsNormalizedText(text, query) -- 948
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 949
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 950
	if normalizedQuery == "" then -- 950
		return true -- 951
	end -- 951
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 952
end -- 952
function getSubAgentDisplayKey(item) -- 955
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 961
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 962
	local label = goal ~= "" and goal or title -- 963
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 964
end -- 964
function writeSubAgentResultFile(session, record, resultText) -- 967
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 968
	if not Content:exist(dir) then -- 968
		ensureDirRecursive(dir) -- 970
	end -- 970
	local ____array_29 = __TS__SparseArrayNew( -- 970
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 973
		"- Status: " .. record.status, -- 974
		"- Success: " .. (record.success and "true" or "false"), -- 975
		"- Session ID: " .. tostring(record.sessionId), -- 976
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 977
		"- Goal: " .. record.goal, -- 978
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 979
	) -- 979
	__TS__SparseArrayPush( -- 979
		____array_29, -- 979
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 980
	) -- 980
	__TS__SparseArrayPush( -- 980
		____array_29, -- 980
		"- Finished At: " .. record.finishedAt, -- 981
		"", -- 982
		"## Summary", -- 983
		resultText ~= "" and resultText or "(empty)" -- 984
	) -- 984
	local lines = {__TS__SparseArraySpread(____array_29)} -- 972
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 986
	local content = table.concat(lines, "\n") .. "\n" -- 987
	if not Content:save(path, content) then -- 987
		return false -- 989
	end -- 989
	Tools.sendWebIDEFileUpdate(path, true, content) -- 991
	return true -- 992
end -- 992
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 995
	local dir = Path(projectRoot, ".agent", "subagents") -- 996
	if not Content:exist(dir) or not Content:isdir(dir) then -- 996
		return {} -- 997
	end -- 997
	local items = {} -- 998
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 999
		do -- 999
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1000
			if not Content:exist(path) or not Content:isdir(path) then -- 1000
				goto __continue172 -- 1001
			end -- 1001
			local info = readSpawnInfo( -- 1002
				projectRoot, -- 1002
				Path( -- 1002
					"subagents", -- 1002
					Path:getFilename(path) -- 1002
				) -- 1002
			) -- 1002
			if not info then -- 1002
				goto __continue172 -- 1003
			end -- 1003
			local sessionId = tonumber(info.sessionId) -- 1004
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1005
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1006
			local status = sanitizeUTF8(toStr(info.status)) -- 1007
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1007
				goto __continue172 -- 1008
			end -- 1008
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1008
				goto __continue172 -- 1009
			end -- 1009
			items[#items + 1] = { -- 1010
				sessionId = sessionId, -- 1011
				rootSessionId = infoRootSessionId, -- 1012
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1013
				title = sanitizeUTF8(toStr(info.title)), -- 1014
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1015
				goal = sanitizeUTF8(toStr(info.goal)), -- 1016
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1017
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1018
					__TS__ArrayFilter( -- 1019
						info.filesHint, -- 1019
						function(____, item) return type(item) == "string" end -- 1019
					), -- 1019
					function(____, item) return sanitizeUTF8(item) end -- 1019
				) or ({}), -- 1019
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1021
				success = info.success == true, -- 1022
				cleared = info.cleared == true, -- 1023
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1024
				artifactDir = sanitizeUTF8(toStr(info.artifactDir)) or getArtifactRelativeDir(Path( -- 1025
					"subagents", -- 1025
					Path:getFilename(path) -- 1025
				)), -- 1025
				sourceTaskId = sourceTaskId or 0, -- 1026
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1027
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1028
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1029
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1030
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1031
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1032
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1033
			} -- 1033
		end -- 1033
		::__continue172:: -- 1033
	end -- 1033
	__TS__ArraySort( -- 1036
		items, -- 1036
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1036
	) -- 1036
	return items -- 1037
end -- 1037
function getPendingHandoffDir(projectRoot, memoryScope) -- 1040
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1041
end -- 1041
function writePendingHandoff(projectRoot, memoryScope, value) -- 1044
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1045
	if not Content:exist(dir) then -- 1045
		ensureDirRecursive(dir) -- 1047
	end -- 1047
	local path = Path(dir, value.id .. ".json") -- 1049
	local text = safeJsonEncode(value) -- 1050
	if not text then -- 1050
		return false -- 1051
	end -- 1051
	return Content:save(path, text .. "\n") -- 1052
end -- 1052
function listPendingHandoffs(projectRoot, memoryScope) -- 1055
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1056
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1056
		return {} -- 1057
	end -- 1057
	local items = {} -- 1058
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1059
		do -- 1059
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1060
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1060
				goto __continue187 -- 1061
			end -- 1061
			local text = Content:load(path) -- 1062
			if not text or __TS__StringTrim(text) == "" then -- 1062
				goto __continue187 -- 1063
			end -- 1063
			local value = safeJsonDecode(text) -- 1064
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 1064
				goto __continue187 -- 1065
			end -- 1065
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1066
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1067
			local id = sanitizeUTF8(toStr(value.id)) -- 1068
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1069
			local message = sanitizeUTF8(toStr(value.message)) -- 1070
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1071
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1072
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1073
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1073
				goto __continue187 -- 1075
			end -- 1075
			items[#items + 1] = { -- 1077
				id = id, -- 1078
				sourceSessionId = sourceSessionId, -- 1079
				sourceTitle = sourceTitle, -- 1080
				sourceTaskId = sourceTaskId, -- 1081
				message = message, -- 1082
				prompt = prompt, -- 1083
				goal = goal, -- 1084
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1085
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1086
					__TS__ArrayFilter( -- 1087
						value.filesHint, -- 1087
						function(____, item) return type(item) == "string" end -- 1087
					), -- 1087
					function(____, item) return sanitizeUTF8(item) end -- 1087
				) or ({}), -- 1087
				success = value.success == true, -- 1089
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1090
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1091
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1092
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1093
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1094
				createdAt = createdAt -- 1095
			} -- 1095
		end -- 1095
		::__continue187:: -- 1095
	end -- 1095
	__TS__ArraySort( -- 1098
		items, -- 1098
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1098
	) -- 1098
	return items -- 1099
end -- 1099
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1102
	local path = Path( -- 1103
		getPendingHandoffDir(projectRoot, memoryScope), -- 1103
		id .. ".json" -- 1103
	) -- 1103
	if Content:exist(path) then -- 1103
		Content:remove(path) -- 1105
	end -- 1105
end -- 1105
function normalizePromptText(prompt) -- 1109
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1110
end -- 1110
function normalizePromptTextSafe(prompt) -- 1113
	if type(prompt) == "string" then -- 1113
		local normalized = normalizePromptText(prompt) -- 1115
		if normalized ~= "" then -- 1115
			return normalized -- 1116
		end -- 1116
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1117
		if sanitized ~= "" then -- 1117
			return truncateAgentUserPrompt(sanitized) -- 1119
		end -- 1119
		return "" -- 1121
	end -- 1121
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1123
	if text == "" then -- 1123
		return "" -- 1124
	end -- 1124
	return truncateAgentUserPrompt(text) -- 1125
end -- 1125
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1128
	local sections = {} -- 1129
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1130
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1131
	local normalizedFiles = __TS__ArrayFilter( -- 1132
		__TS__ArrayMap( -- 1132
			__TS__ArrayFilter( -- 1132
				filesHint or ({}), -- 1132
				function(____, item) return type(item) == "string" end -- 1133
			), -- 1133
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1134
		), -- 1134
		function(____, item) return item ~= "" end -- 1135
	) -- 1135
	if normalizedTitle ~= "" then -- 1135
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1137
	end -- 1137
	if normalizedExpected ~= "" then -- 1137
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1140
	end -- 1140
	if #normalizedFiles > 0 then -- 1140
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1143
	end -- 1143
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1145
end -- 1145
function normalizeSessionRuntimeState(session) -- 1148
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1148
		return session -- 1150
	end -- 1150
	if activeStopTokens[session.currentTaskId] then -- 1150
		return session -- 1153
	end -- 1153
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1155
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1156
	return __TS__ObjectAssign( -- 1157
		{}, -- 1157
		session, -- 1158
		{ -- 1157
			status = "STOPPED", -- 1159
			currentTaskStatus = "STOPPED", -- 1160
			updatedAt = now() -- 1161
		} -- 1161
	) -- 1161
end -- 1161
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1165
	DB:exec( -- 1166
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1166
		{ -- 1170
			status, -- 1171
			currentTaskId or 0, -- 1172
			currentTaskStatus or status, -- 1173
			now(), -- 1174
			sessionId -- 1175
		} -- 1175
	) -- 1175
end -- 1175
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1180
	if taskId == nil or taskId <= 0 then -- 1180
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1182
		return -- 1183
	end -- 1183
	local row = getSessionRow(sessionId) -- 1185
	if not row then -- 1185
		return -- 1186
	end -- 1186
	local session = rowToSession(row) -- 1187
	if session.currentTaskId ~= taskId then -- 1187
		Log( -- 1189
			"Info", -- 1189
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1189
		) -- 1189
		return -- 1190
	end -- 1190
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1192
end -- 1192
function insertMessage(sessionId, role, content, taskId) -- 1195
	local t = now() -- 1196
	DB:exec( -- 1197
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1197
		{ -- 1200
			sessionId, -- 1201
			taskId or 0, -- 1202
			role, -- 1203
			sanitizeUTF8(content), -- 1204
			t, -- 1205
			t -- 1206
		} -- 1206
	) -- 1206
	return getLastInsertRowId() -- 1209
end -- 1209
function updateMessage(messageId, content) -- 1212
	DB:exec( -- 1213
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1213
		{ -- 1215
			sanitizeUTF8(content), -- 1215
			now(), -- 1215
			messageId -- 1215
		} -- 1215
	) -- 1215
end -- 1215
function upsertAssistantMessage(sessionId, taskId, content) -- 1219
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1220
	if row and type(row[1]) == "number" then -- 1220
		updateMessage(row[1], content) -- 1227
		return row[1] -- 1228
	end -- 1228
	return insertMessage(sessionId, "assistant", content, taskId) -- 1230
end -- 1230
function upsertStep(sessionId, taskId, step, tool, patch) -- 1233
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1243
	local reason = sanitizeUTF8(patch.reason or "") -- 1247
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1248
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1249
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1250
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1251
	local statusPatch = patch.status or "" -- 1252
	local status = patch.status or "PENDING" -- 1253
	if not row then -- 1253
		local t = now() -- 1255
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1256
			sessionId, -- 1260
			taskId, -- 1261
			step, -- 1262
			tool, -- 1263
			status, -- 1264
			reason, -- 1265
			reasoningContent, -- 1266
			paramsJson, -- 1267
			resultJson, -- 1268
			patch.checkpointId or 0, -- 1269
			patch.checkpointSeq or 0, -- 1270
			filesJson, -- 1271
			t, -- 1272
			t -- 1273
		}) -- 1273
		return -- 1276
	end -- 1276
	DB:exec( -- 1278
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1278
		{ -- 1290
			tool, -- 1291
			statusPatch, -- 1292
			status, -- 1293
			reason, -- 1294
			reason, -- 1295
			reasoningContent, -- 1296
			reasoningContent, -- 1297
			paramsJson, -- 1298
			paramsJson, -- 1299
			resultJson, -- 1300
			resultJson, -- 1301
			patch.checkpointId or 0, -- 1302
			patch.checkpointId or 0, -- 1303
			patch.checkpointSeq or 0, -- 1304
			patch.checkpointSeq or 0, -- 1305
			filesJson, -- 1306
			filesJson, -- 1307
			now(), -- 1308
			row[1] -- 1309
		} -- 1309
	) -- 1309
end -- 1309
function getNextStepNumber(sessionId, taskId) -- 1314
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1315
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1319
	return math.max(0, current) + 1 -- 1320
end -- 1320
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1323
	if status == nil then -- 1323
		status = "DONE" -- 1331
	end -- 1331
	local step = getNextStepNumber(sessionId, taskId) -- 1333
	upsertStep( -- 1334
		sessionId, -- 1334
		taskId, -- 1334
		step, -- 1334
		tool, -- 1334
		{status = status, reason = reason, params = params, result = result} -- 1334
	) -- 1334
	return getStepItem(sessionId, taskId, step) -- 1340
end -- 1340
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1343
	if taskId <= 0 then -- 1343
		return -- 1344
	end -- 1344
	if finalSteps ~= nil and finalSteps >= 0 then -- 1344
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1346
	end -- 1346
	if not finalStatus then -- 1346
		return -- 1352
	end -- 1352
	if finalSteps ~= nil and finalSteps >= 0 then -- 1352
		DB:exec( -- 1354
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1354
			{ -- 1358
				finalStatus, -- 1358
				now(), -- 1358
				sessionId, -- 1358
				taskId, -- 1358
				finalSteps -- 1358
			} -- 1358
		) -- 1358
		return -- 1360
	end -- 1360
	DB:exec( -- 1362
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1362
		{ -- 1366
			finalStatus, -- 1366
			now(), -- 1366
			sessionId, -- 1366
			taskId -- 1366
		} -- 1366
	) -- 1366
end -- 1366
function emitAgentSessionPatch(sessionId, patch) -- 1393
	if HttpServer.wsConnectionCount == 0 then -- 1393
		return -- 1395
	end -- 1395
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1397
	if not text then -- 1397
		return -- 1402
	end -- 1402
	emit("AppWS", "Send", text) -- 1403
end -- 1403
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1406
	emitAgentSessionPatch( -- 1407
		sessionId, -- 1407
		{ -- 1407
			sessionDeleted = true, -- 1408
			relatedSessions = listRelatedSessions(rootSessionId) -- 1409
		} -- 1409
	) -- 1409
	local rootSession = getSessionItem(rootSessionId) -- 1411
	if rootSession then -- 1411
		emitAgentSessionPatch( -- 1413
			rootSessionId, -- 1413
			{ -- 1413
				session = rootSession, -- 1414
				relatedSessions = listRelatedSessions(rootSessionId) -- 1415
			} -- 1415
		) -- 1415
	end -- 1415
end -- 1415
function flushPendingSubAgentHandoffs(rootSession) -- 1420
	if rootSession.kind ~= "main" then -- 1420
		return -- 1421
	end -- 1421
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1421
		return -- 1423
	end -- 1423
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1425
	if #items == 0 then -- 1425
		return -- 1426
	end -- 1426
	local handoffTaskId = 0 -- 1427
	local ____rootSession_currentTaskId_30 -- 1428
	if rootSession.currentTaskId then -- 1428
		____rootSession_currentTaskId_30 = getTaskPrompt(rootSession.currentTaskId) -- 1428
	else -- 1428
		____rootSession_currentTaskId_30 = nil -- 1428
	end -- 1428
	local currentTaskPrompt = ____rootSession_currentTaskId_30 -- 1428
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1428
		handoffTaskId = rootSession.currentTaskId -- 1436
	else -- 1436
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1438
		if not taskRes.success then -- 1438
			Log( -- 1440
				"Warn", -- 1440
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1440
			) -- 1440
			return -- 1441
		end -- 1441
		handoffTaskId = taskRes.taskId -- 1443
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1444
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1445
		emitAgentSessionPatch( -- 1446
			rootSession.id, -- 1446
			{session = getSessionItem(rootSession.id)} -- 1446
		) -- 1446
	end -- 1446
	do -- 1446
		local i = 0 -- 1450
		while i < #items do -- 1450
			local item = items[i + 1] -- 1451
			local step = appendSystemStep( -- 1452
				rootSession.id, -- 1453
				handoffTaskId, -- 1454
				"sub_agent_handoff", -- 1455
				"sub_agent_handoff", -- 1456
				item.message, -- 1457
				{ -- 1458
					sourceSessionId = item.sourceSessionId, -- 1459
					sourceTitle = item.sourceTitle, -- 1460
					sourceTaskId = item.sourceTaskId, -- 1461
					success = item.success == true, -- 1462
					summary = item.message, -- 1463
					resultFilePath = item.resultFilePath or "", -- 1464
					artifactDir = item.artifactDir or "", -- 1465
					finishedAt = item.finishedAt or "", -- 1466
					changeSet = item.changeSet, -- 1467
					memoryEntry = item.memoryEntry -- 1468
				}, -- 1468
				{ -- 1470
					sourceSessionId = item.sourceSessionId, -- 1471
					sourceTitle = item.sourceTitle, -- 1472
					sourceTaskId = item.sourceTaskId, -- 1473
					prompt = item.prompt, -- 1474
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1475
					expectedOutput = item.expectedOutput or "", -- 1476
					filesHint = item.filesHint or ({}), -- 1477
					resultFilePath = item.resultFilePath or "", -- 1478
					artifactDir = item.artifactDir or "", -- 1479
					changeSet = item.changeSet, -- 1480
					memoryEntry = item.memoryEntry -- 1481
				}, -- 1481
				"DONE" -- 1483
			) -- 1483
			if step then -- 1483
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1486
			end -- 1486
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1488
			i = i + 1 -- 1450
		end -- 1450
	end -- 1450
end -- 1450
function applyEvent(sessionId, event) -- 1492
	repeat -- 1492
		local ____switch249 = event.type -- 1492
		local ____cond249 = ____switch249 == "task_started" -- 1492
		if ____cond249 then -- 1492
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1495
			emitAgentSessionPatch( -- 1496
				sessionId, -- 1496
				{session = getSessionItem(sessionId)} -- 1496
			) -- 1496
			break -- 1499
		end -- 1499
		____cond249 = ____cond249 or ____switch249 == "decision_made" -- 1499
		if ____cond249 then -- 1499
			upsertStep( -- 1501
				sessionId, -- 1501
				event.taskId, -- 1501
				event.step, -- 1501
				event.tool, -- 1501
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1501
			) -- 1501
			emitAgentSessionPatch( -- 1507
				sessionId, -- 1507
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1507
			) -- 1507
			break -- 1510
		end -- 1510
		____cond249 = ____cond249 or ____switch249 == "tool_started" -- 1510
		if ____cond249 then -- 1510
			upsertStep( -- 1512
				sessionId, -- 1512
				event.taskId, -- 1512
				event.step, -- 1512
				event.tool, -- 1512
				{status = "RUNNING"} -- 1512
			) -- 1512
			emitAgentSessionPatch( -- 1515
				sessionId, -- 1515
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1515
			) -- 1515
			break -- 1518
		end -- 1518
		____cond249 = ____cond249 or ____switch249 == "tool_finished" -- 1518
		if ____cond249 then -- 1518
			upsertStep( -- 1520
				sessionId, -- 1520
				event.taskId, -- 1520
				event.step, -- 1520
				event.tool, -- 1520
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1520
			) -- 1520
			emitAgentSessionPatch( -- 1525
				sessionId, -- 1525
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1525
			) -- 1525
			break -- 1528
		end -- 1528
		____cond249 = ____cond249 or ____switch249 == "checkpoint_created" -- 1528
		if ____cond249 then -- 1528
			upsertStep( -- 1530
				sessionId, -- 1530
				event.taskId, -- 1530
				event.step, -- 1530
				event.tool, -- 1530
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1530
			) -- 1530
			emitAgentSessionPatch( -- 1535
				sessionId, -- 1535
				{ -- 1535
					step = getStepItem(sessionId, event.taskId, event.step), -- 1536
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1537
				} -- 1537
			) -- 1537
			break -- 1539
		end -- 1539
		____cond249 = ____cond249 or ____switch249 == "memory_compression_started" -- 1539
		if ____cond249 then -- 1539
			upsertStep( -- 1541
				sessionId, -- 1541
				event.taskId, -- 1541
				event.step, -- 1541
				event.tool, -- 1541
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1541
			) -- 1541
			emitAgentSessionPatch( -- 1546
				sessionId, -- 1546
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1546
			) -- 1546
			break -- 1549
		end -- 1549
		____cond249 = ____cond249 or ____switch249 == "memory_compression_finished" -- 1549
		if ____cond249 then -- 1549
			upsertStep( -- 1551
				sessionId, -- 1551
				event.taskId, -- 1551
				event.step, -- 1551
				event.tool, -- 1551
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1551
			) -- 1551
			emitAgentSessionPatch( -- 1556
				sessionId, -- 1556
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1556
			) -- 1556
			break -- 1559
		end -- 1559
		____cond249 = ____cond249 or ____switch249 == "assistant_message_updated" -- 1559
		if ____cond249 then -- 1559
			do -- 1559
				upsertStep( -- 1561
					sessionId, -- 1561
					event.taskId, -- 1561
					event.step, -- 1561
					"message", -- 1561
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1561
				) -- 1561
				emitAgentSessionPatch( -- 1566
					sessionId, -- 1566
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1566
				) -- 1566
				break -- 1569
			end -- 1569
		end -- 1569
		____cond249 = ____cond249 or ____switch249 == "task_finished" -- 1569
		if ____cond249 then -- 1569
			do -- 1569
				local ____opt_31 = activeStopTokens[event.taskId or -1] -- 1569
				local stopped = (____opt_31 and ____opt_31.stopped) == true -- 1572
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1573
				local session = getSessionItem(sessionId) -- 1576
				local isSubSession = (session and session.kind) == "sub" -- 1577
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1578
				if isSubSession and event.taskId ~= nil then -- 1578
					finalizingSubSessionTaskIds[event.taskId] = true -- 1580
				end -- 1580
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1582
				if event.taskId ~= nil then -- 1582
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1584
					local ____finalizeTaskSteps_37 = finalizeTaskSteps -- 1585
					local ____array_36 = __TS__SparseArrayNew( -- 1585
						sessionId, -- 1586
						event.taskId, -- 1587
						type(event.steps) == "number" and math.max( -- 1588
							0, -- 1588
							math.floor(event.steps) -- 1588
						) or nil -- 1588
					) -- 1588
					local ____event_success_35 -- 1589
					if event.success then -- 1589
						____event_success_35 = nil -- 1589
					else -- 1589
						____event_success_35 = stopped and "STOPPED" or "FAILED" -- 1589
					end -- 1589
					__TS__SparseArrayPush(____array_36, ____event_success_35) -- 1589
					____finalizeTaskSteps_37(__TS__SparseArraySpread(____array_36)) -- 1585
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1591
					if not isSubSession then -- 1591
						activeStopTokens[event.taskId] = nil -- 1593
					end -- 1593
					emitAgentSessionPatch( -- 1595
						sessionId, -- 1595
						{ -- 1595
							session = getSessionItem(sessionId), -- 1596
							message = getMessageItem(messageId), -- 1597
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1598
							removedStepIds = removedStepIds -- 1599
						} -- 1599
					) -- 1599
				end -- 1599
				if session and session.kind == "main" then -- 1599
					flushPendingSubAgentHandoffs(session) -- 1603
				end -- 1603
				break -- 1605
			end -- 1605
		end -- 1605
	until true -- 1605
end -- 1605
function ____exports.createSession(projectRoot, title) -- 1722
	if title == nil then -- 1722
		title = "" -- 1722
	end -- 1722
	if not isValidProjectRoot(projectRoot) then -- 1722
		return {success = false, message = "invalid projectRoot"} -- 1724
	end -- 1724
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1726
	if row then -- 1726
		return { -- 1735
			success = true, -- 1735
			session = rowToSession(row) -- 1735
		} -- 1735
	end -- 1735
	local t = now() -- 1737
	DB:exec( -- 1738
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1738
		{ -- 1741
			projectRoot, -- 1741
			title ~= "" and title or Path:getFilename(projectRoot), -- 1741
			t, -- 1741
			t -- 1741
		} -- 1741
	) -- 1741
	local sessionId = getLastInsertRowId() -- 1743
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1744
	local session = getSessionItem(sessionId) -- 1745
	if not session then -- 1745
		return {success = false, message = "failed to create session"} -- 1747
	end -- 1747
	return {success = true, session = session} -- 1749
end -- 1722
function ____exports.createSubSession(parentSessionId, title) -- 1752
	if title == nil then -- 1752
		title = "" -- 1752
	end -- 1752
	local parent = getSessionItem(parentSessionId) -- 1753
	if not parent then -- 1753
		return {success = false, message = "parent session not found"} -- 1755
	end -- 1755
	local rootId = getSessionRootId(parent) -- 1757
	local t = now() -- 1758
	DB:exec( -- 1759
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1759
		{ -- 1762
			parent.projectRoot, -- 1762
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1762
			rootId, -- 1762
			parent.id, -- 1762
			t, -- 1762
			t -- 1762
		} -- 1762
	) -- 1762
	local sessionId = getLastInsertRowId() -- 1764
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1765
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1766
	local session = getSessionItem(sessionId) -- 1767
	if not session then -- 1767
		return {success = false, message = "failed to create sub session"} -- 1769
	end -- 1769
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1771
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1772
	subStorage:writeMemory(parentStorage:readMemory()) -- 1773
	return {success = true, session = session} -- 1774
end -- 1752
function spawnSubAgentSession(request) -- 1777
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1777
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1788
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1789
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1790
		if normalizedPrompt == "" then -- 1790
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1792
		end -- 1792
		if normalizedPrompt == "" then -- 1792
			local ____Log_43 = Log -- 1799
			local ____temp_40 = #normalizedTitle -- 1799
			local ____temp_41 = #rawPrompt -- 1799
			local ____temp_42 = #toStr(request.expectedOutput) -- 1799
			local ____opt_38 = request.filesHint -- 1799
			____Log_43( -- 1799
				"Warn", -- 1799
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_40)) .. " raw_prompt_len=") .. tostring(____temp_41)) .. " expected_len=") .. tostring(____temp_42)) .. " files_hint_count=") .. tostring(____opt_38 and #____opt_38 or 0) -- 1799
			) -- 1799
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1799
		end -- 1799
		Log( -- 1802
			"Info", -- 1802
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1802
		) -- 1802
		local parentSessionId = request.parentSessionId -- 1803
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1803
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1805
			if not fallbackParent then -- 1805
				local createdMain = ____exports.createSession(request.projectRoot) -- 1807
				if createdMain.success then -- 1807
					fallbackParent = createdMain.session -- 1809
				end -- 1809
			end -- 1809
			if fallbackParent then -- 1809
				Log( -- 1813
					"Warn", -- 1813
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1813
				) -- 1813
				parentSessionId = fallbackParent.id -- 1814
			end -- 1814
		end -- 1814
		local parentSession = getSessionItem(parentSessionId) -- 1817
		if not parentSession then -- 1817
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1817
		end -- 1817
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1821
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1821
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1821
		end -- 1821
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1825
		if not created.success then -- 1825
			return ____awaiter_resolve(nil, created) -- 1825
		end -- 1825
		writeSpawnInfo( -- 1829
			created.session.projectRoot, -- 1829
			created.session.memoryScope, -- 1829
			{ -- 1829
				sessionId = created.session.id, -- 1830
				rootSessionId = created.session.rootSessionId, -- 1831
				parentSessionId = created.session.parentSessionId, -- 1832
				title = created.session.title, -- 1833
				prompt = normalizedPrompt, -- 1834
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1835
				expectedOutput = request.expectedOutput or "", -- 1836
				filesHint = request.filesHint or ({}), -- 1837
				status = "RUNNING", -- 1838
				success = false, -- 1839
				resultFilePath = "", -- 1840
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1841
				sourceTaskId = 0, -- 1842
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1843
				createdAtTs = created.session.createdAt, -- 1844
				finishedAt = "", -- 1845
				finishedAtTs = 0 -- 1846
			} -- 1846
		) -- 1846
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1848
		if not sent.success then -- 1848
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1848
		end -- 1848
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1848
	end) -- 1848
end -- 1848
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 1929
	local rootSession = getRootSessionItem(session.id) -- 1930
	if not rootSession then -- 1930
		return -- 1931
	end -- 1931
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 1932
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1933
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1934
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1935
	local queueResult = writePendingHandoff( -- 1936
		rootSession.projectRoot, -- 1936
		rootSession.memoryScope, -- 1936
		{ -- 1936
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1937
			sourceSessionId = session.id, -- 1938
			sourceTitle = session.title, -- 1939
			sourceTaskId = taskId, -- 1940
			message = summary, -- 1941
			prompt = result.prompt, -- 1942
			goal = result.goal, -- 1943
			expectedOutput = result.expectedOutput or "", -- 1944
			filesHint = result.filesHint or ({}), -- 1945
			success = result.success, -- 1946
			resultFilePath = result.resultFilePath, -- 1947
			artifactDir = result.artifactDir, -- 1948
			finishedAt = result.finishedAt, -- 1949
			changeSet = changeSet, -- 1950
			memoryEntry = result.memoryEntry, -- 1951
			createdAt = createdAt -- 1952
		} -- 1952
	) -- 1952
	if not queueResult then -- 1952
		Log( -- 1955
			"Warn", -- 1955
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1955
		) -- 1955
		return -- 1956
	end -- 1956
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1956
		flushPendingSubAgentHandoffs(rootSession) -- 1959
	end -- 1959
end -- 1959
function finalizeSubSession(session, taskId, success, message) -- 1963
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1963
		local rootSessionId = getSessionRootId(session) -- 1964
		local rootSession = getRootSessionItem(session.id) -- 1965
		if not rootSession then -- 1965
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 1965
		end -- 1965
		local spawnInfo = getSessionSpawnInfo(session) -- 1969
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1970
		local finishedAtTs = now() -- 1971
		local resultText = sanitizeUTF8(message) -- 1972
		local changeSet = getTaskChangeSetSummary(taskId) -- 1973
		local record = { -- 1974
			sessionId = session.id, -- 1975
			rootSessionId = rootSessionId, -- 1976
			parentSessionId = session.parentSessionId, -- 1977
			title = session.title, -- 1978
			prompt = spawnInfo and spawnInfo.prompt or "", -- 1979
			goal = spawnInfo and spawnInfo.goal or session.title, -- 1980
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 1981
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 1982
			status = success and "DONE" or "FAILED", -- 1983
			success = success, -- 1984
			resultFilePath = getResultRelativePath(session.memoryScope), -- 1985
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 1986
			sourceTaskId = taskId, -- 1987
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 1988
			finishedAt = finishedAt, -- 1989
			createdAtTs = session.createdAt, -- 1990
			finishedAtTs = finishedAtTs, -- 1991
			changeSet = changeSet -- 1992
		} -- 1992
		if record.success then -- 1992
			local memoryEntryResult = __TS__Await(generateSubAgentMemoryEntry(session, record, resultText)) -- 1995
			record.memoryEntry = memoryEntryResult.entry -- 1996
			if memoryEntryResult.error and memoryEntryResult.error ~= "" then -- 1996
				record.memoryEntryError = memoryEntryResult.error -- 1998
				Log( -- 1999
					"Warn", -- 1999
					(("[AgentSession] sub session memory entry failed session=" .. tostring(session.id)) .. " error=") .. memoryEntryResult.error -- 1999
				) -- 1999
			end -- 1999
		end -- 1999
		if not writeSubAgentResultFile(session, record, resultText) then -- 1999
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 1999
		end -- 1999
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 1999
			sessionId = record.sessionId, -- 2006
			rootSessionId = record.rootSessionId, -- 2007
			parentSessionId = record.parentSessionId, -- 2008
			title = record.title, -- 2009
			prompt = record.prompt, -- 2010
			goal = record.goal, -- 2011
			expectedOutput = record.expectedOutput or "", -- 2012
			filesHint = record.filesHint or ({}), -- 2013
			status = record.status, -- 2014
			success = record.success, -- 2015
			resultFilePath = record.resultFilePath, -- 2016
			artifactDir = record.artifactDir, -- 2017
			sourceTaskId = record.sourceTaskId, -- 2018
			createdAt = record.createdAt, -- 2019
			finishedAt = record.finishedAt, -- 2020
			createdAtTs = record.createdAtTs, -- 2021
			finishedAtTs = record.finishedAtTs, -- 2022
			changeSet = record.changeSet, -- 2023
			memoryEntry = record.memoryEntry, -- 2024
			memoryEntryError = record.memoryEntryError -- 2025
		}) then -- 2025
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2025
		end -- 2025
		if success then -- 2025
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2030
			deleteSessionRecords(session.id, true) -- 2031
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2032
		end -- 2032
		return ____awaiter_resolve(nil, {success = true}) -- 2032
	end) -- 2032
end -- 2032
function stopClearedSubSession(session, taskId) -- 2037
	local spawnInfo = getSessionSpawnInfo(session) -- 2038
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2039
	local rootSessionId = getSessionRootId(session) -- 2040
	Tools.setTaskStatus(taskId, "STOPPED") -- 2041
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2042
	if not writeSpawnInfo( -- 2042
		session.projectRoot, -- 2043
		session.memoryScope, -- 2043
		{ -- 2043
			sessionId = session.id, -- 2044
			rootSessionId = rootSessionId, -- 2045
			parentSessionId = session.parentSessionId, -- 2046
			title = session.title, -- 2047
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2048
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2049
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2050
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2051
			status = "STOPPED", -- 2052
			success = false, -- 2053
			cleared = true, -- 2054
			resultFilePath = "", -- 2055
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2056
			sourceTaskId = taskId, -- 2057
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2058
			finishedAt = finishedAt, -- 2059
			createdAtTs = session.createdAt, -- 2060
			finishedAtTs = now() -- 2061
		} -- 2061
	) then -- 2061
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2063
	end -- 2063
	deleteSessionRecords(session.id, true) -- 2065
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2066
	return {success = true} -- 2067
end -- 2067
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 2070
	if allowSubSessionStart == nil then -- 2070
		allowSubSessionStart = false -- 2070
	end -- 2070
	local session = getSessionItem(sessionId) -- 2071
	if not session then -- 2071
		return {success = false, message = "session not found"} -- 2073
	end -- 2073
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2073
		return {success = false, message = "session task is finalizing"} -- 2076
	end -- 2076
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2076
		return {success = false, message = "session task is still running"} -- 2079
	end -- 2079
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2081
	if normalizedPrompt == "" and session.kind == "sub" then -- 2081
		local spawnInfo = getSessionSpawnInfo(session) -- 2083
		if spawnInfo then -- 2083
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2085
			if normalizedPrompt == "" then -- 2085
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2087
			end -- 2087
		end -- 2087
	end -- 2087
	if normalizedPrompt == "" then -- 2087
		return {success = false, message = "prompt is empty"} -- 2096
	end -- 2096
	local taskRes = Tools.createTask(normalizedPrompt) -- 2098
	if not taskRes.success then -- 2098
		return {success = false, message = taskRes.message} -- 2100
	end -- 2100
	local taskId = taskRes.taskId -- 2102
	local useChineseResponse = getDefaultUseChineseResponse() -- 2103
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 2104
	local stopToken = {stopped = false} -- 2105
	activeStopTokens[taskId] = stopToken -- 2106
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 2107
	runCodingAgent( -- 2108
		{ -- 2108
			prompt = normalizedPrompt, -- 2109
			workDir = session.projectRoot, -- 2110
			useChineseResponse = useChineseResponse, -- 2111
			taskId = taskId, -- 2112
			sessionId = sessionId, -- 2113
			memoryScope = session.memoryScope, -- 2114
			role = session.kind, -- 2115
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2116
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2119
			stopToken = stopToken, -- 2122
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 2123
		}, -- 2123
		function(result) -- 2124
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2124
				local nextSession = getSessionItem(sessionId) -- 2125
				if nextSession and nextSession.kind == "sub" then -- 2125
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2125
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2128
						if not stopped.success then -- 2128
							Log( -- 2130
								"Warn", -- 2130
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2130
							) -- 2130
							emitAgentSessionPatch( -- 2131
								sessionId, -- 2131
								{session = getSessionItem(sessionId)} -- 2131
							) -- 2131
						end -- 2131
						activeStopTokens[taskId] = nil -- 2135
						return ____awaiter_resolve(nil) -- 2135
					end -- 2135
					setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 2138
					emitAgentSessionPatch( -- 2139
						sessionId, -- 2139
						{session = getSessionItem(sessionId)} -- 2139
					) -- 2139
					local finalized = __TS__Await(finalizeSubSession(nextSession, taskId, result.success, result.message)) -- 2142
					if not finalized.success then -- 2142
						Log( -- 2144
							"Warn", -- 2144
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2144
						) -- 2144
					end -- 2144
					local finalizedSession = getSessionItem(sessionId) -- 2146
					if finalizedSession then -- 2146
						local stopped = stopToken.stopped == true -- 2148
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2149
						setSessionState(sessionId, finalStatus, taskId, finalStatus) -- 2152
						emitAgentSessionPatch( -- 2153
							sessionId, -- 2153
							{session = getSessionItem(sessionId)} -- 2153
						) -- 2153
					end -- 2153
					activeStopTokens[taskId] = nil -- 2157
					finalizingSubSessionTaskIds[taskId] = nil -- 2158
				end -- 2158
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2158
					applyEvent(sessionId, { -- 2161
						type = "task_finished", -- 2162
						sessionId = sessionId, -- 2163
						taskId = result.taskId, -- 2164
						success = false, -- 2165
						message = result.message, -- 2166
						steps = result.steps -- 2167
					}) -- 2167
				end -- 2167
			end) -- 2167
		end -- 2124
	) -- 2124
	return {success = true, sessionId = sessionId, taskId = taskId} -- 2171
end -- 2070
function ____exports.listRunningSubAgents(request) -- 2221
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2221
		local session = getSessionItem(request.sessionId) -- 2229
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2229
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2231
		end -- 2231
		if not session then -- 2231
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2231
		end -- 2231
		local rootSession = getRootSessionItem(session.id) -- 2236
		if not rootSession then -- 2236
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2236
		end -- 2236
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2240
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2241
		local limit = math.max( -- 2242
			1, -- 2242
			math.floor(tonumber(request.limit) or 5) -- 2242
		) -- 2242
		local offset = math.max( -- 2243
			0, -- 2243
			math.floor(tonumber(request.offset) or 0) -- 2243
		) -- 2243
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2244
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2245
		local runningSessions = {} -- 2252
		do -- 2252
			local i = 0 -- 2253
			while i < #rows do -- 2253
				do -- 2253
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2254
					if current.currentTaskStatus ~= "RUNNING" then -- 2254
						goto __continue339 -- 2256
					end -- 2256
					local spawnInfo = getSessionSpawnInfo(current) -- 2258
					runningSessions[#runningSessions + 1] = { -- 2259
						sessionId = current.id, -- 2260
						title = current.title, -- 2261
						parentSessionId = current.parentSessionId, -- 2262
						rootSessionId = current.rootSessionId, -- 2263
						status = "RUNNING", -- 2264
						currentTaskId = current.currentTaskId, -- 2265
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2266
						goal = spawnInfo and spawnInfo.goal, -- 2267
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2268
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2269
						createdAt = current.createdAt, -- 2270
						updatedAt = current.updatedAt -- 2271
					} -- 2271
				end -- 2271
				::__continue339:: -- 2271
				i = i + 1 -- 2253
			end -- 2253
		end -- 2253
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2274
		local completedSessions = __TS__ArrayMap( -- 2275
			completedRecords, -- 2275
			function(____, record) return { -- 2275
				sessionId = record.sessionId, -- 2276
				title = record.title, -- 2277
				parentSessionId = record.parentSessionId, -- 2278
				rootSessionId = record.rootSessionId, -- 2279
				status = record.status, -- 2280
				goal = record.goal, -- 2281
				expectedOutput = record.expectedOutput, -- 2282
				filesHint = record.filesHint, -- 2283
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2284
				success = record.success, -- 2285
				cleared = record.cleared, -- 2286
				resultFilePath = record.resultFilePath, -- 2287
				artifactDir = record.artifactDir, -- 2288
				finishedAt = record.finishedAt, -- 2289
				createdAt = record.createdAtTs, -- 2290
				updatedAt = record.finishedAtTs -- 2291
			} end -- 2291
		) -- 2291
		local merged = {} -- 2293
		if status == "running" then -- 2293
			merged = runningSessions -- 2295
		elseif status == "done" then -- 2295
			merged = __TS__ArrayFilter( -- 2297
				completedSessions, -- 2297
				function(____, item) return item.status == "DONE" end -- 2297
			) -- 2297
		elseif status == "failed" then -- 2297
			merged = __TS__ArrayFilter( -- 2299
				completedSessions, -- 2299
				function(____, item) return item.status == "FAILED" end -- 2299
			) -- 2299
		elseif status == "stopped" then -- 2299
			merged = __TS__ArrayFilter( -- 2301
				completedSessions, -- 2301
				function(____, item) return item.status == "STOPPED" end -- 2301
			) -- 2301
		elseif status == "all" then -- 2301
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2303
		else -- 2303
			local runningKeys = {} -- 2305
			do -- 2305
				local i = 0 -- 2306
				while i < #runningSessions do -- 2306
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2307
					i = i + 1 -- 2306
				end -- 2306
			end -- 2306
			local latestCompletedByKey = {} -- 2309
			do -- 2309
				local i = 0 -- 2310
				while i < #completedSessions do -- 2310
					do -- 2310
						local item = completedSessions[i + 1] -- 2311
						local key = getSubAgentDisplayKey(item) -- 2312
						if runningKeys[key] then -- 2312
							goto __continue354 -- 2314
						end -- 2314
						local current = latestCompletedByKey[key] -- 2316
						if not current or item.updatedAt > current.updatedAt then -- 2316
							latestCompletedByKey[key] = item -- 2318
						end -- 2318
					end -- 2318
					::__continue354:: -- 2318
					i = i + 1 -- 2310
				end -- 2310
			end -- 2310
			local latestCompleted = {} -- 2321
			for ____, item in pairs(latestCompletedByKey) do -- 2322
				latestCompleted[#latestCompleted + 1] = item -- 2323
			end -- 2323
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2325
		end -- 2325
		if query ~= "" then -- 2325
			merged = __TS__ArrayFilter( -- 2328
				merged, -- 2328
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2328
			) -- 2328
		end -- 2328
		__TS__ArraySort( -- 2334
			merged, -- 2334
			function(____, a, b) -- 2334
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2334
					return -1 -- 2335
				end -- 2335
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2335
					return 1 -- 2336
				end -- 2336
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2336
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2338
				end -- 2338
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2340
			end -- 2334
		) -- 2334
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2342
		return ____awaiter_resolve(nil, { -- 2342
			success = true, -- 2344
			rootSessionId = rootSession.id, -- 2345
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2346
			status = status, -- 2347
			limit = limit, -- 2348
			offset = offset, -- 2349
			hasMore = offset + limit < #merged, -- 2350
			sessions = paged -- 2351
		}) -- 2351
	end) -- 2351
end -- 2221
TABLE_SESSION = "AgentSession" -- 172
TABLE_MESSAGE = "AgentSessionMessage" -- 173
TABLE_STEP = "AgentSessionStep" -- 174
TABLE_TASK = "AgentTask" -- 175
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 176
SPAWN_INFO_FILE = "SPAWN.json" -- 177
RESULT_FILE = "RESULT.md" -- 178
PENDING_HANDOFF_DIR = "pending-handoffs" -- 179
MAX_CONCURRENT_SUB_AGENTS = 4 -- 180
SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE = 0.1 -- 181
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS = 1024 -- 182
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY = 3 -- 183
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 184
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 185
SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS = 3000 -- 186
SUB_AGENT_MEMORY_RESULT_MAX_TOKENS = 2000 -- 187
SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES = 20 -- 188
SUB_AGENT_MEMORY_TAIL_MAX_TOKENS = 4000 -- 189
SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS = 600 -- 190
activeStopTokens = {} -- 236
finalizingSubSessionTaskIds = {} -- 237
now = function() return os.time() end -- 238
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 600
	if projectRoot == oldRoot then -- 600
		return newRoot -- 602
	end -- 602
	for ____, separator in ipairs({"/", "\\"}) do -- 604
		local prefix = oldRoot .. separator -- 605
		if __TS__StringStartsWith(projectRoot, prefix) then -- 605
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 607
		end -- 607
	end -- 607
	return nil -- 610
end -- 600
local function sanitizeStoredSteps(sessionId) -- 1370
	DB:exec( -- 1371
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1371
		{ -- 1389
			now(), -- 1389
			sessionId -- 1389
		} -- 1389
	) -- 1389
end -- 1370
local function getSchemaVersion() -- 1610
	local row = queryOne("PRAGMA user_version") -- 1611
	return row and type(row[1]) == "number" and row[1] or 0 -- 1612
end -- 1610
local function setSchemaVersion(version) -- 1615
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1616
		0, -- 1616
		math.floor(version) -- 1616
	))) -- 1616
end -- 1615
local function recreateSchema() -- 1619
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1620
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1621
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1622
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1623
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1637
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1638
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1647
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1648
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1665
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1666
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1667
end -- 1619
do -- 1619
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1619
		recreateSchema() -- 1673
	else -- 1673
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1675
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1689
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1690
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1699
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1700
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1717
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1718
	end -- 1718
end -- 1718
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1860
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1860
		return {success = false, message = "invalid projectRoot"} -- 1862
	end -- 1862
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1864
	for ____, row in ipairs(rows) do -- 1865
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1866
		if sessionId > 0 then -- 1866
			deleteSessionRecords(sessionId) -- 1868
		end -- 1868
	end -- 1868
	return {success = true, deleted = #rows} -- 1871
end -- 1860
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1874
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1874
		return {success = false, message = "invalid projectRoot"} -- 1876
	end -- 1876
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1878
	local renamed = 0 -- 1879
	for ____, row in ipairs(rows) do -- 1880
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1881
		local projectRoot = toStr(row[2]) -- 1882
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1883
		if sessionId > 0 and nextProjectRoot then -- 1883
			DB:exec( -- 1885
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1885
				{ -- 1887
					nextProjectRoot, -- 1887
					Path:getFilename(nextProjectRoot), -- 1887
					now(), -- 1887
					sessionId -- 1887
				} -- 1887
			) -- 1887
			renamed = renamed + 1 -- 1889
		end -- 1889
	end -- 1889
	return {success = true, renamed = renamed} -- 1892
end -- 1874
function ____exports.getSession(sessionId) -- 1895
	local session = getSessionItem(sessionId) -- 1896
	if not session then -- 1896
		return {success = false, message = "session not found"} -- 1898
	end -- 1898
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1900
	local relatedSessions = listRelatedSessions(sessionId) -- 1901
	sanitizeStoredSteps(sessionId) -- 1902
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1903
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1910
	local ____relatedSessions_45 = relatedSessions -- 1921
	local ____temp_44 -- 1922
	if normalizedSession.kind == "sub" then -- 1922
		____temp_44 = getSessionSpawnInfo(normalizedSession) -- 1922
	else -- 1922
		____temp_44 = nil -- 1922
	end -- 1922
	return { -- 1918
		success = true, -- 1919
		session = normalizedSession, -- 1920
		relatedSessions = ____relatedSessions_45, -- 1921
		spawnInfo = ____temp_44, -- 1922
		messages = __TS__ArrayMap( -- 1923
			messages, -- 1923
			function(____, row) return rowToMessage(row) end -- 1923
		), -- 1923
		steps = __TS__ArrayMap( -- 1924
			steps, -- 1924
			function(____, row) return rowToStep(row) end -- 1924
		), -- 1924
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 1925
	} -- 1925
end -- 1895
function ____exports.stopSessionTask(sessionId) -- 2174
	local session = getSessionItem(sessionId) -- 2175
	if not session or session.currentTaskId == nil then -- 2175
		return {success = false, message = "session task not found"} -- 2177
	end -- 2177
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2177
		return {success = false, message = "session task is finalizing"} -- 2180
	end -- 2180
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2182
	local stopToken = activeStopTokens[session.currentTaskId] -- 2183
	if not stopToken then -- 2183
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2183
			return {success = true, recovered = true} -- 2186
		end -- 2186
		return {success = false, message = "task is not running"} -- 2188
	end -- 2188
	stopToken.stopped = true -- 2190
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2191
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2192
	return {success = true} -- 2193
end -- 2174
function ____exports.getCurrentTaskId(sessionId) -- 2196
	local ____opt_66 = getSessionItem(sessionId) -- 2196
	return ____opt_66 and ____opt_66.currentTaskId -- 2197
end -- 2196
function ____exports.listRunningSessions() -- 2200
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2201
	local sessions = {} -- 2208
	do -- 2208
		local i = 0 -- 2209
		while i < #rows do -- 2209
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2210
			if session.currentTaskStatus == "RUNNING" then -- 2210
				sessions[#sessions + 1] = session -- 2212
			end -- 2212
			i = i + 1 -- 2209
		end -- 2209
	end -- 2209
	return {success = true, sessions = sessions} -- 2215
end -- 2200
return ____exports -- 2200