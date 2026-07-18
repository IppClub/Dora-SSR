-- [ts]: AgentSession.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
function getDefaultUseChineseResponse() -- 301
	local zh = string.match(App.locale, "^zh") -- 302
	return zh ~= nil -- 303
end -- 303
function toStr(v) -- 306
	if v == false or v == nil then -- 306
		return "" -- 307
	end -- 307
	return tostring(v) -- 308
end -- 308
function encodeJson(value) -- 311
	local text = safeJsonEncode(value) -- 312
	return text or "" -- 313
end -- 313
function decodeJsonObject(text) -- 316
	if not text or text == "" then -- 316
		return nil -- 317
	end -- 317
	local value = safeJsonDecode(text) -- 318
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 318
		return value -- 320
	end -- 320
	return nil -- 322
end -- 322
function decodeJsonFiles(text) -- 325
	if not text or text == "" then -- 325
		return nil -- 326
	end -- 326
	local value = safeJsonDecode(text) -- 327
	if not value or not __TS__ArrayIsArray(value) then -- 327
		return nil -- 328
	end -- 328
	local files = {} -- 329
	do -- 329
		local i = 0 -- 330
		while i < #value do -- 330
			do -- 330
				local item = value[i + 1] -- 331
				if type(item) ~= "table" then -- 331
					goto __continue14 -- 332
				end -- 332
				files[#files + 1] = { -- 333
					path = sanitizeUTF8(toStr(item.path)), -- 334
					op = sanitizeUTF8(toStr(item.op)) -- 335
				} -- 335
			end -- 335
			::__continue14:: -- 335
			i = i + 1 -- 330
		end -- 330
	end -- 330
	return files -- 338
end -- 338
function decodeChangeSetSummary(value) -- 341
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 341
		return nil -- 342
	end -- 342
	local row = value -- 343
	if row.success ~= true then -- 343
		return nil -- 344
	end -- 344
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 345
	if taskId <= 0 then -- 345
		return nil -- 346
	end -- 346
	local files = {} -- 347
	if __TS__ArrayIsArray(row.files) then -- 347
		do -- 347
			local i = 0 -- 349
			while i < #row.files do -- 349
				do -- 349
					local file = row.files[i + 1] -- 350
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 350
						goto __continue22 -- 351
					end -- 351
					local fileRow = file -- 352
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 353
					if path == "" then -- 353
						goto __continue22 -- 354
					end -- 354
					local checkpointIds = {} -- 355
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 355
						do -- 355
							local j = 0 -- 357
							while j < #fileRow.checkpointIds do -- 357
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 358
								if checkpointId > 0 then -- 358
									checkpointIds[#checkpointIds + 1] = checkpointId -- 359
								end -- 359
								j = j + 1 -- 357
							end -- 357
						end -- 357
					end -- 357
					local op = toStr(fileRow.op) -- 362
					files[#files + 1] = { -- 363
						path = path, -- 364
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 365
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 366
						checkpointIds = checkpointIds -- 367
					} -- 367
				end -- 367
				::__continue22:: -- 367
				i = i + 1 -- 349
			end -- 349
		end -- 349
	end -- 349
	return { -- 371
		success = true, -- 372
		taskId = taskId, -- 373
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 374
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 375
		files = files, -- 376
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 377
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 378
	} -- 378
end -- 378
function decodeHandoffEvidence(value) -- 382
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 382
		return nil -- 383
	end -- 383
	local row = value -- 384
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 385
		__TS__ArrayFilter( -- 386
			row.modifiedFiles, -- 386
			function(____, item) return type(item) == "string" end -- 386
		), -- 386
		function(____, item) return sanitizeUTF8(item) end -- 386
	) or ({}) -- 386
	local lastBuild = nil -- 388
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 388
		local build = row.lastBuild -- 390
		lastBuild = { -- 391
			result = build.result == "passed" and "passed" or "failed", -- 392
			path = sanitizeUTF8(toStr(build.path)), -- 393
			evidence = takeUtf8Head( -- 394
				sanitizeUTF8(toStr(build.evidence)), -- 394
				600 -- 394
			) -- 394
		} -- 394
	end -- 394
	local commands = {} -- 397
	if __TS__ArrayIsArray(row.commands) then -- 397
		do -- 397
			local i = 0 -- 399
			while i < #row.commands and #commands < 8 do -- 399
				do -- 399
					local raw = row.commands[i + 1] -- 400
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 400
						goto __continue36 -- 401
					end -- 401
					local item = raw -- 402
					commands[#commands + 1] = { -- 403
						mode = sanitizeUTF8(toStr(item.mode)), -- 404
						command = takeUtf8Head( -- 405
							sanitizeUTF8(toStr(item.command)), -- 405
							600 -- 405
						), -- 405
						result = item.result == "passed" and "passed" or "failed", -- 406
						evidence = takeUtf8Head( -- 407
							sanitizeUTF8(toStr(item.evidence)), -- 407
							600 -- 407
						) -- 407
					} -- 407
				end -- 407
				::__continue36:: -- 407
				i = i + 1 -- 399
			end -- 399
		end -- 399
	end -- 399
	local authoritativeSources = {} -- 411
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 411
		do -- 411
			local i = 0 -- 413
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 413
				do -- 413
					local raw = row.authoritativeSources[i + 1] -- 414
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 414
						goto __continue40 -- 415
					end -- 415
					local item = raw -- 416
					authoritativeSources[#authoritativeSources + 1] = { -- 417
						tool = "search_dora_api", -- 418
						query = takeUtf8Head( -- 419
							sanitizeUTF8(toStr(item.query)), -- 419
							300 -- 419
						), -- 419
						source = sanitizeUTF8(toStr(item.source)), -- 420
						result = item.result == "passed" and "passed" or "failed" -- 421
					} -- 421
				end -- 421
				::__continue40:: -- 421
				i = i + 1 -- 413
			end -- 413
		end -- 413
	end -- 413
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 425
end -- 425
function takeUtf8Head(text, maxChars) -- 428
	if maxChars <= 0 or text == "" then -- 428
		return "" -- 429
	end -- 429
	local nextPos = utf8.offset(text, maxChars + 1) -- 430
	if nextPos == nil then -- 430
		return text -- 431
	end -- 431
	return string.sub(text, 1, nextPos - 1) -- 432
end -- 432
function normalizeMemoryEntryEvidence(value) -- 435
	local evidence = {} -- 436
	if not __TS__ArrayIsArray(value) then -- 436
		return evidence -- 437
	end -- 437
	do -- 437
		local i = 0 -- 438
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 438
			do -- 438
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 439
				if item == "" then -- 439
					goto __continue48 -- 440
				end -- 440
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 440
					evidence[#evidence + 1] = item -- 442
				end -- 442
			end -- 442
			::__continue48:: -- 442
			i = i + 1 -- 438
		end -- 438
	end -- 438
	return evidence -- 445
end -- 445
function decodeSubAgentMemoryEntry(value) -- 448
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 448
		return nil -- 449
	end -- 449
	local row = value -- 450
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 451
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 452
	local content = takeUtf8Head( -- 453
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 453
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 453
	) -- 453
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 453
		return nil -- 454
	end -- 454
	return { -- 455
		sourceSessionId = sourceSessionId, -- 456
		sourceTaskId = sourceTaskId, -- 457
		content = content, -- 458
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 459
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 460
	} -- 460
end -- 460
function getTaskChangeSetSummary(taskId) -- 464
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 465
	return summary.success and summary or nil -- 466
end -- 466
function queryRows(sql, args) -- 469
	local ____args_0 -- 470
	if args then -- 470
		____args_0 = DB:query(sql, args) -- 470
	else -- 470
		____args_0 = DB:query(sql) -- 470
	end -- 470
	return ____args_0 -- 470
end -- 470
function queryOne(sql, args) -- 473
	local rows = queryRows(sql, args) -- 474
	if not rows or #rows == 0 then -- 474
		return nil -- 475
	end -- 475
	return rows[1] -- 476
end -- 476
function summarizeHandoffResult(result) -- 479
	local candidates = {result.output, result.message, result.state, result.phase} -- 480
	do -- 480
		local i = 0 -- 481
		while i < #candidates do -- 481
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 482
			if text ~= "" then -- 482
				return takeUtf8Head(text, 600) -- 483
			end -- 483
			i = i + 1 -- 481
		end -- 481
	end -- 481
	local messages = result.messages -- 485
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 485
		local parts = {} -- 487
		do -- 487
			local i = 0 -- 488
			while i < #messages and #parts < 4 do -- 488
				do -- 488
					local row = messages[i + 1] -- 489
					if not row or type(row) ~= "table" then -- 489
						goto __continue64 -- 490
					end -- 490
					local item = row -- 491
					local ____sanitizeUTF8_4 = sanitizeUTF8 -- 492
					local ____toStr_3 = toStr -- 492
					local ____item_message_1 = item.message -- 492
					if ____item_message_1 == nil then -- 492
						____item_message_1 = item.error -- 492
					end -- 492
					local ____item_message_1_2 = ____item_message_1 -- 492
					if ____item_message_1_2 == nil then -- 492
						____item_message_1_2 = item.file -- 492
					end -- 492
					local text = __TS__StringTrim(____sanitizeUTF8_4(____toStr_3(____item_message_1_2))) -- 492
					if text ~= "" then -- 492
						parts[#parts + 1] = text -- 493
					end -- 493
				end -- 493
				::__continue64:: -- 493
				i = i + 1 -- 488
			end -- 488
		end -- 488
		if #parts > 0 then -- 488
			return takeUtf8Head( -- 495
				table.concat(parts, "; "), -- 495
				600 -- 495
			) -- 495
		end -- 495
	end -- 495
	return result.success == true and "tool result success=true" or "tool result success=false" -- 497
end -- 497
function getTaskHandoffEvidence(taskId, changeSet) -- 500
	local ____opt_5 = changeSet -- 500
	local evidence = { -- 501
		modifiedFiles = ____opt_5 and __TS__ArrayMap( -- 502
			changeSet and changeSet.files, -- 502
			function(____, item) return item.path end -- 502
		) or ({}), -- 502
		commands = {}, -- 503
		authoritativeSources = {} -- 504
	} -- 504
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_api"}) or ({}) -- 506
	do -- 506
		local i = 0 -- 511
		while i < #rows do -- 511
			local tool = toStr(rows[i + 1][1]) -- 512
			local status = toStr(rows[i + 1][2]) -- 513
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 514
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 515
			local passed = status == "DONE" and result.success == true -- 516
			if tool == "build" then -- 516
				evidence.lastBuild = { -- 518
					result = passed and "passed" or "failed", -- 519
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 520
					evidence = summarizeHandoffResult(result) -- 521
				} -- 521
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 521
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 524
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 525
				local ____evidence_commands_9 = evidence.commands -- 525
				____evidence_commands_9[#____evidence_commands_9 + 1] = { -- 526
					mode = mode, -- 527
					command = takeUtf8Head( -- 528
						__TS__StringTrim(sanitizeUTF8(command)), -- 528
						600 -- 528
					), -- 528
					result = passed and "passed" or "failed", -- 529
					evidence = summarizeHandoffResult(result) -- 530
				} -- 530
			elseif tool == "search_dora_api" and #evidence.authoritativeSources < 8 then -- 530
				local ____evidence_authoritativeSources_10 = evidence.authoritativeSources -- 530
				____evidence_authoritativeSources_10[#____evidence_authoritativeSources_10 + 1] = { -- 533
					tool = "search_dora_api", -- 534
					query = takeUtf8Head( -- 535
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 535
						300 -- 535
					), -- 535
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docSource or "api"))), -- 536
					result = passed and "passed" or "failed" -- 537
				} -- 537
			end -- 537
			i = i + 1 -- 511
		end -- 511
	end -- 511
	return evidence -- 541
end -- 541
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 544
	local lastBuild = evidence.lastBuild -- 548
	if not lastBuild or lastBuild.result ~= "failed" then -- 548
		return completion -- 549
	end -- 549
	local validation = __TS__ArraySlice(completion.validation) -- 550
	local foundBuild = false -- 551
	do -- 551
		local i = 0 -- 552
		while i < #validation do -- 552
			do -- 552
				if validation[i + 1].kind ~= "build" then -- 552
					goto __continue78 -- 553
				end -- 553
				foundBuild = true -- 554
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 555
			end -- 555
			::__continue78:: -- 555
			i = i + 1 -- 552
		end -- 552
	end -- 552
	if not foundBuild then -- 552
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 562
	end -- 562
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 564
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 565
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 565
		knownIssues[#knownIssues + 1] = issue -- 566
	end -- 566
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 567
end -- 567
function getLastInsertRowId() -- 575
	local row = queryOne("SELECT last_insert_rowid()") -- 576
	return row and (row[1] or 0) or 0 -- 577
end -- 577
function isValidProjectRoot(path) -- 580
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 581
end -- 581
function rowToSession(row) -- 584
	return { -- 585
		id = row[1], -- 586
		projectRoot = toStr(row[2]), -- 587
		title = toStr(row[3]), -- 588
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 589
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 590
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 591
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 592
		status = toStr(row[8]), -- 593
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 594
		currentTaskStatus = toStr(row[10]), -- 595
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 596
		createdAt = row[11], -- 597
		updatedAt = row[12], -- 598
		metrics = decodeJsonObject(toStr(row[13])) -- 599
	} -- 599
end -- 599
function rowToMessage(row) -- 603
	return { -- 604
		id = row[1], -- 605
		sessionId = row[2], -- 606
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 607
		role = toStr(row[4]), -- 608
		content = toStr(row[5]), -- 609
		createdAt = row[6], -- 610
		updatedAt = row[7] -- 611
	} -- 611
end -- 611
function rowToStep(row) -- 615
	return { -- 616
		id = row[1], -- 617
		sessionId = row[2], -- 618
		taskId = row[3], -- 619
		step = row[4], -- 620
		tool = toStr(row[5]), -- 621
		status = toStr(row[6]), -- 622
		reason = toStr(row[7]), -- 623
		reasoningContent = toStr(row[8]), -- 624
		params = decodeJsonObject(toStr(row[9])), -- 625
		result = decodeJsonObject(toStr(row[10])), -- 626
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 627
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 628
		files = decodeJsonFiles(toStr(row[13])), -- 629
		createdAt = row[14], -- 630
		updatedAt = row[15] -- 631
	} -- 631
end -- 631
function getMessageItem(messageId) -- 635
	local row = queryOne(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 636
	return row and rowToMessage(row) or nil -- 642
end -- 642
function getStepItem(sessionId, taskId, step) -- 645
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 646
	return row and rowToStep(row) or nil -- 652
end -- 652
function deleteMessageSteps(sessionId, taskId) -- 655
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 656
	local ids = {} -- 661
	do -- 661
		local i = 0 -- 662
		while i < #rows do -- 662
			local row = rows[i + 1] -- 663
			if type(row[1]) == "number" then -- 663
				ids[#ids + 1] = row[1] -- 665
			end -- 665
			i = i + 1 -- 662
		end -- 662
	end -- 662
	if #ids > 0 then -- 662
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 669
	end -- 669
	return ids -- 675
end -- 675
function normalizeDisabledAgentTools(value) -- 678
	if not __TS__ArrayIsArray(value) then -- 678
		return {} -- 679
	end -- 679
	local tools = {} -- 680
	do -- 680
		local i = 0 -- 681
		while i < #value do -- 681
			do -- 681
				local name = value[i + 1] -- 682
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 682
					goto __continue97 -- 683
				end -- 683
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 683
					tools[#tools + 1] = name -- 684
				end -- 684
			end -- 684
			::__continue97:: -- 684
			i = i + 1 -- 681
		end -- 681
	end -- 681
	return tools -- 686
end -- 686
function getSessionRow(sessionId) -- 689
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 690
end -- 690
function getSessionItem(sessionId) -- 698
	local row = getSessionRow(sessionId) -- 699
	return row and rowToSession(row) or nil -- 700
end -- 700
function getTaskPrompt(taskId) -- 703
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 704
	if not row or type(row[1]) ~= "string" then -- 704
		return nil -- 705
	end -- 705
	return toStr(row[1]) -- 706
end -- 706
function getLatestMainSessionByProjectRoot(projectRoot) -- 709
	if not isValidProjectRoot(projectRoot) then -- 709
		return nil -- 710
	end -- 710
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 711
	return row and rowToSession(row) or nil -- 719
end -- 719
function countRunningSubSessions(rootSessionId) -- 722
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 723
	local count = 0 -- 730
	do -- 730
		local i = 0 -- 731
		while i < #rows do -- 731
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 732
			if session.currentTaskStatus == "RUNNING" then -- 732
				count = count + 1 -- 734
			end -- 734
			i = i + 1 -- 731
		end -- 731
	end -- 731
	return count -- 737
end -- 737
function deleteSessionRecords(sessionId, preserveArtifacts) -- 740
	if preserveArtifacts == nil then -- 740
		preserveArtifacts = false -- 740
	end -- 740
	local session = getSessionItem(sessionId) -- 741
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 742
	do -- 742
		local i = 0 -- 743
		while i < #children do -- 743
			local row = children[i + 1] -- 744
			if type(row[1]) == "number" and row[1] > 0 then -- 744
				deleteSessionRecords(row[1], preserveArtifacts) -- 746
			end -- 746
			i = i + 1 -- 743
		end -- 743
	end -- 743
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 749
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 750
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 751
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 752
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 752
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 754
	end -- 754
end -- 754
function getSessionRootId(session) -- 758
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 759
end -- 759
function getRootSessionItem(sessionId) -- 762
	local session = getSessionItem(sessionId) -- 763
	if not session then -- 763
		return nil -- 764
	end -- 764
	return getSessionItem(getSessionRootId(session)) or session -- 765
end -- 765
function listRelatedSessions(sessionId) -- 768
	local root = getRootSessionItem(sessionId) -- 769
	if not root then -- 769
		return {} -- 770
	end -- 770
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 771
	return __TS__ArrayMap( -- 780
		rows, -- 780
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 780
	) -- 780
end -- 780
function getSessionSpawnInfo(session) -- 783
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 784
	if not info then -- 784
		return nil -- 785
	end -- 785
	local ____temp_14 = type(info.sessionId) == "number" and info.sessionId or nil -- 787
	local ____temp_15 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 788
	local ____temp_16 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 789
	local ____temp_17 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 790
	local ____temp_18 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 791
	local ____temp_19 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 792
	local ____temp_20 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 793
	local ____temp_21 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 794
		__TS__ArrayFilter( -- 795
			info.filesHint, -- 795
			function(____, item) return type(item) == "string" end -- 795
		), -- 795
		function(____, item) return sanitizeUTF8(item) end -- 795
	) or nil -- 795
	local ____temp_22 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 797
	local ____temp_12 -- 800
	if info.success == true then -- 800
		____temp_12 = true -- 800
	else -- 800
		local ____temp_11 -- 800
		if info.success == false then -- 800
			____temp_11 = false -- 800
		else -- 800
			____temp_11 = nil -- 800
		end -- 800
		____temp_12 = ____temp_11 -- 800
	end -- 800
	local ____temp_13 -- 801
	if info.cleared == true then -- 801
		____temp_13 = true -- 801
	else -- 801
		____temp_13 = nil -- 801
	end -- 801
	return { -- 786
		sessionId = ____temp_14, -- 787
		rootSessionId = ____temp_15, -- 788
		parentSessionId = ____temp_16, -- 789
		title = ____temp_17, -- 790
		prompt = ____temp_18, -- 791
		goal = ____temp_19, -- 792
		expectedOutput = ____temp_20, -- 793
		filesHint = ____temp_21, -- 794
		status = ____temp_22, -- 797
		success = ____temp_12, -- 800
		cleared = ____temp_13, -- 801
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 802
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 803
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 804
		changeSet = decodeChangeSetSummary(info.changeSet), -- 805
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 806
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 807
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 808
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 809
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 812
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 813
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 814
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 815
	} -- 815
end -- 815
function ensureDirRecursive(dir) -- 832
	if not dir or dir == "" then -- 832
		return false -- 833
	end -- 833
	if Content:exist(dir) then -- 833
		return Content:isdir(dir) -- 834
	end -- 834
	local parent = Path:getPath(dir) -- 835
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 835
		if not ensureDirRecursive(parent) then -- 835
			return false -- 838
		end -- 838
	end -- 838
	return Content:mkdir(dir) -- 841
end -- 841
function writeSpawnInfo(projectRoot, memoryScope, value) -- 844
	local dir = Path(projectRoot, ".agent", memoryScope) -- 845
	if not Content:exist(dir) then -- 845
		ensureDirRecursive(dir) -- 847
	end -- 847
	local path = Path(dir, SPAWN_INFO_FILE) -- 849
	local text = safeJsonEncode(value) -- 850
	if not text then -- 850
		return false -- 851
	end -- 851
	local content = text .. "\n" -- 852
	if not Content:save(path, content) then -- 852
		return false -- 854
	end -- 854
	Tools.sendWebIDEFileUpdate(path, true, content) -- 856
	return true -- 857
end -- 857
function readSpawnInfo(projectRoot, memoryScope) -- 860
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 861
	if not Content:exist(path) then -- 861
		return nil -- 862
	end -- 862
	local text = Content:load(path) -- 863
	if not text or __TS__StringTrim(text) == "" then -- 863
		return nil -- 864
	end -- 864
	local value = safeJsonDecode(text) -- 865
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 865
		return value -- 867
	end -- 867
	return nil -- 869
end -- 869
function getArtifactRelativeDir(memoryScope) -- 872
	return Path(".agent", memoryScope) -- 873
end -- 873
function getArtifactDir(projectRoot, memoryScope) -- 876
	return Path( -- 877
		projectRoot, -- 877
		getArtifactRelativeDir(memoryScope) -- 877
	) -- 877
end -- 877
function getResultRelativePath(memoryScope) -- 880
	return Path( -- 881
		getArtifactRelativeDir(memoryScope), -- 881
		RESULT_FILE -- 881
	) -- 881
end -- 881
function getResultPath(projectRoot, memoryScope) -- 884
	return Path( -- 885
		projectRoot, -- 885
		getResultRelativePath(memoryScope) -- 885
	) -- 885
end -- 885
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 888
	if not resultFilePath or resultFilePath == "" then -- 888
		return "" -- 889
	end -- 889
	local path = Path(projectRoot, resultFilePath) -- 890
	if not Content:exist(path) then -- 890
		return "" -- 891
	end -- 891
	local text = sanitizeUTF8(Content:load(path)) -- 892
	if not text or __TS__StringTrim(text) == "" then -- 892
		return "" -- 893
	end -- 893
	local marker = "\n## Summary\n" -- 894
	local start = string.find(text, marker, 1, true) -- 895
	if start ~= nil then -- 895
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 897
	end -- 897
	return __TS__StringTrim(text) -- 899
end -- 899
function buildStructuredSubAgentMemoryEntry(record) -- 902
	local hasPassedValidation = false -- 903
	do -- 903
		local i = 0 -- 904
		while i < #record.completion.validation do -- 904
			local result = record.completion.validation[i + 1].result -- 905
			if result == "failed" then -- 905
				return nil -- 910
			end -- 910
			if result == "passed" then -- 910
				hasPassedValidation = true -- 912
			end -- 912
			i = i + 1 -- 904
		end -- 904
	end -- 904
	if not hasPassedValidation then -- 904
		return nil -- 915
	end -- 915
	local candidates = record.completion.learningCandidates -- 916
	local claims = {} -- 917
	local evidence = {} -- 918
	do -- 918
		local i = 0 -- 919
		while i < #candidates do -- 919
			do -- 919
				local candidate = candidates[i + 1] -- 920
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 920
					goto __continue159 -- 921
				end -- 921
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 922
				do -- 922
					local j = 0 -- 923
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 923
						local item = candidate.evidence[j + 1] -- 924
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 924
							evidence[#evidence + 1] = item -- 925
						end -- 925
						j = j + 1 -- 923
					end -- 923
				end -- 923
			end -- 923
			::__continue159:: -- 923
			i = i + 1 -- 919
		end -- 919
	end -- 919
	local content = takeUtf8Head( -- 928
		table.concat(claims, "\n"), -- 928
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 928
	) -- 928
	if content == "" then -- 928
		return nil -- 929
	end -- 929
	return { -- 930
		sourceSessionId = record.sessionId, -- 931
		sourceTaskId = record.sourceTaskId, -- 932
		content = content, -- 933
		evidence = evidence, -- 934
		createdAt = record.finishedAt -- 935
	} -- 935
end -- 935
function containsNormalizedText(text, query) -- 939
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 940
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 941
	if normalizedQuery == "" then -- 941
		return true -- 942
	end -- 942
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 943
end -- 943
function getSubAgentDisplayKey(item) -- 946
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 952
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 953
	local label = goal ~= "" and goal or title -- 954
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 955
end -- 955
function writeSubAgentResultFile(session, record, resultText) -- 958
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 959
	if not Content:exist(dir) then -- 959
		ensureDirRecursive(dir) -- 961
	end -- 961
	local ____array_31 = __TS__SparseArrayNew( -- 961
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 964
		"- Status: " .. record.status, -- 965
		"- Success: " .. (record.success and "true" or "false"), -- 966
		"- Outcome: " .. record.completion.outcome, -- 967
		"- Session ID: " .. tostring(record.sessionId), -- 968
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 969
		"- Goal: " .. record.goal, -- 970
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 971
	) -- 971
	__TS__SparseArrayPush( -- 971
		____array_31, -- 971
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 972
	) -- 972
	__TS__SparseArrayPush( -- 972
		____array_31, -- 972
		"- Finished At: " .. record.finishedAt, -- 973
		"", -- 974
		"## Validation", -- 975
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 976
			record.completion.validation, -- 977
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 977
		) or ({"- Not reported"})) -- 977
	) -- 977
	__TS__SparseArrayPush(____array_31, "", "## Recorded Evidence") -- 977
	local ____opt_23 = record.handoffEvidence -- 977
	__TS__SparseArrayPush( -- 977
		____array_31, -- 977
		table.unpack(____opt_23 and #____opt_23.modifiedFiles and __TS__ArrayMap( -- 981
			record.handoffEvidence.modifiedFiles, -- 982
			function(____, item) return "- modified: " .. item end -- 982
		) or ({"- modified: none recorded"})) -- 982
	) -- 982
	local ____opt_25 = record.handoffEvidence -- 982
	__TS__SparseArrayPush( -- 982
		____array_31, -- 982
		table.unpack(____opt_25 and ____opt_25.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 984
	) -- 984
	local ____opt_27 = record.handoffEvidence -- 984
	__TS__SparseArrayPush( -- 984
		____array_31, -- 984
		table.unpack(__TS__ArrayMap( -- 987
			____opt_27 and ____opt_27.commands or ({}), -- 987
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 987
		)) -- 987
	) -- 987
	local ____opt_29 = record.handoffEvidence -- 987
	__TS__SparseArrayPush( -- 987
		____array_31, -- 987
		table.unpack(__TS__ArrayMap( -- 988
			____opt_29 and ____opt_29.authoritativeSources or ({}), -- 988
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 988
		)) -- 988
	) -- 988
	__TS__SparseArrayPush( -- 988
		____array_31, -- 988
		"", -- 989
		"## Known Issues", -- 990
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 991
			record.completion.knownIssues, -- 991
			function(____, item) return "- " .. item end -- 991
		) or ({"- None reported"})) -- 991
	) -- 991
	__TS__SparseArrayPush( -- 991
		____array_31, -- 991
		"", -- 992
		"## Assumptions", -- 993
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 994
			record.completion.assumptions, -- 994
			function(____, item) return "- " .. item end -- 994
		) or ({"- None reported"})) -- 994
	) -- 994
	__TS__SparseArrayPush(____array_31, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 994
	local lines = {__TS__SparseArraySpread(____array_31)} -- 963
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 999
	local content = table.concat(lines, "\n") .. "\n" -- 1000
	if not Content:save(path, content) then -- 1000
		return false -- 1002
	end -- 1002
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1004
	return true -- 1005
end -- 1005
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1008
	local dir = Path(projectRoot, ".agent", "subagents") -- 1009
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1009
		return {} -- 1010
	end -- 1010
	local items = {} -- 1011
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1012
		do -- 1012
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1013
			if not Content:exist(path) or not Content:isdir(path) then -- 1013
				goto __continue179 -- 1014
			end -- 1014
			local info = readSpawnInfo( -- 1015
				projectRoot, -- 1015
				Path( -- 1015
					"subagents", -- 1015
					Path:getFilename(path) -- 1015
				) -- 1015
			) -- 1015
			if not info then -- 1015
				goto __continue179 -- 1016
			end -- 1016
			local sessionId = tonumber(info.sessionId) -- 1017
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1018
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1019
			local status = sanitizeUTF8(toStr(info.status)) -- 1020
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1020
				goto __continue179 -- 1021
			end -- 1021
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1021
				goto __continue179 -- 1022
			end -- 1022
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1023
			items[#items + 1] = { -- 1024
				sessionId = sessionId, -- 1025
				rootSessionId = infoRootSessionId, -- 1026
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1027
				title = sanitizeUTF8(toStr(info.title)), -- 1028
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1029
				goal = sanitizeUTF8(toStr(info.goal)), -- 1030
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1031
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1032
					__TS__ArrayFilter( -- 1033
						info.filesHint, -- 1033
						function(____, item) return type(item) == "string" end -- 1033
					), -- 1033
					function(____, item) return sanitizeUTF8(item) end -- 1033
				) or ({}), -- 1033
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1035
				success = info.success == true, -- 1036
				cleared = info.cleared == true, -- 1037
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1038
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1039
					"subagents", -- 1039
					Path:getFilename(path) -- 1039
				)), -- 1039
				sourceTaskId = sourceTaskId or 0, -- 1040
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1041
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1042
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1043
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1044
				completion = normalizeAgentCompletionReport(info.completion), -- 1045
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1046
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1047
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1048
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1049
			} -- 1049
		end -- 1049
		::__continue179:: -- 1049
	end -- 1049
	__TS__ArraySort( -- 1052
		items, -- 1052
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1052
	) -- 1052
	return items -- 1053
end -- 1053
function getPendingHandoffDir(projectRoot, memoryScope) -- 1056
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1057
end -- 1057
function writePendingHandoff(projectRoot, memoryScope, value) -- 1060
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1061
	if not Content:exist(dir) then -- 1061
		ensureDirRecursive(dir) -- 1063
	end -- 1063
	local path = Path(dir, value.id .. ".json") -- 1065
	local text = safeJsonEncode(value) -- 1066
	if not text then -- 1066
		return false -- 1067
	end -- 1067
	return Content:save(path, text .. "\n") -- 1068
end -- 1068
function listPendingHandoffs(projectRoot, memoryScope) -- 1071
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1072
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1072
		return {} -- 1073
	end -- 1073
	local items = {} -- 1074
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1075
		do -- 1075
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1076
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1076
				goto __continue194 -- 1077
			end -- 1077
			local text = Content:load(path) -- 1078
			if not text or __TS__StringTrim(text) == "" then -- 1078
				goto __continue194 -- 1079
			end -- 1079
			local obj = safeJsonDecode(text) -- 1080
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1080
				goto __continue194 -- 1081
			end -- 1081
			local value = obj -- 1082
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1083
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1084
			local id = sanitizeUTF8(toStr(value.id)) -- 1085
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1086
			local message = sanitizeUTF8(toStr(value.message)) -- 1087
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1088
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1089
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1090
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1090
				goto __continue194 -- 1092
			end -- 1092
			items[#items + 1] = { -- 1094
				id = id, -- 1095
				sourceSessionId = sourceSessionId, -- 1096
				sourceTitle = sourceTitle, -- 1097
				sourceTaskId = sourceTaskId, -- 1098
				message = message, -- 1099
				prompt = prompt, -- 1100
				goal = goal, -- 1101
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1102
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1103
					__TS__ArrayFilter( -- 1104
						value.filesHint, -- 1104
						function(____, item) return type(item) == "string" end -- 1104
					), -- 1104
					function(____, item) return sanitizeUTF8(item) end -- 1104
				) or ({}), -- 1104
				success = value.success == true, -- 1106
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1107
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1108
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1109
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1110
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1111
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1112
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1113
				createdAt = createdAt -- 1116
			} -- 1116
		end -- 1116
		::__continue194:: -- 1116
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
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1171
		return session -- 1174
	end -- 1174
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1176
	if #pendingToolRows > 0 then -- 1176
		local t = now() -- 1182
		do -- 1182
			local i = 0 -- 1183
			while i < #pendingToolRows do -- 1183
				local row = pendingToolRows[i + 1] -- 1184
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1185
				result.success = false -- 1186
				result.state = "failed" -- 1187
				result.interrupted = true -- 1188
				result.message = "tool call was interrupted because the program exited before it completed." -- 1189
				DB:exec( -- 1190
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1190
					{ -- 1192
						encodeJson(result), -- 1192
						t, -- 1192
						row[1] -- 1192
					} -- 1192
				) -- 1192
				i = i + 1 -- 1183
			end -- 1183
		end -- 1183
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1195
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1196
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1197
	end -- 1197
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1204
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1205
	return __TS__ObjectAssign( -- 1206
		{}, -- 1206
		session, -- 1207
		{ -- 1206
			status = "STOPPED", -- 1208
			currentTaskStatus = "STOPPED", -- 1209
			updatedAt = now() -- 1210
		} -- 1210
	) -- 1210
end -- 1210
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1214
	DB:exec( -- 1215
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1215
		{ -- 1219
			status, -- 1220
			currentTaskId or 0, -- 1221
			currentTaskStatus or status, -- 1222
			now(), -- 1223
			sessionId -- 1224
		} -- 1224
	) -- 1224
end -- 1224
function mergeAgentMetrics(current, next) -- 1229
	return __TS__ObjectAssign({}, current or ({}), next) -- 1230
end -- 1230
function updateSessionMetrics(sessionId, metrics) -- 1236
	local session = getSessionItem(sessionId) -- 1237
	if not session then -- 1237
		return nil -- 1238
	end -- 1238
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1239
	DB:exec( -- 1240
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1240
		{ -- 1244
			encodeJson(merged), -- 1245
			now(), -- 1246
			sessionId -- 1247
		} -- 1247
	) -- 1247
	return merged -- 1250
end -- 1250
function clearSessionTokenUsage(sessionId) -- 1253
	local session = getSessionItem(sessionId) -- 1254
	if not session then -- 1254
		return nil -- 1255
	end -- 1255
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1256
	__TS__Delete(metrics, "usage") -- 1257
	DB:exec( -- 1258
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1258
		{ -- 1262
			encodeJson(metrics), -- 1263
			now(), -- 1264
			sessionId -- 1265
		} -- 1265
	) -- 1265
	return metrics -- 1268
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
	local ____rootSession_currentTaskId_32 -- 1581
	if rootSession.currentTaskId then -- 1581
		____rootSession_currentTaskId_32 = getTaskPrompt(rootSession.currentTaskId) -- 1581
	else -- 1581
		____rootSession_currentTaskId_32 = nil -- 1581
	end -- 1581
	local currentTaskPrompt = ____rootSession_currentTaskId_32 -- 1581
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
					handoffEvidence = item.handoffEvidence, -- 1621
					memoryEntry = item.memoryEntry, -- 1622
					completion = item.completion -- 1623
				}, -- 1623
				{ -- 1625
					sourceSessionId = item.sourceSessionId, -- 1626
					sourceTitle = item.sourceTitle, -- 1627
					sourceTaskId = item.sourceTaskId, -- 1628
					prompt = item.prompt, -- 1629
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1630
					expectedOutput = item.expectedOutput or "", -- 1631
					filesHint = item.filesHint or ({}), -- 1632
					resultFilePath = item.resultFilePath or "", -- 1633
					artifactDir = item.artifactDir or "", -- 1634
					changeSet = item.changeSet, -- 1635
					handoffEvidence = item.handoffEvidence, -- 1636
					memoryEntry = item.memoryEntry, -- 1637
					completion = item.completion -- 1638
				}, -- 1638
				"DONE" -- 1640
			) -- 1640
			if step then -- 1640
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1643
			end -- 1643
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1645
			i = i + 1 -- 1603
		end -- 1603
	end -- 1603
end -- 1603
function applyEvent(sessionId, event) -- 1657
	repeat -- 1657
		local ____switch274 = event.type -- 1657
		local metrics -- 1657
		local ____cond274 = ____switch274 == "task_started" -- 1657
		if ____cond274 then -- 1657
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1660
			metrics = clearSessionTokenUsage(sessionId) -- 1661
			emitAgentSessionPatch( -- 1662
				sessionId, -- 1662
				{ -- 1662
					session = getSessionItem(sessionId), -- 1663
					metrics = metrics -- 1664
				} -- 1664
			) -- 1664
			break -- 1666
		end -- 1666
		____cond274 = ____cond274 or ____switch274 == "decision_made" -- 1666
		if ____cond274 then -- 1666
			upsertStep( -- 1668
				sessionId, -- 1668
				event.taskId, -- 1668
				event.step, -- 1668
				event.tool, -- 1668
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.params} -- 1668
			) -- 1668
			emitAgentSessionPatch( -- 1674
				sessionId, -- 1674
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1674
			) -- 1674
			break -- 1677
		end -- 1677
		____cond274 = ____cond274 or ____switch274 == "tool_started" -- 1677
		if ____cond274 then -- 1677
			upsertStep( -- 1679
				sessionId, -- 1679
				event.taskId, -- 1679
				event.step, -- 1679
				event.tool, -- 1679
				{status = "RUNNING"} -- 1679
			) -- 1679
			emitAgentSessionPatch( -- 1682
				sessionId, -- 1682
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1682
			) -- 1682
			break -- 1685
		end -- 1685
		____cond274 = ____cond274 or ____switch274 == "tool_finished" -- 1685
		if ____cond274 then -- 1685
			upsertStep( -- 1687
				sessionId, -- 1687
				event.taskId, -- 1687
				event.step, -- 1687
				event.tool, -- 1687
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1687
			) -- 1687
			emitAgentSessionPatch( -- 1692
				sessionId, -- 1692
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1692
			) -- 1692
			break -- 1695
		end -- 1695
		____cond274 = ____cond274 or ____switch274 == "tool_progress" -- 1695
		if ____cond274 then -- 1695
			do -- 1695
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1698
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1698
					break -- 1700
				end -- 1700
			end -- 1700
			upsertStep( -- 1703
				sessionId, -- 1703
				event.taskId, -- 1703
				event.step, -- 1703
				event.tool, -- 1703
				{status = "RUNNING", result = event.result} -- 1703
			) -- 1703
			emitAgentSessionPatch( -- 1707
				sessionId, -- 1707
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1707
			) -- 1707
			break -- 1710
		end -- 1710
		____cond274 = ____cond274 or ____switch274 == "checkpoint_created" -- 1710
		if ____cond274 then -- 1710
			upsertStep( -- 1712
				sessionId, -- 1712
				event.taskId, -- 1712
				event.step, -- 1712
				event.tool, -- 1712
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1712
			) -- 1712
			emitAgentSessionPatch( -- 1717
				sessionId, -- 1717
				{ -- 1717
					step = getStepItem(sessionId, event.taskId, event.step), -- 1718
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1719
				} -- 1719
			) -- 1719
			break -- 1721
		end -- 1721
		____cond274 = ____cond274 or ____switch274 == "memory_compression_started" -- 1721
		if ____cond274 then -- 1721
			upsertStep( -- 1723
				sessionId, -- 1723
				event.taskId, -- 1723
				event.step, -- 1723
				event.tool, -- 1723
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1723
			) -- 1723
			emitAgentSessionPatch( -- 1728
				sessionId, -- 1728
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1728
			) -- 1728
			break -- 1731
		end -- 1731
		____cond274 = ____cond274 or ____switch274 == "memory_compression_finished" -- 1731
		if ____cond274 then -- 1731
			upsertStep( -- 1733
				sessionId, -- 1733
				event.taskId, -- 1733
				event.step, -- 1733
				event.tool, -- 1733
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1733
			) -- 1733
			emitAgentSessionPatch( -- 1738
				sessionId, -- 1738
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1738
			) -- 1738
			break -- 1741
		end -- 1741
		____cond274 = ____cond274 or ____switch274 == "metrics_updated" -- 1741
		if ____cond274 then -- 1741
			do -- 1741
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1743
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1744
				break -- 1747
			end -- 1747
		end -- 1747
		____cond274 = ____cond274 or ____switch274 == "assistant_message_updated" -- 1747
		if ____cond274 then -- 1747
			do -- 1747
				upsertStep( -- 1750
					sessionId, -- 1750
					event.taskId, -- 1750
					event.step, -- 1750
					"message", -- 1750
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1750
				) -- 1750
				emitAgentSessionPatch( -- 1755
					sessionId, -- 1755
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1755
				) -- 1755
				break -- 1758
			end -- 1758
		end -- 1758
		____cond274 = ____cond274 or ____switch274 == "task_finished" -- 1758
		if ____cond274 then -- 1758
			do -- 1758
				local session = getSessionItem(sessionId) -- 1761
				local ____opt_33 = activeStopTokens[event.taskId or -1] -- 1761
				local stopped = (____opt_33 and ____opt_33.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 1762
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1764
				local isSubSession = (session and session.kind) == "sub" -- 1767
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1768
				if isSubSession and event.taskId ~= nil then -- 1768
					finalizingSubSessionTaskIds[event.taskId] = true -- 1770
				end -- 1770
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1772
				if event.taskId ~= nil then -- 1772
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1774
					local ____finalizeTaskSteps_39 = finalizeTaskSteps -- 1775
					local ____array_38 = __TS__SparseArrayNew( -- 1775
						sessionId, -- 1776
						event.taskId, -- 1777
						type(event.steps) == "number" and math.max( -- 1778
							0, -- 1778
							math.floor(event.steps) -- 1778
						) or nil -- 1778
					) -- 1778
					local ____event_success_37 -- 1779
					if event.success then -- 1779
						____event_success_37 = nil -- 1779
					else -- 1779
						____event_success_37 = stopped and "STOPPED" or "FAILED" -- 1779
					end -- 1779
					__TS__SparseArrayPush(____array_38, ____event_success_37) -- 1779
					____finalizeTaskSteps_39(__TS__SparseArraySpread(____array_38)) -- 1775
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1781
					if not isSubSession then -- 1781
						__TS__Delete(activeStopTokens, event.taskId) -- 1783
					end -- 1783
					emitAgentSessionPatch( -- 1785
						sessionId, -- 1785
						{ -- 1785
							session = getSessionItem(sessionId), -- 1786
							message = getMessageItem(messageId), -- 1787
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1788
							removedStepIds = removedStepIds -- 1789
						} -- 1789
					) -- 1789
				end -- 1789
				if session and session.kind == "main" then -- 1789
					flushPendingSubAgentHandoffs(session) -- 1793
				end -- 1793
				break -- 1795
			end -- 1795
		end -- 1795
	until true -- 1795
end -- 1795
function ____exports.createSession(projectRoot, title) -- 1932
	if title == nil then -- 1932
		title = "" -- 1932
	end -- 1932
	if not isValidProjectRoot(projectRoot) then -- 1932
		return {success = false, message = "invalid projectRoot"} -- 1934
	end -- 1934
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1936
	if row then -- 1936
		return { -- 1945
			success = true, -- 1945
			session = rowToSession(row) -- 1945
		} -- 1945
	end -- 1945
	local t = now() -- 1947
	DB:exec( -- 1948
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 1948
		{ -- 1951
			projectRoot, -- 1951
			title ~= "" and title or Path:getFilename(projectRoot), -- 1951
			t, -- 1951
			t -- 1951
		} -- 1951
	) -- 1951
	local sessionId = getLastInsertRowId() -- 1953
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 1954
	local session = getSessionItem(sessionId) -- 1955
	if not session then -- 1955
		return {success = false, message = "failed to create session"} -- 1957
	end -- 1957
	return {success = true, session = session} -- 1959
end -- 1932
function ____exports.createSubSession(parentSessionId, title) -- 1962
	if title == nil then -- 1962
		title = "" -- 1962
	end -- 1962
	local parent = getSessionItem(parentSessionId) -- 1963
	if not parent then -- 1963
		return {success = false, message = "parent session not found"} -- 1965
	end -- 1965
	local rootId = getSessionRootId(parent) -- 1967
	local t = now() -- 1968
	DB:exec( -- 1969
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 1969
		{ -- 1972
			parent.projectRoot, -- 1972
			title ~= "" and title or "Sub " .. tostring(rootId), -- 1972
			rootId, -- 1972
			parent.id, -- 1972
			t, -- 1972
			t -- 1972
		} -- 1972
	) -- 1972
	local sessionId = getLastInsertRowId() -- 1974
	local memoryScope = "subagents/" .. tostring(sessionId) -- 1975
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 1976
	local session = getSessionItem(sessionId) -- 1977
	if not session then -- 1977
		return {success = false, message = "failed to create sub session"} -- 1979
	end -- 1979
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 1981
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 1982
	subStorage:writeMemory(parentStorage:readMemory()) -- 1983
	return {success = true, session = session} -- 1984
end -- 1962
function spawnSubAgentSession(request) -- 1987
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1987
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 1999
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2000
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2001
		if normalizedPrompt == "" then -- 2001
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2003
		end -- 2003
		if normalizedPrompt == "" then -- 2003
			local ____Log_45 = Log -- 2010
			local ____temp_42 = #normalizedTitle -- 2010
			local ____temp_43 = #rawPrompt -- 2010
			local ____temp_44 = #toStr(request.expectedOutput) -- 2010
			local ____opt_40 = request.filesHint -- 2010
			____Log_45( -- 2010
				"Warn", -- 2010
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_42)) .. " raw_prompt_len=") .. tostring(____temp_43)) .. " expected_len=") .. tostring(____temp_44)) .. " files_hint_count=") .. tostring(____opt_40 and #____opt_40 or 0) -- 2010
			) -- 2010
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2010
		end -- 2010
		Log( -- 2013
			"Info", -- 2013
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2013
		) -- 2013
		local parentSessionId = request.parentSessionId -- 2014
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2014
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2016
			if not fallbackParent then -- 2016
				local createdMain = ____exports.createSession(request.projectRoot) -- 2018
				if createdMain.success then -- 2018
					fallbackParent = createdMain.session -- 2020
				end -- 2020
			end -- 2020
			if fallbackParent then -- 2020
				Log( -- 2024
					"Warn", -- 2024
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2024
				) -- 2024
				parentSessionId = fallbackParent.id -- 2025
			end -- 2025
		end -- 2025
		local parentSession = getSessionItem(parentSessionId) -- 2028
		if not parentSession then -- 2028
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2028
		end -- 2028
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2032
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2032
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2032
		end -- 2032
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2036
		if not created.success then -- 2036
			return ____awaiter_resolve(nil, created) -- 2036
		end -- 2036
		writeSpawnInfo( -- 2040
			created.session.projectRoot, -- 2040
			created.session.memoryScope, -- 2040
			{ -- 2040
				sessionId = created.session.id, -- 2041
				rootSessionId = created.session.rootSessionId, -- 2042
				parentSessionId = created.session.parentSessionId, -- 2043
				title = created.session.title, -- 2044
				prompt = normalizedPrompt, -- 2045
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2046
				expectedOutput = request.expectedOutput or "", -- 2047
				filesHint = request.filesHint or ({}), -- 2048
				status = "RUNNING", -- 2049
				success = false, -- 2050
				resultFilePath = "", -- 2051
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2052
				sourceTaskId = 0, -- 2053
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2054
				createdAtTs = created.session.createdAt, -- 2055
				finishedAt = "", -- 2056
				finishedAtTs = 0 -- 2057
			} -- 2057
		) -- 2057
		local sent = ____exports.sendPrompt(created.session.id, normalizedPrompt, true, request.disabledAgentTools) -- 2059
		if not sent.success then -- 2059
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2059
		end -- 2059
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2059
	end) -- 2059
end -- 2059
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2140
	local rootSession = getRootSessionItem(session.id) -- 2141
	if not rootSession then -- 2141
		return -- 2142
	end -- 2142
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2143
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2144
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2145
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2146
	local queueResult = writePendingHandoff( -- 2147
		rootSession.projectRoot, -- 2147
		rootSession.memoryScope, -- 2147
		{ -- 2147
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2148
			sourceSessionId = session.id, -- 2149
			sourceTitle = session.title, -- 2150
			sourceTaskId = taskId, -- 2151
			message = summary, -- 2152
			prompt = result.prompt, -- 2153
			goal = result.goal, -- 2154
			expectedOutput = result.expectedOutput or "", -- 2155
			filesHint = result.filesHint or ({}), -- 2156
			success = result.success, -- 2157
			resultFilePath = result.resultFilePath, -- 2158
			artifactDir = result.artifactDir, -- 2159
			finishedAt = result.finishedAt, -- 2160
			changeSet = changeSet, -- 2161
			handoffEvidence = result.handoffEvidence, -- 2162
			memoryEntry = result.memoryEntry, -- 2163
			completion = result.completion, -- 2164
			createdAt = createdAt -- 2165
		} -- 2165
	) -- 2165
	if not queueResult then -- 2165
		Log( -- 2168
			"Warn", -- 2168
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2168
		) -- 2168
		return -- 2169
	end -- 2169
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2169
		flushPendingSubAgentHandoffs(rootSession) -- 2172
	end -- 2172
end -- 2172
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2176
	if forceHandoff == nil then -- 2176
		forceHandoff = false -- 2182
	end -- 2182
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2182
		local rootSessionId = getSessionRootId(session) -- 2184
		local rootSession = getRootSessionItem(session.id) -- 2185
		if not rootSession then -- 2185
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2185
		end -- 2185
		local spawnInfo = getSessionSpawnInfo(session) -- 2189
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2190
		local finishedAtTs = now() -- 2191
		local resultText = sanitizeUTF8(message) -- 2192
		local changeSet = getTaskChangeSetSummary(taskId) -- 2193
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2194
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2195
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2199
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2199
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2201
		end -- 2201
		local completed = success and completionReport.outcome == "completed" -- 2209
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2210
		local record = { -- 2213
			sessionId = session.id, -- 2214
			rootSessionId = rootSessionId, -- 2215
			parentSessionId = session.parentSessionId, -- 2216
			title = session.title, -- 2217
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2218
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2219
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2220
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2221
			status = recordStatus, -- 2222
			success = completed, -- 2223
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2224
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2225
			sourceTaskId = taskId, -- 2226
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2227
			finishedAt = finishedAt, -- 2228
			createdAtTs = session.createdAt, -- 2229
			finishedAtTs = finishedAtTs, -- 2230
			changeSet = changeSet, -- 2231
			handoffEvidence = handoffEvidence, -- 2232
			completion = completionReport -- 2233
		} -- 2233
		local ____record_success_58 -- 2235
		if record.success then -- 2235
			____record_success_58 = buildStructuredSubAgentMemoryEntry(record) -- 2235
		else -- 2235
			____record_success_58 = nil -- 2235
		end -- 2235
		record.memoryEntry = ____record_success_58 -- 2235
		if not writeSubAgentResultFile(session, record, resultText) then -- 2235
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2235
		end -- 2235
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2235
			sessionId = record.sessionId, -- 2240
			rootSessionId = record.rootSessionId, -- 2241
			parentSessionId = record.parentSessionId, -- 2242
			title = record.title, -- 2243
			prompt = record.prompt, -- 2244
			goal = record.goal, -- 2245
			expectedOutput = record.expectedOutput or "", -- 2246
			filesHint = record.filesHint or ({}), -- 2247
			status = record.status, -- 2248
			success = record.success, -- 2249
			resultFilePath = record.resultFilePath, -- 2250
			artifactDir = record.artifactDir, -- 2251
			sourceTaskId = record.sourceTaskId, -- 2252
			createdAt = record.createdAt, -- 2253
			finishedAt = record.finishedAt, -- 2254
			createdAtTs = record.createdAtTs, -- 2255
			finishedAtTs = record.finishedAtTs, -- 2256
			changeSet = record.changeSet, -- 2257
			handoffEvidence = record.handoffEvidence, -- 2258
			memoryEntry = record.memoryEntry, -- 2259
			memoryEntryError = record.memoryEntryError, -- 2260
			completion = record.completion -- 2261
		}) then -- 2261
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2261
		end -- 2261
		if success or forceHandoff then -- 2261
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2266
			deleteSessionRecords(session.id, true) -- 2267
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2268
		end -- 2268
		return ____awaiter_resolve(nil, {success = true}) -- 2268
	end) -- 2268
end -- 2268
function stopClearedSubSession(session, taskId) -- 2273
	local spawnInfo = getSessionSpawnInfo(session) -- 2274
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2275
	local rootSessionId = getSessionRootId(session) -- 2276
	Tools.setTaskStatus(taskId, "STOPPED") -- 2277
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2278
	if not writeSpawnInfo( -- 2278
		session.projectRoot, -- 2279
		session.memoryScope, -- 2279
		{ -- 2279
			sessionId = session.id, -- 2280
			rootSessionId = rootSessionId, -- 2281
			parentSessionId = session.parentSessionId, -- 2282
			title = session.title, -- 2283
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2284
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2285
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2286
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2287
			status = "STOPPED", -- 2288
			success = false, -- 2289
			cleared = true, -- 2290
			resultFilePath = "", -- 2291
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2292
			sourceTaskId = taskId, -- 2293
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2294
			finishedAt = finishedAt, -- 2295
			createdAtTs = session.createdAt, -- 2296
			finishedAtTs = now() -- 2297
		} -- 2297
	) then -- 2297
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2299
	end -- 2299
	deleteSessionRecords(session.id, true) -- 2301
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2302
	return {success = true} -- 2303
end -- 2303
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools) -- 2306
	if allowSubSessionStart == nil then -- 2306
		allowSubSessionStart = false -- 2306
	end -- 2306
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
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2317
	if normalizedPrompt == "" and session.kind == "sub" then -- 2317
		local spawnInfo = getSessionSpawnInfo(session) -- 2319
		if spawnInfo then -- 2319
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2321
			if normalizedPrompt == "" then -- 2321
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2323
			end -- 2323
		end -- 2323
	end -- 2323
	if normalizedPrompt == "" then -- 2323
		return {success = false, message = "prompt is empty"} -- 2332
	end -- 2332
	return startPromptTask( -- 2334
		session, -- 2334
		normalizedPrompt, -- 2334
		nil, -- 2334
		normalizeDisabledAgentTools(disabledAgentTools) -- 2334
	) -- 2334
end -- 2306
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2342
	if disabledAgentTools == nil then -- 2342
		disabledAgentTools = {} -- 2346
	end -- 2346
	local taskRes = Tools.createTask(normalizedPrompt) -- 2349
	if not taskRes.success then -- 2349
		return {success = false, message = taskRes.message} -- 2351
	end -- 2351
	local taskId = taskRes.taskId -- 2353
	local useChineseResponse = getDefaultUseChineseResponse() -- 2354
	if existingUserMessageId ~= nil then -- 2354
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2356
	else -- 2356
		insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2358
	end -- 2358
	local stopToken = {stopped = false} -- 2360
	activeStopTokens[taskId] = stopToken -- 2361
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2362
	runCodingAgent( -- 2363
		{ -- 2363
			prompt = normalizedPrompt, -- 2364
			workDir = session.projectRoot, -- 2365
			useChineseResponse = useChineseResponse, -- 2366
			taskId = taskId, -- 2367
			sessionId = session.id, -- 2368
			memoryScope = session.memoryScope, -- 2369
			role = session.kind, -- 2370
			maxSteps = options and options.maxSteps, -- 2371
			disabledAgentTools = disabledAgentTools, -- 2372
			spawnSubAgent = session.kind == "main" and spawnSubAgentSession or nil, -- 2373
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2376
			stopToken = stopToken, -- 2379
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2380
		}, -- 2380
		function(result) -- 2381
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2381
				local nextSession = getSessionItem(session.id) -- 2382
				if nextSession and nextSession.kind == "sub" then -- 2382
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2382
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2385
						if not stopped.success then -- 2385
							Log( -- 2387
								"Warn", -- 2387
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2387
							) -- 2387
							emitAgentSessionPatch( -- 2388
								session.id, -- 2388
								{session = getSessionItem(session.id)} -- 2388
							) -- 2388
						end -- 2388
						__TS__Delete(activeStopTokens, taskId) -- 2392
						return ____awaiter_resolve(nil) -- 2392
					end -- 2392
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2395
					emitAgentSessionPatch( -- 2396
						session.id, -- 2396
						{session = getSessionItem(session.id)} -- 2396
					) -- 2396
					local finalized = __TS__Await(finalizeSubSession( -- 2399
						nextSession, -- 2400
						taskId, -- 2401
						result.success, -- 2402
						result.message, -- 2403
						result.completion, -- 2404
						(options and options.forceSubAgentHandoff) == true -- 2405
					)) -- 2405
					if not finalized.success then -- 2405
						Log( -- 2408
							"Warn", -- 2408
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2408
						) -- 2408
					end -- 2408
					local finalizedSession = getSessionItem(session.id) -- 2410
					if finalizedSession then -- 2410
						local stopped = stopToken.stopped == true -- 2412
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2413
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2416
						emitAgentSessionPatch( -- 2417
							session.id, -- 2417
							{session = getSessionItem(session.id)} -- 2417
						) -- 2417
					end -- 2417
					__TS__Delete(activeStopTokens, taskId) -- 2421
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2422
				end -- 2422
				if not result.success and (not nextSession or nextSession.kind ~= "sub") then -- 2422
					applyEvent(session.id, { -- 2425
						type = "task_finished", -- 2426
						sessionId = session.id, -- 2427
						taskId = result.taskId, -- 2428
						success = false, -- 2429
						message = result.message, -- 2430
						steps = result.steps -- 2431
					}) -- 2431
				end -- 2431
			end) -- 2431
		end -- 2381
	) -- 2381
	return {success = true, sessionId = session.id, taskId = taskId} -- 2435
end -- 2435
function ____exports.listRunningSubAgents(request) -- 2560
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2560
		local session = getSessionItem(request.sessionId) -- 2568
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2568
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2570
		end -- 2570
		if not session then -- 2570
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2570
		end -- 2570
		local rootSession = getRootSessionItem(session.id) -- 2575
		if not rootSession then -- 2575
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2575
		end -- 2575
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2579
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2580
		local limit = math.max( -- 2581
			1, -- 2581
			math.floor(tonumber(request.limit) or 5) -- 2581
		) -- 2581
		local offset = math.max( -- 2582
			0, -- 2582
			math.floor(tonumber(request.offset) or 0) -- 2582
		) -- 2582
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2583
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2584
		local runningSessions = {} -- 2591
		do -- 2591
			local i = 0 -- 2592
			while i < #rows do -- 2592
				do -- 2592
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2593
					if current.currentTaskStatus ~= "RUNNING" then -- 2593
						goto __continue390 -- 2595
					end -- 2595
					local spawnInfo = getSessionSpawnInfo(current) -- 2597
					runningSessions[#runningSessions + 1] = { -- 2598
						sessionId = current.id, -- 2599
						title = current.title, -- 2600
						parentSessionId = current.parentSessionId, -- 2601
						rootSessionId = current.rootSessionId, -- 2602
						status = "RUNNING", -- 2603
						currentTaskId = current.currentTaskId, -- 2604
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2605
						goal = spawnInfo and spawnInfo.goal, -- 2606
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2607
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2608
						createdAt = current.createdAt, -- 2609
						updatedAt = current.updatedAt -- 2610
					} -- 2610
				end -- 2610
				::__continue390:: -- 2610
				i = i + 1 -- 2592
			end -- 2592
		end -- 2592
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2613
		local completedSessions = __TS__ArrayMap( -- 2614
			completedRecords, -- 2614
			function(____, record) return { -- 2614
				sessionId = record.sessionId, -- 2615
				title = record.title, -- 2616
				parentSessionId = record.parentSessionId, -- 2617
				rootSessionId = record.rootSessionId, -- 2618
				status = record.status, -- 2619
				goal = record.goal, -- 2620
				expectedOutput = record.expectedOutput, -- 2621
				filesHint = record.filesHint, -- 2622
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2623
				success = record.success, -- 2624
				cleared = record.cleared, -- 2625
				resultFilePath = record.resultFilePath, -- 2626
				artifactDir = record.artifactDir, -- 2627
				finishedAt = record.finishedAt, -- 2628
				createdAt = record.createdAtTs, -- 2629
				updatedAt = record.finishedAtTs -- 2630
			} end -- 2630
		) -- 2630
		local merged = {} -- 2632
		if status == "running" then -- 2632
			merged = runningSessions -- 2634
		elseif status == "done" then -- 2634
			merged = __TS__ArrayFilter( -- 2636
				completedSessions, -- 2636
				function(____, item) return item.status == "DONE" end -- 2636
			) -- 2636
		elseif status == "failed" then -- 2636
			merged = __TS__ArrayFilter( -- 2638
				completedSessions, -- 2638
				function(____, item) return item.status == "FAILED" end -- 2638
			) -- 2638
		elseif status == "stopped" then -- 2638
			merged = __TS__ArrayFilter( -- 2640
				completedSessions, -- 2640
				function(____, item) return item.status == "STOPPED" end -- 2640
			) -- 2640
		elseif status == "all" then -- 2640
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 2642
		else -- 2642
			local runningKeys = {} -- 2644
			do -- 2644
				local i = 0 -- 2645
				while i < #runningSessions do -- 2645
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 2646
					i = i + 1 -- 2645
				end -- 2645
			end -- 2645
			local latestCompletedByKey = {} -- 2648
			do -- 2648
				local i = 0 -- 2649
				while i < #completedSessions do -- 2649
					do -- 2649
						local item = completedSessions[i + 1] -- 2650
						local key = getSubAgentDisplayKey(item) -- 2651
						if runningKeys[key] then -- 2651
							goto __continue405 -- 2653
						end -- 2653
						local current = latestCompletedByKey[key] -- 2655
						if not current or item.updatedAt > current.updatedAt then -- 2655
							latestCompletedByKey[key] = item -- 2657
						end -- 2657
					end -- 2657
					::__continue405:: -- 2657
					i = i + 1 -- 2649
				end -- 2649
			end -- 2649
			local latestCompleted = {} -- 2660
			for ____, item in pairs(latestCompletedByKey) do -- 2661
				latestCompleted[#latestCompleted + 1] = item -- 2662
			end -- 2662
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 2664
		end -- 2664
		if query ~= "" then -- 2664
			merged = __TS__ArrayFilter( -- 2667
				merged, -- 2667
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 2667
			) -- 2667
		end -- 2667
		__TS__ArraySort( -- 2673
			merged, -- 2673
			function(____, a, b) -- 2673
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 2673
					return -1 -- 2674
				end -- 2674
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 2674
					return 1 -- 2675
				end -- 2675
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 2675
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2677
				end -- 2677
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 2679
			end -- 2673
		) -- 2673
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 2681
		return ____awaiter_resolve(nil, { -- 2681
			success = true, -- 2683
			rootSessionId = rootSession.id, -- 2684
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 2685
			status = status, -- 2686
			limit = limit, -- 2687
			offset = offset, -- 2688
			hasMore = offset + limit < #merged, -- 2689
			sessions = paged -- 2690
		}) -- 2690
	end) -- 2690
end -- 2560
TABLE_SESSION = "AgentSession" -- 237
TABLE_MESSAGE = "AgentSessionMessage" -- 238
TABLE_STEP = "AgentSessionStep" -- 239
TABLE_TASK = "AgentTask" -- 240
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 241
SPAWN_INFO_FILE = "SPAWN.json" -- 242
RESULT_FILE = "RESULT.md" -- 243
PENDING_HANDOFF_DIR = "pending-handoffs" -- 244
MAX_CONCURRENT_SUB_AGENTS = 4 -- 245
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 246
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 247
activeStopTokens = {} -- 297
finalizingSubSessionTaskIds = {} -- 298
now = function() return os.time() end -- 299
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 819
	if projectRoot == oldRoot then -- 819
		return newRoot -- 821
	end -- 821
	for ____, separator in ipairs({"/", "\\"}) do -- 823
		local prefix = oldRoot .. separator -- 824
		if __TS__StringStartsWith(projectRoot, prefix) then -- 824
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 826
		end -- 826
	end -- 826
	return nil -- 829
end -- 819
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
local function getSchemaVersion() -- 1800
	local row = queryOne("PRAGMA user_version") -- 1801
	return row and type(row[1]) == "number" and row[1] or 0 -- 1802
end -- 1800
local function setSchemaVersion(version) -- 1805
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1806
		0, -- 1806
		math.floor(version) -- 1806
	))) -- 1806
end -- 1805
local function hasTableColumn(tableName, columnName) -- 1809
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1810
	do -- 1810
		local i = 0 -- 1811
		while i < #rows do -- 1811
			local row = rows[i + 1] -- 1812
			if toStr(row[2]) == columnName then -- 1812
				return true -- 1814
			end -- 1814
			i = i + 1 -- 1811
		end -- 1811
	end -- 1811
	return false -- 1817
end -- 1809
local function ensureSessionMetricsColumn() -- 1820
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1820
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1822
	end -- 1822
end -- 1820
local function recreateSchema() -- 1826
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 1827
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 1828
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 1829
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1830
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1845
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1846
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1855
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1856
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1873
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1874
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 1875
end -- 1826
do -- 1826
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 1826
		recreateSchema() -- 1881
	else -- 1881
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT ''\n\t\t);") -- 1883
		ensureSessionMetricsColumn() -- 1898
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 1899
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1900
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 1909
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 1910
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1927
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 1928
	end -- 1928
end -- 1928
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2071
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2071
		return {success = false, message = "invalid projectRoot"} -- 2073
	end -- 2073
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2075
	for ____, row in ipairs(rows) do -- 2076
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2077
		if sessionId > 0 then -- 2077
			deleteSessionRecords(sessionId) -- 2079
		end -- 2079
	end -- 2079
	return {success = true, deleted = #rows} -- 2082
end -- 2071
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2085
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2085
		return {success = false, message = "invalid projectRoot"} -- 2087
	end -- 2087
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2089
	local renamed = 0 -- 2090
	for ____, row in ipairs(rows) do -- 2091
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2092
		local projectRoot = toStr(row[2]) -- 2093
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2094
		if sessionId > 0 and nextProjectRoot then -- 2094
			DB:exec( -- 2096
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2096
				{ -- 2098
					nextProjectRoot, -- 2098
					Path:getFilename(nextProjectRoot), -- 2098
					now(), -- 2098
					sessionId -- 2098
				} -- 2098
			) -- 2098
			renamed = renamed + 1 -- 2100
		end -- 2100
	end -- 2100
	return {success = true, renamed = renamed} -- 2103
end -- 2085
function ____exports.getSession(sessionId) -- 2106
	local session = getSessionItem(sessionId) -- 2107
	if not session then -- 2107
		return {success = false, message = "session not found"} -- 2109
	end -- 2109
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2111
	local relatedSessions = listRelatedSessions(sessionId) -- 2112
	sanitizeStoredSteps(sessionId) -- 2113
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2114
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2121
	local ____relatedSessions_47 = relatedSessions -- 2132
	local ____temp_46 -- 2133
	if normalizedSession.kind == "sub" then -- 2133
		____temp_46 = getSessionSpawnInfo(normalizedSession) -- 2133
	else -- 2133
		____temp_46 = nil -- 2133
	end -- 2133
	return { -- 2129
		success = true, -- 2130
		session = normalizedSession, -- 2131
		relatedSessions = ____relatedSessions_47, -- 2132
		spawnInfo = ____temp_46, -- 2133
		messages = __TS__ArrayMap( -- 2134
			messages, -- 2134
			function(____, row) return rowToMessage(row) end -- 2134
		), -- 2134
		steps = __TS__ArrayMap( -- 2135
			steps, -- 2135
			function(____, row) return rowToStep(row) end -- 2135
		), -- 2135
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}) -- 2136
	} -- 2136
end -- 2106
function ____exports.finishSubSessionHandoff(sessionId) -- 2438
	local session = getSessionItem(sessionId) -- 2439
	if not session then -- 2439
		return {success = false, message = "session not found"} -- 2441
	end -- 2441
	if session.kind ~= "sub" then -- 2441
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2444
	end -- 2444
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2444
		return {success = false, message = "session task is finalizing"} -- 2447
	end -- 2447
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2449
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2449
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2454
	end -- 2454
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2454
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2457
	end -- 2457
	local disabledAgentTools = __TS__ArrayFilter( -- 2459
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2459
		function(____, tool) return tool ~= "finish" end -- 2460
	) -- 2460
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2461
	return startPromptTask( -- 2464
		session, -- 2464
		prompt, -- 2464
		nil, -- 2464
		disabledAgentTools, -- 2464
		{maxSteps = 1, forceSubAgentHandoff = true} -- 2464
	) -- 2464
end -- 2438
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools) -- 2470
	local session = getSessionItem(sessionId) -- 2471
	if not session then -- 2471
		return {success = false, message = "session not found"} -- 2473
	end -- 2473
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2473
		return {success = false, message = "session task is finalizing"} -- 2476
	end -- 2476
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2476
		return {success = false, message = "session task is still running"} -- 2479
	end -- 2479
	local message = getMessageItem(messageId) -- 2481
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2481
		return {success = false, message = "message not found"} -- 2483
	end -- 2483
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2485
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2491
	if latestUserMessageId ~= messageId then -- 2491
		return {success = false, message = "only the latest user prompt can be edited"} -- 2493
	end -- 2493
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2495
	if normalizedPrompt == "" then -- 2495
		return {success = false, message = "prompt is empty"} -- 2497
	end -- 2497
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2499
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2500
	local result = startPromptTask( -- 2501
		session, -- 2501
		normalizedPrompt, -- 2501
		messageId, -- 2501
		normalizeDisabledAgentTools(disabledAgentTools) -- 2501
	) -- 2501
	if result.success and #removedStepIds > 0 then -- 2501
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2503
	end -- 2503
	return result -- 2505
end -- 2470
function ____exports.stopSessionTask(sessionId) -- 2508
	local session = getSessionItem(sessionId) -- 2509
	if not session or session.currentTaskId == nil then -- 2509
		return {success = false, message = "session task not found"} -- 2511
	end -- 2511
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2511
		return {success = false, message = "session task is finalizing"} -- 2514
	end -- 2514
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2516
	local stopToken = activeStopTokens[session.currentTaskId] -- 2517
	if not stopToken then -- 2517
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2517
			return {success = true, recovered = true} -- 2520
		end -- 2520
		return {success = false, message = "task is not running"} -- 2522
	end -- 2522
	stopToken.stopped = true -- 2524
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2525
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 2529
	finalizeTaskSteps(session.id, session.currentTaskId, nil, "STOPPED") -- 2530
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2531
	return {success = true} -- 2532
end -- 2508
function ____exports.getCurrentTaskId(sessionId) -- 2535
	local ____opt_73 = getSessionItem(sessionId) -- 2535
	return ____opt_73 and ____opt_73.currentTaskId -- 2536
end -- 2535
function ____exports.listRunningSessions() -- 2539
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2540
	local sessions = {} -- 2547
	do -- 2547
		local i = 0 -- 2548
		while i < #rows do -- 2548
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2549
			if session.currentTaskStatus == "RUNNING" then -- 2549
				sessions[#sessions + 1] = session -- 2551
			end -- 2551
			i = i + 1 -- 2548
		end -- 2548
	end -- 2548
	return {success = true, sessions = sessions} -- 2554
end -- 2539
return ____exports -- 2539