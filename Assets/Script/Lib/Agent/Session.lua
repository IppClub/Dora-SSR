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
				local ____temp_43 = pending.deltas == 1 or pending.deltas >= STREAM_UPDATE_MAX_DELTAS -- 2071
				if not ____temp_43 then -- 2071
					local ____opt_41 = pending.content -- 2071
					____temp_43 = (____opt_41 and #____opt_41 or 0) - pending.lastFlushedLength >= STREAM_UPDATE_MIN_BYTES -- 2071
				end -- 2071
				if ____temp_43 then -- 2071
					__TS__Delete(pendingStreamUpdates, pendingKey) -- 2074
					upsertStep( -- 2075
						sessionId, -- 2075
						event.taskId, -- 2075
						event.step, -- 2075
						"message", -- 2075
						{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2075
					) -- 2075
					emitAgentSessionPatch( -- 2080
						sessionId, -- 2080
						{step = getStepItem(sessionId, event.taskId, event.step)} -- 2080
					) -- 2080
				end -- 2080
				break -- 2084
			end -- 2084
		end -- 2084
		____cond321 = ____cond321 or ____switch321 == "assistant_message_finished" -- 2084
		if ____cond321 then -- 2084
			do -- 2084
				__TS__Delete( -- 2087
					pendingStreamUpdates, -- 2087
					streamUpdateKey(sessionId, event.taskId, event.step) -- 2087
				) -- 2087
				upsertStep( -- 2088
					sessionId, -- 2088
					event.taskId, -- 2088
					event.step, -- 2088
					"message", -- 2088
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2088
				) -- 2088
				emitAgentSessionPatch( -- 2094
					sessionId, -- 2094
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2094
				) -- 2094
				break -- 2097
			end -- 2097
		end -- 2097
		____cond321 = ____cond321 or ____switch321 == "task_waiting_for_user" -- 2097
		if ____cond321 then -- 2097
			do -- 2097
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2100
				__TS__Delete(activeStopTokens, event.taskId) -- 2101
				emitAgentSessionPatch( -- 2102
					sessionId, -- 2102
					{ -- 2102
						session = getSessionItem(sessionId), -- 2103
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2104
					} -- 2104
				) -- 2104
				break -- 2106
			end -- 2106
		end -- 2106
		____cond321 = ____cond321 or ____switch321 == "task_finished" -- 2106
		if ____cond321 then -- 2106
			do -- 2106
				local session = getSessionItem(sessionId) -- 2109
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2109
					__TS__Delete(activeStopTokens, event.taskId) -- 2111
					Log( -- 2112
						"Info", -- 2112
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2112
					) -- 2112
					break -- 2113
				end -- 2113
				local ____opt_44 = activeStopTokens[event.taskId or -1] -- 2113
				local stopped = (____opt_44 and ____opt_44.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2115
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2117
				local isSubSession = (session and session.kind) == "sub" -- 2120
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2121
				if isSubSession and event.taskId ~= nil then -- 2121
					finalizingSubSessionTaskIds[event.taskId] = true -- 2123
				end -- 2123
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2125
				if event.taskId ~= nil then -- 2125
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2127
					local ____finalizeTaskSteps_50 = finalizeTaskSteps -- 2128
					local ____array_49 = __TS__SparseArrayNew( -- 2128
						sessionId, -- 2129
						event.taskId, -- 2130
						type(event.steps) == "number" and math.max( -- 2131
							0, -- 2131
							math.floor(event.steps) -- 2131
						) or nil -- 2131
					) -- 2131
					local ____event_success_48 -- 2132
					if event.success then -- 2132
						____event_success_48 = nil -- 2132
					else -- 2132
						____event_success_48 = stopped and "STOPPED" or "FAILED" -- 2132
					end -- 2132
					__TS__SparseArrayPush(____array_49, ____event_success_48) -- 2132
					____finalizeTaskSteps_50(__TS__SparseArraySpread(____array_49)) -- 2128
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
			local ____Log_56 = Log -- 2236
			local ____temp_53 = #normalizedTitle -- 2236
			local ____temp_54 = #rawPrompt -- 2236
			local ____temp_55 = #toStr(request.expectedOutput) -- 2236
			local ____opt_51 = request.filesHint -- 2236
			____Log_56( -- 2236
				"Warn", -- 2236
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_53)) .. " raw_prompt_len=") .. tostring(____temp_54)) .. " expected_len=") .. tostring(____temp_55)) .. " files_hint_count=") .. tostring(____opt_51 and #____opt_51 or 0) -- 2236
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
		local ____record_success_73 -- 2505
		if record.success then -- 2505
			____record_success_73 = buildStructuredSubAgentMemoryEntry(record) -- 2505
		else -- 2505
			____record_success_73 = nil -- 2505
		end -- 2505
		record.memoryEntry = ____record_success_73 -- 2505
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
	local ____temp_94 -- 2774
	if (options and options.existingTaskId) == nil then -- 2774
		____temp_94 = session.currentTaskId -- 2774
	else -- 2774
		____temp_94 = nil -- 2774
	end -- 2774
	local previousTaskId = ____temp_94 -- 2774
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
	local ____runCodingAgent_123 = runCodingAgent -- 2797
	local ____normalizedPrompt_116 = normalizedPrompt -- 2798
	local ____temp_117 = options and options.resumeConversation -- 2799
	local ____temp_118 = (options and options.existingTaskId) ~= nil -- 2800
	local ____temp_119 = options and options.initialStep -- 2801
	local ____temp_120 = options and options.initialAgentStepCount -- 2802
	local ____temp_111 -- 2803
	if (options and options.existingTaskId) ~= nil then -- 2803
		____temp_111 = getInitialTokenUsage(session) -- 2803
	else -- 2803
		____temp_111 = nil -- 2803
	end -- 2803
	____runCodingAgent_123( -- 2797
		{ -- 2797
			prompt = ____normalizedPrompt_116, -- 2798
			resumeConversation = ____temp_117, -- 2799
			resumeTask = ____temp_118, -- 2800
			initialStep = ____temp_119, -- 2801
			initialAgentStepCount = ____temp_120, -- 2802
			initialTokenUsage = ____temp_111, -- 2803
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
function ____exports.listRunningSubAgents(request) -- 3342
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3342
		local session = getSessionItem(request.sessionId) -- 3350
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3350
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3352
		end -- 3352
		if not session then -- 3352
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3352
		end -- 3352
		local rootSession = getRootSessionItem(session.id) -- 3357
		if not rootSession then -- 3357
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3357
		end -- 3357
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3361
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3362
		local limit = math.max( -- 3363
			1, -- 3363
			math.floor(tonumber(request.limit) or 5) -- 3363
		) -- 3363
		local offset = math.max( -- 3364
			0, -- 3364
			math.floor(tonumber(request.offset) or 0) -- 3364
		) -- 3364
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3365
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3366
		local runningSessions = {} -- 3373
		do -- 3373
			local i = 0 -- 3374
			while i < #rows do -- 3374
				do -- 3374
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3375
					if current.currentTaskStatus ~= "RUNNING" then -- 3375
						goto __continue564 -- 3377
					end -- 3377
					local spawnInfo = getSessionSpawnInfo(current) -- 3379
					runningSessions[#runningSessions + 1] = { -- 3380
						sessionId = current.id, -- 3381
						title = current.title, -- 3382
						parentSessionId = current.parentSessionId, -- 3383
						rootSessionId = current.rootSessionId, -- 3384
						status = "RUNNING", -- 3385
						currentTaskId = current.currentTaskId, -- 3386
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3387
						goal = spawnInfo and spawnInfo.goal, -- 3388
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3389
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3390
						createdAt = current.createdAt, -- 3391
						updatedAt = current.updatedAt -- 3392
					} -- 3392
				end -- 3392
				::__continue564:: -- 3392
				i = i + 1 -- 3374
			end -- 3374
		end -- 3374
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3395
		local completedSessions = __TS__ArrayMap( -- 3396
			completedRecords, -- 3396
			function(____, record) return { -- 3396
				sessionId = record.sessionId, -- 3397
				title = record.title, -- 3398
				parentSessionId = record.parentSessionId, -- 3399
				rootSessionId = record.rootSessionId, -- 3400
				status = record.status, -- 3401
				goal = record.goal, -- 3402
				expectedOutput = record.expectedOutput, -- 3403
				filesHint = record.filesHint, -- 3404
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3405
				success = record.success, -- 3406
				cleared = record.cleared, -- 3407
				resultFilePath = record.resultFilePath, -- 3408
				artifactDir = record.artifactDir, -- 3409
				finishedAt = record.finishedAt, -- 3410
				createdAt = record.createdAtTs, -- 3411
				updatedAt = record.finishedAtTs -- 3412
			} end -- 3412
		) -- 3412
		local merged = {} -- 3414
		if status == "running" then -- 3414
			merged = runningSessions -- 3416
		elseif status == "done" then -- 3416
			merged = __TS__ArrayFilter( -- 3418
				completedSessions, -- 3418
				function(____, item) return item.status == "DONE" end -- 3418
			) -- 3418
		elseif status == "failed" then -- 3418
			merged = __TS__ArrayFilter( -- 3420
				completedSessions, -- 3420
				function(____, item) return item.status == "FAILED" end -- 3420
			) -- 3420
		elseif status == "stopped" then -- 3420
			merged = __TS__ArrayFilter( -- 3422
				completedSessions, -- 3422
				function(____, item) return item.status == "STOPPED" end -- 3422
			) -- 3422
		elseif status == "all" then -- 3422
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3424
		else -- 3424
			local runningKeys = {} -- 3426
			do -- 3426
				local i = 0 -- 3427
				while i < #runningSessions do -- 3427
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3428
					i = i + 1 -- 3427
				end -- 3427
			end -- 3427
			local latestCompletedByKey = {} -- 3430
			do -- 3430
				local i = 0 -- 3431
				while i < #completedSessions do -- 3431
					do -- 3431
						local item = completedSessions[i + 1] -- 3432
						local key = getSubAgentDisplayKey(item) -- 3433
						if runningKeys[key] then -- 3433
							goto __continue579 -- 3435
						end -- 3435
						local current = latestCompletedByKey[key] -- 3437
						if current == nil or item.updatedAt > current.updatedAt then -- 3437
							latestCompletedByKey[key] = item -- 3439
						end -- 3439
					end -- 3439
					::__continue579:: -- 3439
					i = i + 1 -- 3431
				end -- 3431
			end -- 3431
			local latestCompleted = {} -- 3442
			for ____, item in pairs(latestCompletedByKey) do -- 3443
				latestCompleted[#latestCompleted + 1] = item -- 3444
			end -- 3444
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3446
		end -- 3446
		if query ~= "" then -- 3446
			merged = __TS__ArrayFilter( -- 3449
				merged, -- 3449
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3449
			) -- 3449
		end -- 3449
		__TS__ArraySort( -- 3455
			merged, -- 3455
			function(____, a, b) -- 3455
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3455
					return -1 -- 3456
				end -- 3456
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3456
					return 1 -- 3457
				end -- 3457
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3457
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3459
				end -- 3459
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3461
			end -- 3455
		) -- 3455
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3463
		return ____awaiter_resolve(nil, { -- 3463
			success = true, -- 3465
			rootSessionId = rootSession.id, -- 3466
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3467
			status = status, -- 3468
			limit = limit, -- 3469
			offset = offset, -- 3470
			hasMore = offset + limit < #merged, -- 3471
			sessions = paged -- 3472
		}) -- 3472
	end) -- 3472
end -- 3342
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
	local ____relatedSessions_62 = relatedSessions -- 2375
	local ____temp_61 -- 2376
	if normalizedSession.kind == "sub" then -- 2376
		____temp_61 = getSessionSpawnInfo(normalizedSession) -- 2376
	else -- 2376
		____temp_61 = nil -- 2376
	end -- 2376
	return { -- 2372
		success = true, -- 2373
		session = normalizedSession, -- 2374
		relatedSessions = ____relatedSessions_62, -- 2375
		spawnInfo = ____temp_61, -- 2376
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
					goto __continue476 -- 3008
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
			::__continue476:: -- 3023
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
					goto __continue496 -- 3074
				end -- 3074
				local decoded = safeJsonDecode(message.content) -- 3075
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3075
					goto __continue496 -- 3076
				end -- 3076
				local row = decoded -- 3077
				if row.questionnaireId ~= questionnaire.id then -- 3077
					goto __continue496 -- 3078
				end -- 3078
				toolResultIndex = i -- 3079
				existingResult = row -- 3080
				break -- 3081
			end -- 3081
			::__continue496:: -- 3081
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
						goto __continue506 -- 3110
					end -- 3110
					if __TS__ArraySome( -- 3110
						message.tool_calls, -- 3111
						function(____, call) return call.id == toolCallId end -- 3111
					) then -- 3111
						pairStartIndex = i -- 3112
						break -- 3113
					end -- 3113
				end -- 3113
				::__continue506:: -- 3113
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
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3238
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3239
	if localControl ~= nil then -- 3239
		localControl:stop() -- 3241
		return {success = true, stopping = true} -- 3242
	end -- 3242
	local stopToken = activeStopTokens[session.currentTaskId] -- 3244
	if stopToken == nil then -- 3244
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3244
			return {success = true, recovered = true} -- 3247
		end -- 3247
		return {success = false, message = "task is not running"} -- 3249
	end -- 3249
	if stopToken.stopped then -- 3249
		return {success = true, stopping = true} -- 3252
	end -- 3252
	stopToken.stopped = true -- 3254
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3255
	return {success = true, stopping = true} -- 3259
end -- 3230
function ____exports.getCurrentTaskId(sessionId) -- 3262
	local ____opt_126 = getSessionItem(sessionId) -- 3262
	return ____opt_126 and ____opt_126.currentTaskId -- 3263
end -- 3262
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3267
	local owner = getSessionItem(sessionId) -- 3268
	if not owner then -- 3268
		return {success = false, message = "session not found"} -- 3269
	end -- 3269
	local projectRoot = owner.projectRoot -- 3270
	local release = holdProjectTaskAdmission(projectRoot) -- 3271
	local closed = false -- 3272
	return { -- 3273
		success = true, -- 3274
		projectRoot = projectRoot, -- 3275
		close = function() -- 3276
			if not closed then -- 3276
				closed = true -- 3276
				release() -- 3276
			end -- 3276
		end, -- 3276
		poll = function() -- 3277
			if closed then -- 3277
				return {success = false, message = "quiescence handle closed"} -- 3278
			end -- 3278
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3279
			if not rows then -- 3279
				return {success = false, message = "failed to inspect project tasks"} -- 3280
			end -- 3280
			local pending = {} -- 3281
			for ____, row in ipairs(rows) do -- 3282
				do -- 3282
					local session = rowToSession(row) -- 3283
					local taskId = session.currentTaskId -- 3284
					if taskId == nil then -- 3284
						goto __continue544 -- 3285
					end -- 3285
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3286
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3286
						goto __continue544 -- 3287
					end -- 3287
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3289
					local ____session_id_129 = session.id -- 3290
					local ____taskId_130 = taskId -- 3290
					local ____finalizing_131 = finalizing -- 3290
					local ____result_success_132 = result.success -- 3290
					local ____result_success_128 -- 3290
					if result.success then -- 3290
						____result_success_128 = nil -- 3290
					else -- 3290
						____result_success_128 = result.message -- 3290
					end -- 3290
					pending[#pending + 1] = { -- 3290
						sessionId = ____session_id_129, -- 3290
						taskId = ____taskId_130, -- 3290
						finalizing = ____finalizing_131, -- 3290
						stopRequested = ____result_success_132, -- 3290
						message = ____result_success_128 -- 3290
					} -- 3290
				end -- 3290
				::__continue544:: -- 3290
			end -- 3290
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3294
		end -- 3277
	} -- 3277
end -- 3267
function ____exports.validateTaskAccess(sessionId, taskId) -- 3299
	local session = getSessionItem(sessionId) -- 3300
	if not session then -- 3300
		return {success = false, message = "session not found"} -- 3301
	end -- 3301
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3301
		getSessionOperableTaskIds(sessionId), -- 3302
		taskId -- 3302
	) < 0 then -- 3302
		return {success = false, message = "task is not operable for this session"} -- 3303
	end -- 3303
	return {success = true, session = session} -- 3305
end -- 3299
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3308
	if checkpointId <= 0 then -- 3308
		return {success = false, message = "invalid checkpointId"} -- 3310
	end -- 3310
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3312
	if not checkpoint then -- 3312
		return {success = false, message = "checkpoint not found"} -- 3314
	end -- 3314
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3316
	if not taskAccess.success then -- 3316
		return taskAccess -- 3317
	end -- 3317
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3318
end -- 3308
function ____exports.listRunningSessions() -- 3321
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3322
	local sessions = {} -- 3329
	do -- 3329
		local i = 0 -- 3330
		while i < #rows do -- 3330
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3331
			if session.currentTaskStatus == "RUNNING" then -- 3331
				sessions[#sessions + 1] = session -- 3333
			end -- 3333
			i = i + 1 -- 3330
		end -- 3330
	end -- 3330
	return {success = true, sessions = sessions} -- 3336
end -- 3321
return ____exports -- 3321