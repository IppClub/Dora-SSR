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
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1380
	if #pendingToolRows > 0 then -- 1380
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
		local ____completion_71 = completion -- 2466
		if ____completion_71 == nil then -- 2466
			local ____normalizeAgentCompletionReport_70 = normalizeAgentCompletionReport -- 2466
			local ____opt_68 = handoffEvidence.lastBuild -- 2466
			____completion_71 = ____normalizeAgentCompletionReport_70({outcome = (____opt_68 and ____opt_68.result) == "passed" and "completed" or "partial", knownIssues = {}}) -- 2466
		end -- 2466
		local completionReport = ____completion_71 -- 2466
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2470
		if not success and completionReport.outcome == "completed" and not forceHandoff then -- 2470
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "blocked", knownIssues = {resultText ~= "" and resultText or "The sub-agent did not complete."}})) -- 2472
		end -- 2472
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2472
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2479
		end -- 2479
		local completed = success and completionReport.outcome == "completed" -- 2487
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2488
		local record = { -- 2491
			sessionId = session.id, -- 2492
			rootSessionId = rootSessionId, -- 2493
			parentSessionId = session.parentSessionId, -- 2494
			title = session.title, -- 2495
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2496
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2497
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2498
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2499
			status = recordStatus, -- 2500
			success = completed, -- 2501
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2502
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2503
			sourceTaskId = taskId, -- 2504
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2505
			finishedAt = finishedAt, -- 2506
			createdAtTs = session.createdAt, -- 2507
			finishedAtTs = finishedAtTs, -- 2508
			changeSet = changeSet, -- 2509
			handoffEvidence = handoffEvidence, -- 2510
			completion = completionReport -- 2511
		} -- 2511
		local ____record_success_82 -- 2513
		if record.success then -- 2513
			____record_success_82 = buildStructuredSubAgentMemoryEntry(record) -- 2513
		else -- 2513
			____record_success_82 = nil -- 2513
		end -- 2513
		record.memoryEntry = ____record_success_82 -- 2513
		if not writeSubAgentResultFile(session, record, resultText) then -- 2513
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2513
		end -- 2513
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2513
			sessionId = record.sessionId, -- 2518
			rootSessionId = record.rootSessionId, -- 2519
			parentSessionId = record.parentSessionId, -- 2520
			title = record.title, -- 2521
			prompt = record.prompt, -- 2522
			goal = record.goal, -- 2523
			expectedOutput = record.expectedOutput or "", -- 2524
			filesHint = record.filesHint or ({}), -- 2525
			status = record.status, -- 2526
			success = record.success, -- 2527
			resultFilePath = record.resultFilePath, -- 2528
			artifactDir = record.artifactDir, -- 2529
			sourceTaskId = record.sourceTaskId, -- 2530
			createdAt = record.createdAt, -- 2531
			finishedAt = record.finishedAt, -- 2532
			createdAtTs = record.createdAtTs, -- 2533
			finishedAtTs = record.finishedAtTs, -- 2534
			changeSet = record.changeSet, -- 2535
			handoffEvidence = record.handoffEvidence, -- 2536
			memoryEntry = record.memoryEntry, -- 2537
			memoryEntryError = record.memoryEntryError, -- 2538
			completion = record.completion -- 2539
		}) then -- 2539
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2539
		end -- 2539
		if success or forceHandoff then -- 2539
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2544
			deleteSessionRecords(session.id, true) -- 2545
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2546
		end -- 2546
		return ____awaiter_resolve(nil, {success = true}) -- 2546
	end) -- 2546
end -- 2546
function stopClearedSubSession(session, taskId) -- 2551
	local spawnInfo = getSessionSpawnInfo(session) -- 2552
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2553
	local rootSessionId = getSessionRootId(session) -- 2554
	Tools.setTaskStatus(taskId, "STOPPED") -- 2555
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2556
	if not writeSpawnInfo( -- 2556
		session.projectRoot, -- 2557
		session.memoryScope, -- 2557
		{ -- 2557
			sessionId = session.id, -- 2558
			rootSessionId = rootSessionId, -- 2559
			parentSessionId = session.parentSessionId, -- 2560
			title = session.title, -- 2561
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2562
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2563
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2564
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2565
			status = "STOPPED", -- 2566
			success = false, -- 2567
			cleared = true, -- 2568
			resultFilePath = "", -- 2569
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2570
			sourceTaskId = taskId, -- 2571
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2572
			finishedAt = finishedAt, -- 2573
			createdAtTs = session.createdAt, -- 2574
			finishedAtTs = now() -- 2575
		} -- 2575
	) then -- 2575
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2577
	end -- 2577
	deleteSessionRecords(session.id, true) -- 2579
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2580
	return {success = true} -- 2581
end -- 2581
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps) -- 2584
	local session = getSessionItem(sessionId) -- 2585
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2585
		return {success = false, message = "project task admission is closed"} -- 2586
	end -- 2586
	if not session then -- 2586
		return {success = false, message = "session not found"} -- 2588
	end -- 2588
	if getPendingQuestionnaire(sessionId) then -- 2588
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2590
	end -- 2590
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2590
		return {success = false, message = "session task is finalizing"} -- 2592
	end -- 2592
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2592
		return {success = false, message = "session task is still running"} -- 2595
	end -- 2595
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2597
	if normalizedPrompt == "" and session.kind == "sub" then -- 2597
		local spawnInfo = getSessionSpawnInfo(session) -- 2599
		if spawnInfo then -- 2599
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2601
			if normalizedPrompt == "" then -- 2601
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2603
			end -- 2603
		end -- 2603
	end -- 2603
	if normalizedPrompt == "" then -- 2603
		return {success = false, message = "prompt is empty"} -- 2612
	end -- 2612
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2614
	if session.workMode ~= nextWorkMode then -- 2614
		DB:exec( -- 2616
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2616
			{ -- 2616
				nextWorkMode, -- 2616
				now(), -- 2616
				session.id -- 2616
			} -- 2616
		) -- 2616
		session.workMode = nextWorkMode -- 2617
	end -- 2617
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2619
	return startPromptTask( -- 2620
		session, -- 2620
		normalizedPrompt, -- 2620
		nil, -- 2620
		normalizeDisabledAgentTools(disabledAgentTools), -- 2620
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig, maxSteps = boundedMaxSteps} -- 2620
	) -- 2620
end -- 2584
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2754
	if disabledAgentTools == nil then -- 2754
		disabledAgentTools = {} -- 2758
	end -- 2758
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2761
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2761
		return {success = false, message = "project task admission is closed"} -- 2762
	end -- 2762
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2763
	if not llmConfigRes.success then -- 2763
		return {success = false, message = llmConfigRes.message} -- 2767
	end -- 2767
	local llmConfig = llmConfigRes.config -- 2769
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2770
	if not llmConfigValidation.success then -- 2770
		return llmConfigValidation -- 2772
	end -- 2772
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2774
	if not taskRes.success then -- 2774
		return {success = false, message = taskRes.message} -- 2777
	end -- 2777
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2777
		removeContinuableTaskSummary(session) -- 2779
	end -- 2779
	local taskId = taskRes.taskId -- 2781
	local ____temp_103 -- 2782
	if (options and options.existingTaskId) == nil then -- 2782
		____temp_103 = session.currentTaskId -- 2782
	else -- 2782
		____temp_103 = nil -- 2782
	end -- 2782
	local previousTaskId = ____temp_103 -- 2782
	local useChineseResponse = getDefaultUseChineseResponse() -- 2783
	local promptMessageId -- 2784
	if existingUserMessageId ~= nil then -- 2784
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2786
		promptMessageId = existingUserMessageId -- 2787
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2787
		promptMessageId = insertMessage( -- 2789
			session.id, -- 2789
			"user", -- 2789
			normalizedPrompt, -- 2789
			taskId, -- 2789
			options and options.displayContent -- 2789
		) -- 2789
	end -- 2789
	local stopToken = {stopped = false} -- 2791
	activeStopTokens[taskId] = stopToken -- 2792
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2793
	emitAgentSessionPatch( -- 2797
		session.id, -- 2797
		__TS__ObjectAssign( -- 2797
			{session = getSessionItem(session.id)}, -- 2797
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 2799
		) -- 2799
	) -- 2799
	if previousTaskId and previousTaskId ~= taskId then -- 2799
		cleanupTaskHeavyData(previousTaskId) -- 2802
	end -- 2802
	activePromptRuns = activePromptRuns + 1 -- 2804
	local ____runCodingAgent_132 = runCodingAgent -- 2805
	local ____normalizedPrompt_125 = normalizedPrompt -- 2806
	local ____temp_126 = options and options.resumeConversation -- 2807
	local ____temp_127 = (options and options.existingTaskId) ~= nil -- 2808
	local ____temp_128 = options and options.initialStep -- 2809
	local ____temp_129 = options and options.initialAgentStepCount -- 2810
	local ____temp_120 -- 2811
	if (options and options.existingTaskId) ~= nil then -- 2811
		____temp_120 = getInitialTokenUsage(session) -- 2811
	else -- 2811
		____temp_120 = nil -- 2811
	end -- 2811
	____runCodingAgent_132( -- 2805
		{ -- 2805
			prompt = ____normalizedPrompt_125, -- 2806
			resumeConversation = ____temp_126, -- 2807
			resumeTask = ____temp_127, -- 2808
			initialStep = ____temp_128, -- 2809
			initialAgentStepCount = ____temp_129, -- 2810
			initialTokenUsage = ____temp_120, -- 2811
			workDir = session.projectRoot, -- 2812
			useChineseResponse = useChineseResponse, -- 2813
			taskId = taskId, -- 2814
			sessionId = session.id, -- 2815
			memoryScope = session.memoryScope, -- 2816
			role = session.kind, -- 2817
			maxSteps = options and options.maxSteps, -- 2818
			disabledAgentTools = disabledAgentTools, -- 2819
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2820
			llmConfig = llmConfig, -- 2821
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2822
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2825
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2828
			stopToken = stopToken, -- 2829
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2830
		}, -- 2830
		function(result) -- 2831
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2831
				local ____hasReturned, ____returnValue -- 2831
				local ____try = __TS__AsyncAwaiter(function() -- 2831
					local nextSession = getSessionItem(session.id) -- 2833
					if nextSession and nextSession.kind == "sub" then -- 2833
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2833
							local stopped = stopClearedSubSession(nextSession, taskId) -- 2836
							if not stopped.success then -- 2836
								Log( -- 2838
									"Warn", -- 2838
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2838
								) -- 2838
								emitAgentSessionPatch( -- 2839
									session.id, -- 2839
									{session = getSessionItem(session.id)} -- 2839
								) -- 2839
							end -- 2839
							__TS__Delete(activeStopTokens, taskId) -- 2843
							____hasReturned = true -- 2844
							return -- 2844
						end -- 2844
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2846
						emitAgentSessionPatch( -- 2847
							session.id, -- 2847
							{session = getSessionItem(session.id)} -- 2847
						) -- 2847
						local finalized = __TS__Await(finalizeSubSession( -- 2850
							nextSession, -- 2851
							taskId, -- 2852
							result.success, -- 2853
							result.message, -- 2854
							result.completion, -- 2855
							(options and options.forceSubAgentHandoff) == true -- 2856
						)) -- 2856
						if not finalized.success then -- 2856
							Log( -- 2859
								"Warn", -- 2859
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2859
							) -- 2859
						end -- 2859
						local finalizedSession = getSessionItem(session.id) -- 2861
						if finalizedSession then -- 2861
							local stopped = stopToken.stopped == true -- 2863
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2864
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2867
							emitAgentSessionPatch( -- 2868
								session.id, -- 2868
								{session = getSessionItem(session.id)} -- 2868
							) -- 2868
						end -- 2868
						__TS__Delete(activeStopTokens, taskId) -- 2872
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2873
					end -- 2873
					local fallbackSession = getSessionItem(session.id) -- 2875
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2875
						applyEvent(session.id, { -- 2881
							type = "task_finished", -- 2882
							sessionId = session.id, -- 2883
							taskId = result.taskId, -- 2884
							success = false, -- 2885
							message = result.message, -- 2886
							steps = result.steps -- 2887
						}) -- 2887
					end -- 2887
				end) -- 2887
				____try = ____try.finally( -- 2887
					____try, -- 2887
					function() -- 2887
						return __TS__AsyncAwaiter(function() -- 2887
							activePromptRuns = activePromptRuns - 1 -- 2891
						end) -- 2891
					end -- 2891
				) -- 2891
				__TS__Await(____try) -- 2832
				if ____hasReturned then -- 2832
					return ____awaiter_resolve(nil, ____returnValue) -- 2832
				end -- 2832
			end) -- 2832
		end -- 2831
	) -- 2831
	return {success = true, sessionId = session.id, taskId = taskId} -- 2894
end -- 2894
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3047
	local lines = {} -- 3048
	do -- 3048
		local i = 0 -- 3049
		while i < #questionnaire.schema.questions do -- 3049
			local question = questionnaire.schema.questions[i + 1] -- 3050
			local answer = __TS__ArrayFind( -- 3051
				answers, -- 3051
				function(____, item) return item.questionId == question.id end -- 3051
			) -- 3051
			local answerText = "已跳过" -- 3052
			if answer and answer.status == "answered" then -- 3052
				local parts = {} -- 3054
				do -- 3054
					local j = 0 -- 3055
					while j < #(answer.selectedOptionIds or ({})) do -- 3055
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3056
						local option = __TS__ArrayFind( -- 3057
							question.options or ({}), -- 3057
							function(____, item) return item.id == optionId end -- 3057
						) -- 3057
						if option then -- 3057
							parts[#parts + 1] = option.label -- 3058
						end -- 3058
						j = j + 1 -- 3055
					end -- 3055
				end -- 3055
				if answer.otherText then -- 3055
					parts[#parts + 1] = answer.otherText -- 3060
				end -- 3060
				if answer.text then -- 3060
					parts[#parts + 1] = answer.text -- 3061
				end -- 3061
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3062
			end -- 3062
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3064
			i = i + 1 -- 3049
		end -- 3049
	end -- 3049
	return table.concat(lines, "\n\n") -- 3066
end -- 3066
function ____exports.listRunningSubAgents(request) -- 3351
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3351
		local session = getSessionItem(request.sessionId) -- 3359
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3359
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3361
		end -- 3361
		if not session then -- 3361
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3361
		end -- 3361
		local rootSession = getRootSessionItem(session.id) -- 3366
		if not rootSession then -- 3366
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3366
		end -- 3366
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3370
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3371
		local limit = math.max( -- 3372
			1, -- 3372
			math.floor(tonumber(request.limit) or 5) -- 3372
		) -- 3372
		local offset = math.max( -- 3373
			0, -- 3373
			math.floor(tonumber(request.offset) or 0) -- 3373
		) -- 3373
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3374
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3375
		local runningSessions = {} -- 3382
		do -- 3382
			local i = 0 -- 3383
			while i < #rows do -- 3383
				do -- 3383
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3384
					if current.currentTaskStatus ~= "RUNNING" then -- 3384
						goto __continue570 -- 3386
					end -- 3386
					local spawnInfo = getSessionSpawnInfo(current) -- 3388
					runningSessions[#runningSessions + 1] = { -- 3389
						sessionId = current.id, -- 3390
						title = current.title, -- 3391
						parentSessionId = current.parentSessionId, -- 3392
						rootSessionId = current.rootSessionId, -- 3393
						status = "RUNNING", -- 3394
						currentTaskId = current.currentTaskId, -- 3395
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3396
						goal = spawnInfo and spawnInfo.goal, -- 3397
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3398
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3399
						createdAt = current.createdAt, -- 3400
						updatedAt = current.updatedAt -- 3401
					} -- 3401
				end -- 3401
				::__continue570:: -- 3401
				i = i + 1 -- 3383
			end -- 3383
		end -- 3383
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3404
		local completedSessions = __TS__ArrayMap( -- 3405
			completedRecords, -- 3405
			function(____, record) return { -- 3405
				sessionId = record.sessionId, -- 3406
				title = record.title, -- 3407
				parentSessionId = record.parentSessionId, -- 3408
				rootSessionId = record.rootSessionId, -- 3409
				status = record.status, -- 3410
				goal = record.goal, -- 3411
				expectedOutput = record.expectedOutput, -- 3412
				filesHint = record.filesHint, -- 3413
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3414
				success = record.success, -- 3415
				cleared = record.cleared, -- 3416
				resultFilePath = record.resultFilePath, -- 3417
				artifactDir = record.artifactDir, -- 3418
				finishedAt = record.finishedAt, -- 3419
				createdAt = record.createdAtTs, -- 3420
				updatedAt = record.finishedAtTs -- 3421
			} end -- 3421
		) -- 3421
		local merged = {} -- 3423
		if status == "running" then -- 3423
			merged = runningSessions -- 3425
		elseif status == "done" then -- 3425
			merged = __TS__ArrayFilter( -- 3427
				completedSessions, -- 3427
				function(____, item) return item.status == "DONE" end -- 3427
			) -- 3427
		elseif status == "failed" then -- 3427
			merged = __TS__ArrayFilter( -- 3429
				completedSessions, -- 3429
				function(____, item) return item.status == "FAILED" end -- 3429
			) -- 3429
		elseif status == "stopped" then -- 3429
			merged = __TS__ArrayFilter( -- 3431
				completedSessions, -- 3431
				function(____, item) return item.status == "STOPPED" end -- 3431
			) -- 3431
		elseif status == "all" then -- 3431
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3433
		else -- 3433
			local runningKeys = {} -- 3435
			do -- 3435
				local i = 0 -- 3436
				while i < #runningSessions do -- 3436
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3437
					i = i + 1 -- 3436
				end -- 3436
			end -- 3436
			local latestCompletedByKey = {} -- 3439
			do -- 3439
				local i = 0 -- 3440
				while i < #completedSessions do -- 3440
					do -- 3440
						local item = completedSessions[i + 1] -- 3441
						local key = getSubAgentDisplayKey(item) -- 3442
						if runningKeys[key] then -- 3442
							goto __continue585 -- 3444
						end -- 3444
						local current = latestCompletedByKey[key] -- 3446
						if current == nil or item.updatedAt > current.updatedAt then -- 3446
							latestCompletedByKey[key] = item -- 3448
						end -- 3448
					end -- 3448
					::__continue585:: -- 3448
					i = i + 1 -- 3440
				end -- 3440
			end -- 3440
			local latestCompleted = {} -- 3451
			for ____, item in pairs(latestCompletedByKey) do -- 3452
				latestCompleted[#latestCompleted + 1] = item -- 3453
			end -- 3453
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3455
		end -- 3455
		if query ~= "" then -- 3455
			merged = __TS__ArrayFilter( -- 3458
				merged, -- 3458
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3458
			) -- 3458
		end -- 3458
		__TS__ArraySort( -- 3464
			merged, -- 3464
			function(____, a, b) -- 3464
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3464
					return -1 -- 3465
				end -- 3465
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3465
					return 1 -- 3466
				end -- 3466
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3466
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3468
				end -- 3468
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3470
			end -- 3464
		) -- 3464
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3472
		return ____awaiter_resolve(nil, { -- 3472
			success = true, -- 3474
			rootSessionId = rootSession.id, -- 3475
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3476
			status = status, -- 3477
			limit = limit, -- 3478
			offset = offset, -- 3479
			hasMore = offset + limit < #merged, -- 3480
			sessions = paged -- 3481
		}) -- 3481
	end) -- 3481
end -- 3351
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
function ____exports.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 2623
	local session = getSessionItem(sessionId) -- 2624
	if not session then -- 2624
		return {success = false, message = "session not found"} -- 2625
	end -- 2625
	if session.kind ~= "main" then -- 2625
		return {success = false, message = "local Agent only supports main sessions"} -- 2626
	end -- 2626
	if getPendingQuestionnaire(sessionId) then -- 2626
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2627
	end -- 2627
	if session.currentTaskStatus == "RUNNING" then -- 2627
		return {success = false, message = "session task is still running"} -- 2628
	end -- 2628
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2629
	if normalizedPrompt == "" then -- 2629
		return {success = false, message = "prompt is empty"} -- 2630
	end -- 2630
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2631
	if not config then -- 2631
		return {success = false, message = "local Agent config not found"} -- 2632
	end -- 2632
	if not config.verifiedAt then -- 2632
		return {success = false, message = "local Agent config is not verified"} -- 2633
	end -- 2633
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2634
	if not taskRes.success then -- 2634
		return taskRes -- 2635
	end -- 2635
	local taskId = taskRes.taskId -- 2636
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2637
	Tools.setTaskStatus(taskId, "RUNNING") -- 2638
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2639
	upsertStep( -- 2640
		session.id, -- 2640
		taskId, -- 2640
		1, -- 2640
		"local_agent_message", -- 2640
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2640
	) -- 2640
	emitAgentSessionPatch( -- 2646
		session.id, -- 2646
		{ -- 2646
			session = getSessionItem(session.id), -- 2647
			message = getMessageItem(messageId), -- 2648
			step = getStepItem(session.id, taskId, 1) -- 2649
		} -- 2649
	) -- 2649
	local events = {} -- 2651
	local transcript = "" -- 2652
	local assistant = "" -- 2653
	local lastFlush = 0 -- 2654
	local function flush(force) -- 2655
		if force == nil then -- 2655
			force = false -- 2655
		end -- 2655
		if not force and App.runningTime - lastFlush < 0.075 then -- 2655
			return -- 2656
		end -- 2656
		lastFlush = App.runningTime -- 2657
		if #events > 400 then -- 2657
			events = __TS__ArraySlice(events, #events - 400) -- 2658
		end -- 2658
		if #transcript > 1024 * 1024 then -- 2658
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2659
		end -- 2659
		upsertStep( -- 2660
			session.id, -- 2660
			taskId, -- 2660
			1, -- 2660
			"local_agent_message", -- 2660
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2660
		) -- 2660
		local message -- 2665
		if assistant ~= "" then -- 2665
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2667
			message = getMessageItem(assistantId) -- 2668
		end -- 2668
		emitAgentSessionPatch( -- 2670
			session.id, -- 2670
			__TS__ObjectAssign( -- 2670
				{step = getStepItem(session.id, taskId, 1)}, -- 2670
				message and ({message = message}) or ({}) -- 2670
			) -- 2670
		) -- 2670
	end -- 2655
	local completedSynchronously = false -- 2672
	local control = LocalAgent.run( -- 2673
		session.id, -- 2673
		config, -- 2673
		session.projectRoot, -- 2673
		normalizedPrompt, -- 2673
		function(event) -- 2673
			local text = sanitizeUTF8(event.text) -- 2674
			if text == "" then -- 2674
				return -- 2675
			end -- 2675
			local previous = #events > 0 and events[#events] or nil -- 2676
			if previous and previous.kind == event.kind and previous.text == text then -- 2676
				return -- 2677
			end -- 2677
			events[#events + 1] = {kind = event.kind, text = text} -- 2678
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2679
			if event.kind == "assistant" then -- 2679
				assistant = text -- 2680
			end -- 2680
			flush(false) -- 2681
		end, -- 2673
		function(result) -- 2682
			completedSynchronously = true -- 2683
			flush(true) -- 2684
			__TS__Delete(activeLocalAgentControls, taskId) -- 2685
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2686
			Tools.setTaskStatus(taskId, status) -- 2687
			setSessionState(session.id, status, taskId, status) -- 2688
			upsertStep( -- 2689
				session.id, -- 2689
				taskId, -- 2689
				1, -- 2689
				"local_agent_message", -- 2689
				{status = status, reason = config.name .. " · full permissions", result = { -- 2689
					provider = config.provider, -- 2692
					events = events, -- 2692
					transcript = transcript, -- 2692
					exitCode = result.exitCode, -- 2692
					resumeId = result.resumeId, -- 2692
					message = result.message -- 2692
				}} -- 2692
			) -- 2692
			emitAgentSessionPatch( -- 2694
				session.id, -- 2694
				{ -- 2694
					session = getSessionItem(session.id), -- 2694
					step = getStepItem(session.id, taskId, 1) -- 2694
				} -- 2694
			) -- 2694
		end -- 2682
	) -- 2682
	if not completedSynchronously then -- 2682
		activeLocalAgentControls[taskId] = control -- 2696
	end -- 2696
	return {success = true, sessionId = session.id, taskId = taskId} -- 2697
end -- 2623
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2700
	local session = getSessionItem(sessionId) -- 2701
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2701
		return {success = false, message = "project task admission is closed"} -- 2702
	end -- 2702
	if not session then -- 2702
		return {success = false, message = "session not found"} -- 2704
	end -- 2704
	if getPendingQuestionnaire(sessionId) then -- 2704
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2706
	end -- 2706
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2706
		return {success = false, message = "session task is finalizing"} -- 2708
	end -- 2708
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2708
		return {success = false, message = "session task is still stopping"} -- 2711
	end -- 2711
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2711
		return {success = false, message = "session task is not continuable"} -- 2714
	end -- 2714
	if session.currentTaskId == nil then -- 2714
		return {success = false, message = "session task not found"} -- 2717
	end -- 2717
	local taskId = session.currentTaskId -- 2719
	return startPromptTask( -- 2720
		session, -- 2721
		"", -- 2722
		nil, -- 2723
		normalizeDisabledAgentTools(disabledAgentTools), -- 2724
		{ -- 2725
			workMode = session.workMode, -- 2726
			persistUserMessage = false, -- 2727
			resumeConversation = true, -- 2728
			existingTaskId = taskId, -- 2729
			initialStep = math.max( -- 2730
				0, -- 2730
				getNextStepNumber(session.id, taskId) - 1 -- 2730
			), -- 2730
			initialAgentStepCount = 0, -- 2734
			llmConfigId = llmConfigId -- 2735
		} -- 2735
	) -- 2735
end -- 2700
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2897
	local session = getSessionItem(sessionId) -- 2898
	if not session then -- 2898
		return {success = false, message = "session not found"} -- 2900
	end -- 2900
	if session.kind ~= "sub" then -- 2900
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2903
	end -- 2903
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2903
		return {success = false, message = "session task is finalizing"} -- 2906
	end -- 2906
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2908
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2908
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2913
	end -- 2913
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2913
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2916
	end -- 2916
	local disabledAgentTools = AgentToolRegistry.getAllowedToolsForRole("sub") -- 2918
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并给出最终总结。不要再调用任何工具；用纯文本如实总结已完成内容、文件变更、验证状态和剩余问题。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2920
	return startPromptTask( -- 2923
		session, -- 2923
		prompt, -- 2923
		nil, -- 2923
		disabledAgentTools, -- 2923
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2923
	) -- 2923
end -- 2897
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2930
	local session = getSessionItem(sessionId) -- 2931
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2931
		return {success = false, message = "project task admission is closed"} -- 2932
	end -- 2932
	if not session then -- 2932
		return {success = false, message = "session not found"} -- 2934
	end -- 2934
	if getPendingQuestionnaire(sessionId) then -- 2934
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2936
	end -- 2936
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2936
		return {success = false, message = "session task is finalizing"} -- 2938
	end -- 2938
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2938
		return {success = false, message = "session task is still running"} -- 2941
	end -- 2941
	local message = getMessageItem(messageId) -- 2943
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2943
		return {success = false, message = "message not found"} -- 2945
	end -- 2945
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2947
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2953
	if latestUserMessageId ~= messageId then -- 2953
		return {success = false, message = "only the latest user prompt can be edited"} -- 2955
	end -- 2955
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2957
	if normalizedPrompt == "" then -- 2957
		return {success = false, message = "prompt is empty"} -- 2959
	end -- 2959
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2961
	if session.workMode ~= nextWorkMode then -- 2961
		DB:exec( -- 2963
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2963
			{ -- 2963
				nextWorkMode, -- 2963
				now(), -- 2963
				session.id -- 2963
			} -- 2963
		) -- 2963
		session.workMode = nextWorkMode -- 2964
	end -- 2964
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2966
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2967
	local result = startPromptTask( -- 2968
		session, -- 2968
		normalizedPrompt, -- 2968
		messageId, -- 2968
		normalizeDisabledAgentTools(disabledAgentTools), -- 2968
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2968
	) -- 2968
	if result.success and #removedStepIds > 0 then -- 2968
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2970
	end -- 2970
	return result -- 2972
end -- 2930
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2977
	if status == "dismissed" then -- 2977
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2983
	end -- 2983
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2985
end -- 2977
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2988
	if status == "dismissed" then -- 2988
		return { -- 2994
			success = true, -- 2995
			status = "dismissed", -- 2996
			source = "user", -- 2997
			questionnaireId = questionnaire.id, -- 2998
			title = questionnaire.schema.title, -- 2999
			answers = {}, -- 3000
			responses = {}, -- 3001
			displayText = "用户关闭了调查问卷，未作答。", -- 3002
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 3003
		} -- 3003
	end -- 3003
	local responses = {} -- 3006
	do -- 3006
		local i = 0 -- 3007
		while i < #questionnaire.schema.questions do -- 3007
			do -- 3007
				local question = questionnaire.schema.questions[i + 1] -- 3008
				local answer = __TS__ArrayFind( -- 3009
					answers, -- 3009
					function(____, item) return item.questionId == question.id end -- 3009
				) -- 3009
				if not answer or answer.status == "skipped" then -- 3009
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 3011
					goto __continue482 -- 3016
				end -- 3016
				local selectedOptionLabels = {} -- 3018
				do -- 3018
					local j = 0 -- 3019
					while j < #(answer.selectedOptionIds or ({})) do -- 3019
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3020
						local option = __TS__ArrayFind( -- 3021
							question.options or ({}), -- 3021
							function(____, item) return item.id == optionId end -- 3021
						) -- 3021
						if option then -- 3021
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 3022
						end -- 3022
						j = j + 1 -- 3019
					end -- 3019
				end -- 3019
				responses[#responses + 1] = { -- 3024
					questionId = question.id, -- 3025
					prompt = question.prompt, -- 3026
					status = "answered", -- 3027
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 3028
					selectedOptionLabels = selectedOptionLabels, -- 3029
					otherText = answer.otherText, -- 3030
					text = answer.text -- 3031
				} -- 3031
			end -- 3031
			::__continue482:: -- 3031
			i = i + 1 -- 3007
		end -- 3007
	end -- 3007
	return { -- 3034
		success = true, -- 3035
		status = "answered", -- 3036
		source = "user", -- 3037
		questionnaireId = questionnaire.id, -- 3038
		title = questionnaire.schema.title, -- 3039
		answers = answers, -- 3040
		responses = responses, -- 3041
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3042
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3043
	} -- 3043
end -- 2988
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3069
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3075
	local persisted = storage:readSessionState() -- 3076
	local messages = __TS__ArraySlice(persisted.messages) -- 3077
	local toolResultIndex = -1 -- 3078
	local existingResult -- 3079
	do -- 3079
		local i = #messages - 1 -- 3080
		while i >= 0 do -- 3080
			do -- 3080
				local message = messages[i + 1] -- 3081
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3081
					goto __continue502 -- 3082
				end -- 3082
				local decoded = safeJsonDecode(message.content) -- 3083
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3083
					goto __continue502 -- 3084
				end -- 3084
				local row = decoded -- 3085
				if row.questionnaireId ~= questionnaire.id then -- 3085
					goto __continue502 -- 3086
				end -- 3086
				toolResultIndex = i -- 3087
				existingResult = row -- 3088
				break -- 3089
			end -- 3089
			::__continue502:: -- 3089
			i = i - 1 -- 3080
		end -- 3080
	end -- 3080
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3091
	local guidance = {} -- 3092
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3092
		guidance[#guidance + 1] = existingResult.guidance -- 3094
	end -- 3094
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3094
		guidance[#guidance + 1] = result.guidance -- 3097
	end -- 3097
	result.guidance = table.concat(guidance, "\n") -- 3099
	if toolResultIndex < 0 then -- 3099
		messages[#messages + 1] = { -- 3101
			role = "user", -- 3102
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3103
		} -- 3103
		toolResultIndex = #messages - 1 -- 3105
	else -- 3105
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3107
			{}, -- 3107
			messages[toolResultIndex + 1], -- 3108
			{content = encodeJson(result)} -- 3107
		) -- 3107
	end -- 3107
	local pairStartIndex = toolResultIndex -- 3113
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3114
	if toolCallId and toolCallId ~= "" then -- 3114
		do -- 3114
			local i = toolResultIndex - 1 -- 3116
			while i >= 0 do -- 3116
				do -- 3116
					local message = messages[i + 1] -- 3117
					if message.role ~= "assistant" or not message.tool_calls then -- 3117
						goto __continue512 -- 3118
					end -- 3118
					if __TS__ArraySome( -- 3118
						message.tool_calls, -- 3119
						function(____, call) return call.id == toolCallId end -- 3119
					) then -- 3119
						pairStartIndex = i -- 3120
						break -- 3121
					end -- 3121
				end -- 3121
				::__continue512:: -- 3121
				i = i - 1 -- 3116
			end -- 3116
		end -- 3116
	end -- 3116
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3125
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3128
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3132
	upsertStep( -- 3134
		session.id, -- 3134
		questionnaire.taskId, -- 3134
		questionnaire.step, -- 3134
		"ask_user", -- 3134
		{status = "DONE", result = result} -- 3134
	) -- 3134
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3138
	upsertStep( -- 3139
		session.id, -- 3139
		questionnaire.taskId, -- 3139
		answerStep, -- 3139
		"questionnaire_answer", -- 3139
		{status = "DONE", result = result} -- 3139
	) -- 3139
	return {success = true, answerStep = answerStep, result = result} -- 3143
end -- 3069
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3146
	local session = getSessionItem(sessionId) -- 3147
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3147
		return {success = false, message = "project task admission is closed"} -- 3148
	end -- 3148
	if not session then -- 3148
		return {success = false, message = "session not found"} -- 3149
	end -- 3149
	if session.kind ~= "main" then -- 3149
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3150
	end -- 3150
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3151
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3151
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3153
	end -- 3153
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3155
	if not llmConfigRes.success then -- 3155
		return {success = false, message = llmConfigRes.message} -- 3156
	end -- 3156
	if not removePendingQuestionnaire(session) then -- 3156
		return {success = false, message = "failed to consume questionnaire file"} -- 3157
	end -- 3157
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3158
	if not replaced.success then -- 3158
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3160
		return replaced -- 3161
	end -- 3161
	local t = now() -- 3163
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3164
	session.workMode = "plan" -- 3165
	local result = startPromptTask( -- 3166
		session, -- 3166
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3166
		nil, -- 3166
		{}, -- 3166
		{ -- 3166
			workMode = "plan", -- 3167
			persistUserMessage = false, -- 3168
			resumeConversation = true, -- 3169
			existingTaskId = questionnaire.taskId, -- 3170
			initialStep = replaced.answerStep, -- 3171
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3172
			llmConfig = llmConfigRes.config -- 3173
		} -- 3173
	) -- 3173
	if not result.success then -- 3173
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3176
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3177
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3178
		emitAgentSessionPatch( -- 3179
			session.id, -- 3179
			{ -- 3179
				session = getSessionItem(session.id), -- 3180
				pendingQuestionnaire = questionnaire -- 3181
			} -- 3181
		) -- 3181
		return result -- 3183
	end -- 3183
	emitAgentSessionPatch( -- 3185
		sessionId, -- 3185
		{ -- 3185
			session = getSessionItem(sessionId), -- 3186
			pendingQuestionnaire = false -- 3187
		} -- 3187
	) -- 3187
	return result -- 3189
end -- 3146
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3192
	local session = getSessionItem(sessionId) -- 3193
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3193
		return {success = false, message = "project task admission is closed"} -- 3194
	end -- 3194
	if not session then -- 3194
		return {success = false, message = "session not found"} -- 3195
	end -- 3195
	if session.kind ~= "main" then -- 3195
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3196
	end -- 3196
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3197
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3197
		return {success = false, message = "pending questionnaire not found"} -- 3198
	end -- 3198
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3199
	if not validated.success then -- 3199
		return validated -- 3200
	end -- 3200
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3201
	if not llmConfigRes.success then -- 3201
		return {success = false, message = llmConfigRes.message} -- 3202
	end -- 3202
	local t = now() -- 3203
	if not removePendingQuestionnaire(session) then -- 3203
		return {success = false, message = "failed to consume questionnaire file"} -- 3204
	end -- 3204
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3205
	if not replaced.success then -- 3205
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3207
		return replaced -- 3208
	end -- 3208
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3210
	session.workMode = "plan" -- 3211
	local result = startPromptTask( -- 3212
		session, -- 3212
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3212
		nil, -- 3212
		{}, -- 3212
		{ -- 3212
			workMode = "plan", -- 3213
			persistUserMessage = false, -- 3214
			resumeConversation = true, -- 3215
			existingTaskId = questionnaire.taskId, -- 3216
			initialStep = replaced.answerStep, -- 3217
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3218
			llmConfig = llmConfigRes.config -- 3219
		} -- 3219
	) -- 3219
	if not result.success then -- 3219
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3222
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3223
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3224
		emitAgentSessionPatch( -- 3225
			session.id, -- 3225
			{ -- 3225
				session = getSessionItem(session.id), -- 3226
				pendingQuestionnaire = questionnaire -- 3227
			} -- 3227
		) -- 3227
		return result -- 3229
	end -- 3229
	emitAgentSessionPatch( -- 3231
		sessionId, -- 3231
		{ -- 3231
			session = getSessionItem(sessionId), -- 3232
			pendingQuestionnaire = false -- 3233
		} -- 3233
	) -- 3233
	return result -- 3235
end -- 3192
function ____exports.stopSessionTask(sessionId) -- 3238
	local session = getSessionItem(sessionId) -- 3239
	if not session or session.currentTaskId == nil then -- 3239
		return {success = false, message = "session task not found"} -- 3241
	end -- 3241
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3241
		return {success = false, message = "session task is finalizing"} -- 3244
	end -- 3244
	streamUpdates:clear(sessionId, session.currentTaskId, App.runningTime) -- 3246
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3247
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3248
	if localControl ~= nil then -- 3248
		localControl:stop() -- 3250
		return {success = true, stopping = true} -- 3251
	end -- 3251
	local stopToken = activeStopTokens[session.currentTaskId] -- 3253
	if stopToken == nil then -- 3253
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3253
			return {success = true, recovered = true} -- 3256
		end -- 3256
		return {success = false, message = "task is not running"} -- 3258
	end -- 3258
	if stopToken.stopped then -- 3258
		return {success = true, stopping = true} -- 3261
	end -- 3261
	stopToken.stopped = true -- 3263
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3264
	return {success = true, stopping = true} -- 3268
end -- 3238
function ____exports.getCurrentTaskId(sessionId) -- 3271
	local ____opt_135 = getSessionItem(sessionId) -- 3271
	return ____opt_135 and ____opt_135.currentTaskId -- 3272
end -- 3271
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3276
	local owner = getSessionItem(sessionId) -- 3277
	if not owner then -- 3277
		return {success = false, message = "session not found"} -- 3278
	end -- 3278
	local projectRoot = owner.projectRoot -- 3279
	local release = holdProjectTaskAdmission(projectRoot) -- 3280
	local closed = false -- 3281
	return { -- 3282
		success = true, -- 3283
		projectRoot = projectRoot, -- 3284
		close = function() -- 3285
			if not closed then -- 3285
				closed = true -- 3285
				release() -- 3285
			end -- 3285
		end, -- 3285
		poll = function() -- 3286
			if closed then -- 3286
				return {success = false, message = "quiescence handle closed"} -- 3287
			end -- 3287
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3288
			if not rows then -- 3288
				return {success = false, message = "failed to inspect project tasks"} -- 3289
			end -- 3289
			local pending = {} -- 3290
			for ____, row in ipairs(rows) do -- 3291
				do -- 3291
					local session = rowToSession(row) -- 3292
					local taskId = session.currentTaskId -- 3293
					if taskId == nil then -- 3293
						goto __continue550 -- 3294
					end -- 3294
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3295
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3295
						goto __continue550 -- 3296
					end -- 3296
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3298
					local ____session_id_138 = session.id -- 3299
					local ____taskId_139 = taskId -- 3299
					local ____finalizing_140 = finalizing -- 3299
					local ____result_success_141 = result.success -- 3299
					local ____result_success_137 -- 3299
					if result.success then -- 3299
						____result_success_137 = nil -- 3299
					else -- 3299
						____result_success_137 = result.message -- 3299
					end -- 3299
					pending[#pending + 1] = { -- 3299
						sessionId = ____session_id_138, -- 3299
						taskId = ____taskId_139, -- 3299
						finalizing = ____finalizing_140, -- 3299
						stopRequested = ____result_success_141, -- 3299
						message = ____result_success_137 -- 3299
					} -- 3299
				end -- 3299
				::__continue550:: -- 3299
			end -- 3299
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3303
		end -- 3286
	} -- 3286
end -- 3276
function ____exports.validateTaskAccess(sessionId, taskId) -- 3308
	local session = getSessionItem(sessionId) -- 3309
	if not session then -- 3309
		return {success = false, message = "session not found"} -- 3310
	end -- 3310
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3310
		getSessionOperableTaskIds(sessionId), -- 3311
		taskId -- 3311
	) < 0 then -- 3311
		return {success = false, message = "task is not operable for this session"} -- 3312
	end -- 3312
	return {success = true, session = session} -- 3314
end -- 3308
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3317
	if checkpointId <= 0 then -- 3317
		return {success = false, message = "invalid checkpointId"} -- 3319
	end -- 3319
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3321
	if not checkpoint then -- 3321
		return {success = false, message = "checkpoint not found"} -- 3323
	end -- 3323
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3325
	if not taskAccess.success then -- 3325
		return taskAccess -- 3326
	end -- 3326
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3327
end -- 3317
function ____exports.listRunningSessions() -- 3330
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3331
	local sessions = {} -- 3338
	do -- 3338
		local i = 0 -- 3339
		while i < #rows do -- 3339
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3340
			if session.currentTaskStatus == "RUNNING" then -- 3340
				sessions[#sessions + 1] = session -- 3342
			end -- 3342
			i = i + 1 -- 3339
		end -- 3339
	end -- 3339
	return {success = true, sessions = sessions} -- 3345
end -- 3330
return ____exports -- 3330