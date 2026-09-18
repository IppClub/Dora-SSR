-- [ts]: Session.ts
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
local getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, SESSION_SELECT_COLUMNS, now -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____SessionEvents = require("Agent.Runtime.SessionEvents") -- 3
local publishSessionPatch = ____SessionEvents.publishSessionPatch -- 3
local ____TaskAdmission = require("Agent.Runtime.TaskAdmission") -- 4
local holdProjectTaskAdmission = ____TaskAdmission.holdProjectTaskAdmission -- 4
local isProjectTaskAdmissionClosed = ____TaskAdmission.isProjectTaskAdmissionClosed -- 4
local ____DoraAgent = require("Agent.DoraAgent") -- 6
local runCodingAgent = ____DoraAgent.runCodingAgent -- 6
local truncateAgentUserPrompt = ____DoraAgent.truncateAgentUserPrompt -- 6
local AgentConfig = require("Agent.Config") -- 9
local AgentToolRegistry = require("Agent.Tool.Registry") -- 10
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 11
local Tools = require("Agent.Tools") -- 12
local ____Database = require("Agent.Storage.Database") -- 13
local TABLE_SESSION = ____Database.TABLE_SESSION -- 14
local TABLE_MESSAGE = ____Database.TABLE_MESSAGE -- 15
local TABLE_STEP = ____Database.TABLE_STEP -- 16
local TABLE_TASK = ____Database.TABLE_TASK -- 17
local TABLE_TASK_REFERENCE = ____Database.TABLE_TASK_REFERENCE -- 18
local addTaskReference = ____Database.addTaskReference -- 19
local cleanupTaskHeavyData = ____Database.cleanupTaskHeavyData -- 20
local getSessionOperableTaskIds = ____Database.getSessionOperableTaskIds -- 21
local requireAgentStorage = ____Database.requireAgentStorage -- 22
local ____Memory = require("Agent.Memory") -- 24
local DualLayerStorage = ____Memory.DualLayerStorage -- 24
local ____Utils = require("Agent.Utils") -- 25
local Log = ____Utils.Log -- 25
local getLLMConfig = ____Utils.getLLMConfig -- 25
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 25
local safeJsonDecode = ____Utils.safeJsonDecode -- 25
local safeJsonEncode = ____Utils.safeJsonEncode -- 25
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 25
local validateAgentLLMConfig = ____Utils.validateAgentLLMConfig -- 25
local ____Questionnaire = require("Agent.Questionnaire") -- 29
local validateQuestionnaireAnswers = ____Questionnaire.validateQuestionnaireAnswers -- 29
local ____Support = require("Agent.Storage.Support") -- 31
local getLastInsertRowId = ____Support.getLastInsertRowId -- 31
local queryOne = ____Support.queryOne -- 31
local queryRows = ____Support.queryRows -- 31
local toStr = ____Support.toStr -- 31
function getDefaultUseChineseResponse() -- 337
	local zh = string.match(App.locale, "^zh") -- 338
	return zh ~= nil -- 339
end -- 339
function encodeJson(value) -- 342
	local text = safeJsonEncode(value) -- 343
	return text or "" -- 344
end -- 344
function decodeJsonObject(text) -- 347
	if not text or text == "" then -- 347
		return nil -- 348
	end -- 348
	local value = safeJsonDecode(text) -- 349
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 349
		return value -- 351
	end -- 351
	return nil -- 353
end -- 353
function decodeJsonFiles(text) -- 356
	if not text or text == "" then -- 356
		return nil -- 357
	end -- 357
	local value = safeJsonDecode(text) -- 358
	if not value or not __TS__ArrayIsArray(value) then -- 358
		return nil -- 359
	end -- 359
	local files = {} -- 360
	do -- 360
		local i = 0 -- 361
		while i < #value do -- 361
			do -- 361
				local item = value[i + 1] -- 362
				if type(item) ~= "table" then -- 362
					goto __continue12 -- 363
				end -- 363
				files[#files + 1] = { -- 364
					path = sanitizeUTF8(toStr(item.path)), -- 365
					op = sanitizeUTF8(toStr(item.op)) -- 366
				} -- 366
			end -- 366
			::__continue12:: -- 366
			i = i + 1 -- 361
		end -- 361
	end -- 361
	return files -- 369
end -- 369
function decodeChangeSetSummary(value) -- 372
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 372
		return nil -- 373
	end -- 373
	local row = value -- 374
	if row.success ~= true then -- 374
		return nil -- 375
	end -- 375
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 376
	if taskId <= 0 then -- 376
		return nil -- 377
	end -- 377
	local files = {} -- 378
	if __TS__ArrayIsArray(row.files) then -- 378
		do -- 378
			local i = 0 -- 380
			while i < #row.files do -- 380
				do -- 380
					local file = row.files[i + 1] -- 381
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 381
						goto __continue20 -- 382
					end -- 382
					local fileRow = file -- 383
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 384
					if path == "" then -- 384
						goto __continue20 -- 385
					end -- 385
					local checkpointIds = {} -- 386
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 386
						do -- 386
							local j = 0 -- 388
							while j < #fileRow.checkpointIds do -- 388
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 389
								if checkpointId > 0 then -- 389
									checkpointIds[#checkpointIds + 1] = checkpointId -- 390
								end -- 390
								j = j + 1 -- 388
							end -- 388
						end -- 388
					end -- 388
					local op = toStr(fileRow.op) -- 393
					files[#files + 1] = { -- 394
						path = path, -- 395
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 396
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 397
						checkpointIds = checkpointIds -- 398
					} -- 398
				end -- 398
				::__continue20:: -- 398
				i = i + 1 -- 380
			end -- 380
		end -- 380
	end -- 380
	return { -- 402
		success = true, -- 403
		taskId = taskId, -- 404
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 405
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 406
		files = files, -- 407
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 408
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 409
	} -- 409
end -- 409
function decodeHandoffEvidence(value) -- 413
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 413
		return nil -- 414
	end -- 414
	local row = value -- 415
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 416
		__TS__ArrayFilter( -- 417
			row.modifiedFiles, -- 417
			function(____, item) return type(item) == "string" end -- 417
		), -- 417
		function(____, item) return sanitizeUTF8(item) end -- 417
	) or ({}) -- 417
	local lastBuild = nil -- 419
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 419
		local build = row.lastBuild -- 421
		lastBuild = { -- 422
			result = build.result == "passed" and "passed" or "failed", -- 423
			path = sanitizeUTF8(toStr(build.path)), -- 424
			evidence = takeUtf8Head( -- 425
				sanitizeUTF8(toStr(build.evidence)), -- 425
				600 -- 425
			) -- 425
		} -- 425
	end -- 425
	local commands = {} -- 428
	if __TS__ArrayIsArray(row.commands) then -- 428
		do -- 428
			local i = 0 -- 430
			while i < #row.commands and #commands < 8 do -- 430
				do -- 430
					local raw = row.commands[i + 1] -- 431
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 431
						goto __continue34 -- 432
					end -- 432
					local item = raw -- 433
					commands[#commands + 1] = { -- 434
						mode = sanitizeUTF8(toStr(item.mode)), -- 435
						command = takeUtf8Head( -- 436
							sanitizeUTF8(toStr(item.command)), -- 436
							600 -- 436
						), -- 436
						result = item.result == "passed" and "passed" or "failed", -- 437
						evidence = takeUtf8Head( -- 438
							sanitizeUTF8(toStr(item.evidence)), -- 438
							600 -- 438
						) -- 438
					} -- 438
				end -- 438
				::__continue34:: -- 438
				i = i + 1 -- 430
			end -- 430
		end -- 430
	end -- 430
	local authoritativeSources = {} -- 442
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 442
		do -- 442
			local i = 0 -- 444
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 444
				do -- 444
					local raw = row.authoritativeSources[i + 1] -- 445
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 445
						goto __continue38 -- 446
					end -- 446
					local item = raw -- 447
					authoritativeSources[#authoritativeSources + 1] = { -- 448
						tool = "search_dora_doc", -- 449
						query = takeUtf8Head( -- 450
							sanitizeUTF8(toStr(item.query)), -- 450
							300 -- 450
						), -- 450
						source = sanitizeUTF8(toStr(item.source)), -- 451
						result = item.result == "passed" and "passed" or "failed" -- 452
					} -- 452
				end -- 452
				::__continue38:: -- 452
				i = i + 1 -- 444
			end -- 444
		end -- 444
	end -- 444
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 456
end -- 456
function takeUtf8Head(text, maxChars) -- 459
	if maxChars <= 0 or text == "" then -- 459
		return "" -- 460
	end -- 460
	local nextPos = utf8.offset(text, maxChars + 1) -- 461
	if nextPos == nil then -- 461
		return text -- 462
	end -- 462
	return string.sub(text, 1, nextPos - 1) -- 463
end -- 463
function normalizeMemoryEntryEvidence(value) -- 466
	local evidence = {} -- 467
	if not __TS__ArrayIsArray(value) then -- 467
		return evidence -- 468
	end -- 468
	do -- 468
		local i = 0 -- 469
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 469
			do -- 469
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 470
				if item == "" then -- 470
					goto __continue46 -- 471
				end -- 471
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 471
					evidence[#evidence + 1] = item -- 473
				end -- 473
			end -- 473
			::__continue46:: -- 473
			i = i + 1 -- 469
		end -- 469
	end -- 469
	return evidence -- 476
end -- 476
function decodeSubAgentMemoryEntry(value) -- 479
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 479
		return nil -- 480
	end -- 480
	local row = value -- 481
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 482
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 483
	local content = takeUtf8Head( -- 484
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 484
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 484
	) -- 484
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 484
		return nil -- 485
	end -- 485
	return { -- 486
		sourceSessionId = sourceSessionId, -- 487
		sourceTaskId = sourceTaskId, -- 488
		content = content, -- 489
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 490
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 491
	} -- 491
end -- 491
function getTaskChangeSetSummary(taskId) -- 495
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 496
	return summary.success and summary or nil -- 497
end -- 497
function summarizeHandoffResult(result) -- 500
	local candidates = {result.output, result.message, result.state, result.phase} -- 501
	do -- 501
		local i = 0 -- 502
		while i < #candidates do -- 502
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 503
			if text ~= "" then -- 503
				return takeUtf8Head(text, 600) -- 504
			end -- 504
			i = i + 1 -- 502
		end -- 502
	end -- 502
	local messages = result.messages -- 506
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 506
		local parts = {} -- 508
		do -- 508
			local i = 0 -- 509
			while i < #messages and #parts < 4 do -- 509
				do -- 509
					local row = messages[i + 1] -- 510
					if not row or type(row) ~= "table" then -- 510
						goto __continue59 -- 511
					end -- 511
					local item = row -- 512
					local ____sanitizeUTF8_3 = sanitizeUTF8 -- 513
					local ____toStr_2 = toStr -- 513
					local ____item_message_0 = item.message -- 513
					if ____item_message_0 == nil then -- 513
						____item_message_0 = item.error -- 513
					end -- 513
					local ____item_message_0_1 = ____item_message_0 -- 513
					if ____item_message_0_1 == nil then -- 513
						____item_message_0_1 = item.file -- 513
					end -- 513
					local text = __TS__StringTrim(____sanitizeUTF8_3(____toStr_2(____item_message_0_1))) -- 513
					if text ~= "" then -- 513
						parts[#parts + 1] = text -- 514
					end -- 514
				end -- 514
				::__continue59:: -- 514
				i = i + 1 -- 509
			end -- 509
		end -- 509
		if #parts > 0 then -- 509
			return takeUtf8Head( -- 516
				table.concat(parts, "; "), -- 516
				600 -- 516
			) -- 516
		end -- 516
	end -- 516
	return result.success == true and "tool result success=true" or "tool result success=false" -- 518
end -- 518
function getTaskHandoffEvidence(taskId, changeSet) -- 521
	local ____opt_4 = changeSet -- 521
	local evidence = { -- 522
		modifiedFiles = ____opt_4 and __TS__ArrayMap( -- 523
			changeSet and changeSet.files, -- 523
			function(____, item) return item.path end -- 523
		) or ({}), -- 523
		commands = {}, -- 524
		authoritativeSources = {} -- 525
	} -- 525
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 527
	do -- 527
		local i = 0 -- 532
		while i < #rows do -- 532
			local tool = toStr(rows[i + 1][1]) -- 533
			local status = toStr(rows[i + 1][2]) -- 534
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 535
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 536
			local passed = status == "DONE" and result.success == true -- 537
			if tool == "build" then -- 537
				evidence.lastBuild = { -- 539
					result = passed and "passed" or "failed", -- 540
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 541
					evidence = summarizeHandoffResult(result) -- 542
				} -- 542
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 542
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 545
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 546
				local ____evidence_commands_8 = evidence.commands -- 546
				____evidence_commands_8[#____evidence_commands_8 + 1] = { -- 547
					mode = mode, -- 548
					command = takeUtf8Head( -- 549
						__TS__StringTrim(sanitizeUTF8(command)), -- 549
						600 -- 549
					), -- 549
					result = passed and "passed" or "failed", -- 550
					evidence = summarizeHandoffResult(result) -- 551
				} -- 551
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 551
				local ____evidence_authoritativeSources_9 = evidence.authoritativeSources -- 551
				____evidence_authoritativeSources_9[#____evidence_authoritativeSources_9 + 1] = { -- 554
					tool = "search_dora_doc", -- 555
					query = takeUtf8Head( -- 556
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 556
						300 -- 556
					), -- 556
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 557
					result = passed and "passed" or "failed" -- 558
				} -- 558
			end -- 558
			i = i + 1 -- 532
		end -- 532
	end -- 532
	return evidence -- 562
end -- 562
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 565
	local lastBuild = evidence.lastBuild -- 569
	if not lastBuild or lastBuild.result ~= "failed" then -- 569
		return completion -- 570
	end -- 570
	local validation = __TS__ArraySlice(completion.validation) -- 571
	local foundBuild = false -- 572
	do -- 572
		local i = 0 -- 573
		while i < #validation do -- 573
			do -- 573
				if validation[i + 1].kind ~= "build" then -- 573
					goto __continue73 -- 574
				end -- 574
				foundBuild = true -- 575
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 576
			end -- 576
			::__continue73:: -- 576
			i = i + 1 -- 573
		end -- 573
	end -- 573
	if not foundBuild then -- 573
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 583
	end -- 583
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 585
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 586
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 586
		knownIssues[#knownIssues + 1] = issue -- 587
	end -- 587
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 588
end -- 588
function isValidProjectRoot(path) -- 596
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 597
end -- 597
function rowToSession(row) -- 600
	return { -- 601
		id = row[1], -- 602
		projectRoot = toStr(row[2]), -- 603
		title = toStr(row[3]), -- 604
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 605
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 606
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 607
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 608
		status = toStr(row[8]), -- 609
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 610
		currentTaskStatus = toStr(row[10]), -- 611
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 612
		createdAt = row[11], -- 613
		updatedAt = row[12], -- 614
		metrics = decodeJsonObject(toStr(row[13])), -- 615
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 616
	} -- 616
end -- 616
function rowToMessage(row) -- 620
	local message = { -- 621
		id = row[1], -- 622
		sessionId = row[2], -- 623
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 624
		role = toStr(row[4]), -- 625
		content = toStr(row[5]), -- 626
		createdAt = row[7], -- 627
		updatedAt = row[8] -- 628
	} -- 628
	local displayContent = toStr(row[6]) -- 630
	if displayContent ~= "" then -- 630
		message.displayContent = displayContent -- 631
	end -- 631
	return message -- 632
end -- 632
function rowToStep(row) -- 635
	return { -- 636
		id = row[1], -- 637
		sessionId = row[2], -- 638
		taskId = row[3], -- 639
		step = row[4], -- 640
		tool = toStr(row[5]), -- 641
		status = toStr(row[6]), -- 642
		reason = toStr(row[7]), -- 643
		reasoningContent = toStr(row[8]), -- 644
		params = decodeJsonObject(toStr(row[9])), -- 645
		result = decodeJsonObject(toStr(row[10])), -- 646
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 647
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 648
		files = decodeJsonFiles(toStr(row[13])), -- 649
		createdAt = row[14], -- 650
		updatedAt = row[15] -- 651
	} -- 651
end -- 651
function getQuestionnairePath(projectRoot) -- 655
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 656
end -- 656
function decodeQuestionnaireFile(text) -- 659
	local value = decodeJsonObject(text) -- 660
	if not value then -- 660
		return nil -- 661
	end -- 661
	local schema = value.schema -- 662
	local id = type(value.id) == "number" and value.id or 0 -- 663
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 664
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 665
	local step = type(value.step) == "number" and value.step or 0 -- 666
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 667
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 667
		return nil -- 669
	end -- 669
	return { -- 671
		id = id, -- 671
		sessionId = sessionId, -- 671
		taskId = taskId, -- 671
		step = step, -- 671
		status = "PENDING", -- 671
		schema = schema, -- 671
		createdAt = createdAt -- 671
	} -- 671
end -- 671
function getPendingQuestionnaire(sessionId) -- 674
	local session = getSessionItem(sessionId) -- 675
	if not session or session.kind ~= "main" then -- 675
		return nil -- 676
	end -- 676
	local path = getQuestionnairePath(session.projectRoot) -- 677
	if not Content:exist(path) then -- 677
		return nil -- 678
	end -- 678
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 679
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 680
end -- 680
function restorePendingQuestionnaireState(session) -- 683
	local questionnaire = getPendingQuestionnaire(session.id) -- 684
	if not questionnaire then -- 684
		return {session = session} -- 685
	end -- 685
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 685
		local t = now() -- 692
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 693
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 699
		local restored = getSessionItem(session.id) -- 700
		if restored then -- 700
			session = restored -- 701
		end -- 701
	end -- 701
	return {session = session, questionnaire = questionnaire} -- 703
end -- 703
function savePendingQuestionnaire(projectRoot, questionnaire) -- 706
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 707
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 707
		return false -- 708
	end -- 708
	local path = getQuestionnairePath(projectRoot) -- 709
	local tempPath = path .. ".tmp" -- 710
	local backupPath = path .. ".bak" -- 711
	Content:remove(tempPath) -- 712
	Content:remove(backupPath) -- 713
	if not Content:save( -- 713
		tempPath, -- 714
		encodeJson(questionnaire) -- 714
	) then -- 714
		return false -- 714
	end -- 714
	local hadOriginal = Content:exist(path) -- 715
	if hadOriginal and not Content:move(path, backupPath) then -- 715
		Content:remove(tempPath) -- 717
		return false -- 718
	end -- 718
	if Content:move(tempPath, path) then -- 718
		Content:remove(backupPath) -- 721
		Tools.sendWebIDEFileUpdate( -- 722
			path, -- 722
			true, -- 722
			encodeJson(questionnaire) -- 722
		) -- 722
		return true -- 723
	end -- 723
	Content:remove(tempPath) -- 725
	if hadOriginal and Content:exist(backupPath) then -- 725
		Content:move(backupPath, path) -- 727
	end -- 727
	return false -- 729
end -- 729
function removePendingQuestionnaire(session) -- 732
	local path = getQuestionnairePath(session.projectRoot) -- 733
	if not Content:exist(path) then -- 733
		return true -- 734
	end -- 734
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 735
	if questionnaire and questionnaire.sessionId ~= session.id then -- 735
		return false -- 736
	end -- 736
	if not Content:remove(path) then -- 736
		return false -- 737
	end -- 737
	Tools.sendWebIDEFileUpdate(path, false, "") -- 738
	return true -- 739
end -- 739
function publishQuestionnaire(request) -- 742
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 742
		local session = getSessionItem(request.sessionId) -- 748
		if not session or session.kind ~= "main" then -- 748
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 748
		end -- 748
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 750
		if Content:exist(pendingPath) then -- 750
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 750
		end -- 750
		local questionnaire = { -- 752
			id = request.taskId, -- 753
			sessionId = request.sessionId, -- 754
			taskId = request.taskId, -- 755
			step = request.step, -- 756
			status = "PENDING", -- 757
			schema = request.schema, -- 758
			createdAt = now() -- 759
		} -- 759
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 759
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 759
		end -- 759
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 759
	end) -- 759
end -- 759
function getMessageItem(messageId) -- 767
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 768
	return row and rowToMessage(row) or nil -- 774
end -- 774
function getStepItem(sessionId, taskId, step) -- 777
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 778
	return row and rowToStep(row) or nil -- 784
end -- 784
function deleteMessageSteps(sessionId, taskId) -- 787
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 788
	local ids = {} -- 793
	do -- 793
		local i = 0 -- 794
		while i < #rows do -- 794
			local row = rows[i + 1] -- 795
			if type(row[1]) == "number" then -- 795
				ids[#ids + 1] = row[1] -- 797
			end -- 797
			i = i + 1 -- 794
		end -- 794
	end -- 794
	if #ids > 0 then -- 794
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 801
	end -- 801
	return ids -- 807
end -- 807
function normalizeDisabledAgentTools(value) -- 810
	if not __TS__ArrayIsArray(value) then -- 810
		return {} -- 811
	end -- 811
	local tools = {} -- 812
	do -- 812
		local i = 0 -- 813
		while i < #value do -- 813
			do -- 813
				local name = value[i + 1] -- 814
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 814
					goto __continue117 -- 815
				end -- 815
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 815
					tools[#tools + 1] = name -- 816
				end -- 816
			end -- 816
			::__continue117:: -- 816
			i = i + 1 -- 813
		end -- 813
	end -- 813
	return tools -- 818
end -- 818
function normalizeWorkMode(value, fallback) -- 821
	if fallback == nil then -- 821
		fallback = "code" -- 821
	end -- 821
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 822
end -- 822
function getSessionRow(sessionId) -- 825
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 826
end -- 826
function getSessionItem(sessionId) -- 834
	local row = getSessionRow(sessionId) -- 835
	return row and rowToSession(row) or nil -- 836
end -- 836
function getTaskPrompt(taskId) -- 839
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 840
	if not row or type(row[1]) ~= "string" then -- 840
		return nil -- 841
	end -- 841
	return toStr(row[1]) -- 842
end -- 842
function getLatestMainSessionByProjectRoot(projectRoot) -- 845
	if not isValidProjectRoot(projectRoot) then -- 845
		return nil -- 846
	end -- 846
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 847
	return row and rowToSession(row) or nil -- 855
end -- 855
function countRunningSubSessions(rootSessionId) -- 858
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 859
	local count = 0 -- 866
	do -- 866
		local i = 0 -- 867
		while i < #rows do -- 867
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 868
			if session.currentTaskStatus == "RUNNING" then -- 868
				count = count + 1 -- 870
			end -- 870
			i = i + 1 -- 867
		end -- 867
	end -- 867
	return count -- 873
end -- 873
function deleteSessionRecords(sessionId, preserveArtifacts) -- 876
	if preserveArtifacts == nil then -- 876
		preserveArtifacts = false -- 876
	end -- 876
	local session = getSessionItem(sessionId) -- 877
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 878
	local taskIds = {} -- 886
	do -- 886
		local i = 0 -- 887
		while i < #taskRows do -- 887
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 888
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 888
				taskIds[#taskIds + 1] = taskId -- 890
				local stopToken = activeStopTokens[taskId] -- 891
				if stopToken ~= nil then -- 891
					stopToken.stopped = true -- 893
					stopToken.reason = "session deleted" -- 894
				end -- 894
			end -- 894
			i = i + 1 -- 887
		end -- 887
	end -- 887
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 898
	do -- 898
		local i = 0 -- 899
		while i < #children do -- 899
			local row = children[i + 1] -- 900
			if type(row[1]) == "number" and row[1] > 0 then -- 900
				deleteSessionRecords(row[1], preserveArtifacts) -- 902
			end -- 902
			i = i + 1 -- 899
		end -- 899
	end -- 899
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 905
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 906
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 907
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 908
	if session and session.kind == "main" then -- 908
		removePendingQuestionnaire(session) -- 910
	end -- 910
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 910
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 910
			Tools.sendWebIDERefreshTree() -- 914
		end -- 914
	end -- 914
	do -- 914
		local i = 0 -- 917
		while i < #taskIds do -- 917
			cleanupTaskHeavyData(taskIds[i + 1]) -- 918
			i = i + 1 -- 917
		end -- 917
	end -- 917
end -- 917
function getSessionRootId(session) -- 922
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 923
end -- 923
function getRootSessionItem(sessionId) -- 926
	local session = getSessionItem(sessionId) -- 927
	if not session then -- 927
		return nil -- 928
	end -- 928
	return getSessionItem(getSessionRootId(session)) or session -- 929
end -- 929
function listRelatedSessions(sessionId) -- 932
	local root = getRootSessionItem(sessionId) -- 933
	if not root then -- 933
		return {} -- 934
	end -- 934
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 935
	return __TS__ArrayMap( -- 944
		rows, -- 944
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 944
	) -- 944
end -- 944
function getSessionSpawnInfo(session) -- 947
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 948
	if not info then -- 948
		return nil -- 949
	end -- 949
	local ____temp_15 = type(info.sessionId) == "number" and info.sessionId or nil -- 951
	local ____temp_16 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 952
	local ____temp_17 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 953
	local ____temp_18 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 954
	local ____temp_19 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 955
	local ____temp_20 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 956
	local ____temp_21 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 957
	local ____temp_22 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 958
		__TS__ArrayFilter( -- 959
			info.filesHint, -- 959
			function(____, item) return type(item) == "string" end -- 959
		), -- 959
		function(____, item) return sanitizeUTF8(item) end -- 959
	) or nil -- 959
	local ____temp_23 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 961
	local ____temp_13 -- 964
	if info.success == true then -- 964
		____temp_13 = true -- 964
	else -- 964
		local ____temp_12 -- 964
		if info.success == false then -- 964
			____temp_12 = false -- 964
		else -- 964
			____temp_12 = nil -- 964
		end -- 964
		____temp_13 = ____temp_12 -- 964
	end -- 964
	local ____temp_14 -- 965
	if info.cleared == true then -- 965
		____temp_14 = true -- 965
	else -- 965
		____temp_14 = nil -- 965
	end -- 965
	return { -- 950
		sessionId = ____temp_15, -- 951
		rootSessionId = ____temp_16, -- 952
		parentSessionId = ____temp_17, -- 953
		title = ____temp_18, -- 954
		prompt = ____temp_19, -- 955
		goal = ____temp_20, -- 956
		expectedOutput = ____temp_21, -- 957
		filesHint = ____temp_22, -- 958
		status = ____temp_23, -- 961
		success = ____temp_13, -- 964
		cleared = ____temp_14, -- 965
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 966
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 967
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 968
		changeSet = decodeChangeSetSummary(info.changeSet), -- 969
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 970
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 971
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 972
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 973
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 976
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 977
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 978
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 979
	} -- 979
end -- 979
function ensureDirRecursive(dir) -- 996
	if not dir or dir == "" then -- 996
		return false -- 997
	end -- 997
	if Content:exist(dir) then -- 997
		return Content:isdir(dir) -- 998
	end -- 998
	local parent = Path:getPath(dir) -- 999
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 999
		if not ensureDirRecursive(parent) then -- 999
			return false -- 1002
		end -- 1002
	end -- 1002
	return Content:mkdir(dir) -- 1005
end -- 1005
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1008
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1009
	if not Content:exist(dir) then -- 1009
		ensureDirRecursive(dir) -- 1011
	end -- 1011
	local path = Path(dir, SPAWN_INFO_FILE) -- 1013
	local text = safeJsonEncode(value) -- 1014
	if not text then -- 1014
		return false -- 1015
	end -- 1015
	local content = text .. "\n" -- 1016
	if not Content:save(path, content) then -- 1016
		return false -- 1018
	end -- 1018
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1020
	return true -- 1021
end -- 1021
function readSpawnInfo(projectRoot, memoryScope) -- 1024
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1025
	if not Content:exist(path) then -- 1025
		return nil -- 1026
	end -- 1026
	local text = Content:load(path) -- 1027
	if not text or __TS__StringTrim(text) == "" then -- 1027
		return nil -- 1028
	end -- 1028
	local value = safeJsonDecode(text) -- 1029
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1029
		return value -- 1031
	end -- 1031
	return nil -- 1033
end -- 1033
function getArtifactRelativeDir(memoryScope) -- 1036
	return Path(".agent", memoryScope) -- 1037
end -- 1037
function getArtifactDir(projectRoot, memoryScope) -- 1040
	return Path( -- 1041
		projectRoot, -- 1041
		getArtifactRelativeDir(memoryScope) -- 1041
	) -- 1041
end -- 1041
function getResultRelativePath(memoryScope) -- 1044
	return Path( -- 1045
		getArtifactRelativeDir(memoryScope), -- 1045
		RESULT_FILE -- 1045
	) -- 1045
end -- 1045
function getResultPath(projectRoot, memoryScope) -- 1048
	return Path( -- 1049
		projectRoot, -- 1049
		getResultRelativePath(memoryScope) -- 1049
	) -- 1049
end -- 1049
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1052
	if not resultFilePath or resultFilePath == "" then -- 1052
		return "" -- 1053
	end -- 1053
	local path = Path(projectRoot, resultFilePath) -- 1054
	if not Content:exist(path) then -- 1054
		return "" -- 1055
	end -- 1055
	local text = sanitizeUTF8(Content:load(path)) -- 1056
	if not text or __TS__StringTrim(text) == "" then -- 1056
		return "" -- 1057
	end -- 1057
	local marker = "\n## Summary\n" -- 1058
	local start = string.find(text, marker, 1, true) -- 1059
	if start ~= nil then -- 1059
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1061
	end -- 1061
	return __TS__StringTrim(text) -- 1063
end -- 1063
function buildStructuredSubAgentMemoryEntry(record) -- 1066
	local hasPassedValidation = false -- 1067
	do -- 1067
		local i = 0 -- 1068
		while i < #record.completion.validation do -- 1068
			local result = record.completion.validation[i + 1].result -- 1069
			if result == "failed" then -- 1069
				return nil -- 1074
			end -- 1074
			if result == "passed" then -- 1074
				hasPassedValidation = true -- 1076
			end -- 1076
			i = i + 1 -- 1068
		end -- 1068
	end -- 1068
	if not hasPassedValidation then -- 1068
		return nil -- 1079
	end -- 1079
	local candidates = record.completion.learningCandidates -- 1080
	local claims = {} -- 1081
	local evidence = {} -- 1082
	do -- 1082
		local i = 0 -- 1083
		while i < #candidates do -- 1083
			do -- 1083
				local candidate = candidates[i + 1] -- 1084
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1084
					goto __continue188 -- 1085
				end -- 1085
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1086
				do -- 1086
					local j = 0 -- 1087
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1087
						local item = candidate.evidence[j + 1] -- 1088
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1088
							evidence[#evidence + 1] = item -- 1089
						end -- 1089
						j = j + 1 -- 1087
					end -- 1087
				end -- 1087
			end -- 1087
			::__continue188:: -- 1087
			i = i + 1 -- 1083
		end -- 1083
	end -- 1083
	local content = takeUtf8Head( -- 1092
		table.concat(claims, "\n"), -- 1092
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1092
	) -- 1092
	if content == "" then -- 1092
		return nil -- 1093
	end -- 1093
	return { -- 1094
		sourceSessionId = record.sessionId, -- 1095
		sourceTaskId = record.sourceTaskId, -- 1096
		content = content, -- 1097
		evidence = evidence, -- 1098
		createdAt = record.finishedAt -- 1099
	} -- 1099
end -- 1099
function containsNormalizedText(text, query) -- 1103
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1104
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1105
	if normalizedQuery == "" then -- 1105
		return true -- 1106
	end -- 1106
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1107
end -- 1107
function getSubAgentDisplayKey(item) -- 1110
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1116
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1117
	local label = goal ~= "" and goal or title -- 1118
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1119
end -- 1119
function writeSubAgentResultFile(session, record, resultText) -- 1122
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1123
	if not Content:exist(dir) then -- 1123
		ensureDirRecursive(dir) -- 1125
	end -- 1125
	local ____array_32 = __TS__SparseArrayNew( -- 1125
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1128
		"- Status: " .. record.status, -- 1129
		"- Success: " .. (record.success and "true" or "false"), -- 1130
		"- Outcome: " .. record.completion.outcome, -- 1131
		"- Session ID: " .. tostring(record.sessionId), -- 1132
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1133
		"- Goal: " .. record.goal, -- 1134
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1135
	) -- 1135
	__TS__SparseArrayPush( -- 1135
		____array_32, -- 1135
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1136
	) -- 1136
	__TS__SparseArrayPush( -- 1136
		____array_32, -- 1136
		"- Finished At: " .. record.finishedAt, -- 1137
		"", -- 1138
		"## Validation", -- 1139
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1140
			record.completion.validation, -- 1141
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1141
		) or ({"- Not reported"})) -- 1141
	) -- 1141
	__TS__SparseArrayPush(____array_32, "", "## Recorded Evidence") -- 1141
	local ____opt_24 = record.handoffEvidence -- 1141
	__TS__SparseArrayPush( -- 1141
		____array_32, -- 1141
		table.unpack(____opt_24 and #____opt_24.modifiedFiles and __TS__ArrayMap( -- 1145
			record.handoffEvidence.modifiedFiles, -- 1146
			function(____, item) return "- modified: " .. item end -- 1146
		) or ({"- modified: none recorded"})) -- 1146
	) -- 1146
	local ____opt_26 = record.handoffEvidence -- 1146
	__TS__SparseArrayPush( -- 1146
		____array_32, -- 1146
		table.unpack(____opt_26 and ____opt_26.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1148
	) -- 1148
	local ____opt_28 = record.handoffEvidence -- 1148
	__TS__SparseArrayPush( -- 1148
		____array_32, -- 1148
		table.unpack(__TS__ArrayMap( -- 1151
			____opt_28 and ____opt_28.commands or ({}), -- 1151
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1151
		)) -- 1151
	) -- 1151
	local ____opt_30 = record.handoffEvidence -- 1151
	__TS__SparseArrayPush( -- 1151
		____array_32, -- 1151
		table.unpack(__TS__ArrayMap( -- 1152
			____opt_30 and ____opt_30.authoritativeSources or ({}), -- 1152
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1152
		)) -- 1152
	) -- 1152
	__TS__SparseArrayPush( -- 1152
		____array_32, -- 1152
		"", -- 1153
		"## Known Issues", -- 1154
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1155
			record.completion.knownIssues, -- 1155
			function(____, item) return "- " .. item end -- 1155
		) or ({"- None reported"})) -- 1155
	) -- 1155
	__TS__SparseArrayPush( -- 1155
		____array_32, -- 1155
		"", -- 1156
		"## Assumptions", -- 1157
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1158
			record.completion.assumptions, -- 1158
			function(____, item) return "- " .. item end -- 1158
		) or ({"- None reported"})) -- 1158
	) -- 1158
	__TS__SparseArrayPush(____array_32, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1158
	local lines = {__TS__SparseArraySpread(____array_32)} -- 1127
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1163
	local content = table.concat(lines, "\n") .. "\n" -- 1164
	if not Content:save(path, content) then -- 1164
		return false -- 1166
	end -- 1166
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1168
	return true -- 1169
end -- 1169
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1172
	local dir = Path(projectRoot, ".agent", "subagents") -- 1173
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1173
		return {} -- 1174
	end -- 1174
	local items = {} -- 1175
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1176
		do -- 1176
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1177
			if not Content:exist(path) or not Content:isdir(path) then -- 1177
				goto __continue208 -- 1178
			end -- 1178
			local info = readSpawnInfo( -- 1179
				projectRoot, -- 1179
				Path( -- 1179
					"subagents", -- 1179
					Path:getFilename(path) -- 1179
				) -- 1179
			) -- 1179
			if not info then -- 1179
				goto __continue208 -- 1180
			end -- 1180
			local sessionId = tonumber(info.sessionId) -- 1181
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1182
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1183
			local status = sanitizeUTF8(toStr(info.status)) -- 1184
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1184
				goto __continue208 -- 1185
			end -- 1185
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1185
				goto __continue208 -- 1186
			end -- 1186
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1187
			items[#items + 1] = { -- 1188
				sessionId = sessionId, -- 1189
				rootSessionId = infoRootSessionId, -- 1190
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1191
				title = sanitizeUTF8(toStr(info.title)), -- 1192
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1193
				goal = sanitizeUTF8(toStr(info.goal)), -- 1194
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1195
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1196
					__TS__ArrayFilter( -- 1197
						info.filesHint, -- 1197
						function(____, item) return type(item) == "string" end -- 1197
					), -- 1197
					function(____, item) return sanitizeUTF8(item) end -- 1197
				) or ({}), -- 1197
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1199
				success = info.success == true, -- 1200
				cleared = info.cleared == true, -- 1201
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1202
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1203
					"subagents", -- 1203
					Path:getFilename(path) -- 1203
				)), -- 1203
				sourceTaskId = sourceTaskId or 0, -- 1204
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1205
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1206
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1207
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1208
				completion = normalizeAgentCompletionReport(info.completion), -- 1209
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1210
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1211
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1212
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1213
			} -- 1213
		end -- 1213
		::__continue208:: -- 1213
	end -- 1213
	__TS__ArraySort( -- 1216
		items, -- 1216
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1216
	) -- 1216
	return items -- 1217
end -- 1217
function getPendingHandoffDir(projectRoot, memoryScope) -- 1220
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1221
end -- 1221
function writePendingHandoff(projectRoot, memoryScope, value) -- 1224
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1225
	if not Content:exist(dir) then -- 1225
		ensureDirRecursive(dir) -- 1227
	end -- 1227
	local path = Path(dir, value.id .. ".json") -- 1229
	local text = safeJsonEncode(value) -- 1230
	if not text then -- 1230
		return false -- 1231
	end -- 1231
	local content = text .. "\n" -- 1232
	if not Content:save(path, content) then -- 1232
		return false -- 1233
	end -- 1233
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1234
	return true -- 1235
end -- 1235
function listPendingHandoffs(projectRoot, memoryScope) -- 1238
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1239
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1239
		return {} -- 1240
	end -- 1240
	local items = {} -- 1241
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1242
		do -- 1242
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1243
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1243
				goto __continue224 -- 1244
			end -- 1244
			local text = Content:load(path) -- 1245
			if not text or __TS__StringTrim(text) == "" then -- 1245
				goto __continue224 -- 1246
			end -- 1246
			local obj = safeJsonDecode(text) -- 1247
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1247
				goto __continue224 -- 1248
			end -- 1248
			local value = obj -- 1249
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1250
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1251
			local id = sanitizeUTF8(toStr(value.id)) -- 1252
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1253
			local message = sanitizeUTF8(toStr(value.message)) -- 1254
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1255
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1256
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1257
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1257
				goto __continue224 -- 1259
			end -- 1259
			items[#items + 1] = { -- 1261
				id = id, -- 1262
				sourceSessionId = sourceSessionId, -- 1263
				sourceTitle = sourceTitle, -- 1264
				sourceTaskId = sourceTaskId, -- 1265
				message = message, -- 1266
				prompt = prompt, -- 1267
				goal = goal, -- 1268
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1269
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1270
					__TS__ArrayFilter( -- 1271
						value.filesHint, -- 1271
						function(____, item) return type(item) == "string" end -- 1271
					), -- 1271
					function(____, item) return sanitizeUTF8(item) end -- 1271
				) or ({}), -- 1271
				success = value.success == true, -- 1273
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1274
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1275
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1276
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1277
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1278
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1279
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1280
				createdAt = createdAt -- 1283
			} -- 1283
		end -- 1283
		::__continue224:: -- 1283
	end -- 1283
	__TS__ArraySort( -- 1286
		items, -- 1286
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1286
	) -- 1286
	return items -- 1287
end -- 1287
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1290
	local path = Path( -- 1291
		getPendingHandoffDir(projectRoot, memoryScope), -- 1291
		id .. ".json" -- 1291
	) -- 1291
	if Content:exist(path) then -- 1291
		if Content:remove(path) then -- 1291
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1294
		end -- 1294
	end -- 1294
end -- 1294
function normalizePromptText(prompt) -- 1299
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1300
end -- 1300
function normalizePromptTextSafe(prompt) -- 1303
	if type(prompt) == "string" then -- 1303
		local normalized = normalizePromptText(prompt) -- 1305
		if normalized ~= "" then -- 1305
			return normalized -- 1306
		end -- 1306
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1307
		if sanitized ~= "" then -- 1307
			return truncateAgentUserPrompt(sanitized) -- 1309
		end -- 1309
		return "" -- 1311
	end -- 1311
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1313
	if text == "" then -- 1313
		return "" -- 1314
	end -- 1314
	return truncateAgentUserPrompt(text) -- 1315
end -- 1315
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1318
	local sections = {} -- 1319
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1320
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1321
	local normalizedFiles = __TS__ArrayFilter( -- 1322
		__TS__ArrayMap( -- 1322
			__TS__ArrayFilter( -- 1322
				filesHint or ({}), -- 1322
				function(____, item) return type(item) == "string" end -- 1323
			), -- 1323
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1324
		), -- 1324
		function(____, item) return item ~= "" end -- 1325
	) -- 1325
	if normalizedTitle ~= "" then -- 1325
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1327
	end -- 1327
	if normalizedExpected ~= "" then -- 1327
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1330
	end -- 1330
	if #normalizedFiles > 0 then -- 1330
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1333
	end -- 1333
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1335
end -- 1335
function normalizeSessionRuntimeState(session) -- 1338
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1338
		return session -- 1340
	end -- 1340
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1340
		return session -- 1343
	end -- 1343
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1345
		session.id, -- 1348
		session.currentTaskId, -- 1348
		"fetch_url", -- 1348
		"execute_command", -- 1348
		"analyze_image" -- 1348
	}) or ({}) -- 1348
	if #pendingToolRows > 0 then -- 1348
		local t = now() -- 1351
		do -- 1351
			local i = 0 -- 1352
			while i < #pendingToolRows do -- 1352
				local row = pendingToolRows[i + 1] -- 1353
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1354
				result.success = false -- 1355
				result.state = "failed" -- 1356
				result.interrupted = true -- 1357
				result.message = "tool call was interrupted because the program exited before it completed." -- 1358
				DB:exec( -- 1359
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1359
					{ -- 1361
						encodeJson(result), -- 1361
						t, -- 1361
						row[1] -- 1361
					} -- 1361
				) -- 1361
				i = i + 1 -- 1352
			end -- 1352
		end -- 1352
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1364
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1365
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1366
	end -- 1366
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1373
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1374
	return __TS__ObjectAssign( -- 1375
		{}, -- 1375
		session, -- 1376
		{ -- 1375
			status = "STOPPED", -- 1377
			currentTaskStatus = "STOPPED", -- 1378
			updatedAt = now() -- 1379
		} -- 1379
	) -- 1379
end -- 1379
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1383
	DB:exec( -- 1384
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1384
		{ -- 1388
			status, -- 1389
			currentTaskId or 0, -- 1390
			currentTaskStatus or status, -- 1391
			now(), -- 1392
			sessionId -- 1393
		} -- 1393
	) -- 1393
end -- 1393
function mergeAgentMetrics(current, next) -- 1398
	return __TS__ObjectAssign({}, current or ({}), next) -- 1399
end -- 1399
function updateSessionMetrics(sessionId, metrics) -- 1405
	local session = getSessionItem(sessionId) -- 1406
	if not session then -- 1406
		return nil -- 1407
	end -- 1407
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1408
	DB:exec( -- 1409
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1409
		{ -- 1413
			encodeJson(merged), -- 1414
			now(), -- 1415
			sessionId -- 1416
		} -- 1416
	) -- 1416
	return merged -- 1419
end -- 1419
function clearSessionTokenUsage(sessionId) -- 1422
	local session = getSessionItem(sessionId) -- 1423
	if not session then -- 1423
		return nil -- 1424
	end -- 1424
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1425
	__TS__Delete(metrics, "usage") -- 1426
	__TS__Delete(metrics, "visionUsage") -- 1427
	DB:exec( -- 1428
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1428
		{ -- 1432
			encodeJson(metrics), -- 1433
			now(), -- 1434
			sessionId -- 1435
		} -- 1435
	) -- 1435
	return metrics -- 1438
end -- 1438
function getInitialTokenUsage(session) -- 1441
	local ____opt_33 = session.metrics -- 1441
	local usage = ____opt_33 and ____opt_33.usage -- 1442
	if not usage or (usage.requestCount or 0) <= 0 then -- 1442
		return nil -- 1443
	end -- 1443
	return { -- 1444
		inputTokens = usage.inputTokens or 0, -- 1445
		outputTokens = usage.outputTokens or 0, -- 1446
		totalTokens = usage.totalTokens, -- 1447
		cachedInputTokens = usage.cachedInputTokens, -- 1448
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1449
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1450
		requestCount = usage.requestCount or 0, -- 1451
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1452
		model = usage.model or "", -- 1453
		phase = usage.phase or "", -- 1454
		step = usage.step or 0, -- 1455
		updatedAt = usage.updatedAt or now() -- 1456
	} -- 1456
end -- 1456
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1460
	if taskId == nil or taskId <= 0 then -- 1460
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1462
		return -- 1463
	end -- 1463
	local row = getSessionRow(sessionId) -- 1465
	if not row then -- 1465
		return -- 1466
	end -- 1466
	local session = rowToSession(row) -- 1467
	if session.currentTaskId ~= taskId then -- 1467
		Log( -- 1469
			"Info", -- 1469
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1469
		) -- 1469
		return -- 1470
	end -- 1470
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1472
end -- 1472
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1475
	local t = now() -- 1476
	DB:exec( -- 1477
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1477
		{ -- 1480
			sessionId, -- 1481
			taskId or 0, -- 1482
			role, -- 1483
			sanitizeUTF8(content), -- 1484
			displayContent and sanitizeUTF8(displayContent) or "", -- 1485
			t, -- 1486
			t -- 1487
		} -- 1487
	) -- 1487
	return getLastInsertRowId() -- 1490
end -- 1490
function updateMessage(messageId, content) -- 1493
	DB:exec( -- 1494
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1494
		{ -- 1496
			sanitizeUTF8(content), -- 1496
			now(), -- 1496
			messageId -- 1496
		} -- 1496
	) -- 1496
end -- 1496
function updateUserMessageForTask(messageId, content, taskId) -- 1500
	DB:exec( -- 1501
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1501
		{ -- 1505
			sanitizeUTF8(content), -- 1505
			taskId, -- 1505
			now(), -- 1505
			messageId -- 1505
		} -- 1505
	) -- 1505
end -- 1505
function removeContinuableTaskSummary(session) -- 1562
	local taskId = session.currentTaskId -- 1563
	if taskId == nil then -- 1563
		return -- 1564
	end -- 1564
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1565
end -- 1565
function upsertAssistantMessage(sessionId, taskId, content) -- 1577
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1578
	if row and type(row[1]) == "number" then -- 1578
		updateMessage(row[1], content) -- 1585
		return row[1] -- 1586
	end -- 1586
	return insertMessage(sessionId, "assistant", content, taskId) -- 1588
end -- 1588
function upsertStep(sessionId, taskId, step, tool, patch) -- 1591
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1601
	local reason = sanitizeUTF8(patch.reason or "") -- 1605
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1606
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1607
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1608
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1609
	local statusPatch = patch.status or "" -- 1610
	local status = patch.status or "PENDING" -- 1611
	if not row then -- 1611
		local t = now() -- 1613
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1614
			sessionId, -- 1618
			taskId, -- 1619
			step, -- 1620
			tool, -- 1621
			status, -- 1622
			reason, -- 1623
			reasoningContent, -- 1624
			paramsJson, -- 1625
			resultJson, -- 1626
			patch.checkpointId or 0, -- 1627
			patch.checkpointSeq or 0, -- 1628
			filesJson, -- 1629
			t, -- 1630
			t -- 1631
		}) -- 1631
		return -- 1634
	end -- 1634
	DB:exec( -- 1636
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1636
		{ -- 1648
			tool, -- 1649
			statusPatch, -- 1650
			status, -- 1651
			reason, -- 1652
			reason, -- 1653
			reasoningContent, -- 1654
			reasoningContent, -- 1655
			paramsJson, -- 1656
			paramsJson, -- 1657
			resultJson, -- 1658
			resultJson, -- 1659
			patch.checkpointId or 0, -- 1660
			patch.checkpointId or 0, -- 1661
			patch.checkpointSeq or 0, -- 1662
			patch.checkpointSeq or 0, -- 1663
			filesJson, -- 1664
			filesJson, -- 1665
			now(), -- 1666
			row[1] -- 1667
		} -- 1667
	) -- 1667
end -- 1667
function getNextStepNumber(sessionId, taskId) -- 1672
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1673
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1677
	return math.max(0, current) + 1 -- 1678
end -- 1678
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1719
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1727
	local t = now() -- 1728
	local sqls = { -- 1729
		{ -- 1730
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1730
			{{ -- 1733
				sessionId, -- 1734
				ownerTaskId, -- 1735
				step, -- 1736
				"sub_agent_handoff", -- 1737
				"DONE", -- 1738
				sanitizeUTF8(reason), -- 1739
				encodeJson(params), -- 1740
				encodeJson(result), -- 1741
				t, -- 1742
				t -- 1743
			}} -- 1743
		}, -- 1743
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1746
	} -- 1746
	if not DB:transaction(sqls) then -- 1746
		return nil -- 1752
	end -- 1752
	return getStepItem(sessionId, ownerTaskId, step) -- 1753
end -- 1753
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1756
	if taskId <= 0 then -- 1756
		return -- 1757
	end -- 1757
	if finalSteps ~= nil and finalSteps >= 0 then -- 1757
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1759
	end -- 1759
	if not finalStatus then -- 1759
		return -- 1765
	end -- 1765
	if finalSteps ~= nil and finalSteps >= 0 then -- 1765
		DB:exec( -- 1767
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1767
			{ -- 1771
				finalStatus, -- 1771
				now(), -- 1771
				sessionId, -- 1771
				taskId, -- 1771
				finalSteps -- 1771
			} -- 1771
		) -- 1771
		return -- 1773
	end -- 1773
	DB:exec( -- 1775
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1775
		{ -- 1779
			finalStatus, -- 1779
			now(), -- 1779
			sessionId, -- 1779
			taskId -- 1779
		} -- 1779
	) -- 1779
end -- 1779
function emitAgentSessionPatch(sessionId, patch) -- 1806
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1807
	if not text then -- 1807
		return -- 1812
	end -- 1812
	local failed = publishSessionPatch(sessionId, text) -- 1813
	if failed > 0 then -- 1813
		Log( -- 1814
			"Warn", -- 1814
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 1814
		) -- 1814
	end -- 1814
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 1814
		emit("AppWS", "Send", text) -- 1815
	end -- 1815
end -- 1815
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1818
	emitAgentSessionPatch( -- 1819
		sessionId, -- 1819
		{ -- 1819
			sessionDeleted = true, -- 1820
			relatedSessions = listRelatedSessions(rootSessionId) -- 1821
		} -- 1821
	) -- 1821
	local rootSession = getSessionItem(rootSessionId) -- 1823
	if rootSession then -- 1823
		emitAgentSessionPatch( -- 1825
			rootSessionId, -- 1825
			{ -- 1825
				session = rootSession, -- 1826
				relatedSessions = listRelatedSessions(rootSessionId) -- 1827
			} -- 1827
		) -- 1827
	end -- 1827
end -- 1827
function flushPendingSubAgentHandoffs(rootSession) -- 1832
	if rootSession.kind ~= "main" then -- 1832
		return -- 1833
	end -- 1833
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1833
		return -- 1835
	end -- 1835
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1837
	if #items == 0 then -- 1837
		return -- 1838
	end -- 1838
	local handoffTaskId = 0 -- 1839
	local previousTaskId = rootSession.currentTaskId -- 1840
	local ____rootSession_currentTaskId_37 -- 1841
	if rootSession.currentTaskId then -- 1841
		____rootSession_currentTaskId_37 = getTaskPrompt(rootSession.currentTaskId) -- 1841
	else -- 1841
		____rootSession_currentTaskId_37 = nil -- 1841
	end -- 1841
	local currentTaskPrompt = ____rootSession_currentTaskId_37 -- 1841
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1841
		handoffTaskId = rootSession.currentTaskId -- 1849
	else -- 1849
		local taskRes = Tools.createTask( -- 1851
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1851
			"code" -- 1851
		) -- 1851
		if not taskRes.success then -- 1851
			Log( -- 1853
				"Warn", -- 1853
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1853
			) -- 1853
			return -- 1854
		end -- 1854
		handoffTaskId = taskRes.taskId -- 1856
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1857
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1858
		emitAgentSessionPatch( -- 1859
			rootSession.id, -- 1859
			{session = getSessionItem(rootSession.id)} -- 1859
		) -- 1859
	end -- 1859
	do -- 1859
		local i = 0 -- 1863
		while i < #items do -- 1863
			local item = items[i + 1] -- 1864
			local step = appendHandoffSystemStep( -- 1865
				rootSession.id, -- 1866
				handoffTaskId, -- 1867
				item.sourceTaskId, -- 1868
				item.message, -- 1869
				{ -- 1870
					sourceSessionId = item.sourceSessionId, -- 1871
					sourceTitle = item.sourceTitle, -- 1872
					sourceTaskId = item.sourceTaskId, -- 1873
					success = item.success == true, -- 1874
					summary = item.message, -- 1875
					resultFilePath = item.resultFilePath or "", -- 1876
					artifactDir = item.artifactDir or "", -- 1877
					finishedAt = item.finishedAt or "", -- 1878
					changeSet = item.changeSet, -- 1879
					handoffEvidence = item.handoffEvidence, -- 1880
					memoryEntry = item.memoryEntry, -- 1881
					completion = item.completion -- 1882
				}, -- 1882
				{ -- 1884
					sourceSessionId = item.sourceSessionId, -- 1885
					sourceTitle = item.sourceTitle, -- 1886
					sourceTaskId = item.sourceTaskId, -- 1887
					prompt = item.prompt, -- 1888
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1889
					expectedOutput = item.expectedOutput or "", -- 1890
					filesHint = item.filesHint or ({}), -- 1891
					resultFilePath = item.resultFilePath or "", -- 1892
					artifactDir = item.artifactDir or "", -- 1893
					changeSet = item.changeSet, -- 1894
					handoffEvidence = item.handoffEvidence, -- 1895
					memoryEntry = item.memoryEntry, -- 1896
					completion = item.completion -- 1897
				} -- 1897
			) -- 1897
			if step then -- 1897
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1901
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1902
			else -- 1902
				Log( -- 1904
					"Warn", -- 1904
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1904
				) -- 1904
			end -- 1904
			i = i + 1 -- 1863
		end -- 1863
	end -- 1863
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1863
		cleanupTaskHeavyData(previousTaskId) -- 1908
	end -- 1908
end -- 1908
function applyEvent(sessionId, event) -- 1920
	if not getSessionItem(sessionId) then -- 1920
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1920
			__TS__Delete(activeStopTokens, event.taskId) -- 1923
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1924
		end -- 1924
		return -- 1926
	end -- 1926
	repeat -- 1926
		local ____switch318 = event.type -- 1926
		local metrics, startedSession -- 1926
		local ____cond318 = ____switch318 == "task_started" -- 1926
		if ____cond318 then -- 1926
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1930
			local ____event_resumed_40 -- 1931
			if event.resumed then -- 1931
				local ____opt_38 = getSessionItem(sessionId) -- 1931
				____event_resumed_40 = ____opt_38 and ____opt_38.metrics -- 1932
			else -- 1932
				____event_resumed_40 = clearSessionTokenUsage(sessionId) -- 1933
			end -- 1933
			metrics = ____event_resumed_40 -- 1931
			startedSession = getSessionItem(sessionId) -- 1934
			emitAgentSessionPatch( -- 1935
				sessionId, -- 1935
				{ -- 1935
					session = startedSession, -- 1936
					metrics = metrics, -- 1937
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1938
				} -- 1938
			) -- 1938
			break -- 1942
		end -- 1942
		____cond318 = ____cond318 or ____switch318 == "decision_made" -- 1942
		if ____cond318 then -- 1942
			upsertStep( -- 1944
				sessionId, -- 1944
				event.taskId, -- 1944
				event.step, -- 1944
				event.tool, -- 1944
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1944
			) -- 1944
			emitAgentSessionPatch( -- 1952
				sessionId, -- 1952
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1952
			) -- 1952
			break -- 1955
		end -- 1955
		____cond318 = ____cond318 or ____switch318 == "tool_started" -- 1955
		if ____cond318 then -- 1955
			upsertStep( -- 1957
				sessionId, -- 1957
				event.taskId, -- 1957
				event.step, -- 1957
				event.tool, -- 1957
				{status = "RUNNING"} -- 1957
			) -- 1957
			emitAgentSessionPatch( -- 1960
				sessionId, -- 1960
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1960
			) -- 1960
			break -- 1963
		end -- 1963
		____cond318 = ____cond318 or ____switch318 == "tool_finished" -- 1963
		if ____cond318 then -- 1963
			do -- 1963
				local ____temp_43 = event.result.success ~= true -- 1965
				if ____temp_43 then -- 1965
					local ____opt_41 = activeStopTokens[event.taskId] -- 1965
					____temp_43 = (____opt_41 and ____opt_41.stopped) == true -- 1965
				end -- 1965
				local stopped = ____temp_43 -- 1965
				upsertStep( -- 1967
					sessionId, -- 1967
					event.taskId, -- 1967
					event.step, -- 1967
					event.tool, -- 1967
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1967
				) -- 1967
				emitAgentSessionPatch( -- 1975
					sessionId, -- 1975
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1975
				) -- 1975
				break -- 1978
			end -- 1978
		end -- 1978
		____cond318 = ____cond318 or ____switch318 == "tool_progress" -- 1978
		if ____cond318 then -- 1978
			do -- 1978
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1982
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1982
					break -- 1984
				end -- 1984
			end -- 1984
			upsertStep( -- 1987
				sessionId, -- 1987
				event.taskId, -- 1987
				event.step, -- 1987
				event.tool, -- 1987
				{status = "RUNNING", result = event.result} -- 1987
			) -- 1987
			emitAgentSessionPatch( -- 1991
				sessionId, -- 1991
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1991
			) -- 1991
			break -- 1994
		end -- 1994
		____cond318 = ____cond318 or ____switch318 == "checkpoint_created" -- 1994
		if ____cond318 then -- 1994
			upsertStep( -- 1996
				sessionId, -- 1996
				event.taskId, -- 1996
				event.step, -- 1996
				event.tool, -- 1996
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1996
			) -- 1996
			emitAgentSessionPatch( -- 2001
				sessionId, -- 2001
				{ -- 2001
					step = getStepItem(sessionId, event.taskId, event.step), -- 2002
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2003
				} -- 2003
			) -- 2003
			break -- 2005
		end -- 2005
		____cond318 = ____cond318 or ____switch318 == "memory_compression_started" -- 2005
		if ____cond318 then -- 2005
			upsertStep( -- 2007
				sessionId, -- 2007
				event.taskId, -- 2007
				event.step, -- 2007
				event.tool, -- 2007
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2007
			) -- 2007
			emitAgentSessionPatch( -- 2012
				sessionId, -- 2012
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2012
			) -- 2012
			break -- 2015
		end -- 2015
		____cond318 = ____cond318 or ____switch318 == "memory_compression_finished" -- 2015
		if ____cond318 then -- 2015
			upsertStep( -- 2017
				sessionId, -- 2017
				event.taskId, -- 2017
				event.step, -- 2017
				event.tool, -- 2017
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2017
			) -- 2017
			emitAgentSessionPatch( -- 2022
				sessionId, -- 2022
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2022
			) -- 2022
			break -- 2025
		end -- 2025
		____cond318 = ____cond318 or ____switch318 == "metrics_updated" -- 2025
		if ____cond318 then -- 2025
			do -- 2025
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2027
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2028
				break -- 2031
			end -- 2031
		end -- 2031
		____cond318 = ____cond318 or ____switch318 == "assistant_message_updated" -- 2031
		if ____cond318 then -- 2031
			do -- 2031
				upsertStep( -- 2034
					sessionId, -- 2034
					event.taskId, -- 2034
					event.step, -- 2034
					"message", -- 2034
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2034
				) -- 2034
				emitAgentSessionPatch( -- 2039
					sessionId, -- 2039
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2039
				) -- 2039
				break -- 2042
			end -- 2042
		end -- 2042
		____cond318 = ____cond318 or ____switch318 == "assistant_message_finished" -- 2042
		if ____cond318 then -- 2042
			do -- 2042
				upsertStep( -- 2045
					sessionId, -- 2045
					event.taskId, -- 2045
					event.step, -- 2045
					"message", -- 2045
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2045
				) -- 2045
				emitAgentSessionPatch( -- 2051
					sessionId, -- 2051
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2051
				) -- 2051
				break -- 2054
			end -- 2054
		end -- 2054
		____cond318 = ____cond318 or ____switch318 == "task_waiting_for_user" -- 2054
		if ____cond318 then -- 2054
			do -- 2054
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2057
				__TS__Delete(activeStopTokens, event.taskId) -- 2058
				emitAgentSessionPatch( -- 2059
					sessionId, -- 2059
					{ -- 2059
						session = getSessionItem(sessionId), -- 2060
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2061
					} -- 2061
				) -- 2061
				break -- 2063
			end -- 2063
		end -- 2063
		____cond318 = ____cond318 or ____switch318 == "task_finished" -- 2063
		if ____cond318 then -- 2063
			do -- 2063
				local session = getSessionItem(sessionId) -- 2066
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2066
					__TS__Delete(activeStopTokens, event.taskId) -- 2068
					Log( -- 2069
						"Info", -- 2069
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2069
					) -- 2069
					break -- 2070
				end -- 2070
				local ____opt_44 = activeStopTokens[event.taskId or -1] -- 2070
				local stopped = (____opt_44 and ____opt_44.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2072
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2074
				local isSubSession = (session and session.kind) == "sub" -- 2077
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2078
				if isSubSession and event.taskId ~= nil then -- 2078
					finalizingSubSessionTaskIds[event.taskId] = true -- 2080
				end -- 2080
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2082
				if event.taskId ~= nil then -- 2082
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2084
					local ____finalizeTaskSteps_50 = finalizeTaskSteps -- 2085
					local ____array_49 = __TS__SparseArrayNew( -- 2085
						sessionId, -- 2086
						event.taskId, -- 2087
						type(event.steps) == "number" and math.max( -- 2088
							0, -- 2088
							math.floor(event.steps) -- 2088
						) or nil -- 2088
					) -- 2088
					local ____event_success_48 -- 2089
					if event.success then -- 2089
						____event_success_48 = nil -- 2089
					else -- 2089
						____event_success_48 = stopped and "STOPPED" or "FAILED" -- 2089
					end -- 2089
					__TS__SparseArrayPush(____array_49, ____event_success_48) -- 2089
					____finalizeTaskSteps_50(__TS__SparseArraySpread(____array_49)) -- 2085
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2091
					if not isSubSession then -- 2091
						__TS__Delete(activeStopTokens, event.taskId) -- 2093
					end -- 2093
					emitAgentSessionPatch( -- 2095
						sessionId, -- 2095
						{ -- 2095
							session = getSessionItem(sessionId), -- 2096
							message = getMessageItem(messageId), -- 2097
							removedStepIds = removedStepIds -- 2098
						} -- 2098
					) -- 2098
				end -- 2098
				if session and session.kind == "main" then -- 2098
					flushPendingSubAgentHandoffs(session) -- 2102
				end -- 2102
				break -- 2104
			end -- 2104
		end -- 2104
	until true -- 2104
end -- 2104
function ____exports.createSession(projectRoot, title) -- 2109
	if title == nil then -- 2109
		title = "" -- 2109
	end -- 2109
	local storage = requireAgentStorage() -- 2110
	if not storage.success then -- 2110
		return storage -- 2111
	end -- 2111
	if not isValidProjectRoot(projectRoot) then -- 2111
		return {success = false, message = "invalid projectRoot"} -- 2113
	end -- 2113
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2115
	if row then -- 2115
		return { -- 2124
			success = true, -- 2124
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2124
		} -- 2124
	end -- 2124
	local t = now() -- 2126
	DB:exec( -- 2127
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2127
		{ -- 2130
			projectRoot, -- 2130
			title ~= "" and title or Path:getFilename(projectRoot), -- 2130
			t, -- 2130
			t -- 2130
		} -- 2130
	) -- 2130
	local sessionId = getLastInsertRowId() -- 2132
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2133
	local session = getSessionItem(sessionId) -- 2134
	if not session then -- 2134
		return {success = false, message = "failed to create session"} -- 2136
	end -- 2136
	return {success = true, session = session} -- 2138
end -- 2109
function ____exports.createSubSession(parentSessionId, title) -- 2141
	if title == nil then -- 2141
		title = "" -- 2141
	end -- 2141
	local storage = requireAgentStorage() -- 2142
	if not storage.success then -- 2142
		return storage -- 2143
	end -- 2143
	local parent = getSessionItem(parentSessionId) -- 2144
	if not parent then -- 2144
		return {success = false, message = "parent session not found"} -- 2146
	end -- 2146
	local rootId = getSessionRootId(parent) -- 2148
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2148
		return {success = false, message = "project task admission is closed"} -- 2149
	end -- 2149
	local t = now() -- 2150
	DB:exec( -- 2151
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2151
		{ -- 2154
			parent.projectRoot, -- 2154
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2154
			rootId, -- 2154
			parent.id, -- 2154
			t, -- 2154
			t -- 2154
		} -- 2154
	) -- 2154
	local sessionId = getLastInsertRowId() -- 2156
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2157
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2158
	local session = getSessionItem(sessionId) -- 2159
	if not session then -- 2159
		return {success = false, message = "failed to create sub session"} -- 2161
	end -- 2161
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2163
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2164
	subStorage:writeMemory(parentStorage:readMemory()) -- 2165
	return {success = true, session = session} -- 2166
end -- 2141
function spawnSubAgentSession(request) -- 2169
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2169
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2182
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2183
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2184
		if normalizedPrompt == "" then -- 2184
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2186
		end -- 2186
		if normalizedPrompt == "" then -- 2186
			local ____Log_56 = Log -- 2193
			local ____temp_53 = #normalizedTitle -- 2193
			local ____temp_54 = #rawPrompt -- 2193
			local ____temp_55 = #toStr(request.expectedOutput) -- 2193
			local ____opt_51 = request.filesHint -- 2193
			____Log_56( -- 2193
				"Warn", -- 2193
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_53)) .. " raw_prompt_len=") .. tostring(____temp_54)) .. " expected_len=") .. tostring(____temp_55)) .. " files_hint_count=") .. tostring(____opt_51 and #____opt_51 or 0) -- 2193
			) -- 2193
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2193
		end -- 2193
		Log( -- 2196
			"Info", -- 2196
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2196
		) -- 2196
		local parentSessionId = request.parentSessionId -- 2197
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2197
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2199
			if not fallbackParent then -- 2199
				local createdMain = ____exports.createSession(request.projectRoot) -- 2201
				if createdMain.success then -- 2201
					fallbackParent = createdMain.session -- 2203
				end -- 2203
			end -- 2203
			if fallbackParent then -- 2203
				Log( -- 2207
					"Warn", -- 2207
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2207
				) -- 2207
				parentSessionId = fallbackParent.id -- 2208
			end -- 2208
		end -- 2208
		local parentSession = getSessionItem(parentSessionId) -- 2211
		if not parentSession then -- 2211
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2211
		end -- 2211
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2215
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2215
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2215
		end -- 2215
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2215
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2215
		end -- 2215
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2220
		if not created.success then -- 2220
			return ____awaiter_resolve(nil, created) -- 2220
		end -- 2220
		writeSpawnInfo( -- 2224
			created.session.projectRoot, -- 2224
			created.session.memoryScope, -- 2224
			{ -- 2224
				sessionId = created.session.id, -- 2225
				rootSessionId = created.session.rootSessionId, -- 2226
				parentSessionId = created.session.parentSessionId, -- 2227
				title = created.session.title, -- 2228
				prompt = normalizedPrompt, -- 2229
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2230
				expectedOutput = request.expectedOutput or "", -- 2231
				filesHint = request.filesHint or ({}), -- 2232
				status = "RUNNING", -- 2233
				success = false, -- 2234
				resultFilePath = "", -- 2235
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2236
				sourceTaskId = 0, -- 2237
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2238
				createdAtTs = created.session.createdAt, -- 2239
				finishedAt = "", -- 2240
				finishedAtTs = 0 -- 2241
			} -- 2241
		) -- 2241
		local sent = ____exports.sendPrompt( -- 2243
			created.session.id, -- 2243
			normalizedPrompt, -- 2243
			request.disabledAgentTools, -- 2243
			nil, -- 2243
			nil, -- 2243
			request.llmConfig -- 2243
		) -- 2243
		if not sent.success then -- 2243
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2243
		end -- 2243
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2243
	end) -- 2243
end -- 2243
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2364
	local rootSession = getRootSessionItem(session.id) -- 2365
	if not rootSession then -- 2365
		return -- 2366
	end -- 2366
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2367
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2368
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2369
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2370
	local queueResult = writePendingHandoff( -- 2371
		rootSession.projectRoot, -- 2371
		rootSession.memoryScope, -- 2371
		{ -- 2371
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2372
			sourceSessionId = session.id, -- 2373
			sourceTitle = session.title, -- 2374
			sourceTaskId = taskId, -- 2375
			message = summary, -- 2376
			prompt = result.prompt, -- 2377
			goal = result.goal, -- 2378
			expectedOutput = result.expectedOutput or "", -- 2379
			filesHint = result.filesHint or ({}), -- 2380
			success = result.success, -- 2381
			resultFilePath = result.resultFilePath, -- 2382
			artifactDir = result.artifactDir, -- 2383
			finishedAt = result.finishedAt, -- 2384
			changeSet = changeSet, -- 2385
			handoffEvidence = result.handoffEvidence, -- 2386
			memoryEntry = result.memoryEntry, -- 2387
			completion = result.completion, -- 2388
			createdAt = createdAt -- 2389
		} -- 2389
	) -- 2389
	if not queueResult then -- 2389
		Log( -- 2392
			"Warn", -- 2392
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2392
		) -- 2392
		return -- 2393
	end -- 2393
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2393
		addTaskReference(rootSession.currentTaskId, taskId) -- 2396
	end -- 2396
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2396
		flushPendingSubAgentHandoffs(rootSession) -- 2399
	end -- 2399
end -- 2399
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2403
	if forceHandoff == nil then -- 2403
		forceHandoff = false -- 2409
	end -- 2409
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2409
		local rootSessionId = getSessionRootId(session) -- 2411
		local rootSession = getRootSessionItem(session.id) -- 2412
		if not rootSession then -- 2412
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2412
		end -- 2412
		local spawnInfo = getSessionSpawnInfo(session) -- 2416
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2417
		local finishedAtTs = now() -- 2418
		local resultText = sanitizeUTF8(message) -- 2419
		local changeSet = getTaskChangeSetSummary(taskId) -- 2420
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2421
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2422
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2426
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2426
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2428
		end -- 2428
		local completed = success and completionReport.outcome == "completed" -- 2436
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2437
		local record = { -- 2440
			sessionId = session.id, -- 2441
			rootSessionId = rootSessionId, -- 2442
			parentSessionId = session.parentSessionId, -- 2443
			title = session.title, -- 2444
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2445
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2446
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2447
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2448
			status = recordStatus, -- 2449
			success = completed, -- 2450
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2451
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2452
			sourceTaskId = taskId, -- 2453
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2454
			finishedAt = finishedAt, -- 2455
			createdAtTs = session.createdAt, -- 2456
			finishedAtTs = finishedAtTs, -- 2457
			changeSet = changeSet, -- 2458
			handoffEvidence = handoffEvidence, -- 2459
			completion = completionReport -- 2460
		} -- 2460
		local ____record_success_73 -- 2462
		if record.success then -- 2462
			____record_success_73 = buildStructuredSubAgentMemoryEntry(record) -- 2462
		else -- 2462
			____record_success_73 = nil -- 2462
		end -- 2462
		record.memoryEntry = ____record_success_73 -- 2462
		if not writeSubAgentResultFile(session, record, resultText) then -- 2462
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2462
		end -- 2462
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2462
			sessionId = record.sessionId, -- 2467
			rootSessionId = record.rootSessionId, -- 2468
			parentSessionId = record.parentSessionId, -- 2469
			title = record.title, -- 2470
			prompt = record.prompt, -- 2471
			goal = record.goal, -- 2472
			expectedOutput = record.expectedOutput or "", -- 2473
			filesHint = record.filesHint or ({}), -- 2474
			status = record.status, -- 2475
			success = record.success, -- 2476
			resultFilePath = record.resultFilePath, -- 2477
			artifactDir = record.artifactDir, -- 2478
			sourceTaskId = record.sourceTaskId, -- 2479
			createdAt = record.createdAt, -- 2480
			finishedAt = record.finishedAt, -- 2481
			createdAtTs = record.createdAtTs, -- 2482
			finishedAtTs = record.finishedAtTs, -- 2483
			changeSet = record.changeSet, -- 2484
			handoffEvidence = record.handoffEvidence, -- 2485
			memoryEntry = record.memoryEntry, -- 2486
			memoryEntryError = record.memoryEntryError, -- 2487
			completion = record.completion -- 2488
		}) then -- 2488
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2488
		end -- 2488
		if success or forceHandoff then -- 2488
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2493
			deleteSessionRecords(session.id, true) -- 2494
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2495
		end -- 2495
		return ____awaiter_resolve(nil, {success = true}) -- 2495
	end) -- 2495
end -- 2495
function stopClearedSubSession(session, taskId) -- 2500
	local spawnInfo = getSessionSpawnInfo(session) -- 2501
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2502
	local rootSessionId = getSessionRootId(session) -- 2503
	Tools.setTaskStatus(taskId, "STOPPED") -- 2504
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2505
	if not writeSpawnInfo( -- 2505
		session.projectRoot, -- 2506
		session.memoryScope, -- 2506
		{ -- 2506
			sessionId = session.id, -- 2507
			rootSessionId = rootSessionId, -- 2508
			parentSessionId = session.parentSessionId, -- 2509
			title = session.title, -- 2510
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2511
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2512
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2513
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2514
			status = "STOPPED", -- 2515
			success = false, -- 2516
			cleared = true, -- 2517
			resultFilePath = "", -- 2518
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2519
			sourceTaskId = taskId, -- 2520
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2521
			finishedAt = finishedAt, -- 2522
			createdAtTs = session.createdAt, -- 2523
			finishedAtTs = now() -- 2524
		} -- 2524
	) then -- 2524
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2526
	end -- 2526
	deleteSessionRecords(session.id, true) -- 2528
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2529
	return {success = true} -- 2530
end -- 2530
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps) -- 2533
	local session = getSessionItem(sessionId) -- 2534
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2534
		return {success = false, message = "project task admission is closed"} -- 2535
	end -- 2535
	if not session then -- 2535
		return {success = false, message = "session not found"} -- 2537
	end -- 2537
	if getPendingQuestionnaire(sessionId) then -- 2537
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2539
	end -- 2539
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2539
		return {success = false, message = "session task is finalizing"} -- 2541
	end -- 2541
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2541
		return {success = false, message = "session task is still running"} -- 2544
	end -- 2544
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2546
	if normalizedPrompt == "" and session.kind == "sub" then -- 2546
		local spawnInfo = getSessionSpawnInfo(session) -- 2548
		if spawnInfo then -- 2548
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2550
			if normalizedPrompt == "" then -- 2550
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2552
			end -- 2552
		end -- 2552
	end -- 2552
	if normalizedPrompt == "" then -- 2552
		return {success = false, message = "prompt is empty"} -- 2561
	end -- 2561
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2563
	if session.workMode ~= nextWorkMode then -- 2563
		DB:exec( -- 2565
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2565
			{ -- 2565
				nextWorkMode, -- 2565
				now(), -- 2565
				session.id -- 2565
			} -- 2565
		) -- 2565
		session.workMode = nextWorkMode -- 2566
	end -- 2566
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2568
	return startPromptTask( -- 2569
		session, -- 2569
		normalizedPrompt, -- 2569
		nil, -- 2569
		normalizeDisabledAgentTools(disabledAgentTools), -- 2569
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig, maxSteps = boundedMaxSteps} -- 2569
	) -- 2569
end -- 2533
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2623
	if disabledAgentTools == nil then -- 2623
		disabledAgentTools = {} -- 2627
	end -- 2627
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2630
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2630
		return {success = false, message = "project task admission is closed"} -- 2631
	end -- 2631
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2632
	if not llmConfigRes.success then -- 2632
		return {success = false, message = llmConfigRes.message} -- 2636
	end -- 2636
	local llmConfig = llmConfigRes.config -- 2638
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2639
	if not llmConfigValidation.success then -- 2639
		return llmConfigValidation -- 2641
	end -- 2641
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2643
	if not taskRes.success then -- 2643
		return {success = false, message = taskRes.message} -- 2646
	end -- 2646
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2646
		removeContinuableTaskSummary(session) -- 2648
	end -- 2648
	local taskId = taskRes.taskId -- 2650
	local ____temp_94 -- 2651
	if (options and options.existingTaskId) == nil then -- 2651
		____temp_94 = session.currentTaskId -- 2651
	else -- 2651
		____temp_94 = nil -- 2651
	end -- 2651
	local previousTaskId = ____temp_94 -- 2651
	local useChineseResponse = getDefaultUseChineseResponse() -- 2652
	local promptMessageId -- 2653
	if existingUserMessageId ~= nil then -- 2653
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2655
		promptMessageId = existingUserMessageId -- 2656
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2656
		promptMessageId = insertMessage( -- 2658
			session.id, -- 2658
			"user", -- 2658
			normalizedPrompt, -- 2658
			taskId, -- 2658
			options and options.displayContent -- 2658
		) -- 2658
	end -- 2658
	local stopToken = {stopped = false} -- 2660
	activeStopTokens[taskId] = stopToken -- 2661
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2662
	emitAgentSessionPatch( -- 2666
		session.id, -- 2666
		__TS__ObjectAssign( -- 2666
			{session = getSessionItem(session.id)}, -- 2666
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 2668
		) -- 2668
	) -- 2668
	if previousTaskId and previousTaskId ~= taskId then -- 2668
		cleanupTaskHeavyData(previousTaskId) -- 2671
	end -- 2671
	local ____runCodingAgent_123 = runCodingAgent -- 2673
	local ____normalizedPrompt_116 = normalizedPrompt -- 2674
	local ____temp_117 = options and options.resumeConversation -- 2675
	local ____temp_118 = (options and options.existingTaskId) ~= nil -- 2676
	local ____temp_119 = options and options.initialStep -- 2677
	local ____temp_120 = options and options.initialAgentStepCount -- 2678
	local ____temp_111 -- 2679
	if (options and options.existingTaskId) ~= nil then -- 2679
		____temp_111 = getInitialTokenUsage(session) -- 2679
	else -- 2679
		____temp_111 = nil -- 2679
	end -- 2679
	____runCodingAgent_123( -- 2673
		{ -- 2673
			prompt = ____normalizedPrompt_116, -- 2674
			resumeConversation = ____temp_117, -- 2675
			resumeTask = ____temp_118, -- 2676
			initialStep = ____temp_119, -- 2677
			initialAgentStepCount = ____temp_120, -- 2678
			initialTokenUsage = ____temp_111, -- 2679
			workDir = session.projectRoot, -- 2680
			useChineseResponse = useChineseResponse, -- 2681
			taskId = taskId, -- 2682
			sessionId = session.id, -- 2683
			memoryScope = session.memoryScope, -- 2684
			role = session.kind, -- 2685
			maxSteps = options and options.maxSteps, -- 2686
			disabledAgentTools = disabledAgentTools, -- 2687
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2688
			llmConfig = llmConfig, -- 2689
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2690
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2693
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2696
			stopToken = stopToken, -- 2697
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2698
		}, -- 2698
		function(result) -- 2699
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2699
				local nextSession = getSessionItem(session.id) -- 2700
				if nextSession and nextSession.kind == "sub" then -- 2700
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2700
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2703
						if not stopped.success then -- 2703
							Log( -- 2705
								"Warn", -- 2705
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2705
							) -- 2705
							emitAgentSessionPatch( -- 2706
								session.id, -- 2706
								{session = getSessionItem(session.id)} -- 2706
							) -- 2706
						end -- 2706
						__TS__Delete(activeStopTokens, taskId) -- 2710
						return ____awaiter_resolve(nil) -- 2710
					end -- 2710
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2713
					emitAgentSessionPatch( -- 2714
						session.id, -- 2714
						{session = getSessionItem(session.id)} -- 2714
					) -- 2714
					local finalized = __TS__Await(finalizeSubSession( -- 2717
						nextSession, -- 2718
						taskId, -- 2719
						result.success, -- 2720
						result.message, -- 2721
						result.completion, -- 2722
						(options and options.forceSubAgentHandoff) == true -- 2723
					)) -- 2723
					if not finalized.success then -- 2723
						Log( -- 2726
							"Warn", -- 2726
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2726
						) -- 2726
					end -- 2726
					local finalizedSession = getSessionItem(session.id) -- 2728
					if finalizedSession then -- 2728
						local stopped = stopToken.stopped == true -- 2730
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2731
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2734
						emitAgentSessionPatch( -- 2735
							session.id, -- 2735
							{session = getSessionItem(session.id)} -- 2735
						) -- 2735
					end -- 2735
					__TS__Delete(activeStopTokens, taskId) -- 2739
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2740
				end -- 2740
				local fallbackSession = getSessionItem(session.id) -- 2742
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2742
					applyEvent(session.id, { -- 2748
						type = "task_finished", -- 2749
						sessionId = session.id, -- 2750
						taskId = result.taskId, -- 2751
						success = false, -- 2752
						message = result.message, -- 2753
						steps = result.steps -- 2754
					}) -- 2754
				end -- 2754
			end) -- 2754
		end -- 2699
	) -- 2699
	return {success = true, sessionId = session.id, taskId = taskId} -- 2758
end -- 2758
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2911
	local lines = {} -- 2912
	do -- 2912
		local i = 0 -- 2913
		while i < #questionnaire.schema.questions do -- 2913
			local question = questionnaire.schema.questions[i + 1] -- 2914
			local answer = __TS__ArrayFind( -- 2915
				answers, -- 2915
				function(____, item) return item.questionId == question.id end -- 2915
			) -- 2915
			local answerText = "已跳过" -- 2916
			if answer and answer.status == "answered" then -- 2916
				local parts = {} -- 2918
				do -- 2918
					local j = 0 -- 2919
					while j < #(answer.selectedOptionIds or ({})) do -- 2919
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2920
						local option = __TS__ArrayFind( -- 2921
							question.options or ({}), -- 2921
							function(____, item) return item.id == optionId end -- 2921
						) -- 2921
						if option then -- 2921
							parts[#parts + 1] = option.label -- 2922
						end -- 2922
						j = j + 1 -- 2919
					end -- 2919
				end -- 2919
				if answer.otherText then -- 2919
					parts[#parts + 1] = answer.otherText -- 2924
				end -- 2924
				if answer.text then -- 2924
					parts[#parts + 1] = answer.text -- 2925
				end -- 2925
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2926
			end -- 2926
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2928
			i = i + 1 -- 2913
		end -- 2913
	end -- 2913
	return table.concat(lines, "\n\n") -- 2930
end -- 2930
function ____exports.listRunningSubAgents(request) -- 3209
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3209
		local session = getSessionItem(request.sessionId) -- 3217
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3217
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3219
		end -- 3219
		if not session then -- 3219
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3219
		end -- 3219
		local rootSession = getRootSessionItem(session.id) -- 3224
		if not rootSession then -- 3224
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3224
		end -- 3224
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3228
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3229
		local limit = math.max( -- 3230
			1, -- 3230
			math.floor(tonumber(request.limit) or 5) -- 3230
		) -- 3230
		local offset = math.max( -- 3231
			0, -- 3231
			math.floor(tonumber(request.offset) or 0) -- 3231
		) -- 3231
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3232
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3233
		local runningSessions = {} -- 3240
		do -- 3240
			local i = 0 -- 3241
			while i < #rows do -- 3241
				do -- 3241
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3242
					if current.currentTaskStatus ~= "RUNNING" then -- 3242
						goto __continue537 -- 3244
					end -- 3244
					local spawnInfo = getSessionSpawnInfo(current) -- 3246
					runningSessions[#runningSessions + 1] = { -- 3247
						sessionId = current.id, -- 3248
						title = current.title, -- 3249
						parentSessionId = current.parentSessionId, -- 3250
						rootSessionId = current.rootSessionId, -- 3251
						status = "RUNNING", -- 3252
						currentTaskId = current.currentTaskId, -- 3253
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3254
						goal = spawnInfo and spawnInfo.goal, -- 3255
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3256
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3257
						createdAt = current.createdAt, -- 3258
						updatedAt = current.updatedAt -- 3259
					} -- 3259
				end -- 3259
				::__continue537:: -- 3259
				i = i + 1 -- 3241
			end -- 3241
		end -- 3241
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3262
		local completedSessions = __TS__ArrayMap( -- 3263
			completedRecords, -- 3263
			function(____, record) return { -- 3263
				sessionId = record.sessionId, -- 3264
				title = record.title, -- 3265
				parentSessionId = record.parentSessionId, -- 3266
				rootSessionId = record.rootSessionId, -- 3267
				status = record.status, -- 3268
				goal = record.goal, -- 3269
				expectedOutput = record.expectedOutput, -- 3270
				filesHint = record.filesHint, -- 3271
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3272
				success = record.success, -- 3273
				cleared = record.cleared, -- 3274
				resultFilePath = record.resultFilePath, -- 3275
				artifactDir = record.artifactDir, -- 3276
				finishedAt = record.finishedAt, -- 3277
				createdAt = record.createdAtTs, -- 3278
				updatedAt = record.finishedAtTs -- 3279
			} end -- 3279
		) -- 3279
		local merged = {} -- 3281
		if status == "running" then -- 3281
			merged = runningSessions -- 3283
		elseif status == "done" then -- 3283
			merged = __TS__ArrayFilter( -- 3285
				completedSessions, -- 3285
				function(____, item) return item.status == "DONE" end -- 3285
			) -- 3285
		elseif status == "failed" then -- 3285
			merged = __TS__ArrayFilter( -- 3287
				completedSessions, -- 3287
				function(____, item) return item.status == "FAILED" end -- 3287
			) -- 3287
		elseif status == "stopped" then -- 3287
			merged = __TS__ArrayFilter( -- 3289
				completedSessions, -- 3289
				function(____, item) return item.status == "STOPPED" end -- 3289
			) -- 3289
		elseif status == "all" then -- 3289
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3291
		else -- 3291
			local runningKeys = {} -- 3293
			do -- 3293
				local i = 0 -- 3294
				while i < #runningSessions do -- 3294
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3295
					i = i + 1 -- 3294
				end -- 3294
			end -- 3294
			local latestCompletedByKey = {} -- 3297
			do -- 3297
				local i = 0 -- 3298
				while i < #completedSessions do -- 3298
					do -- 3298
						local item = completedSessions[i + 1] -- 3299
						local key = getSubAgentDisplayKey(item) -- 3300
						if runningKeys[key] then -- 3300
							goto __continue552 -- 3302
						end -- 3302
						local current = latestCompletedByKey[key] -- 3304
						if not current or item.updatedAt > current.updatedAt then -- 3304
							latestCompletedByKey[key] = item -- 3306
						end -- 3306
					end -- 3306
					::__continue552:: -- 3306
					i = i + 1 -- 3298
				end -- 3298
			end -- 3298
			local latestCompleted = {} -- 3309
			for ____, item in pairs(latestCompletedByKey) do -- 3310
				latestCompleted[#latestCompleted + 1] = item -- 3311
			end -- 3311
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3313
		end -- 3313
		if query ~= "" then -- 3313
			merged = __TS__ArrayFilter( -- 3316
				merged, -- 3316
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3316
			) -- 3316
		end -- 3316
		__TS__ArraySort( -- 3322
			merged, -- 3322
			function(____, a, b) -- 3322
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3322
					return -1 -- 3323
				end -- 3323
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3323
					return 1 -- 3324
				end -- 3324
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3324
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3326
				end -- 3326
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3328
			end -- 3322
		) -- 3322
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3330
		return ____awaiter_resolve(nil, { -- 3330
			success = true, -- 3332
			rootSessionId = rootSession.id, -- 3333
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3334
			status = status, -- 3335
			limit = limit, -- 3336
			offset = offset, -- 3337
			hasMore = offset + limit < #merged, -- 3338
			sessions = paged -- 3339
		}) -- 3339
	end) -- 3339
end -- 3209
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 275
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 276
SPAWN_INFO_FILE = "SPAWN.json" -- 277
RESULT_FILE = "RESULT.md" -- 278
PENDING_HANDOFF_DIR = "pending-handoffs" -- 279
MAX_CONCURRENT_SUB_AGENTS = 4 -- 280
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 281
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 282
activeStopTokens = {} -- 332
finalizingSubSessionTaskIds = {} -- 333
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 334
now = function() return os.time() end -- 335
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 983
	if projectRoot == oldRoot then -- 983
		return newRoot -- 985
	end -- 985
	for ____, separator in ipairs({"/", "\\"}) do -- 987
		local prefix = oldRoot .. separator -- 988
		if __TS__StringStartsWith(projectRoot, prefix) then -- 988
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 990
		end -- 990
	end -- 990
	return nil -- 993
end -- 983
local function clearSessionAfterMessage(sessionId, message) -- 1509
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1510
	local removedStepIds = {} -- 1518
	do -- 1518
		local i = 0 -- 1519
		while i < #removedStepRows do -- 1519
			local row = removedStepRows[i + 1] -- 1520
			if type(row[1]) == "number" then -- 1520
				removedStepIds[#removedStepIds + 1] = row[1] -- 1522
			end -- 1522
			i = i + 1 -- 1519
		end -- 1519
	end -- 1519
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1525
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1533
	return removedStepIds -- 1538
end -- 1509
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1541
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1542
	local persisted = storage:readSessionState() -- 1543
	local userIndex = -1 -- 1544
	do -- 1544
		local i = #persisted.messages - 1 -- 1545
		while i >= 0 do -- 1545
			if persisted.messages[i + 1].role == "user" then -- 1545
				userIndex = i -- 1547
				break -- 1548
			end -- 1548
			i = i - 1 -- 1545
		end -- 1545
	end -- 1545
	if userIndex < 0 then -- 1545
		return -- 1551
	end -- 1551
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1552
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1553
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1554
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1559
end -- 1541
local function listCurrentTaskCheckpoints(sessionId) -- 1571
	local session = getSessionItem(sessionId) -- 1572
	local taskId = session and session.currentTaskId -- 1573
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1574
end -- 1571
local function getAgentStepCount(sessionId, taskId) -- 1681
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1682
		sessionId, -- 1687
		taskId, -- 1688
		"compress_memory", -- 1689
		"merge_memory", -- 1690
		"sub_agent_handoff", -- 1691
		"questionnaire_answer", -- 1692
		"message" -- 1693
	}) -- 1693
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1696
end -- 1681
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1699
	if status == nil then -- 1699
		status = "DONE" -- 1707
	end -- 1707
	local step = getNextStepNumber(sessionId, taskId) -- 1709
	upsertStep( -- 1710
		sessionId, -- 1710
		taskId, -- 1710
		step, -- 1710
		tool, -- 1710
		{status = status, reason = reason, params = params, result = result} -- 1710
	) -- 1710
	return getStepItem(sessionId, taskId, step) -- 1716
end -- 1699
local function sanitizeStoredSteps(sessionId) -- 1783
	DB:exec( -- 1784
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1784
		{ -- 1802
			now(), -- 1802
			sessionId -- 1802
		} -- 1802
	) -- 1802
end -- 1783
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2255
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2255
		return {success = false, message = "invalid projectRoot"} -- 2257
	end -- 2257
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2259
	for ____, row in ipairs(rows) do -- 2260
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2261
		if sessionId > 0 then -- 2261
			deleteSessionRecords(sessionId) -- 2263
		end -- 2263
	end -- 2263
	return {success = true, deleted = #rows} -- 2266
end -- 2255
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2269
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2269
		return {success = false, message = "invalid projectRoot"} -- 2271
	end -- 2271
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2273
	local renamed = 0 -- 2274
	for ____, row in ipairs(rows) do -- 2275
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2276
		local projectRoot = toStr(row[2]) -- 2277
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2278
		if sessionId > 0 and nextProjectRoot then -- 2278
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2280
			DB:exec( -- 2281
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2281
				{ -- 2283
					nextProjectRoot, -- 2283
					Path:getFilename(nextProjectRoot), -- 2283
					now(), -- 2283
					sessionId -- 2283
				} -- 2283
			) -- 2283
			renamed = renamed + 1 -- 2285
		end -- 2285
	end -- 2285
	return {success = true, renamed = renamed} -- 2288
end -- 2269
function ____exports.getSession(sessionId, view) -- 2291
	local session = getSessionItem(sessionId) -- 2292
	if not session then -- 2292
		return {success = false, message = "session not found"} -- 2294
	end -- 2294
	local restored = restorePendingQuestionnaireState(session) -- 2296
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2297
	local relatedSessions = listRelatedSessions(sessionId) -- 2298
	sanitizeStoredSteps(sessionId) -- 2299
	local firstMessageId = 0 -- 2300
	local hasEarlierMessages = false -- 2301
	if view then -- 2301
		local limit = math.max( -- 2303
			1, -- 2303
			math.min( -- 2303
				1000, -- 2303
				math.floor(view.recentRounds) -- 2303
			) -- 2303
		) -- 2303
		local requests = queryRows(("SELECT id FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND role = 'user'\n\t\t\tORDER BY id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2304
		if #requests > limit then -- 2304
			firstMessageId = requests[limit][1] -- 2309
			hasEarlierMessages = true -- 2310
		end -- 2310
	end -- 2310
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2313
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2320
	local ____relatedSessions_62 = relatedSessions -- 2332
	local ____temp_61 -- 2333
	if normalizedSession.kind == "sub" then -- 2333
		____temp_61 = getSessionSpawnInfo(normalizedSession) -- 2333
	else -- 2333
		____temp_61 = nil -- 2333
	end -- 2333
	return { -- 2329
		success = true, -- 2330
		session = normalizedSession, -- 2331
		relatedSessions = ____relatedSessions_62, -- 2332
		spawnInfo = ____temp_61, -- 2333
		messages = __TS__ArrayMap( -- 2334
			messages, -- 2334
			function(____, row) return rowToMessage(row) end -- 2334
		), -- 2334
		hasEarlierMessages = hasEarlierMessages, -- 2335
		steps = __TS__ArrayMap( -- 2336
			steps, -- 2336
			function(____, row) return rowToStep(row) end -- 2336
		), -- 2336
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2337
		pendingQuestionnaire = restored.questionnaire, -- 2338
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2339
	} -- 2339
end -- 2291
function ____exports.setWorkMode(sessionId, workMode) -- 2344
	local session = getSessionItem(sessionId) -- 2345
	if not session then -- 2345
		return {success = false, message = "session not found"} -- 2346
	end -- 2346
	if session.kind ~= "main" then -- 2346
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2347
	end -- 2347
	if workMode ~= "code" and workMode ~= "plan" then -- 2347
		return {success = false, message = "invalid work mode"} -- 2348
	end -- 2348
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2349
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2349
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2351
	end -- 2351
	if getPendingQuestionnaire(sessionId) then -- 2351
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2354
	end -- 2354
	if normalizedSession.workMode ~= workMode then -- 2354
		DB:exec( -- 2357
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2357
			{ -- 2357
				workMode, -- 2357
				now(), -- 2357
				sessionId -- 2357
			} -- 2357
		) -- 2357
	end -- 2357
	local updated = getSessionItem(sessionId) -- 2359
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2360
	return { -- 2361
		success = true, -- 2361
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2361
	} -- 2361
end -- 2344
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2572
	local session = getSessionItem(sessionId) -- 2573
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2573
		return {success = false, message = "project task admission is closed"} -- 2574
	end -- 2574
	if not session then -- 2574
		return {success = false, message = "session not found"} -- 2576
	end -- 2576
	if getPendingQuestionnaire(sessionId) then -- 2576
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2578
	end -- 2578
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2578
		return {success = false, message = "session task is finalizing"} -- 2580
	end -- 2580
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2580
		return {success = false, message = "session task is still stopping"} -- 2583
	end -- 2583
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2583
		return {success = false, message = "session task is not continuable"} -- 2586
	end -- 2586
	if session.currentTaskId == nil then -- 2586
		return {success = false, message = "session task not found"} -- 2589
	end -- 2589
	local taskId = session.currentTaskId -- 2591
	return startPromptTask( -- 2592
		session, -- 2593
		"", -- 2594
		nil, -- 2595
		normalizeDisabledAgentTools(disabledAgentTools), -- 2596
		{ -- 2597
			workMode = session.workMode, -- 2598
			persistUserMessage = false, -- 2599
			resumeConversation = true, -- 2600
			existingTaskId = taskId, -- 2601
			initialStep = math.max( -- 2602
				0, -- 2602
				getNextStepNumber(session.id, taskId) - 1 -- 2602
			), -- 2602
			initialAgentStepCount = getAgentStepCount(session.id, taskId), -- 2603
			llmConfigId = llmConfigId -- 2604
		} -- 2604
	) -- 2604
end -- 2572
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2761
	local session = getSessionItem(sessionId) -- 2762
	if not session then -- 2762
		return {success = false, message = "session not found"} -- 2764
	end -- 2764
	if session.kind ~= "sub" then -- 2764
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2767
	end -- 2767
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2767
		return {success = false, message = "session task is finalizing"} -- 2770
	end -- 2770
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2772
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2772
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2777
	end -- 2777
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2777
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2780
	end -- 2780
	local disabledAgentTools = __TS__ArrayFilter( -- 2782
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2782
		function(____, tool) return tool ~= "finish" end -- 2783
	) -- 2783
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2784
	return startPromptTask( -- 2787
		session, -- 2787
		prompt, -- 2787
		nil, -- 2787
		disabledAgentTools, -- 2787
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2787
	) -- 2787
end -- 2761
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2794
	local session = getSessionItem(sessionId) -- 2795
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2795
		return {success = false, message = "project task admission is closed"} -- 2796
	end -- 2796
	if not session then -- 2796
		return {success = false, message = "session not found"} -- 2798
	end -- 2798
	if getPendingQuestionnaire(sessionId) then -- 2798
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2800
	end -- 2800
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2800
		return {success = false, message = "session task is finalizing"} -- 2802
	end -- 2802
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2802
		return {success = false, message = "session task is still running"} -- 2805
	end -- 2805
	local message = getMessageItem(messageId) -- 2807
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2807
		return {success = false, message = "message not found"} -- 2809
	end -- 2809
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2811
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2817
	if latestUserMessageId ~= messageId then -- 2817
		return {success = false, message = "only the latest user prompt can be edited"} -- 2819
	end -- 2819
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2821
	if normalizedPrompt == "" then -- 2821
		return {success = false, message = "prompt is empty"} -- 2823
	end -- 2823
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2825
	if session.workMode ~= nextWorkMode then -- 2825
		DB:exec( -- 2827
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2827
			{ -- 2827
				nextWorkMode, -- 2827
				now(), -- 2827
				session.id -- 2827
			} -- 2827
		) -- 2827
		session.workMode = nextWorkMode -- 2828
	end -- 2828
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2830
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2831
	local result = startPromptTask( -- 2832
		session, -- 2832
		normalizedPrompt, -- 2832
		messageId, -- 2832
		normalizeDisabledAgentTools(disabledAgentTools), -- 2832
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2832
	) -- 2832
	if result.success and #removedStepIds > 0 then -- 2832
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2834
	end -- 2834
	return result -- 2836
end -- 2794
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2841
	if status == "dismissed" then -- 2841
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2847
	end -- 2847
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2849
end -- 2841
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2852
	if status == "dismissed" then -- 2852
		return { -- 2858
			success = true, -- 2859
			status = "dismissed", -- 2860
			source = "user", -- 2861
			questionnaireId = questionnaire.id, -- 2862
			title = questionnaire.schema.title, -- 2863
			answers = {}, -- 2864
			responses = {}, -- 2865
			displayText = "用户关闭了调查问卷，未作答。", -- 2866
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2867
		} -- 2867
	end -- 2867
	local responses = {} -- 2870
	do -- 2870
		local i = 0 -- 2871
		while i < #questionnaire.schema.questions do -- 2871
			do -- 2871
				local question = questionnaire.schema.questions[i + 1] -- 2872
				local answer = __TS__ArrayFind( -- 2873
					answers, -- 2873
					function(____, item) return item.questionId == question.id end -- 2873
				) -- 2873
				if not answer or answer.status == "skipped" then -- 2873
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2875
					goto __continue450 -- 2880
				end -- 2880
				local selectedOptionLabels = {} -- 2882
				do -- 2882
					local j = 0 -- 2883
					while j < #(answer.selectedOptionIds or ({})) do -- 2883
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2884
						local option = __TS__ArrayFind( -- 2885
							question.options or ({}), -- 2885
							function(____, item) return item.id == optionId end -- 2885
						) -- 2885
						if option then -- 2885
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2886
						end -- 2886
						j = j + 1 -- 2883
					end -- 2883
				end -- 2883
				responses[#responses + 1] = { -- 2888
					questionId = question.id, -- 2889
					prompt = question.prompt, -- 2890
					status = "answered", -- 2891
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2892
					selectedOptionLabels = selectedOptionLabels, -- 2893
					otherText = answer.otherText, -- 2894
					text = answer.text -- 2895
				} -- 2895
			end -- 2895
			::__continue450:: -- 2895
			i = i + 1 -- 2871
		end -- 2871
	end -- 2871
	return { -- 2898
		success = true, -- 2899
		status = "answered", -- 2900
		source = "user", -- 2901
		questionnaireId = questionnaire.id, -- 2902
		title = questionnaire.schema.title, -- 2903
		answers = answers, -- 2904
		responses = responses, -- 2905
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2906
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2907
	} -- 2907
end -- 2852
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2933
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2939
	local persisted = storage:readSessionState() -- 2940
	local messages = __TS__ArraySlice(persisted.messages) -- 2941
	local toolResultIndex = -1 -- 2942
	local existingResult -- 2943
	do -- 2943
		local i = #messages - 1 -- 2944
		while i >= 0 do -- 2944
			do -- 2944
				local message = messages[i + 1] -- 2945
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2945
					goto __continue470 -- 2946
				end -- 2946
				local decoded = safeJsonDecode(message.content) -- 2947
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2947
					goto __continue470 -- 2948
				end -- 2948
				local row = decoded -- 2949
				if row.questionnaireId ~= questionnaire.id then -- 2949
					goto __continue470 -- 2950
				end -- 2950
				toolResultIndex = i -- 2951
				existingResult = row -- 2952
				break -- 2953
			end -- 2953
			::__continue470:: -- 2953
			i = i - 1 -- 2944
		end -- 2944
	end -- 2944
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2955
	local guidance = {} -- 2956
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2956
		guidance[#guidance + 1] = existingResult.guidance -- 2958
	end -- 2958
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2958
		guidance[#guidance + 1] = result.guidance -- 2961
	end -- 2961
	result.guidance = table.concat(guidance, "\n") -- 2963
	if toolResultIndex < 0 then -- 2963
		messages[#messages + 1] = { -- 2965
			role = "user", -- 2966
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 2967
		} -- 2967
		toolResultIndex = #messages - 1 -- 2969
	else -- 2969
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2971
			{}, -- 2971
			messages[toolResultIndex + 1], -- 2972
			{content = encodeJson(result)} -- 2971
		) -- 2971
	end -- 2971
	local pairStartIndex = toolResultIndex -- 2977
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2978
	if toolCallId and toolCallId ~= "" then -- 2978
		do -- 2978
			local i = toolResultIndex - 1 -- 2980
			while i >= 0 do -- 2980
				do -- 2980
					local message = messages[i + 1] -- 2981
					if message.role ~= "assistant" or not message.tool_calls then -- 2981
						goto __continue480 -- 2982
					end -- 2982
					if __TS__ArraySome( -- 2982
						message.tool_calls, -- 2983
						function(____, call) return call.id == toolCallId end -- 2983
					) then -- 2983
						pairStartIndex = i -- 2984
						break -- 2985
					end -- 2985
				end -- 2985
				::__continue480:: -- 2985
				i = i - 1 -- 2980
			end -- 2980
		end -- 2980
	end -- 2980
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2989
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2992
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2996
	upsertStep( -- 2998
		session.id, -- 2998
		questionnaire.taskId, -- 2998
		questionnaire.step, -- 2998
		"ask_user", -- 2998
		{status = "DONE", result = result} -- 2998
	) -- 2998
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3002
	upsertStep( -- 3003
		session.id, -- 3003
		questionnaire.taskId, -- 3003
		answerStep, -- 3003
		"questionnaire_answer", -- 3003
		{status = "DONE", result = result} -- 3003
	) -- 3003
	return {success = true, answerStep = answerStep, result = result} -- 3007
end -- 2933
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3010
	local session = getSessionItem(sessionId) -- 3011
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3011
		return {success = false, message = "project task admission is closed"} -- 3012
	end -- 3012
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
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3019
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
end -- 3010
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3056
	local session = getSessionItem(sessionId) -- 3057
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3057
		return {success = false, message = "project task admission is closed"} -- 3058
	end -- 3058
	if not session then -- 3058
		return {success = false, message = "session not found"} -- 3059
	end -- 3059
	if session.kind ~= "main" then -- 3059
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3060
	end -- 3060
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3061
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3061
		return {success = false, message = "pending questionnaire not found"} -- 3062
	end -- 3062
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3063
	if not validated.success then -- 3063
		return validated -- 3064
	end -- 3064
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3065
	if not llmConfigRes.success then -- 3065
		return {success = false, message = llmConfigRes.message} -- 3066
	end -- 3066
	local t = now() -- 3067
	if not removePendingQuestionnaire(session) then -- 3067
		return {success = false, message = "failed to consume questionnaire file"} -- 3068
	end -- 3068
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3069
	if not replaced.success then -- 3069
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3071
		return replaced -- 3072
	end -- 3072
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3074
	session.workMode = "plan" -- 3075
	local result = startPromptTask( -- 3076
		session, -- 3076
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3076
		nil, -- 3076
		{}, -- 3076
		{ -- 3076
			workMode = "plan", -- 3077
			persistUserMessage = false, -- 3078
			resumeConversation = true, -- 3079
			existingTaskId = questionnaire.taskId, -- 3080
			initialStep = replaced.answerStep, -- 3081
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3082
			llmConfig = llmConfigRes.config -- 3083
		} -- 3083
	) -- 3083
	if not result.success then -- 3083
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3086
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3087
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3088
		emitAgentSessionPatch( -- 3089
			session.id, -- 3089
			{ -- 3089
				session = getSessionItem(session.id), -- 3090
				pendingQuestionnaire = questionnaire -- 3091
			} -- 3091
		) -- 3091
		return result -- 3093
	end -- 3093
	emitAgentSessionPatch( -- 3095
		sessionId, -- 3095
		{ -- 3095
			session = getSessionItem(sessionId), -- 3096
			pendingQuestionnaire = false -- 3097
		} -- 3097
	) -- 3097
	return result -- 3099
end -- 3056
function ____exports.stopSessionTask(sessionId) -- 3102
	local session = getSessionItem(sessionId) -- 3103
	if not session or session.currentTaskId == nil then -- 3103
		return {success = false, message = "session task not found"} -- 3105
	end -- 3105
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3105
		return {success = false, message = "session task is finalizing"} -- 3108
	end -- 3108
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3110
	local stopToken = activeStopTokens[session.currentTaskId] -- 3111
	if not stopToken then -- 3111
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3111
			return {success = true, recovered = true} -- 3114
		end -- 3114
		return {success = false, message = "task is not running"} -- 3116
	end -- 3116
	if stopToken.stopped then -- 3116
		return {success = true, stopping = true} -- 3119
	end -- 3119
	stopToken.stopped = true -- 3121
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3122
	return {success = true, stopping = true} -- 3126
end -- 3102
function ____exports.getCurrentTaskId(sessionId) -- 3129
	local ____opt_126 = getSessionItem(sessionId) -- 3129
	return ____opt_126 and ____opt_126.currentTaskId -- 3130
end -- 3129
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3134
	local owner = getSessionItem(sessionId) -- 3135
	if not owner then -- 3135
		return {success = false, message = "session not found"} -- 3136
	end -- 3136
	local projectRoot = owner.projectRoot -- 3137
	local release = holdProjectTaskAdmission(projectRoot) -- 3138
	local closed = false -- 3139
	return { -- 3140
		success = true, -- 3141
		projectRoot = projectRoot, -- 3142
		close = function() -- 3143
			if not closed then -- 3143
				closed = true -- 3143
				release() -- 3143
			end -- 3143
		end, -- 3143
		poll = function() -- 3144
			if closed then -- 3144
				return {success = false, message = "quiescence handle closed"} -- 3145
			end -- 3145
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3146
			if not rows then -- 3146
				return {success = false, message = "failed to inspect project tasks"} -- 3147
			end -- 3147
			local pending = {} -- 3148
			for ____, row in ipairs(rows) do -- 3149
				do -- 3149
					local session = rowToSession(row) -- 3150
					local taskId = session.currentTaskId -- 3151
					if taskId == nil then -- 3151
						goto __continue517 -- 3152
					end -- 3152
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3153
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3153
						goto __continue517 -- 3154
					end -- 3154
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3156
					local ____session_id_129 = session.id -- 3157
					local ____taskId_130 = taskId -- 3157
					local ____finalizing_131 = finalizing -- 3157
					local ____result_success_132 = result.success -- 3157
					local ____result_success_128 -- 3157
					if result.success then -- 3157
						____result_success_128 = nil -- 3157
					else -- 3157
						____result_success_128 = result.message -- 3157
					end -- 3157
					pending[#pending + 1] = { -- 3157
						sessionId = ____session_id_129, -- 3157
						taskId = ____taskId_130, -- 3157
						finalizing = ____finalizing_131, -- 3157
						stopRequested = ____result_success_132, -- 3157
						message = ____result_success_128 -- 3157
					} -- 3157
				end -- 3157
				::__continue517:: -- 3157
			end -- 3157
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3161
		end -- 3144
	} -- 3144
end -- 3134
function ____exports.validateTaskAccess(sessionId, taskId) -- 3166
	local session = getSessionItem(sessionId) -- 3167
	if not session then -- 3167
		return {success = false, message = "session not found"} -- 3168
	end -- 3168
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3168
		getSessionOperableTaskIds(sessionId), -- 3169
		taskId -- 3169
	) < 0 then -- 3169
		return {success = false, message = "task is not operable for this session"} -- 3170
	end -- 3170
	return {success = true, session = session} -- 3172
end -- 3166
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3175
	if checkpointId <= 0 then -- 3175
		return {success = false, message = "invalid checkpointId"} -- 3177
	end -- 3177
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3179
	if not checkpoint then -- 3179
		return {success = false, message = "checkpoint not found"} -- 3181
	end -- 3181
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3183
	if not taskAccess.success then -- 3183
		return taskAccess -- 3184
	end -- 3184
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3185
end -- 3175
function ____exports.listRunningSessions() -- 3188
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3189
	local sessions = {} -- 3196
	do -- 3196
		local i = 0 -- 3197
		while i < #rows do -- 3197
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3198
			if session.currentTaskStatus == "RUNNING" then -- 3198
				sessions[#sessions + 1] = session -- 3200
			end -- 3200
			i = i + 1 -- 3197
		end -- 3197
	end -- 3197
	return {success = true, sessions = sessions} -- 3203
end -- 3188
return ____exports -- 3188