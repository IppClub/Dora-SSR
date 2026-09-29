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
local getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, activeLocalAgentControls, finalizingSubSessionTaskIds, SESSION_SELECT_COLUMNS, now -- 1
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
local LocalAgent = require("Agent.LocalAgent") -- 12
local Tools = require("Agent.Tools") -- 13
local ____Database = require("Agent.Storage.Database") -- 14
local TABLE_SESSION = ____Database.TABLE_SESSION -- 15
local TABLE_MESSAGE = ____Database.TABLE_MESSAGE -- 16
local TABLE_STEP = ____Database.TABLE_STEP -- 17
local TABLE_TASK = ____Database.TABLE_TASK -- 18
local TABLE_TASK_REFERENCE = ____Database.TABLE_TASK_REFERENCE -- 19
local addTaskReference = ____Database.addTaskReference -- 20
local cleanupTaskHeavyData = ____Database.cleanupTaskHeavyData -- 21
local getSessionOperableTaskIds = ____Database.getSessionOperableTaskIds -- 22
local requireAgentStorage = ____Database.requireAgentStorage -- 23
local ____Memory = require("Agent.Memory") -- 25
local DualLayerStorage = ____Memory.DualLayerStorage -- 25
local ____Utils = require("Agent.Utils") -- 26
local Log = ____Utils.Log -- 26
local getLLMConfig = ____Utils.getLLMConfig -- 26
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 26
local safeJsonDecode = ____Utils.safeJsonDecode -- 26
local safeJsonEncode = ____Utils.safeJsonEncode -- 26
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 26
local validateAgentLLMConfig = ____Utils.validateAgentLLMConfig -- 26
local ____Questionnaire = require("Agent.Questionnaire") -- 30
local validateQuestionnaireAnswers = ____Questionnaire.validateQuestionnaireAnswers -- 30
local ____Support = require("Agent.Storage.Support") -- 32
local getLastInsertRowId = ____Support.getLastInsertRowId -- 32
local queryOne = ____Support.queryOne -- 32
local queryRows = ____Support.queryRows -- 32
local toStr = ____Support.toStr -- 32
function getDefaultUseChineseResponse() -- 339
	local zh = string.match(App.locale, "^zh") -- 340
	return zh ~= nil -- 341
end -- 341
function encodeJson(value) -- 344
	local text = safeJsonEncode(value) -- 345
	return text or "" -- 346
end -- 346
function decodeJsonObject(text) -- 349
	if text == "" then -- 349
		return nil -- 350
	end -- 350
	local value = safeJsonDecode(text) -- 351
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 351
		return value -- 353
	end -- 353
	return nil -- 355
end -- 355
function decodeJsonFiles(text) -- 358
	if text == "" then -- 358
		return nil -- 359
	end -- 359
	local value = safeJsonDecode(text) -- 360
	if not value or not __TS__ArrayIsArray(value) then -- 360
		return nil -- 361
	end -- 361
	local files = {} -- 362
	do -- 362
		local i = 0 -- 363
		while i < #value do -- 363
			do -- 363
				local item = value[i + 1] -- 364
				if type(item) ~= "table" then -- 364
					goto __continue12 -- 365
				end -- 365
				files[#files + 1] = { -- 366
					path = sanitizeUTF8(toStr(item.path)), -- 367
					op = sanitizeUTF8(toStr(item.op)) -- 368
				} -- 368
			end -- 368
			::__continue12:: -- 368
			i = i + 1 -- 363
		end -- 363
	end -- 363
	return files -- 371
end -- 371
function decodeChangeSetSummary(value) -- 374
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 374
		return nil -- 375
	end -- 375
	local row = value -- 376
	if row.success ~= true then -- 376
		return nil -- 377
	end -- 377
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 378
	if taskId <= 0 then -- 378
		return nil -- 379
	end -- 379
	local files = {} -- 380
	if __TS__ArrayIsArray(row.files) then -- 380
		do -- 380
			local i = 0 -- 382
			while i < #row.files do -- 382
				do -- 382
					local file = row.files[i + 1] -- 383
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 383
						goto __continue20 -- 384
					end -- 384
					local fileRow = file -- 385
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 386
					if path == "" then -- 386
						goto __continue20 -- 387
					end -- 387
					local checkpointIds = {} -- 388
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 388
						do -- 388
							local j = 0 -- 390
							while j < #fileRow.checkpointIds do -- 390
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 391
								if checkpointId > 0 then -- 391
									checkpointIds[#checkpointIds + 1] = checkpointId -- 392
								end -- 392
								j = j + 1 -- 390
							end -- 390
						end -- 390
					end -- 390
					local op = toStr(fileRow.op) -- 395
					files[#files + 1] = { -- 396
						path = path, -- 397
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 398
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 399
						checkpointIds = checkpointIds -- 400
					} -- 400
				end -- 400
				::__continue20:: -- 400
				i = i + 1 -- 382
			end -- 382
		end -- 382
	end -- 382
	return { -- 404
		success = true, -- 405
		taskId = taskId, -- 406
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 407
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 408
		files = files, -- 409
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 410
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 411
	} -- 411
end -- 411
function decodeHandoffEvidence(value) -- 415
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 415
		return nil -- 416
	end -- 416
	local row = value -- 417
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 418
		__TS__ArrayFilter( -- 419
			row.modifiedFiles, -- 419
			function(____, item) return type(item) == "string" end -- 419
		), -- 419
		function(____, item) return sanitizeUTF8(item) end -- 419
	) or ({}) -- 419
	local lastBuild = nil -- 421
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 421
		local build = row.lastBuild -- 423
		lastBuild = { -- 424
			result = build.result == "passed" and "passed" or "failed", -- 425
			path = sanitizeUTF8(toStr(build.path)), -- 426
			evidence = takeUtf8Head( -- 427
				sanitizeUTF8(toStr(build.evidence)), -- 427
				600 -- 427
			) -- 427
		} -- 427
	end -- 427
	local commands = {} -- 430
	if __TS__ArrayIsArray(row.commands) then -- 430
		do -- 430
			local i = 0 -- 432
			while i < #row.commands and #commands < 8 do -- 432
				do -- 432
					local raw = row.commands[i + 1] -- 433
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 433
						goto __continue34 -- 434
					end -- 434
					local item = raw -- 435
					commands[#commands + 1] = { -- 436
						mode = sanitizeUTF8(toStr(item.mode)), -- 437
						command = takeUtf8Head( -- 438
							sanitizeUTF8(toStr(item.command)), -- 438
							600 -- 438
						), -- 438
						result = item.result == "passed" and "passed" or "failed", -- 439
						evidence = takeUtf8Head( -- 440
							sanitizeUTF8(toStr(item.evidence)), -- 440
							600 -- 440
						) -- 440
					} -- 440
				end -- 440
				::__continue34:: -- 440
				i = i + 1 -- 432
			end -- 432
		end -- 432
	end -- 432
	local authoritativeSources = {} -- 444
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 444
		do -- 444
			local i = 0 -- 446
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 446
				do -- 446
					local raw = row.authoritativeSources[i + 1] -- 447
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 447
						goto __continue38 -- 448
					end -- 448
					local item = raw -- 449
					authoritativeSources[#authoritativeSources + 1] = { -- 450
						tool = "search_dora_doc", -- 451
						query = takeUtf8Head( -- 452
							sanitizeUTF8(toStr(item.query)), -- 452
							300 -- 452
						), -- 452
						source = sanitizeUTF8(toStr(item.source)), -- 453
						result = item.result == "passed" and "passed" or "failed" -- 454
					} -- 454
				end -- 454
				::__continue38:: -- 454
				i = i + 1 -- 446
			end -- 446
		end -- 446
	end -- 446
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 458
end -- 458
function takeUtf8Head(text, maxChars) -- 461
	if maxChars <= 0 or text == "" then -- 461
		return "" -- 462
	end -- 462
	local nextPos = utf8.offset(text, maxChars + 1) -- 463
	if nextPos == nil then -- 463
		return text -- 464
	end -- 464
	return string.sub(text, 1, nextPos - 1) -- 465
end -- 465
function normalizeMemoryEntryEvidence(value) -- 468
	local evidence = {} -- 469
	if not __TS__ArrayIsArray(value) then -- 469
		return evidence -- 470
	end -- 470
	do -- 470
		local i = 0 -- 471
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 471
			do -- 471
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 472
				if item == "" then -- 472
					goto __continue46 -- 473
				end -- 473
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 473
					evidence[#evidence + 1] = item -- 475
				end -- 475
			end -- 475
			::__continue46:: -- 475
			i = i + 1 -- 471
		end -- 471
	end -- 471
	return evidence -- 478
end -- 478
function decodeSubAgentMemoryEntry(value) -- 481
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 481
		return nil -- 482
	end -- 482
	local row = value -- 483
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 484
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 485
	local content = takeUtf8Head( -- 486
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 486
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 486
	) -- 486
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 486
		return nil -- 487
	end -- 487
	return { -- 488
		sourceSessionId = sourceSessionId, -- 489
		sourceTaskId = sourceTaskId, -- 490
		content = content, -- 491
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 492
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 493
	} -- 493
end -- 493
function getTaskChangeSetSummary(taskId) -- 497
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 498
	return summary.success and summary or nil -- 499
end -- 499
function summarizeHandoffResult(result) -- 502
	local candidates = {result.output, result.message, result.state, result.phase} -- 503
	do -- 503
		local i = 0 -- 504
		while i < #candidates do -- 504
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 505
			if text ~= "" then -- 505
				return takeUtf8Head(text, 600) -- 506
			end -- 506
			i = i + 1 -- 504
		end -- 504
	end -- 504
	local messages = result.messages -- 508
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 508
		local parts = {} -- 510
		do -- 510
			local i = 0 -- 511
			while i < #messages and #parts < 4 do -- 511
				do -- 511
					local row = messages[i + 1] -- 512
					if not row or type(row) ~= "table" then -- 512
						goto __continue59 -- 513
					end -- 513
					local item = row -- 514
					local ____sanitizeUTF8_3 = sanitizeUTF8 -- 515
					local ____toStr_2 = toStr -- 515
					local ____item_message_0 = item.message -- 515
					if ____item_message_0 == nil then -- 515
						____item_message_0 = item.error -- 515
					end -- 515
					local ____item_message_0_1 = ____item_message_0 -- 515
					if ____item_message_0_1 == nil then -- 515
						____item_message_0_1 = item.file -- 515
					end -- 515
					local text = __TS__StringTrim(____sanitizeUTF8_3(____toStr_2(____item_message_0_1))) -- 515
					if text ~= "" then -- 515
						parts[#parts + 1] = text -- 516
					end -- 516
				end -- 516
				::__continue59:: -- 516
				i = i + 1 -- 511
			end -- 511
		end -- 511
		if #parts > 0 then -- 511
			return takeUtf8Head( -- 518
				table.concat(parts, "; "), -- 518
				600 -- 518
			) -- 518
		end -- 518
	end -- 518
	return result.success == true and "tool result success=true" or "tool result success=false" -- 520
end -- 520
function getTaskHandoffEvidence(taskId, changeSet) -- 523
	local ____opt_4 = changeSet -- 523
	local evidence = { -- 524
		modifiedFiles = ____opt_4 and __TS__ArrayMap( -- 525
			changeSet and changeSet.files, -- 525
			function(____, item) return item.path end -- 525
		) or ({}), -- 525
		commands = {}, -- 526
		authoritativeSources = {} -- 527
	} -- 527
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 529
	do -- 529
		local i = 0 -- 534
		while i < #rows do -- 534
			local tool = toStr(rows[i + 1][1]) -- 535
			local status = toStr(rows[i + 1][2]) -- 536
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 537
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 538
			local passed = status == "DONE" and result.success == true -- 539
			if tool == "build" then -- 539
				evidence.lastBuild = { -- 541
					result = passed and "passed" or "failed", -- 542
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 543
					evidence = summarizeHandoffResult(result) -- 544
				} -- 544
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 544
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 547
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 548
				local ____evidence_commands_8 = evidence.commands -- 548
				____evidence_commands_8[#____evidence_commands_8 + 1] = { -- 549
					mode = mode, -- 550
					command = takeUtf8Head( -- 551
						__TS__StringTrim(sanitizeUTF8(command)), -- 551
						600 -- 551
					), -- 551
					result = passed and "passed" or "failed", -- 552
					evidence = summarizeHandoffResult(result) -- 553
				} -- 553
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 553
				local ____evidence_authoritativeSources_9 = evidence.authoritativeSources -- 553
				____evidence_authoritativeSources_9[#____evidence_authoritativeSources_9 + 1] = { -- 556
					tool = "search_dora_doc", -- 557
					query = takeUtf8Head( -- 558
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 558
						300 -- 558
					), -- 558
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 559
					result = passed and "passed" or "failed" -- 560
				} -- 560
			end -- 560
			i = i + 1 -- 534
		end -- 534
	end -- 534
	return evidence -- 564
end -- 564
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 567
	local lastBuild = evidence.lastBuild -- 571
	if not lastBuild or lastBuild.result ~= "failed" then -- 571
		return completion -- 572
	end -- 572
	local validation = __TS__ArraySlice(completion.validation) -- 573
	local foundBuild = false -- 574
	do -- 574
		local i = 0 -- 575
		while i < #validation do -- 575
			do -- 575
				if validation[i + 1].kind ~= "build" then -- 575
					goto __continue73 -- 576
				end -- 576
				foundBuild = true -- 577
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 578
			end -- 578
			::__continue73:: -- 578
			i = i + 1 -- 575
		end -- 575
	end -- 575
	if not foundBuild then -- 575
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 585
	end -- 585
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 587
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 588
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 588
		knownIssues[#knownIssues + 1] = issue -- 589
	end -- 589
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 590
end -- 590
function isValidProjectRoot(path) -- 598
	return path ~= "" and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 599
end -- 599
function rowToSession(row) -- 602
	return { -- 603
		id = row[1], -- 604
		projectRoot = toStr(row[2]), -- 605
		title = toStr(row[3]), -- 606
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 607
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 608
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 609
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 610
		status = toStr(row[8]), -- 611
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 612
		currentTaskStatus = toStr(row[10]), -- 613
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 614
		createdAt = row[11], -- 615
		updatedAt = row[12], -- 616
		metrics = decodeJsonObject(toStr(row[13])), -- 617
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 618
	} -- 618
end -- 618
function rowToMessage(row) -- 622
	local message = { -- 623
		id = row[1], -- 624
		sessionId = row[2], -- 625
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 626
		role = toStr(row[4]), -- 627
		content = toStr(row[5]), -- 628
		createdAt = row[7], -- 629
		updatedAt = row[8] -- 630
	} -- 630
	local displayContent = toStr(row[6]) -- 632
	if displayContent ~= "" then -- 632
		message.displayContent = displayContent -- 633
	end -- 633
	return message -- 634
end -- 634
function rowToStep(row) -- 637
	return { -- 638
		id = row[1], -- 639
		sessionId = row[2], -- 640
		taskId = row[3], -- 641
		step = row[4], -- 642
		tool = toStr(row[5]), -- 643
		status = toStr(row[6]), -- 644
		reason = toStr(row[7]), -- 645
		reasoningContent = toStr(row[8]), -- 646
		params = decodeJsonObject(toStr(row[9])), -- 647
		result = decodeJsonObject(toStr(row[10])), -- 648
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 649
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 650
		files = decodeJsonFiles(toStr(row[13])), -- 651
		createdAt = row[14], -- 652
		updatedAt = row[15] -- 653
	} -- 653
end -- 653
function getQuestionnairePath(projectRoot) -- 657
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 658
end -- 658
function decodeQuestionnaireFile(text) -- 661
	local value = decodeJsonObject(text) -- 662
	if not value then -- 662
		return nil -- 663
	end -- 663
	local schema = value.schema -- 664
	local id = type(value.id) == "number" and value.id or 0 -- 665
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 666
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 667
	local step = type(value.step) == "number" and value.step or 0 -- 668
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 669
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 669
		return nil -- 671
	end -- 671
	return { -- 673
		id = id, -- 673
		sessionId = sessionId, -- 673
		taskId = taskId, -- 673
		step = step, -- 673
		status = "PENDING", -- 673
		schema = schema, -- 673
		createdAt = createdAt -- 673
	} -- 673
end -- 673
function getPendingQuestionnaire(sessionId) -- 676
	local session = getSessionItem(sessionId) -- 677
	if not session or session.kind ~= "main" then -- 677
		return nil -- 678
	end -- 678
	local path = getQuestionnairePath(session.projectRoot) -- 679
	if not Content:exist(path) then -- 679
		return nil -- 680
	end -- 680
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 681
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 682
end -- 682
function restorePendingQuestionnaireState(session) -- 685
	local questionnaire = getPendingQuestionnaire(session.id) -- 686
	if not questionnaire then -- 686
		return {session = session} -- 687
	end -- 687
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 687
		local t = now() -- 694
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 695
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 701
		local restored = getSessionItem(session.id) -- 702
		if restored then -- 702
			session = restored -- 703
		end -- 703
	end -- 703
	return {session = session, questionnaire = questionnaire} -- 705
end -- 705
function savePendingQuestionnaire(projectRoot, questionnaire) -- 708
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 709
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 709
		return false -- 710
	end -- 710
	local path = getQuestionnairePath(projectRoot) -- 711
	local tempPath = path .. ".tmp" -- 712
	local backupPath = path .. ".bak" -- 713
	Content:remove(tempPath) -- 714
	Content:remove(backupPath) -- 715
	if not Content:save( -- 715
		tempPath, -- 716
		encodeJson(questionnaire) -- 716
	) then -- 716
		return false -- 716
	end -- 716
	local hadOriginal = Content:exist(path) -- 717
	if hadOriginal and not Content:move(path, backupPath) then -- 717
		Content:remove(tempPath) -- 719
		return false -- 720
	end -- 720
	if Content:move(tempPath, path) then -- 720
		Content:remove(backupPath) -- 723
		Tools.sendWebIDEFileUpdate( -- 724
			path, -- 724
			true, -- 724
			encodeJson(questionnaire) -- 724
		) -- 724
		return true -- 725
	end -- 725
	Content:remove(tempPath) -- 727
	if hadOriginal and Content:exist(backupPath) then -- 727
		Content:move(backupPath, path) -- 729
	end -- 729
	return false -- 731
end -- 731
function removePendingQuestionnaire(session) -- 734
	local path = getQuestionnairePath(session.projectRoot) -- 735
	if not Content:exist(path) then -- 735
		return true -- 736
	end -- 736
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 737
	if questionnaire and questionnaire.sessionId ~= session.id then -- 737
		return false -- 738
	end -- 738
	if not Content:remove(path) then -- 738
		return false -- 739
	end -- 739
	Tools.sendWebIDEFileUpdate(path, false, "") -- 740
	return true -- 741
end -- 741
function publishQuestionnaire(request) -- 744
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 744
		local session = getSessionItem(request.sessionId) -- 750
		if not session or session.kind ~= "main" then -- 750
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 750
		end -- 750
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 752
		if Content:exist(pendingPath) then -- 752
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 752
		end -- 752
		local questionnaire = { -- 754
			id = request.taskId, -- 755
			sessionId = request.sessionId, -- 756
			taskId = request.taskId, -- 757
			step = request.step, -- 758
			status = "PENDING", -- 759
			schema = request.schema, -- 760
			createdAt = now() -- 761
		} -- 761
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 761
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 761
		end -- 761
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 761
	end) -- 761
end -- 761
function getMessageItem(messageId) -- 769
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 770
	return row and rowToMessage(row) or nil -- 776
end -- 776
function getStepItem(sessionId, taskId, step) -- 779
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 780
	return row and rowToStep(row) or nil -- 786
end -- 786
function deleteMessageSteps(sessionId, taskId) -- 789
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 790
	local ids = {} -- 795
	do -- 795
		local i = 0 -- 796
		while i < #rows do -- 796
			local row = rows[i + 1] -- 797
			if type(row[1]) == "number" then -- 797
				ids[#ids + 1] = row[1] -- 799
			end -- 799
			i = i + 1 -- 796
		end -- 796
	end -- 796
	if #ids > 0 then -- 796
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 803
	end -- 803
	return ids -- 809
end -- 809
function normalizeDisabledAgentTools(value) -- 812
	if not __TS__ArrayIsArray(value) then -- 812
		return {} -- 813
	end -- 813
	local tools = {} -- 814
	do -- 814
		local i = 0 -- 815
		while i < #value do -- 815
			do -- 815
				local name = value[i + 1] -- 816
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 816
					goto __continue117 -- 817
				end -- 817
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 817
					tools[#tools + 1] = name -- 818
				end -- 818
			end -- 818
			::__continue117:: -- 818
			i = i + 1 -- 815
		end -- 815
	end -- 815
	return tools -- 820
end -- 820
function normalizeWorkMode(value, fallback) -- 823
	if fallback == nil then -- 823
		fallback = "code" -- 823
	end -- 823
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 824
end -- 824
function getSessionRow(sessionId) -- 827
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 828
end -- 828
function getSessionItem(sessionId) -- 836
	local row = getSessionRow(sessionId) -- 837
	return row and rowToSession(row) or nil -- 838
end -- 838
function getTaskPrompt(taskId) -- 841
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 842
	if not row or type(row[1]) ~= "string" then -- 842
		return nil -- 843
	end -- 843
	return toStr(row[1]) -- 844
end -- 844
function getLatestMainSessionByProjectRoot(projectRoot) -- 847
	if not isValidProjectRoot(projectRoot) then -- 847
		return nil -- 848
	end -- 848
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 849
	return row and rowToSession(row) or nil -- 857
end -- 857
function countRunningSubSessions(rootSessionId) -- 860
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 861
	local count = 0 -- 868
	do -- 868
		local i = 0 -- 869
		while i < #rows do -- 869
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 870
			if session.currentTaskStatus == "RUNNING" then -- 870
				count = count + 1 -- 872
			end -- 872
			i = i + 1 -- 869
		end -- 869
	end -- 869
	return count -- 875
end -- 875
function deleteSessionRecords(sessionId, preserveArtifacts) -- 878
	if preserveArtifacts == nil then -- 878
		preserveArtifacts = false -- 878
	end -- 878
	local session = getSessionItem(sessionId) -- 879
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 880
	local taskIds = {} -- 888
	do -- 888
		local i = 0 -- 889
		while i < #taskRows do -- 889
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 890
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 890
				taskIds[#taskIds + 1] = taskId -- 892
				local stopToken = activeStopTokens[taskId] -- 893
				if stopToken ~= nil then -- 893
					stopToken.stopped = true -- 895
					stopToken.reason = "session deleted" -- 896
				end -- 896
			end -- 896
			i = i + 1 -- 889
		end -- 889
	end -- 889
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 900
	do -- 900
		local i = 0 -- 901
		while i < #children do -- 901
			local row = children[i + 1] -- 902
			if type(row[1]) == "number" and row[1] > 0 then -- 902
				deleteSessionRecords(row[1], preserveArtifacts) -- 904
			end -- 904
			i = i + 1 -- 901
		end -- 901
	end -- 901
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 907
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 908
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 909
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 910
	if session and session.kind == "main" then -- 910
		removePendingQuestionnaire(session) -- 912
	end -- 912
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 912
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 912
			Tools.sendWebIDERefreshTree() -- 916
		end -- 916
	end -- 916
	do -- 916
		local i = 0 -- 919
		while i < #taskIds do -- 919
			cleanupTaskHeavyData(taskIds[i + 1]) -- 920
			i = i + 1 -- 919
		end -- 919
	end -- 919
end -- 919
function getSessionRootId(session) -- 924
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 925
end -- 925
function getRootSessionItem(sessionId) -- 928
	local session = getSessionItem(sessionId) -- 929
	if not session then -- 929
		return nil -- 930
	end -- 930
	return getSessionItem(getSessionRootId(session)) or session -- 931
end -- 931
function listRelatedSessions(sessionId) -- 934
	local root = getRootSessionItem(sessionId) -- 935
	if not root then -- 935
		return {} -- 936
	end -- 936
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 937
	return __TS__ArrayMap( -- 946
		rows, -- 946
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 946
	) -- 946
end -- 946
function getSessionSpawnInfo(session) -- 949
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 950
	if not info then -- 950
		return nil -- 951
	end -- 951
	local ____temp_15 = type(info.sessionId) == "number" and info.sessionId or nil -- 953
	local ____temp_16 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 954
	local ____temp_17 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 955
	local ____temp_18 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 956
	local ____temp_19 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 957
	local ____temp_20 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 958
	local ____temp_21 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 959
	local ____temp_22 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 960
		__TS__ArrayFilter( -- 961
			info.filesHint, -- 961
			function(____, item) return type(item) == "string" end -- 961
		), -- 961
		function(____, item) return sanitizeUTF8(item) end -- 961
	) or nil -- 961
	local ____temp_23 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 963
	local ____temp_13 -- 966
	if info.success == true then -- 966
		____temp_13 = true -- 966
	else -- 966
		local ____temp_12 -- 966
		if info.success == false then -- 966
			____temp_12 = false -- 966
		else -- 966
			____temp_12 = nil -- 966
		end -- 966
		____temp_13 = ____temp_12 -- 966
	end -- 966
	local ____temp_14 -- 967
	if info.cleared == true then -- 967
		____temp_14 = true -- 967
	else -- 967
		____temp_14 = nil -- 967
	end -- 967
	return { -- 952
		sessionId = ____temp_15, -- 953
		rootSessionId = ____temp_16, -- 954
		parentSessionId = ____temp_17, -- 955
		title = ____temp_18, -- 956
		prompt = ____temp_19, -- 957
		goal = ____temp_20, -- 958
		expectedOutput = ____temp_21, -- 959
		filesHint = ____temp_22, -- 960
		status = ____temp_23, -- 963
		success = ____temp_13, -- 966
		cleared = ____temp_14, -- 967
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 968
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 969
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 970
		changeSet = decodeChangeSetSummary(info.changeSet), -- 971
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 972
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 973
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 974
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 975
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 978
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 979
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 980
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 981
	} -- 981
end -- 981
function ensureDirRecursive(dir) -- 998
	if dir == "" then -- 998
		return false -- 999
	end -- 999
	if Content:exist(dir) then -- 999
		return Content:isdir(dir) -- 1000
	end -- 1000
	local parent = Path:getPath(dir) -- 1001
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1001
		if not ensureDirRecursive(parent) then -- 1001
			return false -- 1004
		end -- 1004
	end -- 1004
	return Content:mkdir(dir) -- 1007
end -- 1007
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1010
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1011
	if not Content:exist(dir) then -- 1011
		ensureDirRecursive(dir) -- 1013
	end -- 1013
	local path = Path(dir, SPAWN_INFO_FILE) -- 1015
	local text = safeJsonEncode(value) -- 1016
	if not text then -- 1016
		return false -- 1017
	end -- 1017
	local content = text .. "\n" -- 1018
	if not Content:save(path, content) then -- 1018
		return false -- 1020
	end -- 1020
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1022
	return true -- 1023
end -- 1023
function readSpawnInfo(projectRoot, memoryScope) -- 1026
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1027
	if not Content:exist(path) then -- 1027
		return nil -- 1028
	end -- 1028
	local text = Content:load(path) -- 1029
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1029
		return nil -- 1030
	end -- 1030
	local value = safeJsonDecode(text) -- 1031
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1031
		return value -- 1033
	end -- 1033
	return nil -- 1035
end -- 1035
function getArtifactRelativeDir(memoryScope) -- 1038
	return Path(".agent", memoryScope) -- 1039
end -- 1039
function getArtifactDir(projectRoot, memoryScope) -- 1042
	return Path( -- 1043
		projectRoot, -- 1043
		getArtifactRelativeDir(memoryScope) -- 1043
	) -- 1043
end -- 1043
function getResultRelativePath(memoryScope) -- 1046
	return Path( -- 1047
		getArtifactRelativeDir(memoryScope), -- 1047
		RESULT_FILE -- 1047
	) -- 1047
end -- 1047
function getResultPath(projectRoot, memoryScope) -- 1050
	return Path( -- 1051
		projectRoot, -- 1051
		getResultRelativePath(memoryScope) -- 1051
	) -- 1051
end -- 1051
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1054
	if resultFilePath == "" then -- 1054
		return "" -- 1055
	end -- 1055
	local path = Path(projectRoot, resultFilePath) -- 1056
	if not Content:exist(path) then -- 1056
		return "" -- 1057
	end -- 1057
	local text = sanitizeUTF8(Content:load(path)) -- 1058
	if __TS__StringTrim(text) == "" then -- 1058
		return "" -- 1059
	end -- 1059
	local marker = "\n## Summary\n" -- 1060
	local start = string.find(text, marker, 1, true) -- 1061
	if start ~= nil then -- 1061
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1063
	end -- 1063
	return __TS__StringTrim(text) -- 1065
end -- 1065
function buildStructuredSubAgentMemoryEntry(record) -- 1068
	local hasPassedValidation = false -- 1069
	do -- 1069
		local i = 0 -- 1070
		while i < #record.completion.validation do -- 1070
			local result = record.completion.validation[i + 1].result -- 1071
			if result == "failed" then -- 1071
				return nil -- 1076
			end -- 1076
			if result == "passed" then -- 1076
				hasPassedValidation = true -- 1078
			end -- 1078
			i = i + 1 -- 1070
		end -- 1070
	end -- 1070
	if not hasPassedValidation then -- 1070
		return nil -- 1081
	end -- 1081
	local candidates = record.completion.learningCandidates -- 1082
	local claims = {} -- 1083
	local evidence = {} -- 1084
	do -- 1084
		local i = 0 -- 1085
		while i < #candidates do -- 1085
			do -- 1085
				local candidate = candidates[i + 1] -- 1086
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1086
					goto __continue188 -- 1087
				end -- 1087
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1088
				do -- 1088
					local j = 0 -- 1089
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1089
						local item = candidate.evidence[j + 1] -- 1090
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1090
							evidence[#evidence + 1] = item -- 1091
						end -- 1091
						j = j + 1 -- 1089
					end -- 1089
				end -- 1089
			end -- 1089
			::__continue188:: -- 1089
			i = i + 1 -- 1085
		end -- 1085
	end -- 1085
	local content = takeUtf8Head( -- 1094
		table.concat(claims, "\n"), -- 1094
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1094
	) -- 1094
	if content == "" then -- 1094
		return nil -- 1095
	end -- 1095
	return { -- 1096
		sourceSessionId = record.sessionId, -- 1097
		sourceTaskId = record.sourceTaskId, -- 1098
		content = content, -- 1099
		evidence = evidence, -- 1100
		createdAt = record.finishedAt -- 1101
	} -- 1101
end -- 1101
function containsNormalizedText(text, query) -- 1105
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1106
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1107
	if normalizedQuery == "" then -- 1107
		return true -- 1108
	end -- 1108
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1109
end -- 1109
function getSubAgentDisplayKey(item) -- 1112
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1118
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1119
	local label = goal ~= "" and goal or title -- 1120
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1121
end -- 1121
function writeSubAgentResultFile(session, record, resultText) -- 1124
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1125
	if not Content:exist(dir) then -- 1125
		ensureDirRecursive(dir) -- 1127
	end -- 1127
	local ____array_32 = __TS__SparseArrayNew( -- 1127
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1130
		"- Status: " .. record.status, -- 1131
		"- Success: " .. (record.success and "true" or "false"), -- 1132
		"- Outcome: " .. record.completion.outcome, -- 1133
		"- Session ID: " .. tostring(record.sessionId), -- 1134
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1135
		"- Goal: " .. record.goal, -- 1136
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1137
	) -- 1137
	__TS__SparseArrayPush( -- 1137
		____array_32, -- 1137
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1138
	) -- 1138
	__TS__SparseArrayPush( -- 1138
		____array_32, -- 1138
		"- Finished At: " .. record.finishedAt, -- 1139
		"", -- 1140
		"## Validation", -- 1141
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1142
			record.completion.validation, -- 1143
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1143
		) or ({"- Not reported"})) -- 1143
	) -- 1143
	__TS__SparseArrayPush(____array_32, "", "## Recorded Evidence") -- 1143
	local ____opt_24 = record.handoffEvidence -- 1143
	__TS__SparseArrayPush( -- 1143
		____array_32, -- 1143
		table.unpack(____opt_24 and #____opt_24.modifiedFiles and __TS__ArrayMap( -- 1147
			record.handoffEvidence.modifiedFiles, -- 1148
			function(____, item) return "- modified: " .. item end -- 1148
		) or ({"- modified: none recorded"})) -- 1148
	) -- 1148
	local ____opt_26 = record.handoffEvidence -- 1148
	__TS__SparseArrayPush( -- 1148
		____array_32, -- 1148
		table.unpack(____opt_26 and ____opt_26.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1150
	) -- 1150
	local ____opt_28 = record.handoffEvidence -- 1150
	__TS__SparseArrayPush( -- 1150
		____array_32, -- 1150
		table.unpack(__TS__ArrayMap( -- 1153
			____opt_28 and ____opt_28.commands or ({}), -- 1153
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1153
		)) -- 1153
	) -- 1153
	local ____opt_30 = record.handoffEvidence -- 1153
	__TS__SparseArrayPush( -- 1153
		____array_32, -- 1153
		table.unpack(__TS__ArrayMap( -- 1154
			____opt_30 and ____opt_30.authoritativeSources or ({}), -- 1154
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1154
		)) -- 1154
	) -- 1154
	__TS__SparseArrayPush( -- 1154
		____array_32, -- 1154
		"", -- 1155
		"## Known Issues", -- 1156
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1157
			record.completion.knownIssues, -- 1157
			function(____, item) return "- " .. item end -- 1157
		) or ({"- None reported"})) -- 1157
	) -- 1157
	__TS__SparseArrayPush( -- 1157
		____array_32, -- 1157
		"", -- 1158
		"## Assumptions", -- 1159
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1160
			record.completion.assumptions, -- 1160
			function(____, item) return "- " .. item end -- 1160
		) or ({"- None reported"})) -- 1160
	) -- 1160
	__TS__SparseArrayPush(____array_32, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1160
	local lines = {__TS__SparseArraySpread(____array_32)} -- 1129
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1165
	local content = table.concat(lines, "\n") .. "\n" -- 1166
	if not Content:save(path, content) then -- 1166
		return false -- 1168
	end -- 1168
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1170
	return true -- 1171
end -- 1171
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1174
	local dir = Path(projectRoot, ".agent", "subagents") -- 1175
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1175
		return {} -- 1176
	end -- 1176
	local items = {} -- 1177
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1178
		do -- 1178
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1179
			if not Content:exist(path) or not Content:isdir(path) then -- 1179
				goto __continue208 -- 1180
			end -- 1180
			local info = readSpawnInfo( -- 1181
				projectRoot, -- 1181
				Path( -- 1181
					"subagents", -- 1181
					Path:getFilename(path) -- 1181
				) -- 1181
			) -- 1181
			if not info then -- 1181
				goto __continue208 -- 1182
			end -- 1182
			local sessionId = tonumber(info.sessionId) -- 1183
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1184
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1185
			local status = sanitizeUTF8(toStr(info.status)) -- 1186
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1186
				goto __continue208 -- 1187
			end -- 1187
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1187
				goto __continue208 -- 1188
			end -- 1188
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1189
			items[#items + 1] = { -- 1190
				sessionId = sessionId, -- 1191
				rootSessionId = infoRootSessionId, -- 1192
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1193
				title = sanitizeUTF8(toStr(info.title)), -- 1194
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1195
				goal = sanitizeUTF8(toStr(info.goal)), -- 1196
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1197
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1198
					__TS__ArrayFilter( -- 1199
						info.filesHint, -- 1199
						function(____, item) return type(item) == "string" end -- 1199
					), -- 1199
					function(____, item) return sanitizeUTF8(item) end -- 1199
				) or ({}), -- 1199
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1201
				success = info.success == true, -- 1202
				cleared = info.cleared == true, -- 1203
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1204
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1205
					"subagents", -- 1205
					Path:getFilename(path) -- 1205
				)), -- 1205
				sourceTaskId = sourceTaskId or 0, -- 1206
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1207
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1208
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1209
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1210
				completion = normalizeAgentCompletionReport(info.completion), -- 1211
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1212
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1213
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1214
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1215
			} -- 1215
		end -- 1215
		::__continue208:: -- 1215
	end -- 1215
	__TS__ArraySort( -- 1218
		items, -- 1218
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1218
	) -- 1218
	return items -- 1219
end -- 1219
function getPendingHandoffDir(projectRoot, memoryScope) -- 1222
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1223
end -- 1223
function writePendingHandoff(projectRoot, memoryScope, value) -- 1226
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1227
	if not Content:exist(dir) then -- 1227
		ensureDirRecursive(dir) -- 1229
	end -- 1229
	local path = Path(dir, value.id .. ".json") -- 1231
	local text = safeJsonEncode(value) -- 1232
	if not text then -- 1232
		return false -- 1233
	end -- 1233
	local content = text .. "\n" -- 1234
	if not Content:save(path, content) then -- 1234
		return false -- 1235
	end -- 1235
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1236
	return true -- 1237
end -- 1237
function listPendingHandoffs(projectRoot, memoryScope) -- 1240
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1241
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1241
		return {} -- 1242
	end -- 1242
	local items = {} -- 1243
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1244
		do -- 1244
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1245
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1245
				goto __continue224 -- 1246
			end -- 1246
			local text = Content:load(path) -- 1247
			if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1247
				goto __continue224 -- 1248
			end -- 1248
			local obj = safeJsonDecode(text) -- 1249
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1249
				goto __continue224 -- 1250
			end -- 1250
			local value = obj -- 1251
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1252
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1253
			local id = sanitizeUTF8(toStr(value.id)) -- 1254
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1255
			local message = sanitizeUTF8(toStr(value.message)) -- 1256
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1257
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1258
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1259
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1259
				goto __continue224 -- 1261
			end -- 1261
			items[#items + 1] = { -- 1263
				id = id, -- 1264
				sourceSessionId = sourceSessionId, -- 1265
				sourceTitle = sourceTitle, -- 1266
				sourceTaskId = sourceTaskId, -- 1267
				message = message, -- 1268
				prompt = prompt, -- 1269
				goal = goal, -- 1270
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1271
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1272
					__TS__ArrayFilter( -- 1273
						value.filesHint, -- 1273
						function(____, item) return type(item) == "string" end -- 1273
					), -- 1273
					function(____, item) return sanitizeUTF8(item) end -- 1273
				) or ({}), -- 1273
				success = value.success == true, -- 1275
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1276
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1277
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1278
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1279
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1280
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1281
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1282
				createdAt = createdAt -- 1285
			} -- 1285
		end -- 1285
		::__continue224:: -- 1285
	end -- 1285
	__TS__ArraySort( -- 1288
		items, -- 1288
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1288
	) -- 1288
	return items -- 1289
end -- 1289
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1292
	local path = Path( -- 1293
		getPendingHandoffDir(projectRoot, memoryScope), -- 1293
		id .. ".json" -- 1293
	) -- 1293
	if Content:exist(path) then -- 1293
		if Content:remove(path) then -- 1293
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1296
		end -- 1296
	end -- 1296
end -- 1296
function normalizePromptText(prompt) -- 1301
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1302
end -- 1302
function normalizePromptTextSafe(prompt) -- 1305
	if type(prompt) == "string" then -- 1305
		local normalized = normalizePromptText(prompt) -- 1307
		if normalized ~= "" then -- 1307
			return normalized -- 1308
		end -- 1308
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1309
		if sanitized ~= "" then -- 1309
			return truncateAgentUserPrompt(sanitized) -- 1311
		end -- 1311
		return "" -- 1313
	end -- 1313
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1315
	if text == "" then -- 1315
		return "" -- 1316
	end -- 1316
	return truncateAgentUserPrompt(text) -- 1317
end -- 1317
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1320
	local sections = {} -- 1321
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1322
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1323
	local normalizedFiles = __TS__ArrayFilter( -- 1324
		__TS__ArrayMap( -- 1324
			__TS__ArrayFilter( -- 1324
				filesHint or ({}), -- 1324
				function(____, item) return type(item) == "string" end -- 1325
			), -- 1325
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1326
		), -- 1326
		function(____, item) return item ~= "" end -- 1327
	) -- 1327
	if normalizedTitle ~= "" then -- 1327
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1329
	end -- 1329
	if normalizedExpected ~= "" then -- 1329
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1332
	end -- 1332
	if #normalizedFiles > 0 then -- 1332
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1335
	end -- 1335
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1337
end -- 1337
function normalizeSessionRuntimeState(session) -- 1340
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1340
		return session -- 1342
	end -- 1342
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1342
		return session -- 1345
	end -- 1345
	if activeLocalAgentControls[session.currentTaskId] ~= nil then -- 1345
		return session -- 1348
	end -- 1348
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1350
		session.id, -- 1353
		session.currentTaskId, -- 1353
		"fetch_url", -- 1353
		"execute_command", -- 1353
		"analyze_image" -- 1353
	}) or ({}) -- 1353
	if #pendingToolRows > 0 then -- 1353
		local t = now() -- 1356
		do -- 1356
			local i = 0 -- 1357
			while i < #pendingToolRows do -- 1357
				local row = pendingToolRows[i + 1] -- 1358
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1359
				result.success = false -- 1360
				result.state = "failed" -- 1361
				result.interrupted = true -- 1362
				result.message = "tool call was interrupted because the program exited before it completed." -- 1363
				DB:exec( -- 1364
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1364
					{ -- 1366
						encodeJson(result), -- 1366
						t, -- 1366
						row[1] -- 1366
					} -- 1366
				) -- 1366
				i = i + 1 -- 1357
			end -- 1357
		end -- 1357
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1369
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1370
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1371
	end -- 1371
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1378
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1379
	return __TS__ObjectAssign( -- 1380
		{}, -- 1380
		session, -- 1381
		{ -- 1380
			status = "STOPPED", -- 1382
			currentTaskStatus = "STOPPED", -- 1383
			updatedAt = now() -- 1384
		} -- 1384
	) -- 1384
end -- 1384
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1388
	DB:exec( -- 1389
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1389
		{ -- 1393
			status, -- 1394
			currentTaskId or 0, -- 1395
			currentTaskStatus or status, -- 1396
			now(), -- 1397
			sessionId -- 1398
		} -- 1398
	) -- 1398
end -- 1398
function mergeAgentMetrics(current, next) -- 1403
	return __TS__ObjectAssign({}, current or ({}), next) -- 1404
end -- 1404
function updateSessionMetrics(sessionId, metrics) -- 1410
	local session = getSessionItem(sessionId) -- 1411
	if not session then -- 1411
		return nil -- 1412
	end -- 1412
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1413
	DB:exec( -- 1414
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1414
		{ -- 1418
			encodeJson(merged), -- 1419
			now(), -- 1420
			sessionId -- 1421
		} -- 1421
	) -- 1421
	return merged -- 1424
end -- 1424
function clearSessionTokenUsage(sessionId) -- 1427
	local session = getSessionItem(sessionId) -- 1428
	if not session then -- 1428
		return nil -- 1429
	end -- 1429
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1430
	__TS__Delete(metrics, "usage") -- 1431
	__TS__Delete(metrics, "visionUsage") -- 1432
	DB:exec( -- 1433
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1433
		{ -- 1437
			encodeJson(metrics), -- 1438
			now(), -- 1439
			sessionId -- 1440
		} -- 1440
	) -- 1440
	return metrics -- 1443
end -- 1443
function getInitialTokenUsage(session) -- 1446
	local ____opt_33 = session.metrics -- 1446
	local usage = ____opt_33 and ____opt_33.usage -- 1447
	if not usage or (usage.requestCount or 0) <= 0 then -- 1447
		return nil -- 1448
	end -- 1448
	return { -- 1449
		inputTokens = usage.inputTokens or 0, -- 1450
		outputTokens = usage.outputTokens or 0, -- 1451
		totalTokens = usage.totalTokens, -- 1452
		cachedInputTokens = usage.cachedInputTokens, -- 1453
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1454
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1455
		requestCount = usage.requestCount or 0, -- 1456
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1457
		model = usage.model or "", -- 1458
		phase = usage.phase or "", -- 1459
		step = usage.step or 0, -- 1460
		updatedAt = usage.updatedAt or now() -- 1461
	} -- 1461
end -- 1461
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1465
	if taskId == nil or taskId <= 0 then -- 1465
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1467
		return -- 1468
	end -- 1468
	local row = getSessionRow(sessionId) -- 1470
	if not row then -- 1470
		return -- 1471
	end -- 1471
	local session = rowToSession(row) -- 1472
	if session.currentTaskId ~= taskId then -- 1472
		Log( -- 1474
			"Info", -- 1474
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1474
		) -- 1474
		return -- 1475
	end -- 1475
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1477
end -- 1477
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1480
	local t = now() -- 1481
	DB:exec( -- 1482
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1482
		{ -- 1485
			sessionId, -- 1486
			taskId or 0, -- 1487
			role, -- 1488
			sanitizeUTF8(content), -- 1489
			displayContent and sanitizeUTF8(displayContent) or "", -- 1490
			t, -- 1491
			t -- 1492
		} -- 1492
	) -- 1492
	return getLastInsertRowId() -- 1495
end -- 1495
function updateMessage(messageId, content) -- 1498
	DB:exec( -- 1499
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1499
		{ -- 1501
			sanitizeUTF8(content), -- 1501
			now(), -- 1501
			messageId -- 1501
		} -- 1501
	) -- 1501
end -- 1501
function updateUserMessageForTask(messageId, content, taskId) -- 1505
	DB:exec( -- 1506
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1506
		{ -- 1510
			sanitizeUTF8(content), -- 1510
			taskId, -- 1510
			now(), -- 1510
			messageId -- 1510
		} -- 1510
	) -- 1510
end -- 1510
function removeContinuableTaskSummary(session) -- 1567
	local taskId = session.currentTaskId -- 1568
	if taskId == nil then -- 1568
		return -- 1569
	end -- 1569
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1570
end -- 1570
function upsertAssistantMessage(sessionId, taskId, content) -- 1582
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1583
	if row and type(row[1]) == "number" then -- 1583
		updateMessage(row[1], content) -- 1590
		return row[1] -- 1591
	end -- 1591
	return insertMessage(sessionId, "assistant", content, taskId) -- 1593
end -- 1593
function upsertStep(sessionId, taskId, step, tool, patch) -- 1596
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1606
	local reason = sanitizeUTF8(patch.reason or "") -- 1610
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1611
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1612
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1613
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1614
	local statusPatch = patch.status or "" -- 1615
	local status = patch.status or "PENDING" -- 1616
	if not row then -- 1616
		local t = now() -- 1618
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1619
			sessionId, -- 1623
			taskId, -- 1624
			step, -- 1625
			tool, -- 1626
			status, -- 1627
			reason, -- 1628
			reasoningContent, -- 1629
			paramsJson, -- 1630
			resultJson, -- 1631
			patch.checkpointId or 0, -- 1632
			patch.checkpointSeq or 0, -- 1633
			filesJson, -- 1634
			t, -- 1635
			t -- 1636
		}) -- 1636
		return -- 1639
	end -- 1639
	DB:exec( -- 1641
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1641
		{ -- 1653
			tool, -- 1654
			statusPatch, -- 1655
			status, -- 1656
			reason, -- 1657
			reason, -- 1658
			reasoningContent, -- 1659
			reasoningContent, -- 1660
			paramsJson, -- 1661
			paramsJson, -- 1662
			resultJson, -- 1663
			resultJson, -- 1664
			patch.checkpointId or 0, -- 1665
			patch.checkpointId or 0, -- 1666
			patch.checkpointSeq or 0, -- 1667
			patch.checkpointSeq or 0, -- 1668
			filesJson, -- 1669
			filesJson, -- 1670
			now(), -- 1671
			row[1] -- 1672
		} -- 1672
	) -- 1672
end -- 1672
function getNextStepNumber(sessionId, taskId) -- 1677
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1678
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1682
	return math.max(0, current) + 1 -- 1683
end -- 1683
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1724
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1732
	local t = now() -- 1733
	local sqls = { -- 1734
		{ -- 1735
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1735
			{{ -- 1738
				sessionId, -- 1739
				ownerTaskId, -- 1740
				step, -- 1741
				"sub_agent_handoff", -- 1742
				"DONE", -- 1743
				sanitizeUTF8(reason), -- 1744
				encodeJson(params), -- 1745
				encodeJson(result), -- 1746
				t, -- 1747
				t -- 1748
			}} -- 1748
		}, -- 1748
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1751
	} -- 1751
	if not DB:transaction(sqls) then -- 1751
		return nil -- 1757
	end -- 1757
	return getStepItem(sessionId, ownerTaskId, step) -- 1758
end -- 1758
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1761
	if taskId <= 0 then -- 1761
		return -- 1762
	end -- 1762
	if finalSteps ~= nil and finalSteps >= 0 then -- 1762
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1764
	end -- 1764
	if not finalStatus then -- 1764
		return -- 1770
	end -- 1770
	if finalSteps ~= nil and finalSteps >= 0 then -- 1770
		DB:exec( -- 1772
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1772
			{ -- 1776
				finalStatus, -- 1776
				now(), -- 1776
				sessionId, -- 1776
				taskId, -- 1776
				finalSteps -- 1776
			} -- 1776
		) -- 1776
		return -- 1778
	end -- 1778
	DB:exec( -- 1780
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1780
		{ -- 1784
			finalStatus, -- 1784
			now(), -- 1784
			sessionId, -- 1784
			taskId -- 1784
		} -- 1784
	) -- 1784
end -- 1784
function emitAgentSessionPatch(sessionId, patch) -- 1811
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1812
	if not text then -- 1812
		return -- 1817
	end -- 1817
	local failed = publishSessionPatch(sessionId, text) -- 1818
	if failed > 0 then -- 1818
		Log( -- 1819
			"Warn", -- 1819
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 1819
		) -- 1819
	end -- 1819
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 1819
		emit("AppWS", "Send", text) -- 1820
	end -- 1820
end -- 1820
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1823
	emitAgentSessionPatch( -- 1824
		sessionId, -- 1824
		{ -- 1824
			sessionDeleted = true, -- 1825
			relatedSessions = listRelatedSessions(rootSessionId) -- 1826
		} -- 1826
	) -- 1826
	local rootSession = getSessionItem(rootSessionId) -- 1828
	if rootSession then -- 1828
		emitAgentSessionPatch( -- 1830
			rootSessionId, -- 1830
			{ -- 1830
				session = rootSession, -- 1831
				relatedSessions = listRelatedSessions(rootSessionId) -- 1832
			} -- 1832
		) -- 1832
	end -- 1832
end -- 1832
function flushPendingSubAgentHandoffs(rootSession) -- 1837
	if rootSession.kind ~= "main" then -- 1837
		return -- 1838
	end -- 1838
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1838
		return -- 1840
	end -- 1840
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1842
	if #items == 0 then -- 1842
		return -- 1843
	end -- 1843
	local handoffTaskId = 0 -- 1844
	local previousTaskId = rootSession.currentTaskId -- 1845
	local ____rootSession_currentTaskId_37 -- 1846
	if rootSession.currentTaskId then -- 1846
		____rootSession_currentTaskId_37 = getTaskPrompt(rootSession.currentTaskId) -- 1846
	else -- 1846
		____rootSession_currentTaskId_37 = nil -- 1846
	end -- 1846
	local currentTaskPrompt = ____rootSession_currentTaskId_37 -- 1846
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1846
		handoffTaskId = rootSession.currentTaskId -- 1854
	else -- 1854
		local taskRes = Tools.createTask( -- 1856
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1856
			"code" -- 1856
		) -- 1856
		if not taskRes.success then -- 1856
			Log( -- 1858
				"Warn", -- 1858
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1858
			) -- 1858
			return -- 1859
		end -- 1859
		handoffTaskId = taskRes.taskId -- 1861
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1862
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1863
		emitAgentSessionPatch( -- 1864
			rootSession.id, -- 1864
			{session = getSessionItem(rootSession.id)} -- 1864
		) -- 1864
	end -- 1864
	do -- 1864
		local i = 0 -- 1868
		while i < #items do -- 1868
			local item = items[i + 1] -- 1869
			local step = appendHandoffSystemStep( -- 1870
				rootSession.id, -- 1871
				handoffTaskId, -- 1872
				item.sourceTaskId, -- 1873
				item.message, -- 1874
				{ -- 1875
					sourceSessionId = item.sourceSessionId, -- 1876
					sourceTitle = item.sourceTitle, -- 1877
					sourceTaskId = item.sourceTaskId, -- 1878
					success = item.success == true, -- 1879
					summary = item.message, -- 1880
					resultFilePath = item.resultFilePath or "", -- 1881
					artifactDir = item.artifactDir or "", -- 1882
					finishedAt = item.finishedAt or "", -- 1883
					changeSet = item.changeSet, -- 1884
					handoffEvidence = item.handoffEvidence, -- 1885
					memoryEntry = item.memoryEntry, -- 1886
					completion = item.completion -- 1887
				}, -- 1887
				{ -- 1889
					sourceSessionId = item.sourceSessionId, -- 1890
					sourceTitle = item.sourceTitle, -- 1891
					sourceTaskId = item.sourceTaskId, -- 1892
					prompt = item.prompt, -- 1893
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1894
					expectedOutput = item.expectedOutput or "", -- 1895
					filesHint = item.filesHint or ({}), -- 1896
					resultFilePath = item.resultFilePath or "", -- 1897
					artifactDir = item.artifactDir or "", -- 1898
					changeSet = item.changeSet, -- 1899
					handoffEvidence = item.handoffEvidence, -- 1900
					memoryEntry = item.memoryEntry, -- 1901
					completion = item.completion -- 1902
				} -- 1902
			) -- 1902
			if step then -- 1902
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1906
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1907
			else -- 1907
				Log( -- 1909
					"Warn", -- 1909
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1909
				) -- 1909
			end -- 1909
			i = i + 1 -- 1868
		end -- 1868
	end -- 1868
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1868
		cleanupTaskHeavyData(previousTaskId) -- 1913
	end -- 1913
end -- 1913
function applyEvent(sessionId, event) -- 1925
	if not getSessionItem(sessionId) then -- 1925
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1925
			__TS__Delete(activeStopTokens, event.taskId) -- 1928
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1929
		end -- 1929
		return -- 1931
	end -- 1931
	repeat -- 1931
		local ____switch319 = event.type -- 1931
		local metrics, startedSession -- 1931
		local ____cond319 = ____switch319 == "task_started" -- 1931
		if ____cond319 then -- 1931
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1935
			local ____event_resumed_40 -- 1936
			if event.resumed then -- 1936
				local ____opt_38 = getSessionItem(sessionId) -- 1936
				____event_resumed_40 = ____opt_38 and ____opt_38.metrics -- 1937
			else -- 1937
				____event_resumed_40 = clearSessionTokenUsage(sessionId) -- 1938
			end -- 1938
			metrics = ____event_resumed_40 -- 1936
			startedSession = getSessionItem(sessionId) -- 1939
			emitAgentSessionPatch( -- 1940
				sessionId, -- 1940
				{ -- 1940
					session = startedSession, -- 1941
					metrics = metrics, -- 1942
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1943
				} -- 1943
			) -- 1943
			break -- 1947
		end -- 1947
		____cond319 = ____cond319 or ____switch319 == "decision_made" -- 1947
		if ____cond319 then -- 1947
			upsertStep( -- 1949
				sessionId, -- 1949
				event.taskId, -- 1949
				event.step, -- 1949
				event.tool, -- 1949
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1949
			) -- 1949
			emitAgentSessionPatch( -- 1957
				sessionId, -- 1957
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1957
			) -- 1957
			break -- 1960
		end -- 1960
		____cond319 = ____cond319 or ____switch319 == "tool_started" -- 1960
		if ____cond319 then -- 1960
			upsertStep( -- 1962
				sessionId, -- 1962
				event.taskId, -- 1962
				event.step, -- 1962
				event.tool, -- 1962
				{status = "RUNNING"} -- 1962
			) -- 1962
			emitAgentSessionPatch( -- 1965
				sessionId, -- 1965
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1965
			) -- 1965
			break -- 1968
		end -- 1968
		____cond319 = ____cond319 or ____switch319 == "tool_finished" -- 1968
		if ____cond319 then -- 1968
			do -- 1968
				local ____temp_43 = event.result.success ~= true -- 1970
				if ____temp_43 then -- 1970
					local ____opt_41 = activeStopTokens[event.taskId] -- 1970
					____temp_43 = (____opt_41 and ____opt_41.stopped) == true -- 1970
				end -- 1970
				local stopped = ____temp_43 -- 1970
				upsertStep( -- 1972
					sessionId, -- 1972
					event.taskId, -- 1972
					event.step, -- 1972
					event.tool, -- 1972
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1972
				) -- 1972
				emitAgentSessionPatch( -- 1980
					sessionId, -- 1980
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1980
				) -- 1980
				break -- 1983
			end -- 1983
		end -- 1983
		____cond319 = ____cond319 or ____switch319 == "tool_progress" -- 1983
		if ____cond319 then -- 1983
			do -- 1983
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1987
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1987
					break -- 1989
				end -- 1989
			end -- 1989
			upsertStep( -- 1992
				sessionId, -- 1992
				event.taskId, -- 1992
				event.step, -- 1992
				event.tool, -- 1992
				{status = "RUNNING", result = event.result} -- 1992
			) -- 1992
			emitAgentSessionPatch( -- 1996
				sessionId, -- 1996
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1996
			) -- 1996
			break -- 1999
		end -- 1999
		____cond319 = ____cond319 or ____switch319 == "checkpoint_created" -- 1999
		if ____cond319 then -- 1999
			upsertStep( -- 2001
				sessionId, -- 2001
				event.taskId, -- 2001
				event.step, -- 2001
				event.tool, -- 2001
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2001
			) -- 2001
			emitAgentSessionPatch( -- 2006
				sessionId, -- 2006
				{ -- 2006
					step = getStepItem(sessionId, event.taskId, event.step), -- 2007
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2008
				} -- 2008
			) -- 2008
			break -- 2010
		end -- 2010
		____cond319 = ____cond319 or ____switch319 == "memory_compression_started" -- 2010
		if ____cond319 then -- 2010
			upsertStep( -- 2012
				sessionId, -- 2012
				event.taskId, -- 2012
				event.step, -- 2012
				event.tool, -- 2012
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2012
			) -- 2012
			emitAgentSessionPatch( -- 2017
				sessionId, -- 2017
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2017
			) -- 2017
			break -- 2020
		end -- 2020
		____cond319 = ____cond319 or ____switch319 == "memory_compression_finished" -- 2020
		if ____cond319 then -- 2020
			upsertStep( -- 2022
				sessionId, -- 2022
				event.taskId, -- 2022
				event.step, -- 2022
				event.tool, -- 2022
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2022
			) -- 2022
			emitAgentSessionPatch( -- 2027
				sessionId, -- 2027
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2027
			) -- 2027
			break -- 2030
		end -- 2030
		____cond319 = ____cond319 or ____switch319 == "metrics_updated" -- 2030
		if ____cond319 then -- 2030
			do -- 2030
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2032
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2033
				break -- 2036
			end -- 2036
		end -- 2036
		____cond319 = ____cond319 or ____switch319 == "assistant_message_updated" -- 2036
		if ____cond319 then -- 2036
			do -- 2036
				upsertStep( -- 2039
					sessionId, -- 2039
					event.taskId, -- 2039
					event.step, -- 2039
					"message", -- 2039
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2039
				) -- 2039
				emitAgentSessionPatch( -- 2044
					sessionId, -- 2044
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2044
				) -- 2044
				break -- 2047
			end -- 2047
		end -- 2047
		____cond319 = ____cond319 or ____switch319 == "assistant_message_finished" -- 2047
		if ____cond319 then -- 2047
			do -- 2047
				upsertStep( -- 2050
					sessionId, -- 2050
					event.taskId, -- 2050
					event.step, -- 2050
					"message", -- 2050
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2050
				) -- 2050
				emitAgentSessionPatch( -- 2056
					sessionId, -- 2056
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2056
				) -- 2056
				break -- 2059
			end -- 2059
		end -- 2059
		____cond319 = ____cond319 or ____switch319 == "task_waiting_for_user" -- 2059
		if ____cond319 then -- 2059
			do -- 2059
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2062
				__TS__Delete(activeStopTokens, event.taskId) -- 2063
				emitAgentSessionPatch( -- 2064
					sessionId, -- 2064
					{ -- 2064
						session = getSessionItem(sessionId), -- 2065
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2066
					} -- 2066
				) -- 2066
				break -- 2068
			end -- 2068
		end -- 2068
		____cond319 = ____cond319 or ____switch319 == "task_finished" -- 2068
		if ____cond319 then -- 2068
			do -- 2068
				local session = getSessionItem(sessionId) -- 2071
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2071
					__TS__Delete(activeStopTokens, event.taskId) -- 2073
					Log( -- 2074
						"Info", -- 2074
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2074
					) -- 2074
					break -- 2075
				end -- 2075
				local ____opt_44 = activeStopTokens[event.taskId or -1] -- 2075
				local stopped = (____opt_44 and ____opt_44.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2077
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2079
				local isSubSession = (session and session.kind) == "sub" -- 2082
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2083
				if isSubSession and event.taskId ~= nil then -- 2083
					finalizingSubSessionTaskIds[event.taskId] = true -- 2085
				end -- 2085
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2087
				if event.taskId ~= nil then -- 2087
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2089
					local ____finalizeTaskSteps_50 = finalizeTaskSteps -- 2090
					local ____array_49 = __TS__SparseArrayNew( -- 2090
						sessionId, -- 2091
						event.taskId, -- 2092
						type(event.steps) == "number" and math.max( -- 2093
							0, -- 2093
							math.floor(event.steps) -- 2093
						) or nil -- 2093
					) -- 2093
					local ____event_success_48 -- 2094
					if event.success then -- 2094
						____event_success_48 = nil -- 2094
					else -- 2094
						____event_success_48 = stopped and "STOPPED" or "FAILED" -- 2094
					end -- 2094
					__TS__SparseArrayPush(____array_49, ____event_success_48) -- 2094
					____finalizeTaskSteps_50(__TS__SparseArraySpread(____array_49)) -- 2090
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2096
					if not isSubSession then -- 2096
						__TS__Delete(activeStopTokens, event.taskId) -- 2098
					end -- 2098
					emitAgentSessionPatch( -- 2100
						sessionId, -- 2100
						{ -- 2100
							session = getSessionItem(sessionId), -- 2101
							message = getMessageItem(messageId), -- 2102
							removedStepIds = removedStepIds -- 2103
						} -- 2103
					) -- 2103
				end -- 2103
				if session and session.kind == "main" then -- 2103
					flushPendingSubAgentHandoffs(session) -- 2107
				end -- 2107
				break -- 2109
			end -- 2109
		end -- 2109
	until true -- 2109
end -- 2109
function ____exports.createSession(projectRoot, title) -- 2114
	if title == nil then -- 2114
		title = "" -- 2114
	end -- 2114
	local storage = requireAgentStorage() -- 2115
	if not storage.success then -- 2115
		return storage -- 2116
	end -- 2116
	if not isValidProjectRoot(projectRoot) then -- 2116
		return {success = false, message = "invalid projectRoot"} -- 2118
	end -- 2118
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2120
	if row then -- 2120
		return { -- 2129
			success = true, -- 2129
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2129
		} -- 2129
	end -- 2129
	local t = now() -- 2131
	DB:exec( -- 2132
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2132
		{ -- 2135
			projectRoot, -- 2135
			title ~= "" and title or Path:getFilename(projectRoot), -- 2135
			t, -- 2135
			t -- 2135
		} -- 2135
	) -- 2135
	local sessionId = getLastInsertRowId() -- 2137
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2138
	local session = getSessionItem(sessionId) -- 2139
	if not session then -- 2139
		return {success = false, message = "failed to create session"} -- 2141
	end -- 2141
	return {success = true, session = session} -- 2143
end -- 2114
function ____exports.createSubSession(parentSessionId, title) -- 2146
	if title == nil then -- 2146
		title = "" -- 2146
	end -- 2146
	local storage = requireAgentStorage() -- 2147
	if not storage.success then -- 2147
		return storage -- 2148
	end -- 2148
	local parent = getSessionItem(parentSessionId) -- 2149
	if not parent then -- 2149
		return {success = false, message = "parent session not found"} -- 2151
	end -- 2151
	local rootId = getSessionRootId(parent) -- 2153
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2153
		return {success = false, message = "project task admission is closed"} -- 2154
	end -- 2154
	local t = now() -- 2155
	DB:exec( -- 2156
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2156
		{ -- 2159
			parent.projectRoot, -- 2159
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2159
			rootId, -- 2159
			parent.id, -- 2159
			t, -- 2159
			t -- 2159
		} -- 2159
	) -- 2159
	local sessionId = getLastInsertRowId() -- 2161
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2162
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2163
	local session = getSessionItem(sessionId) -- 2164
	if not session then -- 2164
		return {success = false, message = "failed to create sub session"} -- 2166
	end -- 2166
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2168
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2169
	subStorage:writeMemory(parentStorage:readMemory()) -- 2170
	return {success = true, session = session} -- 2171
end -- 2146
function spawnSubAgentSession(request) -- 2174
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2174
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2187
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2188
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2189
		if normalizedPrompt == "" then -- 2189
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2191
		end -- 2191
		if normalizedPrompt == "" then -- 2191
			local ____Log_56 = Log -- 2198
			local ____temp_53 = #normalizedTitle -- 2198
			local ____temp_54 = #rawPrompt -- 2198
			local ____temp_55 = #toStr(request.expectedOutput) -- 2198
			local ____opt_51 = request.filesHint -- 2198
			____Log_56( -- 2198
				"Warn", -- 2198
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_53)) .. " raw_prompt_len=") .. tostring(____temp_54)) .. " expected_len=") .. tostring(____temp_55)) .. " files_hint_count=") .. tostring(____opt_51 and #____opt_51 or 0) -- 2198
			) -- 2198
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2198
		end -- 2198
		Log( -- 2201
			"Info", -- 2201
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2201
		) -- 2201
		local parentSessionId = request.parentSessionId -- 2202
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2202
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2204
			if not fallbackParent then -- 2204
				local createdMain = ____exports.createSession(request.projectRoot) -- 2206
				if createdMain.success then -- 2206
					fallbackParent = createdMain.session -- 2208
				end -- 2208
			end -- 2208
			if fallbackParent then -- 2208
				Log( -- 2212
					"Warn", -- 2212
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2212
				) -- 2212
				parentSessionId = fallbackParent.id -- 2213
			end -- 2213
		end -- 2213
		local parentSession = getSessionItem(parentSessionId) -- 2216
		if not parentSession then -- 2216
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2216
		end -- 2216
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2220
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2220
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2220
		end -- 2220
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2220
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2220
		end -- 2220
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2225
		if not created.success then -- 2225
			return ____awaiter_resolve(nil, created) -- 2225
		end -- 2225
		writeSpawnInfo( -- 2229
			created.session.projectRoot, -- 2229
			created.session.memoryScope, -- 2229
			{ -- 2229
				sessionId = created.session.id, -- 2230
				rootSessionId = created.session.rootSessionId, -- 2231
				parentSessionId = created.session.parentSessionId, -- 2232
				title = created.session.title, -- 2233
				prompt = normalizedPrompt, -- 2234
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2235
				expectedOutput = request.expectedOutput or "", -- 2236
				filesHint = request.filesHint or ({}), -- 2237
				status = "RUNNING", -- 2238
				success = false, -- 2239
				resultFilePath = "", -- 2240
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2241
				sourceTaskId = 0, -- 2242
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2243
				createdAtTs = created.session.createdAt, -- 2244
				finishedAt = "", -- 2245
				finishedAtTs = 0 -- 2246
			} -- 2246
		) -- 2246
		local sent = ____exports.sendPrompt( -- 2248
			created.session.id, -- 2248
			normalizedPrompt, -- 2248
			request.disabledAgentTools, -- 2248
			nil, -- 2248
			nil, -- 2248
			request.llmConfig -- 2248
		) -- 2248
		if not sent.success then -- 2248
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2248
		end -- 2248
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2248
	end) -- 2248
end -- 2248
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2369
	local rootSession = getRootSessionItem(session.id) -- 2370
	if not rootSession then -- 2370
		return -- 2371
	end -- 2371
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2372
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2373
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2374
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2375
	local queueResult = writePendingHandoff( -- 2376
		rootSession.projectRoot, -- 2376
		rootSession.memoryScope, -- 2376
		{ -- 2376
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2377
			sourceSessionId = session.id, -- 2378
			sourceTitle = session.title, -- 2379
			sourceTaskId = taskId, -- 2380
			message = summary, -- 2381
			prompt = result.prompt, -- 2382
			goal = result.goal, -- 2383
			expectedOutput = result.expectedOutput or "", -- 2384
			filesHint = result.filesHint or ({}), -- 2385
			success = result.success, -- 2386
			resultFilePath = result.resultFilePath, -- 2387
			artifactDir = result.artifactDir, -- 2388
			finishedAt = result.finishedAt, -- 2389
			changeSet = changeSet, -- 2390
			handoffEvidence = result.handoffEvidence, -- 2391
			memoryEntry = result.memoryEntry, -- 2392
			completion = result.completion, -- 2393
			createdAt = createdAt -- 2394
		} -- 2394
	) -- 2394
	if not queueResult then -- 2394
		Log( -- 2397
			"Warn", -- 2397
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2397
		) -- 2397
		return -- 2398
	end -- 2398
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2398
		addTaskReference(rootSession.currentTaskId, taskId) -- 2401
	end -- 2401
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2401
		flushPendingSubAgentHandoffs(rootSession) -- 2404
	end -- 2404
end -- 2404
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2408
	if forceHandoff == nil then -- 2408
		forceHandoff = false -- 2414
	end -- 2414
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2414
		local rootSessionId = getSessionRootId(session) -- 2416
		local rootSession = getRootSessionItem(session.id) -- 2417
		if not rootSession then -- 2417
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2417
		end -- 2417
		local spawnInfo = getSessionSpawnInfo(session) -- 2421
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2422
		local finishedAtTs = now() -- 2423
		local resultText = sanitizeUTF8(message) -- 2424
		local changeSet = getTaskChangeSetSummary(taskId) -- 2425
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2426
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2427
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2431
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2431
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2433
		end -- 2433
		local completed = success and completionReport.outcome == "completed" -- 2441
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2442
		local record = { -- 2445
			sessionId = session.id, -- 2446
			rootSessionId = rootSessionId, -- 2447
			parentSessionId = session.parentSessionId, -- 2448
			title = session.title, -- 2449
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2450
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2451
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2452
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2453
			status = recordStatus, -- 2454
			success = completed, -- 2455
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2456
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2457
			sourceTaskId = taskId, -- 2458
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2459
			finishedAt = finishedAt, -- 2460
			createdAtTs = session.createdAt, -- 2461
			finishedAtTs = finishedAtTs, -- 2462
			changeSet = changeSet, -- 2463
			handoffEvidence = handoffEvidence, -- 2464
			completion = completionReport -- 2465
		} -- 2465
		local ____record_success_73 -- 2467
		if record.success then -- 2467
			____record_success_73 = buildStructuredSubAgentMemoryEntry(record) -- 2467
		else -- 2467
			____record_success_73 = nil -- 2467
		end -- 2467
		record.memoryEntry = ____record_success_73 -- 2467
		if not writeSubAgentResultFile(session, record, resultText) then -- 2467
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2467
		end -- 2467
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2467
			sessionId = record.sessionId, -- 2472
			rootSessionId = record.rootSessionId, -- 2473
			parentSessionId = record.parentSessionId, -- 2474
			title = record.title, -- 2475
			prompt = record.prompt, -- 2476
			goal = record.goal, -- 2477
			expectedOutput = record.expectedOutput or "", -- 2478
			filesHint = record.filesHint or ({}), -- 2479
			status = record.status, -- 2480
			success = record.success, -- 2481
			resultFilePath = record.resultFilePath, -- 2482
			artifactDir = record.artifactDir, -- 2483
			sourceTaskId = record.sourceTaskId, -- 2484
			createdAt = record.createdAt, -- 2485
			finishedAt = record.finishedAt, -- 2486
			createdAtTs = record.createdAtTs, -- 2487
			finishedAtTs = record.finishedAtTs, -- 2488
			changeSet = record.changeSet, -- 2489
			handoffEvidence = record.handoffEvidence, -- 2490
			memoryEntry = record.memoryEntry, -- 2491
			memoryEntryError = record.memoryEntryError, -- 2492
			completion = record.completion -- 2493
		}) then -- 2493
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2493
		end -- 2493
		if success or forceHandoff then -- 2493
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2498
			deleteSessionRecords(session.id, true) -- 2499
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2500
		end -- 2500
		return ____awaiter_resolve(nil, {success = true}) -- 2500
	end) -- 2500
end -- 2500
function stopClearedSubSession(session, taskId) -- 2505
	local spawnInfo = getSessionSpawnInfo(session) -- 2506
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2507
	local rootSessionId = getSessionRootId(session) -- 2508
	Tools.setTaskStatus(taskId, "STOPPED") -- 2509
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2510
	if not writeSpawnInfo( -- 2510
		session.projectRoot, -- 2511
		session.memoryScope, -- 2511
		{ -- 2511
			sessionId = session.id, -- 2512
			rootSessionId = rootSessionId, -- 2513
			parentSessionId = session.parentSessionId, -- 2514
			title = session.title, -- 2515
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2516
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2517
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2518
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2519
			status = "STOPPED", -- 2520
			success = false, -- 2521
			cleared = true, -- 2522
			resultFilePath = "", -- 2523
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2524
			sourceTaskId = taskId, -- 2525
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2526
			finishedAt = finishedAt, -- 2527
			createdAtTs = session.createdAt, -- 2528
			finishedAtTs = now() -- 2529
		} -- 2529
	) then -- 2529
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2531
	end -- 2531
	deleteSessionRecords(session.id, true) -- 2533
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2534
	return {success = true} -- 2535
end -- 2535
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps) -- 2538
	local session = getSessionItem(sessionId) -- 2539
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2539
		return {success = false, message = "project task admission is closed"} -- 2540
	end -- 2540
	if not session then -- 2540
		return {success = false, message = "session not found"} -- 2542
	end -- 2542
	if getPendingQuestionnaire(sessionId) then -- 2542
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2544
	end -- 2544
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2544
		return {success = false, message = "session task is finalizing"} -- 2546
	end -- 2546
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2546
		return {success = false, message = "session task is still running"} -- 2549
	end -- 2549
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2551
	if normalizedPrompt == "" and session.kind == "sub" then -- 2551
		local spawnInfo = getSessionSpawnInfo(session) -- 2553
		if spawnInfo then -- 2553
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2555
			if normalizedPrompt == "" then -- 2555
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2557
			end -- 2557
		end -- 2557
	end -- 2557
	if normalizedPrompt == "" then -- 2557
		return {success = false, message = "prompt is empty"} -- 2566
	end -- 2566
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2568
	if session.workMode ~= nextWorkMode then -- 2568
		DB:exec( -- 2570
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2570
			{ -- 2570
				nextWorkMode, -- 2570
				now(), -- 2570
				session.id -- 2570
			} -- 2570
		) -- 2570
		session.workMode = nextWorkMode -- 2571
	end -- 2571
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2573
	return startPromptTask( -- 2574
		session, -- 2574
		normalizedPrompt, -- 2574
		nil, -- 2574
		normalizeDisabledAgentTools(disabledAgentTools), -- 2574
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig, maxSteps = boundedMaxSteps} -- 2574
	) -- 2574
end -- 2538
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2708
	if disabledAgentTools == nil then -- 2708
		disabledAgentTools = {} -- 2712
	end -- 2712
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2715
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2715
		return {success = false, message = "project task admission is closed"} -- 2716
	end -- 2716
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2717
	if not llmConfigRes.success then -- 2717
		return {success = false, message = llmConfigRes.message} -- 2721
	end -- 2721
	local llmConfig = llmConfigRes.config -- 2723
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2724
	if not llmConfigValidation.success then -- 2724
		return llmConfigValidation -- 2726
	end -- 2726
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2728
	if not taskRes.success then -- 2728
		return {success = false, message = taskRes.message} -- 2731
	end -- 2731
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2731
		removeContinuableTaskSummary(session) -- 2733
	end -- 2733
	local taskId = taskRes.taskId -- 2735
	local ____temp_94 -- 2736
	if (options and options.existingTaskId) == nil then -- 2736
		____temp_94 = session.currentTaskId -- 2736
	else -- 2736
		____temp_94 = nil -- 2736
	end -- 2736
	local previousTaskId = ____temp_94 -- 2736
	local useChineseResponse = getDefaultUseChineseResponse() -- 2737
	local promptMessageId -- 2738
	if existingUserMessageId ~= nil then -- 2738
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2740
		promptMessageId = existingUserMessageId -- 2741
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2741
		promptMessageId = insertMessage( -- 2743
			session.id, -- 2743
			"user", -- 2743
			normalizedPrompt, -- 2743
			taskId, -- 2743
			options and options.displayContent -- 2743
		) -- 2743
	end -- 2743
	local stopToken = {stopped = false} -- 2745
	activeStopTokens[taskId] = stopToken -- 2746
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2747
	emitAgentSessionPatch( -- 2751
		session.id, -- 2751
		__TS__ObjectAssign( -- 2751
			{session = getSessionItem(session.id)}, -- 2751
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 2753
		) -- 2753
	) -- 2753
	if previousTaskId and previousTaskId ~= taskId then -- 2753
		cleanupTaskHeavyData(previousTaskId) -- 2756
	end -- 2756
	local ____runCodingAgent_123 = runCodingAgent -- 2758
	local ____normalizedPrompt_116 = normalizedPrompt -- 2759
	local ____temp_117 = options and options.resumeConversation -- 2760
	local ____temp_118 = (options and options.existingTaskId) ~= nil -- 2761
	local ____temp_119 = options and options.initialStep -- 2762
	local ____temp_120 = options and options.initialAgentStepCount -- 2763
	local ____temp_111 -- 2764
	if (options and options.existingTaskId) ~= nil then -- 2764
		____temp_111 = getInitialTokenUsage(session) -- 2764
	else -- 2764
		____temp_111 = nil -- 2764
	end -- 2764
	____runCodingAgent_123( -- 2758
		{ -- 2758
			prompt = ____normalizedPrompt_116, -- 2759
			resumeConversation = ____temp_117, -- 2760
			resumeTask = ____temp_118, -- 2761
			initialStep = ____temp_119, -- 2762
			initialAgentStepCount = ____temp_120, -- 2763
			initialTokenUsage = ____temp_111, -- 2764
			workDir = session.projectRoot, -- 2765
			useChineseResponse = useChineseResponse, -- 2766
			taskId = taskId, -- 2767
			sessionId = session.id, -- 2768
			memoryScope = session.memoryScope, -- 2769
			role = session.kind, -- 2770
			maxSteps = options and options.maxSteps, -- 2771
			disabledAgentTools = disabledAgentTools, -- 2772
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2773
			llmConfig = llmConfig, -- 2774
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2775
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2778
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2781
			stopToken = stopToken, -- 2782
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2783
		}, -- 2783
		function(result) -- 2784
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2784
				local nextSession = getSessionItem(session.id) -- 2785
				if nextSession and nextSession.kind == "sub" then -- 2785
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2785
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2788
						if not stopped.success then -- 2788
							Log( -- 2790
								"Warn", -- 2790
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2790
							) -- 2790
							emitAgentSessionPatch( -- 2791
								session.id, -- 2791
								{session = getSessionItem(session.id)} -- 2791
							) -- 2791
						end -- 2791
						__TS__Delete(activeStopTokens, taskId) -- 2795
						return ____awaiter_resolve(nil) -- 2795
					end -- 2795
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2798
					emitAgentSessionPatch( -- 2799
						session.id, -- 2799
						{session = getSessionItem(session.id)} -- 2799
					) -- 2799
					local finalized = __TS__Await(finalizeSubSession( -- 2802
						nextSession, -- 2803
						taskId, -- 2804
						result.success, -- 2805
						result.message, -- 2806
						result.completion, -- 2807
						(options and options.forceSubAgentHandoff) == true -- 2808
					)) -- 2808
					if not finalized.success then -- 2808
						Log( -- 2811
							"Warn", -- 2811
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2811
						) -- 2811
					end -- 2811
					local finalizedSession = getSessionItem(session.id) -- 2813
					if finalizedSession then -- 2813
						local stopped = stopToken.stopped == true -- 2815
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2816
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2819
						emitAgentSessionPatch( -- 2820
							session.id, -- 2820
							{session = getSessionItem(session.id)} -- 2820
						) -- 2820
					end -- 2820
					__TS__Delete(activeStopTokens, taskId) -- 2824
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2825
				end -- 2825
				local fallbackSession = getSessionItem(session.id) -- 2827
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2827
					applyEvent(session.id, { -- 2833
						type = "task_finished", -- 2834
						sessionId = session.id, -- 2835
						taskId = result.taskId, -- 2836
						success = false, -- 2837
						message = result.message, -- 2838
						steps = result.steps -- 2839
					}) -- 2839
				end -- 2839
			end) -- 2839
		end -- 2784
	) -- 2784
	return {success = true, sessionId = session.id, taskId = taskId} -- 2843
end -- 2843
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2996
	local lines = {} -- 2997
	do -- 2997
		local i = 0 -- 2998
		while i < #questionnaire.schema.questions do -- 2998
			local question = questionnaire.schema.questions[i + 1] -- 2999
			local answer = __TS__ArrayFind( -- 3000
				answers, -- 3000
				function(____, item) return item.questionId == question.id end -- 3000
			) -- 3000
			local answerText = "已跳过" -- 3001
			if answer and answer.status == "answered" then -- 3001
				local parts = {} -- 3003
				do -- 3003
					local j = 0 -- 3004
					while j < #(answer.selectedOptionIds or ({})) do -- 3004
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3005
						local option = __TS__ArrayFind( -- 3006
							question.options or ({}), -- 3006
							function(____, item) return item.id == optionId end -- 3006
						) -- 3006
						if option then -- 3006
							parts[#parts + 1] = option.label -- 3007
						end -- 3007
						j = j + 1 -- 3004
					end -- 3004
				end -- 3004
				if answer.otherText then -- 3004
					parts[#parts + 1] = answer.otherText -- 3009
				end -- 3009
				if answer.text then -- 3009
					parts[#parts + 1] = answer.text -- 3010
				end -- 3010
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3011
			end -- 3011
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3013
			i = i + 1 -- 2998
		end -- 2998
	end -- 2998
	return table.concat(lines, "\n\n") -- 3015
end -- 3015
function ____exports.listRunningSubAgents(request) -- 3299
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3299
		local session = getSessionItem(request.sessionId) -- 3307
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3307
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3309
		end -- 3309
		if not session then -- 3309
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3309
		end -- 3309
		local rootSession = getRootSessionItem(session.id) -- 3314
		if not rootSession then -- 3314
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3314
		end -- 3314
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3318
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3319
		local limit = math.max( -- 3320
			1, -- 3320
			math.floor(tonumber(request.limit) or 5) -- 3320
		) -- 3320
		local offset = math.max( -- 3321
			0, -- 3321
			math.floor(tonumber(request.offset) or 0) -- 3321
		) -- 3321
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3322
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3323
		local runningSessions = {} -- 3330
		do -- 3330
			local i = 0 -- 3331
			while i < #rows do -- 3331
				do -- 3331
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3332
					if current.currentTaskStatus ~= "RUNNING" then -- 3332
						goto __continue559 -- 3334
					end -- 3334
					local spawnInfo = getSessionSpawnInfo(current) -- 3336
					runningSessions[#runningSessions + 1] = { -- 3337
						sessionId = current.id, -- 3338
						title = current.title, -- 3339
						parentSessionId = current.parentSessionId, -- 3340
						rootSessionId = current.rootSessionId, -- 3341
						status = "RUNNING", -- 3342
						currentTaskId = current.currentTaskId, -- 3343
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3344
						goal = spawnInfo and spawnInfo.goal, -- 3345
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3346
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3347
						createdAt = current.createdAt, -- 3348
						updatedAt = current.updatedAt -- 3349
					} -- 3349
				end -- 3349
				::__continue559:: -- 3349
				i = i + 1 -- 3331
			end -- 3331
		end -- 3331
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3352
		local completedSessions = __TS__ArrayMap( -- 3353
			completedRecords, -- 3353
			function(____, record) return { -- 3353
				sessionId = record.sessionId, -- 3354
				title = record.title, -- 3355
				parentSessionId = record.parentSessionId, -- 3356
				rootSessionId = record.rootSessionId, -- 3357
				status = record.status, -- 3358
				goal = record.goal, -- 3359
				expectedOutput = record.expectedOutput, -- 3360
				filesHint = record.filesHint, -- 3361
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3362
				success = record.success, -- 3363
				cleared = record.cleared, -- 3364
				resultFilePath = record.resultFilePath, -- 3365
				artifactDir = record.artifactDir, -- 3366
				finishedAt = record.finishedAt, -- 3367
				createdAt = record.createdAtTs, -- 3368
				updatedAt = record.finishedAtTs -- 3369
			} end -- 3369
		) -- 3369
		local merged = {} -- 3371
		if status == "running" then -- 3371
			merged = runningSessions -- 3373
		elseif status == "done" then -- 3373
			merged = __TS__ArrayFilter( -- 3375
				completedSessions, -- 3375
				function(____, item) return item.status == "DONE" end -- 3375
			) -- 3375
		elseif status == "failed" then -- 3375
			merged = __TS__ArrayFilter( -- 3377
				completedSessions, -- 3377
				function(____, item) return item.status == "FAILED" end -- 3377
			) -- 3377
		elseif status == "stopped" then -- 3377
			merged = __TS__ArrayFilter( -- 3379
				completedSessions, -- 3379
				function(____, item) return item.status == "STOPPED" end -- 3379
			) -- 3379
		elseif status == "all" then -- 3379
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3381
		else -- 3381
			local runningKeys = {} -- 3383
			do -- 3383
				local i = 0 -- 3384
				while i < #runningSessions do -- 3384
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3385
					i = i + 1 -- 3384
				end -- 3384
			end -- 3384
			local latestCompletedByKey = {} -- 3387
			do -- 3387
				local i = 0 -- 3388
				while i < #completedSessions do -- 3388
					do -- 3388
						local item = completedSessions[i + 1] -- 3389
						local key = getSubAgentDisplayKey(item) -- 3390
						if runningKeys[key] then -- 3390
							goto __continue574 -- 3392
						end -- 3392
						local current = latestCompletedByKey[key] -- 3394
						if current == nil or item.updatedAt > current.updatedAt then -- 3394
							latestCompletedByKey[key] = item -- 3396
						end -- 3396
					end -- 3396
					::__continue574:: -- 3396
					i = i + 1 -- 3388
				end -- 3388
			end -- 3388
			local latestCompleted = {} -- 3399
			for ____, item in pairs(latestCompletedByKey) do -- 3400
				latestCompleted[#latestCompleted + 1] = item -- 3401
			end -- 3401
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3403
		end -- 3403
		if query ~= "" then -- 3403
			merged = __TS__ArrayFilter( -- 3406
				merged, -- 3406
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3406
			) -- 3406
		end -- 3406
		__TS__ArraySort( -- 3412
			merged, -- 3412
			function(____, a, b) -- 3412
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3412
					return -1 -- 3413
				end -- 3413
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3413
					return 1 -- 3414
				end -- 3414
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3414
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3416
				end -- 3416
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3418
			end -- 3412
		) -- 3412
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3420
		return ____awaiter_resolve(nil, { -- 3420
			success = true, -- 3422
			rootSessionId = rootSession.id, -- 3423
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3424
			status = status, -- 3425
			limit = limit, -- 3426
			offset = offset, -- 3427
			hasMore = offset + limit < #merged, -- 3428
			sessions = paged -- 3429
		}) -- 3429
	end) -- 3429
end -- 3299
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 276
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 277
SPAWN_INFO_FILE = "SPAWN.json" -- 278
RESULT_FILE = "RESULT.md" -- 279
PENDING_HANDOFF_DIR = "pending-handoffs" -- 280
MAX_CONCURRENT_SUB_AGENTS = 4 -- 281
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 282
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 283
activeStopTokens = {} -- 333
activeLocalAgentControls = {} -- 334
finalizingSubSessionTaskIds = {} -- 335
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 336
now = function() return os.time() end -- 337
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 985
	if projectRoot == oldRoot then -- 985
		return newRoot -- 987
	end -- 987
	for ____, separator in ipairs({"/", "\\"}) do -- 989
		local prefix = oldRoot .. separator -- 990
		if __TS__StringStartsWith(projectRoot, prefix) then -- 990
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 992
		end -- 992
	end -- 992
	return nil -- 995
end -- 985
local function clearSessionAfterMessage(sessionId, message) -- 1514
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1515
	local removedStepIds = {} -- 1523
	do -- 1523
		local i = 0 -- 1524
		while i < #removedStepRows do -- 1524
			local row = removedStepRows[i + 1] -- 1525
			if type(row[1]) == "number" then -- 1525
				removedStepIds[#removedStepIds + 1] = row[1] -- 1527
			end -- 1527
			i = i + 1 -- 1524
		end -- 1524
	end -- 1524
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1530
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1538
	return removedStepIds -- 1543
end -- 1514
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1546
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1547
	local persisted = storage:readSessionState() -- 1548
	local userIndex = -1 -- 1549
	do -- 1549
		local i = #persisted.messages - 1 -- 1550
		while i >= 0 do -- 1550
			if persisted.messages[i + 1].role == "user" then -- 1550
				userIndex = i -- 1552
				break -- 1553
			end -- 1553
			i = i - 1 -- 1550
		end -- 1550
	end -- 1550
	if userIndex < 0 then -- 1550
		return -- 1556
	end -- 1556
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1557
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1558
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1559
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1564
end -- 1546
local function listCurrentTaskCheckpoints(sessionId) -- 1576
	local session = getSessionItem(sessionId) -- 1577
	local taskId = session and session.currentTaskId -- 1578
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1579
end -- 1576
local function getAgentStepCount(sessionId, taskId) -- 1686
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1687
		sessionId, -- 1692
		taskId, -- 1693
		"compress_memory", -- 1694
		"merge_memory", -- 1695
		"sub_agent_handoff", -- 1696
		"questionnaire_answer", -- 1697
		"message" -- 1698
	}) -- 1698
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1701
end -- 1686
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1704
	if status == nil then -- 1704
		status = "DONE" -- 1712
	end -- 1712
	local step = getNextStepNumber(sessionId, taskId) -- 1714
	upsertStep( -- 1715
		sessionId, -- 1715
		taskId, -- 1715
		step, -- 1715
		tool, -- 1715
		{status = status, reason = reason, params = params, result = result} -- 1715
	) -- 1715
	return getStepItem(sessionId, taskId, step) -- 1721
end -- 1704
local function sanitizeStoredSteps(sessionId) -- 1788
	DB:exec( -- 1789
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1789
		{ -- 1807
			now(), -- 1807
			sessionId -- 1807
		} -- 1807
	) -- 1807
end -- 1788
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2260
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2260
		return {success = false, message = "invalid projectRoot"} -- 2262
	end -- 2262
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2264
	for ____, row in ipairs(rows) do -- 2265
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2266
		if sessionId > 0 then -- 2266
			deleteSessionRecords(sessionId) -- 2268
		end -- 2268
	end -- 2268
	return {success = true, deleted = #rows} -- 2271
end -- 2260
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2274
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2274
		return {success = false, message = "invalid projectRoot"} -- 2276
	end -- 2276
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2278
	local renamed = 0 -- 2279
	for ____, row in ipairs(rows) do -- 2280
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2281
		local projectRoot = toStr(row[2]) -- 2282
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2283
		if sessionId > 0 and nextProjectRoot then -- 2283
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2285
			DB:exec( -- 2286
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2286
				{ -- 2288
					nextProjectRoot, -- 2288
					Path:getFilename(nextProjectRoot), -- 2288
					now(), -- 2288
					sessionId -- 2288
				} -- 2288
			) -- 2288
			renamed = renamed + 1 -- 2290
		end -- 2290
	end -- 2290
	return {success = true, renamed = renamed} -- 2293
end -- 2274
function ____exports.getSession(sessionId, view) -- 2296
	local session = getSessionItem(sessionId) -- 2297
	if not session then -- 2297
		return {success = false, message = "session not found"} -- 2299
	end -- 2299
	local restored = restorePendingQuestionnaireState(session) -- 2301
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2302
	local relatedSessions = listRelatedSessions(sessionId) -- 2303
	sanitizeStoredSteps(sessionId) -- 2304
	local firstMessageId = 0 -- 2305
	local hasEarlierMessages = false -- 2306
	if view then -- 2306
		local limit = math.max( -- 2308
			1, -- 2308
			math.min( -- 2308
				1000, -- 2308
				math.floor(view.recentRounds) -- 2308
			) -- 2308
		) -- 2308
		local requests = queryRows(("SELECT id FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND role = 'user'\n\t\t\tORDER BY id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2309
		if #requests > limit then -- 2309
			firstMessageId = requests[limit][1] -- 2314
			hasEarlierMessages = true -- 2315
		end -- 2315
	end -- 2315
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2318
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2325
	local ____relatedSessions_62 = relatedSessions -- 2337
	local ____temp_61 -- 2338
	if normalizedSession.kind == "sub" then -- 2338
		____temp_61 = getSessionSpawnInfo(normalizedSession) -- 2338
	else -- 2338
		____temp_61 = nil -- 2338
	end -- 2338
	return { -- 2334
		success = true, -- 2335
		session = normalizedSession, -- 2336
		relatedSessions = ____relatedSessions_62, -- 2337
		spawnInfo = ____temp_61, -- 2338
		messages = __TS__ArrayMap( -- 2339
			messages, -- 2339
			function(____, row) return rowToMessage(row) end -- 2339
		), -- 2339
		hasEarlierMessages = hasEarlierMessages, -- 2340
		steps = __TS__ArrayMap( -- 2341
			steps, -- 2341
			function(____, row) return rowToStep(row) end -- 2341
		), -- 2341
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2342
		pendingQuestionnaire = restored.questionnaire, -- 2343
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2344
	} -- 2344
end -- 2296
function ____exports.setWorkMode(sessionId, workMode) -- 2349
	local session = getSessionItem(sessionId) -- 2350
	if not session then -- 2350
		return {success = false, message = "session not found"} -- 2351
	end -- 2351
	if session.kind ~= "main" then -- 2351
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2352
	end -- 2352
	if workMode ~= "code" and workMode ~= "plan" then -- 2352
		return {success = false, message = "invalid work mode"} -- 2353
	end -- 2353
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2354
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2354
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2356
	end -- 2356
	if getPendingQuestionnaire(sessionId) then -- 2356
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2359
	end -- 2359
	if normalizedSession.workMode ~= workMode then -- 2359
		DB:exec( -- 2362
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2362
			{ -- 2362
				workMode, -- 2362
				now(), -- 2362
				sessionId -- 2362
			} -- 2362
		) -- 2362
	end -- 2362
	local updated = getSessionItem(sessionId) -- 2364
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2365
	return { -- 2366
		success = true, -- 2366
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2366
	} -- 2366
end -- 2349
function ____exports.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 2577
	local session = getSessionItem(sessionId) -- 2578
	if not session then -- 2578
		return {success = false, message = "session not found"} -- 2579
	end -- 2579
	if session.kind ~= "main" then -- 2579
		return {success = false, message = "local Agent only supports main sessions"} -- 2580
	end -- 2580
	if getPendingQuestionnaire(sessionId) then -- 2580
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2581
	end -- 2581
	if session.currentTaskStatus == "RUNNING" then -- 2581
		return {success = false, message = "session task is still running"} -- 2582
	end -- 2582
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2583
	if normalizedPrompt == "" then -- 2583
		return {success = false, message = "prompt is empty"} -- 2584
	end -- 2584
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2585
	if not config then -- 2585
		return {success = false, message = "local Agent config not found"} -- 2586
	end -- 2586
	if not config.verifiedAt then -- 2586
		return {success = false, message = "local Agent config is not verified"} -- 2587
	end -- 2587
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2588
	if not taskRes.success then -- 2588
		return taskRes -- 2589
	end -- 2589
	local taskId = taskRes.taskId -- 2590
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2591
	Tools.setTaskStatus(taskId, "RUNNING") -- 2592
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2593
	upsertStep( -- 2594
		session.id, -- 2594
		taskId, -- 2594
		1, -- 2594
		"local_agent_message", -- 2594
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2594
	) -- 2594
	emitAgentSessionPatch( -- 2600
		session.id, -- 2600
		{ -- 2600
			session = getSessionItem(session.id), -- 2601
			message = getMessageItem(messageId), -- 2602
			step = getStepItem(session.id, taskId, 1) -- 2603
		} -- 2603
	) -- 2603
	local events = {} -- 2605
	local transcript = "" -- 2606
	local assistant = "" -- 2607
	local lastFlush = 0 -- 2608
	local function flush(force) -- 2609
		if force == nil then -- 2609
			force = false -- 2609
		end -- 2609
		if not force and App.runningTime - lastFlush < 0.075 then -- 2609
			return -- 2610
		end -- 2610
		lastFlush = App.runningTime -- 2611
		if #events > 400 then -- 2611
			events = __TS__ArraySlice(events, #events - 400) -- 2612
		end -- 2612
		if #transcript > 1024 * 1024 then -- 2612
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2613
		end -- 2613
		upsertStep( -- 2614
			session.id, -- 2614
			taskId, -- 2614
			1, -- 2614
			"local_agent_message", -- 2614
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2614
		) -- 2614
		local message -- 2619
		if assistant ~= "" then -- 2619
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2621
			message = getMessageItem(assistantId) -- 2622
		end -- 2622
		emitAgentSessionPatch( -- 2624
			session.id, -- 2624
			__TS__ObjectAssign( -- 2624
				{step = getStepItem(session.id, taskId, 1)}, -- 2624
				message and ({message = message}) or ({}) -- 2624
			) -- 2624
		) -- 2624
	end -- 2609
	local completedSynchronously = false -- 2626
	local control = LocalAgent.run( -- 2627
		session.id, -- 2627
		config, -- 2627
		session.projectRoot, -- 2627
		normalizedPrompt, -- 2627
		function(event) -- 2627
			local text = sanitizeUTF8(event.text) -- 2628
			if text == "" then -- 2628
				return -- 2629
			end -- 2629
			local previous = #events > 0 and events[#events] or nil -- 2630
			if previous and previous.kind == event.kind and previous.text == text then -- 2630
				return -- 2631
			end -- 2631
			events[#events + 1] = {kind = event.kind, text = text} -- 2632
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2633
			if event.kind == "assistant" then -- 2633
				assistant = text -- 2634
			end -- 2634
			flush(false) -- 2635
		end, -- 2627
		function(result) -- 2636
			completedSynchronously = true -- 2637
			flush(true) -- 2638
			__TS__Delete(activeLocalAgentControls, taskId) -- 2639
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2640
			Tools.setTaskStatus(taskId, status) -- 2641
			setSessionState(session.id, status, taskId, status) -- 2642
			upsertStep( -- 2643
				session.id, -- 2643
				taskId, -- 2643
				1, -- 2643
				"local_agent_message", -- 2643
				{status = status, reason = config.name .. " · full permissions", result = { -- 2643
					provider = config.provider, -- 2646
					events = events, -- 2646
					transcript = transcript, -- 2646
					exitCode = result.exitCode, -- 2646
					resumeId = result.resumeId, -- 2646
					message = result.message -- 2646
				}} -- 2646
			) -- 2646
			emitAgentSessionPatch( -- 2648
				session.id, -- 2648
				{ -- 2648
					session = getSessionItem(session.id), -- 2648
					step = getStepItem(session.id, taskId, 1) -- 2648
				} -- 2648
			) -- 2648
		end -- 2636
	) -- 2636
	if not completedSynchronously then -- 2636
		activeLocalAgentControls[taskId] = control -- 2650
	end -- 2650
	return {success = true, sessionId = session.id, taskId = taskId} -- 2651
end -- 2577
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2654
	local session = getSessionItem(sessionId) -- 2655
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2655
		return {success = false, message = "project task admission is closed"} -- 2656
	end -- 2656
	if not session then -- 2656
		return {success = false, message = "session not found"} -- 2658
	end -- 2658
	if getPendingQuestionnaire(sessionId) then -- 2658
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2660
	end -- 2660
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2660
		return {success = false, message = "session task is finalizing"} -- 2662
	end -- 2662
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2662
		return {success = false, message = "session task is still stopping"} -- 2665
	end -- 2665
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2665
		return {success = false, message = "session task is not continuable"} -- 2668
	end -- 2668
	if session.currentTaskId == nil then -- 2668
		return {success = false, message = "session task not found"} -- 2671
	end -- 2671
	local taskId = session.currentTaskId -- 2673
	return startPromptTask( -- 2674
		session, -- 2675
		"", -- 2676
		nil, -- 2677
		normalizeDisabledAgentTools(disabledAgentTools), -- 2678
		{ -- 2679
			workMode = session.workMode, -- 2680
			persistUserMessage = false, -- 2681
			resumeConversation = true, -- 2682
			existingTaskId = taskId, -- 2683
			initialStep = math.max( -- 2684
				0, -- 2684
				getNextStepNumber(session.id, taskId) - 1 -- 2684
			), -- 2684
			initialAgentStepCount = 0, -- 2688
			llmConfigId = llmConfigId -- 2689
		} -- 2689
	) -- 2689
end -- 2654
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2846
	local session = getSessionItem(sessionId) -- 2847
	if not session then -- 2847
		return {success = false, message = "session not found"} -- 2849
	end -- 2849
	if session.kind ~= "sub" then -- 2849
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2852
	end -- 2852
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2852
		return {success = false, message = "session task is finalizing"} -- 2855
	end -- 2855
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2857
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2857
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2862
	end -- 2862
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2862
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2865
	end -- 2865
	local disabledAgentTools = __TS__ArrayFilter( -- 2867
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2867
		function(____, tool) return tool ~= "finish" end -- 2868
	) -- 2868
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2869
	return startPromptTask( -- 2872
		session, -- 2872
		prompt, -- 2872
		nil, -- 2872
		disabledAgentTools, -- 2872
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2872
	) -- 2872
end -- 2846
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2879
	local session = getSessionItem(sessionId) -- 2880
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2880
		return {success = false, message = "project task admission is closed"} -- 2881
	end -- 2881
	if not session then -- 2881
		return {success = false, message = "session not found"} -- 2883
	end -- 2883
	if getPendingQuestionnaire(sessionId) then -- 2883
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2885
	end -- 2885
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2885
		return {success = false, message = "session task is finalizing"} -- 2887
	end -- 2887
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2887
		return {success = false, message = "session task is still running"} -- 2890
	end -- 2890
	local message = getMessageItem(messageId) -- 2892
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2892
		return {success = false, message = "message not found"} -- 2894
	end -- 2894
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2896
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2902
	if latestUserMessageId ~= messageId then -- 2902
		return {success = false, message = "only the latest user prompt can be edited"} -- 2904
	end -- 2904
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2906
	if normalizedPrompt == "" then -- 2906
		return {success = false, message = "prompt is empty"} -- 2908
	end -- 2908
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2910
	if session.workMode ~= nextWorkMode then -- 2910
		DB:exec( -- 2912
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2912
			{ -- 2912
				nextWorkMode, -- 2912
				now(), -- 2912
				session.id -- 2912
			} -- 2912
		) -- 2912
		session.workMode = nextWorkMode -- 2913
	end -- 2913
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2915
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2916
	local result = startPromptTask( -- 2917
		session, -- 2917
		normalizedPrompt, -- 2917
		messageId, -- 2917
		normalizeDisabledAgentTools(disabledAgentTools), -- 2917
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2917
	) -- 2917
	if result.success and #removedStepIds > 0 then -- 2917
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2919
	end -- 2919
	return result -- 2921
end -- 2879
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2926
	if status == "dismissed" then -- 2926
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2932
	end -- 2932
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2934
end -- 2926
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2937
	if status == "dismissed" then -- 2937
		return { -- 2943
			success = true, -- 2944
			status = "dismissed", -- 2945
			source = "user", -- 2946
			questionnaireId = questionnaire.id, -- 2947
			title = questionnaire.schema.title, -- 2948
			answers = {}, -- 2949
			responses = {}, -- 2950
			displayText = "用户关闭了调查问卷，未作答。", -- 2951
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2952
		} -- 2952
	end -- 2952
	local responses = {} -- 2955
	do -- 2955
		local i = 0 -- 2956
		while i < #questionnaire.schema.questions do -- 2956
			do -- 2956
				local question = questionnaire.schema.questions[i + 1] -- 2957
				local answer = __TS__ArrayFind( -- 2958
					answers, -- 2958
					function(____, item) return item.questionId == question.id end -- 2958
				) -- 2958
				if not answer or answer.status == "skipped" then -- 2958
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2960
					goto __continue471 -- 2965
				end -- 2965
				local selectedOptionLabels = {} -- 2967
				do -- 2967
					local j = 0 -- 2968
					while j < #(answer.selectedOptionIds or ({})) do -- 2968
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2969
						local option = __TS__ArrayFind( -- 2970
							question.options or ({}), -- 2970
							function(____, item) return item.id == optionId end -- 2970
						) -- 2970
						if option then -- 2970
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2971
						end -- 2971
						j = j + 1 -- 2968
					end -- 2968
				end -- 2968
				responses[#responses + 1] = { -- 2973
					questionId = question.id, -- 2974
					prompt = question.prompt, -- 2975
					status = "answered", -- 2976
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2977
					selectedOptionLabels = selectedOptionLabels, -- 2978
					otherText = answer.otherText, -- 2979
					text = answer.text -- 2980
				} -- 2980
			end -- 2980
			::__continue471:: -- 2980
			i = i + 1 -- 2956
		end -- 2956
	end -- 2956
	return { -- 2983
		success = true, -- 2984
		status = "answered", -- 2985
		source = "user", -- 2986
		questionnaireId = questionnaire.id, -- 2987
		title = questionnaire.schema.title, -- 2988
		answers = answers, -- 2989
		responses = responses, -- 2990
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2991
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2992
	} -- 2992
end -- 2937
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3018
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3024
	local persisted = storage:readSessionState() -- 3025
	local messages = __TS__ArraySlice(persisted.messages) -- 3026
	local toolResultIndex = -1 -- 3027
	local existingResult -- 3028
	do -- 3028
		local i = #messages - 1 -- 3029
		while i >= 0 do -- 3029
			do -- 3029
				local message = messages[i + 1] -- 3030
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3030
					goto __continue491 -- 3031
				end -- 3031
				local decoded = safeJsonDecode(message.content) -- 3032
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3032
					goto __continue491 -- 3033
				end -- 3033
				local row = decoded -- 3034
				if row.questionnaireId ~= questionnaire.id then -- 3034
					goto __continue491 -- 3035
				end -- 3035
				toolResultIndex = i -- 3036
				existingResult = row -- 3037
				break -- 3038
			end -- 3038
			::__continue491:: -- 3038
			i = i - 1 -- 3029
		end -- 3029
	end -- 3029
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3040
	local guidance = {} -- 3041
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3041
		guidance[#guidance + 1] = existingResult.guidance -- 3043
	end -- 3043
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3043
		guidance[#guidance + 1] = result.guidance -- 3046
	end -- 3046
	result.guidance = table.concat(guidance, "\n") -- 3048
	if toolResultIndex < 0 then -- 3048
		messages[#messages + 1] = { -- 3050
			role = "user", -- 3051
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3052
		} -- 3052
		toolResultIndex = #messages - 1 -- 3054
	else -- 3054
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3056
			{}, -- 3056
			messages[toolResultIndex + 1], -- 3057
			{content = encodeJson(result)} -- 3056
		) -- 3056
	end -- 3056
	local pairStartIndex = toolResultIndex -- 3062
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3063
	if toolCallId and toolCallId ~= "" then -- 3063
		do -- 3063
			local i = toolResultIndex - 1 -- 3065
			while i >= 0 do -- 3065
				do -- 3065
					local message = messages[i + 1] -- 3066
					if message.role ~= "assistant" or not message.tool_calls then -- 3066
						goto __continue501 -- 3067
					end -- 3067
					if __TS__ArraySome( -- 3067
						message.tool_calls, -- 3068
						function(____, call) return call.id == toolCallId end -- 3068
					) then -- 3068
						pairStartIndex = i -- 3069
						break -- 3070
					end -- 3070
				end -- 3070
				::__continue501:: -- 3070
				i = i - 1 -- 3065
			end -- 3065
		end -- 3065
	end -- 3065
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3074
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3077
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3081
	upsertStep( -- 3083
		session.id, -- 3083
		questionnaire.taskId, -- 3083
		questionnaire.step, -- 3083
		"ask_user", -- 3083
		{status = "DONE", result = result} -- 3083
	) -- 3083
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3087
	upsertStep( -- 3088
		session.id, -- 3088
		questionnaire.taskId, -- 3088
		answerStep, -- 3088
		"questionnaire_answer", -- 3088
		{status = "DONE", result = result} -- 3088
	) -- 3088
	return {success = true, answerStep = answerStep, result = result} -- 3092
end -- 3018
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3095
	local session = getSessionItem(sessionId) -- 3096
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3096
		return {success = false, message = "project task admission is closed"} -- 3097
	end -- 3097
	if not session then -- 3097
		return {success = false, message = "session not found"} -- 3098
	end -- 3098
	if session.kind ~= "main" then -- 3098
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3099
	end -- 3099
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3100
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3100
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3102
	end -- 3102
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3104
	if not llmConfigRes.success then -- 3104
		return {success = false, message = llmConfigRes.message} -- 3105
	end -- 3105
	if not removePendingQuestionnaire(session) then -- 3105
		return {success = false, message = "failed to consume questionnaire file"} -- 3106
	end -- 3106
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3107
	if not replaced.success then -- 3107
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3109
		return replaced -- 3110
	end -- 3110
	local t = now() -- 3112
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3113
	session.workMode = "plan" -- 3114
	local result = startPromptTask( -- 3115
		session, -- 3115
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3115
		nil, -- 3115
		{}, -- 3115
		{ -- 3115
			workMode = "plan", -- 3116
			persistUserMessage = false, -- 3117
			resumeConversation = true, -- 3118
			existingTaskId = questionnaire.taskId, -- 3119
			initialStep = replaced.answerStep, -- 3120
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3121
			llmConfig = llmConfigRes.config -- 3122
		} -- 3122
	) -- 3122
	if not result.success then -- 3122
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3125
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3126
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3127
		emitAgentSessionPatch( -- 3128
			session.id, -- 3128
			{ -- 3128
				session = getSessionItem(session.id), -- 3129
				pendingQuestionnaire = questionnaire -- 3130
			} -- 3130
		) -- 3130
		return result -- 3132
	end -- 3132
	emitAgentSessionPatch( -- 3134
		sessionId, -- 3134
		{ -- 3134
			session = getSessionItem(sessionId), -- 3135
			pendingQuestionnaire = false -- 3136
		} -- 3136
	) -- 3136
	return result -- 3138
end -- 3095
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3141
	local session = getSessionItem(sessionId) -- 3142
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3142
		return {success = false, message = "project task admission is closed"} -- 3143
	end -- 3143
	if not session then -- 3143
		return {success = false, message = "session not found"} -- 3144
	end -- 3144
	if session.kind ~= "main" then -- 3144
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3145
	end -- 3145
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3146
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3146
		return {success = false, message = "pending questionnaire not found"} -- 3147
	end -- 3147
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3148
	if not validated.success then -- 3148
		return validated -- 3149
	end -- 3149
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3150
	if not llmConfigRes.success then -- 3150
		return {success = false, message = llmConfigRes.message} -- 3151
	end -- 3151
	local t = now() -- 3152
	if not removePendingQuestionnaire(session) then -- 3152
		return {success = false, message = "failed to consume questionnaire file"} -- 3153
	end -- 3153
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3154
	if not replaced.success then -- 3154
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3156
		return replaced -- 3157
	end -- 3157
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3159
	session.workMode = "plan" -- 3160
	local result = startPromptTask( -- 3161
		session, -- 3161
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3161
		nil, -- 3161
		{}, -- 3161
		{ -- 3161
			workMode = "plan", -- 3162
			persistUserMessage = false, -- 3163
			resumeConversation = true, -- 3164
			existingTaskId = questionnaire.taskId, -- 3165
			initialStep = replaced.answerStep, -- 3166
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3167
			llmConfig = llmConfigRes.config -- 3168
		} -- 3168
	) -- 3168
	if not result.success then -- 3168
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3171
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3172
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3173
		emitAgentSessionPatch( -- 3174
			session.id, -- 3174
			{ -- 3174
				session = getSessionItem(session.id), -- 3175
				pendingQuestionnaire = questionnaire -- 3176
			} -- 3176
		) -- 3176
		return result -- 3178
	end -- 3178
	emitAgentSessionPatch( -- 3180
		sessionId, -- 3180
		{ -- 3180
			session = getSessionItem(sessionId), -- 3181
			pendingQuestionnaire = false -- 3182
		} -- 3182
	) -- 3182
	return result -- 3184
end -- 3141
function ____exports.stopSessionTask(sessionId) -- 3187
	local session = getSessionItem(sessionId) -- 3188
	if not session or session.currentTaskId == nil then -- 3188
		return {success = false, message = "session task not found"} -- 3190
	end -- 3190
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3190
		return {success = false, message = "session task is finalizing"} -- 3193
	end -- 3193
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3195
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3196
	if localControl ~= nil then -- 3196
		localControl:stop() -- 3198
		return {success = true, stopping = true} -- 3199
	end -- 3199
	local stopToken = activeStopTokens[session.currentTaskId] -- 3201
	if stopToken == nil then -- 3201
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3201
			return {success = true, recovered = true} -- 3204
		end -- 3204
		return {success = false, message = "task is not running"} -- 3206
	end -- 3206
	if stopToken.stopped then -- 3206
		return {success = true, stopping = true} -- 3209
	end -- 3209
	stopToken.stopped = true -- 3211
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3212
	return {success = true, stopping = true} -- 3216
end -- 3187
function ____exports.getCurrentTaskId(sessionId) -- 3219
	local ____opt_126 = getSessionItem(sessionId) -- 3219
	return ____opt_126 and ____opt_126.currentTaskId -- 3220
end -- 3219
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3224
	local owner = getSessionItem(sessionId) -- 3225
	if not owner then -- 3225
		return {success = false, message = "session not found"} -- 3226
	end -- 3226
	local projectRoot = owner.projectRoot -- 3227
	local release = holdProjectTaskAdmission(projectRoot) -- 3228
	local closed = false -- 3229
	return { -- 3230
		success = true, -- 3231
		projectRoot = projectRoot, -- 3232
		close = function() -- 3233
			if not closed then -- 3233
				closed = true -- 3233
				release() -- 3233
			end -- 3233
		end, -- 3233
		poll = function() -- 3234
			if closed then -- 3234
				return {success = false, message = "quiescence handle closed"} -- 3235
			end -- 3235
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3236
			if not rows then -- 3236
				return {success = false, message = "failed to inspect project tasks"} -- 3237
			end -- 3237
			local pending = {} -- 3238
			for ____, row in ipairs(rows) do -- 3239
				do -- 3239
					local session = rowToSession(row) -- 3240
					local taskId = session.currentTaskId -- 3241
					if taskId == nil then -- 3241
						goto __continue539 -- 3242
					end -- 3242
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3243
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3243
						goto __continue539 -- 3244
					end -- 3244
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3246
					local ____session_id_129 = session.id -- 3247
					local ____taskId_130 = taskId -- 3247
					local ____finalizing_131 = finalizing -- 3247
					local ____result_success_132 = result.success -- 3247
					local ____result_success_128 -- 3247
					if result.success then -- 3247
						____result_success_128 = nil -- 3247
					else -- 3247
						____result_success_128 = result.message -- 3247
					end -- 3247
					pending[#pending + 1] = { -- 3247
						sessionId = ____session_id_129, -- 3247
						taskId = ____taskId_130, -- 3247
						finalizing = ____finalizing_131, -- 3247
						stopRequested = ____result_success_132, -- 3247
						message = ____result_success_128 -- 3247
					} -- 3247
				end -- 3247
				::__continue539:: -- 3247
			end -- 3247
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3251
		end -- 3234
	} -- 3234
end -- 3224
function ____exports.validateTaskAccess(sessionId, taskId) -- 3256
	local session = getSessionItem(sessionId) -- 3257
	if not session then -- 3257
		return {success = false, message = "session not found"} -- 3258
	end -- 3258
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3258
		getSessionOperableTaskIds(sessionId), -- 3259
		taskId -- 3259
	) < 0 then -- 3259
		return {success = false, message = "task is not operable for this session"} -- 3260
	end -- 3260
	return {success = true, session = session} -- 3262
end -- 3256
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3265
	if checkpointId <= 0 then -- 3265
		return {success = false, message = "invalid checkpointId"} -- 3267
	end -- 3267
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3269
	if not checkpoint then -- 3269
		return {success = false, message = "checkpoint not found"} -- 3271
	end -- 3271
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3273
	if not taskAccess.success then -- 3273
		return taskAccess -- 3274
	end -- 3274
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3275
end -- 3265
function ____exports.listRunningSessions() -- 3278
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3279
	local sessions = {} -- 3286
	do -- 3286
		local i = 0 -- 3287
		while i < #rows do -- 3287
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3288
			if session.currentTaskStatus == "RUNNING" then -- 3288
				sessions[#sessions + 1] = session -- 3290
			end -- 3290
			i = i + 1 -- 3287
		end -- 3287
	end -- 3287
	return {success = true, sessions = sessions} -- 3293
end -- 3278
return ____exports -- 3278