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
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildSubAgentMemoryEntryLLMOptions, buildSubAgentMemoryEntryToolSchema, buildSubAgentMemoryEntrySystemPrompt, formatSubAgentMemoryTailMessage, buildSubAgentRecentMessageTail, buildSubAgentMemoryEntryPrompt, buildSubAgentMemoryEntryRetryPrompt, normalizeGeneratedSubAgentMemoryEntry, getMemoryEntryToolFunction, getMemoryEntryPlainContent, decodeMemoryEntryFromPlainContent, hasEmptyMemoryEntryContent, generateSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, setSessionStateForTaskEvent, insertMessage, updateMessage, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS, SUB_AGENT_MEMORY_RESULT_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS, activeStopTokens, now -- 1
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
function getDefaultUseChineseResponse() -- 238
	local zh = string.match(App.locale, "^zh") -- 239
	return zh ~= nil -- 240
end -- 240
function toStr(v) -- 243
	if v == false or v == nil or v == nil then -- 243
		return "" -- 244
	end -- 244
	return tostring(v) -- 245
end -- 245
function encodeJson(value) -- 248
	local text = safeJsonEncode(value) -- 249
	return text or "" -- 250
end -- 250
function decodeJsonObject(text) -- 253
	if not text or text == "" then -- 253
		return nil -- 254
	end -- 254
	local value = safeJsonDecode(text) -- 255
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 255
		return value -- 257
	end -- 257
	return nil -- 259
end -- 259
function decodeJsonFiles(text) -- 262
	if not text or text == "" then -- 262
		return nil -- 263
	end -- 263
	local value = safeJsonDecode(text) -- 264
	if not value or not __TS__ArrayIsArray(value) then -- 264
		return nil -- 265
	end -- 265
	local files = {} -- 266
	do -- 266
		local i = 0 -- 267
		while i < #value do -- 267
			do -- 267
				local item = value[i + 1] -- 268
				if type(item) ~= "table" then -- 268
					goto __continue14 -- 269
				end -- 269
				files[#files + 1] = { -- 270
					path = sanitizeUTF8(toStr(item.path)), -- 271
					op = sanitizeUTF8(toStr(item.op)) -- 272
				} -- 272
			end -- 272
			::__continue14:: -- 272
			i = i + 1 -- 267
		end -- 267
	end -- 267
	return files -- 275
end -- 275
function decodeChangeSetSummary(value) -- 278
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 278
		return nil -- 279
	end -- 279
	local row = value -- 280
	if row.success ~= true then -- 280
		return nil -- 281
	end -- 281
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 282
	if taskId <= 0 then -- 282
		return nil -- 283
	end -- 283
	local files = {} -- 284
	if __TS__ArrayIsArray(row.files) then -- 284
		do -- 284
			local i = 0 -- 286
			while i < #row.files do -- 286
				do -- 286
					local file = row.files[i + 1] -- 287
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 287
						goto __continue22 -- 288
					end -- 288
					local fileRow = file -- 289
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 290
					if path == "" then -- 290
						goto __continue22 -- 291
					end -- 291
					local checkpointIds = {} -- 292
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 292
						do -- 292
							local j = 0 -- 294
							while j < #fileRow.checkpointIds do -- 294
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 295
								if checkpointId > 0 then -- 295
									checkpointIds[#checkpointIds + 1] = checkpointId -- 296
								end -- 296
								j = j + 1 -- 294
							end -- 294
						end -- 294
					end -- 294
					local op = toStr(fileRow.op) -- 299
					files[#files + 1] = { -- 300
						path = path, -- 301
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 302
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 303
						checkpointIds = checkpointIds -- 304
					} -- 304
				end -- 304
				::__continue22:: -- 304
				i = i + 1 -- 286
			end -- 286
		end -- 286
	end -- 286
	return { -- 308
		success = true, -- 309
		taskId = taskId, -- 310
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 311
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 312
		files = files, -- 313
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 314
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 315
	} -- 315
end -- 315
function takeUtf8Head(text, maxChars) -- 319
	if maxChars <= 0 or text == "" then -- 319
		return "" -- 320
	end -- 320
	local nextPos = utf8.offset(text, maxChars + 1) -- 321
	if nextPos == nil then -- 321
		return text -- 322
	end -- 322
	return string.sub(text, 1, nextPos - 1) -- 323
end -- 323
function normalizeMemoryEntryEvidence(value) -- 326
	local evidence = {} -- 327
	if not __TS__ArrayIsArray(value) then -- 327
		return evidence -- 328
	end -- 328
	do -- 328
		local i = 0 -- 329
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 329
			do -- 329
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 330
				if item == "" then -- 330
					goto __continue35 -- 331
				end -- 331
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 331
					evidence[#evidence + 1] = item -- 333
				end -- 333
			end -- 333
			::__continue35:: -- 333
			i = i + 1 -- 329
		end -- 329
	end -- 329
	return evidence -- 336
end -- 336
function decodeSubAgentMemoryEntry(value) -- 339
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 339
		return nil -- 340
	end -- 340
	local row = value -- 341
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 342
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 343
	local content = takeUtf8Head( -- 344
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 344
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 344
	) -- 344
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 344
		return nil -- 345
	end -- 345
	return { -- 346
		sourceSessionId = sourceSessionId, -- 347
		sourceTaskId = sourceTaskId, -- 348
		content = content, -- 349
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 350
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 351
	} -- 351
end -- 351
function getTaskChangeSetSummary(taskId) -- 355
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 356
	return summary.success and summary or nil -- 357
end -- 357
function queryRows(sql, args) -- 360
	local ____args_0 -- 361
	if args then -- 361
		____args_0 = DB:query(sql, args) -- 361
	else -- 361
		____args_0 = DB:query(sql) -- 361
	end -- 361
	return ____args_0 -- 361
end -- 361
function queryOne(sql, args) -- 364
	local rows = queryRows(sql, args) -- 365
	if not rows or #rows == 0 then -- 365
		return nil -- 366
	end -- 366
	return rows[1] -- 367
end -- 367
function getLastInsertRowId() -- 370
	local row = queryOne("SELECT last_insert_rowid()") -- 371
	return row and (row[1] or 0) or 0 -- 372
end -- 372
function isValidProjectRoot(path) -- 375
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 376
end -- 376
function rowToSession(row) -- 379
	return { -- 380
		id = row[1], -- 381
		projectRoot = toStr(row[2]), -- 382
		title = toStr(row[3]), -- 383
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 384
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 385
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 386
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 387
		status = toStr(row[8]), -- 388
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 389
		currentTaskStatus = toStr(row[10]), -- 390
		createdAt = row[11], -- 391
		updatedAt = row[12] -- 392
	} -- 392
end -- 392
function rowToMessage(row) -- 396
	return { -- 397
		id = row[1], -- 398
		sessionId = row[2], -- 399
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 400
		role = toStr(row[4]), -- 401
		content = toStr(row[5]), -- 402
		createdAt = row[6], -- 403
		updatedAt = row[7] -- 404
	} -- 404
end -- 404
function rowToStep(row) -- 408
	return { -- 409
		id = row[1], -- 410
		sessionId = row[2], -- 411
		taskId = row[3], -- 412
		step = row[4], -- 413
		tool = toStr(row[5]), -- 414
		status = toStr(row[6]), -- 415
		reason = toStr(row[7]), -- 416
		reasoningContent = toStr(row[8]), -- 417
		params = decodeJsonObject(toStr(row[9])), -- 418
		result = decodeJsonObject(toStr(row[10])), -- 419
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 420
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 421
		files = decodeJsonFiles(toStr(row[13])), -- 422
		createdAt = row[14], -- 423
		updatedAt = row[15] -- 424
	} -- 424
end -- 424
function getMessageItem(messageId) -- 428
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 429
	return row and rowToMessage(row) or nil -- 435
end -- 435
function getStepItem(sessionId, taskId, step) -- 438
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 439
	return row and rowToStep(row) or nil -- 445
end -- 445
function deleteMessageSteps(sessionId, taskId) -- 448
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 449
	local ids = {} -- 454
	do -- 454
		local i = 0 -- 455
		while i < #rows do -- 455
			local row = rows[i + 1] -- 456
			if type(row[1]) == "number" then -- 456
				ids[#ids + 1] = row[1] -- 458
			end -- 458
			i = i + 1 -- 455
		end -- 455
	end -- 455
	if #ids > 0 then -- 455
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 462
	end -- 462
	return ids -- 468
end -- 468
function getSessionRow(sessionId) -- 471
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 472
end -- 472
function getSessionItem(sessionId) -- 480
	local row = getSessionRow(sessionId) -- 481
	return row and rowToSession(row) or nil -- 482
end -- 482
function getTaskPrompt(taskId) -- 485
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 486
	if not row or type(row[1]) ~= "string" then -- 486
		return nil -- 487
	end -- 487
	return toStr(row[1]) -- 488
end -- 488
function getLatestMainSessionByProjectRoot(projectRoot) -- 491
	if not isValidProjectRoot(projectRoot) then -- 491
		return nil -- 492
	end -- 492
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 493
	return row and rowToSession(row) or nil -- 501
end -- 501
function countRunningSubSessions(rootSessionId) -- 504
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 505
	local count = 0 -- 512
	do -- 512
		local i = 0 -- 513
		while i < #rows do -- 513
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 514
			if session.currentTaskStatus == "RUNNING" then -- 514
				count = count + 1 -- 516
			end -- 516
			i = i + 1 -- 513
		end -- 513
	end -- 513
	return count -- 519
end -- 519
function deleteSessionRecords(sessionId, preserveArtifacts) -- 522
	if preserveArtifacts == nil then -- 522
		preserveArtifacts = false -- 522
	end -- 522
	local session = getSessionItem(sessionId) -- 523
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 524
	do -- 524
		local i = 0 -- 525
		while i < #children do -- 525
			local row = children[i + 1] -- 526
			if type(row[1]) == "number" and row[1] > 0 then -- 526
				deleteSessionRecords(row[1], preserveArtifacts) -- 528
			end -- 528
			i = i + 1 -- 525
		end -- 525
	end -- 525
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 531
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 532
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 533
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 534
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 534
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 536
	end -- 536
end -- 536
function getSessionRootId(session) -- 540
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 541
end -- 541
function getRootSessionItem(sessionId) -- 544
	local session = getSessionItem(sessionId) -- 545
	if not session then -- 545
		return nil -- 546
	end -- 546
	return getSessionItem(getSessionRootId(session)) or session -- 547
end -- 547
function listRelatedSessions(sessionId) -- 550
	local root = getRootSessionItem(sessionId) -- 551
	if not root then -- 551
		return {} -- 552
	end -- 552
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 553
	return __TS__ArrayMap( -- 562
		rows, -- 562
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 562
	) -- 562
end -- 562
function getSessionSpawnInfo(session) -- 565
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 566
	if not info then -- 566
		return nil -- 567
	end -- 567
	local ____temp_4 = type(info.sessionId) == "number" and info.sessionId or nil -- 569
	local ____temp_5 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 570
	local ____temp_6 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 571
	local ____temp_7 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 572
	local ____temp_8 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 573
	local ____temp_9 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 574
	local ____temp_10 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 575
	local ____temp_11 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 576
		__TS__ArrayFilter( -- 577
			info.filesHint, -- 577
			function(____, item) return type(item) == "string" end -- 577
		), -- 577
		function(____, item) return sanitizeUTF8(item) end -- 577
	) or nil -- 577
	local ____temp_12 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 579
	local ____temp_2 -- 582
	if info.success == true then -- 582
		____temp_2 = true -- 582
	else -- 582
		local ____temp_1 -- 582
		if info.success == false then -- 582
			____temp_1 = false -- 582
		else -- 582
			____temp_1 = nil -- 582
		end -- 582
		____temp_2 = ____temp_1 -- 582
	end -- 582
	local ____temp_3 -- 583
	if info.cleared == true then -- 583
		____temp_3 = true -- 583
	else -- 583
		____temp_3 = nil -- 583
	end -- 583
	return { -- 568
		sessionId = ____temp_4, -- 569
		rootSessionId = ____temp_5, -- 570
		parentSessionId = ____temp_6, -- 571
		title = ____temp_7, -- 572
		prompt = ____temp_8, -- 573
		goal = ____temp_9, -- 574
		expectedOutput = ____temp_10, -- 575
		filesHint = ____temp_11, -- 576
		status = ____temp_12, -- 579
		success = ____temp_2, -- 582
		cleared = ____temp_3, -- 583
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 584
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 585
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 586
		changeSet = decodeChangeSetSummary(info.changeSet), -- 587
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 588
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 589
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 590
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 591
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 592
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 593
	} -- 593
end -- 593
function ensureDirRecursive(dir) -- 610
	if not dir or dir == "" then -- 610
		return false -- 611
	end -- 611
	if Content:exist(dir) then -- 611
		return Content:isdir(dir) -- 612
	end -- 612
	local parent = Path:getPath(dir) -- 613
	if parent and parent ~= dir and not Content:exist(parent) then -- 613
		if not ensureDirRecursive(parent) then -- 613
			return false -- 616
		end -- 616
	end -- 616
	return Content:mkdir(dir) -- 619
end -- 619
function writeSpawnInfo(projectRoot, memoryScope, value) -- 622
	local dir = Path(projectRoot, ".agent", memoryScope) -- 623
	if not Content:exist(dir) then -- 623
		ensureDirRecursive(dir) -- 625
	end -- 625
	local path = Path(dir, SPAWN_INFO_FILE) -- 627
	local text = safeJsonEncode(value) -- 628
	if not text then -- 628
		return false -- 629
	end -- 629
	local content = text .. "\n" -- 630
	if not Content:save(path, content) then -- 630
		return false -- 632
	end -- 632
	Tools.sendWebIDEFileUpdate(path, true, content) -- 634
	return true -- 635
end -- 635
function readSpawnInfo(projectRoot, memoryScope) -- 638
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 639
	if not Content:exist(path) then -- 639
		return nil -- 640
	end -- 640
	local text = Content:load(path) -- 641
	if not text or __TS__StringTrim(text) == "" then -- 641
		return nil -- 642
	end -- 642
	local value = safeJsonDecode(text) -- 643
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 643
		return value -- 645
	end -- 645
	return nil -- 647
end -- 647
function getArtifactRelativeDir(memoryScope) -- 650
	return Path(".agent", memoryScope) -- 651
end -- 651
function getArtifactDir(projectRoot, memoryScope) -- 654
	return Path( -- 655
		projectRoot, -- 655
		getArtifactRelativeDir(memoryScope) -- 655
	) -- 655
end -- 655
function getResultRelativePath(memoryScope) -- 658
	return Path( -- 659
		getArtifactRelativeDir(memoryScope), -- 659
		RESULT_FILE -- 659
	) -- 659
end -- 659
function getResultPath(projectRoot, memoryScope) -- 662
	return Path( -- 663
		projectRoot, -- 663
		getResultRelativePath(memoryScope) -- 663
	) -- 663
end -- 663
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 666
	if not resultFilePath or resultFilePath == "" then -- 666
		return "" -- 667
	end -- 667
	local path = Path(projectRoot, resultFilePath) -- 668
	if not Content:exist(path) then -- 668
		return "" -- 669
	end -- 669
	local text = sanitizeUTF8(Content:load(path)) -- 670
	if not text or __TS__StringTrim(text) == "" then -- 670
		return "" -- 671
	end -- 671
	local marker = "\n## Summary\n" -- 672
	local start = string.find(text, marker, 1, true) -- 673
	if start ~= nil then -- 673
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 675
	end -- 675
	return __TS__StringTrim(text) -- 677
end -- 677
function buildSubAgentMemoryEntryLLMOptions(llmConfig) -- 680
	local options = { -- 681
		temperature = llmConfig.temperature or SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE, -- 682
		max_tokens = math.min(llmConfig.maxTokens or SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS) -- 683
	} -- 683
	if llmConfig.reasoningEffort then -- 683
		options.reasoning_effort = __TS__StringTrim(llmConfig.reasoningEffort) -- 686
	end -- 686
	if type(options.reasoning_effort) ~= "string" or __TS__StringTrim(options.reasoning_effort) == "" then -- 686
		__TS__Delete(options, "reasoning_effort") -- 689
	end -- 689
	return options -- 691
end -- 691
function buildSubAgentMemoryEntryToolSchema() -- 694
	return {{type = "function", ["function"] = {name = "save_sub_agent_memory_entry", description = "Save one durable memory paragraph extracted from a completed sub-agent session.", parameters = {type = "object", properties = {content = {type = "string", description = "A concise paragraph of key information worth carrying into future main-agent context. Use an empty string when nothing durable should be saved."}, evidence = {type = "array", items = {type = "string"}, description = "Optional short file paths, artifact paths, or concrete anchors that support the memory paragraph."}}, required = {"content"}}}}} -- 695
end -- 695
function buildSubAgentMemoryEntrySystemPrompt() -- 719
	return "You generate a durable memory entry for the parent Dora agent.\nPrefer calling save_sub_agent_memory_entry when tool calling is available.\nIf you cannot call tools, output exactly one JSON object with this shape: {\"content\":\"...\",\"evidence\":[\"...\"]}.\n\nUse the completed sub-agent conversation and final result to decide whether anything should be remembered.\nReturn a single compact paragraph in content, similar to a history entry.\nFocus on durable facts: implemented behavior, important design decisions, constraints, discovered project conventions, or follow-up risks.\nDo not include generic progress narration, praise, or temporary execution details.\nIf there is no information likely to help future work, set content to an empty string.\nKeep evidence short and concrete, such as touched file paths or result artifact paths." -- 720
end -- 720
function formatSubAgentMemoryTailMessage(message) -- 732
	local lines = {"role: " .. sanitizeUTF8(toStr(message.role))} -- 733
	if type(message.name) == "string" and message.name ~= "" then -- 733
		lines[#lines + 1] = "name: " .. sanitizeUTF8(message.name) -- 735
	end -- 735
	if type(message.tool_call_id) == "string" and message.tool_call_id ~= "" then -- 735
		lines[#lines + 1] = "tool_call_id: " .. sanitizeUTF8(message.tool_call_id) -- 738
	end -- 738
	local content = type(message.content) == "string" and clipTextToTokenBudget( -- 740
		sanitizeUTF8(message.content), -- 741
		SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS -- 741
	) or "" -- 741
	if content ~= "" then -- 741
		lines[#lines + 1] = "content:\n" .. content -- 744
	end -- 744
	if __TS__ArrayIsArray(message.tool_calls) and #message.tool_calls > 0 then -- 744
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 747
		if toolCallsText ~= nil and toolCallsText ~= "" then -- 747
			lines[#lines + 1] = "tool_calls:\n" .. clipTextToTokenBudget(toolCallsText, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS) -- 749
		end -- 749
	end -- 749
	return table.concat(lines, "\n") -- 752
end -- 752
function buildSubAgentRecentMessageTail(messages) -- 755
	local parts = {} -- 756
	local totalTokens = 0 -- 757
	local count = 0 -- 758
	do -- 758
		local i = #messages - 1 -- 759
		while i >= 0 and count < SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES do -- 759
			do -- 759
				local text = formatSubAgentMemoryTailMessage(messages[i + 1]) -- 760
				if text == "" then -- 760
					goto __continue122 -- 761
				end -- 761
				local tokens = estimateTextTokens(text) -- 762
				if #parts > 0 and totalTokens + tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS then -- 762
					break -- 763
				end -- 763
				if tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS and #parts == 0 then -- 763
					__TS__ArrayUnshift( -- 765
						parts, -- 765
						clipTextToTokenBudget(text, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS) -- 765
					) -- 765
					break -- 766
				end -- 766
				__TS__ArrayUnshift(parts, text) -- 768
				totalTokens = totalTokens + tokens -- 769
				count = count + 1 -- 770
			end -- 770
			::__continue122:: -- 770
			i = i - 1 -- 759
		end -- 759
	end -- 759
	return #parts > 0 and table.concat(parts, "\n\n---\n\n") or "(empty)"
end -- 772
function buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 775
	local ____opt_13 = record.changeSet -- 775
	local files = ____opt_13 and ____opt_13.files or ({}) -- 776
	local changedFiles = table.concat( -- 777
		__TS__ArrayMap( -- 777
			files, -- 777
			function(____, file) return ((("- " .. file.path) .. " (") .. file.op) .. ")" end -- 777
		), -- 777
		"\n" -- 777
	) -- 777
	local boundedMemoryContext = clipTextToTokenBudget(memoryContext ~= "" and memoryContext or "(empty)", SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS) -- 778
	local boundedResultText = clipTextToTokenBudget(resultText ~= "" and resultText or "(empty)", SUB_AGENT_MEMORY_RESULT_MAX_TOKENS) -- 779
	return ((((((((((((((((((((((("Sub-agent memory context:\n" .. boundedMemoryContext) .. "\n\nSub-agent task metadata:\n- sessionId: ") .. tostring(record.sessionId)) .. "\n- taskId: ") .. tostring(record.sourceTaskId)) .. "\n- title: ") .. record.title) .. "\n- goal: ") .. record.goal) .. "\n- prompt: ") .. record.prompt) .. "\n- expectedOutput: ") .. (record.expectedOutput or "")) .. "\n- resultFilePath: ") .. record.resultFilePath) .. "\n- finishedAt: ") .. record.finishedAt) .. "\n\nChanged files:\n") .. (changedFiles ~= "" and changedFiles or "- none")) .. "\n\nFinal sub-agent result:\n") .. boundedResultText) .. "\n\nRecent conversation tail:\n") .. recentMessageTail) .. "\n\nGenerate the memory entry now." -- 780
end -- 780
function buildSubAgentMemoryEntryRetryPrompt(lastError) -- 805
	return ("Previous memory entry response was invalid: " .. lastError) .. "\n\nRetry with exactly one JSON object and no Markdown fences, no prose, no tool call.\nSchema:\n{\"content\":\"one concise durable memory paragraph, or empty string if nothing should be saved\",\"evidence\":[\"optional short file path or artifact path\"]}\n\nRules:\n- content must be a string.\n- evidence must be an array of strings.\n- Use {\"content\":\"\",\"evidence\":[]} when there is no durable memory to save." -- 806
end -- 806
function normalizeGeneratedSubAgentMemoryEntry(value, record) -- 818
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 818
		return nil -- 819
	end -- 819
	local row = value -- 820
	local content = takeUtf8Head( -- 821
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 821
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 821
	) -- 821
	if content == "" then -- 821
		return nil -- 822
	end -- 822
	return { -- 823
		sourceSessionId = record.sessionId, -- 824
		sourceTaskId = record.sourceTaskId, -- 825
		content = content, -- 826
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 827
		createdAt = record.finishedAt -- 828
	} -- 828
end -- 828
function getMemoryEntryToolFunction(response) -- 832
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 832
		return nil -- 833
	end -- 833
	local row = response -- 834
	local choices = row.choices -- 835
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 835
		return nil -- 836
	end -- 836
	local ____opt_15 = choices[1] -- 836
	if ____opt_15 ~= nil then -- 836
		____opt_15 = ____opt_15.message -- 836
	end -- 836
	local message = ____opt_15 -- 837
	local ____opt_result_19 -- 837
	if message ~= nil then -- 837
		____opt_result_19 = message.tool_calls -- 837
	end -- 837
	local toolCalls = ____opt_result_19 -- 838
	if not __TS__ArrayIsArray(toolCalls) then -- 838
		return nil -- 839
	end -- 839
	do -- 839
		local i = 0 -- 840
		while i < #toolCalls do -- 840
			local ____opt_20 = toolCalls[i + 1] -- 840
			if ____opt_20 ~= nil then -- 840
				____opt_20 = ____opt_20["function"] -- 840
			end -- 840
			local fn = ____opt_20 -- 841
			if (fn and fn.name) == "save_sub_agent_memory_entry" then -- 841
				return fn -- 842
			end -- 842
			i = i + 1 -- 840
		end -- 840
	end -- 840
	return nil -- 844
end -- 844
function getMemoryEntryPlainContent(response) -- 847
	if not response or __TS__ArrayIsArray(response) or type(response) ~= "table" then -- 847
		return "" -- 848
	end -- 848
	local row = response -- 849
	local choices = row.choices -- 850
	if not __TS__ArrayIsArray(choices) or #choices == 0 then -- 850
		return "" -- 851
	end -- 851
	local ____opt_24 = choices[1] -- 851
	if ____opt_24 ~= nil then -- 851
		____opt_24 = ____opt_24.message -- 851
	end -- 851
	local message = ____opt_24 -- 852
	local ____opt_result_28 -- 852
	if message ~= nil then -- 852
		____opt_result_28 = message.content -- 852
	end -- 852
	return type(____opt_result_28) == "string" and __TS__StringTrim(sanitizeUTF8(message.content)) or "" -- 853
end -- 853
function decodeMemoryEntryFromPlainContent(content) -- 856
	if content == "" then -- 856
		return nil -- 857
	end -- 857
	local direct = safeJsonDecode(content) -- 858
	if direct ~= nil then -- 858
		return direct -- 859
	end -- 859
	local start = string.find(content, "{", 1, true) -- 860
	if start == nil then -- 860
		return nil -- 861
	end -- 861
	local ____end = #content -- 862
	while ____end >= start do -- 862
		local candidate = string.sub(content, start, ____end) -- 864
		local value = safeJsonDecode(candidate) -- 865
		if value ~= nil then -- 865
			return value -- 866
		end -- 866
		____end = ____end - 1 -- 867
	end -- 867
	return nil -- 869
end -- 869
function hasEmptyMemoryEntryContent(value) -- 872
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 872
		return false -- 873
	end -- 873
	local row = value -- 874
	return type(row.content) == "string" and __TS__StringTrim(sanitizeUTF8(row.content)) == "" -- 875
end -- 875
function generateSubAgentMemoryEntry(session, record, resultText) -- 878
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 878
		if not record.success then -- 878
			return ____awaiter_resolve(nil, {}) -- 878
		end -- 878
		local configRes = getActiveLLMConfig() -- 880
		if not configRes.success then -- 880
			return ____awaiter_resolve(nil, {error = configRes.message}) -- 880
		end -- 880
		local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 884
		local persisted = storage:readSessionState() -- 885
		local memoryContext = storage:readMemory() -- 886
		local recentMessageTail = buildSubAgentRecentMessageTail(persisted.messages) -- 887
		local prompt = buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail) -- 888
		local tools = configRes.config.supportsFunctionCalling and buildSubAgentMemoryEntryToolSchema() or nil -- 889
		local lastError = "missing memory entry" -- 890
		do -- 890
			local attempt = 0 -- 891
			while attempt < SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY do -- 891
				do -- 891
					local useTools = attempt == 0 and tools ~= nil -- 892
					local messages = { -- 893
						{ -- 894
							role = "system", -- 894
							content = buildSubAgentMemoryEntrySystemPrompt() -- 894
						}, -- 894
						{ -- 895
							role = "user", -- 896
							content = attempt == 0 and prompt or (prompt .. "\n\n") .. buildSubAgentMemoryEntryRetryPrompt(lastError) -- 897
						} -- 897
					} -- 897
					local response = __TS__Await(callLLM( -- 902
						messages, -- 903
						__TS__ObjectAssign( -- 904
							{}, -- 904
							buildSubAgentMemoryEntryLLMOptions(configRes.config), -- 905
							useTools and ({tools = tools}) or ({}) -- 906
						), -- 906
						configRes.config -- 908
					)) -- 908
					if not response.success then -- 908
						lastError = response.message -- 911
						if useTools then -- 911
							Log("Warn", "[AgentSession] sub session memory entry tool request failed, retrying without tools: " .. response.message) -- 913
						end -- 913
						goto __continue154 -- 915
					end -- 915
					local fn = getMemoryEntryToolFunction(response.response) -- 917
					local argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 918
					if fn ~= nil and argsText ~= "" then -- 918
						local args, err = safeJsonDecode(argsText) -- 920
						if err ~= nil or args == nil then -- 920
							lastError = "invalid memory entry tool arguments: " .. tostring(err) -- 922
							goto __continue154 -- 923
						end -- 923
						if hasEmptyMemoryEntryContent(args) then -- 923
							return ____awaiter_resolve(nil, {}) -- 923
						end -- 923
						local entry = normalizeGeneratedSubAgentMemoryEntry(args, record) -- 926
						if entry ~= nil then -- 926
							return ____awaiter_resolve(nil, {entry = entry}) -- 926
						end -- 926
						lastError = "invalid memory entry tool arguments shape" -- 928
						goto __continue154 -- 929
					end -- 929
					local plainContent = getMemoryEntryPlainContent(response.response) -- 931
					local plainArgs = decodeMemoryEntryFromPlainContent(plainContent) -- 932
					if plainArgs ~= nil then -- 932
						if hasEmptyMemoryEntryContent(plainArgs) then -- 932
							return ____awaiter_resolve(nil, {}) -- 932
						end -- 932
						local entry = normalizeGeneratedSubAgentMemoryEntry(plainArgs, record) -- 935
						if entry ~= nil then -- 935
							return ____awaiter_resolve(nil, {entry = entry}) -- 935
						end -- 935
						lastError = "invalid memory entry JSON shape" -- 937
						goto __continue154 -- 938
					end -- 938
					lastError = "LLM did not return memory entry tool call or JSON content" -- 940
				end -- 940
				::__continue154:: -- 940
				attempt = attempt + 1 -- 891
			end -- 891
		end -- 891
		return ____awaiter_resolve(nil, {error = lastError}) -- 891
	end) -- 891
end -- 891
function containsNormalizedText(text, query) -- 945
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 946
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 947
	if normalizedQuery == "" then -- 947
		return true -- 948
	end -- 948
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 949
end -- 949
function getSubAgentDisplayKey(item) -- 952
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 958
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 959
	local label = goal ~= "" and goal or title -- 960
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 961
end -- 961
function writeSubAgentResultFile(session, record, resultText) -- 964
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 965
	if not Content:exist(dir) then -- 965
		ensureDirRecursive(dir) -- 967
	end -- 967
	local ____array_29 = __TS__SparseArrayNew( -- 967
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 970
		"- Status: " .. record.status, -- 971
		"- Success: " .. (record.success and "true" or "false"), -- 972
		"- Session ID: " .. tostring(record.sessionId), -- 973
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 974
		"- Goal: " .. record.goal, -- 975
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 976
	) -- 976
	__TS__SparseArrayPush( -- 976
		____array_29, -- 976
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 977
	) -- 977
	__TS__SparseArrayPush( -- 977
		____array_29, -- 977
		"- Finished At: " .. record.finishedAt, -- 978
		"", -- 979
		"## Summary", -- 980
		resultText ~= "" and resultText or "(empty)" -- 981
	) -- 981
	local lines = {__TS__SparseArraySpread(____array_29)} -- 969
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 983
	local content = table.concat(lines, "\n") .. "\n" -- 984
	if not Content:save(path, content) then -- 984
		return false -- 986
	end -- 986
	Tools.sendWebIDEFileUpdate(path, true, content) -- 988
	return true -- 989
end -- 989
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 992
	local dir = Path(projectRoot, ".agent", "subagents") -- 993
	if not Content:exist(dir) or not Content:isdir(dir) then -- 993
		return {} -- 994
	end -- 994
	local items = {} -- 995
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 996
		do -- 996
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 997
			if not Content:exist(path) or not Content:isdir(path) then -- 997
				goto __continue172 -- 998
			end -- 998
			local info = readSpawnInfo( -- 999
				projectRoot, -- 999
				Path( -- 999
					"subagents", -- 999
					Path:getFilename(path) -- 999
				) -- 999
			) -- 999
			if not info then -- 999
				goto __continue172 -- 1000
			end -- 1000
			local sessionId = tonumber(info.sessionId) -- 1001
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1002
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1003
			local status = sanitizeUTF8(toStr(info.status)) -- 1004
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1004
				goto __continue172 -- 1005
			end -- 1005
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1005
				goto __continue172 -- 1006
			end -- 1006
			items[#items + 1] = { -- 1007
				sessionId = sessionId, -- 1008
				rootSessionId = infoRootSessionId, -- 1009
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1010
				title = sanitizeUTF8(toStr(info.title)), -- 1011
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1012
				goal = sanitizeUTF8(toStr(info.goal)), -- 1013
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1014
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1015
					__TS__ArrayFilter( -- 1016
						info.filesHint, -- 1016
						function(____, item) return type(item) == "string" end -- 1016
					), -- 1016
					function(____, item) return sanitizeUTF8(item) end -- 1016
				) or ({}), -- 1016
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1018
				success = info.success == true, -- 1019
				cleared = info.cleared == true, -- 1020
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1021
				artifactDir = sanitizeUTF8(toStr(info.artifactDir)) or getArtifactRelativeDir(Path( -- 1022
					"subagents", -- 1022
					Path:getFilename(path) -- 1022
				)), -- 1022
				sourceTaskId = sourceTaskId or 0, -- 1023
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1024
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1025
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1026
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1027
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1028
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1029
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1030
			} -- 1030
		end -- 1030
		::__continue172:: -- 1030
	end -- 1030
	__TS__ArraySort( -- 1033
		items, -- 1033
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1033
	) -- 1033
	return items -- 1034
end -- 1034
function getPendingHandoffDir(projectRoot, memoryScope) -- 1037
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1038
end -- 1038
function writePendingHandoff(projectRoot, memoryScope, value) -- 1041
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1042
	if not Content:exist(dir) then -- 1042
		ensureDirRecursive(dir) -- 1044
	end -- 1044
	local path = Path(dir, value.id .. ".json") -- 1046
	local text = safeJsonEncode(value) -- 1047
	if not text then -- 1047
		return false -- 1048
	end -- 1048
	return Content:save(path, text .. "\n") -- 1049
end -- 1049
function listPendingHandoffs(projectRoot, memoryScope) -- 1052
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1053
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1053
		return {} -- 1054
	end -- 1054
	local items = {} -- 1055
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1056
		do -- 1056
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1057
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1057
				goto __continue187 -- 1058
			end -- 1058
			local text = Content:load(path) -- 1059
			if not text or __TS__StringTrim(text) == "" then -- 1059
				goto __continue187 -- 1060
			end -- 1060
			local value = safeJsonDecode(text) -- 1061
			if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 1061
				goto __continue187 -- 1062
			end -- 1062
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1063
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1064
			local id = sanitizeUTF8(toStr(value.id)) -- 1065
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1066
			local message = sanitizeUTF8(toStr(value.message)) -- 1067
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1068
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1069
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1070
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1070
				goto __continue187 -- 1072
			end -- 1072
			items[#items + 1] = { -- 1074
				id = id, -- 1075
				sourceSessionId = sourceSessionId, -- 1076
				sourceTitle = sourceTitle, -- 1077
				sourceTaskId = sourceTaskId, -- 1078
				message = message, -- 1079
				prompt = prompt, -- 1080
				goal = goal, -- 1081
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1082
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1083
					__TS__ArrayFilter( -- 1084
						value.filesHint, -- 1084
						function(____, item) return type(item) == "string" end -- 1084
					), -- 1084
					function(____, item) return sanitizeUTF8(item) end -- 1084
				) or ({}), -- 1084
				success = value.success == true, -- 1086
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1087
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1088
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1089
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1090
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1091
				createdAt = createdAt -- 1092
			} -- 1092
		end -- 1092
		::__continue187:: -- 1092
	end -- 1092
	__TS__ArraySort( -- 1095
		items, -- 1095
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1095
	) -- 1095
	return items -- 1096
end -- 1096
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1099
	local path = Path( -- 1100
		getPendingHandoffDir(projectRoot, memoryScope), -- 1100
		id .. ".json" -- 1100
	) -- 1100
	if Content:exist(path) then -- 1100
		Content:remove(path) -- 1102
	end -- 1102
end -- 1102
function normalizePromptText(prompt) -- 1106
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1107
end -- 1107
function normalizePromptTextSafe(prompt) -- 1110
	if type(prompt) == "string" then -- 1110
		local normalized = normalizePromptText(prompt) -- 1112
		if normalized ~= "" then -- 1112
			return normalized -- 1113
		end -- 1113
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1114
		if sanitized ~= "" then -- 1114
			return truncateAgentUserPrompt(sanitized) -- 1116
		end -- 1116
		return "" -- 1118
	end -- 1118
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1120
	if text == "" then -- 1120
		return "" -- 1121
	end -- 1121
	return truncateAgentUserPrompt(text) -- 1122
end -- 1122
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1125
	local sections = {} -- 1126
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1127
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1128
	local normalizedFiles = __TS__ArrayFilter( -- 1129
		__TS__ArrayMap( -- 1129
			__TS__ArrayFilter( -- 1129
				filesHint or ({}), -- 1129
				function(____, item) return type(item) == "string" end -- 1130
			), -- 1130
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1131
		), -- 1131
		function(____, item) return item ~= "" end -- 1132
	) -- 1132
	if normalizedTitle ~= "" then -- 1132
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1134
	end -- 1134
	if normalizedExpected ~= "" then -- 1134
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1137
	end -- 1137
	if #normalizedFiles > 0 then -- 1137
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1140
	end -- 1140
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1142
end -- 1142
function normalizeSessionRuntimeState(session) -- 1145
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1145
		return session -- 1147
	end -- 1147
	if activeStopTokens[session.currentTaskId] then -- 1147
		return session -- 1150
	end -- 1150
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1152
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1153
	return __TS__ObjectAssign( -- 1154
		{}, -- 1154
		session, -- 1155
		{ -- 1154
			status = "STOPPED", -- 1156
			currentTaskStatus = "STOPPED", -- 1157
			updatedAt = now() -- 1158
		} -- 1158
	) -- 1158
end -- 1158
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1162
	DB:exec( -- 1163
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1163
		{ -- 1167
			status, -- 1168
			currentTaskId or 0, -- 1169
			currentTaskStatus or status, -- 1170
			now(), -- 1171
			sessionId -- 1172
		} -- 1172
	) -- 1172
end -- 1172
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1177
	if taskId == nil or taskId <= 0 then -- 1177
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1179
		return -- 1180
	end -- 1180
	local row = getSessionRow(sessionId) -- 1182
	if not row then -- 1182
		return -- 1183
	end -- 1183
	local session = rowToSession(row) -- 1184
	if session.currentTaskId ~= taskId then -- 1184
		Log( -- 1186
			"Info", -- 1186
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1186
		) -- 1186
		return -- 1187
	end -- 1187
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1189
end -- 1189
function insertMessage(sessionId, role, content, taskId) -- 1192
	local t = now() -- 1193
	DB:exec( -- 1194
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1194
		{ -- 1197
			sessionId, -- 1198
			taskId or 0, -- 1199
			role, -- 1200
			sanitizeUTF8(content), -- 1201
			t, -- 1202
			t -- 1203
		} -- 1203
	) -- 1203
	return getLastInsertRowId() -- 1206
end -- 1206
function updateMessage(messageId, content) -- 1209
	DB:exec( -- 1210
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1210
		{ -- 1212
			sanitizeUTF8(content), -- 1212
			now(), -- 1212
			messageId -- 1212
		} -- 1212
	) -- 1212
end -- 1212
function upsertAssistantMessage(sessionId, taskId, content) -- 1216
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1217
	if row and type(row[1]) == "number" then -- 1217
		updateMessage(row[1], content) -- 1224
		return row[1] -- 1225
	end -- 1225
	return insertMessage(sessionId, "assistant", content, taskId) -- 1227
end -- 1227
function upsertStep(sessionId, taskId, step, tool, patch) -- 1230
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1240
	local reason = sanitizeUTF8(patch.reason or "") -- 1244
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1245
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1246
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1247
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1248
	local statusPatch = patch.status or "" -- 1249
	local status = patch.status or "PENDING" -- 1250
	if not row then -- 1250
		local t = now() -- 1252
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1253
			sessionId, -- 1257
			taskId, -- 1258
			step, -- 1259
			tool, -- 1260
			status, -- 1261
			reason, -- 1262
			reasoningContent, -- 1263
			paramsJson, -- 1264
			resultJson, -- 1265
			patch.checkpointId or 0, -- 1266
			patch.checkpointSeq or 0, -- 1267
			filesJson, -- 1268
			t, -- 1269
			t -- 1270
		}) -- 1270
		return -- 1273
	end -- 1273
	DB:exec( -- 1275
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1275
		{ -- 1287
			tool, -- 1288
			statusPatch, -- 1289
			status, -- 1290
			reason, -- 1291
			reason, -- 1292
			reasoningContent, -- 1293
			reasoningContent, -- 1294
			paramsJson, -- 1295
			paramsJson, -- 1296
			resultJson, -- 1297
			resultJson, -- 1298
			patch.checkpointId or 0, -- 1299
			patch.checkpointId or 0, -- 1300
			patch.checkpointSeq or 0, -- 1301
			patch.checkpointSeq or 0, -- 1302
			filesJson, -- 1303
			filesJson, -- 1304
			now(), -- 1305
			row[1] -- 1306
		} -- 1306
	) -- 1306
end -- 1306
function getNextStepNumber(sessionId, taskId) -- 1311
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1312
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1316
	return math.max(0, current) + 1 -- 1317
end -- 1317
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1320
	if status == nil then -- 1320
		status = "DONE" -- 1328
	end -- 1328
	local step = getNextStepNumber(sessionId, taskId) -- 1330
	upsertStep( -- 1331
		sessionId, -- 1331
		taskId, -- 1331
		step, -- 1331
		tool, -- 1331
		{status = status, reason = reason, params = params, result = result} -- 1331
	) -- 1331
	return getStepItem(sessionId, taskId, step) -- 1337
end -- 1337
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1340
	if taskId <= 0 then -- 1340
		return -- 1341
	end -- 1341
	if finalSteps ~= nil and finalSteps >= 0 then -- 1341
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1343
	end -- 1343
	if not finalStatus then -- 1343
		return -- 1349
	end -- 1349
	if finalSteps ~= nil and finalSteps >= 0 then -- 1349
		DB:exec( -- 1351
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1351
			{ -- 1355
				finalStatus, -- 1355
				now(), -- 1355
				sessionId, -- 1355
				taskId, -- 1355
				finalSteps -- 1355
			} -- 1355
		) -- 1355
		return -- 1357
	end -- 1357
	DB:exec( -- 1359
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1359
		{ -- 1363
			finalStatus, -- 1363
			now(), -- 1363
			sessionId, -- 1363
			taskId -- 1363
		} -- 1363
	) -- 1363
end -- 1363
function emitAgentSessionPatch(sessionId, patch) -- 1390
	if HttpServer.wsConnectionCount == 0 then -- 1390
		return -- 1392
	end -- 1392
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1394
	if not text then -- 1394
		return -- 1399
	end -- 1399
	emit("AppWS", "Send", text) -- 1400
end -- 1400
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1403
	emitAgentSessionPatch( -- 1404
		sessionId, -- 1404
		{ -- 1404
			sessionDeleted = true, -- 1405
			relatedSessions = listRelatedSessions(rootSessionId) -- 1406
		} -- 1406
	) -- 1406
	local rootSession = getSessionItem(rootSessionId) -- 1408
	if rootSession then -- 1408
		emitAgentSessionPatch( -- 1410
			rootSessionId, -- 1410
			{ -- 1410
				session = rootSession, -- 1411
				relatedSessions = listRelatedSessions(rootSessionId) -- 1412
			} -- 1412
		) -- 1412
	end -- 1412
end -- 1412
function flushPendingSubAgentHandoffs(rootSession) -- 1417
	if rootSession.kind ~= "main" then -- 1417
		return -- 1418
	end -- 1418
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1418
		return -- 1420
	end -- 1420
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1422
	if #items == 0 then -- 1422
		return -- 1423
	end -- 1423
	local handoffTaskId = 0 -- 1424
	local ____rootSession_currentTaskId_30 -- 1425
	if rootSession.currentTaskId then -- 1425
		____rootSession_currentTaskId_30 = getTaskPrompt(rootSession.currentTaskId) -- 1425
	else -- 1425
		____rootSession_currentTaskId_30 = nil -- 1425
	end -- 1425
	local currentTaskPrompt = ____rootSession_currentTaskId_30 -- 1425
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1425
		handoffTaskId = rootSession.currentTaskId -- 1433
	else -- 1433
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1435
		if not taskRes.success then -- 1435
			Log( -- 1437
				"Warn", -- 1437
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1437
			) -- 1437
			return -- 1438
		end -- 1438
		handoffTaskId = taskRes.taskId -- 1440
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1441
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1442
		emitAgentSessionPatch( -- 1443
			rootSession.id, -- 1443
			{session = getSessionItem(rootSession.id)} -- 1443
		) -- 1443
	end -- 1443
	do -- 1443
		local i = 0 -- 1447
		while i < #items do -- 1447
			local item = items[i + 1] -- 1448
			local step = appendSystemStep( -- 1449
				rootSession.id, -- 1450
				handoffTaskId, -- 1451
				"sub_agent_handoff", -- 1452
				"sub_agent_handoff", -- 1453
				item.message, -- 1454
				{ -- 1455
					sourceSessionId = item.sourceSessionId, -- 1456
					sourceTitle = item.sourceTitle, -- 1457
					sourceTaskId = item.sourceTaskId, -- 1458
					success = item.success == true, -- 1459
					summary = item.message, -- 1460
					resultFilePath = item.resultFilePath or "", -- 1461
					artifactDir = item.artifactDir or "", -- 1462
					finishedAt = item.finishedAt or "", -- 1463
					changeSet = item.changeSet, -- 1464
					memoryEntry = item.memoryEntry -- 1465
				}, -- 1465
				{ -- 1467
					sourceSessionId = item.sourceSessionId, -- 1468
					sourceTitle = item.sourceTitle, -- 1469
					sourceTaskId = item.sourceTaskId, -- 1470
					prompt = item.prompt, -- 1471
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1472
					expectedOutput = item.expectedOutput or "", -- 1473
					filesHint = item.filesHint or ({}), -- 1474
					resultFilePath = item.resultFilePath or "", -- 1475
					artifactDir = item.artifactDir or "", -- 1476
					changeSet = item.changeSet, -- 1477
					memoryEntry = item.memoryEntry -- 1478
				}, -- 1478
				"DONE" -- 1480
			) -- 1480
			if step then -- 1480
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1483
			end -- 1483
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1485
			i = i + 1 -- 1447
		end -- 1447
	end -- 1447
end -- 1447
function applyEvent(sessionId, event) -- 1489
	repeat -- 1489
		local ____switch249 = event.type -- 1489
		local ____cond249 = ____switch249 == "task_started" -- 1489
		if ____cond249 then -- 1489
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1492
			emitAgentSessionPatch( -- 1493
				sessionId, -- 1493
				{session = getSessionItem(sessionId)} -- 1493
			) -- 1493
			break -- 1496
		end -- 1496
		____cond249 = ____cond249 or ____switch249 == "decision_made" -- 1496
		if ____cond249 then -- 1496
			upsertStep( -- 1498
				sessionId, -- 1498
				event.taskId, -- 1498
				event.step, -- 1498
				event.tool, -- 1498
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1498
			) -- 1498
			emitAgentSessionPatch( -- 1504
				sessionId, -- 1504
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1504
			) -- 1504
			break -- 1507
		end -- 1507
		____cond249 = ____cond249 or ____switch249 == "tool_started" -- 1507
		if ____cond249 then -- 1507
			upsertStep( -- 1509
				sessionId, -- 1509
				event.taskId, -- 1509
				event.step, -- 1509
				event.tool, -- 1509
				{status = "RUNNING"} -- 1509
			) -- 1509
			emitAgentSessionPatch( -- 1512
				sessionId, -- 1512
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1512
			) -- 1512
			break -- 1515
		end -- 1515
		____cond249 = ____cond249 or ____switch249 == "tool_finished" -- 1515
		if ____cond249 then -- 1515
			upsertStep( -- 1517
				sessionId, -- 1517
				event.taskId, -- 1517
				event.step, -- 1517
				event.tool, -- 1517
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1517
			) -- 1517
			emitAgentSessionPatch( -- 1522
				sessionId, -- 1522
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1522
			) -- 1522
			break -- 1525
		end -- 1525
		____cond249 = ____cond249 or ____switch249 == "checkpoint_created" -- 1525
		if ____cond249 then -- 1525
			upsertStep( -- 1527
				sessionId, -- 1527
				event.taskId, -- 1527
				event.step, -- 1527
				event.tool, -- 1527
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1527
			) -- 1527
			emitAgentSessionPatch( -- 1532
				sessionId, -- 1532
				{ -- 1532
					step = getStepItem(sessionId, event.taskId, event.step), -- 1533
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1534
				} -- 1534
			) -- 1534
			break -- 1536
		end -- 1536
		____cond249 = ____cond249 or ____switch249 == "memory_compression_started" -- 1536
		if ____cond249 then -- 1536
			upsertStep( -- 1538
				sessionId, -- 1538
				event.taskId, -- 1538
				event.step, -- 1538
				event.tool, -- 1538
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1538
			) -- 1538
			emitAgentSessionPatch( -- 1543
				sessionId, -- 1543
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1543
			) -- 1543
			break -- 1546
		end -- 1546
		____cond249 = ____cond249 or ____switch249 == "memory_compression_finished" -- 1546
		if ____cond249 then -- 1546
			upsertStep( -- 1548
				sessionId, -- 1548
				event.taskId, -- 1548
				event.step, -- 1548
				event.tool, -- 1548
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1548
			) -- 1548
			emitAgentSessionPatch( -- 1553
				sessionId, -- 1553
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1553
			) -- 1553
			break -- 1556
		end -- 1556
		____cond249 = ____cond249 or ____switch249 == "assistant_message_updated" -- 1556
		if ____cond249 then -- 1556
			do -- 1556
				upsertStep( -- 1558
					sessionId, -- 1558
					event.taskId, -- 1558
					event.step, -- 1558
					"message", -- 1558
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1558
				) -- 1558
				emitAgentSessionPatch( -- 1563
					sessionId, -- 1563
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1563
				) -- 1563
				break -- 1566
			end -- 1566
		end -- 1566
		____cond249 = ____cond249 or ____switch249 == "task_finished" -- 1566
		if ____cond249 then -- 1566
			do -- 1566
				local ____opt_31 = activeStopTokens[event.taskId or -1] -- 1566
				local stopped = (____opt_31 and ____opt_31.stopped) == true -- 1569
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1570
				setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus) -- 1573
				if event.taskId ~= nil then -- 1573
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1575
					local ____finalizeTaskSteps_35 = finalizeTaskSteps -- 1576
					local ____array_34 = __TS__SparseArrayNew( -- 1576
						sessionId, -- 1577
						event.taskId, -- 1578
						type(event.steps) == "number" and math.max( -- 1579
							0, -- 1579
							math.floor(event.steps) -- 1579
						) or nil -- 1579
					) -- 1579
					local ____event_success_33 -- 1580
					if event.success then -- 1580
						____event_success_33 = nil -- 1580
					else -- 1580
						____event_success_33 = stopped and "STOPPED" or "FAILED" -- 1580
					end -- 1580
					__TS__SparseArrayPush(____array_34, ____event_success_33) -- 1580
					____finalizeTaskSteps_35(__TS__SparseArraySpread(____array_34)) -- 1576
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1582
					activeStopTokens[event.taskId] = nil -- 1583
					emitAgentSessionPatch( -- 1584
						sessionId, -- 1584
						{ -- 1584
							session = getSessionItem(sessionId), -- 1585
							message = getMessageItem(messageId), -- 1586
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1587
							removedStepIds = removedStepIds -- 1588
						} -- 1588
					) -- 1588
				end -- 1588
				local session = getSessionItem(sessionId) -- 1591
				if session and session.kind == "main" then -- 1591
					flushPendingSubAgentHandoffs(session) -- 1593
				end -- 1593
				break -- 1595
			end -- 1595
		end -- 1595
	until true -- 1595
end -- 1595
function ____exports.createSession(projectRoot, title) -- 1712
	if title == nil then -- 1712
		title = "" -- 1712
	end -- 1712
	if not isValidProjectRoot(projectRoot) then -- 1712
		return {success = false, message = "invalid projectRoot"} -- 1714
	end -- 1714
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1716
	if row then -- 1716
		return { -- 1725
			success = true, -- 1725
			session = rowToSession(row) -- 1725
		} -- 1725
	end -- 1725
	local t = now() -- 1727
	DB:exec( -- 1728
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1728
		{ -- 1731
			projectRoot, -- 1731
			title ~= "" and title or Path:getFilename(projectRoot), -- 1731
			t, -- 1731
			t -- 1731
		} -- 1731
	) -- 1731
	local sessionId = getLastInsertRowId() -- 1733
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1734
	local session = getSessionItem(sessionId) -- 1735
	if not session then -- 1735
		return {success = false, message = "failed to create session"} -- 1737
	end -- 1737
	return {success = true, session = session} -- 1739
end -- 1712
function ____exports.createSubSession(parentSessionId, title) -- 1742
	if title == nil then -- 1742
		title = "" -- 1742
	end -- 1742
	local parent = getSessionItem(parentSessionId) -- 1743
	if not parent then -- 1743
		return {success = false, message = "parent session not found"} -- 1745
	end -- 1745
	local rootId = getSessionRootId(parent) -- 1747
	local t = now() -- 1748
	DB:exec( -- 1749
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1749
		{ -- 1752
			parent.projectRoot, -- 1752
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1752
			rootId, -- 1752
			parent.id, -- 1752
			t, -- 1752
			t -- 1752
		} -- 1752
	) -- 1752
	local sessionId = getLastInsertRowId() -- 1754
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1755
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1756
	local session = getSessionItem(sessionId) -- 1757
	if not session then -- 1757
		return {success = false, message = "failed to create sub session"} -- 1759
	end -- 1759
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1761
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1762
	subStorage:writeMemory(parentStorage:readMemory()) -- 1763
	return {success = true, session = session} -- 1764
end -- 1742
function spawnSubAgentSession(request) -- 1767
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1767
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1778
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1779
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1780
		if normalizedPrompt == "" then -- 1780
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1782
		end -- 1782
		if normalizedPrompt == "" then -- 1782
			local ____Log_41 = Log -- 1789
			local ____temp_38 = #normalizedTitle -- 1789
			local ____temp_39 = #rawPrompt -- 1789
			local ____temp_40 = #toStr(request.expectedOutput) -- 1789
			local ____opt_36 = request.filesHint -- 1789
			____Log_41( -- 1789
				"Warn", -- 1789
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_38)) .. " raw_prompt_len=") .. tostring(____temp_39)) .. " expected_len=") .. tostring(____temp_40)) .. " files_hint_count=") .. tostring(____opt_36 and #____opt_36 or 0) -- 1789
			) -- 1789
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1789
		end -- 1789
		Log( -- 1792
			"Info", -- 1792
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1792
		) -- 1792
		local parentSessionId = request.parentSessionId -- 1793
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1793
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1795
			if not fallbackParent then -- 1795
				local createdMain = ____exports.createSession(request.projectRoot) -- 1797
				if createdMain.success then -- 1797
					fallbackParent = createdMain.session -- 1799
				end -- 1799
			end -- 1799
			if fallbackParent then -- 1799
				Log( -- 1803
					"Warn", -- 1803
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1803
				) -- 1803
				parentSessionId = fallbackParent.id -- 1804
			end -- 1804
		end -- 1804
		local parentSession = getSessionItem(parentSessionId) -- 1807
		if not parentSession then -- 1807
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1807
		end -- 1807
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1811
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1811
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1811
		end -- 1811
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1815
		if not created.success then -- 1815
			return ____awaiter_resolve(nil, created) -- 1815
		end -- 1815
		writeSpawnInfo( -- 1819
			created.session.projectRoot, -- 1819
			created.session.memoryScope, -- 1819
			{ -- 1819
				sessionId = created.session.id, -- 1820
				rootSessionId = created.session.rootSessionId, -- 1821
				parentSessionId = created.session.parentSessionId, -- 1822
				title = created.session.title, -- 1823
				prompt = normalizedPrompt, -- 1824
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1825
				expectedOutput = request.expectedOutput or "", -- 1826
				filesHint = request.filesHint or ({}), -- 1827
				status = "RUNNING", -- 1828
				success = false, -- 1829
				resultFilePath = "", -- 1830
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1831
				sourceTaskId = 0, -- 1832
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1833
				createdAtTs = created.session.createdAt, -- 1834
				finishedAt = "", -- 1835
				finishedAtTs = 0 -- 1836
			} -- 1836
		) -- 1836
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true) -- 1838
		if not sent.success then -- 1838
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1838
		end -- 1838
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1838
	end) -- 1838
end -- 1838
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 1919
	local rootSession = getRootSessionItem(session.id) -- 1920
	if not rootSession then -- 1920
		return -- 1921
	end -- 1921
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 1922
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1923
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1924
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1925
	local queueResult = writePendingHandoff( -- 1926
		rootSession.projectRoot, -- 1926
		rootSession.memoryScope, -- 1926
		{ -- 1926
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1927
			sourceSessionId = session.id, -- 1928
			sourceTitle = session.title, -- 1929
			sourceTaskId = taskId, -- 1930
			message = summary, -- 1931
			prompt = result.prompt, -- 1932
			goal = result.goal, -- 1933
			expectedOutput = result.expectedOutput or "", -- 1934
			filesHint = result.filesHint or ({}), -- 1935
			success = result.success, -- 1936
			resultFilePath = result.resultFilePath, -- 1937
			artifactDir = result.artifactDir, -- 1938
			finishedAt = result.finishedAt, -- 1939
			changeSet = changeSet, -- 1940
			memoryEntry = result.memoryEntry, -- 1941
			createdAt = createdAt -- 1942
		} -- 1942
	) -- 1942
	if not queueResult then -- 1942
		Log( -- 1945
			"Warn", -- 1945
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1945
		) -- 1945
		return -- 1946
	end -- 1946
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1946
		flushPendingSubAgentHandoffs(rootSession) -- 1949
	end -- 1949
end -- 1949
function finalizeSubSession(session, taskId, success, message) -- 1953
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1953
		local rootSessionId = getSessionRootId(session) -- 1954
		local rootSession = getRootSessionItem(session.id) -- 1955
		if not rootSession then -- 1955
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 1955
		end -- 1955
		local spawnInfo = getSessionSpawnInfo(session) -- 1959
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1960
		local finishedAtTs = now() -- 1961
		local resultText = sanitizeUTF8(message) -- 1962
		local changeSet = getTaskChangeSetSummary(taskId) -- 1963
		local record = { -- 1964
			sessionId = session.id, -- 1965
			rootSessionId = rootSessionId, -- 1966
			parentSessionId = session.parentSessionId, -- 1967
			title = session.title, -- 1968
			prompt = spawnInfo and spawnInfo.prompt or "", -- 1969
			goal = spawnInfo and spawnInfo.goal or session.title, -- 1970
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 1971
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 1972
			status = success and "DONE" or "FAILED", -- 1973
			success = success, -- 1974
			resultFilePath = getResultRelativePath(session.memoryScope), -- 1975
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 1976
			sourceTaskId = taskId, -- 1977
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 1978
			finishedAt = finishedAt, -- 1979
			createdAtTs = session.createdAt, -- 1980
			finishedAtTs = finishedAtTs, -- 1981
			changeSet = changeSet -- 1982
		} -- 1982
		if record.success then -- 1982
			local memoryEntryResult = __TS__Await(generateSubAgentMemoryEntry(session, record, resultText)) -- 1985
			record.memoryEntry = memoryEntryResult.entry -- 1986
			if memoryEntryResult.error and memoryEntryResult.error ~= "" then -- 1986
				record.memoryEntryError = memoryEntryResult.error -- 1988
				Log( -- 1989
					"Warn", -- 1989
					(("[AgentSession] sub session memory entry failed session=" .. tostring(session.id)) .. " error=") .. memoryEntryResult.error -- 1989
				) -- 1989
			end -- 1989
		end -- 1989
		if not writeSubAgentResultFile(session, record, resultText) then -- 1989
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 1989
		end -- 1989
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 1989
			sessionId = record.sessionId, -- 1996
			rootSessionId = record.rootSessionId, -- 1997
			parentSessionId = record.parentSessionId, -- 1998
			title = record.title, -- 1999
			prompt = record.prompt, -- 2000
			goal = record.goal, -- 2001
			expectedOutput = record.expectedOutput or "", -- 2002
			filesHint = record.filesHint or ({}), -- 2003
			status = record.status, -- 2004
			success = record.success, -- 2005
			resultFilePath = record.resultFilePath, -- 2006
			artifactDir = record.artifactDir, -- 2007
			sourceTaskId = record.sourceTaskId, -- 2008
			createdAt = record.createdAt, -- 2009
			finishedAt = record.finishedAt, -- 2010
			createdAtTs = record.createdAtTs, -- 2011
			finishedAtTs = record.finishedAtTs, -- 2012
			changeSet = record.changeSet, -- 2013
			memoryEntry = record.memoryEntry, -- 2014
			memoryEntryError = record.memoryEntryError -- 2015
		}) then -- 2015
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2015
		end -- 2015
		if success then -- 2015
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2020
			deleteSessionRecords(session.id, true) -- 2021
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2022
		end -- 2022
		return ____awaiter_resolve(nil, {success = true}) -- 2022
	end) -- 2022
end -- 2022
function stopClearedSubSession(session, taskId) -- 2027
	local spawnInfo = getSessionSpawnInfo(session) -- 2028
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2029
	local rootSessionId = getSessionRootId(session) -- 2030
	Tools.setTaskStatus(taskId, "STOPPED") -- 2031
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2032
	if not writeSpawnInfo( -- 2032
		session.projectRoot, -- 2033
		session.memoryScope, -- 2033
		{ -- 2033
			sessionId = session.id, -- 2034
			rootSessionId = rootSessionId, -- 2035
			parentSessionId = session.parentSessionId, -- 2036
			title = session.title, -- 2037
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2038
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2039
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2040
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2041
			status = "STOPPED", -- 2042
			success = false, -- 2043
			cleared = true, -- 2044
			resultFilePath = "", -- 2045
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2046
			sourceTaskId = taskId, -- 2047
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2048
			finishedAt = finishedAt, -- 2049
			createdAtTs = session.createdAt, -- 2050
			finishedAtTs = now() -- 2051
		} -- 2051
	) then -- 2051
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2053
	end -- 2053
	deleteSessionRecords(session.id, true) -- 2055
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2056
	return {success = true} -- 2057
end -- 2057
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart) -- 2060
	if allowSubSessionStart == nil then -- 2060
		allowSubSessionStart = false -- 2060
	end -- 2060
	local session = getSessionItem(sessionId) -- 2061
	if not session then -- 2061
		return {success = false, message = "session not found"} -- 2063
	end -- 2063
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2063
		return {success = false, message = "session task is still running"} -- 2066
	end -- 2066
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2068
	if normalizedPrompt == "" and session.kind == "sub" then -- 2068
		local spawnInfo = getSessionSpawnInfo(session) -- 2070
		if spawnInfo then -- 2070
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2072
			if normalizedPrompt == "" then -- 2072
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2074
			end -- 2074
		end -- 2074
	end -- 2074
	if normalizedPrompt == "" then -- 2074
		return {success = false, message = "prompt is empty"} -- 2083
	end -- 2083
	local taskRes = Tools.createTask(normalizedPrompt) -- 2085
	if not taskRes.success then -- 2085
		return {success = false, message = taskRes.message} -- 2087
	end -- 2087
	local taskId = taskRes.taskId -- 2089
	local useChineseResponse = getDefaultUseChineseResponse() -- 2090
	insertMessage(sessionId, "user", normalizedPrompt, taskId) -- 2091
	local stopToken = {stopped = false} -- 2092
	activeStopTokens[taskId] = stopToken -- 2093
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 2094
	runCodingAgent( -- 2095
		{ -- 2095
			prompt = normalizedPrompt, -- 2096
			workDir = session.projectRoot, -- 2097
			useChineseResponse = useChineseResponse, -- 2098
			taskId = taskId, -- 2099
			sessionId = sessionId, -- 2100
			memoryScope = session.memoryScope, -- 2101
			role = session.kind, -- 2102
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2103
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2106
			stopToken = stopToken, -- 2109
			onEvent = function(____, event) return applyEvent(sessionId, event) end -- 2110
		}, -- 2110
		function(result) -- 2111
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2111
				local nextSession = getSessionItem(sessionId) -- 2112
				if nextSession and nextSession.kind == "sub" then -- 2112
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2112
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2115
						if not stopped.success then -- 2115
							Log( -- 2117
								"Warn", -- 2117
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2117
							) -- 2117
							emitAgentSessionPatch( -- 2118
								sessionId, -- 2118
								{session = getSessionItem(sessionId)} -- 2118
							) -- 2118
						end -- 2118
						activeStopTokens[taskId] = nil -- 2122
						return ____awaiter_resolve(nil) -- 2122
					end -- 2122
					setSessionState(sessionId, "RUNNING", taskId, "RUNNING") -- 2125
					emitAgentSessionPatch( -- 2126
						sessionId, -- 2126
						{session = getSessionItem(sessionId)} -- 2126
					) -- 2126
					local finalized = __TS__Await(finalizeSubSession(nextSession, taskId, result.success, result.message)) -- 2129
					if not finalized.success then -- 2129
						Log( -- 2131
							"Warn", -- 2131
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2131
						) -- 2131
					end -- 2131
					local finalizedSession = getSessionItem(sessionId) -- 2133
					if finalizedSession then -- 2133
						local stopped = stopToken.stopped == true -- 2135
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2136
						setSessionState(sessionId, finalStatus, taskId, finalStatus) -- 2139
						emitAgentSessionPatch( -- 2140
							sessionId, -- 2140
							{session = getSessionItem(sessionId)} -- 2140
						) -- 2140
					end -- 2140
				end -- 2140
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2140
					applyEvent(sessionId, { -- 2146
						type = "task_finished", -- 2147
						sessionId = sessionId, -- 2148
						taskId = result.taskId, -- 2149
						success = false, -- 2150
						message = result.message, -- 2151
						steps = result.steps -- 2152
					}) -- 2152
				end -- 2152
			end) -- 2152
		end -- 2111
	) -- 2111
	return {success = true, sessionId = sessionId, taskId = taskId} -- 2156
end -- 2060
function ____exports.listRunningSubAgents(request) -- 2203
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2203
		local session = getSessionItem(request.sessionId) -- 2211
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2211
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2213
		end -- 2213
		if not session then -- 2213
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2213
		end -- 2213
		local rootSession = getRootSessionItem(session.id) -- 2218
		if not rootSession then -- 2218
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2218
		end -- 2218
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2222
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2223
		local limit = math.max( -- 2224
			1, -- 2224
			math.floor(tonumber(request.limit) or 5) -- 2224
		) -- 2224
		local offset = math.max( -- 2225
			0, -- 2225
			math.floor(tonumber(request.offset) or 0) -- 2225
		) -- 2225
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2226
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2227
		local runningSessions = {} -- 2234
		do -- 2234
			local i = 0 -- 2235
			while i < #rows do -- 2235
				do -- 2235
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2236
					if current.currentTaskStatus ~= "RUNNING" then -- 2236
						goto __continue335 -- 2238
					end -- 2238
					local spawnInfo = getSessionSpawnInfo(current) -- 2240
					runningSessions[#runningSessions + 1] = { -- 2241
						sessionId = current.id, -- 2242
						title = current.title, -- 2243
						parentSessionId = current.parentSessionId, -- 2244
						rootSessionId = current.rootSessionId, -- 2245
						status = "RUNNING", -- 2246
						currentTaskId = current.currentTaskId, -- 2247
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2248
						goal = spawnInfo and spawnInfo.goal, -- 2249
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2250
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2251
						createdAt = current.createdAt, -- 2252
						updatedAt = current.updatedAt -- 2253
					} -- 2253
				end -- 2253
				::__continue335:: -- 2253
				i = i + 1 -- 2235
			end -- 2235
		end -- 2235
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2256
		local completedSessions = __TS__ArrayMap( -- 2257
			completedRecords, -- 2257
			function(____, record) return { -- 2257
				sessionId = record.sessionId, -- 2258
				title = record.title, -- 2259
				parentSessionId = record.parentSessionId, -- 2260
				rootSessionId = record.rootSessionId, -- 2261
				status = record.status, -- 2262
				goal = record.goal, -- 2263
				expectedOutput = record.expectedOutput, -- 2264
				filesHint = record.filesHint, -- 2265
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2266
				success = record.success, -- 2267
				cleared = record.cleared, -- 2268
				resultFilePath = record.resultFilePath, -- 2269
				artifactDir = record.artifactDir, -- 2270
				finishedAt = record.finishedAt, -- 2271
				createdAt = record.createdAtTs, -- 2272
				updatedAt = record.finishedAtTs -- 2273
			} end -- 2273
		) -- 2273
		local merged = {} -- 2275
		if status == "running" then -- 2275
			merged = runningSessions -- 2277
		elseif status == "done" then -- 2277
			merged = __TS__ArrayFilter( -- 2279
				completedSessions, -- 2279
				function(____, item) return item.status == "DONE" end -- 2279
			) -- 2279
		elseif status == "failed" then -- 2279
			merged = __TS__ArrayFilter( -- 2281
				completedSessions, -- 2281
				function(____, item) return item.status == "FAILED" end -- 2281
			) -- 2281
		elseif status == "stopped" then -- 2281
			merged = __TS__ArrayFilter( -- 2283
				completedSessions, -- 2283
				function(____, item) return item.status == "STOPPED" end -- 2283
			) -- 2283
		elseif status == "all" then -- 2283
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2285
		else -- 2285
			local runningKeys = {} -- 2287
			do -- 2287
				local i = 0 -- 2288
				while i < #runningSessions do -- 2288
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2289
					i = i + 1 -- 2288
				end -- 2288
			end -- 2288
			local latestCompletedByKey = {} -- 2291
			do -- 2291
				local i = 0 -- 2292
				while i < #completedSessions do -- 2292
					do -- 2292
						local item = completedSessions[i + 1] -- 2293
						local key = getSubAgentDisplayKey(item) -- 2294
						if runningKeys[key] then -- 2294
							goto __continue350 -- 2296
						end -- 2296
						local current = latestCompletedByKey[key] -- 2298
						if not current or item.updatedAt > current.updatedAt then -- 2298
							latestCompletedByKey[key] = item -- 2300
						end -- 2300
					end -- 2300
					::__continue350:: -- 2300
					i = i + 1 -- 2292
				end -- 2292
			end -- 2292
			local latestCompleted = {} -- 2303
			for ____, item in pairs(latestCompletedByKey) do -- 2304
				latestCompleted[#latestCompleted + 1] = item -- 2305
			end -- 2305
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2307
		end -- 2307
		if query ~= "" then -- 2307
			merged = __TS__ArrayFilter( -- 2310
				merged, -- 2310
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2310
			) -- 2310
		end -- 2310
		__TS__ArraySort( -- 2316
			merged, -- 2316
			function(____, a, b) -- 2316
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2316
					return -1 -- 2317
				end -- 2317
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2317
					return 1 -- 2318
				end -- 2318
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2318
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2320
				end -- 2320
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2322
			end -- 2316
		) -- 2316
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2324
		return ____awaiter_resolve(nil, { -- 2324
			success = true, -- 2326
			rootSessionId = rootSession.id, -- 2327
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2328
			status = status, -- 2329
			limit = limit, -- 2330
			offset = offset, -- 2331
			hasMore = offset + limit < #merged, -- 2332
			sessions = paged -- 2333
		}) -- 2333
	end) -- 2333
end -- 2203
TABLE_SESSION = "AgentSession" -- 171
TABLE_MESSAGE = "AgentSessionMessage" -- 172
TABLE_STEP = "AgentSessionStep" -- 173
TABLE_TASK = "AgentTask" -- 174
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 175
SPAWN_INFO_FILE = "SPAWN.json" -- 176
RESULT_FILE = "RESULT.md" -- 177
PENDING_HANDOFF_DIR = "pending-handoffs" -- 178
MAX_CONCURRENT_SUB_AGENTS = 4 -- 179
SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE = 0.1 -- 180
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS = 1024 -- 181
SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY = 3 -- 182
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 183
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 184
SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS = 3000 -- 185
SUB_AGENT_MEMORY_RESULT_MAX_TOKENS = 2000 -- 186
SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES = 20 -- 187
SUB_AGENT_MEMORY_TAIL_MAX_TOKENS = 4000 -- 188
SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS = 600 -- 189
activeStopTokens = {} -- 235
now = function() return os.time() end -- 236
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 597
	if projectRoot == oldRoot then -- 597
		return newRoot -- 599
	end -- 599
	for ____, separator in ipairs({"/", "\\"}) do -- 601
		local prefix = oldRoot .. separator -- 602
		if __TS__StringStartsWith(projectRoot, prefix) then -- 602
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 604
		end -- 604
	end -- 604
	return nil -- 607
end -- 597
local function sanitizeStoredSteps(sessionId) -- 1367
	DB:exec( -- 1368
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1368
		{ -- 1386
			now(), -- 1386
			sessionId -- 1386
		} -- 1386
	) -- 1386
end -- 1367
local function getSchemaVersion() -- 1600
	local row = queryOne("PRAGMA user_version") -- 1601
	return row and type(row[1]) == "number" and row[1] or 0 -- 1602
end -- 1600
local function setSchemaVersion(version) -- 1605
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1606
		0, -- 1606
		math.floor(version) -- 1606
	))) -- 1606
end -- 1605
local function recreateSchema() -- 1609
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1610
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1611
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1612
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1613
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1627
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1628
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1637
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1638
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1655
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1656
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1657
end -- 1609
do -- 1609
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1609
		recreateSchema() -- 1663
	else -- 1663
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1665
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1679
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1680
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1689
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1690
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1707
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1708
	end -- 1708
end -- 1708
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1850
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1850
		return {success = false, message = "invalid projectRoot"} -- 1852
	end -- 1852
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1854
	for ____, row in ipairs(rows) do -- 1855
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1856
		if sessionId > 0 then -- 1856
			deleteSessionRecords(sessionId) -- 1858
		end -- 1858
	end -- 1858
	return {success = true, deleted = #rows} -- 1861
end -- 1850
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1864
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1864
		return {success = false, message = "invalid projectRoot"} -- 1866
	end -- 1866
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1868
	local renamed = 0 -- 1869
	for ____, row in ipairs(rows) do -- 1870
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1871
		local projectRoot = toStr(row[2]) -- 1872
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1873
		if sessionId > 0 and nextProjectRoot then -- 1873
			DB:exec( -- 1875
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1875
				{ -- 1877
					nextProjectRoot, -- 1877
					Path:getFilename(nextProjectRoot), -- 1877
					now(), -- 1877
					sessionId -- 1877
				} -- 1877
			) -- 1877
			renamed = renamed + 1 -- 1879
		end -- 1879
	end -- 1879
	return {success = true, renamed = renamed} -- 1882
end -- 1864
function ____exports.getSession(sessionId) -- 1885
	local session = getSessionItem(sessionId) -- 1886
	if not session then -- 1886
		return {success = false, message = "session not found"} -- 1888
	end -- 1888
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1890
	local relatedSessions = listRelatedSessions(sessionId) -- 1891
	sanitizeStoredSteps(sessionId) -- 1892
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1893
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1900
	local ____relatedSessions_43 = relatedSessions -- 1911
	local ____temp_42 -- 1912
	if normalizedSession.kind == "sub" then -- 1912
		____temp_42 = getSessionSpawnInfo(normalizedSession) -- 1912
	else -- 1912
		____temp_42 = nil -- 1912
	end -- 1912
	return { -- 1908
		success = true, -- 1909
		session = normalizedSession, -- 1910
		relatedSessions = ____relatedSessions_43, -- 1911
		spawnInfo = ____temp_42, -- 1912
		messages = __TS__ArrayMap( -- 1913
			messages, -- 1913
			function(____, row) return rowToMessage(row) end -- 1913
		), -- 1913
		steps = __TS__ArrayMap( -- 1914
			steps, -- 1914
			function(____, row) return rowToStep(row) end -- 1914
		), -- 1914
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 1915
	} -- 1915
end -- 1885
function ____exports.stopSessionTask(sessionId) -- 2159
	local session = getSessionItem(sessionId) -- 2160
	if not session or session.currentTaskId == nil then -- 2160
		return {success = false, message = "session task not found"} -- 2162
	end -- 2162
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2164
	local stopToken = activeStopTokens[session.currentTaskId] -- 2165
	if not stopToken then -- 2165
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2165
			return {success = true, recovered = true} -- 2168
		end -- 2168
		return {success = false, message = "task is not running"} -- 2170
	end -- 2170
	stopToken.stopped = true -- 2172
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2173
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2174
	return {success = true} -- 2175
end -- 2159
function ____exports.getCurrentTaskId(sessionId) -- 2178
	local ____opt_64 = getSessionItem(sessionId) -- 2178
	return ____opt_64 and ____opt_64.currentTaskId -- 2179
end -- 2178
function ____exports.listRunningSessions() -- 2182
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2183
	local sessions = {} -- 2190
	do -- 2190
		local i = 0 -- 2191
		while i < #rows do -- 2191
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2192
			if session.currentTaskStatus == "RUNNING" then -- 2192
				sessions[#sessions + 1] = session -- 2194
			end -- 2194
			i = i + 1 -- 2191
		end -- 2191
	end -- 2191
	return {success = true, sessions = sessions} -- 2197
end -- 2182
return ____exports -- 2182