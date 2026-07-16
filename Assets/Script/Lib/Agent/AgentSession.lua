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
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
function getDefaultUseChineseResponse() -- 261
	local zh = string.match(App.locale, "^zh") -- 262
	return zh ~= nil -- 263
end -- 263
function toStr(v) -- 266
	if v == false or v == nil then -- 266
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
function normalizeDisabledAgentTools(value) -- 496
	if not __TS__ArrayIsArray(value) then -- 496
		return {} -- 497
	end -- 497
	local tools = {} -- 498
	do -- 498
		local i = 0 -- 499
		while i < #value do -- 499
			do -- 499
				local name = value[i + 1] -- 500
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 500
					goto __continue60 -- 501
				end -- 501
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 501
					tools[#tools + 1] = name -- 502
				end -- 502
			end -- 502
			::__continue60:: -- 502
			i = i + 1 -- 499
		end -- 499
	end -- 499
	return tools -- 504
end -- 504
function getSessionRow(sessionId) -- 507
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 508
end -- 508
function getSessionItem(sessionId) -- 516
	local row = getSessionRow(sessionId) -- 517
	return row and rowToSession(row) or nil -- 518
end -- 518
function getTaskPrompt(taskId) -- 521
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 522
	if not row or type(row[1]) ~= "string" then -- 522
		return nil -- 523
	end -- 523
	return toStr(row[1]) -- 524
end -- 524
function getLatestMainSessionByProjectRoot(projectRoot) -- 527
	if not isValidProjectRoot(projectRoot) then -- 527
		return nil -- 528
	end -- 528
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 529
	return row and rowToSession(row) or nil -- 537
end -- 537
function countRunningSubSessions(rootSessionId) -- 540
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 541
	local count = 0 -- 548
	do -- 548
		local i = 0 -- 549
		while i < #rows do -- 549
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 550
			if session.currentTaskStatus == "RUNNING" then -- 550
				count = count + 1 -- 552
			end -- 552
			i = i + 1 -- 549
		end -- 549
	end -- 549
	return count -- 555
end -- 555
function deleteSessionRecords(sessionId, preserveArtifacts) -- 558
	if preserveArtifacts == nil then -- 558
		preserveArtifacts = false -- 558
	end -- 558
	local session = getSessionItem(sessionId) -- 559
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 560
	do -- 560
		local i = 0 -- 561
		while i < #children do -- 561
			local row = children[i + 1] -- 562
			if type(row[1]) == "number" and row[1] > 0 then -- 562
				deleteSessionRecords(row[1], preserveArtifacts) -- 564
			end -- 564
			i = i + 1 -- 561
		end -- 561
	end -- 561
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 567
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 568
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 569
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 570
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 570
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 572
	end -- 572
end -- 572
function getSessionRootId(session) -- 576
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 577
end -- 577
function getRootSessionItem(sessionId) -- 580
	local session = getSessionItem(sessionId) -- 581
	if not session then -- 581
		return nil -- 582
	end -- 582
	return getSessionItem(getSessionRootId(session)) or session -- 583
end -- 583
function listRelatedSessions(sessionId) -- 586
	local root = getRootSessionItem(sessionId) -- 587
	if not root then -- 587
		return {} -- 588
	end -- 588
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 589
	return __TS__ArrayMap( -- 598
		rows, -- 598
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 598
	) -- 598
end -- 598
function getSessionSpawnInfo(session) -- 601
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 602
	if not info then -- 602
		return nil -- 603
	end -- 603
	local ____temp_4 = type(info.sessionId) == "number" and info.sessionId or nil -- 605
	local ____temp_5 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 606
	local ____temp_6 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 607
	local ____temp_7 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 608
	local ____temp_8 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 609
	local ____temp_9 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 610
	local ____temp_10 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 611
	local ____temp_11 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 612
		__TS__ArrayFilter( -- 613
			info.filesHint, -- 613
			function(____, item) return type(item) == "string" end -- 613
		), -- 613
		function(____, item) return sanitizeUTF8(item) end -- 613
	) or nil -- 613
	local ____temp_12 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 615
	local ____temp_2 -- 618
	if info.success == true then -- 618
		____temp_2 = true -- 618
	else -- 618
		local ____temp_1 -- 618
		if info.success == false then -- 618
			____temp_1 = false -- 618
		else -- 618
			____temp_1 = nil -- 618
		end -- 618
		____temp_2 = ____temp_1 -- 618
	end -- 618
	local ____temp_3 -- 619
	if info.cleared == true then -- 619
		____temp_3 = true -- 619
	else -- 619
		____temp_3 = nil -- 619
	end -- 619
	return { -- 604
		sessionId = ____temp_4, -- 605
		rootSessionId = ____temp_5, -- 606
		parentSessionId = ____temp_6, -- 607
		title = ____temp_7, -- 608
		prompt = ____temp_8, -- 609
		goal = ____temp_9, -- 610
		expectedOutput = ____temp_10, -- 611
		filesHint = ____temp_11, -- 612
		status = ____temp_12, -- 615
		success = ____temp_2, -- 618
		cleared = ____temp_3, -- 619
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 620
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 621
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 622
		changeSet = decodeChangeSetSummary(info.changeSet), -- 623
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 624
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 625
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 626
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 629
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 630
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 631
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 632
	} -- 632
end -- 632
function ensureDirRecursive(dir) -- 649
	if not dir or dir == "" then -- 649
		return false -- 650
	end -- 650
	if Content:exist(dir) then -- 650
		return Content:isdir(dir) -- 651
	end -- 651
	local parent = Path:getPath(dir) -- 652
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 652
		if not ensureDirRecursive(parent) then -- 652
			return false -- 655
		end -- 655
	end -- 655
	return Content:mkdir(dir) -- 658
end -- 658
function writeSpawnInfo(projectRoot, memoryScope, value) -- 661
	local dir = Path(projectRoot, ".agent", memoryScope) -- 662
	if not Content:exist(dir) then -- 662
		ensureDirRecursive(dir) -- 664
	end -- 664
	local path = Path(dir, SPAWN_INFO_FILE) -- 666
	local text = safeJsonEncode(value) -- 667
	if not text then -- 667
		return false -- 668
	end -- 668
	local content = text .. "\n" -- 669
	if not Content:save(path, content) then -- 669
		return false -- 671
	end -- 671
	Tools.sendWebIDEFileUpdate(path, true, content) -- 673
	return true -- 674
end -- 674
function readSpawnInfo(projectRoot, memoryScope) -- 677
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 678
	if not Content:exist(path) then -- 678
		return nil -- 679
	end -- 679
	local text = Content:load(path) -- 680
	if not text or __TS__StringTrim(text) == "" then -- 680
		return nil -- 681
	end -- 681
	local value = safeJsonDecode(text) -- 682
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 682
		return value -- 684
	end -- 684
	return nil -- 686
end -- 686
function getArtifactRelativeDir(memoryScope) -- 689
	return Path(".agent", memoryScope) -- 690
end -- 690
function getArtifactDir(projectRoot, memoryScope) -- 693
	return Path( -- 694
		projectRoot, -- 694
		getArtifactRelativeDir(memoryScope) -- 694
	) -- 694
end -- 694
function getResultRelativePath(memoryScope) -- 697
	return Path( -- 698
		getArtifactRelativeDir(memoryScope), -- 698
		RESULT_FILE -- 698
	) -- 698
end -- 698
function getResultPath(projectRoot, memoryScope) -- 701
	return Path( -- 702
		projectRoot, -- 702
		getResultRelativePath(memoryScope) -- 702
	) -- 702
end -- 702
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 705
	if not resultFilePath or resultFilePath == "" then -- 705
		return "" -- 706
	end -- 706
	local path = Path(projectRoot, resultFilePath) -- 707
	if not Content:exist(path) then -- 707
		return "" -- 708
	end -- 708
	local text = sanitizeUTF8(Content:load(path)) -- 709
	if not text or __TS__StringTrim(text) == "" then -- 709
		return "" -- 710
	end -- 710
	local marker = "\n## Summary\n" -- 711
	local start = string.find(text, marker, 1, true) -- 712
	if start ~= nil then -- 712
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 714
	end -- 714
	return __TS__StringTrim(text) -- 716
end -- 716
function buildStructuredSubAgentMemoryEntry(record) -- 719
	local hasPassedValidation = false -- 720
	do -- 720
		local i = 0 -- 721
		while i < #record.completion.validation do -- 721
			if record.completion.validation[i + 1].result == "passed" then -- 721
				hasPassedValidation = true -- 723
				break -- 724
			end -- 724
			i = i + 1 -- 721
		end -- 721
	end -- 721
	if not hasPassedValidation then -- 721
		return nil -- 727
	end -- 727
	local candidates = record.completion.learningCandidates -- 728
	local claims = {} -- 729
	local evidence = {} -- 730
	do -- 730
		local i = 0 -- 731
		while i < #candidates do -- 731
			do -- 731
				local candidate = candidates[i + 1] -- 732
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 732
					goto __continue121 -- 733
				end -- 733
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 734
				do -- 734
					local j = 0 -- 735
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 735
						local item = candidate.evidence[j + 1] -- 736
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 736
							evidence[#evidence + 1] = item -- 737
						end -- 737
						j = j + 1 -- 735
					end -- 735
				end -- 735
			end -- 735
			::__continue121:: -- 735
			i = i + 1 -- 731
		end -- 731
	end -- 731
	local content = takeUtf8Head( -- 740
		table.concat(claims, "\n"), -- 740
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 740
	) -- 740
	if content == "" then -- 740
		return nil -- 741
	end -- 741
	return { -- 742
		sourceSessionId = record.sessionId, -- 743
		sourceTaskId = record.sourceTaskId, -- 744
		content = content, -- 745
		evidence = evidence, -- 746
		createdAt = record.finishedAt -- 747
	} -- 747
end -- 747
function containsNormalizedText(text, query) -- 751
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 752
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 753
	if normalizedQuery == "" then -- 753
		return true -- 754
	end -- 754
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 755
end -- 755
function getSubAgentDisplayKey(item) -- 758
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 764
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 765
	local label = goal ~= "" and goal or title -- 766
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 767
end -- 767
function writeSubAgentResultFile(session, record, resultText) -- 770
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 771
	if not Content:exist(dir) then -- 771
		ensureDirRecursive(dir) -- 773
	end -- 773
	local ____array_13 = __TS__SparseArrayNew( -- 773
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 776
		"- Status: " .. record.status, -- 777
		"- Success: " .. (record.success and "true" or "false"), -- 778
		"- Outcome: " .. record.completion.outcome, -- 779
		"- Session ID: " .. tostring(record.sessionId), -- 780
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 781
		"- Goal: " .. record.goal, -- 782
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 783
	) -- 783
	__TS__SparseArrayPush( -- 783
		____array_13, -- 783
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 784
	) -- 784
	__TS__SparseArrayPush( -- 784
		____array_13, -- 784
		"- Finished At: " .. record.finishedAt, -- 785
		"", -- 786
		"## Validation", -- 787
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 788
			record.completion.validation, -- 789
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 789
		) or ({"- Not reported"})) -- 789
	) -- 789
	__TS__SparseArrayPush( -- 789
		____array_13, -- 789
		"", -- 791
		"## Known Issues", -- 792
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 793
			record.completion.knownIssues, -- 793
			function(____, item) return "- " .. item end -- 793
		) or ({"- None reported"})) -- 793
	) -- 793
	__TS__SparseArrayPush( -- 793
		____array_13, -- 793
		"", -- 794
		"## Assumptions", -- 795
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 796
			record.completion.assumptions, -- 796
			function(____, item) return "- " .. item end -- 796
		) or ({"- None reported"})) -- 796
	) -- 796
	__TS__SparseArrayPush(____array_13, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 796
	local lines = {__TS__SparseArraySpread(____array_13)} -- 775
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 801
	local content = table.concat(lines, "\n") .. "\n" -- 802
	if not Content:save(path, content) then -- 802
		return false -- 804
	end -- 804
	Tools.sendWebIDEFileUpdate(path, true, content) -- 806
	return true -- 807
end -- 807
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 810
	local dir = Path(projectRoot, ".agent", "subagents") -- 811
	if not Content:exist(dir) or not Content:isdir(dir) then -- 811
		return {} -- 812
	end -- 812
	local items = {} -- 813
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 814
		do -- 814
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 815
			if not Content:exist(path) or not Content:isdir(path) then -- 815
				goto __continue138 -- 816
			end -- 816
			local info = readSpawnInfo( -- 817
				projectRoot, -- 817
				Path( -- 817
					"subagents", -- 817
					Path:getFilename(path) -- 817
				) -- 817
			) -- 817
			if not info then -- 817
				goto __continue138 -- 818
			end -- 818
			local sessionId = tonumber(info.sessionId) -- 819
			local infoRootSessionId = tonumber(info.rootSessionId) -- 820
			local sourceTaskId = tonumber(info.sourceTaskId) -- 821
			local status = sanitizeUTF8(toStr(info.status)) -- 822
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 822
				goto __continue138 -- 823
			end -- 823
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 823
				goto __continue138 -- 824
			end -- 824
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 825
			items[#items + 1] = { -- 826
				sessionId = sessionId, -- 827
				rootSessionId = infoRootSessionId, -- 828
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 829
				title = sanitizeUTF8(toStr(info.title)), -- 830
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 831
				goal = sanitizeUTF8(toStr(info.goal)), -- 832
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 833
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 834
					__TS__ArrayFilter( -- 835
						info.filesHint, -- 835
						function(____, item) return type(item) == "string" end -- 835
					), -- 835
					function(____, item) return sanitizeUTF8(item) end -- 835
				) or ({}), -- 835
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 837
				success = info.success == true, -- 838
				cleared = info.cleared == true, -- 839
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 840
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 841
					"subagents", -- 841
					Path:getFilename(path) -- 841
				)), -- 841
				sourceTaskId = sourceTaskId or 0, -- 842
				changeSet = decodeChangeSetSummary(info.changeSet), -- 843
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 844
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 845
				completion = normalizeAgentCompletionReport(info.completion), -- 846
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 847
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 848
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 849
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 850
			} -- 850
		end -- 850
		::__continue138:: -- 850
	end -- 850
	__TS__ArraySort( -- 853
		items, -- 853
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 853
	) -- 853
	return items -- 854
end -- 854
function getPendingHandoffDir(projectRoot, memoryScope) -- 857
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 858
end -- 858
function writePendingHandoff(projectRoot, memoryScope, value) -- 861
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 862
	if not Content:exist(dir) then -- 862
		ensureDirRecursive(dir) -- 864
	end -- 864
	local path = Path(dir, value.id .. ".json") -- 866
	local text = safeJsonEncode(value) -- 867
	if not text then -- 867
		return false -- 868
	end -- 868
	return Content:save(path, text .. "\n") -- 869
end -- 869
function listPendingHandoffs(projectRoot, memoryScope) -- 872
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 873
	if not Content:exist(dir) or not Content:isdir(dir) then -- 873
		return {} -- 874
	end -- 874
	local items = {} -- 875
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 876
		do -- 876
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 877
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 877
				goto __continue153 -- 878
			end -- 878
			local text = Content:load(path) -- 879
			if not text or __TS__StringTrim(text) == "" then -- 879
				goto __continue153 -- 880
			end -- 880
			local obj = safeJsonDecode(text) -- 881
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 881
				goto __continue153 -- 882
			end -- 882
			local value = obj -- 883
			local sourceTaskId = tonumber(value.sourceTaskId) -- 884
			local sourceSessionId = tonumber(value.sourceSessionId) -- 885
			local id = sanitizeUTF8(toStr(value.id)) -- 886
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 887
			local message = sanitizeUTF8(toStr(value.message)) -- 888
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 889
			local goal = sanitizeUTF8(toStr(value.goal)) -- 890
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 891
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 891
				goto __continue153 -- 893
			end -- 893
			items[#items + 1] = { -- 895
				id = id, -- 896
				sourceSessionId = sourceSessionId, -- 897
				sourceTitle = sourceTitle, -- 898
				sourceTaskId = sourceTaskId, -- 899
				message = message, -- 900
				prompt = prompt, -- 901
				goal = goal, -- 902
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 903
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 904
					__TS__ArrayFilter( -- 905
						value.filesHint, -- 905
						function(____, item) return type(item) == "string" end -- 905
					), -- 905
					function(____, item) return sanitizeUTF8(item) end -- 905
				) or ({}), -- 905
				success = value.success == true, -- 907
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 908
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 909
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 910
				changeSet = decodeChangeSetSummary(value.changeSet), -- 911
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 912
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 913
				createdAt = createdAt -- 916
			} -- 916
		end -- 916
		::__continue153:: -- 916
	end -- 916
	__TS__ArraySort( -- 919
		items, -- 919
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 919
	) -- 919
	return items -- 920
end -- 920
function deletePendingHandoff(projectRoot, memoryScope, id) -- 923
	local path = Path( -- 924
		getPendingHandoffDir(projectRoot, memoryScope), -- 924
		id .. ".json" -- 924
	) -- 924
	if Content:exist(path) then -- 924
		Content:remove(path) -- 926
	end -- 926
end -- 926
function normalizePromptText(prompt) -- 930
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 931
end -- 931
function normalizePromptTextSafe(prompt) -- 934
	if type(prompt) == "string" then -- 934
		local normalized = normalizePromptText(prompt) -- 936
		if normalized ~= "" then -- 936
			return normalized -- 937
		end -- 937
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 938
		if sanitized ~= "" then -- 938
			return truncateAgentUserPrompt(sanitized) -- 940
		end -- 940
		return "" -- 942
	end -- 942
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 944
	if text == "" then -- 944
		return "" -- 945
	end -- 945
	return truncateAgentUserPrompt(text) -- 946
end -- 946
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 949
	local sections = {} -- 950
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 951
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 952
	local normalizedFiles = __TS__ArrayFilter( -- 953
		__TS__ArrayMap( -- 953
			__TS__ArrayFilter( -- 953
				filesHint or ({}), -- 953
				function(____, item) return type(item) == "string" end -- 954
			), -- 954
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 955
		), -- 955
		function(____, item) return item ~= "" end -- 956
	) -- 956
	if normalizedTitle ~= "" then -- 956
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 958
	end -- 958
	if normalizedExpected ~= "" then -- 958
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 961
	end -- 961
	if #normalizedFiles > 0 then -- 961
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 964
	end -- 964
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 966
end -- 966
function normalizeSessionRuntimeState(session) -- 969
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 969
		return session -- 971
	end -- 971
	if activeStopTokens[session.currentTaskId] ~= nil then -- 971
		return session -- 974
	end -- 974
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 976
	if #pendingToolRows > 0 then -- 976
		local t = now() -- 982
		do -- 982
			local i = 0 -- 983
			while i < #pendingToolRows do -- 983
				local row = pendingToolRows[i + 1] -- 984
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 985
				result.success = false -- 986
				result.state = "failed" -- 987
				result.interrupted = true -- 988
				result.message = "tool call was interrupted because the program exited before it completed." -- 989
				DB:exec( -- 990
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 990
					{ -- 992
						encodeJson(result), -- 992
						t, -- 992
						row[1] -- 992
					} -- 992
				) -- 992
				i = i + 1 -- 983
			end -- 983
		end -- 983
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 995
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 996
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 997
	end -- 997
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1004
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1005
	return __TS__ObjectAssign( -- 1006
		{}, -- 1006
		session, -- 1007
		{ -- 1006
			status = "STOPPED", -- 1008
			currentTaskStatus = "STOPPED", -- 1009
			updatedAt = now() -- 1010
		} -- 1010
	) -- 1010
end -- 1010
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1014
	DB:exec( -- 1015
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1015
		{ -- 1019
			status, -- 1020
			currentTaskId or 0, -- 1021
			currentTaskStatus or status, -- 1022
			now(), -- 1023
			sessionId -- 1024
		} -- 1024
	) -- 1024
end -- 1024
function mergeAgentMetrics(current, next) -- 1029
	return __TS__ObjectAssign({}, current or ({}), next) -- 1030
end -- 1030
function updateSessionMetrics(sessionId, metrics) -- 1036
	local session = getSessionItem(sessionId) -- 1037
	if not session then -- 1037
		return nil -- 1038
	end -- 1038
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1039
	DB:exec( -- 1040
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1040
		{ -- 1044
			encodeJson(merged), -- 1045
			now(), -- 1046
			sessionId -- 1047
		} -- 1047
	) -- 1047
	return merged -- 1050
end -- 1050
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1053
	if taskId == nil or taskId <= 0 then -- 1053
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1055
		return -- 1056
	end -- 1056
	local row = getSessionRow(sessionId) -- 1058
	if not row then -- 1058
		return -- 1059
	end -- 1059
	local session = rowToSession(row) -- 1060
	if session.currentTaskId ~= taskId then -- 1060
		Log( -- 1062
			"Info", -- 1062
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1062
		) -- 1062
		return -- 1063
	end -- 1063
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1065
end -- 1065
function insertMessage(sessionId, role, content, taskId) -- 1068
	local t = now() -- 1069
	DB:exec( -- 1070
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?)", -- 1070
		{ -- 1073
			sessionId, -- 1074
			taskId or 0, -- 1075
			role, -- 1076
			sanitizeUTF8(content), -- 1077
			t, -- 1078
			t -- 1079
		} -- 1079
	) -- 1079
	return getLastInsertRowId() -- 1082
end -- 1082
function updateMessage(messageId, content) -- 1085
	DB:exec( -- 1086
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1086
		{ -- 1088
			sanitizeUTF8(content), -- 1088
			now(), -- 1088
			messageId -- 1088
		} -- 1088
	) -- 1088
end -- 1088
function updateUserMessageForTask(messageId, content, taskId) -- 1092
	DB:exec( -- 1093
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1093
		{ -- 1097
			sanitizeUTF8(content), -- 1097
			taskId, -- 1097
			now(), -- 1097
			messageId -- 1097
		} -- 1097
	) -- 1097
end -- 1097
function upsertAssistantMessage(sessionId, taskId, content) -- 1154
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1155
	if row and type(row[1]) == "number" then -- 1155
		updateMessage(row[1], content) -- 1162
		return row[1] -- 1163
	end -- 1163
	return insertMessage(sessionId, "assistant", content, taskId) -- 1165
end -- 1165
function upsertStep(sessionId, taskId, step, tool, patch) -- 1168
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1178
	local reason = sanitizeUTF8(patch.reason or "") -- 1182
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1183
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1184
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1185
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1186
	local statusPatch = patch.status or "" -- 1187
	local status = patch.status or "PENDING" -- 1188
	if not row then -- 1188
		local t = now() -- 1190
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1191
			sessionId, -- 1195
			taskId, -- 1196
			step, -- 1197
			tool, -- 1198
			status, -- 1199
			reason, -- 1200
			reasoningContent, -- 1201
			paramsJson, -- 1202
			resultJson, -- 1203
			patch.checkpointId or 0, -- 1204
			patch.checkpointSeq or 0, -- 1205
			filesJson, -- 1206
			t, -- 1207
			t -- 1208
		}) -- 1208
		return -- 1211
	end -- 1211
	DB:exec( -- 1213
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1213
		{ -- 1225
			tool, -- 1226
			statusPatch, -- 1227
			status, -- 1228
			reason, -- 1229
			reason, -- 1230
			reasoningContent, -- 1231
			reasoningContent, -- 1232
			paramsJson, -- 1233
			paramsJson, -- 1234
			resultJson, -- 1235
			resultJson, -- 1236
			patch.checkpointId or 0, -- 1237
			patch.checkpointId or 0, -- 1238
			patch.checkpointSeq or 0, -- 1239
			patch.checkpointSeq or 0, -- 1240
			filesJson, -- 1241
			filesJson, -- 1242
			now(), -- 1243
			row[1] -- 1244
		} -- 1244
	) -- 1244
end -- 1244
function getNextStepNumber(sessionId, taskId) -- 1249
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1250
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1254
	return math.max(0, current) + 1 -- 1255
end -- 1255
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1258
	if status == nil then -- 1258
		status = "DONE" -- 1266
	end -- 1266
	local step = getNextStepNumber(sessionId, taskId) -- 1268
	upsertStep( -- 1269
		sessionId, -- 1269
		taskId, -- 1269
		step, -- 1269
		tool, -- 1269
		{status = status, reason = reason, params = params, result = result} -- 1269
	) -- 1269
	return getStepItem(sessionId, taskId, step) -- 1275
end -- 1275
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1278
	if taskId <= 0 then -- 1278
		return -- 1279
	end -- 1279
	if finalSteps ~= nil and finalSteps >= 0 then -- 1279
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1281
	end -- 1281
	if not finalStatus then -- 1281
		return -- 1287
	end -- 1287
	if finalSteps ~= nil and finalSteps >= 0 then -- 1287
		DB:exec( -- 1289
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1289
			{ -- 1293
				finalStatus, -- 1293
				now(), -- 1293
				sessionId, -- 1293
				taskId, -- 1293
				finalSteps -- 1293
			} -- 1293
		) -- 1293
		return -- 1295
	end -- 1295
	DB:exec( -- 1297
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1297
		{ -- 1301
			finalStatus, -- 1301
			now(), -- 1301
			sessionId, -- 1301
			taskId -- 1301
		} -- 1301
	) -- 1301
end -- 1301
function emitAgentSessionPatch(sessionId, patch) -- 1328
	if HttpServer.wsConnectionCount == 0 then -- 1328
		return -- 1330
	end -- 1330
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1332
	if not text then -- 1332
		return -- 1337
	end -- 1337
	emit("AppWS", "Send", text) -- 1338
end -- 1338
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1341
	emitAgentSessionPatch( -- 1342
		sessionId, -- 1342
		{ -- 1342
			sessionDeleted = true, -- 1343
			relatedSessions = listRelatedSessions(rootSessionId) -- 1344
		} -- 1344
	) -- 1344
	local rootSession = getSessionItem(rootSessionId) -- 1346
	if rootSession then -- 1346
		emitAgentSessionPatch( -- 1348
			rootSessionId, -- 1348
			{ -- 1348
				session = rootSession, -- 1349
				relatedSessions = listRelatedSessions(rootSessionId) -- 1350
			} -- 1350
		) -- 1350
	end -- 1350
end -- 1350
function flushPendingSubAgentHandoffs(rootSession) -- 1355
	if rootSession.kind ~= "main" then -- 1355
		return -- 1356
	end -- 1356
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1356
		return -- 1358
	end -- 1358
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1360
	if #items == 0 then -- 1360
		return -- 1361
	end -- 1361
	local handoffTaskId = 0 -- 1362
	local ____rootSession_currentTaskId_14 -- 1363
	if rootSession.currentTaskId then -- 1363
		____rootSession_currentTaskId_14 = getTaskPrompt(rootSession.currentTaskId) -- 1363
	else -- 1363
		____rootSession_currentTaskId_14 = nil -- 1363
	end -- 1363
	local currentTaskPrompt = ____rootSession_currentTaskId_14 -- 1363
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1363
		handoffTaskId = rootSession.currentTaskId -- 1371
	else -- 1371
		local taskRes = Tools.createTask(("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)") -- 1373
		if not taskRes.success then -- 1373
			Log( -- 1375
				"Warn", -- 1375
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1375
			) -- 1375
			return -- 1376
		end -- 1376
		handoffTaskId = taskRes.taskId -- 1378
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1379
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1380
		emitAgentSessionPatch( -- 1381
			rootSession.id, -- 1381
			{session = getSessionItem(rootSession.id)} -- 1381
		) -- 1381
	end -- 1381
	do -- 1381
		local i = 0 -- 1385
		while i < #items do -- 1385
			local item = items[i + 1] -- 1386
			local step = appendSystemStep( -- 1387
				rootSession.id, -- 1388
				handoffTaskId, -- 1389
				"sub_agent_handoff", -- 1390
				"sub_agent_handoff", -- 1391
				item.message, -- 1392
				{ -- 1393
					sourceSessionId = item.sourceSessionId, -- 1394
					sourceTitle = item.sourceTitle, -- 1395
					sourceTaskId = item.sourceTaskId, -- 1396
					success = item.success == true, -- 1397
					summary = item.message, -- 1398
					resultFilePath = item.resultFilePath or "", -- 1399
					artifactDir = item.artifactDir or "", -- 1400
					finishedAt = item.finishedAt or "", -- 1401
					changeSet = item.changeSet, -- 1402
					memoryEntry = item.memoryEntry, -- 1403
					completion = item.completion -- 1404
				}, -- 1404
				{ -- 1406
					sourceSessionId = item.sourceSessionId, -- 1407
					sourceTitle = item.sourceTitle, -- 1408
					sourceTaskId = item.sourceTaskId, -- 1409
					prompt = item.prompt, -- 1410
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1411
					expectedOutput = item.expectedOutput or "", -- 1412
					filesHint = item.filesHint or ({}), -- 1413
					resultFilePath = item.resultFilePath or "", -- 1414
					artifactDir = item.artifactDir or "", -- 1415
					changeSet = item.changeSet, -- 1416
					memoryEntry = item.memoryEntry, -- 1417
					completion = item.completion -- 1418
				}, -- 1418
				"DONE" -- 1420
			) -- 1420
			if step then -- 1420
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1423
			end -- 1423
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1425
			i = i + 1 -- 1385
		end -- 1385
	end -- 1385
end -- 1385
function applyEvent(sessionId, event) -- 1437
	repeat -- 1437
		local ____switch231 = event.type -- 1437
		local ____cond231 = ____switch231 == "task_started" -- 1437
		if ____cond231 then -- 1437
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1440
			emitAgentSessionPatch( -- 1441
				sessionId, -- 1441
				{session = getSessionItem(sessionId)} -- 1441
			) -- 1441
			break -- 1444
		end -- 1444
		____cond231 = ____cond231 or ____switch231 == "decision_made" -- 1444
		if ____cond231 then -- 1444
			upsertStep( -- 1446
				sessionId, -- 1446
				event.taskId, -- 1446
				event.step, -- 1446
				event.tool, -- 1446
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1446
			) -- 1446
			emitAgentSessionPatch( -- 1452
				sessionId, -- 1452
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1452
			) -- 1452
			break -- 1455
		end -- 1455
		____cond231 = ____cond231 or ____switch231 == "tool_started" -- 1455
		if ____cond231 then -- 1455
			upsertStep( -- 1457
				sessionId, -- 1457
				event.taskId, -- 1457
				event.step, -- 1457
				event.tool, -- 1457
				{status = "RUNNING"} -- 1457
			) -- 1457
			emitAgentSessionPatch( -- 1460
				sessionId, -- 1460
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1460
			) -- 1460
			break -- 1463
		end -- 1463
		____cond231 = ____cond231 or ____switch231 == "tool_finished" -- 1463
		if ____cond231 then -- 1463
			upsertStep( -- 1465
				sessionId, -- 1465
				event.taskId, -- 1465
				event.step, -- 1465
				event.tool, -- 1465
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1465
			) -- 1465
			emitAgentSessionPatch( -- 1470
				sessionId, -- 1470
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1470
			) -- 1470
			break -- 1473
		end -- 1473
		____cond231 = ____cond231 or ____switch231 == "tool_progress" -- 1473
		if ____cond231 then -- 1473
			do -- 1473
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1476
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1476
					break -- 1478
				end -- 1478
			end -- 1478
			upsertStep( -- 1481
				sessionId, -- 1481
				event.taskId, -- 1481
				event.step, -- 1481
				event.tool, -- 1481
				{status = "RUNNING", result = event.result} -- 1481
			) -- 1481
			emitAgentSessionPatch( -- 1485
				sessionId, -- 1485
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1485
			) -- 1485
			break -- 1488
		end -- 1488
		____cond231 = ____cond231 or ____switch231 == "checkpoint_created" -- 1488
		if ____cond231 then -- 1488
			upsertStep( -- 1490
				sessionId, -- 1490
				event.taskId, -- 1490
				event.step, -- 1490
				event.tool, -- 1490
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1490
			) -- 1490
			emitAgentSessionPatch( -- 1495
				sessionId, -- 1495
				{ -- 1495
					step = getStepItem(sessionId, event.taskId, event.step), -- 1496
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1497
				} -- 1497
			) -- 1497
			break -- 1499
		end -- 1499
		____cond231 = ____cond231 or ____switch231 == "memory_compression_started" -- 1499
		if ____cond231 then -- 1499
			upsertStep( -- 1501
				sessionId, -- 1501
				event.taskId, -- 1501
				event.step, -- 1501
				event.tool, -- 1501
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1501
			) -- 1501
			emitAgentSessionPatch( -- 1506
				sessionId, -- 1506
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1506
			) -- 1506
			break -- 1509
		end -- 1509
		____cond231 = ____cond231 or ____switch231 == "memory_compression_finished" -- 1509
		if ____cond231 then -- 1509
			upsertStep( -- 1511
				sessionId, -- 1511
				event.taskId, -- 1511
				event.step, -- 1511
				event.tool, -- 1511
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1511
			) -- 1511
			emitAgentSessionPatch( -- 1516
				sessionId, -- 1516
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1516
			) -- 1516
			break -- 1519
		end -- 1519
		____cond231 = ____cond231 or ____switch231 == "metrics_updated" -- 1519
		if ____cond231 then -- 1519
			do -- 1519
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1521
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1522
				break -- 1525
			end -- 1525
		end -- 1525
		____cond231 = ____cond231 or ____switch231 == "assistant_message_updated" -- 1525
		if ____cond231 then -- 1525
			do -- 1525
				upsertStep( -- 1528
					sessionId, -- 1528
					event.taskId, -- 1528
					event.step, -- 1528
					"message", -- 1528
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1528
				) -- 1528
				emitAgentSessionPatch( -- 1533
					sessionId, -- 1533
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1533
				) -- 1533
				break -- 1536
			end -- 1536
		end -- 1536
		____cond231 = ____cond231 or ____switch231 == "task_finished" -- 1536
		if ____cond231 then -- 1536
			do -- 1536
				local ____opt_15 = activeStopTokens[event.taskId or -1] -- 1536
				local stopped = (____opt_15 and ____opt_15.stopped) == true -- 1539
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1540
				local session = getSessionItem(sessionId) -- 1543
				local isSubSession = (session and session.kind) == "sub" -- 1544
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1545
				if isSubSession and event.taskId ~= nil then -- 1545
					finalizingSubSessionTaskIds[event.taskId] = true -- 1547
				end -- 1547
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1549
				if event.taskId ~= nil then -- 1549
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1551
					local ____finalizeTaskSteps_21 = finalizeTaskSteps -- 1552
					local ____array_20 = __TS__SparseArrayNew( -- 1552
						sessionId, -- 1553
						event.taskId, -- 1554
						type(event.steps) == "number" and math.max( -- 1555
							0, -- 1555
							math.floor(event.steps) -- 1555
						) or nil -- 1555
					) -- 1555
					local ____event_success_19 -- 1556
					if event.success then -- 1556
						____event_success_19 = nil -- 1556
					else -- 1556
						____event_success_19 = stopped and "STOPPED" or "FAILED" -- 1556
					end -- 1556
					__TS__SparseArrayPush(____array_20, ____event_success_19) -- 1556
					____finalizeTaskSteps_21(__TS__SparseArraySpread(____array_20)) -- 1552
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1558
					if not isSubSession then -- 1558
						__TS__Delete(activeStopTokens, event.taskId) -- 1560
					end -- 1560
					emitAgentSessionPatch( -- 1562
						sessionId, -- 1562
						{ -- 1562
							session = getSessionItem(sessionId), -- 1563
							message = getMessageItem(messageId), -- 1564
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1565
							removedStepIds = removedStepIds -- 1566
						} -- 1566
					) -- 1566
				end -- 1566
				if session and session.kind == "main" then -- 1566
					flushPendingSubAgentHandoffs(session) -- 1570
				end -- 1570
				break -- 1572
			end -- 1572
		end -- 1572
	until true -- 1572
end -- 1572
function ____exports.createSession(projectRoot, title) -- 1709
	if title == nil then -- 1709
		title = "" -- 1709
	end -- 1709
	if not isValidProjectRoot(projectRoot) then -- 1709
		return {success = false, message = "invalid projectRoot"} -- 1711
	end -- 1711
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1713
	if row then -- 1713
		return { -- 1722
			success = true, -- 1722
			session = rowToSession(row) -- 1722
		} -- 1722
	end -- 1722
	local t = now() -- 1724
	DB:exec( -- 1725
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1725
		{ -- 1728
			projectRoot, -- 1728
			title ~= "" and title or Path:getFilename(projectRoot), -- 1728
			t, -- 1728
			t -- 1728
		} -- 1728
	) -- 1728
	local sessionId = getLastInsertRowId() -- 1730
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1731
	local session = getSessionItem(sessionId) -- 1732
	if not session then -- 1732
		return {success = false, message = "failed to create session"} -- 1734
	end -- 1734
	return {success = true, session = session} -- 1736
end -- 1709
function ____exports.createSubSession(parentSessionId, title) -- 1739
	if title == nil then -- 1739
		title = "" -- 1739
	end -- 1739
	local parent = getSessionItem(parentSessionId) -- 1740
	if not parent then -- 1740
		return {success = false, message = "parent session not found"} -- 1742
	end -- 1742
	local rootId = getSessionRootId(parent) -- 1744
	local t = now() -- 1745
	DB:exec( -- 1746
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1746
		{ -- 1749
			parent.projectRoot, -- 1749
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1749
			rootId, -- 1749
			parent.id, -- 1749
			t, -- 1749
			t -- 1749
		} -- 1749
	) -- 1749
	local sessionId = getLastInsertRowId() -- 1751
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1752
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1753
	local session = getSessionItem(sessionId) -- 1754
	if not session then -- 1754
		return {success = false, message = "failed to create sub session"} -- 1756
	end -- 1756
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1758
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1759
	subStorage:writeMemory(parentStorage:readMemory()) -- 1760
	return {success = true, session = session} -- 1761
end -- 1739
function spawnSubAgentSession(request) -- 1764
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1764
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1776
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 1777
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 1778
		if normalizedPrompt == "" then -- 1778
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 1780
		end -- 1780
		if normalizedPrompt == "" then -- 1780
			local ____Log_27 = Log -- 1787
			local ____temp_24 = #normalizedTitle -- 1787
			local ____temp_25 = #rawPrompt -- 1787
			local ____temp_26 = #toStr(request.expectedOutput) -- 1787
			local ____opt_22 = request.filesHint -- 1787
			____Log_27( -- 1787
				"Warn", -- 1787
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_24)) .. " raw_prompt_len=") .. tostring(____temp_25)) .. " expected_len=") .. tostring(____temp_26)) .. " files_hint_count=") .. tostring(____opt_22 and #____opt_22 or 0) -- 1787
			) -- 1787
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 1787
		end -- 1787
		Log( -- 1790
			"Info", -- 1790
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 1790
		) -- 1790
		local parentSessionId = request.parentSessionId -- 1791
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 1791
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 1793
			if not fallbackParent then -- 1793
				local createdMain = ____exports.createSession(request.projectRoot) -- 1795
				if createdMain.success then -- 1795
					fallbackParent = createdMain.session -- 1797
				end -- 1797
			end -- 1797
			if fallbackParent then -- 1797
				Log( -- 1801
					"Warn", -- 1801
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 1801
				) -- 1801
				parentSessionId = fallbackParent.id -- 1802
			end -- 1802
		end -- 1802
		local parentSession = getSessionItem(parentSessionId) -- 1805
		if not parentSession then -- 1805
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 1805
		end -- 1805
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 1809
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 1809
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 1809
		end -- 1809
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 1813
		if not created.success then -- 1813
			return ____awaiter_resolve(nil, created) -- 1813
		end -- 1813
		writeSpawnInfo( -- 1817
			created.session.projectRoot, -- 1817
			created.session.memoryScope, -- 1817
			{ -- 1817
				sessionId = created.session.id, -- 1818
				rootSessionId = created.session.rootSessionId, -- 1819
				parentSessionId = created.session.parentSessionId, -- 1820
				title = created.session.title, -- 1821
				prompt = normalizedPrompt, -- 1822
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 1823
				expectedOutput = request.expectedOutput or "", -- 1824
				filesHint = request.filesHint or ({}), -- 1825
				status = "RUNNING", -- 1826
				success = false, -- 1827
				resultFilePath = "", -- 1828
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 1829
				sourceTaskId = 0, -- 1830
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1831
				createdAtTs = created.session.createdAt, -- 1832
				finishedAt = "", -- 1833
				finishedAtTs = 0 -- 1834
			} -- 1834
		) -- 1834
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true, request.disabledAgentTools) -- 1836
		if not sent.success then -- 1836
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 1836
		end -- 1836
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 1836
	end) -- 1836
end -- 1836
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 1917
	local rootSession = getRootSessionItem(session.id) -- 1918
	if not rootSession then -- 1918
		return -- 1919
	end -- 1919
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 1920
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1921
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 1922
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 1923
	local queueResult = writePendingHandoff( -- 1924
		rootSession.projectRoot, -- 1924
		rootSession.memoryScope, -- 1924
		{ -- 1924
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 1925
			sourceSessionId = session.id, -- 1926
			sourceTitle = session.title, -- 1927
			sourceTaskId = taskId, -- 1928
			message = summary, -- 1929
			prompt = result.prompt, -- 1930
			goal = result.goal, -- 1931
			expectedOutput = result.expectedOutput or "", -- 1932
			filesHint = result.filesHint or ({}), -- 1933
			success = result.success, -- 1934
			resultFilePath = result.resultFilePath, -- 1935
			artifactDir = result.artifactDir, -- 1936
			finishedAt = result.finishedAt, -- 1937
			changeSet = changeSet, -- 1938
			memoryEntry = result.memoryEntry, -- 1939
			completion = result.completion, -- 1940
			createdAt = createdAt -- 1941
		} -- 1941
	) -- 1941
	if not queueResult then -- 1941
		Log( -- 1944
			"Warn", -- 1944
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 1944
		) -- 1944
		return -- 1945
	end -- 1945
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 1945
		flushPendingSubAgentHandoffs(rootSession) -- 1948
	end -- 1948
end -- 1948
function finalizeSubSession(session, taskId, success, message, completion) -- 1952
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1952
		local rootSessionId = getSessionRootId(session) -- 1953
		local rootSession = getRootSessionItem(session.id) -- 1954
		if not rootSession then -- 1954
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 1954
		end -- 1954
		local spawnInfo = getSessionSpawnInfo(session) -- 1958
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1959
		local finishedAtTs = now() -- 1960
		local resultText = sanitizeUTF8(message) -- 1961
		local changeSet = getTaskChangeSetSummary(taskId) -- 1962
		local record = { -- 1963
			sessionId = session.id, -- 1964
			rootSessionId = rootSessionId, -- 1965
			parentSessionId = session.parentSessionId, -- 1966
			title = session.title, -- 1967
			prompt = spawnInfo and spawnInfo.prompt or "", -- 1968
			goal = spawnInfo and spawnInfo.goal or session.title, -- 1969
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 1970
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 1971
			status = success and "DONE" or "FAILED", -- 1972
			success = success, -- 1973
			resultFilePath = getResultRelativePath(session.memoryScope), -- 1974
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 1975
			sourceTaskId = taskId, -- 1976
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 1977
			finishedAt = finishedAt, -- 1978
			createdAtTs = session.createdAt, -- 1979
			finishedAtTs = finishedAtTs, -- 1980
			changeSet = changeSet, -- 1981
			completion = completion or normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({resultText})}) -- 1982
		} -- 1982
		local ____record_success_40 -- 1987
		if record.success then -- 1987
			____record_success_40 = buildStructuredSubAgentMemoryEntry(record) -- 1987
		else -- 1987
			____record_success_40 = nil -- 1987
		end -- 1987
		record.memoryEntry = ____record_success_40 -- 1987
		if not writeSubAgentResultFile(session, record, resultText) then -- 1987
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 1987
		end -- 1987
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 1987
			sessionId = record.sessionId, -- 1992
			rootSessionId = record.rootSessionId, -- 1993
			parentSessionId = record.parentSessionId, -- 1994
			title = record.title, -- 1995
			prompt = record.prompt, -- 1996
			goal = record.goal, -- 1997
			expectedOutput = record.expectedOutput or "", -- 1998
			filesHint = record.filesHint or ({}), -- 1999
			status = record.status, -- 2000
			success = record.success, -- 2001
			resultFilePath = record.resultFilePath, -- 2002
			artifactDir = record.artifactDir, -- 2003
			sourceTaskId = record.sourceTaskId, -- 2004
			createdAt = record.createdAt, -- 2005
			finishedAt = record.finishedAt, -- 2006
			createdAtTs = record.createdAtTs, -- 2007
			finishedAtTs = record.finishedAtTs, -- 2008
			changeSet = record.changeSet, -- 2009
			memoryEntry = record.memoryEntry, -- 2010
			memoryEntryError = record.memoryEntryError, -- 2011
			completion = record.completion -- 2012
		}) then -- 2012
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2012
		end -- 2012
		if success then -- 2012
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2017
			deleteSessionRecords(session.id, true) -- 2018
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2019
		end -- 2019
		return ____awaiter_resolve(nil, {success = true}) -- 2019
	end) -- 2019
end -- 2019
function stopClearedSubSession(session, taskId) -- 2024
	local spawnInfo = getSessionSpawnInfo(session) -- 2025
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2026
	local rootSessionId = getSessionRootId(session) -- 2027
	Tools.setTaskStatus(taskId, "STOPPED") -- 2028
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2029
	if not writeSpawnInfo( -- 2029
		session.projectRoot, -- 2030
		session.memoryScope, -- 2030
		{ -- 2030
			sessionId = session.id, -- 2031
			rootSessionId = rootSessionId, -- 2032
			parentSessionId = session.parentSessionId, -- 2033
			title = session.title, -- 2034
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2035
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2036
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2037
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2038
			status = "STOPPED", -- 2039
			success = false, -- 2040
			cleared = true, -- 2041
			resultFilePath = "", -- 2042
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2043
			sourceTaskId = taskId, -- 2044
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2045
			finishedAt = finishedAt, -- 2046
			createdAtTs = session.createdAt, -- 2047
			finishedAtTs = now() -- 2048
		} -- 2048
	) then -- 2048
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2050
	end -- 2050
	deleteSessionRecords(session.id, true) -- 2052
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2053
	return {success = true} -- 2054
end -- 2054
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools) -- 2057
	if allowSubSessionStart == nil then -- 2057
		allowSubSessionStart = false -- 2057
	end -- 2057
	local session = getSessionItem(sessionId) -- 2058
	if not session then -- 2058
		return {success = false, message = "session not found"} -- 2060
	end -- 2060
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2060
		return {success = false, message = "session task is finalizing"} -- 2063
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
	return startPromptTask( -- 2085
		session, -- 2085
		normalizedPrompt, -- 2085
		nil, -- 2085
		normalizeDisabledAgentTools(disabledAgentTools) -- 2085
	) -- 2085
end -- 2057
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools) -- 2088
	if disabledAgentTools == nil then -- 2088
		disabledAgentTools = {} -- 2088
	end -- 2088
	local taskRes = Tools.createTask(normalizedPrompt) -- 2089
	if not taskRes.success then -- 2089
		return {success = false, message = taskRes.message} -- 2091
	end -- 2091
	local taskId = taskRes.taskId -- 2093
	local useChineseResponse = getDefaultUseChineseResponse() -- 2094
	if existingUserMessageId ~= nil then -- 2094
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2096
	else -- 2096
		insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2098
	end -- 2098
	local stopToken = {stopped = false} -- 2100
	activeStopTokens[taskId] = stopToken -- 2101
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2102
	runCodingAgent( -- 2103
		{ -- 2103
			prompt = normalizedPrompt, -- 2104
			workDir = session.projectRoot, -- 2105
			useChineseResponse = useChineseResponse, -- 2106
			taskId = taskId, -- 2107
			sessionId = session.id, -- 2108
			memoryScope = session.memoryScope, -- 2109
			role = session.kind, -- 2110
			disabledAgentTools = disabledAgentTools, -- 2111
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2112
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2115
			stopToken = stopToken, -- 2118
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2119
		}, -- 2119
		function(result) -- 2120
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2120
				local nextSession = getSessionItem(session.id) -- 2121
				if nextSession and nextSession.kind == "sub" then -- 2121
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2121
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2124
						if not stopped.success then -- 2124
							Log( -- 2126
								"Warn", -- 2126
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2126
							) -- 2126
							emitAgentSessionPatch( -- 2127
								session.id, -- 2127
								{session = getSessionItem(session.id)} -- 2127
							) -- 2127
						end -- 2127
						__TS__Delete(activeStopTokens, taskId) -- 2131
						return ____awaiter_resolve(nil) -- 2131
					end -- 2131
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2134
					emitAgentSessionPatch( -- 2135
						session.id, -- 2135
						{session = getSessionItem(session.id)} -- 2135
					) -- 2135
					local finalized = __TS__Await(finalizeSubSession( -- 2138
						nextSession, -- 2138
						taskId, -- 2138
						result.success, -- 2138
						result.message, -- 2138
						result.completion -- 2138
					)) -- 2138
					if not finalized.success then -- 2138
						Log( -- 2140
							"Warn", -- 2140
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2140
						) -- 2140
					end -- 2140
					local finalizedSession = getSessionItem(session.id) -- 2142
					if finalizedSession then -- 2142
						local stopped = stopToken.stopped == true -- 2144
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2145
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2148
						emitAgentSessionPatch( -- 2149
							session.id, -- 2149
							{session = getSessionItem(session.id)} -- 2149
						) -- 2149
					end -- 2149
					__TS__Delete(activeStopTokens, taskId) -- 2153
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2154
				end -- 2154
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2154
					applyEvent(session.id, { -- 2157
						type = "task_finished", -- 2158
						sessionId = session.id, -- 2159
						taskId = result.taskId, -- 2160
						success = false, -- 2161
						message = result.message, -- 2162
						steps = result.steps -- 2163
					}) -- 2163
				end -- 2163
			end) -- 2163
		end -- 2120
	) -- 2120
	return {success = true, sessionId = session.id, taskId = taskId} -- 2167
end -- 2167
function ____exports.listRunningSubAgents(request) -- 2255
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2255
		local session = getSessionItem(request.sessionId) -- 2263
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2263
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2265
		end -- 2265
		if not session then -- 2265
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2265
		end -- 2265
		local rootSession = getRootSessionItem(session.id) -- 2270
		if not rootSession then -- 2270
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2270
		end -- 2270
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2274
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2275
		local limit = math.max( -- 2276
			1, -- 2276
			math.floor(tonumber(request.limit) or 5) -- 2276
		) -- 2276
		local offset = math.max( -- 2277
			0, -- 2277
			math.floor(tonumber(request.offset) or 0) -- 2277
		) -- 2277
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2278
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2279
		local runningSessions = {} -- 2286
		do -- 2286
			local i = 0 -- 2287
			while i < #rows do -- 2287
				do -- 2287
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2288
					if current.currentTaskStatus ~= "RUNNING" then -- 2288
						goto __continue339 -- 2290
					end -- 2290
					local spawnInfo = getSessionSpawnInfo(current) -- 2292
					runningSessions[#runningSessions + 1] = { -- 2293
						sessionId = current.id, -- 2294
						title = current.title, -- 2295
						parentSessionId = current.parentSessionId, -- 2296
						rootSessionId = current.rootSessionId, -- 2297
						status = "RUNNING", -- 2298
						currentTaskId = current.currentTaskId, -- 2299
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2300
						goal = spawnInfo and spawnInfo.goal, -- 2301
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2302
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2303
						createdAt = current.createdAt, -- 2304
						updatedAt = current.updatedAt -- 2305
					} -- 2305
				end -- 2305
				::__continue339:: -- 2305
				i = i + 1 -- 2287
			end -- 2287
		end -- 2287
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2308
		local completedSessions = __TS__ArrayMap( -- 2309
			completedRecords, -- 2309
			function(____, record) return { -- 2309
				sessionId = record.sessionId, -- 2310
				title = record.title, -- 2311
				parentSessionId = record.parentSessionId, -- 2312
				rootSessionId = record.rootSessionId, -- 2313
				status = record.status, -- 2314
				goal = record.goal, -- 2315
				expectedOutput = record.expectedOutput, -- 2316
				filesHint = record.filesHint, -- 2317
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2318
				success = record.success, -- 2319
				cleared = record.cleared, -- 2320
				resultFilePath = record.resultFilePath, -- 2321
				artifactDir = record.artifactDir, -- 2322
				finishedAt = record.finishedAt, -- 2323
				createdAt = record.createdAtTs, -- 2324
				updatedAt = record.finishedAtTs -- 2325
			} end -- 2325
		) -- 2325
		local merged = {} -- 2327
		if status == "running" then -- 2327
			merged = runningSessions -- 2329
		elseif status == "done" then -- 2329
			merged = __TS__ArrayFilter( -- 2331
				completedSessions, -- 2331
				function(____, item) return item.status == "DONE" end -- 2331
			) -- 2331
		elseif status == "failed" then -- 2331
			merged = __TS__ArrayFilter( -- 2333
				completedSessions, -- 2333
				function(____, item) return item.status == "FAILED" end -- 2333
			) -- 2333
		elseif status == "stopped" then -- 2333
			merged = __TS__ArrayFilter( -- 2335
				completedSessions, -- 2335
				function(____, item) return item.status == "STOPPED" end -- 2335
			) -- 2335
		elseif status == "all" then -- 2335
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2337
		else -- 2337
			local runningKeys = {} -- 2339
			do -- 2339
				local i = 0 -- 2340
				while i < #runningSessions do -- 2340
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2341
					i = i + 1 -- 2340
				end -- 2340
			end -- 2340
			local latestCompletedByKey = {} -- 2343
			do -- 2343
				local i = 0 -- 2344
				while i < #completedSessions do -- 2344
					do -- 2344
						local item = completedSessions[i + 1] -- 2345
						local key = getSubAgentDisplayKey(item) -- 2346
						if runningKeys[key] then -- 2346
							goto __continue354 -- 2348
						end -- 2348
						local current = latestCompletedByKey[key] -- 2350
						if not current or item.updatedAt > current.updatedAt then -- 2350
							latestCompletedByKey[key] = item -- 2352
						end -- 2352
					end -- 2352
					::__continue354:: -- 2352
					i = i + 1 -- 2344
				end -- 2344
			end -- 2344
			local latestCompleted = {} -- 2355
			for ____, item in pairs(latestCompletedByKey) do -- 2356
				latestCompleted[#latestCompleted + 1] = item -- 2357
			end -- 2357
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2359
		end -- 2359
		if query ~= "" then -- 2359
			merged = __TS__ArrayFilter( -- 2362
				merged, -- 2362
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2362
			) -- 2362
		end -- 2362
		__TS__ArraySort( -- 2368
			merged, -- 2368
			function(____, a, b) -- 2368
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2368
					return -1 -- 2369
				end -- 2369
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2369
					return 1 -- 2370
				end -- 2370
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2370
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2372
				end -- 2372
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2374
			end -- 2368
		) -- 2368
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2376
		return ____awaiter_resolve(nil, { -- 2376
			success = true, -- 2378
			rootSessionId = rootSession.id, -- 2379
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2380
			status = status, -- 2381
			limit = limit, -- 2382
			offset = offset, -- 2383
			hasMore = offset + limit < #merged, -- 2384
			sessions = paged -- 2385
		}) -- 2385
	end) -- 2385
end -- 2255
TABLE_SESSION = "AgentSession" -- 199
TABLE_MESSAGE = "AgentSessionMessage" -- 200
TABLE_STEP = "AgentSessionStep" -- 201
TABLE_TASK = "AgentTask" -- 202
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 203
SPAWN_INFO_FILE = "SPAWN.json" -- 204
RESULT_FILE = "RESULT.md" -- 205
PENDING_HANDOFF_DIR = "pending-handoffs" -- 206
MAX_CONCURRENT_SUB_AGENTS = 4 -- 207
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 208
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 209
activeStopTokens = {} -- 257
finalizingSubSessionTaskIds = {} -- 258
now = function() return os.time() end -- 259
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 636
	if projectRoot == oldRoot then -- 636
		return newRoot -- 638
	end -- 638
	for ____, separator in ipairs({"/", "\\"}) do -- 640
		local prefix = oldRoot .. separator -- 641
		if __TS__StringStartsWith(projectRoot, prefix) then -- 641
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 643
		end -- 643
	end -- 643
	return nil -- 646
end -- 636
local function clearSessionAfterMessage(sessionId, message) -- 1101
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1102
	local removedStepIds = {} -- 1110
	do -- 1110
		local i = 0 -- 1111
		while i < #removedStepRows do -- 1111
			local row = removedStepRows[i + 1] -- 1112
			if type(row[1]) == "number" then -- 1112
				removedStepIds[#removedStepIds + 1] = row[1] -- 1114
			end -- 1114
			i = i + 1 -- 1111
		end -- 1111
	end -- 1111
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1117
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1125
	return removedStepIds -- 1130
end -- 1101
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1133
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1134
	local persisted = storage:readSessionState() -- 1135
	local userIndex = -1 -- 1136
	do -- 1136
		local i = #persisted.messages - 1 -- 1137
		while i >= 0 do -- 1137
			if persisted.messages[i + 1].role == "user" then -- 1137
				userIndex = i -- 1139
				break -- 1140
			end -- 1140
			i = i - 1 -- 1137
		end -- 1137
	end -- 1137
	if userIndex < 0 then -- 1137
		return -- 1143
	end -- 1143
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1144
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1145
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1146
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1151
end -- 1133
local function sanitizeStoredSteps(sessionId) -- 1305
	DB:exec( -- 1306
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1306
		{ -- 1324
			now(), -- 1324
			sessionId -- 1324
		} -- 1324
	) -- 1324
end -- 1305
local function getSchemaVersion() -- 1577
	local row = queryOne("PRAGMA user_version") -- 1578
	return row and type(row[1]) == "number" and row[1] or 0 -- 1579
end -- 1577
local function setSchemaVersion(version) -- 1582
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1583
		0, -- 1583
		math.floor(version) -- 1583
	))) -- 1583
end -- 1582
local function hasTableColumn(tableName, columnName) -- 1586
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1587
	do -- 1587
		local i = 0 -- 1588
		while i < #rows do -- 1588
			local row = rows[i + 1] -- 1589
			if toStr(row[2]) == columnName then -- 1589
				return true -- 1591
			end -- 1591
			i = i + 1 -- 1588
		end -- 1588
	end -- 1588
	return false -- 1594
end -- 1586
local function ensureSessionMetricsColumn() -- 1597
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1597
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1599
	end -- 1599
end -- 1597
local function recreateSchema() -- 1603
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1604
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1605
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1606
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1607
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1622
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1623
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1632
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1633
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1650
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1651
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1652
end -- 1603
do -- 1603
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1603
		recreateSchema() -- 1658
	else -- 1658
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1660
		ensureSessionMetricsColumn() -- 1675
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1676
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1677
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1686
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1687
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1704
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1705
	end -- 1705
end -- 1705
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 1848
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 1848
		return {success = false, message = "invalid projectRoot"} -- 1850
	end -- 1850
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 1852
	for ____, row in ipairs(rows) do -- 1853
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1854
		if sessionId > 0 then -- 1854
			deleteSessionRecords(sessionId) -- 1856
		end -- 1856
	end -- 1856
	return {success = true, deleted = #rows} -- 1859
end -- 1848
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 1862
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 1862
		return {success = false, message = "invalid projectRoot"} -- 1864
	end -- 1864
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 1866
	local renamed = 0 -- 1867
	for ____, row in ipairs(rows) do -- 1868
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 1869
		local projectRoot = toStr(row[2]) -- 1870
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1871
		if sessionId > 0 and nextProjectRoot then -- 1871
			DB:exec( -- 1873
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 1873
				{ -- 1875
					nextProjectRoot, -- 1875
					Path:getFilename(nextProjectRoot), -- 1875
					now(), -- 1875
					sessionId -- 1875
				} -- 1875
			) -- 1875
			renamed = renamed + 1 -- 1877
		end -- 1877
	end -- 1877
	return {success = true, renamed = renamed} -- 1880
end -- 1862
function ____exports.getSession(sessionId) -- 1883
	local session = getSessionItem(sessionId) -- 1884
	if not session then -- 1884
		return {success = false, message = "session not found"} -- 1886
	end -- 1886
	local normalizedSession = normalizeSessionRuntimeState(session) -- 1888
	local relatedSessions = listRelatedSessions(sessionId) -- 1889
	sanitizeStoredSteps(sessionId) -- 1890
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 1891
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 1898
	local ____relatedSessions_29 = relatedSessions -- 1909
	local ____temp_28 -- 1910
	if normalizedSession.kind == "sub" then -- 1910
		____temp_28 = getSessionSpawnInfo(normalizedSession) -- 1910
	else -- 1910
		____temp_28 = nil -- 1910
	end -- 1910
	return { -- 1906
		success = true, -- 1907
		session = normalizedSession, -- 1908
		relatedSessions = ____relatedSessions_29, -- 1909
		spawnInfo = ____temp_28, -- 1910
		messages = __TS__ArrayMap( -- 1911
			messages, -- 1911
			function(____, row) return rowToMessage(row) end -- 1911
		), -- 1911
		steps = __TS__ArrayMap( -- 1912
			steps, -- 1912
			function(____, row) return rowToStep(row) end -- 1912
		), -- 1912
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 1913
	} -- 1913
end -- 1883
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools) -- 2170
	local session = getSessionItem(sessionId) -- 2171
	if not session then -- 2171
		return {success = false, message = "session not found"} -- 2173
	end -- 2173
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2173
		return {success = false, message = "session task is finalizing"} -- 2176
	end -- 2176
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2176
		return {success = false, message = "session task is still running"} -- 2179
	end -- 2179
	local message = getMessageItem(messageId) -- 2181
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2181
		return {success = false, message = "message not found"} -- 2183
	end -- 2183
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2185
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2191
	if latestUserMessageId ~= messageId then -- 2191
		return {success = false, message = "only the latest user prompt can be edited"} -- 2193
	end -- 2193
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2195
	if normalizedPrompt == "" then -- 2195
		return {success = false, message = "prompt is empty"} -- 2197
	end -- 2197
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2199
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2200
	local result = startPromptTask( -- 2201
		session, -- 2201
		normalizedPrompt, -- 2201
		messageId, -- 2201
		normalizeDisabledAgentTools(disabledAgentTools) -- 2201
	) -- 2201
	if result.success and #removedStepIds > 0 then -- 2201
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2203
	end -- 2203
	return result -- 2205
end -- 2170
function ____exports.stopSessionTask(sessionId) -- 2208
	local session = getSessionItem(sessionId) -- 2209
	if not session or session.currentTaskId == nil then -- 2209
		return {success = false, message = "session task not found"} -- 2211
	end -- 2211
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2211
		return {success = false, message = "session task is finalizing"} -- 2214
	end -- 2214
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2216
	local stopToken = activeStopTokens[session.currentTaskId] -- 2217
	if not stopToken then -- 2217
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2217
			return {success = true, recovered = true} -- 2220
		end -- 2220
		return {success = false, message = "task is not running"} -- 2222
	end -- 2222
	stopToken.stopped = true -- 2224
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2225
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2226
	return {success = true} -- 2227
end -- 2208
function ____exports.getCurrentTaskId(sessionId) -- 2230
	local ____opt_51 = getSessionItem(sessionId) -- 2230
	return ____opt_51 and ____opt_51.currentTaskId -- 2231
end -- 2230
function ____exports.listRunningSessions() -- 2234
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2235
	local sessions = {} -- 2242
	do -- 2242
		local i = 0 -- 2243
		while i < #rows do -- 2243
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2244
			if session.currentTaskStatus == "RUNNING" then -- 2244
				sessions[#sessions + 1] = session -- 2246
			end -- 2246
			i = i + 1 -- 2243
		end -- 2243
	end -- 2243
	return {success = true, sessions = sessions} -- 2249
end -- 2234
return ____exports -- 2234