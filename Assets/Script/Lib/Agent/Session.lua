-- [ts]: Session.ts
local ____lualib = require("lualib_bundle") -- 1
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
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, activeLocalAgentControls, finalizingSubSessionTaskIds, activePromptRuns, pendingStreamUpdates, STREAM_UPDATE_MAX_DELTAS, STREAM_UPDATE_MIN_BYTES, streamUpdateKey, SESSION_SELECT_COLUMNS, now -- 1
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
function getDefaultUseChineseResponse() -- 364
	local zh = string.match(App.locale, "^zh") -- 365
	return zh ~= nil -- 366
end -- 366
function encodeJson(value) -- 369
	local text = safeJsonEncode(value) -- 370
	return text or "" -- 371
end -- 371
function decodeJsonObject(text) -- 374
	if text == "" then -- 374
		return nil -- 375
	end -- 375
	local value = safeJsonDecode(text) -- 376
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 376
		return value -- 378
	end -- 378
	return nil -- 380
end -- 380
function decodeJsonFiles(text) -- 383
	if text == "" then -- 383
		return nil -- 384
	end -- 384
	local value = safeJsonDecode(text) -- 385
	if not value or not __TS__ArrayIsArray(value) then -- 385
		return nil -- 386
	end -- 386
	local files = {} -- 387
	do -- 387
		local i = 0 -- 388
		while i < #value do -- 388
			do -- 388
				local item = value[i + 1] -- 389
				if type(item) ~= "table" then -- 389
					goto __continue14 -- 390
				end -- 390
				files[#files + 1] = { -- 391
					path = sanitizeUTF8(toStr(item.path)), -- 392
					op = sanitizeUTF8(toStr(item.op)) -- 393
				} -- 393
			end -- 393
			::__continue14:: -- 393
			i = i + 1 -- 388
		end -- 388
	end -- 388
	return files -- 396
end -- 396
function decodeChangeSetSummary(value) -- 399
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 399
		return nil -- 400
	end -- 400
	local row = value -- 401
	if row.success ~= true then -- 401
		return nil -- 402
	end -- 402
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 403
	if taskId <= 0 then -- 403
		return nil -- 404
	end -- 404
	local files = {} -- 405
	if __TS__ArrayIsArray(row.files) then -- 405
		do -- 405
			local i = 0 -- 407
			while i < #row.files do -- 407
				do -- 407
					local file = row.files[i + 1] -- 408
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 408
						goto __continue22 -- 409
					end -- 409
					local fileRow = file -- 410
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 411
					if path == "" then -- 411
						goto __continue22 -- 412
					end -- 412
					local checkpointIds = {} -- 413
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 413
						do -- 413
							local j = 0 -- 415
							while j < #fileRow.checkpointIds do -- 415
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 416
								if checkpointId > 0 then -- 416
									checkpointIds[#checkpointIds + 1] = checkpointId -- 417
								end -- 417
								j = j + 1 -- 415
							end -- 415
						end -- 415
					end -- 415
					local op = toStr(fileRow.op) -- 420
					files[#files + 1] = { -- 421
						path = path, -- 422
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 423
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 424
						checkpointIds = checkpointIds -- 425
					} -- 425
				end -- 425
				::__continue22:: -- 425
				i = i + 1 -- 407
			end -- 407
		end -- 407
	end -- 407
	return { -- 429
		success = true, -- 430
		taskId = taskId, -- 431
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 432
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 433
		files = files, -- 434
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 435
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 436
	} -- 436
end -- 436
function decodeHandoffEvidence(value) -- 440
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 440
		return nil -- 441
	end -- 441
	local row = value -- 442
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 443
		__TS__ArrayFilter( -- 444
			row.modifiedFiles, -- 444
			function(____, item) return type(item) == "string" end -- 444
		), -- 444
		function(____, item) return sanitizeUTF8(item) end -- 444
	) or ({}) -- 444
	local lastBuild = nil -- 446
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 446
		local build = row.lastBuild -- 448
		lastBuild = { -- 449
			result = build.result == "passed" and "passed" or "failed", -- 450
			path = sanitizeUTF8(toStr(build.path)), -- 451
			evidence = takeUtf8Head( -- 452
				sanitizeUTF8(toStr(build.evidence)), -- 452
				600 -- 452
			) -- 452
		} -- 452
	end -- 452
	local commands = {} -- 455
	if __TS__ArrayIsArray(row.commands) then -- 455
		do -- 455
			local i = 0 -- 457
			while i < #row.commands and #commands < 8 do -- 457
				do -- 457
					local raw = row.commands[i + 1] -- 458
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 458
						goto __continue36 -- 459
					end -- 459
					local item = raw -- 460
					commands[#commands + 1] = { -- 461
						mode = sanitizeUTF8(toStr(item.mode)), -- 462
						command = takeUtf8Head( -- 463
							sanitizeUTF8(toStr(item.command)), -- 463
							600 -- 463
						), -- 463
						result = item.result == "passed" and "passed" or "failed", -- 464
						evidence = takeUtf8Head( -- 465
							sanitizeUTF8(toStr(item.evidence)), -- 465
							600 -- 465
						) -- 465
					} -- 465
				end -- 465
				::__continue36:: -- 465
				i = i + 1 -- 457
			end -- 457
		end -- 457
	end -- 457
	local authoritativeSources = {} -- 469
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 469
		do -- 469
			local i = 0 -- 471
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 471
				do -- 471
					local raw = row.authoritativeSources[i + 1] -- 472
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 472
						goto __continue40 -- 473
					end -- 473
					local item = raw -- 474
					authoritativeSources[#authoritativeSources + 1] = { -- 475
						tool = "search_dora_doc", -- 476
						query = takeUtf8Head( -- 477
							sanitizeUTF8(toStr(item.query)), -- 477
							300 -- 477
						), -- 477
						source = sanitizeUTF8(toStr(item.source)), -- 478
						result = item.result == "passed" and "passed" or "failed" -- 479
					} -- 479
				end -- 479
				::__continue40:: -- 479
				i = i + 1 -- 471
			end -- 471
		end -- 471
	end -- 471
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 483
end -- 483
function takeUtf8Head(text, maxChars) -- 486
	if maxChars <= 0 or text == "" then -- 486
		return "" -- 487
	end -- 487
	local nextPos = utf8.offset(text, maxChars + 1) -- 488
	if nextPos == nil then -- 488
		return text -- 489
	end -- 489
	return string.sub(text, 1, nextPos - 1) -- 490
end -- 490
function normalizeMemoryEntryEvidence(value) -- 493
	local evidence = {} -- 494
	if not __TS__ArrayIsArray(value) then -- 494
		return evidence -- 495
	end -- 495
	do -- 495
		local i = 0 -- 496
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 496
			do -- 496
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 497
				if item == "" then -- 497
					goto __continue48 -- 498
				end -- 498
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 498
					evidence[#evidence + 1] = item -- 500
				end -- 500
			end -- 500
			::__continue48:: -- 500
			i = i + 1 -- 496
		end -- 496
	end -- 496
	return evidence -- 503
end -- 503
function decodeSubAgentMemoryEntry(value) -- 506
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 506
		return nil -- 507
	end -- 507
	local row = value -- 508
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 509
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 510
	local content = takeUtf8Head( -- 511
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 511
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 511
	) -- 511
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 511
		return nil -- 512
	end -- 512
	return { -- 513
		sourceSessionId = sourceSessionId, -- 514
		sourceTaskId = sourceTaskId, -- 515
		content = content, -- 516
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 517
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 518
	} -- 518
end -- 518
function getTaskChangeSetSummary(taskId) -- 522
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 523
	return summary.success and summary or nil -- 524
end -- 524
function summarizeHandoffResult(result) -- 527
	local candidates = {result.output, result.message, result.state, result.phase} -- 528
	do -- 528
		local i = 0 -- 529
		while i < #candidates do -- 529
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 530
			if text ~= "" then -- 530
				return takeUtf8Head(text, 600) -- 531
			end -- 531
			i = i + 1 -- 529
		end -- 529
	end -- 529
	local messages = result.messages -- 533
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 533
		local parts = {} -- 535
		do -- 535
			local i = 0 -- 536
			while i < #messages and #parts < 4 do -- 536
				do -- 536
					local row = messages[i + 1] -- 537
					if not row or type(row) ~= "table" then -- 537
						goto __continue61 -- 538
					end -- 538
					local item = row -- 539
					local ____sanitizeUTF8_3 = sanitizeUTF8 -- 540
					local ____toStr_2 = toStr -- 540
					local ____item_message_0 = item.message -- 540
					if ____item_message_0 == nil then -- 540
						____item_message_0 = item.error -- 540
					end -- 540
					local ____item_message_0_1 = ____item_message_0 -- 540
					if ____item_message_0_1 == nil then -- 540
						____item_message_0_1 = item.file -- 540
					end -- 540
					local text = __TS__StringTrim(____sanitizeUTF8_3(____toStr_2(____item_message_0_1))) -- 540
					if text ~= "" then -- 540
						parts[#parts + 1] = text -- 541
					end -- 541
				end -- 541
				::__continue61:: -- 541
				i = i + 1 -- 536
			end -- 536
		end -- 536
		if #parts > 0 then -- 536
			return takeUtf8Head( -- 543
				table.concat(parts, "; "), -- 543
				600 -- 543
			) -- 543
		end -- 543
	end -- 543
	return result.success == true and "tool result success=true" or "tool result success=false" -- 545
end -- 545
function getTaskHandoffEvidence(taskId, changeSet) -- 548
	local ____opt_4 = changeSet -- 548
	local evidence = { -- 549
		modifiedFiles = ____opt_4 and __TS__ArrayMap( -- 550
			changeSet and changeSet.files, -- 550
			function(____, item) return item.path end -- 550
		) or ({}), -- 550
		commands = {}, -- 551
		authoritativeSources = {} -- 552
	} -- 552
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 554
	do -- 554
		local i = 0 -- 559
		while i < #rows do -- 559
			local tool = toStr(rows[i + 1][1]) -- 560
			local status = toStr(rows[i + 1][2]) -- 561
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 562
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 563
			local passed = status == "DONE" and result.success == true -- 564
			if tool == "build" then -- 564
				evidence.lastBuild = { -- 566
					result = passed and "passed" or "failed", -- 567
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 568
					evidence = summarizeHandoffResult(result) -- 569
				} -- 569
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 569
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 572
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 573
				local ____evidence_commands_8 = evidence.commands -- 573
				____evidence_commands_8[#____evidence_commands_8 + 1] = { -- 574
					mode = mode, -- 575
					command = takeUtf8Head( -- 576
						__TS__StringTrim(sanitizeUTF8(command)), -- 576
						600 -- 576
					), -- 576
					result = passed and "passed" or "failed", -- 577
					evidence = summarizeHandoffResult(result) -- 578
				} -- 578
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 578
				local ____evidence_authoritativeSources_9 = evidence.authoritativeSources -- 578
				____evidence_authoritativeSources_9[#____evidence_authoritativeSources_9 + 1] = { -- 581
					tool = "search_dora_doc", -- 582
					query = takeUtf8Head( -- 583
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 583
						300 -- 583
					), -- 583
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 584
					result = passed and "passed" or "failed" -- 585
				} -- 585
			end -- 585
			i = i + 1 -- 559
		end -- 559
	end -- 559
	return evidence -- 589
end -- 589
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 592
	local lastBuild = evidence.lastBuild -- 596
	if not lastBuild or lastBuild.result ~= "failed" then -- 596
		return completion -- 597
	end -- 597
	local validation = __TS__ArraySlice(completion.validation) -- 598
	local foundBuild = false -- 599
	do -- 599
		local i = 0 -- 600
		while i < #validation do -- 600
			do -- 600
				if validation[i + 1].kind ~= "build" then -- 600
					goto __continue75 -- 601
				end -- 601
				foundBuild = true -- 602
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 603
			end -- 603
			::__continue75:: -- 603
			i = i + 1 -- 600
		end -- 600
	end -- 600
	if not foundBuild then -- 600
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 610
	end -- 610
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 612
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 613
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 613
		knownIssues[#knownIssues + 1] = issue -- 614
	end -- 614
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 615
end -- 615
function isValidProjectRoot(path) -- 623
	return path ~= "" and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 624
end -- 624
function rowToSession(row) -- 627
	return { -- 628
		id = row[1], -- 629
		projectRoot = toStr(row[2]), -- 630
		title = toStr(row[3]), -- 631
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 632
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 633
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 634
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 635
		status = toStr(row[8]), -- 636
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 637
		currentTaskStatus = toStr(row[10]), -- 638
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 639
		createdAt = row[11], -- 640
		updatedAt = row[12], -- 641
		metrics = decodeJsonObject(toStr(row[13])), -- 642
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 643
	} -- 643
end -- 643
function rowToMessage(row) -- 647
	local message = { -- 648
		id = row[1], -- 649
		sessionId = row[2], -- 650
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 651
		role = toStr(row[4]), -- 652
		content = toStr(row[5]), -- 653
		createdAt = row[7], -- 654
		updatedAt = row[8] -- 655
	} -- 655
	local displayContent = toStr(row[6]) -- 657
	if displayContent ~= "" then -- 657
		message.displayContent = displayContent -- 658
	end -- 658
	return message -- 659
end -- 659
function rowToStep(row) -- 662
	return { -- 663
		id = row[1], -- 664
		sessionId = row[2], -- 665
		taskId = row[3], -- 666
		step = row[4], -- 667
		tool = toStr(row[5]), -- 668
		status = toStr(row[6]), -- 669
		reason = toStr(row[7]), -- 670
		reasoningContent = toStr(row[8]), -- 671
		params = decodeJsonObject(toStr(row[9])), -- 672
		result = decodeJsonObject(toStr(row[10])), -- 673
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 674
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 675
		files = decodeJsonFiles(toStr(row[13])), -- 676
		createdAt = row[14], -- 677
		updatedAt = row[15] -- 678
	} -- 678
end -- 678
function getQuestionnairePath(projectRoot) -- 682
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 683
end -- 683
function decodeQuestionnaireFile(text) -- 686
	local value = decodeJsonObject(text) -- 687
	if not value then -- 687
		return nil -- 688
	end -- 688
	local schema = value.schema -- 689
	local id = type(value.id) == "number" and value.id or 0 -- 690
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 691
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 692
	local step = type(value.step) == "number" and value.step or 0 -- 693
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 694
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 694
		return nil -- 696
	end -- 696
	return { -- 698
		id = id, -- 698
		sessionId = sessionId, -- 698
		taskId = taskId, -- 698
		step = step, -- 698
		status = "PENDING", -- 698
		schema = schema, -- 698
		createdAt = createdAt -- 698
	} -- 698
end -- 698
function getPendingQuestionnaire(sessionId) -- 701
	local session = getSessionItem(sessionId) -- 702
	if not session or session.kind ~= "main" then -- 702
		return nil -- 703
	end -- 703
	local path = getQuestionnairePath(session.projectRoot) -- 704
	if not Content:exist(path) then -- 704
		return nil -- 705
	end -- 705
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 706
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 707
end -- 707
function restorePendingQuestionnaireState(session) -- 710
	local questionnaire = getPendingQuestionnaire(session.id) -- 711
	if not questionnaire then -- 711
		return {session = session} -- 712
	end -- 712
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 712
		local t = now() -- 719
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 720
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 726
		local restored = getSessionItem(session.id) -- 727
		if restored then -- 727
			session = restored -- 728
		end -- 728
	end -- 728
	return {session = session, questionnaire = questionnaire} -- 730
end -- 730
function savePendingQuestionnaire(projectRoot, questionnaire) -- 733
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 734
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 734
		return false -- 735
	end -- 735
	local path = getQuestionnairePath(projectRoot) -- 736
	local tempPath = path .. ".tmp" -- 737
	local backupPath = path .. ".bak" -- 738
	Content:remove(tempPath) -- 739
	Content:remove(backupPath) -- 740
	if not Content:save( -- 740
		tempPath, -- 741
		encodeJson(questionnaire) -- 741
	) then -- 741
		return false -- 741
	end -- 741
	local hadOriginal = Content:exist(path) -- 742
	if hadOriginal and not Content:move(path, backupPath) then -- 742
		Content:remove(tempPath) -- 744
		return false -- 745
	end -- 745
	if Content:move(tempPath, path) then -- 745
		Content:remove(backupPath) -- 748
		Tools.sendWebIDEFileUpdate( -- 749
			path, -- 749
			true, -- 749
			encodeJson(questionnaire) -- 749
		) -- 749
		return true -- 750
	end -- 750
	Content:remove(tempPath) -- 752
	if hadOriginal and Content:exist(backupPath) then -- 752
		Content:move(backupPath, path) -- 754
	end -- 754
	return false -- 756
end -- 756
function removePendingQuestionnaire(session) -- 759
	local path = getQuestionnairePath(session.projectRoot) -- 760
	if not Content:exist(path) then -- 760
		return true -- 761
	end -- 761
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 762
	if questionnaire and questionnaire.sessionId ~= session.id then -- 762
		return false -- 763
	end -- 763
	if not Content:remove(path) then -- 763
		return false -- 764
	end -- 764
	Tools.sendWebIDEFileUpdate(path, false, "") -- 765
	return true -- 766
end -- 766
function publishQuestionnaire(request) -- 769
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 769
		local session = getSessionItem(request.sessionId) -- 775
		if not session or session.kind ~= "main" then -- 775
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 775
		end -- 775
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 777
		if Content:exist(pendingPath) then -- 777
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 777
		end -- 777
		local questionnaire = { -- 779
			id = request.taskId, -- 780
			sessionId = request.sessionId, -- 781
			taskId = request.taskId, -- 782
			step = request.step, -- 783
			status = "PENDING", -- 784
			schema = request.schema, -- 785
			createdAt = now() -- 786
		} -- 786
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 786
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 786
		end -- 786
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 786
	end) -- 786
end -- 786
function getMessageItem(messageId) -- 794
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 795
	return row and rowToMessage(row) or nil -- 801
end -- 801
function getStepItem(sessionId, taskId, step) -- 804
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 805
	return row and rowToStep(row) or nil -- 811
end -- 811
function deleteMessageSteps(sessionId, taskId) -- 814
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 815
	local ids = {} -- 820
	do -- 820
		local i = 0 -- 821
		while i < #rows do -- 821
			local row = rows[i + 1] -- 822
			if type(row[1]) == "number" then -- 822
				ids[#ids + 1] = row[1] -- 824
			end -- 824
			i = i + 1 -- 821
		end -- 821
	end -- 821
	if #ids > 0 then -- 821
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 828
	end -- 828
	return ids -- 834
end -- 834
function normalizeDisabledAgentTools(value) -- 837
	if not __TS__ArrayIsArray(value) then -- 837
		return {} -- 838
	end -- 838
	local tools = {} -- 839
	do -- 839
		local i = 0 -- 840
		while i < #value do -- 840
			do -- 840
				local name = value[i + 1] -- 841
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 841
					goto __continue119 -- 842
				end -- 842
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 842
					tools[#tools + 1] = name -- 843
				end -- 843
			end -- 843
			::__continue119:: -- 843
			i = i + 1 -- 840
		end -- 840
	end -- 840
	return tools -- 845
end -- 845
function normalizeWorkMode(value, fallback) -- 848
	if fallback == nil then -- 848
		fallback = "code" -- 848
	end -- 848
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 849
end -- 849
function getSessionRow(sessionId) -- 852
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 853
end -- 853
function getSessionItem(sessionId) -- 861
	local row = getSessionRow(sessionId) -- 862
	return row and rowToSession(row) or nil -- 863
end -- 863
function getTaskPrompt(taskId) -- 866
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 867
	if not row or type(row[1]) ~= "string" then -- 867
		return nil -- 868
	end -- 868
	return toStr(row[1]) -- 869
end -- 869
function getLatestMainSessionByProjectRoot(projectRoot) -- 872
	if not isValidProjectRoot(projectRoot) then -- 872
		return nil -- 873
	end -- 873
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 874
	return row and rowToSession(row) or nil -- 882
end -- 882
function countRunningSubSessions(rootSessionId) -- 885
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 886
	local count = 0 -- 893
	do -- 893
		local i = 0 -- 894
		while i < #rows do -- 894
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 895
			if session.currentTaskStatus == "RUNNING" then -- 895
				count = count + 1 -- 897
			end -- 897
			i = i + 1 -- 894
		end -- 894
	end -- 894
	return count -- 900
end -- 900
function deleteSessionRecords(sessionId, preserveArtifacts) -- 903
	if preserveArtifacts == nil then -- 903
		preserveArtifacts = false -- 903
	end -- 903
	local session = getSessionItem(sessionId) -- 904
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 905
	local taskIds = {} -- 913
	do -- 913
		local i = 0 -- 914
		while i < #taskRows do -- 914
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 915
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 915
				taskIds[#taskIds + 1] = taskId -- 917
				local stopToken = activeStopTokens[taskId] -- 918
				if stopToken ~= nil then -- 918
					stopToken.stopped = true -- 920
					stopToken.reason = "session deleted" -- 921
				end -- 921
			end -- 921
			i = i + 1 -- 914
		end -- 914
	end -- 914
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 925
	do -- 925
		local i = 0 -- 926
		while i < #children do -- 926
			local row = children[i + 1] -- 927
			if type(row[1]) == "number" and row[1] > 0 then -- 927
				deleteSessionRecords(row[1], preserveArtifacts) -- 929
			end -- 929
			i = i + 1 -- 926
		end -- 926
	end -- 926
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 932
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 933
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 934
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 935
	if session and session.kind == "main" then -- 935
		removePendingQuestionnaire(session) -- 937
	end -- 937
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 937
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 937
			Tools.sendWebIDERefreshTree() -- 941
		end -- 941
	end -- 941
	do -- 941
		local i = 0 -- 944
		while i < #taskIds do -- 944
			cleanupTaskHeavyData(taskIds[i + 1]) -- 945
			i = i + 1 -- 944
		end -- 944
	end -- 944
end -- 944
function getSessionRootId(session) -- 949
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 950
end -- 950
function getRootSessionItem(sessionId) -- 953
	local session = getSessionItem(sessionId) -- 954
	if not session then -- 954
		return nil -- 955
	end -- 955
	return getSessionItem(getSessionRootId(session)) or session -- 956
end -- 956
function listRelatedSessions(sessionId) -- 959
	local root = getRootSessionItem(sessionId) -- 960
	if not root then -- 960
		return {} -- 961
	end -- 961
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 962
	return __TS__ArrayMap( -- 971
		rows, -- 971
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 971
	) -- 971
end -- 971
function getSessionSpawnInfo(session) -- 974
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 975
	if not info then -- 975
		return nil -- 976
	end -- 976
	local ____temp_15 = type(info.sessionId) == "number" and info.sessionId or nil -- 978
	local ____temp_16 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 979
	local ____temp_17 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 980
	local ____temp_18 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 981
	local ____temp_19 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 982
	local ____temp_20 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 983
	local ____temp_21 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 984
	local ____temp_22 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 985
		__TS__ArrayFilter( -- 986
			info.filesHint, -- 986
			function(____, item) return type(item) == "string" end -- 986
		), -- 986
		function(____, item) return sanitizeUTF8(item) end -- 986
	) or nil -- 986
	local ____temp_23 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 988
	local ____temp_13 -- 991
	if info.success == true then -- 991
		____temp_13 = true -- 991
	else -- 991
		local ____temp_12 -- 991
		if info.success == false then -- 991
			____temp_12 = false -- 991
		else -- 991
			____temp_12 = nil -- 991
		end -- 991
		____temp_13 = ____temp_12 -- 991
	end -- 991
	local ____temp_14 -- 992
	if info.cleared == true then -- 992
		____temp_14 = true -- 992
	else -- 992
		____temp_14 = nil -- 992
	end -- 992
	return { -- 977
		sessionId = ____temp_15, -- 978
		rootSessionId = ____temp_16, -- 979
		parentSessionId = ____temp_17, -- 980
		title = ____temp_18, -- 981
		prompt = ____temp_19, -- 982
		goal = ____temp_20, -- 983
		expectedOutput = ____temp_21, -- 984
		filesHint = ____temp_22, -- 985
		status = ____temp_23, -- 988
		success = ____temp_13, -- 991
		cleared = ____temp_14, -- 992
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 993
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 994
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 995
		changeSet = decodeChangeSetSummary(info.changeSet), -- 996
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 997
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 998
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 999
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 1000
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 1003
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 1004
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 1005
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 1006
	} -- 1006
end -- 1006
function ensureDirRecursive(dir) -- 1023
	if dir == "" then -- 1023
		return false -- 1024
	end -- 1024
	if Content:exist(dir) then -- 1024
		return Content:isdir(dir) -- 1025
	end -- 1025
	local parent = Path:getPath(dir) -- 1026
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1026
		if not ensureDirRecursive(parent) then -- 1026
			return false -- 1029
		end -- 1029
	end -- 1029
	return Content:mkdir(dir) -- 1032
end -- 1032
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1035
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1036
	if not Content:exist(dir) then -- 1036
		ensureDirRecursive(dir) -- 1038
	end -- 1038
	local path = Path(dir, SPAWN_INFO_FILE) -- 1040
	local text = safeJsonEncode(value) -- 1041
	if not text then -- 1041
		return false -- 1042
	end -- 1042
	local content = text .. "\n" -- 1043
	if not Content:save(path, content) then -- 1043
		return false -- 1045
	end -- 1045
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1047
	return true -- 1048
end -- 1048
function readSpawnInfo(projectRoot, memoryScope) -- 1051
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1052
	if not Content:exist(path) then -- 1052
		return nil -- 1053
	end -- 1053
	local text = Content:load(path) -- 1054
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1054
		return nil -- 1055
	end -- 1055
	local value = safeJsonDecode(text) -- 1056
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1056
		return value -- 1058
	end -- 1058
	return nil -- 1060
end -- 1060
function getArtifactRelativeDir(memoryScope) -- 1063
	return Path(".agent", memoryScope) -- 1064
end -- 1064
function getArtifactDir(projectRoot, memoryScope) -- 1067
	return Path( -- 1068
		projectRoot, -- 1068
		getArtifactRelativeDir(memoryScope) -- 1068
	) -- 1068
end -- 1068
function getResultRelativePath(memoryScope) -- 1071
	return Path( -- 1072
		getArtifactRelativeDir(memoryScope), -- 1072
		RESULT_FILE -- 1072
	) -- 1072
end -- 1072
function getResultPath(projectRoot, memoryScope) -- 1075
	return Path( -- 1076
		projectRoot, -- 1076
		getResultRelativePath(memoryScope) -- 1076
	) -- 1076
end -- 1076
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1079
	if resultFilePath == "" then -- 1079
		return "" -- 1080
	end -- 1080
	local path = Path(projectRoot, resultFilePath) -- 1081
	if not Content:exist(path) then -- 1081
		return "" -- 1082
	end -- 1082
	local text = sanitizeUTF8(Content:load(path)) -- 1083
	if __TS__StringTrim(text) == "" then -- 1083
		return "" -- 1084
	end -- 1084
	local marker = "\n## Summary\n" -- 1085
	local start = string.find(text, marker, 1, true) -- 1086
	if start ~= nil then -- 1086
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1088
	end -- 1088
	return __TS__StringTrim(text) -- 1090
end -- 1090
function buildStructuredSubAgentMemoryEntry(record) -- 1093
	local hasPassedValidation = false -- 1094
	do -- 1094
		local i = 0 -- 1095
		while i < #record.completion.validation do -- 1095
			local result = record.completion.validation[i + 1].result -- 1096
			if result == "failed" then -- 1096
				return nil -- 1101
			end -- 1101
			if result == "passed" then -- 1101
				hasPassedValidation = true -- 1103
			end -- 1103
			i = i + 1 -- 1095
		end -- 1095
	end -- 1095
	if not hasPassedValidation then -- 1095
		return nil -- 1106
	end -- 1106
	local candidates = record.completion.learningCandidates -- 1107
	local claims = {} -- 1108
	local evidence = {} -- 1109
	do -- 1109
		local i = 0 -- 1110
		while i < #candidates do -- 1110
			do -- 1110
				local candidate = candidates[i + 1] -- 1111
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1111
					goto __continue190 -- 1112
				end -- 1112
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1113
				do -- 1113
					local j = 0 -- 1114
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1114
						local item = candidate.evidence[j + 1] -- 1115
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1115
							evidence[#evidence + 1] = item -- 1116
						end -- 1116
						j = j + 1 -- 1114
					end -- 1114
				end -- 1114
			end -- 1114
			::__continue190:: -- 1114
			i = i + 1 -- 1110
		end -- 1110
	end -- 1110
	local content = takeUtf8Head( -- 1119
		table.concat(claims, "\n"), -- 1119
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1119
	) -- 1119
	if content == "" then -- 1119
		return nil -- 1120
	end -- 1120
	return { -- 1121
		sourceSessionId = record.sessionId, -- 1122
		sourceTaskId = record.sourceTaskId, -- 1123
		content = content, -- 1124
		evidence = evidence, -- 1125
		createdAt = record.finishedAt -- 1126
	} -- 1126
end -- 1126
function containsNormalizedText(text, query) -- 1130
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1131
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1132
	if normalizedQuery == "" then -- 1132
		return true -- 1133
	end -- 1133
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1134
end -- 1134
function getSubAgentDisplayKey(item) -- 1137
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1143
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1144
	local label = goal ~= "" and goal or title -- 1145
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1146
end -- 1146
function writeSubAgentResultFile(session, record, resultText) -- 1149
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1150
	if not Content:exist(dir) then -- 1150
		ensureDirRecursive(dir) -- 1152
	end -- 1152
	local ____array_32 = __TS__SparseArrayNew( -- 1152
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1155
		"- Status: " .. record.status, -- 1156
		"- Success: " .. (record.success and "true" or "false"), -- 1157
		"- Outcome: " .. record.completion.outcome, -- 1158
		"- Session ID: " .. tostring(record.sessionId), -- 1159
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1160
		"- Goal: " .. record.goal, -- 1161
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1162
	) -- 1162
	__TS__SparseArrayPush( -- 1162
		____array_32, -- 1162
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1163
	) -- 1163
	__TS__SparseArrayPush( -- 1163
		____array_32, -- 1163
		"- Finished At: " .. record.finishedAt, -- 1164
		"", -- 1165
		"## Validation", -- 1166
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1167
			record.completion.validation, -- 1168
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1168
		) or ({"- Not reported"})) -- 1168
	) -- 1168
	__TS__SparseArrayPush(____array_32, "", "## Recorded Evidence") -- 1168
	local ____opt_24 = record.handoffEvidence -- 1168
	__TS__SparseArrayPush( -- 1168
		____array_32, -- 1168
		table.unpack(____opt_24 and #____opt_24.modifiedFiles and __TS__ArrayMap( -- 1172
			record.handoffEvidence.modifiedFiles, -- 1173
			function(____, item) return "- modified: " .. item end -- 1173
		) or ({"- modified: none recorded"})) -- 1173
	) -- 1173
	local ____opt_26 = record.handoffEvidence -- 1173
	__TS__SparseArrayPush( -- 1173
		____array_32, -- 1173
		table.unpack(____opt_26 and ____opt_26.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1175
	) -- 1175
	local ____opt_28 = record.handoffEvidence -- 1175
	__TS__SparseArrayPush( -- 1175
		____array_32, -- 1175
		table.unpack(__TS__ArrayMap( -- 1178
			____opt_28 and ____opt_28.commands or ({}), -- 1178
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1178
		)) -- 1178
	) -- 1178
	local ____opt_30 = record.handoffEvidence -- 1178
	__TS__SparseArrayPush( -- 1178
		____array_32, -- 1178
		table.unpack(__TS__ArrayMap( -- 1179
			____opt_30 and ____opt_30.authoritativeSources or ({}), -- 1179
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1179
		)) -- 1179
	) -- 1179
	__TS__SparseArrayPush( -- 1179
		____array_32, -- 1179
		"", -- 1180
		"## Known Issues", -- 1181
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1182
			record.completion.knownIssues, -- 1182
			function(____, item) return "- " .. item end -- 1182
		) or ({"- None reported"})) -- 1182
	) -- 1182
	__TS__SparseArrayPush( -- 1182
		____array_32, -- 1182
		"", -- 1183
		"## Assumptions", -- 1184
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1185
			record.completion.assumptions, -- 1185
			function(____, item) return "- " .. item end -- 1185
		) or ({"- None reported"})) -- 1185
	) -- 1185
	__TS__SparseArrayPush(____array_32, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1185
	local lines = {__TS__SparseArraySpread(____array_32)} -- 1154
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1190
	local content = table.concat(lines, "\n") .. "\n" -- 1191
	if not Content:save(path, content) then -- 1191
		return false -- 1193
	end -- 1193
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1195
	return true -- 1196
end -- 1196
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1199
	local dir = Path(projectRoot, ".agent", "subagents") -- 1200
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1200
		return {} -- 1201
	end -- 1201
	local items = {} -- 1202
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1203
		do -- 1203
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1204
			if not Content:exist(path) or not Content:isdir(path) then -- 1204
				goto __continue210 -- 1205
			end -- 1205
			local info = readSpawnInfo( -- 1206
				projectRoot, -- 1206
				Path( -- 1206
					"subagents", -- 1206
					Path:getFilename(path) -- 1206
				) -- 1206
			) -- 1206
			if not info then -- 1206
				goto __continue210 -- 1207
			end -- 1207
			local sessionId = tonumber(info.sessionId) -- 1208
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1209
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1210
			local status = sanitizeUTF8(toStr(info.status)) -- 1211
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1211
				goto __continue210 -- 1212
			end -- 1212
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1212
				goto __continue210 -- 1213
			end -- 1213
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1214
			items[#items + 1] = { -- 1215
				sessionId = sessionId, -- 1216
				rootSessionId = infoRootSessionId, -- 1217
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1218
				title = sanitizeUTF8(toStr(info.title)), -- 1219
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1220
				goal = sanitizeUTF8(toStr(info.goal)), -- 1221
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1222
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1223
					__TS__ArrayFilter( -- 1224
						info.filesHint, -- 1224
						function(____, item) return type(item) == "string" end -- 1224
					), -- 1224
					function(____, item) return sanitizeUTF8(item) end -- 1224
				) or ({}), -- 1224
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1226
				success = info.success == true, -- 1227
				cleared = info.cleared == true, -- 1228
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1229
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1230
					"subagents", -- 1230
					Path:getFilename(path) -- 1230
				)), -- 1230
				sourceTaskId = sourceTaskId or 0, -- 1231
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1232
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1233
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1234
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1235
				completion = normalizeAgentCompletionReport(info.completion), -- 1236
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1237
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1238
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1239
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1240
			} -- 1240
		end -- 1240
		::__continue210:: -- 1240
	end -- 1240
	__TS__ArraySort( -- 1243
		items, -- 1243
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1243
	) -- 1243
	return items -- 1244
end -- 1244
function getPendingHandoffDir(projectRoot, memoryScope) -- 1247
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1248
end -- 1248
function writePendingHandoff(projectRoot, memoryScope, value) -- 1251
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1252
	if not Content:exist(dir) then -- 1252
		ensureDirRecursive(dir) -- 1254
	end -- 1254
	local path = Path(dir, value.id .. ".json") -- 1256
	local text = safeJsonEncode(value) -- 1257
	if not text then -- 1257
		return false -- 1258
	end -- 1258
	local content = text .. "\n" -- 1259
	if not Content:save(path, content) then -- 1259
		return false -- 1260
	end -- 1260
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1261
	return true -- 1262
end -- 1262
function listPendingHandoffs(projectRoot, memoryScope) -- 1265
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1266
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1266
		return {} -- 1267
	end -- 1267
	local items = {} -- 1268
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1269
		do -- 1269
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1270
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1270
				goto __continue226 -- 1271
			end -- 1271
			local text = Content:load(path) -- 1272
			if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1272
				goto __continue226 -- 1273
			end -- 1273
			local obj = safeJsonDecode(text) -- 1274
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1274
				goto __continue226 -- 1275
			end -- 1275
			local value = obj -- 1276
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1277
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1278
			local id = sanitizeUTF8(toStr(value.id)) -- 1279
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1280
			local message = sanitizeUTF8(toStr(value.message)) -- 1281
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1282
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1283
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1284
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1284
				goto __continue226 -- 1286
			end -- 1286
			items[#items + 1] = { -- 1288
				id = id, -- 1289
				sourceSessionId = sourceSessionId, -- 1290
				sourceTitle = sourceTitle, -- 1291
				sourceTaskId = sourceTaskId, -- 1292
				message = message, -- 1293
				prompt = prompt, -- 1294
				goal = goal, -- 1295
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1296
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1297
					__TS__ArrayFilter( -- 1298
						value.filesHint, -- 1298
						function(____, item) return type(item) == "string" end -- 1298
					), -- 1298
					function(____, item) return sanitizeUTF8(item) end -- 1298
				) or ({}), -- 1298
				success = value.success == true, -- 1300
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1301
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1302
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1303
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1304
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1305
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1306
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1307
				createdAt = createdAt -- 1310
			} -- 1310
		end -- 1310
		::__continue226:: -- 1310
	end -- 1310
	__TS__ArraySort( -- 1313
		items, -- 1313
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1313
	) -- 1313
	return items -- 1314
end -- 1314
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1317
	local path = Path( -- 1318
		getPendingHandoffDir(projectRoot, memoryScope), -- 1318
		id .. ".json" -- 1318
	) -- 1318
	if Content:exist(path) then -- 1318
		if Content:remove(path) then -- 1318
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1321
		end -- 1321
	end -- 1321
end -- 1321
function normalizePromptText(prompt) -- 1326
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1327
end -- 1327
function normalizePromptTextSafe(prompt) -- 1330
	if type(prompt) == "string" then -- 1330
		local normalized = normalizePromptText(prompt) -- 1332
		if normalized ~= "" then -- 1332
			return normalized -- 1333
		end -- 1333
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1334
		if sanitized ~= "" then -- 1334
			return truncateAgentUserPrompt(sanitized) -- 1336
		end -- 1336
		return "" -- 1338
	end -- 1338
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1340
	if text == "" then -- 1340
		return "" -- 1341
	end -- 1341
	return truncateAgentUserPrompt(text) -- 1342
end -- 1342
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1345
	local sections = {} -- 1346
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1347
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1348
	local normalizedFiles = __TS__ArrayFilter( -- 1349
		__TS__ArrayMap( -- 1349
			__TS__ArrayFilter( -- 1349
				filesHint or ({}), -- 1349
				function(____, item) return type(item) == "string" end -- 1350
			), -- 1350
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1351
		), -- 1351
		function(____, item) return item ~= "" end -- 1352
	) -- 1352
	if normalizedTitle ~= "" then -- 1352
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1354
	end -- 1354
	if normalizedExpected ~= "" then -- 1354
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1357
	end -- 1357
	if #normalizedFiles > 0 then -- 1357
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1360
	end -- 1360
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1362
end -- 1362
function normalizeSessionRuntimeState(session) -- 1365
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1365
		return session -- 1367
	end -- 1367
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1367
		return session -- 1370
	end -- 1370
	if activeLocalAgentControls[session.currentTaskId] ~= nil then -- 1370
		return session -- 1373
	end -- 1373
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1375
		session.id, -- 1378
		session.currentTaskId, -- 1378
		"fetch_url", -- 1378
		"execute_command", -- 1378
		"analyze_image" -- 1378
	}) or ({}) -- 1378
	if #pendingToolRows > 0 then -- 1378
		local t = now() -- 1381
		do -- 1381
			local i = 0 -- 1382
			while i < #pendingToolRows do -- 1382
				local row = pendingToolRows[i + 1] -- 1383
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1384
				result.success = false -- 1385
				result.state = "failed" -- 1386
				result.interrupted = true -- 1387
				result.message = "tool call was interrupted because the program exited before it completed." -- 1388
				DB:exec( -- 1389
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1389
					{ -- 1391
						encodeJson(result), -- 1391
						t, -- 1391
						row[1] -- 1391
					} -- 1391
				) -- 1391
				i = i + 1 -- 1382
			end -- 1382
		end -- 1382
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1394
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1395
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1396
	end -- 1396
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1403
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1404
	return __TS__ObjectAssign( -- 1405
		{}, -- 1405
		session, -- 1406
		{ -- 1405
			status = "STOPPED", -- 1407
			currentTaskStatus = "STOPPED", -- 1408
			updatedAt = now() -- 1409
		} -- 1409
	) -- 1409
end -- 1409
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1413
	DB:exec( -- 1414
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1414
		{ -- 1418
			status, -- 1419
			currentTaskId or 0, -- 1420
			currentTaskStatus or status, -- 1421
			now(), -- 1422
			sessionId -- 1423
		} -- 1423
	) -- 1423
end -- 1423
function mergeAgentMetrics(current, next) -- 1428
	return __TS__ObjectAssign({}, current or ({}), next) -- 1429
end -- 1429
function updateSessionMetrics(sessionId, metrics) -- 1435
	local session = getSessionItem(sessionId) -- 1436
	if not session then -- 1436
		return nil -- 1437
	end -- 1437
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1438
	DB:exec( -- 1439
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1439
		{ -- 1443
			encodeJson(merged), -- 1444
			now(), -- 1445
			sessionId -- 1446
		} -- 1446
	) -- 1446
	return merged -- 1449
end -- 1449
function clearSessionTokenUsage(sessionId) -- 1452
	local session = getSessionItem(sessionId) -- 1453
	if not session then -- 1453
		return nil -- 1454
	end -- 1454
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1455
	__TS__Delete(metrics, "usage") -- 1456
	__TS__Delete(metrics, "visionUsage") -- 1457
	DB:exec( -- 1458
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1458
		{ -- 1462
			encodeJson(metrics), -- 1463
			now(), -- 1464
			sessionId -- 1465
		} -- 1465
	) -- 1465
	return metrics -- 1468
end -- 1468
function getInitialTokenUsage(session) -- 1471
	local ____opt_33 = session.metrics -- 1471
	local usage = ____opt_33 and ____opt_33.usage -- 1472
	if not usage or (usage.requestCount or 0) <= 0 then -- 1472
		return nil -- 1473
	end -- 1473
	return { -- 1474
		inputTokens = usage.inputTokens or 0, -- 1475
		outputTokens = usage.outputTokens or 0, -- 1476
		totalTokens = usage.totalTokens, -- 1477
		cachedInputTokens = usage.cachedInputTokens, -- 1478
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1479
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1480
		requestCount = usage.requestCount or 0, -- 1481
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1482
		model = usage.model or "", -- 1483
		phase = usage.phase or "", -- 1484
		step = usage.step or 0, -- 1485
		updatedAt = usage.updatedAt or now() -- 1486
	} -- 1486
end -- 1486
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1490
	if taskId == nil or taskId <= 0 then -- 1490
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1492
		return -- 1493
	end -- 1493
	local row = getSessionRow(sessionId) -- 1495
	if not row then -- 1495
		return -- 1496
	end -- 1496
	local session = rowToSession(row) -- 1497
	if session.currentTaskId ~= taskId then -- 1497
		Log( -- 1499
			"Info", -- 1499
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1499
		) -- 1499
		return -- 1500
	end -- 1500
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1502
end -- 1502
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1505
	local t = now() -- 1506
	DB:exec( -- 1507
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1507
		{ -- 1510
			sessionId, -- 1511
			taskId or 0, -- 1512
			role, -- 1513
			sanitizeUTF8(content), -- 1514
			displayContent and sanitizeUTF8(displayContent) or "", -- 1515
			t, -- 1516
			t -- 1517
		} -- 1517
	) -- 1517
	return getLastInsertRowId() -- 1520
end -- 1520
function updateMessage(messageId, content) -- 1523
	DB:exec( -- 1524
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1524
		{ -- 1526
			sanitizeUTF8(content), -- 1526
			now(), -- 1526
			messageId -- 1526
		} -- 1526
	) -- 1526
end -- 1526
function updateUserMessageForTask(messageId, content, taskId) -- 1530
	DB:exec( -- 1531
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1531
		{ -- 1535
			sanitizeUTF8(content), -- 1535
			taskId, -- 1535
			now(), -- 1535
			messageId -- 1535
		} -- 1535
	) -- 1535
end -- 1535
function removeContinuableTaskSummary(session) -- 1592
	local taskId = session.currentTaskId -- 1593
	if taskId == nil then -- 1593
		return -- 1594
	end -- 1594
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1595
end -- 1595
function upsertAssistantMessage(sessionId, taskId, content) -- 1607
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1608
	if row and type(row[1]) == "number" then -- 1608
		updateMessage(row[1], content) -- 1615
		return row[1] -- 1616
	end -- 1616
	return insertMessage(sessionId, "assistant", content, taskId) -- 1618
end -- 1618
function upsertStep(sessionId, taskId, step, tool, patch) -- 1621
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1631
	local reason = sanitizeUTF8(patch.reason or "") -- 1635
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1636
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1637
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1638
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1639
	local statusPatch = patch.status or "" -- 1640
	local status = patch.status or "PENDING" -- 1641
	if not row then -- 1641
		local t = now() -- 1643
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1644
			sessionId, -- 1648
			taskId, -- 1649
			step, -- 1650
			tool, -- 1651
			status, -- 1652
			reason, -- 1653
			reasoningContent, -- 1654
			paramsJson, -- 1655
			resultJson, -- 1656
			patch.checkpointId or 0, -- 1657
			patch.checkpointSeq or 0, -- 1658
			filesJson, -- 1659
			t, -- 1660
			t -- 1661
		}) -- 1661
		return -- 1664
	end -- 1664
	DB:exec( -- 1666
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1666
		{ -- 1678
			tool, -- 1679
			statusPatch, -- 1680
			status, -- 1681
			reason, -- 1682
			reason, -- 1683
			reasoningContent, -- 1684
			reasoningContent, -- 1685
			paramsJson, -- 1686
			paramsJson, -- 1687
			resultJson, -- 1688
			resultJson, -- 1689
			patch.checkpointId or 0, -- 1690
			patch.checkpointId or 0, -- 1691
			patch.checkpointSeq or 0, -- 1692
			patch.checkpointSeq or 0, -- 1693
			filesJson, -- 1694
			filesJson, -- 1695
			now(), -- 1696
			row[1] -- 1697
		} -- 1697
	) -- 1697
end -- 1697
function getNextStepNumber(sessionId, taskId) -- 1702
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1703
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1707
	return math.max(0, current) + 1 -- 1708
end -- 1708
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1749
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1757
	local t = now() -- 1758
	local sqls = { -- 1759
		{ -- 1760
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1760
			{{ -- 1763
				sessionId, -- 1764
				ownerTaskId, -- 1765
				step, -- 1766
				"sub_agent_handoff", -- 1767
				"DONE", -- 1768
				sanitizeUTF8(reason), -- 1769
				encodeJson(params), -- 1770
				encodeJson(result), -- 1771
				t, -- 1772
				t -- 1773
			}} -- 1773
		}, -- 1773
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1776
	} -- 1776
	if not DB:transaction(sqls) then -- 1776
		return nil -- 1782
	end -- 1782
	return getStepItem(sessionId, ownerTaskId, step) -- 1783
end -- 1783
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1786
	if taskId <= 0 then -- 1786
		return -- 1787
	end -- 1787
	if finalSteps ~= nil and finalSteps >= 0 then -- 1787
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1789
	end -- 1789
	if not finalStatus then -- 1789
		return -- 1795
	end -- 1795
	if finalSteps ~= nil and finalSteps >= 0 then -- 1795
		DB:exec( -- 1797
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1797
			{ -- 1801
				finalStatus, -- 1801
				now(), -- 1801
				sessionId, -- 1801
				taskId, -- 1801
				finalSteps -- 1801
			} -- 1801
		) -- 1801
		return -- 1803
	end -- 1803
	DB:exec( -- 1805
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1805
		{ -- 1809
			finalStatus, -- 1809
			now(), -- 1809
			sessionId, -- 1809
			taskId -- 1809
		} -- 1809
	) -- 1809
end -- 1809
function emitAgentSessionPatch(sessionId, patch) -- 1836
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1837
	if not text then -- 1837
		return -- 1842
	end -- 1842
	local failed = publishSessionPatch(sessionId, text) -- 1843
	if failed > 0 then -- 1843
		Log( -- 1844
			"Warn", -- 1844
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 1844
		) -- 1844
	end -- 1844
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 1844
		emit("AppWS", "Send", text) -- 1845
	end -- 1845
end -- 1845
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1848
	emitAgentSessionPatch( -- 1849
		sessionId, -- 1849
		{ -- 1849
			sessionDeleted = true, -- 1850
			relatedSessions = listRelatedSessions(rootSessionId) -- 1851
		} -- 1851
	) -- 1851
	local rootSession = getSessionItem(rootSessionId) -- 1853
	if rootSession then -- 1853
		emitAgentSessionPatch( -- 1855
			rootSessionId, -- 1855
			{ -- 1855
				session = rootSession, -- 1856
				relatedSessions = listRelatedSessions(rootSessionId) -- 1857
			} -- 1857
		) -- 1857
	end -- 1857
end -- 1857
function flushPendingSubAgentHandoffs(rootSession) -- 1862
	if rootSession.kind ~= "main" then -- 1862
		return -- 1863
	end -- 1863
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1863
		return -- 1865
	end -- 1865
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1867
	if #items == 0 then -- 1867
		return -- 1868
	end -- 1868
	local handoffTaskId = 0 -- 1869
	local previousTaskId = rootSession.currentTaskId -- 1870
	local ____rootSession_currentTaskId_37 -- 1871
	if rootSession.currentTaskId then -- 1871
		____rootSession_currentTaskId_37 = getTaskPrompt(rootSession.currentTaskId) -- 1871
	else -- 1871
		____rootSession_currentTaskId_37 = nil -- 1871
	end -- 1871
	local currentTaskPrompt = ____rootSession_currentTaskId_37 -- 1871
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1871
		handoffTaskId = rootSession.currentTaskId -- 1879
	else -- 1879
		local taskRes = Tools.createTask( -- 1881
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1881
			"code" -- 1881
		) -- 1881
		if not taskRes.success then -- 1881
			Log( -- 1883
				"Warn", -- 1883
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1883
			) -- 1883
			return -- 1884
		end -- 1884
		handoffTaskId = taskRes.taskId -- 1886
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1887
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1888
		emitAgentSessionPatch( -- 1889
			rootSession.id, -- 1889
			{session = getSessionItem(rootSession.id)} -- 1889
		) -- 1889
	end -- 1889
	do -- 1889
		local i = 0 -- 1893
		while i < #items do -- 1893
			local item = items[i + 1] -- 1894
			local step = appendHandoffSystemStep( -- 1895
				rootSession.id, -- 1896
				handoffTaskId, -- 1897
				item.sourceTaskId, -- 1898
				item.message, -- 1899
				{ -- 1900
					sourceSessionId = item.sourceSessionId, -- 1901
					sourceTitle = item.sourceTitle, -- 1902
					sourceTaskId = item.sourceTaskId, -- 1903
					success = item.success == true, -- 1904
					summary = item.message, -- 1905
					resultFilePath = item.resultFilePath or "", -- 1906
					artifactDir = item.artifactDir or "", -- 1907
					finishedAt = item.finishedAt or "", -- 1908
					changeSet = item.changeSet, -- 1909
					handoffEvidence = item.handoffEvidence, -- 1910
					memoryEntry = item.memoryEntry, -- 1911
					completion = item.completion -- 1912
				}, -- 1912
				{ -- 1914
					sourceSessionId = item.sourceSessionId, -- 1915
					sourceTitle = item.sourceTitle, -- 1916
					sourceTaskId = item.sourceTaskId, -- 1917
					prompt = item.prompt, -- 1918
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1919
					expectedOutput = item.expectedOutput or "", -- 1920
					filesHint = item.filesHint or ({}), -- 1921
					resultFilePath = item.resultFilePath or "", -- 1922
					artifactDir = item.artifactDir or "", -- 1923
					changeSet = item.changeSet, -- 1924
					handoffEvidence = item.handoffEvidence, -- 1925
					memoryEntry = item.memoryEntry, -- 1926
					completion = item.completion -- 1927
				} -- 1927
			) -- 1927
			if step then -- 1927
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1931
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1932
			else -- 1932
				Log( -- 1934
					"Warn", -- 1934
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1934
				) -- 1934
			end -- 1934
			i = i + 1 -- 1893
		end -- 1893
	end -- 1893
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1893
		cleanupTaskHeavyData(previousTaskId) -- 1938
	end -- 1938
end -- 1938
function applyEvent(sessionId, event) -- 1950
	if not getSessionItem(sessionId) then -- 1950
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1950
			__TS__Delete(activeStopTokens, event.taskId) -- 1953
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1954
		end -- 1954
		return -- 1956
	end -- 1956
	repeat -- 1956
		local ____switch321 = event.type -- 1956
		local metrics, startedSession -- 1956
		local ____cond321 = ____switch321 == "task_started" -- 1956
		if ____cond321 then -- 1956
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1960
			local ____event_resumed_40 -- 1961
			if event.resumed then -- 1961
				local ____opt_38 = getSessionItem(sessionId) -- 1961
				____event_resumed_40 = ____opt_38 and ____opt_38.metrics -- 1962
			else -- 1962
				____event_resumed_40 = clearSessionTokenUsage(sessionId) -- 1963
			end -- 1963
			metrics = ____event_resumed_40 -- 1961
			startedSession = getSessionItem(sessionId) -- 1964
			emitAgentSessionPatch( -- 1965
				sessionId, -- 1965
				{ -- 1965
					session = startedSession, -- 1966
					metrics = metrics, -- 1967
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1968
				} -- 1968
			) -- 1968
			break -- 1972
		end -- 1972
		____cond321 = ____cond321 or ____switch321 == "decision_made" -- 1972
		if ____cond321 then -- 1972
			upsertStep( -- 1974
				sessionId, -- 1974
				event.taskId, -- 1974
				event.step, -- 1974
				event.tool, -- 1974
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1974
			) -- 1974
			emitAgentSessionPatch( -- 1982
				sessionId, -- 1982
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1982
			) -- 1982
			break -- 1985
		end -- 1985
		____cond321 = ____cond321 or ____switch321 == "tool_started" -- 1985
		if ____cond321 then -- 1985
			upsertStep( -- 1987
				sessionId, -- 1987
				event.taskId, -- 1987
				event.step, -- 1987
				event.tool, -- 1987
				{status = "RUNNING"} -- 1987
			) -- 1987
			emitAgentSessionPatch( -- 1990
				sessionId, -- 1990
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1990
			) -- 1990
			break -- 1993
		end -- 1993
		____cond321 = ____cond321 or ____switch321 == "tool_finished" -- 1993
		if ____cond321 then -- 1993
			do -- 1993
				upsertStep( -- 1995
					sessionId, -- 1995
					event.taskId, -- 1995
					event.step, -- 1995
					event.tool, -- 1995
					{status = event.execution.status, reason = event.reason, result = event.result} -- 1995
				) -- 1995
				emitAgentSessionPatch( -- 2003
					sessionId, -- 2003
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2003
				) -- 2003
				break -- 2006
			end -- 2006
		end -- 2006
		____cond321 = ____cond321 or ____switch321 == "tool_progress" -- 2006
		if ____cond321 then -- 2006
			do -- 2006
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 2010
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 2010
					break -- 2012
				end -- 2012
			end -- 2012
			upsertStep( -- 2015
				sessionId, -- 2015
				event.taskId, -- 2015
				event.step, -- 2015
				event.tool, -- 2015
				{status = "RUNNING", result = event.result} -- 2015
			) -- 2015
			emitAgentSessionPatch( -- 2019
				sessionId, -- 2019
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2019
			) -- 2019
			break -- 2022
		end -- 2022
		____cond321 = ____cond321 or ____switch321 == "checkpoint_created" -- 2022
		if ____cond321 then -- 2022
			upsertStep( -- 2024
				sessionId, -- 2024
				event.taskId, -- 2024
				event.step, -- 2024
				event.tool, -- 2024
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2024
			) -- 2024
			emitAgentSessionPatch( -- 2029
				sessionId, -- 2029
				{ -- 2029
					step = getStepItem(sessionId, event.taskId, event.step), -- 2030
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2031
				} -- 2031
			) -- 2031
			break -- 2033
		end -- 2033
		____cond321 = ____cond321 or ____switch321 == "memory_compression_started" -- 2033
		if ____cond321 then -- 2033
			upsertStep( -- 2035
				sessionId, -- 2035
				event.taskId, -- 2035
				event.step, -- 2035
				event.tool, -- 2035
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2035
			) -- 2035
			emitAgentSessionPatch( -- 2040
				sessionId, -- 2040
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2040
			) -- 2040
			break -- 2043
		end -- 2043
		____cond321 = ____cond321 or ____switch321 == "memory_compression_finished" -- 2043
		if ____cond321 then -- 2043
			upsertStep( -- 2045
				sessionId, -- 2045
				event.taskId, -- 2045
				event.step, -- 2045
				event.tool, -- 2045
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2045
			) -- 2045
			emitAgentSessionPatch( -- 2050
				sessionId, -- 2050
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2050
			) -- 2050
			break -- 2053
		end -- 2053
		____cond321 = ____cond321 or ____switch321 == "metrics_updated" -- 2053
		if ____cond321 then -- 2053
			do -- 2053
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2055
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2056
				break -- 2059
			end -- 2059
		end -- 2059
		____cond321 = ____cond321 or ____switch321 == "assistant_message_updated" -- 2059
		if ____cond321 then -- 2059
			do -- 2059
				local pendingKey = streamUpdateKey(sessionId, event.taskId, event.step) -- 2062
				local pending = pendingStreamUpdates[pendingKey] -- 2063
				if pending == nil then -- 2063
					pending = {deltas = 0, lastFlushedLength = -1} -- 2065
					pendingStreamUpdates[pendingKey] = pending -- 2066
				end -- 2066
				pending.deltas = pending.deltas + 1 -- 2068
				pending.content = event.content -- 2069
				pending.reasoningContent = event.reasoningContent -- 2070
				local ____opt_41 = pending.content -- 2070
				local contentLength = ____opt_41 and #____opt_41 or 0 -- 2071
				if pending.lastFlushedLength < 0 or pending.deltas >= STREAM_UPDATE_MAX_DELTAS or contentLength - pending.lastFlushedLength >= STREAM_UPDATE_MIN_BYTES then -- 2071
					pending.deltas = 0 -- 2075
					pending.lastFlushedLength = contentLength -- 2076
					upsertStep( -- 2077
						sessionId, -- 2077
						event.taskId, -- 2077
						event.step, -- 2077
						"message", -- 2077
						{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2077
					) -- 2077
					emitAgentSessionPatch( -- 2082
						sessionId, -- 2082
						{step = getStepItem(sessionId, event.taskId, event.step)} -- 2082
					) -- 2082
				end -- 2082
				break -- 2086
			end -- 2086
		end -- 2086
		____cond321 = ____cond321 or ____switch321 == "assistant_message_finished" -- 2086
		if ____cond321 then -- 2086
			do -- 2086
				__TS__Delete( -- 2089
					pendingStreamUpdates, -- 2089
					streamUpdateKey(sessionId, event.taskId, event.step) -- 2089
				) -- 2089
				upsertStep( -- 2090
					sessionId, -- 2090
					event.taskId, -- 2090
					event.step, -- 2090
					"message", -- 2090
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2090
				) -- 2090
				emitAgentSessionPatch( -- 2096
					sessionId, -- 2096
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2096
				) -- 2096
				break -- 2099
			end -- 2099
		end -- 2099
		____cond321 = ____cond321 or ____switch321 == "task_waiting_for_user" -- 2099
		if ____cond321 then -- 2099
			do -- 2099
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2102
				__TS__Delete(activeStopTokens, event.taskId) -- 2103
				emitAgentSessionPatch( -- 2104
					sessionId, -- 2104
					{ -- 2104
						session = getSessionItem(sessionId), -- 2105
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2106
					} -- 2106
				) -- 2106
				break -- 2108
			end -- 2108
		end -- 2108
		____cond321 = ____cond321 or ____switch321 == "task_finished" -- 2108
		if ____cond321 then -- 2108
			do -- 2108
				local session = getSessionItem(sessionId) -- 2111
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2111
					__TS__Delete(activeStopTokens, event.taskId) -- 2113
					Log( -- 2114
						"Info", -- 2114
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2114
					) -- 2114
					break -- 2115
				end -- 2115
				local ____opt_43 = activeStopTokens[event.taskId or -1] -- 2115
				local stopped = (____opt_43 and ____opt_43.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2117
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2119
				local isSubSession = (session and session.kind) == "sub" -- 2122
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2123
				if isSubSession and event.taskId ~= nil then -- 2123
					finalizingSubSessionTaskIds[event.taskId] = true -- 2125
				end -- 2125
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2127
				if event.taskId ~= nil then -- 2127
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2129
					local ____finalizeTaskSteps_49 = finalizeTaskSteps -- 2130
					local ____array_48 = __TS__SparseArrayNew( -- 2130
						sessionId, -- 2131
						event.taskId, -- 2132
						type(event.steps) == "number" and math.max( -- 2133
							0, -- 2133
							math.floor(event.steps) -- 2133
						) or nil -- 2133
					) -- 2133
					local ____event_success_47 -- 2134
					if event.success then -- 2134
						____event_success_47 = nil -- 2134
					else -- 2134
						____event_success_47 = stopped and "STOPPED" or "FAILED" -- 2134
					end -- 2134
					__TS__SparseArrayPush(____array_48, ____event_success_47) -- 2134
					____finalizeTaskSteps_49(__TS__SparseArraySpread(____array_48)) -- 2130
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2136
					if not isSubSession then -- 2136
						__TS__Delete(activeStopTokens, event.taskId) -- 2138
					end -- 2138
					emitAgentSessionPatch( -- 2140
						sessionId, -- 2140
						{ -- 2140
							session = getSessionItem(sessionId), -- 2141
							message = getMessageItem(messageId), -- 2142
							removedStepIds = removedStepIds -- 2143
						} -- 2143
					) -- 2143
				end -- 2143
				if session and session.kind == "main" then -- 2143
					flushPendingSubAgentHandoffs(session) -- 2147
				end -- 2147
				break -- 2149
			end -- 2149
		end -- 2149
	until true -- 2149
end -- 2149
function ____exports.createSession(projectRoot, title) -- 2154
	if title == nil then -- 2154
		title = "" -- 2154
	end -- 2154
	local storage = requireAgentStorage() -- 2155
	if not storage.success then -- 2155
		return storage -- 2156
	end -- 2156
	if not isValidProjectRoot(projectRoot) then -- 2156
		return {success = false, message = "invalid projectRoot"} -- 2158
	end -- 2158
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2160
	if row then -- 2160
		return { -- 2169
			success = true, -- 2169
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2169
		} -- 2169
	end -- 2169
	local t = now() -- 2171
	DB:exec( -- 2172
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2172
		{ -- 2175
			projectRoot, -- 2175
			title ~= "" and title or Path:getFilename(projectRoot), -- 2175
			t, -- 2175
			t -- 2175
		} -- 2175
	) -- 2175
	local sessionId = getLastInsertRowId() -- 2177
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2178
	local session = getSessionItem(sessionId) -- 2179
	if not session then -- 2179
		return {success = false, message = "failed to create session"} -- 2181
	end -- 2181
	return {success = true, session = session} -- 2183
end -- 2154
function ____exports.createSubSession(parentSessionId, title) -- 2186
	if title == nil then -- 2186
		title = "" -- 2186
	end -- 2186
	local storage = requireAgentStorage() -- 2187
	if not storage.success then -- 2187
		return storage -- 2188
	end -- 2188
	local parent = getSessionItem(parentSessionId) -- 2189
	if not parent then -- 2189
		return {success = false, message = "parent session not found"} -- 2191
	end -- 2191
	local rootId = getSessionRootId(parent) -- 2193
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2193
		return {success = false, message = "project task admission is closed"} -- 2194
	end -- 2194
	local t = now() -- 2195
	DB:exec( -- 2196
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2196
		{ -- 2199
			parent.projectRoot, -- 2199
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2199
			rootId, -- 2199
			parent.id, -- 2199
			t, -- 2199
			t -- 2199
		} -- 2199
	) -- 2199
	local sessionId = getLastInsertRowId() -- 2201
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2202
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2203
	local session = getSessionItem(sessionId) -- 2204
	if not session then -- 2204
		return {success = false, message = "failed to create sub session"} -- 2206
	end -- 2206
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2208
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2209
	subStorage:writeMemory(parentStorage:readMemory()) -- 2210
	return {success = true, session = session} -- 2211
end -- 2186
function spawnSubAgentSession(request) -- 2214
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2214
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2227
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2228
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2229
		if normalizedPrompt == "" then -- 2229
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2231
		end -- 2231
		if normalizedPrompt == "" then -- 2231
			local ____Log_55 = Log -- 2238
			local ____temp_52 = #normalizedTitle -- 2238
			local ____temp_53 = #rawPrompt -- 2238
			local ____temp_54 = #toStr(request.expectedOutput) -- 2238
			local ____opt_50 = request.filesHint -- 2238
			____Log_55( -- 2238
				"Warn", -- 2238
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_52)) .. " raw_prompt_len=") .. tostring(____temp_53)) .. " expected_len=") .. tostring(____temp_54)) .. " files_hint_count=") .. tostring(____opt_50 and #____opt_50 or 0) -- 2238
			) -- 2238
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2238
		end -- 2238
		Log( -- 2241
			"Info", -- 2241
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2241
		) -- 2241
		local parentSessionId = request.parentSessionId -- 2242
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2242
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2244
			if not fallbackParent then -- 2244
				local createdMain = ____exports.createSession(request.projectRoot) -- 2246
				if createdMain.success then -- 2246
					fallbackParent = createdMain.session -- 2248
				end -- 2248
			end -- 2248
			if fallbackParent then -- 2248
				Log( -- 2252
					"Warn", -- 2252
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2252
				) -- 2252
				parentSessionId = fallbackParent.id -- 2253
			end -- 2253
		end -- 2253
		local parentSession = getSessionItem(parentSessionId) -- 2256
		if not parentSession then -- 2256
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2256
		end -- 2256
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2260
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2260
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2260
		end -- 2260
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2260
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2260
		end -- 2260
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2265
		if not created.success then -- 2265
			return ____awaiter_resolve(nil, created) -- 2265
		end -- 2265
		writeSpawnInfo( -- 2269
			created.session.projectRoot, -- 2269
			created.session.memoryScope, -- 2269
			{ -- 2269
				sessionId = created.session.id, -- 2270
				rootSessionId = created.session.rootSessionId, -- 2271
				parentSessionId = created.session.parentSessionId, -- 2272
				title = created.session.title, -- 2273
				prompt = normalizedPrompt, -- 2274
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2275
				expectedOutput = request.expectedOutput or "", -- 2276
				filesHint = request.filesHint or ({}), -- 2277
				status = "RUNNING", -- 2278
				success = false, -- 2279
				resultFilePath = "", -- 2280
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2281
				sourceTaskId = 0, -- 2282
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2283
				createdAtTs = created.session.createdAt, -- 2284
				finishedAt = "", -- 2285
				finishedAtTs = 0 -- 2286
			} -- 2286
		) -- 2286
		local sent = ____exports.sendPrompt( -- 2288
			created.session.id, -- 2288
			normalizedPrompt, -- 2288
			request.disabledAgentTools, -- 2288
			nil, -- 2288
			nil, -- 2288
			request.llmConfig -- 2288
		) -- 2288
		if not sent.success then -- 2288
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2288
		end -- 2288
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2288
	end) -- 2288
end -- 2288
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2409
	local rootSession = getRootSessionItem(session.id) -- 2410
	if not rootSession then -- 2410
		return -- 2411
	end -- 2411
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2412
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2413
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2414
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2415
	local queueResult = writePendingHandoff( -- 2416
		rootSession.projectRoot, -- 2416
		rootSession.memoryScope, -- 2416
		{ -- 2416
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2417
			sourceSessionId = session.id, -- 2418
			sourceTitle = session.title, -- 2419
			sourceTaskId = taskId, -- 2420
			message = summary, -- 2421
			prompt = result.prompt, -- 2422
			goal = result.goal, -- 2423
			expectedOutput = result.expectedOutput or "", -- 2424
			filesHint = result.filesHint or ({}), -- 2425
			success = result.success, -- 2426
			resultFilePath = result.resultFilePath, -- 2427
			artifactDir = result.artifactDir, -- 2428
			finishedAt = result.finishedAt, -- 2429
			changeSet = changeSet, -- 2430
			handoffEvidence = result.handoffEvidence, -- 2431
			memoryEntry = result.memoryEntry, -- 2432
			completion = result.completion, -- 2433
			createdAt = createdAt -- 2434
		} -- 2434
	) -- 2434
	if not queueResult then -- 2434
		Log( -- 2437
			"Warn", -- 2437
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2437
		) -- 2437
		return -- 2438
	end -- 2438
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2438
		addTaskReference(rootSession.currentTaskId, taskId) -- 2441
	end -- 2441
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2441
		flushPendingSubAgentHandoffs(rootSession) -- 2444
	end -- 2444
end -- 2444
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2448
	if forceHandoff == nil then -- 2448
		forceHandoff = false -- 2454
	end -- 2454
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2454
		local rootSessionId = getSessionRootId(session) -- 2456
		local rootSession = getRootSessionItem(session.id) -- 2457
		if not rootSession then -- 2457
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2457
		end -- 2457
		local spawnInfo = getSessionSpawnInfo(session) -- 2461
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2462
		local finishedAtTs = now() -- 2463
		local resultText = sanitizeUTF8(message) -- 2464
		local changeSet = getTaskChangeSetSummary(taskId) -- 2465
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2466
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2467
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2471
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2471
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2473
		end -- 2473
		local completed = success and completionReport.outcome == "completed" -- 2481
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2482
		local record = { -- 2485
			sessionId = session.id, -- 2486
			rootSessionId = rootSessionId, -- 2487
			parentSessionId = session.parentSessionId, -- 2488
			title = session.title, -- 2489
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2490
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2491
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2492
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2493
			status = recordStatus, -- 2494
			success = completed, -- 2495
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2496
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2497
			sourceTaskId = taskId, -- 2498
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2499
			finishedAt = finishedAt, -- 2500
			createdAtTs = session.createdAt, -- 2501
			finishedAtTs = finishedAtTs, -- 2502
			changeSet = changeSet, -- 2503
			handoffEvidence = handoffEvidence, -- 2504
			completion = completionReport -- 2505
		} -- 2505
		local ____record_success_72 -- 2507
		if record.success then -- 2507
			____record_success_72 = buildStructuredSubAgentMemoryEntry(record) -- 2507
		else -- 2507
			____record_success_72 = nil -- 2507
		end -- 2507
		record.memoryEntry = ____record_success_72 -- 2507
		if not writeSubAgentResultFile(session, record, resultText) then -- 2507
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2507
		end -- 2507
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2507
			sessionId = record.sessionId, -- 2512
			rootSessionId = record.rootSessionId, -- 2513
			parentSessionId = record.parentSessionId, -- 2514
			title = record.title, -- 2515
			prompt = record.prompt, -- 2516
			goal = record.goal, -- 2517
			expectedOutput = record.expectedOutput or "", -- 2518
			filesHint = record.filesHint or ({}), -- 2519
			status = record.status, -- 2520
			success = record.success, -- 2521
			resultFilePath = record.resultFilePath, -- 2522
			artifactDir = record.artifactDir, -- 2523
			sourceTaskId = record.sourceTaskId, -- 2524
			createdAt = record.createdAt, -- 2525
			finishedAt = record.finishedAt, -- 2526
			createdAtTs = record.createdAtTs, -- 2527
			finishedAtTs = record.finishedAtTs, -- 2528
			changeSet = record.changeSet, -- 2529
			handoffEvidence = record.handoffEvidence, -- 2530
			memoryEntry = record.memoryEntry, -- 2531
			memoryEntryError = record.memoryEntryError, -- 2532
			completion = record.completion -- 2533
		}) then -- 2533
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2533
		end -- 2533
		if success or forceHandoff then -- 2533
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2538
			deleteSessionRecords(session.id, true) -- 2539
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2540
		end -- 2540
		return ____awaiter_resolve(nil, {success = true}) -- 2540
	end) -- 2540
end -- 2540
function stopClearedSubSession(session, taskId) -- 2545
	local spawnInfo = getSessionSpawnInfo(session) -- 2546
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2547
	local rootSessionId = getSessionRootId(session) -- 2548
	Tools.setTaskStatus(taskId, "STOPPED") -- 2549
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2550
	if not writeSpawnInfo( -- 2550
		session.projectRoot, -- 2551
		session.memoryScope, -- 2551
		{ -- 2551
			sessionId = session.id, -- 2552
			rootSessionId = rootSessionId, -- 2553
			parentSessionId = session.parentSessionId, -- 2554
			title = session.title, -- 2555
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2556
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2557
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2558
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2559
			status = "STOPPED", -- 2560
			success = false, -- 2561
			cleared = true, -- 2562
			resultFilePath = "", -- 2563
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2564
			sourceTaskId = taskId, -- 2565
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2566
			finishedAt = finishedAt, -- 2567
			createdAtTs = session.createdAt, -- 2568
			finishedAtTs = now() -- 2569
		} -- 2569
	) then -- 2569
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2571
	end -- 2571
	deleteSessionRecords(session.id, true) -- 2573
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2574
	return {success = true} -- 2575
end -- 2575
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps) -- 2578
	local session = getSessionItem(sessionId) -- 2579
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2579
		return {success = false, message = "project task admission is closed"} -- 2580
	end -- 2580
	if not session then -- 2580
		return {success = false, message = "session not found"} -- 2582
	end -- 2582
	if getPendingQuestionnaire(sessionId) then -- 2582
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2584
	end -- 2584
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2584
		return {success = false, message = "session task is finalizing"} -- 2586
	end -- 2586
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2586
		return {success = false, message = "session task is still running"} -- 2589
	end -- 2589
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2591
	if normalizedPrompt == "" and session.kind == "sub" then -- 2591
		local spawnInfo = getSessionSpawnInfo(session) -- 2593
		if spawnInfo then -- 2593
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2595
			if normalizedPrompt == "" then -- 2595
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2597
			end -- 2597
		end -- 2597
	end -- 2597
	if normalizedPrompt == "" then -- 2597
		return {success = false, message = "prompt is empty"} -- 2606
	end -- 2606
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2608
	if session.workMode ~= nextWorkMode then -- 2608
		DB:exec( -- 2610
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2610
			{ -- 2610
				nextWorkMode, -- 2610
				now(), -- 2610
				session.id -- 2610
			} -- 2610
		) -- 2610
		session.workMode = nextWorkMode -- 2611
	end -- 2611
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2613
	return startPromptTask( -- 2614
		session, -- 2614
		normalizedPrompt, -- 2614
		nil, -- 2614
		normalizeDisabledAgentTools(disabledAgentTools), -- 2614
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig, maxSteps = boundedMaxSteps} -- 2614
	) -- 2614
end -- 2578
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2748
	if disabledAgentTools == nil then -- 2748
		disabledAgentTools = {} -- 2752
	end -- 2752
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2755
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2755
		return {success = false, message = "project task admission is closed"} -- 2756
	end -- 2756
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2757
	if not llmConfigRes.success then -- 2757
		return {success = false, message = llmConfigRes.message} -- 2761
	end -- 2761
	local llmConfig = llmConfigRes.config -- 2763
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2764
	if not llmConfigValidation.success then -- 2764
		return llmConfigValidation -- 2766
	end -- 2766
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2768
	if not taskRes.success then -- 2768
		return {success = false, message = taskRes.message} -- 2771
	end -- 2771
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2771
		removeContinuableTaskSummary(session) -- 2773
	end -- 2773
	local taskId = taskRes.taskId -- 2775
	local ____temp_93 -- 2776
	if (options and options.existingTaskId) == nil then -- 2776
		____temp_93 = session.currentTaskId -- 2776
	else -- 2776
		____temp_93 = nil -- 2776
	end -- 2776
	local previousTaskId = ____temp_93 -- 2776
	local useChineseResponse = getDefaultUseChineseResponse() -- 2777
	local promptMessageId -- 2778
	if existingUserMessageId ~= nil then -- 2778
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2780
		promptMessageId = existingUserMessageId -- 2781
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2781
		promptMessageId = insertMessage( -- 2783
			session.id, -- 2783
			"user", -- 2783
			normalizedPrompt, -- 2783
			taskId, -- 2783
			options and options.displayContent -- 2783
		) -- 2783
	end -- 2783
	local stopToken = {stopped = false} -- 2785
	activeStopTokens[taskId] = stopToken -- 2786
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2787
	emitAgentSessionPatch( -- 2791
		session.id, -- 2791
		__TS__ObjectAssign( -- 2791
			{session = getSessionItem(session.id)}, -- 2791
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 2793
		) -- 2793
	) -- 2793
	if previousTaskId and previousTaskId ~= taskId then -- 2793
		cleanupTaskHeavyData(previousTaskId) -- 2796
	end -- 2796
	activePromptRuns = activePromptRuns + 1 -- 2798
	local ____runCodingAgent_122 = runCodingAgent -- 2799
	local ____normalizedPrompt_115 = normalizedPrompt -- 2800
	local ____temp_116 = options and options.resumeConversation -- 2801
	local ____temp_117 = (options and options.existingTaskId) ~= nil -- 2802
	local ____temp_118 = options and options.initialStep -- 2803
	local ____temp_119 = options and options.initialAgentStepCount -- 2804
	local ____temp_110 -- 2805
	if (options and options.existingTaskId) ~= nil then -- 2805
		____temp_110 = getInitialTokenUsage(session) -- 2805
	else -- 2805
		____temp_110 = nil -- 2805
	end -- 2805
	____runCodingAgent_122( -- 2799
		{ -- 2799
			prompt = ____normalizedPrompt_115, -- 2800
			resumeConversation = ____temp_116, -- 2801
			resumeTask = ____temp_117, -- 2802
			initialStep = ____temp_118, -- 2803
			initialAgentStepCount = ____temp_119, -- 2804
			initialTokenUsage = ____temp_110, -- 2805
			workDir = session.projectRoot, -- 2806
			useChineseResponse = useChineseResponse, -- 2807
			taskId = taskId, -- 2808
			sessionId = session.id, -- 2809
			memoryScope = session.memoryScope, -- 2810
			role = session.kind, -- 2811
			maxSteps = options and options.maxSteps, -- 2812
			disabledAgentTools = disabledAgentTools, -- 2813
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2814
			llmConfig = llmConfig, -- 2815
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2816
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2819
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2822
			stopToken = stopToken, -- 2823
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2824
		}, -- 2824
		function(result) -- 2825
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2825
				local ____hasReturned, ____returnValue -- 2825
				local ____try = __TS__AsyncAwaiter(function() -- 2825
					local nextSession = getSessionItem(session.id) -- 2827
					if nextSession and nextSession.kind == "sub" then -- 2827
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2827
							local stopped = stopClearedSubSession(nextSession, taskId) -- 2830
							if not stopped.success then -- 2830
								Log( -- 2832
									"Warn", -- 2832
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2832
								) -- 2832
								emitAgentSessionPatch( -- 2833
									session.id, -- 2833
									{session = getSessionItem(session.id)} -- 2833
								) -- 2833
							end -- 2833
							__TS__Delete(activeStopTokens, taskId) -- 2837
							____hasReturned = true -- 2838
							return -- 2838
						end -- 2838
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2840
						emitAgentSessionPatch( -- 2841
							session.id, -- 2841
							{session = getSessionItem(session.id)} -- 2841
						) -- 2841
						local finalized = __TS__Await(finalizeSubSession( -- 2844
							nextSession, -- 2845
							taskId, -- 2846
							result.success, -- 2847
							result.message, -- 2848
							result.completion, -- 2849
							(options and options.forceSubAgentHandoff) == true -- 2850
						)) -- 2850
						if not finalized.success then -- 2850
							Log( -- 2853
								"Warn", -- 2853
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2853
							) -- 2853
						end -- 2853
						local finalizedSession = getSessionItem(session.id) -- 2855
						if finalizedSession then -- 2855
							local stopped = stopToken.stopped == true -- 2857
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2858
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2861
							emitAgentSessionPatch( -- 2862
								session.id, -- 2862
								{session = getSessionItem(session.id)} -- 2862
							) -- 2862
						end -- 2862
						__TS__Delete(activeStopTokens, taskId) -- 2866
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2867
					end -- 2867
					local fallbackSession = getSessionItem(session.id) -- 2869
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2869
						applyEvent(session.id, { -- 2875
							type = "task_finished", -- 2876
							sessionId = session.id, -- 2877
							taskId = result.taskId, -- 2878
							success = false, -- 2879
							message = result.message, -- 2880
							steps = result.steps -- 2881
						}) -- 2881
					end -- 2881
				end) -- 2881
				____try = ____try.finally( -- 2881
					____try, -- 2881
					function() -- 2881
						return __TS__AsyncAwaiter(function() -- 2881
							activePromptRuns = activePromptRuns - 1 -- 2885
						end) -- 2885
					end -- 2885
				) -- 2885
				__TS__Await(____try) -- 2826
				if ____hasReturned then -- 2826
					return ____awaiter_resolve(nil, ____returnValue) -- 2826
				end -- 2826
			end) -- 2826
		end -- 2825
	) -- 2825
	return {success = true, sessionId = session.id, taskId = taskId} -- 2888
end -- 2888
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3041
	local lines = {} -- 3042
	do -- 3042
		local i = 0 -- 3043
		while i < #questionnaire.schema.questions do -- 3043
			local question = questionnaire.schema.questions[i + 1] -- 3044
			local answer = __TS__ArrayFind( -- 3045
				answers, -- 3045
				function(____, item) return item.questionId == question.id end -- 3045
			) -- 3045
			local answerText = "已跳过" -- 3046
			if answer and answer.status == "answered" then -- 3046
				local parts = {} -- 3048
				do -- 3048
					local j = 0 -- 3049
					while j < #(answer.selectedOptionIds or ({})) do -- 3049
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3050
						local option = __TS__ArrayFind( -- 3051
							question.options or ({}), -- 3051
							function(____, item) return item.id == optionId end -- 3051
						) -- 3051
						if option then -- 3051
							parts[#parts + 1] = option.label -- 3052
						end -- 3052
						j = j + 1 -- 3049
					end -- 3049
				end -- 3049
				if answer.otherText then -- 3049
					parts[#parts + 1] = answer.otherText -- 3054
				end -- 3054
				if answer.text then -- 3054
					parts[#parts + 1] = answer.text -- 3055
				end -- 3055
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3056
			end -- 3056
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3058
			i = i + 1 -- 3043
		end -- 3043
	end -- 3043
	return table.concat(lines, "\n\n") -- 3060
end -- 3060
function ____exports.listRunningSubAgents(request) -- 3344
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3344
		local session = getSessionItem(request.sessionId) -- 3352
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3352
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3354
		end -- 3354
		if not session then -- 3354
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3354
		end -- 3354
		local rootSession = getRootSessionItem(session.id) -- 3359
		if not rootSession then -- 3359
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3359
		end -- 3359
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3363
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3364
		local limit = math.max( -- 3365
			1, -- 3365
			math.floor(tonumber(request.limit) or 5) -- 3365
		) -- 3365
		local offset = math.max( -- 3366
			0, -- 3366
			math.floor(tonumber(request.offset) or 0) -- 3366
		) -- 3366
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3367
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3368
		local runningSessions = {} -- 3375
		do -- 3375
			local i = 0 -- 3376
			while i < #rows do -- 3376
				do -- 3376
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3377
					if current.currentTaskStatus ~= "RUNNING" then -- 3377
						goto __continue564 -- 3379
					end -- 3379
					local spawnInfo = getSessionSpawnInfo(current) -- 3381
					runningSessions[#runningSessions + 1] = { -- 3382
						sessionId = current.id, -- 3383
						title = current.title, -- 3384
						parentSessionId = current.parentSessionId, -- 3385
						rootSessionId = current.rootSessionId, -- 3386
						status = "RUNNING", -- 3387
						currentTaskId = current.currentTaskId, -- 3388
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3389
						goal = spawnInfo and spawnInfo.goal, -- 3390
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3391
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3392
						createdAt = current.createdAt, -- 3393
						updatedAt = current.updatedAt -- 3394
					} -- 3394
				end -- 3394
				::__continue564:: -- 3394
				i = i + 1 -- 3376
			end -- 3376
		end -- 3376
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3397
		local completedSessions = __TS__ArrayMap( -- 3398
			completedRecords, -- 3398
			function(____, record) return { -- 3398
				sessionId = record.sessionId, -- 3399
				title = record.title, -- 3400
				parentSessionId = record.parentSessionId, -- 3401
				rootSessionId = record.rootSessionId, -- 3402
				status = record.status, -- 3403
				goal = record.goal, -- 3404
				expectedOutput = record.expectedOutput, -- 3405
				filesHint = record.filesHint, -- 3406
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3407
				success = record.success, -- 3408
				cleared = record.cleared, -- 3409
				resultFilePath = record.resultFilePath, -- 3410
				artifactDir = record.artifactDir, -- 3411
				finishedAt = record.finishedAt, -- 3412
				createdAt = record.createdAtTs, -- 3413
				updatedAt = record.finishedAtTs -- 3414
			} end -- 3414
		) -- 3414
		local merged = {} -- 3416
		if status == "running" then -- 3416
			merged = runningSessions -- 3418
		elseif status == "done" then -- 3418
			merged = __TS__ArrayFilter( -- 3420
				completedSessions, -- 3420
				function(____, item) return item.status == "DONE" end -- 3420
			) -- 3420
		elseif status == "failed" then -- 3420
			merged = __TS__ArrayFilter( -- 3422
				completedSessions, -- 3422
				function(____, item) return item.status == "FAILED" end -- 3422
			) -- 3422
		elseif status == "stopped" then -- 3422
			merged = __TS__ArrayFilter( -- 3424
				completedSessions, -- 3424
				function(____, item) return item.status == "STOPPED" end -- 3424
			) -- 3424
		elseif status == "all" then -- 3424
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3426
		else -- 3426
			local runningKeys = {} -- 3428
			do -- 3428
				local i = 0 -- 3429
				while i < #runningSessions do -- 3429
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3430
					i = i + 1 -- 3429
				end -- 3429
			end -- 3429
			local latestCompletedByKey = {} -- 3432
			do -- 3432
				local i = 0 -- 3433
				while i < #completedSessions do -- 3433
					do -- 3433
						local item = completedSessions[i + 1] -- 3434
						local key = getSubAgentDisplayKey(item) -- 3435
						if runningKeys[key] then -- 3435
							goto __continue579 -- 3437
						end -- 3437
						local current = latestCompletedByKey[key] -- 3439
						if current == nil or item.updatedAt > current.updatedAt then -- 3439
							latestCompletedByKey[key] = item -- 3441
						end -- 3441
					end -- 3441
					::__continue579:: -- 3441
					i = i + 1 -- 3433
				end -- 3433
			end -- 3433
			local latestCompleted = {} -- 3444
			for ____, item in pairs(latestCompletedByKey) do -- 3445
				latestCompleted[#latestCompleted + 1] = item -- 3446
			end -- 3446
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3448
		end -- 3448
		if query ~= "" then -- 3448
			merged = __TS__ArrayFilter( -- 3451
				merged, -- 3451
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3451
			) -- 3451
		end -- 3451
		__TS__ArraySort( -- 3457
			merged, -- 3457
			function(____, a, b) -- 3457
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3457
					return -1 -- 3458
				end -- 3458
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3458
					return 1 -- 3459
				end -- 3459
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3459
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3461
				end -- 3461
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3463
			end -- 3457
		) -- 3457
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3465
		return ____awaiter_resolve(nil, { -- 3465
			success = true, -- 3467
			rootSessionId = rootSession.id, -- 3468
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3469
			status = status, -- 3470
			limit = limit, -- 3471
			offset = offset, -- 3472
			hasMore = offset + limit < #merged, -- 3473
			sessions = paged -- 3474
		}) -- 3474
	end) -- 3474
end -- 3344
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
activePromptRuns = 0 -- 336
pendingStreamUpdates = {} -- 344
STREAM_UPDATE_MAX_DELTAS = 32 -- 349
STREAM_UPDATE_MIN_BYTES = 4096 -- 350
streamUpdateKey = function(sessionId, taskId, step) return (((tostring(sessionId) .. ":") .. tostring(taskId)) .. ":") .. tostring(step) end -- 351
--- Runtime ownership, including asynchronous completion after task status changes.
function ____exports.isRuntimeIdle() -- 355
	return activePromptRuns == 0 and #__TS__ObjectKeys(activeStopTokens) == 0 and #__TS__ObjectKeys(activeLocalAgentControls) == 0 and #__TS__ObjectKeys(finalizingSubSessionTaskIds) == 0 -- 356
end -- 355
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 361
now = function() return os.time() end -- 362
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1010
	if projectRoot == oldRoot then -- 1010
		return newRoot -- 1012
	end -- 1012
	for ____, separator in ipairs({"/", "\\"}) do -- 1014
		local prefix = oldRoot .. separator -- 1015
		if __TS__StringStartsWith(projectRoot, prefix) then -- 1015
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 1017
		end -- 1017
	end -- 1017
	return nil -- 1020
end -- 1010
local function clearSessionAfterMessage(sessionId, message) -- 1539
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1540
	local removedStepIds = {} -- 1548
	do -- 1548
		local i = 0 -- 1549
		while i < #removedStepRows do -- 1549
			local row = removedStepRows[i + 1] -- 1550
			if type(row[1]) == "number" then -- 1550
				removedStepIds[#removedStepIds + 1] = row[1] -- 1552
			end -- 1552
			i = i + 1 -- 1549
		end -- 1549
	end -- 1549
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1555
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1563
	return removedStepIds -- 1568
end -- 1539
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1571
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1572
	local persisted = storage:readSessionState() -- 1573
	local userIndex = -1 -- 1574
	do -- 1574
		local i = #persisted.messages - 1 -- 1575
		while i >= 0 do -- 1575
			if persisted.messages[i + 1].role == "user" then -- 1575
				userIndex = i -- 1577
				break -- 1578
			end -- 1578
			i = i - 1 -- 1575
		end -- 1575
	end -- 1575
	if userIndex < 0 then -- 1575
		return -- 1581
	end -- 1581
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1582
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1583
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1584
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1589
end -- 1571
local function listCurrentTaskCheckpoints(sessionId) -- 1601
	local session = getSessionItem(sessionId) -- 1602
	local taskId = session and session.currentTaskId -- 1603
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1604
end -- 1601
local function getAgentStepCount(sessionId, taskId) -- 1711
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1712
		sessionId, -- 1717
		taskId, -- 1718
		"compress_memory", -- 1719
		"merge_memory", -- 1720
		"sub_agent_handoff", -- 1721
		"questionnaire_answer", -- 1722
		"message" -- 1723
	}) -- 1723
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1726
end -- 1711
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1729
	if status == nil then -- 1729
		status = "DONE" -- 1737
	end -- 1737
	local step = getNextStepNumber(sessionId, taskId) -- 1739
	upsertStep( -- 1740
		sessionId, -- 1740
		taskId, -- 1740
		step, -- 1740
		tool, -- 1740
		{status = status, reason = reason, params = params, result = result} -- 1740
	) -- 1740
	return getStepItem(sessionId, taskId, step) -- 1746
end -- 1729
local function sanitizeStoredSteps(sessionId) -- 1813
	DB:exec( -- 1814
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1814
		{ -- 1832
			now(), -- 1832
			sessionId -- 1832
		} -- 1832
	) -- 1832
end -- 1813
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2300
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2300
		return {success = false, message = "invalid projectRoot"} -- 2302
	end -- 2302
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2304
	for ____, row in ipairs(rows) do -- 2305
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2306
		if sessionId > 0 then -- 2306
			deleteSessionRecords(sessionId) -- 2308
		end -- 2308
	end -- 2308
	return {success = true, deleted = #rows} -- 2311
end -- 2300
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2314
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2314
		return {success = false, message = "invalid projectRoot"} -- 2316
	end -- 2316
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2318
	local renamed = 0 -- 2319
	for ____, row in ipairs(rows) do -- 2320
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2321
		local projectRoot = toStr(row[2]) -- 2322
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2323
		if sessionId > 0 and nextProjectRoot then -- 2323
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2325
			DB:exec( -- 2326
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2326
				{ -- 2328
					nextProjectRoot, -- 2328
					Path:getFilename(nextProjectRoot), -- 2328
					now(), -- 2328
					sessionId -- 2328
				} -- 2328
			) -- 2328
			renamed = renamed + 1 -- 2330
		end -- 2330
	end -- 2330
	return {success = true, renamed = renamed} -- 2333
end -- 2314
function ____exports.getSession(sessionId, view) -- 2336
	local session = getSessionItem(sessionId) -- 2337
	if not session then -- 2337
		return {success = false, message = "session not found"} -- 2339
	end -- 2339
	local restored = restorePendingQuestionnaireState(session) -- 2341
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2342
	local relatedSessions = listRelatedSessions(sessionId) -- 2343
	sanitizeStoredSteps(sessionId) -- 2344
	local firstMessageId = 0 -- 2345
	local hasEarlierMessages = false -- 2346
	if view then -- 2346
		local limit = math.max( -- 2348
			1, -- 2348
			math.min( -- 2348
				1000, -- 2348
				math.floor(view.recentRounds) -- 2348
			) -- 2348
		) -- 2348
		local requests = queryRows(("SELECT id FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND role = 'user'\n\t\t\tORDER BY id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2349
		if #requests > limit then -- 2349
			firstMessageId = requests[limit][1] -- 2354
			hasEarlierMessages = true -- 2355
		end -- 2355
	end -- 2355
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2358
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2365
	local ____relatedSessions_61 = relatedSessions -- 2377
	local ____temp_60 -- 2378
	if normalizedSession.kind == "sub" then -- 2378
		____temp_60 = getSessionSpawnInfo(normalizedSession) -- 2378
	else -- 2378
		____temp_60 = nil -- 2378
	end -- 2378
	return { -- 2374
		success = true, -- 2375
		session = normalizedSession, -- 2376
		relatedSessions = ____relatedSessions_61, -- 2377
		spawnInfo = ____temp_60, -- 2378
		messages = __TS__ArrayMap( -- 2379
			messages, -- 2379
			function(____, row) return rowToMessage(row) end -- 2379
		), -- 2379
		hasEarlierMessages = hasEarlierMessages, -- 2380
		steps = __TS__ArrayMap( -- 2381
			steps, -- 2381
			function(____, row) return rowToStep(row) end -- 2381
		), -- 2381
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2382
		pendingQuestionnaire = restored.questionnaire, -- 2383
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2384
	} -- 2384
end -- 2336
function ____exports.setWorkMode(sessionId, workMode) -- 2389
	local session = getSessionItem(sessionId) -- 2390
	if not session then -- 2390
		return {success = false, message = "session not found"} -- 2391
	end -- 2391
	if session.kind ~= "main" then -- 2391
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2392
	end -- 2392
	if workMode ~= "code" and workMode ~= "plan" then -- 2392
		return {success = false, message = "invalid work mode"} -- 2393
	end -- 2393
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2394
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2394
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2396
	end -- 2396
	if getPendingQuestionnaire(sessionId) then -- 2396
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2399
	end -- 2399
	if normalizedSession.workMode ~= workMode then -- 2399
		DB:exec( -- 2402
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2402
			{ -- 2402
				workMode, -- 2402
				now(), -- 2402
				sessionId -- 2402
			} -- 2402
		) -- 2402
	end -- 2402
	local updated = getSessionItem(sessionId) -- 2404
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2405
	return { -- 2406
		success = true, -- 2406
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2406
	} -- 2406
end -- 2389
function ____exports.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 2617
	local session = getSessionItem(sessionId) -- 2618
	if not session then -- 2618
		return {success = false, message = "session not found"} -- 2619
	end -- 2619
	if session.kind ~= "main" then -- 2619
		return {success = false, message = "local Agent only supports main sessions"} -- 2620
	end -- 2620
	if getPendingQuestionnaire(sessionId) then -- 2620
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2621
	end -- 2621
	if session.currentTaskStatus == "RUNNING" then -- 2621
		return {success = false, message = "session task is still running"} -- 2622
	end -- 2622
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2623
	if normalizedPrompt == "" then -- 2623
		return {success = false, message = "prompt is empty"} -- 2624
	end -- 2624
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2625
	if not config then -- 2625
		return {success = false, message = "local Agent config not found"} -- 2626
	end -- 2626
	if not config.verifiedAt then -- 2626
		return {success = false, message = "local Agent config is not verified"} -- 2627
	end -- 2627
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2628
	if not taskRes.success then -- 2628
		return taskRes -- 2629
	end -- 2629
	local taskId = taskRes.taskId -- 2630
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2631
	Tools.setTaskStatus(taskId, "RUNNING") -- 2632
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2633
	upsertStep( -- 2634
		session.id, -- 2634
		taskId, -- 2634
		1, -- 2634
		"local_agent_message", -- 2634
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2634
	) -- 2634
	emitAgentSessionPatch( -- 2640
		session.id, -- 2640
		{ -- 2640
			session = getSessionItem(session.id), -- 2641
			message = getMessageItem(messageId), -- 2642
			step = getStepItem(session.id, taskId, 1) -- 2643
		} -- 2643
	) -- 2643
	local events = {} -- 2645
	local transcript = "" -- 2646
	local assistant = "" -- 2647
	local lastFlush = 0 -- 2648
	local function flush(force) -- 2649
		if force == nil then -- 2649
			force = false -- 2649
		end -- 2649
		if not force and App.runningTime - lastFlush < 0.075 then -- 2649
			return -- 2650
		end -- 2650
		lastFlush = App.runningTime -- 2651
		if #events > 400 then -- 2651
			events = __TS__ArraySlice(events, #events - 400) -- 2652
		end -- 2652
		if #transcript > 1024 * 1024 then -- 2652
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2653
		end -- 2653
		upsertStep( -- 2654
			session.id, -- 2654
			taskId, -- 2654
			1, -- 2654
			"local_agent_message", -- 2654
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2654
		) -- 2654
		local message -- 2659
		if assistant ~= "" then -- 2659
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2661
			message = getMessageItem(assistantId) -- 2662
		end -- 2662
		emitAgentSessionPatch( -- 2664
			session.id, -- 2664
			__TS__ObjectAssign( -- 2664
				{step = getStepItem(session.id, taskId, 1)}, -- 2664
				message and ({message = message}) or ({}) -- 2664
			) -- 2664
		) -- 2664
	end -- 2649
	local completedSynchronously = false -- 2666
	local control = LocalAgent.run( -- 2667
		session.id, -- 2667
		config, -- 2667
		session.projectRoot, -- 2667
		normalizedPrompt, -- 2667
		function(event) -- 2667
			local text = sanitizeUTF8(event.text) -- 2668
			if text == "" then -- 2668
				return -- 2669
			end -- 2669
			local previous = #events > 0 and events[#events] or nil -- 2670
			if previous and previous.kind == event.kind and previous.text == text then -- 2670
				return -- 2671
			end -- 2671
			events[#events + 1] = {kind = event.kind, text = text} -- 2672
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2673
			if event.kind == "assistant" then -- 2673
				assistant = text -- 2674
			end -- 2674
			flush(false) -- 2675
		end, -- 2667
		function(result) -- 2676
			completedSynchronously = true -- 2677
			flush(true) -- 2678
			__TS__Delete(activeLocalAgentControls, taskId) -- 2679
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2680
			Tools.setTaskStatus(taskId, status) -- 2681
			setSessionState(session.id, status, taskId, status) -- 2682
			upsertStep( -- 2683
				session.id, -- 2683
				taskId, -- 2683
				1, -- 2683
				"local_agent_message", -- 2683
				{status = status, reason = config.name .. " · full permissions", result = { -- 2683
					provider = config.provider, -- 2686
					events = events, -- 2686
					transcript = transcript, -- 2686
					exitCode = result.exitCode, -- 2686
					resumeId = result.resumeId, -- 2686
					message = result.message -- 2686
				}} -- 2686
			) -- 2686
			emitAgentSessionPatch( -- 2688
				session.id, -- 2688
				{ -- 2688
					session = getSessionItem(session.id), -- 2688
					step = getStepItem(session.id, taskId, 1) -- 2688
				} -- 2688
			) -- 2688
		end -- 2676
	) -- 2676
	if not completedSynchronously then -- 2676
		activeLocalAgentControls[taskId] = control -- 2690
	end -- 2690
	return {success = true, sessionId = session.id, taskId = taskId} -- 2691
end -- 2617
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2694
	local session = getSessionItem(sessionId) -- 2695
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2695
		return {success = false, message = "project task admission is closed"} -- 2696
	end -- 2696
	if not session then -- 2696
		return {success = false, message = "session not found"} -- 2698
	end -- 2698
	if getPendingQuestionnaire(sessionId) then -- 2698
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2700
	end -- 2700
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2700
		return {success = false, message = "session task is finalizing"} -- 2702
	end -- 2702
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2702
		return {success = false, message = "session task is still stopping"} -- 2705
	end -- 2705
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2705
		return {success = false, message = "session task is not continuable"} -- 2708
	end -- 2708
	if session.currentTaskId == nil then -- 2708
		return {success = false, message = "session task not found"} -- 2711
	end -- 2711
	local taskId = session.currentTaskId -- 2713
	return startPromptTask( -- 2714
		session, -- 2715
		"", -- 2716
		nil, -- 2717
		normalizeDisabledAgentTools(disabledAgentTools), -- 2718
		{ -- 2719
			workMode = session.workMode, -- 2720
			persistUserMessage = false, -- 2721
			resumeConversation = true, -- 2722
			existingTaskId = taskId, -- 2723
			initialStep = math.max( -- 2724
				0, -- 2724
				getNextStepNumber(session.id, taskId) - 1 -- 2724
			), -- 2724
			initialAgentStepCount = 0, -- 2728
			llmConfigId = llmConfigId -- 2729
		} -- 2729
	) -- 2729
end -- 2694
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2891
	local session = getSessionItem(sessionId) -- 2892
	if not session then -- 2892
		return {success = false, message = "session not found"} -- 2894
	end -- 2894
	if session.kind ~= "sub" then -- 2894
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2897
	end -- 2897
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2897
		return {success = false, message = "session task is finalizing"} -- 2900
	end -- 2900
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2902
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2902
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2907
	end -- 2907
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2907
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2910
	end -- 2910
	local disabledAgentTools = __TS__ArrayFilter( -- 2912
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2912
		function(____, tool) return tool ~= "finish" end -- 2913
	) -- 2913
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2914
	return startPromptTask( -- 2917
		session, -- 2917
		prompt, -- 2917
		nil, -- 2917
		disabledAgentTools, -- 2917
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2917
	) -- 2917
end -- 2891
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2924
	local session = getSessionItem(sessionId) -- 2925
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2925
		return {success = false, message = "project task admission is closed"} -- 2926
	end -- 2926
	if not session then -- 2926
		return {success = false, message = "session not found"} -- 2928
	end -- 2928
	if getPendingQuestionnaire(sessionId) then -- 2928
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2930
	end -- 2930
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2930
		return {success = false, message = "session task is finalizing"} -- 2932
	end -- 2932
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2932
		return {success = false, message = "session task is still running"} -- 2935
	end -- 2935
	local message = getMessageItem(messageId) -- 2937
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2937
		return {success = false, message = "message not found"} -- 2939
	end -- 2939
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2941
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2947
	if latestUserMessageId ~= messageId then -- 2947
		return {success = false, message = "only the latest user prompt can be edited"} -- 2949
	end -- 2949
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2951
	if normalizedPrompt == "" then -- 2951
		return {success = false, message = "prompt is empty"} -- 2953
	end -- 2953
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2955
	if session.workMode ~= nextWorkMode then -- 2955
		DB:exec( -- 2957
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2957
			{ -- 2957
				nextWorkMode, -- 2957
				now(), -- 2957
				session.id -- 2957
			} -- 2957
		) -- 2957
		session.workMode = nextWorkMode -- 2958
	end -- 2958
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2960
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2961
	local result = startPromptTask( -- 2962
		session, -- 2962
		normalizedPrompt, -- 2962
		messageId, -- 2962
		normalizeDisabledAgentTools(disabledAgentTools), -- 2962
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2962
	) -- 2962
	if result.success and #removedStepIds > 0 then -- 2962
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2964
	end -- 2964
	return result -- 2966
end -- 2924
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2971
	if status == "dismissed" then -- 2971
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2977
	end -- 2977
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2979
end -- 2971
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2982
	if status == "dismissed" then -- 2982
		return { -- 2988
			success = true, -- 2989
			status = "dismissed", -- 2990
			source = "user", -- 2991
			questionnaireId = questionnaire.id, -- 2992
			title = questionnaire.schema.title, -- 2993
			answers = {}, -- 2994
			responses = {}, -- 2995
			displayText = "用户关闭了调查问卷，未作答。", -- 2996
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2997
		} -- 2997
	end -- 2997
	local responses = {} -- 3000
	do -- 3000
		local i = 0 -- 3001
		while i < #questionnaire.schema.questions do -- 3001
			do -- 3001
				local question = questionnaire.schema.questions[i + 1] -- 3002
				local answer = __TS__ArrayFind( -- 3003
					answers, -- 3003
					function(____, item) return item.questionId == question.id end -- 3003
				) -- 3003
				if not answer or answer.status == "skipped" then -- 3003
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 3005
					goto __continue476 -- 3010
				end -- 3010
				local selectedOptionLabels = {} -- 3012
				do -- 3012
					local j = 0 -- 3013
					while j < #(answer.selectedOptionIds or ({})) do -- 3013
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3014
						local option = __TS__ArrayFind( -- 3015
							question.options or ({}), -- 3015
							function(____, item) return item.id == optionId end -- 3015
						) -- 3015
						if option then -- 3015
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 3016
						end -- 3016
						j = j + 1 -- 3013
					end -- 3013
				end -- 3013
				responses[#responses + 1] = { -- 3018
					questionId = question.id, -- 3019
					prompt = question.prompt, -- 3020
					status = "answered", -- 3021
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 3022
					selectedOptionLabels = selectedOptionLabels, -- 3023
					otherText = answer.otherText, -- 3024
					text = answer.text -- 3025
				} -- 3025
			end -- 3025
			::__continue476:: -- 3025
			i = i + 1 -- 3001
		end -- 3001
	end -- 3001
	return { -- 3028
		success = true, -- 3029
		status = "answered", -- 3030
		source = "user", -- 3031
		questionnaireId = questionnaire.id, -- 3032
		title = questionnaire.schema.title, -- 3033
		answers = answers, -- 3034
		responses = responses, -- 3035
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3036
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3037
	} -- 3037
end -- 2982
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3063
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3069
	local persisted = storage:readSessionState() -- 3070
	local messages = __TS__ArraySlice(persisted.messages) -- 3071
	local toolResultIndex = -1 -- 3072
	local existingResult -- 3073
	do -- 3073
		local i = #messages - 1 -- 3074
		while i >= 0 do -- 3074
			do -- 3074
				local message = messages[i + 1] -- 3075
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3075
					goto __continue496 -- 3076
				end -- 3076
				local decoded = safeJsonDecode(message.content) -- 3077
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3077
					goto __continue496 -- 3078
				end -- 3078
				local row = decoded -- 3079
				if row.questionnaireId ~= questionnaire.id then -- 3079
					goto __continue496 -- 3080
				end -- 3080
				toolResultIndex = i -- 3081
				existingResult = row -- 3082
				break -- 3083
			end -- 3083
			::__continue496:: -- 3083
			i = i - 1 -- 3074
		end -- 3074
	end -- 3074
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3085
	local guidance = {} -- 3086
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3086
		guidance[#guidance + 1] = existingResult.guidance -- 3088
	end -- 3088
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3088
		guidance[#guidance + 1] = result.guidance -- 3091
	end -- 3091
	result.guidance = table.concat(guidance, "\n") -- 3093
	if toolResultIndex < 0 then -- 3093
		messages[#messages + 1] = { -- 3095
			role = "user", -- 3096
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3097
		} -- 3097
		toolResultIndex = #messages - 1 -- 3099
	else -- 3099
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3101
			{}, -- 3101
			messages[toolResultIndex + 1], -- 3102
			{content = encodeJson(result)} -- 3101
		) -- 3101
	end -- 3101
	local pairStartIndex = toolResultIndex -- 3107
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3108
	if toolCallId and toolCallId ~= "" then -- 3108
		do -- 3108
			local i = toolResultIndex - 1 -- 3110
			while i >= 0 do -- 3110
				do -- 3110
					local message = messages[i + 1] -- 3111
					if message.role ~= "assistant" or not message.tool_calls then -- 3111
						goto __continue506 -- 3112
					end -- 3112
					if __TS__ArraySome( -- 3112
						message.tool_calls, -- 3113
						function(____, call) return call.id == toolCallId end -- 3113
					) then -- 3113
						pairStartIndex = i -- 3114
						break -- 3115
					end -- 3115
				end -- 3115
				::__continue506:: -- 3115
				i = i - 1 -- 3110
			end -- 3110
		end -- 3110
	end -- 3110
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3119
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3122
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3126
	upsertStep( -- 3128
		session.id, -- 3128
		questionnaire.taskId, -- 3128
		questionnaire.step, -- 3128
		"ask_user", -- 3128
		{status = "DONE", result = result} -- 3128
	) -- 3128
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3132
	upsertStep( -- 3133
		session.id, -- 3133
		questionnaire.taskId, -- 3133
		answerStep, -- 3133
		"questionnaire_answer", -- 3133
		{status = "DONE", result = result} -- 3133
	) -- 3133
	return {success = true, answerStep = answerStep, result = result} -- 3137
end -- 3063
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3140
	local session = getSessionItem(sessionId) -- 3141
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3141
		return {success = false, message = "project task admission is closed"} -- 3142
	end -- 3142
	if not session then -- 3142
		return {success = false, message = "session not found"} -- 3143
	end -- 3143
	if session.kind ~= "main" then -- 3143
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3144
	end -- 3144
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3145
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3145
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3147
	end -- 3147
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3149
	if not llmConfigRes.success then -- 3149
		return {success = false, message = llmConfigRes.message} -- 3150
	end -- 3150
	if not removePendingQuestionnaire(session) then -- 3150
		return {success = false, message = "failed to consume questionnaire file"} -- 3151
	end -- 3151
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3152
	if not replaced.success then -- 3152
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3154
		return replaced -- 3155
	end -- 3155
	local t = now() -- 3157
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3158
	session.workMode = "plan" -- 3159
	local result = startPromptTask( -- 3160
		session, -- 3160
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3160
		nil, -- 3160
		{}, -- 3160
		{ -- 3160
			workMode = "plan", -- 3161
			persistUserMessage = false, -- 3162
			resumeConversation = true, -- 3163
			existingTaskId = questionnaire.taskId, -- 3164
			initialStep = replaced.answerStep, -- 3165
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3166
			llmConfig = llmConfigRes.config -- 3167
		} -- 3167
	) -- 3167
	if not result.success then -- 3167
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3170
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3171
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3172
		emitAgentSessionPatch( -- 3173
			session.id, -- 3173
			{ -- 3173
				session = getSessionItem(session.id), -- 3174
				pendingQuestionnaire = questionnaire -- 3175
			} -- 3175
		) -- 3175
		return result -- 3177
	end -- 3177
	emitAgentSessionPatch( -- 3179
		sessionId, -- 3179
		{ -- 3179
			session = getSessionItem(sessionId), -- 3180
			pendingQuestionnaire = false -- 3181
		} -- 3181
	) -- 3181
	return result -- 3183
end -- 3140
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3186
	local session = getSessionItem(sessionId) -- 3187
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3187
		return {success = false, message = "project task admission is closed"} -- 3188
	end -- 3188
	if not session then -- 3188
		return {success = false, message = "session not found"} -- 3189
	end -- 3189
	if session.kind ~= "main" then -- 3189
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3190
	end -- 3190
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3191
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3191
		return {success = false, message = "pending questionnaire not found"} -- 3192
	end -- 3192
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3193
	if not validated.success then -- 3193
		return validated -- 3194
	end -- 3194
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3195
	if not llmConfigRes.success then -- 3195
		return {success = false, message = llmConfigRes.message} -- 3196
	end -- 3196
	local t = now() -- 3197
	if not removePendingQuestionnaire(session) then -- 3197
		return {success = false, message = "failed to consume questionnaire file"} -- 3198
	end -- 3198
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3199
	if not replaced.success then -- 3199
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3201
		return replaced -- 3202
	end -- 3202
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3204
	session.workMode = "plan" -- 3205
	local result = startPromptTask( -- 3206
		session, -- 3206
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3206
		nil, -- 3206
		{}, -- 3206
		{ -- 3206
			workMode = "plan", -- 3207
			persistUserMessage = false, -- 3208
			resumeConversation = true, -- 3209
			existingTaskId = questionnaire.taskId, -- 3210
			initialStep = replaced.answerStep, -- 3211
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3212
			llmConfig = llmConfigRes.config -- 3213
		} -- 3213
	) -- 3213
	if not result.success then -- 3213
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3216
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3217
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3218
		emitAgentSessionPatch( -- 3219
			session.id, -- 3219
			{ -- 3219
				session = getSessionItem(session.id), -- 3220
				pendingQuestionnaire = questionnaire -- 3221
			} -- 3221
		) -- 3221
		return result -- 3223
	end -- 3223
	emitAgentSessionPatch( -- 3225
		sessionId, -- 3225
		{ -- 3225
			session = getSessionItem(sessionId), -- 3226
			pendingQuestionnaire = false -- 3227
		} -- 3227
	) -- 3227
	return result -- 3229
end -- 3186
function ____exports.stopSessionTask(sessionId) -- 3232
	local session = getSessionItem(sessionId) -- 3233
	if not session or session.currentTaskId == nil then -- 3233
		return {success = false, message = "session task not found"} -- 3235
	end -- 3235
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3235
		return {success = false, message = "session task is finalizing"} -- 3238
	end -- 3238
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3240
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3241
	if localControl ~= nil then -- 3241
		localControl:stop() -- 3243
		return {success = true, stopping = true} -- 3244
	end -- 3244
	local stopToken = activeStopTokens[session.currentTaskId] -- 3246
	if stopToken == nil then -- 3246
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3246
			return {success = true, recovered = true} -- 3249
		end -- 3249
		return {success = false, message = "task is not running"} -- 3251
	end -- 3251
	if stopToken.stopped then -- 3251
		return {success = true, stopping = true} -- 3254
	end -- 3254
	stopToken.stopped = true -- 3256
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3257
	return {success = true, stopping = true} -- 3261
end -- 3232
function ____exports.getCurrentTaskId(sessionId) -- 3264
	local ____opt_125 = getSessionItem(sessionId) -- 3264
	return ____opt_125 and ____opt_125.currentTaskId -- 3265
end -- 3264
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3269
	local owner = getSessionItem(sessionId) -- 3270
	if not owner then -- 3270
		return {success = false, message = "session not found"} -- 3271
	end -- 3271
	local projectRoot = owner.projectRoot -- 3272
	local release = holdProjectTaskAdmission(projectRoot) -- 3273
	local closed = false -- 3274
	return { -- 3275
		success = true, -- 3276
		projectRoot = projectRoot, -- 3277
		close = function() -- 3278
			if not closed then -- 3278
				closed = true -- 3278
				release() -- 3278
			end -- 3278
		end, -- 3278
		poll = function() -- 3279
			if closed then -- 3279
				return {success = false, message = "quiescence handle closed"} -- 3280
			end -- 3280
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3281
			if not rows then -- 3281
				return {success = false, message = "failed to inspect project tasks"} -- 3282
			end -- 3282
			local pending = {} -- 3283
			for ____, row in ipairs(rows) do -- 3284
				do -- 3284
					local session = rowToSession(row) -- 3285
					local taskId = session.currentTaskId -- 3286
					if taskId == nil then -- 3286
						goto __continue544 -- 3287
					end -- 3287
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3288
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3288
						goto __continue544 -- 3289
					end -- 3289
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3291
					local ____session_id_128 = session.id -- 3292
					local ____taskId_129 = taskId -- 3292
					local ____finalizing_130 = finalizing -- 3292
					local ____result_success_131 = result.success -- 3292
					local ____result_success_127 -- 3292
					if result.success then -- 3292
						____result_success_127 = nil -- 3292
					else -- 3292
						____result_success_127 = result.message -- 3292
					end -- 3292
					pending[#pending + 1] = { -- 3292
						sessionId = ____session_id_128, -- 3292
						taskId = ____taskId_129, -- 3292
						finalizing = ____finalizing_130, -- 3292
						stopRequested = ____result_success_131, -- 3292
						message = ____result_success_127 -- 3292
					} -- 3292
				end -- 3292
				::__continue544:: -- 3292
			end -- 3292
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3296
		end -- 3279
	} -- 3279
end -- 3269
function ____exports.validateTaskAccess(sessionId, taskId) -- 3301
	local session = getSessionItem(sessionId) -- 3302
	if not session then -- 3302
		return {success = false, message = "session not found"} -- 3303
	end -- 3303
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3303
		getSessionOperableTaskIds(sessionId), -- 3304
		taskId -- 3304
	) < 0 then -- 3304
		return {success = false, message = "task is not operable for this session"} -- 3305
	end -- 3305
	return {success = true, session = session} -- 3307
end -- 3301
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3310
	if checkpointId <= 0 then -- 3310
		return {success = false, message = "invalid checkpointId"} -- 3312
	end -- 3312
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3314
	if not checkpoint then -- 3314
		return {success = false, message = "checkpoint not found"} -- 3316
	end -- 3316
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3318
	if not taskAccess.success then -- 3318
		return taskAccess -- 3319
	end -- 3319
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3320
end -- 3310
function ____exports.listRunningSessions() -- 3323
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3324
	local sessions = {} -- 3331
	do -- 3331
		local i = 0 -- 3332
		while i < #rows do -- 3332
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3333
			if session.currentTaskStatus == "RUNNING" then -- 3333
				sessions[#sessions + 1] = session -- 3335
			end -- 3335
			i = i + 1 -- 3332
		end -- 3332
	end -- 3332
	return {success = true, sessions = sessions} -- 3338
end -- 3323
return ____exports -- 3323