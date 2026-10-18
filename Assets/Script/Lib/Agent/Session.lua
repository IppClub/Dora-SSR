-- [ts]: Session.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
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
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local scheduleStreamFlush, getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, activeLocalAgentControls, finalizingSubSessionTaskIds, activePromptRuns, streamUpdates, streamFlushScheduled, SESSION_SELECT_COLUMNS, now -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Director = ____Dora.Director -- 2
local Path = ____Dora.Path -- 2
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____StreamUpdates = require("Agent.Runtime.StreamUpdates") -- 3
local StreamUpdates = ____StreamUpdates.StreamUpdates -- 3
local ____SessionEvents = require("Agent.Runtime.SessionEvents") -- 4
local publishSessionPatch = ____SessionEvents.publishSessionPatch -- 4
local ____TaskAdmission = require("Agent.Runtime.TaskAdmission") -- 5
local holdProjectTaskAdmission = ____TaskAdmission.holdProjectTaskAdmission -- 5
local isProjectTaskAdmissionClosed = ____TaskAdmission.isProjectTaskAdmissionClosed -- 5
local ____DoraAgent = require("Agent.DoraAgent") -- 7
local runCodingAgent = ____DoraAgent.runCodingAgent -- 7
local truncateAgentUserPrompt = ____DoraAgent.truncateAgentUserPrompt -- 7
local AgentConfig = require("Agent.Config.Defaults") -- 10
local AgentToolRegistry = require("Agent.Tool.Registry") -- 11
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 12
local LocalAgent = require("Agent.Runtime.LocalAgent") -- 13
local Tools = require("Agent.Tools") -- 14
local ____Database = require("Agent.Storage.Database") -- 15
local TABLE_SESSION = ____Database.TABLE_SESSION -- 16
local TABLE_MESSAGE = ____Database.TABLE_MESSAGE -- 17
local TABLE_STEP = ____Database.TABLE_STEP -- 18
local TABLE_TASK = ____Database.TABLE_TASK -- 19
local TABLE_TASK_REFERENCE = ____Database.TABLE_TASK_REFERENCE -- 20
local addTaskReference = ____Database.addTaskReference -- 21
local cleanupTaskHeavyData = ____Database.cleanupTaskHeavyData -- 22
local getSessionOperableTaskIds = ____Database.getSessionOperableTaskIds -- 23
local requireAgentStorage = ____Database.requireAgentStorage -- 24
local ____Memory = require("Agent.Runtime.Memory") -- 26
local DualLayerStorage = ____Memory.DualLayerStorage -- 26
local ____Utils = require("Agent.Utils") -- 27
local Log = ____Utils.Log -- 27
local getLLMConfig = ____Utils.getLLMConfig -- 27
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 27
local safeJsonDecode = ____Utils.safeJsonDecode -- 27
local safeJsonEncode = ____Utils.safeJsonEncode -- 27
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 27
local validateAgentLLMConfig = ____Utils.validateAgentLLMConfig -- 27
local ____Questionnaire = require("Agent.Runtime.Questionnaire") -- 31
local validateQuestionnaireAnswers = ____Questionnaire.validateQuestionnaireAnswers -- 31
local ____Support = require("Agent.Storage.Support") -- 33
local getLastInsertRowId = ____Support.getLastInsertRowId -- 33
local queryOne = ____Support.queryOne -- 33
local queryRows = ____Support.queryRows -- 33
local toStr = ____Support.toStr -- 33
function scheduleStreamFlush() -- 347
	if streamFlushScheduled or not streamUpdates:hasPending() then -- 347
		return -- 348
	end -- 348
	streamFlushScheduled = true -- 349
	Director.systemScheduler:schedule(function() -- 350
		streamUpdates:flushDue(App.runningTime) -- 351
		if streamUpdates:hasPending() then -- 351
			return false -- 352
		end -- 352
		streamFlushScheduled = false -- 353
		return true -- 354
	end) -- 350
end -- 350
function getDefaultUseChineseResponse() -- 368
	local zh = string.match(App.locale, "^zh") -- 369
	return zh ~= nil -- 370
end -- 370
function encodeJson(value) -- 373
	local text = safeJsonEncode(value) -- 374
	return text or "" -- 375
end -- 375
function decodeJsonObject(text) -- 378
	if text == "" then -- 378
		return nil -- 379
	end -- 379
	local value = safeJsonDecode(text) -- 380
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 380
		return value -- 382
	end -- 382
	return nil -- 384
end -- 384
function decodeJsonFiles(text) -- 387
	if text == "" then -- 387
		return nil -- 388
	end -- 388
	local value = safeJsonDecode(text) -- 389
	if not value or not __TS__ArrayIsArray(value) then -- 389
		return nil -- 390
	end -- 390
	local files = {} -- 391
	do -- 391
		local i = 0 -- 392
		while i < #value do -- 392
			do -- 392
				local item = value[i + 1] -- 393
				if type(item) ~= "table" then -- 393
					goto __continue19 -- 394
				end -- 394
				files[#files + 1] = { -- 395
					path = sanitizeUTF8(toStr(item.path)), -- 396
					op = sanitizeUTF8(toStr(item.op)) -- 397
				} -- 397
			end -- 397
			::__continue19:: -- 397
			i = i + 1 -- 392
		end -- 392
	end -- 392
	return files -- 400
end -- 400
function decodeChangeSetSummary(value) -- 403
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 403
		return nil -- 404
	end -- 404
	local row = value -- 405
	if row.success ~= true then -- 405
		return nil -- 406
	end -- 406
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 407
	if taskId <= 0 then -- 407
		return nil -- 408
	end -- 408
	local files = {} -- 409
	if __TS__ArrayIsArray(row.files) then -- 409
		do -- 409
			local i = 0 -- 411
			while i < #row.files do -- 411
				do -- 411
					local file = row.files[i + 1] -- 412
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 412
						goto __continue27 -- 413
					end -- 413
					local fileRow = file -- 414
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 415
					if path == "" then -- 415
						goto __continue27 -- 416
					end -- 416
					local checkpointIds = {} -- 417
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 417
						do -- 417
							local j = 0 -- 419
							while j < #fileRow.checkpointIds do -- 419
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 420
								if checkpointId > 0 then -- 420
									checkpointIds[#checkpointIds + 1] = checkpointId -- 421
								end -- 421
								j = j + 1 -- 419
							end -- 419
						end -- 419
					end -- 419
					local op = toStr(fileRow.op) -- 424
					files[#files + 1] = { -- 425
						path = path, -- 426
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 427
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 428
						checkpointIds = checkpointIds -- 429
					} -- 429
				end -- 429
				::__continue27:: -- 429
				i = i + 1 -- 411
			end -- 411
		end -- 411
	end -- 411
	return { -- 433
		success = true, -- 434
		taskId = taskId, -- 435
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 436
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 437
		files = files, -- 438
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 439
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 440
	} -- 440
end -- 440
function decodeHandoffEvidence(value) -- 444
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 444
		return nil -- 445
	end -- 445
	local row = value -- 446
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 447
		__TS__ArrayFilter( -- 448
			row.modifiedFiles, -- 448
			function(____, item) return type(item) == "string" end -- 448
		), -- 448
		function(____, item) return sanitizeUTF8(item) end -- 448
	) or ({}) -- 448
	local lastBuild = nil -- 450
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 450
		local build = row.lastBuild -- 452
		lastBuild = { -- 453
			result = build.result == "passed" and "passed" or "failed", -- 454
			path = sanitizeUTF8(toStr(build.path)), -- 455
			evidence = takeUtf8Head( -- 456
				sanitizeUTF8(toStr(build.evidence)), -- 456
				600 -- 456
			) -- 456
		} -- 456
	end -- 456
	local commands = {} -- 459
	if __TS__ArrayIsArray(row.commands) then -- 459
		do -- 459
			local i = 0 -- 461
			while i < #row.commands and #commands < 8 do -- 461
				do -- 461
					local raw = row.commands[i + 1] -- 462
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 462
						goto __continue41 -- 463
					end -- 463
					local item = raw -- 464
					commands[#commands + 1] = { -- 465
						mode = sanitizeUTF8(toStr(item.mode)), -- 466
						command = takeUtf8Head( -- 467
							sanitizeUTF8(toStr(item.command)), -- 467
							600 -- 467
						), -- 467
						result = item.result == "passed" and "passed" or "failed", -- 468
						evidence = takeUtf8Head( -- 469
							sanitizeUTF8(toStr(item.evidence)), -- 469
							600 -- 469
						) -- 469
					} -- 469
				end -- 469
				::__continue41:: -- 469
				i = i + 1 -- 461
			end -- 461
		end -- 461
	end -- 461
	local authoritativeSources = {} -- 473
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 473
		do -- 473
			local i = 0 -- 475
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 475
				do -- 475
					local raw = row.authoritativeSources[i + 1] -- 476
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 476
						goto __continue45 -- 477
					end -- 477
					local item = raw -- 478
					authoritativeSources[#authoritativeSources + 1] = { -- 479
						tool = "search_dora_doc", -- 480
						query = takeUtf8Head( -- 481
							sanitizeUTF8(toStr(item.query)), -- 481
							300 -- 481
						), -- 481
						source = sanitizeUTF8(toStr(item.source)), -- 482
						result = item.result == "passed" and "passed" or "failed" -- 483
					} -- 483
				end -- 483
				::__continue45:: -- 483
				i = i + 1 -- 475
			end -- 475
		end -- 475
	end -- 475
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 487
end -- 487
function takeUtf8Head(text, maxChars) -- 490
	if maxChars <= 0 or text == "" then -- 490
		return "" -- 491
	end -- 491
	local nextPos = utf8.offset(text, maxChars + 1) -- 492
	if nextPos == nil then -- 492
		return text -- 493
	end -- 493
	return string.sub(text, 1, nextPos - 1) -- 494
end -- 494
function normalizeMemoryEntryEvidence(value) -- 497
	local evidence = {} -- 498
	if not __TS__ArrayIsArray(value) then -- 498
		return evidence -- 499
	end -- 499
	do -- 499
		local i = 0 -- 500
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 500
			do -- 500
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 501
				if item == "" then -- 501
					goto __continue53 -- 502
				end -- 502
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 502
					evidence[#evidence + 1] = item -- 504
				end -- 504
			end -- 504
			::__continue53:: -- 504
			i = i + 1 -- 500
		end -- 500
	end -- 500
	return evidence -- 507
end -- 507
function decodeSubAgentMemoryEntry(value) -- 510
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 510
		return nil -- 511
	end -- 511
	local row = value -- 512
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 513
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 514
	local content = takeUtf8Head( -- 515
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 515
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 515
	) -- 515
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 515
		return nil -- 516
	end -- 516
	return { -- 517
		sourceSessionId = sourceSessionId, -- 518
		sourceTaskId = sourceTaskId, -- 519
		content = content, -- 520
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 521
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 522
	} -- 522
end -- 522
function getTaskChangeSetSummary(taskId) -- 526
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 527
	return summary.success and summary or nil -- 528
end -- 528
function summarizeHandoffResult(result) -- 531
	local candidates = {result.output, result.message, result.state, result.phase} -- 532
	do -- 532
		local i = 0 -- 533
		while i < #candidates do -- 533
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 534
			if text ~= "" then -- 534
				return takeUtf8Head(text, 600) -- 535
			end -- 535
			i = i + 1 -- 533
		end -- 533
	end -- 533
	local messages = result.messages -- 537
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 537
		local parts = {} -- 539
		do -- 539
			local i = 0 -- 540
			while i < #messages and #parts < 4 do -- 540
				do -- 540
					local row = messages[i + 1] -- 541
					if not row or type(row) ~= "table" then -- 541
						goto __continue66 -- 542
					end -- 542
					local item = row -- 543
					local ____sanitizeUTF8_5 = sanitizeUTF8 -- 544
					local ____toStr_4 = toStr -- 544
					local ____item_message_2 = item.message -- 544
					if ____item_message_2 == nil then -- 544
						____item_message_2 = item.error -- 544
					end -- 544
					local ____item_message_2_3 = ____item_message_2 -- 544
					if ____item_message_2_3 == nil then -- 544
						____item_message_2_3 = item.file -- 544
					end -- 544
					local text = __TS__StringTrim(____sanitizeUTF8_5(____toStr_4(____item_message_2_3))) -- 544
					if text ~= "" then -- 544
						parts[#parts + 1] = text -- 545
					end -- 545
				end -- 545
				::__continue66:: -- 545
				i = i + 1 -- 540
			end -- 540
		end -- 540
		if #parts > 0 then -- 540
			return takeUtf8Head( -- 547
				table.concat(parts, "; "), -- 547
				600 -- 547
			) -- 547
		end -- 547
	end -- 547
	return result.success == true and "tool result success=true" or "tool result success=false" -- 549
end -- 549
function getTaskHandoffEvidence(taskId, changeSet) -- 552
	local ____opt_6 = changeSet -- 552
	local evidence = { -- 553
		modifiedFiles = ____opt_6 and __TS__ArrayMap( -- 554
			changeSet and changeSet.files, -- 554
			function(____, item) return item.path end -- 554
		) or ({}), -- 554
		commands = {}, -- 555
		authoritativeSources = {} -- 556
	} -- 556
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 558
	do -- 558
		local i = 0 -- 563
		while i < #rows do -- 563
			local tool = toStr(rows[i + 1][1]) -- 564
			local status = toStr(rows[i + 1][2]) -- 565
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 566
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 567
			local passed = status == "DONE" and result.success == true -- 568
			if tool == "build" then -- 568
				evidence.lastBuild = { -- 570
					result = passed and "passed" or "failed", -- 571
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 572
					evidence = summarizeHandoffResult(result) -- 573
				} -- 573
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 573
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 576
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 577
				local ____evidence_commands_10 = evidence.commands -- 577
				____evidence_commands_10[#____evidence_commands_10 + 1] = { -- 578
					mode = mode, -- 579
					command = takeUtf8Head( -- 580
						__TS__StringTrim(sanitizeUTF8(command)), -- 580
						600 -- 580
					), -- 580
					result = passed and "passed" or "failed", -- 581
					evidence = summarizeHandoffResult(result) -- 582
				} -- 582
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 582
				local ____evidence_authoritativeSources_11 = evidence.authoritativeSources -- 582
				____evidence_authoritativeSources_11[#____evidence_authoritativeSources_11 + 1] = { -- 585
					tool = "search_dora_doc", -- 586
					query = takeUtf8Head( -- 587
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 587
						300 -- 587
					), -- 587
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 588
					result = passed and "passed" or "failed" -- 589
				} -- 589
			end -- 589
			i = i + 1 -- 563
		end -- 563
	end -- 563
	return evidence -- 593
end -- 593
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 596
	local lastBuild = evidence.lastBuild -- 600
	if not lastBuild or lastBuild.result ~= "failed" then -- 600
		return completion -- 601
	end -- 601
	local validation = __TS__ArraySlice(completion.validation) -- 602
	local foundBuild = false -- 603
	do -- 603
		local i = 0 -- 604
		while i < #validation do -- 604
			do -- 604
				if validation[i + 1].kind ~= "build" then -- 604
					goto __continue80 -- 605
				end -- 605
				foundBuild = true -- 606
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 607
			end -- 607
			::__continue80:: -- 607
			i = i + 1 -- 604
		end -- 604
	end -- 604
	if not foundBuild then -- 604
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 614
	end -- 614
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 616
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 617
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 617
		knownIssues[#knownIssues + 1] = issue -- 618
	end -- 618
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 619
end -- 619
function isValidProjectRoot(path) -- 627
	return path ~= "" and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 628
end -- 628
function rowToSession(row) -- 631
	return { -- 632
		id = row[1], -- 633
		projectRoot = toStr(row[2]), -- 634
		title = toStr(row[3]), -- 635
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 636
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 637
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 638
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 639
		status = toStr(row[8]), -- 640
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 641
		currentTaskStatus = toStr(row[10]), -- 642
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 643
		createdAt = row[11], -- 644
		updatedAt = row[12], -- 645
		metrics = decodeJsonObject(toStr(row[13])), -- 646
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 647
	} -- 647
end -- 647
function rowToMessage(row) -- 651
	local message = { -- 652
		id = row[1], -- 653
		sessionId = row[2], -- 654
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 655
		role = toStr(row[4]), -- 656
		content = toStr(row[5]), -- 657
		createdAt = row[7], -- 658
		updatedAt = row[8] -- 659
	} -- 659
	local displayContent = toStr(row[6]) -- 661
	if displayContent ~= "" then -- 661
		message.displayContent = displayContent -- 662
	end -- 662
	return message -- 663
end -- 663
function rowToStep(row) -- 666
	return { -- 667
		id = row[1], -- 668
		sessionId = row[2], -- 669
		taskId = row[3], -- 670
		step = row[4], -- 671
		tool = toStr(row[5]), -- 672
		status = toStr(row[6]), -- 673
		reason = toStr(row[7]), -- 674
		reasoningContent = toStr(row[8]), -- 675
		params = decodeJsonObject(toStr(row[9])), -- 676
		result = decodeJsonObject(toStr(row[10])), -- 677
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 678
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 679
		files = decodeJsonFiles(toStr(row[13])), -- 680
		createdAt = row[14], -- 681
		updatedAt = row[15] -- 682
	} -- 682
end -- 682
function getQuestionnairePath(projectRoot) -- 686
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 687
end -- 687
function decodeQuestionnaireFile(text) -- 690
	local value = decodeJsonObject(text) -- 691
	if not value then -- 691
		return nil -- 692
	end -- 692
	local schema = value.schema -- 693
	local id = type(value.id) == "number" and value.id or 0 -- 694
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 695
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 696
	local step = type(value.step) == "number" and value.step or 0 -- 697
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 698
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 698
		return nil -- 700
	end -- 700
	return { -- 702
		id = id, -- 702
		sessionId = sessionId, -- 702
		taskId = taskId, -- 702
		step = step, -- 702
		status = "PENDING", -- 702
		schema = schema, -- 702
		createdAt = createdAt -- 702
	} -- 702
end -- 702
function getPendingQuestionnaire(sessionId) -- 705
	local session = getSessionItem(sessionId) -- 706
	if not session or session.kind ~= "main" then -- 706
		return nil -- 707
	end -- 707
	local path = getQuestionnairePath(session.projectRoot) -- 708
	if not Content:exist(path) then -- 708
		return nil -- 709
	end -- 709
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 710
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 711
end -- 711
function restorePendingQuestionnaireState(session) -- 714
	local questionnaire = getPendingQuestionnaire(session.id) -- 715
	if not questionnaire then -- 715
		return {session = session} -- 716
	end -- 716
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 716
		local t = now() -- 723
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 724
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 730
		local restored = getSessionItem(session.id) -- 731
		if restored then -- 731
			session = restored -- 732
		end -- 732
	end -- 732
	return {session = session, questionnaire = questionnaire} -- 734
end -- 734
function savePendingQuestionnaire(projectRoot, questionnaire) -- 737
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 738
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 738
		return false -- 739
	end -- 739
	local path = getQuestionnairePath(projectRoot) -- 740
	local tempPath = path .. ".tmp" -- 741
	local backupPath = path .. ".bak" -- 742
	Content:remove(tempPath) -- 743
	Content:remove(backupPath) -- 744
	if not Content:save( -- 744
		tempPath, -- 745
		encodeJson(questionnaire) -- 745
	) then -- 745
		return false -- 745
	end -- 745
	local hadOriginal = Content:exist(path) -- 746
	if hadOriginal and not Content:move(path, backupPath) then -- 746
		Content:remove(tempPath) -- 748
		return false -- 749
	end -- 749
	if Content:move(tempPath, path) then -- 749
		Content:remove(backupPath) -- 752
		Tools.sendWebIDEFileUpdate( -- 753
			path, -- 753
			true, -- 753
			encodeJson(questionnaire) -- 753
		) -- 753
		return true -- 754
	end -- 754
	Content:remove(tempPath) -- 756
	if hadOriginal and Content:exist(backupPath) then -- 756
		Content:move(backupPath, path) -- 758
	end -- 758
	return false -- 760
end -- 760
function removePendingQuestionnaire(session) -- 763
	local path = getQuestionnairePath(session.projectRoot) -- 764
	if not Content:exist(path) then -- 764
		return true -- 765
	end -- 765
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 766
	if questionnaire and questionnaire.sessionId ~= session.id then -- 766
		return false -- 767
	end -- 767
	if not Content:remove(path) then -- 767
		return false -- 768
	end -- 768
	Tools.sendWebIDEFileUpdate(path, false, "") -- 769
	return true -- 770
end -- 770
function publishQuestionnaire(request) -- 773
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 773
		local session = getSessionItem(request.sessionId) -- 779
		if not session or session.kind ~= "main" then -- 779
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 779
		end -- 779
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 781
		if Content:exist(pendingPath) then -- 781
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 781
		end -- 781
		local questionnaire = { -- 783
			id = request.taskId, -- 784
			sessionId = request.sessionId, -- 785
			taskId = request.taskId, -- 786
			step = request.step, -- 787
			status = "PENDING", -- 788
			schema = request.schema, -- 789
			createdAt = now() -- 790
		} -- 790
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 790
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 790
		end -- 790
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 790
	end) -- 790
end -- 790
function getMessageItem(messageId) -- 798
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 799
	return row and rowToMessage(row) or nil -- 805
end -- 805
function getStepItem(sessionId, taskId, step) -- 808
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 809
	return row and rowToStep(row) or nil -- 815
end -- 815
function deleteMessageSteps(sessionId, taskId) -- 818
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 819
	local ids = {} -- 824
	do -- 824
		local i = 0 -- 825
		while i < #rows do -- 825
			local row = rows[i + 1] -- 826
			if type(row[1]) == "number" then -- 826
				ids[#ids + 1] = row[1] -- 828
			end -- 828
			i = i + 1 -- 825
		end -- 825
	end -- 825
	if #ids > 0 then -- 825
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 832
	end -- 832
	return ids -- 838
end -- 838
function normalizeDisabledAgentTools(value) -- 841
	if not __TS__ArrayIsArray(value) then -- 841
		return {} -- 842
	end -- 842
	local tools = {} -- 843
	do -- 843
		local i = 0 -- 844
		while i < #value do -- 844
			do -- 844
				local name = value[i + 1] -- 845
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 845
					goto __continue124 -- 846
				end -- 846
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 846
					tools[#tools + 1] = name -- 847
				end -- 847
			end -- 847
			::__continue124:: -- 847
			i = i + 1 -- 844
		end -- 844
	end -- 844
	return tools -- 849
end -- 849
function normalizeWorkMode(value, fallback) -- 852
	if fallback == nil then -- 852
		fallback = "code" -- 852
	end -- 852
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 853
end -- 853
function getSessionRow(sessionId) -- 856
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 857
end -- 857
function getSessionItem(sessionId) -- 865
	local row = getSessionRow(sessionId) -- 866
	return row and rowToSession(row) or nil -- 867
end -- 867
function getTaskPrompt(taskId) -- 870
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 871
	if not row or type(row[1]) ~= "string" then -- 871
		return nil -- 872
	end -- 872
	return toStr(row[1]) -- 873
end -- 873
function getLatestMainSessionByProjectRoot(projectRoot) -- 876
	if not isValidProjectRoot(projectRoot) then -- 876
		return nil -- 877
	end -- 877
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 878
	return row and rowToSession(row) or nil -- 886
end -- 886
function countRunningSubSessions(rootSessionId) -- 889
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 890
	local count = 0 -- 897
	do -- 897
		local i = 0 -- 898
		while i < #rows do -- 898
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 899
			if session.currentTaskStatus == "RUNNING" then -- 899
				count = count + 1 -- 901
			end -- 901
			i = i + 1 -- 898
		end -- 898
	end -- 898
	return count -- 904
end -- 904
function deleteSessionRecords(sessionId, preserveArtifacts) -- 907
	if preserveArtifacts == nil then -- 907
		preserveArtifacts = false -- 907
	end -- 907
	streamUpdates:clear(sessionId) -- 908
	local session = getSessionItem(sessionId) -- 909
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 910
	local taskIds = {} -- 918
	do -- 918
		local i = 0 -- 919
		while i < #taskRows do -- 919
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 920
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 920
				taskIds[#taskIds + 1] = taskId -- 922
				local stopToken = activeStopTokens[taskId] -- 923
				if stopToken ~= nil then -- 923
					stopToken.stopped = true -- 925
					stopToken.reason = "session deleted" -- 926
				end -- 926
			end -- 926
			i = i + 1 -- 919
		end -- 919
	end -- 919
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 930
	do -- 930
		local i = 0 -- 931
		while i < #children do -- 931
			local row = children[i + 1] -- 932
			if type(row[1]) == "number" and row[1] > 0 then -- 932
				deleteSessionRecords(row[1], preserveArtifacts) -- 934
			end -- 934
			i = i + 1 -- 931
		end -- 931
	end -- 931
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 937
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 938
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 939
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 940
	if session and session.kind == "main" then -- 940
		removePendingQuestionnaire(session) -- 942
	end -- 942
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 942
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 942
			Tools.sendWebIDERefreshTree() -- 946
		end -- 946
	end -- 946
	do -- 946
		local i = 0 -- 949
		while i < #taskIds do -- 949
			cleanupTaskHeavyData(taskIds[i + 1]) -- 950
			i = i + 1 -- 949
		end -- 949
	end -- 949
end -- 949
function getSessionRootId(session) -- 954
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 955
end -- 955
function getRootSessionItem(sessionId) -- 958
	local session = getSessionItem(sessionId) -- 959
	if not session then -- 959
		return nil -- 960
	end -- 960
	return getSessionItem(getSessionRootId(session)) or session -- 961
end -- 961
function listRelatedSessions(sessionId) -- 964
	local root = getRootSessionItem(sessionId) -- 965
	if not root then -- 965
		return {} -- 966
	end -- 966
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 967
	return __TS__ArrayMap( -- 976
		rows, -- 976
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 976
	) -- 976
end -- 976
function getSessionSpawnInfo(session) -- 979
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 980
	if not info then -- 980
		return nil -- 981
	end -- 981
	local ____temp_17 = type(info.sessionId) == "number" and info.sessionId or nil -- 983
	local ____temp_18 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 984
	local ____temp_19 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 985
	local ____temp_20 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 986
	local ____temp_21 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 987
	local ____temp_22 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 988
	local ____temp_23 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 989
	local ____temp_24 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 990
		__TS__ArrayFilter( -- 991
			info.filesHint, -- 991
			function(____, item) return type(item) == "string" end -- 991
		), -- 991
		function(____, item) return sanitizeUTF8(item) end -- 991
	) or nil -- 991
	local ____temp_25 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 993
	local ____temp_15 -- 996
	if info.success == true then -- 996
		____temp_15 = true -- 996
	else -- 996
		local ____temp_14 -- 996
		if info.success == false then -- 996
			____temp_14 = false -- 996
		else -- 996
			____temp_14 = nil -- 996
		end -- 996
		____temp_15 = ____temp_14 -- 996
	end -- 996
	local ____temp_16 -- 997
	if info.cleared == true then -- 997
		____temp_16 = true -- 997
	else -- 997
		____temp_16 = nil -- 997
	end -- 997
	return { -- 982
		sessionId = ____temp_17, -- 983
		rootSessionId = ____temp_18, -- 984
		parentSessionId = ____temp_19, -- 985
		title = ____temp_20, -- 986
		prompt = ____temp_21, -- 987
		goal = ____temp_22, -- 988
		expectedOutput = ____temp_23, -- 989
		filesHint = ____temp_24, -- 990
		status = ____temp_25, -- 993
		success = ____temp_15, -- 996
		cleared = ____temp_16, -- 997
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 998
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 999
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 1000
		changeSet = decodeChangeSetSummary(info.changeSet), -- 1001
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1002
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1003
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 1004
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 1005
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 1008
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 1009
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 1010
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 1011
	} -- 1011
end -- 1011
function ensureDirRecursive(dir) -- 1028
	if dir == "" then -- 1028
		return false -- 1029
	end -- 1029
	if Content:exist(dir) then -- 1029
		return Content:isdir(dir) -- 1030
	end -- 1030
	local parent = Path:getPath(dir) -- 1031
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1031
		if not ensureDirRecursive(parent) then -- 1031
			return false -- 1034
		end -- 1034
	end -- 1034
	return Content:mkdir(dir) -- 1037
end -- 1037
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1040
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1041
	if not Content:exist(dir) then -- 1041
		ensureDirRecursive(dir) -- 1043
	end -- 1043
	local path = Path(dir, SPAWN_INFO_FILE) -- 1045
	local text = safeJsonEncode(value) -- 1046
	if not text then -- 1046
		return false -- 1047
	end -- 1047
	local content = text .. "\n" -- 1048
	if not Content:save(path, content) then -- 1048
		return false -- 1050
	end -- 1050
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1052
	return true -- 1053
end -- 1053
function readSpawnInfo(projectRoot, memoryScope) -- 1056
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1057
	if not Content:exist(path) then -- 1057
		return nil -- 1058
	end -- 1058
	local text = Content:load(path) -- 1059
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1059
		return nil -- 1060
	end -- 1060
	local value = safeJsonDecode(text) -- 1061
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1061
		return value -- 1063
	end -- 1063
	return nil -- 1065
end -- 1065
function getArtifactRelativeDir(memoryScope) -- 1068
	return Path(".agent", memoryScope) -- 1069
end -- 1069
function getArtifactDir(projectRoot, memoryScope) -- 1072
	return Path( -- 1073
		projectRoot, -- 1073
		getArtifactRelativeDir(memoryScope) -- 1073
	) -- 1073
end -- 1073
function getResultRelativePath(memoryScope) -- 1076
	return Path( -- 1077
		getArtifactRelativeDir(memoryScope), -- 1077
		RESULT_FILE -- 1077
	) -- 1077
end -- 1077
function getResultPath(projectRoot, memoryScope) -- 1080
	return Path( -- 1081
		projectRoot, -- 1081
		getResultRelativePath(memoryScope) -- 1081
	) -- 1081
end -- 1081
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1084
	if resultFilePath == "" then -- 1084
		return "" -- 1085
	end -- 1085
	local path = Path(projectRoot, resultFilePath) -- 1086
	if not Content:exist(path) then -- 1086
		return "" -- 1087
	end -- 1087
	local text = sanitizeUTF8(Content:load(path)) -- 1088
	if __TS__StringTrim(text) == "" then -- 1088
		return "" -- 1089
	end -- 1089
	local marker = "\n## Summary\n" -- 1090
	local start = string.find(text, marker, 1, true) -- 1091
	if start ~= nil then -- 1091
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1093
	end -- 1093
	return __TS__StringTrim(text) -- 1095
end -- 1095
function buildStructuredSubAgentMemoryEntry(record) -- 1098
	local hasPassedValidation = false -- 1099
	do -- 1099
		local i = 0 -- 1100
		while i < #record.completion.validation do -- 1100
			local result = record.completion.validation[i + 1].result -- 1101
			if result == "failed" then -- 1101
				return nil -- 1106
			end -- 1106
			if result == "passed" then -- 1106
				hasPassedValidation = true -- 1108
			end -- 1108
			i = i + 1 -- 1100
		end -- 1100
	end -- 1100
	if not hasPassedValidation then -- 1100
		return nil -- 1111
	end -- 1111
	local candidates = record.completion.learningCandidates -- 1112
	local claims = {} -- 1113
	local evidence = {} -- 1114
	do -- 1114
		local i = 0 -- 1115
		while i < #candidates do -- 1115
			do -- 1115
				local candidate = candidates[i + 1] -- 1116
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1116
					goto __continue195 -- 1117
				end -- 1117
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1118
				do -- 1118
					local j = 0 -- 1119
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1119
						local item = candidate.evidence[j + 1] -- 1120
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1120
							evidence[#evidence + 1] = item -- 1121
						end -- 1121
						j = j + 1 -- 1119
					end -- 1119
				end -- 1119
			end -- 1119
			::__continue195:: -- 1119
			i = i + 1 -- 1115
		end -- 1115
	end -- 1115
	local content = takeUtf8Head( -- 1124
		table.concat(claims, "\n"), -- 1124
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1124
	) -- 1124
	if content == "" then -- 1124
		return nil -- 1125
	end -- 1125
	return { -- 1126
		sourceSessionId = record.sessionId, -- 1127
		sourceTaskId = record.sourceTaskId, -- 1128
		content = content, -- 1129
		evidence = evidence, -- 1130
		createdAt = record.finishedAt -- 1131
	} -- 1131
end -- 1131
function containsNormalizedText(text, query) -- 1135
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1136
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1137
	if normalizedQuery == "" then -- 1137
		return true -- 1138
	end -- 1138
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1139
end -- 1139
function getSubAgentDisplayKey(item) -- 1142
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1148
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1149
	local label = goal ~= "" and goal or title -- 1150
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1151
end -- 1151
function writeSubAgentResultFile(session, record, resultText) -- 1154
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1155
	if not Content:exist(dir) then -- 1155
		ensureDirRecursive(dir) -- 1157
	end -- 1157
	local ____array_34 = __TS__SparseArrayNew( -- 1157
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1160
		"- Status: " .. record.status, -- 1161
		"- Success: " .. (record.success and "true" or "false"), -- 1162
		"- Outcome: " .. record.completion.outcome, -- 1163
		"- Session ID: " .. tostring(record.sessionId), -- 1164
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1165
		"- Goal: " .. record.goal, -- 1166
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1167
	) -- 1167
	__TS__SparseArrayPush( -- 1167
		____array_34, -- 1167
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1168
	) -- 1168
	__TS__SparseArrayPush( -- 1168
		____array_34, -- 1168
		"- Finished At: " .. record.finishedAt, -- 1169
		"", -- 1170
		"## Validation", -- 1171
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1172
			record.completion.validation, -- 1173
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1173
		) or ({"- Not reported"})) -- 1173
	) -- 1173
	__TS__SparseArrayPush(____array_34, "", "## Recorded Evidence") -- 1173
	local ____opt_26 = record.handoffEvidence -- 1173
	__TS__SparseArrayPush( -- 1173
		____array_34, -- 1173
		table.unpack(____opt_26 and #____opt_26.modifiedFiles and __TS__ArrayMap( -- 1177
			record.handoffEvidence.modifiedFiles, -- 1178
			function(____, item) return "- modified: " .. item end -- 1178
		) or ({"- modified: none recorded"})) -- 1178
	) -- 1178
	local ____opt_28 = record.handoffEvidence -- 1178
	__TS__SparseArrayPush( -- 1178
		____array_34, -- 1178
		table.unpack(____opt_28 and ____opt_28.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1180
	) -- 1180
	local ____opt_30 = record.handoffEvidence -- 1180
	__TS__SparseArrayPush( -- 1180
		____array_34, -- 1180
		table.unpack(__TS__ArrayMap( -- 1183
			____opt_30 and ____opt_30.commands or ({}), -- 1183
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1183
		)) -- 1183
	) -- 1183
	local ____opt_32 = record.handoffEvidence -- 1183
	__TS__SparseArrayPush( -- 1183
		____array_34, -- 1183
		table.unpack(__TS__ArrayMap( -- 1184
			____opt_32 and ____opt_32.authoritativeSources or ({}), -- 1184
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1184
		)) -- 1184
	) -- 1184
	__TS__SparseArrayPush( -- 1184
		____array_34, -- 1184
		"", -- 1185
		"## Known Issues", -- 1186
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1187
			record.completion.knownIssues, -- 1187
			function(____, item) return "- " .. item end -- 1187
		) or ({"- None reported"})) -- 1187
	) -- 1187
	__TS__SparseArrayPush( -- 1187
		____array_34, -- 1187
		"", -- 1188
		"## Assumptions", -- 1189
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1190
			record.completion.assumptions, -- 1190
			function(____, item) return "- " .. item end -- 1190
		) or ({"- None reported"})) -- 1190
	) -- 1190
	__TS__SparseArrayPush(____array_34, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1190
	local lines = {__TS__SparseArraySpread(____array_34)} -- 1159
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1195
	local content = table.concat(lines, "\n") .. "\n" -- 1196
	if not Content:save(path, content) then -- 1196
		return false -- 1198
	end -- 1198
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1200
	return true -- 1201
end -- 1201
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1204
	local dir = Path(projectRoot, ".agent", "subagents") -- 1205
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1205
		return {} -- 1206
	end -- 1206
	local items = {} -- 1207
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1208
		do -- 1208
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1209
			if not Content:exist(path) or not Content:isdir(path) then -- 1209
				goto __continue215 -- 1210
			end -- 1210
			local info = readSpawnInfo( -- 1211
				projectRoot, -- 1211
				Path( -- 1211
					"subagents", -- 1211
					Path:getFilename(path) -- 1211
				) -- 1211
			) -- 1211
			if not info then -- 1211
				goto __continue215 -- 1212
			end -- 1212
			local sessionId = tonumber(info.sessionId) -- 1213
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1214
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1215
			local status = sanitizeUTF8(toStr(info.status)) -- 1216
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1216
				goto __continue215 -- 1217
			end -- 1217
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1217
				goto __continue215 -- 1218
			end -- 1218
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1219
			items[#items + 1] = { -- 1220
				sessionId = sessionId, -- 1221
				rootSessionId = infoRootSessionId, -- 1222
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1223
				title = sanitizeUTF8(toStr(info.title)), -- 1224
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1225
				goal = sanitizeUTF8(toStr(info.goal)), -- 1226
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1227
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1228
					__TS__ArrayFilter( -- 1229
						info.filesHint, -- 1229
						function(____, item) return type(item) == "string" end -- 1229
					), -- 1229
					function(____, item) return sanitizeUTF8(item) end -- 1229
				) or ({}), -- 1229
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1231
				success = info.success == true, -- 1232
				cleared = info.cleared == true, -- 1233
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1234
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1235
					"subagents", -- 1235
					Path:getFilename(path) -- 1235
				)), -- 1235
				sourceTaskId = sourceTaskId or 0, -- 1236
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1237
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1238
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1239
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1240
				completion = normalizeAgentCompletionReport(info.completion), -- 1241
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1242
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1243
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1244
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1245
			} -- 1245
		end -- 1245
		::__continue215:: -- 1245
	end -- 1245
	__TS__ArraySort( -- 1248
		items, -- 1248
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1248
	) -- 1248
	return items -- 1249
end -- 1249
function getPendingHandoffDir(projectRoot, memoryScope) -- 1252
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1253
end -- 1253
function writePendingHandoff(projectRoot, memoryScope, value) -- 1256
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1257
	if not Content:exist(dir) then -- 1257
		ensureDirRecursive(dir) -- 1259
	end -- 1259
	local path = Path(dir, value.id .. ".json") -- 1261
	local text = safeJsonEncode(value) -- 1262
	if not text then -- 1262
		return false -- 1263
	end -- 1263
	local content = text .. "\n" -- 1264
	if not Content:save(path, content) then -- 1264
		return false -- 1265
	end -- 1265
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1266
	return true -- 1267
end -- 1267
function listPendingHandoffs(projectRoot, memoryScope) -- 1270
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1271
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1271
		return {} -- 1272
	end -- 1272
	local items = {} -- 1273
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1274
		do -- 1274
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1275
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1275
				goto __continue231 -- 1276
			end -- 1276
			local text = Content:load(path) -- 1277
			if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1277
				goto __continue231 -- 1278
			end -- 1278
			local obj = safeJsonDecode(text) -- 1279
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1279
				goto __continue231 -- 1280
			end -- 1280
			local value = obj -- 1281
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1282
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1283
			local id = sanitizeUTF8(toStr(value.id)) -- 1284
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1285
			local message = sanitizeUTF8(toStr(value.message)) -- 1286
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1287
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1288
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1289
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1289
				goto __continue231 -- 1291
			end -- 1291
			items[#items + 1] = { -- 1293
				id = id, -- 1294
				sourceSessionId = sourceSessionId, -- 1295
				sourceTitle = sourceTitle, -- 1296
				sourceTaskId = sourceTaskId, -- 1297
				message = message, -- 1298
				prompt = prompt, -- 1299
				goal = goal, -- 1300
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1301
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1302
					__TS__ArrayFilter( -- 1303
						value.filesHint, -- 1303
						function(____, item) return type(item) == "string" end -- 1303
					), -- 1303
					function(____, item) return sanitizeUTF8(item) end -- 1303
				) or ({}), -- 1303
				success = value.success == true, -- 1305
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1306
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1307
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1308
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1309
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1310
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1311
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1312
				createdAt = createdAt -- 1315
			} -- 1315
		end -- 1315
		::__continue231:: -- 1315
	end -- 1315
	__TS__ArraySort( -- 1318
		items, -- 1318
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1318
	) -- 1318
	return items -- 1319
end -- 1319
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1322
	local path = Path( -- 1323
		getPendingHandoffDir(projectRoot, memoryScope), -- 1323
		id .. ".json" -- 1323
	) -- 1323
	if Content:exist(path) then -- 1323
		if Content:remove(path) then -- 1323
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1326
		end -- 1326
	end -- 1326
end -- 1326
function normalizePromptText(prompt) -- 1331
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1332
end -- 1332
function normalizePromptTextSafe(prompt) -- 1335
	if type(prompt) == "string" then -- 1335
		local normalized = normalizePromptText(prompt) -- 1337
		if normalized ~= "" then -- 1337
			return normalized -- 1338
		end -- 1338
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1339
		if sanitized ~= "" then -- 1339
			return truncateAgentUserPrompt(sanitized) -- 1341
		end -- 1341
		return "" -- 1343
	end -- 1343
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1345
	if text == "" then -- 1345
		return "" -- 1346
	end -- 1346
	return truncateAgentUserPrompt(text) -- 1347
end -- 1347
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1350
	local sections = {} -- 1351
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1352
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1353
	local normalizedFiles = __TS__ArrayFilter( -- 1354
		__TS__ArrayMap( -- 1354
			__TS__ArrayFilter( -- 1354
				filesHint or ({}), -- 1354
				function(____, item) return type(item) == "string" end -- 1355
			), -- 1355
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1356
		), -- 1356
		function(____, item) return item ~= "" end -- 1357
	) -- 1357
	if normalizedTitle ~= "" then -- 1357
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1359
	end -- 1359
	if normalizedExpected ~= "" then -- 1359
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1362
	end -- 1362
	if #normalizedFiles > 0 then -- 1362
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1365
	end -- 1365
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1367
end -- 1367
function normalizeSessionRuntimeState(session) -- 1370
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1370
		return session -- 1372
	end -- 1372
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1372
		return session -- 1375
	end -- 1375
	if activeLocalAgentControls[session.currentTaskId] ~= nil then -- 1375
		return session -- 1378
	end -- 1378
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1380
		session.id, -- 1383
		session.currentTaskId, -- 1383
		"fetch_url", -- 1383
		"execute_command", -- 1383
		"analyze_image" -- 1383
	}) or ({}) -- 1383
	if #pendingToolRows > 0 then -- 1383
		local t = now() -- 1386
		do -- 1386
			local i = 0 -- 1387
			while i < #pendingToolRows do -- 1387
				local row = pendingToolRows[i + 1] -- 1388
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1389
				result.success = false -- 1390
				result.state = "failed" -- 1391
				result.interrupted = true -- 1392
				result.message = "tool call was interrupted because the program exited before it completed." -- 1393
				DB:exec( -- 1394
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1394
					{ -- 1396
						encodeJson(result), -- 1396
						t, -- 1396
						row[1] -- 1396
					} -- 1396
				) -- 1396
				i = i + 1 -- 1387
			end -- 1387
		end -- 1387
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1399
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1400
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1401
	end -- 1401
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1408
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1409
	return __TS__ObjectAssign( -- 1410
		{}, -- 1410
		session, -- 1411
		{ -- 1410
			status = "STOPPED", -- 1412
			currentTaskStatus = "STOPPED", -- 1413
			updatedAt = now() -- 1414
		} -- 1414
	) -- 1414
end -- 1414
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1418
	DB:exec( -- 1419
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1419
		{ -- 1423
			status, -- 1424
			currentTaskId or 0, -- 1425
			currentTaskStatus or status, -- 1426
			now(), -- 1427
			sessionId -- 1428
		} -- 1428
	) -- 1428
end -- 1428
function mergeAgentMetrics(current, next) -- 1433
	return __TS__ObjectAssign({}, current or ({}), next) -- 1434
end -- 1434
function updateSessionMetrics(sessionId, metrics) -- 1440
	local session = getSessionItem(sessionId) -- 1441
	if not session then -- 1441
		return nil -- 1442
	end -- 1442
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1443
	DB:exec( -- 1444
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1444
		{ -- 1448
			encodeJson(merged), -- 1449
			now(), -- 1450
			sessionId -- 1451
		} -- 1451
	) -- 1451
	return merged -- 1454
end -- 1454
function clearSessionTokenUsage(sessionId) -- 1457
	local session = getSessionItem(sessionId) -- 1458
	if not session then -- 1458
		return nil -- 1459
	end -- 1459
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1460
	__TS__Delete(metrics, "usage") -- 1461
	__TS__Delete(metrics, "visionUsage") -- 1462
	DB:exec( -- 1463
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1463
		{ -- 1467
			encodeJson(metrics), -- 1468
			now(), -- 1469
			sessionId -- 1470
		} -- 1470
	) -- 1470
	return metrics -- 1473
end -- 1473
function getInitialTokenUsage(session) -- 1476
	local ____opt_35 = session.metrics -- 1476
	local usage = ____opt_35 and ____opt_35.usage -- 1477
	if not usage or (usage.requestCount or 0) <= 0 then -- 1477
		return nil -- 1478
	end -- 1478
	return { -- 1479
		inputTokens = usage.inputTokens or 0, -- 1480
		outputTokens = usage.outputTokens or 0, -- 1481
		totalTokens = usage.totalTokens, -- 1482
		cachedInputTokens = usage.cachedInputTokens, -- 1483
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1484
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1485
		requestCount = usage.requestCount or 0, -- 1486
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1487
		model = usage.model or "", -- 1488
		phase = usage.phase or "", -- 1489
		step = usage.step or 0, -- 1490
		updatedAt = usage.updatedAt or now() -- 1491
	} -- 1491
end -- 1491
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1495
	if taskId == nil or taskId <= 0 then -- 1495
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1497
		return -- 1498
	end -- 1498
	local row = getSessionRow(sessionId) -- 1500
	if not row then -- 1500
		return -- 1501
	end -- 1501
	local session = rowToSession(row) -- 1502
	if session.currentTaskId ~= taskId then -- 1502
		Log( -- 1504
			"Info", -- 1504
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1504
		) -- 1504
		return -- 1505
	end -- 1505
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1507
end -- 1507
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1510
	local t = now() -- 1511
	DB:exec( -- 1512
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1512
		{ -- 1515
			sessionId, -- 1516
			taskId or 0, -- 1517
			role, -- 1518
			sanitizeUTF8(content), -- 1519
			displayContent and sanitizeUTF8(displayContent) or "", -- 1520
			t, -- 1521
			t -- 1522
		} -- 1522
	) -- 1522
	return getLastInsertRowId() -- 1525
end -- 1525
function updateMessage(messageId, content) -- 1528
	DB:exec( -- 1529
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1529
		{ -- 1531
			sanitizeUTF8(content), -- 1531
			now(), -- 1531
			messageId -- 1531
		} -- 1531
	) -- 1531
end -- 1531
function updateUserMessageForTask(messageId, content, taskId) -- 1535
	DB:exec( -- 1536
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1536
		{ -- 1540
			sanitizeUTF8(content), -- 1540
			taskId, -- 1540
			now(), -- 1540
			messageId -- 1540
		} -- 1540
	) -- 1540
end -- 1540
function removeContinuableTaskSummary(session) -- 1597
	local taskId = session.currentTaskId -- 1598
	if taskId == nil then -- 1598
		return -- 1599
	end -- 1599
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1600
end -- 1600
function upsertAssistantMessage(sessionId, taskId, content) -- 1612
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1613
	if row and type(row[1]) == "number" then -- 1613
		updateMessage(row[1], content) -- 1620
		return row[1] -- 1621
	end -- 1621
	return insertMessage(sessionId, "assistant", content, taskId) -- 1623
end -- 1623
function upsertStep(sessionId, taskId, step, tool, patch) -- 1626
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1636
	local reason = sanitizeUTF8(patch.reason or "") -- 1640
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1641
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1642
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1643
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1644
	local statusPatch = patch.status or "" -- 1645
	local status = patch.status or "PENDING" -- 1646
	if not row then -- 1646
		local t = now() -- 1648
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1649
			sessionId, -- 1653
			taskId, -- 1654
			step, -- 1655
			tool, -- 1656
			status, -- 1657
			reason, -- 1658
			reasoningContent, -- 1659
			paramsJson, -- 1660
			resultJson, -- 1661
			patch.checkpointId or 0, -- 1662
			patch.checkpointSeq or 0, -- 1663
			filesJson, -- 1664
			t, -- 1665
			t -- 1666
		}) -- 1666
		return -- 1669
	end -- 1669
	DB:exec( -- 1671
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1671
		{ -- 1683
			tool, -- 1684
			statusPatch, -- 1685
			status, -- 1686
			reason, -- 1687
			reason, -- 1688
			reasoningContent, -- 1689
			reasoningContent, -- 1690
			paramsJson, -- 1691
			paramsJson, -- 1692
			resultJson, -- 1693
			resultJson, -- 1694
			patch.checkpointId or 0, -- 1695
			patch.checkpointId or 0, -- 1696
			patch.checkpointSeq or 0, -- 1697
			patch.checkpointSeq or 0, -- 1698
			filesJson, -- 1699
			filesJson, -- 1700
			now(), -- 1701
			row[1] -- 1702
		} -- 1702
	) -- 1702
end -- 1702
function getNextStepNumber(sessionId, taskId) -- 1707
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1708
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1712
	return math.max(0, current) + 1 -- 1713
end -- 1713
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1754
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1762
	local t = now() -- 1763
	local sqls = { -- 1764
		{ -- 1765
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1765
			{{ -- 1768
				sessionId, -- 1769
				ownerTaskId, -- 1770
				step, -- 1771
				"sub_agent_handoff", -- 1772
				"DONE", -- 1773
				sanitizeUTF8(reason), -- 1774
				encodeJson(params), -- 1775
				encodeJson(result), -- 1776
				t, -- 1777
				t -- 1778
			}} -- 1778
		}, -- 1778
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1781
	} -- 1781
	if not DB:transaction(sqls) then -- 1781
		return nil -- 1787
	end -- 1787
	return getStepItem(sessionId, ownerTaskId, step) -- 1788
end -- 1788
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1791
	if taskId <= 0 then -- 1791
		return -- 1792
	end -- 1792
	if finalSteps ~= nil and finalSteps >= 0 then -- 1792
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1794
	end -- 1794
	if not finalStatus then -- 1794
		return -- 1800
	end -- 1800
	if finalSteps ~= nil and finalSteps >= 0 then -- 1800
		DB:exec( -- 1802
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1802
			{ -- 1806
				finalStatus, -- 1806
				now(), -- 1806
				sessionId, -- 1806
				taskId, -- 1806
				finalSteps -- 1806
			} -- 1806
		) -- 1806
		return -- 1808
	end -- 1808
	DB:exec( -- 1810
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1810
		{ -- 1814
			finalStatus, -- 1814
			now(), -- 1814
			sessionId, -- 1814
			taskId -- 1814
		} -- 1814
	) -- 1814
end -- 1814
function emitAgentSessionPatch(sessionId, patch) -- 1841
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1842
	if not text then -- 1842
		return -- 1847
	end -- 1847
	local failed = publishSessionPatch(sessionId, text) -- 1848
	if failed > 0 then -- 1848
		Log( -- 1849
			"Warn", -- 1849
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 1849
		) -- 1849
	end -- 1849
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 1849
		emit("AppWS", "Send", text) -- 1850
	end -- 1850
end -- 1850
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1853
	emitAgentSessionPatch( -- 1854
		sessionId, -- 1854
		{ -- 1854
			sessionDeleted = true, -- 1855
			relatedSessions = listRelatedSessions(rootSessionId) -- 1856
		} -- 1856
	) -- 1856
	local rootSession = getSessionItem(rootSessionId) -- 1858
	if rootSession then -- 1858
		emitAgentSessionPatch( -- 1860
			rootSessionId, -- 1860
			{ -- 1860
				session = rootSession, -- 1861
				relatedSessions = listRelatedSessions(rootSessionId) -- 1862
			} -- 1862
		) -- 1862
	end -- 1862
end -- 1862
function flushPendingSubAgentHandoffs(rootSession) -- 1867
	if rootSession.kind ~= "main" then -- 1867
		return -- 1868
	end -- 1868
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1868
		return -- 1870
	end -- 1870
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1872
	if #items == 0 then -- 1872
		return -- 1873
	end -- 1873
	local handoffTaskId = 0 -- 1874
	local previousTaskId = rootSession.currentTaskId -- 1875
	local ____rootSession_currentTaskId_39 -- 1876
	if rootSession.currentTaskId then -- 1876
		____rootSession_currentTaskId_39 = getTaskPrompt(rootSession.currentTaskId) -- 1876
	else -- 1876
		____rootSession_currentTaskId_39 = nil -- 1876
	end -- 1876
	local currentTaskPrompt = ____rootSession_currentTaskId_39 -- 1876
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1876
		handoffTaskId = rootSession.currentTaskId -- 1884
	else -- 1884
		local taskRes = Tools.createTask( -- 1886
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1886
			"code" -- 1886
		) -- 1886
		if not taskRes.success then -- 1886
			Log( -- 1888
				"Warn", -- 1888
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1888
			) -- 1888
			return -- 1889
		end -- 1889
		handoffTaskId = taskRes.taskId -- 1891
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1892
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1893
		emitAgentSessionPatch( -- 1894
			rootSession.id, -- 1894
			{session = getSessionItem(rootSession.id)} -- 1894
		) -- 1894
	end -- 1894
	do -- 1894
		local i = 0 -- 1898
		while i < #items do -- 1898
			local item = items[i + 1] -- 1899
			local step = appendHandoffSystemStep( -- 1900
				rootSession.id, -- 1901
				handoffTaskId, -- 1902
				item.sourceTaskId, -- 1903
				item.message, -- 1904
				{ -- 1905
					sourceSessionId = item.sourceSessionId, -- 1906
					sourceTitle = item.sourceTitle, -- 1907
					sourceTaskId = item.sourceTaskId, -- 1908
					success = item.success == true, -- 1909
					summary = item.message, -- 1910
					resultFilePath = item.resultFilePath or "", -- 1911
					artifactDir = item.artifactDir or "", -- 1912
					finishedAt = item.finishedAt or "", -- 1913
					changeSet = item.changeSet, -- 1914
					handoffEvidence = item.handoffEvidence, -- 1915
					memoryEntry = item.memoryEntry, -- 1916
					completion = item.completion -- 1917
				}, -- 1917
				{ -- 1919
					sourceSessionId = item.sourceSessionId, -- 1920
					sourceTitle = item.sourceTitle, -- 1921
					sourceTaskId = item.sourceTaskId, -- 1922
					prompt = item.prompt, -- 1923
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1924
					expectedOutput = item.expectedOutput or "", -- 1925
					filesHint = item.filesHint or ({}), -- 1926
					resultFilePath = item.resultFilePath or "", -- 1927
					artifactDir = item.artifactDir or "", -- 1928
					changeSet = item.changeSet, -- 1929
					handoffEvidence = item.handoffEvidence, -- 1930
					memoryEntry = item.memoryEntry, -- 1931
					completion = item.completion -- 1932
				} -- 1932
			) -- 1932
			if step then -- 1932
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1936
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1937
			else -- 1937
				Log( -- 1939
					"Warn", -- 1939
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1939
				) -- 1939
			end -- 1939
			i = i + 1 -- 1898
		end -- 1898
	end -- 1898
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1898
		cleanupTaskHeavyData(previousTaskId) -- 1943
	end -- 1943
end -- 1943
function applyEvent(sessionId, event) -- 1955
	if not getSessionItem(sessionId) then -- 1955
		streamUpdates:clear(sessionId) -- 1957
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1957
			__TS__Delete(activeStopTokens, event.taskId) -- 1959
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1960
		end -- 1960
		return -- 1962
	end -- 1962
	repeat -- 1962
		local ____switch326 = event.type -- 1962
		local metrics, startedSession -- 1962
		local ____cond326 = ____switch326 == "task_started" -- 1962
		if ____cond326 then -- 1962
			streamUpdates:clear(sessionId) -- 1966
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1967
			local ____event_resumed_42 -- 1968
			if event.resumed then -- 1968
				local ____opt_40 = getSessionItem(sessionId) -- 1968
				____event_resumed_42 = ____opt_40 and ____opt_40.metrics -- 1969
			else -- 1969
				____event_resumed_42 = clearSessionTokenUsage(sessionId) -- 1970
			end -- 1970
			metrics = ____event_resumed_42 -- 1968
			startedSession = getSessionItem(sessionId) -- 1971
			emitAgentSessionPatch( -- 1972
				sessionId, -- 1972
				{ -- 1972
					session = startedSession, -- 1973
					metrics = metrics, -- 1974
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1975
				} -- 1975
			) -- 1975
			break -- 1979
		end -- 1979
		____cond326 = ____cond326 or ____switch326 == "decision_made" -- 1979
		if ____cond326 then -- 1979
			upsertStep( -- 1981
				sessionId, -- 1981
				event.taskId, -- 1981
				event.step, -- 1981
				event.tool, -- 1981
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1981
			) -- 1981
			emitAgentSessionPatch( -- 1989
				sessionId, -- 1989
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1989
			) -- 1989
			break -- 1992
		end -- 1992
		____cond326 = ____cond326 or ____switch326 == "tool_started" -- 1992
		if ____cond326 then -- 1992
			upsertStep( -- 1994
				sessionId, -- 1994
				event.taskId, -- 1994
				event.step, -- 1994
				event.tool, -- 1994
				{status = "RUNNING"} -- 1994
			) -- 1994
			emitAgentSessionPatch( -- 1997
				sessionId, -- 1997
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1997
			) -- 1997
			break -- 2000
		end -- 2000
		____cond326 = ____cond326 or ____switch326 == "tool_finished" -- 2000
		if ____cond326 then -- 2000
			do -- 2000
				upsertStep( -- 2002
					sessionId, -- 2002
					event.taskId, -- 2002
					event.step, -- 2002
					event.tool, -- 2002
					{status = event.execution.status, reason = event.reason, result = event.result} -- 2002
				) -- 2002
				emitAgentSessionPatch( -- 2010
					sessionId, -- 2010
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2010
				) -- 2010
				break -- 2013
			end -- 2013
		end -- 2013
		____cond326 = ____cond326 or ____switch326 == "tool_progress" -- 2013
		if ____cond326 then -- 2013
			do -- 2013
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 2017
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 2017
					break -- 2019
				end -- 2019
			end -- 2019
			upsertStep( -- 2022
				sessionId, -- 2022
				event.taskId, -- 2022
				event.step, -- 2022
				event.tool, -- 2022
				{status = "RUNNING", result = event.result} -- 2022
			) -- 2022
			emitAgentSessionPatch( -- 2026
				sessionId, -- 2026
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2026
			) -- 2026
			break -- 2029
		end -- 2029
		____cond326 = ____cond326 or ____switch326 == "checkpoint_created" -- 2029
		if ____cond326 then -- 2029
			upsertStep( -- 2031
				sessionId, -- 2031
				event.taskId, -- 2031
				event.step, -- 2031
				event.tool, -- 2031
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2031
			) -- 2031
			emitAgentSessionPatch( -- 2036
				sessionId, -- 2036
				{ -- 2036
					step = getStepItem(sessionId, event.taskId, event.step), -- 2037
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2038
				} -- 2038
			) -- 2038
			break -- 2040
		end -- 2040
		____cond326 = ____cond326 or ____switch326 == "memory_compression_started" -- 2040
		if ____cond326 then -- 2040
			upsertStep( -- 2042
				sessionId, -- 2042
				event.taskId, -- 2042
				event.step, -- 2042
				event.tool, -- 2042
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2042
			) -- 2042
			emitAgentSessionPatch( -- 2047
				sessionId, -- 2047
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2047
			) -- 2047
			break -- 2050
		end -- 2050
		____cond326 = ____cond326 or ____switch326 == "memory_compression_finished" -- 2050
		if ____cond326 then -- 2050
			upsertStep( -- 2052
				sessionId, -- 2052
				event.taskId, -- 2052
				event.step, -- 2052
				event.tool, -- 2052
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2052
			) -- 2052
			emitAgentSessionPatch( -- 2057
				sessionId, -- 2057
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2057
			) -- 2057
			break -- 2060
		end -- 2060
		____cond326 = ____cond326 or ____switch326 == "metrics_updated" -- 2060
		if ____cond326 then -- 2060
			do -- 2060
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2062
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2063
				break -- 2066
			end -- 2066
		end -- 2066
		____cond326 = ____cond326 or ____switch326 == "assistant_message_updated" -- 2066
		if ____cond326 then -- 2066
			do -- 2066
				local session = getSessionItem(sessionId) -- 2069
				if (session and session.currentTaskId) ~= event.taskId then -- 2069
					streamUpdates:clear(sessionId, event.taskId) -- 2071
					break -- 2071
				end -- 2071
				streamUpdates:update( -- 2073
					sessionId, -- 2073
					event.taskId, -- 2073
					event.step, -- 2073
					event, -- 2073
					App.runningTime -- 2073
				) -- 2073
				scheduleStreamFlush() -- 2074
				break -- 2075
			end -- 2075
		end -- 2075
		____cond326 = ____cond326 or ____switch326 == "assistant_message_finished" -- 2075
		if ____cond326 then -- 2075
			do -- 2075
				local ____opt_45 = getSessionItem(sessionId) -- 2075
				if (____opt_45 and ____opt_45.currentTaskId) ~= event.taskId then -- 2075
					streamUpdates:clear(sessionId, event.taskId) -- 2079
					break -- 2079
				end -- 2079
				streamUpdates:finish(sessionId, event.taskId, event.step) -- 2081
				upsertStep( -- 2082
					sessionId, -- 2082
					event.taskId, -- 2082
					event.step, -- 2082
					"message", -- 2082
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2082
				) -- 2082
				emitAgentSessionPatch( -- 2088
					sessionId, -- 2088
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2088
				) -- 2088
				break -- 2091
			end -- 2091
		end -- 2091
		____cond326 = ____cond326 or ____switch326 == "task_waiting_for_user" -- 2091
		if ____cond326 then -- 2091
			do -- 2091
				local ____opt_47 = getSessionItem(sessionId) -- 2091
				if (____opt_47 and ____opt_47.currentTaskId) ~= event.taskId then -- 2091
					streamUpdates:clear(sessionId, event.taskId) -- 2095
					break -- 2095
				end -- 2095
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2097
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2098
				__TS__Delete(activeStopTokens, event.taskId) -- 2099
				emitAgentSessionPatch( -- 2100
					sessionId, -- 2100
					{ -- 2100
						session = getSessionItem(sessionId), -- 2101
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2102
					} -- 2102
				) -- 2102
				break -- 2104
			end -- 2104
		end -- 2104
		____cond326 = ____cond326 or ____switch326 == "task_finished" -- 2104
		if ____cond326 then -- 2104
			do -- 2104
				local session = getSessionItem(sessionId) -- 2107
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2107
					__TS__Delete(activeStopTokens, event.taskId) -- 2109
					streamUpdates:clear(sessionId, event.taskId) -- 2110
					Log( -- 2111
						"Info", -- 2111
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2111
					) -- 2111
					break -- 2112
				end -- 2112
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2114
				local ____opt_49 = activeStopTokens[event.taskId or -1] -- 2114
				local stopped = (____opt_49 and ____opt_49.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2115
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2117
				local isSubSession = (session and session.kind) == "sub" -- 2120
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2121
				if isSubSession and event.taskId ~= nil then -- 2121
					finalizingSubSessionTaskIds[event.taskId] = true -- 2123
				end -- 2123
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2125
				if event.taskId ~= nil then -- 2125
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2127
					local ____finalizeTaskSteps_55 = finalizeTaskSteps -- 2128
					local ____array_54 = __TS__SparseArrayNew( -- 2128
						sessionId, -- 2129
						event.taskId, -- 2130
						type(event.steps) == "number" and math.max( -- 2131
							0, -- 2131
							math.floor(event.steps) -- 2131
						) or nil -- 2131
					) -- 2131
					local ____event_success_53 -- 2132
					if event.success then -- 2132
						____event_success_53 = nil -- 2132
					else -- 2132
						____event_success_53 = stopped and "STOPPED" or "FAILED" -- 2132
					end -- 2132
					__TS__SparseArrayPush(____array_54, ____event_success_53) -- 2132
					____finalizeTaskSteps_55(__TS__SparseArraySpread(____array_54)) -- 2128
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2134
					if not isSubSession then -- 2134
						__TS__Delete(activeStopTokens, event.taskId) -- 2136
					end -- 2136
					emitAgentSessionPatch( -- 2138
						sessionId, -- 2138
						{ -- 2138
							session = getSessionItem(sessionId), -- 2139
							message = getMessageItem(messageId), -- 2140
							removedStepIds = removedStepIds -- 2141
						} -- 2141
					) -- 2141
				end -- 2141
				if session and session.kind == "main" then -- 2141
					flushPendingSubAgentHandoffs(session) -- 2145
				end -- 2145
				break -- 2147
			end -- 2147
		end -- 2147
	until true -- 2147
end -- 2147
function ____exports.createSession(projectRoot, title) -- 2152
	if title == nil then -- 2152
		title = "" -- 2152
	end -- 2152
	local storage = requireAgentStorage() -- 2153
	if not storage.success then -- 2153
		return storage -- 2154
	end -- 2154
	if not isValidProjectRoot(projectRoot) then -- 2154
		return {success = false, message = "invalid projectRoot"} -- 2156
	end -- 2156
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2158
	if row then -- 2158
		return { -- 2167
			success = true, -- 2167
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2167
		} -- 2167
	end -- 2167
	local t = now() -- 2169
	DB:exec( -- 2170
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2170
		{ -- 2173
			projectRoot, -- 2173
			title ~= "" and title or Path:getFilename(projectRoot), -- 2173
			t, -- 2173
			t -- 2173
		} -- 2173
	) -- 2173
	local sessionId = getLastInsertRowId() -- 2175
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2176
	local session = getSessionItem(sessionId) -- 2177
	if not session then -- 2177
		return {success = false, message = "failed to create session"} -- 2179
	end -- 2179
	return {success = true, session = session} -- 2181
end -- 2152
function ____exports.createSubSession(parentSessionId, title) -- 2184
	if title == nil then -- 2184
		title = "" -- 2184
	end -- 2184
	local storage = requireAgentStorage() -- 2185
	if not storage.success then -- 2185
		return storage -- 2186
	end -- 2186
	local parent = getSessionItem(parentSessionId) -- 2187
	if not parent then -- 2187
		return {success = false, message = "parent session not found"} -- 2189
	end -- 2189
	local rootId = getSessionRootId(parent) -- 2191
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2191
		return {success = false, message = "project task admission is closed"} -- 2192
	end -- 2192
	local t = now() -- 2193
	DB:exec( -- 2194
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2194
		{ -- 2197
			parent.projectRoot, -- 2197
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2197
			rootId, -- 2197
			parent.id, -- 2197
			t, -- 2197
			t -- 2197
		} -- 2197
	) -- 2197
	local sessionId = getLastInsertRowId() -- 2199
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2200
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2201
	local session = getSessionItem(sessionId) -- 2202
	if not session then -- 2202
		return {success = false, message = "failed to create sub session"} -- 2204
	end -- 2204
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2206
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2207
	subStorage:writeMemory(parentStorage:readMemory()) -- 2208
	return {success = true, session = session} -- 2209
end -- 2184
function spawnSubAgentSession(request) -- 2212
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2212
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2225
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2226
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2227
		if normalizedPrompt == "" then -- 2227
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2229
		end -- 2229
		if normalizedPrompt == "" then -- 2229
			local ____Log_61 = Log -- 2236
			local ____temp_58 = #normalizedTitle -- 2236
			local ____temp_59 = #rawPrompt -- 2236
			local ____temp_60 = #toStr(request.expectedOutput) -- 2236
			local ____opt_56 = request.filesHint -- 2236
			____Log_61( -- 2236
				"Warn", -- 2236
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_58)) .. " raw_prompt_len=") .. tostring(____temp_59)) .. " expected_len=") .. tostring(____temp_60)) .. " files_hint_count=") .. tostring(____opt_56 and #____opt_56 or 0) -- 2236
			) -- 2236
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2236
		end -- 2236
		Log( -- 2239
			"Info", -- 2239
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2239
		) -- 2239
		local parentSessionId = request.parentSessionId -- 2240
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2240
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2242
			if not fallbackParent then -- 2242
				local createdMain = ____exports.createSession(request.projectRoot) -- 2244
				if createdMain.success then -- 2244
					fallbackParent = createdMain.session -- 2246
				end -- 2246
			end -- 2246
			if fallbackParent then -- 2246
				Log( -- 2250
					"Warn", -- 2250
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2250
				) -- 2250
				parentSessionId = fallbackParent.id -- 2251
			end -- 2251
		end -- 2251
		local parentSession = getSessionItem(parentSessionId) -- 2254
		if not parentSession then -- 2254
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2254
		end -- 2254
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2258
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2258
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2258
		end -- 2258
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2258
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2258
		end -- 2258
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2263
		if not created.success then -- 2263
			return ____awaiter_resolve(nil, created) -- 2263
		end -- 2263
		writeSpawnInfo( -- 2267
			created.session.projectRoot, -- 2267
			created.session.memoryScope, -- 2267
			{ -- 2267
				sessionId = created.session.id, -- 2268
				rootSessionId = created.session.rootSessionId, -- 2269
				parentSessionId = created.session.parentSessionId, -- 2270
				title = created.session.title, -- 2271
				prompt = normalizedPrompt, -- 2272
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2273
				expectedOutput = request.expectedOutput or "", -- 2274
				filesHint = request.filesHint or ({}), -- 2275
				status = "RUNNING", -- 2276
				success = false, -- 2277
				resultFilePath = "", -- 2278
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2279
				sourceTaskId = 0, -- 2280
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2281
				createdAtTs = created.session.createdAt, -- 2282
				finishedAt = "", -- 2283
				finishedAtTs = 0 -- 2284
			} -- 2284
		) -- 2284
		local sent = ____exports.sendPrompt( -- 2286
			created.session.id, -- 2286
			normalizedPrompt, -- 2286
			request.disabledAgentTools, -- 2286
			nil, -- 2286
			nil, -- 2286
			request.llmConfig -- 2286
		) -- 2286
		if not sent.success then -- 2286
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2286
		end -- 2286
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2286
	end) -- 2286
end -- 2286
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2407
	local rootSession = getRootSessionItem(session.id) -- 2408
	if not rootSession then -- 2408
		return -- 2409
	end -- 2409
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2410
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2411
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2412
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2413
	local queueResult = writePendingHandoff( -- 2414
		rootSession.projectRoot, -- 2414
		rootSession.memoryScope, -- 2414
		{ -- 2414
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2415
			sourceSessionId = session.id, -- 2416
			sourceTitle = session.title, -- 2417
			sourceTaskId = taskId, -- 2418
			message = summary, -- 2419
			prompt = result.prompt, -- 2420
			goal = result.goal, -- 2421
			expectedOutput = result.expectedOutput or "", -- 2422
			filesHint = result.filesHint or ({}), -- 2423
			success = result.success, -- 2424
			resultFilePath = result.resultFilePath, -- 2425
			artifactDir = result.artifactDir, -- 2426
			finishedAt = result.finishedAt, -- 2427
			changeSet = changeSet, -- 2428
			handoffEvidence = result.handoffEvidence, -- 2429
			memoryEntry = result.memoryEntry, -- 2430
			completion = result.completion, -- 2431
			createdAt = createdAt -- 2432
		} -- 2432
	) -- 2432
	if not queueResult then -- 2432
		Log( -- 2435
			"Warn", -- 2435
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2435
		) -- 2435
		return -- 2436
	end -- 2436
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2436
		addTaskReference(rootSession.currentTaskId, taskId) -- 2439
	end -- 2439
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2439
		flushPendingSubAgentHandoffs(rootSession) -- 2442
	end -- 2442
end -- 2442
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2446
	if forceHandoff == nil then -- 2446
		forceHandoff = false -- 2452
	end -- 2452
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2452
		local rootSessionId = getSessionRootId(session) -- 2454
		local rootSession = getRootSessionItem(session.id) -- 2455
		if not rootSession then -- 2455
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2455
		end -- 2455
		local spawnInfo = getSessionSpawnInfo(session) -- 2459
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2460
		local finishedAtTs = now() -- 2461
		local resultText = sanitizeUTF8(message) -- 2462
		local changeSet = getTaskChangeSetSummary(taskId) -- 2463
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2464
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2465
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2469
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2469
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2471
		end -- 2471
		local completed = success and completionReport.outcome == "completed" -- 2479
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2480
		local record = { -- 2483
			sessionId = session.id, -- 2484
			rootSessionId = rootSessionId, -- 2485
			parentSessionId = session.parentSessionId, -- 2486
			title = session.title, -- 2487
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2488
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2489
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2490
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2491
			status = recordStatus, -- 2492
			success = completed, -- 2493
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2494
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2495
			sourceTaskId = taskId, -- 2496
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2497
			finishedAt = finishedAt, -- 2498
			createdAtTs = session.createdAt, -- 2499
			finishedAtTs = finishedAtTs, -- 2500
			changeSet = changeSet, -- 2501
			handoffEvidence = handoffEvidence, -- 2502
			completion = completionReport -- 2503
		} -- 2503
		local ____record_success_78 -- 2505
		if record.success then -- 2505
			____record_success_78 = buildStructuredSubAgentMemoryEntry(record) -- 2505
		else -- 2505
			____record_success_78 = nil -- 2505
		end -- 2505
		record.memoryEntry = ____record_success_78 -- 2505
		if not writeSubAgentResultFile(session, record, resultText) then -- 2505
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2505
		end -- 2505
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2505
			sessionId = record.sessionId, -- 2510
			rootSessionId = record.rootSessionId, -- 2511
			parentSessionId = record.parentSessionId, -- 2512
			title = record.title, -- 2513
			prompt = record.prompt, -- 2514
			goal = record.goal, -- 2515
			expectedOutput = record.expectedOutput or "", -- 2516
			filesHint = record.filesHint or ({}), -- 2517
			status = record.status, -- 2518
			success = record.success, -- 2519
			resultFilePath = record.resultFilePath, -- 2520
			artifactDir = record.artifactDir, -- 2521
			sourceTaskId = record.sourceTaskId, -- 2522
			createdAt = record.createdAt, -- 2523
			finishedAt = record.finishedAt, -- 2524
			createdAtTs = record.createdAtTs, -- 2525
			finishedAtTs = record.finishedAtTs, -- 2526
			changeSet = record.changeSet, -- 2527
			handoffEvidence = record.handoffEvidence, -- 2528
			memoryEntry = record.memoryEntry, -- 2529
			memoryEntryError = record.memoryEntryError, -- 2530
			completion = record.completion -- 2531
		}) then -- 2531
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2531
		end -- 2531
		if success or forceHandoff then -- 2531
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2536
			deleteSessionRecords(session.id, true) -- 2537
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2538
		end -- 2538
		return ____awaiter_resolve(nil, {success = true}) -- 2538
	end) -- 2538
end -- 2538
function stopClearedSubSession(session, taskId) -- 2543
	local spawnInfo = getSessionSpawnInfo(session) -- 2544
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2545
	local rootSessionId = getSessionRootId(session) -- 2546
	Tools.setTaskStatus(taskId, "STOPPED") -- 2547
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2548
	if not writeSpawnInfo( -- 2548
		session.projectRoot, -- 2549
		session.memoryScope, -- 2549
		{ -- 2549
			sessionId = session.id, -- 2550
			rootSessionId = rootSessionId, -- 2551
			parentSessionId = session.parentSessionId, -- 2552
			title = session.title, -- 2553
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2554
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2555
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2556
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2557
			status = "STOPPED", -- 2558
			success = false, -- 2559
			cleared = true, -- 2560
			resultFilePath = "", -- 2561
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2562
			sourceTaskId = taskId, -- 2563
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2564
			finishedAt = finishedAt, -- 2565
			createdAtTs = session.createdAt, -- 2566
			finishedAtTs = now() -- 2567
		} -- 2567
	) then -- 2567
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2569
	end -- 2569
	deleteSessionRecords(session.id, true) -- 2571
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2572
	return {success = true} -- 2573
end -- 2573
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps) -- 2576
	local session = getSessionItem(sessionId) -- 2577
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2577
		return {success = false, message = "project task admission is closed"} -- 2578
	end -- 2578
	if not session then -- 2578
		return {success = false, message = "session not found"} -- 2580
	end -- 2580
	if getPendingQuestionnaire(sessionId) then -- 2580
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2582
	end -- 2582
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2582
		return {success = false, message = "session task is finalizing"} -- 2584
	end -- 2584
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2584
		return {success = false, message = "session task is still running"} -- 2587
	end -- 2587
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2589
	if normalizedPrompt == "" and session.kind == "sub" then -- 2589
		local spawnInfo = getSessionSpawnInfo(session) -- 2591
		if spawnInfo then -- 2591
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2593
			if normalizedPrompt == "" then -- 2593
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2595
			end -- 2595
		end -- 2595
	end -- 2595
	if normalizedPrompt == "" then -- 2595
		return {success = false, message = "prompt is empty"} -- 2604
	end -- 2604
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2606
	if session.workMode ~= nextWorkMode then -- 2606
		DB:exec( -- 2608
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2608
			{ -- 2608
				nextWorkMode, -- 2608
				now(), -- 2608
				session.id -- 2608
			} -- 2608
		) -- 2608
		session.workMode = nextWorkMode -- 2609
	end -- 2609
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2611
	return startPromptTask( -- 2612
		session, -- 2612
		normalizedPrompt, -- 2612
		nil, -- 2612
		normalizeDisabledAgentTools(disabledAgentTools), -- 2612
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig, maxSteps = boundedMaxSteps} -- 2612
	) -- 2612
end -- 2576
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2746
	if disabledAgentTools == nil then -- 2746
		disabledAgentTools = {} -- 2750
	end -- 2750
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2753
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2753
		return {success = false, message = "project task admission is closed"} -- 2754
	end -- 2754
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2755
	if not llmConfigRes.success then -- 2755
		return {success = false, message = llmConfigRes.message} -- 2759
	end -- 2759
	local llmConfig = llmConfigRes.config -- 2761
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2762
	if not llmConfigValidation.success then -- 2762
		return llmConfigValidation -- 2764
	end -- 2764
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2766
	if not taskRes.success then -- 2766
		return {success = false, message = taskRes.message} -- 2769
	end -- 2769
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2769
		removeContinuableTaskSummary(session) -- 2771
	end -- 2771
	local taskId = taskRes.taskId -- 2773
	local ____temp_99 -- 2774
	if (options and options.existingTaskId) == nil then -- 2774
		____temp_99 = session.currentTaskId -- 2774
	else -- 2774
		____temp_99 = nil -- 2774
	end -- 2774
	local previousTaskId = ____temp_99 -- 2774
	local useChineseResponse = getDefaultUseChineseResponse() -- 2775
	local promptMessageId -- 2776
	if existingUserMessageId ~= nil then -- 2776
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2778
		promptMessageId = existingUserMessageId -- 2779
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2779
		promptMessageId = insertMessage( -- 2781
			session.id, -- 2781
			"user", -- 2781
			normalizedPrompt, -- 2781
			taskId, -- 2781
			options and options.displayContent -- 2781
		) -- 2781
	end -- 2781
	local stopToken = {stopped = false} -- 2783
	activeStopTokens[taskId] = stopToken -- 2784
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2785
	emitAgentSessionPatch( -- 2789
		session.id, -- 2789
		__TS__ObjectAssign( -- 2789
			{session = getSessionItem(session.id)}, -- 2789
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 2791
		) -- 2791
	) -- 2791
	if previousTaskId and previousTaskId ~= taskId then -- 2791
		cleanupTaskHeavyData(previousTaskId) -- 2794
	end -- 2794
	activePromptRuns = activePromptRuns + 1 -- 2796
	local ____runCodingAgent_128 = runCodingAgent -- 2797
	local ____normalizedPrompt_121 = normalizedPrompt -- 2798
	local ____temp_122 = options and options.resumeConversation -- 2799
	local ____temp_123 = (options and options.existingTaskId) ~= nil -- 2800
	local ____temp_124 = options and options.initialStep -- 2801
	local ____temp_125 = options and options.initialAgentStepCount -- 2802
	local ____temp_116 -- 2803
	if (options and options.existingTaskId) ~= nil then -- 2803
		____temp_116 = getInitialTokenUsage(session) -- 2803
	else -- 2803
		____temp_116 = nil -- 2803
	end -- 2803
	____runCodingAgent_128( -- 2797
		{ -- 2797
			prompt = ____normalizedPrompt_121, -- 2798
			resumeConversation = ____temp_122, -- 2799
			resumeTask = ____temp_123, -- 2800
			initialStep = ____temp_124, -- 2801
			initialAgentStepCount = ____temp_125, -- 2802
			initialTokenUsage = ____temp_116, -- 2803
			workDir = session.projectRoot, -- 2804
			useChineseResponse = useChineseResponse, -- 2805
			taskId = taskId, -- 2806
			sessionId = session.id, -- 2807
			memoryScope = session.memoryScope, -- 2808
			role = session.kind, -- 2809
			maxSteps = options and options.maxSteps, -- 2810
			disabledAgentTools = disabledAgentTools, -- 2811
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2812
			llmConfig = llmConfig, -- 2813
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2814
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2817
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2820
			stopToken = stopToken, -- 2821
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2822
		}, -- 2822
		function(result) -- 2823
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2823
				local ____hasReturned, ____returnValue -- 2823
				local ____try = __TS__AsyncAwaiter(function() -- 2823
					local nextSession = getSessionItem(session.id) -- 2825
					if nextSession and nextSession.kind == "sub" then -- 2825
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2825
							local stopped = stopClearedSubSession(nextSession, taskId) -- 2828
							if not stopped.success then -- 2828
								Log( -- 2830
									"Warn", -- 2830
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2830
								) -- 2830
								emitAgentSessionPatch( -- 2831
									session.id, -- 2831
									{session = getSessionItem(session.id)} -- 2831
								) -- 2831
							end -- 2831
							__TS__Delete(activeStopTokens, taskId) -- 2835
							____hasReturned = true -- 2836
							return -- 2836
						end -- 2836
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2838
						emitAgentSessionPatch( -- 2839
							session.id, -- 2839
							{session = getSessionItem(session.id)} -- 2839
						) -- 2839
						local finalized = __TS__Await(finalizeSubSession( -- 2842
							nextSession, -- 2843
							taskId, -- 2844
							result.success, -- 2845
							result.message, -- 2846
							result.completion, -- 2847
							(options and options.forceSubAgentHandoff) == true -- 2848
						)) -- 2848
						if not finalized.success then -- 2848
							Log( -- 2851
								"Warn", -- 2851
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2851
							) -- 2851
						end -- 2851
						local finalizedSession = getSessionItem(session.id) -- 2853
						if finalizedSession then -- 2853
							local stopped = stopToken.stopped == true -- 2855
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2856
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2859
							emitAgentSessionPatch( -- 2860
								session.id, -- 2860
								{session = getSessionItem(session.id)} -- 2860
							) -- 2860
						end -- 2860
						__TS__Delete(activeStopTokens, taskId) -- 2864
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2865
					end -- 2865
					local fallbackSession = getSessionItem(session.id) -- 2867
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2867
						applyEvent(session.id, { -- 2873
							type = "task_finished", -- 2874
							sessionId = session.id, -- 2875
							taskId = result.taskId, -- 2876
							success = false, -- 2877
							message = result.message, -- 2878
							steps = result.steps -- 2879
						}) -- 2879
					end -- 2879
				end) -- 2879
				____try = ____try.finally( -- 2879
					____try, -- 2879
					function() -- 2879
						return __TS__AsyncAwaiter(function() -- 2879
							activePromptRuns = activePromptRuns - 1 -- 2883
						end) -- 2883
					end -- 2883
				) -- 2883
				__TS__Await(____try) -- 2824
				if ____hasReturned then -- 2824
					return ____awaiter_resolve(nil, ____returnValue) -- 2824
				end -- 2824
			end) -- 2824
		end -- 2823
	) -- 2823
	return {success = true, sessionId = session.id, taskId = taskId} -- 2886
end -- 2886
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3039
	local lines = {} -- 3040
	do -- 3040
		local i = 0 -- 3041
		while i < #questionnaire.schema.questions do -- 3041
			local question = questionnaire.schema.questions[i + 1] -- 3042
			local answer = __TS__ArrayFind( -- 3043
				answers, -- 3043
				function(____, item) return item.questionId == question.id end -- 3043
			) -- 3043
			local answerText = "已跳过" -- 3044
			if answer and answer.status == "answered" then -- 3044
				local parts = {} -- 3046
				do -- 3046
					local j = 0 -- 3047
					while j < #(answer.selectedOptionIds or ({})) do -- 3047
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3048
						local option = __TS__ArrayFind( -- 3049
							question.options or ({}), -- 3049
							function(____, item) return item.id == optionId end -- 3049
						) -- 3049
						if option then -- 3049
							parts[#parts + 1] = option.label -- 3050
						end -- 3050
						j = j + 1 -- 3047
					end -- 3047
				end -- 3047
				if answer.otherText then -- 3047
					parts[#parts + 1] = answer.otherText -- 3052
				end -- 3052
				if answer.text then -- 3052
					parts[#parts + 1] = answer.text -- 3053
				end -- 3053
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3054
			end -- 3054
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3056
			i = i + 1 -- 3041
		end -- 3041
	end -- 3041
	return table.concat(lines, "\n\n") -- 3058
end -- 3058
function ____exports.listRunningSubAgents(request) -- 3343
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3343
		local session = getSessionItem(request.sessionId) -- 3351
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3351
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3353
		end -- 3353
		if not session then -- 3353
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3353
		end -- 3353
		local rootSession = getRootSessionItem(session.id) -- 3358
		if not rootSession then -- 3358
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3358
		end -- 3358
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3362
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3363
		local limit = math.max( -- 3364
			1, -- 3364
			math.floor(tonumber(request.limit) or 5) -- 3364
		) -- 3364
		local offset = math.max( -- 3365
			0, -- 3365
			math.floor(tonumber(request.offset) or 0) -- 3365
		) -- 3365
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3366
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3367
		local runningSessions = {} -- 3374
		do -- 3374
			local i = 0 -- 3375
			while i < #rows do -- 3375
				do -- 3375
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3376
					if current.currentTaskStatus ~= "RUNNING" then -- 3376
						goto __continue570 -- 3378
					end -- 3378
					local spawnInfo = getSessionSpawnInfo(current) -- 3380
					runningSessions[#runningSessions + 1] = { -- 3381
						sessionId = current.id, -- 3382
						title = current.title, -- 3383
						parentSessionId = current.parentSessionId, -- 3384
						rootSessionId = current.rootSessionId, -- 3385
						status = "RUNNING", -- 3386
						currentTaskId = current.currentTaskId, -- 3387
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3388
						goal = spawnInfo and spawnInfo.goal, -- 3389
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3390
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3391
						createdAt = current.createdAt, -- 3392
						updatedAt = current.updatedAt -- 3393
					} -- 3393
				end -- 3393
				::__continue570:: -- 3393
				i = i + 1 -- 3375
			end -- 3375
		end -- 3375
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3396
		local completedSessions = __TS__ArrayMap( -- 3397
			completedRecords, -- 3397
			function(____, record) return { -- 3397
				sessionId = record.sessionId, -- 3398
				title = record.title, -- 3399
				parentSessionId = record.parentSessionId, -- 3400
				rootSessionId = record.rootSessionId, -- 3401
				status = record.status, -- 3402
				goal = record.goal, -- 3403
				expectedOutput = record.expectedOutput, -- 3404
				filesHint = record.filesHint, -- 3405
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3406
				success = record.success, -- 3407
				cleared = record.cleared, -- 3408
				resultFilePath = record.resultFilePath, -- 3409
				artifactDir = record.artifactDir, -- 3410
				finishedAt = record.finishedAt, -- 3411
				createdAt = record.createdAtTs, -- 3412
				updatedAt = record.finishedAtTs -- 3413
			} end -- 3413
		) -- 3413
		local merged = {} -- 3415
		if status == "running" then -- 3415
			merged = runningSessions -- 3417
		elseif status == "done" then -- 3417
			merged = __TS__ArrayFilter( -- 3419
				completedSessions, -- 3419
				function(____, item) return item.status == "DONE" end -- 3419
			) -- 3419
		elseif status == "failed" then -- 3419
			merged = __TS__ArrayFilter( -- 3421
				completedSessions, -- 3421
				function(____, item) return item.status == "FAILED" end -- 3421
			) -- 3421
		elseif status == "stopped" then -- 3421
			merged = __TS__ArrayFilter( -- 3423
				completedSessions, -- 3423
				function(____, item) return item.status == "STOPPED" end -- 3423
			) -- 3423
		elseif status == "all" then -- 3423
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3425
		else -- 3425
			local runningKeys = {} -- 3427
			do -- 3427
				local i = 0 -- 3428
				while i < #runningSessions do -- 3428
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3429
					i = i + 1 -- 3428
				end -- 3428
			end -- 3428
			local latestCompletedByKey = {} -- 3431
			do -- 3431
				local i = 0 -- 3432
				while i < #completedSessions do -- 3432
					do -- 3432
						local item = completedSessions[i + 1] -- 3433
						local key = getSubAgentDisplayKey(item) -- 3434
						if runningKeys[key] then -- 3434
							goto __continue585 -- 3436
						end -- 3436
						local current = latestCompletedByKey[key] -- 3438
						if current == nil or item.updatedAt > current.updatedAt then -- 3438
							latestCompletedByKey[key] = item -- 3440
						end -- 3440
					end -- 3440
					::__continue585:: -- 3440
					i = i + 1 -- 3432
				end -- 3432
			end -- 3432
			local latestCompleted = {} -- 3443
			for ____, item in pairs(latestCompletedByKey) do -- 3444
				latestCompleted[#latestCompleted + 1] = item -- 3445
			end -- 3445
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3447
		end -- 3447
		if query ~= "" then -- 3447
			merged = __TS__ArrayFilter( -- 3450
				merged, -- 3450
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3450
			) -- 3450
		end -- 3450
		__TS__ArraySort( -- 3456
			merged, -- 3456
			function(____, a, b) -- 3456
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3456
					return -1 -- 3457
				end -- 3457
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3457
					return 1 -- 3458
				end -- 3458
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3458
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3460
				end -- 3460
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3462
			end -- 3456
		) -- 3456
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3464
		return ____awaiter_resolve(nil, { -- 3464
			success = true, -- 3466
			rootSessionId = rootSession.id, -- 3467
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3468
			status = status, -- 3469
			limit = limit, -- 3470
			offset = offset, -- 3471
			hasMore = offset + limit < #merged, -- 3472
			sessions = paged -- 3473
		}) -- 3473
	end) -- 3473
end -- 3343
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 277
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 278
SPAWN_INFO_FILE = "SPAWN.json" -- 279
RESULT_FILE = "RESULT.md" -- 280
PENDING_HANDOFF_DIR = "pending-handoffs" -- 281
MAX_CONCURRENT_SUB_AGENTS = 4 -- 282
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 283
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 284
activeStopTokens = {} -- 334
activeLocalAgentControls = {} -- 335
finalizingSubSessionTaskIds = {} -- 336
activePromptRuns = 0 -- 337
streamUpdates = __TS__New( -- 339
	StreamUpdates, -- 339
	function(sessionId, taskId, step, value) -- 339
		local ____opt_0 = getSessionItem(sessionId) -- 339
		if (____opt_0 and ____opt_0.currentTaskId) ~= taskId then -- 339
			return -- 340
		end -- 340
		upsertStep( -- 341
			sessionId, -- 341
			taskId, -- 341
			step, -- 341
			"message", -- 341
			{status = "RUNNING", reason = value.content, reasoningContent = value.reasoningContent} -- 341
		) -- 341
		emitAgentSessionPatch( -- 344
			sessionId, -- 344
			{step = getStepItem(sessionId, taskId, step)} -- 344
		) -- 344
	end -- 339
) -- 339
streamFlushScheduled = false -- 346
--- Runtime ownership, including asynchronous completion after task status changes.
function ____exports.isRuntimeIdle() -- 359
	return activePromptRuns == 0 and #__TS__ObjectKeys(activeStopTokens) == 0 and #__TS__ObjectKeys(activeLocalAgentControls) == 0 and #__TS__ObjectKeys(finalizingSubSessionTaskIds) == 0 -- 360
end -- 359
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 365
now = function() return os.time() end -- 366
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1015
	if projectRoot == oldRoot then -- 1015
		return newRoot -- 1017
	end -- 1017
	for ____, separator in ipairs({"/", "\\"}) do -- 1019
		local prefix = oldRoot .. separator -- 1020
		if __TS__StringStartsWith(projectRoot, prefix) then -- 1020
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 1022
		end -- 1022
	end -- 1022
	return nil -- 1025
end -- 1015
local function clearSessionAfterMessage(sessionId, message) -- 1544
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1545
	local removedStepIds = {} -- 1553
	do -- 1553
		local i = 0 -- 1554
		while i < #removedStepRows do -- 1554
			local row = removedStepRows[i + 1] -- 1555
			if type(row[1]) == "number" then -- 1555
				removedStepIds[#removedStepIds + 1] = row[1] -- 1557
			end -- 1557
			i = i + 1 -- 1554
		end -- 1554
	end -- 1554
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1560
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1568
	return removedStepIds -- 1573
end -- 1544
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1576
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1577
	local persisted = storage:readSessionState() -- 1578
	local userIndex = -1 -- 1579
	do -- 1579
		local i = #persisted.messages - 1 -- 1580
		while i >= 0 do -- 1580
			if persisted.messages[i + 1].role == "user" then -- 1580
				userIndex = i -- 1582
				break -- 1583
			end -- 1583
			i = i - 1 -- 1580
		end -- 1580
	end -- 1580
	if userIndex < 0 then -- 1580
		return -- 1586
	end -- 1586
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1587
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1588
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1589
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1594
end -- 1576
local function listCurrentTaskCheckpoints(sessionId) -- 1606
	local session = getSessionItem(sessionId) -- 1607
	local taskId = session and session.currentTaskId -- 1608
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1609
end -- 1606
local function getAgentStepCount(sessionId, taskId) -- 1716
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1717
		sessionId, -- 1722
		taskId, -- 1723
		"compress_memory", -- 1724
		"merge_memory", -- 1725
		"sub_agent_handoff", -- 1726
		"questionnaire_answer", -- 1727
		"message" -- 1728
	}) -- 1728
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1731
end -- 1716
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1734
	if status == nil then -- 1734
		status = "DONE" -- 1742
	end -- 1742
	local step = getNextStepNumber(sessionId, taskId) -- 1744
	upsertStep( -- 1745
		sessionId, -- 1745
		taskId, -- 1745
		step, -- 1745
		tool, -- 1745
		{status = status, reason = reason, params = params, result = result} -- 1745
	) -- 1745
	return getStepItem(sessionId, taskId, step) -- 1751
end -- 1734
local function sanitizeStoredSteps(sessionId) -- 1818
	DB:exec( -- 1819
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1819
		{ -- 1837
			now(), -- 1837
			sessionId -- 1837
		} -- 1837
	) -- 1837
end -- 1818
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2298
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2298
		return {success = false, message = "invalid projectRoot"} -- 2300
	end -- 2300
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2302
	for ____, row in ipairs(rows) do -- 2303
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2304
		if sessionId > 0 then -- 2304
			deleteSessionRecords(sessionId) -- 2306
		end -- 2306
	end -- 2306
	return {success = true, deleted = #rows} -- 2309
end -- 2298
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2312
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2312
		return {success = false, message = "invalid projectRoot"} -- 2314
	end -- 2314
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2316
	local renamed = 0 -- 2317
	for ____, row in ipairs(rows) do -- 2318
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2319
		local projectRoot = toStr(row[2]) -- 2320
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2321
		if sessionId > 0 and nextProjectRoot then -- 2321
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2323
			DB:exec( -- 2324
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2324
				{ -- 2326
					nextProjectRoot, -- 2326
					Path:getFilename(nextProjectRoot), -- 2326
					now(), -- 2326
					sessionId -- 2326
				} -- 2326
			) -- 2326
			renamed = renamed + 1 -- 2328
		end -- 2328
	end -- 2328
	return {success = true, renamed = renamed} -- 2331
end -- 2312
function ____exports.getSession(sessionId, view) -- 2334
	local session = getSessionItem(sessionId) -- 2335
	if not session then -- 2335
		return {success = false, message = "session not found"} -- 2337
	end -- 2337
	local restored = restorePendingQuestionnaireState(session) -- 2339
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2340
	local relatedSessions = listRelatedSessions(sessionId) -- 2341
	sanitizeStoredSteps(sessionId) -- 2342
	local firstMessageId = 0 -- 2343
	local hasEarlierMessages = false -- 2344
	if view then -- 2344
		local limit = math.max( -- 2346
			1, -- 2346
			math.min( -- 2346
				1000, -- 2346
				math.floor(view.recentRounds) -- 2346
			) -- 2346
		) -- 2346
		local requests = queryRows(("SELECT id FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND role = 'user'\n\t\t\tORDER BY id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2347
		if #requests > limit then -- 2347
			firstMessageId = requests[limit][1] -- 2352
			hasEarlierMessages = true -- 2353
		end -- 2353
	end -- 2353
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2356
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2363
	local ____relatedSessions_67 = relatedSessions -- 2375
	local ____temp_66 -- 2376
	if normalizedSession.kind == "sub" then -- 2376
		____temp_66 = getSessionSpawnInfo(normalizedSession) -- 2376
	else -- 2376
		____temp_66 = nil -- 2376
	end -- 2376
	return { -- 2372
		success = true, -- 2373
		session = normalizedSession, -- 2374
		relatedSessions = ____relatedSessions_67, -- 2375
		spawnInfo = ____temp_66, -- 2376
		messages = __TS__ArrayMap( -- 2377
			messages, -- 2377
			function(____, row) return rowToMessage(row) end -- 2377
		), -- 2377
		hasEarlierMessages = hasEarlierMessages, -- 2378
		steps = __TS__ArrayMap( -- 2379
			steps, -- 2379
			function(____, row) return rowToStep(row) end -- 2379
		), -- 2379
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2380
		pendingQuestionnaire = restored.questionnaire, -- 2381
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2382
	} -- 2382
end -- 2334
function ____exports.setWorkMode(sessionId, workMode) -- 2387
	local session = getSessionItem(sessionId) -- 2388
	if not session then -- 2388
		return {success = false, message = "session not found"} -- 2389
	end -- 2389
	if session.kind ~= "main" then -- 2389
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2390
	end -- 2390
	if workMode ~= "code" and workMode ~= "plan" then -- 2390
		return {success = false, message = "invalid work mode"} -- 2391
	end -- 2391
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2392
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2392
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2394
	end -- 2394
	if getPendingQuestionnaire(sessionId) then -- 2394
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2397
	end -- 2397
	if normalizedSession.workMode ~= workMode then -- 2397
		DB:exec( -- 2400
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2400
			{ -- 2400
				workMode, -- 2400
				now(), -- 2400
				sessionId -- 2400
			} -- 2400
		) -- 2400
	end -- 2400
	local updated = getSessionItem(sessionId) -- 2402
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2403
	return { -- 2404
		success = true, -- 2404
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2404
	} -- 2404
end -- 2387
function ____exports.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 2615
	local session = getSessionItem(sessionId) -- 2616
	if not session then -- 2616
		return {success = false, message = "session not found"} -- 2617
	end -- 2617
	if session.kind ~= "main" then -- 2617
		return {success = false, message = "local Agent only supports main sessions"} -- 2618
	end -- 2618
	if getPendingQuestionnaire(sessionId) then -- 2618
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2619
	end -- 2619
	if session.currentTaskStatus == "RUNNING" then -- 2619
		return {success = false, message = "session task is still running"} -- 2620
	end -- 2620
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2621
	if normalizedPrompt == "" then -- 2621
		return {success = false, message = "prompt is empty"} -- 2622
	end -- 2622
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2623
	if not config then -- 2623
		return {success = false, message = "local Agent config not found"} -- 2624
	end -- 2624
	if not config.verifiedAt then -- 2624
		return {success = false, message = "local Agent config is not verified"} -- 2625
	end -- 2625
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2626
	if not taskRes.success then -- 2626
		return taskRes -- 2627
	end -- 2627
	local taskId = taskRes.taskId -- 2628
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2629
	Tools.setTaskStatus(taskId, "RUNNING") -- 2630
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2631
	upsertStep( -- 2632
		session.id, -- 2632
		taskId, -- 2632
		1, -- 2632
		"local_agent_message", -- 2632
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2632
	) -- 2632
	emitAgentSessionPatch( -- 2638
		session.id, -- 2638
		{ -- 2638
			session = getSessionItem(session.id), -- 2639
			message = getMessageItem(messageId), -- 2640
			step = getStepItem(session.id, taskId, 1) -- 2641
		} -- 2641
	) -- 2641
	local events = {} -- 2643
	local transcript = "" -- 2644
	local assistant = "" -- 2645
	local lastFlush = 0 -- 2646
	local function flush(force) -- 2647
		if force == nil then -- 2647
			force = false -- 2647
		end -- 2647
		if not force and App.runningTime - lastFlush < 0.075 then -- 2647
			return -- 2648
		end -- 2648
		lastFlush = App.runningTime -- 2649
		if #events > 400 then -- 2649
			events = __TS__ArraySlice(events, #events - 400) -- 2650
		end -- 2650
		if #transcript > 1024 * 1024 then -- 2650
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2651
		end -- 2651
		upsertStep( -- 2652
			session.id, -- 2652
			taskId, -- 2652
			1, -- 2652
			"local_agent_message", -- 2652
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2652
		) -- 2652
		local message -- 2657
		if assistant ~= "" then -- 2657
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2659
			message = getMessageItem(assistantId) -- 2660
		end -- 2660
		emitAgentSessionPatch( -- 2662
			session.id, -- 2662
			__TS__ObjectAssign( -- 2662
				{step = getStepItem(session.id, taskId, 1)}, -- 2662
				message and ({message = message}) or ({}) -- 2662
			) -- 2662
		) -- 2662
	end -- 2647
	local completedSynchronously = false -- 2664
	local control = LocalAgent.run( -- 2665
		session.id, -- 2665
		config, -- 2665
		session.projectRoot, -- 2665
		normalizedPrompt, -- 2665
		function(event) -- 2665
			local text = sanitizeUTF8(event.text) -- 2666
			if text == "" then -- 2666
				return -- 2667
			end -- 2667
			local previous = #events > 0 and events[#events] or nil -- 2668
			if previous and previous.kind == event.kind and previous.text == text then -- 2668
				return -- 2669
			end -- 2669
			events[#events + 1] = {kind = event.kind, text = text} -- 2670
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2671
			if event.kind == "assistant" then -- 2671
				assistant = text -- 2672
			end -- 2672
			flush(false) -- 2673
		end, -- 2665
		function(result) -- 2674
			completedSynchronously = true -- 2675
			flush(true) -- 2676
			__TS__Delete(activeLocalAgentControls, taskId) -- 2677
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2678
			Tools.setTaskStatus(taskId, status) -- 2679
			setSessionState(session.id, status, taskId, status) -- 2680
			upsertStep( -- 2681
				session.id, -- 2681
				taskId, -- 2681
				1, -- 2681
				"local_agent_message", -- 2681
				{status = status, reason = config.name .. " · full permissions", result = { -- 2681
					provider = config.provider, -- 2684
					events = events, -- 2684
					transcript = transcript, -- 2684
					exitCode = result.exitCode, -- 2684
					resumeId = result.resumeId, -- 2684
					message = result.message -- 2684
				}} -- 2684
			) -- 2684
			emitAgentSessionPatch( -- 2686
				session.id, -- 2686
				{ -- 2686
					session = getSessionItem(session.id), -- 2686
					step = getStepItem(session.id, taskId, 1) -- 2686
				} -- 2686
			) -- 2686
		end -- 2674
	) -- 2674
	if not completedSynchronously then -- 2674
		activeLocalAgentControls[taskId] = control -- 2688
	end -- 2688
	return {success = true, sessionId = session.id, taskId = taskId} -- 2689
end -- 2615
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2692
	local session = getSessionItem(sessionId) -- 2693
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2693
		return {success = false, message = "project task admission is closed"} -- 2694
	end -- 2694
	if not session then -- 2694
		return {success = false, message = "session not found"} -- 2696
	end -- 2696
	if getPendingQuestionnaire(sessionId) then -- 2696
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2698
	end -- 2698
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2698
		return {success = false, message = "session task is finalizing"} -- 2700
	end -- 2700
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2700
		return {success = false, message = "session task is still stopping"} -- 2703
	end -- 2703
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2703
		return {success = false, message = "session task is not continuable"} -- 2706
	end -- 2706
	if session.currentTaskId == nil then -- 2706
		return {success = false, message = "session task not found"} -- 2709
	end -- 2709
	local taskId = session.currentTaskId -- 2711
	return startPromptTask( -- 2712
		session, -- 2713
		"", -- 2714
		nil, -- 2715
		normalizeDisabledAgentTools(disabledAgentTools), -- 2716
		{ -- 2717
			workMode = session.workMode, -- 2718
			persistUserMessage = false, -- 2719
			resumeConversation = true, -- 2720
			existingTaskId = taskId, -- 2721
			initialStep = math.max( -- 2722
				0, -- 2722
				getNextStepNumber(session.id, taskId) - 1 -- 2722
			), -- 2722
			initialAgentStepCount = 0, -- 2726
			llmConfigId = llmConfigId -- 2727
		} -- 2727
	) -- 2727
end -- 2692
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2889
	local session = getSessionItem(sessionId) -- 2890
	if not session then -- 2890
		return {success = false, message = "session not found"} -- 2892
	end -- 2892
	if session.kind ~= "sub" then -- 2892
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2895
	end -- 2895
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2895
		return {success = false, message = "session task is finalizing"} -- 2898
	end -- 2898
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2900
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2900
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2905
	end -- 2905
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2905
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2908
	end -- 2908
	local disabledAgentTools = __TS__ArrayFilter( -- 2910
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2910
		function(____, tool) return tool ~= "finish" end -- 2911
	) -- 2911
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2912
	return startPromptTask( -- 2915
		session, -- 2915
		prompt, -- 2915
		nil, -- 2915
		disabledAgentTools, -- 2915
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2915
	) -- 2915
end -- 2889
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2922
	local session = getSessionItem(sessionId) -- 2923
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2923
		return {success = false, message = "project task admission is closed"} -- 2924
	end -- 2924
	if not session then -- 2924
		return {success = false, message = "session not found"} -- 2926
	end -- 2926
	if getPendingQuestionnaire(sessionId) then -- 2926
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2928
	end -- 2928
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2928
		return {success = false, message = "session task is finalizing"} -- 2930
	end -- 2930
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2930
		return {success = false, message = "session task is still running"} -- 2933
	end -- 2933
	local message = getMessageItem(messageId) -- 2935
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2935
		return {success = false, message = "message not found"} -- 2937
	end -- 2937
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2939
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2945
	if latestUserMessageId ~= messageId then -- 2945
		return {success = false, message = "only the latest user prompt can be edited"} -- 2947
	end -- 2947
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2949
	if normalizedPrompt == "" then -- 2949
		return {success = false, message = "prompt is empty"} -- 2951
	end -- 2951
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2953
	if session.workMode ~= nextWorkMode then -- 2953
		DB:exec( -- 2955
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2955
			{ -- 2955
				nextWorkMode, -- 2955
				now(), -- 2955
				session.id -- 2955
			} -- 2955
		) -- 2955
		session.workMode = nextWorkMode -- 2956
	end -- 2956
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2958
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2959
	local result = startPromptTask( -- 2960
		session, -- 2960
		normalizedPrompt, -- 2960
		messageId, -- 2960
		normalizeDisabledAgentTools(disabledAgentTools), -- 2960
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2960
	) -- 2960
	if result.success and #removedStepIds > 0 then -- 2960
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2962
	end -- 2962
	return result -- 2964
end -- 2922
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2969
	if status == "dismissed" then -- 2969
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2975
	end -- 2975
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2977
end -- 2969
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2980
	if status == "dismissed" then -- 2980
		return { -- 2986
			success = true, -- 2987
			status = "dismissed", -- 2988
			source = "user", -- 2989
			questionnaireId = questionnaire.id, -- 2990
			title = questionnaire.schema.title, -- 2991
			answers = {}, -- 2992
			responses = {}, -- 2993
			displayText = "用户关闭了调查问卷，未作答。", -- 2994
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2995
		} -- 2995
	end -- 2995
	local responses = {} -- 2998
	do -- 2998
		local i = 0 -- 2999
		while i < #questionnaire.schema.questions do -- 2999
			do -- 2999
				local question = questionnaire.schema.questions[i + 1] -- 3000
				local answer = __TS__ArrayFind( -- 3001
					answers, -- 3001
					function(____, item) return item.questionId == question.id end -- 3001
				) -- 3001
				if not answer or answer.status == "skipped" then -- 3001
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 3003
					goto __continue482 -- 3008
				end -- 3008
				local selectedOptionLabels = {} -- 3010
				do -- 3010
					local j = 0 -- 3011
					while j < #(answer.selectedOptionIds or ({})) do -- 3011
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3012
						local option = __TS__ArrayFind( -- 3013
							question.options or ({}), -- 3013
							function(____, item) return item.id == optionId end -- 3013
						) -- 3013
						if option then -- 3013
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 3014
						end -- 3014
						j = j + 1 -- 3011
					end -- 3011
				end -- 3011
				responses[#responses + 1] = { -- 3016
					questionId = question.id, -- 3017
					prompt = question.prompt, -- 3018
					status = "answered", -- 3019
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 3020
					selectedOptionLabels = selectedOptionLabels, -- 3021
					otherText = answer.otherText, -- 3022
					text = answer.text -- 3023
				} -- 3023
			end -- 3023
			::__continue482:: -- 3023
			i = i + 1 -- 2999
		end -- 2999
	end -- 2999
	return { -- 3026
		success = true, -- 3027
		status = "answered", -- 3028
		source = "user", -- 3029
		questionnaireId = questionnaire.id, -- 3030
		title = questionnaire.schema.title, -- 3031
		answers = answers, -- 3032
		responses = responses, -- 3033
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3034
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3035
	} -- 3035
end -- 2980
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3061
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3067
	local persisted = storage:readSessionState() -- 3068
	local messages = __TS__ArraySlice(persisted.messages) -- 3069
	local toolResultIndex = -1 -- 3070
	local existingResult -- 3071
	do -- 3071
		local i = #messages - 1 -- 3072
		while i >= 0 do -- 3072
			do -- 3072
				local message = messages[i + 1] -- 3073
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3073
					goto __continue502 -- 3074
				end -- 3074
				local decoded = safeJsonDecode(message.content) -- 3075
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3075
					goto __continue502 -- 3076
				end -- 3076
				local row = decoded -- 3077
				if row.questionnaireId ~= questionnaire.id then -- 3077
					goto __continue502 -- 3078
				end -- 3078
				toolResultIndex = i -- 3079
				existingResult = row -- 3080
				break -- 3081
			end -- 3081
			::__continue502:: -- 3081
			i = i - 1 -- 3072
		end -- 3072
	end -- 3072
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3083
	local guidance = {} -- 3084
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3084
		guidance[#guidance + 1] = existingResult.guidance -- 3086
	end -- 3086
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3086
		guidance[#guidance + 1] = result.guidance -- 3089
	end -- 3089
	result.guidance = table.concat(guidance, "\n") -- 3091
	if toolResultIndex < 0 then -- 3091
		messages[#messages + 1] = { -- 3093
			role = "user", -- 3094
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3095
		} -- 3095
		toolResultIndex = #messages - 1 -- 3097
	else -- 3097
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3099
			{}, -- 3099
			messages[toolResultIndex + 1], -- 3100
			{content = encodeJson(result)} -- 3099
		) -- 3099
	end -- 3099
	local pairStartIndex = toolResultIndex -- 3105
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3106
	if toolCallId and toolCallId ~= "" then -- 3106
		do -- 3106
			local i = toolResultIndex - 1 -- 3108
			while i >= 0 do -- 3108
				do -- 3108
					local message = messages[i + 1] -- 3109
					if message.role ~= "assistant" or not message.tool_calls then -- 3109
						goto __continue512 -- 3110
					end -- 3110
					if __TS__ArraySome( -- 3110
						message.tool_calls, -- 3111
						function(____, call) return call.id == toolCallId end -- 3111
					) then -- 3111
						pairStartIndex = i -- 3112
						break -- 3113
					end -- 3113
				end -- 3113
				::__continue512:: -- 3113
				i = i - 1 -- 3108
			end -- 3108
		end -- 3108
	end -- 3108
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3117
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3120
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3124
	upsertStep( -- 3126
		session.id, -- 3126
		questionnaire.taskId, -- 3126
		questionnaire.step, -- 3126
		"ask_user", -- 3126
		{status = "DONE", result = result} -- 3126
	) -- 3126
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3130
	upsertStep( -- 3131
		session.id, -- 3131
		questionnaire.taskId, -- 3131
		answerStep, -- 3131
		"questionnaire_answer", -- 3131
		{status = "DONE", result = result} -- 3131
	) -- 3131
	return {success = true, answerStep = answerStep, result = result} -- 3135
end -- 3061
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3138
	local session = getSessionItem(sessionId) -- 3139
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3139
		return {success = false, message = "project task admission is closed"} -- 3140
	end -- 3140
	if not session then -- 3140
		return {success = false, message = "session not found"} -- 3141
	end -- 3141
	if session.kind ~= "main" then -- 3141
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3142
	end -- 3142
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3143
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3143
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3145
	end -- 3145
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3147
	if not llmConfigRes.success then -- 3147
		return {success = false, message = llmConfigRes.message} -- 3148
	end -- 3148
	if not removePendingQuestionnaire(session) then -- 3148
		return {success = false, message = "failed to consume questionnaire file"} -- 3149
	end -- 3149
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3150
	if not replaced.success then -- 3150
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3152
		return replaced -- 3153
	end -- 3153
	local t = now() -- 3155
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3156
	session.workMode = "plan" -- 3157
	local result = startPromptTask( -- 3158
		session, -- 3158
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3158
		nil, -- 3158
		{}, -- 3158
		{ -- 3158
			workMode = "plan", -- 3159
			persistUserMessage = false, -- 3160
			resumeConversation = true, -- 3161
			existingTaskId = questionnaire.taskId, -- 3162
			initialStep = replaced.answerStep, -- 3163
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3164
			llmConfig = llmConfigRes.config -- 3165
		} -- 3165
	) -- 3165
	if not result.success then -- 3165
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3168
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3169
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3170
		emitAgentSessionPatch( -- 3171
			session.id, -- 3171
			{ -- 3171
				session = getSessionItem(session.id), -- 3172
				pendingQuestionnaire = questionnaire -- 3173
			} -- 3173
		) -- 3173
		return result -- 3175
	end -- 3175
	emitAgentSessionPatch( -- 3177
		sessionId, -- 3177
		{ -- 3177
			session = getSessionItem(sessionId), -- 3178
			pendingQuestionnaire = false -- 3179
		} -- 3179
	) -- 3179
	return result -- 3181
end -- 3138
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3184
	local session = getSessionItem(sessionId) -- 3185
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3185
		return {success = false, message = "project task admission is closed"} -- 3186
	end -- 3186
	if not session then -- 3186
		return {success = false, message = "session not found"} -- 3187
	end -- 3187
	if session.kind ~= "main" then -- 3187
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3188
	end -- 3188
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3189
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3189
		return {success = false, message = "pending questionnaire not found"} -- 3190
	end -- 3190
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3191
	if not validated.success then -- 3191
		return validated -- 3192
	end -- 3192
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3193
	if not llmConfigRes.success then -- 3193
		return {success = false, message = llmConfigRes.message} -- 3194
	end -- 3194
	local t = now() -- 3195
	if not removePendingQuestionnaire(session) then -- 3195
		return {success = false, message = "failed to consume questionnaire file"} -- 3196
	end -- 3196
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3197
	if not replaced.success then -- 3197
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3199
		return replaced -- 3200
	end -- 3200
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3202
	session.workMode = "plan" -- 3203
	local result = startPromptTask( -- 3204
		session, -- 3204
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3204
		nil, -- 3204
		{}, -- 3204
		{ -- 3204
			workMode = "plan", -- 3205
			persistUserMessage = false, -- 3206
			resumeConversation = true, -- 3207
			existingTaskId = questionnaire.taskId, -- 3208
			initialStep = replaced.answerStep, -- 3209
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3210
			llmConfig = llmConfigRes.config -- 3211
		} -- 3211
	) -- 3211
	if not result.success then -- 3211
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3214
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3215
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3216
		emitAgentSessionPatch( -- 3217
			session.id, -- 3217
			{ -- 3217
				session = getSessionItem(session.id), -- 3218
				pendingQuestionnaire = questionnaire -- 3219
			} -- 3219
		) -- 3219
		return result -- 3221
	end -- 3221
	emitAgentSessionPatch( -- 3223
		sessionId, -- 3223
		{ -- 3223
			session = getSessionItem(sessionId), -- 3224
			pendingQuestionnaire = false -- 3225
		} -- 3225
	) -- 3225
	return result -- 3227
end -- 3184
function ____exports.stopSessionTask(sessionId) -- 3230
	local session = getSessionItem(sessionId) -- 3231
	if not session or session.currentTaskId == nil then -- 3231
		return {success = false, message = "session task not found"} -- 3233
	end -- 3233
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3233
		return {success = false, message = "session task is finalizing"} -- 3236
	end -- 3236
	streamUpdates:clear(sessionId, session.currentTaskId, App.runningTime) -- 3238
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3239
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3240
	if localControl ~= nil then -- 3240
		localControl:stop() -- 3242
		return {success = true, stopping = true} -- 3243
	end -- 3243
	local stopToken = activeStopTokens[session.currentTaskId] -- 3245
	if stopToken == nil then -- 3245
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3245
			return {success = true, recovered = true} -- 3248
		end -- 3248
		return {success = false, message = "task is not running"} -- 3250
	end -- 3250
	if stopToken.stopped then -- 3250
		return {success = true, stopping = true} -- 3253
	end -- 3253
	stopToken.stopped = true -- 3255
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3256
	return {success = true, stopping = true} -- 3260
end -- 3230
function ____exports.getCurrentTaskId(sessionId) -- 3263
	local ____opt_131 = getSessionItem(sessionId) -- 3263
	return ____opt_131 and ____opt_131.currentTaskId -- 3264
end -- 3263
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3268
	local owner = getSessionItem(sessionId) -- 3269
	if not owner then -- 3269
		return {success = false, message = "session not found"} -- 3270
	end -- 3270
	local projectRoot = owner.projectRoot -- 3271
	local release = holdProjectTaskAdmission(projectRoot) -- 3272
	local closed = false -- 3273
	return { -- 3274
		success = true, -- 3275
		projectRoot = projectRoot, -- 3276
		close = function() -- 3277
			if not closed then -- 3277
				closed = true -- 3277
				release() -- 3277
			end -- 3277
		end, -- 3277
		poll = function() -- 3278
			if closed then -- 3278
				return {success = false, message = "quiescence handle closed"} -- 3279
			end -- 3279
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3280
			if not rows then -- 3280
				return {success = false, message = "failed to inspect project tasks"} -- 3281
			end -- 3281
			local pending = {} -- 3282
			for ____, row in ipairs(rows) do -- 3283
				do -- 3283
					local session = rowToSession(row) -- 3284
					local taskId = session.currentTaskId -- 3285
					if taskId == nil then -- 3285
						goto __continue550 -- 3286
					end -- 3286
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3287
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3287
						goto __continue550 -- 3288
					end -- 3288
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3290
					local ____session_id_134 = session.id -- 3291
					local ____taskId_135 = taskId -- 3291
					local ____finalizing_136 = finalizing -- 3291
					local ____result_success_137 = result.success -- 3291
					local ____result_success_133 -- 3291
					if result.success then -- 3291
						____result_success_133 = nil -- 3291
					else -- 3291
						____result_success_133 = result.message -- 3291
					end -- 3291
					pending[#pending + 1] = { -- 3291
						sessionId = ____session_id_134, -- 3291
						taskId = ____taskId_135, -- 3291
						finalizing = ____finalizing_136, -- 3291
						stopRequested = ____result_success_137, -- 3291
						message = ____result_success_133 -- 3291
					} -- 3291
				end -- 3291
				::__continue550:: -- 3291
			end -- 3291
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3295
		end -- 3278
	} -- 3278
end -- 3268
function ____exports.validateTaskAccess(sessionId, taskId) -- 3300
	local session = getSessionItem(sessionId) -- 3301
	if not session then -- 3301
		return {success = false, message = "session not found"} -- 3302
	end -- 3302
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3302
		getSessionOperableTaskIds(sessionId), -- 3303
		taskId -- 3303
	) < 0 then -- 3303
		return {success = false, message = "task is not operable for this session"} -- 3304
	end -- 3304
	return {success = true, session = session} -- 3306
end -- 3300
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3309
	if checkpointId <= 0 then -- 3309
		return {success = false, message = "invalid checkpointId"} -- 3311
	end -- 3311
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3313
	if not checkpoint then -- 3313
		return {success = false, message = "checkpoint not found"} -- 3315
	end -- 3315
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3317
	if not taskAccess.success then -- 3317
		return taskAccess -- 3318
	end -- 3318
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3319
end -- 3309
function ____exports.listRunningSessions() -- 3322
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3323
	local sessions = {} -- 3330
	do -- 3330
		local i = 0 -- 3331
		while i < #rows do -- 3331
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3332
			if session.currentTaskStatus == "RUNNING" then -- 3332
				sessions[#sessions + 1] = session -- 3334
			end -- 3334
			i = i + 1 -- 3331
		end -- 3331
	end -- 3331
	return {success = true, sessions = sessions} -- 3337
end -- 3322
return ____exports -- 3322