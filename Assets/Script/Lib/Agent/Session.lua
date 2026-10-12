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
local getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, activeLocalAgentControls, finalizingSubSessionTaskIds, activePromptRuns, SESSION_SELECT_COLUMNS, now -- 1
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
function getDefaultUseChineseResponse() -- 348
	local zh = string.match(App.locale, "^zh") -- 349
	return zh ~= nil -- 350
end -- 350
function encodeJson(value) -- 353
	local text = safeJsonEncode(value) -- 354
	return text or "" -- 355
end -- 355
function decodeJsonObject(text) -- 358
	if text == "" then -- 358
		return nil -- 359
	end -- 359
	local value = safeJsonDecode(text) -- 360
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 360
		return value -- 362
	end -- 362
	return nil -- 364
end -- 364
function decodeJsonFiles(text) -- 367
	if text == "" then -- 367
		return nil -- 368
	end -- 368
	local value = safeJsonDecode(text) -- 369
	if not value or not __TS__ArrayIsArray(value) then -- 369
		return nil -- 370
	end -- 370
	local files = {} -- 371
	do -- 371
		local i = 0 -- 372
		while i < #value do -- 372
			do -- 372
				local item = value[i + 1] -- 373
				if type(item) ~= "table" then -- 373
					goto __continue13 -- 374
				end -- 374
				files[#files + 1] = { -- 375
					path = sanitizeUTF8(toStr(item.path)), -- 376
					op = sanitizeUTF8(toStr(item.op)) -- 377
				} -- 377
			end -- 377
			::__continue13:: -- 377
			i = i + 1 -- 372
		end -- 372
	end -- 372
	return files -- 380
end -- 380
function decodeChangeSetSummary(value) -- 383
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 383
		return nil -- 384
	end -- 384
	local row = value -- 385
	if row.success ~= true then -- 385
		return nil -- 386
	end -- 386
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 387
	if taskId <= 0 then -- 387
		return nil -- 388
	end -- 388
	local files = {} -- 389
	if __TS__ArrayIsArray(row.files) then -- 389
		do -- 389
			local i = 0 -- 391
			while i < #row.files do -- 391
				do -- 391
					local file = row.files[i + 1] -- 392
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 392
						goto __continue21 -- 393
					end -- 393
					local fileRow = file -- 394
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 395
					if path == "" then -- 395
						goto __continue21 -- 396
					end -- 396
					local checkpointIds = {} -- 397
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 397
						do -- 397
							local j = 0 -- 399
							while j < #fileRow.checkpointIds do -- 399
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 400
								if checkpointId > 0 then -- 400
									checkpointIds[#checkpointIds + 1] = checkpointId -- 401
								end -- 401
								j = j + 1 -- 399
							end -- 399
						end -- 399
					end -- 399
					local op = toStr(fileRow.op) -- 404
					files[#files + 1] = { -- 405
						path = path, -- 406
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 407
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 408
						checkpointIds = checkpointIds -- 409
					} -- 409
				end -- 409
				::__continue21:: -- 409
				i = i + 1 -- 391
			end -- 391
		end -- 391
	end -- 391
	return { -- 413
		success = true, -- 414
		taskId = taskId, -- 415
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 416
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 417
		files = files, -- 418
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 419
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 420
	} -- 420
end -- 420
function decodeHandoffEvidence(value) -- 424
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 424
		return nil -- 425
	end -- 425
	local row = value -- 426
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 427
		__TS__ArrayFilter( -- 428
			row.modifiedFiles, -- 428
			function(____, item) return type(item) == "string" end -- 428
		), -- 428
		function(____, item) return sanitizeUTF8(item) end -- 428
	) or ({}) -- 428
	local lastBuild = nil -- 430
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 430
		local build = row.lastBuild -- 432
		lastBuild = { -- 433
			result = build.result == "passed" and "passed" or "failed", -- 434
			path = sanitizeUTF8(toStr(build.path)), -- 435
			evidence = takeUtf8Head( -- 436
				sanitizeUTF8(toStr(build.evidence)), -- 436
				600 -- 436
			) -- 436
		} -- 436
	end -- 436
	local commands = {} -- 439
	if __TS__ArrayIsArray(row.commands) then -- 439
		do -- 439
			local i = 0 -- 441
			while i < #row.commands and #commands < 8 do -- 441
				do -- 441
					local raw = row.commands[i + 1] -- 442
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 442
						goto __continue35 -- 443
					end -- 443
					local item = raw -- 444
					commands[#commands + 1] = { -- 445
						mode = sanitizeUTF8(toStr(item.mode)), -- 446
						command = takeUtf8Head( -- 447
							sanitizeUTF8(toStr(item.command)), -- 447
							600 -- 447
						), -- 447
						result = item.result == "passed" and "passed" or "failed", -- 448
						evidence = takeUtf8Head( -- 449
							sanitizeUTF8(toStr(item.evidence)), -- 449
							600 -- 449
						) -- 449
					} -- 449
				end -- 449
				::__continue35:: -- 449
				i = i + 1 -- 441
			end -- 441
		end -- 441
	end -- 441
	local authoritativeSources = {} -- 453
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 453
		do -- 453
			local i = 0 -- 455
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 455
				do -- 455
					local raw = row.authoritativeSources[i + 1] -- 456
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 456
						goto __continue39 -- 457
					end -- 457
					local item = raw -- 458
					authoritativeSources[#authoritativeSources + 1] = { -- 459
						tool = "search_dora_doc", -- 460
						query = takeUtf8Head( -- 461
							sanitizeUTF8(toStr(item.query)), -- 461
							300 -- 461
						), -- 461
						source = sanitizeUTF8(toStr(item.source)), -- 462
						result = item.result == "passed" and "passed" or "failed" -- 463
					} -- 463
				end -- 463
				::__continue39:: -- 463
				i = i + 1 -- 455
			end -- 455
		end -- 455
	end -- 455
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 467
end -- 467
function takeUtf8Head(text, maxChars) -- 470
	if maxChars <= 0 or text == "" then -- 470
		return "" -- 471
	end -- 471
	local nextPos = utf8.offset(text, maxChars + 1) -- 472
	if nextPos == nil then -- 472
		return text -- 473
	end -- 473
	return string.sub(text, 1, nextPos - 1) -- 474
end -- 474
function normalizeMemoryEntryEvidence(value) -- 477
	local evidence = {} -- 478
	if not __TS__ArrayIsArray(value) then -- 478
		return evidence -- 479
	end -- 479
	do -- 479
		local i = 0 -- 480
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 480
			do -- 480
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 481
				if item == "" then -- 481
					goto __continue47 -- 482
				end -- 482
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 482
					evidence[#evidence + 1] = item -- 484
				end -- 484
			end -- 484
			::__continue47:: -- 484
			i = i + 1 -- 480
		end -- 480
	end -- 480
	return evidence -- 487
end -- 487
function decodeSubAgentMemoryEntry(value) -- 490
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 490
		return nil -- 491
	end -- 491
	local row = value -- 492
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 493
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 494
	local content = takeUtf8Head( -- 495
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 495
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 495
	) -- 495
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 495
		return nil -- 496
	end -- 496
	return { -- 497
		sourceSessionId = sourceSessionId, -- 498
		sourceTaskId = sourceTaskId, -- 499
		content = content, -- 500
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 501
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 502
	} -- 502
end -- 502
function getTaskChangeSetSummary(taskId) -- 506
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 507
	return summary.success and summary or nil -- 508
end -- 508
function summarizeHandoffResult(result) -- 511
	local candidates = {result.output, result.message, result.state, result.phase} -- 512
	do -- 512
		local i = 0 -- 513
		while i < #candidates do -- 513
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 514
			if text ~= "" then -- 514
				return takeUtf8Head(text, 600) -- 515
			end -- 515
			i = i + 1 -- 513
		end -- 513
	end -- 513
	local messages = result.messages -- 517
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 517
		local parts = {} -- 519
		do -- 519
			local i = 0 -- 520
			while i < #messages and #parts < 4 do -- 520
				do -- 520
					local row = messages[i + 1] -- 521
					if not row or type(row) ~= "table" then -- 521
						goto __continue60 -- 522
					end -- 522
					local item = row -- 523
					local ____sanitizeUTF8_3 = sanitizeUTF8 -- 524
					local ____toStr_2 = toStr -- 524
					local ____item_message_0 = item.message -- 524
					if ____item_message_0 == nil then -- 524
						____item_message_0 = item.error -- 524
					end -- 524
					local ____item_message_0_1 = ____item_message_0 -- 524
					if ____item_message_0_1 == nil then -- 524
						____item_message_0_1 = item.file -- 524
					end -- 524
					local text = __TS__StringTrim(____sanitizeUTF8_3(____toStr_2(____item_message_0_1))) -- 524
					if text ~= "" then -- 524
						parts[#parts + 1] = text -- 525
					end -- 525
				end -- 525
				::__continue60:: -- 525
				i = i + 1 -- 520
			end -- 520
		end -- 520
		if #parts > 0 then -- 520
			return takeUtf8Head( -- 527
				table.concat(parts, "; "), -- 527
				600 -- 527
			) -- 527
		end -- 527
	end -- 527
	return result.success == true and "tool result success=true" or "tool result success=false" -- 529
end -- 529
function getTaskHandoffEvidence(taskId, changeSet) -- 532
	local ____opt_4 = changeSet -- 532
	local evidence = { -- 533
		modifiedFiles = ____opt_4 and __TS__ArrayMap( -- 534
			changeSet and changeSet.files, -- 534
			function(____, item) return item.path end -- 534
		) or ({}), -- 534
		commands = {}, -- 535
		authoritativeSources = {} -- 536
	} -- 536
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 538
	do -- 538
		local i = 0 -- 543
		while i < #rows do -- 543
			local tool = toStr(rows[i + 1][1]) -- 544
			local status = toStr(rows[i + 1][2]) -- 545
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 546
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 547
			local passed = status == "DONE" and result.success == true -- 548
			if tool == "build" then -- 548
				evidence.lastBuild = { -- 550
					result = passed and "passed" or "failed", -- 551
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 552
					evidence = summarizeHandoffResult(result) -- 553
				} -- 553
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 553
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 556
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 557
				local ____evidence_commands_8 = evidence.commands -- 557
				____evidence_commands_8[#____evidence_commands_8 + 1] = { -- 558
					mode = mode, -- 559
					command = takeUtf8Head( -- 560
						__TS__StringTrim(sanitizeUTF8(command)), -- 560
						600 -- 560
					), -- 560
					result = passed and "passed" or "failed", -- 561
					evidence = summarizeHandoffResult(result) -- 562
				} -- 562
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 562
				local ____evidence_authoritativeSources_9 = evidence.authoritativeSources -- 562
				____evidence_authoritativeSources_9[#____evidence_authoritativeSources_9 + 1] = { -- 565
					tool = "search_dora_doc", -- 566
					query = takeUtf8Head( -- 567
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 567
						300 -- 567
					), -- 567
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 568
					result = passed and "passed" or "failed" -- 569
				} -- 569
			end -- 569
			i = i + 1 -- 543
		end -- 543
	end -- 543
	return evidence -- 573
end -- 573
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 576
	local lastBuild = evidence.lastBuild -- 580
	if not lastBuild or lastBuild.result ~= "failed" then -- 580
		return completion -- 581
	end -- 581
	local validation = __TS__ArraySlice(completion.validation) -- 582
	local foundBuild = false -- 583
	do -- 583
		local i = 0 -- 584
		while i < #validation do -- 584
			do -- 584
				if validation[i + 1].kind ~= "build" then -- 584
					goto __continue74 -- 585
				end -- 585
				foundBuild = true -- 586
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 587
			end -- 587
			::__continue74:: -- 587
			i = i + 1 -- 584
		end -- 584
	end -- 584
	if not foundBuild then -- 584
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 594
	end -- 594
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 596
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 597
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 597
		knownIssues[#knownIssues + 1] = issue -- 598
	end -- 598
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 599
end -- 599
function isValidProjectRoot(path) -- 607
	return path ~= "" and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 608
end -- 608
function rowToSession(row) -- 611
	return { -- 612
		id = row[1], -- 613
		projectRoot = toStr(row[2]), -- 614
		title = toStr(row[3]), -- 615
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 616
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 617
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 618
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 619
		status = toStr(row[8]), -- 620
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 621
		currentTaskStatus = toStr(row[10]), -- 622
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 623
		createdAt = row[11], -- 624
		updatedAt = row[12], -- 625
		metrics = decodeJsonObject(toStr(row[13])), -- 626
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 627
	} -- 627
end -- 627
function rowToMessage(row) -- 631
	local message = { -- 632
		id = row[1], -- 633
		sessionId = row[2], -- 634
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 635
		role = toStr(row[4]), -- 636
		content = toStr(row[5]), -- 637
		createdAt = row[7], -- 638
		updatedAt = row[8] -- 639
	} -- 639
	local displayContent = toStr(row[6]) -- 641
	if displayContent ~= "" then -- 641
		message.displayContent = displayContent -- 642
	end -- 642
	return message -- 643
end -- 643
function rowToStep(row) -- 646
	return { -- 647
		id = row[1], -- 648
		sessionId = row[2], -- 649
		taskId = row[3], -- 650
		step = row[4], -- 651
		tool = toStr(row[5]), -- 652
		status = toStr(row[6]), -- 653
		reason = toStr(row[7]), -- 654
		reasoningContent = toStr(row[8]), -- 655
		params = decodeJsonObject(toStr(row[9])), -- 656
		result = decodeJsonObject(toStr(row[10])), -- 657
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 658
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 659
		files = decodeJsonFiles(toStr(row[13])), -- 660
		createdAt = row[14], -- 661
		updatedAt = row[15] -- 662
	} -- 662
end -- 662
function getQuestionnairePath(projectRoot) -- 666
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 667
end -- 667
function decodeQuestionnaireFile(text) -- 670
	local value = decodeJsonObject(text) -- 671
	if not value then -- 671
		return nil -- 672
	end -- 672
	local schema = value.schema -- 673
	local id = type(value.id) == "number" and value.id or 0 -- 674
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 675
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 676
	local step = type(value.step) == "number" and value.step or 0 -- 677
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 678
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 678
		return nil -- 680
	end -- 680
	return { -- 682
		id = id, -- 682
		sessionId = sessionId, -- 682
		taskId = taskId, -- 682
		step = step, -- 682
		status = "PENDING", -- 682
		schema = schema, -- 682
		createdAt = createdAt -- 682
	} -- 682
end -- 682
function getPendingQuestionnaire(sessionId) -- 685
	local session = getSessionItem(sessionId) -- 686
	if not session or session.kind ~= "main" then -- 686
		return nil -- 687
	end -- 687
	local path = getQuestionnairePath(session.projectRoot) -- 688
	if not Content:exist(path) then -- 688
		return nil -- 689
	end -- 689
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 690
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 691
end -- 691
function restorePendingQuestionnaireState(session) -- 694
	local questionnaire = getPendingQuestionnaire(session.id) -- 695
	if not questionnaire then -- 695
		return {session = session} -- 696
	end -- 696
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 696
		local t = now() -- 703
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 704
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 710
		local restored = getSessionItem(session.id) -- 711
		if restored then -- 711
			session = restored -- 712
		end -- 712
	end -- 712
	return {session = session, questionnaire = questionnaire} -- 714
end -- 714
function savePendingQuestionnaire(projectRoot, questionnaire) -- 717
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 718
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 718
		return false -- 719
	end -- 719
	local path = getQuestionnairePath(projectRoot) -- 720
	local tempPath = path .. ".tmp" -- 721
	local backupPath = path .. ".bak" -- 722
	Content:remove(tempPath) -- 723
	Content:remove(backupPath) -- 724
	if not Content:save( -- 724
		tempPath, -- 725
		encodeJson(questionnaire) -- 725
	) then -- 725
		return false -- 725
	end -- 725
	local hadOriginal = Content:exist(path) -- 726
	if hadOriginal and not Content:move(path, backupPath) then -- 726
		Content:remove(tempPath) -- 728
		return false -- 729
	end -- 729
	if Content:move(tempPath, path) then -- 729
		Content:remove(backupPath) -- 732
		Tools.sendWebIDEFileUpdate( -- 733
			path, -- 733
			true, -- 733
			encodeJson(questionnaire) -- 733
		) -- 733
		return true -- 734
	end -- 734
	Content:remove(tempPath) -- 736
	if hadOriginal and Content:exist(backupPath) then -- 736
		Content:move(backupPath, path) -- 738
	end -- 738
	return false -- 740
end -- 740
function removePendingQuestionnaire(session) -- 743
	local path = getQuestionnairePath(session.projectRoot) -- 744
	if not Content:exist(path) then -- 744
		return true -- 745
	end -- 745
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 746
	if questionnaire and questionnaire.sessionId ~= session.id then -- 746
		return false -- 747
	end -- 747
	if not Content:remove(path) then -- 747
		return false -- 748
	end -- 748
	Tools.sendWebIDEFileUpdate(path, false, "") -- 749
	return true -- 750
end -- 750
function publishQuestionnaire(request) -- 753
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 753
		local session = getSessionItem(request.sessionId) -- 759
		if not session or session.kind ~= "main" then -- 759
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 759
		end -- 759
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 761
		if Content:exist(pendingPath) then -- 761
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 761
		end -- 761
		local questionnaire = { -- 763
			id = request.taskId, -- 764
			sessionId = request.sessionId, -- 765
			taskId = request.taskId, -- 766
			step = request.step, -- 767
			status = "PENDING", -- 768
			schema = request.schema, -- 769
			createdAt = now() -- 770
		} -- 770
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 770
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 770
		end -- 770
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 770
	end) -- 770
end -- 770
function getMessageItem(messageId) -- 778
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 779
	return row and rowToMessage(row) or nil -- 785
end -- 785
function getStepItem(sessionId, taskId, step) -- 788
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 789
	return row and rowToStep(row) or nil -- 795
end -- 795
function deleteMessageSteps(sessionId, taskId) -- 798
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 799
	local ids = {} -- 804
	do -- 804
		local i = 0 -- 805
		while i < #rows do -- 805
			local row = rows[i + 1] -- 806
			if type(row[1]) == "number" then -- 806
				ids[#ids + 1] = row[1] -- 808
			end -- 808
			i = i + 1 -- 805
		end -- 805
	end -- 805
	if #ids > 0 then -- 805
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 812
	end -- 812
	return ids -- 818
end -- 818
function normalizeDisabledAgentTools(value) -- 821
	if not __TS__ArrayIsArray(value) then -- 821
		return {} -- 822
	end -- 822
	local tools = {} -- 823
	do -- 823
		local i = 0 -- 824
		while i < #value do -- 824
			do -- 824
				local name = value[i + 1] -- 825
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 825
					goto __continue118 -- 826
				end -- 826
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 826
					tools[#tools + 1] = name -- 827
				end -- 827
			end -- 827
			::__continue118:: -- 827
			i = i + 1 -- 824
		end -- 824
	end -- 824
	return tools -- 829
end -- 829
function normalizeWorkMode(value, fallback) -- 832
	if fallback == nil then -- 832
		fallback = "code" -- 832
	end -- 832
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 833
end -- 833
function getSessionRow(sessionId) -- 836
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 837
end -- 837
function getSessionItem(sessionId) -- 845
	local row = getSessionRow(sessionId) -- 846
	return row and rowToSession(row) or nil -- 847
end -- 847
function getTaskPrompt(taskId) -- 850
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 851
	if not row or type(row[1]) ~= "string" then -- 851
		return nil -- 852
	end -- 852
	return toStr(row[1]) -- 853
end -- 853
function getLatestMainSessionByProjectRoot(projectRoot) -- 856
	if not isValidProjectRoot(projectRoot) then -- 856
		return nil -- 857
	end -- 857
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 858
	return row and rowToSession(row) or nil -- 866
end -- 866
function countRunningSubSessions(rootSessionId) -- 869
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 870
	local count = 0 -- 877
	do -- 877
		local i = 0 -- 878
		while i < #rows do -- 878
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 879
			if session.currentTaskStatus == "RUNNING" then -- 879
				count = count + 1 -- 881
			end -- 881
			i = i + 1 -- 878
		end -- 878
	end -- 878
	return count -- 884
end -- 884
function deleteSessionRecords(sessionId, preserveArtifacts) -- 887
	if preserveArtifacts == nil then -- 887
		preserveArtifacts = false -- 887
	end -- 887
	local session = getSessionItem(sessionId) -- 888
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 889
	local taskIds = {} -- 897
	do -- 897
		local i = 0 -- 898
		while i < #taskRows do -- 898
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 899
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 899
				taskIds[#taskIds + 1] = taskId -- 901
				local stopToken = activeStopTokens[taskId] -- 902
				if stopToken ~= nil then -- 902
					stopToken.stopped = true -- 904
					stopToken.reason = "session deleted" -- 905
				end -- 905
			end -- 905
			i = i + 1 -- 898
		end -- 898
	end -- 898
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 909
	do -- 909
		local i = 0 -- 910
		while i < #children do -- 910
			local row = children[i + 1] -- 911
			if type(row[1]) == "number" and row[1] > 0 then -- 911
				deleteSessionRecords(row[1], preserveArtifacts) -- 913
			end -- 913
			i = i + 1 -- 910
		end -- 910
	end -- 910
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 916
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 917
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 918
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 919
	if session and session.kind == "main" then -- 919
		removePendingQuestionnaire(session) -- 921
	end -- 921
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 921
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 921
			Tools.sendWebIDERefreshTree() -- 925
		end -- 925
	end -- 925
	do -- 925
		local i = 0 -- 928
		while i < #taskIds do -- 928
			cleanupTaskHeavyData(taskIds[i + 1]) -- 929
			i = i + 1 -- 928
		end -- 928
	end -- 928
end -- 928
function getSessionRootId(session) -- 933
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 934
end -- 934
function getRootSessionItem(sessionId) -- 937
	local session = getSessionItem(sessionId) -- 938
	if not session then -- 938
		return nil -- 939
	end -- 939
	return getSessionItem(getSessionRootId(session)) or session -- 940
end -- 940
function listRelatedSessions(sessionId) -- 943
	local root = getRootSessionItem(sessionId) -- 944
	if not root then -- 944
		return {} -- 945
	end -- 945
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 946
	return __TS__ArrayMap( -- 955
		rows, -- 955
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 955
	) -- 955
end -- 955
function getSessionSpawnInfo(session) -- 958
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 959
	if not info then -- 959
		return nil -- 960
	end -- 960
	local ____temp_15 = type(info.sessionId) == "number" and info.sessionId or nil -- 962
	local ____temp_16 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 963
	local ____temp_17 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 964
	local ____temp_18 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 965
	local ____temp_19 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 966
	local ____temp_20 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 967
	local ____temp_21 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 968
	local ____temp_22 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 969
		__TS__ArrayFilter( -- 970
			info.filesHint, -- 970
			function(____, item) return type(item) == "string" end -- 970
		), -- 970
		function(____, item) return sanitizeUTF8(item) end -- 970
	) or nil -- 970
	local ____temp_23 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 972
	local ____temp_13 -- 975
	if info.success == true then -- 975
		____temp_13 = true -- 975
	else -- 975
		local ____temp_12 -- 975
		if info.success == false then -- 975
			____temp_12 = false -- 975
		else -- 975
			____temp_12 = nil -- 975
		end -- 975
		____temp_13 = ____temp_12 -- 975
	end -- 975
	local ____temp_14 -- 976
	if info.cleared == true then -- 976
		____temp_14 = true -- 976
	else -- 976
		____temp_14 = nil -- 976
	end -- 976
	return { -- 961
		sessionId = ____temp_15, -- 962
		rootSessionId = ____temp_16, -- 963
		parentSessionId = ____temp_17, -- 964
		title = ____temp_18, -- 965
		prompt = ____temp_19, -- 966
		goal = ____temp_20, -- 967
		expectedOutput = ____temp_21, -- 968
		filesHint = ____temp_22, -- 969
		status = ____temp_23, -- 972
		success = ____temp_13, -- 975
		cleared = ____temp_14, -- 976
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 977
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 978
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 979
		changeSet = decodeChangeSetSummary(info.changeSet), -- 980
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 981
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 982
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 983
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 984
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 987
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 988
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 989
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 990
	} -- 990
end -- 990
function ensureDirRecursive(dir) -- 1007
	if dir == "" then -- 1007
		return false -- 1008
	end -- 1008
	if Content:exist(dir) then -- 1008
		return Content:isdir(dir) -- 1009
	end -- 1009
	local parent = Path:getPath(dir) -- 1010
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1010
		if not ensureDirRecursive(parent) then -- 1010
			return false -- 1013
		end -- 1013
	end -- 1013
	return Content:mkdir(dir) -- 1016
end -- 1016
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1019
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1020
	if not Content:exist(dir) then -- 1020
		ensureDirRecursive(dir) -- 1022
	end -- 1022
	local path = Path(dir, SPAWN_INFO_FILE) -- 1024
	local text = safeJsonEncode(value) -- 1025
	if not text then -- 1025
		return false -- 1026
	end -- 1026
	local content = text .. "\n" -- 1027
	if not Content:save(path, content) then -- 1027
		return false -- 1029
	end -- 1029
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1031
	return true -- 1032
end -- 1032
function readSpawnInfo(projectRoot, memoryScope) -- 1035
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1036
	if not Content:exist(path) then -- 1036
		return nil -- 1037
	end -- 1037
	local text = Content:load(path) -- 1038
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1038
		return nil -- 1039
	end -- 1039
	local value = safeJsonDecode(text) -- 1040
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1040
		return value -- 1042
	end -- 1042
	return nil -- 1044
end -- 1044
function getArtifactRelativeDir(memoryScope) -- 1047
	return Path(".agent", memoryScope) -- 1048
end -- 1048
function getArtifactDir(projectRoot, memoryScope) -- 1051
	return Path( -- 1052
		projectRoot, -- 1052
		getArtifactRelativeDir(memoryScope) -- 1052
	) -- 1052
end -- 1052
function getResultRelativePath(memoryScope) -- 1055
	return Path( -- 1056
		getArtifactRelativeDir(memoryScope), -- 1056
		RESULT_FILE -- 1056
	) -- 1056
end -- 1056
function getResultPath(projectRoot, memoryScope) -- 1059
	return Path( -- 1060
		projectRoot, -- 1060
		getResultRelativePath(memoryScope) -- 1060
	) -- 1060
end -- 1060
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1063
	if resultFilePath == "" then -- 1063
		return "" -- 1064
	end -- 1064
	local path = Path(projectRoot, resultFilePath) -- 1065
	if not Content:exist(path) then -- 1065
		return "" -- 1066
	end -- 1066
	local text = sanitizeUTF8(Content:load(path)) -- 1067
	if __TS__StringTrim(text) == "" then -- 1067
		return "" -- 1068
	end -- 1068
	local marker = "\n## Summary\n" -- 1069
	local start = string.find(text, marker, 1, true) -- 1070
	if start ~= nil then -- 1070
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1072
	end -- 1072
	return __TS__StringTrim(text) -- 1074
end -- 1074
function buildStructuredSubAgentMemoryEntry(record) -- 1077
	local hasPassedValidation = false -- 1078
	do -- 1078
		local i = 0 -- 1079
		while i < #record.completion.validation do -- 1079
			local result = record.completion.validation[i + 1].result -- 1080
			if result == "failed" then -- 1080
				return nil -- 1085
			end -- 1085
			if result == "passed" then -- 1085
				hasPassedValidation = true -- 1087
			end -- 1087
			i = i + 1 -- 1079
		end -- 1079
	end -- 1079
	if not hasPassedValidation then -- 1079
		return nil -- 1090
	end -- 1090
	local candidates = record.completion.learningCandidates -- 1091
	local claims = {} -- 1092
	local evidence = {} -- 1093
	do -- 1093
		local i = 0 -- 1094
		while i < #candidates do -- 1094
			do -- 1094
				local candidate = candidates[i + 1] -- 1095
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1095
					goto __continue189 -- 1096
				end -- 1096
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1097
				do -- 1097
					local j = 0 -- 1098
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1098
						local item = candidate.evidence[j + 1] -- 1099
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1099
							evidence[#evidence + 1] = item -- 1100
						end -- 1100
						j = j + 1 -- 1098
					end -- 1098
				end -- 1098
			end -- 1098
			::__continue189:: -- 1098
			i = i + 1 -- 1094
		end -- 1094
	end -- 1094
	local content = takeUtf8Head( -- 1103
		table.concat(claims, "\n"), -- 1103
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1103
	) -- 1103
	if content == "" then -- 1103
		return nil -- 1104
	end -- 1104
	return { -- 1105
		sourceSessionId = record.sessionId, -- 1106
		sourceTaskId = record.sourceTaskId, -- 1107
		content = content, -- 1108
		evidence = evidence, -- 1109
		createdAt = record.finishedAt -- 1110
	} -- 1110
end -- 1110
function containsNormalizedText(text, query) -- 1114
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1115
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1116
	if normalizedQuery == "" then -- 1116
		return true -- 1117
	end -- 1117
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1118
end -- 1118
function getSubAgentDisplayKey(item) -- 1121
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1127
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1128
	local label = goal ~= "" and goal or title -- 1129
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1130
end -- 1130
function writeSubAgentResultFile(session, record, resultText) -- 1133
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1134
	if not Content:exist(dir) then -- 1134
		ensureDirRecursive(dir) -- 1136
	end -- 1136
	local ____array_32 = __TS__SparseArrayNew( -- 1136
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1139
		"- Status: " .. record.status, -- 1140
		"- Success: " .. (record.success and "true" or "false"), -- 1141
		"- Outcome: " .. record.completion.outcome, -- 1142
		"- Session ID: " .. tostring(record.sessionId), -- 1143
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1144
		"- Goal: " .. record.goal, -- 1145
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1146
	) -- 1146
	__TS__SparseArrayPush( -- 1146
		____array_32, -- 1146
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1147
	) -- 1147
	__TS__SparseArrayPush( -- 1147
		____array_32, -- 1147
		"- Finished At: " .. record.finishedAt, -- 1148
		"", -- 1149
		"## Validation", -- 1150
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1151
			record.completion.validation, -- 1152
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1152
		) or ({"- Not reported"})) -- 1152
	) -- 1152
	__TS__SparseArrayPush(____array_32, "", "## Recorded Evidence") -- 1152
	local ____opt_24 = record.handoffEvidence -- 1152
	__TS__SparseArrayPush( -- 1152
		____array_32, -- 1152
		table.unpack(____opt_24 and #____opt_24.modifiedFiles and __TS__ArrayMap( -- 1156
			record.handoffEvidence.modifiedFiles, -- 1157
			function(____, item) return "- modified: " .. item end -- 1157
		) or ({"- modified: none recorded"})) -- 1157
	) -- 1157
	local ____opt_26 = record.handoffEvidence -- 1157
	__TS__SparseArrayPush( -- 1157
		____array_32, -- 1157
		table.unpack(____opt_26 and ____opt_26.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1159
	) -- 1159
	local ____opt_28 = record.handoffEvidence -- 1159
	__TS__SparseArrayPush( -- 1159
		____array_32, -- 1159
		table.unpack(__TS__ArrayMap( -- 1162
			____opt_28 and ____opt_28.commands or ({}), -- 1162
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1162
		)) -- 1162
	) -- 1162
	local ____opt_30 = record.handoffEvidence -- 1162
	__TS__SparseArrayPush( -- 1162
		____array_32, -- 1162
		table.unpack(__TS__ArrayMap( -- 1163
			____opt_30 and ____opt_30.authoritativeSources or ({}), -- 1163
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1163
		)) -- 1163
	) -- 1163
	__TS__SparseArrayPush( -- 1163
		____array_32, -- 1163
		"", -- 1164
		"## Known Issues", -- 1165
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1166
			record.completion.knownIssues, -- 1166
			function(____, item) return "- " .. item end -- 1166
		) or ({"- None reported"})) -- 1166
	) -- 1166
	__TS__SparseArrayPush( -- 1166
		____array_32, -- 1166
		"", -- 1167
		"## Assumptions", -- 1168
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1169
			record.completion.assumptions, -- 1169
			function(____, item) return "- " .. item end -- 1169
		) or ({"- None reported"})) -- 1169
	) -- 1169
	__TS__SparseArrayPush(____array_32, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1169
	local lines = {__TS__SparseArraySpread(____array_32)} -- 1138
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1174
	local content = table.concat(lines, "\n") .. "\n" -- 1175
	if not Content:save(path, content) then -- 1175
		return false -- 1177
	end -- 1177
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1179
	return true -- 1180
end -- 1180
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1183
	local dir = Path(projectRoot, ".agent", "subagents") -- 1184
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1184
		return {} -- 1185
	end -- 1185
	local items = {} -- 1186
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1187
		do -- 1187
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1188
			if not Content:exist(path) or not Content:isdir(path) then -- 1188
				goto __continue209 -- 1189
			end -- 1189
			local info = readSpawnInfo( -- 1190
				projectRoot, -- 1190
				Path( -- 1190
					"subagents", -- 1190
					Path:getFilename(path) -- 1190
				) -- 1190
			) -- 1190
			if not info then -- 1190
				goto __continue209 -- 1191
			end -- 1191
			local sessionId = tonumber(info.sessionId) -- 1192
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1193
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1194
			local status = sanitizeUTF8(toStr(info.status)) -- 1195
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1195
				goto __continue209 -- 1196
			end -- 1196
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1196
				goto __continue209 -- 1197
			end -- 1197
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1198
			items[#items + 1] = { -- 1199
				sessionId = sessionId, -- 1200
				rootSessionId = infoRootSessionId, -- 1201
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1202
				title = sanitizeUTF8(toStr(info.title)), -- 1203
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1204
				goal = sanitizeUTF8(toStr(info.goal)), -- 1205
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1206
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1207
					__TS__ArrayFilter( -- 1208
						info.filesHint, -- 1208
						function(____, item) return type(item) == "string" end -- 1208
					), -- 1208
					function(____, item) return sanitizeUTF8(item) end -- 1208
				) or ({}), -- 1208
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1210
				success = info.success == true, -- 1211
				cleared = info.cleared == true, -- 1212
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1213
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1214
					"subagents", -- 1214
					Path:getFilename(path) -- 1214
				)), -- 1214
				sourceTaskId = sourceTaskId or 0, -- 1215
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1216
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1217
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1218
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1219
				completion = normalizeAgentCompletionReport(info.completion), -- 1220
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1221
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1222
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1223
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1224
			} -- 1224
		end -- 1224
		::__continue209:: -- 1224
	end -- 1224
	__TS__ArraySort( -- 1227
		items, -- 1227
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1227
	) -- 1227
	return items -- 1228
end -- 1228
function getPendingHandoffDir(projectRoot, memoryScope) -- 1231
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1232
end -- 1232
function writePendingHandoff(projectRoot, memoryScope, value) -- 1235
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1236
	if not Content:exist(dir) then -- 1236
		ensureDirRecursive(dir) -- 1238
	end -- 1238
	local path = Path(dir, value.id .. ".json") -- 1240
	local text = safeJsonEncode(value) -- 1241
	if not text then -- 1241
		return false -- 1242
	end -- 1242
	local content = text .. "\n" -- 1243
	if not Content:save(path, content) then -- 1243
		return false -- 1244
	end -- 1244
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1245
	return true -- 1246
end -- 1246
function listPendingHandoffs(projectRoot, memoryScope) -- 1249
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1250
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1250
		return {} -- 1251
	end -- 1251
	local items = {} -- 1252
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1253
		do -- 1253
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1254
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1254
				goto __continue225 -- 1255
			end -- 1255
			local text = Content:load(path) -- 1256
			if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1256
				goto __continue225 -- 1257
			end -- 1257
			local obj = safeJsonDecode(text) -- 1258
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1258
				goto __continue225 -- 1259
			end -- 1259
			local value = obj -- 1260
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1261
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1262
			local id = sanitizeUTF8(toStr(value.id)) -- 1263
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1264
			local message = sanitizeUTF8(toStr(value.message)) -- 1265
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1266
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1267
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1268
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1268
				goto __continue225 -- 1270
			end -- 1270
			items[#items + 1] = { -- 1272
				id = id, -- 1273
				sourceSessionId = sourceSessionId, -- 1274
				sourceTitle = sourceTitle, -- 1275
				sourceTaskId = sourceTaskId, -- 1276
				message = message, -- 1277
				prompt = prompt, -- 1278
				goal = goal, -- 1279
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1280
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1281
					__TS__ArrayFilter( -- 1282
						value.filesHint, -- 1282
						function(____, item) return type(item) == "string" end -- 1282
					), -- 1282
					function(____, item) return sanitizeUTF8(item) end -- 1282
				) or ({}), -- 1282
				success = value.success == true, -- 1284
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1285
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1286
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1287
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1288
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1289
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1290
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1291
				createdAt = createdAt -- 1294
			} -- 1294
		end -- 1294
		::__continue225:: -- 1294
	end -- 1294
	__TS__ArraySort( -- 1297
		items, -- 1297
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1297
	) -- 1297
	return items -- 1298
end -- 1298
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1301
	local path = Path( -- 1302
		getPendingHandoffDir(projectRoot, memoryScope), -- 1302
		id .. ".json" -- 1302
	) -- 1302
	if Content:exist(path) then -- 1302
		if Content:remove(path) then -- 1302
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1305
		end -- 1305
	end -- 1305
end -- 1305
function normalizePromptText(prompt) -- 1310
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1311
end -- 1311
function normalizePromptTextSafe(prompt) -- 1314
	if type(prompt) == "string" then -- 1314
		local normalized = normalizePromptText(prompt) -- 1316
		if normalized ~= "" then -- 1316
			return normalized -- 1317
		end -- 1317
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1318
		if sanitized ~= "" then -- 1318
			return truncateAgentUserPrompt(sanitized) -- 1320
		end -- 1320
		return "" -- 1322
	end -- 1322
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1324
	if text == "" then -- 1324
		return "" -- 1325
	end -- 1325
	return truncateAgentUserPrompt(text) -- 1326
end -- 1326
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1329
	local sections = {} -- 1330
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1331
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1332
	local normalizedFiles = __TS__ArrayFilter( -- 1333
		__TS__ArrayMap( -- 1333
			__TS__ArrayFilter( -- 1333
				filesHint or ({}), -- 1333
				function(____, item) return type(item) == "string" end -- 1334
			), -- 1334
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1335
		), -- 1335
		function(____, item) return item ~= "" end -- 1336
	) -- 1336
	if normalizedTitle ~= "" then -- 1336
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1338
	end -- 1338
	if normalizedExpected ~= "" then -- 1338
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1341
	end -- 1341
	if #normalizedFiles > 0 then -- 1341
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1344
	end -- 1344
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1346
end -- 1346
function normalizeSessionRuntimeState(session) -- 1349
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1349
		return session -- 1351
	end -- 1351
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1351
		return session -- 1354
	end -- 1354
	if activeLocalAgentControls[session.currentTaskId] ~= nil then -- 1354
		return session -- 1357
	end -- 1357
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1359
		session.id, -- 1362
		session.currentTaskId, -- 1362
		"fetch_url", -- 1362
		"execute_command", -- 1362
		"analyze_image" -- 1362
	}) or ({}) -- 1362
	if #pendingToolRows > 0 then -- 1362
		local t = now() -- 1365
		do -- 1365
			local i = 0 -- 1366
			while i < #pendingToolRows do -- 1366
				local row = pendingToolRows[i + 1] -- 1367
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1368
				result.success = false -- 1369
				result.state = "failed" -- 1370
				result.interrupted = true -- 1371
				result.message = "tool call was interrupted because the program exited before it completed." -- 1372
				DB:exec( -- 1373
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1373
					{ -- 1375
						encodeJson(result), -- 1375
						t, -- 1375
						row[1] -- 1375
					} -- 1375
				) -- 1375
				i = i + 1 -- 1366
			end -- 1366
		end -- 1366
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1378
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1379
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1380
	end -- 1380
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1387
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1388
	return __TS__ObjectAssign( -- 1389
		{}, -- 1389
		session, -- 1390
		{ -- 1389
			status = "STOPPED", -- 1391
			currentTaskStatus = "STOPPED", -- 1392
			updatedAt = now() -- 1393
		} -- 1393
	) -- 1393
end -- 1393
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1397
	DB:exec( -- 1398
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1398
		{ -- 1402
			status, -- 1403
			currentTaskId or 0, -- 1404
			currentTaskStatus or status, -- 1405
			now(), -- 1406
			sessionId -- 1407
		} -- 1407
	) -- 1407
end -- 1407
function mergeAgentMetrics(current, next) -- 1412
	return __TS__ObjectAssign({}, current or ({}), next) -- 1413
end -- 1413
function updateSessionMetrics(sessionId, metrics) -- 1419
	local session = getSessionItem(sessionId) -- 1420
	if not session then -- 1420
		return nil -- 1421
	end -- 1421
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1422
	DB:exec( -- 1423
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1423
		{ -- 1427
			encodeJson(merged), -- 1428
			now(), -- 1429
			sessionId -- 1430
		} -- 1430
	) -- 1430
	return merged -- 1433
end -- 1433
function clearSessionTokenUsage(sessionId) -- 1436
	local session = getSessionItem(sessionId) -- 1437
	if not session then -- 1437
		return nil -- 1438
	end -- 1438
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1439
	__TS__Delete(metrics, "usage") -- 1440
	__TS__Delete(metrics, "visionUsage") -- 1441
	DB:exec( -- 1442
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1442
		{ -- 1446
			encodeJson(metrics), -- 1447
			now(), -- 1448
			sessionId -- 1449
		} -- 1449
	) -- 1449
	return metrics -- 1452
end -- 1452
function getInitialTokenUsage(session) -- 1455
	local ____opt_33 = session.metrics -- 1455
	local usage = ____opt_33 and ____opt_33.usage -- 1456
	if not usage or (usage.requestCount or 0) <= 0 then -- 1456
		return nil -- 1457
	end -- 1457
	return { -- 1458
		inputTokens = usage.inputTokens or 0, -- 1459
		outputTokens = usage.outputTokens or 0, -- 1460
		totalTokens = usage.totalTokens, -- 1461
		cachedInputTokens = usage.cachedInputTokens, -- 1462
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1463
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1464
		requestCount = usage.requestCount or 0, -- 1465
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1466
		model = usage.model or "", -- 1467
		phase = usage.phase or "", -- 1468
		step = usage.step or 0, -- 1469
		updatedAt = usage.updatedAt or now() -- 1470
	} -- 1470
end -- 1470
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1474
	if taskId == nil or taskId <= 0 then -- 1474
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1476
		return -- 1477
	end -- 1477
	local row = getSessionRow(sessionId) -- 1479
	if not row then -- 1479
		return -- 1480
	end -- 1480
	local session = rowToSession(row) -- 1481
	if session.currentTaskId ~= taskId then -- 1481
		Log( -- 1483
			"Info", -- 1483
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1483
		) -- 1483
		return -- 1484
	end -- 1484
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1486
end -- 1486
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1489
	local t = now() -- 1490
	DB:exec( -- 1491
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1491
		{ -- 1494
			sessionId, -- 1495
			taskId or 0, -- 1496
			role, -- 1497
			sanitizeUTF8(content), -- 1498
			displayContent and sanitizeUTF8(displayContent) or "", -- 1499
			t, -- 1500
			t -- 1501
		} -- 1501
	) -- 1501
	return getLastInsertRowId() -- 1504
end -- 1504
function updateMessage(messageId, content) -- 1507
	DB:exec( -- 1508
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1508
		{ -- 1510
			sanitizeUTF8(content), -- 1510
			now(), -- 1510
			messageId -- 1510
		} -- 1510
	) -- 1510
end -- 1510
function updateUserMessageForTask(messageId, content, taskId) -- 1514
	DB:exec( -- 1515
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1515
		{ -- 1519
			sanitizeUTF8(content), -- 1519
			taskId, -- 1519
			now(), -- 1519
			messageId -- 1519
		} -- 1519
	) -- 1519
end -- 1519
function removeContinuableTaskSummary(session) -- 1576
	local taskId = session.currentTaskId -- 1577
	if taskId == nil then -- 1577
		return -- 1578
	end -- 1578
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1579
end -- 1579
function upsertAssistantMessage(sessionId, taskId, content) -- 1591
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1592
	if row and type(row[1]) == "number" then -- 1592
		updateMessage(row[1], content) -- 1599
		return row[1] -- 1600
	end -- 1600
	return insertMessage(sessionId, "assistant", content, taskId) -- 1602
end -- 1602
function upsertStep(sessionId, taskId, step, tool, patch) -- 1605
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1615
	local reason = sanitizeUTF8(patch.reason or "") -- 1619
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1620
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1621
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1622
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1623
	local statusPatch = patch.status or "" -- 1624
	local status = patch.status or "PENDING" -- 1625
	if not row then -- 1625
		local t = now() -- 1627
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1628
			sessionId, -- 1632
			taskId, -- 1633
			step, -- 1634
			tool, -- 1635
			status, -- 1636
			reason, -- 1637
			reasoningContent, -- 1638
			paramsJson, -- 1639
			resultJson, -- 1640
			patch.checkpointId or 0, -- 1641
			patch.checkpointSeq or 0, -- 1642
			filesJson, -- 1643
			t, -- 1644
			t -- 1645
		}) -- 1645
		return -- 1648
	end -- 1648
	DB:exec( -- 1650
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1650
		{ -- 1662
			tool, -- 1663
			statusPatch, -- 1664
			status, -- 1665
			reason, -- 1666
			reason, -- 1667
			reasoningContent, -- 1668
			reasoningContent, -- 1669
			paramsJson, -- 1670
			paramsJson, -- 1671
			resultJson, -- 1672
			resultJson, -- 1673
			patch.checkpointId or 0, -- 1674
			patch.checkpointId or 0, -- 1675
			patch.checkpointSeq or 0, -- 1676
			patch.checkpointSeq or 0, -- 1677
			filesJson, -- 1678
			filesJson, -- 1679
			now(), -- 1680
			row[1] -- 1681
		} -- 1681
	) -- 1681
end -- 1681
function getNextStepNumber(sessionId, taskId) -- 1686
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1687
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1691
	return math.max(0, current) + 1 -- 1692
end -- 1692
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1733
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1741
	local t = now() -- 1742
	local sqls = { -- 1743
		{ -- 1744
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1744
			{{ -- 1747
				sessionId, -- 1748
				ownerTaskId, -- 1749
				step, -- 1750
				"sub_agent_handoff", -- 1751
				"DONE", -- 1752
				sanitizeUTF8(reason), -- 1753
				encodeJson(params), -- 1754
				encodeJson(result), -- 1755
				t, -- 1756
				t -- 1757
			}} -- 1757
		}, -- 1757
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1760
	} -- 1760
	if not DB:transaction(sqls) then -- 1760
		return nil -- 1766
	end -- 1766
	return getStepItem(sessionId, ownerTaskId, step) -- 1767
end -- 1767
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1770
	if taskId <= 0 then -- 1770
		return -- 1771
	end -- 1771
	if finalSteps ~= nil and finalSteps >= 0 then -- 1771
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1773
	end -- 1773
	if not finalStatus then -- 1773
		return -- 1779
	end -- 1779
	if finalSteps ~= nil and finalSteps >= 0 then -- 1779
		DB:exec( -- 1781
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1781
			{ -- 1785
				finalStatus, -- 1785
				now(), -- 1785
				sessionId, -- 1785
				taskId, -- 1785
				finalSteps -- 1785
			} -- 1785
		) -- 1785
		return -- 1787
	end -- 1787
	DB:exec( -- 1789
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1789
		{ -- 1793
			finalStatus, -- 1793
			now(), -- 1793
			sessionId, -- 1793
			taskId -- 1793
		} -- 1793
	) -- 1793
end -- 1793
function emitAgentSessionPatch(sessionId, patch) -- 1820
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1821
	if not text then -- 1821
		return -- 1826
	end -- 1826
	local failed = publishSessionPatch(sessionId, text) -- 1827
	if failed > 0 then -- 1827
		Log( -- 1828
			"Warn", -- 1828
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 1828
		) -- 1828
	end -- 1828
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 1828
		emit("AppWS", "Send", text) -- 1829
	end -- 1829
end -- 1829
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1832
	emitAgentSessionPatch( -- 1833
		sessionId, -- 1833
		{ -- 1833
			sessionDeleted = true, -- 1834
			relatedSessions = listRelatedSessions(rootSessionId) -- 1835
		} -- 1835
	) -- 1835
	local rootSession = getSessionItem(rootSessionId) -- 1837
	if rootSession then -- 1837
		emitAgentSessionPatch( -- 1839
			rootSessionId, -- 1839
			{ -- 1839
				session = rootSession, -- 1840
				relatedSessions = listRelatedSessions(rootSessionId) -- 1841
			} -- 1841
		) -- 1841
	end -- 1841
end -- 1841
function flushPendingSubAgentHandoffs(rootSession) -- 1846
	if rootSession.kind ~= "main" then -- 1846
		return -- 1847
	end -- 1847
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1847
		return -- 1849
	end -- 1849
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1851
	if #items == 0 then -- 1851
		return -- 1852
	end -- 1852
	local handoffTaskId = 0 -- 1853
	local previousTaskId = rootSession.currentTaskId -- 1854
	local ____rootSession_currentTaskId_37 -- 1855
	if rootSession.currentTaskId then -- 1855
		____rootSession_currentTaskId_37 = getTaskPrompt(rootSession.currentTaskId) -- 1855
	else -- 1855
		____rootSession_currentTaskId_37 = nil -- 1855
	end -- 1855
	local currentTaskPrompt = ____rootSession_currentTaskId_37 -- 1855
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1855
		handoffTaskId = rootSession.currentTaskId -- 1863
	else -- 1863
		local taskRes = Tools.createTask( -- 1865
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1865
			"code" -- 1865
		) -- 1865
		if not taskRes.success then -- 1865
			Log( -- 1867
				"Warn", -- 1867
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1867
			) -- 1867
			return -- 1868
		end -- 1868
		handoffTaskId = taskRes.taskId -- 1870
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1871
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1872
		emitAgentSessionPatch( -- 1873
			rootSession.id, -- 1873
			{session = getSessionItem(rootSession.id)} -- 1873
		) -- 1873
	end -- 1873
	do -- 1873
		local i = 0 -- 1877
		while i < #items do -- 1877
			local item = items[i + 1] -- 1878
			local step = appendHandoffSystemStep( -- 1879
				rootSession.id, -- 1880
				handoffTaskId, -- 1881
				item.sourceTaskId, -- 1882
				item.message, -- 1883
				{ -- 1884
					sourceSessionId = item.sourceSessionId, -- 1885
					sourceTitle = item.sourceTitle, -- 1886
					sourceTaskId = item.sourceTaskId, -- 1887
					success = item.success == true, -- 1888
					summary = item.message, -- 1889
					resultFilePath = item.resultFilePath or "", -- 1890
					artifactDir = item.artifactDir or "", -- 1891
					finishedAt = item.finishedAt or "", -- 1892
					changeSet = item.changeSet, -- 1893
					handoffEvidence = item.handoffEvidence, -- 1894
					memoryEntry = item.memoryEntry, -- 1895
					completion = item.completion -- 1896
				}, -- 1896
				{ -- 1898
					sourceSessionId = item.sourceSessionId, -- 1899
					sourceTitle = item.sourceTitle, -- 1900
					sourceTaskId = item.sourceTaskId, -- 1901
					prompt = item.prompt, -- 1902
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1903
					expectedOutput = item.expectedOutput or "", -- 1904
					filesHint = item.filesHint or ({}), -- 1905
					resultFilePath = item.resultFilePath or "", -- 1906
					artifactDir = item.artifactDir or "", -- 1907
					changeSet = item.changeSet, -- 1908
					handoffEvidence = item.handoffEvidence, -- 1909
					memoryEntry = item.memoryEntry, -- 1910
					completion = item.completion -- 1911
				} -- 1911
			) -- 1911
			if step then -- 1911
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1915
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1916
			else -- 1916
				Log( -- 1918
					"Warn", -- 1918
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1918
				) -- 1918
			end -- 1918
			i = i + 1 -- 1877
		end -- 1877
	end -- 1877
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1877
		cleanupTaskHeavyData(previousTaskId) -- 1922
	end -- 1922
end -- 1922
function applyEvent(sessionId, event) -- 1934
	if not getSessionItem(sessionId) then -- 1934
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1934
			__TS__Delete(activeStopTokens, event.taskId) -- 1937
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1938
		end -- 1938
		return -- 1940
	end -- 1940
	repeat -- 1940
		local ____switch320 = event.type -- 1940
		local metrics, startedSession -- 1940
		local ____cond320 = ____switch320 == "task_started" -- 1940
		if ____cond320 then -- 1940
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1944
			local ____event_resumed_40 -- 1945
			if event.resumed then -- 1945
				local ____opt_38 = getSessionItem(sessionId) -- 1945
				____event_resumed_40 = ____opt_38 and ____opt_38.metrics -- 1946
			else -- 1946
				____event_resumed_40 = clearSessionTokenUsage(sessionId) -- 1947
			end -- 1947
			metrics = ____event_resumed_40 -- 1945
			startedSession = getSessionItem(sessionId) -- 1948
			emitAgentSessionPatch( -- 1949
				sessionId, -- 1949
				{ -- 1949
					session = startedSession, -- 1950
					metrics = metrics, -- 1951
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1952
				} -- 1952
			) -- 1952
			break -- 1956
		end -- 1956
		____cond320 = ____cond320 or ____switch320 == "decision_made" -- 1956
		if ____cond320 then -- 1956
			upsertStep( -- 1958
				sessionId, -- 1958
				event.taskId, -- 1958
				event.step, -- 1958
				event.tool, -- 1958
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1958
			) -- 1958
			emitAgentSessionPatch( -- 1966
				sessionId, -- 1966
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1966
			) -- 1966
			break -- 1969
		end -- 1969
		____cond320 = ____cond320 or ____switch320 == "tool_started" -- 1969
		if ____cond320 then -- 1969
			upsertStep( -- 1971
				sessionId, -- 1971
				event.taskId, -- 1971
				event.step, -- 1971
				event.tool, -- 1971
				{status = "RUNNING"} -- 1971
			) -- 1971
			emitAgentSessionPatch( -- 1974
				sessionId, -- 1974
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1974
			) -- 1974
			break -- 1977
		end -- 1977
		____cond320 = ____cond320 or ____switch320 == "tool_finished" -- 1977
		if ____cond320 then -- 1977
			do -- 1977
				upsertStep( -- 1979
					sessionId, -- 1979
					event.taskId, -- 1979
					event.step, -- 1979
					event.tool, -- 1979
					{status = event.execution.status, reason = event.reason, result = event.result} -- 1979
				) -- 1979
				emitAgentSessionPatch( -- 1987
					sessionId, -- 1987
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1987
				) -- 1987
				break -- 1990
			end -- 1990
		end -- 1990
		____cond320 = ____cond320 or ____switch320 == "tool_progress" -- 1990
		if ____cond320 then -- 1990
			do -- 1990
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1994
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1994
					break -- 1996
				end -- 1996
			end -- 1996
			upsertStep( -- 1999
				sessionId, -- 1999
				event.taskId, -- 1999
				event.step, -- 1999
				event.tool, -- 1999
				{status = "RUNNING", result = event.result} -- 1999
			) -- 1999
			emitAgentSessionPatch( -- 2003
				sessionId, -- 2003
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2003
			) -- 2003
			break -- 2006
		end -- 2006
		____cond320 = ____cond320 or ____switch320 == "checkpoint_created" -- 2006
		if ____cond320 then -- 2006
			upsertStep( -- 2008
				sessionId, -- 2008
				event.taskId, -- 2008
				event.step, -- 2008
				event.tool, -- 2008
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2008
			) -- 2008
			emitAgentSessionPatch( -- 2013
				sessionId, -- 2013
				{ -- 2013
					step = getStepItem(sessionId, event.taskId, event.step), -- 2014
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2015
				} -- 2015
			) -- 2015
			break -- 2017
		end -- 2017
		____cond320 = ____cond320 or ____switch320 == "memory_compression_started" -- 2017
		if ____cond320 then -- 2017
			upsertStep( -- 2019
				sessionId, -- 2019
				event.taskId, -- 2019
				event.step, -- 2019
				event.tool, -- 2019
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2019
			) -- 2019
			emitAgentSessionPatch( -- 2024
				sessionId, -- 2024
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2024
			) -- 2024
			break -- 2027
		end -- 2027
		____cond320 = ____cond320 or ____switch320 == "memory_compression_finished" -- 2027
		if ____cond320 then -- 2027
			upsertStep( -- 2029
				sessionId, -- 2029
				event.taskId, -- 2029
				event.step, -- 2029
				event.tool, -- 2029
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2029
			) -- 2029
			emitAgentSessionPatch( -- 2034
				sessionId, -- 2034
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2034
			) -- 2034
			break -- 2037
		end -- 2037
		____cond320 = ____cond320 or ____switch320 == "metrics_updated" -- 2037
		if ____cond320 then -- 2037
			do -- 2037
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2039
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2040
				break -- 2043
			end -- 2043
		end -- 2043
		____cond320 = ____cond320 or ____switch320 == "assistant_message_updated" -- 2043
		if ____cond320 then -- 2043
			do -- 2043
				upsertStep( -- 2046
					sessionId, -- 2046
					event.taskId, -- 2046
					event.step, -- 2046
					"message", -- 2046
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2046
				) -- 2046
				emitAgentSessionPatch( -- 2051
					sessionId, -- 2051
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2051
				) -- 2051
				break -- 2054
			end -- 2054
		end -- 2054
		____cond320 = ____cond320 or ____switch320 == "assistant_message_finished" -- 2054
		if ____cond320 then -- 2054
			do -- 2054
				upsertStep( -- 2057
					sessionId, -- 2057
					event.taskId, -- 2057
					event.step, -- 2057
					"message", -- 2057
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2057
				) -- 2057
				emitAgentSessionPatch( -- 2063
					sessionId, -- 2063
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2063
				) -- 2063
				break -- 2066
			end -- 2066
		end -- 2066
		____cond320 = ____cond320 or ____switch320 == "task_waiting_for_user" -- 2066
		if ____cond320 then -- 2066
			do -- 2066
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2069
				__TS__Delete(activeStopTokens, event.taskId) -- 2070
				emitAgentSessionPatch( -- 2071
					sessionId, -- 2071
					{ -- 2071
						session = getSessionItem(sessionId), -- 2072
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2073
					} -- 2073
				) -- 2073
				break -- 2075
			end -- 2075
		end -- 2075
		____cond320 = ____cond320 or ____switch320 == "task_finished" -- 2075
		if ____cond320 then -- 2075
			do -- 2075
				local session = getSessionItem(sessionId) -- 2078
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2078
					__TS__Delete(activeStopTokens, event.taskId) -- 2080
					Log( -- 2081
						"Info", -- 2081
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2081
					) -- 2081
					break -- 2082
				end -- 2082
				local ____opt_41 = activeStopTokens[event.taskId or -1] -- 2082
				local stopped = (____opt_41 and ____opt_41.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2084
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2086
				local isSubSession = (session and session.kind) == "sub" -- 2089
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2090
				if isSubSession and event.taskId ~= nil then -- 2090
					finalizingSubSessionTaskIds[event.taskId] = true -- 2092
				end -- 2092
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2094
				if event.taskId ~= nil then -- 2094
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2096
					local ____finalizeTaskSteps_47 = finalizeTaskSteps -- 2097
					local ____array_46 = __TS__SparseArrayNew( -- 2097
						sessionId, -- 2098
						event.taskId, -- 2099
						type(event.steps) == "number" and math.max( -- 2100
							0, -- 2100
							math.floor(event.steps) -- 2100
						) or nil -- 2100
					) -- 2100
					local ____event_success_45 -- 2101
					if event.success then -- 2101
						____event_success_45 = nil -- 2101
					else -- 2101
						____event_success_45 = stopped and "STOPPED" or "FAILED" -- 2101
					end -- 2101
					__TS__SparseArrayPush(____array_46, ____event_success_45) -- 2101
					____finalizeTaskSteps_47(__TS__SparseArraySpread(____array_46)) -- 2097
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2103
					if not isSubSession then -- 2103
						__TS__Delete(activeStopTokens, event.taskId) -- 2105
					end -- 2105
					emitAgentSessionPatch( -- 2107
						sessionId, -- 2107
						{ -- 2107
							session = getSessionItem(sessionId), -- 2108
							message = getMessageItem(messageId), -- 2109
							removedStepIds = removedStepIds -- 2110
						} -- 2110
					) -- 2110
				end -- 2110
				if session and session.kind == "main" then -- 2110
					flushPendingSubAgentHandoffs(session) -- 2114
				end -- 2114
				break -- 2116
			end -- 2116
		end -- 2116
	until true -- 2116
end -- 2116
function ____exports.createSession(projectRoot, title) -- 2121
	if title == nil then -- 2121
		title = "" -- 2121
	end -- 2121
	local storage = requireAgentStorage() -- 2122
	if not storage.success then -- 2122
		return storage -- 2123
	end -- 2123
	if not isValidProjectRoot(projectRoot) then -- 2123
		return {success = false, message = "invalid projectRoot"} -- 2125
	end -- 2125
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2127
	if row then -- 2127
		return { -- 2136
			success = true, -- 2136
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2136
		} -- 2136
	end -- 2136
	local t = now() -- 2138
	DB:exec( -- 2139
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2139
		{ -- 2142
			projectRoot, -- 2142
			title ~= "" and title or Path:getFilename(projectRoot), -- 2142
			t, -- 2142
			t -- 2142
		} -- 2142
	) -- 2142
	local sessionId = getLastInsertRowId() -- 2144
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2145
	local session = getSessionItem(sessionId) -- 2146
	if not session then -- 2146
		return {success = false, message = "failed to create session"} -- 2148
	end -- 2148
	return {success = true, session = session} -- 2150
end -- 2121
function ____exports.createSubSession(parentSessionId, title) -- 2153
	if title == nil then -- 2153
		title = "" -- 2153
	end -- 2153
	local storage = requireAgentStorage() -- 2154
	if not storage.success then -- 2154
		return storage -- 2155
	end -- 2155
	local parent = getSessionItem(parentSessionId) -- 2156
	if not parent then -- 2156
		return {success = false, message = "parent session not found"} -- 2158
	end -- 2158
	local rootId = getSessionRootId(parent) -- 2160
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2160
		return {success = false, message = "project task admission is closed"} -- 2161
	end -- 2161
	local t = now() -- 2162
	DB:exec( -- 2163
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2163
		{ -- 2166
			parent.projectRoot, -- 2166
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2166
			rootId, -- 2166
			parent.id, -- 2166
			t, -- 2166
			t -- 2166
		} -- 2166
	) -- 2166
	local sessionId = getLastInsertRowId() -- 2168
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2169
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2170
	local session = getSessionItem(sessionId) -- 2171
	if not session then -- 2171
		return {success = false, message = "failed to create sub session"} -- 2173
	end -- 2173
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2175
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2176
	subStorage:writeMemory(parentStorage:readMemory()) -- 2177
	return {success = true, session = session} -- 2178
end -- 2153
function spawnSubAgentSession(request) -- 2181
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2181
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2194
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2195
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2196
		if normalizedPrompt == "" then -- 2196
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2198
		end -- 2198
		if normalizedPrompt == "" then -- 2198
			local ____Log_53 = Log -- 2205
			local ____temp_50 = #normalizedTitle -- 2205
			local ____temp_51 = #rawPrompt -- 2205
			local ____temp_52 = #toStr(request.expectedOutput) -- 2205
			local ____opt_48 = request.filesHint -- 2205
			____Log_53( -- 2205
				"Warn", -- 2205
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_50)) .. " raw_prompt_len=") .. tostring(____temp_51)) .. " expected_len=") .. tostring(____temp_52)) .. " files_hint_count=") .. tostring(____opt_48 and #____opt_48 or 0) -- 2205
			) -- 2205
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2205
		end -- 2205
		Log( -- 2208
			"Info", -- 2208
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2208
		) -- 2208
		local parentSessionId = request.parentSessionId -- 2209
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2209
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2211
			if not fallbackParent then -- 2211
				local createdMain = ____exports.createSession(request.projectRoot) -- 2213
				if createdMain.success then -- 2213
					fallbackParent = createdMain.session -- 2215
				end -- 2215
			end -- 2215
			if fallbackParent then -- 2215
				Log( -- 2219
					"Warn", -- 2219
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2219
				) -- 2219
				parentSessionId = fallbackParent.id -- 2220
			end -- 2220
		end -- 2220
		local parentSession = getSessionItem(parentSessionId) -- 2223
		if not parentSession then -- 2223
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2223
		end -- 2223
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2227
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2227
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2227
		end -- 2227
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2227
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2227
		end -- 2227
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2232
		if not created.success then -- 2232
			return ____awaiter_resolve(nil, created) -- 2232
		end -- 2232
		writeSpawnInfo( -- 2236
			created.session.projectRoot, -- 2236
			created.session.memoryScope, -- 2236
			{ -- 2236
				sessionId = created.session.id, -- 2237
				rootSessionId = created.session.rootSessionId, -- 2238
				parentSessionId = created.session.parentSessionId, -- 2239
				title = created.session.title, -- 2240
				prompt = normalizedPrompt, -- 2241
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2242
				expectedOutput = request.expectedOutput or "", -- 2243
				filesHint = request.filesHint or ({}), -- 2244
				status = "RUNNING", -- 2245
				success = false, -- 2246
				resultFilePath = "", -- 2247
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2248
				sourceTaskId = 0, -- 2249
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2250
				createdAtTs = created.session.createdAt, -- 2251
				finishedAt = "", -- 2252
				finishedAtTs = 0 -- 2253
			} -- 2253
		) -- 2253
		local sent = ____exports.sendPrompt( -- 2255
			created.session.id, -- 2255
			normalizedPrompt, -- 2255
			request.disabledAgentTools, -- 2255
			nil, -- 2255
			nil, -- 2255
			request.llmConfig -- 2255
		) -- 2255
		if not sent.success then -- 2255
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2255
		end -- 2255
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2255
	end) -- 2255
end -- 2255
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2376
	local rootSession = getRootSessionItem(session.id) -- 2377
	if not rootSession then -- 2377
		return -- 2378
	end -- 2378
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2379
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2380
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2381
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2382
	local queueResult = writePendingHandoff( -- 2383
		rootSession.projectRoot, -- 2383
		rootSession.memoryScope, -- 2383
		{ -- 2383
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2384
			sourceSessionId = session.id, -- 2385
			sourceTitle = session.title, -- 2386
			sourceTaskId = taskId, -- 2387
			message = summary, -- 2388
			prompt = result.prompt, -- 2389
			goal = result.goal, -- 2390
			expectedOutput = result.expectedOutput or "", -- 2391
			filesHint = result.filesHint or ({}), -- 2392
			success = result.success, -- 2393
			resultFilePath = result.resultFilePath, -- 2394
			artifactDir = result.artifactDir, -- 2395
			finishedAt = result.finishedAt, -- 2396
			changeSet = changeSet, -- 2397
			handoffEvidence = result.handoffEvidence, -- 2398
			memoryEntry = result.memoryEntry, -- 2399
			completion = result.completion, -- 2400
			createdAt = createdAt -- 2401
		} -- 2401
	) -- 2401
	if not queueResult then -- 2401
		Log( -- 2404
			"Warn", -- 2404
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2404
		) -- 2404
		return -- 2405
	end -- 2405
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2405
		addTaskReference(rootSession.currentTaskId, taskId) -- 2408
	end -- 2408
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2408
		flushPendingSubAgentHandoffs(rootSession) -- 2411
	end -- 2411
end -- 2411
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2415
	if forceHandoff == nil then -- 2415
		forceHandoff = false -- 2421
	end -- 2421
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2421
		local rootSessionId = getSessionRootId(session) -- 2423
		local rootSession = getRootSessionItem(session.id) -- 2424
		if not rootSession then -- 2424
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2424
		end -- 2424
		local spawnInfo = getSessionSpawnInfo(session) -- 2428
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2429
		local finishedAtTs = now() -- 2430
		local resultText = sanitizeUTF8(message) -- 2431
		local changeSet = getTaskChangeSetSummary(taskId) -- 2432
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2433
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2434
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2438
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2438
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2440
		end -- 2440
		local completed = success and completionReport.outcome == "completed" -- 2448
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2449
		local record = { -- 2452
			sessionId = session.id, -- 2453
			rootSessionId = rootSessionId, -- 2454
			parentSessionId = session.parentSessionId, -- 2455
			title = session.title, -- 2456
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2457
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2458
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2459
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2460
			status = recordStatus, -- 2461
			success = completed, -- 2462
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2463
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2464
			sourceTaskId = taskId, -- 2465
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2466
			finishedAt = finishedAt, -- 2467
			createdAtTs = session.createdAt, -- 2468
			finishedAtTs = finishedAtTs, -- 2469
			changeSet = changeSet, -- 2470
			handoffEvidence = handoffEvidence, -- 2471
			completion = completionReport -- 2472
		} -- 2472
		local ____record_success_70 -- 2474
		if record.success then -- 2474
			____record_success_70 = buildStructuredSubAgentMemoryEntry(record) -- 2474
		else -- 2474
			____record_success_70 = nil -- 2474
		end -- 2474
		record.memoryEntry = ____record_success_70 -- 2474
		if not writeSubAgentResultFile(session, record, resultText) then -- 2474
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2474
		end -- 2474
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2474
			sessionId = record.sessionId, -- 2479
			rootSessionId = record.rootSessionId, -- 2480
			parentSessionId = record.parentSessionId, -- 2481
			title = record.title, -- 2482
			prompt = record.prompt, -- 2483
			goal = record.goal, -- 2484
			expectedOutput = record.expectedOutput or "", -- 2485
			filesHint = record.filesHint or ({}), -- 2486
			status = record.status, -- 2487
			success = record.success, -- 2488
			resultFilePath = record.resultFilePath, -- 2489
			artifactDir = record.artifactDir, -- 2490
			sourceTaskId = record.sourceTaskId, -- 2491
			createdAt = record.createdAt, -- 2492
			finishedAt = record.finishedAt, -- 2493
			createdAtTs = record.createdAtTs, -- 2494
			finishedAtTs = record.finishedAtTs, -- 2495
			changeSet = record.changeSet, -- 2496
			handoffEvidence = record.handoffEvidence, -- 2497
			memoryEntry = record.memoryEntry, -- 2498
			memoryEntryError = record.memoryEntryError, -- 2499
			completion = record.completion -- 2500
		}) then -- 2500
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2500
		end -- 2500
		if success or forceHandoff then -- 2500
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2505
			deleteSessionRecords(session.id, true) -- 2506
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2507
		end -- 2507
		return ____awaiter_resolve(nil, {success = true}) -- 2507
	end) -- 2507
end -- 2507
function stopClearedSubSession(session, taskId) -- 2512
	local spawnInfo = getSessionSpawnInfo(session) -- 2513
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2514
	local rootSessionId = getSessionRootId(session) -- 2515
	Tools.setTaskStatus(taskId, "STOPPED") -- 2516
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2517
	if not writeSpawnInfo( -- 2517
		session.projectRoot, -- 2518
		session.memoryScope, -- 2518
		{ -- 2518
			sessionId = session.id, -- 2519
			rootSessionId = rootSessionId, -- 2520
			parentSessionId = session.parentSessionId, -- 2521
			title = session.title, -- 2522
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2523
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2524
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2525
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2526
			status = "STOPPED", -- 2527
			success = false, -- 2528
			cleared = true, -- 2529
			resultFilePath = "", -- 2530
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2531
			sourceTaskId = taskId, -- 2532
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2533
			finishedAt = finishedAt, -- 2534
			createdAtTs = session.createdAt, -- 2535
			finishedAtTs = now() -- 2536
		} -- 2536
	) then -- 2536
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2538
	end -- 2538
	deleteSessionRecords(session.id, true) -- 2540
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2541
	return {success = true} -- 2542
end -- 2542
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps) -- 2545
	local session = getSessionItem(sessionId) -- 2546
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2546
		return {success = false, message = "project task admission is closed"} -- 2547
	end -- 2547
	if not session then -- 2547
		return {success = false, message = "session not found"} -- 2549
	end -- 2549
	if getPendingQuestionnaire(sessionId) then -- 2549
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2551
	end -- 2551
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2551
		return {success = false, message = "session task is finalizing"} -- 2553
	end -- 2553
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2553
		return {success = false, message = "session task is still running"} -- 2556
	end -- 2556
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2558
	if normalizedPrompt == "" and session.kind == "sub" then -- 2558
		local spawnInfo = getSessionSpawnInfo(session) -- 2560
		if spawnInfo then -- 2560
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2562
			if normalizedPrompt == "" then -- 2562
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2564
			end -- 2564
		end -- 2564
	end -- 2564
	if normalizedPrompt == "" then -- 2564
		return {success = false, message = "prompt is empty"} -- 2573
	end -- 2573
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2575
	if session.workMode ~= nextWorkMode then -- 2575
		DB:exec( -- 2577
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2577
			{ -- 2577
				nextWorkMode, -- 2577
				now(), -- 2577
				session.id -- 2577
			} -- 2577
		) -- 2577
		session.workMode = nextWorkMode -- 2578
	end -- 2578
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2580
	return startPromptTask( -- 2581
		session, -- 2581
		normalizedPrompt, -- 2581
		nil, -- 2581
		normalizeDisabledAgentTools(disabledAgentTools), -- 2581
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig, maxSteps = boundedMaxSteps} -- 2581
	) -- 2581
end -- 2545
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2715
	if disabledAgentTools == nil then -- 2715
		disabledAgentTools = {} -- 2719
	end -- 2719
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2722
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2722
		return {success = false, message = "project task admission is closed"} -- 2723
	end -- 2723
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2724
	if not llmConfigRes.success then -- 2724
		return {success = false, message = llmConfigRes.message} -- 2728
	end -- 2728
	local llmConfig = llmConfigRes.config -- 2730
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2731
	if not llmConfigValidation.success then -- 2731
		return llmConfigValidation -- 2733
	end -- 2733
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2735
	if not taskRes.success then -- 2735
		return {success = false, message = taskRes.message} -- 2738
	end -- 2738
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2738
		removeContinuableTaskSummary(session) -- 2740
	end -- 2740
	local taskId = taskRes.taskId -- 2742
	local ____temp_91 -- 2743
	if (options and options.existingTaskId) == nil then -- 2743
		____temp_91 = session.currentTaskId -- 2743
	else -- 2743
		____temp_91 = nil -- 2743
	end -- 2743
	local previousTaskId = ____temp_91 -- 2743
	local useChineseResponse = getDefaultUseChineseResponse() -- 2744
	local promptMessageId -- 2745
	if existingUserMessageId ~= nil then -- 2745
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2747
		promptMessageId = existingUserMessageId -- 2748
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2748
		promptMessageId = insertMessage( -- 2750
			session.id, -- 2750
			"user", -- 2750
			normalizedPrompt, -- 2750
			taskId, -- 2750
			options and options.displayContent -- 2750
		) -- 2750
	end -- 2750
	local stopToken = {stopped = false} -- 2752
	activeStopTokens[taskId] = stopToken -- 2753
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2754
	emitAgentSessionPatch( -- 2758
		session.id, -- 2758
		__TS__ObjectAssign( -- 2758
			{session = getSessionItem(session.id)}, -- 2758
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 2760
		) -- 2760
	) -- 2760
	if previousTaskId and previousTaskId ~= taskId then -- 2760
		cleanupTaskHeavyData(previousTaskId) -- 2763
	end -- 2763
	activePromptRuns = activePromptRuns + 1 -- 2765
	local ____runCodingAgent_120 = runCodingAgent -- 2766
	local ____normalizedPrompt_113 = normalizedPrompt -- 2767
	local ____temp_114 = options and options.resumeConversation -- 2768
	local ____temp_115 = (options and options.existingTaskId) ~= nil -- 2769
	local ____temp_116 = options and options.initialStep -- 2770
	local ____temp_117 = options and options.initialAgentStepCount -- 2771
	local ____temp_108 -- 2772
	if (options and options.existingTaskId) ~= nil then -- 2772
		____temp_108 = getInitialTokenUsage(session) -- 2772
	else -- 2772
		____temp_108 = nil -- 2772
	end -- 2772
	____runCodingAgent_120( -- 2766
		{ -- 2766
			prompt = ____normalizedPrompt_113, -- 2767
			resumeConversation = ____temp_114, -- 2768
			resumeTask = ____temp_115, -- 2769
			initialStep = ____temp_116, -- 2770
			initialAgentStepCount = ____temp_117, -- 2771
			initialTokenUsage = ____temp_108, -- 2772
			workDir = session.projectRoot, -- 2773
			useChineseResponse = useChineseResponse, -- 2774
			taskId = taskId, -- 2775
			sessionId = session.id, -- 2776
			memoryScope = session.memoryScope, -- 2777
			role = session.kind, -- 2778
			maxSteps = options and options.maxSteps, -- 2779
			disabledAgentTools = disabledAgentTools, -- 2780
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2781
			llmConfig = llmConfig, -- 2782
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2783
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2786
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2789
			stopToken = stopToken, -- 2790
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2791
		}, -- 2791
		function(result) -- 2792
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2792
				local ____hasReturned, ____returnValue -- 2792
				local ____try = __TS__AsyncAwaiter(function() -- 2792
					local nextSession = getSessionItem(session.id) -- 2794
					if nextSession and nextSession.kind == "sub" then -- 2794
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2794
							local stopped = stopClearedSubSession(nextSession, taskId) -- 2797
							if not stopped.success then -- 2797
								Log( -- 2799
									"Warn", -- 2799
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2799
								) -- 2799
								emitAgentSessionPatch( -- 2800
									session.id, -- 2800
									{session = getSessionItem(session.id)} -- 2800
								) -- 2800
							end -- 2800
							__TS__Delete(activeStopTokens, taskId) -- 2804
							____hasReturned = true -- 2805
							return -- 2805
						end -- 2805
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2807
						emitAgentSessionPatch( -- 2808
							session.id, -- 2808
							{session = getSessionItem(session.id)} -- 2808
						) -- 2808
						local finalized = __TS__Await(finalizeSubSession( -- 2811
							nextSession, -- 2812
							taskId, -- 2813
							result.success, -- 2814
							result.message, -- 2815
							result.completion, -- 2816
							(options and options.forceSubAgentHandoff) == true -- 2817
						)) -- 2817
						if not finalized.success then -- 2817
							Log( -- 2820
								"Warn", -- 2820
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2820
							) -- 2820
						end -- 2820
						local finalizedSession = getSessionItem(session.id) -- 2822
						if finalizedSession then -- 2822
							local stopped = stopToken.stopped == true -- 2824
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2825
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2828
							emitAgentSessionPatch( -- 2829
								session.id, -- 2829
								{session = getSessionItem(session.id)} -- 2829
							) -- 2829
						end -- 2829
						__TS__Delete(activeStopTokens, taskId) -- 2833
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2834
					end -- 2834
					local fallbackSession = getSessionItem(session.id) -- 2836
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2836
						applyEvent(session.id, { -- 2842
							type = "task_finished", -- 2843
							sessionId = session.id, -- 2844
							taskId = result.taskId, -- 2845
							success = false, -- 2846
							message = result.message, -- 2847
							steps = result.steps -- 2848
						}) -- 2848
					end -- 2848
				end) -- 2848
				____try = ____try.finally( -- 2848
					____try, -- 2848
					function() -- 2848
						return __TS__AsyncAwaiter(function() -- 2848
							activePromptRuns = activePromptRuns - 1 -- 2852
						end) -- 2852
					end -- 2852
				) -- 2852
				__TS__Await(____try) -- 2793
				if ____hasReturned then -- 2793
					return ____awaiter_resolve(nil, ____returnValue) -- 2793
				end -- 2793
			end) -- 2793
		end -- 2792
	) -- 2792
	return {success = true, sessionId = session.id, taskId = taskId} -- 2855
end -- 2855
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3008
	local lines = {} -- 3009
	do -- 3009
		local i = 0 -- 3010
		while i < #questionnaire.schema.questions do -- 3010
			local question = questionnaire.schema.questions[i + 1] -- 3011
			local answer = __TS__ArrayFind( -- 3012
				answers, -- 3012
				function(____, item) return item.questionId == question.id end -- 3012
			) -- 3012
			local answerText = "已跳过" -- 3013
			if answer and answer.status == "answered" then -- 3013
				local parts = {} -- 3015
				do -- 3015
					local j = 0 -- 3016
					while j < #(answer.selectedOptionIds or ({})) do -- 3016
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3017
						local option = __TS__ArrayFind( -- 3018
							question.options or ({}), -- 3018
							function(____, item) return item.id == optionId end -- 3018
						) -- 3018
						if option then -- 3018
							parts[#parts + 1] = option.label -- 3019
						end -- 3019
						j = j + 1 -- 3016
					end -- 3016
				end -- 3016
				if answer.otherText then -- 3016
					parts[#parts + 1] = answer.otherText -- 3021
				end -- 3021
				if answer.text then -- 3021
					parts[#parts + 1] = answer.text -- 3022
				end -- 3022
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3023
			end -- 3023
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3025
			i = i + 1 -- 3010
		end -- 3010
	end -- 3010
	return table.concat(lines, "\n\n") -- 3027
end -- 3027
function ____exports.listRunningSubAgents(request) -- 3311
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3311
		local session = getSessionItem(request.sessionId) -- 3319
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3319
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3321
		end -- 3321
		if not session then -- 3321
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3321
		end -- 3321
		local rootSession = getRootSessionItem(session.id) -- 3326
		if not rootSession then -- 3326
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3326
		end -- 3326
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3330
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3331
		local limit = math.max( -- 3332
			1, -- 3332
			math.floor(tonumber(request.limit) or 5) -- 3332
		) -- 3332
		local offset = math.max( -- 3333
			0, -- 3333
			math.floor(tonumber(request.offset) or 0) -- 3333
		) -- 3333
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3334
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3335
		local runningSessions = {} -- 3342
		do -- 3342
			local i = 0 -- 3343
			while i < #rows do -- 3343
				do -- 3343
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3344
					if current.currentTaskStatus ~= "RUNNING" then -- 3344
						goto __continue561 -- 3346
					end -- 3346
					local spawnInfo = getSessionSpawnInfo(current) -- 3348
					runningSessions[#runningSessions + 1] = { -- 3349
						sessionId = current.id, -- 3350
						title = current.title, -- 3351
						parentSessionId = current.parentSessionId, -- 3352
						rootSessionId = current.rootSessionId, -- 3353
						status = "RUNNING", -- 3354
						currentTaskId = current.currentTaskId, -- 3355
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3356
						goal = spawnInfo and spawnInfo.goal, -- 3357
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3358
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3359
						createdAt = current.createdAt, -- 3360
						updatedAt = current.updatedAt -- 3361
					} -- 3361
				end -- 3361
				::__continue561:: -- 3361
				i = i + 1 -- 3343
			end -- 3343
		end -- 3343
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3364
		local completedSessions = __TS__ArrayMap( -- 3365
			completedRecords, -- 3365
			function(____, record) return { -- 3365
				sessionId = record.sessionId, -- 3366
				title = record.title, -- 3367
				parentSessionId = record.parentSessionId, -- 3368
				rootSessionId = record.rootSessionId, -- 3369
				status = record.status, -- 3370
				goal = record.goal, -- 3371
				expectedOutput = record.expectedOutput, -- 3372
				filesHint = record.filesHint, -- 3373
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3374
				success = record.success, -- 3375
				cleared = record.cleared, -- 3376
				resultFilePath = record.resultFilePath, -- 3377
				artifactDir = record.artifactDir, -- 3378
				finishedAt = record.finishedAt, -- 3379
				createdAt = record.createdAtTs, -- 3380
				updatedAt = record.finishedAtTs -- 3381
			} end -- 3381
		) -- 3381
		local merged = {} -- 3383
		if status == "running" then -- 3383
			merged = runningSessions -- 3385
		elseif status == "done" then -- 3385
			merged = __TS__ArrayFilter( -- 3387
				completedSessions, -- 3387
				function(____, item) return item.status == "DONE" end -- 3387
			) -- 3387
		elseif status == "failed" then -- 3387
			merged = __TS__ArrayFilter( -- 3389
				completedSessions, -- 3389
				function(____, item) return item.status == "FAILED" end -- 3389
			) -- 3389
		elseif status == "stopped" then -- 3389
			merged = __TS__ArrayFilter( -- 3391
				completedSessions, -- 3391
				function(____, item) return item.status == "STOPPED" end -- 3391
			) -- 3391
		elseif status == "all" then -- 3391
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3393
		else -- 3393
			local runningKeys = {} -- 3395
			do -- 3395
				local i = 0 -- 3396
				while i < #runningSessions do -- 3396
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3397
					i = i + 1 -- 3396
				end -- 3396
			end -- 3396
			local latestCompletedByKey = {} -- 3399
			do -- 3399
				local i = 0 -- 3400
				while i < #completedSessions do -- 3400
					do -- 3400
						local item = completedSessions[i + 1] -- 3401
						local key = getSubAgentDisplayKey(item) -- 3402
						if runningKeys[key] then -- 3402
							goto __continue576 -- 3404
						end -- 3404
						local current = latestCompletedByKey[key] -- 3406
						if current == nil or item.updatedAt > current.updatedAt then -- 3406
							latestCompletedByKey[key] = item -- 3408
						end -- 3408
					end -- 3408
					::__continue576:: -- 3408
					i = i + 1 -- 3400
				end -- 3400
			end -- 3400
			local latestCompleted = {} -- 3411
			for ____, item in pairs(latestCompletedByKey) do -- 3412
				latestCompleted[#latestCompleted + 1] = item -- 3413
			end -- 3413
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3415
		end -- 3415
		if query ~= "" then -- 3415
			merged = __TS__ArrayFilter( -- 3418
				merged, -- 3418
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3418
			) -- 3418
		end -- 3418
		__TS__ArraySort( -- 3424
			merged, -- 3424
			function(____, a, b) -- 3424
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3424
					return -1 -- 3425
				end -- 3425
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3425
					return 1 -- 3426
				end -- 3426
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3426
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3428
				end -- 3428
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3430
			end -- 3424
		) -- 3424
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3432
		return ____awaiter_resolve(nil, { -- 3432
			success = true, -- 3434
			rootSessionId = rootSession.id, -- 3435
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3436
			status = status, -- 3437
			limit = limit, -- 3438
			offset = offset, -- 3439
			hasMore = offset + limit < #merged, -- 3440
			sessions = paged -- 3441
		}) -- 3441
	end) -- 3441
end -- 3311
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
--- Runtime ownership, including asynchronous completion after task status changes.
function ____exports.isRuntimeIdle() -- 339
	return activePromptRuns == 0 and #__TS__ObjectKeys(activeStopTokens) == 0 and #__TS__ObjectKeys(activeLocalAgentControls) == 0 and #__TS__ObjectKeys(finalizingSubSessionTaskIds) == 0 -- 340
end -- 339
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 345
now = function() return os.time() end -- 346
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 994
	if projectRoot == oldRoot then -- 994
		return newRoot -- 996
	end -- 996
	for ____, separator in ipairs({"/", "\\"}) do -- 998
		local prefix = oldRoot .. separator -- 999
		if __TS__StringStartsWith(projectRoot, prefix) then -- 999
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 1001
		end -- 1001
	end -- 1001
	return nil -- 1004
end -- 994
local function clearSessionAfterMessage(sessionId, message) -- 1523
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1524
	local removedStepIds = {} -- 1532
	do -- 1532
		local i = 0 -- 1533
		while i < #removedStepRows do -- 1533
			local row = removedStepRows[i + 1] -- 1534
			if type(row[1]) == "number" then -- 1534
				removedStepIds[#removedStepIds + 1] = row[1] -- 1536
			end -- 1536
			i = i + 1 -- 1533
		end -- 1533
	end -- 1533
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1539
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1547
	return removedStepIds -- 1552
end -- 1523
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1555
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1556
	local persisted = storage:readSessionState() -- 1557
	local userIndex = -1 -- 1558
	do -- 1558
		local i = #persisted.messages - 1 -- 1559
		while i >= 0 do -- 1559
			if persisted.messages[i + 1].role == "user" then -- 1559
				userIndex = i -- 1561
				break -- 1562
			end -- 1562
			i = i - 1 -- 1559
		end -- 1559
	end -- 1559
	if userIndex < 0 then -- 1559
		return -- 1565
	end -- 1565
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1566
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1567
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1568
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1573
end -- 1555
local function listCurrentTaskCheckpoints(sessionId) -- 1585
	local session = getSessionItem(sessionId) -- 1586
	local taskId = session and session.currentTaskId -- 1587
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1588
end -- 1585
local function getAgentStepCount(sessionId, taskId) -- 1695
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1696
		sessionId, -- 1701
		taskId, -- 1702
		"compress_memory", -- 1703
		"merge_memory", -- 1704
		"sub_agent_handoff", -- 1705
		"questionnaire_answer", -- 1706
		"message" -- 1707
	}) -- 1707
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1710
end -- 1695
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1713
	if status == nil then -- 1713
		status = "DONE" -- 1721
	end -- 1721
	local step = getNextStepNumber(sessionId, taskId) -- 1723
	upsertStep( -- 1724
		sessionId, -- 1724
		taskId, -- 1724
		step, -- 1724
		tool, -- 1724
		{status = status, reason = reason, params = params, result = result} -- 1724
	) -- 1724
	return getStepItem(sessionId, taskId, step) -- 1730
end -- 1713
local function sanitizeStoredSteps(sessionId) -- 1797
	DB:exec( -- 1798
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1798
		{ -- 1816
			now(), -- 1816
			sessionId -- 1816
		} -- 1816
	) -- 1816
end -- 1797
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2267
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2267
		return {success = false, message = "invalid projectRoot"} -- 2269
	end -- 2269
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2271
	for ____, row in ipairs(rows) do -- 2272
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2273
		if sessionId > 0 then -- 2273
			deleteSessionRecords(sessionId) -- 2275
		end -- 2275
	end -- 2275
	return {success = true, deleted = #rows} -- 2278
end -- 2267
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2281
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2281
		return {success = false, message = "invalid projectRoot"} -- 2283
	end -- 2283
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2285
	local renamed = 0 -- 2286
	for ____, row in ipairs(rows) do -- 2287
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2288
		local projectRoot = toStr(row[2]) -- 2289
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2290
		if sessionId > 0 and nextProjectRoot then -- 2290
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2292
			DB:exec( -- 2293
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2293
				{ -- 2295
					nextProjectRoot, -- 2295
					Path:getFilename(nextProjectRoot), -- 2295
					now(), -- 2295
					sessionId -- 2295
				} -- 2295
			) -- 2295
			renamed = renamed + 1 -- 2297
		end -- 2297
	end -- 2297
	return {success = true, renamed = renamed} -- 2300
end -- 2281
function ____exports.getSession(sessionId, view) -- 2303
	local session = getSessionItem(sessionId) -- 2304
	if not session then -- 2304
		return {success = false, message = "session not found"} -- 2306
	end -- 2306
	local restored = restorePendingQuestionnaireState(session) -- 2308
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2309
	local relatedSessions = listRelatedSessions(sessionId) -- 2310
	sanitizeStoredSteps(sessionId) -- 2311
	local firstMessageId = 0 -- 2312
	local hasEarlierMessages = false -- 2313
	if view then -- 2313
		local limit = math.max( -- 2315
			1, -- 2315
			math.min( -- 2315
				1000, -- 2315
				math.floor(view.recentRounds) -- 2315
			) -- 2315
		) -- 2315
		local requests = queryRows(("SELECT id FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND role = 'user'\n\t\t\tORDER BY id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2316
		if #requests > limit then -- 2316
			firstMessageId = requests[limit][1] -- 2321
			hasEarlierMessages = true -- 2322
		end -- 2322
	end -- 2322
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2325
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2332
	local ____relatedSessions_59 = relatedSessions -- 2344
	local ____temp_58 -- 2345
	if normalizedSession.kind == "sub" then -- 2345
		____temp_58 = getSessionSpawnInfo(normalizedSession) -- 2345
	else -- 2345
		____temp_58 = nil -- 2345
	end -- 2345
	return { -- 2341
		success = true, -- 2342
		session = normalizedSession, -- 2343
		relatedSessions = ____relatedSessions_59, -- 2344
		spawnInfo = ____temp_58, -- 2345
		messages = __TS__ArrayMap( -- 2346
			messages, -- 2346
			function(____, row) return rowToMessage(row) end -- 2346
		), -- 2346
		hasEarlierMessages = hasEarlierMessages, -- 2347
		steps = __TS__ArrayMap( -- 2348
			steps, -- 2348
			function(____, row) return rowToStep(row) end -- 2348
		), -- 2348
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2349
		pendingQuestionnaire = restored.questionnaire, -- 2350
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2351
	} -- 2351
end -- 2303
function ____exports.setWorkMode(sessionId, workMode) -- 2356
	local session = getSessionItem(sessionId) -- 2357
	if not session then -- 2357
		return {success = false, message = "session not found"} -- 2358
	end -- 2358
	if session.kind ~= "main" then -- 2358
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2359
	end -- 2359
	if workMode ~= "code" and workMode ~= "plan" then -- 2359
		return {success = false, message = "invalid work mode"} -- 2360
	end -- 2360
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2361
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2361
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2363
	end -- 2363
	if getPendingQuestionnaire(sessionId) then -- 2363
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2366
	end -- 2366
	if normalizedSession.workMode ~= workMode then -- 2366
		DB:exec( -- 2369
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2369
			{ -- 2369
				workMode, -- 2369
				now(), -- 2369
				sessionId -- 2369
			} -- 2369
		) -- 2369
	end -- 2369
	local updated = getSessionItem(sessionId) -- 2371
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2372
	return { -- 2373
		success = true, -- 2373
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2373
	} -- 2373
end -- 2356
function ____exports.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 2584
	local session = getSessionItem(sessionId) -- 2585
	if not session then -- 2585
		return {success = false, message = "session not found"} -- 2586
	end -- 2586
	if session.kind ~= "main" then -- 2586
		return {success = false, message = "local Agent only supports main sessions"} -- 2587
	end -- 2587
	if getPendingQuestionnaire(sessionId) then -- 2587
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2588
	end -- 2588
	if session.currentTaskStatus == "RUNNING" then -- 2588
		return {success = false, message = "session task is still running"} -- 2589
	end -- 2589
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2590
	if normalizedPrompt == "" then -- 2590
		return {success = false, message = "prompt is empty"} -- 2591
	end -- 2591
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2592
	if not config then -- 2592
		return {success = false, message = "local Agent config not found"} -- 2593
	end -- 2593
	if not config.verifiedAt then -- 2593
		return {success = false, message = "local Agent config is not verified"} -- 2594
	end -- 2594
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2595
	if not taskRes.success then -- 2595
		return taskRes -- 2596
	end -- 2596
	local taskId = taskRes.taskId -- 2597
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2598
	Tools.setTaskStatus(taskId, "RUNNING") -- 2599
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2600
	upsertStep( -- 2601
		session.id, -- 2601
		taskId, -- 2601
		1, -- 2601
		"local_agent_message", -- 2601
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2601
	) -- 2601
	emitAgentSessionPatch( -- 2607
		session.id, -- 2607
		{ -- 2607
			session = getSessionItem(session.id), -- 2608
			message = getMessageItem(messageId), -- 2609
			step = getStepItem(session.id, taskId, 1) -- 2610
		} -- 2610
	) -- 2610
	local events = {} -- 2612
	local transcript = "" -- 2613
	local assistant = "" -- 2614
	local lastFlush = 0 -- 2615
	local function flush(force) -- 2616
		if force == nil then -- 2616
			force = false -- 2616
		end -- 2616
		if not force and App.runningTime - lastFlush < 0.075 then -- 2616
			return -- 2617
		end -- 2617
		lastFlush = App.runningTime -- 2618
		if #events > 400 then -- 2618
			events = __TS__ArraySlice(events, #events - 400) -- 2619
		end -- 2619
		if #transcript > 1024 * 1024 then -- 2619
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2620
		end -- 2620
		upsertStep( -- 2621
			session.id, -- 2621
			taskId, -- 2621
			1, -- 2621
			"local_agent_message", -- 2621
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2621
		) -- 2621
		local message -- 2626
		if assistant ~= "" then -- 2626
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2628
			message = getMessageItem(assistantId) -- 2629
		end -- 2629
		emitAgentSessionPatch( -- 2631
			session.id, -- 2631
			__TS__ObjectAssign( -- 2631
				{step = getStepItem(session.id, taskId, 1)}, -- 2631
				message and ({message = message}) or ({}) -- 2631
			) -- 2631
		) -- 2631
	end -- 2616
	local completedSynchronously = false -- 2633
	local control = LocalAgent.run( -- 2634
		session.id, -- 2634
		config, -- 2634
		session.projectRoot, -- 2634
		normalizedPrompt, -- 2634
		function(event) -- 2634
			local text = sanitizeUTF8(event.text) -- 2635
			if text == "" then -- 2635
				return -- 2636
			end -- 2636
			local previous = #events > 0 and events[#events] or nil -- 2637
			if previous and previous.kind == event.kind and previous.text == text then -- 2637
				return -- 2638
			end -- 2638
			events[#events + 1] = {kind = event.kind, text = text} -- 2639
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2640
			if event.kind == "assistant" then -- 2640
				assistant = text -- 2641
			end -- 2641
			flush(false) -- 2642
		end, -- 2634
		function(result) -- 2643
			completedSynchronously = true -- 2644
			flush(true) -- 2645
			__TS__Delete(activeLocalAgentControls, taskId) -- 2646
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2647
			Tools.setTaskStatus(taskId, status) -- 2648
			setSessionState(session.id, status, taskId, status) -- 2649
			upsertStep( -- 2650
				session.id, -- 2650
				taskId, -- 2650
				1, -- 2650
				"local_agent_message", -- 2650
				{status = status, reason = config.name .. " · full permissions", result = { -- 2650
					provider = config.provider, -- 2653
					events = events, -- 2653
					transcript = transcript, -- 2653
					exitCode = result.exitCode, -- 2653
					resumeId = result.resumeId, -- 2653
					message = result.message -- 2653
				}} -- 2653
			) -- 2653
			emitAgentSessionPatch( -- 2655
				session.id, -- 2655
				{ -- 2655
					session = getSessionItem(session.id), -- 2655
					step = getStepItem(session.id, taskId, 1) -- 2655
				} -- 2655
			) -- 2655
		end -- 2643
	) -- 2643
	if not completedSynchronously then -- 2643
		activeLocalAgentControls[taskId] = control -- 2657
	end -- 2657
	return {success = true, sessionId = session.id, taskId = taskId} -- 2658
end -- 2584
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2661
	local session = getSessionItem(sessionId) -- 2662
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2662
		return {success = false, message = "project task admission is closed"} -- 2663
	end -- 2663
	if not session then -- 2663
		return {success = false, message = "session not found"} -- 2665
	end -- 2665
	if getPendingQuestionnaire(sessionId) then -- 2665
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2667
	end -- 2667
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2667
		return {success = false, message = "session task is finalizing"} -- 2669
	end -- 2669
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2669
		return {success = false, message = "session task is still stopping"} -- 2672
	end -- 2672
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2672
		return {success = false, message = "session task is not continuable"} -- 2675
	end -- 2675
	if session.currentTaskId == nil then -- 2675
		return {success = false, message = "session task not found"} -- 2678
	end -- 2678
	local taskId = session.currentTaskId -- 2680
	return startPromptTask( -- 2681
		session, -- 2682
		"", -- 2683
		nil, -- 2684
		normalizeDisabledAgentTools(disabledAgentTools), -- 2685
		{ -- 2686
			workMode = session.workMode, -- 2687
			persistUserMessage = false, -- 2688
			resumeConversation = true, -- 2689
			existingTaskId = taskId, -- 2690
			initialStep = math.max( -- 2691
				0, -- 2691
				getNextStepNumber(session.id, taskId) - 1 -- 2691
			), -- 2691
			initialAgentStepCount = 0, -- 2695
			llmConfigId = llmConfigId -- 2696
		} -- 2696
	) -- 2696
end -- 2661
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2858
	local session = getSessionItem(sessionId) -- 2859
	if not session then -- 2859
		return {success = false, message = "session not found"} -- 2861
	end -- 2861
	if session.kind ~= "sub" then -- 2861
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2864
	end -- 2864
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2864
		return {success = false, message = "session task is finalizing"} -- 2867
	end -- 2867
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2869
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2869
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2874
	end -- 2874
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2874
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2877
	end -- 2877
	local disabledAgentTools = __TS__ArrayFilter( -- 2879
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2879
		function(____, tool) return tool ~= "finish" end -- 2880
	) -- 2880
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2881
	return startPromptTask( -- 2884
		session, -- 2884
		prompt, -- 2884
		nil, -- 2884
		disabledAgentTools, -- 2884
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2884
	) -- 2884
end -- 2858
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2891
	local session = getSessionItem(sessionId) -- 2892
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2892
		return {success = false, message = "project task admission is closed"} -- 2893
	end -- 2893
	if not session then -- 2893
		return {success = false, message = "session not found"} -- 2895
	end -- 2895
	if getPendingQuestionnaire(sessionId) then -- 2895
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2897
	end -- 2897
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2897
		return {success = false, message = "session task is finalizing"} -- 2899
	end -- 2899
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2899
		return {success = false, message = "session task is still running"} -- 2902
	end -- 2902
	local message = getMessageItem(messageId) -- 2904
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2904
		return {success = false, message = "message not found"} -- 2906
	end -- 2906
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2908
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2914
	if latestUserMessageId ~= messageId then -- 2914
		return {success = false, message = "only the latest user prompt can be edited"} -- 2916
	end -- 2916
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2918
	if normalizedPrompt == "" then -- 2918
		return {success = false, message = "prompt is empty"} -- 2920
	end -- 2920
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2922
	if session.workMode ~= nextWorkMode then -- 2922
		DB:exec( -- 2924
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2924
			{ -- 2924
				nextWorkMode, -- 2924
				now(), -- 2924
				session.id -- 2924
			} -- 2924
		) -- 2924
		session.workMode = nextWorkMode -- 2925
	end -- 2925
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2927
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2928
	local result = startPromptTask( -- 2929
		session, -- 2929
		normalizedPrompt, -- 2929
		messageId, -- 2929
		normalizeDisabledAgentTools(disabledAgentTools), -- 2929
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2929
	) -- 2929
	if result.success and #removedStepIds > 0 then -- 2929
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2931
	end -- 2931
	return result -- 2933
end -- 2891
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2938
	if status == "dismissed" then -- 2938
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2944
	end -- 2944
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2946
end -- 2938
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2949
	if status == "dismissed" then -- 2949
		return { -- 2955
			success = true, -- 2956
			status = "dismissed", -- 2957
			source = "user", -- 2958
			questionnaireId = questionnaire.id, -- 2959
			title = questionnaire.schema.title, -- 2960
			answers = {}, -- 2961
			responses = {}, -- 2962
			displayText = "用户关闭了调查问卷，未作答。", -- 2963
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2964
		} -- 2964
	end -- 2964
	local responses = {} -- 2967
	do -- 2967
		local i = 0 -- 2968
		while i < #questionnaire.schema.questions do -- 2968
			do -- 2968
				local question = questionnaire.schema.questions[i + 1] -- 2969
				local answer = __TS__ArrayFind( -- 2970
					answers, -- 2970
					function(____, item) return item.questionId == question.id end -- 2970
				) -- 2970
				if not answer or answer.status == "skipped" then -- 2970
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2972
					goto __continue473 -- 2977
				end -- 2977
				local selectedOptionLabels = {} -- 2979
				do -- 2979
					local j = 0 -- 2980
					while j < #(answer.selectedOptionIds or ({})) do -- 2980
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2981
						local option = __TS__ArrayFind( -- 2982
							question.options or ({}), -- 2982
							function(____, item) return item.id == optionId end -- 2982
						) -- 2982
						if option then -- 2982
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2983
						end -- 2983
						j = j + 1 -- 2980
					end -- 2980
				end -- 2980
				responses[#responses + 1] = { -- 2985
					questionId = question.id, -- 2986
					prompt = question.prompt, -- 2987
					status = "answered", -- 2988
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2989
					selectedOptionLabels = selectedOptionLabels, -- 2990
					otherText = answer.otherText, -- 2991
					text = answer.text -- 2992
				} -- 2992
			end -- 2992
			::__continue473:: -- 2992
			i = i + 1 -- 2968
		end -- 2968
	end -- 2968
	return { -- 2995
		success = true, -- 2996
		status = "answered", -- 2997
		source = "user", -- 2998
		questionnaireId = questionnaire.id, -- 2999
		title = questionnaire.schema.title, -- 3000
		answers = answers, -- 3001
		responses = responses, -- 3002
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3003
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3004
	} -- 3004
end -- 2949
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3030
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3036
	local persisted = storage:readSessionState() -- 3037
	local messages = __TS__ArraySlice(persisted.messages) -- 3038
	local toolResultIndex = -1 -- 3039
	local existingResult -- 3040
	do -- 3040
		local i = #messages - 1 -- 3041
		while i >= 0 do -- 3041
			do -- 3041
				local message = messages[i + 1] -- 3042
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3042
					goto __continue493 -- 3043
				end -- 3043
				local decoded = safeJsonDecode(message.content) -- 3044
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3044
					goto __continue493 -- 3045
				end -- 3045
				local row = decoded -- 3046
				if row.questionnaireId ~= questionnaire.id then -- 3046
					goto __continue493 -- 3047
				end -- 3047
				toolResultIndex = i -- 3048
				existingResult = row -- 3049
				break -- 3050
			end -- 3050
			::__continue493:: -- 3050
			i = i - 1 -- 3041
		end -- 3041
	end -- 3041
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3052
	local guidance = {} -- 3053
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3053
		guidance[#guidance + 1] = existingResult.guidance -- 3055
	end -- 3055
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3055
		guidance[#guidance + 1] = result.guidance -- 3058
	end -- 3058
	result.guidance = table.concat(guidance, "\n") -- 3060
	if toolResultIndex < 0 then -- 3060
		messages[#messages + 1] = { -- 3062
			role = "user", -- 3063
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3064
		} -- 3064
		toolResultIndex = #messages - 1 -- 3066
	else -- 3066
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3068
			{}, -- 3068
			messages[toolResultIndex + 1], -- 3069
			{content = encodeJson(result)} -- 3068
		) -- 3068
	end -- 3068
	local pairStartIndex = toolResultIndex -- 3074
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3075
	if toolCallId and toolCallId ~= "" then -- 3075
		do -- 3075
			local i = toolResultIndex - 1 -- 3077
			while i >= 0 do -- 3077
				do -- 3077
					local message = messages[i + 1] -- 3078
					if message.role ~= "assistant" or not message.tool_calls then -- 3078
						goto __continue503 -- 3079
					end -- 3079
					if __TS__ArraySome( -- 3079
						message.tool_calls, -- 3080
						function(____, call) return call.id == toolCallId end -- 3080
					) then -- 3080
						pairStartIndex = i -- 3081
						break -- 3082
					end -- 3082
				end -- 3082
				::__continue503:: -- 3082
				i = i - 1 -- 3077
			end -- 3077
		end -- 3077
	end -- 3077
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3086
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3089
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3093
	upsertStep( -- 3095
		session.id, -- 3095
		questionnaire.taskId, -- 3095
		questionnaire.step, -- 3095
		"ask_user", -- 3095
		{status = "DONE", result = result} -- 3095
	) -- 3095
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3099
	upsertStep( -- 3100
		session.id, -- 3100
		questionnaire.taskId, -- 3100
		answerStep, -- 3100
		"questionnaire_answer", -- 3100
		{status = "DONE", result = result} -- 3100
	) -- 3100
	return {success = true, answerStep = answerStep, result = result} -- 3104
end -- 3030
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3107
	local session = getSessionItem(sessionId) -- 3108
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3108
		return {success = false, message = "project task admission is closed"} -- 3109
	end -- 3109
	if not session then -- 3109
		return {success = false, message = "session not found"} -- 3110
	end -- 3110
	if session.kind ~= "main" then -- 3110
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3111
	end -- 3111
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3112
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3112
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3114
	end -- 3114
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3116
	if not llmConfigRes.success then -- 3116
		return {success = false, message = llmConfigRes.message} -- 3117
	end -- 3117
	if not removePendingQuestionnaire(session) then -- 3117
		return {success = false, message = "failed to consume questionnaire file"} -- 3118
	end -- 3118
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3119
	if not replaced.success then -- 3119
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3121
		return replaced -- 3122
	end -- 3122
	local t = now() -- 3124
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3125
	session.workMode = "plan" -- 3126
	local result = startPromptTask( -- 3127
		session, -- 3127
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3127
		nil, -- 3127
		{}, -- 3127
		{ -- 3127
			workMode = "plan", -- 3128
			persistUserMessage = false, -- 3129
			resumeConversation = true, -- 3130
			existingTaskId = questionnaire.taskId, -- 3131
			initialStep = replaced.answerStep, -- 3132
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3133
			llmConfig = llmConfigRes.config -- 3134
		} -- 3134
	) -- 3134
	if not result.success then -- 3134
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3137
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3138
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3139
		emitAgentSessionPatch( -- 3140
			session.id, -- 3140
			{ -- 3140
				session = getSessionItem(session.id), -- 3141
				pendingQuestionnaire = questionnaire -- 3142
			} -- 3142
		) -- 3142
		return result -- 3144
	end -- 3144
	emitAgentSessionPatch( -- 3146
		sessionId, -- 3146
		{ -- 3146
			session = getSessionItem(sessionId), -- 3147
			pendingQuestionnaire = false -- 3148
		} -- 3148
	) -- 3148
	return result -- 3150
end -- 3107
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3153
	local session = getSessionItem(sessionId) -- 3154
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3154
		return {success = false, message = "project task admission is closed"} -- 3155
	end -- 3155
	if not session then -- 3155
		return {success = false, message = "session not found"} -- 3156
	end -- 3156
	if session.kind ~= "main" then -- 3156
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3157
	end -- 3157
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3158
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3158
		return {success = false, message = "pending questionnaire not found"} -- 3159
	end -- 3159
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3160
	if not validated.success then -- 3160
		return validated -- 3161
	end -- 3161
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3162
	if not llmConfigRes.success then -- 3162
		return {success = false, message = llmConfigRes.message} -- 3163
	end -- 3163
	local t = now() -- 3164
	if not removePendingQuestionnaire(session) then -- 3164
		return {success = false, message = "failed to consume questionnaire file"} -- 3165
	end -- 3165
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3166
	if not replaced.success then -- 3166
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3168
		return replaced -- 3169
	end -- 3169
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3171
	session.workMode = "plan" -- 3172
	local result = startPromptTask( -- 3173
		session, -- 3173
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3173
		nil, -- 3173
		{}, -- 3173
		{ -- 3173
			workMode = "plan", -- 3174
			persistUserMessage = false, -- 3175
			resumeConversation = true, -- 3176
			existingTaskId = questionnaire.taskId, -- 3177
			initialStep = replaced.answerStep, -- 3178
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3179
			llmConfig = llmConfigRes.config -- 3180
		} -- 3180
	) -- 3180
	if not result.success then -- 3180
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3183
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3184
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3185
		emitAgentSessionPatch( -- 3186
			session.id, -- 3186
			{ -- 3186
				session = getSessionItem(session.id), -- 3187
				pendingQuestionnaire = questionnaire -- 3188
			} -- 3188
		) -- 3188
		return result -- 3190
	end -- 3190
	emitAgentSessionPatch( -- 3192
		sessionId, -- 3192
		{ -- 3192
			session = getSessionItem(sessionId), -- 3193
			pendingQuestionnaire = false -- 3194
		} -- 3194
	) -- 3194
	return result -- 3196
end -- 3153
function ____exports.stopSessionTask(sessionId) -- 3199
	local session = getSessionItem(sessionId) -- 3200
	if not session or session.currentTaskId == nil then -- 3200
		return {success = false, message = "session task not found"} -- 3202
	end -- 3202
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3202
		return {success = false, message = "session task is finalizing"} -- 3205
	end -- 3205
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3207
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3208
	if localControl ~= nil then -- 3208
		localControl:stop() -- 3210
		return {success = true, stopping = true} -- 3211
	end -- 3211
	local stopToken = activeStopTokens[session.currentTaskId] -- 3213
	if stopToken == nil then -- 3213
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3213
			return {success = true, recovered = true} -- 3216
		end -- 3216
		return {success = false, message = "task is not running"} -- 3218
	end -- 3218
	if stopToken.stopped then -- 3218
		return {success = true, stopping = true} -- 3221
	end -- 3221
	stopToken.stopped = true -- 3223
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3224
	return {success = true, stopping = true} -- 3228
end -- 3199
function ____exports.getCurrentTaskId(sessionId) -- 3231
	local ____opt_123 = getSessionItem(sessionId) -- 3231
	return ____opt_123 and ____opt_123.currentTaskId -- 3232
end -- 3231
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3236
	local owner = getSessionItem(sessionId) -- 3237
	if not owner then -- 3237
		return {success = false, message = "session not found"} -- 3238
	end -- 3238
	local projectRoot = owner.projectRoot -- 3239
	local release = holdProjectTaskAdmission(projectRoot) -- 3240
	local closed = false -- 3241
	return { -- 3242
		success = true, -- 3243
		projectRoot = projectRoot, -- 3244
		close = function() -- 3245
			if not closed then -- 3245
				closed = true -- 3245
				release() -- 3245
			end -- 3245
		end, -- 3245
		poll = function() -- 3246
			if closed then -- 3246
				return {success = false, message = "quiescence handle closed"} -- 3247
			end -- 3247
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3248
			if not rows then -- 3248
				return {success = false, message = "failed to inspect project tasks"} -- 3249
			end -- 3249
			local pending = {} -- 3250
			for ____, row in ipairs(rows) do -- 3251
				do -- 3251
					local session = rowToSession(row) -- 3252
					local taskId = session.currentTaskId -- 3253
					if taskId == nil then -- 3253
						goto __continue541 -- 3254
					end -- 3254
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3255
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3255
						goto __continue541 -- 3256
					end -- 3256
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3258
					local ____session_id_126 = session.id -- 3259
					local ____taskId_127 = taskId -- 3259
					local ____finalizing_128 = finalizing -- 3259
					local ____result_success_129 = result.success -- 3259
					local ____result_success_125 -- 3259
					if result.success then -- 3259
						____result_success_125 = nil -- 3259
					else -- 3259
						____result_success_125 = result.message -- 3259
					end -- 3259
					pending[#pending + 1] = { -- 3259
						sessionId = ____session_id_126, -- 3259
						taskId = ____taskId_127, -- 3259
						finalizing = ____finalizing_128, -- 3259
						stopRequested = ____result_success_129, -- 3259
						message = ____result_success_125 -- 3259
					} -- 3259
				end -- 3259
				::__continue541:: -- 3259
			end -- 3259
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3263
		end -- 3246
	} -- 3246
end -- 3236
function ____exports.validateTaskAccess(sessionId, taskId) -- 3268
	local session = getSessionItem(sessionId) -- 3269
	if not session then -- 3269
		return {success = false, message = "session not found"} -- 3270
	end -- 3270
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3270
		getSessionOperableTaskIds(sessionId), -- 3271
		taskId -- 3271
	) < 0 then -- 3271
		return {success = false, message = "task is not operable for this session"} -- 3272
	end -- 3272
	return {success = true, session = session} -- 3274
end -- 3268
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3277
	if checkpointId <= 0 then -- 3277
		return {success = false, message = "invalid checkpointId"} -- 3279
	end -- 3279
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3281
	if not checkpoint then -- 3281
		return {success = false, message = "checkpoint not found"} -- 3283
	end -- 3283
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3285
	if not taskAccess.success then -- 3285
		return taskAccess -- 3286
	end -- 3286
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3287
end -- 3277
function ____exports.listRunningSessions() -- 3290
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3291
	local sessions = {} -- 3298
	do -- 3298
		local i = 0 -- 3299
		while i < #rows do -- 3299
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3300
			if session.currentTaskStatus == "RUNNING" then -- 3300
				sessions[#sessions + 1] = session -- 3302
			end -- 3302
			i = i + 1 -- 3299
		end -- 3299
	end -- 3299
	return {success = true, sessions = sessions} -- 3305
end -- 3290
return ____exports -- 3290