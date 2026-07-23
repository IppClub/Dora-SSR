-- [ts]: AgentSession.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeStoppedTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
local AgentToolRegistry = require("Agent.AgentToolRegistry") -- 5
local AgentRuntimePolicy = require("Agent.AgentRuntimePolicy") -- 6
local Tools = require("Agent.Tools") -- 7
local ____Memory = require("Agent.Memory") -- 8
local DualLayerStorage = ____Memory.DualLayerStorage -- 8
local ____Utils = require("Agent.Utils") -- 9
local Log = ____Utils.Log -- 9
local getLLMConfig = ____Utils.getLLMConfig -- 9
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 9
local safeJsonDecode = ____Utils.safeJsonDecode -- 9
local safeJsonEncode = ____Utils.safeJsonEncode -- 9
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 9
local ____AgentQuestionnaire = require("Agent.AgentQuestionnaire") -- 13
local validateQuestionnaireAnswers = ____AgentQuestionnaire.validateQuestionnaireAnswers -- 13
function getDefaultUseChineseResponse() -- 321
	local zh = string.match(App.locale, "^zh") -- 322
	return zh ~= nil -- 323
end -- 323
function toStr(v) -- 326
	if v == false or v == nil then -- 326
		return "" -- 327
	end -- 327
	return tostring(v) -- 328
end -- 328
function encodeJson(value) -- 331
	local text = safeJsonEncode(value) -- 332
	return text or "" -- 333
end -- 333
function decodeJsonObject(text) -- 336
	if not text or text == "" then -- 336
		return nil -- 337
	end -- 337
	local value = safeJsonDecode(text) -- 338
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 338
		return value -- 340
	end -- 340
	return nil -- 342
end -- 342
function decodeJsonFiles(text) -- 345
	if not text or text == "" then -- 345
		return nil -- 346
	end -- 346
	local value = safeJsonDecode(text) -- 347
	if not value or not __TS__ArrayIsArray(value) then -- 347
		return nil -- 348
	end -- 348
	local files = {} -- 349
	do -- 349
		local i = 0 -- 350
		while i < #value do -- 350
			do -- 350
				local item = value[i + 1] -- 351
				if type(item) ~= "table" then -- 351
					goto __continue14 -- 352
				end -- 352
				files[#files + 1] = { -- 353
					path = sanitizeUTF8(toStr(item.path)), -- 354
					op = sanitizeUTF8(toStr(item.op)) -- 355
				} -- 355
			end -- 355
			::__continue14:: -- 355
			i = i + 1 -- 350
		end -- 350
	end -- 350
	return files -- 358
end -- 358
function decodeChangeSetSummary(value) -- 361
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 361
		return nil -- 362
	end -- 362
	local row = value -- 363
	if row.success ~= true then -- 363
		return nil -- 364
	end -- 364
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 365
	if taskId <= 0 then -- 365
		return nil -- 366
	end -- 366
	local files = {} -- 367
	if __TS__ArrayIsArray(row.files) then -- 367
		do -- 367
			local i = 0 -- 369
			while i < #row.files do -- 369
				do -- 369
					local file = row.files[i + 1] -- 370
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 370
						goto __continue22 -- 371
					end -- 371
					local fileRow = file -- 372
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 373
					if path == "" then -- 373
						goto __continue22 -- 374
					end -- 374
					local checkpointIds = {} -- 375
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 375
						do -- 375
							local j = 0 -- 377
							while j < #fileRow.checkpointIds do -- 377
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 378
								if checkpointId > 0 then -- 378
									checkpointIds[#checkpointIds + 1] = checkpointId -- 379
								end -- 379
								j = j + 1 -- 377
							end -- 377
						end -- 377
					end -- 377
					local op = toStr(fileRow.op) -- 382
					files[#files + 1] = { -- 383
						path = path, -- 384
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 385
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 386
						checkpointIds = checkpointIds -- 387
					} -- 387
				end -- 387
				::__continue22:: -- 387
				i = i + 1 -- 369
			end -- 369
		end -- 369
	end -- 369
	return { -- 391
		success = true, -- 392
		taskId = taskId, -- 393
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 394
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 395
		files = files, -- 396
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 397
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 398
	} -- 398
end -- 398
function decodeHandoffEvidence(value) -- 402
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 402
		return nil -- 403
	end -- 403
	local row = value -- 404
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 405
		__TS__ArrayFilter( -- 406
			row.modifiedFiles, -- 406
			function(____, item) return type(item) == "string" end -- 406
		), -- 406
		function(____, item) return sanitizeUTF8(item) end -- 406
	) or ({}) -- 406
	local lastBuild = nil -- 408
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 408
		local build = row.lastBuild -- 410
		lastBuild = { -- 411
			result = build.result == "passed" and "passed" or "failed", -- 412
			path = sanitizeUTF8(toStr(build.path)), -- 413
			evidence = takeUtf8Head( -- 414
				sanitizeUTF8(toStr(build.evidence)), -- 414
				600 -- 414
			) -- 414
		} -- 414
	end -- 414
	local commands = {} -- 417
	if __TS__ArrayIsArray(row.commands) then -- 417
		do -- 417
			local i = 0 -- 419
			while i < #row.commands and #commands < 8 do -- 419
				do -- 419
					local raw = row.commands[i + 1] -- 420
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 420
						goto __continue36 -- 421
					end -- 421
					local item = raw -- 422
					commands[#commands + 1] = { -- 423
						mode = sanitizeUTF8(toStr(item.mode)), -- 424
						command = takeUtf8Head( -- 425
							sanitizeUTF8(toStr(item.command)), -- 425
							600 -- 425
						), -- 425
						result = item.result == "passed" and "passed" or "failed", -- 426
						evidence = takeUtf8Head( -- 427
							sanitizeUTF8(toStr(item.evidence)), -- 427
							600 -- 427
						) -- 427
					} -- 427
				end -- 427
				::__continue36:: -- 427
				i = i + 1 -- 419
			end -- 419
		end -- 419
	end -- 419
	local authoritativeSources = {} -- 431
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 431
		do -- 431
			local i = 0 -- 433
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 433
				do -- 433
					local raw = row.authoritativeSources[i + 1] -- 434
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 434
						goto __continue40 -- 435
					end -- 435
					local item = raw -- 436
					authoritativeSources[#authoritativeSources + 1] = { -- 437
						tool = "search_dora_api", -- 438
						query = takeUtf8Head( -- 439
							sanitizeUTF8(toStr(item.query)), -- 439
							300 -- 439
						), -- 439
						source = sanitizeUTF8(toStr(item.source)), -- 440
						result = item.result == "passed" and "passed" or "failed" -- 441
					} -- 441
				end -- 441
				::__continue40:: -- 441
				i = i + 1 -- 433
			end -- 433
		end -- 433
	end -- 433
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 445
end -- 445
function takeUtf8Head(text, maxChars) -- 448
	if maxChars <= 0 or text == "" then -- 448
		return "" -- 449
	end -- 449
	local nextPos = utf8.offset(text, maxChars + 1) -- 450
	if nextPos == nil then -- 450
		return text -- 451
	end -- 451
	return string.sub(text, 1, nextPos - 1) -- 452
end -- 452
function normalizeMemoryEntryEvidence(value) -- 455
	local evidence = {} -- 456
	if not __TS__ArrayIsArray(value) then -- 456
		return evidence -- 457
	end -- 457
	do -- 457
		local i = 0 -- 458
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 458
			do -- 458
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 459
				if item == "" then -- 459
					goto __continue48 -- 460
				end -- 460
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 460
					evidence[#evidence + 1] = item -- 462
				end -- 462
			end -- 462
			::__continue48:: -- 462
			i = i + 1 -- 458
		end -- 458
	end -- 458
	return evidence -- 465
end -- 465
function decodeSubAgentMemoryEntry(value) -- 468
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 468
		return nil -- 469
	end -- 469
	local row = value -- 470
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 471
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 472
	local content = takeUtf8Head( -- 473
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 473
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 473
	) -- 473
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 473
		return nil -- 474
	end -- 474
	return { -- 475
		sourceSessionId = sourceSessionId, -- 476
		sourceTaskId = sourceTaskId, -- 477
		content = content, -- 478
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 479
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 480
	} -- 480
end -- 480
function getTaskChangeSetSummary(taskId) -- 484
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 485
	return summary.success and summary or nil -- 486
end -- 486
function queryRows(sql, args) -- 489
	local ____args_0 -- 490
	if args then -- 490
		____args_0 = DB:query(sql, args) -- 490
	else -- 490
		____args_0 = DB:query(sql) -- 490
	end -- 490
	return ____args_0 -- 490
end -- 490
function queryOne(sql, args) -- 493
	local rows = queryRows(sql, args) -- 494
	if not rows or #rows == 0 then -- 494
		return nil -- 495
	end -- 495
	return rows[1] -- 496
end -- 496
function summarizeHandoffResult(result) -- 499
	local candidates = {result.output, result.message, result.state, result.phase} -- 500
	do -- 500
		local i = 0 -- 501
		while i < #candidates do -- 501
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 502
			if text ~= "" then -- 502
				return takeUtf8Head(text, 600) -- 503
			end -- 503
			i = i + 1 -- 501
		end -- 501
	end -- 501
	local messages = result.messages -- 505
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 505
		local parts = {} -- 507
		do -- 507
			local i = 0 -- 508
			while i < #messages and #parts < 4 do -- 508
				do -- 508
					local row = messages[i + 1] -- 509
					if not row or type(row) ~= "table" then -- 509
						goto __continue64 -- 510
					end -- 510
					local item = row -- 511
					local ____sanitizeUTF8_4 = sanitizeUTF8 -- 512
					local ____toStr_3 = toStr -- 512
					local ____item_message_1 = item.message -- 512
					if ____item_message_1 == nil then -- 512
						____item_message_1 = item.error -- 512
					end -- 512
					local ____item_message_1_2 = ____item_message_1 -- 512
					if ____item_message_1_2 == nil then -- 512
						____item_message_1_2 = item.file -- 512
					end -- 512
					local text = __TS__StringTrim(____sanitizeUTF8_4(____toStr_3(____item_message_1_2))) -- 512
					if text ~= "" then -- 512
						parts[#parts + 1] = text -- 513
					end -- 513
				end -- 513
				::__continue64:: -- 513
				i = i + 1 -- 508
			end -- 508
		end -- 508
		if #parts > 0 then -- 508
			return takeUtf8Head( -- 515
				table.concat(parts, "; "), -- 515
				600 -- 515
			) -- 515
		end -- 515
	end -- 515
	return result.success == true and "tool result success=true" or "tool result success=false" -- 517
end -- 517
function getTaskHandoffEvidence(taskId, changeSet) -- 520
	local ____opt_5 = changeSet -- 520
	local evidence = { -- 521
		modifiedFiles = ____opt_5 and __TS__ArrayMap( -- 522
			changeSet and changeSet.files, -- 522
			function(____, item) return item.path end -- 522
		) or ({}), -- 522
		commands = {}, -- 523
		authoritativeSources = {} -- 524
	} -- 524
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_api"}) or ({}) -- 526
	do -- 526
		local i = 0 -- 531
		while i < #rows do -- 531
			local tool = toStr(rows[i + 1][1]) -- 532
			local status = toStr(rows[i + 1][2]) -- 533
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 534
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 535
			local passed = status == "DONE" and result.success == true -- 536
			if tool == "build" then -- 536
				evidence.lastBuild = { -- 538
					result = passed and "passed" or "failed", -- 539
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 540
					evidence = summarizeHandoffResult(result) -- 541
				} -- 541
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 541
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 544
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 545
				local ____evidence_commands_9 = evidence.commands -- 545
				____evidence_commands_9[#____evidence_commands_9 + 1] = { -- 546
					mode = mode, -- 547
					command = takeUtf8Head( -- 548
						__TS__StringTrim(sanitizeUTF8(command)), -- 548
						600 -- 548
					), -- 548
					result = passed and "passed" or "failed", -- 549
					evidence = summarizeHandoffResult(result) -- 550
				} -- 550
			elseif tool == "search_dora_api" and #evidence.authoritativeSources < 8 then -- 550
				local ____evidence_authoritativeSources_10 = evidence.authoritativeSources -- 550
				____evidence_authoritativeSources_10[#____evidence_authoritativeSources_10 + 1] = { -- 553
					tool = "search_dora_api", -- 554
					query = takeUtf8Head( -- 555
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 555
						300 -- 555
					), -- 555
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docSource or "api"))), -- 556
					result = passed and "passed" or "failed" -- 557
				} -- 557
			end -- 557
			i = i + 1 -- 531
		end -- 531
	end -- 531
	return evidence -- 561
end -- 561
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 564
	local lastBuild = evidence.lastBuild -- 568
	if not lastBuild or lastBuild.result ~= "failed" then -- 568
		return completion -- 569
	end -- 569
	local validation = __TS__ArraySlice(completion.validation) -- 570
	local foundBuild = false -- 571
	do -- 571
		local i = 0 -- 572
		while i < #validation do -- 572
			do -- 572
				if validation[i + 1].kind ~= "build" then -- 572
					goto __continue78 -- 573
				end -- 573
				foundBuild = true -- 574
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 575
			end -- 575
			::__continue78:: -- 575
			i = i + 1 -- 572
		end -- 572
	end -- 572
	if not foundBuild then -- 572
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 582
	end -- 582
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 584
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 585
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 585
		knownIssues[#knownIssues + 1] = issue -- 586
	end -- 586
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 587
end -- 587
function getLastInsertRowId() -- 595
	local row = queryOne("SELECT last_insert_rowid()") -- 596
	return row and (row[1] or 0) or 0 -- 597
end -- 597
function isValidProjectRoot(path) -- 600
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 601
end -- 601
function rowToSession(row) -- 604
	return { -- 605
		id = row[1], -- 606
		projectRoot = toStr(row[2]), -- 607
		title = toStr(row[3]), -- 608
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 609
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 610
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 611
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 612
		status = toStr(row[8]), -- 613
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 614
		currentTaskStatus = toStr(row[10]), -- 615
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 616
		createdAt = row[11], -- 617
		updatedAt = row[12], -- 618
		metrics = decodeJsonObject(toStr(row[13])), -- 619
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 620
	} -- 620
end -- 620
function rowToMessage(row) -- 624
	local message = { -- 625
		id = row[1], -- 626
		sessionId = row[2], -- 627
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 628
		role = toStr(row[4]), -- 629
		content = toStr(row[5]), -- 630
		createdAt = row[7], -- 631
		updatedAt = row[8] -- 632
	} -- 632
	local displayContent = toStr(row[6]) -- 634
	if displayContent ~= "" then -- 634
		message.displayContent = displayContent -- 635
	end -- 635
	return message -- 636
end -- 636
function rowToStep(row) -- 639
	return { -- 640
		id = row[1], -- 641
		sessionId = row[2], -- 642
		taskId = row[3], -- 643
		step = row[4], -- 644
		tool = toStr(row[5]), -- 645
		status = toStr(row[6]), -- 646
		reason = toStr(row[7]), -- 647
		reasoningContent = toStr(row[8]), -- 648
		params = decodeJsonObject(toStr(row[9])), -- 649
		result = decodeJsonObject(toStr(row[10])), -- 650
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 651
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 652
		files = decodeJsonFiles(toStr(row[13])), -- 653
		createdAt = row[14], -- 654
		updatedAt = row[15] -- 655
	} -- 655
end -- 655
function getQuestionnairePath(projectRoot) -- 659
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 660
end -- 660
function decodeQuestionnaireFile(text) -- 663
	local value = decodeJsonObject(text) -- 664
	if not value then -- 664
		return nil -- 665
	end -- 665
	local schema = value.schema -- 666
	local id = type(value.id) == "number" and value.id or 0 -- 667
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 668
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 669
	local step = type(value.step) == "number" and value.step or 0 -- 670
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 671
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 671
		return nil -- 673
	end -- 673
	return { -- 675
		id = id, -- 675
		sessionId = sessionId, -- 675
		taskId = taskId, -- 675
		step = step, -- 675
		status = "PENDING", -- 675
		schema = schema, -- 675
		createdAt = createdAt -- 675
	} -- 675
end -- 675
function getPendingQuestionnaire(sessionId) -- 678
	local session = getSessionItem(sessionId) -- 679
	if not session or session.kind ~= "main" then -- 679
		return nil -- 680
	end -- 680
	local path = getQuestionnairePath(session.projectRoot) -- 681
	if not Content:exist(path) then -- 681
		return nil -- 682
	end -- 682
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 683
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 684
end -- 684
function restorePendingQuestionnaireState(session) -- 687
	local questionnaire = getPendingQuestionnaire(session.id) -- 688
	if not questionnaire then -- 688
		return {session = session} -- 689
	end -- 689
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 689
		local t = now() -- 696
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 697
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 703
		local restored = getSessionItem(session.id) -- 704
		if restored then -- 704
			session = restored -- 705
		end -- 705
	end -- 705
	return {session = session, questionnaire = questionnaire} -- 707
end -- 707
function savePendingQuestionnaire(projectRoot, questionnaire) -- 710
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 711
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 711
		return false -- 712
	end -- 712
	local path = getQuestionnairePath(projectRoot) -- 713
	local tempPath = path .. ".tmp" -- 714
	Content:remove(tempPath) -- 715
	if not Content:save( -- 715
		tempPath, -- 716
		encodeJson(questionnaire) -- 716
	) then -- 716
		return false -- 716
	end -- 716
	if Content:exist(path) then -- 716
		Content:remove(path) -- 717
	end -- 717
	if Content:move(tempPath, path) then -- 717
		return true -- 718
	end -- 718
	Content:remove(tempPath) -- 719
	return false -- 720
end -- 720
function removePendingQuestionnaire(session) -- 723
	local path = getQuestionnairePath(session.projectRoot) -- 724
	if not Content:exist(path) then -- 724
		return true -- 725
	end -- 725
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 726
	if questionnaire and questionnaire.sessionId ~= session.id then -- 726
		return false -- 727
	end -- 727
	return Content:remove(path) -- 728
end -- 728
function publishQuestionnaire(request) -- 731
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 731
		local session = getSessionItem(request.sessionId) -- 737
		if not session or session.kind ~= "main" then -- 737
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 737
		end -- 737
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 739
		if Content:exist(pendingPath) then -- 739
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 739
		end -- 739
		local questionnaire = { -- 741
			id = request.taskId, -- 742
			sessionId = request.sessionId, -- 743
			taskId = request.taskId, -- 744
			step = request.step, -- 745
			status = "PENDING", -- 746
			schema = request.schema, -- 747
			createdAt = now() -- 748
		} -- 748
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 748
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 748
		end -- 748
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 748
	end) -- 748
end -- 748
function getMessageItem(messageId) -- 756
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 757
	return row and rowToMessage(row) or nil -- 763
end -- 763
function getStepItem(sessionId, taskId, step) -- 766
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 767
	return row and rowToStep(row) or nil -- 773
end -- 773
function deleteMessageSteps(sessionId, taskId) -- 776
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 777
	local ids = {} -- 782
	do -- 782
		local i = 0 -- 783
		while i < #rows do -- 783
			local row = rows[i + 1] -- 784
			if type(row[1]) == "number" then -- 784
				ids[#ids + 1] = row[1] -- 786
			end -- 786
			i = i + 1 -- 783
		end -- 783
	end -- 783
	if #ids > 0 then -- 783
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 790
	end -- 790
	return ids -- 796
end -- 796
function normalizeDisabledAgentTools(value) -- 799
	if not __TS__ArrayIsArray(value) then -- 799
		return {} -- 800
	end -- 800
	local tools = {} -- 801
	do -- 801
		local i = 0 -- 802
		while i < #value do -- 802
			do -- 802
				local name = value[i + 1] -- 803
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 803
					goto __continue121 -- 804
				end -- 804
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 804
					tools[#tools + 1] = name -- 805
				end -- 805
			end -- 805
			::__continue121:: -- 805
			i = i + 1 -- 802
		end -- 802
	end -- 802
	return tools -- 807
end -- 807
function normalizeWorkMode(value, fallback) -- 810
	if fallback == nil then -- 810
		fallback = "code" -- 810
	end -- 810
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 811
end -- 811
function getSessionRow(sessionId) -- 814
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 815
end -- 815
function getSessionItem(sessionId) -- 823
	local row = getSessionRow(sessionId) -- 824
	return row and rowToSession(row) or nil -- 825
end -- 825
function getTaskPrompt(taskId) -- 828
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 829
	if not row or type(row[1]) ~= "string" then -- 829
		return nil -- 830
	end -- 830
	return toStr(row[1]) -- 831
end -- 831
function getLatestMainSessionByProjectRoot(projectRoot) -- 834
	if not isValidProjectRoot(projectRoot) then -- 834
		return nil -- 835
	end -- 835
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 836
	return row and rowToSession(row) or nil -- 844
end -- 844
function countRunningSubSessions(rootSessionId) -- 847
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 848
	local count = 0 -- 855
	do -- 855
		local i = 0 -- 856
		while i < #rows do -- 856
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 857
			if session.currentTaskStatus == "RUNNING" then -- 857
				count = count + 1 -- 859
			end -- 859
			i = i + 1 -- 856
		end -- 856
	end -- 856
	return count -- 862
end -- 862
function deleteSessionRecords(sessionId, preserveArtifacts) -- 865
	if preserveArtifacts == nil then -- 865
		preserveArtifacts = false -- 865
	end -- 865
	local session = getSessionItem(sessionId) -- 866
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 867
	do -- 867
		local i = 0 -- 868
		while i < #children do -- 868
			local row = children[i + 1] -- 869
			if type(row[1]) == "number" and row[1] > 0 then -- 869
				deleteSessionRecords(row[1], preserveArtifacts) -- 871
			end -- 871
			i = i + 1 -- 868
		end -- 868
	end -- 868
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 874
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 875
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 876
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 877
	if session and session.kind == "main" then -- 877
		removePendingQuestionnaire(session) -- 879
	end -- 879
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 879
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 882
	end -- 882
end -- 882
function getSessionRootId(session) -- 886
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 887
end -- 887
function getRootSessionItem(sessionId) -- 890
	local session = getSessionItem(sessionId) -- 891
	if not session then -- 891
		return nil -- 892
	end -- 892
	return getSessionItem(getSessionRootId(session)) or session -- 893
end -- 893
function listRelatedSessions(sessionId) -- 896
	local root = getRootSessionItem(sessionId) -- 897
	if not root then -- 897
		return {} -- 898
	end -- 898
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 899
	return __TS__ArrayMap( -- 908
		rows, -- 908
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 908
	) -- 908
end -- 908
function getSessionSpawnInfo(session) -- 911
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 912
	if not info then -- 912
		return nil -- 913
	end -- 913
	local ____temp_16 = type(info.sessionId) == "number" and info.sessionId or nil -- 915
	local ____temp_17 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 916
	local ____temp_18 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 917
	local ____temp_19 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 918
	local ____temp_20 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 919
	local ____temp_21 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 920
	local ____temp_22 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 921
	local ____temp_23 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 922
		__TS__ArrayFilter( -- 923
			info.filesHint, -- 923
			function(____, item) return type(item) == "string" end -- 923
		), -- 923
		function(____, item) return sanitizeUTF8(item) end -- 923
	) or nil -- 923
	local ____temp_24 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 925
	local ____temp_14 -- 928
	if info.success == true then -- 928
		____temp_14 = true -- 928
	else -- 928
		local ____temp_13 -- 928
		if info.success == false then -- 928
			____temp_13 = false -- 928
		else -- 928
			____temp_13 = nil -- 928
		end -- 928
		____temp_14 = ____temp_13 -- 928
	end -- 928
	local ____temp_15 -- 929
	if info.cleared == true then -- 929
		____temp_15 = true -- 929
	else -- 929
		____temp_15 = nil -- 929
	end -- 929
	return { -- 914
		sessionId = ____temp_16, -- 915
		rootSessionId = ____temp_17, -- 916
		parentSessionId = ____temp_18, -- 917
		title = ____temp_19, -- 918
		prompt = ____temp_20, -- 919
		goal = ____temp_21, -- 920
		expectedOutput = ____temp_22, -- 921
		filesHint = ____temp_23, -- 922
		status = ____temp_24, -- 925
		success = ____temp_14, -- 928
		cleared = ____temp_15, -- 929
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 930
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 931
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 932
		changeSet = decodeChangeSetSummary(info.changeSet), -- 933
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 934
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 935
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 936
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 937
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 940
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 941
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 942
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 943
	} -- 943
end -- 943
function ensureDirRecursive(dir) -- 960
	if not dir or dir == "" then -- 960
		return false -- 961
	end -- 961
	if Content:exist(dir) then -- 961
		return Content:isdir(dir) -- 962
	end -- 962
	local parent = Path:getPath(dir) -- 963
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 963
		if not ensureDirRecursive(parent) then -- 963
			return false -- 966
		end -- 966
	end -- 966
	return Content:mkdir(dir) -- 969
end -- 969
function writeSpawnInfo(projectRoot, memoryScope, value) -- 972
	local dir = Path(projectRoot, ".agent", memoryScope) -- 973
	if not Content:exist(dir) then -- 973
		ensureDirRecursive(dir) -- 975
	end -- 975
	local path = Path(dir, SPAWN_INFO_FILE) -- 977
	local text = safeJsonEncode(value) -- 978
	if not text then -- 978
		return false -- 979
	end -- 979
	local content = text .. "\n" -- 980
	if not Content:save(path, content) then -- 980
		return false -- 982
	end -- 982
	Tools.sendWebIDEFileUpdate(path, true, content) -- 984
	return true -- 985
end -- 985
function readSpawnInfo(projectRoot, memoryScope) -- 988
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 989
	if not Content:exist(path) then -- 989
		return nil -- 990
	end -- 990
	local text = Content:load(path) -- 991
	if not text or __TS__StringTrim(text) == "" then -- 991
		return nil -- 992
	end -- 992
	local value = safeJsonDecode(text) -- 993
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 993
		return value -- 995
	end -- 995
	return nil -- 997
end -- 997
function getArtifactRelativeDir(memoryScope) -- 1000
	return Path(".agent", memoryScope) -- 1001
end -- 1001
function getArtifactDir(projectRoot, memoryScope) -- 1004
	return Path( -- 1005
		projectRoot, -- 1005
		getArtifactRelativeDir(memoryScope) -- 1005
	) -- 1005
end -- 1005
function getResultRelativePath(memoryScope) -- 1008
	return Path( -- 1009
		getArtifactRelativeDir(memoryScope), -- 1009
		RESULT_FILE -- 1009
	) -- 1009
end -- 1009
function getResultPath(projectRoot, memoryScope) -- 1012
	return Path( -- 1013
		projectRoot, -- 1013
		getResultRelativePath(memoryScope) -- 1013
	) -- 1013
end -- 1013
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1016
	if not resultFilePath or resultFilePath == "" then -- 1016
		return "" -- 1017
	end -- 1017
	local path = Path(projectRoot, resultFilePath) -- 1018
	if not Content:exist(path) then -- 1018
		return "" -- 1019
	end -- 1019
	local text = sanitizeUTF8(Content:load(path)) -- 1020
	if not text or __TS__StringTrim(text) == "" then -- 1020
		return "" -- 1021
	end -- 1021
	local marker = "\n## Summary\n" -- 1022
	local start = string.find(text, marker, 1, true) -- 1023
	if start ~= nil then -- 1023
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1025
	end -- 1025
	return __TS__StringTrim(text) -- 1027
end -- 1027
function buildStructuredSubAgentMemoryEntry(record) -- 1030
	local hasPassedValidation = false -- 1031
	do -- 1031
		local i = 0 -- 1032
		while i < #record.completion.validation do -- 1032
			local result = record.completion.validation[i + 1].result -- 1033
			if result == "failed" then -- 1033
				return nil -- 1038
			end -- 1038
			if result == "passed" then -- 1038
				hasPassedValidation = true -- 1040
			end -- 1040
			i = i + 1 -- 1032
		end -- 1032
	end -- 1032
	if not hasPassedValidation then -- 1032
		return nil -- 1043
	end -- 1043
	local candidates = record.completion.learningCandidates -- 1044
	local claims = {} -- 1045
	local evidence = {} -- 1046
	do -- 1046
		local i = 0 -- 1047
		while i < #candidates do -- 1047
			do -- 1047
				local candidate = candidates[i + 1] -- 1048
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1048
					goto __continue185 -- 1049
				end -- 1049
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1050
				do -- 1050
					local j = 0 -- 1051
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1051
						local item = candidate.evidence[j + 1] -- 1052
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1052
							evidence[#evidence + 1] = item -- 1053
						end -- 1053
						j = j + 1 -- 1051
					end -- 1051
				end -- 1051
			end -- 1051
			::__continue185:: -- 1051
			i = i + 1 -- 1047
		end -- 1047
	end -- 1047
	local content = takeUtf8Head( -- 1056
		table.concat(claims, "\n"), -- 1056
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1056
	) -- 1056
	if content == "" then -- 1056
		return nil -- 1057
	end -- 1057
	return { -- 1058
		sourceSessionId = record.sessionId, -- 1059
		sourceTaskId = record.sourceTaskId, -- 1060
		content = content, -- 1061
		evidence = evidence, -- 1062
		createdAt = record.finishedAt -- 1063
	} -- 1063
end -- 1063
function containsNormalizedText(text, query) -- 1067
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1068
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1069
	if normalizedQuery == "" then -- 1069
		return true -- 1070
	end -- 1070
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1071
end -- 1071
function getSubAgentDisplayKey(item) -- 1074
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1080
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1081
	local label = goal ~= "" and goal or title -- 1082
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1083
end -- 1083
function writeSubAgentResultFile(session, record, resultText) -- 1086
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1087
	if not Content:exist(dir) then -- 1087
		ensureDirRecursive(dir) -- 1089
	end -- 1089
	local ____array_33 = __TS__SparseArrayNew( -- 1089
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1092
		"- Status: " .. record.status, -- 1093
		"- Success: " .. (record.success and "true" or "false"), -- 1094
		"- Outcome: " .. record.completion.outcome, -- 1095
		"- Session ID: " .. tostring(record.sessionId), -- 1096
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1097
		"- Goal: " .. record.goal, -- 1098
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1099
	) -- 1099
	__TS__SparseArrayPush( -- 1099
		____array_33, -- 1099
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1100
	) -- 1100
	__TS__SparseArrayPush( -- 1100
		____array_33, -- 1100
		"- Finished At: " .. record.finishedAt, -- 1101
		"", -- 1102
		"## Validation", -- 1103
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1104
			record.completion.validation, -- 1105
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1105
		) or ({"- Not reported"})) -- 1105
	) -- 1105
	__TS__SparseArrayPush(____array_33, "", "## Recorded Evidence") -- 1105
	local ____opt_25 = record.handoffEvidence -- 1105
	__TS__SparseArrayPush( -- 1105
		____array_33, -- 1105
		table.unpack(____opt_25 and #____opt_25.modifiedFiles and __TS__ArrayMap( -- 1109
			record.handoffEvidence.modifiedFiles, -- 1110
			function(____, item) return "- modified: " .. item end -- 1110
		) or ({"- modified: none recorded"})) -- 1110
	) -- 1110
	local ____opt_27 = record.handoffEvidence -- 1110
	__TS__SparseArrayPush( -- 1110
		____array_33, -- 1110
		table.unpack(____opt_27 and ____opt_27.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1112
	) -- 1112
	local ____opt_29 = record.handoffEvidence -- 1112
	__TS__SparseArrayPush( -- 1112
		____array_33, -- 1112
		table.unpack(__TS__ArrayMap( -- 1115
			____opt_29 and ____opt_29.commands or ({}), -- 1115
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1115
		)) -- 1115
	) -- 1115
	local ____opt_31 = record.handoffEvidence -- 1115
	__TS__SparseArrayPush( -- 1115
		____array_33, -- 1115
		table.unpack(__TS__ArrayMap( -- 1116
			____opt_31 and ____opt_31.authoritativeSources or ({}), -- 1116
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1116
		)) -- 1116
	) -- 1116
	__TS__SparseArrayPush( -- 1116
		____array_33, -- 1116
		"", -- 1117
		"## Known Issues", -- 1118
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1119
			record.completion.knownIssues, -- 1119
			function(____, item) return "- " .. item end -- 1119
		) or ({"- None reported"})) -- 1119
	) -- 1119
	__TS__SparseArrayPush( -- 1119
		____array_33, -- 1119
		"", -- 1120
		"## Assumptions", -- 1121
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1122
			record.completion.assumptions, -- 1122
			function(____, item) return "- " .. item end -- 1122
		) or ({"- None reported"})) -- 1122
	) -- 1122
	__TS__SparseArrayPush(____array_33, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1122
	local lines = {__TS__SparseArraySpread(____array_33)} -- 1091
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1127
	local content = table.concat(lines, "\n") .. "\n" -- 1128
	if not Content:save(path, content) then -- 1128
		return false -- 1130
	end -- 1130
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1132
	return true -- 1133
end -- 1133
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1136
	local dir = Path(projectRoot, ".agent", "subagents") -- 1137
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1137
		return {} -- 1138
	end -- 1138
	local items = {} -- 1139
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1140
		do -- 1140
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1141
			if not Content:exist(path) or not Content:isdir(path) then -- 1141
				goto __continue205 -- 1142
			end -- 1142
			local info = readSpawnInfo( -- 1143
				projectRoot, -- 1143
				Path( -- 1143
					"subagents", -- 1143
					Path:getFilename(path) -- 1143
				) -- 1143
			) -- 1143
			if not info then -- 1143
				goto __continue205 -- 1144
			end -- 1144
			local sessionId = tonumber(info.sessionId) -- 1145
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1146
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1147
			local status = sanitizeUTF8(toStr(info.status)) -- 1148
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1148
				goto __continue205 -- 1149
			end -- 1149
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1149
				goto __continue205 -- 1150
			end -- 1150
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1151
			items[#items + 1] = { -- 1152
				sessionId = sessionId, -- 1153
				rootSessionId = infoRootSessionId, -- 1154
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1155
				title = sanitizeUTF8(toStr(info.title)), -- 1156
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1157
				goal = sanitizeUTF8(toStr(info.goal)), -- 1158
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1159
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1160
					__TS__ArrayFilter( -- 1161
						info.filesHint, -- 1161
						function(____, item) return type(item) == "string" end -- 1161
					), -- 1161
					function(____, item) return sanitizeUTF8(item) end -- 1161
				) or ({}), -- 1161
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1163
				success = info.success == true, -- 1164
				cleared = info.cleared == true, -- 1165
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1166
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1167
					"subagents", -- 1167
					Path:getFilename(path) -- 1167
				)), -- 1167
				sourceTaskId = sourceTaskId or 0, -- 1168
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1169
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1170
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1171
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1172
				completion = normalizeAgentCompletionReport(info.completion), -- 1173
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1174
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1175
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1176
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1177
			} -- 1177
		end -- 1177
		::__continue205:: -- 1177
	end -- 1177
	__TS__ArraySort( -- 1180
		items, -- 1180
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1180
	) -- 1180
	return items -- 1181
end -- 1181
function getPendingHandoffDir(projectRoot, memoryScope) -- 1184
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1185
end -- 1185
function writePendingHandoff(projectRoot, memoryScope, value) -- 1188
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1189
	if not Content:exist(dir) then -- 1189
		ensureDirRecursive(dir) -- 1191
	end -- 1191
	local path = Path(dir, value.id .. ".json") -- 1193
	local text = safeJsonEncode(value) -- 1194
	if not text then -- 1194
		return false -- 1195
	end -- 1195
	return Content:save(path, text .. "\n") -- 1196
end -- 1196
function listPendingHandoffs(projectRoot, memoryScope) -- 1199
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1200
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1200
		return {} -- 1201
	end -- 1201
	local items = {} -- 1202
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1203
		do -- 1203
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1204
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1204
				goto __continue220 -- 1205
			end -- 1205
			local text = Content:load(path) -- 1206
			if not text or __TS__StringTrim(text) == "" then -- 1206
				goto __continue220 -- 1207
			end -- 1207
			local obj = safeJsonDecode(text) -- 1208
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1208
				goto __continue220 -- 1209
			end -- 1209
			local value = obj -- 1210
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1211
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1212
			local id = sanitizeUTF8(toStr(value.id)) -- 1213
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1214
			local message = sanitizeUTF8(toStr(value.message)) -- 1215
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1216
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1217
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1218
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1218
				goto __continue220 -- 1220
			end -- 1220
			items[#items + 1] = { -- 1222
				id = id, -- 1223
				sourceSessionId = sourceSessionId, -- 1224
				sourceTitle = sourceTitle, -- 1225
				sourceTaskId = sourceTaskId, -- 1226
				message = message, -- 1227
				prompt = prompt, -- 1228
				goal = goal, -- 1229
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1230
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1231
					__TS__ArrayFilter( -- 1232
						value.filesHint, -- 1232
						function(____, item) return type(item) == "string" end -- 1232
					), -- 1232
					function(____, item) return sanitizeUTF8(item) end -- 1232
				) or ({}), -- 1232
				success = value.success == true, -- 1234
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1235
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1236
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1237
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1238
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1239
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1240
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1241
				createdAt = createdAt -- 1244
			} -- 1244
		end -- 1244
		::__continue220:: -- 1244
	end -- 1244
	__TS__ArraySort( -- 1247
		items, -- 1247
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1247
	) -- 1247
	return items -- 1248
end -- 1248
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1251
	local path = Path( -- 1252
		getPendingHandoffDir(projectRoot, memoryScope), -- 1252
		id .. ".json" -- 1252
	) -- 1252
	if Content:exist(path) then -- 1252
		Content:remove(path) -- 1254
	end -- 1254
end -- 1254
function normalizePromptText(prompt) -- 1258
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1259
end -- 1259
function normalizePromptTextSafe(prompt) -- 1262
	if type(prompt) == "string" then -- 1262
		local normalized = normalizePromptText(prompt) -- 1264
		if normalized ~= "" then -- 1264
			return normalized -- 1265
		end -- 1265
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1266
		if sanitized ~= "" then -- 1266
			return truncateAgentUserPrompt(sanitized) -- 1268
		end -- 1268
		return "" -- 1270
	end -- 1270
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1272
	if text == "" then -- 1272
		return "" -- 1273
	end -- 1273
	return truncateAgentUserPrompt(text) -- 1274
end -- 1274
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1277
	local sections = {} -- 1278
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1279
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1280
	local normalizedFiles = __TS__ArrayFilter( -- 1281
		__TS__ArrayMap( -- 1281
			__TS__ArrayFilter( -- 1281
				filesHint or ({}), -- 1281
				function(____, item) return type(item) == "string" end -- 1282
			), -- 1282
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1283
		), -- 1283
		function(____, item) return item ~= "" end -- 1284
	) -- 1284
	if normalizedTitle ~= "" then -- 1284
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1286
	end -- 1286
	if normalizedExpected ~= "" then -- 1286
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1289
	end -- 1289
	if #normalizedFiles > 0 then -- 1289
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1292
	end -- 1292
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1294
end -- 1294
function normalizeSessionRuntimeState(session) -- 1297
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1297
		return session -- 1299
	end -- 1299
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1299
		return session -- 1302
	end -- 1302
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1304
	if #pendingToolRows > 0 then -- 1304
		local t = now() -- 1310
		do -- 1310
			local i = 0 -- 1311
			while i < #pendingToolRows do -- 1311
				local row = pendingToolRows[i + 1] -- 1312
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1313
				result.success = false -- 1314
				result.state = "failed" -- 1315
				result.interrupted = true -- 1316
				result.message = "tool call was interrupted because the program exited before it completed." -- 1317
				DB:exec( -- 1318
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1318
					{ -- 1320
						encodeJson(result), -- 1320
						t, -- 1320
						row[1] -- 1320
					} -- 1320
				) -- 1320
				i = i + 1 -- 1311
			end -- 1311
		end -- 1311
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1323
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1324
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1325
	end -- 1325
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1332
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1333
	return __TS__ObjectAssign( -- 1334
		{}, -- 1334
		session, -- 1335
		{ -- 1334
			status = "STOPPED", -- 1336
			currentTaskStatus = "STOPPED", -- 1337
			updatedAt = now() -- 1338
		} -- 1338
	) -- 1338
end -- 1338
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1342
	DB:exec( -- 1343
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1343
		{ -- 1347
			status, -- 1348
			currentTaskId or 0, -- 1349
			currentTaskStatus or status, -- 1350
			now(), -- 1351
			sessionId -- 1352
		} -- 1352
	) -- 1352
end -- 1352
function mergeAgentMetrics(current, next) -- 1357
	return __TS__ObjectAssign({}, current or ({}), next) -- 1358
end -- 1358
function updateSessionMetrics(sessionId, metrics) -- 1364
	local session = getSessionItem(sessionId) -- 1365
	if not session then -- 1365
		return nil -- 1366
	end -- 1366
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1367
	DB:exec( -- 1368
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1368
		{ -- 1372
			encodeJson(merged), -- 1373
			now(), -- 1374
			sessionId -- 1375
		} -- 1375
	) -- 1375
	return merged -- 1378
end -- 1378
function clearSessionTokenUsage(sessionId) -- 1381
	local session = getSessionItem(sessionId) -- 1382
	if not session then -- 1382
		return nil -- 1383
	end -- 1383
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1384
	__TS__Delete(metrics, "usage") -- 1385
	DB:exec( -- 1386
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1386
		{ -- 1390
			encodeJson(metrics), -- 1391
			now(), -- 1392
			sessionId -- 1393
		} -- 1393
	) -- 1393
	return metrics -- 1396
end -- 1396
function getInitialTokenUsage(session) -- 1399
	local ____opt_34 = session.metrics -- 1399
	local usage = ____opt_34 and ____opt_34.usage -- 1400
	if not usage or (usage.requestCount or 0) <= 0 then -- 1400
		return nil -- 1401
	end -- 1401
	return { -- 1402
		inputTokens = usage.inputTokens or 0, -- 1403
		outputTokens = usage.outputTokens or 0, -- 1404
		totalTokens = usage.totalTokens, -- 1405
		cachedInputTokens = usage.cachedInputTokens, -- 1406
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1407
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1408
		requestCount = usage.requestCount or 0, -- 1409
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1410
		model = usage.model or "", -- 1411
		phase = usage.phase or "", -- 1412
		step = usage.step or 0, -- 1413
		updatedAt = usage.updatedAt or now() -- 1414
	} -- 1414
end -- 1414
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1418
	if taskId == nil or taskId <= 0 then -- 1418
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1420
		return -- 1421
	end -- 1421
	local row = getSessionRow(sessionId) -- 1423
	if not row then -- 1423
		return -- 1424
	end -- 1424
	local session = rowToSession(row) -- 1425
	if session.currentTaskId ~= taskId then -- 1425
		Log( -- 1427
			"Info", -- 1427
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1427
		) -- 1427
		return -- 1428
	end -- 1428
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1430
end -- 1430
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1433
	local t = now() -- 1434
	DB:exec( -- 1435
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1435
		{ -- 1438
			sessionId, -- 1439
			taskId or 0, -- 1440
			role, -- 1441
			sanitizeUTF8(content), -- 1442
			displayContent and sanitizeUTF8(displayContent) or "", -- 1443
			t, -- 1444
			t -- 1445
		} -- 1445
	) -- 1445
	return getLastInsertRowId() -- 1448
end -- 1448
function updateMessage(messageId, content) -- 1451
	DB:exec( -- 1452
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1452
		{ -- 1454
			sanitizeUTF8(content), -- 1454
			now(), -- 1454
			messageId -- 1454
		} -- 1454
	) -- 1454
end -- 1454
function updateUserMessageForTask(messageId, content, taskId) -- 1458
	DB:exec( -- 1459
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1459
		{ -- 1463
			sanitizeUTF8(content), -- 1463
			taskId, -- 1463
			now(), -- 1463
			messageId -- 1463
		} -- 1463
	) -- 1463
end -- 1463
function removeStoppedTaskSummary(session) -- 1520
	local taskId = session.currentTaskId -- 1521
	if taskId == nil then -- 1521
		return -- 1522
	end -- 1522
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1523
end -- 1523
function upsertAssistantMessage(sessionId, taskId, content) -- 1535
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1536
	if row and type(row[1]) == "number" then -- 1536
		updateMessage(row[1], content) -- 1543
		return row[1] -- 1544
	end -- 1544
	return insertMessage(sessionId, "assistant", content, taskId) -- 1546
end -- 1546
function upsertStep(sessionId, taskId, step, tool, patch) -- 1549
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1559
	local reason = sanitizeUTF8(patch.reason or "") -- 1563
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1564
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1565
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1566
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1567
	local statusPatch = patch.status or "" -- 1568
	local status = patch.status or "PENDING" -- 1569
	if not row then -- 1569
		local t = now() -- 1571
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1572
			sessionId, -- 1576
			taskId, -- 1577
			step, -- 1578
			tool, -- 1579
			status, -- 1580
			reason, -- 1581
			reasoningContent, -- 1582
			paramsJson, -- 1583
			resultJson, -- 1584
			patch.checkpointId or 0, -- 1585
			patch.checkpointSeq or 0, -- 1586
			filesJson, -- 1587
			t, -- 1588
			t -- 1589
		}) -- 1589
		return -- 1592
	end -- 1592
	DB:exec( -- 1594
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1594
		{ -- 1606
			tool, -- 1607
			statusPatch, -- 1608
			status, -- 1609
			reason, -- 1610
			reason, -- 1611
			reasoningContent, -- 1612
			reasoningContent, -- 1613
			paramsJson, -- 1614
			paramsJson, -- 1615
			resultJson, -- 1616
			resultJson, -- 1617
			patch.checkpointId or 0, -- 1618
			patch.checkpointId or 0, -- 1619
			patch.checkpointSeq or 0, -- 1620
			patch.checkpointSeq or 0, -- 1621
			filesJson, -- 1622
			filesJson, -- 1623
			now(), -- 1624
			row[1] -- 1625
		} -- 1625
	) -- 1625
end -- 1625
function getNextStepNumber(sessionId, taskId) -- 1630
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1631
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1635
	return math.max(0, current) + 1 -- 1636
end -- 1636
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1657
	if status == nil then -- 1657
		status = "DONE" -- 1665
	end -- 1665
	local step = getNextStepNumber(sessionId, taskId) -- 1667
	upsertStep( -- 1668
		sessionId, -- 1668
		taskId, -- 1668
		step, -- 1668
		tool, -- 1668
		{status = status, reason = reason, params = params, result = result} -- 1668
	) -- 1668
	return getStepItem(sessionId, taskId, step) -- 1674
end -- 1674
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1677
	if taskId <= 0 then -- 1677
		return -- 1678
	end -- 1678
	if finalSteps ~= nil and finalSteps >= 0 then -- 1678
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1680
	end -- 1680
	if not finalStatus then -- 1680
		return -- 1686
	end -- 1686
	if finalSteps ~= nil and finalSteps >= 0 then -- 1686
		DB:exec( -- 1688
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1688
			{ -- 1692
				finalStatus, -- 1692
				now(), -- 1692
				sessionId, -- 1692
				taskId, -- 1692
				finalSteps -- 1692
			} -- 1692
		) -- 1692
		return -- 1694
	end -- 1694
	DB:exec( -- 1696
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1696
		{ -- 1700
			finalStatus, -- 1700
			now(), -- 1700
			sessionId, -- 1700
			taskId -- 1700
		} -- 1700
	) -- 1700
end -- 1700
function emitAgentSessionPatch(sessionId, patch) -- 1727
	if HttpServer.wsConnectionCount == 0 then -- 1727
		return -- 1729
	end -- 1729
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1731
	if not text then -- 1731
		return -- 1736
	end -- 1736
	emit("AppWS", "Send", text) -- 1737
end -- 1737
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1740
	emitAgentSessionPatch( -- 1741
		sessionId, -- 1741
		{ -- 1741
			sessionDeleted = true, -- 1742
			relatedSessions = listRelatedSessions(rootSessionId) -- 1743
		} -- 1743
	) -- 1743
	local rootSession = getSessionItem(rootSessionId) -- 1745
	if rootSession then -- 1745
		emitAgentSessionPatch( -- 1747
			rootSessionId, -- 1747
			{ -- 1747
				session = rootSession, -- 1748
				relatedSessions = listRelatedSessions(rootSessionId) -- 1749
			} -- 1749
		) -- 1749
	end -- 1749
end -- 1749
function flushPendingSubAgentHandoffs(rootSession) -- 1754
	if rootSession.kind ~= "main" then -- 1754
		return -- 1755
	end -- 1755
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1755
		return -- 1757
	end -- 1757
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1759
	if #items == 0 then -- 1759
		return -- 1760
	end -- 1760
	local handoffTaskId = 0 -- 1761
	local ____rootSession_currentTaskId_38 -- 1762
	if rootSession.currentTaskId then -- 1762
		____rootSession_currentTaskId_38 = getTaskPrompt(rootSession.currentTaskId) -- 1762
	else -- 1762
		____rootSession_currentTaskId_38 = nil -- 1762
	end -- 1762
	local currentTaskPrompt = ____rootSession_currentTaskId_38 -- 1762
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1762
		handoffTaskId = rootSession.currentTaskId -- 1770
	else -- 1770
		local taskRes = Tools.createTask( -- 1772
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1772
			"code" -- 1772
		) -- 1772
		if not taskRes.success then -- 1772
			Log( -- 1774
				"Warn", -- 1774
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1774
			) -- 1774
			return -- 1775
		end -- 1775
		handoffTaskId = taskRes.taskId -- 1777
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1778
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1779
		emitAgentSessionPatch( -- 1780
			rootSession.id, -- 1780
			{session = getSessionItem(rootSession.id)} -- 1780
		) -- 1780
	end -- 1780
	do -- 1780
		local i = 0 -- 1784
		while i < #items do -- 1784
			local item = items[i + 1] -- 1785
			local step = appendSystemStep( -- 1786
				rootSession.id, -- 1787
				handoffTaskId, -- 1788
				"sub_agent_handoff", -- 1789
				"sub_agent_handoff", -- 1790
				item.message, -- 1791
				{ -- 1792
					sourceSessionId = item.sourceSessionId, -- 1793
					sourceTitle = item.sourceTitle, -- 1794
					sourceTaskId = item.sourceTaskId, -- 1795
					success = item.success == true, -- 1796
					summary = item.message, -- 1797
					resultFilePath = item.resultFilePath or "", -- 1798
					artifactDir = item.artifactDir or "", -- 1799
					finishedAt = item.finishedAt or "", -- 1800
					changeSet = item.changeSet, -- 1801
					handoffEvidence = item.handoffEvidence, -- 1802
					memoryEntry = item.memoryEntry, -- 1803
					completion = item.completion -- 1804
				}, -- 1804
				{ -- 1806
					sourceSessionId = item.sourceSessionId, -- 1807
					sourceTitle = item.sourceTitle, -- 1808
					sourceTaskId = item.sourceTaskId, -- 1809
					prompt = item.prompt, -- 1810
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1811
					expectedOutput = item.expectedOutput or "", -- 1812
					filesHint = item.filesHint or ({}), -- 1813
					resultFilePath = item.resultFilePath or "", -- 1814
					artifactDir = item.artifactDir or "", -- 1815
					changeSet = item.changeSet, -- 1816
					handoffEvidence = item.handoffEvidence, -- 1817
					memoryEntry = item.memoryEntry, -- 1818
					completion = item.completion -- 1819
				}, -- 1819
				"DONE" -- 1821
			) -- 1821
			if step then -- 1821
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1824
			end -- 1824
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1826
			i = i + 1 -- 1784
		end -- 1784
	end -- 1784
end -- 1784
function applyEvent(sessionId, event) -- 1838
	repeat -- 1838
		local ____switch306 = event.type -- 1838
		local metrics, startedSession -- 1838
		local ____cond306 = ____switch306 == "task_started" -- 1838
		if ____cond306 then -- 1838
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1841
			local ____event_resumed_41 -- 1842
			if event.resumed then -- 1842
				local ____opt_39 = getSessionItem(sessionId) -- 1842
				____event_resumed_41 = ____opt_39 and ____opt_39.metrics -- 1843
			else -- 1843
				____event_resumed_41 = clearSessionTokenUsage(sessionId) -- 1844
			end -- 1844
			metrics = ____event_resumed_41 -- 1842
			startedSession = getSessionItem(sessionId) -- 1845
			emitAgentSessionPatch( -- 1846
				sessionId, -- 1846
				{ -- 1846
					session = startedSession, -- 1847
					metrics = metrics, -- 1848
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1849
				} -- 1849
			) -- 1849
			break -- 1853
		end -- 1853
		____cond306 = ____cond306 or ____switch306 == "decision_made" -- 1853
		if ____cond306 then -- 1853
			upsertStep( -- 1855
				sessionId, -- 1855
				event.taskId, -- 1855
				event.step, -- 1855
				event.tool, -- 1855
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1855
			) -- 1855
			emitAgentSessionPatch( -- 1863
				sessionId, -- 1863
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1863
			) -- 1863
			break -- 1866
		end -- 1866
		____cond306 = ____cond306 or ____switch306 == "tool_started" -- 1866
		if ____cond306 then -- 1866
			upsertStep( -- 1868
				sessionId, -- 1868
				event.taskId, -- 1868
				event.step, -- 1868
				event.tool, -- 1868
				{status = "RUNNING"} -- 1868
			) -- 1868
			emitAgentSessionPatch( -- 1871
				sessionId, -- 1871
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1871
			) -- 1871
			break -- 1874
		end -- 1874
		____cond306 = ____cond306 or ____switch306 == "tool_finished" -- 1874
		if ____cond306 then -- 1874
			do -- 1874
				local ____temp_44 = event.result.success ~= true -- 1876
				if ____temp_44 then -- 1876
					local ____opt_42 = activeStopTokens[event.taskId] -- 1876
					____temp_44 = (____opt_42 and ____opt_42.stopped) == true -- 1876
				end -- 1876
				local stopped = ____temp_44 -- 1876
				upsertStep( -- 1878
					sessionId, -- 1878
					event.taskId, -- 1878
					event.step, -- 1878
					event.tool, -- 1878
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1878
				) -- 1878
				emitAgentSessionPatch( -- 1886
					sessionId, -- 1886
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1886
				) -- 1886
				break -- 1889
			end -- 1889
		end -- 1889
		____cond306 = ____cond306 or ____switch306 == "tool_progress" -- 1889
		if ____cond306 then -- 1889
			do -- 1889
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1893
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1893
					break -- 1895
				end -- 1895
			end -- 1895
			upsertStep( -- 1898
				sessionId, -- 1898
				event.taskId, -- 1898
				event.step, -- 1898
				event.tool, -- 1898
				{status = "RUNNING", result = event.result} -- 1898
			) -- 1898
			emitAgentSessionPatch( -- 1902
				sessionId, -- 1902
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1902
			) -- 1902
			break -- 1905
		end -- 1905
		____cond306 = ____cond306 or ____switch306 == "checkpoint_created" -- 1905
		if ____cond306 then -- 1905
			upsertStep( -- 1907
				sessionId, -- 1907
				event.taskId, -- 1907
				event.step, -- 1907
				event.tool, -- 1907
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1907
			) -- 1907
			emitAgentSessionPatch( -- 1912
				sessionId, -- 1912
				{ -- 1912
					step = getStepItem(sessionId, event.taskId, event.step), -- 1913
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 1914
				} -- 1914
			) -- 1914
			break -- 1916
		end -- 1916
		____cond306 = ____cond306 or ____switch306 == "memory_compression_started" -- 1916
		if ____cond306 then -- 1916
			upsertStep( -- 1918
				sessionId, -- 1918
				event.taskId, -- 1918
				event.step, -- 1918
				event.tool, -- 1918
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1918
			) -- 1918
			emitAgentSessionPatch( -- 1923
				sessionId, -- 1923
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1923
			) -- 1923
			break -- 1926
		end -- 1926
		____cond306 = ____cond306 or ____switch306 == "memory_compression_finished" -- 1926
		if ____cond306 then -- 1926
			upsertStep( -- 1928
				sessionId, -- 1928
				event.taskId, -- 1928
				event.step, -- 1928
				event.tool, -- 1928
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1928
			) -- 1928
			emitAgentSessionPatch( -- 1933
				sessionId, -- 1933
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1933
			) -- 1933
			break -- 1936
		end -- 1936
		____cond306 = ____cond306 or ____switch306 == "metrics_updated" -- 1936
		if ____cond306 then -- 1936
			do -- 1936
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1938
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1939
				break -- 1942
			end -- 1942
		end -- 1942
		____cond306 = ____cond306 or ____switch306 == "assistant_message_updated" -- 1942
		if ____cond306 then -- 1942
			do -- 1942
				upsertStep( -- 1945
					sessionId, -- 1945
					event.taskId, -- 1945
					event.step, -- 1945
					"message", -- 1945
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1945
				) -- 1945
				emitAgentSessionPatch( -- 1950
					sessionId, -- 1950
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1950
				) -- 1950
				break -- 1953
			end -- 1953
		end -- 1953
		____cond306 = ____cond306 or ____switch306 == "task_waiting_for_user" -- 1953
		if ____cond306 then -- 1953
			do -- 1953
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 1956
				__TS__Delete(activeStopTokens, event.taskId) -- 1957
				emitAgentSessionPatch( -- 1958
					sessionId, -- 1958
					{ -- 1958
						session = getSessionItem(sessionId), -- 1959
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 1960
					} -- 1960
				) -- 1960
				break -- 1962
			end -- 1962
		end -- 1962
		____cond306 = ____cond306 or ____switch306 == "task_finished" -- 1962
		if ____cond306 then -- 1962
			do -- 1962
				local session = getSessionItem(sessionId) -- 1965
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 1965
					__TS__Delete(activeStopTokens, event.taskId) -- 1967
					Log( -- 1968
						"Info", -- 1968
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1968
					) -- 1968
					break -- 1969
				end -- 1969
				local ____opt_45 = activeStopTokens[event.taskId or -1] -- 1969
				local stopped = (____opt_45 and ____opt_45.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 1971
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1973
				local isSubSession = (session and session.kind) == "sub" -- 1976
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1977
				if isSubSession and event.taskId ~= nil then -- 1977
					finalizingSubSessionTaskIds[event.taskId] = true -- 1979
				end -- 1979
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1981
				if event.taskId ~= nil then -- 1981
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1983
					local ____finalizeTaskSteps_51 = finalizeTaskSteps -- 1984
					local ____array_50 = __TS__SparseArrayNew( -- 1984
						sessionId, -- 1985
						event.taskId, -- 1986
						type(event.steps) == "number" and math.max( -- 1987
							0, -- 1987
							math.floor(event.steps) -- 1987
						) or nil -- 1987
					) -- 1987
					local ____event_success_49 -- 1988
					if event.success then -- 1988
						____event_success_49 = nil -- 1988
					else -- 1988
						____event_success_49 = stopped and "STOPPED" or "FAILED" -- 1988
					end -- 1988
					__TS__SparseArrayPush(____array_50, ____event_success_49) -- 1988
					____finalizeTaskSteps_51(__TS__SparseArraySpread(____array_50)) -- 1984
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1990
					if not isSubSession then -- 1990
						__TS__Delete(activeStopTokens, event.taskId) -- 1992
					end -- 1992
					emitAgentSessionPatch( -- 1994
						sessionId, -- 1994
						{ -- 1994
							session = getSessionItem(sessionId), -- 1995
							message = getMessageItem(messageId), -- 1996
							removedStepIds = removedStepIds -- 1997
						} -- 1997
					) -- 1997
				end -- 1997
				if session and session.kind == "main" then -- 1997
					flushPendingSubAgentHandoffs(session) -- 2001
				end -- 2001
				break -- 2003
			end -- 2003
		end -- 2003
	until true -- 2003
end -- 2003
function ____exports.createSession(projectRoot, title) -- 2162
	if title == nil then -- 2162
		title = "" -- 2162
	end -- 2162
	if not isValidProjectRoot(projectRoot) then -- 2162
		return {success = false, message = "invalid projectRoot"} -- 2164
	end -- 2164
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2166
	if row then -- 2166
		return { -- 2175
			success = true, -- 2175
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2175
		} -- 2175
	end -- 2175
	local t = now() -- 2177
	DB:exec( -- 2178
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 2178
		{ -- 2181
			projectRoot, -- 2181
			title ~= "" and title or Path:getFilename(projectRoot), -- 2181
			t, -- 2181
			t -- 2181
		} -- 2181
	) -- 2181
	local sessionId = getLastInsertRowId() -- 2183
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2184
	local session = getSessionItem(sessionId) -- 2185
	if not session then -- 2185
		return {success = false, message = "failed to create session"} -- 2187
	end -- 2187
	return {success = true, session = session} -- 2189
end -- 2162
function ____exports.createSubSession(parentSessionId, title) -- 2192
	if title == nil then -- 2192
		title = "" -- 2192
	end -- 2192
	local parent = getSessionItem(parentSessionId) -- 2193
	if not parent then -- 2193
		return {success = false, message = "parent session not found"} -- 2195
	end -- 2195
	local rootId = getSessionRootId(parent) -- 2197
	local t = now() -- 2198
	DB:exec( -- 2199
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2199
		{ -- 2202
			parent.projectRoot, -- 2202
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2202
			rootId, -- 2202
			parent.id, -- 2202
			t, -- 2202
			t -- 2202
		} -- 2202
	) -- 2202
	local sessionId = getLastInsertRowId() -- 2204
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2205
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2206
	local session = getSessionItem(sessionId) -- 2207
	if not session then -- 2207
		return {success = false, message = "failed to create sub session"} -- 2209
	end -- 2209
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2211
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2212
	subStorage:writeMemory(parentStorage:readMemory()) -- 2213
	return {success = true, session = session} -- 2214
end -- 2192
function spawnSubAgentSession(request) -- 2217
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2217
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2230
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2231
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2232
		if normalizedPrompt == "" then -- 2232
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2234
		end -- 2234
		if normalizedPrompt == "" then -- 2234
			local ____Log_57 = Log -- 2241
			local ____temp_54 = #normalizedTitle -- 2241
			local ____temp_55 = #rawPrompt -- 2241
			local ____temp_56 = #toStr(request.expectedOutput) -- 2241
			local ____opt_52 = request.filesHint -- 2241
			____Log_57( -- 2241
				"Warn", -- 2241
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_54)) .. " raw_prompt_len=") .. tostring(____temp_55)) .. " expected_len=") .. tostring(____temp_56)) .. " files_hint_count=") .. tostring(____opt_52 and #____opt_52 or 0) -- 2241
			) -- 2241
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2241
		end -- 2241
		Log( -- 2244
			"Info", -- 2244
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2244
		) -- 2244
		local parentSessionId = request.parentSessionId -- 2245
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2245
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2247
			if not fallbackParent then -- 2247
				local createdMain = ____exports.createSession(request.projectRoot) -- 2249
				if createdMain.success then -- 2249
					fallbackParent = createdMain.session -- 2251
				end -- 2251
			end -- 2251
			if fallbackParent then -- 2251
				Log( -- 2255
					"Warn", -- 2255
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2255
				) -- 2255
				parentSessionId = fallbackParent.id -- 2256
			end -- 2256
		end -- 2256
		local parentSession = getSessionItem(parentSessionId) -- 2259
		if not parentSession then -- 2259
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2259
		end -- 2259
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2263
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2263
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2263
		end -- 2263
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2267
		if not created.success then -- 2267
			return ____awaiter_resolve(nil, created) -- 2267
		end -- 2267
		writeSpawnInfo( -- 2271
			created.session.projectRoot, -- 2271
			created.session.memoryScope, -- 2271
			{ -- 2271
				sessionId = created.session.id, -- 2272
				rootSessionId = created.session.rootSessionId, -- 2273
				parentSessionId = created.session.parentSessionId, -- 2274
				title = created.session.title, -- 2275
				prompt = normalizedPrompt, -- 2276
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2277
				expectedOutput = request.expectedOutput or "", -- 2278
				filesHint = request.filesHint or ({}), -- 2279
				status = "RUNNING", -- 2280
				success = false, -- 2281
				resultFilePath = "", -- 2282
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2283
				sourceTaskId = 0, -- 2284
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2285
				createdAtTs = created.session.createdAt, -- 2286
				finishedAt = "", -- 2287
				finishedAtTs = 0 -- 2288
			} -- 2288
		) -- 2288
		local sent = ____exports.sendPrompt( -- 2290
			created.session.id, -- 2290
			normalizedPrompt, -- 2290
			true, -- 2290
			request.disabledAgentTools, -- 2290
			nil, -- 2290
			nil, -- 2290
			request.llmConfig -- 2290
		) -- 2290
		if not sent.success then -- 2290
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2290
		end -- 2290
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2290
	end) -- 2290
end -- 2290
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2395
	local rootSession = getRootSessionItem(session.id) -- 2396
	if not rootSession then -- 2396
		return -- 2397
	end -- 2397
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2398
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2399
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2400
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2401
	local queueResult = writePendingHandoff( -- 2402
		rootSession.projectRoot, -- 2402
		rootSession.memoryScope, -- 2402
		{ -- 2402
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2403
			sourceSessionId = session.id, -- 2404
			sourceTitle = session.title, -- 2405
			sourceTaskId = taskId, -- 2406
			message = summary, -- 2407
			prompt = result.prompt, -- 2408
			goal = result.goal, -- 2409
			expectedOutput = result.expectedOutput or "", -- 2410
			filesHint = result.filesHint or ({}), -- 2411
			success = result.success, -- 2412
			resultFilePath = result.resultFilePath, -- 2413
			artifactDir = result.artifactDir, -- 2414
			finishedAt = result.finishedAt, -- 2415
			changeSet = changeSet, -- 2416
			handoffEvidence = result.handoffEvidence, -- 2417
			memoryEntry = result.memoryEntry, -- 2418
			completion = result.completion, -- 2419
			createdAt = createdAt -- 2420
		} -- 2420
	) -- 2420
	if not queueResult then -- 2420
		Log( -- 2423
			"Warn", -- 2423
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2423
		) -- 2423
		return -- 2424
	end -- 2424
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2424
		flushPendingSubAgentHandoffs(rootSession) -- 2427
	end -- 2427
end -- 2427
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2431
	if forceHandoff == nil then -- 2431
		forceHandoff = false -- 2437
	end -- 2437
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2437
		local rootSessionId = getSessionRootId(session) -- 2439
		local rootSession = getRootSessionItem(session.id) -- 2440
		if not rootSession then -- 2440
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2440
		end -- 2440
		local spawnInfo = getSessionSpawnInfo(session) -- 2444
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2445
		local finishedAtTs = now() -- 2446
		local resultText = sanitizeUTF8(message) -- 2447
		local changeSet = getTaskChangeSetSummary(taskId) -- 2448
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2449
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2450
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2454
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2454
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2456
		end -- 2456
		local completed = success and completionReport.outcome == "completed" -- 2464
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2465
		local record = { -- 2468
			sessionId = session.id, -- 2469
			rootSessionId = rootSessionId, -- 2470
			parentSessionId = session.parentSessionId, -- 2471
			title = session.title, -- 2472
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2473
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2474
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2475
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2476
			status = recordStatus, -- 2477
			success = completed, -- 2478
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2479
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2480
			sourceTaskId = taskId, -- 2481
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2482
			finishedAt = finishedAt, -- 2483
			createdAtTs = session.createdAt, -- 2484
			finishedAtTs = finishedAtTs, -- 2485
			changeSet = changeSet, -- 2486
			handoffEvidence = handoffEvidence, -- 2487
			completion = completionReport -- 2488
		} -- 2488
		local ____record_success_70 -- 2490
		if record.success then -- 2490
			____record_success_70 = buildStructuredSubAgentMemoryEntry(record) -- 2490
		else -- 2490
			____record_success_70 = nil -- 2490
		end -- 2490
		record.memoryEntry = ____record_success_70 -- 2490
		if not writeSubAgentResultFile(session, record, resultText) then -- 2490
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2490
		end -- 2490
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2490
			sessionId = record.sessionId, -- 2495
			rootSessionId = record.rootSessionId, -- 2496
			parentSessionId = record.parentSessionId, -- 2497
			title = record.title, -- 2498
			prompt = record.prompt, -- 2499
			goal = record.goal, -- 2500
			expectedOutput = record.expectedOutput or "", -- 2501
			filesHint = record.filesHint or ({}), -- 2502
			status = record.status, -- 2503
			success = record.success, -- 2504
			resultFilePath = record.resultFilePath, -- 2505
			artifactDir = record.artifactDir, -- 2506
			sourceTaskId = record.sourceTaskId, -- 2507
			createdAt = record.createdAt, -- 2508
			finishedAt = record.finishedAt, -- 2509
			createdAtTs = record.createdAtTs, -- 2510
			finishedAtTs = record.finishedAtTs, -- 2511
			changeSet = record.changeSet, -- 2512
			handoffEvidence = record.handoffEvidence, -- 2513
			memoryEntry = record.memoryEntry, -- 2514
			memoryEntryError = record.memoryEntryError, -- 2515
			completion = record.completion -- 2516
		}) then -- 2516
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2516
		end -- 2516
		if success or forceHandoff then -- 2516
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2521
			deleteSessionRecords(session.id, true) -- 2522
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2523
		end -- 2523
		return ____awaiter_resolve(nil, {success = true}) -- 2523
	end) -- 2523
end -- 2523
function stopClearedSubSession(session, taskId) -- 2528
	local spawnInfo = getSessionSpawnInfo(session) -- 2529
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2530
	local rootSessionId = getSessionRootId(session) -- 2531
	Tools.setTaskStatus(taskId, "STOPPED") -- 2532
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2533
	if not writeSpawnInfo( -- 2533
		session.projectRoot, -- 2534
		session.memoryScope, -- 2534
		{ -- 2534
			sessionId = session.id, -- 2535
			rootSessionId = rootSessionId, -- 2536
			parentSessionId = session.parentSessionId, -- 2537
			title = session.title, -- 2538
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2539
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2540
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2541
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2542
			status = "STOPPED", -- 2543
			success = false, -- 2544
			cleared = true, -- 2545
			resultFilePath = "", -- 2546
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2547
			sourceTaskId = taskId, -- 2548
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2549
			finishedAt = finishedAt, -- 2550
			createdAtTs = session.createdAt, -- 2551
			finishedAtTs = now() -- 2552
		} -- 2552
	) then -- 2552
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2554
	end -- 2554
	deleteSessionRecords(session.id, true) -- 2556
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2557
	return {success = true} -- 2558
end -- 2558
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2561
	if allowSubSessionStart == nil then -- 2561
		allowSubSessionStart = false -- 2561
	end -- 2561
	local session = getSessionItem(sessionId) -- 2562
	if not session then -- 2562
		return {success = false, message = "session not found"} -- 2564
	end -- 2564
	if getPendingQuestionnaire(sessionId) then -- 2564
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2566
	end -- 2566
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2566
		return {success = false, message = "session task is finalizing"} -- 2568
	end -- 2568
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2568
		return {success = false, message = "session task is still running"} -- 2571
	end -- 2571
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2573
	if normalizedPrompt == "" and session.kind == "sub" then -- 2573
		local spawnInfo = getSessionSpawnInfo(session) -- 2575
		if spawnInfo then -- 2575
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2577
			if normalizedPrompt == "" then -- 2577
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2579
			end -- 2579
		end -- 2579
	end -- 2579
	if normalizedPrompt == "" then -- 2579
		return {success = false, message = "prompt is empty"} -- 2588
	end -- 2588
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2590
	if session.workMode ~= nextWorkMode then -- 2590
		DB:exec( -- 2592
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2592
			{ -- 2592
				nextWorkMode, -- 2592
				now(), -- 2592
				session.id -- 2592
			} -- 2592
		) -- 2592
		session.workMode = nextWorkMode -- 2593
	end -- 2593
	return startPromptTask( -- 2595
		session, -- 2595
		normalizedPrompt, -- 2595
		nil, -- 2595
		normalizeDisabledAgentTools(disabledAgentTools), -- 2595
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2595
	) -- 2595
end -- 2561
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2648
	if disabledAgentTools == nil then -- 2648
		disabledAgentTools = {} -- 2652
	end -- 2652
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2655
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2656
	if not llmConfigRes.success then -- 2656
		return {success = false, message = llmConfigRes.message} -- 2660
	end -- 2660
	local llmConfig = llmConfigRes.config -- 2662
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2663
	if not taskRes.success then -- 2663
		return {success = false, message = taskRes.message} -- 2666
	end -- 2666
	if session.currentTaskStatus == "STOPPED" then -- 2666
		removeStoppedTaskSummary(session) -- 2668
	end -- 2668
	local taskId = taskRes.taskId -- 2670
	local useChineseResponse = getDefaultUseChineseResponse() -- 2671
	if existingUserMessageId ~= nil then -- 2671
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2673
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2673
		insertMessage( -- 2675
			session.id, -- 2675
			"user", -- 2675
			normalizedPrompt, -- 2675
			taskId, -- 2675
			options and options.displayContent -- 2675
		) -- 2675
	end -- 2675
	local stopToken = {stopped = false} -- 2677
	activeStopTokens[taskId] = stopToken -- 2678
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2679
	local ____runCodingAgent_117 = runCodingAgent -- 2680
	local ____normalizedPrompt_110 = normalizedPrompt -- 2681
	local ____temp_111 = options and options.resumeConversation -- 2682
	local ____temp_112 = (options and options.existingTaskId) ~= nil -- 2683
	local ____temp_113 = options and options.initialStep -- 2684
	local ____temp_114 = options and options.initialAgentStepCount -- 2685
	local ____temp_105 -- 2686
	if (options and options.existingTaskId) ~= nil then -- 2686
		____temp_105 = getInitialTokenUsage(session) -- 2686
	else -- 2686
		____temp_105 = nil -- 2686
	end -- 2686
	____runCodingAgent_117( -- 2680
		{ -- 2680
			prompt = ____normalizedPrompt_110, -- 2681
			resumeConversation = ____temp_111, -- 2682
			resumeTask = ____temp_112, -- 2683
			initialStep = ____temp_113, -- 2684
			initialAgentStepCount = ____temp_114, -- 2685
			initialTokenUsage = ____temp_105, -- 2686
			workDir = session.projectRoot, -- 2687
			useChineseResponse = useChineseResponse, -- 2688
			taskId = taskId, -- 2689
			sessionId = session.id, -- 2690
			memoryScope = session.memoryScope, -- 2691
			role = session.kind, -- 2692
			maxSteps = options and options.maxSteps, -- 2693
			disabledAgentTools = disabledAgentTools, -- 2694
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2695
			llmConfig = llmConfig, -- 2696
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2697
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2700
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2703
			stopToken = stopToken, -- 2704
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2705
		}, -- 2705
		function(result) -- 2706
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2706
				local nextSession = getSessionItem(session.id) -- 2707
				if nextSession and nextSession.kind == "sub" then -- 2707
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2707
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2710
						if not stopped.success then -- 2710
							Log( -- 2712
								"Warn", -- 2712
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2712
							) -- 2712
							emitAgentSessionPatch( -- 2713
								session.id, -- 2713
								{session = getSessionItem(session.id)} -- 2713
							) -- 2713
						end -- 2713
						__TS__Delete(activeStopTokens, taskId) -- 2717
						return ____awaiter_resolve(nil) -- 2717
					end -- 2717
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2720
					emitAgentSessionPatch( -- 2721
						session.id, -- 2721
						{session = getSessionItem(session.id)} -- 2721
					) -- 2721
					local finalized = __TS__Await(finalizeSubSession( -- 2724
						nextSession, -- 2725
						taskId, -- 2726
						result.success, -- 2727
						result.message, -- 2728
						result.completion, -- 2729
						(options and options.forceSubAgentHandoff) == true -- 2730
					)) -- 2730
					if not finalized.success then -- 2730
						Log( -- 2733
							"Warn", -- 2733
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2733
						) -- 2733
					end -- 2733
					local finalizedSession = getSessionItem(session.id) -- 2735
					if finalizedSession then -- 2735
						local stopped = stopToken.stopped == true -- 2737
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2738
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2741
						emitAgentSessionPatch( -- 2742
							session.id, -- 2742
							{session = getSessionItem(session.id)} -- 2742
						) -- 2742
					end -- 2742
					__TS__Delete(activeStopTokens, taskId) -- 2746
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2747
				end -- 2747
				local fallbackSession = getSessionItem(session.id) -- 2749
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2749
					applyEvent(session.id, { -- 2755
						type = "task_finished", -- 2756
						sessionId = session.id, -- 2757
						taskId = result.taskId, -- 2758
						success = false, -- 2759
						message = result.message, -- 2760
						steps = result.steps -- 2761
					}) -- 2761
				end -- 2761
			end) -- 2761
		end -- 2706
	) -- 2706
	return {success = true, sessionId = session.id, taskId = taskId} -- 2765
end -- 2765
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2917
	local lines = {} -- 2918
	do -- 2918
		local i = 0 -- 2919
		while i < #questionnaire.schema.questions do -- 2919
			local question = questionnaire.schema.questions[i + 1] -- 2920
			local answer = __TS__ArrayFind( -- 2921
				answers, -- 2921
				function(____, item) return item.questionId == question.id end -- 2921
			) -- 2921
			local answerText = "已跳过" -- 2922
			if answer and answer.status == "answered" then -- 2922
				local parts = {} -- 2924
				do -- 2924
					local j = 0 -- 2925
					while j < #(answer.selectedOptionIds or ({})) do -- 2925
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2926
						local option = __TS__ArrayFind( -- 2927
							question.options or ({}), -- 2927
							function(____, item) return item.id == optionId end -- 2927
						) -- 2927
						if option then -- 2927
							parts[#parts + 1] = option.label -- 2928
						end -- 2928
						j = j + 1 -- 2925
					end -- 2925
				end -- 2925
				if answer.otherText then -- 2925
					parts[#parts + 1] = answer.otherText -- 2930
				end -- 2930
				if answer.text then -- 2930
					parts[#parts + 1] = answer.text -- 2931
				end -- 2931
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2932
			end -- 2932
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2934
			i = i + 1 -- 2919
		end -- 2919
	end -- 2919
	return table.concat(lines, "\n\n") -- 2936
end -- 2936
function ____exports.listRunningSubAgents(request) -- 3153
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3153
		local session = getSessionItem(request.sessionId) -- 3161
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3161
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3163
		end -- 3163
		if not session then -- 3163
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3163
		end -- 3163
		local rootSession = getRootSessionItem(session.id) -- 3168
		if not rootSession then -- 3168
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3168
		end -- 3168
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3172
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3173
		local limit = math.max( -- 3174
			1, -- 3174
			math.floor(tonumber(request.limit) or 5) -- 3174
		) -- 3174
		local offset = math.max( -- 3175
			0, -- 3175
			math.floor(tonumber(request.offset) or 0) -- 3175
		) -- 3175
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3176
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3177
		local runningSessions = {} -- 3184
		do -- 3184
			local i = 0 -- 3185
			while i < #rows do -- 3185
				do -- 3185
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3186
					if current.currentTaskStatus ~= "RUNNING" then -- 3186
						goto __continue506 -- 3188
					end -- 3188
					local spawnInfo = getSessionSpawnInfo(current) -- 3190
					runningSessions[#runningSessions + 1] = { -- 3191
						sessionId = current.id, -- 3192
						title = current.title, -- 3193
						parentSessionId = current.parentSessionId, -- 3194
						rootSessionId = current.rootSessionId, -- 3195
						status = "RUNNING", -- 3196
						currentTaskId = current.currentTaskId, -- 3197
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3198
						goal = spawnInfo and spawnInfo.goal, -- 3199
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3200
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3201
						createdAt = current.createdAt, -- 3202
						updatedAt = current.updatedAt -- 3203
					} -- 3203
				end -- 3203
				::__continue506:: -- 3203
				i = i + 1 -- 3185
			end -- 3185
		end -- 3185
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3206
		local completedSessions = __TS__ArrayMap( -- 3207
			completedRecords, -- 3207
			function(____, record) return { -- 3207
				sessionId = record.sessionId, -- 3208
				title = record.title, -- 3209
				parentSessionId = record.parentSessionId, -- 3210
				rootSessionId = record.rootSessionId, -- 3211
				status = record.status, -- 3212
				goal = record.goal, -- 3213
				expectedOutput = record.expectedOutput, -- 3214
				filesHint = record.filesHint, -- 3215
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3216
				success = record.success, -- 3217
				cleared = record.cleared, -- 3218
				resultFilePath = record.resultFilePath, -- 3219
				artifactDir = record.artifactDir, -- 3220
				finishedAt = record.finishedAt, -- 3221
				createdAt = record.createdAtTs, -- 3222
				updatedAt = record.finishedAtTs -- 3223
			} end -- 3223
		) -- 3223
		local merged = {} -- 3225
		if status == "running" then -- 3225
			merged = runningSessions -- 3227
		elseif status == "done" then -- 3227
			merged = __TS__ArrayFilter( -- 3229
				completedSessions, -- 3229
				function(____, item) return item.status == "DONE" end -- 3229
			) -- 3229
		elseif status == "failed" then -- 3229
			merged = __TS__ArrayFilter( -- 3231
				completedSessions, -- 3231
				function(____, item) return item.status == "FAILED" end -- 3231
			) -- 3231
		elseif status == "stopped" then -- 3231
			merged = __TS__ArrayFilter( -- 3233
				completedSessions, -- 3233
				function(____, item) return item.status == "STOPPED" end -- 3233
			) -- 3233
		elseif status == "all" then -- 3233
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3235
		else -- 3235
			local runningKeys = {} -- 3237
			do -- 3237
				local i = 0 -- 3238
				while i < #runningSessions do -- 3238
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3239
					i = i + 1 -- 3238
				end -- 3238
			end -- 3238
			local latestCompletedByKey = {} -- 3241
			do -- 3241
				local i = 0 -- 3242
				while i < #completedSessions do -- 3242
					do -- 3242
						local item = completedSessions[i + 1] -- 3243
						local key = getSubAgentDisplayKey(item) -- 3244
						if runningKeys[key] then -- 3244
							goto __continue521 -- 3246
						end -- 3246
						local current = latestCompletedByKey[key] -- 3248
						if not current or item.updatedAt > current.updatedAt then -- 3248
							latestCompletedByKey[key] = item -- 3250
						end -- 3250
					end -- 3250
					::__continue521:: -- 3250
					i = i + 1 -- 3242
				end -- 3242
			end -- 3242
			local latestCompleted = {} -- 3253
			for ____, item in pairs(latestCompletedByKey) do -- 3254
				latestCompleted[#latestCompleted + 1] = item -- 3255
			end -- 3255
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3257
		end -- 3257
		if query ~= "" then -- 3257
			merged = __TS__ArrayFilter( -- 3260
				merged, -- 3260
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3260
			) -- 3260
		end -- 3260
		__TS__ArraySort( -- 3266
			merged, -- 3266
			function(____, a, b) -- 3266
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3266
					return -1 -- 3267
				end -- 3267
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3267
					return 1 -- 3268
				end -- 3268
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3268
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3270
				end -- 3270
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3272
			end -- 3266
		) -- 3266
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3274
		return ____awaiter_resolve(nil, { -- 3274
			success = true, -- 3276
			rootSessionId = rootSession.id, -- 3277
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3278
			status = status, -- 3279
			limit = limit, -- 3280
			offset = offset, -- 3281
			hasMore = offset + limit < #merged, -- 3282
			sessions = paged -- 3283
		}) -- 3283
	end) -- 3283
end -- 3153
TABLE_SESSION = "AgentSession" -- 255
TABLE_MESSAGE = "AgentSessionMessage" -- 256
TABLE_STEP = "AgentSessionStep" -- 257
TABLE_TASK = "AgentTask" -- 258
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 259
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 260
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 261
SPAWN_INFO_FILE = "SPAWN.json" -- 262
RESULT_FILE = "RESULT.md" -- 263
PENDING_HANDOFF_DIR = "pending-handoffs" -- 264
MAX_CONCURRENT_SUB_AGENTS = 4 -- 265
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 266
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 267
activeStopTokens = {} -- 317
finalizingSubSessionTaskIds = {} -- 318
now = function() return os.time() end -- 319
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 947
	if projectRoot == oldRoot then -- 947
		return newRoot -- 949
	end -- 949
	for ____, separator in ipairs({"/", "\\"}) do -- 951
		local prefix = oldRoot .. separator -- 952
		if __TS__StringStartsWith(projectRoot, prefix) then -- 952
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 954
		end -- 954
	end -- 954
	return nil -- 957
end -- 947
local function clearSessionAfterMessage(sessionId, message) -- 1467
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1468
	local removedStepIds = {} -- 1476
	do -- 1476
		local i = 0 -- 1477
		while i < #removedStepRows do -- 1477
			local row = removedStepRows[i + 1] -- 1478
			if type(row[1]) == "number" then -- 1478
				removedStepIds[#removedStepIds + 1] = row[1] -- 1480
			end -- 1480
			i = i + 1 -- 1477
		end -- 1477
	end -- 1477
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1483
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1491
	return removedStepIds -- 1496
end -- 1467
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1499
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1500
	local persisted = storage:readSessionState() -- 1501
	local userIndex = -1 -- 1502
	do -- 1502
		local i = #persisted.messages - 1 -- 1503
		while i >= 0 do -- 1503
			if persisted.messages[i + 1].role == "user" then -- 1503
				userIndex = i -- 1505
				break -- 1506
			end -- 1506
			i = i - 1 -- 1503
		end -- 1503
	end -- 1503
	if userIndex < 0 then -- 1503
		return -- 1509
	end -- 1509
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1510
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1511
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1512
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1517
end -- 1499
local function listCurrentTaskCheckpoints(sessionId) -- 1529
	local session = getSessionItem(sessionId) -- 1530
	local taskId = session and session.currentTaskId -- 1531
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1532
end -- 1529
local function getAgentStepCount(sessionId, taskId) -- 1639
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1640
		sessionId, -- 1645
		taskId, -- 1646
		"compress_memory", -- 1647
		"merge_memory", -- 1648
		"sub_agent_handoff", -- 1649
		"questionnaire_answer", -- 1650
		"message" -- 1651
	}) -- 1651
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1654
end -- 1639
local function sanitizeStoredSteps(sessionId) -- 1704
	DB:exec( -- 1705
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1705
		{ -- 1723
			now(), -- 1723
			sessionId -- 1723
		} -- 1723
	) -- 1723
end -- 1704
local function getSchemaVersion() -- 2008
	local row = queryOne("PRAGMA user_version") -- 2009
	return row and type(row[1]) == "number" and row[1] or 0 -- 2010
end -- 2008
local function setSchemaVersion(version) -- 2013
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 2014
		0, -- 2014
		math.floor(version) -- 2014
	))) -- 2014
end -- 2013
local function hasTableColumn(tableName, columnName) -- 2017
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 2018
	do -- 2018
		local i = 0 -- 2019
		while i < #rows do -- 2019
			local row = rows[i + 1] -- 2020
			if toStr(row[2]) == columnName then -- 2020
				return true -- 2022
			end -- 2022
			i = i + 1 -- 2019
		end -- 2019
	end -- 2019
	return false -- 2025
end -- 2017
local function ensureSessionMetricsColumn() -- 2028
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 2028
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 2030
	end -- 2030
end -- 2028
local function ensureSessionWorkModeColumn() -- 2034
	if not hasTableColumn(TABLE_SESSION, "work_mode") then -- 2034
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN work_mode TEXT NOT NULL DEFAULT 'code';") -- 2036
	end -- 2036
end -- 2034
local function ensureMessageDisplayContentColumn() -- 2040
	if not hasTableColumn(TABLE_MESSAGE, "display_content") then -- 2040
		DB:exec(("ALTER TABLE " .. TABLE_MESSAGE) .. " ADD COLUMN display_content TEXT NOT NULL DEFAULT '';") -- 2042
	end -- 2042
end -- 2040
local function recreateSchema() -- 2046
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 2047
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 2048
	DB:exec("DROP TABLE IF EXISTS AgentQuestionnaire;") -- 2049
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 2050
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT '',\n\t\t\twork_mode TEXT NOT NULL DEFAULT 'code'\n\t\t);") -- 2051
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 2067
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tdisplay_content TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 2068
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 2078
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 2079
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2096
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2097
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 2098
end -- 2046
do -- 2046
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 2046
		recreateSchema() -- 2104
	else -- 2104
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT '',\n\t\t\twork_mode TEXT NOT NULL DEFAULT 'code'\n\t\t);") -- 2106
		ensureSessionMetricsColumn() -- 2122
		ensureSessionWorkModeColumn() -- 2123
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 2124
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tdisplay_content TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 2125
		ensureMessageDisplayContentColumn() -- 2135
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 2136
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 2137
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2154
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2155
	end -- 2155
	DB:exec("DROP TABLE IF EXISTS AgentQuestionnaire;") -- 2159
end -- 2159
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2302
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2302
		return {success = false, message = "invalid projectRoot"} -- 2304
	end -- 2304
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2306
	for ____, row in ipairs(rows) do -- 2307
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2308
		if sessionId > 0 then -- 2308
			deleteSessionRecords(sessionId) -- 2310
		end -- 2310
	end -- 2310
	return {success = true, deleted = #rows} -- 2313
end -- 2302
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2316
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2316
		return {success = false, message = "invalid projectRoot"} -- 2318
	end -- 2318
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2320
	local renamed = 0 -- 2321
	for ____, row in ipairs(rows) do -- 2322
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2323
		local projectRoot = toStr(row[2]) -- 2324
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2325
		if sessionId > 0 and nextProjectRoot then -- 2325
			DB:exec( -- 2327
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2327
				{ -- 2329
					nextProjectRoot, -- 2329
					Path:getFilename(nextProjectRoot), -- 2329
					now(), -- 2329
					sessionId -- 2329
				} -- 2329
			) -- 2329
			renamed = renamed + 1 -- 2331
		end -- 2331
	end -- 2331
	return {success = true, renamed = renamed} -- 2334
end -- 2316
function ____exports.getSession(sessionId) -- 2337
	local session = getSessionItem(sessionId) -- 2338
	if not session then -- 2338
		return {success = false, message = "session not found"} -- 2340
	end -- 2340
	local restored = restorePendingQuestionnaireState(session) -- 2342
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2343
	local relatedSessions = listRelatedSessions(sessionId) -- 2344
	sanitizeStoredSteps(sessionId) -- 2345
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2346
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2353
	local ____relatedSessions_59 = relatedSessions -- 2364
	local ____temp_58 -- 2365
	if normalizedSession.kind == "sub" then -- 2365
		____temp_58 = getSessionSpawnInfo(normalizedSession) -- 2365
	else -- 2365
		____temp_58 = nil -- 2365
	end -- 2365
	return { -- 2361
		success = true, -- 2362
		session = normalizedSession, -- 2363
		relatedSessions = ____relatedSessions_59, -- 2364
		spawnInfo = ____temp_58, -- 2365
		messages = __TS__ArrayMap( -- 2366
			messages, -- 2366
			function(____, row) return rowToMessage(row) end -- 2366
		), -- 2366
		steps = __TS__ArrayMap( -- 2367
			steps, -- 2367
			function(____, row) return rowToStep(row) end -- 2367
		), -- 2367
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2368
		pendingQuestionnaire = restored.questionnaire, -- 2369
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2370
	} -- 2370
end -- 2337
function ____exports.setWorkMode(sessionId, workMode) -- 2375
	local session = getSessionItem(sessionId) -- 2376
	if not session then -- 2376
		return {success = false, message = "session not found"} -- 2377
	end -- 2377
	if session.kind ~= "main" then -- 2377
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2378
	end -- 2378
	if workMode ~= "code" and workMode ~= "plan" then -- 2378
		return {success = false, message = "invalid work mode"} -- 2379
	end -- 2379
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2380
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2380
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2382
	end -- 2382
	if getPendingQuestionnaire(sessionId) then -- 2382
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2385
	end -- 2385
	if normalizedSession.workMode ~= workMode then -- 2385
		DB:exec( -- 2388
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2388
			{ -- 2388
				workMode, -- 2388
				now(), -- 2388
				sessionId -- 2388
			} -- 2388
		) -- 2388
	end -- 2388
	local updated = getSessionItem(sessionId) -- 2390
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2391
	return { -- 2392
		success = true, -- 2392
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2392
	} -- 2392
end -- 2375
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2598
	local session = getSessionItem(sessionId) -- 2599
	if not session then -- 2599
		return {success = false, message = "session not found"} -- 2601
	end -- 2601
	if getPendingQuestionnaire(sessionId) then -- 2601
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2603
	end -- 2603
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2603
		return {success = false, message = "session task is finalizing"} -- 2605
	end -- 2605
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2605
		return {success = false, message = "session task is still stopping"} -- 2608
	end -- 2608
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2608
		return {success = false, message = "session task is not continuable"} -- 2611
	end -- 2611
	if session.currentTaskId == nil then -- 2611
		return {success = false, message = "session task not found"} -- 2614
	end -- 2614
	local taskId = session.currentTaskId -- 2616
	return startPromptTask( -- 2617
		session, -- 2618
		"", -- 2619
		nil, -- 2620
		normalizeDisabledAgentTools(disabledAgentTools), -- 2621
		{ -- 2622
			workMode = session.workMode, -- 2623
			persistUserMessage = false, -- 2624
			resumeConversation = true, -- 2625
			existingTaskId = taskId, -- 2626
			initialStep = math.max( -- 2627
				0, -- 2627
				getNextStepNumber(session.id, taskId) - 1 -- 2627
			), -- 2627
			initialAgentStepCount = 0, -- 2628
			llmConfigId = llmConfigId -- 2629
		} -- 2629
	) -- 2629
end -- 2598
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2768
	local session = getSessionItem(sessionId) -- 2769
	if not session then -- 2769
		return {success = false, message = "session not found"} -- 2771
	end -- 2771
	if session.kind ~= "sub" then -- 2771
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2774
	end -- 2774
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2774
		return {success = false, message = "session task is finalizing"} -- 2777
	end -- 2777
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2779
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2779
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2784
	end -- 2784
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2784
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2787
	end -- 2787
	local disabledAgentTools = __TS__ArrayFilter( -- 2789
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2789
		function(____, tool) return tool ~= "finish" end -- 2790
	) -- 2790
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2791
	return startPromptTask( -- 2794
		session, -- 2794
		prompt, -- 2794
		nil, -- 2794
		disabledAgentTools, -- 2794
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2794
	) -- 2794
end -- 2768
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2801
	local session = getSessionItem(sessionId) -- 2802
	if not session then -- 2802
		return {success = false, message = "session not found"} -- 2804
	end -- 2804
	if getPendingQuestionnaire(sessionId) then -- 2804
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2806
	end -- 2806
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2806
		return {success = false, message = "session task is finalizing"} -- 2808
	end -- 2808
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2808
		return {success = false, message = "session task is still running"} -- 2811
	end -- 2811
	local message = getMessageItem(messageId) -- 2813
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2813
		return {success = false, message = "message not found"} -- 2815
	end -- 2815
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2817
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2823
	if latestUserMessageId ~= messageId then -- 2823
		return {success = false, message = "only the latest user prompt can be edited"} -- 2825
	end -- 2825
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2827
	if normalizedPrompt == "" then -- 2827
		return {success = false, message = "prompt is empty"} -- 2829
	end -- 2829
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2831
	if session.workMode ~= nextWorkMode then -- 2831
		DB:exec( -- 2833
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2833
			{ -- 2833
				nextWorkMode, -- 2833
				now(), -- 2833
				session.id -- 2833
			} -- 2833
		) -- 2833
		session.workMode = nextWorkMode -- 2834
	end -- 2834
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2836
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2837
	local result = startPromptTask( -- 2838
		session, -- 2838
		normalizedPrompt, -- 2838
		messageId, -- 2838
		normalizeDisabledAgentTools(disabledAgentTools), -- 2838
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2838
	) -- 2838
	if result.success and #removedStepIds > 0 then -- 2838
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2840
	end -- 2840
	return result -- 2842
end -- 2801
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2847
	if status == "dismissed" then -- 2847
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2853
	end -- 2853
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2855
end -- 2847
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2858
	if status == "dismissed" then -- 2858
		return { -- 2864
			success = true, -- 2865
			status = "dismissed", -- 2866
			source = "user", -- 2867
			questionnaireId = questionnaire.id, -- 2868
			title = questionnaire.schema.title, -- 2869
			answers = {}, -- 2870
			responses = {}, -- 2871
			displayText = "用户关闭了调查问卷，未作答。", -- 2872
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2873
		} -- 2873
	end -- 2873
	local responses = {} -- 2876
	do -- 2876
		local i = 0 -- 2877
		while i < #questionnaire.schema.questions do -- 2877
			do -- 2877
				local question = questionnaire.schema.questions[i + 1] -- 2878
				local answer = __TS__ArrayFind( -- 2879
					answers, -- 2879
					function(____, item) return item.questionId == question.id end -- 2879
				) -- 2879
				if not answer or answer.status == "skipped" then -- 2879
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2881
					goto __continue440 -- 2886
				end -- 2886
				local selectedOptionLabels = {} -- 2888
				do -- 2888
					local j = 0 -- 2889
					while j < #(answer.selectedOptionIds or ({})) do -- 2889
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2890
						local option = __TS__ArrayFind( -- 2891
							question.options or ({}), -- 2891
							function(____, item) return item.id == optionId end -- 2891
						) -- 2891
						if option then -- 2891
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2892
						end -- 2892
						j = j + 1 -- 2889
					end -- 2889
				end -- 2889
				responses[#responses + 1] = { -- 2894
					questionId = question.id, -- 2895
					prompt = question.prompt, -- 2896
					status = "answered", -- 2897
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2898
					selectedOptionLabels = selectedOptionLabels, -- 2899
					otherText = answer.otherText, -- 2900
					text = answer.text -- 2901
				} -- 2901
			end -- 2901
			::__continue440:: -- 2901
			i = i + 1 -- 2877
		end -- 2877
	end -- 2877
	return { -- 2904
		success = true, -- 2905
		status = "answered", -- 2906
		source = "user", -- 2907
		questionnaireId = questionnaire.id, -- 2908
		title = questionnaire.schema.title, -- 2909
		answers = answers, -- 2910
		responses = responses, -- 2911
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2912
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2913
	} -- 2913
end -- 2858
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2939
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2945
	local persisted = storage:readSessionState() -- 2946
	local messages = __TS__ArraySlice(persisted.messages) -- 2947
	local toolResultIndex = -1 -- 2948
	local existingResult -- 2949
	do -- 2949
		local i = #messages - 1 -- 2950
		while i >= 0 do -- 2950
			do -- 2950
				local message = messages[i + 1] -- 2951
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2951
					goto __continue460 -- 2952
				end -- 2952
				local decoded = safeJsonDecode(message.content) -- 2953
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2953
					goto __continue460 -- 2954
				end -- 2954
				local row = decoded -- 2955
				if row.questionnaireId ~= questionnaire.id then -- 2955
					goto __continue460 -- 2956
				end -- 2956
				toolResultIndex = i -- 2957
				existingResult = row -- 2958
				break -- 2959
			end -- 2959
			::__continue460:: -- 2959
			i = i - 1 -- 2950
		end -- 2950
	end -- 2950
	if toolResultIndex < 0 then -- 2950
		return {success = false, message = "matching ask_user tool result not found"} -- 2962
	end -- 2962
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2964
	local guidance = {} -- 2965
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2965
		guidance[#guidance + 1] = existingResult.guidance -- 2967
	end -- 2967
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2967
		guidance[#guidance + 1] = result.guidance -- 2970
	end -- 2970
	result.guidance = table.concat(guidance, "\n") -- 2972
	messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2973
		{}, -- 2973
		messages[toolResultIndex + 1], -- 2974
		{content = encodeJson(result)} -- 2973
	) -- 2973
	local pairStartIndex = toolResultIndex -- 2978
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2979
	if toolCallId and toolCallId ~= "" then -- 2979
		do -- 2979
			local i = toolResultIndex - 1 -- 2981
			while i >= 0 do -- 2981
				do -- 2981
					local message = messages[i + 1] -- 2982
					if message.role ~= "assistant" or not message.tool_calls then -- 2982
						goto __continue469 -- 2983
					end -- 2983
					if __TS__ArraySome( -- 2983
						message.tool_calls, -- 2984
						function(____, call) return call.id == toolCallId end -- 2984
					) then -- 2984
						pairStartIndex = i -- 2985
						break -- 2986
					end -- 2986
				end -- 2986
				::__continue469:: -- 2986
				i = i - 1 -- 2981
			end -- 2981
		end -- 2981
	end -- 2981
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2990
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2993
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2997
	upsertStep( -- 2999
		session.id, -- 2999
		questionnaire.taskId, -- 2999
		questionnaire.step, -- 2999
		"ask_user", -- 2999
		{status = "DONE", result = result} -- 2999
	) -- 2999
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3003
	upsertStep( -- 3004
		session.id, -- 3004
		questionnaire.taskId, -- 3004
		answerStep, -- 3004
		"questionnaire_answer", -- 3004
		{status = "DONE", result = result} -- 3004
	) -- 3004
	return {success = true, answerStep = answerStep, result = result} -- 3008
end -- 2939
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId) -- 3011
	local session = getSessionItem(sessionId) -- 3012
	if not session then -- 3012
		return {success = false, message = "session not found"} -- 3013
	end -- 3013
	if session.kind ~= "main" then -- 3013
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3014
	end -- 3014
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3015
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3015
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3017
	end -- 3017
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3019
	if not llmConfigRes.success then -- 3019
		return {success = false, message = llmConfigRes.message} -- 3020
	end -- 3020
	if not removePendingQuestionnaire(session) then -- 3020
		return {success = false, message = "failed to consume questionnaire file"} -- 3021
	end -- 3021
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3022
	if not replaced.success then -- 3022
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3024
		return replaced -- 3025
	end -- 3025
	local t = now() -- 3027
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3028
	session.workMode = "plan" -- 3029
	local result = startPromptTask( -- 3030
		session, -- 3030
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3030
		nil, -- 3030
		{}, -- 3030
		{ -- 3030
			workMode = "plan", -- 3031
			persistUserMessage = false, -- 3032
			resumeConversation = true, -- 3033
			existingTaskId = questionnaire.taskId, -- 3034
			initialStep = replaced.answerStep, -- 3035
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3036
			llmConfig = llmConfigRes.config -- 3037
		} -- 3037
	) -- 3037
	if not result.success then -- 3037
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3040
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3041
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3042
		emitAgentSessionPatch( -- 3043
			session.id, -- 3043
			{ -- 3043
				session = getSessionItem(session.id), -- 3044
				pendingQuestionnaire = questionnaire -- 3045
			} -- 3045
		) -- 3045
		return result -- 3047
	end -- 3047
	emitAgentSessionPatch( -- 3049
		sessionId, -- 3049
		{ -- 3049
			session = getSessionItem(sessionId), -- 3050
			pendingQuestionnaire = false -- 3051
		} -- 3051
	) -- 3051
	return result -- 3053
end -- 3011
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 3056
	local session = getSessionItem(sessionId) -- 3057
	if not session then -- 3057
		return {success = false, message = "session not found"} -- 3058
	end -- 3058
	if session.kind ~= "main" then -- 3058
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3059
	end -- 3059
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3060
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3060
		return {success = false, message = "pending questionnaire not found"} -- 3061
	end -- 3061
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3062
	if not validated.success then -- 3062
		return validated -- 3063
	end -- 3063
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3064
	if not llmConfigRes.success then -- 3064
		return {success = false, message = llmConfigRes.message} -- 3065
	end -- 3065
	local t = now() -- 3066
	if not removePendingQuestionnaire(session) then -- 3066
		return {success = false, message = "failed to consume questionnaire file"} -- 3067
	end -- 3067
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3068
	if not replaced.success then -- 3068
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3070
		return replaced -- 3071
	end -- 3071
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3073
	session.workMode = "plan" -- 3074
	local result = startPromptTask( -- 3075
		session, -- 3075
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3075
		nil, -- 3075
		{}, -- 3075
		{ -- 3075
			workMode = "plan", -- 3076
			persistUserMessage = false, -- 3077
			resumeConversation = true, -- 3078
			existingTaskId = questionnaire.taskId, -- 3079
			initialStep = replaced.answerStep, -- 3080
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3081
			llmConfig = llmConfigRes.config -- 3082
		} -- 3082
	) -- 3082
	if not result.success then -- 3082
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3085
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3086
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3087
		emitAgentSessionPatch( -- 3088
			session.id, -- 3088
			{ -- 3088
				session = getSessionItem(session.id), -- 3089
				pendingQuestionnaire = questionnaire -- 3090
			} -- 3090
		) -- 3090
		return result -- 3092
	end -- 3092
	emitAgentSessionPatch( -- 3094
		sessionId, -- 3094
		{ -- 3094
			session = getSessionItem(sessionId), -- 3095
			pendingQuestionnaire = false -- 3096
		} -- 3096
	) -- 3096
	return result -- 3098
end -- 3056
function ____exports.stopSessionTask(sessionId) -- 3101
	local session = getSessionItem(sessionId) -- 3102
	if not session or session.currentTaskId == nil then -- 3102
		return {success = false, message = "session task not found"} -- 3104
	end -- 3104
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3104
		return {success = false, message = "session task is finalizing"} -- 3107
	end -- 3107
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3109
	local stopToken = activeStopTokens[session.currentTaskId] -- 3110
	if not stopToken then -- 3110
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3110
			return {success = true, recovered = true} -- 3113
		end -- 3113
		return {success = false, message = "task is not running"} -- 3115
	end -- 3115
	if stopToken.stopped then -- 3115
		return {success = true, stopping = true} -- 3118
	end -- 3118
	stopToken.stopped = true -- 3120
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3121
	return {success = true, stopping = true} -- 3125
end -- 3101
function ____exports.getCurrentTaskId(sessionId) -- 3128
	local ____opt_120 = getSessionItem(sessionId) -- 3128
	return ____opt_120 and ____opt_120.currentTaskId -- 3129
end -- 3128
function ____exports.listRunningSessions() -- 3132
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3133
	local sessions = {} -- 3140
	do -- 3140
		local i = 0 -- 3141
		while i < #rows do -- 3141
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3142
			if session.currentTaskStatus == "RUNNING" then -- 3142
				sessions[#sessions + 1] = session -- 3144
			end -- 3144
			i = i + 1 -- 3141
		end -- 3141
	end -- 3141
	return {success = true, sessions = sessions} -- 3147
end -- 3132
return ____exports -- 3132